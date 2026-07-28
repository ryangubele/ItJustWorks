; Copyright (c) 2026 Ryan Gubele
; SPDX-License-Identifier: MPL-2.0
;
; Scene watchdog: timer poll + advisory notification when elapsed exceeds warn.
;
; Elapsed = min(played, calendar) from save-relative endpoints (GetRealHoursPassed,
; GetCurrentGameTime / lowest positive TimeScale this episode). Witness only weakens.
; IsPlaying() is a delivery filter (stuck scenes stay "playing"). No OnPlayerLoadGame:
; single-update re-registers each tick; MCM re-arms on open.
; Logs: [fth_IJW], space-free. Gate non-literal Log args (eager eval); LogTerminal only
; under a literal LOG_CHECK test.

Scriptname fth_IJW_Watcher extends Quest

Actor Property PlayerRef Auto

; Skyrim.esm TimeScale (0x3A), ESP-filled; read live. Recovered by form lookup if unfilled.
GlobalVariable Property TimeScale Auto

int Property LOG_OFF    = 0 AutoReadOnly Hidden
int Property LOG_EVENTS = 1 AutoReadOnly Hidden
int Property LOG_CHECK  = 2 AutoReadOnly Hidden

; Live TimeScale for MCM (not episode accounting mode).
int Property RATE_UNKNOWN = 0 AutoReadOnly Hidden
int Property RATE_OK      = 1 AutoReadOnly Hidden
int Property RATE_LOW     = 2 AutoReadOnly Hidden
int Property RATE_FROZEN  = 3 AutoReadOnly Hidden
int Property RATE_MISSING = 4 AutoReadOnly Hidden
int Property RATE_INVALID = 5 AutoReadOnly Hidden

; First calendar-loss reason this episode (kept if the resolver later recovers).
int Property LOSS_NONE     = 0 AutoReadOnly Hidden
int Property LOSS_MISSING  = 1 AutoReadOnly Hidden
int Property LOSS_FROZEN   = 2 AutoReadOnly Hidden
int Property LOSS_INVALID  = 3 AutoReadOnly Hidden
int Property LOSS_BACKWARD = 4 AutoReadOnly Hidden

int Property STOP_NO_TARGET = 0 AutoReadOnly Hidden
int Property STOP_NO_PLAYER = 1 AutoReadOnly Hidden
int Property STOP_NO_SCENE  = 2 AutoReadOnly Hidden
int Property STOP_CHANGED   = 3 AutoReadOnly Hidden
int Property STOP_CLEARED   = 4 AutoReadOnly Hidden
int Property STOP_PLAYING   = 5 AutoReadOnly Hidden

; Defaults match settings.ini.
float  fPollInterval  = 30.0     ; seconds between polls; 0 disables the loop
float  fAlertThreshold = 360.0   ; elapsed seconds before the warning (warn minutes * 60); 0 = never
bool   bRealert = false          ; opt-in repeat warnings; off = one per scene
float  fRealertInterval = 300.0  ; elapsed seconds between repeats when bRealert
int    iLogLevel = 0             ; 0 Off / 1 Events / 2 Every check
bool   bLevity = true            ; flavored notification copy; off = plain
int    iToastLang = 0            ; notification language index; see fth_IJW_Toasts

; --- episode state (one live scene, both origins save-relative)
Scene  currentScene
float  fSceneStartPlayHours      ; Game.GetRealHoursPassed() when the scene was first seen
float  fSceneStartGameDays       ; Utility.GetCurrentGameTime() when the scene was first seen
float  fMinPosTsSeen             ; lowest positive TimeScale seen this episode; 0 = played-time only
bool   bTimingAnchorsInited      ; true after seed; zero floats are valid stamps
bool   bCalendarUsable           ; false latches for the rest of the episode
int    iCalLossReason            ; LOSS_*; preserved even if the live resolver heals
bool   bAlerted                  ; a warning has been delivered for this episode
float  fLastAlertElapsed         ; episode elapsed (seconds) at the last delivered warning
bool   bAlertHoldLogged          ; one Events line per continuous hold
bool   bAlertDeferLogged         ; one Events line per continuous defer
float  fLastElapsed = -1.0       ; last computed episode elapsed, for the MCM readout; -1 = none

; --- resolver / recovery (played-time backoff; no process clock)
int    iRateDiag                 ; RATE_*
int    iRecoverStage             ; 0..4
float  fRecoverLastTryPlayHours
bool   bRecoverTryInited
bool   bRecoverRequested         ; one-shot; cleared when an attempt begins

; --- loop health (played-time stamp; reload-safe)
; Verdicts: the calendar can be unusable in ways that are not "on time".
int Property LOOP_ONTIME  = 0 AutoReadOnly Hidden
int Property LOOP_LATE    = 1 AutoReadOnly Hidden
int Property LOOP_REWOUND = 2 AutoReadOnly Hidden   ; calendar moved back; rebaseline
int Property LOOP_SEED    = 3 AutoReadOnly Hidden   ; no game stamp yet; seed quietly
float  fLastArmPlayHours
float  fLastArmGameDays          ; menus advance played time but not the calendar
bool   bLoopStampInited
bool   bLoopGameStampInited      ; own bit: 0.0 is a valid stamp, so it cannot be a sentinel

; --- player
bool   bPlayerFaultLogged

; --- misc
bool   bEditorIdHinted           ; one-time Load EditorIDs hint
string sLastCorrection           ; $-key of last real self-heal, or ""
bool   bEnabled = true           ; master switch; off = dormant, episode cleared
int    iHotkeyCode = -1          ; DXScanCode, -1 unbound

; History ring, newest first. Built lazily -- OnInit does not re-run on load.
string[] histLabel
bool     histReady

; Endpoint-clock schema bit. False on a v0.6.0 save; drives the one-time migration.
bool   bEndpointSchemaInited

; --- lifecycle

Event OnInit()
    EnsureHist()
    string player = "ok"
    if !PlayerRef                     ; recover if the VMAD property fill came up empty
        if AcquirePlayer("init") == 2
            player = "recovered"
        else
            player = "fault"
        endif
    endif
    if !TimeScale                     ; packaging fault: ESP fill missing; bare Trace (not level-gated)
        Debug.Trace("[fth_IJW] FAULT timescale property unfilled -- calendar gate off (played-time only); rebuild the ESP")
    endif
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "life armed player=" + player + " hotkey=" + HotkeyField() + " warn=" + ((fAlertThreshold / 60.0) as int) + "m realert=" + BoolField(bRealert) + " ts=" + TsField() + " level=" + iLogLevel + " levity=" + BoolField(bLevity) + " lang=" + iToastLang)
    endif
    RegisterHotkey()
    Rearm()
    bEndpointSchemaInited = true      ; after setup; false bit means migrate path
EndEvent

Event OnUpdate()
    Rearm()                           ; before work so a RunCheck fault cannot drop the timer
    RunCheck("timer", true)
EndEvent

; Loop health reads the played-time arm stamp set here.
Function Rearm()
    UnregisterForUpdate()             ; re-registering a live one is undefined; no-op if none pending
    if bEnabled && fPollInterval >= 1.0
        RegisterForSingleUpdate(fPollInterval)
        fLastArmPlayHours = Game.GetRealHoursPassed()
        fLastArmGameDays = Utility.GetCurrentGameTime()
        bLoopStampInited = true
        bLoopGameStampInited = true
    endif
EndFunction

; --- upgrade

; v0.6.0 -> endpoint schema once per save (RunCheck/Stop/settings; OnInit skips loads).
; Clears legacy process-clock state. Safe to retry before the bit is set.
Function EnsureSchema()
    if bEndpointSchemaInited
        return
    endif
    UnregisterForUpdate()             ; drop any legacy registration before re-applying control
    currentScene = None
    ResetEpisode()
    bLoopStampInited = false
    bLoopGameStampInited = false
    fLastArmPlayHours = 0.0
    fLastArmGameDays = 0.0
    iRecoverStage = 0
    fRecoverLastTryPlayHours = 0.0
    bRecoverTryInited = false
    bRecoverRequested = false
    bPlayerFaultLogged = false
    iRateDiag = RATE_UNKNOWN
    EnsureHist()                      ; valid history is preserved; only a bad length is repaired
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "life migrate schema_was=v0.6.0-wallclock schema_now=v0.6.1-endpoint scene=cleared credit=0")
    endif
    RecordCorrection("$fth_IJW_Heal_Migrate")
    bEndpointSchemaInited = true      ; only after normalization succeeded
    RegisterHotkey()
    Rearm()
EndFunction

; --- settings and control

; 0 poll stops the loop; 0 warn disables warnings.
Function ApplySettings(int aiPollSeconds, int aiWarnMinutes, bool abRealert, int aiRealertMinutes, int aiLogLevel, bool abLevity, int aiToastLang)
    EnsureSchema()
    float newPoll = aiPollSeconds as float
    float newThr = (aiWarnMinutes * 60) as float
    float newRealertInt = (aiRealertMinutes * 60) as float
    bool pollChanged = (newPoll != fPollInterval)
    bool changed = pollChanged || (newThr != fAlertThreshold) || (abRealert != bRealert) || (newRealertInt != fRealertInterval) || (aiLogLevel != iLogLevel) || (abLevity != bLevity) || (aiToastLang != iToastLang)
    int oldPoll = fPollInterval as int
    int oldWarn = (fAlertThreshold / 60.0) as int
    bool oldRealert = bRealert
    int oldEvery = (fRealertInterval / 60.0) as int
    bool oldLevity = bLevity
    int oldLang = iToastLang
    bool wasArmed = bEnabled && fPollInterval >= 1.0
    int oldLevel = iLogLevel
    ; Log under the old level first (Events-off still records the change).
    if changed && iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "life settings poll_was=" + oldPoll + "s poll_now=" + aiPollSeconds + "s warn_was=" + oldWarn + "m warn_now=" + aiWarnMinutes + "m realert_was=" + BoolField(oldRealert) + " realert_now=" + BoolField(abRealert) + " every_was=" + oldEvery + "m every_now=" + aiRealertMinutes + "m level_was=" + oldLevel + " level_now=" + aiLogLevel + " levity_was=" + BoolField(oldLevity) + " levity_now=" + BoolField(abLevity) + " lang_was=" + oldLang + " lang_now=" + aiToastLang)
    endif
    iLogLevel = aiLogLevel
    if oldLevel < LOG_EVENTS && iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "life settings level_was=" + oldLevel + " level_now=" + iLogLevel + " logging=on")
    endif
    fPollInterval = newPoll
    fAlertThreshold = newThr
    bRealert = abRealert
    fRealertInterval = newRealertInt
    bLevity = abLevity
    iToastLang = aiToastLang
    bool nowArmed = bEnabled && fPollInterval >= 1.0
    ; Poll 0: Unregister (skipping re-arm alone leaves one OnUpdate pending).
    if wasArmed && !nowArmed
        EndObservedEpisode("poll_off")
    elseif nowArmed
        if pollChanged
            Rearm()
        endif
    else
        UnregisterForUpdate()
    endif
EndFunction

; Master on and polling (MCM uses this for armed-boundary crossings).
bool Function IsArmed()
    return bEnabled && fPollInterval >= 1.0
EndFunction

Function SetEnabled(bool abEnabled)
    EnsureSchema()
    if abEnabled == bEnabled
        return
    endif
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "life enabled_was=" + BoolField(bEnabled) + " enabled_now=" + BoolField(abEnabled))
    endif
    bEnabled = abEnabled
    if bEnabled
        RegisterHotkey()
        Rearm()
    else
        EndObservedEpisode("master_off")
        UnregisterHotkey()
    endif
EndFunction

; Unregister and clear the live episode. History keeps completed rows only.
Function EndObservedEpisode(string asReason)
    UnregisterForUpdate()
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "life episode-end reason=" + asReason + " scene=" + SceneKey(currentScene))
    endif
    currentScene = None
    ResetEpisode()
    bLoopStampInited = false
EndFunction

; Clear per-episode timing, witness, cadence, and latches. Caller owns scene id;
; history and settings stay.
Function ResetEpisode()
    fSceneStartPlayHours = 0.0
    fSceneStartGameDays = 0.0
    fMinPosTsSeen = 0.0
    bTimingAnchorsInited = false
    bCalendarUsable = false
    iCalLossReason = LOSS_NONE
    bAlerted = false
    fLastAlertElapsed = 0.0
    bAlertHoldLogged = false
    bAlertDeferLogged = false
    fLastElapsed = -1.0
EndFunction

; --- evaluator

; source: timer | mcm | stop. mayNotify: timer only.
Function RunCheck(string asSource, bool abMayNotify)
    EnsureSchema()
    float nowPlay = Game.GetRealHoursPassed()

    ; --- master / poll: exit before player or scene work
    if !bEnabled
        if iLogLevel >= LOG_CHECK
            LogTerminal(asSource, None, 0, iRateDiag, "-", -1.0, -1.0, -1.0, "-", -1, "none", "frozen", "master_off")
        endif
        return
    endif
    if fPollInterval < 1.0
        if iLogLevel >= LOG_CHECK
            LogTerminal(asSource, None, 0, iRateDiag, "-", -1.0, -1.0, -1.0, "-", -1, "none", "frozen", "poll_off")
        endif
        return
    endif

    ; --- player
    int acquired = AcquirePlayer(asSource)
    if acquired == 0
        if iLogLevel >= LOG_CHECK
            LogTerminal(asSource, currentScene, 0, iRateDiag, "player_fault", -1.0, -1.0, -1.0, "-", -1, "none", "player_fault", "-")
        endif
        return
    endif

    ; --- scene identity
    Scene liveScene = PlayerRef.GetCurrentScene()
    if liveScene != currentScene
        HandleTransition(asSource, liveScene, nowPlay)
        return
    endif
    if !currentScene
        if iLogLevel >= LOG_CHECK
            LogTerminal(asSource, None, 0, iRateDiag, "-", -1.0, -1.0, -1.0, "-", -1, "none", "frozen", "no_scene")
        endif
        return
    endif

    ; --- rate resolve
    float ts = ResolveTimeScale(asSource, nowPlay)

    ; --- played time stepped backward (edit/corrupt)
    if bTimingAnchorsInited && nowPlay < fSceneStartPlayHours
        PlayReseed(asSource, nowPlay, ts)
        return
    endif
    if !bTimingAnchorsInited            ; defensive: a live scene with no origins
        SeedEpisode(nowPlay, ts)
        if iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "timing seed scene=" + SceneKey(currentScene) + " cause=no-anchors mode=" + ModeField(ModeNow()) + " reason=" + ReasonField())
        endif
        if iLogLevel >= LOG_CHECK
            LogTerminal(asSource, currentScene, ModeNow(), iRateDiag, "seed", 0.0, 0.0, 0.0, "play", -1, "none", "none", "-")
        endif
        return
    endif

    ; --- witness: weaken only
    float nowGame = Utility.GetCurrentGameTime()
    if bCalendarUsable
        if ts > 0.0
            if ts < fMinPosTsSeen
                if iLogLevel >= LOG_EVENTS
                    Log(LOG_EVENTS, "rate_min_lowered scene=" + SceneKey(currentScene) + " from=" + FloatField(fMinPosTsSeen) + " to=" + FloatField(ts))
                endif
                fMinPosTsSeen = ts
            endif
        else
            LoseWitness(LossForRate(ts))
        endif
    endif
    if bCalendarUsable && nowGame < fSceneStartGameDays
        LoseWitness(LOSS_BACKWARD)
    endif
    if bCalendarUsable && fMinPosTsSeen <= 0.0
        ; usable flag requires a positive normalizer
        if iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "heal invariant scene=" + SceneKey(currentScene) + " witness=1 min=" + FloatField(fMinPosTsSeen) + " action=latch-play-only")
        endif
        RecordCorrection("$fth_IJW_Heal_Timing")
        LoseWitness(LOSS_INVALID)
    endif

    ; --- endpoint elapsed
    float elapsedPlay = (nowPlay - fSceneStartPlayHours) * 3600.0
    if elapsedPlay < 0.0
        elapsedPlay = 0.0
    endif
    float elapsedGame = -1.0
    float elapsed = elapsedPlay
    string bind = "play"
    if bCalendarUsable
        elapsedGame = (nowGame - fSceneStartGameDays) * 86400.0 / fMinPosTsSeen
        if elapsedGame < 0.0
            elapsedGame = 0.0
        endif
        if elapsedGame < elapsedPlay
            elapsed = elapsedGame
            bind = "game"
        endif
    endif
    fLastElapsed = elapsed

    ; --- eligibility
    string due = "none"
    string outcome = "none"
    if fAlertThreshold < 1.0
        outcome = "threshold_disabled"
    else
        float repeatInterval = 0.0
        if bRealert
            repeatInterval = fRealertInterval
        endif
        if !bAlerted && elapsed >= fAlertThreshold
            due = "first"
        elseif bAlerted && repeatInterval > 0.0 && (elapsed - fLastAlertElapsed) >= repeatInterval
            due = "repeat"
        endif
    endif

    ; --- delivery (IsPlaying only if due)
    int playingField = -1
    if due != "none"
        bool playing = currentScene.IsPlaying()
        playingField = BoolField2(playing)
        if !playing
            outcome = "hold"
        elseif !abMayNotify
            outcome = "deferred"
        else
            FireAlert(due, elapsed, elapsedPlay, elapsedGame, ts)
            outcome = "fire"
        endif
    endif
    UpdateAlertLatches(outcome, elapsed, elapsedPlay, elapsedGame)

    string sample = "endpoint"
    if acquired == 2
        sample = "player_recovered"
    endif
    if iLogLevel >= LOG_CHECK
        LogTerminal(asSource, currentScene, ModeNow(), iRateDiag, sample, elapsedPlay, elapsedGame, elapsed, bind, playingField, due, outcome, ReasonField())
    endif
EndFunction

; Outgoing: terminal check + history. Incoming: Events seed only.
Function HandleTransition(string asSource, Scene akLive, float afNowPlay)
    bool ownsTerminal = false
    if currentScene
        ; Endpoints at the check that saw the leave. History, readout and warn all use min().
        float outPlay = -1.0
        float outGame = -1.0
        float outElapsed = -1.0
        string outBind = "-"
        if bTimingAnchorsInited
            outPlay = (afNowPlay - fSceneStartPlayHours) * 3600.0
            if outPlay < 0.0
                outPlay = 0.0
            endif
            outElapsed = outPlay
            outBind = "play"
            if bCalendarUsable && fMinPosTsSeen > 0.0
                float outNowGame = Utility.GetCurrentGameTime()
                if outNowGame < fSceneStartGameDays
                    LoseWitness(LOSS_BACKWARD)
                else
                    outGame = (outNowGame - fSceneStartGameDays) * 86400.0 / fMinPosTsSeen
                    if outGame < outPlay
                        outElapsed = outGame
                        outBind = "game"
                    endif
                endif
            endif
            PushHistory(currentScene, outElapsed)
        endif
        if iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "scene leave scene=" + SceneKey(currentScene) + " name=" + QuietEdid(currentScene) + " play=" + SecField(outPlay) + " elapsed=" + SecField(outElapsed))
        endif
        string outOutcome = "none"
        string outReason = ReasonField()
        if !akLive
            outOutcome = "frozen"
            outReason = "no_scene"
        endif
        ownsTerminal = true
        if iLogLevel >= LOG_CHECK
            LogTerminal(asSource, currentScene, ModeNow(), iRateDiag, "scene_transition", outPlay, outGame, outElapsed, outBind, -1, "none", outOutcome, outReason)
        endif
    endif

    currentScene = akLive
    ResetEpisode()

    if !akLive
        if !ownsTerminal
            if iLogLevel >= LOG_CHECK
                LogTerminal(asSource, None, 0, iRateDiag, "-", -1.0, -1.0, -1.0, "-", -1, "none", "frozen", "no_scene")
            endif
        endif
        return
    endif

    SeedEpisode(afNowPlay, ResolveTimeScale(asSource, afNowPlay))
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "scene enter scene=" + SceneKey(akLive) + " name=" + QuietEdid(akLive) + " mode=" + ModeField(ModeNow()) + " reason=" + ReasonField())
    endif
    if !ownsTerminal
        if iLogLevel >= LOG_CHECK
            LogTerminal(asSource, akLive, ModeNow(), iRateDiag, "seed", 0.0, 0.0, 0.0, "play", -1, "none", "none", ReasonField())
        endif
    endif
EndFunction

; Anchor both endpoints. Non-positive rate at seed -> played-time only + reason for MCM.
Function SeedEpisode(float afNowPlay, float afTs)
    fSceneStartPlayHours = afNowPlay
    fSceneStartGameDays = Utility.GetCurrentGameTime()
    bTimingAnchorsInited = true
    bAlerted = false
    fLastAlertElapsed = 0.0
    bAlertHoldLogged = false
    bAlertDeferLogged = false
    fLastElapsed = 0.0
    if afTs > 0.0
        fMinPosTsSeen = afTs
        bCalendarUsable = true
        iCalLossReason = LOSS_NONE
    else
        fMinPosTsSeen = 0.0
        bCalendarUsable = false
        iCalLossReason = LossForRate(afTs)
    endif
EndFunction

; Played time stepped backward (edit/corrupt). Re-anchor; keep any prior calendar loss.
Function PlayReseed(string asSource, float afNowPlay, float afTs)
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "heal play-reseed scene=" + SceneKey(currentScene) + " was=" + FloatField(fSceneStartPlayHours) + "h now=" + FloatField(afNowPlay) + "h")
    endif
    RecordCorrection("$fth_IJW_Heal_Rebaseline")
    bool keepWitness = bCalendarUsable
    int keepReason = iCalLossReason
    float keepMin = fMinPosTsSeen
    fSceneStartPlayHours = afNowPlay
    fSceneStartGameDays = Utility.GetCurrentGameTime()
    bTimingAnchorsInited = true
    bAlerted = false
    fLastAlertElapsed = 0.0
    bAlertHoldLogged = false
    bAlertDeferLogged = false
    fLastElapsed = 0.0
    bCalendarUsable = keepWitness
    iCalLossReason = keepReason
    fMinPosTsSeen = keepMin
    if bCalendarUsable
        if afTs > 0.0
            if afTs < fMinPosTsSeen
                fMinPosTsSeen = afTs
            endif
        else
            LoseWitness(LossForRate(afTs))
        endif
    endif
    if iLogLevel >= LOG_CHECK
        LogTerminal(asSource, currentScene, ModeNow(), iRateDiag, "play_reseed", 0.0, 0.0, 0.0, "play", -1, "none", "none", ReasonField())
    endif
EndFunction

; Latch played-time only once; keep the first loss reason for MCM.
Function LoseWitness(int aiReason)
    if !bCalendarUsable
        return
    endif
    bCalendarUsable = false
    fMinPosTsSeen = 0.0
    iCalLossReason = aiReason
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "calendar_witness_lost scene=" + SceneKey(currentScene) + " reason=" + ReasonField())
    endif
EndFunction

; Separate hold/defer Events latches; set with the line.
Function UpdateAlertLatches(string asOutcome, float afElapsed, float afPlay, float afGame)
    if asOutcome == "hold"
        if !bAlertHoldLogged && iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "alert hold scene=" + SceneKey(currentScene) + " elapsed=" + SecField(afElapsed) + " play=" + SecField(afPlay) + " game=" + SecField(afGame) + " why=not-playing")
            bAlertHoldLogged = true
        endif
    else
        bAlertHoldLogged = false
    endif
    if asOutcome == "deferred"
        if !bAlertDeferLogged && iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "alert defer scene=" + SceneKey(currentScene) + " elapsed=" + SecField(afElapsed) + " why=no-notify-source")
            bAlertDeferLogged = true
        endif
    else
        bAlertDeferLogged = false
    endif
EndFunction

; asDue is first|repeat for the Events line.
Function FireAlert(string asDue, float afElapsed, float afPlay, float afGame, float afTs)
    Debug.Notification(fth_IJW_Toasts.Alert(iToastLang) + " " + ElapsedLabel(afElapsed))
    if bLevity
        Debug.Notification("See? It Just Works!")   ; Levity punchline stays English
    endif
    bAlerted = true
    fLastAlertElapsed = afElapsed
    bAlertHoldLogged = false
    bAlertDeferLogged = false
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "alert fire due=" + asDue + " scene=" + SceneKey(currentScene) + " name=" + QuietEdid(currentScene) + " elapsed=" + SecField(afElapsed) + " play=" + SecField(afPlay) + " game=" + SecField(afGame) + " ts=" + FloatField(afTs))
    endif
EndFunction

; --- TimeScale resolver

; Live TimeScale or 0.0; at most one recovery try. Episode witness unchanged.
float Function ResolveTimeScale(string asSource, float afNowPlay)
    if !TimeScale
        TryRecoverRate(asSource, afNowPlay)
    endif
    if !TimeScale
        SetRateDiag(RATE_MISSING)
        return 0.0
    endif
    float v = TimeScale.GetValue()
    if v < 0.0
        SetRateDiag(RATE_INVALID)
    elseif v == 0.0
        SetRateDiag(RATE_FROZEN)
    elseif v < 1.0
        SetRateDiag(RATE_LOW)          ; informative only -- every positive value is usable
    else
        SetRateDiag(RATE_OK)
    endif
    return v
EndFunction

; Form/plugin re-lookup on played-time exponential backoff. MCM can skip one wait; min gap 5s.
Function TryRecoverRate(string asSource, float afNowPlay)
    if bRecoverTryInited && afNowPlay < fRecoverLastTryPlayHours
        if iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "heal recover-stamp was=" + FloatField(fRecoverLastTryPlayHours) + "h now=" + FloatField(afNowPlay) + "h action=clear")
        endif
        RecordCorrection("$fth_IJW_Heal_Rebaseline")
        bRecoverTryInited = false
    endif
    float sinceSec = 0.0
    if bRecoverTryInited
        sinceSec = (afNowPlay - fRecoverLastTryPlayHours) * 3600.0
    endif
    float delay = fPollInterval * Math.pow(2.0, iRecoverStage as float)
    if delay < 5.0
        delay = 5.0
    endif
    bool mayTry = !bRecoverTryInited || (sinceSec >= delay)
    if !mayTry && bRecoverRequested && sinceSec >= 5.0
        mayTry = true
    endif
    if !mayTry
        return
    endif
    bool forced = bRecoverRequested
    bRecoverRequested = false          ; one-shot: consumed the moment an attempt begins
    GlobalVariable found = Game.GetFormFromFile(0x0000003A, "Skyrim.esm") as GlobalVariable
    if found
        TimeScale = found
        iRecoverStage = 0
        bRecoverTryInited = false
        if iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "heal rate-recovered source=" + asSource + " forced=" + BoolField(forced))
        endif
        RecordCorrection("$fth_IJW_Heal_Rate")
        return
    endif
    fRecoverLastTryPlayHours = afNowPlay
    bRecoverTryInited = true
    if iRecoverStage < 4
        iRecoverStage += 1
    endif
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "heal rate-retry-failed source=" + asSource + " forced=" + BoolField(forced) + " stage=" + iRecoverStage)
    endif
EndFunction

; MCM open/refresh: one backoff bypass when TimeScale is still unfilled.
Function RequestRateRetry()
    if TimeScale
        return
    endif
    bRecoverRequested = true
    Log(LOG_CHECK, "heal rate-retry-requested")
EndFunction

Function SetRateDiag(int aiDiag)
    iRateDiag = aiDiag
EndFunction

; --- player

; 0 unresolved / 1 valid / 2 repaired.
int Function AcquirePlayer(string asSource)
    if PlayerRef
        return 1
    endif
    Actor p = Game.GetPlayer()
    if !p
        if !bPlayerFaultLogged
            if iLogLevel >= LOG_EVENTS
                Log(LOG_EVENTS, "player fault source=" + asSource + " GetPlayer=none")
            endif
            bPlayerFaultLogged = true
        endif
        return 0
    endif
    PlayerRef = p
    bPlayerFaultLogged = false
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "heal player source=" + asSource + " via=GetPlayer")
    endif
    RecordCorrection("$fth_IJW_Heal_Player")
    return 2
EndFunction

; --- MCM readout

; Live scene via AcquirePlayer (not the tracked episode scene).
Scene Function GetLiveSceneRef()
    if AcquirePlayer("mcm") == 0
        return None
    endif
    return PlayerRef.GetCurrentScene()
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
    if !currentScene || fLastElapsed < 0.0
        return "--"
    endif
    return ElapsedLabel(fLastElapsed)
EndFunction

; Episode accounting mode for MCM (not live property). Unchanged until a new scene.
string Function GetRateStatus()
    if !bEnabled || fPollInterval < 1.0 || !currentScene || !bTimingAnchorsInited
        return "--"
    endif
    if bCalendarUsable
        return "$fth_IJW_Rate_Dual"
    endif
    if iCalLossReason == LOSS_FROZEN
        return "$fth_IJW_Rate_Frozen"
    elseif iCalLossReason == LOSS_INVALID
        return "$fth_IJW_Rate_Invalid"
    elseif iCalLossReason == LOSS_BACKWARD
        return "$fth_IJW_Rate_Backward"
    endif
    return "$fth_IJW_Rate_Missing"
EndFunction

string[] Function GetHistoryLabels()
    EnsureHist()
    return histLabel
EndFunction

; Late needs both arms over the limit; played alone would flag any long menu.
; No usable rate -> played decides. Rate changes mid-gap skew it; advisory.
int Function LoopGapVerdict(float afNowPlay, float afLimitSec)
    if ((afNowPlay - fLastArmPlayHours) * 3600.0) <= afLimitSec
        return LOOP_ONTIME
    endif
    if !bLoopGameStampInited
        return LOOP_SEED
    endif
    float ts = 0.0
    if TimeScale
        ts = TimeScale.GetValue()
    endif
    if ts <= 0.0
        return LOOP_LATE
    endif
    float nowGame = Utility.GetCurrentGameTime()
    if nowGame < fLastArmGameDays
        return LOOP_REWOUND
    endif
    if ((nowGame - fLastArmGameDays) * 86400.0 / ts) > afLimitSec
        return LOOP_LATE
    endif
    return LOOP_ONTIME
EndFunction

; Loop status $-key on played time (reload-safe). Backward stamp: clear and re-arm.
string Function GetLoopStatus()
    if !bEnabled
        return "$fth_IJW_Loop_Dormant"
    endif
    if fPollInterval < 1.0
        return "$fth_IJW_Loop_Off"
    endif
    if !bLoopStampInited
        return "$fth_IJW_Loop_Waking"
    endif
    float now = Game.GetRealHoursPassed()
    if now < fLastArmPlayHours
        if iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "heal loop-stamp was=" + FloatField(fLastArmPlayHours) + "h now=" + FloatField(now) + "h action=rearm")
        endif
        RecordCorrection("$fth_IJW_Heal_Rebaseline")
        bLoopStampInited = false
        Rearm()
        return "$fth_IJW_Loop_Waking"
    endif
    int verdict = LoopGapVerdict(now, fPollInterval * 2.0 + 5.0)
    if verdict == LOOP_SEED
        Rearm()
        return "$fth_IJW_Loop_Waking"
    endif
    if verdict == LOOP_REWOUND
        if iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "heal loop-stamp calendar=rewound was=" + FloatField(fLastArmGameDays) + "d action=rearm")
        endif
        RecordCorrection("$fth_IJW_Heal_Rebaseline")
        bLoopStampInited = false
        Rearm()
        return "$fth_IJW_Loop_Waking"
    endif
    if verdict == LOOP_ONTIME
        return "$fth_IJW_Loop_Running"
    endif
    return "$fth_IJW_Loop_Late"
EndFunction

string Function GetLastCorrection()
    if sLastCorrection == ""
        return "$fth_IJW_Heal_None"
    endif
    return sLastCorrection
EndFunction

; po3 Load EditorIDs on? Probe player (and base); false if no player.
bool Function EditorIdsLoading()
    if AcquirePlayer("mcm") == 0
        return false
    endif
    if PO3_SKSEFunctions.GetFormEditorID(PlayerRef as Form) != ""
        return true
    endif
    return PO3_SKSEFunctions.GetFormEditorID(PlayerRef.GetActorBase() as Form) != ""
EndFunction

; --- Stop Scene

; MCM arm/cancel (watcher owns the Events sink).
Function LogStopArm(Scene akTarget, bool abArmed)
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "alert stop-arm scene=" + SceneKey(akTarget) + " name=" + QuietEdid(akTarget) + " armed=" + BoolField(abArmed))
    endif
EndFunction

; Stop only if live scene still matches the armed ref; otherwise refuse.
int Function StopScene(Scene akTarget)
    EnsureSchema()
    if !akTarget
        return STOP_NO_TARGET
    endif
    if AcquirePlayer("stop") == 0
        return STOP_NO_PLAYER
    endif
    Scene live = PlayerRef.GetCurrentScene()
    if !live
        if iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "alert stop-reject target=" + SceneKey(akTarget) + " live=- why=no-scene")
        endif
        return STOP_NO_SCENE
    endif
    if live != akTarget
        if iLogLevel >= LOG_EVENTS
            Log(LOG_EVENTS, "alert stop-reject target=" + SceneKey(akTarget) + " live=" + SceneKey(live) + " why=changed")
        endif
        return STOP_CHANGED
    endif
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "alert stop-req scene=" + SceneKey(akTarget))
    endif
    akTarget.Stop()
    ; Clearance = engine no longer returns the scene (IsPlaying can lie). 4 tries @ 0.25s.
    bool cleared = false
    int tries = 0
    while tries < 4 && !cleared
        Utility.Wait(0.25)
        cleared = PlayerRef.GetCurrentScene() != akTarget
        tries += 1
    endwhile
    if iLogLevel >= LOG_EVENTS
        Log(LOG_EVENTS, "alert stop-result scene=" + SceneKey(akTarget) + " cleared=" + BoolField(cleared) + " tries=" + tries)
    endif
    RunCheck("stop", false)            ; refresh tracked state now, without consuming a warning
    if cleared
        return STOP_CLEARED
    endif
    return STOP_PLAYING
EndFunction

; --- enable / hotkey

; -1 clears. Watcher registers the key; MCM stores the code.
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

Function UnregisterHotkey()
    if iHotkeyCode >= 0
        UnregisterForKey(iHotkeyCode)
    endif
EndFunction

; MCM open: re-register key + timer. Heal late gap; rearm last.
Function ReassertRegistrations()
    EnsureSchema()
    if bEnabled && fPollInterval >= 1.0 && bLoopStampInited
        float now = Game.GetRealHoursPassed()
        float gapSec = (now - fLastArmPlayHours) * 3600.0
        ; Backward stamp before Rearm (rearm overwrites the evidence).
        if now < fLastArmPlayHours
            if iLogLevel >= LOG_EVENTS
                Log(LOG_EVENTS, "heal loop-stamp was=" + FloatField(fLastArmPlayHours) + "h now=" + FloatField(now) + "h action=rearm source=reassert")
            endif
            RecordCorrection("$fth_IJW_Heal_Rebaseline")
            bLoopStampInited = false
        else
            int verdict = LoopGapVerdict(now, fPollInterval * 2.0 + 5.0)
            if verdict == LOOP_REWOUND
                if iLogLevel >= LOG_EVENTS
                    Log(LOG_EVENTS, "heal loop-stamp calendar=rewound was=" + FloatField(fLastArmGameDays) + "d action=rearm source=reassert")
                endif
                RecordCorrection("$fth_IJW_Heal_Rebaseline")
                bLoopStampInited = false
            elseif verdict == LOOP_LATE
                if iLogLevel >= LOG_EVENTS
                    Log(LOG_EVENTS, "heal reassert dropped=1 gap=" + SecField(gapSec))
                endif
                RecordCorrection("$fth_IJW_Heal_Reassert")
            else
                Log(LOG_CHECK, "heal reassert routine")     ; on time, or seeding a stamp this build added
            endif
        endif
    else
        Log(LOG_CHECK, "heal reassert routine")
    endif
    RegisterHotkey()
    Rearm()
EndFunction

Event OnKeyDown(int aiKeyCode)
    if aiKeyCode != iHotkeyCode || !bEnabled || UI.IsMenuOpen("Console")
        return
    endif
    if AcquirePlayer("hotkey") == 0
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

; Display edid or form id; may one-shot names-off. Logs use SceneKey/QuietEdid.
string Function LabelFor(Scene akScene)
    string edid = PO3_SKSEFunctions.GetFormEditorID(akScene as Form)
    if edid != ""
        return edid
    endif
    if !bEditorIdHinted
        bEditorIdHinted = true
        Debug.Notification(fth_IJW_Toasts.NamesOff(iToastLang))
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

; Loss reason for a non-positive rate. Missing property is also 0.0 -- check property first.
int Function LossForRate(float afTs)
    if !TimeScale
        return LOSS_MISSING
    endif
    if afTs < 0.0
        return LOSS_INVALID
    endif
    return LOSS_FROZEN
EndFunction

; Current episode accounting mode: 0 none, 1 dual, 2 played-time only.
int Function ModeNow()
    if !currentScene || !bTimingAnchorsInited
        return 0
    endif
    if bCalendarUsable
        return 1
    endif
    return 2
EndFunction

; --- logging

; Gate non-literal args at the call site (eager eval).
Function Log(int aiLevel, string asLine)
    if iLogLevel >= aiLevel
        Debug.Trace("[fth_IJW] " + asLine)
    endif
EndFunction

; Every-check terminal line. Call only under a literal LOG_CHECK test.
; Sentinels: float < 0, aiPlaying -1, aiMode 0 -> "-".
Function LogTerminal(string asSource, Scene akScene, int aiMode, int aiDiag, string asSample, float afPlay, float afGame, float afElapsed, string asBind, int aiPlaying, string asDue, string asOutcome, string asReason)
    Debug.Trace("[fth_IJW] check source=" + asSource + " scene=" + SceneKey(akScene) + " mode=" + ModeField(aiMode) + " diag=" + DiagField(aiDiag) + " sample=" + asSample + " play=" + SecField(afPlay) + " game=" + SecField(afGame) + " elapsed=" + SecField(afElapsed) + " bind=" + asBind + " playing=" + TriField(aiPlaying) + " due=" + asDue + " outcome=" + asOutcome + " reason=" + asReason)
EndFunction

Function RecordCorrection(string asKey)
    sLastCorrection = asKey
EndFunction

string Function SceneKey(Scene akScene)
    if !akScene
        return "-"
    endif
    return "0x" + HexOf(akScene.GetFormID())
EndFunction

; No names-off toast (unlike LabelFor).
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

string Function BoolField(bool ab)
    if ab
        return "1"
    endif
    return "0"
EndFunction

int Function BoolField2(bool ab)
    if ab
        return 1
    endif
    return 0
EndFunction

string Function TriField(int aiValue)
    if aiValue < 0
        return "-"
    endif
    if aiValue == 0
        return "false"
    endif
    return "true"
EndFunction

string Function SecField(float afSeconds)
    if afSeconds < 0.0
        return "-"
    endif
    return (afSeconds as int) + "s"
EndFunction

; Locale-free two decimals (no StringUtil.Format).
string Function FloatField(float afValue)
    int whole = afValue as int
    int frac = ((afValue - (whole as float)) * 100.0) as int
    if frac < 0
        frac = -frac
    endif
    if frac < 10
        return whole + ".0" + frac
    endif
    return whole + "." + frac
EndFunction

string Function ModeField(int aiMode)
    if aiMode == 1
        return "dual"
    endif
    if aiMode == 2
        return "play_only"
    endif
    return "-"
EndFunction

string Function DiagField(int aiDiag)
    if aiDiag == RATE_OK
        return "ok"
    elseif aiDiag == RATE_LOW
        return "low"
    elseif aiDiag == RATE_FROZEN
        return "frozen"
    elseif aiDiag == RATE_MISSING
        return "missing"
    elseif aiDiag == RATE_INVALID
        return "invalid"
    endif
    return "unknown"
EndFunction

string Function ReasonField()
    if iCalLossReason == LOSS_MISSING
        return "rate_missing"
    elseif iCalLossReason == LOSS_FROZEN
        return "rate_frozen"
    elseif iCalLossReason == LOSS_INVALID
        return "rate_invalid"
    elseif iCalLossReason == LOSS_BACKWARD
        return "game_backward"
    endif
    return "-"
EndFunction

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
