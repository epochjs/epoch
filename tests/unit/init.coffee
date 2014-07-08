process.env.TZ = "America/Los_Angeles"

jsdom = require('jsdom')
global.assert = require('chai').assert
url = require('url')

html = "<html><head></head><body></body></html>"

before (done) ->
  jsdom.env
    html: html
    scripts: ["http://d3js.org/d3.v3.min.js", "../../js/epoch.js"]
    done: (errors, window) ->
      global.Epoch = window.Epoch
      global.d3 = window.d3
      global.doc = window.document

      # Set this to "retina" so we can test canvas based charts
      window.devicePixelRatio = 2
      
      done()

global.addStyleSheet = (css) ->
  head = doc.head
  style = doc.createElement('style')
  style.type = 'text/css'
  style.appendChild(doc.createTextNode(css))
  head.appendChild(style)
  style
