while true
	while not key.available; yield; end while
	while key.available
		k = key.get
		print k + " ("+code(k)+")"
	end while
end while