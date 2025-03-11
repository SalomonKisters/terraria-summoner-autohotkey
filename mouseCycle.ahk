#NoEnv
#SingleInstance Force
SendMode Event
SetBatchLines, -1  ; Run script at maximum speed
Process, Priority, , High  ; Set script process to high priority

; ========== CONFIGURATION SECTION ==========
; Add or remove keys from this array to customize your cycle
KeysToSend := ["3","4"]  ; Change these to any keys you want to cycle through

; Timing settings
CycleInterval := 300     ; Time between key presses in milliseconds (0.5 seconds)

; Tooltip settings
ShowTooltip := false      ; Set to false to disable the tooltip
TooltipX := 50           ; X position of tooltip
TooltipY := 50           ; Y position of tooltip
TooltipDuration := 300   ; How long the tooltip shows (milliseconds)

; ========== CODE SECTION ==========
; Global variables
global Counter := 0
global KeyCount := KeysToSend.Length()
global CyclingActive := false
global LastKeyTime := 0
global TimerName := "ForceKeyCycle"

; Map Mouse Button 4 to toggle the auto-cycling
XButton1::
    CyclingActive := !CyclingActive
    
    if (CyclingActive) {
        ; Initialize the counter and start the cycling timer
        Counter := 0  ; Reset counter when starting
        LastKeyTime := A_TickCount
        SetTimer, %TimerName%, 50  ; Check more frequently to maintain timing accuracy
        ToolTip, Auto Key Cycling: ENABLED, %TooltipX%, %TooltipY%
    } else {
        ; Stop the cycling timer
        SetTimer, %TimerName%, Off
        ToolTip, Auto Key Cycling: DISABLED, %TooltipX%, %TooltipY%
    }
    
    ; Remove the enable/disable tooltip after a moment
    SetTimer, RemoveToolTip, 1000
return

; Alternative approach using a more reliable timer mechanism
ForceKeyCycle:
    if (!CyclingActive)
        return
    
    ; Check if it's time to send the next key
    CurrentTime := A_TickCount
    if (CurrentTime - LastKeyTime >= CycleInterval) {
        ; Update counter
        Counter := Mod(Counter, KeyCount) + 1
        
        currentKey := KeysToSend[Counter]
        
        ; Convert the key to ASCII value for sending
        key := GetKeyCode(currentKey)
        
        ; More robust key sending that won't be blocked by other inputs as easily
        Critical, On  ; Make this section uninterruptible
        DllCall("keybd_event", "int", key, "int", 0, "int", 0, "int", 0)
        Sleep, 1  ; Longer sleep for more reliable key press in games
        DllCall("keybd_event", "int", key, "int", 0, "int", 2, "int", 0)
        Critical, Off
        
        ; Update the last key time
        LastKeyTime := CurrentTime
        
        ; Simple notification
        if (ShowTooltip) {
            ToolTip, % "Auto-sent key: " . currentKey, %TooltipX%, %TooltipY%
            SetTimer, RemoveToolTip, -%TooltipDuration%
        }
    }
return

RemoveToolTip:
    ToolTip
return

; Function to convert key names to key codes
GetKeyCode(keyName) {
    if (keyName >= "0" && keyName <= "9")
        return Asc(keyName)  ; Number keys
    else if (keyName >= "A" && keyName <= "Z")
        return Asc(keyName)  ; Letter keys
    else if (keyName >= "a" && keyName <= "z")
        return Asc(keyName) - 32  ; Convert lowercase to uppercase ASCII
    
    return 0  ; Default return if key not recognized
}
