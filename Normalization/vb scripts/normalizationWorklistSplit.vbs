'-------------------------------------------------------------------------------------------------------------------
'  This is a script that takes in a worklist file from the Tecan Evoware software and splits it into multiple       '
'  worklists to ensure that the correct tip size gets used for each volume to be pipetted.  The tecan does not      '
'  automtically adjust tip size depending on the volume to be pipetted so this script takes in the worklist         '
'  that contains the pipetting instruction for the Tecan EVO, then evaluates each line of the worklist and          '
'  puts it into one of four new worklists based on the liquid type and volume being pippetted.  The script then     '
'  feeds the Tecan EVOWARE software a boolean for each worklsit to let it know if there is anything present in the  '
'  worklist so that it will execute any worklist that is not empty. Evwoare is a class known to the Tecan Evwoare   '
'  software.  When this script is run from within the Evoware software it will allow the setting and reading of     '
'  variables within a Tecan Evoware program.                                                                        '
'------------------------------------------------------------------------------------------------------------------ 


'SET FILE PATHS 
inputfilePath = Evoware.GetStringVariable("normalizationFilePath")

'THIS FILE PATH IS FOR TESTING PURPOSES ONLY
'inputfilePath = "Z:\Matt\TECAN\test files\Normalization Test.csv "

outputWater50FilePath = "C:\Tecan scripts\GSAF_Normalization\CSV Files\Water Worklist 50.csv"
outputWater200FilePath = "C:\Tecan scripts\GSAF_Normalization\CSV Files\Water Worklist 200.csv"
outputSample50FilePath = "C:\Tecan scripts\GSAF_Normalization\CSV Files\Sample Worklist 50.csv"
outputSample200FilePath = "C:\Tecan scripts\GSAF_Normalization\CSV Files\Sample Worklist 200.csv"

Set fso = CreateObject("Scripting.FileSystemObject")
Set inputFile = fso.OpenTextFile(inputfilePath)

'SET THE COUNTERS THAT WILL INDICATE IF A LINE AS BEEN ADDED TO A WORKLIST FILE OR NOT
water50Count = 0
water200Count = 0
sample50Count = 0
sample200Count = 0

'SKIP THE HEADER LINE OF THE INPUTFILE
inputFile.SkipLine

'CREATE THE CSV WATER 50 AND 200 uL FILES AND WRITE THE HEADERS FOR THE TWO WATER CSV FILES
set output50File = fso.CreateTextFile(outputWater50FilePath)
set output200File = fso.CreateTextFile(outputWater200FilePath)

output50File.Write("Source labware,Source position,Destination labware,Destination position,Volume" + chr(13) + chr(10))
output200File.Write("Source labware,Source position,Destination labware,Destination position,Volume" + chr(13) + chr(10))

'LOOP THROUGH THE INPUT FILE AND WRITE ALL THE WATER COMMANDS INTO EITHER A 50 OR 200 uL FILE DEPENDING ON WHETHER OR Not
	'ITS VOLUME IS OVER OR UNDER 45 uL
Do Until inputFile.AtEndOfStream
	inputLine = inputFile.readLine
	strArray = split(inputLine, ",")
	if strArray(0) <> "Water" Then exit do
	if strArray(4) <= 45 Then
		output50File.Write(inputLine + chr(13) + chr(10))
		water50Count = water50Count + 1
	else
		output200File.Write(inputLine + chr(13) + chr(10))
		water200Count = water200Count + 1
	End If
Loop
output50File.Close
output200File.Close


'CREATE THE FILES FOR THE SAMPLE CSV FILES AND WRITE THE HEADERS
Set output50File = fso.CreateTextFile(outputSample50FilePath)
Set output200File = fso.CreateTextFile(outputSample200FilePath)

output50File.Write("Source labware,Source position,Destination labware,Destination position,Volume" + chr(13) + chr(10))
output200File.Write("Source labware,Source position,Destination labware,Destination position,Volume" + chr(13) + chr(10))

'CONTINUE LOOPING THROUGH THE ORIGINAL INPUT FILE FOR ALL THE SAMPLE COMMANDS AND WRITE THEM INTO EITHER A 50 uL or 200 uL FILE 
	'DEPENDING ON WHETHER THEY ARE UNDER 45 uL OR OVER 45 uL
If strArray(4) <= 45 Then
	output50File.Write(inputLine + chr(13) + chr(10))
Else
	output200File.Write(inputLine + chr(13) + chr(10))
End If
Do Until inputFile.AtEndOfStream
	inputLine = inputFile.readLine
	strArray = split(inputLine, ",")
	if strArray(4) <= 45 Then
		output50File.Write(inputLine + chr(13) + chr(10))
		sample50Count = sample50Count + 1
	else	
		output200File.Write(inputLine + chr(13) + chr(10))
		sample200Count = sample200Count + 1
	End If
Loop

output50File.Close
output200File.Close
inputFile.Close

'SET BOOLEANS BASED ON WHETER OR NOT A FILE HAS A LINE OF INSTRUCTIONS IN IT OR NOT SO THAT EVOWARE KNOWS WHETHER OR NOT TO TRY
	'AND EXECUTE THAT WORKLIST
If water50Count > 0 then water50Boolean = "True" else water50Boolean = "False" 
If water200Count > 0 then water200Boolean = "True"  else water200Boolean = "False" 
If sample50Count > 0 then sample50Boolean = "True" else sample50Boolean = "False" 
If sample200Count > 0 then sample200Boolean = "True" else sample200Boolean = "False" 


'PASS THE BOOLEAN VARIABLES ALONG TO EVWARE SO IT CAN USE THEM TO DECIDE WHETHER OR NOT A PARTICULAR WORK LIST NEEDS TO BE EXECUTED
Evoware.SetStringVariable "water50Boolean", water50Boolean
Evoware.SetStringVariable "water200Boolean", water200Boolean
Evoware.SetStringVariable "sample50Boolean", sample50Boolean
Evoware.SetStringVariable "sample200Boolean", sample200Boolean










