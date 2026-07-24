; Copyright (c) 2026 Ryan Gubele
; SPDX-License-Identifier: MPL-2.0
;
; MCM glue. config.json is the menu; this pushes the watcher's live state into the
; ModSetting sources the page shows and wires the buttons. Both scripts sit on the
; same quest, so `Self as fth_IJW_Watcher` resolves the sibling instance.

Scriptname fth_IJW_MCM extends MCM_ConfigBase

; Set when the user confirms Stop; the actual Scene.Stop() runs on menu close,
; because the world is paused behind an open MCM and the stop won't take there.
bool bStopOnClose

; Sibling scripts on one quest form can't cast directly; route through the shared Quest base.
fth_IJW_Watcher Function GetWatcher()
    return (Self as Quest) as fth_IJW_Watcher
EndFunction

; ================================================================== MCM events

Event OnConfigInit()
    PushSettingsToWatcher()      ; defaults from settings.ini into the engine
    PushControlToWatcher()       ; ...and the master switch + bound hotkey
EndEvent

; Opened because you think you're stuck, so take a fresh reading, not the last poll's.
Event OnConfigOpen()
    PushSettingsToWatcher()
    PushControlToWatcher()                        ; reconcile enable/hotkey with disk
    bStopOnClose = false                          ; never open pre-armed
    SetModSettingString("sStopHint:Actions", "")
    GetWatcher().RunCheck()
    PublishAll()                                  ; repaints
EndEvent

Event OnSettingChange(string a_ID)
    if StringUtil.Find(a_ID, "bNamesLoaded") >= 0
        ; read-only status light: snap any click back to the real state
        SetModSettingBool("bNamesLoaded:Diagnostics", GetWatcher().EditorIdsLoading())
        RefreshMenu()
        return
    endif
    if StringUtil.Find(a_ID, "iHotkey") >= 0
        ; rebound in the keymap -> mirror the new code into the engine
        GetWatcher().SetHotkey(GetModSettingInt("iHotkey:Control"))
        return
    endif
    if StringUtil.Find(a_ID, "bEnabled") >= 0
        GetWatcher().SetEnabled(GetModSettingBool("bEnabled:Control"))
        return
    endif
    PushSettingsToWatcher()      ; any watchdog slider/toggle -> re-apply the trio
EndEvent

; The world resumes the instant the menu closes, so a confirmed Stop is carried out
; here -- the only moment Scene.Stop() actually bites.
Event OnConfigClose()
    if bStopOnClose
        bStopOnClose = false
        bool cleared = GetWatcher().StopCurrentScene()
        if cleared
            Debug.Notification("Scene stopped. Watch the next minute -- deferred stages may fire.")
        else
            Debug.Notification("Stop sent, but the scene did not clear. Open It Just Works again.")
        endif
    endif
EndEvent

; ================================================================ page buttons

; config.json CallFunction: immediate re-read + repaint.
Function Refresh()
    GetWatcher().RunCheck()
    PublishAll()
EndFunction

; Two-step confirm: ShowMessage() can't display from a CallFunction action, so press
; once to arm (the hint row says so), again to cancel. The stop itself runs on menu
; close (OnConfigClose). Guards against an accidental misfire on a working scene.
; Hint row uses $-keys so MCM Helper localizes them (same pattern as Diagnostics
; loop/heal status). Not Debug.Notification -- those stay English on purpose.
Function StopScene()
    if !GetWatcher().GetCurrentSceneRef()
        SetStopHint("$fth_IJW_NoScene")
        return
    endif
    bStopOnClose = !bStopOnClose
    if bStopOnClose
        SetStopHint("$fth_IJW_StopArmed")
    else
        SetStopHint("$fth_IJW_StopCancelled")
    endif
EndFunction

Function SetStopHint(string asText)
    SetModSettingString("sStopHint:Actions", asText)
    RefreshMenu()
EndFunction

; Clear button beneath the keymap: ESC won't unbind here (ESC is Pause), so this
; zeroes the stored keycode, drops the live registration, and repaints as unbound.
Function ClearHotkey()
    SetModSettingInt("iHotkey:Control", -1)
    GetWatcher().SetHotkey(-1)
    RefreshMenu()
EndFunction

; =================================================================== plumbing

Function PushSettingsToWatcher()
    int poll = GetModSettingInt("iPollSeconds:Watchdog")
    int warn = GetModSettingInt("iWarnMinutes:Watchdog")
    int level = GetModSettingInt("iLogLevel:Diagnostics")
    bool levity = GetModSettingBool("bLevity:Control")
    GetWatcher().ApplySettings(poll, warn, level, levity)
EndFunction

; Master switch + hotkey. Disk is the source of truth; the watcher mirrors it.
; Idempotent, so pushing on every open self-heals drift between save and settings.
Function PushControlToWatcher()
    fth_IJW_Watcher w = GetWatcher()
    w.SetEnabled(GetModSettingBool("bEnabled:Control"))
    w.SetHotkey(GetModSettingInt("iHotkey:Control"))
    w.ReassertRegistrations()    ; heal any registration dropped since last open
EndFunction

Function PublishAll()
    fth_IJW_Watcher w = GetWatcher()
    SetModSettingString("sScene:Current",   w.GetSceneLabel())
    SetModSettingString("sFormID:Current",  w.GetFormIDLabel())
    SetModSettingString("sQuest:Current",   w.GetQuestLabel())
    SetModSettingString("sElapsed:Current", w.GetElapsedLabel())
    SetModSettingBool("bNamesLoaded:Diagnostics", w.EditorIdsLoading())
    SetModSettingString("sLoopStatus:Diagnostics", w.GetLoopStatus())
    SetModSettingString("sLastFix:Diagnostics", w.GetLastCorrection())

    string[] hist = w.GetHistoryLabels()
    int i = 0
    while i < 10
        string label = hist[i]
        if label == ""
            label = "--"
        endif
        SetModSettingString("sRecent" + i + ":History", label)
        i += 1
    endwhile
    RefreshMenu()                ; repaint; the native ModSetting writes above are async
EndFunction
