; === Some virtual desktop helper methods to avoid the WS_EX_TOOLWINDOW hack
; See the VirtualDesktopAccessor project for details. The Interface ID's seems to change between windows versions so 
; be prepared to update... Some methods belong to the IVirtualDesktopManagerInternal interface...
hVirtualDesktopAccessor := DllCall("LoadLibrary", Str, A_ScriptDir . "\Lib\VirtualDesktopAccessor.dll", "Ptr") 
GoToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GoToDesktopNumber", "Ptr")
GetCurrentDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetCurrentDesktopNumber", "Ptr")
GetDesktopCountProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetDesktopCount", "Ptr")
MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "MoveWindowToDesktopNumber", "Ptr")
RestartVirtualDesktopAccessorProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "RestartVirtualDesktopAccessor", "Ptr")
IsPinnedWindowProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "IsPinnedWindow", "Ptr")
PinWindowProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "PinWindow", "Ptr")
UnPinWindowProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "UnPinWindow", "Ptr")

; Restart the virtual desktop accessor when Explorer.exe crashes, or restarts (e.g. when coming from fullscreen game)
explorerRestartMsg := DllCall("user32\RegisterWindowMessage", "Str", "TaskbarCreated")
OnMessage(explorerRestartMsg, "OnExplorerRestart")
OnExplorerRestart(wParam, lParam, msg, hwnd) {
    global RestartVirtualDesktopAccessorProc
    DllCall(RestartVirtualDesktopAccessorProc)
}

; StepToDesktop(steps, moveActive)
;   steps: number of desktops to move, negative left, positive right. Wraps.
;   moveActive : send active window to the desktop before switching to it
StepToDesktop(steps, moveActive) {
  global MoveWindowToDesktopNumberProc, GoToDesktopNumberProc, GetCurrentDesktopNumberProc, GetDesktopCountProc
  d_current := DllCall(GetCurrentDesktopNumberProc, UInt)
  d_count := DllCall(GetDesktopCountProc, UInt)
  d_next := Mod(d_current + steps, d_count)
  If (d_next < 0) {
    d_next := d_count + d_next
  }
  If (moveActive) {
    WinGet, activeHwnd, ID, A
    DllCall(MoveWindowToDesktopNumberProc, UInt, activeHwnd, UInt, d_next)
  }
  DllCall(GoToDesktopNumberProc, UInt, d_next)
}

; Toggles Pinned status of active window
TogglePinnedWindow() {
  global IsPinnedWindowProc, PinWindowProc, UnPinWindowProc
  WinGet, activeHwnd, ID, A
  isPinned := DllCall(IsPinnedWindowProc, UInt, activeHwnd)
  If (isPinned == 0) {
    DllCall(PinWindowProc, UInt, activeHwnd)
  } Else If (isPinned == 1) {
    DllCall(UnPinWindowProc, UInt, activeHwnd)
  } Else {
    ; Error / unknown... do nothing 
  }
}
