LogFile("")
formattime,timeNow,A_now,dd.MM.yy_HH-mm-ss
logText := % "" . timeNow . ""
LogFile(logText)
LogFile("Starting Extraction Macro")

sleep 5000
SetCoordModes()

// 2 minutes, 40 seconds for a stack
// roughly 2.7
extractTime := 2.7

// Main loop
LoopBool := true
while LoopBool 
{
	Inv_Open()
	sleep 3000
	
	selectExtractSkill()
	dragRock()
	extractPress()
	
	sleep (2.7 * 60 * 1000)
}

dragRock()
{
	rockType := findRocks()
	if (rockType == "")
	{
		LogFile("StartMining: no rock types found")
		EndScript()
	}
	
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *100 %A_ScriptDir%\Pictures\UI_%rockType%.bmp
	foundRocks := (Errorlevel = 0)
	
	dragLocation := getResourceSlot()
	startLocation := [FoundX + 3, FoundY + 3]
	
	MouseMove, startLocation[1], startLocation[2]
	sleep, 500
	Click down
	sleep, 500
	MouseMove, dragLocation[1], dragLocation[2]
	sleep, 500
	Click up
	sleep, 500
}

getResourceSlot()
{
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *100 %A_ScriptDir%\Pictures\UI_crusherTitle.bmp
	foundTitle := (Errorlevel = 0)
	
	slotLocation := []
	
	if foundTitle
	{
		slotLocation := [FoundX, FoundY + 80]
		LogFile("StartMining: extract title found")
	}
	else
	{
		LogFile("StartMining: Error, extract title not found")
		EndScript()
	}
	
	return slotLocation
}

findRocks()
{
	returnRock := ""
	
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *100 %A_ScriptDir%\Pictures\UI_granum.bmp
	foundRocks := (Errorlevel = 0)
	
	if foundRocks
	{
		returnRock := "granum"
	}
	else
	{
		ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *100 %A_ScriptDir%\Pictures\UI_saburra.bmp
		foundRocks := (Errorlevel = 0)
		
		if foundRocks
		{
			returnRock := "saburra"
		}
		else
		{
			ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *100 %A_ScriptDir%\Pictures\UI_calx.bmp
			foundRocks := (Errorlevel = 0)
			
			if foundRocks
			{
				returnRock := "calx"
			}
		}
	}
	
	return returnRock
}


selectExtractSkill()
{
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *100 %A_ScriptDir%\Pictures\UI_extractSkill.bmp
	foundSkill := (Errorlevel = 0)
	
	if foundSkill
	{
		MouseClick, left, (FoundX + 5), (FoundY + 5)
		LogFile("StartMining: skill button found")
	}
	else
	{
		LogFile("StartMining: Error, skill button not found")
		EndScript()
	}
	
	
}

extractPress()
{
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *100 %A_ScriptDir%\Pictures\UI_extractButton.bmp
	foundButton := (Errorlevel = 0)
	
	if foundButton
	{
		MouseClick, left, (FoundX + 5), (FoundY + 5)
		LogFile("StartMining: extract Button found")
	}
	else
	{
		LogFile("StartMining: Error, extract Button not found")
		EndScript()
	}
}

Inv_isOpen()
{
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_invTitle.bmp
	return (ErrorLevel = 0)
}

Inv_Open()
{
	if !Inv_isOpen()
	{
		send, i
	}
}

Inv_Close()
{
	if Inv_isOpen()
	{
		send, i
	}
}

EndScript()
{
	ExitApp
}

SetCoordModes()
{
	; Pixel, Mouse
	; Relative, Screen
	CoordMode, Pixel, Screen
	CoordMode, Mouse, Screen
}

LogFile(TEXT)
{
	FileAppend %TEXT%`n, %A_ScriptDir%\Logfile.txt
}

LogREPORT(TEXT)
{
	FileAppend %TEXT%`n, %A_ScriptDir%\ATTENTION.txt
}
