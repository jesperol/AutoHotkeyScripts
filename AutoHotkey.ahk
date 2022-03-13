; Recommended for performance and compatibility with future AutoHotkey releases.
#NoEnv
#Warn

#SingleInstance, Force

; Will make $ superfluous, probably
#InstallKeybdHook
#InstallMouseHook

; This is for trackpads, they generate too many events for AHK
#MaxHotkeysPerInterval 1000

; Recommended for new scripts due to its superior speed and reliability.
SendMode Input

; Ensures a consistent starting directory.
SetWorkingDir %A_ScriptDir%

DetectHiddenWindows, On

; Remove and comment out #Warn?
space_to_click := False

; Run every 250, will not reenter so function will be always active practically 
SetTimer, CloseSndvolOnInactivate

; Disable contexts for Hotkeys, both those defined by :: syntax and Hotkey method. Place context sensitive hotkeys
; below the non-context sensitive in the script.
HotKey, If
#If

; === Quick-Open volume mixer
; Win-G XBoxGameBar...
;
; ms-settings:apps-volume
; sndvol.exe
; EarTrumpet
;
; ms-settings:apps-volume is incomprehensibly slow to open and bloated interface if you only want the volume
; sliders. sndvol.exe has about the right features. As does the GameBar, which funnily opens its whole overlay
; faster than the ms-settings app... Like the temporary overlay thing...


; === VirtualDesktopAccessor.dll, Calls and Functions
; imports TogglePinnedWindow() and StepToDesktop(steps, moveActive)
#Include VirtualDesktopAccessor.ahk

; === Let's map capslock to esc
; if I ever start using that in editors... and let Shift + Capslock act as caps lock.
+CapsLock::CapsLock
$CapsLock::Esc


; === Open Notebook Directory in Code (Shift-Alt-n)
+!n::Run, code.cmd ., C:\Users\mignon\OneDrive\Documents\Notes


; === Toggle "Pinned" (display on all desktops) window status
; In case the move to virtual desktop script fscks it...toggle it back manually
!F2::TogglePinnedWindow()


; === Toggle AlwaysOnTop
; Let's make Alt-F3 toggle active window's "AlwaysOnTop" property (wtf, they have one but it is not
; changeable through the window menu's or button's? Made this simpler than I anticipated... Alt-F3
; easily rememberred as next to Alt-F4 and never use it for something else.
!F3::Winset,Alwaysontop,,A


; === Virtual Desktop mods.
; Makes it so one can move windows between desktops with simple keyboard shortcuts
;   * Ctrl-Win-Left / Ctrl-Win-Right swith to desktop left / right
;   * Adding Shift sends currently active window to the destination desktop before switching to it
;
; 2022: Migrated to using VirtualDesktopAccessor.dll
;   StepToDesktop(steps, moveActive)
;     steps: number of desktops to move, negative left, positive right. Wraps.
;     moveActive : send active window to the desktop before switching to it
$^#Left::StepToDesktop(-1, False)
$^#Right::StepToDesktop(1, False)
$+^#Left::StepToDesktop(-1, True)
$+^#Right::StepToDesktop(1, True)


; === Optionally Remaps Space to Click (left mouse button), toggle with Shift-F1
; On first invocation, create hotkey (check for existence). On consequent toggle it off/on
+F1::
  Hotkey, $Space, , UseErrorLevel
  if ErrorLevel in 5,6
    HotKey, $Space, SendClick
  Else
    HotKey, $Space, Toggle
Return
SendClick:
  Send {Click}
Return


; === Open sndvol.exe with Shift-Win-g. 
; Inspired by XBox Game Overlay (Win-g), but will start the sndvol.exe app and close it when
; it loses focus. 
; Loop wait for an active window that is deactivated and close it. Will work reliably however
; the app is started....
$^#g::Run sndvol.exe
CloseSndvolOnInactivate:
  WinWaitActive, ahk_exe SndVol.exe
  WinWaitNotActive, ahk_exe SndVol.exe
  WinClose
Return


; === Scroll Wheel Over Notification Area Speaker Icon Changes Volume
; Must be a trivial way to do this without the if and function, but, works and... I originally wanted
; the snippet to run only if the pointer waforevers over the speaker icon to add scroll volume chaning to that
; (as most linux desktop managers do since the dawn of time and is damn convenient imo) but Win11 TrayNotifyWnd1
;
; Windows 11 changed controlclassnn needed for this script to "TrayNotifyWnd1"... from something... maybe akin to
; "ToolbarWindow322". Don't grok, although I've tried... =)
;
; But, just read that the scroll-wheel-over-notification-area-speaker-icon function has been added to Win11
; _finally_, some other that I and 4 people of similar mind had suggested this, so UserVoice suggestions is't
; piped to /dev/null afterall... even requests for features that almost nobody wants... go figure...
;
#If IsPointerOverTray()
$WheelUp::Send {Volume_Up}
$WheelDown::Send {Volume_Down}

IsPointerOverTray()
{
  MouseGetPos,,,,controlclassnn,1
  ; MsgBox, %controlclassnn%  ; If the control name changes again uncomment this for a while and look up and right
  return controlclassnn=="TrayNotifyWnd1"
}


; === Virtual desktop switch on mouse 4-5 and wheel up/down over task bar
#If IsPointerOverTaskBar()
$WheelUp::
$XButton1::
  StepToDesktop(-1, False)
Return
$WheelDown::
$XButton2::
  StepToDesktop(1, False)
Return

IsPointerOverTaskBar()
{
  MouseGetPos,,,windowsid,,1
  WinGet,taskbarid,ID,ahk_class Shell_TrayWnd
  return windowsid==taskbarid
}

