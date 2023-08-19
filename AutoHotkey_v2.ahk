#Requires AutoHotkey v2

#SingleInstance Force

CoordMode "Mouse", "Screen"
; === Open sndvol.exe with Ctrl-Win-g. 
;
; Only woorks consistenty with AutoHotkey v2, for seome reason or setting.
;
; Win-g -> XBoxGameBar
; ms-settings:apps-volume
; sndvol.exe

; ms-settings:apps-volume is oddly slow to open and has a bloated interface if you only want the volume
; sliders. sndvol.exe has about the right features. As does the GameBar, which funnily opens its whole overlay
; faster than the ms-settings app. Like the temporary overlay thing with widgets. Better than widgets on
; the desktop itself...
;
; Inspired by XBox Game Overlay (Win-g), but will start the sndvol.exe app and close it when
; it loses focus... and just to see how it could be done. Use the GameBar or ms-settings:apps-volume
; anyways. Perhaps if moving to midscreen and expanding width some to make app volume sliders immediatly accessable
; will increase the useability factor some. 
;
; Loop wait for an active window that is deactivated and close it. Will work "reliably" in any way
; the app is started... Taking PID from Run's 4th argument will not work as it does not correspond to 
; the process / windows immediatly. So lets just match on exe instead instead of nice reference. 
; WinMove will act on "Last ""Found"" Window", that should be the one set by WinWaitActivate, so we
; don't have to titlematch which i never understood was a prefered way with own parameter...
; Set width to half that of the screen and center the window. Height is fixed and Y pos find so we can omit them. 
;
; This is just confusing
$^#g::
{
  ; sndvol.exe -f coordinates = y * 65536 + x, where x and y - signed integers
  Run("sndvol.exe")
  WinWaitActive("ahk_exe SndVol.exe")
  WinMove(A_ScreenWidth/4,, A_ScreenWidth/2,)
  If WinWaitNotActive("ahk_exe SndVol.exe",, 60)
    Try WinClose()
}


; === Let's map capslock to esc
; if I ever start using that in editors... and let Shift + Capslock act as caps lock.
+CapsLock::CapsLock
$CapsLock::Esc

; === Open Notebook Directory in Code (Shift-Alt-n)
+!n::Run "nvim-qt.exe .", "C:\Users\mignon\OneDrive\Documents\Notes"


Hotkey "XButton1", ClickAtPosition, "Off"

+F1::
{
    global Xc, Yc
    MouseGetPos &Xc, &Yc
    Hotkey "XButton1", "Toggle"
}

ClickAtPosition(ThisHotkey) 
{
    MouseGetPos &Xo, &Yo
    Click "Left", Xc, Yc
    MouseMove Xo, Yo
}
