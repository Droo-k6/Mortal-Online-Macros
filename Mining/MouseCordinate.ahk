^Lbutton::

MouseGetPos, xpos, ypos
msgbox X: %xpos% `nY: %ypos%
FileAppend %A_Hour%-%A_Min%-%A_sec%   X: %xpos%   Y: %ypos%`n, %A_ScriptDir%\Cordinates.txt

return