repl = {}
defn = function(cde,chr)
	repl[char(cde)] = chr
end function
// Latin-1 Supplement
defn 162, "c/"
defn 163, "L"
defn 164, "$?"
defn 165, "Y"
defn 166, "|"
defn 167, "SS"
defn 168, """"
defn 170, "a"
defn 171, "<<"
defn 175, "-"
defn 177, "+/-"
defn 178, "^2"
defn 179, "^3"
defn 180, "'"
defn 182, "P"
defn 183, "*"
defn 184, ","
defn 185, "1"
defn 186, char(176)
defn 187, ">>"
defn 188, "1/4"
defn 189, "1/2"
defn 190, "3/4"
// Latin Extended-A
lea_n = 256
lea_defn = function(ltn)
	defn lea_n, ltn.upper
	defn lea_n+1, ltn.lower
	outer.lea_n+=2
end function
lea_defn_s = function(s)
	for c in s
		lea_defn c
	end for
end function
lea_defn_s "AAACCCCDDEEEEEGGGGHHIIIII"
lea_defn "IJ" // LATIN CAPITAL/SMALL LIGATURE IJ (Dutch)
lea_defn_s "JK"
defn lea_n, "k"; lea_n+=1 // LATIN SMALL LETTER KRA
lea_defn_s "LLLLLNNN"
defn lea_n, "'n"; lea_n+=1 // LATIN SMALL LETTER N PRECEDED BY APOSTROPHE (yeah I don't get it either)
lea_defn_s "NOOO"
lea_defn "OE" // LATIN CAPITAL/SMALL LIGATURE OE
lea_defn_s "RRRSSSSTTTUUUUUUWY"
defn lea_n, "Y"; lea_n+=1 // LATIN CAPITAL LETTER Y WITH DIAERESIS
lea_defn_s "ZZZ"
defn lea_n, "s" // long s
// a few others
defn 8216, "'"
defn 8217, "'"

unidecode = function(s)
	r = ""
	for c in s
		if repl.hasIndex(c) then r+=repl[c] else r+=c
	end for
	return r
end function

if locals==globals then
	import "chars"
	skipcc = [127,173]
	for i in range(32,127)+range(161,255)+range(256,383)
		if chars.allPrintable.indexOf(char(i))==null and not repl.hasIndex(char(i)) and skipcc.indexOf(i)==null then
			print "Unsupported character "+char(i)+" (char("+i+"))"
		end if
	end for
end if