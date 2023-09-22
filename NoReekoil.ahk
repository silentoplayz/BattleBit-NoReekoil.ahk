SendMode Input
SetWinDelay, -1
SetControlDelay, -1
SetKeyDelay, -1
SetMouseDelay, -1
SetBatchLines, -1
SetTitleMatchMode, 2
SetWorkingDir %A_ScriptDir%
ListLines Off
#NoEnv
#Persistent
#SingleInstance Force
#MaxThreadsPerHotkey 5
#InstallKeybdHook
#InstallMouseHook
#UseHook On
#KeyHistory 0
#MaxHotkeysPerInterval 999999
#Warn, UseUnsetLocal, Off

ScriptName := SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".") - 1)

; Check admin status and restart the script with admin rights when not found
if (!A_IsAdmin) {
    try {
        Run *RunAs "%A_ScriptFullPath%" /restart
    } catch {
        Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

; Ensure only one instance of the script or compiled EXE is running
if (A_IsCompiled) {
    try {
        hMutex := DllCall("CreateMutex", "uint", 0, "int", true, "Str", "Global\AUniqueMutex")
        if (hMutex = 0) {
            if (A_LastError = 183) {
                MsgBox, An instance of this script is already running.
                ExitApp
            } else {
                throw
            }
        }
    } catch {
        MsgBox, Error creating mutex: %A_LastError%
        ExitApp
    }
}

;-------------------------------------------------------------------------------
; Utility Functions
;-------------------------------------------------------------------------------

; Generate a random string of specified length
GenerateRandomString(length) {
    randomString := ""
    Random, seed
    Loop % length {
        Random, randomInt, 97, 122, %seed%
        randomString .= Chr(randomInt)
    }
    return randomString
}

; Generate random name for the compiled EXE
GenerateDynamicNames() {
    baseName := "G30"
    randomString := GenerateRandomString(12) ; Generate a 12-character random string
    if (A_IsCompiled) {
        DynamicTitle := baseName " - " randomString
        DynamicExeName := baseName "_" randomString ".exe"
        FileMove, % A_ScriptFullPath, % A_WorkingDir "\" DynamicExeName
		return { Title: DynamicTitle, ExeName: DynamicExeName, Success: ErrorLevel }
    } else {
        DynamicTitle := baseName " (Running as .ahk)"
        DynamicExeName := ""
		return { Title: DynamicTitle, ExeName: DynamicExeName, Success: true }
    }
}

; Generate dynamic names
DynamicNames := GenerateDynamicNames()

; Check the existence of a process with the specified window title
ProcessExists(TargetWindowName) {
    Process, Exist, %TargetWindowName%
    return ErrorLevel
}

;-------------------------------------------------------------------------------
; Configuration
;-------------------------------------------------------------------------------

; Load the user-defined TargetWindowName from the INI file
TargetWindowName := IniReadValue("General", "TargetWindowName", DefaultConfig["TargetWindowName"])

; Dictionary to store weapon properties [pixelY, shotsPerMinute]
WeaponProps := {}
WeaponProps["AK74"] := [1.50, 670.0]
WeaponProps["M4A1"] := [1.50, 700.0]
WeaponProps["AK15"] := [1.60, 540.0]
WeaponProps["F2000"] := [1.00, 850.0]
WeaponProps["SCAR-H"] := [1.60, 500.0]
WeaponProps["AUG A3"] := [1.20, 500.0]
WeaponProps["SG550"] := [1.00, 700.0]
WeaponProps["FAMAS"] := [1.40, 900.0]
WeaponProps["ACR"] := [1.40, 700.0]
WeaponProps["G36C"] := [1.45, 750.0]
WeaponProps["HK419"] := [1.40, 660.0]
WeaponProps["FAL"] := [1.5, 650.0]
WeaponProps["AK5C"] := [1.6, 600.0]
WeaponProps["MK14 EBR"] := [1.30, 400.0]
WeaponProps["G3"] := [1.50, 500.0]
WeaponProps["MP7"] := [1.00, 950.0]
WeaponProps["UMP-45"] := [1.00, 650.0]
WeaponProps["PP2000"] := [1.10, 1000.0]
WeaponProps["PP19"] := [1.00, 750.0]
WeaponProps["KRISS VECTOR"] := [1.00, 1200.0]
WeaponProps["MP5"] := [1.00, 800.0]
WeaponProps["HONEY BADGER"] := [1.25, 880.0]
WeaponProps["GROZA"] := [1.20, 650.0]
WeaponProps["P90"] := [0.8, 800.0]
WeaponProps["AS-VAL"] := [1.50, 800.0]
WeaponProps["SCORPIONEVO"] := [2.70, 1200.0]
WeaponProps["L86A1"] := [1.20, 775.0]
WeaponProps["MG36"] := [1.80, 600.0]
WeaponProps["M249"] := [1.10, 700.0]
WeaponProps["ULTIMAX"] := [1.10, 600.0]
WeaponProps["Glock18"] := [1.00, 1100.0]

global currentWeapon := "SG550"
global isFirstShotFired := 0
global weaponIndex := 1
global scriptEnabled := True
accumulatedRecoil := 0.0 ; Variable to store the accumulated recoil value
accumulatedSleepFraction := 0.0 ; Variable to store the accumulated sleep fraction value
baseFov := 90 ; Base field of view (FOV) value
baseSens := 100 ; Base sensitivity value
smoothSteps := 6 ; Number of steps to smooth the recoil
fov := 108 ; Current field of view (FOV) value
sens := 100 ; Current sensitivity value

; Default configuration values
DefaultConfig := Object()
DefaultConfig["pixelX"] := 0 ; Horizontal pixel adjustment for recoil control
DefaultConfig["pixelY"] := WeaponProps[currentWeapon][1]  ; Vertical pixel adjustment for recoil control
DefaultConfig["shotsPerMinute"] := WeaponProps[currentWeapon][2]  ; Rate of fire (shots per minute) based on current weapon
DefaultConfig["isNoRecoilEnabled"] := 1 ; Toggle for enabling/disabling the recoil control (1 = enabled, 0 = disabled)
DefaultConfig["period"] := 3200 ; Time period (in milliseconds) for some functionality (e.g., rate of adjustment)
DefaultConfig["pixelIncrement"] := 1 ; Increment value for adjusting pixelX and pixelY
DefaultConfig["delayIncrement"] := 1 ; Increment value for adjusting delay between shots or actions
DefaultConfig["periodIncrement"] := 100 ; Increment value for adjusting the period
DefaultConfig["firstShotCompensationX"] := 0 ; Horizontal adjustment specifically for the first shot
DefaultConfig["firstShotCompensationY"] := 1 ; Vertical adjustment specifically for the first shot
DefaultConfig["isFirstShotEnabled"] := 0 ; Toggle for enabling/disabling the first shot compensation (1 = enabled, 0 = disabled)
DefaultConfig["TargetWindowName"] := "ChatGPT.exe" ; Default target window name

; Set a configuration variable
Set(varName, varValue) {
    global
    %varName% := varValue
}

; Initialize global variables with default configuration values
for key, value in DefaultConfig {
    Set(key, value)
}

; Check existence of config.ini file and create when needed
if (!FileExist(A_WorkingDir . "\config.ini")) {
    ; Create the INI file with default values
    for key, value in DefaultConfig {
        IniWrite, % value, %A_WorkingDir%\config.ini, General, % key
    }
}

;-------------------------------------------------------------------------------
; Hotkeys Setup
;-------------------------------------------------------------------------------

; Define hotkey identifiers for various actions
LoadFromConfig := "Numpad0"
SaveToConfig := "Numpad1"
ToggleNoRecoil := "Numpad2"
ToggleisFirstShotEnabled := "Numpad3"
RotateWeapons := "Numpad5"
IncrementDown := "Numpad6"
IncrementUp := "Numpad9"
DelayDown := "Numpad7"
DelayUp := "Numpad8"
PeriodDown := "NumpadSub"
PeriodUp := "NumpadAdd"
PixelUp := "PgUp"
PixelDown := "PgDn"
PixelLeft := "Del"
PixelRight := "End"
MoveCursor := "LButton"

; Always set up the hotkey to toggle the script's state
HotKey, ~*$%ToggleNoRecoil%, DoToggleNoRecoil

; Use hooks to set up hotkeys only based on the target window's existence
if (scriptEnabled && ProcessExists(TargetWindowName))
{
HotKey, ~*$%LoadFromConfig%, DoLoadFromConfig
HotKey, ~*$%SaveToConfig%, DoSaveToConfig
HotKey, ~*$%ToggleisFirstShotEnabled%, DoToggleisFirstShotEnabled
HotKey, ~*$%RotateWeapons%, DoRotateThroughWeapons
HotKey, ~*$%IncrementDown%, DoIncrementDown
HotKey, ~*$%IncrementUp%, DoIncrementUp
HotKey, ~*$%DelayDown%, DoDelayDown
HotKey, ~*$%DelayUp%, DoDelayUp
HotKey, ~*$%PeriodDown%, DoPeriodDown
HotKey, ~*$%PeriodUp%, DoPeriodUp
Hotkey, ~*$%PixelUp%, DoPixelUp
Hotkey, ~*$%PixelDown%, DoPixelDown
Hotkey, ~*$%PixelLeft%, DoPixelLeft
Hotkey, ~*$%PixelRight%, DoPixelRight
HotKey, ~*$%MoveCursor%, DoHandleRecoil
}
return

;-------------------------------------------------------------------------------
; Tool-tips
;-------------------------------------------------------------------------------

; Show a tooltip with specified text and type
ShowTip(PopupText, TipType) {
    Gui, Destroy
    Gui, +AlwaysOnTop +ToolWindow -SysMenu -Caption
    Gui, Color, 000000
    Gui, Font, s8, norm, Verdana

    if (TipType = "On") {
        Gui, Add, Text, x5 y5 c00ff00, %PopupText%
        Gui, Show, NoActivate X0 Y18
    } else if (TipType = "Off") {
        Gui, Add, Text, x5 y5 cff0000, %PopupText%
        Gui, Show, NoActivate X0 Y54
    } else if (TipType = "RPS") {
        Gui, Add, Text, x5 y5 c00ff00, %PopupText%
        Gui, Show, NoActivate X0 Y36
    }

    ; Apply transparency only to the tooltip GUI
    WinSet, Transparent, 100, ahk_id %A_GuiHwnd%

    SetTimer, TipClear, -5000  ; Set a timer to clear tooltips after 5 seconds
}

TipClear() {
    Gui, Destroy
}

;-------------------------------------------------------------------------------
; INI Setup
;-------------------------------------------------------------------------------

DoLoadFromConfig:
    if (!scriptEnabled || !ProcessExists(TargetWindowName))
        return

        ShowTip("LoadFromConfig started.", "On")
        InputBox, WeaponCall, WeaponCall, , Show, 200, 100
        if !ErrorLevel {
            for key, value in DefaultConfig {
                valueFromFile := IniReadValue(WeaponCall, key, value)
                if (valueFromFile = "") {
                    MsgBox, Error reading value from INI file for key %key% in section %WeaponCall%.
                } else {
                    %key% := valueFromFile
                }
            }
            ShowTip("Loaded settings from " WeaponCall, "On")
        } else {
            ShowTip("LoadFromConfig canceled.", "Off")
        }
return

DoSaveToConfig:
    if (!scriptEnabled || !ProcessExists(TargetWindowName))
        return

        ShowTip("SaveToConfig function started.", "On")
        InputBox, WeaponSend, WeaponSend, , Show, 200, 100
        if !ErrorLevel {
            for key, value in DefaultConfig {
                try {
                    IniWrite, % %key%, %A_WorkingDir%\config.ini, %WeaponSend%, %key%
                } catch {
                    MsgBox, Error writing value to INI file for key %key% in section %WeaponSend%: %A_LastError%
                }
            }
            ShowTip("Saved settings for " WeaponSend, "On")
        }
return

IniReadValue(Section, Key, Default) {
    try {
        IniRead, OutputVar, %A_WorkingDir%\config.ini, %Section%, %Key%, %Default%
        return OutputVar
    } catch {
        MsgBox, Error reading from the INI file: %A_LastError%
        return Default ; Return the default value if there's an error
    }
}

;-------------------------------------------------------------------------------
; Action Functions
;-------------------------------------------------------------------------------

DoRotateThroughWeapons:
    if (!scriptEnabled || !ProcessExists(TargetWindowName))
        return

    ; Get the list of weapons from the WeaponProps dictionary
    weapons := Object()
    for weapon, props in WeaponProps
        weapons.Insert(weapon)

    ; Increment the weapon index
    weaponIndex++
    if (weaponIndex > weapons.Length())
        weaponIndex := 1

    ; Set the current weapon
    currentWeapon := weapons[weaponIndex]

    ; Update the values based on the selected weapon
    pixelY := WeaponProps[currentWeapon][1]  ; Update the vertical pixel adjustment for recoil control
    shotsPerMinute := WeaponProps[currentWeapon][2]  ; Update the rate of fire (shots per minute) based on current weapon

    ; Display the tooltip
    props := WeaponProps[currentWeapon]
    ShowTip("Selected Weapon: " . currentWeapon . "`nRecoil Multiplier: " . props[1] . "`nShots Per Minute: " . props[2], "On")
return

DoToggleNoRecoil:
    if (ProcessExists(TargetWindowName))
    {
        global isNoRecoilEnabled, scriptEnabled

        scriptEnabled := !scriptEnabled ; Toggle the scriptEnabled state
        isNoRecoilEnabled := scriptEnabled ; Sync the NoRecoil state with scriptEnabled

        SoundBeep, % (isNoRecoilEnabled) ? "800,200" : "200,100 500,100"
        ShowTip((isNoRecoilEnabled) ? "Script && No Recoil: ON" : "Script && No Recoil: OFF", (isNoRecoilEnabled) ? "On" : "Off")
    }
return

DoToggleisFirstShotEnabled:
    if (!scriptEnabled || !ProcessExists(TargetWindowName)) ; If the script is not enabled or the target window doesn't exist, exit the function
        return

    global isFirstShotEnabled

    isFirstShotEnabled := !isFirstShotEnabled ; Toggle the isFirstShotEnabled state
    SoundBeep, % (isFirstShotEnabled) ? "800,200" : "200,100 500,100"
    ShowTip("First Shot Compensation: " . (isFirstShotEnabled ? "ON" : "OFF"), (isFirstShotEnabled ? "On" : "Off"))
return


DoAdjustPixel(direction) {
    global pixelx, pixely, pixelIncrement

    if (!scriptEnabled || !ProcessExists(TargetWindowName))
        return

    ; Adjust the pixel values based on the given direction
    if (direction = "Left" && pixelx < 1000) {
        pixelx += pixelIncrement
    } else if (direction = "Right" && pixelx > -1000) {
        pixelx -= pixelIncrement
    } else if (direction = "Up" && pixely < 1000) {
        pixely += pixelIncrement
    } else if (direction = "Down" && pixely > -1000) {
        pixely -= pixelIncrement
    }

    ; Display the tooltip with the updated pixel values
    ShowTip("Pixel X Is " . pixelx . "`nPixel Y Is " . pixely, "On")
}


DoAdjustValue(type, direction) {
    if (!scriptEnabled || !ProcessExists(TargetWindowName))
        return

    global shotsPerMinute, delayIncrement, period, periodIncrement, pixelIncrement

    if (type = "Delay") {
        if (direction = "Up") {
            shotsPerMinute += delayIncrement
        } else if (direction = "Down" && shotsPerMinute > delayIncrement) { ; Ensure RPM doesn't go negative
            shotsPerMinute -= delayIncrement
        }
        timePerShot := 60 / Max(shotsPerMinute, 1) ; Time in seconds for one shot, avoid division by zero
        ShowTip("RPM: " . shotsPerMinute . "  Time per Shot: " . timePerShot . " seconds", "RPS")
    } else if (type = "Period") {
        if (direction = "Up" && period > 100) {
            period -= periodIncrement
        } else if (direction = "Down" && period < 6000) {
            period += periodIncrement
        }
        ShowTip("PERIOD IS " period, "On")
    } else if (type = "Increment") {
        if (direction = "Up") {
            pixelIncrement += 0.1
            delayIncrement += 1
            periodIncrement += 100
        } else if (direction = "Down") {
            pixelIncrement := Max(pixelIncrement - 0.1, 0.1)
            delayIncrement := Max(delayIncrement - 1, 1)
            periodIncrement := Max(periodIncrement - 100, 100)
        }
        ShowTip("Increment: " . pixelIncrement . "  " . "Delay Increment:" . delayIncrement . "  " . "Period Increment:" . periodIncrement, "On")
    }
}

DoHandleRecoil:
    global isFirstShotEnabled, shotsPerMinute, isNoRecoilEnabled, firstShotCompensationX, firstShotCompensationY, currentWeapon, accumulatedRecoil, accumulatedSleepFraction, baseFov, baseSens, smoothSteps, fov, sens, pixelx, pixely

    if (ProcessExists(TargetWindowName))
    {
        GetKeyState, stateL, LButton, P
        GetKeyState, stateR, RButton, P

        if (stateL = "U" || stateR = "U") {
            isFirstShotFired := 0 ; Reset the isFirstShotFired variable when the button is released
            return
        }

        ; Get the current weapon's recoil properties
        weapon := currentWeapon
        props := WeaponProps[weapon]
        recoilY := props[1] * 19.5 * (fov / baseFov) / (sens / baseSens)

        ; Calculate the delay between shots based on the RPM
        localRecoilShotsPerMinute := (60000 / shotsPerMinute) / smoothSteps

        ; Divide the recoil value by the number of smooth steps
        if (smoothSteps > 1) {
            recoilY /= smoothSteps
        }

        while (stateL = "D" && stateR = "D") ; Both buttons are being held down
        {
            totalRecoil := recoilY + accumulatedRecoil ; Calculate the total recoil value
            integerRecoil := Round(totalRecoil) ; Round the total recoil value to the nearest integer
            accumulatedRecoil := totalRecoil - integerRecoil ; Update the accumulated recoil value
            accumulatedSleepFraction += localRecoilShotsPerMinute Mod 1 ; Add the fractional part of the fire rate to the accumulated sleep fraction

            totalDelay := localRecoilShotsPerMinute + accumulatedSleepFraction ; Calculate the total delay
            integerDelay := Floor(totalDelay) ; Round the total delay to the nearest integer
            accumulatedSleepFraction := totalDelay - integerDelay ; Update the accumulated sleep fraction

            ; Apply normal pixel movement with accumulated recoil only when isNoRecoilEnabled is on
            if (isNoRecoilEnabled = 1) {
                DllCall("mouse_event", uint, 1, int, pixelx, int, pixely + integerRecoil, uint, 0, int, 0)
            }
            ; Apply first shot compensation on the first shot
            else if (isFirstShotFired = 0 && isFirstShotEnabled = 1) {
                DllCall("mouse_event", uint, 1, int, Round(pixelx + firstShotCompensationX), int, Round(pixely + firstShotCompensationY), uint, 0, int, 0)
                isFirstShotFired := 1
            }

            if (accumulatedSleepFraction >= 1)
            {
                integerDelay-- ; Decrease the integer delay by 1
                accumulatedSleepFraction-- ; Decrease the accumulated sleep fraction by 1
            }
            Sleep, integerDelay ; Sleep for the integer delay

            ; Update the button states for the next iteration
            GetKeyState, stateL, LButton, P
            GetKeyState, stateR, RButton, P
        }
    }
    return

DoPixelLeft:
    global pixelx, pixely, pixelIncrement
    DoAdjustPixel("Left")
return

DoPixelRight:
    global pixelx, pixely, pixelIncrement
    DoAdjustPixel("Right")
return

DoPixelUp:
    global pixelx, pixely, pixelIncrement
    DoAdjustPixel("Up")
return

DoPixelDown:
    global pixelx, pixely, pixelIncrement
    DoAdjustPixel("Down")
return

DoDelayUp:
    global shotsPerMinute, delayIncrement
    DoAdjustValue("Delay", "Up")
return

DoDelayDown:
    global shotsPerMinute, delayIncrement
    DoAdjustValue("Delay", "Down")
return

DoPeriodUp:
    global period, periodIncrement
    DoAdjustValue("Period", "Up")
return

DoPeriodDown:
    global period, periodIncrement
    DoAdjustValue("Period", "Down")
return

DoIncrementUp:
    global pixelIncrement, delayIncrement, periodIncrement
    DoAdjustValue("Increment", "Up")
return

DoIncrementDown:
    global pixelIncrement, delayIncrement, periodIncrement
    DoAdjustValue("Increment", "Down")
return

OnExit, releaseMutex
return

releaseMutex:
    global hMutex
    try {
        if (hMutex != 0)
            DllCall("CloseHandle", "Uint", hMutex)
    } catch {
        MsgBox, Error releasing mutex: %A_LastError%
    }
    ExitApp
