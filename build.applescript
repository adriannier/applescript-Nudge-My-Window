(*

Nudge My Window - build.applescript

This script builds the individual AppleScript files to reposition and/or resize windows.

*)

(*

## A WORD ABOUT THE INSTALL LOCATION

The *installLocation* property allows you to specify a custom installation location. You can use either HFS-style or POSIX-style paths. The tilde (~) is supported as the first character to specify the current home directory.

Please note that built script files are moved to the installation location only after ALL script files have been built successfully.

You can restore the default behavior of building the script files in the project’s directory by setting *installLocation* to an empty string.

Alternatively you can set the installation location using the shell. The path will be stored locally on your Mac and survive replacements of the project directory. To do so, use the following command:

defaults write de.adriannier.NudgeMyWindow installLocation '~/Desktop/Test'

Setting the *installLocation* in this script will override whatever was set using the shell command.

To clear the installation location using the shell, use the following command:
defaults write de.adriannier.NudgeMyWindow installLocation ''

*)

property installLocation : ""

----

global failedCompilationCount
global tempOutputFolderPath
global compilationErrorMessage
global installLocationPath

property libraryRelativePath : "./Source/template.applescript"
property additionalCommandsRelativePath : "./Source/Additional Commands/"
property scriptNamePrefix : "Nudge My Window - "
property scriptNamePrefixUsedForDeletion : "Nudge My Window - "
property outputFolderName : "Build"
property templateInsertMarker : "-- This comment will be replaced by the build script"
property additionalCommandScriptStartMarker : "-- Code after this line will run as your custom command"
property additionalCommandScriptEndMarker : "-- Code before this line will run as your custom command"

on run
	
	-- Init
	set failedCompilationCount to 0
	set compilationErrorMessage to ""
	set libraryPath to hfsPath(libraryRelativePath)
	
	-- Check the installation location so we don’t build if there’s nowhere to put the built script files
	checkInstallLocation()
	
	-- Determine temporary output folder and reset it
	set tempOutputFolderPath to hfsPath(outputFolderName & "_temp")
	if tempOutputFolderPath does not end with ":" then
		set tempOutputFolderPath to tempOutputFolderPath & ":"
	end if
	do shell script "rm -rf " & qpp(tempOutputFolderPath)
	do shell script "mkdir -p " & qpp(tempOutputFolderPath)
	
	-- Load the library so we can get the list of all supported commands later on	
	set Nudger to loadScript(libraryRelativePath)
	
	-- Get the source of the library so we can use it as a template to create individual scripts
	set NudgerSource to readScriptFile(libraryPath, "MACROMAN", {templateInsertMarker})
	if NudgerSource is false then
		error "Could not find insert marker in template. This could also be a text encoding problem."
	end if
	
	-- Get a list of all additional commands
	set additionalCommandsPath to hfsPath(additionalCommandsRelativePath)
	try
		set additionalCommands to paragraphs of (do shell script "ls " & qpp(additionalCommandsPath) & " | grep '.applescript'")
	on error
		set additionalCommands to {}
	end try
	
	-- Initialize variables to keep track of failed compilations
	set failedCompilationCount to 0
	
	-- Iterate through additional commands to create scripts for them
	repeat with additionalCommand in additionalCommands
		
		set cmdName to text 1 thru -13 of additionalCommand
		
		log "Compiling additional command «" & cmdName & "»"
		
		-- Get the relevant script statements from the additional command script file
		set additionalCommandPath to additionalCommandsPath & additionalCommand
		
		-- Read script file
		set additionalCommandScriptSource to readScriptFile(additionalCommandPath, "UTF-16", {additionalCommandScriptStartMarker, additionalCommandScriptEndMarker})
		if additionalCommandScriptSource is false then
			error "Could not find markers in additional command script file. This could also be a text encoding problem."
		end if
		
		-- Get just the part of the source code we are interested in
		set additionalCommandSource to trim(textBetween(additionalCommandScriptSource, additionalCommandScriptStartMarker, additionalCommandScriptEndMarker))
		
		-- Use the template to create the source code for this script file
		set cmdSource to searchAndReplace(NudgerSource, templateInsertMarker, additionalCommandSource)
		
		-- Compile
		compileScript(cmdName, cmdSource)
		
		-- Stop further compilation
		if failedCompilationCount > 0 then exit repeat
		
	end repeat
	
	-- Iterate through all built-in commands to create individual scripts
	repeat with cmdName in Nudger's builtinCommands
		
		-- Stop further compilation
		if failedCompilationCount > 0 then exit repeat
		
		log "Compiling command «" & cmdName & "»"
		
		-- Use the template to create the source code for this script file
		set cmdSource to searchAndReplace(NudgerSource, templateInsertMarker, "nudgeWindow(\"" & cmdName & "\")")
		
		-- Compile
		compileScript(cmdName, cmdSource)
		
	end repeat
	
	-- Check to see if all scripts have been compiled
	if failedCompilationCount = 0 then
		
		set outputFolderPath to hfsPath(outputFolderName)
		
		if installLocationPath is not "" then
			
			-- Check installation location again to make sure it hasn’t been removed while the scripts were being built
			checkInstallLocation()
			
			-- Delete existing scripts at installation location; we use the common script name prefix to mass delete the scripts and need to make sure that the prefix is not an empty string, otherwise we’ll end up deleting more than intended. To be extra cautious we also introduced to separate prefixes that need to match for the deletion to be allowed.
			if scriptNamePrefixUsedForDeletion is not "" and scriptNamePrefix is scriptNamePrefixUsedForDeletion then
				do shell script "find " & qpp(installLocationPath) & " -name " & quoted form of (scriptNamePrefixUsedForDeletion & "*.scpt") & " -maxdepth 1 -delete"
			end if
			
			do shell script "mv " & qpp(tempOutputFolderPath) & "* " & qpp(installLocationPath)
			do shell script "rm -rf " & qpp(tempOutputFolderPath)
			do shell script "rm -rf " & qpp(outputFolderPath)
			
			log "Scripts installed"
			
		else
			
			-- Move output folder into place
			do shell script "rm -rf " & qpp(outputFolderPath)
			do shell script "mv " & qpp(tempOutputFolderPath) & " " & qpp(outputFolderPath)
			
			log "Scripts built"
			
		end if
		
		-- Show success dialog
		activate
		set buttonPressed to button returned of (display alert "Nudge My Window" message "All commands have been compiled." buttons {"Show Commands", "OK"} default button "OK")
		
		-- Open directory if user choses to do so
		if buttonPressed is "Show Commands" then
			if installLocationPath is not "" then
				do shell script "open " & qpp(installLocationPath)
			else
				do shell script "open " & qpp(outputFolderPath)
			end if
		end if
		
	else
		
		-- Show error dialog
		activate
		display alert "Compilation Error" message compilationErrorMessage
		
		
	end if
	
end run

on readScriptFile(filePath, defaultEncoding, markers)
	
	if defaultEncoding is not false then
		set scriptSource to readScriptFileUsingEncoding(filePath, defaultEncoding, markers)
		if scriptSource is not false then return scriptSource
	end if
	
	set allEncodings to {"UTF-16", "MACROMAN", "UTF-8"}
	
	repeat with i from 1 to count of allEncodings
		
		if defaultEncoding is false or defaultEncoding is not item i of allEncodings then
			
			set scriptSource to readScriptFileUsingEncoding(filePath, item i of allEncodings, markers)
			if scriptSource is not false then return scriptSource
			
		end if
		
	end repeat
	
	return false
	
end readScriptFile

on readScriptFileUsingEncoding(filePath, anEncoding, markers)
	
	try
		set scriptSource to do shell script "iconv -f " & anEncoding & " -t UTF-8 " & qpp(filePath)
	on error
		set scriptSource to ""
	end try
	
	repeat with i from 1 to count of markers
		if item i of markers is not in scriptSource then return false
	end repeat
	
	return scriptSource
	
end readScriptFileUsingEncoding

on checkInstallLocation()
	
	set installLocationPath to ""
	
	if installLocation is "" then
		
		-- Try to get user preference from installation location
		try
			set installLocationPref to first paragraph of (do shell script "defaults read de.adriannier.NudgeMyWindow installLocation")
		on error
			set installLocationPref to ""
		end try
		
		if installLocationPref is not "" then
			set installLocationPath to hfsPath(installLocationPref)
		end if
	else
		set installLocationPath to hfsPath(installLocation)
	end if
	
	if installLocationPath is "" then return
	
	if installLocationPath does not end with ":" then
		set installLocationPath to installLocationPath & ":"
	end if
	
	tell application "System Events" to set installLocationExist to (exists folder installLocationPath)
	if installLocationExist is false then error "Install location not found at \"" & installLocationPath & "\""
	
	log "Installation location set to \"" & installLocationPath & "\""
	
end checkInstallLocation

on compileScript(cmdName, cmdSource)
	
	-- Generate a temporary path to store the source code for this scripts
	set tempFilePath to temporaryPath() & ".applescript"
	
	-- Generate a path for the compiled script file
	set outputFilePath to tempOutputFolderPath & scriptNamePrefix & cmdName & ".scpt"
	
	try
		
		try
			simpleWriteFile(cmdSource, tempFilePath, «class utf8»)
			do shell script "osacompile -o " & qpp(outputFilePath) & " " & qpp(tempFilePath)
		on error
			simpleWriteFile(cmdSource, tempFilePath, Unicode text)
			do shell script "osacompile -o " & qpp(outputFilePath) & " " & qpp(tempFilePath)
		end try
		
		-- Write the source code to the temporary file and compile the script
		-- do shell script "echo " & quoted form of cmdSource & " > " & qpp(tempFilePath) & " && " & "osacompile -o " & qpp(outputFilePath) & " " & qpp(tempFilePath)
		
		log "Compiled \"" & cmdName & "\""
		
	on error eMsg number eNum
		
		set compilationErrorMessage to "Error while compiling \"" & cmdName & "\": " & eMsg
		
		log compilationErrorMessage
		
		-- Raise the count of failed compilations
		set failedCompilationCount to failedCompilationCount + 1
		
	end try
	
	-- Remove the temporary file
	do shell script "rm -f " & qpp(tempFilePath)
	
end compileScript

on searchAndReplace(aText, aPattern, aReplacement)
	
	(*	Search for a pattern and replace it in a string. Pattern and replacement can be a list of multiple values. *)
	
	if (class of aPattern) is list and (class of aReplacement) is list then
		
		-- Replace multiple patterns with a corresponding replacement
		
		-- Check patterns and replacements count
		if (count of aPattern) is not (count of aReplacement) then
			error "The count of patterns and replacements needs to match."
		end if
		
		-- Process matching list of patterns and replacements
		repeat with i from 1 to count of aPattern
			set aText to searchAndReplace(aText, item i of aPattern, item i of aReplacement)
		end repeat
		
		return aText
		
	else if class of aPattern is list then
		
		-- Replace multiple patterns with the same text
		
		repeat with i from 1 to count of aPattern
			set aText to searchAndReplace(aText, item i of aPattern, aReplacement)
		end repeat
		
		return aText
		
	else
		
		
		if aText does not contain aPattern then
			
			return aText
			
		else
			
			set prvDlmt to text item delimiters
			
			-- considering case
			
			try
				set text item delimiters to aPattern
				set tempList to text items of aText
				set text item delimiters to aReplacement
				set aText to tempList as text
			end try
			
			--	end considering
			
			set text item delimiters to prvDlmt
			
			return aText
			
		end if
		
	end if
	
end searchAndReplace

on textBetween(str, a, b)
	
	(* Returns a substring between a start string and an end string *)
	
	try
		
		-- Start string
		if class of a is integer then
			
			if a is 0 or a > (length of str) then
				error "Invalid start offset specified"
			end if
			
			set aOffset to a
			
		else if class of a is boolean then
			
			if a is false then
				set a to ""
				set aOffset to 1
			else
				error "Invalid start offset"
			end if
			
			
		else if a is "" then
			error "Empty start string specified"
			
		else
			set aOffset to offset of a in str
			
		end if
		
		-- End string
		if class of b is integer then
			
			if b < 0 then
				set b to (length of str) + b + 1
			end if
			
			if class of a is integer and b ≤ a then
				error "Invalid end offset specified. Needs to be higher than start offset."
			end if
			
			if b > (length of str) then
				error "Invalid end offset specified. Out of bounds."
			end if
			
		else if class of b is boolean and b is not false then
			error "Invalid end position"
			
		else if b is "" then
			error "Empty end string specified"
			
		end if
		
		if aOffset is 0 then
			
			error "Start string not found"
			
		else
			
			if class of a is integer then
				set newStartOffset to a + 1
			else
				set newStartOffset to aOffset + (length of a)
			end if
			
			if newStartOffset > (length of str) then
				error "Input string too short"
			end if
			
			set subStr to text newStartOffset thru -1 of str
			
			if class of b is integer then
				set bOffset to b - newStartOffset
				
			else if class of b is boolean then
				set bOffset to length of subStr
				
			else
				set bOffset to (offset of b in subStr) - 1
				
			end if
			
			if bOffset ≤ 0 then
				error "End string not found"
				
			else
				
				set subStr to text 1 thru bOffset of subStr
				
				return subStr
				
			end if
			
		end if
		
	on error eMsg number eNum
		
		error "textBetween: " & eMsg number eNum
		
	end try
	
end textBetween

on trim(aText)
	
	(* Removes surrounding white space from a text. *)
	
	try
		
		if class of aText is not text then error "Wrong type."
		
		if length of aText is 0 then return ""
		
		----------------------------------------------------
		
		set start_WhiteSpaceEnd to false
		
		repeat with i from 1 to count of characters in aText
			
			set asc to ASCII number character i of aText
			if asc > 32 and asc is not 202 then
				exit repeat
			else
				set start_WhiteSpaceEnd to i
			end if
			
		end repeat
		
		----------------------------------------------------
		
		set end_WhiteSpaceStart to false
		
		set i to count of characters in aText
		
		repeat
			
			if start_WhiteSpaceEnd is not false and i ≤ (start_WhiteSpaceEnd + 1) then exit repeat
			
			set asc to ASCII number character i of aText
			
			if asc > 32 and asc is not 202 then
				exit repeat
			else
				set end_WhiteSpaceStart to i
			end if
			
			set i to i - 1
			
		end repeat
		
		----------------------------------------------------
		
		if start_WhiteSpaceEnd is false and end_WhiteSpaceStart is false then
			return aText
			
		else if start_WhiteSpaceEnd is not false and end_WhiteSpaceStart is false then
			try
				return text (start_WhiteSpaceEnd + 1) thru -1 of aText
			on error
				return ""
			end try
			
		else if start_WhiteSpaceEnd is false and end_WhiteSpaceStart is not false then
			return text 1 thru (end_WhiteSpaceStart - 1) of aText
			
		else if start_WhiteSpaceEnd is not false and end_WhiteSpaceStart is not false then
			return text (start_WhiteSpaceEnd + 1) thru (end_WhiteSpaceStart - 1) of aText
			
		end if
		
	on error eMsg number eNum
		
		log "trim: " & eMsg & " (" & (eNum as text) & ")"
		error "trim: " & eMsg number eNum
		
	end try
	
end trim

on temporaryPath()
	
	(* Generates a unique path for a file in the current user's temporary items folder. *)
	
	-- Generate pseudorandom numbers
	set rand1 to (round (random number from 100 to 999)) as text
	set rand2 to (round (random number from 100 to 999)) as text
	set randomText to rand1 & "-" & rand2
	
	-- Create file name
	set fileName to (("AppleScriptTempFile_" & randomText) as text)
	
	-- Get the path to the parent folder
	set parentFolderPath to (path to temporary items folder from user domain) as text
	
	-- Make sure the file does not exist
	set rNumber to 1
	
	repeat
		if rNumber is 1 then
			set tempFilePath to parentFolderPath & fileName
		else
			set tempFilePath to parentFolderPath & fileName & "_" & (rNumber as text)
		end if
		
		tell application "System Events" to if (exists file tempFilePath) is false then exit repeat
		set rNumber to rNumber + 1
	end repeat
	
	return tempFilePath
	
end temporaryPath

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
		
		-- Get the path to the user’s home folder
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

on simpleWriteFile(content, filePath, contentType)
	
	try
		
		-- Convert path to text
		set filePath to filePath as text
		
		-- Remove quotes
		if filePath starts with "'" and filePath ends with "'" then
			set filePath to text 2 thru -2 of filePath
		end if
		
		-- Expand tilde
		if filePath starts with "~" then
			
			-- Get the path to the user’s home folder
			set userPath to POSIX path of (path to home folder)
			
			-- Remove trailing slash
			if userPath ends with "/" then set userPath to text 1 thru -2 of userPath as text
			if filePath is "~" then
				set filePath to userPath
			else
				set filePath to userPath & text 2 thru -1 of filePath
			end if
			
		end if
		
		-- Convert to HFS style path if necessary
		if filePath does not contain ":" then set filePath to (POSIX file filePath) as text
		
		-- Set content type if not already set
		if contentType is false then
			set contentType to class of content
		end if
		
		-- Open file
		try
			open for access file filePath with write permission
		on error errorMessage number errorNumber
			error "Could not open file with write permission: " & errorMessage number errorNumber
		end try
		
		-- Write to file
		try
			
			set eof of file filePath to 0
			write content to file filePath starting at 0 as contentType
			
		on error errorMessage number errorNumber
			
			try
				close access file filePath
			end try
			
			error "Error while writing to file: " & errorMessage number errorNumber
			
		end try
		
		
		-- Close file
		try
			close access file filePath
		end try
		
		
		return true
		
	on error errorMessage number errorNumber
		
		set errorMessage to "simpleWriteFile(): " & errorMessage
		error errorMessage number errorNumber
		
		return false
		
	end try
	
	
end simpleWriteFile

on loadScript(specifiedPath)
	
	(* 
	
	loadScript("/path/to/script.applescript")
	Version 4
	
	Loads an AppleScript file compiling it first if necessary.
	
	Specified path can be:
	
	- single file name 
	  --> file assumed in same directory as current script
	  
	- single file name prefixed with ./ 
	  --> file assumed in same directory as current script
	  
	- relative POSIX path prefixed with one or more ../ 
	  --> file assumed at relative path
	  
	- relative POSIX path starting with ~/ 
	  --> file assumed relative to home directory
	  
	- full HFS-style path
	
	- full POSIX path
	
	Version history
	===============

	Version 4 - 2021-12-15
	
	- Improved logging
	
	Version 3 - 2021-02-09
	
	- Fixed bug in handling paths that start with "../"
		
	Version 2 - 2020-09-23
	
	- Handled error where sometimes the path to the temporary 
	  items folder could not be gathered
	  
	- Packed uses of the text class inside System Events tell 
	  blocks to avoid certain applications causing the class 
	  to change during compile time

	Version 1 - Initial release
	
*)
	
	try
		
		script Util
			
			on hfsPath(aPath)
				
				logMessage("Converting path \"" & aPath & "\" to HFS")
				
				set aPath to pathToString(aPath)
				set aPath to unwrap(aPath, "'")
				
				if aPath does not contain "/" and aPath does not contain ":" then
					-- Only filename specified; treat as path relative to current directory
					set aPath to "./" & aPath
					logMessage("Converted file name specification to " & aPath)
				end if
				
				-- Get the path to this script
				try
					set myPath to pp(kScriptPath)
				on error
					set myPath to pp(path to me)
				end try
				
				logMessage("Own path is " & myPath)
				
				-- Get path to parent directory
				set myPathComponents to explode(myPath, "/")
				set myParentDirectoryPath to implode(items 1 thru -2 of myPathComponents & "", "/")
				
				logMessage("Parent path is " & myParentDirectoryPath)
				
				if aPath does not contain ":" then
					
					if aPath starts with "~" then
						
						(* Expand tilde *)
						
						-- Get the path to the userŐs home folder
						tell application "System Events" to set userPath to Util's pp(path to home folder as text)
						
						-- Remove trailing slash
						if userPath ends with "/" then
							tell application "System Events"
								set userPath to text 1 thru -2 of userPath
							end tell
						end if
						
						logMessage("Found userŐs home folder at " & userPath)
						
						if aPath is "~" then
							-- Simply use home folder path
							set aPath to userPath
						else
							-- Concatenate paths
							tell application "System Events"
								set aPath to userPath & (text 2 thru -1 of aPath)
							end tell
						end if
						
						logMessage("Expanded tilde to " & aPath)
						
					else if aPath starts with "./" then
						
						(* Convert current directory reference *)
						
						tell application "System Events"
							set aPath to myParentDirectoryPath & text 3 thru -1 of aPath
						end tell
						
						logMessage("Converted reference to current directory to " & aPath)
						
					else if aPath starts with "../" then
						
						-- Convert reference to parent directories to absolute path
						
						tell Util
							set pathComponents to explode(aPath, "../")
							set parentDirectoryCount to (count of pathComponents)
							set parentDirectoryPath to implode((items 1 thru ((count of items of myPathComponents) - parentDirectoryCount) of myPathComponents) & "", "/")
						end tell
						
						set aPath to parentDirectoryPath & item -1 of pathComponents
						
						logMessage("Converted relative path to " & aPath)
						
					else
						
						logMessage("Normalized path to " & aPath)
						
					end if
					
					-- Turn POSIX path to HFS path
					tell application "System Events"
						set aPath to POSIX file aPath as text
					end tell
					
				end if
				
				logMessage("Converted path to " & aPath)
				
				return aPath
				
			end hfsPath
			
			on q(str)
				
				(* Return quoted string *)
				
				return quoted form of str
				
			end q
			
			on pp(aPath)
				
				(* Return posix path for path *)
				
				try
					tell application "System Events" to return POSIX path of file (aPath as text)
				on error eMsg number eNum
					-- logMessage("Warning! System Events could not get posix path of " & aPath)
					try
						tell application "System Events" to return POSIX path of folder (aPath as text) & "/"
					on error eMsg number eNum
						error "Util/pp(): " & eMsg number eNum
					end try
				end try
				
			end pp
			
			on qpp(aPath)
				
				(* Return quoted posix path for path *)
				
				return q(pp(aPath))
				
			end qpp
			
			on snr(str, search, replace)
				
				(* Search and replace *)
				
				return implode(explode(str, search), replace)
				
			end snr
			
			on explode(str, dlmt)
				
				(* Convert string to list *)
				
				set prvDlmt to AppleScript's text item delimiters
				set AppleScript's text item delimiters to dlmt
				set strComponents to text items of str
				set AppleScript's text item delimiters to prvDlmt
				
				return strComponents
				
			end explode
			
			on implode(strComponents, dlmt)
				
				(* Convert list to string *)
				
				tell application "System Events"
					set prvDlmt to AppleScript's text item delimiters
					set AppleScript's text item delimiters to dlmt
					set str to strComponents as text
					set AppleScript's text item delimiters to prvDlmt
				end tell
				
				return str
				
			end implode
			
			on unwrap(str, char)
				
				(* Remove first and last character of `str` if both characters are `char` *)
				
				if str starts with char and str ends with char and str is not (char & char) then
					tell application "System Events" to return text 2 thru -2 of str
				end if
				
				return str
				
			end unwrap
			
			on pathToString(aPath)
				
				(* Convert any path to a string *)
				
				try
					tell application "System Events" to return aPath as text
				on error
					tell application "System Events" to return path of aPath
				end try
				
			end pathToString
			
			on logMessage(val)
				
				try
					set val to val as text
					
					tell (current date) as «class isot» as string
						tell contents to set ts to text 1 thru 10 & " " & text 12 thru -1
					end tell
					
					log " " & ts & " " & val & " "
				on error
					log val
				end try
				
			end logMessage
			
		end script -- Util
		
		-- Convert path to text
		tell Util to set scriptPath to hfsPath(specifiedPath)
		
		-- Get information on existing script file
		try
			tell application "System Events"
				set scriptModDate to modification date of file scriptPath
				set scriptName to name of file scriptPath
			end tell
		on error
			error "Could not find script file at \"" & scriptPath & "\""
		end try
		
		if scriptPath ends with ".applescript" then
			
			Util's logMessage("Plain-text AppleScript specified")
			
			-- Plain text version of script; look for compiled version
			
			-- Turn script path into a string we can use for identification
			tell Util to set scriptId to implode(explode(scriptPath, {":", " ", "/"}), "_")
			-- Remove the .applescript suffix from the id
			tell application "System Events" to set scriptId to text 1 thru -13 of scriptId
			
			Util's logMessage("Script id is " & scriptId)
			
			-- Generate temporary path
			try
				set compiledScriptParent to (path to temporary items folder from user domain)
			on error eMsg number eNum
				try
					set compiledScriptParent to (path to temporary items folder)
				on error eMsg number eNum
					try
						tell application "System Events" to set compiledScriptParent to (path to temporary items folder)
					on error eMsg number eNum
						try
							set compiledScriptParent to do shell script "echo $TMPDIR"
							set compiledScriptParent to POSIX file compiledScriptParent
						on error eMsg number eNum
							error "Could not get path to temporary items folder. " & eMsg number eNum
						end try
					end try
				end try
			end try
			
			tell application "System Events"
				set compiledScriptParent to compiledScriptParent as text
			end tell
			
			set compiledScriptPath to compiledScriptParent & scriptId & ".scpt"
			
			Util's logMessage("Compiled script path is " & compiledScriptPath)
			
			-- Get information on possibly existing compiled script		
			try
				tell application "System Events"
					set compiledModDate to modification date of file compiledScriptPath
				end tell
				Util's logMessage("Modification date of compiled script is " & compiledModDate)
			on error eMsg number eNum
				Util's logMessage("Could not get modification date of compiled script. " & eMsg & " (" & (eNum as string) & ")")
				set compiledModDate to false
			end try
			
			if compiledModDate is false or scriptModDate > compiledModDate then
				
				Util's logMessage("Script changed or was never compiled")
				
				set compileCommand to "/usr/bin/osacompile -o " & Util's q(Util's pp(compiledScriptParent) & scriptId & ".scpt") & " " & Util's qpp(scriptPath)
				
				try
					do shell script compileCommand
				on error eMsg number eNum
					error "Failed to compile script file at \"" & scriptPath & "\". " & eMsg number eNum
				end try
				
			end if
			
		else
			
			Util's logMessage("Compiled AppleScript specified")
			
			set compiledScriptPath to scriptPath
			
		end if
		
		-- Load the script			
		try
			Util's logMessage("Loading script from \"" & compiledScriptPath & "\"")
			set loadedScript to load script file compiledScriptPath
		on error eMsg number eNum
			error "Could not load script file at \"" & compiledScriptPath & "\". " & eMsg number eNum
		end try
		
		-- Try to set script's own path property
		try
			set loadedScript's kScriptPath to scriptPath
			Util's logMessage("Property kScriptPath set \"" & scriptPath & "\" in loaded script")
		on error eMsg number eNum
			Util's logMessage("Script has no kScriptPath property")
		end try
		
		-- Try to initialize script
		try
			set initFunctionClass to class of loadedScript's initScript
		on error eMsg number eNum
			set initFunctionClass to missing value
			Util's logMessage("Script has no initScript() function")
		end try
		
		if initFunctionClass is handler then
			try
				set initResult to loadedScript's initScript()
				try
					get initResult
					set loadedScript to initResult
				end try
				
			on error eMsg number eNum
				error " Error while initializing script " & scriptName & ": " & eMsg number eNum
			end try
		end if
		
		return loadedScript
		
	on error eMsg number eNum
		
		log " " & eMsg & " (" & (eNum as string) & ")"
		
		error "loadScript(" & specifiedPath & "): " & eMsg number eNum
		
	end try
	
end loadScript