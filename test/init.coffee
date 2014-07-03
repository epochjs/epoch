jsdom = require('jsdom')
global.assert = require('chai').assert
[Epoch, document] = [null, null]

process.env.TZ = "America/Los_Angeles"
  
before (done) ->
  jsdom.env
    html: "<html><body></body></html>"
    scripts: ["http://d3js.org/d3.v3.min.js", "../js/epoch.js"]
    done: (errors, window) ->
      global.Epoch = window.Epoch
      global.document = window.document
      done()
