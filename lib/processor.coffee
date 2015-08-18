path = require('path')

module.exports = new class Processor
    # Fake requires for me to verify coffee-links as I work on it.
    _testRequire: ->
        require('./same')
        require('../parent')
        require('./something.coffee')
        require('sub-atom')
        # This will jump up to module.exports
        require('./processor')

    scopes: [
        'source.doconce'
    ]

    process: (source) ->
        links = []
        labels = []
        for lineNum, line of source.split("\n")
            index = line.indexOf('#include')
            if index != -1
                firstIndex = line.indexOf('\"')
                lastIndex = line.lastIndexOf('\"')
                links.push({
                    filename: line.substring(firstIndex+1, lastIndex)
                    range: [
                        [parseInt(lineNum), firstIndex+1],
                        [parseInt(lineNum), lastIndex]
                    ]
                    })
            index = line.indexOf('label{')
            if index != -1
                firstIndex = line.indexOf('{')
                lastIndex = line.lastIndexOf('}')
                labels.push({
                    label: line.substring(firstIndex+1, lastIndex)
                    dest: [
                        parseInt(lineNum) 
                        firstIndex
                    ]
                    })
        
        for lineNum, line of source.split("\n")
            index = line.indexOf('ref{')
            if index != -1
                firstIndex = line.indexOf('{')
                lastIndex = line.lastIndexOf('}')
                ref = line.substring(firstIndex+1, lastIndex)
                for label in labels
                    if ref == label.label     
                        links.push({
                            dest: label.dest
                            range: [
                                [parseInt(lineNum), firstIndex+1],
                                [parseInt(lineNum), lastIndex]
                            ]
                            })
        return links

    followLink: (srcFilename, link) ->
        console.log("Following link")
        if link.fileName
            return link.filename
        return srcFilename

    scanForDestination: (source, marker) ->
        return [
            marker.dest[0] 
            marker.dest[1]
        ]

    # Attached to the object so it can be mocked for tests
    _resolve: (modulePath, options) ->
        resolve = require('resolve').sync
        return resolve(modulePath, options)

    _processNode: (node, links = []) ->
        nodeName = (node) ->
            node?.base?.value

        # nodes don't always provide a name, so .isNew indicates that this
        # is probably a Call node.
        if node.isNew? and nodeName(node.variable) is 'require' and
                node.args?.length is 1

            { locationData } = node.args[0]
            links.push({
                # [1...-1] trims the quote characters
                moduleName: nodeName(node.args[0])[1...-1]
                range: [
                    [ locationData.first_line, locationData.first_column ],
                    [ locationData.last_line, locationData.last_column ]
                ]
            })

        node.eachChild (child) =>
            links = links.concat(@_processNode(child))

        return links
