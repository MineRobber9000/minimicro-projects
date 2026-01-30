import "json"
import "bmfFonts"
import "grfon"

defaultConfig = {"hostname":"localhost","port":32767,"api_key":null,"checkInterval":5}
config = defaultConfig+grfon.parse(file.readLines("config.grfon").join(char(10)))

if globals.hasIndex("frames") then
	print "Keeping animation from last run..."
else
	print "Loading animation...",""
	n=0
	frames = []
	for i in range(1,100)
		if i<1000 then s=""+i
		if i<100 then s="0"+i
		if i<10 then s="00"+i
		frames.push file.loadImage(["im_",s,".png"].join(""))
		n+=1
		if n>10 then
			n-=10
			print ".",""
		end if
	end for
	print
end if

prepFont = function(f)
	for c in " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
		f.getCharImage c
	end for
end function

if globals.hasIndex("font") then
	print "Keeping font from previous run..."
else
	print "Loading font..."
	font = bmfFonts.Font.load("/sys/fonts/Georgia-24.bmf")
	print "Prepping font..."
	//	font.print " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", 0, 0
	prepFont font
end if

if globals.hasIndex("font2") then
	print "Keeping font2 from previous run..."
else
	print "Loading font2..."
	font2 = bmfFonts.Font.load("Georgia-48.bmf")
	print "Prepping font2..."
	//	font2.print " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", 0, 0
	prepFont font2
end if

apiUrl = function(route)
	return ["http://",config.hostname,":",config.port,"/api/v1/",route].join("")
end function

apiSong = apiUrl("song")
apiPlay = apiUrl("play")
apiPause = apiUrl("pause")
apiPrevious = apiUrl("previous")
apiNext = apiUrl("next")
apiGoBack = apiUrl("go-back")
apiGoForward = apiUrl("go-forward")

apiGet = function(url)
	headers = {}
	if config.api_key!=null then headers["Authorization"] = ["Bearer ",config.api_key].join("")
	return http.get(url,headers)
end function

apiPost = function(url,data="",_headers=null)
	if _headers==null then _headers={}
	headers = _headers+{}
	if config.api_key!=null then headers["Authorization"] = ["Bearer ",config.api_key].join("")
	return http.post(url,"",headers)
end function

_songData = function
	return json.parse(apiGet(apiSong))
end function
songData = null //_songData

if not globals.hasIndex("_cover") then _cover = null
cover = function
	if _cover==null or (songData!=null and _cover.path!=songData.imageSrc) then
		globals._cover = http.get(songData.imageSrc)
	end if
	return _cover
end function

coverBottom = 196 // picked by hand
updateDisplay = function
	gfx.clear
	gfx.drawImage cover, 24, coverBottom, 136, 136
	if songData.hasIndex("album") then
		font.print [songData.artist,"-",songData.album].join, 24+136+8, coverBottom+16+8
	else
		font.print songData.artist, 24+136+8, coverBottom+16+8
	end if
	font2.print songData.title, 24+136+8, coverBottom+16+8+24+8
	if songData.isPaused then
		overlay.fillRect 24, coverBottom, 136, 136, "#777777cc"
	else
		overlay.clear
	end if
	updateProgressBar
end function

updateProgressBar = function
	gfx.fillRect 24+136+8, coverBottom+4, 768, 8, "#cccccccc"
	gfx.fillRect 24+136+8, coverBottom+4, 768*(songData.elapsedSeconds/songData.songDuration), 8, "#ff0000cc"
end function

checkForUpdate = function
	if songData==null then
		globals.songData = _songData
		updateDisplay
		return
	end if
	resData = _songData
	if not (resData.title==songData.title and resData.artist==songData.artist and resData.imageSrc==songData.imageSrc and (resData.album==songData.album) and resData.isPaused==songData.isPaused) then
		globals.songData = resData
		updateDisplay
		return
	end if
	globals.songData = resData
end function

_pressed = {}
pressed = function(_key)
	if _pressed.hasIndex(_key) then old = _pressed[_key] else old = false
	_pressed[_key] = key.pressed(_key)
	if old then return false else return _pressed[_key]
end function

// get delta time since last call; used to ensure smooth playback of animation
ot = time
delta = function
	nt = time
	ret = nt-ot
	outer.ot = nt
	return ret
end function

// reset displays to known starting state
clear
// display 6 = bg, used for video loop
display(6).mode = displayMode.pixel
bg = display(6)
// display 5 = gfx, used for cover art
gfx.clear "#00000000" // clear
// display 4 = overlay, used for pause effect
// this is usually the sprite display but we aren't using sprites
display(4).mode = displayMode.pixel
overlay = display(4)
overlay.clear "#00000000" // clear

checkForUpdate

at = 0
ct = 0
f = 0
gfr = (1/25)
while true
	bg.drawImage frames[f], 0, 0, 960, 640
	yield
	p = delta
	at += p
	if at>=gfr then
		at-=gfr
		f=(f+1)%frames.len
	end if
	if not songData.isPaused then
		songData.elapsedSeconds += p
		updateProgressBar
	end if
	ct += p
	if songData.elapsedSeconds>songData.songDuration then
		songData.isPaused = true
		songData.elapsedSeconds = 0
		songData.songDuration = 1
		ct=config.checkInterval-1
	end if
	if pressed("r") then ct=config.checkInterval
	if ct>=config.checkInterval then
		ct -= config.checkInterval
		checkForUpdate
	end if
	if pressed("k") then
		if songData.isPaused then
			apiPost apiPlay
			songData.isPaused = false
		else
			apiPost apiPause
			songData.isPaused = true
		end if
		updateDisplay
	end if
	if pressed("j") then
		apiPost apiPrevious
		ct = config.checkInterval-1.5
	end if
	if pressed("l") then
		apiPost apiNext
		ct = config.checkInterval-1.5
	end if
	if pressed(",") then
		apiPost apiGoBack, "{""seconds"": 10}", {"Content-Type":"application/json"}
		ct = config.checkInterval-1.5
	end if
	if pressed(".") then
		apiPost apiGoForward, "{""seconds"": 10}", {"Content-Type":"application/json"}
		ct = config.checkInterval-1.5		
	end if
end while