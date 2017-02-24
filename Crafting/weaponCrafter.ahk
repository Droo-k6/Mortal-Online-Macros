LogFile("")
formattime,timeNow,A_now,dd.MM.yy_HH-mm-ss
logText := % "" . timeNow . ""
LogFile(logText)
LogFile("Starting Weapon Crafting Macro")

sleep 5000
SetCoordModes()

buildAmount := 30
loopAmount := 20

logText := % "Build Amount- " . buildAmount . ""
LogFile(logText)
logText := % "Loop Amount- " . loopAmount . ""
LogFile(logText)

LoopBool := true
counter := 0

while LoopBool 
{
	Inv_Open()
	sleep 3000
	
	CheckCraftOpen()
	CraftItems(buildAmount)
	DeleteItems()
	
	sleep 2000
	
	counter := counter + 1
	
	if (counter == loopAmount)
	{
		LogFile("Crafter: Loop finished")
		EndScript()
	}
}

CheckCraftOpen()
{
	menuFound := false
	
	ImageSearch, FoundX_title, FoundY_title, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_craftingmenu_title.png
	menuFound := (Errorlevel = 0)
	
	if !(menuFound)
	{
		LogFile("Crafter: Crafting Menu not found")
		EndScript()
	}
}

CraftItems(buildAmount)
{
	LogFile("Crafter: CraftItems - Starting")

	ImageSearch, FoundX_button, FoundY_button, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_craftingmenu_button.png
	buttonFound := (Errorlevel = 0)
	
	if !(buttonFound)
	{
		LogFile("Crafter: Crafting button not found")
		EndScript()
	}
	
	loop %buildAmount%
	{
		MouseClick,left,(FoundX_button + 5),(FoundY_button + 5)
		sleep 2000
	}
	
	LogFile("Crafter: CraftItems - Ending")
}

DeleteItems()
{
	LogFile("Crafter: DeleteItems - Starting")

	center_x := (A_ScreenWidth // 2) - 10
	center_y := (A_ScreenHeight // 2) - 20
	
	itemsFound := true
	while itemsFound
	{
		ImageSearch, FoundX_icon, FoundY_icon, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_item_icon.png
		itemsFound := (Errorlevel = 0)
		
		if itemsFound
		{
			MouseMove, (FoundX_icon + 5), (FoundY_icon + 5)
			sleep, 500
			Click down
			sleep, 500
			MouseMove, center_x, center_y
			sleep, 500
			Click up
			sleep, 500
			
			deleteAccept()
		}
	}
	
	LogFile("Crafter: DeleteItems - Ending")
}

deleteAccept()
{
	sleep, 500
	
	ImageSearch, FoundX_delete, FoundY_delete, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_delete_accept.png
	acceptFound := (Errorlevel = 0)
	
	if acceptFound
	{
		MouseClick,left,(FoundX_delete + 5),(FoundY_delete + 5)
	}
	
	sleep, 2000
}

Inv_isOpen()
{
	ImageSearch, FoundX_inv, FoundY_inv, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_invTitle.png
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
