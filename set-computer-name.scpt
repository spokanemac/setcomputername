-- Gets & Sets Computer Name
-- Created 2014.09.25 by Jack-Daniyel Strong.

-- (C)opyright 2008-2014 J-D Strong Consulting, Inc.

-- Variable settings:

property MyTitle : "Set Computer Name"
property defaults : "/usr/bin/defaults"
property launchctl : "/usr/bin/launchctl"
property scutil : "/usr/sbin/scutil"
property systemsetup : "/usr/sbin/systemsetup"
property defaults_write : defaults & " write "
property defaults_read : defaults & " read "
property launchctl_load : launchctl & " load "
property scutil_get : scutil & " --get "
property scutil_set : scutil & " --set "
property ComputerName : ""
property HostName : ""
property LocalHostName : ""
property NewHostName : "Lab_00"



-- Start the script (double click)
on run
	my main()
end run

on main()
	try
		
		set getComputerName to ""
		set promptForName to true
		set getComputerName to (do shell script scutil_get & "ComputerName")
		--		set HostName to (do shell script scutil_get & "HostName")
		--		set LocalHostName to (do shell script scutil_get & "LocalHostName")
		
		
		if ((length of getComputerName) > 0) then -- ComputerName is already set
			
			set Msg to "Looks like the ComputerName is already set to 
			
			" & getComputerName & "
			
Do you want to change this?"
			set Prompt to display dialog Msg buttons {"Change Name", "Leave it alone"} ¬
				default button 2 with icon note
			set Choice to the button returned of Prompt
			if Choice is "Leave it alone" then
				set promptForName to false
			end if
			set ComputerName to getComputerName
		else
			set ComputerName to NewHostName
		end if
		
		if ((promptForName) or (length of ComputerName) ≤ 3) or (ComputerName is equal to NewHostName) then
			repeat
				set tTitle to "Computer Name"
				set tPrompt to "Please enter a valid Computer Name:"
				set tComputerName to text returned of (display dialog tPrompt ¬
					default answer ComputerName buttons {"Cancel", "Continue"} ¬
					default button 2 with title tTitle)
				try
					set ComputerName to (tComputerName as text)
					if ((length of ComputerName) ≥ 6) and ComputerName is not equal to NewHostName then
						exit repeat
					end if
				end try
			end repeat
		end if
		
		-- Set ComputerName to filename-friendly version:
		set ComputerName to str_replace(":", " ", ComputerName)
		set ComputerName to str_replace("/", " ", ComputerName)
		set ComputerName to str_replace(" ", "-", ComputerName)
		
		
		my SetComputerName()
		
		my AlertDone()
		
		-- Catch any unexpected errors:
		
	on error ErrorMsg number ErrorNum
		my DisplayErrorMsg(ErrorMsg, ErrorNum)
	end try
end main


-- Set the ComputerName
on SetComputerName()
	
	--#Set Computer Name to user name
	--scutil --set ComputerName $COMPUTER_NAME
	--scutil --set HostName $COMPUTER_NAME
	--scutil --set LocalHostName $COMPUTER_NAME
	--# $defaults write "${PREFS_DIR}/SystemConfiguration/com.apple.smb.server" NetBIOSName -string "$COMPUTER_NAME"
	--systemsetup -setlocalsubnetname $hostname
	-- systemsetup -setcomputername <computername
	
	set cmd to scutil_set & "ComputerName \"" & ComputerName & "\" && "
	set cmd to cmd & scutil_set & "HostName \"" & ComputerName & "\" && "
	set cmd to cmd & scutil_set & "LocalHostName \"" & ComputerName & "\" && "
	set cmd to cmd & systemsetup & " -setlocalsubnetname \"" & ComputerName & "\" && "
	set cmd to cmd & systemsetup & " -setcomputername \"" & ComputerName & "\" ; "
	
	my DisplayInfoMsg(cmd)
	
	-- do shell script cmd with administrator privileges
	
end SetComputerName


on AlertDone()
	-- get current volume settings
	set curVolume to output volume of (get volume settings)
	set curAlertVolume to alert volume of (get volume settings)
	set isMuted to output muted of (get volume settings)
	-- check for a mute, and unmute
	if isMuted then set volume without output muted
	-- turn it up to 11
	set volume output volume 100
	set volume alert volume 100
	beep 3 -- get attention
	-- CleanUp
	set volume output muted isMuted
	set volume output volume curVolume
	set volume alert volume curAlertVolume
	
	display dialog "Done!" buttons {"OK"} default button 1 with icon note with title MyTitle giving up after 5
end AlertDone

-- Display information to the user:

on DisplayInfoMsg(DisplayInfo)
	tell me
		activate
		display dialog DisplayInfo buttons {"OK"} default button 1 with icon note with title MyTitle
	end tell
end DisplayInfoMsg

-- Display an error message to the user:

on DisplayErrorMsg(ErrorMsg, ErrorNum)
	set Msg to "Sorry, an error occured:" & return & return & ErrorMsg & " (" & ErrorNum & ")"
	tell me
		activate
		display dialog Msg buttons {"OK"} default button 1 with icon stop with title MyTitle
	end tell
end DisplayErrorMsg

-- Replace text function:

on str_replace(find, replace, subject)
	set prevTIDs to text item delimiters of AppleScript
	set returnList to true
	
	if class of find is not list and class of replace is list then error -128
	
	if class of find is not list then set find to {find}
	if class of subject is not list then ¬
		set {subject, returnList} to {{subject}, false}
	
	set findCount to count find
	set usingReplaceList to class of replace is list
	
	try
		repeat with i from 1 to (count subject)
			set thisSubject to item i of subject
			
			repeat with n from 1 to findCount
				set text item delimiters of AppleScript to item n of find
				set thisSubject to text items of thisSubject
				
				if usingReplaceList then
					try
						item n of replace
					on error
						"" -- replace ran out of items.
					end try
				else
					replace
				end if
				
				set text item delimiters of AppleScript to result
				set thisSubject to "" & thisSubject
			end repeat
			
			set item i of subject to thisSubject
		end repeat
	end try
	
	set text item delimiters of AppleScript to prevTIDs
	if not returnList then return beginning of subject
	return subject
end str_replace
