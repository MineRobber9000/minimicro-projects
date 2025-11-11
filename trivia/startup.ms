import "utils"

text.clear
text.row = 14
text.print_centered "*** MINI MICRO TRIVIA ***"
text.print_centered "by minerobber"
print ""
text.print_centered "Trivia questions courtesy of Open Trivia DB"
print ""
st = time
while true
	if (time-st)>3 then break
	if key.available then
		k = key.get
		if k==char(10) or k==" " then break
	end if
end while
clear
utils.header "CHOOSE A MODE"
print ""
text.column = 0
choices = [["One at a time","oneatatime.ms"],["Quiz","quiz.ms"]]
i=1
for choice in choices
	print i+".) "+choice[0]
	i+=1
end for
choice = input("? ").val
while choice<1 or choice>choices.len
	print "Invalid choice!"
	text.row+=2
	print " "*67
	text.row+=1
	choice = input("? ").val
end while
print " "*67
load choices[choice-1][1]
run