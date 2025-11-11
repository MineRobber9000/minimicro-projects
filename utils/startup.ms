ls = @dir // ls alias
rm = @delete // rm alias
touch = function(fn)
	file.writeLines fn, []
end function
touchAndLoad = function(fn)
	touch fn
	load fn
end function
copyAndLoad = function(fn1,fn2)
	file.copy fn1, fn2
	load fn2
end function
mv = @file.move
cp = @file.copy
editstartup = function
	save
	load "/usr/startup.ms"
	edit
end function
if not globals.hasIndex("_reset") then globals._reset = @reset
reset = function(truereset=false)
	if truereset then
		globals._reset
		globals.reset = @globals._reset
		return
	end if
	globals._reset
	load "/usr/startup.ms"
	run
end function