Function checkWorklist()

'FILEPATHS FOR TESTING-------------------------------------------------------------------------
'MsgBox("Method Start")
'numWorklists = 2
'inputFilePath1 = "Z:\Tecan\Pooling Tests\test files\QA17154 Robot Pooling File 2.csv"
'inputFilePath2 = "Z:\Tecan\Pooling Tests\test files\QA17130 Metagenomics Robot Pooling File.csv"
'-------------------------------------------------------------------------------------------------

inputFilePath1 = Evoware.GetStringVariable("poolingFilePath1")
inputFilePath2 = Evoware.GetStringVariable("poolingFilePath2")

Set fso = CreateObject("Scripting.FileSystemObject")
Set inputFile1 = fso.OpenTextFile(inputFilePath1)

numWorklists = Evoware.GetDoubleVariable("numOfWorklists")
arrayCounter = 0
arrayLocation = 0
arrayBoolean = 0
poolArrayLocation = 0
dim plateArray(6)
dim poolArray(95)

'#################################################################################################################
'Check the formatting of first worklist and build arrays of Plates and Pools to compare 2nd Worklist to          #
'#################################################################################################################
If numWorklists = 1 Then
	inputLine = inputFile1.readLine 'reads the first line of header rows before beginning the loop
	lineCounter = 2
	Do Until inputFile1.AtEndOfStream
		inputLine = inputFile1.readLine 
		strArray = split(inputLine, ",")
	
		formatResult = checkWorklistFormat(strArray,1)
		If formatResult = 1 Then 
			Evoware.SetDoubleVariable "errorLine", lineCounter
			'msgbox("Error on Line: " & lineCounter)
			Exit Function
		End If
		
		lineCounter = lineCounter + 1
	Loop
	
Else
	Set inputFile2 = fso.OpenTextFile(inputFilePath2)
	inputLine = inputFile1.readLine 'reads the first line of header rows before beginning the loop
	lineCounter = 2
	Do Until inputFile1.AtEndOfStream
		inputLine = inputFile1.readLine 
		strArray = split(inputLine, ",")
	
		formatResult = checkWorklistFormat(strArray,1)
		If formatResult = 1 Then 
			Evoware.SetDoubleVariable "errorLine", lineCounter
			'msgbox("Error on Line: " & lineCounter)
			Exit Function
		End If
	'-------------------------------------------------------------------------------------------
	'build the array of plate namees from the first CSV Worklist File to compare to the 2nd file
	'-------------------------------------------------------------------------------------------
		Do Until arrayCounter > arrayLocation
		
			If plateArray(arrayCounter) = strArray(0) AND plateArray(arrayCounter) <> "null" Then
				arrayBoolean = 1
			End If
		
			arrayCounter = arrayCounter + 1	
		Loop
	
		If arrayBoolean = 0 Then
			plateArray(arrayLocation) = strArray(0)
			arrayLocation = arrayLocation + 1
		End If
	
	'----------------------------------------------------------------------------------------
    'WHILE GOING THROUGH THE LIST ALSO PUT EVERY UNIQUE INSTANCE OF A POOL NUMBER IN AN ARRAY
	'----------------------------------------------------------------------------------------
		arrayCounter = 0
		arrayBoolean = 0
	
		Do Until arrayCounter > poolArrayLocation
		
			If poolArray(arrayCounter) = strArray(3) AND poolArray(arrayCounter) <> "null" Then
				arrayBoolean = arrayBoolean + 1
			End If
			
			arrayCounter = arrayCounter + 1
			
		Loop
	
		If arrayBoolean = 0 Then	
			poolArray(poolArrayLocation) = strArray(3)
			poolArrayLocation = poolArrayLocation + 1
		End If
	
		arrayCounter = 0
		arrayBoolean = 0
		lineCounter = lineCounter + 1
	Loop


'#############################################################################################################################

'##############################################################################################################################
'GO THROUGH THE SECOND LIST AND COMPARE EACH PLATE NAME TO EACH UNIQUE PLATE NAME STORED IN THE PLATE NAME ARRAY			  #	
'IF IT MATCHES SET AN EVOWARE BOOLEAN TO FALSE WHICH WILL TRIGGER AN ERROR MESSAGE IN EVOWARE AND END THE SCRIPT              #
'##############################################################################################################################

	inputLine = inputFile2.readLine  'reads the first line of header rows before beginning the loop
	lineCounter = 2
	Do Until inputFile2.AtEndOfStream
		inputLine = inputFile2.readLine
		strArray = split(inputLine, ",")
	
		formatResult = checkWorklistFormat(strArray,2)
		If formatResult = 1 Then 
			Evoware.SetDoubleVariable "errorLine", lineCounter
			'msgbox("Error on Line: " & lineCounter)
			Exit Function
		End If
	'--------------------------------------------------------------------------------------------
	' Check the Plate name for the current line and make sure it doesn't match any of the plates
	' already stored in the plateArray from the 1st Worklist
	'--------------------------------------------------------------------------------------------
	
		Do Until arrayCounter > 5
			If plateArray(arrayCounter) = strArray(0) Then
				Evoware.SetStringVariable "plateBoolean", "False"
				'msgbox("Plate Already Present")
				Exit Function
	
			End If
		
			arrayCounter = arrayCounter + 1
	
		Loop
	
		arrayCounter = 0

	'-------------------------------------------------------------------------------------------------------------
	'AT THE SAME TIME AS THE ABOVE GO THROUGH THE SECOND CSV FILE AND COMPARE EACH POOL NAME/NUMBER TO EACH UNIQUE
	'POOL NAME STORED IN THE POOL ARRAY CREATED ABOVE.  IF THERE IS A MATCH SET AN EVOWARE VARIABLE TO FALSE WHICH 
	'WILL TRIGGER AN ERROR IN EVOWARE, AND THEN TERMINATE THIS SCRIPT	
	'-------------------------------------------------------------------------------------------------------------
	
		Do until arrayCounter > 95
			If poolArray(arrayCounter) = strArray(3) Then
				Evoware.SetStringVariable "poolBoolean", "False"
				'msgbox(" Pool already exists in worklist")
				Exit Function
		
			End If
			arrayCounter = arrayCOunter + 1
		Loop
	
		arrayCounter = 0
		lineCounter = lineCounter + 1
	Loop
End If
'#####################################################################################################################################

inputFile1.Close
if numWorklists = 2 Then
	inputFile2.Close
End If

'msgbox("Worklists are Good")
checkWorklist = "True"

End Function

'checkWorklist

Evoware.SetStringVariable "worklistBoolean", checkWorklist


function checkWorklistFormat( ByRef formatArray(), ByRef plates)
	'----------------------------------------------------------------------------------------------------------
	'Check Each Line of the CSV to make sure the worklist is written for the Tecan and that all needed elements  
	'are in place                                                                                                
	'----------------------------------------------------------------------------------------------------------
	

	'------------------------------------------------------------------------
	'Use regular expressions to make sure Plate Names are formateed correctly
	'------------------------------------------------------------------------
		Set objRE = New RegExp
		With objRE                                                                                                  
			.Pattern = "\bPlate\s[1-6]\b"                                                                           
			.IgnoreCase = True                                                                                      
			.Global = False                                                                                         
		End With                                                                                                    
	
		If objRE.Test(formatArray(0)) = False Then                                                                     
			If plates = 2 Then
				Evoware.SetStringVariable "plateNameBoolean2", "False"
				'MsgBox("Incorrect Plate Name Plate 2")
			Else
				Evoware.SetStringVariable "plateNameBoolean1", "False"
				'MsgBox("Incorrect Plate Name Plate 1")
			End If
			checkWorklistFormat = 1
			Exit Function                                                                                    
		End If
	
	'--------------------------------------------------------------------------------------------------
	'Use regular expressions to check to make sure Source and Destination wells are Correctly formatted
	'--------------------------------------------------------------------------------------------------
		With objRE
			.Pattern = "\b\d{1,2}\b"
			.IgnoreCase = True
			.Global = False
		End With
	
		If objRE.Test(formatArray(1)) = False Then
			If plates = 2 Then
				Evoware.SetStringVariable "sourceWellBoolean2", "False"
				'MsgBox("Incorrect Source Well Plate 2")
			Else
				Evoware.SetStringVariable "sourceWellBoolean1", "False"
				'MsgBox("Incorrect Source Well Plate 1")
			End If
			checkWorklistFormat = 1
			Exit Function    
		End If
	
		If objRE.Test(formatArray(3)) = False Then
			If plates = 2 Then
				Evoware.SetStringVariable "destWellBoolean2", "False"
				'MsgBox("Incorrect Destination Well Plate 2")
			Else
				Evoware.SetStringVariable "destWellBoolean1", "False"
				'MsgBox("Incorrect Destination Well Plate 1")
			End If
			checkWorklistFormat = 1
			Exit Function    
		End If
		
		checkWorklistFormat = 0

End function