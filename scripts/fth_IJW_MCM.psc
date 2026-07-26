; Copyright (c) 2026 Ryan Gubele
; SPDX-License-Identifier: MPL-2.0
;
; MCM glue. config.json is the menu; this pushes the watcher's live state into the
; ModSetting sources the page shows and wires the buttons. Both scripts sit on the
; same quest, so `Self as fth_IJW_Watcher` resolves the sibling instance.

Scriptname fth_IJW_MCM extends MCM_ConfigBase

; Set when the user confirms Stop; the actual Scene.Stop() runs on menu close
bool bStopOnClose

; Sibling scripts on one quest form can't cast directly; route through the shared Quest base.
fth_IJW_Watcher Function GetWatcher()
    return (Self as Quest) as fth_IJW_Watcher
EndFunction

; --- MCM events

Event OnConfigInit()
    PushSettingsToWatcher()
    PushControlToWatcher()
EndEvent

; Fresh reading on open (not last poll).
Event OnConfigOpen()
    PushSettingsToWatcher()
    PushControlToWatcher()
    bStopOnClose = false
    SetModSettingString("sStopHint:Actions", "")
    GetWatcher().RunCheck()
    PublishAll()
EndEvent

Event OnSettingChange(string a_ID)
    if StringUtil.Find(a_ID, "bNamesLoaded") >= 0
        SetModSettingBool("bNamesLoaded:Diagnostics", GetWatcher().EditorIdsLoading())
        RefreshMenu()
        return
    endif
    if StringUtil.Find(a_ID, "iHotkey") >= 0
        GetWatcher().SetHotkey(GetModSettingInt("iHotkey:Control"))
        return
    endif
    if StringUtil.Find(a_ID, "bEnabled") >= 0
        GetWatcher().SetEnabled(GetModSettingBool("bEnabled:Control"))
        return
    endif
    PushSettingsToWatcher()
EndEvent

; Stop runs on close.
Event OnConfigClose()
    if bStopOnClose
        bStopOnClose = false
        bool cleared = GetWatcher().StopCurrentScene()
        int lang = GetModSettingInt("iToastLang:Control")
        if cleared
            Debug.Notification(fth_IJW_Toasts.StopOk(lang))
        else
            Debug.Notification(fth_IJW_Toasts.StopFail(lang))
        endif
    endif
EndEvent

; --- page buttons

Function Refresh()
    GetWatcher().RunCheck()
    PublishAll()
EndFunction

; Two-step arm/cancel; Stop executes on OnConfigClose.
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

; Clear button beneath the keymap
Function ClearHotkey()
    SetModSettingInt("iHotkey:Control", -1)
    GetWatcher().SetHotkey(-1)
    RefreshMenu()
EndFunction

; --- plumbing

Function PushSettingsToWatcher()
    int poll = GetModSettingInt("iPollSeconds:Watchdog")
    int warn = GetModSettingInt("iWarnMinutes:Watchdog")
    bool realert = GetModSettingBool("bRealert:Watchdog")
    int realertMin = GetModSettingInt("iRealertMinutes:Watchdog")
    int level = GetModSettingInt("iLogLevel:Diagnostics")
    bool levity = GetModSettingBool("bLevity:Control")
    int lang = GetModSettingInt("iToastLang:Control")
    GetWatcher().ApplySettings(poll, warn, realert, realertMin, level, levity, lang)
EndFunction

; Disk is source of truth; push enable/hotkey and reassert registrations.
Function PushControlToWatcher()
    fth_IJW_Watcher w = GetWatcher()
    w.SetEnabled(GetModSettingBool("bEnabled:Control"))
    w.SetHotkey(GetModSettingInt("iHotkey:Control"))
    w.ReassertRegistrations()
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
