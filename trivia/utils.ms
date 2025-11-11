import "chars"
import "unidecode"
unidecode = @unidecode.unidecode

choose = function
	s = input("? ").lower
	if s=="" then return ""
	return s[0]
end function

TextDisplay.print_centered = function(s)
	self.column = floor(68/2)-floor(s.len/2)
	self.print s
end function

header = function(hdr)
	text.inverse = true
	text.print_centered " "+hdr+" "
	text.inverse = false
	text.column = 0
end function

print_inverse = function(s,inv)
	text.inverse = inv
	print s
	text.inverse = false
end function

print_choices = function(choices,sel_index,index=true)
	delim = text.delimiter
	text.delimiter = ""
	for i in range(0,choices.len-1)
		s = ""
		if index then s+=(i+1)+".) "
		s += unidecode(choices[i])
		print_inverse s, i==sel_index
		text.row-=1
		text.column = 0
		if text.row<0 then text.row=0
	end for
	text.delimiter = delim
end function

select = function(choices,sel_index=0,index=true,act=null)
	row = text.row
	text.inverse = false
	print_choices choices, sel_index, index
	while true
		while not key.available
			if @act!=null then act
			yield
		end while
		k = key.get
		if k==chars.up then sel_index=(sel_index-1+choices.len)%choices.len
		if k==chars.down then sel_index=(sel_index+1)%choices.len
		if k==char(10) then return choices[sel_index]
		if index and k.val and choices.hasIndex((k.val-1)%10) then return choices[(k.val-1)%10]
		text.row = row
		print_choices choices, sel_index, index
	end while
end function

toggle = function(_map,indexes=null)
	if indexes==null then
		indexes = _map.indexes
		indexes.sort
	end if
	x = []
	for index in indexes; x.push index; end for
	for i in range(0,x.len-1)
		s = ""
		if _map[x[i]] then s+=chars.checkedBox else s+=chars.emptyBox
		s+=" "
		s+=x[i]
		x[i]=s
	end for
	x.push chars.boxWithX+" Exit"
	row = text.row
	sel_index = 0
	while true
		choice = select(x,sel_index,false)
		if choice[0]==chars.boxWithX then return
		key = choice[2:]
		_map[key] = choice[0]==chars.emptyBox
		newbox = ""
		if choice[0]==chars.emptyBox then newbox=chars.checkedBox else newbox=chars.emptyBox
		sel_index = x.indexOf(choice)
		x[sel_index]=newbox+" "+key
		text.row = row
	end while
end function

random = function(l)
	if l.len==1 then return l[0]
	return l[floor(rnd*l.len)]
end function

wait4enter = function
	key.clear
	while true
		while not key.available; yield; end while
		if key.get==char(10) then return
	end while
end function