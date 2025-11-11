FuncIter = {}
FuncIter.make = function(funRef)
	ret = new FuncIter
	ret._fn = @funRef
	return ret
end function
FuncIter.next = function
	if self.hasIndex("_value") then
		ret = self._value
		self.remove "_value"
		return ret
	end if
	return self._fn
end function
FuncIter.peek = function
	if not self.hasIndex("_value") then
		self._value = self._fn
	end if
	return self._value
end function
FuncIter.hasNext = function
	return self.peek!=null
end function