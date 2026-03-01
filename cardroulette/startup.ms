import "utils"
import "textUtil"
import "bets"
display(4).sprites.push cardHolder
display(4).sprites.push deckSprite

deck = null
reshuffle = function
	outer.deck = utils.cardImages.deepCopy
	outer.deck.shuffle
end function
reshuffle

betsImg = file.loadImage("bets.png")
betsX = 960-betsImg.width-70
betsY = 320-(betsImg.height/2)
gfxBack.clear "#007700"
gfxBack.drawImage betsImg, betsX, betsY

betAmounts = {}
betNames = {}

imgMap = new utils.ImageMap
imgMap.offsetX = betsX
imgMap.offsetY = betsY

textUI = function
	text.clear
	text.row = 25
	text.column = 0
	message = "Chips: "
	message += outer.playerChips
	if betAmounts!={} then
		message += " (+"
		message += betAmounts.sum
		message += " in bets)"
	end if
	print message
end function

ChipSprite = new Sprite
ChipSprite.image = file.loadImage("/sys/pics/gamePieces/pieceWhite_border11.png")
ChipSprite.tint = "#ff0000"
ChipSprite.localBounds = new Bounds
ChipSprite.localBounds.width = ChipSprite.image.width
ChipSprite.localBounds.height = ChipSprite.image.height
ChipSprite.valid = function(cs)
	if not (cs isa ChipSprite) then return true
	if not cs.hasIndex("bet") then return false
	return betAmounts.hasIndex(cs.bet)
end function
filterChipSprites = function
	display(4).sprites.filter @ChipSprite.valid
end function
getChipSprite = function(bet)
	for sprite in display(4).sprites
		if not (sprite isa ChipSprite) then continue
		if sprite.hasIndex("bet") and sprite.bet==bet then return sprite
	end for // sprite
	sprite = new ChipSprite
	sprite.bet = bet
	for area in imgMap.areas
		if not (area isa BetButton) then continue
		if area.hasIndex("bet") and area.bet==bet then
			bounds = area.bounds.translate(betsX, betsY)
			sprite.x = bounds.x-(bounds.width/4)
			sprite.y = bounds.y
		end if
	end for // area
	display(4).sprites.push sprite
	return sprite
end function

playerChips = 50
textUI

BetDialog = textUtil.Dialog.make("Place a bet")
BetDialog.height += 1
BetDialog.okBtn.caption = "+1 Chip"
BetDialog.okBtn.key = "="
BetDialog.altBtn.caption = "-1 Chip"
BetDialog.altBtn.visible = true
BetDialog.altBtn.key = "-"
BetDialog.cancelBtn.caption = "Close"
BetDialog.cancelBtn.visible = true
BetDialog.cancelBtn.key = char(10)
BetDialog.handleKey = function(k)
	if not betAmounts.hasIndex(self.bet) then betAmounts[self.bet]=0
	if k=="i" then
		betAmounts[self.bet]=playerChips
		outer.playerChips=0
		self.done = true
		return true
	end if
	if k=="o" then
		outer.playerChips+=betAmounts[self.bet]
		betAmounts[self.bet]=0
		self.done = true
		return true
	end if
	return false
end function
BetDialog.show = function(bet)
	text.clear
	self.done = false
	self.bet = bet
	while mouse.button
		yield
	end while
	while true
		self.title = "Place a bet: "+betNames[bet]
		self.message = "Current bet: "
		count = 0
		if betAmounts.hasIndex(bet) then count = outer.betAmounts[bet]
		self.message += count
		self.message += " chip"
		if count!=1 then self.message+="s"
		self.message += char(10)
		self.message += "You have: "
		self.message += playerChips
		self.message += " chip"
		if playerChips!=1 then self.message+="s"
		self.msgLines = self.message.split(char(10))
		btnHit = super.show
		if btnHit==self.cancelBtn then
			textUI
			return
		end if
		if btnHit==self.okBtn and playerChips>0 then
			count+=1
			outer.playerChips-=1
		else if btnHit==self.altBtn and count>0 then
			count-=1
			outer.playerChips+=1
		end if
		if btnHit!=null then betAmounts[bet]=count
		if betAmounts[bet]==0 then
			betAmounts.remove bet
		else
			getChipSprite bet
		end if
		filterChipSprites
	end while
end function

BetButton = new utils.Area
BetButton.onClick = function(_)
	if not self.hasIndex("bet") then
		clear
		print "Bet button doesn't have a bet associated with it >:("
		1 2 // cause error
	end if
	self.onMouseExit _
	BetDialog.show self.bet
end function

for betObj in bets.listBets
	betBtn = BetButton.make(betObj.spot[0],460-betObj.spot[1],betObj.spot[2],betObj.spot[3])
	betBtn.bet = betObj.bet
	betNames[betObj.bet] = betObj.name
	imgMap.areas.push betBtn
end for // betObj

moving = false
deckSprite.update = function
	if moving then return
	if self.localBounds.translate(self.x, self.y).contains(mouse) then
		self.scale = 0.9
		if mouse.button then
			self.scale = 1
			card = utils.newCard
			card.x = self.x
			card.y = self.y
			card.update
			card.target.x = cardHolder.x
			card.target.y = cardHolder.y
			display(4).sprites.push card
			outer.moving = true
			while not allCardsFinished
				updateAllSprites
				yield
			end while
			card.frontImage = deck.pop
			card.target.faceUp = 1
			while not allCardsFinished
				updateAllSprites
				yield
			end while
			filterCardSprites card
			info = utils.cardInfo[card.frontImage]
			lines = []
			for betObj in bets.listBets
				if betAmounts.hasIndex(betObj.bet) then
					if betObj.hits(info) then
						outer.playerChips += betAmounts[betObj.bet] * (1+betObj.payout)
						lines.push " - "+betObj.name+" x"+betAmounts[betObj.bet]
					end if
					betAmounts.remove betObj.bet
				end if
			end for // betObj
			outer.playerChips = floor(outer.playerChips)
			resultDialog = textUtil.Dialog.make("...", "Winning bets:")
			resultDialog.msgLines.push ""
			if lines.len>0 then
				resultDialog.title = "You won!"
				for line in lines
					resultDialog.msgLines.push line
				end for // line
			else
				resultDialog.title = "No luck!"
				resultDialog.message = "Unfortunately, none of your bets hit. Better luck next time!"
				resultDialog.msgLines = resultDialog.message.wrap(resultDialog.width-4)
			end if
			resultDialog.height = resultDialog.msgLines.len+4
			resultDialog.show
			if playerChips==0 then
				textUtil.Dialog.make("Game Over","You ran out of chips!").show
				exit
			end if
			textUI
			filterChipSprites
			// reshuffle on ace/joker/deckout
			// (that last one shouldn't be possible but just in case)
			if info.suit=="Joker" or info.rank==1 or deck.len==0 then
				display(4).sprites.pop
				display(4).sprites.insert 1, card
				card.faceUp = 0
				card.target.remove "faceUp"
				card.target.x = self.x
				card.target.y = self.y
				while not allCardsFinished
					updateAllSprites
					yield
				end while
				filterCardSprites
			end if
			outer.moving = false
		end if
	else
		self.scale = 1
	end if
end function

while true
	imgMap.update
	updateAllSprites
	if key.available then
		code = key.get.code
		if code==27 then exit
	end if
	yield
end while