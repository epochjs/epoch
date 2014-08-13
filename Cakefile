fs = require 'fs'
{exec} = require 'child_process'
compressor = require 'node-minify'
util = require 'util'

#
# Build / Package Rules & Targets
#

version = 'X.Y.Z'

package_order = [
  'epoch.js',
  'core/context.js',
  'core/util.js',
  'core/d3.js',
  'core/format.js',
  'core/chart.js',
  'core/css.js',
  'data.js',
  'model.js',
  'basic.js',
  'basic/*.js',
  'time.js',
  'time/*.js',
  'adapters.js',
  'adapters/*.js'
]

dirs =
  src: 'src/'
  build: 'js/epoch/'
  doc: 'doc/'
  css: 'css/'
  js: 'js/'


target =
  package: 'js/epoch.js'
  compile: "./epoch.min.js"


compiler_url = 'http://closure-compiler.appspot.com/compile'


#
# Utilities & Eventing
#

events = {}

after = (name, fn) ->
  events[name] ?= []
  events[name].push fn

chain = (list, callback) ->
  return unless list? and list.length
  for i in [0..list.length-2]
    [cause, effect] = [list[i], list[i+1]]
    after cause, ((task) -> -> invoke task)(effect)
  after list[list.length-1], -> callback() if callback?
  invoke list[0]

all = (list, callback) ->
  return unless list? and list.length
  count = list.length
  for task in list
    after task, -> callback() unless (--count) or !callback?
    invoke task

done = (name) ->
  return unless events[name]?
  fn() for fn in events[name]

stripSlash = (name) ->
  name.replace /\/\s*$/, ''

error = (task, msg) ->
  util.log "[ERROR] Task '#{task}':\n  #{msg}"

watch = (dir, ext, fn) ->
  stampName = ".stamp_#{stripSlash(dir)+ext}"

  watchFiles = (err, stdout, stderr) ->
    return error("watch(#{dir})", stderr) if err?
    for file in stdout.split /\s+/
      continue unless file.match ext
      fs.watch file, ((file) -> (event) -> fn(event, file))(file)
    exec "touch #{stampName}"

  fs.watch dir, -> exec "find #{stripSlash(dir)} -newer #{stampName}", watchFiles
  exec "find #{stripSlash(dir)}", watchFiles

#
# Tasks
#

task 'build', 'Builds JavaScript and CSS from source (also packages)', ->
  console.log "Building..."
  chain ['coffee', 'sass', 'package'], ->
    done 'build'

task 'coffee', 'Compiles JavaScript from CoffeeScript source', ->
  console.log "Compiling CoffeeScript into JavaScript..."
  exec "./node_modules/.bin/coffee --output #{dirs.build} --compile #{dirs.src}", (err, stdout, stderr) ->
    error('coffee', stdout + stderr) if err?
    done 'coffee'

task 'sass', 'Compiles SASS source into CSS', ->
  console.log "Compiling SCSS into CSS..."
  fs.mkdir 'css/', ->
    exec './node_modules/.bin/node-sass --output-style compressed sass/epoch.scss css/epoch.css', (err, o, e) ->
      error('sass', o+e) if err?
      done 'sass'

task 'package', 'Packages the JavaScript into a single file', ->
  console.log "Packaging..."
  sources = ("#{dirs.build}#{source}" for source in package_order).join(' ')
  exec "cat #{sources} > #{target.package}", (err, stdout, stderr) ->
    error('package', stdout + stderr) if err?
    done 'package'

task 'compile', 'Compiles the packaged source via the Google Closure Compiler', ->
  chain ['coffee', 'package'], ->
    console.log "Google Closure Compiling..."
    new compressor.minify
      type: 'gcc'
      language: 'ECMASCRIPT5'
      fileIn: target.package
      fileOut: target.compile
      callback: (err) ->
        if err?
          error 'compile', err if err?
        done 'compile'

task 'watch', ->
  watch 'src/', '.coffee', (event, filename) ->
    invoke 'build'

task 'documentation', 'Compiles API documentation', ->
  console.log 'Compiling documentation...'
  exec "./node_modules/.bin/codo --quiet --private --name Epoch --readme README.md --title 'Epoch Documentation' --output #{dirs.doc} #{dirs.src} - LICENSE", (err, stdout, stderr) ->
    error('documentation', stdout + stderr) if err?

task 'test', 'Runs unit tests', ->
  after 'build', ->
    console.log "Testing..."
    exec "./node_modules/.bin/mocha --reporter dot --recursive --compilers coffee:coffee-script/register tests/unit/", (err, stdout, stderr) ->
      console.log stderr + stdout
  invoke 'build'

#
# Release Tasks
#

option '-v', '--version [VERSION_NUMBER]', 'Sets the version number for the release task'

setVersion = (options, callback) ->
  cmd = 'git tag | grep -E "^[0-9]"  | sort -b -t . -k1,1 -k2,2n -k3,3n | tail -1 | awk \'BEGIN{FS=OFS="."}{++$3; print $0}\''
  if options.version? and options.version.match(/^[0-9]+\.[0-9]+\.[0-9]+$/)?
    version = options.version
    callback()
  else if options.version?
    error('release', 'Version must be supplied in a semantic format (X.Y.Z).')
  else
    exec cmd, (err, stdout, stderr) ->
      error('release', stdout+stderr) if err?
      version = stdout.replace(/^\s+|\s+$/, '')
      callback()

task 'release', 'Releases a new version of the library', (options) ->
  setVersion options, ->
    console.log "Building release #{version}..."
    all ['sass', 'compile'], ->
      exec "cp css/epoch.css ./epoch.min.css", (err, o, e) ->
        error('release', o+e) if err?

task 'clean', 'Removes build files completely', ->
  console.log "Removing #{dirs.js} #{dirs.css} #{dirs.doc}"
  exec "rm -r #{dirs.js} #{dirs.css} #{dirs.doc}"
