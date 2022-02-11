; === Virtual Desktop mods. 
; Makes it so one can move windows between desktops with simple keyboard shortcuts
;   * First remaps Win-Left / Win-Right from snap window left / right to swith to desktop left / right
;   * Then makes Ctrl-Win-Left / Ctrl-Win-Right bring currently active window when switching desktop
;
; Doesn't work for some types of windows etc.. but good enough for purpose. Mostly works. 
; TODO: Move to using the Virtual Desktop API when amended and stabilized...
; To move a window to another desktop is a very convoluted operation otherwise 
; achive that. 
; 
; Found a really neat akk snippet at:
;     https://superuser.com/a/1538134
; That accomplishes just this without DllCalls or anything. Beutiful and elegant in it's simplicity. Why this works 
; it not all that obvious (probably an unintended side-effect), to me. But fortunately for us it does.
; From AHK manual: 
;     WinSet, ExStyle, ^0x80, WinTitle   ; Toggle the WS_EX_TOOLWINDOW attribute, which removes/adds the window from 
;                                          the alt-tab list.
; This also makes the window follow on desktop switch appearantly. Toggle flag back and window stays there. 
;
; Override built in Win-Left/Right shortcut that usually snaps windows to left/right. Remap to the built shortcuts for 
; desktop switching (Left - Right) (Ctrl-Win-Left/Right).
;
$#Left::^#Left
$#Right::^#Right
$^#Left::
  WinGet, Id, ID, A
  WinSet, ExStyle, +0x80, ahk_id %Id%
  Send, ^#{Left}
  WinWait, ahk_id %Id%
  Sleep, 50
  WinSet, ExStyle, -0x80, ahk_id %Id%
  WinActivate, ahk_id %Id%
Return
$^#Right::
  WinGet, Id, ID, A
  WinSet, ExStyle, +0x80, ahk_id %Id%
  Send, ^#{Right}
  WinWait, ahk_id %Id%
  Sleep, 50
  WinSet, ExStyle, -0x80, ahk_id %Id%
  WinActivate, ahk_id %Id%
Return