Iterator = {}
Iterator.make = function(args=null)
	ret = new self
	ret.init @args
	return ret
end function
Iterator.init = function(args=null)
	if @args isa funcRef then
		self._advance = @args
	else if @args isa list then
		self.args = @args
		self.i = 0
	else if @args isa map then
		tmp = []
		for kv in @args
			tmp.push kv
		end for
		self.init tmp
	else
		self._value = @args
	end if
end function
Iterator._advance = function
	if not self.hasIndex("args") then return null
	if not self.hasIndex("i") then return null
	if self.i>=self.args.len then return null
	ret = self.args[self.i]
	self.i+=1
	return ret
end function
Iterator.peek = function
	if not self.hasIndex("_value") then self._value = self._advance
	return @self._value
end function
Iterator.hasNext = function
	return self.peek!=null
end function
Iterator.next = function
	if self.hasIndex("_value") then
		ret = @self._value
		self.remove "_value"
		return @ret
	end if
	return self._advance
end function

import "mathUtil"
xrange = Iterator.make
xrange.init = function(args=null)
	if @args==null then args=[]
	if args.len<2 or args.len>3 then
		print "Runtime Error: xrange takes 2-3 arguments (start, stop, step)"
		pprint stackTrace
		exit
	end if
	self.step = 1
	if args.len==3 then self.step = args.pop
	if self.step==0 then
		print "Runtime Error: xrange step cannot be 0"
		pprint stackTrace
		exit
	end if
	self.start = args[0]
	self.stop = args[1]
	diff = self.stop-self.start
	if (diff<0 and self.step>0) or (diff>0 and self.step<0) then
		print "Runtime Error: cannot reach "+self.stop+" from "+self.start+" with step "+self.step
		pprint stackTrace
		exit
	end if
	self.value = self.start-self.step
end function
xrange.stopCondition = function
	if self.step>0 then
		return self.value>=self.stop
	else
		return self.value<=self.stop
	end if
end function
xrange._advance = function
	if self.stopCondition then return null
	self.value+=self.step
	if self.value<mathUtil.min(self.start,self.stop) or self.value>mathUtil.max(self.start,self.stop) then return null
	return self.value
end function
