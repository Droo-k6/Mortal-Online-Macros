LogFile("")
logText := % "" . A_Hour . ":" . A_Min . ":" . A_sec . ""
LogFile(logText)
LogFile("Starting Macro")


SetCoordModes()

Index_Username := 1
Index_Password := 2
Index_Slot := 3
Index_Action := 4
Index_Active := 5
Index_Wait := 6
Index_Timeout := 7

Index_Alive := 8
Index_Tools := 9
Index_Target := 10

Index_Time := 11


LoginArray := []
LoginArray := iniFile_GetLogin()
LoginArray := PrepareArray(LoginArray)

index := 1
indexMin := 1
indexMax := LoginArray.MaxIndex()

Array_Cordinates = [[0,0],[0,0],[0,0],[0,0]]
Username_Cords = [0,0]

buildArrayCordinates()

DeathDelay = IniConfigLoad("DeathDelay")

StartUpClient()

LogFile("Starting Loop")

loop
{
	username 	:= LoginArray[index, Index_Username]
	password 	:= LoginArray[index, Index_Password]
	slot		:= LoginArray[index, Index_Slot]
	action		:= LoginArray[index, Index_Action]
	active		:= LoginArray[index, Index_Active]
	waitTime	:= LoginArray[index, Index_Wait]
	timeOutTime	:= LoginArray[index, Index_Timeout]
	
	alive		:= LoginArray[index, Index_Alive]
	tools		:= LoginArray[index, Index_Tools]
	target		:= LoginArray[index, Index_Target]
	
	time		:= LoginArray[index, Index_Time]
	
	LogText := % "Miner#" . index . " Info loaded"
	LogFile(LogText)
	
	LogText := % "active-" . active . " alive-" . alive . " tools-" . tools . " target-" . target . ""
	LogFile(LogText)
	
	if (active && (alive && tools && target))
	{
		LogText := % "Miner#" . index . " Waiting for ready"
		LogFile(LogText)
	
		waitForReady(waitTime, time)
		
		LogText := % "Miner#" . index . " Logging in"
		LogFile(LogText)
		
		loginWorked := Login_Process(username, password, slot, 1)
		
		if loginWorked 
		{
			miningOutcome := MiningLoop(action,timeOutTime)
			
			dead		:= miningOutcome[1]
			notools		:= miningOutcome[2]
			notarget	:= miningOutcome[3]
			kicked		:= miningOutcome[4]
			timeNow		:= GetCurrentTime()
			
			LoginArray[index, Index_Alive]	:= !dead
			LoginArray[index, Index_Tools]	:= !notools
			LoginArray[index, Index_Target]	:= !notarget
			LoginArray[index, Index_Time]	:= timeNow
			
			LogText := % "Miner#" . index . " Logging off, Dead: " . dead . " NoTools: " . notools . ""
			LogFile(LogText)
			
			if (dead || notools || notarget)
			{
				if dead
				{
					LogText := % "" . A_Hour . ":" . A_Min . ":" . A_sec . "  Miner#" . index . " Is dead"
					LogREPORT(LogText)
					
					screenshotDead()
					reportDead()
				}
				if notools
				{
					LogText := % "Miner#" . index . " Is out of tools"
					LogREPORT(LogText)
				}
				if notarget
				{
					LogText := % "Miner#" . index . " no target for mining/woodcutting"
					LogREPORT(LogText)
				}
			}
			
			
		}
		else
		{
			LogText := % "Miner#" . index . " Login failed all attempts, continueing to next miner"
			LogFile(LogText)
		}
		
		LogText := "Logout Function Starting"
		LogFile(LogText)
			
		StartLogout()
		
		LogText := "Logout Function Ended"
		LogFile(LogText)
		
		if dead
		{
			LogText := % "Waiting: " . DeathDelay . " Minutes before starting next miner"
			LogFile(LogText)
			
			timeNow		:= GetCurrentTime()
			waitForReady(DeathDelay, timeNow)
		}
	}
	
	index := index + 1
	if (index > indexMax)
	{
		index := indexMin
	}
}

LogFile("Ending Loop")


Login_Process(username, password, slot, attempts)
{
	FailedCheck := Login_Info(username, password)
	
	Completed := FailedCheck[1]
	Invalid := FailedCheck[2]
	Offline := FailedCheck[3]
	ConnectionLost := FailedCheck[4]
	Firewall := FailedCheck[5]
	
	if Offline
	{
		logText := % "" . A_Hour . ":" . A_Min . ":" . A_sec . ""
		LogFile(logText)
		
		Login_SelectCancel()
		LogFile("Offline Detected, waiting 10 minutes")
		sleep (10 * 60 * 1000)
		
		logText := % "" . A_Hour . ":" . A_Min . ":" . A_sec . ""
		LogFile(logText)
	}
	
	if ConnectionLost
	{
		logText := % "" . A_Hour . ":" . A_Min . ":" . A_sec . ""
		LogFile(logText)
		
		connectionLost_SelectCancel()
		LogFile("Connection Lost, attempting again in 5 minutes")
		sleep (5 * 60 * 1000)
		
		logText := % "" . A_Hour . ":" . A_Min . ":" . A_sec . ""
		LogFile(logText)
	}
	
	if Firewall
	{
		logText := % "" . A_Hour . ":" . A_Min . ":" . A_sec . ""
		LogFile(logText)
		
		Firewall_selectCancel()
		LogFile("Loading characters failed, attempting again in 5 minutes")
		sleep (5 * 60 * 1000)
		
		logText := % "" . A_Hour . ":" . A_Min . ":" . A_sec . ""
		LogFile(logText)
	}
	
	
	Failed := Invalid || Offline || ConnectionLost || Firewall
	
	if !Failed
	{
		Login_Slot(slot)
		workLoad := Login_Load()
	}
	
	if (Failed || !workLoad)
	{
		if (attempts == 5)
		{
			LogFile("5 Attempts failed")
;			StartUpClient()
		}
			
		if (attempts >= 10)
		{
			LogFile("10 Attempts failed, skipping to next miner")
			return false
		}
		LogText := % "Login_Process: Failed, attempt #" . attempts . "/5, Restarting Client"
		LogFile(LogText)
			
		CloseClient()
		
;		Login_SelectCancel()
;		sleep, 30000
		
		attempts := attempts + 1
			
		loginWorked := Login_Process(username, password, slot, attempts)
		return loginWorked
	}
	
	return true
}

Login_Info(name, pass)
{
	ClearLoginInfo()
	InputLoginInfo(name, pass)
	send, {ENTER}
	
	failed := WaitForLogin()
	
	return failed
}

Login_Slot(slot)
{
	LogText := % "Login_Slot: Slot#- " . slot . ""
	LogFile(LogText)
	sleep, 5000
	
	global Array_Cordinates
	PosX := Array_Cordinates[slot,1]
	PosY := Array_Cordinates[slot,2]
	
	WindowActivate()
	
	LogText := % "Login_Slot 1: PosX-" . PosX . "  PosY-" . PosY . ""
	LogFile(LogText)
	
	sleep, 10000
	MouseClick,left,PosX,PosY
	
	sleep, 50
	MouseClick,left,PosX,PosY
	sleep, 50
	MouseClick,left,PosX,PosY
	sleep, 50
	MouseClick,left,PosX,PosY
	sleep, 50
	MouseClick,left,PosX,PosY
	
	sleep, 10
	MouseClick,left,PosX,PosY
	sleep, 10
	MouseClick,left,PosX,PosY
	
	LogFile("Login_Slot complete")
}

Login_Load()
{
	LogFile("Login_Load: Waiting for load in")
	worked := WaitForLoadIn()
	workedLoad := true
	LogFile("Login_Load: Wait passed")
	if worked
	{
		sleep, 20000
		
		LogFile("Login_Load: Reseting pressed in alt-ctrl-shift bullshit")
		ResetKeys()
		
		LogFile("Login_Load: reseting UI")
		ResetUI()
		sleep, 30000
		ResetUI()
		
		LogFile("Login_Load: complete")
	}
	else
	{
		workedLoad := false
		LogFile("Login_Load: Failed, restarting Client - moving to next miner")
	}
	
	return workedLoad
}

Login_SelectCancel()
{
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\LoginCancel.bmp
	MouseClick, left, (FoundX + 5), (FoundY + 5)
}

Firewall_selectCancel()
{
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\FirewallError_cancel.bmp
	MouseClick, left, (FoundX + 5), (FoundY + 5)
}

connectionLost_SelectCancel()
{
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\ConnectionLost_ok.bmp
	MouseClick, left, (FoundX + 5), (FoundY + 5)
}

waitForReady(waitTime, time)
{
	LogText := % "waitForReady: waitTime-" . waitTime . " time-" . time . "  starting function"
	LogFile(LogText)
	if (time = 0)
	{
		LogFile("waitForReady: Exiting, time is 0")
		return
	}
	
	currentTime := GetCurrentTime()
	waitFor := time + waitTime
	
	LogText := % "waitForReady: currentTime-" . currentTime . " waitFor-" . waitFor . "  starting loop"
	LogFile(LogText)
	
	while (currentTime < waitFor)
	{
		sleep 5000
		currentTime := GetCurrentTime()
	}
	
	LogFile("waitForReady: Exiting, time passed")
}

GetCurrentTime()
{	
	milliseconds_time := A_TickCount
	seconds_time := milliseconds_time / 1000
	minute_time := seconds_time / 60
	
	return minute_time
}

MiningLoop(action,timeout)
{
	Bool_MiningLoop := true
	Bool_Picksempty := false
	Bool_ResourceEmpty := false
	Bool_Mining := false
	Bool_NoTarget := false
	Bool_dead := false
	Bool_Timeout := false
	Bool_MiningAttemptFailure := false
	Bool_LoginScreen := false
	Bool_ConnectionLost := false
	
	returnArray := [Bool_dead, Bool_Picksempty]
	
	startTime := GetCurrentTime()
	TimeOutTime := timeout
	
	while Bool_MiningLoop
	{
	
		if !(PickEquiped())
		{
			Bool_Mining := false
			if (PicksAvailable())
			{
				PickEquip()
			}
			else
			{
				Bool_PicksEmpty := true
			}
		}
		
		if !Bool_Mining
		{
			Bool_Mining := StartMining(action)
			if !Bool_Mining
			{
				Bool_Mining := StartMining(action)
				Bool_MiningAttemptFailure := !Bool_Mining
			}
		}
		
		if !Bool_NoTarget
		{
			ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_chatNoTarget.bmp
			Bool_NoTarget := (ErrorLevel = 0)
		}
		
		if !Bool_PicksEmpty
		{
			ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_chatResourceEmpty.bmp
			Bool_ResourceEmpty := (ErrorLevel = 0)
		}
		
		ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_chatCantWhileDead.bmp
		Bool_dead := (ErrorLevel = 0)
		if !Bool_dead
		{
			ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_MR_title.bmp
			Bool_dead := (ErrorLevel = 0)
		}

		ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\quit.bmp
		Bool_LoginScreen := (ErrorLevel = 0)
		if Bool_LoginScreen
		{
			logFile("Login screen detected")
		}
			
		ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *20 %A_ScriptDir%\Pictures\ConnectionLost.bmp
		Bool_ConnectionLost := (ErrorLevel == 0)
		if Bool_ConnectionLost
		{
			logFile("Connection Lost")
			connectionLost_SelectCancel()
		}
		
		if !Bool_Timeout
		{
			currentTime := GetCurrentTime()
			Bool_Timeout := (currentTime - startTime) > TimeOutTime
			
			logText := % "" . A_Hour . ":" . A_Min . ":" . A_sec . ""
			LogFile(logText)
			
			if Bool_Timeout
			{
				logFile("Timeout passed")
			}
		}
		
		Bool_MiningLoop := !(Bool_dead || Bool_Picksempty || Bool_ResourceEmpty || Bool_NoTarget || Bool_Timeout || Bool_LoginScreen || Bool_ConnectionLost) || Bool_MiningAttemptFailure
		sleep, 1000
	}
	
	returnArray := [Bool_dead, Bool_Picksempty, Bool_NoTarget, Bool_LoginScreen]
	
	return returnArray
}

StartMining(action)
{
	sleep, 2000
	Sheath()
	sleep, 2000
	
;	send, z
	Inv_Open()
	sleep, 5000
	Bool_working := true
	
	LogText := % "StartMining - Action:" . action . ""
	LogFile(LogText)
	
	foundSkill := false
	FoundX := 0
	FoundY := 0
	
	if (action = 1)
	{
		ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *100 %A_ScriptDir%\Pictures\UI_SkillMining.bmp
		foundSkill := (Errorlevel = 0)
	}
	else if (action = 2)
	{
		ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *100 %A_ScriptDir%\Pictures\UI_Woodcutting.bmp
		foundSkill := (Errorlevel = 0)
	}
	else
	{
		LogFile("StartMining: Error, invalid action")
		Bool_working := false
	}
	
	if foundSkill
	{
		MouseClick, left, (FoundX + 5), (FoundY + 5)
		LogFile("StartMining: skill button found")
			
		sleep, 2000
		send, {LCtrl}
		sleep, 5000
		send, {LCtrl}
		sleep, 10000
		send, {LCtrl}
		sleep, 1000
	}
	else
	{
		Bool_working := false
		LogFile("StartMining: Error, skill button not found")
	}
	
;	Inv_Open()
	sleep, 5000
	MouseMove, 0, 0
	Inv_Close()
	sleep, 5000
	
	return Bool_working
}

screenshotDead()
{

	ScreenshotActive := IniConfigLoad("IrfanView_Active")
	
	if ScreenshotActive
	{
		IrfanPath := IniConfigLoad("IrfanView_Install")
		formattime,zeit,A_now,dd.MM.yy_HH-mm-ss
		run, "%IrfanPath%\i_view32.exe" "/capture=1 /convert=%A_ScriptDir%\Captures\Shot%Zeit%.PNG", msgbox, Ctrl Printscreen
	}
}

reportDead()
{
	LoopBool := true
	while LoopBool
	{
		ImageSearch, FoundX_BOX, FoundY_BOX, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_MR_box.bmp
		if (ErrorLevel = 0)
		{
			MouseClick,left,(FoundX_BOX + 3),(FoundY_BOX + 3)
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

PickEquip()
{
	Inv_Open()
	sleep, 5000
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_I_pick.bmp
	if (ErrorLevel == 0)
	{
		MouseClick, right, (FoundX + 5), (FoundY + 5)
	}
	sleep, 5000
	Inv_Close()
	sleep, 5000
}

PicksAvailable()
{
	Pap_Close()
	Inv_Open()
	sleep, 5000
	
	available := false
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_I_pick.bmp
	available := (ErrorLevel == 0)
	
	LogText := % "PicksAvailable: " . available . ""
	LogFile(LogText)
	
	Inv_Close()
	sleep, 5000
	return available
}

PickEquiped()
{
	Inv_Close()
	Pap_Open()
	sleep, 5000
	
	Equiped := false
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_P_pick.bmp
	Equiped := (ErrorLevel == 0)
	
	LogText := % "PickEquiped: " . Equiped . ""
	LogFile(LogText)
	
	sleep, 5000
	Pap_Close()
	sleep, 5000
	return Equiped
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
	ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_Inv.bmp
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

ResetKeys()
{
	sleep, 5000
	
	Loop 2
	{
		send, {LCtrl}
		sleep 100
	}
	sleep, 2000
	
	Loop 2
	{
		send, {RCtrl}
		sleep 100
	}
	sleep, 2000
	
	Loop 2
	{
		send, {Lalt}
		sleep 100
	}
	sleep, 2000
	
	Loop 2
	{
		send, {Ralt}
		sleep 100
	}
	sleep, 2000
	
	Loop 2
	{
		send, {Lshift}
		sleep 100
	}
	sleep, 2000
	
	Loop 2
	{
		send, {Rshift}
		sleep 100
	}
	sleep, 2000
}

ResetUI()
{
	sleep, 5000
	send, ^2
	sleep, 5000
	send, ^2
	sleep, 5000
}

WaitForLoadIn()
{
	LoadInComplete := false
	worked := true
	while !LoadInComplete
	{
		ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_SkillMining.bmp
		if ErrorLevel = 0
		{
			LoadInComplete := true
		}
		
		ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\ConnectionLost.bmp
		if ErrorLevel = 0
		{
			LoadInComplete := true
			worked := false
			
			connectionLost_SelectCancel()
		}
		
		sleep, 100
	}
	
	return worked
}

StartLogout()
{
	LogFile("StartLogout - Starting")

	sleep,30000
	send,^3
	sleep,5000
	send,^3
	sleep,5000
	
	LogFile("StartLogout - Sleep passed")
	
	LogoutComplete := false
	Logged := false
	LogoutCanceled := false
	while !LogoutComplete
	{
		ImageSearch, FoundX_1, FoundY_1, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\chatLogoutCancel.bmp
		if ErrorLevel = 0
		{
			LogFile("StartLogout - Canceled")
			LogoutComplete := true
			LogoutCanceled := true
		}
		else
		{
			if Logged
			{
				LogFile("StartLogout - Logged, exiting")
				LogoutComplete := true

				
;				ImageSearch, FoundX_2, FoundY_2, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\quit.bmp
;				if ErrorLevel = 0
;				{
;					LogFile("StartLogout - Quit found")
;					send, {tab}
;					sleep, 500
;					LogoutComplete := true
;				}
;				else
;				{
;					LogFile("StartLogout - Quit not found")
;				}
			}
			else
			{
				ImageSearch, FoundX_3, FoundY_3, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\logout.bmp
				error_logout := Errorlevel
				
				ImageSearch, FoundX_4, FoundY_4, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\quit.bmp
				error_quit := Errorlevel
				
				ImageSearch, FoundX_5, FoundY_5, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\loginFailedTitle.bmp
				error_loginfailed := Errorlevel
				
				if error_logout = 0
				{
					WindowActivate()
					sleep, 1000
					MouseMove, (FoundX_3 + 5), (FoundY_3 + 5)
					sleep, 1000
					MouseClick, left, (FoundX_3 + 5), (FoundY_3 + 5)
					sleep, 3000
					
					Logged := true
					LogFile("StartLogout - Logout found, logged")
				}
				else if (error_quit = 0)
				{
					Logged := true
					LogoutComplete := true
				}
				else if (error_loginfailed = 0)
				{
					WindowActivate()
					
					ImageSearch, FoundX_6, FoundY_6, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\loginFailedCancel.bmp
					sleep, 1000
					MouseMove, (FoundX_6 + 5), (FoundY_6 + 5)
					sleep, 1000
					MouseClick, left, (FoundX_6 + 5), (FoundY_6 + 5)
					sleep, 3000
					
					Logged := true
					LogoutComplete := true
					
					LogFile("StartLogout - Login failed, logged")
				}
			}
		}
	}
	
	LogFile("StartLogout - Loop ended")
	
	if LogoutCanceled
	{
		formattime,zeit,A_now,dd.MM.yy_HH-mm-ss
		LogText := % "" . zeit . " LOGOUT CANCELED"
		LogREPORT(LogText)
		
		CloseClient()
	} else {
		LogText := "Closing client"
		LogFile(LogText)
		CloseClient()
	}
	
	LogFile("StartLogout - Ending")
}

EndScript()
{
	ExitApp
}

CloseClient()
{
	Process, close, MortalOnline.exe
	StartUpClient()
;	EndScript()
}

WaitForLogin()
{
	LoginComplete := false
	LogInFailed_Info := false
	LogInFailed_Offline := false
	LogInFailed_ConnectionLost := false
	LogInFailed_Firewall := false
	sleep, 5000
	while (!LoginComplete && !LogInFailed_Info && !LogInFailed_Offline && !LogInFailed_ConnectionLost && !LogInFailed_Firewall)
	{
		ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *20 %A_ScriptDir%\Pictures\logout.bmp
		LoginComplete := (ErrorLevel == 0)
		
		ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *20 %A_ScriptDir%\Pictures\NotValidInfo.bmp
		LogInFailed_Info := (ErrorLevel == 0)
		
		ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *20 %A_ScriptDir%\Pictures\LoginOffline.bmp
		LogInFailed_Offline := (ErrorLevel == 0)
		
		ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *20 %A_ScriptDir%\Pictures\ConnectionLost.bmp
		LogInFailed_ConnectionLost := (ErrorLevel == 0)
		
		ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *20 %A_ScriptDir%\Pictures\FirewallError.bmp
		LogInFailed_Firewall := (ErrorLevel == 0)
		
		sleep, 100
	}
	
	returnArray := [LoginComplete, LogInFailed_Info, LogInFailed_Offline, LogInFailed_ConnectionLost, LogInFailed_Firewall]
	return returnArray
}

InputLoginInfo(USER, PASS)
{
	LogFile("InputLoginInfo: STARTING")
	
	LogText := % "InputLoginInfo  USER: " . USER . "   PASS: " . PASS . ""
	LogFile(LogText)
	
	SelectUsername()
	sleep, 3000
	send, %USER%
	sleep, 1000
	send, {tab}
	sleep, 1000
	send, %PASS%
	sleep, 1000
	
	LogFile("InputLoginInfo: ENDING")
}

ClearLoginInfo()
{
	LogFile("ClearLoginInfo: STARTING")

	SelectUsername()
	Sleep, 3000
	send, {tab}
	sleep, 1000
	SelectUsername()
	sleep, 1000
	send, {backspace}
	sleep, 1000
	send, {tab}
	sleep, 1000
	send, {backspace}
	sleep, 1000
	
	LogFile("ClearLoginInfo: ENDING")
}

SelectUsername()
{
;	LogFile("SelectUsername: STARTING")
	
;	ImageSearch, FoundX_USERNAME, FoundY_USERNAME, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *20 %A_ScriptDir%\Pictures\LoginUsername.bmp
;	MouseClick, left, (FoundX_USERNAME + 20), (FoundY_USERNAME + 20)

;	global Username_Cords
;	cord_x := Username_Cords[1]
;	cord_y := Username_Cords[2]
;	MouseClick, left, cord_x, cord_y
;	MouseClick, left, cord_x, cord_y

	send, {tab}
	sleep, 500
	send, {tab}
	sleep, 500
	send, {tab}
	sleep, 500
	
;	LogText := % "SelectUsername  FoundX_USERNAME: " . FoundX_USERNAME . "   FoundY_USERNAME: " . FoundY_USERNAME . ""
;	LogFile(LogText)
	
;	LogFile("SelectUsername: ENDING")
}

SetCoordModes()
{
	; Pixel, Mouse
	; Relative, Screen
	CoordMode, Pixel, Screen
	CoordMode, Mouse, Screen
}

StartUpClient()
{
	LauncherStartup()
	sleep, 30000
	WaitForWindow()
	WindowAndMax()
	WaitForLoad()
}

LauncherStartup()
{
	LogFile("LauncherReady-Start")
	
	MO_path := IniConfigLoad("MortalOnline_InstalPath")
	
	Run, Mortal Online Launcher.exe, %MO_path%
	
	WinActivate, Mortal Online Launcher
	
	CoordMode, Pixel, Screen
	CoordMode, Mouse, Screen
	
	LauncherReady := false
	LauncherRestart := false
	
	FoundX_2 := 0
	FoundY_2 := 0
	
	while (!LauncherReady && !LauncherRestart)
	{
		ImageSearch, FoundX_1, FoundY_1, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\scanerror.bmp
		if (ErrorLevel = 0)
		{
			LauncherRestart := true
		}
		else
		{
			ImageSearch, FoundX_2, FoundY_2, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\playerbuttonE.bmp
			if (ErrorLevel = 0)
			{
				LauncherReady := true
			}
			else
			{
				sleep, 100
			}
		}
	}
	
	if LauncherRestart
	{
		LogFile("LauncherReady-Restarting, scan error")
		Process, close, Mortal Online Launcher.exe
		sleep, 5000
		LauncherStartup()
	}
	else
	{
		sleep, 100
		MouseClick, left, (FoundX_2 + 5), (FoundY_2 + 5)
	
		LogFile("LauncherReady-End")
	}
	
	
}


WindowActivate()
{
	WinActivate, MortalGame
}

WaitForWindow()
{
	LogFile("LaunchDone-Start")

	LaunchDone := false
	while !LaunchDone
	{
		IfWinExist, Mortal Online
		{
			LaunchDone := true
		}
		else
		{
			sleep, 100
			IfWinExist, MortalGame
			{
				LaunchDone := true
			}
			sleep, 100
		}
	}
	
	sleep, 10000
	
	LogFile("LaunchDone-End")
}

WindowAndMax()
{
	IfWinExist, Mortal Online
	{
		windIDd := WinExist("Mortal Online")
		isFullScreen := isWindowFullScreen(windIDd)
		
		WinActivate, Mortal Online
		sleep, 10000
		
		if isFullScreen
		{
		send, {F11}
		sleep, 10000
		}
		
		WinMaximize, Mortal Online
		WinActivate, Mortal Online
	}
	else
	{
		windIDd := WinExist("MortalGame")
		isFullScreen := isWindowFullScreen(windIDd)
		
		WinActivate, MortalGame
		sleep, 10000
		
		if isFullScreen
		{
		send, {F11}
		sleep, 10000
		}
		
		WinMaximize, MortalGame
		WinActivate, MortalGame
	}
}

isWindowFullScreen(WinID)
{
    ;checks if the specified window is full screen
    ;use WinExist of another means to get the Unique ID (HWND) of the desired window

    if ( !WinID )
        return

    WinGet, style, Style, ahk_id %WinID%
	
    ; 0x800000 is WS_BORDER.
    ; 0x20000000 is WS_MINIMIZE.
    ; no border and not minimized
	
    retVal := (style & 0x20800000) ? 0 : 1
    Return, retVal
}

WaitForLoad()
{
	LogFile("LoginReady-Start")
	
	LoginReady := false
	while !LoginReady
	{
		ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\quit.bmp
		LoginReady := (ErrorLevel = 0)		
		sleep, 100
	}
	
	LogFile("LoginReady-End")
}

IniConfigLoad(returnName)
{
	configFile = config.ini
	
	returnValue := ""
	IniRead, returnValue, %configFile%, default, %returnName%
	
	return returnValue
}

iniFile_GetLogin()
{
	LogFile("iniFile_GetLogin: Starting")
	
	returnArray := []

	inifile = LogInfo.ini
	ArrayMain := []
	global Index_Username
	global Index_Password
	global Index_Slot
	global Index_Action
	global Index_Active
	global Index_Wait
	global Index_Timeout
	
	Loop
	{
		LogText := % "Loop Check #" . A_Index . " Starting"
		LogFile(LogText)

		IniRead, info_username, %inifile%, Miner%A_Index%, Username
		IniRead, info_password, %inifile%, Miner%A_Index%, Password
		IniRead, info_slot, %inifile%, Miner%A_Index%, Slot
		IniRead, info_action, %inifile%, Miner%A_Index%, Action
		IniRead, info_active, %inifile%, Miner%A_Index%, Active
		IniRead, info_wait, %inifile%, Miner%A_Index%, Wait
		IniRead, info_timeout, %inifile%, Miner%A_Index%, Timeout
		
		if ( (info_username = "ERROR")||(info_password = "ERROR")||(info_slot = "ERROR")||(info_action = "ERROR")||(info_active = "ERROR")||(info_wait = "ERROR")||(info_timeout = "ERROR") )
		{
			text := % "Username = " . info_username . "  Password = " . info_password . "  Slot = " . info_slot . "  Action = " . info_action . "  Active = " . info_active . " Wait = " . info_wait . " Timeout = " . info_timeout . ""
			LogFile(text)
			LogFile("Breaking loop, error in info loaded: Nil Value in require information")
			break
		}
		
		if !((info_slot == 1)||(info_slot == 2)||(info_slot == 3)||(info_slot == 4))
		{
			LogFile("Breaking loop, error in info loaded: Slot not 1, 2, 3 or 4")
			break
		}
		
		if !((info_action == 1)||(info_action == 2))
		{
			LogFile("Breaking loop, error in info loaded: Action not 1 or 2")
			break
		}
		
		if !((info_active == 0)||(info_active == 1))
		{
			LogFile("Breaking loop, error in info loaded: Active not 0 or 1")
			break
		}
		
		
		ArrayMain[A_Index, Index_Username] := info_username
		ArrayMain[A_Index, Index_Password] := info_password
		ArrayMain[A_Index, Index_Slot] := info_slot
		ArrayMain[A_Index, Index_Action] := info_action
		ArrayMain[A_Index, Index_Active] := info_active
		ArrayMain[A_Index, Index_Wait] := info_wait
		ArrayMain[A_Index, Index_Timeout] := info_timeout
		
		text := % "Username = " . info_username . "  Password = " . info_password . "  Slot = " . info_slot . "  Action = " . info_action . "  Active = " . info_active . " Wait = " . info_wait . " Timeout = " . info_timeout . ""
		LogFile(text)
		
		LogText := % "Loop Check #" . A_Index . " Ending"
		LogFile(LogText)
	}
	
	returnArray := ArrayMain
	LogFile("iniFile_GetLogin: Ending")
	
	return returnArray
}

PrepareArray(LoginArray)
{
	LogFile("PrepareArray: Starting")

	ArrayCount := LoginArray.MaxIndex()
	
	global Index_Username
	global Index_Password
	global Index_Slot
	global Index_Action
	global Index_Active
	global Index_Wait
	global Index_Timeout

	global Index_Alive
	global Index_Tools
	global Index_Target

	global Index_Time := 11
	
	
	loop, %ArrayCount%
	{
		LoginArray[A_Index,Index_Alive] := true
		LoginArray[A_Index,Index_Tools] := true
		LoginArray[A_Index,Index_Target] := true
		LoginArray[A_Index,Index_Time] := 0
	}
	
	LogFile("PrepareArray: Ending")
	
	return LoginArray
}

buildArrayCordinates()
{
	userName_x := IniConfigLoad("Username_X")
	userName_y := IniConfigLoad("Username_Y")
	
	global Username_Cords := [userName_x, userName_y]
	
	
	Slot1_X := IniConfigLoad("Slot1_X")
	Slot1_Y := IniConfigLoad("Slot1_Y")

	Slot2_X := IniConfigLoad("Slot2_X")
	Slot2_Y := IniConfigLoad("Slot2_Y")

	Slot3_X := IniConfigLoad("Slot3_X")
	Slot3_Y := IniConfigLoad("Slot3_Y")

	Slot4_X := IniConfigLoad("Slot4_X")
	Slot4_Y := IniConfigLoad("Slot4_Y")
	
	global Array_Cordinates := [[Slot1_X,Slot1_Y],[Slot2_X,Slot2_Y],[Slot3_X,Slot3_Y],[Slot4_X,Slot4_Y]]
}

LogFile(TEXT)
{
	FileAppend %TEXT%`n, %A_ScriptDir%\Logfile.txt
}

LogREPORT(TEXT)
{
	FileAppend %TEXT%`n, %A_ScriptDir%\ATTENTION.txt
}
