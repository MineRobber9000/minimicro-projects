import "triviaLib"
import "utils"
import "textUtil"
api = triviaLib.api

curr = new triviaLib.session
curr.running = true
while curr.running
	cat_i = 0
	while cat_i<1 or cat_i>(api.categories_ordered.len+1)
		utils.header "Choose a category (or "+(api.categories_ordered.len+1)+" for wildcard):"
		i = 1
		for cat in api.categories_ordered
			print i + ".) " + cat
			i+=1
		end for
		cat_i = input("? ").val
	end while
	cat_i -= 1
	cat = 0
	if cat_i == api.categories_ordered.len then
		cat = -1
	else
		cat = api.categories[api.categories_ordered[cat_i]]
	end if
	q = curr.question(1,cat)[0]
	choices = ""
	correct = 0
	poss_answers = []
	if q.type=="multiple" then
		poss_answers.push q.correct_answer
		for incorrect in q.incorrect_answers
			poss_answers.push incorrect
		end for
		poss_answers.shuffle
		// multiple choice questions *should* be no more than 4 answers
		// but just to be safe!
		choices = "abcdefghijklmnopqrstuvwxyz"
		correct = poss_answers.indexOf(q.correct_answer)
	else if q.type=="boolean" then
		poss_answers.push "True"
		poss_answers.push "False"
		choices = "tf"
		correct = q.correct_answer=="False" // 0 for true (not false), 1 for false (not true)
		q.question = "True or false: "+q.question
	end if
	choices = choices[:poss_answers.len]
	clear
	utils.header q.category+" ["+q.difficulty.capitalized+"]"
	text.column = 1
	print ""
	print q.question.wrap.join(char(10))
	print ""
	for i in range(0,poss_answers.len-1)
		print choices[i].upper+".) "+poss_answers[i]
	end for
	answer = choices.indexOf(utils.choose)
	while answer==null
		print "Invalid answer!"
		text.row+=2
		text.column=1
		textUtil.clearToEOL
		answer = choices.indexOf(utils.choose)
	end while
	textUtil.clearToEOL
	text.row+=1
	if answer==correct then
		print "Correct!"
	else
		print "Incorrect!"
		if poss_answers.len>2 then print "The answer was: "+poss_answers[correct]
	end if
	print "Go again? (y/N):"
	curr.running = utils.choose=="y"
end while
clear
print "Thank you for playing!"
load "startup.ms"