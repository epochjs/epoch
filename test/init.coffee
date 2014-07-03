jsdom = require('jsdom')

[Epoch, document] = [null, null]
  
before (done) ->
  jsdom.env
    html: "<html><body></body></html>"
    scripts: ["http://d3js.org/d3.v3.min.js", "../js/epoch.js"]
    done: (errors, window) ->
      global.Epoch = window.Epoch
      global.document = window.document
      done()
