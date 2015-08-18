describe "Doconce", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-doconce")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.doconce")

  it "parses the grammar", ->
    expect(grammar).toBeDefined()
    expect(grammar.scopeName).toBe "source.doconce"

  it "tokenizes spaces", ->
    {tokens} = grammar.tokenizeLine(" ")
    expect(tokens[0]).toEqual value: " ", scopes: ["source.doconce"]

  it "tokenizes horizontal rules", ->
    {tokens} = grammar.tokenizeLine("***")
    expect(tokens[0]).toEqual value: "***", scopes: ["source.doconce", "comment.hr.doconce"]

    {tokens} = grammar.tokenizeLine("---")
    expect(tokens[0]).toEqual value: "---", scopes: ["source.doconce", "comment.hr.doconce"]

  it "tokenizes escaped characters", ->
    {tokens} = grammar.tokenizeLine("\\*")
    expect(tokens[0]).toEqual value: "\\*", scopes: ["source.doconce", "constant.character.escape.doconce"]

    {tokens} = grammar.tokenizeLine("\\\\")
    expect(tokens[0]).toEqual value: "\\\\", scopes: ["source.doconce", "constant.character.escape.doconce"]

    {tokens} = grammar.tokenizeLine("\\abc")
    expect(tokens[0]).toEqual value: "\\a", scopes: ["source.doconce", "constant.character.escape.doconce"]
    expect(tokens[1]).toEqual value: "bc", scopes: ["source.doconce"]

  it "tokenizes ***bold italic*** text", ->
    {tokens} = grammar.tokenizeLine("this is ***bold italic*** text")
    expect(tokens[0]).toEqual value: "this is ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "***", scopes: ["source.doconce", "markup.bold.italic.doconce"]
    expect(tokens[2]).toEqual value: "bold italic", scopes: ["source.doconce", "markup.bold.italic.doconce"]
    expect(tokens[3]).toEqual value: "***", scopes: ["source.doconce", "markup.bold.italic.doconce"]
    expect(tokens[4]).toEqual value: " text", scopes: ["source.doconce"]

    [firstLineTokens, secondLineTokens] = grammar.tokenizeLines("this is ***bold\nitalic***!")
    expect(firstLineTokens[0]).toEqual value: "this is ", scopes: ["source.doconce"]
    expect(firstLineTokens[1]).toEqual value: "***", scopes: ["source.doconce", "markup.bold.italic.doconce"]
    expect(firstLineTokens[2]).toEqual value: "bold", scopes: ["source.doconce", "markup.bold.italic.doconce"]
    expect(secondLineTokens[0]).toEqual value: "italic", scopes: ["source.doconce", "markup.bold.italic.doconce"]
    expect(secondLineTokens[1]).toEqual value: "***", scopes: ["source.doconce", "markup.bold.italic.doconce"]
    expect(secondLineTokens[2]).toEqual value: "!", scopes: ["source.doconce"]

  it "tokenizes ___bold italic___ text", ->
    {tokens} = grammar.tokenizeLine("this is ___bold italic___ text")
    expect(tokens[0]).toEqual value: "this is ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "___", scopes: ["source.doconce", "markup.bold.italic.doconce"]
    expect(tokens[2]).toEqual value: "bold italic", scopes: ["source.doconce", "markup.bold.italic.doconce"]
    expect(tokens[3]).toEqual value: "___", scopes: ["source.doconce", "markup.bold.italic.doconce"]
    expect(tokens[4]).toEqual value: " text", scopes: ["source.doconce"]

    [firstLineTokens, secondLineTokens] = grammar.tokenizeLines("this is ___bold\nitalic___!")
    expect(firstLineTokens[0]).toEqual value: "this is ", scopes: ["source.doconce"]
    expect(firstLineTokens[1]).toEqual value: "___", scopes: ["source.doconce", "markup.bold.italic.doconce"]
    expect(firstLineTokens[2]).toEqual value: "bold", scopes: ["source.doconce", "markup.bold.italic.doconce"]
    expect(secondLineTokens[0]).toEqual value: "italic", scopes: ["source.doconce", "markup.bold.italic.doconce"]
    expect(secondLineTokens[1]).toEqual value: "___", scopes: ["source.doconce", "markup.bold.italic.doconce"]
    expect(secondLineTokens[2]).toEqual value: "!", scopes: ["source.doconce"]

  it "tokenizes **bold** text", ->
    {tokens} = grammar.tokenizeLine("**bold**")
    expect(tokens[0]).toEqual value: "**", scopes: ["source.doconce", "markup.bold.doconce"]
    expect(tokens[1]).toEqual value: "bold", scopes: ["source.doconce", "markup.bold.doconce"]
    expect(tokens[2]).toEqual value: "**", scopes: ["source.doconce", "markup.bold.doconce"]

    [firstLineTokens, secondLineTokens] = grammar.tokenizeLines("this is **bo\nld**!")
    expect(firstLineTokens[0]).toEqual value: "this is ", scopes: ["source.doconce"]
    expect(firstLineTokens[1]).toEqual value: "**", scopes: ["source.doconce", "markup.bold.doconce"]
    expect(firstLineTokens[2]).toEqual value: "bo", scopes: ["source.doconce", "markup.bold.doconce"]
    expect(secondLineTokens[0]).toEqual value: "ld", scopes: ["source.doconce", "markup.bold.doconce"]
    expect(secondLineTokens[1]).toEqual value: "**", scopes: ["source.doconce", "markup.bold.doconce"]
    expect(secondLineTokens[2]).toEqual value: "!", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("not**bold**")
    expect(tokens[0]).toEqual value: "not**bold**", scopes: ["source.doconce"]

  it "tokenizes __bold__ text", ->
    {tokens} = grammar.tokenizeLine("____")
    expect(tokens[0]).toEqual value: "____", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("__bold__")
    expect(tokens[0]).toEqual value: "__", scopes: ["source.doconce", "markup.bold.doconce"]
    expect(tokens[1]).toEqual value: "bold", scopes: ["source.doconce", "markup.bold.doconce"]
    expect(tokens[2]).toEqual value: "__", scopes: ["source.doconce", "markup.bold.doconce"]

    [firstLineTokens, secondLineTokens] = grammar.tokenizeLines("this is __bo\nld__!")
    expect(firstLineTokens[0]).toEqual value: "this is ", scopes: ["source.doconce"]
    expect(firstLineTokens[1]).toEqual value: "__", scopes: ["source.doconce", "markup.bold.doconce"]
    expect(firstLineTokens[2]).toEqual value: "bo", scopes: ["source.doconce", "markup.bold.doconce"]
    expect(secondLineTokens[0]).toEqual value: "ld", scopes: ["source.doconce", "markup.bold.doconce"]
    expect(secondLineTokens[1]).toEqual value: "__", scopes: ["source.doconce", "markup.bold.doconce"]
    expect(secondLineTokens[2]).toEqual value: "!", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("not__bold__")
    expect(tokens[0]).toEqual value: "not__bold__", scopes: ["source.doconce"]

  it "tokenizes *italic* text", ->
    {tokens} = grammar.tokenizeLine("**")
    expect(tokens[0]).toEqual value: "**", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("this is *italic* text")
    expect(tokens[0]).toEqual value: "this is ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "*", scopes: ["source.doconce", "markup.italic.doconce"]
    expect(tokens[2]).toEqual value: "italic", scopes: ["source.doconce", "markup.italic.doconce"]
    expect(tokens[3]).toEqual value: "*", scopes: ["source.doconce", "markup.italic.doconce"]
    expect(tokens[4]).toEqual value: " text", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("not*italic*")
    expect(tokens[0]).toEqual value: "not*italic*", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("* not italic")
    expect(tokens[0]).toEqual value: "*", scopes: ["source.doconce", "variable.unordered.list.doconce"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.doconce"]
    expect(tokens[2]).toEqual value: "not italic", scopes: ["source.doconce"]

    [firstLineTokens, secondLineTokens] = grammar.tokenizeLines("this is *ita\nlic*!")
    expect(firstLineTokens[0]).toEqual value: "this is ", scopes: ["source.doconce"]
    expect(firstLineTokens[1]).toEqual value: "*", scopes: ["source.doconce", "markup.italic.doconce"]
    expect(firstLineTokens[2]).toEqual value: "ita", scopes: ["source.doconce", "markup.italic.doconce"]
    expect(secondLineTokens[0]).toEqual value: "lic", scopes: ["source.doconce", "markup.italic.doconce"]
    expect(secondLineTokens[1]).toEqual value: "*", scopes: ["source.doconce", "markup.italic.doconce"]
    expect(secondLineTokens[2]).toEqual value: "!", scopes: ["source.doconce"]

  it "tokenizes _italic_ text", ->
    {tokens} = grammar.tokenizeLine("__")
    expect(tokens[0]).toEqual value: "__", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("this is _italic_ text")
    expect(tokens[0]).toEqual value: "this is ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "_", scopes: ["source.doconce", "markup.italic.doconce"]
    expect(tokens[2]).toEqual value: "italic", scopes: ["source.doconce", "markup.italic.doconce"]
    expect(tokens[3]).toEqual value: "_", scopes: ["source.doconce", "markup.italic.doconce"]
    expect(tokens[4]).toEqual value: " text", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("not_italic_")
    expect(tokens[0]).toEqual value: "not_italic_", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("not x^{a}_m y^{b}_n italic")
    expect(tokens[0]).toEqual value: "not x^{a}_m y^{b}_n italic", scopes: ["source.doconce"]

    [firstLineTokens, secondLineTokens] = grammar.tokenizeLines("this is _ita\nlic_!")
    expect(firstLineTokens[0]).toEqual value: "this is ", scopes: ["source.doconce"]
    expect(firstLineTokens[1]).toEqual value: "_", scopes: ["source.doconce", "markup.italic.doconce"]
    expect(firstLineTokens[2]).toEqual value: "ita", scopes: ["source.doconce", "markup.italic.doconce"]
    expect(secondLineTokens[0]).toEqual value: "lic", scopes: ["source.doconce", "markup.italic.doconce"]
    expect(secondLineTokens[1]).toEqual value: "_", scopes: ["source.doconce", "markup.italic.doconce"]
    expect(secondLineTokens[2]).toEqual value: "!", scopes: ["source.doconce"]

  it "tokenizes ~~strike~~ text", ->
    {tokens} = grammar.tokenizeLine("~~strike~~")
    expect(tokens[0]).toEqual value: "~~", scopes: ["source.doconce", "markup.strike.doconce"]
    expect(tokens[1]).toEqual value: "strike", scopes: ["source.doconce", "markup.strike.doconce"]
    expect(tokens[2]).toEqual value: "~~", scopes: ["source.doconce", "markup.strike.doconce"]

    [firstLineTokens, secondLineTokens] = grammar.tokenizeLines("this is ~~str\nike~~!")
    expect(firstLineTokens[0]).toEqual value: "this is ", scopes: ["source.doconce"]
    expect(firstLineTokens[1]).toEqual value: "~~", scopes: ["source.doconce", "markup.strike.doconce"]
    expect(firstLineTokens[2]).toEqual value: "str", scopes: ["source.doconce", "markup.strike.doconce"]
    expect(secondLineTokens[0]).toEqual value: "ike", scopes: ["source.doconce", "markup.strike.doconce"]
    expect(secondLineTokens[1]).toEqual value: "~~", scopes: ["source.doconce", "markup.strike.doconce"]
    expect(secondLineTokens[2]).toEqual value: "!", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("not~~strike~~")
    expect(tokens[0]).toEqual value: "not~~strike~~", scopes: ["source.doconce"]

  it "tokenizes headings", ->
    {tokens} = grammar.tokenizeLine("= Heading 1")
    expect(tokens[0]).toEqual value: "=", scopes: ["source.doconce", "markup.heading.heading-1.doconce", "markup.heading.marker.doconce"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.doconce", "markup.heading.heading-1.doconce", "markup.heading.space.doconce"]
    expect(tokens[2]).toEqual value: "Heading 1", scopes: ["source.doconce", "markup.heading.heading-1.doconce"]

    {tokens} = grammar.tokenizeLine("== Heading 2")
    expect(tokens[0]).toEqual value: "==", scopes: ["source.doconce", "markup.heading.heading-2.doconce", "markup.heading.marker.doconce"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.doconce", "markup.heading.heading-2.doconce", "markup.heading.space.doconce"]
    expect(tokens[2]).toEqual value: "Heading 2", scopes: ["source.doconce", "markup.heading.heading-2.doconce"]

    {tokens} = grammar.tokenizeLine("=== Heading 3")
    expect(tokens[0]).toEqual value: "===", scopes: ["source.doconce", "markup.heading.heading-3.doconce", "markup.heading.marker.doconce"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.doconce", "markup.heading.heading-3.doconce", "markup.heading.space.doconce"]
    expect(tokens[2]).toEqual value: "Heading 3", scopes: ["source.doconce", "markup.heading.heading-3.doconce"]

    {tokens} = grammar.tokenizeLine("==== Heading 4")
    expect(tokens[0]).toEqual value: "====", scopes: ["source.doconce", "markup.heading.heading-4.doconce", "markup.heading.marker.doconce"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.doconce", "markup.heading.heading-4.doconce", "markup.heading.space.doconce"]
    expect(tokens[2]).toEqual value: "Heading 4", scopes: ["source.doconce", "markup.heading.heading-4.doconce"]

    {tokens} = grammar.tokenizeLine("===== Heading 5")
    expect(tokens[0]).toEqual value: "=====", scopes: ["source.doconce", "markup.heading.heading-5.doconce", "markup.heading.marker.doconce"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.doconce", "markup.heading.heading-5.doconce", "markup.heading.space.doconce"]
    expect(tokens[2]).toEqual value: "Heading 5", scopes: ["source.doconce", "markup.heading.heading-5.doconce"]

    {tokens} = grammar.tokenizeLine("====== Heading 6")
    expect(tokens[0]).toEqual value: "======", scopes: ["source.doconce", "markup.heading.heading-6.doconce", "markup.heading.marker.doconce"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.doconce", "markup.heading.heading-6.doconce", "markup.heading.space.doconce"]
    expect(tokens[2]).toEqual value: "Heading 6", scopes: ["source.doconce", "markup.heading.heading-6.doconce"]

  it "tokenizes matches inside of headers", ->
    {tokens} = grammar.tokenizeLine("# Heading :one:")
    expect(tokens[0]).toEqual value: "#", scopes: ["source.doconce", "markup.heading.heading-1.doconce", "markup.heading.marker.doconce"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.doconce", "markup.heading.heading-1.doconce", "markup.heading.space.doconce"]
    expect(tokens[2]).toEqual value: "Heading ", scopes: ["source.doconce", "markup.heading.heading-1.doconce"]
    expect(tokens[3]).toEqual value: ":", scopes: ["source.doconce", "markup.heading.heading-1.doconce", "string.emoji.doconce", "string.emoji.start.doconce"]
    expect(tokens[4]).toEqual value: "one", scopes: ["source.doconce", "markup.heading.heading-1.doconce", "string.emoji.doconce", "string.emoji.word.doconce"]
    expect(tokens[5]).toEqual value: ":", scopes: ["source.doconce", "markup.heading.heading-1.doconce", "string.emoji.doconce", "string.emoji.end.doconce"]

  it "tokenizes an :emoji:", ->
    {tokens} = grammar.tokenizeLine("this is :no_good:")
    expect(tokens[0]).toEqual value: "this is ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: ":", scopes: ["source.doconce", "string.emoji.doconce", "string.emoji.start.doconce"]
    expect(tokens[2]).toEqual value: "no_good", scopes: ["source.doconce", "string.emoji.doconce", "string.emoji.word.doconce"]
    expect(tokens[3]).toEqual value: ":", scopes: ["source.doconce", "string.emoji.doconce", "string.emoji.end.doconce"]

    {tokens} = grammar.tokenizeLine("this is :no good:")
    expect(tokens[0]).toEqual value: "this is :no good:", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("http://localhost:8080")
    expect(tokens[0]).toEqual value: "http://localhost:8080", scopes: ["source.doconce"]

  it "tokenizes a ``` code block", ->
    {tokens, ruleStack} = grammar.tokenizeLine("```mylanguage")
    expect(tokens[0]).toEqual value: "```mylanguage", scopes: ["source.doconce", "markup.raw.doconce", "support.doconce"]
    {tokens, ruleStack} = grammar.tokenizeLine("-> 'hello'", ruleStack)
    expect(tokens[0]).toEqual value: "-> 'hello'", scopes: ["source.doconce", "markup.raw.doconce"]
    {tokens} = grammar.tokenizeLine("```", ruleStack)
    expect(tokens[0]).toEqual value: "```", scopes: ["source.doconce", "markup.raw.doconce", "support.doconce"]

  it "tokenizes a ~~~ code block", ->
    {tokens, ruleStack} = grammar.tokenizeLine("~~~mylanguage")
    expect(tokens[0]).toEqual value: "~~~mylanguage", scopes: ["source.doconce", "markup.raw.doconce", "support.doconce"]
    {tokens, ruleStack} = grammar.tokenizeLine("-> 'hello'", ruleStack)
    expect(tokens[0]).toEqual value: "-> 'hello'", scopes: ["source.doconce", "markup.raw.doconce"]
    {tokens} = grammar.tokenizeLine("~~~", ruleStack)
    expect(tokens[0]).toEqual value: "~~~", scopes: ["source.doconce", "markup.raw.doconce", "support.doconce"]

  it "tokenizes a ``` code block with trailing whitespace", ->
    {tokens, ruleStack} = grammar.tokenizeLine("```mylanguage")
    expect(tokens[0]).toEqual value: "```mylanguage", scopes: ["source.doconce", "markup.raw.doconce", "support.doconce"]
    {tokens, ruleStack} = grammar.tokenizeLine("-> 'hello'", ruleStack)
    expect(tokens[0]).toEqual value: "-> 'hello'", scopes: ["source.doconce", "markup.raw.doconce"]
    {tokens} = grammar.tokenizeLine("```  ", ruleStack)
    expect(tokens[0]).toEqual value: "```  ", scopes: ["source.doconce", "markup.raw.doconce", "support.doconce"]

  it "tokenizes a ~~~ code block with trailing whitespace", ->
    {tokens, ruleStack} = grammar.tokenizeLine("~~~mylanguage")
    expect(tokens[0]).toEqual value: "~~~mylanguage", scopes: ["source.doconce", "markup.raw.doconce", "support.doconce"]
    {tokens, ruleStack} = grammar.tokenizeLine("-> 'hello'", ruleStack)
    expect(tokens[0]).toEqual value: "-> 'hello'", scopes: ["source.doconce", "markup.raw.doconce"]
    {tokens} = grammar.tokenizeLine("~~~  ", ruleStack)
    expect(tokens[0]).toEqual value: "~~~  ", scopes: ["source.doconce", "markup.raw.doconce", "support.doconce"]

  it "tokenizes a ``` code block with a language", ->
    {tokens, ruleStack} = grammar.tokenizeLine("```  bash")
    expect(tokens[0]).toEqual value: "```  bash", scopes: ["source.doconce", "markup.code.shell.doconce",  "support.doconce"]

    {tokens, ruleStack} = grammar.tokenizeLine("```js  ")
    expect(tokens[0]).toEqual value: "```js  ", scopes: ["source.doconce", "markup.code.js.doconce",  "support.doconce"]

  it "tokenizes a ~~~ code block with a language", ->
    {tokens, ruleStack} = grammar.tokenizeLine("~~~  bash")
    expect(tokens[0]).toEqual value: "~~~  bash", scopes: ["source.doconce", "markup.code.shell.doconce",  "support.doconce"]

    {tokens, ruleStack} = grammar.tokenizeLine("~~~js  ")
    expect(tokens[0]).toEqual value: "~~~js  ", scopes: ["source.doconce", "markup.code.js.doconce",  "support.doconce"]

  it "tokenizes a ``` code block with a language and trailing whitespace", ->
    {tokens, ruleStack} = grammar.tokenizeLine("```  bash")
    {tokens} = grammar.tokenizeLine("```  ", ruleStack)
    expect(tokens[0]).toEqual value: "```  ", scopes: ["source.doconce", "markup.code.shell.doconce", "support.doconce"]

    {tokens, ruleStack} = grammar.tokenizeLine("```js  ")
    {tokens} = grammar.tokenizeLine("```  ", ruleStack)
    expect(tokens[0]).toEqual value: "```  ", scopes: ["source.doconce", "markup.code.js.doconce", "support.doconce"]

  it "tokenizes a ~~~ code block with a language and trailing whitespace", ->
    {tokens, ruleStack} = grammar.tokenizeLine("~~~  bash")
    {tokens} = grammar.tokenizeLine("~~~  ", ruleStack)
    expect(tokens[0]).toEqual value: "~~~  ", scopes: ["source.doconce", "markup.code.shell.doconce", "support.doconce"]

    {tokens, ruleStack} = grammar.tokenizeLine("~~~js  ")
    {tokens} = grammar.tokenizeLine("~~~  ", ruleStack)
    expect(tokens[0]).toEqual value: "~~~  ", scopes: ["source.doconce", "markup.code.js.doconce", "support.doconce"]

  it "tokenizes inline `code` blocks", ->
    {tokens} = grammar.tokenizeLine("`this` is `code`")
    expect(tokens[0]).toEqual value: "`", scopes: ["source.doconce", "markup.raw.doconce"]
    expect(tokens[1]).toEqual value: "this", scopes: ["source.doconce", "markup.raw.doconce"]
    expect(tokens[2]).toEqual value: "`", scopes: ["source.doconce", "markup.raw.doconce"]
    expect(tokens[3]).toEqual value: " is ", scopes: ["source.doconce"]
    expect(tokens[4]).toEqual value: "`", scopes: ["source.doconce", "markup.raw.doconce"]
    expect(tokens[5]).toEqual value: "code", scopes: ["source.doconce", "markup.raw.doconce"]
    expect(tokens[6]).toEqual value: "`", scopes: ["source.doconce", "markup.raw.doconce"]

    {tokens} = grammar.tokenizeLine("``")
    expect(tokens[0]).toEqual value: "`", scopes: ["source.doconce", "markup.raw.doconce"]
    expect(tokens[1]).toEqual value: "`", scopes: ["source.doconce", "markup.raw.doconce"]

    {tokens} = grammar.tokenizeLine("``a\\`b``")
    expect(tokens[0]).toEqual value: "``", scopes: ["source.doconce", "markup.raw.doconce"]
    expect(tokens[1]).toEqual value: "a\\`b", scopes: ["source.doconce", "markup.raw.doconce"]
    expect(tokens[2]).toEqual value: "``", scopes: ["source.doconce", "markup.raw.doconce"]

  it "tokenizes [links](links)", ->
    {tokens} = grammar.tokenizeLine("please click [this link](website)")
    expect(tokens[0]).toEqual value: "please click ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "[", scopes: ["source.doconce", "link", "punctuation.definition.begin.doconce"]
    expect(tokens[2]).toEqual value: "this link", scopes: ["source.doconce", "link", "entity.doconce"]
    expect(tokens[3]).toEqual value: "]", scopes: ["source.doconce", "link", "punctuation.definition.end.doconce"]
    expect(tokens[4]).toEqual value: "(", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.begin.doconce"]
    expect(tokens[5]).toEqual value: "website", scopes: ["source.doconce", "link", "markup.underline.link.doconce"]
    expect(tokens[6]).toEqual value: ")", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.end.doconce"]

  it "tokenizes reference [links][links]", ->
    {tokens} = grammar.tokenizeLine("please click [this link][website]")
    expect(tokens[0]).toEqual value: "please click ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "[", scopes: ["source.doconce", "link", "punctuation.definition.begin.doconce"]
    expect(tokens[2]).toEqual value: "this link", scopes: ["source.doconce", "link", "entity.doconce"]
    expect(tokens[3]).toEqual value: "]", scopes: ["source.doconce", "link", "punctuation.definition.end.doconce"]
    expect(tokens[4]).toEqual value: "[", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.begin.doconce"]
    expect(tokens[5]).toEqual value: "website", scopes: ["source.doconce", "link", "markup.underline.link.doconce"]
    expect(tokens[6]).toEqual value: "]", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.end.doconce"]

  it "tokenizes id-less reference [links][]", ->
    {tokens} = grammar.tokenizeLine("please click [this link][]")
    expect(tokens[0]).toEqual value: "please click ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "[", scopes: ["source.doconce", "link", "punctuation.definition.begin.doconce"]
    expect(tokens[2]).toEqual value: "this link", scopes: ["source.doconce", "link", "entity.doconce"]
    expect(tokens[3]).toEqual value: "]", scopes: ["source.doconce", "link", "punctuation.definition.end.doconce"]
    expect(tokens[4]).toEqual value: "[", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.begin.doconce"]
    expect(tokens[5]).toEqual value: "]", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.end.doconce"]

  it "tokenizes [link]: footers", ->
    {tokens} = grammar.tokenizeLine("[aLink]: http://website")
    expect(tokens[0]).toEqual value: "[", scopes: ["source.doconce", "link", "punctuation.definition.begin.doconce"]
    expect(tokens[1]).toEqual value: "aLink", scopes: ["source.doconce", "link", "entity.doconce"]
    expect(tokens[2]).toEqual value: "]", scopes: ["source.doconce", "link", "punctuation.definition.end.doconce"]
    expect(tokens[3]).toEqual value: ":", scopes: ["source.doconce", "link", "punctuation.separator.key-value.doconce"]
    expect(tokens[4]).toEqual value: " ", scopes: ["source.doconce", "link"]
    expect(tokens[5]).toEqual value: "http://website", scopes: ["source.doconce", "link", "markup.underline.link.doconce"]

  it "tokenizes [link]: <footers>", ->
    {tokens} = grammar.tokenizeLine("[aLink]: <http://website>")
    expect(tokens[0]).toEqual value: "[", scopes: ["source.doconce", "link", "punctuation.definition.begin.doconce"]
    expect(tokens[1]).toEqual value: "aLink", scopes: ["source.doconce", "link", "entity.doconce"]
    expect(tokens[2]).toEqual value: "]", scopes: ["source.doconce", "link", "punctuation.definition.end.doconce"]
    expect(tokens[3]).toEqual value: ": <", scopes: ["source.doconce", "link"]
    expect(tokens[4]).toEqual value: "http://website", scopes: ["source.doconce", "link", "markup.underline.link.doconce"]
    expect(tokens[5]).toEqual value: ">", scopes: ["source.doconce", "link"]

  it "tokenizes [![links](links)](links)", ->
    {tokens} = grammar.tokenizeLine("[![title](image)](link)")
    expect(tokens[0]).toEqual value: "[!", scopes: ["source.doconce", "link", "punctuation.definition.begin.doconce"]
    expect(tokens[1]).toEqual value: "[", scopes: ["source.doconce", "link", "punctuation.definition.begin.doconce"]
    expect(tokens[2]).toEqual value: "title", scopes: ["source.doconce", "link", "entity.doconce"]
    expect(tokens[3]).toEqual value: "]", scopes: ["source.doconce", "link", "punctuation.definition.end.doconce"]
    expect(tokens[4]).toEqual value: "(", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.begin.doconce"]
    expect(tokens[5]).toEqual value: "image", scopes: ["source.doconce", "link", "markup.underline.link.doconce"]
    expect(tokens[6]).toEqual value: ")", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.end.doconce"]
    expect(tokens[7]).toEqual value: "]", scopes: ["source.doconce", "link", "punctuation.definition.end.doconce"]
    expect(tokens[8]).toEqual value: "(", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.begin.doconce"]
    expect(tokens[9]).toEqual value: "link", scopes: ["source.doconce", "link", "markup.underline.link.doconce"]
    expect(tokens[10]).toEqual value: ")", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.end.doconce"]

  it "tokenizes [![links](links)][links]", ->
    {tokens} = grammar.tokenizeLine("[![title](image)][link]")
    expect(tokens[0]).toEqual value: "[!", scopes: ["source.doconce", "link", "punctuation.definition.begin.doconce"]
    expect(tokens[1]).toEqual value: "[", scopes: ["source.doconce", "link", "punctuation.definition.begin.doconce"]
    expect(tokens[2]).toEqual value: "title", scopes: ["source.doconce", "link", "entity.doconce"]
    expect(tokens[3]).toEqual value: "]", scopes: ["source.doconce", "link", "punctuation.definition.end.doconce"]
    expect(tokens[4]).toEqual value: "(", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.begin.doconce"]
    expect(tokens[5]).toEqual value: "image", scopes: ["source.doconce", "link", "markup.underline.link.doconce"]
    expect(tokens[6]).toEqual value: ")", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.end.doconce"]
    expect(tokens[7]).toEqual value: "]", scopes: ["source.doconce", "link", "punctuation.definition.end.doconce"]
    expect(tokens[8]).toEqual value: "[", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.begin.doconce"]
    expect(tokens[9]).toEqual value: "link", scopes: ["source.doconce", "link", "markup.underline.link.doconce"]
    expect(tokens[10]).toEqual value: "]", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.end.doconce"]

  it "tokenizes [![links][links]](links)", ->
    {tokens} = grammar.tokenizeLine("[![title][image]](link)")
    expect(tokens[0]).toEqual value: "[!", scopes: ["source.doconce", "link", "punctuation.definition.begin.doconce"]
    expect(tokens[1]).toEqual value: "[", scopes: ["source.doconce", "link", "punctuation.definition.begin.doconce"]
    expect(tokens[2]).toEqual value: "title", scopes: ["source.doconce", "link", "entity.doconce"]
    expect(tokens[3]).toEqual value: "]", scopes: ["source.doconce", "link", "punctuation.definition.end.doconce"]
    expect(tokens[4]).toEqual value: "[", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.begin.doconce"]
    expect(tokens[5]).toEqual value: "image", scopes: ["source.doconce", "link", "markup.underline.link.doconce"]
    expect(tokens[6]).toEqual value: "]", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.end.doconce"]
    expect(tokens[7]).toEqual value: "]", scopes: ["source.doconce", "link", "punctuation.definition.end.doconce"]
    expect(tokens[8]).toEqual value: "(", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.begin.doconce"]
    expect(tokens[9]).toEqual value: "link", scopes: ["source.doconce", "link", "markup.underline.link.doconce"]
    expect(tokens[10]).toEqual value: ")", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.end.doconce"]

  it "tokenizes [![links][links]][links]", ->
    {tokens} = grammar.tokenizeLine("[![title][image]][link]")
    expect(tokens[0]).toEqual value: "[!", scopes: ["source.doconce", "link", "punctuation.definition.begin.doconce"]
    expect(tokens[1]).toEqual value: "[", scopes: ["source.doconce", "link", "punctuation.definition.begin.doconce"]
    expect(tokens[2]).toEqual value: "title", scopes: ["source.doconce", "link", "entity.doconce"]
    expect(tokens[3]).toEqual value: "]", scopes: ["source.doconce", "link", "punctuation.definition.end.doconce"]
    expect(tokens[4]).toEqual value: "[", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.begin.doconce"]
    expect(tokens[5]).toEqual value: "image", scopes: ["source.doconce", "link", "markup.underline.link.doconce"]
    expect(tokens[6]).toEqual value: "]", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.end.doconce"]
    expect(tokens[7]).toEqual value: "]", scopes: ["source.doconce", "link", "punctuation.definition.end.doconce"]
    expect(tokens[8]).toEqual value: "[", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.begin.doconce"]
    expect(tokens[9]).toEqual value: "link", scopes: ["source.doconce", "link", "markup.underline.link.doconce"]
    expect(tokens[10]).toEqual value: "]", scopes: ["source.doconce", "link", "markup.underline.link.doconce", "punctuation.definition.end.doconce"]

  it "tokenizes mentions", ->
    {tokens} = grammar.tokenizeLine("sentence with no space before@name ")
    expect(tokens[0]).toEqual value: "sentence with no space before@name ", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("@name '@name' @name's @name. @name, (@name) [@name]")
    expect(tokens[0]).toEqual value: "@", scopes: ["source.doconce", "variable.mention.doconce"]
    expect(tokens[1]).toEqual value: "name", scopes: ["source.doconce", "string.username.doconce"]
    expect(tokens[2]).toEqual value: " '", scopes: ["source.doconce"]
    expect(tokens[3]).toEqual value: "@", scopes: ["source.doconce", "variable.mention.doconce"]
    expect(tokens[4]).toEqual value: "name", scopes: ["source.doconce", "string.username.doconce"]
    expect(tokens[5]).toEqual value: "' ", scopes: ["source.doconce"]
    expect(tokens[6]).toEqual value: "@", scopes: ["source.doconce", "variable.mention.doconce"]
    expect(tokens[7]).toEqual value: "name", scopes: ["source.doconce", "string.username.doconce"]
    expect(tokens[8]).toEqual value: "'s ", scopes: ["source.doconce"]
    expect(tokens[9]).toEqual value: "@", scopes: ["source.doconce", "variable.mention.doconce"]
    expect(tokens[10]).toEqual value: "name", scopes: ["source.doconce", "string.username.doconce"]
    expect(tokens[11]).toEqual value: ". ", scopes: ["source.doconce"]
    expect(tokens[12]).toEqual value: "@", scopes: ["source.doconce", "variable.mention.doconce"]
    expect(tokens[13]).toEqual value: "name", scopes: ["source.doconce", "string.username.doconce"]
    expect(tokens[14]).toEqual value: ", (", scopes: ["source.doconce"]
    expect(tokens[15]).toEqual value: "@", scopes: ["source.doconce", "variable.mention.doconce"]
    expect(tokens[16]).toEqual value: "name", scopes: ["source.doconce", "string.username.doconce"]
    expect(tokens[17]).toEqual value: ") [", scopes: ["source.doconce"]
    expect(tokens[18]).toEqual value: "@", scopes: ["source.doconce", "variable.mention.doconce"]
    expect(tokens[19]).toEqual value: "name", scopes: ["source.doconce", "string.username.doconce"]
    expect(tokens[20]).toEqual value: "]", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine('"@name"')
    expect(tokens[0]).toEqual value: '"', scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "@", scopes: ["source.doconce", "variable.mention.doconce"]
    expect(tokens[2]).toEqual value: "name", scopes: ["source.doconce", "string.username.doconce"]
    expect(tokens[3]).toEqual value: '"', scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("sentence with a space before @name/ and an invalid symbol after")
    expect(tokens[0]).toEqual value: "sentence with a space before @name/ and an invalid symbol after", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("sentence with a space before @name that continues")
    expect(tokens[0]).toEqual value: "sentence with a space before ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "@", scopes: ["source.doconce", "variable.mention.doconce"]
    expect(tokens[2]).toEqual value: "name", scopes: ["source.doconce", "string.username.doconce"]
    expect(tokens[3]).toEqual value: " that continues", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("* @name at the start of an unordered list")
    expect(tokens[0]).toEqual value: "*", scopes: ["source.doconce", "variable.unordered.list.doconce"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.doconce"]
    expect(tokens[2]).toEqual value: "@", scopes: ["source.doconce", "variable.mention.doconce"]
    expect(tokens[3]).toEqual value: "name", scopes: ["source.doconce", "string.username.doconce"]
    expect(tokens[4]).toEqual value: " at the start of an unordered list", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("a username @1337_hubot with numbers, letters and underscores")
    expect(tokens[0]).toEqual value: "a username ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "@", scopes: ["source.doconce", "variable.mention.doconce"]
    expect(tokens[2]).toEqual value: "1337_hubot", scopes: ["source.doconce", "string.username.doconce"]
    expect(tokens[3]).toEqual value: " with numbers, letters and underscores", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("a username @1337-hubot with numbers, letters and hyphens")
    expect(tokens[0]).toEqual value: "a username ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "@", scopes: ["source.doconce", "variable.mention.doconce"]
    expect(tokens[2]).toEqual value: "1337-hubot", scopes: ["source.doconce", "string.username.doconce"]
    expect(tokens[3]).toEqual value: " with numbers, letters and hyphens", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("@name at the start of a line")
    expect(tokens[0]).toEqual value: "@", scopes: ["source.doconce", "variable.mention.doconce"]
    expect(tokens[1]).toEqual value: "name", scopes: ["source.doconce", "string.username.doconce"]
    expect(tokens[2]).toEqual value: " at the start of a line", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("any email like you@domain.com shouldn't mistakenly be matched as a mention")
    expect(tokens[0]).toEqual value: "any email like you@domain.com shouldn't mistakenly be matched as a mention", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("@person's")
    expect(tokens[0]).toEqual value: "@", scopes: ["source.doconce", "variable.mention.doconce"]
    expect(tokens[1]).toEqual value: "person", scopes: ["source.doconce", "string.username.doconce"]
    expect(tokens[2]).toEqual value: "'s", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("@person;")
    expect(tokens[0]).toEqual value: "@", scopes: ["source.doconce", "variable.mention.doconce"]
    expect(tokens[1]).toEqual value: "person", scopes: ["source.doconce", "string.username.doconce"]
    expect(tokens[2]).toEqual value: ";", scopes: ["source.doconce"]

  it "tokenizes issue numbers", ->
    {tokens} = grammar.tokenizeLine("sentence with no space before#12 ")
    expect(tokens[0]).toEqual value: "sentence with no space before#12 ", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine(" #101 '#101' #101's #101. #101, (#101) [#101]")
    expect(tokens[1]).toEqual value: "#", scopes: ["source.doconce", "variable.issue.tag.doconce"]
    expect(tokens[2]).toEqual value: "101", scopes: ["source.doconce", "string.issue.number.doconce"]
    expect(tokens[3]).toEqual value: " '", scopes: ["source.doconce"]
    expect(tokens[4]).toEqual value: "#", scopes: ["source.doconce", "variable.issue.tag.doconce"]
    expect(tokens[5]).toEqual value: "101", scopes: ["source.doconce", "string.issue.number.doconce"]
    expect(tokens[6]).toEqual value: "' ", scopes: ["source.doconce"]
    expect(tokens[7]).toEqual value: "#", scopes: ["source.doconce", "variable.issue.tag.doconce"]
    expect(tokens[8]).toEqual value: "101", scopes: ["source.doconce", "string.issue.number.doconce"]
    expect(tokens[9]).toEqual value: "'s ", scopes: ["source.doconce"]
    expect(tokens[10]).toEqual value: "#", scopes: ["source.doconce", "variable.issue.tag.doconce"]
    expect(tokens[11]).toEqual value: "101", scopes: ["source.doconce", "string.issue.number.doconce"]
    expect(tokens[12]).toEqual value: ". ", scopes: ["source.doconce"]
    expect(tokens[13]).toEqual value: "#", scopes: ["source.doconce", "variable.issue.tag.doconce"]
    expect(tokens[14]).toEqual value: "101", scopes: ["source.doconce", "string.issue.number.doconce"]
    expect(tokens[15]).toEqual value: ", (", scopes: ["source.doconce"]
    expect(tokens[16]).toEqual value: "#", scopes: ["source.doconce", "variable.issue.tag.doconce"]
    expect(tokens[17]).toEqual value: "101", scopes: ["source.doconce", "string.issue.number.doconce"]
    expect(tokens[18]).toEqual value: ") [", scopes: ["source.doconce"]
    expect(tokens[19]).toEqual value: "#", scopes: ["source.doconce", "variable.issue.tag.doconce"]
    expect(tokens[20]).toEqual value: "101", scopes: ["source.doconce", "string.issue.number.doconce"]
    expect(tokens[21]).toEqual value: "]", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine('"#101"')
    expect(tokens[0]).toEqual value: '"', scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "#", scopes: ["source.doconce", "variable.issue.tag.doconce"]
    expect(tokens[2]).toEqual value: "101", scopes: ["source.doconce", "string.issue.number.doconce"]
    expect(tokens[3]).toEqual value: '"', scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("sentence with a space before #123i and a character after")
    expect(tokens[0]).toEqual value: "sentence with a space before #123i and a character after", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("sentence with a space before #123 that continues")
    expect(tokens[0]).toEqual value: "sentence with a space before ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "#", scopes: ["source.doconce", "variable.issue.tag.doconce"]
    expect(tokens[2]).toEqual value: "123", scopes: ["source.doconce", "string.issue.number.doconce"]
    expect(tokens[3]).toEqual value: " that continues", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine(" #123's")
    expect(tokens[1]).toEqual value: "#", scopes: ["source.doconce", "variable.issue.tag.doconce"]
    expect(tokens[2]).toEqual value: "123", scopes: ["source.doconce", "string.issue.number.doconce"]
    expect(tokens[3]).toEqual value: "'s", scopes: ["source.doconce"]

  it "tokenizes unordered lists", ->
    {tokens} = grammar.tokenizeLine("*Item 1")
    expect(tokens[0]).not.toEqual value: "*Item 1", scopes: ["source.doconce", "variable.unordered.list.doconce"]

    {tokens} = grammar.tokenizeLine("  * Item 1")
    expect(tokens[0]).toEqual value: "  ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "*", scopes: ["source.doconce", "variable.unordered.list.doconce"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.doconce"]
    expect(tokens[3]).toEqual value: "Item 1", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("  + Item 2")
    expect(tokens[0]).toEqual value: "  ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "+", scopes: ["source.doconce", "variable.unordered.list.doconce"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.doconce"]
    expect(tokens[3]).toEqual value: "Item 2", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("  - Item 3")
    expect(tokens[0]).toEqual value: "  ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "-", scopes: ["source.doconce", "variable.unordered.list.doconce"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.doconce"]
    expect(tokens[3]).toEqual value: "Item 3", scopes: ["source.doconce"]

  it "tokenizes ordered lists", ->
    {tokens} = grammar.tokenizeLine("1.First Item")
    expect(tokens[0]).toEqual value: "1.First Item", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("  1. First Item")
    expect(tokens[0]).toEqual value: "  ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "1.", scopes: ["source.doconce", "variable.ordered.list.doconce"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.doconce"]
    expect(tokens[3]).toEqual value: "First Item", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("  10. Tenth Item")
    expect(tokens[0]).toEqual value: "  ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "10.", scopes: ["source.doconce", "variable.ordered.list.doconce"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.doconce"]
    expect(tokens[3]).toEqual value: "Tenth Item", scopes: ["source.doconce"]

    {tokens} = grammar.tokenizeLine("  111. Hundred and eleventh item")
    expect(tokens[0]).toEqual value: "  ", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "111.", scopes: ["source.doconce", "variable.ordered.list.doconce"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.doconce"]
    expect(tokens[3]).toEqual value: "Hundred and eleventh item", scopes: ["source.doconce"]

  it "tokenizes > quoted text", ->
    {tokens} = grammar.tokenizeLine("> Quotation :+1:")
    expect(tokens[0]).toEqual value: ">", scopes: ["source.doconce", "comment.quote.doconce", "support.quote.doconce"]
    expect(tokens[1]).toEqual value: " Quotation ", scopes: ["source.doconce", "comment.quote.doconce"]
    expect(tokens[2]).toEqual value: ":", scopes: ["source.doconce", "comment.quote.doconce", "string.emoji.doconce", "string.emoji.start.doconce"]
    expect(tokens[3]).toEqual value: "+1", scopes: ["source.doconce", "comment.quote.doconce", "string.emoji.doconce", "string.emoji.word.doconce"]
    expect(tokens[4]).toEqual value: ":", scopes: ["source.doconce", "comment.quote.doconce", "string.emoji.doconce", "string.emoji.end.doconce"]

  it "tokenizes HTML entities", ->
    {tokens} = grammar.tokenizeLine("&trade; &#8482; &a1; &#xb3;")
    expect(tokens[0]).toEqual value: "&", scopes: ["source.doconce", "constant.character.entity.doconce", "punctuation.definition.entity.doconce"]
    expect(tokens[1]).toEqual value: "trade", scopes: ["source.doconce", "constant.character.entity.doconce"]
    expect(tokens[2]).toEqual value: ";", scopes: ["source.doconce", "constant.character.entity.doconce", "punctuation.definition.entity.doconce"]

    expect(tokens[3]).toEqual value: " ", scopes: ["source.doconce"]

    expect(tokens[4]).toEqual value: "&", scopes: ["source.doconce", "constant.character.entity.doconce", "punctuation.definition.entity.doconce"]
    expect(tokens[5]).toEqual value: "#8482", scopes: ["source.doconce", "constant.character.entity.doconce"]
    expect(tokens[6]).toEqual value: ";", scopes: ["source.doconce", "constant.character.entity.doconce", "punctuation.definition.entity.doconce"]

    expect(tokens[7]).toEqual value: " ", scopes: ["source.doconce"]

    expect(tokens[8]).toEqual value: "&", scopes: ["source.doconce", "constant.character.entity.doconce", "punctuation.definition.entity.doconce"]
    expect(tokens[9]).toEqual value: "a1", scopes: ["source.doconce", "constant.character.entity.doconce"]
    expect(tokens[10]).toEqual value: ";", scopes: ["source.doconce", "constant.character.entity.doconce", "punctuation.definition.entity.doconce"]

    expect(tokens[11]).toEqual value: " ", scopes: ["source.doconce"]

    expect(tokens[12]).toEqual value: "&", scopes: ["source.doconce", "constant.character.entity.doconce", "punctuation.definition.entity.doconce"]
    expect(tokens[13]).toEqual value: "#xb3", scopes: ["source.doconce", "constant.character.entity.doconce"]
    expect(tokens[14]).toEqual value: ";", scopes: ["source.doconce", "constant.character.entity.doconce", "punctuation.definition.entity.doconce"]

  it "tokenizes HTML comments", ->
    {tokens} = grammar.tokenizeLine("<!-- a comment -->")
    expect(tokens[0]).toEqual value: "<!--", scopes: ["source.doconce", "comment.block.doconce", "punctuation.definition.comment.doconce"]
    expect(tokens[1]).toEqual value: " a comment ", scopes: ["source.doconce", "comment.block.doconce"]
    expect(tokens[2]).toEqual value: "-->", scopes: ["source.doconce", "comment.block.doconce", "punctuation.definition.comment.doconce"]

  it "tokenizes YAML front matter", ->
    [firstLineTokens, secondLineTokens, thirdLineTokens] = grammar.tokenizeLines """
      ---
      front: matter
      ---
    """

    expect(firstLineTokens[0]).toEqual value: "---", scopes: ["source.doconce", "front-matter.yaml.doconce", "comment.hr.doconce"]
    expect(secondLineTokens[0]).toEqual value: "front: matter", scopes: ["source.doconce", "front-matter.yaml.doconce"]
    expect(thirdLineTokens[0]).toEqual value: "---", scopes: ["source.doconce", "front-matter.yaml.doconce", "comment.hr.doconce"]

  it "tokenizes linebreaks", ->
    {tokens} = grammar.tokenizeLine("line  ")
    expect(tokens[0]).toEqual value: "line", scopes: ["source.doconce"]
    expect(tokens[1]).toEqual value: "  ", scopes: ["source.doconce", "linebreak.doconce"]

  it "tokenizes tables", ->
    [headerTokens, alignTokens, contentTokens] = grammar.tokenizeLines """
    | Column 1  | Column 2  |
    |:----------|:---------:|
    | Content 1 | Content 2 |
    """

    # Header line
    expect(headerTokens[0]).toEqual value: "|", scopes: ["source.doconce", "table.doconce", "border.pipe.outer"]
    expect(headerTokens[1]).toEqual value: " Column 1  ", scopes: ["source.doconce", "table.doconce"]
    expect(headerTokens[2]).toEqual value: "|", scopes: ["source.doconce", "table.doconce", "border.pipe.inner"]
    expect(headerTokens[3]).toEqual value: " Column 2  ", scopes: ["source.doconce", "table.doconce"]
    expect(headerTokens[4]).toEqual value: "|", scopes: ["source.doconce", "table.doconce", "border.pipe.outer"]

    # Alignment line
    expect(alignTokens[0]).toEqual value: "|", scopes: ["source.doconce", "table.doconce", "border.pipe.outer"]
    expect(alignTokens[1]).toEqual value: ":", scopes: ["source.doconce", "table.doconce", "border.alignment"]
    expect(alignTokens[2]).toEqual value: "----------", scopes: ["source.doconce", "table.doconce", "border.header"]
    expect(alignTokens[3]).toEqual value: "|", scopes: ["source.doconce", "table.doconce", "border.pipe.inner"]
    expect(alignTokens[4]).toEqual value: ":", scopes: ["source.doconce", "table.doconce", "border.alignment"]
    expect(alignTokens[5]).toEqual value: "---------", scopes: ["source.doconce", "table.doconce", "border.header"]
    expect(alignTokens[6]).toEqual value: ":", scopes: ["source.doconce", "table.doconce", "border.alignment"]
    expect(alignTokens[7]).toEqual value: "|", scopes: ["source.doconce", "table.doconce", "border.pipe.outer"]

    # Content line
    expect(contentTokens[0]).toEqual value: "|", scopes: ["source.doconce", "table.doconce", "border.pipe.outer"]
    expect(contentTokens[1]).toEqual value: " Content 1 ", scopes: ["source.doconce", "table.doconce"]
    expect(contentTokens[2]).toEqual value: "|", scopes: ["source.doconce", "table.doconce", "border.pipe.inner"]
    expect(contentTokens[3]).toEqual value: " Content 2 ", scopes: ["source.doconce", "table.doconce"]
    expect(contentTokens[4]).toEqual value: "|", scopes: ["source.doconce", "table.doconce", "border.pipe.outer"]

    [headerTokens, emptyLineTokens, headingTokens] = grammar.tokenizeLines """
    | Column 1  | Column 2\t

    # Heading
    """

    expect(headerTokens[0]).toEqual value: "|", scopes: ["source.doconce", "table.doconce", "border.pipe.outer"]
    expect(headerTokens[1]).toEqual value: " Column 1  ", scopes: ["source.doconce", "table.doconce"]
    expect(headerTokens[2]).toEqual value: "|", scopes: ["source.doconce", "table.doconce", "border.pipe.inner"]
    expect(headerTokens[3]).toEqual value: " Column 2", scopes: ["source.doconce", "table.doconce"]
    expect(headerTokens[4]).toEqual value: "\t", scopes: ["source.doconce", "table.doconce"]

    expect(headingTokens[0]).toEqual value: "#", scopes: ["source.doconce", "markup.heading.heading-1.doconce", "markup.heading.marker.doconce"]
    expect(headingTokens[1]).toEqual value: " ", scopes: ["source.doconce", "markup.heading.heading-1.doconce", "markup.heading.space.doconce"]
    expect(headingTokens[2]).toEqual value: "Heading", scopes: ["source.doconce", "markup.heading.heading-1.doconce"]

  it "tokenizes criticmarkup", ->
    [addToken, delToken, hlToken, subToken] = grammar.tokenizeLines """
    Add{++ some text++}
    Delete{-- some text--}
    Highlight {==some text==}{>>with comment<<}
    Replace {~~this~>by that~~}
    """
    # Addition
    expect(addToken[0]).toEqual value: "Add", scopes: ["source.doconce"]
    expect(addToken[1]).toEqual value: "{++", scopes: ["source.doconce", "critic.doconce.addition", "critic.doconce.addition.marker"]
    expect(addToken[2]).toEqual value: " some text", scopes: ["source.doconce", "critic.doconce.addition"]
    expect(addToken[3]).toEqual value: "++}", scopes: ["source.doconce", "critic.doconce.addition", "critic.doconce.addition.marker"]
    # Deletion
    expect(delToken[0]).toEqual value: "Delete", scopes: ["source.doconce"]
    expect(delToken[1]).toEqual value: "{--", scopes: ["source.doconce", "critic.doconce.deletion", "critic.doconce.deletion.marker"]
    expect(delToken[2]).toEqual value: " some text", scopes: ["source.doconce", "critic.doconce.deletion"]
    expect(delToken[3]).toEqual value: "--}", scopes: ["source.doconce", "critic.doconce.deletion", "critic.doconce.deletion.marker"]
    # Comment and highlight
    expect(hlToken[0]).toEqual value: "Highlight ", scopes: ["source.doconce"]
    expect(hlToken[1]).toEqual value: "{==", scopes: ["source.doconce", "critic.doconce.highlight", "critic.doconce.highlight.marker"]
    expect(hlToken[2]).toEqual value: "some text", scopes: ["source.doconce", "critic.doconce.highlight"]
    expect(hlToken[3]).toEqual value: "==}", scopes: ["source.doconce", "critic.doconce.highlight", "critic.doconce.highlight.marker"]
    expect(hlToken[4]).toEqual value: "{>>", scopes: ["source.doconce", "critic.doconce.comment", "critic.doconce.comment.marker"]
    expect(hlToken[5]).toEqual value: "with comment", scopes: ["source.doconce", "critic.doconce.comment"]
    expect(hlToken[6]).toEqual value: "<<}", scopes: ["source.doconce", "critic.doconce.comment", "critic.doconce.comment.marker"]
    # Replace
    expect(subToken[0]).toEqual value: "Replace ", scopes: ["source.doconce"]
    expect(subToken[1]).toEqual value: "{~~", scopes: ["source.doconce", "critic.doconce.substitution", "critic.doconce.substitution.marker"]
    expect(subToken[2]).toEqual value: "this", scopes: ["source.doconce", "critic.doconce.substitution"]
    expect(subToken[3]).toEqual value: "~>", scopes: ["source.doconce", "critic.doconce.substitution", "critic.doconce.substitution.operator"]
    expect(subToken[4]).toEqual value: "by that", scopes: ["source.doconce", "critic.doconce.substitution"]
    expect(subToken[5]).toEqual value: "~~}", scopes: ["source.doconce", "critic.doconce.substitution", "critic.doconce.substitution.marker"]
