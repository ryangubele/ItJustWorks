; Copyright (c) 2026 Ryan Gubele
; SPDX-License-Identifier: MPL-2.0
;
; Polls the player's current scene on a timer and fires one advisory notification
; once you've been in a scene past a threshold. The MCM readout is a view of the
; state kept here.
;
; Load-bearing:
;   * IsPlaying() is not a stuck-detector (it stays true for stuck scenes); it only
;     gates out already-ended scenes. Duration is the signal.
;   * Quest scripts get no OnPlayerLoadGame, so the single-update loop re-registers
;     itself each tick (persisted, non-stacking); the MCM re-arms it on open.
;
; Observability (0.3.0): every transition and every self-correction writes a structured,
; greppable line -- [fth_IJW] <tag> <event> key=value -- through Log(), gated by iLogLevel
; (0 Off / 1 Events / 2 Every check). All values are space-free; the join key is
; scene=0x<formid>. Logging is off by default and near-free when off: because Papyrus
; builds call arguments eagerly, every concatenating line is gated at the call site so
; nothing is built or fetched below its level. Log lines use SceneKey/QuietEdid, which
; never fire the "names are off" hint -- that stays owned by the display path (LabelFor).

Scriptname fth_IJW_Watcher extends Quest

Actor Property PlayerRef Auto

; Log levels (see Log()). Off = 0, Events = 1, Every check = 2.
int Property LOG_OFF    = 0 AutoReadOnly Hidden
int Property LOG_EVENTS = 1 AutoReadOnly Hidden
int Property LOG_CHECK  = 2 AutoReadOnly Hidden

; Settings, pushed from the MCM; defaults match settings.ini.
float  fPollInterval  = 30.0     ; seconds between polls; 0 disables the loop
float  fAlertThreshold = 180.0   ; seconds in-scene before alerting; 0 = never
int    iLogLevel = 0             ; 0 Off / 1 Events / 2 Every check

; Tracked state, persisted with the save.
Scene  currentScene
float  fSceneFirstSeen
bool   bAlerted
bool   bEditorIdHinted           ; nag once about Load EditorIDs

; Loop-alive + last self-repair, for the readout. fLastTickRealTime is stamped in
; OnUpdate only (the real timer tick), -1 until the first tick; guarded for the
; real-time reset like ElapsedInScene. sLastCorrection holds the $-key of the most
; recent genuine self-heal ("" = none). Inert value types, no world handles.
float  fLastTickRealTime = -1.0
string sLastCorrection

; Master switch + bound hotkey, persisted so a reload keeps them without the menu.
; bEnabled off = dormant (loop + hotkey unregistered), nothing lost. iHotkeyCode is
; the DXScanCode, -1 when unbound; the MCM owns the on-disk copies, these mirror them.
bool bEnabled = true
int  iHotkeyCode = -1

; 10-entry history ring, newest first. Papyrus throws on array==None and OnInit
; doesn't re-run on load, so readiness is a bool and the array is built lazily in
; EnsureHist() -- self-heals across save/reload and recompiles.
string[] histLabel
bool     histReady

; =================================================================== lifecycle

Event OnInit()
    EnsureHist()
    string player = "ok"
    if !PlayerRef                 ; recover if the VMAD property fill came up empty
        PlayerRef = Game.GetPlayer()
        player = "recovered"
        RecordCorrection("$fth_IJW_Heal_Player")
        Log(LOG_EVENTS, "heal player via=GetPlayer")
    endif
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "life armed player=" + player + " hotkey=" + HotkeyField() + " level=" + iLogLevel)
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
        Log(LOG_CHECK, "poll tick scene=" + SceneKey(currentScene) + " el=" + ElapsedField() + " thr=" + (fAlertThreshold as int) + "s alerted=" + BoolField(bAlerted) + " alive=1")
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

; Pushed by the MCM. 0 poll stops the loop; 0 warn disables alerting. Guarded on a
; real change so a slider drag (fires per step) doesn't spam the log.
Function ApplySettings(int aiPollSeconds, int aiWarnMinutes, int aiLogLevel)
    float newPoll = aiPollSeconds as float
    float newThr = (aiWarnMinutes * 60) as float
    bool changed = (newPoll != fPollInterval) || (newThr != fAlertThreshold) || (aiLogLevel != iLogLevel)
    fPollInterval = newPoll
    fAlertThreshold = newThr
    iLogLevel = aiLogLevel
    if changed && iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "life settings poll=" + aiPollSeconds + "s warn=" + aiWarnMinutes + "m level=" + iLogLevel)
    endif
    Rearm()                       ; pick up a newly non-zero poll now
EndFunction

; ===================================================================== the poll

; Runs on the timer and out-of-band on MCM open, so the readout is never poll-stale.
Function RunCheck()
    Scene liveScene = PlayerRef.GetCurrentScene()

    if liveScene != currentScene
        ; scene changed -- retire the old one to history, adopt the new one
        if currentScene
            float dur = ElapsedInScene()
            PushHistory(currentScene, dur)
            if iLogLevel >= LOG_EVENTS
                Log(LOG_EVENTS, "scene leave scene=" + SceneKey(currentScene) + " name=" + QuietEdid(currentScene) + " el=" + (dur as int) + "s")
            endif
        endif
        currentScene = liveScene
        fSceneFirstSeen = Utility.GetCurrentRealTime()
        bAlerted = false
        if liveScene && iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "scene enter scene=" + SceneKey(liveScene) + " name=" + QuietEdid(liveScene) + " el=0s")
        endif
        return
    endif

    ; Only branch that can alert; gated on bEnabled so manual reads stay silent while dormant.
    if bEnabled && currentScene && !bAlerted && fAlertThreshold >= 1.0
        float elapsed = ElapsedInScene()
        if elapsed > fAlertThreshold && currentScene.IsPlaying()
            ; two short lines -- Skyrim shrinks a single long notification
            Debug.Notification("scene blocking others " + ElapsedLabel(elapsed))
            Debug.Notification("See? It Just Works!")
            bAlerted = true
            if iLogLevel >= LOG_EVENTS
                Log(LOG_EVENTS, "alert fire scene=" + SceneKey(currentScene) + " name=" + QuietEdid(currentScene) + " el=" + (elapsed as int) + "s thr=" + (fAlertThreshold as int) + "s sig=wall")
            endif
        endif
    endif
EndFunction

; Seconds in the current scene. Utility.GetCurrentRealTime() is session-relative and
; resets to ~0 each game launch, but fSceneFirstSeen persists in the save -- so after a
; save/reload while still in the same scene, the raw difference goes negative and the
; alert never fires (the marquee stuck-across-reload case). Detect the reset (now below
; the stored stamp) and re-baseline, restarting the stuck-timer from the reload. Always
; non-negative; identical to a plain subtraction when no reload happened. The re-baseline
; is a genuine self-correction, so it says so (from whichever caller trips it first).
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

; ============================================================ readout for MCM

Scene Function GetCurrentSceneRef()
    return currentScene
EndFunction

string Function GetSceneLabel()
    if !currentScene
        return "None"
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

; Loop-alive state, in calm words, for the Diagnostics readout. Returns a $-key the MCM
; localizes. "Waking up" covers the post-reload window (never ticked, or the real-time
; reset makes now < the stamp) so a fresh load never reads as a stall.
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

; The most recent genuine self-repair, as a $-key the MCM localizes, or "none" when
; the tool has never had to correct itself this save.
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

; True when po3 Tweaks is loading Editor IDs, probed via PlayerRef (which carries an
; edid only when loading is on). Scene-independent, so the MCM shows it as a status light.
bool Function EditorIdsLoading()
    if PO3_SKSEFunctions.GetFormEditorID(PlayerRef as Form) != ""
        return true
    endif
    return PO3_SKSEFunctions.GetFormEditorID(PlayerRef.GetActorBase() as Form) != ""  ; check the base too
EndFunction

; ======================================================== the hammer (from MCM)

; Stops the tracked scene. Returns true only once the ref goes None -- IsPlaying()
; isn't trusted here (it lies for stuck scenes).
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

; =========================================================== enable / hotkey (MCM)

; Master switch (Uninstall page). Off = dormant: loop + hotkey unregistered, no state
; lost, so On restores it exactly.
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

; Self-heal net, called on every MCM open: re-registers key + timer unconditionally,
; restoring anything a mod update or lost co-save dropped (both calls self-guard on
; bEnabled). A Quest can't catch OnPlayerLoadGame and we won't add an alias for it
; (that would force-persist the player), so the menu is the recovery point.
;
; No Ego: a blind re-register can't prove it fixed anything, so it only claims a heal
; when the heartbeat proves the loop was actually dead -- enabled, polling, and no tick
; within ~2x the poll interval. The post-reload window (now < the stamp) is excluded, or
; a fresh load would fabricate a recovery that never happened. Otherwise it's routine.
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
        Debug.Notification("In scene: " + LabelFor(s))
        if iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "hotkey name scene=" + SceneKey(s))
        endif
    else
        Debug.Notification("Not in a scene.")
        Log(LOG_EVENTS, "hotkey name scene=-")
    endif
EndEvent

; ========================================================================= util

Function PushHistory(Scene akScene, float afDuration)
    EnsureHist()
    int i = 9
    while i > 0
        histLabel[i] = histLabel[i - 1]
        i -= 1
    endwhile
    histLabel[0] = LabelFor(akScene) + "   " + ElapsedLabel(afDuration)
EndFunction

; Guarantees a usable 10-slot array. Bool-guarded so we never compare an array to None.
; A rebuild of an already-initialised ring (wrong length after another build) is a genuine
; self-correction; the first lazy build is benign setup.
Function EnsureHist()
    if !histReady
        histLabel = new string[10]
        histReady = true
        Log(LOG_CHECK, "life hist-init")
    elseif histLabel.Length != 10   ; heal a ring resized by another build
        int oldLen = histLabel.Length
        histLabel = new string[10]
        if iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "heal hist len_was=" + oldLen + " len_now=10")
        endif
        RecordCorrection("$fth_IJW_Heal_Hist")
    endif
EndFunction

; Editor ID when we have one; raw form ID otherwise (Load EditorIDs may be off). This is
; the DISPLAY path and may fire the one-time hint; log lines must NOT route through it --
; they use SceneKey/QuietEdid instead.
string Function LabelFor(Scene akScene)
    string edid = PO3_SKSEFunctions.GetFormEditorID(akScene as Form)
    if edid != ""
        return edid
    endif
    if !bEditorIdHinted
        bEditorIdHinted = true
        Debug.Notification("It Just Works: scenes show as ID numbers. Set Load EditorIDs = true in po3_Tweaks.ini for names.")
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

; =================================================================== logging

; The single sink. Emits "[fth_IJW] <line>" to the Papyrus log when the active level is
; at least aiLevel. Callers building a non-literal line gate at the call site first (so
; the string and any lookups aren't built below level -- Papyrus evaluates args eagerly);
; bare literal callers can rely on this check alone.
Function Log(int aiLevel, string asLine)
    if iLogLevel >= aiLevel
        Debug.Trace("[fth_IJW] " + asLine)
    endif
EndFunction

; Records the $-key of the last genuine self-heal for the readout. Never called for the
; routine, prove-nothing re-register (only real corrections).
Function RecordCorrection(string asKey)
    sLastCorrection = asKey
EndFunction

; Side-effect-free scene join key: "0x<formid>" or "-". Cheap native GetFormID, no edid,
; no hint -- safe on the per-poll hot path and as scene= everywhere in the log.
string Function SceneKey(Scene akScene)
    if !akScene
        return "-"
    endif
    return "0x" + HexOf(akScene.GetFormID())
EndFunction

; Side-effect-free editor id: the edid or "-" when names are off. Never fires the hint;
; for the rare Events lines only, never the per-poll heartbeat.
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

string Function HotkeyField()
    if iHotkeyCode >= 0
        return "" + iHotkeyCode
    endif
    return "off"
EndFunction
