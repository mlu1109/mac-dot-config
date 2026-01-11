-- Function to escape JSON strings
on escapeJSON(txt)
	set txt to my replaceText(txt, "\\", "\\\\")
	set txt to my replaceText(txt, "\"", "\\\"")
	set txt to my replaceText(txt, return, "\\n")
	set txt to my replaceText(txt, tab, "\\t")
	return txt
end escapeJSON

-- Function to replace text
on replaceText(theText, searchString, replacementString)
	set AppleScript's text item delimiters to searchString
	set theTextItems to every text item of theText
	set AppleScript's text item delimiters to replacementString
	set theText to theTextItems as string
	set AppleScript's text item delimiters to ""
	return theText
end replaceText

set json to "["

tell application "System Events"
	repeat with p in application processes
		try
			if background only of p is false then
				set pid to unix id of p
				repeat with w in windows of p
					try
						set appName to my escapeJSON(name of p as string)
						set winName to my escapeJSON(name of w as string)
						set pos to position of w
						set sz to size of w

						set json to json & ¬
							"{ \"app\": \"" & appName & ¬
							"\", \"pid\": " & pid & ¬
							", \"title\": \"" & winName & ¬
							"\", \"x\": " & item 1 of pos & ¬
							", \"y\": " & item 2 of pos & ¬
							", \"width\": " & item 1 of sz & ¬
							", \"height\": " & item 2 of sz & " },"
					end try
				end repeat
			end if
		end try
	end repeat
end tell

-- Remove trailing comma if it exists
if json ends with "," then
	set json to text 1 thru -2 of json
end if

set json to json & "]"
return json
