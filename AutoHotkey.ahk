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

; Disable contexts for Hotkeys, both those defined by :: syntax and Hotkey method. Place context sensitive hotkeys
; below the non-context sensitive in the script.
HotKey, If
#If

; === VirtualDesktopAccessor.dll, Calls and Functions
; imports TogglePinnedWindow() and StepToDesktop(steps, moveActive)
#Include VirtualDesktopAccessor.ahk

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
;+F1::
;  Hotkey, $Space, , UseErrorLevel
;  if ErrorLevel in 5,6
;    HotKey, $Space, SendClick
;  Else
;    HotKey, $Space, Toggle
;Return

SendClick:
  Send {Click}
Return

; === Mouse wheel over tray controls volume
; Now native (has pepaps been since long back), next function overrides that though. And as an added bonus we get the 
; OSD indicator popup that native function will not show (but, you propable look at mouse pointer anywas and see volume
; in tooltip text.)
#If IsPointerOverTray()
$WheelUp::Send {Volume_Up}
$WheelDown::Send {Volume_Down}

IsPointerOverTray()
{
  MouseGetPos,,,,controlclassnn,1
  ; MsgBox, %controlclassnn%  ; If the control name changes again uncomment this for a while and look up and right
  return controlclassnn=="TrayNotifyWnd1"
}

; === Virtual desktop switch on mouse 4-5 and wheel up/down over task bar, 
; TODO: make wheel alt-tab switch instead... Shift-Alt-Tab actually cycles, 
; individual Alt-Tabs switches between last window and current. 
; We cannot have this as it will override screll over speaker icon volume
; change functionallity, unless readding the old ahk method from prior commit. 
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

