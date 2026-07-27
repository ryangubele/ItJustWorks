; Copyright (c) 2026 Ryan Gubele
; SPDX-License-Identifier: MPL-2.0
;
; MCM glue. config.json is the menu; this pushes watcher state into ModSettings and
; wires buttons. Same quest as the watcher: `Self as fth_IJW_Watcher`.
;
; Stop Scene: session-only Scene ref. Clear on open and before close-time stop.

Scriptname fth_IJW_MCM extends MCM_ConfigBase

Scene stopTarget

; Sibling scripts on one quest form can't cast directly; route through the shared Quest base.
fth_IJW_Watcher Function GetWatcher()
    return (Self as Quest) as fth_IJW_Watcher
EndFunction

; --- MCM events

Event OnConfigInit()
    stopTarget = None
    PushSettingsToWatcher()
    PushControlToWatcher()
EndEvent

; Clear stopTarget first, then re-push settings and RunCheck.
Event OnConfigOpen()
    stopTarget = None
    SetModSettingString("sStopHint:Actions", "")
    PushSettingsToWatcher()
    PushControlToWatcher()
    fth_IJW_Watcher w = GetWatcher()
    w.RequestRateRetry()
    w.RunCheck("mcm", false)
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
        fth_IJW_Watcher we = GetWatcher()
        bool turnedOn = GetModSettingBool("bEnabled:Control")
        we.SetEnabled(turnedOn)
        if turnedOn
            we.RunCheck("mcm", false)
        endif
        PublishAll()
        return
    endif
    ; Publish only when poll crosses armed/unarmed (not every slider step).
    fth_IJW_Watcher wp = GetWatcher()
    bool wasArmed = wp.IsArmed()
    PushSettingsToWatcher()
    bool nowArmed = wp.IsArmed()
    if wasArmed != nowArmed
        if nowArmed
            wp.RunCheck("mcm", false)
        endif
        PublishAll()
    endif
EndEvent

Event OnConfigClose()
    Scene target = stopTarget
    stopTarget = None
    if !target
        return
    endif
    int result = GetWatcher().StopScene(target)
    NotifyStopResult(result)
EndEvent

; --- page buttons

Function Refresh()
    fth_IJW_Watcher w = GetWatcher()
    w.RequestRateRetry()
    w.RunCheck("mcm", false)
    PublishAll()
EndFunction

Function StopScene()
    fth_IJW_Watcher w = GetWatcher()
    if stopTarget
        w.LogStopArm(stopTarget, false)
        stopTarget = None
        SetStopHint("$fth_IJW_StopCancelled")
        return
    endif
    Scene live = w.GetLiveSceneRef()
    if !live
        SetStopHint("$fth_IJW_NoScene")
        return
    endif
    stopTarget = live
    w.LogStopArm(live, true)
    SetStopHint("$fth_IJW_StopArmed")
EndFunction

Function SetStopHint(string asText)
    SetModSettingString("sStopHint:Actions", asText)
    RefreshMenu()
EndFunction

Function ClearHotkey()
    SetModSettingInt("iHotkey:Control", -1)
    GetWatcher().SetHotkey(-1)
    RefreshMenu()
EndFunction

; --- plumbing

Function NotifyStopResult(int aiResult)
    fth_IJW_Watcher w = GetWatcher()
    int lang = GetModSettingInt("iToastLang:Control")
    if aiResult == w.STOP_CLEARED
        Debug.Notification(fth_IJW_Toasts.StopOk(lang))
    elseif aiResult == w.STOP_CHANGED
        Debug.Notification(fth_IJW_Toasts.StopChanged(lang))
    elseif aiResult == w.STOP_PLAYING
        Debug.Notification(fth_IJW_Toasts.StopFail(lang))
    else
        Debug.Notification(fth_IJW_Toasts.StopNoAction(lang))
    endif
EndFunction

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
    SetModSettingString("sRateStatus:Diagnostics", w.GetRateStatus())
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
