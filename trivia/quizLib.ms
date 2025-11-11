// OpenTDB functions
import "triviaLib"
import "mathUtil"
min = @mathUtil.min
import "unidecode"
unidecode = @unidecode.unidecode

abort = function(msg)
	clear
	print "ABORT: "+msg
	load "quizLib.ms"
	exit
end function

// The main quiz object.
// Loads a certain number of questions and iterates over them
quiz = {}
// Number of questions; defaults to 20
quiz.questions = 20
// Categories: true = included, false = excluded
quiz.categories = {}
for category in triviaLib.api.categories_ordered
	quiz.categories[category]=true
end for
// Flag to recalculate category_names
quiz._categories_changed = true
// A list of category names.
// Essentially every category in quiz.categories that is included
quiz.category_names = function
	if self._categories_changed then
		self._category_names = []
		for kv in self.categories
			if kv.value then self._category_names.push kv.key
		end for
		self._categories_changed = false
	end if
	return self._category_names
end function
// Difficulties, same as quiz.categories
quiz.difficulties = {"Easy": true, "Medium": true, "Hard": true}
// Same as _categories_changed
quiz._difficulties_changed = true
// Same as category_names
quiz.possible_difficulties = function
	if self._difficulties_changed then
		self._possible_difficulties = []
		for kv in self.difficulties
			if kv.value then self._possible_difficulties.push kv.key
		end for
		self._difficulties_changed = false
	end if
	return self._possible_difficulties
end function
// Displays the settings.
quiz.display_settings = function
	print "Questions: "+self.questions
	if self.category_names.len>12 then
		print "Categories: ("+self.category_names.len+" selected)"
	else
		print ("Categories: "+self.category_names.join(", ")).wrap.join(char(10))
	end if
	print "Difficulties: "+self.possible_difficulties.join(", ")
end function
// triviaLib session for quizzes
quiz.session = new triviaLib.session
// list of questions
quiz.lquestions = []
// list of maps for correct and "chosen" answers
quiz.answers = []
// current question index
quiz.questioni = 0
// last time we hit OpenTDB with a request
quiz.last_question = -5
// Loads questions. This is a doozy.
quiz.load = function
	// if we've loaded all the questions we don't need more
	if self.lquestions.len>=self.questions then return false //abort("We have enough questions")
	// if we're making requests too fast opentdb will get mad at us
	if (time - self.last_question) < 5 then return false //abort("Too fast ("+(time-self.last_question)+" seconds since last req)")
	category = -1
	difficulty = -1
	if self.category_names.len==1 then category = triviaLib.api.categories[self.category_names[0]]
	if self.possible_difficulties.len==1 then difficulty = self.possible_difficulties[0]
	// STUPID DUMB HACK WHY HAVE THE CODING GODS FORSAKEN ME
	// so basically, if we have 1 category and 1 difficulty
	// we can just request 'quiz.questions' worth of that category/difficulty combo
	if category!=-1 and difficulty!=-1 then
		qs = self.session.question(min(self.questions-self.lquestions.len,50),category,difficulty)
		if qs.len==0 then return -1 // not enough questions in the DB to fill this query
		for q in qs
			self.lquestions.push q
			self.answers.push {"correct": q.correct_answer}
		end for
		self.last_question = time
		return self.lquestions.len==self.questions
	else
		// if we DON'T, we have to spray and pray
		// grab 50 questions (the max allowed) and then filter
		// on allowed category/difficulty
		// this can theoretically take a long-*** time in the worst case
		// but opentdb doesn't accept multi-category/multi-difficulty requests
		// so we just gotta roll with what we're given
		if not self.hasIndex("queue") then self.queue=[]
		if not self.hasIndex("queue_old") then self.queue_old=[]
		if self.queue.len<self.questions then
			self.queue = self.session.question(50,category,difficulty) + self.queue_old + self.queue
			if self.queue.len==0 then return -1 // not enough questions in the DB to fill this query
			self.last_question = time
		end if
		n = self.questions-self.lquestions.len
		while self.queue.len>0 and n>0
			q = self.queue.pop
			// if:
			// - the category isn't in the categories we're using, or
			// - the difficulty isn't in the difficulties we're using
			// we can't use this question in this quiz right now
			if self.category_names.indexOf(q.category)==null or self.possible_difficulties.join("").lower.indexOf(q.difficulty)==null then
				// push it to be retried next time we refill the queue (unless it's gone around 3 times, then discard it)
				if not q.hasIndex("age") then q.age = 0
				q.age+=1
				if q.age<3 then self.queue_old.push q
			else // it's in a good category and a good difficulty
				// push it
				q.question = unidecode(q.question)
				self.lquestions.push q
				self.answers.push {"correct": q.correct_answer}
				// decrease n (we've accepted a question)
				n-=1
			end if
		end while
		// if n==0, we've filled our questions
		// if n>0, we've ran out of questions in the queue
		// which means we need to wait 5 and try again
		return n==0
	end if
	return true
end function
// returns the next question index
// or null if we're done
quiz.next = function
	if self.questioni==self.questions then return null
	self.questioni+=1
	return self.questioni-1
end function
// restarts the quiz at first question
// without drawing new questions
// (useful for multiplayer quiz)
quiz.restart = function
	self.questioni = 0
end function
// resets the quiz, restarting at first question
// and drawing all new questions
quiz.reset = function
	self.restart
	self.lquestions=[]
	self.answers=[]
	// leave the queues alone
end function
