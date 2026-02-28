// utilities (used below)
import "mapUtil"
import "listUtil"
_importFrom = function(module, things)
	import module
	for k in things
		globals[k] = locals[module][k]
	end for
end function

// steal CardSprite from the cardFlip demo
env.importPaths.push "/sys/demo"
_importFrom("cardFlip",["CardSprite"])
CardSprite.speed.xy = 250 // slow down card sprite movement

// use the red5 card back instead of the default one
globals.cardBack = file.loadImage("/sys/pics/cards/cardBack_red5.png")
CardSprite.backImage = cardBack

// returns true if the card sprite has finished moving to its target
CardSprite.hasFinished = function
	if self.target.hasIndex("x") and self.target.hasIndex("y") then
		if self.target.x!=self.x or self.target.y!=self.y then return false
	end if
	if self.target.hasIndex("scale") then
		if self.target.scale!=self.scale then return false
	end if
	if self.target.hasIndex("faceUp") then
		if self.target.faceUp!=self.faceUp then return false
	end if
	return true
end function

// deck sprite (just the card back)
globals.deckSprite = new Sprite
deckSprite.image = cardBack
deckSprite.x = cardBack.width
deckSprite.y = 640 - cardBack.height
deckSprite.localBounds = new Bounds
deckSprite.localBounds.width = cardBack.width
deckSprite.localBounds.height = cardBack.height

// card holder sprite (a card back)
globals.cardHolder = new Sprite
cardHolder.image = file.loadImage("cardHolder.png")
cardHolder.x = cardBack.width
cardHolder.y = cardBack.height
cardHolder.localBounds = new Bounds
cardHolder.localBounds.width = cardBack.width
cardHolder.localBounds.height = cardBack.height
cardHolder.tint = "#33333377"

// extend Bounds
Bounds.delta = function(dx=0, dy=0, dw=0, dh=0, dr=0)
	ret = new Bounds
	ret.x = self.x+dx
	ret.y = self.y+dy
	ret.width = self.width+dw
	ret.height = self.height+dh
	ret.rotation = self.rotation+dr
	return ret
end function
Bounds.translate = function(dx, dy)
	return self.delta(dx, dy)
end function
Bounds.rotate = function(dr)
	return self.delta(0, 0, 0, 0, dr)
end function
Bounds.scale = function(ds)
	ret = self.delta
	ret.width *= ds
	ret.height *= ds
	return ret
end function

// utility function: makes a card and defaults it to be face down
newCard = function
	ret = new CardSprite
	ret.faceUp = 0
	ret.target = {}
	ret.update
	return ret
end function

// updates every sprite on the display (if it has an update function)
globals.updateAllSprites = function
	for sprite in display(4).sprites
		if sprite.hasOrInherits("update") then sprite.update
	end for
end function

// cleanSprites(card) removes all card sprites except "card" from the display
// can be used to remove card sprites we no longer need
_keepCardFilter = function(card, keepCard=null)
	if not (card isa CardSprite) then return true
	return card==keepCard
end function
globals.filterCardSprites = function(keepCard=null)
	display(4).sprites.filter1 @_keepCardFilter, keepCard
end function

// returns true if all CardSprites have finished their movement
globals.allCardsFinished = function
	for sprite in display(4).sprites
		if not (sprite isa CardSprite) then continue
		if not sprite.hasFinished then return false
	end for
	return true
end function

// load all card fronts
cardImages = []
cardInfo = {}
_defineCard = function(fn, info)
	im = file.loadImage("/sys/pics/cards/card"+fn+".png")
	cardImages.push(im)
	// pre-calculate all bets
	// Red (1:1)
	info.red = info.suit=="Hearts" or info.suit=="Diamonds"
	// Black (1:1)
	info.black = info.suit=="Clubs" or info.suit=="Spades"
	// Suit (3:1), just checks info.suit
	// Rank (12:1), just checks info.rank
	// Low (3:2), A-5
	info.low = info.rank>0 and info.rank<=5
	// Medium (3:2), 6-9
	info.medium = info.rank>5 and info<=9
	// High (2:1), 10-K
	info.high = info.rank>9
	// Joker (50:1), just checks info.suit=="Joker"
	// Even (3:2)
	info.even = info.rank>0 and info.rank<=10 and (info.rank%2)==0
	// Odd (3:2)
	info.odd = info.rank>0 and info.rank<=10 and (info.rank%2)==1
	// Royalty (3:1)
	info.royalty = info.rank>10
	cardInfo[im] = info
end function
_royalty = "JQK"
_defineCard "Joker", {"suit":"Joker", "rank": 0}
for suit in ["Spades","Diamonds","Clubs","Hearts"]
	_defineCard suit+"A", {"suit": suit, "rank": 1}
	for rank in range(2,10)
		_defineCard suit+rank, {"suit": suit, "rank": rank}
	end for // rank
	for rank in range(11,13)
		_defineCard suit+_royalty[rank-11], {"suit": suit, "rank": rank}
	end for // rank
end for // suit
locals.remove "_defineCard"
locals.remove "_royalty"

// GFX behind the original GFX
_clear = @_savedGlobals.clear
globals.clear = function
	_clear
	display(6).mode = displayMode.pixel
	globals.gfxBack = display(6)
	gfx.clear color.clear
	gfxBack.clear
end function
clear

// ImageMap, used for clicking on the bets
ImageMap = {}
ImageMap.offsetX = 0
ImageMap.offsetY = 0
ImageMap._wasHovered = null
ImageMap.areas = function
	if not self.hasIndex("_areas") then self._areas=[]
	return self._areas
end function

ImageMap.update = function
	for area in self.areas
		if area.bounds.translate(self.offsetX,self.offsetY).contains(mouse) then
			if self._wasHovered!=area and self._wasHovered!=null then self._wasHovered.onMouseExit self
			area.onMouseEnter self
			self._wasHovered = area
		end if
	end for // area
	if self._wasHovered!=null and not self._wasHovered.bounds.translate(self.offsetX, self.offsetY).contains(mouse) then
		self._wasHovered.onMouseExit self
		self._wasHovered = null
	end if
	if mouse.button and self._wasHovered!=null then
		self._wasHovered.onClick self
	end if
end function

Area = {}
Area.make = function(left, bottom, width, height)
	bounds = new Bounds
	bounds.x = left + (width/2)
	bounds.y = bottom + (height/2)
	bounds.width = width
	bounds.height = height
	ret = new self
	ret.bounds = bounds
	return ret
end function

Area.onMouseEnter = function(imgMap)
	gfx.drawPoly self.bounds.translate(imgMap.offsetX,imgMap.offsetY).corners, "#aa0000"
end function

Area.onMouseExit = function(imgMap)
	gfx.drawPoly self.bounds.translate(imgMap.offsetX, imgMap.offsetY).corners, "#00000000"
end function

Area.onClick = function(imgMap)
end function