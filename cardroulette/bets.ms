// Represents a bet
Bet = {}
// ID of the bet
Bet.bet = null
// [left, bottom, width, height] of the clickable area on the map
Bet.spot = [0,0,64,64]
// name (used in the BetDialog)
Bet.name = "missingno"
// whether the bet hits or not
Bet.hits = function(card)
	return false
end function
// Payout of the bet
Bet.payout = 0
// Makes a bet object with a specific ID, spot, and name
Bet.make = function(id=null, spot=null, name=null)
	ret = new self
	ret.bet = id
	if spot!=null then ret.spot = spot
	ret.name = name
	return ret
end function

// Pre-calculated bet (from card info)
PreCalculatedBet = new Bet
PreCalculatedBet.hits = function(card)
	return card[self.bet]
end function
PreCalculatedBet.payout = function
	// Red/Black (1:1)
	if self.bet=="red" or self.bet=="black" then return 1
	// Even/Odd/Low (3:2)
	if self.bet=="even" or self.bet=="odd" or self.bet=="low" then return 1.5
	// Medium/High (2:1)
	if self.bet=="medium" or self.bet=="high" then return 2
	// Royalty (3:1)
	if self.bet=="royalty" then return 3
end function

// Suit bet (3:1 except Joker at 50:1)
SuitBet = new Bet
SuitBet.hits = function(card)
	return card.suit == self.bet[4:]
end function
SuitBet.payout = function
	// Joker (50:1)
	if self.bet=="suitJoker" then return 50
	// All others (3:1)
	return 3
end function

// Rank bets (12:1)
RankBet = new Bet
RankBet.rank = function
	if not (self isa RankBet) then return 42
	rank = self.bet[4:]
	if rank=="Ace" then
		rank = 1
	else if rank=="J" then
		rank = 11
	else if rank=="Q" then
		rank = 12
	else if rank=="K" then
		rank = 13
	else
		rank = rank.val
	end if
	self.rank = rank
	return rank
end function
RankBet.hits = function(card)
	return card.rank == self.rank
end function
RankBet.payout = 12

listBets = [PreCalculatedBet.make("red",[3,67,227,64],"Red (1:1)"),
  PreCalculatedBet.make("black",[231,67,226,64],"Black (1:1)"),
  SuitBet.make("suitDiamonds",[3,132,113,64],"Diamonds (3:1)"),
  SuitBet.make("suitHearts",[117,132,113,64],"Hearts (3:1)"),
  SuitBet.make("suitSpades",[231,132,113,64],"Spades (3:1)"),
  SuitBet.make("suitClubs",[345,132,112,64],"Clubs (3:1)"),
  RankBet.make("rankAce",[3,197,64,64],"Ace (12:1)"),
  RankBet.make("rank2",[68,197,64,64],"2 (12:1)"),
  RankBet.make("rank3",[133,197,64,64],"3 (12:1)"),
  RankBet.make("rank4",[198,197,64,64],"4 (12:1)"),
  RankBet.make("rank5",[263,197,64,64],"5 (12:1)"),
  RankBet.make("rank6",[68,262,64,64],"6 (12:1)"),
  RankBet.make("rank7",[133,262,64,64],"7 (12:1)"),
  RankBet.make("rank8",[198,262,64,64],"8 (12:1)"),
  RankBet.make("rank9",[263,262,64,64],"9 (12:1)"),
  RankBet.make("rank10",[68,327,64,64],"10 (12:1)"),
  RankBet.make("rankJ",[133,327,64,64],"Jack (12:1)"),
  RankBet.make("rankQ",[198,327,64,64],"Queen (12:1)"),
  RankBet.make("rankK",[263,327,64,64],"King (12:1)"),
  PreCalculatedBet.make("low",[328,197,129,64],"Low (3:2)"),
  PreCalculatedBet.make("medium",[328,262,129,64],"Medium (2:1)"),
  PreCalculatedBet.make("high",[328,327,129,64],"High (2:1)"),
  SuitBet.make("suitJoker",[3,327,64,129],"Joker (50:1)"),
  PreCalculatedBet.make("even",[3,392,129,64],"Even (3:2)"),
  PreCalculatedBet.make("royalty",[133,392,194,64],"Royalty (3:1)"),
  PreCalculatedBet.make("odd",[328,392,129,64],"Odd (3:2)")]