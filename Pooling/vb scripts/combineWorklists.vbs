
'THESE FILE PATHS ARE FOR TESTING PURPOSES ONLY-----------------------------------------------------
'inputFilePath1 = "Z:\Tecan\Pooling Tests\test files\QA17154 Robot Pooling File.csv"
'inputFilePath2 = "Z:\Tecan\Pooling Tests\test files\QA17130 Metagenomics Robot Pooling File.csv"

'SET THE OUTPUT AND THE 2 INPUT FILE PATHS.  INPUT FILE PATHS ARE PASSED FROM EVOWARE
outputFilePath = "C:\Tecan scripts\GSAF_Pooling\csv files\combinedPoolingWorklist.csv"

inputFilePath1 = Evoware.GetStringVariable("poolingFilePath1")
inputFilePath2 = Evoware.GetStringVariable("poolingFilePath2")

'OPEN THE INPUT FILES AND CREATE THE OUTPUT FILE
Set fso = CreateObject("Scripting.FileSystemObject")
set inputFile1 = fso.OpenTextFile(inputFilePath1)
Set inputFile2 = fso.OpenTextFile(inputFilePath2)
Set outPutFile = fso.CreateTextFile(outputFilePath)

'LOOP THROUGH THE 1ST INPUT FILE AND ADD IT TO THE OUTPUTFILE

Do Until inputFile1.AtEndOfStream

	inputLine = inputFile1.readLine
	outputFile.Write(inputLine + chr(13) + chr(10))

Loop

'SKIP THE HEADER LINE OF THE 2ND INPUT FILE
inputFile2.SkipLine

'LOOP THROUGH THE 2ND INPUT FILE AND ADD IT TO THE OUTPUT FILE
Do Until inputFile2.AtEndOfStream

	inputLine = inputFile2.readLine
	outputFile.Write(inputLine + chr(13) + chr(10))
Loop

'CLOSE THE FILES
inputFile1.Close
inputFile2.Close
outputFile.Close