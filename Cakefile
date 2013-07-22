fs = require 'fs'
{exec} = require 'child_process'

library_order = [
	'*.js'
]

package_order = [
	'epoch.js',
	'charts/*.js',
	'time.js',
	'time/*.js',
	'adapters.js',
	'adapters/*.js'
]

stripSlash = (name) ->
	name.replace /\/\s*$/, ''

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

task 'build', ->
	console.log "Building..."
	exec 'coffee --output js/fastly-charts --compile coffee/', (err, stdout, stderr) ->
		return console.log(stdout + stderr) if err?
		invoke 'package'

task 'package', ->
	console.log "Packaging..."
	libraries = ("lib/#{library}" for library in library_order).join(' ')
	sources = ("js/fastly-charts/#{source}" for source in package_order).join(' ')
	exec "cat #{libraries} #{sources} > js/epoch.js", (err, stdout, stderr) -> 
		console.log "Complete!"

task 'watch', ->
	watch 'coffee/', '.coffee', (event, filename) ->
		invoke 'build'

