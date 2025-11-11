// base64 in MiniScript
// by minerobber
// Mini Micro-exclusive (uses RawData)
// use base64.encode/decode for standard base64
// also supports variants (use .encode/decode on variants):
// - standard (A-Za-z0-9+/; base64.standard)
// - URL (A-Za-z0-9-_; base64.url)
// - B64 (crypt/GEDCOM; ./0-9A-Za-z; base64.b64/crypt/gedcom)
// - bcrypt (./A-Za-z0-9; base64.bcrypt)
// - bash base64 literals (0-9A-Za-z@_; base64.bash)

// Helper functions: shiftLeft, shiftRight
shiftLeft = function(n, places)
	return bitAnd(floor(n)*(2^places),255)
end function
shiftRight = function(n, places)
	return floor(n/(2^places))
end function

encoding = {}
// alphabet
encoding.alphabet = ""
// encode with padding
encoding.pad = true
// encodes up to 3 bytes into up to 4 characters
encoding._encode = function(b1,b2=-1,b3=-1)
	if b2==-1 and b3==-1 then // only 1 byte to encode
		c1 = shiftRight(b1,2)
		c2 = shiftLeft(bitAnd(b1,3),4)
		r = self.alphabet[c1]+self.alphabet[c2]
		if self.pad then
			r += "=="
		end if
		return r
	else if b3==-1 then
		c1 = shiftRight(b1,2)
		c2 = shiftLeft(bitAnd(b1,3),4)+shiftRight(b2,4)
		c3 = shiftLeft(bitAnd(b2,15),2)
		r = self.alphabet[c1]+self.alphabet[c2]+self.alphabet[c3]
		if self.pad then
			r += "="
		end if
		return r
	else
		c1 = shiftRight(b1,2)
		c2 = shiftLeft(bitAnd(b1,3),4)+shiftRight(b2,4)
		c3 = shiftLeft(bitAnd(b2,15),2)+shiftRight(b3,6)
		c4 = bitAnd(b3,63)
		return self.alphabet[c1]+self.alphabet[c2]+self.alphabet[c3]+self.alphabet[c4]
	end if
end function
// decodes up to 4 characters into up to 3 bytes
encoding._decode = function(chunk)
	chunk = chunk[:4]
	while chunk[-1]=="="; chunk = chunk[:-1]; end while
	if chunk.len<2 then return []
	if chunk.len==2 then
		c1 = self.alphabet.indexOf(chunk[0])
		c2 = self.alphabet.indexOf(chunk[1])
		if not (c1!=null and c2!=null) then return []
		b1 = shiftLeft(c1,2)+shiftRight(c2,4)
		return [b1]
	else if chunk.len==3 then
		c1 = self.alphabet.indexOf(chunk[0])
		c2 = self.alphabet.indexOf(chunk[1])
		c3 = self.alphabet.indexOf(chunk[2])
		if not (c1!=null and c2!=null and c3!=null) then return []
		b1 = shiftLeft(c1,2)+shiftRight(c2,4)
		b2 = shiftLeft(bitAnd(c2,15),4)+shiftRight(c3,2)
		return [b1, b2]
	else if chunk.len==4 then
		c1 = self.alphabet.indexOf(chunk[0])
		c2 = self.alphabet.indexOf(chunk[1])
		c3 = self.alphabet.indexOf(chunk[2])
		c4 = self.alphabet.indexOf(chunk[3])
		if not (c1!=null and c2!=null and c3!=null and c4!=null) then return []
		b1 = shiftLeft(c1,2)+shiftRight(c2,4)
		b2 = shiftLeft(bitAnd(c2,15),4)+shiftRight(c3,2)
		b3 = shiftLeft(bitAnd(c3,3),6)+c4
		return [b1, b2, b3]
	end if
end function
// encode RawData to base64
encoding.encode = function(data)
	i = 0
	r = ""
	while (i+2)<data.len
		b1 = data.byte(i)
		b2 = data.byte(i+1)
		b3 = data.byte(i+2)
		r += self._encode(b1,b2,b3)
		i += 3
	end while
	if (i+1)<data.len then
		r += self._encode(data.byte(i),data.byte(i+1))
	else if i<data.len then
		r += self._encode(data.byte(i))
	end if
	return r
end function
// decode base64 to RawData
encoding.decode = function(b64)
	clean = ""
	for c in b64
		if self.alphabet.indexOf(c)!=null or c=="=" then clean+=c
	end for
	ret = new RawData
	i = 0
	j = 0
	while i<clean.len
		bytes = self._decode(clean[i:i+4])
		ret.resize ret.len+bytes.len
		for byte in bytes
			ret.setByte j, byte
			j += 1
		end for
		i += 4
	end while
	return ret
end function

_alph6263 = function(c62,c63)
	return "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"+c62+c63
end function

// RFC 4648 section 4 - base64 standard/common
standard = new encoding
standard.alphabet = _alph6263("+","/")
common = standard

// RFC 4648 section 5 - base64 url
url = new encoding
url.alphabet = _alph6263("-","_")

// B64 - used by crypt, GEDCOM
b64 = new encoding
b64.alphabet = "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
b64.pad = false
crypt = b64
gedcom = b64

// bcrypt - different alphabet but same idea
bcrypt = new b64
bcrypt.alphabet = "./ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

// bash - completely different alphabet (why? I dunno)
bash = new encoding
bash.alphabet = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@_"

// default to encoding/decoding standard base64
encode = function(data); return standard.encode(data); end function
decode = function(b64); return standard.decode(b64); end function