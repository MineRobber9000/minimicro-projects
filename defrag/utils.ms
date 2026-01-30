import "bmfFonts"
import "mathUtil"
import "textUtil"
globals["textUtil"] = textUtil
if not globals.hasIndex("mmfont") then globals["mmfont"] = bmfFonts.Font.load("/sys/fonts/minimicro-mono-16.bmf")

// Generate a box for a file fragment based on a color and fragment name
generateBox = function(color, name)
	im = Image.create(48, 48, color)
	if name != null then
		x = floor(24 - (mmfont.width(name)/2))
		for c in name
			mmfont.renderChar c, im, x, 16
			x += 11
		end for
	end if
	for coord in range(0,47)
		im.setPixel coord, 0, "#ffffff"
		im.setPixel coord, 47, "#ffffff"
		im.setPixel 0, coord, "#ffffff"
		im.setPixel 47, coord, "#ffffff"
	end for
	return im
end function

// Generate a list of boxen given a color, name, and count
generateBoxen = function(color, name, count)
	boxen = []
	for i in range(1, count)
		boxen.push generateBox(color, name+i)
	end for
	return boxen
end function

clear
text.print "Generating boxen..."
if not globals.hasIndex("empty") then globals["empty"] = generateBox("#888888", null)
if not globals.hasIndex("a") then globals["a"] = generateBoxen("#ff0000", "A", 20)
if not globals.hasIndex("b") then globals["b"] = generateBoxen("#ffbc00", "B", 15)
if not globals.hasIndex("c") then globals["c"] = generateBoxen("#00c483", "C", 13)
if not globals.hasIndex("d") then globals["d"] = generateBoxen("#000fc4", "D", 23)
if not globals.hasIndex("e") then globals["e"] = generateBoxen("#ff00ff", "E", 9)

boxBounds = new Bounds
boxBounds.x = 0
boxBounds.y = 0
boxBounds.width = 48
boxBounds.height = 48
BoxSprite = new Sprite
BoxSprite.index = -1
BoxSprite.localBounds = boxBounds

BoxSprite.spec = function
	if self.image==empty then return ["empty",-1]
	for file in "abcde"
		for i in range(0, globals[file].len-1)
			if self.image==globals[file][i] then return [file.upper, i+1]
		end for
	end for
end function

spriteFromBox = function(box, index)
	s = new BoxSprite
	s.image = box
	s.index = index
	moveToIndex s, index
	return s
end function

xForIndex = function(index)
	// index = 89-index
	return 48*(index%15)+24+120
end function

yForIndex = function(index)
	index = 89-index
	return 64*floor(index/15)+24+8
end function

moveToIndex = function(sprite, index)
	sprite.x = xForIndex(index)
	sprite.y = yForIndex(index)
end function

squaredDistance = function(box1, box2)
	return (box1.x-box2.x)^2 + (box1.y-box2.y)^2
end function

distance = function(box1, box2)
	return sqrt(squaredDistance(box1, box2))
end function

MoveData = {}
MoveData.sprite = null
MoveData.x = 0
MoveData.y = 0
MoveData.speed = 8

MoveData.create = function(sprite, x=0, y=0, speed=-1)
	ret = new self
	ret.sprite = sprite
	ret.x = x
	ret.y = y
	if speed==-1 then
		dist = distance(ret, sprite)
		speed = dist / 30
	end if
	ret.speed = speed
	return ret
end function

MoveData.createIndex = function(sprite, index=null, speed=-1)
	if index==null then index=sprite.index
	return MoveData.create(sprite, xForIndex(index), yForIndex(index), speed)
end function

MoveData.update = function()
	return mathUtil.moveTowardsXY(self.sprite, self, self.speed)
end function

executeMoves = function(moves)
	while true
		_any = false
		for move in moves
			_any = _any or move.update
		end for
		if not _any then break
		yield
	end while
end function

// swaps 2 boxes in place
history = []
swapBox = function(box1, box2, addhistory=true)
	b1i = box1.index
	b2i = box2.index
	boxen[b1i]=box2
	box2.index=b1i
	moveToIndex box2, b1i
	boxen[b2i]=box1
	box1.index=b2i
	moveToIndex box1, b2i
	if addhistory then history.push([b1i, b2i])
end function

// undo button
undo = function(boxen)
	_undo = history.pop
	swapBox boxen[_undo[0]], boxen[_undo[1]], false
end function

// checks if the files are defragged
// rules:
// - all files must be contiguous
// - no gaps between files
// the order of the files doesn't actually
// matter as long as the rest of the rules are followed
noDefrag = function(s)
	// print s
	return false
end function
checkDefrag = function(boxen)
	index = 0
	while boxen[index].image==empty
		index+=1
	end while
	for _ in range(1,5)
		spec = boxen[index].spec
		if spec[1]!=1 then return noDefrag("must start at 1; idx="+index)
		index+=1
		while index<boxen.len
			nspec = boxen[index].spec
			// must be the next fragment of the file
			if spec[0]!=nspec[0] then return noDefrag("new file before we expected it; idx="+index)
			if (nspec[1]-spec[1])!=1 then return noDefrag("skipped fragment; idx="+index)
			index+=1
			if nspec[1]==globals[spec[0].lower].len then break
			spec=nspec
		end while
		if index>boxen.len and _<5 then return 
	end for
	return true
end function

swapCount = function
	return history.len
end function

swapCountText = function
	s = swapCount + " swap"
	if s!=1 then s+="s"
	return s
end function

header = function
	clear
	text.inverse=true
	textUtil.printCenteredAt 34, 25, " DISK DEFRAGMENTATION "
	text.inverse=false
end function