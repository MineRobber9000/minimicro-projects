if not globals.hasIndex("utils") then import "utils"

// 6 rows of 15 boxen, for a total of 90
// the 5 files combine to 80 boxen, so we need 10 empties
boxen = a+b+c+d+e+([empty]*10)
boxen.shuffle

clear
sprite = display(4)
for i in range(0,boxen.len-1)
	boxen[i] = utils.spriteFromBox(boxen[i], i)
	sprite.sprites.push boxen[i]
end for

// draws the text UI
won = false
textUI = function
	text.clear
	text.color = "#ffffff"
	text.inverse = true
	textUtil.printCenteredAt 34, 25, " DISK DEFRAGMENTATION "
	text.inverse = false
	print
	if won then
		textUtil.printCenteredAt 34, text.row, "You did it! You defragmented the hard drive in "+utils.swapCountText+"!"
		print
		textUtil.printCenteredAt 34, text.row, "Press R to go again, or ESC to go back to the menu!"
	else
		text.column = 5
		textUtil.printWrap "The diagram below represents a fragmented hard disk.", 57
		text.column = 5
		textUtil.printWrap "Each coloured block is a fragment of a file. The grey blocks are unused blocks on the hard disk.",57
		print
		text.column = 5
		textUtil.printWrap "Drag the file blocks to create contiguous files. It does not matter which order your files are in, but each file's fragments must be in the correct order. There must not be any gaps between files.", 57
		text.column = 0
		text.row = 1
		print "Swaps:"+char(10)+utils.swapCount, ""
	end if
	drawTimer
end function
t0=time
t1=null
drawTimer = function
	current_t = t1
	if current_t==null then current_t=time
	t = floor(current_t-t0)
	minutes = floor(t/60)
	seconds = t%60
	s = minutes+":"
	if seconds<10 then s+="0"
	s+=seconds
	textUtil.clearRect 0,3,68,2
	text.column = 0
	text.row = 4
	print "Time:"
	if (not won) or (time%1)<0.5 then print s, ""
	if won then
		textUtil.clearRect 0,0,68,2
		text.column = 0
		text.row = 1
		print "Swaps:"
		if (time%1)<0.5 then print utils.swapCount, ""
	end if
end function

textUI

// handles dropping a box
// finds the closest box and either animates
// sending us back if it's no good or swaps the boxes if it is
dropBox = function(boxSprite, fakeSprite)
	nearestBox = null
	bestDist = 100000000
	for box in boxen
		dist = utils.squaredDistance(box, fakeSprite)
		if dist<bestDist then
			bestDist = dist
			nearestBox = box
		end if
	end for
	if nearestBox==boxSprite then return
	if nearestBox==null or nearestBox.image!=empty then
		utils.executeMoves [utils.MoveData.createIndex(fakeSprite)]
		return
	end if
	utils.swapBox boxSprite, nearestBox
	if utils.checkDefrag(boxen) then
		outer.won = true
		outer.t1 = time
	end if
	textUI
end function

// handles dragging a box
dragBox = function(boxSprite)
	// create fake sprite to drag around
	fakeSprite = utils.spriteFromBox(boxSprite.image, boxSprite.index)
	sprite.sprites.push fakeSprite
	// drag
	offset = [boxSprite.x-mouse.x, boxSprite.y-mouse.y]
	while true
		drawTimer
		if not mouse.button then
			dropBox boxSprite, fakeSprite
			sprite.sprites.pop
			break
		end if
		fakeSprite.x = mouse.x+offset[0]
		fakeSprite.y = mouse.y+offset[1]
		yield
	end while
end function

// waits for the player to let go of the mouse
// used in case you accidentally click on an empty
emptyDrag=function
	while mouse.button
		drawTimer
		yield
	end while
end function

while true
	drawTimer
	if key.available then
		k = key.get
		if k.code==27 then run "startup"
		if k=="z" and utils.swapCount>0 then utils.undo(boxen)
		if k=="r" and won then run
	end if
	if mouse.button then
		for box in boxen
			if box.contains(mouse.x, mouse.y) then
				if box.image==empty or won then
					emptyDrag
				else
					dragBox box
				end if
				break
			end if
		end for
	end if
	yield
end while

text.color=color.orange
text.row=26
clear