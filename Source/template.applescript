use framework "Foundation"
use framework "AppKit"
use scripting additions

global gMULTI_WINDOW_MODE
global gLAUNCH_BAR_HIDDEN
global gTARGET_PROCESS_SPECIFIER, gTARGET_WINDOW_SPECIFIER

property builtinCommands : {"full", "left", "right", "top", "bottom", Â
	"1", "2", "3", "4", Â
	"1 top", "1 bottom", "3 top", "3 bottom", "2 top", "2 bottom", "4 top", "4 bottom", Â
	"1 left", "1 right", "2 left", "2 right", "3 left", "3 right", "4 left", "4 right", Â
	"1 sub 1", "1 sub 2", "1 sub 3", "1 sub 4", Â
	"2 sub 1", "2 sub 2", "2 sub 3", "2 sub 4", Â
	"3 sub 1", "3 sub 2", "3 sub 3", "3 sub 4", Â
	"4 sub 1", "4 sub 2", "4 sub 3", "4 sub 4", Â
	"a", "b", "c", "d", Â
	"two thirds left", "two thirds center", "two thirds right", Â
	"one third left", "one third horizontal center", "one third right", Â
	"one third top", "one third vertical center", "one third bottom", Â
	"one third left top", "one third left bottom", "one third center top", "one third center bottom", "one third right top", "one third right bottom", Â
	"center", "push left", "push right", "push top", "push bottom", Â
	"max width", "max height", Â
	"half width", "half height", Â
	"double width", "double height", Â
	"third width", "third height", Â
	"center", Â
	"grow width", "shrink width", "grow height", "shrink height", Â
	"grow horizontally", "shrink horizontally", "grow vertically", "shrink vertically", Â
	"move left", "move right", "move up", "move down"}

property cmd : missing value

property screenX : missing value
property screenY : missing value
property screenW : missing value
property screenH : missing value

property winX : missing value
property winY : missing value
property winW : missing value
property winH : missing value

property newX : missing value
property newY : missing value
property newW : missing value
property newH : missing value

property _halfScreenW : missing value
property _halfScreenH : missing value
property _thirdScreenW : missing value
property _thirdScreenH : missing value
property _twoThirdScreenW : missing value
property _twoThirdScreenH : missing value
property _quarterScreenW : missing value
property _quarterScreenH : missing value
property _eighthScreenW : missing value
property _eighthScreenH : missing value

property _doubleWinW : missing value
property _doubleWinH : missing value
property _halfWinW : missing value
property _halfWinH : missing value
property _thirdWinW : missing value
property _thirdWinH : missing value
property _twoThirdWinW : missing value
property _twoThirdWinH : missing value
property _quarterWinW : missing value
property _quarterWinH : missing value
property _eighthWinW : missing value
property _eighthWinH : missing value

on _____________MAIN()
end _____________MAIN

on run
	
	try
		
		-- This comment will be replaced by the build script
		
	on error eMsg number eNum
		
		activate
		display alert "Failed to nudge window" message eMsg
		
	end try
	
end run

on init(commandName)
	
	hideLaunchBar()
	
	set cmd to commandName
	
	try
		get gMULTI_WINDOW_MODE
		set multiWindowMode to gMULTI_WINDOW_MODE
	on error
		set multiWindowMode to false
	end try
	
	set _halfWinW to missing value
	set _halfWinH to missing value
	set _thirdWinW to missing value
	set _thirdWinH to missing value
	set _twoThirdWinW to missing value
	set _twoThirdWinH to missing value
	set _quarterWinW to missing value
	set _quarterWinH to missing value
	set _eighthWinW to missing value
	set _eighthWinH to missing value
	
	if not multiWindowMode or screenX is missing value then
		
		copy currentScreenBounds() to {screenX, screenY, screenW, screenH}
		
		set _halfScreenW to missing value
		set _halfScreenH to missing value
		set _thirdScreenW to missing value
		set _thirdScreenH to missing value
		set _twoThirdScreenW to missing value
		set _twoThirdScreenH to missing value
		set _quarterScreenW to missing value
		set _quarterScreenH to missing value
		set _eighthScreenW to missing value
		set _eighthScreenH to missing value
		
	end if
	
	copy currentWindowBounds() to {winX, winY, winW, winH}
	
	if cmd starts with "shrink" or Â
		cmd starts with "grow" or Â
		cmd starts with "move" or Â
		cmd is "center" or Â
		cmd starts with "max" or Â
		cmd starts with "push" or Â
		cmd starts with "half" or Â
		cmd starts with "double" or Â
		cmd starts with "third" then
		
		copy {winX, winY, winW, winH} to {newX, newY, newW, newH}
		
	else
		
		copy {screenX, screenY, screenW, screenH} to {newX, newY, newW, newH}
		
	end if
	
end init

on nudgeWindows(commands)
	
	set gMULTI_WINDOW_MODE to true
	
	if class of commands is text then
		set commands to splitString(commands, ",")
	end if
	
	set commandCount to count of commands
	
	if windowCount() < commandCount then
		log "Not enough windows to perform commands"
		beep
		return
	end if
	
	repeat with i from 1 to commandCount
		
		setTargetWindowSpecifier(i)
		nudgeWindow(item i of commands)
		
	end repeat
	
end nudgeWindows

on nudgeWindow(commandName)
	
	try
		
		set gMULTI_WINDOW_MODE to false
		
		-- Handling list of commands
		
		if (class of commandName is text and commandName contains ",") or Â
			class of commandName is list then
			
			return nudgeWindows(commandName)
			
		end if
		
		-- Handling single command
		
		init(commandName)
		
		if cmd is "full" then
			-- No changes		
			
		else if cmd is "left" then
			set newW to halfScreenW()
			
		else if cmd is "right" then
			set newW to halfScreenW()
			set newX to winX + halfScreenW()
			
		else if cmd is "top" then
			set newH to halfScreenH()
			
		else if cmd is "bottom" then
			set newH to halfScreenH()
			set newY to screenY + halfScreenH()
			
		else if cmd is "center" then
			set newX to screenX + (round ((screenW - winW) / 2))
			set newY to screenY + (round ((screenH - winH) / 3))
			
		else if cmd is "max width" then
			set newX to screenX
			set newW to screenW
			
		else if cmd is "max height" then
			set newY to screenY
			set newH to screenH
			
		else if cmd starts with "1" or cmd starts with "2" or cmd starts with "3" or cmd starts with "4" then
			handleQuadrant()
			
		else if (count of words in cmd) > 1 and second word of cmd contains "third" then
			handleThirds()
			
		else if cmd starts with "push" then
			handlePushes()
			
		else if cmd starts with "half" or cmd starts with "double" or cmd starts with "third" then
			handleHalfingAndDoubling()
			
		else if cmd starts with "shrink" or cmd starts with "grow" then
			handleShrinkOrGrowth()
			
		else if cmd starts with "move" then
			handleMoves()
			
		else if cmd starts with "a" or cmd starts with "b" or cmd starts with "c" or cmd starts with "d" then
			handleVerticalStrips()
			
		else
			error "Ò" & cmd & "Ó is an unknown command." number 1000
			
		end if
		
		applyNewValues()
		
	on error eMsg number eNum
		
		if eNum is 1001 then
			log "Process has no windows"
			beep
		else
			activate
			display alert "Failed to nudge window" message eMsg & " (" & (eNum as text) & ")"
		end if
	end try
	
end nudgeWindow

on handleQuadrant()
	
	if cmd starts with "1" then
		set newW to halfScreenW()
		set newH to halfScreenH()
		
	else if cmd starts with "2" then
		set newX to screenX + halfScreenW()
		set newW to halfScreenW()
		set newH to halfScreenH()
		
	else if cmd starts with "3" then
		set newY to screenY + halfScreenH()
		set newW to halfScreenW()
		set newH to halfScreenH()
		
	else if cmd starts with "4" then
		set newX to screenX + halfScreenW()
		set newY to screenY + halfScreenH()
		set newW to halfScreenW()
		set newH to halfScreenH()
	else
		error "Ò" & cmd & "Ó is an unknown command." number 1000
		
	end if
	
	if cmd contains " " then
		
		if cmd ends with " left" then
			set newW to quarterScreenW()
			
		else if cmd ends with " right" then
			set newW to quarterScreenW()
			set newX to newX + quarterScreenW()
			
		else if cmd ends with " top" then
			set newH to quarterScreenH()
			
		else if cmd ends with " bottom" then
			set newH to quarterScreenH()
			set newY to newY + quarterScreenH()
			
		else if cmd contains " sub " then
			handleSubQuadrant()
			
		else
			error "Ò" & cmd & "Ó is an unknown command." number 1000
			
		end if
		
	end if
	
end handleQuadrant

on handleSubQuadrant()
	
	try
		set quadrantNumber to last word of cmd as integer
	on error
		error "Invalid sub-quadrant"
	end try
	
	set newH to round (newH / 2)
	set newW to round (newW / 2)
	
	if quadrantNumber is 1 then
		
	else if quadrantNumber is 2 then
		set newX to newX + newW
		
	else if quadrantNumber is 3 then
		set newY to newY + newH
		
	else if quadrantNumber is 4 then
		set newX to newX + newW
		set newY to newY + newH
		
	else
		error "Ò" & cmd & "Ó is an unknown command." number 1000
	end if
	
end handleSubQuadrant

on handleShrinkOrGrowth()
	
	if cmd is "shrink width" then
		set newW to winW - eighthScreenW()
		
	else if cmd is "grow width" then
		set newW to winW + eighthScreenW()
		
	else if cmd is "shrink height" then
		set newH to winH - quarterScreenH()
		
	else if cmd is "grow height" then
		set newH to winH + quarterScreenH()
		
	else if cmd is "shrink horizontally" then
		set newX to winX + eighthScreenW()
		set newW to winW - quarterScreenW()
		
	else if cmd is "grow horizontally" then
		set newX to winX - eighthScreenW()
		set newW to winW + quarterScreenW()
		
	else if cmd is "shrink vertically" then
		set newY to winY + eighthScreenH()
		set newH to winH - quarterScreenH()
		
	else if cmd is "grow vertically" then
		set newY to winY - eighthScreenH()
		set newH to winH + quarterScreenH()
		
	else
		error "Ò" & cmd & "Ó is an unknown command." number 1000
		
	end if
	
end handleShrinkOrGrowth

on handleHalfingAndDoubling()
	
	if cmd is "half width" then
		set newW to halfWinW()
		
	else if cmd is "half height" then
		set newH to halfWinH()
		
	else if cmd is "double width" then
		set newW to doubleWinW()
		
	else if cmd is "double height" then
		set newH to doubleWinH()
		
	else if cmd is "third width" then
		set newW to thirdWinW()
		
	else if cmd is "third height" then
		set newH to thirdWinH()
		
	else
		error "Ò" & cmd & "Ó is an unknown command." number 1000
		
	end if
	
end handleHalfingAndDoubling

on handleThirds()
	
	if cmd is "two thirds left" then
		set newW to twoThirdScreenW()
		
	else if cmd is "two thirds center" then
		set newX to screenX + ((screenW - twoThirdScreenW()) / 2)
		set newW to twoThirdScreenW()
		
	else if cmd is "two thirds right" then
		set newX to screenX + thirdScreenW()
		set newW to twoThirdScreenW()
		
	else if cmd is "one third left" then
		set newW to thirdScreenW()
		
	else if cmd is "one third horizontal center" then
		set newW to thirdScreenW()
		set newX to screenX + (round ((screenW - newW) / 2))
		
	else if cmd is "one third right" then
		set newX to screenX + twoThirdScreenW()
		set newW to thirdScreenW()
		
	else if cmd is "one third right top" then
		set newX to screenX + twoThirdScreenW()
		set newW to thirdScreenW()
		set newH to halfScreenH()
		
	else if cmd is "one third right bottom" then
		set newX to screenX + twoThirdScreenW()
		set newY to screenY + halfScreenH()
		set newW to thirdScreenW()
		set newH to halfScreenH()
		
	else if cmd is "one third left top" then
		set newW to thirdScreenW()
		set newH to halfScreenH()
		
	else if cmd is "one third left bottom" then
		set newY to screenY + halfScreenH()
		set newW to thirdScreenW()
		set newH to halfScreenH()
		
	else if cmd is "one third center top" then
		set newW to thirdScreenW()
		set newX to screenX + (round ((screenW - newW) / 2))
		set newH to halfScreenH()
		
	else if cmd is "one third center bottom" then
		set newW to thirdScreenW()
		set newX to screenX + (round ((screenW - newW) / 2))
		set newY to screenY + halfScreenH()
		set newH to halfScreenH()
		
	else if cmd is "one third vertical center" then
		set newH to thirdScreenH()
		set newY to screenY + thirdScreenH()
		
	else if cmd is "one third top" then
		set newH to thirdScreenH()
		set newY to screenY
		
	else if cmd is "one third bottom" then
		set newH to thirdScreenH()
		set newY to screenY + twoThirdScreenH()
		
	else
		error "Ò" & cmd & "Ó is an unknown command." number 1000
		
	end if
	
end handleThirds

on handleMoves()
	
	if cmd is "move left" then
		set newX to winX - eighthScreenW()
		
	else if cmd is "move right" then
		set newX to winX + eighthScreenW()
		
	else if cmd is "move up" then
		set newY to winY - eighthScreenH()
		
	else if cmd is "move down" then
		set newY to winY + eighthScreenH()
		
	else
		error "Ò" & cmd & "Ó is an unknown command." number 1000
		
	end if
	
end handleMoves

on handleVerticalStrips()
	
	if cmd is "a" then
		set newW to quarterScreenW()
	else if cmd is "b" then
		set newX to quarterScreenW()
		set newW to quarterScreenW()
	else if cmd is "c" then
		set newX to quarterScreenW() * 2
		set newW to quarterScreenW()
	else if cmd is "d" then
		set newX to quarterScreenW() * 3
		set newW to quarterScreenW()
		
	else
		error "Ò" & cmd & "Ó is an unknown command." number 1000
		
	end if
	
end handleVerticalStrips

on handlePushes()
	
	if cmd is "push left" then
		set newX to screenX
		
	else if cmd is "push right" then
		set newX to screenX + screenW - winW
		
	else if cmd is "push top" then
		set newY to screenY
		
	else if cmd is "push bottom" then
		set newY to screenY + screenH - winH
		
	else
		error "Ò" & cmd & "Ó is an unknown command." number 1000
		
	end if
	
end handlePushes

on setWindowSize(x, y, w, h)
	
	log cmd & ", x: " & newX & ", y: " & newY & ", w: " & newW & ", h: " & newH
	
	tell application "System Events"
		tell (my targetProcess())
			
			set position of (my targetWindow()) to {x, y}
			set size of (my targetWindow()) to {w, h}
			
		end tell
	end tell
	
end setWindowSize

on applyNewValues()
	
	-- Horizontal guard
	if newW > screenW then
		set newW to screenW
		set newX to screenX
	else if newX < screenX then
		set newX to screenX
	end if
	
	if isRightOutOfBounds() then
		set newX to screenX + screenW - newW
	end if
	
	-- Vertical guard
	if newH > screenH then
		set newH to screenH
		set newY to screenY
	else if newY < screenY then
		set newY to screenY
	end if
	
	if isBottomOutOfBounds() then
		set newY to screenY + screenH - newH
	end if
	
	setWindowSize(newX, newY, newW, newH)
	
end applyNewValues

on _____________PROCESS()
end _____________PROCESS

on targetProcess()
	
	try
		get gTARGET_PROCESS_SPECIFIER
		if gTARGET_PROCESS_SPECIFIER is missing value then error 1
	on error
		tell application "System Events"
			return first process whose frontmost is true
		end tell
	end try
	
	if class of gTARGET_PROCESS_SPECIFIER is integer then
		
		try
			tell application "System Events"
				return first process whose unix id is gTARGET_PROCESS_SPECIFIER
			end tell
		on error eMsg number eNum
			log "targetProcess(): Could not find process with pid " & (gTARGET_PROCESS_SPECIFIER as text) & ": " & eMsg
		end try
		
	else if class of gTARGET_PROCESS_SPECIFIER is text then
		
		try
			tell application "System Events"
				return first process whose name is gTARGET_PROCESS_SPECIFIER
			end tell
		on error eMsg number eNum
			log "targetProcess(): Could not find process with name " & gTARGET_PROCESS_SPECIFIER & ": " & eMsg
		end try
		
	else
		
		error "targetProcess(): Wrong data type."
		
	end if
	
	return false
	
end targetProcess

on targetProcessName()
	
	tell application "System Events"
		return name of (my targetProcess())
	end tell
	
end targetProcessName

on setTargetProcessSpecifier(spec)
	
	if class of spec is integer then
		
		try
			tell application "System Events"
				set processName to name of first process whose unix id is spec
			end tell
			log "Found process Ò" & processName & "Ó for PID " & spec
		end try
		
	else if class of spec is text then
		
		try
			tell application "System Events"
				set processID to unix id of first process whose name is spec
			end tell
			log "Found PID " & processID & " for process name Ò" & spec & "Ó"
		end try
		
	else
		
		error "setTargetProcessSpecifier(): Wrong data type."
		
	end if
	
	set gTARGET_PROCESS_SPECIFIER to spec
	
end setTargetProcessSpecifier

on targetProcessSpecifier()
	
	return gTARGET_PROCESS_SPECIFIER
	
end targetProcessSpecifier

on _____________WINDOW()
end _____________WINDOW

on raiseWindow()
	
	tell application "System Events"
		tell (my targetProcess())
			tell (my targetWindow())
				perform action "AXRaise"
			end tell
		end tell
	end tell
	
end raiseWindow

on windowCount()
	
	tell application "System Events"
		tell (my targetProcess())
			return count of (windows whose subrole = "AXStandardWindow")
		end tell
	end tell
	
end windowCount

on existsTargetWindow()
	
	try
		return targetWindow() is not false
	on error
		return false
	end try
	
end existsTargetWindow

on targetWindow()
	
	try
		get gTARGET_WINDOW_SPECIFIER
		if gTARGET_WINDOW_SPECIFIER is missing value then error 1
	on error
		try
			
			if targetProcessName() is "Teams" then
				
				tell application "System Events"
					tell (my targetProcess())
						if name of (window 1 whose subrole is "AXStandardWindow") is "Microsoft Teams Notification" then
							set foundWindow to window 2 whose subrole is "AXStandardWindow"
							log foundWindow
							return foundWindow
						end if
					end tell
				end tell
				
			else
				
				tell application "System Events"
					tell (my targetProcess())
						set foundWindow to window 1 whose subrole is "AXStandardWindow"
						log foundWindow
						return foundWindow
					end tell
				end tell
				
			end if
			
		on error eMsg number eNum
			if eNum = -1719 then
				error "targetWindow(): Process has no windows. " & eMsg number 1001
			else
				error "targetWindow(): " & eMsg number eNum
			end if
			
		end try
	end try
	
	if class of gTARGET_WINDOW_SPECIFIER is integer then
		
		tell application "System Events"
			tell (my targetProcess())
				set foundWindow to window gTARGET_WINDOW_SPECIFIER whose subrole is "AXStandardWindow"
				log foundWindow
				return foundWindow
			end tell
		end tell
		
	else if class of gTARGET_WINDOW_SPECIFIER is text then
		
		tell application "System Events"
			tell (my targetProcess())
				set foundWindow to window gTARGET_WINDOW_SPECIFIER
				log foundWindow
				return foundWindow
			end tell
		end tell
		
	else if class of gTARGET_WINDOW_SPECIFIER is list then
		
		set targetPosition to {item 1 of gTARGET_WINDOW_SPECIFIER, item 2 of gTARGET_WINDOW_SPECIFIER}
		set targetSize to {item 3 of gTARGET_WINDOW_SPECIFIER, item 4 of gTARGET_WINDOW_SPECIFIER}
		
		
		tell application "System Events"
			tell (my targetProcess())
				set foundWindow to first window whose position is targetPosition and size is targetSize
				log foundWindow
				return foundWindow
			end tell
		end tell
		
	else
		
		error "targetWindow(): Wrong data type."
		
	end if
	
	return false
	
end targetWindow

on setTargetWindowSpecifier(spec)
	
	if class of spec is integer then
		
		try
			
			tell application "System Events"
				
				tell (my targetProcess())
					set theWindow to window spec whose subrole is "AXStandardWindow"
					set windowName to name of theWindow
				end tell
				
			end tell
			
			set windowBoundsDescription to getWindowBoundsDescription(theWindow)
			
			log "Found window Ò" & windowName & "Ó with bounds " & windowBoundsDescription & " at index " & spec
			
		end try
		
	else if class of spec is text then
		
		try
			
			tell application "System Events"
				
				tell (my targetProcess())
					set theWindow to window spec
				end tell
				
			end tell
			
			set windowBoundsDescription to getWindowBoundsDescription(theWindow)
			
			log "Found window with bounds " & windowBoundsDescription & " for name Ò" & spec & "Ó"
			
		end try
		
	else if class of spec is list then
		
		set targetPosition to {item 1 of spec, item 2 of spec}
		set targetSize to {item 3 of spec, item 4 of spec}
		
		try
			
			tell application "System Events"
				tell (my targetProcess())
					set theWindow to first window whose position is targetPosition and size is targetSize
					set windowName to name of theWindow
				end tell
			end tell
			
			set windowBoundsDescription to getWindowBoundsDescription(theWindow)
			
			log "Found window Ò" & windowName & "Ó for bounds " & windowBoundsDescription
			
		end try
		
	else
		
		error "setTargetWindowSpecifier(): Wrong data type."
		
	end if
	
	set gTARGET_WINDOW_SPECIFIER to spec
	
end setTargetWindowSpecifier

on targetWindowSpecifier()
	
	return gTARGET_WINDOW_SPECIFIER
	
end targetWindowSpecifier

on getWindowBounds(aWindow)
	
	tell application "System Events"
		tell (my targetProcess())
			if aWindow is false then
				tell (my targetWindow())
					copy position to {x, y}
					copy size to {w, h}
					return {x, y, w, h}
				end tell
			else
				tell aWindow
					copy position to {x, y}
					copy size to {w, h}
					return {x, y, w, h}
				end tell
			end if
		end tell
	end tell
	
end getWindowBounds

on getWindowBoundsDescription(aWindow)
	
	return "{" & joinList(getWindowBounds(aWindow), ",") & "}"
	
end getWindowBoundsDescription

on currentWindowBounds()
	
	return getWindowBounds(false)
	
end currentWindowBounds

on isRightOutOfBounds()
	
	return (newX + newW) > (screenX + screenW)
	
end isRightOutOfBounds

on isBottomOutOfBounds()
	
	return (newY + newH) > (screenY + screenH)
	
end isBottomOutOfBounds

on _____________SCREEN()
end _____________SCREEN

on screenZero()
	
	return item 1 of current application's NSScreen's screens
	
end screenZero

on currentScreen()
	
	set mouseLoc to current application's NSEvent's mouseLocation()
	set screenEnum to (current application's NSScreen's screens)'s objectEnumerator()
	
	repeat
		
		try
			set screen to screenEnum's nextObject
		on error
			exit repeat
		end try
		
		set isScreen to current application's NSMouseInRect(mouseLoc, screen's frame, false)
		
		if isScreen then
			return screen
		end if
	end repeat
	
	return missing value
	
end currentScreen

on currentScreenBounds()
	
	set mainScreen to screenZero()
	set thisScreen to currentScreen()
	
	set screenFrame to thisScreen's frame()
	set x to item 1 of item 1 of screenFrame as integer
	set y to item 2 of item 1 of screenFrame as integer
	set w to item 1 of item 2 of screenFrame as integer
	set h to item 2 of item 2 of screenFrame as integer
	
	if not thisScreen is mainScreen then
		set referenceFrame to mainScreen's frame()
		set rx to item 1 of item 1 of referenceFrame as integer
		set ry to item 2 of item 1 of referenceFrame as integer
		set rw to item 1 of item 2 of referenceFrame as integer
		set rh to item 2 of item 2 of referenceFrame as integer
		
		set y to rh - y - h
		
	end if
	
	set barHeight to menuBarHeight()
	
	set y to y + barHeight
	set h to h - barHeight
	
	return {x, y, w, h}
	
end currentScreenBounds

on menuBarHeight()
	
	try
		set h to current application's NSApplication's sharedApplication's mainMenu's menuBarHeight() as integer
		return h
	on error eMsg number eNum
		log "Could not get menu bar height: " & eMsg
		return 37
	end try
	
end menuBarHeight

on _____________SCREEN_SIZES()
end _____________SCREEN_SIZES

on halfScreenW()
	
	if _halfScreenW is missing value then
		set _halfScreenW to round (screenW / 2)
	end if
	
	return _halfScreenW
	
end halfScreenW

on halfScreenH()
	
	if _halfScreenH is missing value then
		set _halfScreenH to round (screenH / 2)
	end if
	
	return _halfScreenH
	
end halfScreenH

on thirdScreenW()
	
	if _thirdScreenW is missing value then
		set _thirdScreenW to round (screenW / 3)
	end if
	
	return _thirdScreenW
	
end thirdScreenW

on thirdScreenH()
	
	if _thirdScreenH is missing value then
		set _thirdScreenH to round (screenH / 3)
	end if
	
	return _thirdScreenH
	
end thirdScreenH

on twoThirdScreenW()
	
	if _twoThirdScreenW is missing value then
		set _twoThirdScreenW to round (screenW / 3 * 2)
	end if
	
	return _twoThirdScreenW
	
end twoThirdScreenW

on twoThirdScreenH()
	
	if _twoThirdScreenH is missing value then
		set _twoThirdScreenH to round (screenH / 3 * 2)
	end if
	
	return _twoThirdScreenH
	
end twoThirdScreenH

on quarterScreenW()
	
	if _quarterScreenW is missing value then
		set _quarterScreenW to round (screenW / 4)
	end if
	
	return _quarterScreenW
	
end quarterScreenW

on quarterScreenH()
	
	if _quarterScreenH is missing value then
		set _quarterScreenH to round (screenH / 4)
	end if
	
	return _quarterScreenH
	
end quarterScreenH

on eighthScreenW()
	
	if _eighthScreenW is missing value then
		set _eighthScreenW to round (screenW / 8)
	end if
	
	return _eighthScreenW
	
end eighthScreenW

on eighthScreenH()
	
	if _eighthScreenH is missing value then
		set _eighthScreenH to round (screenH / 8)
	end if
	
	return _eighthScreenH
	
end eighthScreenH

on _____________WINDOW_SIZES()
end _____________WINDOW_SIZES

on doubleWinW()
	
	if _doubleWinW is missing value then
		set _doubleWinW to winW * 2
	end if
	
	return _doubleWinW
	
end doubleWinW

on doubleWinH()
	
	if _doubleWinH is missing value then
		set _doubleWinH to winH * 2
	end if
	
	return _doubleWinH
	
end doubleWinH

on halfWinW()
	
	if _halfWinW is missing value then
		set _halfWinW to round (winW / 2)
	end if
	
	return _halfWinW
	
end halfWinW

on halfWinH()
	
	if _halfWinH is missing value then
		set _halfWinH to round (winH / 2)
	end if
	
	return _halfWinH
	
end halfWinH

on thirdWinW()
	
	if _thirdWinW is missing value then
		set _thirdWinW to round (winW / 3)
	end if
	
	return _thirdWinW
	
end thirdWinW

on thirdWinH()
	
	if _thirdWinH is missing value then
		set _thirdWinH to round (winH / 3)
	end if
	
	return _thirdWinH
	
end thirdWinH

on twoThirdWinW()
	
	if _twoThirdWinW is missing value then
		set _twoThirdWinW to round (winW / 3 * 2)
	end if
	
	return _twoThirdWinW
	
end twoThirdWinW

on twoThirdWinH()
	
	if _twoThirdWinH is missing value then
		set _twoThirdWinH to round (winH / 3 * 2)
	end if
	
	return _twoThirdWinH
	
end twoThirdWinH

on quarterWinW()
	
	if _quarterWinW is missing value then
		set _quarterWinW to round (winW / 4)
	end if
	
	return _quarterWinW
	
end quarterWinW

on quarterWinH()
	
	if _quarterWinH is missing value then
		set _quarterWinH to round (winH / 4)
	end if
	
	return _quarterWinH
	
end quarterWinH

on eighthWinW()
	
	if _eighthWinW is missing value then
		set _eighthWinW to round (winW / 8)
	end if
	
	return _eighthWinW
	
end eighthWinW

on eighthWinH()
	
	if _eighthWinH is missing value then
		set _eighthWinH to round (winH / 8)
	end if
	
	return _eighthWinH
	
end eighthWinH

on _____________FILESYSTEM()
end _____________FILESYSTEM

on hfsPath(aPath)
	
	(* Converts any file reference even relative ones to a HFS-style path string. *)
	
	-- Convert path to text
	set aPath to aPath as text
	
	if aPath starts with "'" and aPath ends with "'" then
		-- Remove quotes
		set aPath to text 2 thru -2 of anyPath
	end if
	
	if aPath does not contain "/" and aPath does not contain ":" then
		-- Only filename specified; treat as path relative to current directory
		set aPath to "./" & aPath
	end if
	
	if aPath starts with "~" then
		
		-- Expand tilde
		
		-- Get the path to the userÕs home folder
		set userPath to POSIX path of (path to home folder)
		
		-- Remove trailing slash
		if userPath ends with "/" then set userPath to (text 1 thru -2 of userPath) as text
		
		if aPath is "~" then
			-- Simply use home folder path
			set aPath to userPath
		else
			-- Concatenate paths
			set aPath to userPath & (text 2 thru -1 of aPath)
		end if
		
	else if aPath starts with "./" then
		
		-- Convert reference to current directory to absolute path
		
		set aPath to text 3 thru -1 of aPath
		
		try
			set myPath to POSIX path of kScriptPath
		on error
			set myPath to POSIX path of (path to me)
		end try
		
		set prvDlmt to text item delimiters
		set text item delimiters to "/"
		set parentDirectoryPath to (text items 1 thru -2 of myPath) & "" as text
		set text item delimiters to prvDlmt
		
		set aPath to parentDirectoryPath & aPath
		
	else if aPath starts with "../" then
		
		-- Convert reference to parent directories to absolute path
		
		try
			set myPath to POSIX path of kScriptPath
		on error
			set myPath to POSIX path of (path to me)
		end try
		
		set prvDlmt to text item delimiters
		set text item delimiters to "../"
		set pathComponents to text items of aPath
		set parentDirectoryCount to (count of pathComponents)
		set text item delimiters to "/"
		set myPathComponents to text items of myPath
		set parentDirectoryPath to (items 1 thru ((count of items of myPathComponents) - parentDirectoryCount) of myPathComponents) & "" as text
		set text item delimiters to prvDlmt
		
		set aPath to parentDirectoryPath & item -1 of pathComponents
		
	end if
	
	if aPath does not contain ":" then
		set aPath to (POSIX file aPath) as text
	end if
	
	return aPath
	
end hfsPath

on qpp(aPath)
	
	return quoted form of (POSIX path of aPath)
	
end qpp

on _____________UTILITIES()
end _____________UTILITIES

on splitString(aText, aDelimiter)
	
	(* Splits a string the specified delimiter *)
	
	if class of aText is not text then
		error "splitString(): Wrong data type" number 1
	end if
	
	set prvDlmt to text item delimiters
	set text item delimiters to aDelimiter
	
	set anOutput to text items of aText
	
	set text item delimiters to prvDlmt
	
	return anOutput
	
end splitString

on joinList(aList, aDelimiter)
	
	(* Joins a list using the specified delimiter *)
	
	if aDelimiter is false then set aDelimiter to ""
	
	set prvDlmt to text item delimiters
	set text item delimiters to aDelimiter
	
	set aList to aList as text
	
	set text item delimiters to prvDlmt
	
	return aList
	
end joinList

on areModifiersPressed(modifiersList)
	
	(* Returns boolean representing whether the modifier keys in the specified list are pressed together at the time this function is called *)
	
	(* Modifier key names: CapsLock, Shift, Control, Option, Command, Function *)
	
	if class of modifiersList is text then
		set modifiersList to {modifiersList}
	end if
	
	tell current application
		
		set modifierSum to 0
		
		repeat with modifierName in modifiersList
			
			set modifierName to modifierName as text
			
			if modifierName is "CapsLock" then
				set modifier to its NSEventModifierFlagCapsLock
			else if modifierName is "Shift" then
				set modifier to its NSEventModifierFlagShift
			else if modifierName is "Control" then
				set modifier to its NSEventModifierFlagControl
			else if modifierName is "Option" then
				set modifier to its NSEventModifierFlagOption
			else if modifierName is "Command" then
				set modifier to its NSEventModifierFlagCommand
			else if modifierName is "Function" then
				set modifier to its NSEventModifierFlagFunction
			else
				error "areModifiersPressed(): Unknown modifier name: " & modifierName
			end if
			
			set modifierSum to modifierSum + modifier
			
		end repeat
		
		set flags to its NSEvent's modifierFlags()
		
		return flags = modifierSum
		
	end tell
	
end areModifiersPressed

on hideLaunchBar()
	
	-- Hide LaunchBar if it is running but make sure to only do this once
	
	try
		get gLAUNCH_BAR_HIDDEN
	on error
		set gLAUNCH_BAR_HIDDEN to false
	end try
	
	if gLAUNCH_BAR_HIDDEN then return
	
	-- Accessing application names through a variable spares us from pesky dialogs on systems that donÕt have the application installed
	set lbName to "LaunchBar"
	
	tell application "System Events"
		set lbRunning to (exists process lbName)
	end tell
	
	if lbRunning then
		
		try
			tell application lbName
				Çevent odlbhideÈ
			end tell
		on error eMsg number eNum
			log "Could not hide LaunchBar: " & eMsg
		end try
		
		set gLAUNCH_BAR_HIDDEN to true
		
	end if
	
end hideLaunchBar