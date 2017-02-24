Sleep 5000

LogFile("Start")

SetCoordModes()

loop
{
	available := weaponsAvailable()
	equiped := weaponEquiped()
	if available
	{
		if !equiped
		{
			weaponEquip()
			sleep, 2000
			Sheath()
		}
	}
	else
	{
		if !equiped
		{
			EndScript()
		}
	}
	
	HitLoop()
}

HitLoop()
{
	Loop 10 {
		send, {Lalt DOWN}
		send, {LButton DOWN}
		Sleep, 800
		send, {LButton UP}
		sleep, 100
	}
	
	brokeFound := false
	while !brokeFound
	{
		loop 10 {
			send, {Lalt DOWN}
			send, {LButton DOWN}
			Sleep, 800
			send, {LButton UP}
			sleep, 100
		}
		ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_broke.bmp
		brokeFound := (ErrorLevel == 0)
	}
}

weaponEquiped()
{
	Inv_Close()
	Pap_Open()
	sleep, 5000
	
	Equiped := false
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\weapon_P.bmp
	Equiped := (ErrorLevel == 0)
	
	LogText := % "Equiped: " . Equiped . ""
	LogFile(LogText)
	
	sleep, 5000
	Pap_Close()
	sleep, 5000
	return Equiped
}

weaponsAvailable()
{
	Pap_Close()
	Inv_Open()
	sleep, 5000
	
	available := false
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\weapon_I.bmp
	available := (ErrorLevel == 0)
	
	LogText := % "Available: " . available . ""
	LogFile(LogText)
	
	Inv_Close()
	sleep, 5000
	return available
}

weaponEquip()
{
	Inv_Open()
	sleep, 5000
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\weapon_I.bmp
	if (ErrorLevel == 0)
	{
		MouseClick, right, (FoundX + 5), (FoundY + 5)
	}
	sleep, 5000
	Inv_Close()
	sleep, 5000
}

Sheath()
{
	send, x
	sleep, 1000
}

Pap_isOpen()
{
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_Pap.bmp
	return (ErrorLevel = 0)
}

Pap_Open()
{
	if !Pap_isOpen()
	{
		send, P
	}
}

Pap_Close()
{
	if Pap_isOpen()
	{
		send, P
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