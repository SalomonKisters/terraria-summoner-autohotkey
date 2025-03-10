#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force  ; Ensures only one instance of the script is running.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Global variable to track which key to press next
global keyIndex := 0
global keys := ["1", "2", "3"]  ; The keys to cycle through

; Map Mouse Button 4 (XButton1) to the cycling function
XButton1::CycleKeys()

CycleKeys() {
    global keyIndex
    global keys
    
    ; Increment keyIndex and loop back to 0 if we've reached the end
    keyIndex := Mod(keyIndex + 1, keys.Length())
    
    ; Send the current key
    currentKey := keys[keyIndex + 1]  ; +1 because AHK arrays are 1-indexed
    Send, %currentKey%
    
    ; Optional: Show a small tooltip to indicate which key was pressed
    ToolTip, Pressed key: %currentKey%, , , 1
    SetTimer, RemoveToolTip, -500  ; Remove the tooltip after 500ms
    
    return
}

RemoveToolTip:
    ToolTip, , , , 1
    return