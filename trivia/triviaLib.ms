import "json"
import "stringUtil"
import "unidecode"
unidecode = @unidecode.unidecode

api = {}
api.get = function(path,args=null)
	if args==null then args={}
	url = "https://opentdb.com/"+path
	if args.indexes.len then
		url += "?"
		for kv in args
			url += kv.key.urlEncode + "=" + kv.value.urlEncode
			url += "&"
		end for
		url = url[:-1]
	end if
	ret = http.get(url)
	fh = file.open("tmp.txt","w")
	fh.write ret
	fh.close
	if not ret isa string then
		clear
		print "Error in OpenTDB request:"
		print "URL:", " "
		print url
		print "Result:"
		pprint ret
		exit
	end if
	if ret=="HTTP/1.1 429 Too Many Requests" then
		ret = {"response_code": 5}
	else
		ret = json.parse(ret)
	end if
	if not ret isa map then
		clear
		print "Error in OpenTDB request parsing:"
		print "URL:", " "
		print url
		print "Response:"
		pprint 
		print "Result:"
		pprint ret
		exit
	end if
	if not ret.hasIndex("response_code") then ret.response_code = 0
	if ret.response_code==5 then // rate limit, wait 5 and rerun
		wait 5.5
		return api.get(path,args)
	end if
	return ret
end function
api.question = function(token, count=1, category=-1, difficulty=-1)
	args = {}
	args.token = token
	args.encode = "url3986"
	args.amount = ""+count
	if category>-1 then args.category = json.toJSON(category)
	if difficulty!=-1 then args.difficulty = difficulty.lower
	question = api.get("api.php",args)
	if question.response_code == 4 then
		return {"refresh": 1}
	end if
	return question
end function
api.request_token = function
	return api.get("api_token.php",{"command": "request"}).token
end function
api.reset_token = function(token)
	result = api.get("api_token.php",{"command": "reset", "token": token})
	if result.response_code==3 then // token not found, get new one
		return api.request_token
	end if
	return token
end function
api.categories = function
	fh = file.open("categories.json")
	val = json.parse(fh.read)
	fh.close
	api.categories = val
	return val
end function
api.categories_ordered = function
	ordered = api.categories.indexes
	ordered.sort
	self.categories_ordered = ordered
	return ordered
end function

session = {}
session.token = function
	token = api.request_token
	self.token = token
	return token
end function
unescape = function(o)
	if o isa list then
		for i in range(0,o.len-1)
			o[i]=unescape(o[i])
		end for
		return o
	end if
	if o isa map then
		for kv in o
			o[kv.key]=unescape(kv.value)
		end for
		return o
	end if
	if o isa string then
		return unidecode(o.urlDecode)
	end if
	return o
end function
session.question = function(count=1,category=-1,difficulty=-1,_repeat=0)
	q = api.question(self.token,count,category,difficulty)
	if q.hasIndex("refresh") then // token ran out of questions, reset
		if _repeat then
			return []
		end if
		self.refresh
		return self.question(count,category,difficulty,1)
	end if
	q.results = unescape(q.results)
	return q.results
end function
session.refresh = function
	self.token = api.reset_token(self.token)
end function