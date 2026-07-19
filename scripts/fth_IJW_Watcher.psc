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

Scriptname fth_IJW_Watcher extends Quest

Actor Property PlayerRef Auto

; Settings, pushed from the MCM; defaults match settings.ini.
float  fPollInterval  = 30.0     ; seconds between polls; 0 disables the loop
float  fAlertThreshold = 180.0   ; seconds in-scene before alerting; 0 = never
bool   bTrace = false            ; mirror every transition into the Papyrus log

; Tracked state, persisted with the save.
Scene  currentScene
float  fSceneFirstSeen
bool   bAlerted
bool   bEditorIdHinted           ; nag once about Load EditorIDs

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
    if !PlayerRef                 ; recover if the VMAD property fill came up empty
        PlayerRef = Game.GetPlayer()
    endif
    Trace("OnInit -- watcher armed")
    RegisterHotkey()
    Rearm()
EndEvent

Event OnUpdate()
    if !bEnabled                  ; stray timer after we went dormant
        return
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

; Pushed by the MCM. 0 poll stops the loop; 0 warn disables alerting.
Function ApplySettings(int aiPollSeconds, int aiWarnMinutes, bool abTrace)
    fPollInterval = aiPollSeconds as float
    fAlertThreshold = (aiWarnMinutes * 60) as float
    bTrace = abTrace
    Rearm()                       ; pick up a newly non-zero poll now
EndFunction

; ===================================================================== the poll

; Runs on the timer and out-of-band on MCM open, so the readout is never poll-stale.
Function RunCheck()
    Scene liveScene = PlayerRef.GetCurrentScene()

    if liveScene != currentScene
        ; scene changed -- retire the old one to history, adopt the new one
        if currentScene
            PushHistory(currentScene, ElapsedInScene())
        endif
        currentScene = liveScene
        fSceneFirstSeen = Utility.GetCurrentRealTime()
        bAlerted = false
        if liveScene
            Trace("enter scene " + LabelFor(liveScene))
        else
            Trace("left scene -- none")
        endif
        return
    endif

    ; Only branch that can alert; gated on bEnabled so manual reads stay silent while dormant.
    if bEnabled && currentScene && !bAlerted && fAlertThreshold >= 1.0
        float elapsed = ElapsedInScene()
        if elapsed > fAlertThreshold && currentScene.IsPlaying()
            ; two short lines -- Skyrim shrinks a single long notification
            Debug.Notification("In a scene " + ElapsedLabel(elapsed) + "; blocking others.")
            Debug.Notification("See? It Just Works!")
            bAlerted = true
            Trace("ALERT fired for " + LabelFor(currentScene) + " at " + ElapsedLabel(elapsed))
        endif
    endif
EndFunction

; Seconds in the current scene. Utility.GetCurrentRealTime() is session-relative and
; resets to ~0 each game launch, but fSceneFirstSeen persists in the save -- so after a
; save/reload while still in the same scene, the raw difference goes negative and the
; alert never fires (the marquee stuck-across-reload case). Detect the reset (now below
; the stored stamp) and re-baseline, restarting the stuck-timer from the reload. Always
; non-negative; identical to a plain subtraction when no reload happened.
float Function ElapsedInScene()
    float now = Utility.GetCurrentRealTime()
    if now < fSceneFirstSeen
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
    Trace("STOP requested for " + LabelFor(victim))
    victim.Stop()
    Utility.Wait(0.25)
    bool cleared = PlayerRef.GetCurrentScene() != victim
    Trace("STOP result cleared=" + cleared + " -- watching one minute for cascade")
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
        Trace("enabled")
    else
        UnregisterForUpdate()    ; kill any pending timer
        UnregisterHotkey()
        Trace("disabled -- dormant")
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
Function ReassertRegistrations()
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
    else
        Debug.Notification("Not in a scene.")
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
Function EnsureHist()
    if !histReady
        histLabel = new string[10]
        histReady = true
    elseif histLabel.Length != 10   ; heal a ring resized by another build
        histLabel = new string[10]
    endif
EndFunction

; Editor ID when we have one; raw form ID otherwise (Load EditorIDs may be off).
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

; Low-precision duration: seconds under 90s, whole minutes above.
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

Function Trace(string asMsg)
    if bTrace
        Debug.Trace("[fth_IJW] " + asMsg)
    endif
EndFunction
