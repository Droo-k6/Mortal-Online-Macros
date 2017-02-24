Files in folder
	Mining Macro
	Mouse cordinate finder,
		This is used for you to determine the mouse locations of slots to be put into the config, ctrl+left click to get a message, cordinates also get put into a file called Cordinates, created in same location as this program
	Pictures, contains pictures needed for the macros image search
	Screenshots, example screenshots needed if you must create your own pictures - some screenshots may be outdated
====================
Setup:
	
Game/Program:
	- Recomend, lowest settings and sound off, lowest resolution
	- Computer resolution was at 1366x768, game resolution set to lowest
	- You can start it in windowed, if not the macro will set it to macroed
	- All files in the RAR must be in the same place
	- Must be ran as administrator
Config.ini
	- Mortal Online path needs to be set, no spaces between the path and the =
	- If you wish to have screenshots taken of when a miner is killed then you must install irfanview (setup included in .rar) and setup the config path/on or off
	- Mouse cordinates, go to login screen with 4 characters, find each location that activates each slot and ctrl+click with the MouseCodinates.exe running, cords will be printed on screen and copied into cordinates.txt (same location as the .exe), put these cordiantes into the values as needed format: [x,y]
LogInfo.ini
	- Set the worker information in, follow the format given, make sure the # for the bracket name 
	([miner1], [miner2], ect) are all in order starting from 1, 
	else there will be breaks in your mining order
	- No spaces between the = and the values
	- Actions, 1: Mining, 2: Woodcutting
	- Active, 1: on, 0: off
	- Wait, time in minutes before miner should start again
	- Timeout, time in minutes a miner is allowed to be on
	- Slots, 1/2/3/4, any other value will error
	- Username and password, self explanatory
	- NO SPACES between = and the value
Miners
	- Mining icon must be present on hotbar, even if it is a woodcutter
	- Set miner up to be fine on log in to start mining, no requirement to adjust camera pitch and such
	- Chat alpha to 100%
	- Set macros for ctr2 and ctrl3, set ctrl2 macro to do /resetui, ctrl3 macro to do /logout
	