import "triviaLib"
import "quizLib"
quiz=new quizLib.quiz
import "utils"
import "textUtil"

if file.exists("token.txt") then
	fh = file.open("token.txt","r")
	quiz.session.token = fh.read.trim
	fh.close
end if

import "json"
if file.exists("queue.json") then
	fh = file.open("queue.json","r")
	quiz.queue = json.parse(fh.read)
	fh.close
end if

start = function
	text.delimiter = char(10)
	text.color = color.orange
	clear
	utils.header "TRIVIA QUIZ"
	print ""
	quiz.display_settings
	print ""
	choice = utils.select(["Do quiz","Change settings","Exit"])
	if choice=="Do quiz" then return @doQuiz
	if choice=="Change settings" then return @changeSettings
	return null
end function

doQuiz = function
	quiz.reset
	clear
	utils.header "PREPARING QUIZ..."
	print ""
	delim = text.delimiter
	text.delimiter = " "
	print "Preparing your quiz..."
	c = text.column
	text.delimiter = delim
	print "(0/"+quiz.questions+")"
	while quiz.lquestions.len<quiz.questions
		x = quiz.load
		if x==-1 then return @invalidQuery
		text.row+=1
		text.column=c
		print "("+quiz.lquestions.len+"/"+quiz.questions+")"
		if not x then wait 5
	end while
	print ""
	print "Press enter to begin."
	utils.wait4enter
	while quiz.questioni<quiz.questions
		i = quiz.next
		if i==null then return @reviewQuiz
		q = quiz.lquestions[i]
		quiz.answers[i].chose = doQuestion(q,i)
	end while
	return @reviewQuiz
end function

invalidQuery = function
	clear
	utils.header "TRIVIA QUIZ"
	print ""
	print "There aren't enough questions in the database to fill your request. Please change some settings and try again."
	print ""
	print "Press enter to return to the main menu."
	utils.wait4enter
	return @start
end function

doQuestion = function(q,i)
	globals.q = q
	choices = ""
	correct = 0
	poss_answers = []
	if q.type=="multiple" then
		poss_answers.push q.correct_answer
		for incorrect in q.incorrect_answers
			poss_answers.push incorrect
		end for
		poss_answers.shuffle
	else if q.type=="boolean" then
		poss_answers.push "True"
		poss_answers.push "False"
		q.question = "True or false: "+q.question
	end if
	clear
	utils.header q.category+" ["+q.difficulty.capitalized+"]"
	print ""
	qs = "Q"+(i+1)+". "+q.question
	print qs.wrap.join(char(10))
	print ""
	return utils.select(poss_answers,0,true)
end function

reviewQuiz = function
	reviewPage
	print ""
	for i in range(0,quiz.questions-1)
		qs = "Q"+(i+1)+". "+quiz.lquestions[i].question
		lines = qs.wrap.len
		if text.row - (lines + 4) < 0 then
			utils.wait4enter
			reviewPage
		end if
		print ""
		print qs.wrap.join(char(10))
		print ""
		print "Correct answer: "+quiz.answers[i].correct
		delim = text.delimiter
		text.delimiter = " "
		print "     You chose: "+quiz.answers[i].chose
		text.delimiter = delim
		if quiz.answers[i].correct==quiz.answers[i].chose then
			text.color = color.green
			print "+"
			text.color = color.orange
		else
			text.color = color.red
			print "-"
			text.color = color.orange
		end if
	end for
	utils.wait4enter
	return @start
end function

reviewPage = function
	clear
	utils.header "QUIZ REVIEW"
	print ""
	text.print_centered "(press enter to continue)"
end function

changeSettings = function
	clear
	utils.header "CHANGE SETTINGS"
	print ""
	choice = utils.select(["Go back","Number of questions","Categories","Categories (clear)","Difficulties","Reset"])
	if choice=="Go back" then return @start
	if choice=="Number of questions" then return @changeNumberOfQuestions
	if choice=="Categories" then return @changeCategories
	if choice=="Categories (clear)" then return @clearCategories
	if choice=="Difficulties" then return @changeDifficulties
	if choice=="Reset" then return @resetSettings
end function

resetSettings = function
	quiz.questions = 20
	for k in quiz.categories.indexes
		quiz.categories[k] = true
	end for
	quiz._categories_changed = true
	for k in quiz.difficulties.indexes
		quiz.difficulties[k] = true
	end for
	quiz._difficulties_changed = true
	return @start
end function

changeNumberOfQuestions = function
	clear
	utils.header "NUMBER OF QUESTIONS"
	print ""
	print "Current number of questions: "+quiz.questions
	questions = input("New number of questions: ")
	while questions.val<1
		if questions.val==0 and questions!="0" then
			print "Must be a number!             "
		else
			print "Must have at least 1 question!"
		end if
		text.row+=2
		textUtil.clearToEOL
		questions = input("New number of questions: ")
	end while
	quiz.questions = questions.val
	return @changeSettings
end function

changeCategories = function
	clear
	utils.header "CATEGORIES"
	utils.toggle quiz.categories, triviaLib.api.categories_ordered
	quiz._categories_changed = true
	for category in quiz.categories.indexes
		if quiz.categories[category] then return @changeSettings
	end for
	clear
	utils.header "CATEGORIES"
	print ""
	print "Error: you must select at least one category!"
	print ""
	print "Press enter to return to the selection menu."
	utils.wait4enter
	return @changeCategories
end function

clearCategories = function
	for category in quiz.categories.indexes
		quiz.categories[category]=false
	end for
	return @changeCategories
end function

changeDifficulties = function
	clear
	utils.header "DIFFICULTIES"
	print ""
	utils.toggle quiz.difficulties, ["Easy","Medium","Hard"]
	quiz._difficulties_changed = true
	for difficulty in quiz.difficulties.indexes
		if quiz.difficulties[difficulty] then return @changeSettings
	end for
	clear
	utils.header "DIFFICULTIES"
	print ""
	print "Error: you must select at least one difficulty!"
	print ""
	print "Press enter to return to the selection menu."
	utils.wait4enter
	return @changeDifficulties
end function

fn = @start
while @fn!=null
	fn = fn
end while

fh = file.open("token.txt","w")
fh.write quiz.session.token
fh.close

if not quiz.hasIndex("queue") then quiz.queue = []
if not quiz.hasIndex("queue_old") then quiz.queue_old = []
if (quiz.queue.len+quiz.queue_old.len)>0 then
	fh = file.open("queue.json","w")
	fh.write json.toJSON(quiz.queue_old+quiz.queue)
	fh.close
else
	file.delete "queue.json"
end if

clear
print "Thank you for playing!"
load "startup.ms"