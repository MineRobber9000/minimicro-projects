sourcedirs = ["/sys/lib"]
paths = []
charsPerKey = 3

nextPath = function
	if paths.len==0 then
		for dir in sourcedirs
			for child in file.children(dir)
				if child.indexOf(".ms")!=null then paths.push dir+"/"+child
			end for
		end for
		paths.shuffle
	end if
	return paths.pop
end function

code = ""

nextChar = function
	if code.len==0 then
		for line in file.readLines(nextPath)
			if line.len>67 then
				outer.code = code + line[0:68]
			else
				outer.code = code + line + char(10)
			end if
		end for
	end if
	c = code[0]
	outer.code = code[1:]
	return c
end function

text.inverse = false
text.clear
display(7).color = "#000000FF"
text.color = "#00FF00FF"
while true
	key.get
	for i in range(1,charsPerKey)
		print nextChar, ""
	end for
end while