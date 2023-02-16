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

; Run every 250, will not reenter so function will be always active practically 
SetTimer, CloseSndvolOnInactivate

; Disable contexts for Hotkeys, both those defined by :: syntax and Hotkey method. Place context sensitive hotkeys
; below the non-context sensitive in the script.
HotKey, If
#If

; === VirtualDesktopAccessor.dll, Calls and Functions
; imports TogglePinnedWindow() and StepToDesktop(steps, moveActive)
#Include VirtualDesktopAccessor.ahk

; === Let's map capslock to esc
; if I ever start using that in editors... and let Shift + Capslock act as caps lock.
+CapsLock::CapsLock
$CapsLock::Esc

; === Open Notebook Directory in Code (Shift-Alt-n)
+!n::Run, code.exe ., C:\Users\mignon\OneDrive\Documents\Notes

; === Toggle AlwaysOnTop
; Let's make Alt-F3 toggle active window's "AlwaysOnTop" property (wtf, they have one but it is not
; changeable through the window menu's or button's? Made this simpler than I anticipated... Alt-F3
; easily rememberred as next to Alt-F4 and never use it for something else.
; User PowerToy instead that higlights the window as well
; !F3::Winset,Alwaysontop,,A

; === TogglePinnedWindow
!F2::TogglePinnedWindow()

; === Virtual Desktop mods.
; Makes it so one can move windows between desktops with simple keyboard shortcuts
;   * Ctrl-Win-Left / Ctrl-Win-Right swith to desktop left / right
;   * Adding Shift sends currently active window to the destination desktop before switching to it
;
; 2022: Migrated to using VirtualDesktopAccessor.dll
;   StepToDesktop(steps, moveActive)
;     steps: number of desktops to move, negative left, positive right. Wraps.
;     moveActive : send active window to the desktop before switching to it
;
; Ctrl-Mod <- -> now natively switches desktops, keep only because our wraps...  
$^#Left::StepToDesktop(-1, False)
$^#Right::StepToDesktop(1, False)
$+^#Left::StepToDesktop(-1, True)
$+^#Right::StepToDesktop(1, True)


; === Optionally Remaps Space to Click (left mouse button), toggle with Shift-F1
; On first invocation, create hotkey (check for existence). On consequent toggle it off/on.
; The HotKey 2:nd param being either the special keyword "Toggle" or empty or a Label makes
; this pretty readable. 

; On Shift-F1 check if hotkey Shift-Space is defined, else define it as "SendClick:". If defined 
; toggle it on/off. Originally for "Space to spin" function emulation for those games that ltacked
; that option. Seems to work with e.g. ELK / NYX games, but not Leander's for some reason. 
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
; Does at times seem to not close on NotActive transition and leave a thread forever waiting... WioWait -> MinMove works
; sometimes...
$^#g::
  Run sndvol.exe
  WinWaitActive, ahk_exe SndVol.exe
  WinMove,,,A_ScreenWidth/4,,A_ScreenWidth/2
Return

CloseSndvolOnInactivate:
  WinWaitNotActive, ahk_exe SndVol.exe
  WinClose
Return


; === Virtual desktop switch on mouse 4-5 and wheel up/down over task bar, 
; TODO: make wheel alt-tab switch instead... Shift-Alt-Tab actually cycles, 
; individual Alt-Tabs switches between last window and current. 
#If IsPointerOverTaskBar()
$WheelUp::!Tab
$XButton1::StepToDesktop(-1, False)
$WheelDown::+!Tab
$XButton2::StepToDesktop(1, False)

IsPointerOverTaskBar()
{
  MouseGetPos,,,windowsid,,1
  WinGet,taskbarid,ID,ahk_class Shell_TrayWnd
  return windowsid==taskbarid
}

