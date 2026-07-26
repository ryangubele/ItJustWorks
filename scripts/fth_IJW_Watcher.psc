; Copyright (c) 2026 Ryan Gubele
; SPDX-License-Identifier: MPL-2.0
;
; Polls the player's current scene on a timer and fires one advisory toast when
; wallclock and a game-time gate both clear the warn threshold. MCM readout is
; a view of state kept here.
;
; IsPlaying() stays true for stuck scenes -- it only filters already-ended ones.
; Quest scripts have no OnPlayerLoadGame, so the single-update loop re-registers
; each tick (persisted, non-stacking) and the MCM re-arms on open.
;
; Log() emits structured [fth_IJW] lines gated by iLogLevel (0 Off / 1 Events /
; 2 Every check). Values are space-free; join key is scene=0x<form id>. Papyrus
; evaluates args eagerly, so non-literal lines are gated at the call site. Logs
; use SceneKey/QuietEdid so they never fire the names-off toast.

Scriptname fth_IJW_Watcher extends Quest

Actor Property PlayerRef Auto

; Log levels (see Log()). Off = 0, Events = 1, Every check = 2.
int Property LOG_OFF    = 0 AutoReadOnly Hidden
int Property LOG_EVENTS = 1 AutoReadOnly Hidden
int Property LOG_CHECK  = 2 AutoReadOnly Hidden

; Settings, pushed from the MCM; defaults match settings.ini.
float  fPollInterval  = 30.0     ; seconds between polls; 0 disables the loop
float  fAlertThreshold = 360.0   ; wallclock seconds before alert (warn minutes * 60); 0 = never
bool   bRealert = false          ; opt-in repeat alerts; off = one toast per scene
float  fRealertInterval = 300.0  ; wallclock seconds between repeats when bRealert
int    iLogLevel = 0             ; 0 Off / 1 Events / 2 Every check
bool   bLevity = true            ; flavored toast copy; off = plain
int    iToastLang = 0            ; notification language index; see fth_IJW_Toasts

; Game-time gate: also require game minutes >= warn_minutes * TimeScale (live).
GlobalVariable Property TimeScale Auto  ; Skyrim.esm TimeScale (0x3A), ESP-filled; live GetValue
float  TS_EPSILON = 0.01         ; ignore tiny mid-scene timescale jitter

; Tracked state, persisted with the save.
Scene  currentScene
float  fSceneFirstSeen           ; wallclock stamp on scene enter; rebaselined across reload
float  fSceneFirstSeenGame       ; game-time (days) stamp on enter; rebaselined on timescale change
float  fTsAtEnter                ; timescale at enter or last re-baseline
bool   bAlerted                  ; one-shot toast already fired for this scene
float  fLastAlertReal = -1.0     ; wallclock of last toast for re-alert cadence; -1 = none
bool   bAlertHoldLogged          ; Events hold/fire already explained this episode
bool   bEditorIdHinted           ; one-time Load EditorIDs hint

; Loop heartbeat + last self-repair for Diagnostics. fLastTickRealTime only from OnUpdate.
float  fLastTickRealTime = -1.0
string sLastCorrection           ; $-key of last real self-heal, or ""

; Master switch + hotkey mirror (MCM owns disk). Off = dormant, state kept.
bool bEnabled = true
int  iHotkeyCode = -1            ; DXScanCode, -1 unbound

; History ring, newest first. Built lazily -- OnInit does not re-run on load.
string[] histLabel
bool     histReady

; --- lifecycle

Event OnInit()
    EnsureHist()
    string player = "ok"
    if !PlayerRef                 ; recover if the VMAD property fill came up empty
        PlayerRef = Game.GetPlayer()
        player = "recovered"
        RecordCorrection("$fth_IJW_Heal_Player")
        Log(LOG_EVENTS, "heal player via=GetPlayer")
    endif
    if !TimeScale                 ; packaging fault: ESP fill missing; bare Trace (not level-gated)
        Debug.Trace("[fth_IJW] FAULT timescale property unfilled -- game-time gate off (real-only); rebuild the ESP")
    endif
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "life armed player=" + player + " hotkey=" + HotkeyField() + " warn=" + ((fAlertThreshold / 60.0) as int) + "m realert=" + BoolField(bRealert) + " ts=" + TsField() + " level=" + iLogLevel + " levity=" + BoolField(bLevity) + " lang=" + iToastLang)
    endif
    RegisterHotkey()
    Rearm()
EndEvent

Event OnUpdate()
    if !bEnabled                  ; stray timer after we went dormant
        return
    endif
    fLastTickRealTime = Utility.GetCurrentRealTime()   ; heartbeat -- real timer path only
    if iLogLevel >= LOG_CHECK
        Log(LOG_CHECK, "poll tick scene=" + SceneKey(currentScene) + " el=" + ElapsedField() + " thr=" + (fAlertThreshold as int) + "s alerted=" + BoolField(bAlerted) + " playing=" + PlayingField() + " alive=1")
    endif
    Rearm()                       ; re-arm before the work, so a fault in RunCheck can't kill the loop
    RunCheck()
EndEvent

; Re-register the timer unless polling is off or the mod is dormant.
Function Rearm()
    if bEnabled && fPollInterval >= 1.0
        RegisterForSingleUpdate(fPollInterval)
    endif
EndFunction

; MCM push. 0 poll stops the loop; 0 warn disables alerts. Log only on real change
; (slider drag is per-step). Re-arm only when poll interval changes or we go dormant.
Function ApplySettings(int aiPollSeconds, int aiWarnMinutes, bool abRealert, int aiRealertMinutes, int aiLogLevel, bool abLevity, int aiToastLang)
    float newPoll = aiPollSeconds as float
    float newThr = (aiWarnMinutes * 60) as float
    float newRealertInt = (aiRealertMinutes * 60) as float
    bool pollChanged = (newPoll != fPollInterval)
    bool changed = pollChanged || (newThr != fAlertThreshold) || (abRealert != bRealert) || (newRealertInt != fRealertInterval) || (aiLogLevel != iLogLevel) || (abLevity != bLevity) || (aiToastLang != iToastLang)
    fPollInterval = newPoll
    fAlertThreshold = newThr
    bRealert = abRealert
    fRealertInterval = newRealertInt
    iLogLevel = aiLogLevel
    bLevity = abLevity
    iToastLang = aiToastLang
    if changed && iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "life settings poll=" + aiPollSeconds + "s warn=" + aiWarnMinutes + "m realert=" + BoolField(abRealert) + " every=" + aiRealertMinutes + "m level=" + iLogLevel + " levity=" + BoolField(abLevity) + " lang=" + iToastLang)
    endif
    ; Poll 0 must Unregister, not only skip re-arm (else one last OnUpdate can still fire).
    if bEnabled && fPollInterval >= 1.0
        if pollChanged
            Rearm()
        endif
    else
        UnregisterForUpdate()
    endif
EndFunction

; --- poll

; Timer path and MCM-open refresh (readout never poll-stale).
Function RunCheck()
    Scene liveScene = PlayerRef.GetCurrentScene()

    if liveScene != currentScene
        if currentScene
            float dur = ElapsedInScene()
            PushHistory(currentScene, dur)
            if iLogLevel >= LOG_EVENTS
                Log(LOG_EVENTS, "scene leave scene=" + SceneKey(currentScene) + " name=" + QuietEdid(currentScene) + " el=" + (dur as int) + "s")
            endif
        endif
        currentScene = liveScene
        fSceneFirstSeen = Utility.GetCurrentRealTime()
        fSceneFirstSeenGame = Utility.GetCurrentGameTime()
        fTsAtEnter = CurrentTimescale()
        bAlerted = false
        bAlertHoldLogged = false
        fLastAlertReal = -1.0
        if liveScene && iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "scene enter scene=" + SceneKey(liveScene) + " name=" + QuietEdid(liveScene) + " el=0s")
        endif
        return
    endif

    if !bEnabled || !currentScene || fAlertThreshold < 1.0
        return
    endif

    ; Fire when wallclock and game-time gate both clear (AND).
    float ts = CurrentTimescale()
    if ts > 0.0 && Math.abs(ts - fTsAtEnter) > TS_EPSILON
        ; Mid-scene timescale change: restamp game origin only; wallclock stamp stays.
        fSceneFirstSeenGame = Utility.GetCurrentGameTime()
        fTsAtEnter = ts
        if iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "heal rebaseline-ts scene=" + SceneKey(currentScene) + " ts=" + (ts as int))
        endif
    endif

    float realSec = ElapsedInScene()
    float realMin = realSec / 60.0
    float gameMin = ElapsedGameInScene() * 1440.0     ; game days -> minutes
    float gateMin = (fAlertThreshold / 60.0) * ts     ; warn_min * ts; ts<=0 => gate 0 => wallclock-only
    bool realOk = realSec >= fAlertThreshold
    bool gameOk = gameMin >= gateMin
    bool playing = currentScene.IsPlaying()

    ; One-shot unless re-alert; reload rewinds session clock => treat as due.
    bool due
    if bRealert && fRealertInterval >= 60.0
        float nowReal = Utility.GetCurrentRealTime()
        due = (fLastAlertReal < 0.0) || (nowReal < fLastAlertReal) || ((nowReal - fLastAlertReal) >= fRealertInterval)
    else
        due = !bAlerted
    endif

    bool fired = false
    if playing && due && realOk && gameOk
        FireAlert(realSec, gameMin, gateMin, ts)
        fired = true
    endif

    ; One Events hold per episode (latch also set on fire so cadence waits stay quiet).
    if realOk && !fired && !bAlertHoldLogged
        string why
        if !playing
            why = "not-playing"
        ElseIf !due
            why = "already"
        Else
            why = "gate"                  ; wallclock met, game half short
        endif
        if iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "alert hold scene=" + SceneKey(currentScene) + " real=" + (realMin as int) + "m game=" + (gameMin as int) + "m gate=" + (gateMin as int) + "m why=" + why)
        endif
        bAlertHoldLogged = true
    endif
EndFunction

; Advisory toast + one-shot / re-alert stamps + episode latch. Two short lines (UI truncates long ones).
Function FireAlert(float afRealSec, float afGameMin, float afGateMin, float afTs)
    Debug.Notification(fth_IJW_Toasts.Alert(iToastLang) + " " + ElapsedLabel(afRealSec))
    if bLevity
        Debug.Notification("See? It Just Works!")   ; English punchline; Levity off omits it
    endif
    bAlerted = true
    fLastAlertReal = Utility.GetCurrentRealTime()
    bAlertHoldLogged = true
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "alert fire scene=" + SceneKey(currentScene) + " name=" + QuietEdid(currentScene) + " real=" + ((afRealSec / 60.0) as int) + "m game=" + (afGameMin as int) + "m gate=" + (afGateMin as int) + "m ts=" + (afTs as int))
    endif
EndFunction

; Wallclock seconds in this scene. GetCurrentRealTime is session-relative and resets each
; launch while fSceneFirstSeen persists -- now < stamp means reload; restamp so stuck-across-
; reload still works. Always non-negative.
float Function ElapsedInScene()
    float now = Utility.GetCurrentRealTime()
    if now < fSceneFirstSeen
        if iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "heal rebaseline scene=" + SceneKey(currentScene) + " was=" + (fSceneFirstSeen as int) + " now=" + (now as int) + " dt=" + ((fSceneFirstSeen - now) as int) + " (real-time reset across reload)")
        endif
        RecordCorrection("$fth_IJW_Heal_Rebaseline")
        fSceneFirstSeen = now
    endif
    return now - fSceneFirstSeen
EndFunction

; Game-time days in this scene. Calendar time persists across reload (no session reset).
; Stamp <= 0: field never set on this save (upgrade mid-scene) -- stamp now, do not treat
; whole calendar as elapsed. Backwards now < stamp: restamp as a correction.
float Function ElapsedGameInScene()
    float now = Utility.GetCurrentGameTime()
    if fSceneFirstSeenGame <= 0.0
        fSceneFirstSeenGame = now
        fTsAtEnter = CurrentTimescale()
        Log(LOG_CHECK, "life gametime-init scene=" + SceneKey(currentScene))
        return 0.0
    endif
    if now < fSceneFirstSeenGame
        if iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "heal rebaseline-game scene=" + SceneKey(currentScene) + " was=" + (fSceneFirstSeenGame as int) + " now=" + (now as int))
        endif
        RecordCorrection("$fth_IJW_Heal_Rebaseline")
        fSceneFirstSeenGame = now
        return 0.0
    endif
    return now - fSceneFirstSeenGame
EndFunction

; Live TimeScale (ESP-filled 0x3A). ts <= 0 => gate off (wallclock-only). None => 0 (OnInit FAULT).
float Function CurrentTimescale()
    if !TimeScale
        return 0.0
    endif
    return TimeScale.GetValue()
EndFunction

; --- MCM readout

Scene Function GetCurrentSceneRef()
    return currentScene
EndFunction

string Function GetSceneLabel()
    if !currentScene
        return "$fth_IJW_SceneNone"
    endif
    return LabelFor(currentScene)
EndFunction

string Function GetFormIDLabel()
    if !currentScene
        return "--"
    endif
    return "0x" + HexOf(currentScene.GetFormID())
EndFunction

string Function GetQuestLabel()
    if !currentScene
        return "--"
    endif
    Quest owner = currentScene.GetOwningQuest()
    if !owner
        return "--"
    endif
    string edid = PO3_SKSEFunctions.GetFormEditorID(owner as Form)
    string disp = owner.GetName()
    if edid == ""
        edid = "0x" + HexOf(owner.GetFormID())
    endif
    if disp != "" && disp != edid
        return edid + " (" + disp + ")"
    endif
    return edid
EndFunction

string Function GetElapsedLabel()
    if !currentScene
        return "--"
    endif
    return ElapsedLabel(ElapsedInScene())
EndFunction

string[] Function GetHistoryLabels()
    EnsureHist()
    return histLabel
EndFunction

; Diagnostics loop status $-key. "Waking up" = never ticked or post-reload now < stamp.
string Function GetLoopStatus()
    if !bEnabled
        return "$fth_IJW_Loop_Dormant"
    endif
    if fPollInterval < 1.0
        return "$fth_IJW_Loop_Off"
    endif
    float now = Utility.GetCurrentRealTime()
    if fLastTickRealTime < 0.0 || now < fLastTickRealTime
        return "$fth_IJW_Loop_Waking"
    endif
    if (now - fLastTickRealTime) <= (fPollInterval * 2.0 + 5.0)
        return "$fth_IJW_Loop_Running"
    endif
    return "$fth_IJW_Loop_Late"
EndFunction

; Last self-repair $-key for Diagnostics, or "none".
string Function GetLastCorrection()
    if sLastCorrection == ""
        return "$fth_IJW_Heal_None"
    endif
    return sLastCorrection
EndFunction

; True when a scene is present but its editor ID is empty (Load EditorIDs off).
bool Function EditorIdMissing()
    return currentScene && PO3_SKSEFunctions.GetFormEditorID(currentScene as Form) == ""
EndFunction

; po3 Load EditorIDs on? Probe PlayerRef (and base); independent of current scene.
bool Function EditorIdsLoading()
    if PO3_SKSEFunctions.GetFormEditorID(PlayerRef as Form) != ""
        return true
    endif
    return PO3_SKSEFunctions.GetFormEditorID(PlayerRef.GetActorBase() as Form) != ""
EndFunction

; --- Stop Scene (MCM)

; True only when the ref is gone after Stop(); IsPlaying() lies for stuck scenes.
bool Function StopCurrentScene()
    if !currentScene
        return false
    endif
    Scene victim = currentScene
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "alert stop-req scene=" + SceneKey(victim))
    endif
    victim.Stop()
    Utility.Wait(0.25)
    bool cleared = PlayerRef.GetCurrentScene() != victim
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "alert stop-result scene=" + SceneKey(victim) + " cleared=" + BoolField(cleared))
    endif
    RunCheck()               ; refresh tracked state now
    return cleared
EndFunction

; --- enable / hotkey

; Master switch. Off = dormant (loop + hotkey unregistered); state kept for restore.
Function SetEnabled(bool abEnabled)
    if abEnabled == bEnabled
        return
    endif
    bEnabled = abEnabled
    if bEnabled
        Rearm()
        RegisterHotkey()
        Log(LOG_EVENTS, "life enabled")
    else
        UnregisterForUpdate()    ; kill any pending timer
        UnregisterHotkey()
        Log(LOG_EVENTS, "life disabled")
    endif
EndFunction

bool Function IsEnabled()
    return bEnabled
EndFunction

; MCM pushes the bound keycode here (-1 clears). We own the live registration.
Function SetHotkey(int aiKeyCode)
    if aiKeyCode == iHotkeyCode
        return
    endif
    UnregisterHotkey()
    iHotkeyCode = aiKeyCode
    RegisterHotkey()
EndFunction

Function RegisterHotkey()
    if bEnabled && iHotkeyCode >= 0
        RegisterForKey(iHotkeyCode)
    endif
EndFunction

; MCM open: re-register key + timer (no OnPlayerLoadGame on Quest; no player alias).
; Record a heal only if enabled, polling, and no tick within ~2x poll (exclude post-reload
; now < stamp so a fresh load does not fake a recovery).
Function ReassertRegistrations()
    if bEnabled && fPollInterval >= 1.0 && fLastTickRealTime >= 0.0
        float now = Utility.GetCurrentRealTime()
        if now >= fLastTickRealTime && (now - fLastTickRealTime) > (fPollInterval * 2.0)
            if iLogLevel >= LOG_EVENTS
                Log(LOG_EVENTS, "heal reassert dropped=1 gap=" + ((now - fLastTickRealTime) as int) + "s")
            endif
            RecordCorrection("$fth_IJW_Heal_Reassert")
        else
            Log(LOG_CHECK, "heal reassert routine")
        endif
    else
        Log(LOG_CHECK, "heal reassert routine")
    endif
    RegisterHotkey()
    Rearm()
EndFunction

Function UnregisterHotkey()
    if iHotkeyCode >= 0
        UnregisterForKey(iHotkeyCode)
    endif
EndFunction

; Fires for the registered key; ignored while the console is open. Names the current
; scene without opening the menu.
Event OnKeyDown(int aiKeyCode)
    if aiKeyCode != iHotkeyCode || !bEnabled || UI.IsMenuOpen("Console")
        return
    endif
    Scene s = PlayerRef.GetCurrentScene()
    if s
        Debug.Notification(fth_IJW_Toasts.HotkeyInScene(iToastLang) + " " + LabelFor(s))
        if iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "hotkey name scene=" + SceneKey(s))
        endif
    else
        Debug.Notification(fth_IJW_Toasts.HotkeyNoScene(iToastLang))
        Log(LOG_EVENTS, "hotkey name scene=-")
    endif
EndEvent

; --- util

Function PushHistory(Scene akScene, float afDuration)
    EnsureHist()
    int i = 9
    while i > 0
        histLabel[i] = histLabel[i - 1]
        i -= 1
    endwhile
    histLabel[0] = LabelFor(akScene) + "   " + ElapsedLabel(afDuration)
EndFunction

; 10-slot history ring. Lazy first build; wrong length after recompile is a heal.
Function EnsureHist()
    if !histReady
        histLabel = new string[10]
        histReady = true
        Log(LOG_CHECK, "life hist-init")
    elseif histLabel.Length != 10
        int oldLen = histLabel.Length
        histLabel = new string[10]
        if iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "heal hist len_was=" + oldLen + " len_now=10")
        endif
        RecordCorrection("$fth_IJW_Heal_Hist")
    endif
EndFunction

; Display label (edid or form id). May fire the one-time names-off hint.
; Log lines use SceneKey/QuietEdid instead -- never this.
string Function LabelFor(Scene akScene)
    string edid = PO3_SKSEFunctions.GetFormEditorID(akScene as Form)
    if edid != ""
        return edid
    endif
    if !bEditorIdHinted
        bEditorIdHinted = true
        string namesOff = fth_IJW_Toasts.NamesOff(iToastLang)
        if bLevity
            Debug.Notification("It Just Works: " + namesOff)   ; product prefix English; body from fth_IJW_Toasts
        else
            Debug.Notification(namesOff)
        endif
    endif
    return "0x" + HexOf(akScene.GetFormID())
EndFunction

; Low-precision duration for display: seconds under 90s, whole minutes above.
string Function ElapsedLabel(float afSeconds)
    if afSeconds < 90.0
        return "~" + (afSeconds as int) + "s"
    endif
    return "~" + ((afSeconds / 60.0) as int) + "m"
EndFunction

; Sign-safe hex via po3 (form IDs read back signed; a manual loop breaks on the ESL 0xFE range).
string Function HexOf(int aiFormID)
    string s = PO3_SKSEFunctions.IntToString(aiFormID, true)
    if StringUtil.GetLength(s) >= 2 && StringUtil.Substring(s, 0, 2) == "0x"
        return StringUtil.Substring(s, 2)
    endif
    return s
EndFunction

; --- logging

; "[fth_IJW] <line>" when iLogLevel >= aiLevel. Gate non-literal lines at the call site
; (Papyrus evaluates args eagerly).
Function Log(int aiLevel, string asLine)
    if iLogLevel >= aiLevel
        Debug.Trace("[fth_IJW] " + asLine)
    endif
EndFunction

; Last Fix readout. Real corrections only -- not routine reassert.
Function RecordCorrection(string asKey)
    sLastCorrection = asKey
EndFunction

; Log join key: "0x<form id>" or "-". No edid, no names hint.
string Function SceneKey(Scene akScene)
    if !akScene
        return "-"
    endif
    return "0x" + HexOf(akScene.GetFormID())
EndFunction

; Edid or "-" for Events lines. Never fires the names hint; not for the poll heartbeat.
string Function QuietEdid(Scene akScene)
    if !akScene
        return "-"
    endif
    string edid = PO3_SKSEFunctions.GetFormEditorID(akScene as Form)
    if edid == ""
        return "-"
    endif
    return edid
EndFunction

; Precise elapsed seconds for a log field ("120s"), or "-" with no scene.
string Function ElapsedField()
    if !currentScene
        return "-"
    endif
    return (ElapsedInScene() as int) + "s"
EndFunction

string Function BoolField(bool ab)
    if ab
        return "1"
    endif
    return "0"
EndFunction

; IsPlaying() of the current scene for the heartbeat, or "-" with no scene. One native read.
string Function PlayingField()
    if !currentScene
        return "-"
    endif
    return BoolField(currentScene.IsPlaying())
EndFunction

; Boot field: TimeScale property bound?
string Function TsField()
    if TimeScale
        return "ok"
    endif
    return "fault"
EndFunction

string Function HotkeyField()
    if iHotkeyCode >= 0
        return "" + iHotkeyCode
    endif
    return "off"
EndFunction
