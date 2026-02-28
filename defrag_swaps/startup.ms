import "utils"
text.color = "#ffffff"

if not globals.hasIndex("_didSetSeed") then _didSetSeed=false

utils.header

modLen = function(n, l)
	if n<0 then n+=l
	return n%l
end function

choices = [["Random Seed","game.ms"], ["Set Seed","chooseSeed.ms"]]
choice = 0
while true
	for i in range(0,choices.len-1)
		if i==choice then text.inverse=true
		textUtil.printCenteredAt 34, 23-i, " "+choices[i][0]+" "
		text.inverse = false
	end for
	k = key.get
	if k.code==10 then
		if _didSetSeed then
			rnd time // just in case
			_didSetSeed=false
		end if
		run choices[choice][1]
	end if
	if k.code==19 then choice=modLen(choice-1,choices.len)
	if k.code==20 then choice=modLen(choice+1,choices.len)
	if k.code==27 then break
end while
text.color=color.orange