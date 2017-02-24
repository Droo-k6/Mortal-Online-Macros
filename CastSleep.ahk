; Delay
Sleep 5000
; Main loop
Loop 9999999999 {
        ; Spurt 30 times, change the number after loop to whatever. Change the key combo as well
    loop 30 {
                Sleep, 2300
                ControlSend,,{LAlt DOWN}6{LAlt UP}, Mortal Online
                Sleep, 2100
                ControlSend,,{LAlt DOWN}6{LAlt UP}, Mortal Online
        }
        sleep, 2000
       
        ; Change keys to your sleep hotkey
        ; Sleep is in milliseconds
        ControlSend,,{LAlt DOWN}1{LAlt UP}, Mortal Online
        Sleep 95000
        ControlSend,,{LAlt DOWN}1{LAlt UP}, Mortal Online
    Sleep 4000
}