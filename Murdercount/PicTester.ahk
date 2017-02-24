^Lbutton::

ImageSearch, FoundX_1, FoundY_1, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_MR_title.bmp
ImageSearch, FoundX_2, FoundY_2, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_MR_box.bmp
ImageSearch, FoundX_3, FoundY_3, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *60 %A_ScriptDir%\Pictures\UI_MR_report.bmp

msgbox UI_MR_title: %FoundX_1% - %FoundY_1% `nUI_MR_box: %FoundX_2% - %FoundY_2%`nUI_MR_report: %FoundX_3% - %FoundY_3%
