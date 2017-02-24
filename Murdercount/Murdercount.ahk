LogFile("")
logText := % "" . A_Hour . ":" . A_Min . ":" . A_sec . ""
LogFile(logText)
LogFile("Starting Macro")

SetCoordModes()

LogFile("Starting Loop")

Bool_dead := false
LoopBool := true

while LoopBool
{
	Bool_dead := false
	
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_MR_title.bmp
	Bool_dead := (ErrorLevel = 0)
	
	if Bool_dead
	{
		logText := % "" . A_Hour . ":" . A_Min . ":" . A_sec . "	Murder detected, reporting"
		LogFile(logText)
		
		reportDead()
	}
	
	sleep, 2000
}

LogFile("Ending Loop")
logText := % "" . A_Hour . ":" . A_Min . ":" . A_sec . ""
LogFile(logText)
LogFile("Ending Macro")
LogFile("")

reportDead()
{
	LoopBool := true
	while LoopBool
	{
		ImageSearch, FoundX_BOX, FoundY_BOX, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_MR_box.bmp
		if (ErrorLevel = 0)
		{
			MouseClick,left,(FoundX_BOX + 3),(FoundY_BOX + 3)
			sleep, 200
		}
		else
		{
			ImageSearch, FoundX_BUT, FoundY_BUT, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_MR_report.bmp
			MouseClick,left,(FoundX_BUT + 5),(FoundY_BUT + 5)
			sleep, 2000
			LoopBool := false
		}	
	}
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
	FileAppend %TEXT%`n, %A_ScriptDir%\Log.txt
}