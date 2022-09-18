; This is AutoHotkey script.
; Software that allows you to change the keyboard input, installed by scoop.
; scoop install autohotkey

; https://www.autohotkey.com/docs/commands/_HotkeyModifierTimeout.htm
#InstallKeybdHook
#HotkeyModifierTimeout 100

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

;------------------------------------------------------------------------------
; us to jis(https://ossyaritoori.hatenablog.com/entry/2020/09/16/Autohotkeyを用いてWindowsでUS配列キーボードをJIS配列設定で使)
;------------------------------------------------------------------------------
; *"::send, @
; *&::send, {^}
; *'::send, &
; *(::send, *
; *)::send, (
; *+0::send, )
; *=::send, _
; *^::send, =
; *~::send, {+}
; *@::send, [
; *`::send, {{}
; *[::send, ]
; *{::send, {}}
; *]::send, \
; *}::send, |
; *+::send, :k
; +*::send, "
; *vkBA::send, '
; VKF4::send, {``} ; VKF4 = shift
; +VKF4::send,{~}

;------------------------------------------------------------------------------
; Ctrl + h|m|i|[
;------------------------------------------------------------------------------
^h::
  Send, {Backspace}
  Sleep, 2
return

^m::
  Send, {Enter}
  Sleep, 2
return

^i::
  Send, {Tab}
  Sleep, 2
return

^[::
  Send, {Escape}
  Sleep, 2
return

;------------------------------------------------------------------------------
; Alt + Shift + h|j|k|l
;------------------------------------------------------------------------------
!+h::
  Send, {Left}
  Sleep, 2
return

!+j::
  Send, {Down}
  Sleep, 2
return

!+k::
  Send, {Up}
  Sleep, 2
return

!+l::
  Send, {Right}
  Sleep, 2
return

;------------------------------------------------------------------------------
; 無変換+ b|f|n|p|a|e|h|d|m|u (Only JIS keyboard)
;------------------------------------------------------------------------------
vk1D & b::
  Send, {Left}
return

vk1D & f::
  Send, {Right}
return

vk1D & n::
  Send, {Down}
return

vk1D & p::
  Send, {Up}
return

vk1D & a::
  Send, {Home}
return

vk1D & e::
  Send, {End}
return

vk1D & h::
  Send, {Backspace}
return

vk1D & d::
  Send, {Delete}
return

vk1D & m::
  Send, {Enter}
return

vk1D & u::
  Send, {Ctrl Down}{Backspace}{Ctrl Up}
return
