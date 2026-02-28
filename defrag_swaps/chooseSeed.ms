if not globals.hasIndex("utils") then import "utils"
globals["_didSetSeed"] = true

utils.header

text.column=0
text.row=23
print "Enter a seed."
print "> ", ""
seed = input
if seed.val or seed=="0" then
	rnd seed.val
	run "game"
else
	n = 0
	for ch in seed
		n = n*31 + ch.code
		if n>=(2^32) then n = bitAnd(n,2^32-1)
	end for
	if n>=(2^31) then n = n-(2^32)
	rnd n
	run "game"
end if