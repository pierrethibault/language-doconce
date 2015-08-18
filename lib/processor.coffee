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
        'source.gfm'
    ]

    process: (source) ->
        links = []
        for lineNum, line of source.split("\n")
            index = line.indexOf('#include')
            if index != -1
                firstIndex = line.indexOf('\"')
                lastIndex = line.lastIndexOf('\"')
                links.push({
                    fileName: line.substring(firstIndex+1, lastIndex)
                    range: [
                        [parseInt(lineNum), firstIndex+1],
                        [parseInt(lineNum), lastIndex]
                    ]
                    })
        return links

    followLink: (srcFilename, { fileName }) ->
        console.log("Follow link " + srcFilename)
        console.log(fileName)
        return fileName

    scanForDestination: (source, marker) ->
        for lineNum, line of source.split("\n")
            if line.indexOf('module.exports') != -1
                return [
                    lineNum
                    line.indexOf('module.exports')
                ]
        return undefined

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
