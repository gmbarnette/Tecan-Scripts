Function checkWorklist()

'FILEPATHS FOR TESTING-------------------------------------------------------------------------

'inputFilePath1 = "Z:\Tecan\Pooling Tests\test files\QA17154 Robot Pooling File.csv"
'inputFilePath2 = "Z:\Tecan\Pooling Tests\test files\QA17130 Metagenomics Robot Pooling File.csv"

inputFilePath1 = Evoware.GetStringVariable("poolingFilePath1")
inputFilePath2 = Evoware.GetStringVariable("poolingFilePath2")

Set fso = CreateObject("Scripting.FileSystemObject")
Set inputFile1 = fso.OpenTextFile(inputFilePath1)
Set inputFile2 = fso.OpenTextFile(inputFilePath2)

arrayCounter = 0
arrayLocation = 0
arrayBoolean = 0
poolArrayLocation = 0
dim plateArray(6)
dim poolArray(95)

'GO THROUGH THE FIRST CSV FILE AND PUT EVERY UNIQUE INSTANCE OF A PLATE IN AN ARRAY----------------

inputLine = inputFile1.readLine
Do Until inputFile1.AtEndOfStream
	inputLine = inputFile1.readLine
	
	strArray = split(inputLine, ",")
	
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
	
'WHILE GOING THROUGH THE LIST ALSO PUT EVERY UNIQUE INSTANCE OF A POOL NUMBER IN AN ARRAY-----------	
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
	
Loop

'GO THROUGH THE SECOND LIST AND COMPARE EACH PLATE NAME TO EACH UNIQUE PLATE NAME STORED IN THE PLATE NAME ARRAY
	'IF IT MATCHES SET AN EVOWARE BOOLEAN TO FALSE WHICH WILL TRIGGER AN ERROR MESSAGE IN EVOWARE AND END THE SCRIPT

inputLine = inputFile2.readLine
Do Until inputFile2.AtEndOfStream
	inputLine = inputFile2.readLine
	strArray = split(inputLine, ",")
	
	Do Until arrayCounter > 5
		If plateArray(arrayCounter) = strArray(0) Then
			Evoware.SetStringVariable "plateBoolean", "False"
			'msgbox("Plate Already Present")
			Exit Function
	
		End If
		
		arrayCounter = arrayCounter + 1
	
	Loop
	
    arrayCounter = 0

'AT THE SAME TIME AS THE ABOVE GO THROUGH THE SECOND CSV FILE AND COMPARE EACH POOL NAME/NUMBER TO EACH UNIQUE
	'POOL NAME STORED IN THE POOL ARRAY CREATED ABOVE.  IF THERE IS A MATCH SET AN EVOWARE VARIABLE TO FALSE WHICH 
	'WILL TRIGGER AN ERROR IN EVOWARE, AND THEN TERMINATE THIS SCRIPT	
	
	Do until arrayCounter > 95
		If poolArray(arrayCounter) = strArray(3) Then
			Evoware.SetStringVariable "poolBoolean", "False"
			'msgbox(" Pool already exists in worklist")
			Exit Function
		
		End If
		arrayCounter = arrayCOunter + 1
	Loop
	
	arrayCounter = 0

Loop
inputFile1.Close
inputFile2.Close
'msgbox("Worklists are Good")
checkWorklist = "True"

End Function

Evoware.SetStringVariable "worklistBoolean", checkWorklist