fs = require 'fs'
{exec} = require 'child_process'
compressor = require 'node-minify'
util = require 'util'

#
# Build / Package Rules & Targets
#

version = '0.3.2'

library_order = [
  '*.js'
]

package_order = [
  'epoch.js',
  'charts.js',
  'charts/*.js',
  'time.js',
  'time/*.js',
  'adapters.js',
  'adapters/*.js'
]

dirs =
  lib: 'lib/'
  src: 'coffee/'
  build: 'js/epoch/'


target =
  package: 'js/epoch.js'
  compile: "./epoch.#{version}.min.js"


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

task 'build', 'Builds javascript from the coffeescript source (also packages).', ->
  console.log "Building..."
  exec "coffee --output #{dirs.build} --compile #{dirs.src}", (err, stdout, stderr) ->
    error('build', stdout + stderr) if err?
    invoke 'package'

task 'package', 'Packages the js and libraries into a single file.', ->
  console.log "Packaging..."
  libraries = ("#{dirs.lib}#{library}" for library in library_order).join(' ')
  sources = ("#{dirs.build}#{source}" for source in package_order).join(' ')
  exec "cat #{libraries} #{sources} > #{target.package}", (err, stdout, stderr) -> 
    error('package', stdout + stderr) if err?
    console.log "Complete!"
    done 'package'

task 'compile', 'Compiles the packaged source via the Google Closure Compiler', ->
  after 'package', ->
    console.log "Google Closure Compiling..."
    new compressor.minify
      type: 'gcc'
      language: 'ECMASCRIPT5'
      fileIn: target.package
      fileOut: target.compile
      callback: (err) ->
        if err?
          error 'compile', err if err?
        else
          console.log "Compilation complete."
        done 'compile'
  invoke 'build'

#task 'deploy' 
#git tag | grep -E "^[0-9]"  | sort -b -t . -k1,1 -k2,2n -k3,3n | tail -1 | awk 'BEGIN{FS=OFS="."}{++$3; print $0}'

task 'watch', ->
  watch 'coffee/', '.coffee', (event, filename) ->
    invoke 'build'

