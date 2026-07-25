# Copyright (c) 2026 Ryan Gubele
# SPDX-License-Identifier: MPL-2.0
#
# mutagen -> papyrus -> scrub -> assemble -> metadata -> verify gate -> zip.
# Every step that emits a version reads it from VERSION; never a literal.
#
# This script writes no git history -- that's the operator's to make. It does *read* HEAD's
# commit date (clean tree only) to stamp stable, commit-dated .pex timestamps; git is a soft,
# read-only dependency for that and nothing else.

[CmdletBinding()]
param(
    [string]$GameRoot = "",  # install root; else $env:SKYRIM_SE_PATH; else auto-detected
    [string]$Website = "https://www.nexusmods.com/skyrimspecialedition/mods/185927",  # Nexus mod page; stamped into fomod/info.xml
    [string]$Repo = "https://github.com/ryangubele/ItJustWorks",  # source repo, stamped into the license breadcrumb; override for forks
    [string]$Author = "Ryan Gubele",  # lead copyright holder in the license breadcrumb; override for a fork or on handover
    [switch]$SkipSanitization   # outside builders with no identity of ours to strip
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$root = $PSScriptRoot
Set-Location $root

function Fail($msg) { Write-Host "BUILD FAILED: $msg" -ForegroundColor Red; exit 1 }
function Step($n, $msg) { Write-Host "`n[$n] $msg" -ForegroundColor Cyan }

# A real Skyrim SE root has SkyrimSE.exe in it (Steam and GOG both name it that).
# Validate on the game exe, not the compiler -- the CK is a separate download, and
# the compiler/flags checks below report its absence on their own.
function Test-SE([string]$c) { return ($c -and (Test-Path (Join-Path $c "SkyrimSE.exe"))) }

# Best-effort auto-detect: Steam's registry + libraryfolders.vdf first (finds installs
# on any drive), then a matrix of the usual Steam/GOG layouts across fixed drives.
# Returns the install root, or $null.
function Find-SkyrimSE {
    # 1. Steam registry -> library list
    $steam = $null
    foreach ($reg in @(
        @{ Path = "HKCU:\Software\Valve\Steam";             Name = "SteamPath" },
        @{ Path = "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam"; Name = "InstallPath" },
        @{ Path = "HKLM:\SOFTWARE\Valve\Steam";             Name = "InstallPath" }
    )) {
        try { $v = (Get-ItemProperty -Path $reg.Path -Name $reg.Name -ErrorAction Stop).($reg.Name) }
        catch { $v = $null }
        if ($v) { $steam = $v; break }
    }
    if ($steam) {
        $libs = [System.Collections.Generic.List[string]]::new()
        $libs.Add($steam)
        $vdf = Join-Path $steam "steamapps\libraryfolders.vdf"
        if (Test-Path $vdf) {
            foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s*"([^"]+)"')) {
                $libs.Add(($m.Groups[1].Value -replace '\\\\', '\'))
            }
        }
        foreach ($lib in $libs) {
            $c = Join-Path $lib "steamapps\common\Skyrim Special Edition"
            if (Test-SE $c) { return $c }
        }
    }

    # 2. Common-path matrix across fixed drives
    $drives = @()
    try {
        $drives = [System.IO.DriveInfo]::GetDrives() |
            Where-Object { $_.DriveType -eq 'Fixed' -and $_.IsReady } |
            ForEach-Object { $_.Name }   # e.g. "C:\"
    } catch {}
    if (-not $drives) { $drives = @('C:\', 'D:\', 'E:\', 'F:\') }

    $steamRels = @(
        "Program Files (x86)\Steam\steamapps\common\Skyrim Special Edition",
        "Steam\steamapps\common\Skyrim Special Edition",
        "SteamLibrary\steamapps\common\Skyrim Special Edition",
        "Games\Steam\steamapps\common\Skyrim Special Edition",
        "SteamGames\steamapps\common\Skyrim Special Edition"
    )
    $gogGlobs = @(
        "GOG Games\*Skyrim*",
        "Program Files (x86)\GOG Galaxy\Games\*Skyrim*",
        "GOG Galaxy\Games\*Skyrim*",
        "Games\GOG\*Skyrim*"
    )
    foreach ($d in $drives) {
        foreach ($rel in $steamRels) {
            $c = Join-Path $d $rel
            if (Test-SE $c) { return $c }
        }
        foreach ($g in $gogGlobs) {
            foreach ($dir in (Get-ChildItem (Join-Path $d $g) -Directory -ErrorAction SilentlyContinue)) {
                if (Test-SE $dir.FullName) { return $dir.FullName }
            }
        }
    }
    return $null
}

# Resolve the .pex compile timestamp (unix seconds), SOURCE_DATE_EPOCH-style. Precedence:
# explicit env var -> HEAD commit date on a CLEAN tree -> current time. git is read-only
# here; a dirty tree or no git falls back to "now" (a non-deterministic timestamp) and says
# so. Announces the source either way. NB: this only pins the timestamp -- it does not make
# the .pex byte-reproducible (the compiler's string-table order isn't deterministic), and with
# current tools it can't, so reproducibility isn't claimed.
function Resolve-CompileTime {
    if ($env:SOURCE_DATE_EPOCH -match '^\d+$') {
        Write-Host "  timestamp: SOURCE_DATE_EPOCH from environment ($($env:SOURCE_DATE_EPOCH))" -ForegroundColor DarkGray
        return [long]$env:SOURCE_DATE_EPOCH
    }
    $inGit = $false
    try { $inGit = ((git rev-parse --is-inside-work-tree 2>$null) -eq 'true') } catch {}
    if ($inGit) {
        if (@(git status --porcelain 2>$null).Count -eq 0) {
            $ct = (git log -1 --format=%ct 2>$null)
            if ($ct -match '^\d+$') {
                Write-Host "  timestamp: HEAD commit date, clean tree ($ct)" -ForegroundColor DarkGray
                return [long]$ct
            }
        } else {
            Write-Host "  WARN: working tree is DIRTY -- stamping current time (non-deterministic). Commit (or set SOURCE_DATE_EPOCH) for a stable, commit-dated timestamp." -ForegroundColor Yellow
        }
    } else {
        Write-Host "  WARN: no readable git and SOURCE_DATE_EPOCH unset -- stamping current time (non-deterministic). Set SOURCE_DATE_EPOCH for a stable timestamp." -ForegroundColor Yellow
    }
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    Write-Host "  timestamp: current time ($now)" -ForegroundColor DarkGray
    return $now
}

$Version = (Get-Content (Join-Path $root "VERSION") -Raw).Trim()
if ($Version -notmatch '^\d+\.\d+\.\d+$') { Fail "VERSION '$Version' is not X.Y.Z" }
Write-Host "It Just Works build - version $Version" -ForegroundColor Green

# Resolve the install root. Precedence: -GameRoot, then $env:SKYRIM_SE_PATH, then
# auto-detect -- so a fresh clone builds without editing this file.
if (-not $GameRoot -and $env:SKYRIM_SE_PATH) {
    $GameRoot = $env:SKYRIM_SE_PATH
    Write-Host "  using SKYRIM_SE_PATH: $GameRoot" -ForegroundColor DarkGray
}
if (-not $GameRoot) {
    $GameRoot = Find-SkyrimSE
    if ($GameRoot) { Write-Host "  auto-detected Skyrim SE: $GameRoot" -ForegroundColor DarkGray }
}
if (-not $GameRoot) {
    Fail ("could not locate Skyrim Special Edition. Set the SKYRIM_SE_PATH environment variable, " +
          "or pass -GameRoot 'X:\...\steamapps\common\Skyrim Special Edition'.")
}
if (-not (Test-SE $GameRoot)) {
    Write-Host "  WARN: no SkyrimSE.exe under '$GameRoot' - continuing; the compiler/flags checks will confirm" -ForegroundColor Yellow
}

$compiler = Join-Path $GameRoot "Papyrus Compiler\PapyrusCompiler.exe"
$flags    = Join-Path $GameRoot "Data\Scripts\Source\TESV_Papyrus_Flags.flg"
if (-not (Test-Path $compiler)) { Fail "PapyrusCompiler not found at $compiler" }
if (-not (Test-Path $flags))    { Fail "flags file not found at $flags" }

$dist = Join-Path $root "dist"
$pkg  = Join-Path $dist "pkg"          # the Data-rooted archive tree (+ fomod/)
if (Test-Path $pkg) { Remove-Item $pkg -Recurse -Force }
New-Item -ItemType Directory -Force $pkg | Out-Null

# --- 1. ESP via Mutagen ------------------------------------------------------
Step 1 "Generate ESP (Mutagen)"
& dotnet run --project (Join-Path $root "src\Fth.ItJustWorks.Builder") -c Release -- `
    --version $Version --author $Author --out (Join-Path $pkg "fth_ItJustWorks.esp")
if ($LASTEXITCODE -ne 0) { Fail "Builder exited $LASTEXITCODE" }

# --- 2. Compile Papyrus ------------------------------------------------------
Step 2 "Compile Papyrus"
# Toast bake: allow-listed $fth_IJW_Toast_* from the translation tables -> fth_IJW_Toasts.psc.
# Missing cells fall back to English. PapyrusCompiler corrupts non-ASCII string
# literals in .psc, so those become ASCII placeholders (__IJW_*__) and PexScrub
# --replace writes the real UTF-8 into the .pex string table after compile.
# $langOrder index order must match MCM iToastLang enum options and FOMOD seeds.
$langOrder = @("ENGLISH","FRENCH","GERMAN","ITALIAN","SPANISH","POLISH","RUSSIAN","CHINESE","JAPANESE","CZECH")
$toastAllow = @("Alert","NamesOff","StopOk","StopFail","HotkeyInScene","HotkeyNoScene")
$toastByKey = [ordered]@{}
for ($li = 0; $li -lt $langOrder.Count; $li++) {
    $tp = Join-Path $root ("interface\translations\fth_ItJustWorks_{0}.txt" -f $langOrder[$li])
    if (-not (Test-Path $tp)) { Fail "bake: missing translation table $tp" }
    foreach ($line in ([IO.File]::ReadAllText($tp, [Text.Encoding]::Unicode) -split "`r?`n")) {
        if ($line -match '^(\$fth_IJW_Toast_[A-Za-z0-9_]+)\t(.*)$') {
            $k = $Matches[1]; $v = $Matches[2]
            $fn = $k -replace '^\$fth_IJW_Toast_',''
            if ($toastAllow -notcontains $fn) {
                Fail "bake: unexpected toast key $k (allow-list: $($toastAllow -join ', '))"
            }
            if (-not $toastByKey.Contains($k)) { $toastByKey[$k] = New-Object string[] $langOrder.Count }
            $toastByKey[$k][$li] = $v
        }
    }
}
if ($toastByKey.Count -eq 0) { Fail "bake: no `$fth_IJW_Toast_* keys in the tables" }
foreach ($fn in $toastAllow) {
    $k = "`$fth_IJW_Toast_$fn"
    if (-not $toastByKey.Contains($k)) { Fail "bake: missing required toast key $k" }
}
$esc = { param($s) $s.Replace('\','\\').Replace('"','\"') }
$isAscii = { param($s) -not [regex]::IsMatch($s, '[^\x00-\x7F]') }
$toastReplace = [ordered]@{}
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("Scriptname fth_IJW_Toasts Hidden")
[void]$sb.AppendLine("; Generated by build.ps1 from interface/translations (not hand-edited).")
[void]$sb.AppendLine("; aLang = notification language index (0 = English). Non-ASCII returns are __IJW_*__ placeholders filled in the .pex after compile.")
[void]$sb.AppendLine("")
foreach ($k in $toastByKey.Keys) {
    $fn = $k -replace '^\$fth_IJW_Toast_',''
    $vals = $toastByKey[$k]
    if (-not $vals[0]) { Fail "bake: $k has no ENGLISH value" }
    if (-not (& $isAscii $vals[0])) { Fail "bake: $k ENGLISH must be ASCII (compiler cannot embed non-ASCII); got: $($vals[0])" }
    [void]$sb.AppendLine("string Function $fn(int aLang) global")
    $first = $true
    for ($li = 1; $li -lt $langOrder.Count; $li++) {
        $v = $vals[$li]
        if ($v -and $v -ne $vals[0]) {
            $kw = if ($first) { "if" } else { "elseif" }
            $first = $false
            [void]$sb.AppendLine("    $kw aLang == $li")
            if (& $isAscii $v) {
                [void]$sb.AppendLine("        return `"$(& $esc $v)`"")
            } else {
                $ph = "__IJW_${fn}_${li}__"
                $toastReplace[$ph] = $v
                [void]$sb.AppendLine("        return `"$ph`"")
            }
        }
    }
    if (-not $first) { [void]$sb.AppendLine("    endif") }
    [void]$sb.AppendLine("    return `"$(& $esc $vals[0])`"")
    [void]$sb.AppendLine("EndFunction")
    [void]$sb.AppendLine("")
}
[IO.File]::WriteAllText((Join-Path $root "scripts\fth_IJW_Toasts.psc"), $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
$toastMapPath = Join-Path $pkg "toast-replace.json"
if ($toastReplace.Count -gt 0) {
    $ht = @{}
    foreach ($ph in $toastReplace.Keys) { $ht[$ph] = $toastReplace[$ph] }
    $json = $ht | ConvertTo-Json -Compress -Depth 5
    [IO.File]::WriteAllText($toastMapPath, $json, (New-Object System.Text.UTF8Encoding($false)))
} else {
    if (Test-Path $toastMapPath) { Remove-Item -Force $toastMapPath }
}
Write-Host "  baked: scripts\fth_IJW_Toasts.psc ($($toastByKey.Count) toast keys x $($langOrder.Count) langs; $($toastReplace.Count) non-ASCII via pex replace)"

$scriptsOut = Join-Path $pkg "Scripts"
New-Item -ItemType Directory -Force $scriptsOut | Out-Null
# Both game source trees are on the path (mods scatter headers across both); `scripts`
# too, so fth_IJW_MCM resolves the sibling watcher type. Order matters: Data\Scripts\
# Source is the complete SKSE-augmented tree and must precede Data\Source\Scripts, or
# the compiler cross-pairs mismatched base scripts and the transitive closure fails.
$importPath = @(
    (Join-Path $root "headers"),
    (Join-Path $root "scripts"),
    (Join-Path $GameRoot "Data\Scripts\Source"),
    (Join-Path $GameRoot "Data\Source\Scripts")
) -join ";"

foreach ($psc in @("fth_IJW_Toasts.psc", "fth_IJW_Watcher.psc", "fth_IJW_MCM.psc")) {
    $src = Join-Path $root "scripts\$psc"
    & $compiler $src -i="$importPath" -o="$scriptsOut" -f="$flags"
    if ($LASTEXITCODE -ne 0) { Fail "PapyrusCompiler failed on $psc (exit $LASTEXITCODE)" }
}
$pex = Get-ChildItem $scriptsOut -Filter *.pex
if ($pex.Count -lt 3) { Fail "expected 3 .pex, got $($pex.Count)" }
Write-Host "  compiled: $($pex.Name -join ', ')"

# --- 3. Scrub .pex identity (and optional toast string replace) --------------
Step 3 "Scrub .pex headers"
$compileEpoch = Resolve-CompileTime
$pexScrubArgs = @(
    "--time", "$compileEpoch"
)
if (Test-Path $toastMapPath) {
    $pexScrubArgs += @("--replace", $toastMapPath)
}
$pexScrubArgs += (Join-Path $scriptsOut "*.pex")
& dotnet run --project (Join-Path $root "src\Fth.ItJustWorks.PexScrub") -c Release -- @pexScrubArgs
if ($LASTEXITCODE -ne 0) { Fail "PexScrub exited $LASTEXITCODE" }
# Placeholders must not ship: if the bake map was non-empty, fth_IJW_Toasts.pex must have no __IJW_ left.
$toastsPex = Join-Path $scriptsOut "fth_IJW_Toasts.pex"
if (-not (Test-Path $toastsPex)) { Fail "toast gate: missing $toastsPex after compile/scrub" }
$toastsBytes = [IO.File]::ReadAllBytes($toastsPex)
$phNeedle = [Text.Encoding]::ASCII.GetBytes("__IJW_")
$phHits = 0
for ($i = 0; $i -le $toastsBytes.Length - $phNeedle.Length; $i++) {
    $ok = $true
    for ($j = 0; $j -lt $phNeedle.Length; $j++) {
        if ($toastsBytes[$i + $j] -ne $phNeedle[$j]) { $ok = $false; break }
    }
    if ($ok) { $phHits++ }
}
if ($phHits -gt 0) {
    Fail "toast gate: fth_IJW_Toasts.pex still contains $phHits `__IJW_` placeholder marker(s) after PexScrub --replace"
}
if (Test-Path $toastMapPath) { Remove-Item -Force $toastMapPath }

# --- 4. Assemble the archive tree -------------------------------------------
Step 4 "Assemble archive tree"
# Source is not shipped; MPL source availability is met by the public repo (linked
# from the Nexus page). Keeps the zip lean.
# MCM config + keybinds + settings  (mcm\Config\... -> pkg\MCM\Config\...)
$mcmOut = Join-Path $pkg "MCM"; New-Item -ItemType Directory -Force $mcmOut | Out-Null
Copy-Item (Join-Path $root "mcm\Config") $mcmOut -Recurse
# translations  (interface\translations\... -> pkg\Interface\translations\...)
$ifOut = Join-Path $pkg "Interface"; New-Item -ItemType Directory -Force $ifOut | Out-Null
Copy-Item (Join-Path $root "interface\translations") $ifOut -Recurse
# License/source breadcrumb is generated (namespaced) in step 5. Full MPL text is in
# the repo (LICENSE.txt); only the breadcrumb ships.

# --- 5. Metadata (from $Version) --------------------------------------------
Step 5 "Metadata"
$fomodDir = Join-Path $pkg "fomod"
New-Item -ItemType Directory -Force $fomodDir | Out-Null
$tmpl = Get-Content (Join-Path $root "packaging\fomod-info.xml.tmpl") -Raw
$info = $tmpl.Replace("{{VERSION}}", $Version).Replace("{{WEBSITE}}", $Website).Replace("{{AUTHOR}}", $Author)
Set-Content -Path (Join-Path $fomodDir "info.xml") -Value $info -Encoding UTF8

# A single namespaced file, so it can't collide with other mods' LICENSE at the Data
# root. Points at the repo, where the full MPL text and source live.
$repoRef = if ($Repo) { $Repo } else {
    Write-Host "  WARN: -Repo not set; breadcrumb points at the mod page instead of the repo" -ForegroundColor Yellow
    "(see the mod's Nexus description page for the source repository link)"
}
$licTmpl = Get-Content (Join-Path $root "packaging\license-notice.md.tmpl") -Raw
$lic = $licTmpl.Replace("{{VERSION}}", $Version).Replace("{{REPO}}", $repoRef).Replace("{{AUTHOR}}", $Author)
Set-Content -Path (Join-Path $pkg "fth_ItJustWorks_LICENSE.md") -Value $lic -Encoding UTF8

# Version footer in config.json (not the menu title). Write UTF-8 without BOM —
# MCM Helper fails to load the menu if the file has a BOM.
$cfgPath = Join-Path $pkg "MCM\Config\fth_ItJustWorks\config.json"
$utf8NoBom = [Text.UTF8Encoding]::new($false)
$cfg = [IO.File]::ReadAllText($cfgPath, $utf8NoBom)
$cfg = $cfg -replace '("text"\s*:\s*")Version \d+\.\d+\.\d+(")', "`${1}Version $Version`${2}"
if ($cfg.Length -gt 0 -and [int][char]$cfg[0] -eq 0xFEFF) { $cfg = $cfg.Substring(1) }
[IO.File]::WriteAllText($cfgPath, $cfg, $utf8NoBom)

# FOMOD installer, two steps:
#   1. "Extra language files" - opt-in checkboxes; each installs its own
#      fth_ItJustWorks_<LANG>.txt (the file the game reads when its language matches)
#      and raises a flag so step 2 can offer it.
#   2. "Default menu language" - one radio pick that overwrites the ENGLISH file the
#      game reads on an English-language install (and drops an English .bak sidecar so the
#      original strings can be restored by rename). The same option seeds Config
#      settings.ini iToastLang to match the notification-language enum (not user
#      Settings/ - that would fight reset-to-default). English is the default; every
#      other option is greyed out until its box is ticked in step 1.
# The mod + the English file install unconditionally, so there is always a valid menu.
# Endonym display names carry non-ASCII as XML numeric entities to keep build.ps1 ASCII.
# The per-option descriptions are too long to entity-encode, so they live in a UTF-8 data
# file (packaging\fomod-descriptions.json) read here and emitted into the UTF-8 XML.
$fomodLangs = [ordered]@{
    CHINESE  = '&#31616;&#20307;&#20013;&#25991; (Chinese)'
    CZECH    = '&#268;e&#353;tina (Czech)'
    FRENCH   = 'Fran&#231;ais (French)'
    GERMAN   = 'Deutsch (German)'
    ITALIAN  = 'Italiano (Italian)'
    JAPANESE = '&#26085;&#26412;&#35486; (Japanese)'
    POLISH   = 'Polski (Polish)'
    RUSSIAN  = '&#1056;&#1091;&#1089;&#1089;&#1082;&#1080;&#1081; (Russian)'
    SPANISH  = 'Espa&#241;ol (Spanish)'
}
# Derived from $langOrder so FOMOD seeds cannot drift from the bake index.
$toastLangIndex = @{}
for ($li = 0; $li -lt $langOrder.Count; $li++) { $toastLangIndex[$langOrder[$li]] = $li }
# MCM enum option order must match $langOrder (Title-case $fth_IJW_Lang_* labels).
$langTitle = @{
    ENGLISH = "English"; FRENCH = "French"; GERMAN = "German"; ITALIAN = "Italian"
    SPANISH = "Spanish"; POLISH = "Polish"; RUSSIAN = "Russian"; CHINESE = "Chinese"
    JAPANESE = "Japanese"; CZECH = "Czech"
}
$expectedToastOpts = @($langOrder | ForEach-Object { "`$fth_IJW_Lang_$($langTitle[$_])" })
$cfgForToast = Get-Content (Join-Path $root "mcm\Config\fth_ItJustWorks\config.json") -Raw -Encoding UTF8
if ($cfgForToast -notmatch '"id"\s*:\s*"iToastLang:Control"[\s\S]*?"options"\s*:\s*\[([^\]]+)\]') {
    Fail "toast lang: could not find iToastLang:Control options array in config.json"
}
$foundToastOpts = @([regex]::Matches($Matches[1], '"(\$fth_IJW_Lang_[A-Za-z]+)"') | ForEach-Object { $_.Groups[1].Value })
if ($foundToastOpts.Count -ne $expectedToastOpts.Count) {
    Fail "toast lang: config.json has $($foundToastOpts.Count) enum options, expected $($expectedToastOpts.Count)"
}
for ($ti = 0; $ti -lt $expectedToastOpts.Count; $ti++) {
    if ($foundToastOpts[$ti] -ne $expectedToastOpts[$ti]) {
        Fail "toast lang: config.json options[$ti]=$($foundToastOpts[$ti]), expected $($expectedToastOpts[$ti]) (must match bake `$langOrder)"
    }
}
Write-Host "  toast lang: MCM enum order matches bake `$langOrder ($($langOrder.Count) langs)"
$fomodDescPath = Join-Path $root "packaging\fomod-descriptions.json"
if (-not (Test-Path $fomodDescPath)) { Fail "FOMOD: missing packaging\fomod-descriptions.json" }
$fomodDesc = Get-Content $fomodDescPath -Raw -Encoding UTF8 | ConvertFrom-Json
$engRel = "Interface\translations\fth_ItJustWorks_ENGLISH.txt"
$settingsRel = "MCM\Config\fth_ItJustWorks\settings.ini"
$baseSettingsPath = Join-Path $pkg $settingsRel
if (-not (Test-Path $baseSettingsPath)) { Fail "FOMOD: missing baseline $settingsRel" }
$baseSettingsText = [IO.File]::ReadAllText($baseSettingsPath)
if ($baseSettingsText -notmatch '(?m)^iToastLang\s*=\s*0\s*$') {
    Fail "FOMOD: baseline settings.ini must contain iToastLang = 0 (got no match)"
}
$seedDir = Join-Path $pkg "fomod\toast-lang"
New-Item -ItemType Directory -Force $seedDir | Out-Null
$utf8NoBomSeed = [Text.UTF8Encoding]::new($false)
$fomodLangFiles = ""   # step 1: install the native-name file, raise a flag
$fomodDefaults  = ""   # step 2: overwrite ENGLISH (+ .bak) + seed iToastLang
foreach ($lang in $fomodLangs.Keys) {
    $rel = "Interface\translations\fth_ItJustWorks_$lang.txt"
    if (-not (Test-Path (Join-Path $pkg $rel))) { Fail "FOMOD: missing translation $rel" }
    if (-not ($fomodDesc.PSObject.Properties.Name -contains $lang)) { Fail "FOMOD: no descriptions for $lang in fomod-descriptions.json" }
    if (-not $toastLangIndex.ContainsKey($lang)) { Fail "FOMOD: no toast index for $lang" }
    $idx = [int]$toastLangIndex[$lang]
    $seedRel = "fomod\toast-lang\settings_$lang.ini"
    $seedText = [regex]::Replace($baseSettingsText, '(?m)^iToastLang\s*=\s*\d+\s*$', "iToastLang = $idx")
    if ($seedText -notmatch "(?m)^iToastLang\s*=\s*$idx\s*$") {
        Fail "FOMOD: failed to stamp iToastLang = $idx into $seedRel"
    }
    [IO.File]::WriteAllText((Join-Path $pkg $seedRel), $seedText, $utf8NoBomSeed)
    $disp = $fomodLangs[$lang]
    $descCheckbox = ($fomodDesc.$lang.checkbox) -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;'
    $descOverride = ($fomodDesc.$lang.override) -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;'
    $fomodLangFiles += "          <plugin name=`"$disp`">`n" +
        "            <description>$descCheckbox</description>`n" +
        "            <files>`n" +
        "              <file source=`"$rel`" destination=`"$rel`" priority=`"0`"/>`n" +
        "            </files>`n" +
        "            <conditionFlags>`n" +
        "              <flag name=`"default_$lang`">On</flag>`n" +
        "            </conditionFlags>`n" +
        "            <typeDescriptor><type name=`"Optional`"/></typeDescriptor>`n" +
        "          </plugin>`n"
    $fomodDefaults += "          <plugin name=`"$disp`">`n" +
        "            <description>$descOverride</description>`n" +
        "            <files>`n" +
        "              <file source=`"$rel`" destination=`"$engRel`" priority=`"1`"/>`n" +
        "              <file source=`"$engRel`" destination=`"${engRel}.bak`" priority=`"0`"/>`n" +
        "              <file source=`"$seedRel`" destination=`"$settingsRel`" priority=`"1`"/>`n" +
        "            </files>`n" +
        "            <typeDescriptor>`n" +
        "              <dependencyType>`n" +
        "                <defaultType name=`"NotUsable`"/>`n" +
        "                <patterns>`n" +
        "                  <pattern>`n" +
        "                    <dependencies operator=`"And`"><flagDependency flag=`"default_$lang`" value=`"On`"/></dependencies>`n" +
        "                    <type name=`"Optional`"/>`n" +
        "                  </pattern>`n" +
        "                </patterns>`n" +
        "              </dependencyType>`n" +
        "            </typeDescriptor>`n" +
        "          </plugin>`n"
}
$moduleConfig = @"
<?xml version="1.0" encoding="UTF-8"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://qconsulting.ca/fo3/ModConfig5.0.xsd">
  <moduleName>It Just Works&#8482;</moduleName>
  <requiredInstallFiles>
    <file source="fth_ItJustWorks.esp" destination="fth_ItJustWorks.esp" priority="0"/>
    <folder source="Scripts" destination="Scripts" priority="0"/>
    <folder source="MCM" destination="MCM" priority="0"/>
    <folder source="SEQ" destination="SEQ" priority="0"/>
    <file source="$engRel" destination="$engRel" priority="0"/>
    <file source="fth_ItJustWorks_LICENSE.md" destination="fth_ItJustWorks_LICENSE.md" priority="0"/>
  </requiredInstallFiles>
  <installSteps order="Explicit">
    <installStep name="Extra language files">
      <optionalFileGroups order="Explicit">
        <group name="Install extra language files (English always installed)" type="SelectAny">
          <plugins order="Explicit">
$fomodLangFiles          </plugins>
        </group>
      </optionalFileGroups>
    </installStep>
    <installStep name="Default menu language">
      <optionalFileGroups order="Explicit">
        <group name="Which language should the menu show by default?" type="SelectExactlyOne">
          <plugins order="Explicit">
          <plugin name="English (default)">
            <description>Leave the menu in English. This is the default and ships with the mod. Pick another language only if you ticked its file in the previous step and want it to show even on an English-language game.</description>
            <typeDescriptor><type name="Recommended"/></typeDescriptor>
          </plugin>
$fomodDefaults          </plugins>
        </group>
      </optionalFileGroups>
    </installStep>
  </installSteps>
</config>
"@
Set-Content -Path (Join-Path $fomodDir "ModuleConfig.xml") -Value $moduleConfig -Encoding UTF8
Write-Host "  fomod: ModuleConfig.xml - $($fomodLangs.Count) language files + $($fomodLangs.Count + 1) default-language options"

# --- 6. Verify gate ----------------------------------------------------------
Step 6 "Verify gate (fail on any hit)"

function Contains-Bytes([byte[]]$hay, [byte[]]$needle) {
    if ($needle.Length -eq 0 -or $hay.Length -lt $needle.Length) { return $false }
    for ($i = 0; $i -le $hay.Length - $needle.Length; $i++) {
        $match = $true
        for ($j = 0; $j -lt $needle.Length; $j++) {
            if ($hay[$i + $j] -ne $needle[$j]) { $match = $false; break }
        }
        if ($match) { return $true }
    }
    return $false
}

# Identity scrub. The real checks live in the gitignored sanitization\private\ folder,
# so this public repo never holds the machine-local strings. Fatal if there are no
# checks OR if any fails for any reason -- a silently-skipped scrub is the whole risk.
# Each check gets -PackageDir and throws/exits non-zero on a leak. -SkipSanitization
# is the escape hatch for outside builders (the step-3 .pex scrub ran regardless).
$sanRoot = Join-Path $root "sanitization"
$sanDir  = Join-Path $sanRoot "private"
# A .ps1 at the sanitization\ top level is neither run nor gitignored -- a silent
# no-op and a way to accidentally commit an identity check. Active checks go in private\.
$stray = @(Get-ChildItem $sanRoot -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -eq ".ps1" })
if ($stray.Count -gt 0) {
    Write-Host "  WARN: $($stray.Count) .ps1 at sanitization\ top level - NOT run, NOT gitignored. Move active checks to sanitization\private\: $($stray.Name -join ', ')" -ForegroundColor Yellow
}
$sanScripts = @()
# exact .ps1 extension (NOT -Filter "*.ps1", whose 8.3 matching can catch
# "foo.ps1.example") so a template file stays inert until it's renamed active.
if (Test-Path $sanDir) { $sanScripts = @(Get-ChildItem $sanDir -File | Where-Object { $_.Extension -eq ".ps1" } | Sort-Object Name) }
if ($sanScripts.Count -eq 0) {
    if ($SkipSanitization) {
        Write-Host "  identity scrub SKIPPED (-SkipSanitization; no checks in sanitization\private\)" -ForegroundColor Yellow
    } else {
        Fail "no checks in sanitization\private\ -- refusing to package without the identity scrub. Add your checks there (see sanitization\README.md), or pass -SkipSanitization when building your own copy with no identity of ours to strip."
    }
} else {
    foreach ($s in $sanScripts) {
        Write-Host "  sanitize: $($s.Name)"
        $global:LASTEXITCODE = 0
        try { & $s.FullName -PackageDir $pkg }
        catch { Fail "sanitization check $($s.Name) failed: $_" }
        if ($LASTEXITCODE -ne 0) { Fail "sanitization check $($s.Name) exited non-zero ($LASTEXITCODE)" }
    }
    Write-Host "  identity scrub passed ($($sanScripts.Count) check(s))"
}

# version consistency across surfaces
$infoText = Get-Content (Join-Path $fomodDir "info.xml") -Raw
if ($infoText -notmatch [regex]::Escape($Version)) { Fail "version $Version missing from fomod/info.xml" }

$espBytes = [IO.File]::ReadAllBytes((Join-Path $pkg "fth_ItJustWorks.esp"))
if (-not (Contains-Bytes $espBytes ([Text.Encoding]::ASCII.GetBytes("v$Version")))) {
    Fail "version v$Version missing from ESP header description"
}

# SEQ: engine start-on-load list for mid-playthrough installs. One StartGameEnabled
# quest -> one 4-byte little-endian file FormID. Gate: present, length 4, high byte
# non-zero (not a bare object id), ESL object-id window, dword also present in the ESP.
$seqPath = Join-Path $pkg "SEQ\fth_ItJustWorks.seq"
if (-not (Test-Path $seqPath)) { Fail "SEQ missing: expected $seqPath (the Builder should emit it)" }
$seqBytes = [IO.File]::ReadAllBytes($seqPath)
if ($seqBytes.Length -ne 4) { Fail "SEQ must be 4 bytes (one StartGameEnabled quest), got $($seqBytes.Length)" }
if ($seqBytes[3] -eq 0) { Fail "SEQ high byte is 0x00 -- a bare object id (the FormKey.ID trap), not a file FormID" }
$seqObj = [int]$seqBytes[0] -bor ([int]$seqBytes[1] -shl 8) -bor ([int]$seqBytes[2] -shl 16)
if ($seqObj -lt 0x800 -or $seqObj -gt 0xFFF) { Fail ("SEQ object id 0x{0:X} outside the ESL window 0x800-0xFFF" -f $seqObj) }
if (-not (Contains-Bytes $espBytes $seqBytes)) { Fail "SEQ dword not present in the ESP -- does not match any 4-byte run in the plugin file" }
$seqHex = ($seqBytes | ForEach-Object { '{0:X2}' -f $_ }) -join ' '
Write-Host "  SEQ: 4 bytes [$seqHex], object id in ESL window, dword present in ESP"

$cfgText = Get-Content $cfgPath -Raw
if ($cfgText -notmatch [regex]::Escape("Version $Version")) { Fail "version missing from MCM version row" }

$licText = Get-Content (Join-Path $pkg "fth_ItJustWorks_LICENSE.md") -Raw
if ($licText -notmatch [regex]::Escape("Version $Version")) { Fail "version missing from license breadcrumb" }

$changelog = Get-Content (Join-Path $root "CHANGELOG.md")
$topHeading = ($changelog | Where-Object { $_ -match '^##\s+\d+\.\d+\.\d+' } | Select-Object -First 1)
if (-not $topHeading) { Fail "no version heading in CHANGELOG.md" }
$clVer = ($topHeading -replace '^##\s+', '').Trim()
if ($clVer -ne $Version) { Fail "CHANGELOG top heading '$clVer' != VERSION '$Version'" }
Write-Host "  version $Version consistent across info.xml, ESP, MCM title, CHANGELOG"

# FOMOD sanity: a scripted installer copies ONLY what it lists. Prove every referenced
# source exists; the two steps are shaped right; the default-language mechanism is fully
# wired (step-2 flags match step-1 flags, the translation overwrites ENGLISH at priority 1,
# English .bak sidecar, Config settings.ini iToastLang seed at priority 1); and no shipped
# file outside fomod/ is left unreferenced. GetAttribute + SelectNodes throughout: the
# "English (default)" option has no <files>, and property access on a missing node/attribute
# trips Set-StrictMode.
[xml]$mc = Get-Content (Join-Path $fomodDir "ModuleConfig.xml") -Raw
$steps = @($mc.config.installSteps.installStep)
if ($steps.Count -ne 2) { Fail "FOMOD: expected 2 install steps, got $($steps.Count)" }
$langStep = $steps | Where-Object { $_.name -eq 'Extra language files' }
$defStep  = $steps | Where-Object { $_.name -eq 'Default menu language' }
if (-not $langStep) { Fail "FOMOD: missing 'Extra language files' step" }
if (-not $defStep)  { Fail "FOMOD: missing 'Default menu language' step" }
$langPlugins   = @($langStep.SelectNodes('.//plugin'))
$defPlugins    = @($defStep.SelectNodes('.//plugin'))
$langFileNodes = @($langStep.SelectNodes('.//plugin/files/file'))
$defFileNodes  = @($defStep.SelectNodes('.//plugin/files/file'))

$fomodRefs = [System.Collections.Generic.HashSet[string]]::new()
$fomodSources  = @($mc.config.SelectNodes('requiredInstallFiles/file')   | ForEach-Object { $_.GetAttribute('source') })
$fomodSources += @($mc.config.SelectNodes('requiredInstallFiles/folder') | ForEach-Object { $_.GetAttribute('source') })
$fomodSources += @($langFileNodes | ForEach-Object { $_.GetAttribute('source') })
$fomodSources += @($defFileNodes  | ForEach-Object { $_.GetAttribute('source') })
foreach ($src in ($fomodSources | Where-Object { $_ })) {
    $full = Join-Path $pkg $src
    if (-not (Test-Path $full)) { Fail "FOMOD references a missing source: $src" }
    if (Test-Path $full -PathType Container) {
        Get-ChildItem $full -Recurse -File | ForEach-Object { [void]$fomodRefs.Add($_.FullName.ToLower()) }
    } else {
        [void]$fomodRefs.Add((Resolve-Path $full).Path.ToLower())
    }
}

# Step 1: 9 language checkboxes, none of them ENGLISH, each raising a default_<LANG> flag.
if ($langPlugins.Count -ne 9) { Fail "FOMOD: expected 9 language checkboxes, got $($langPlugins.Count)" }
if (@($langFileNodes | Where-Object { $_.GetAttribute('source') -match 'ENGLISH' }).Count -gt 0) { Fail "FOMOD: ENGLISH must be required, not an optional checkbox" }
$step1Flags = @($langStep.SelectNodes('.//plugin/conditionFlags/flag') | ForEach-Object { $_.GetAttribute('name') })
if ($step1Flags.Count -ne 9) { Fail "FOMOD: expected 9 step-1 condition flags, got $($step1Flags.Count)" }

# Step 2: English (default) + 9 language options. Each language option must (a) overwrite
# the ENGLISH file with a non-ENGLISH translation at priority 1, (b) drop an English .bak
# sidecar, (c) seed Config settings.ini iToastLang at priority 1, and (d) gate on a
# flagDependency that a step-1 checkbox actually raises.
if ($defPlugins.Count -ne 10) { Fail "FOMOD: expected 10 default-language options (English + 9), got $($defPlugins.Count)" }
$transNodes = @($defFileNodes | Where-Object { $_.GetAttribute('destination') -match 'fth_ItJustWorks_ENGLISH\.txt$' })
$bakNodes   = @($defFileNodes | Where-Object { $_.GetAttribute('destination') -match 'fth_ItJustWorks_ENGLISH\.txt\.bak$' })
$seedNodes  = @($defFileNodes | Where-Object { $_.GetAttribute('destination') -match '(?i)MCM[/\\]Config[/\\]fth_ItJustWorks[/\\]settings\.ini$' })
if ($transNodes.Count -ne 9) { Fail "FOMOD: expected 9 default-language overwrites of the ENGLISH file, got $($transNodes.Count)" }
if ($bakNodes.Count   -ne 9) { Fail "FOMOD: expected 9 English .bak sidecars, got $($bakNodes.Count)" }
if ($seedNodes.Count  -ne 9) { Fail "FOMOD: expected 9 Config settings.ini toast-lang seeds, got $($seedNodes.Count)" }
foreach ($f in $transNodes) {
    if ($f.GetAttribute('source') -match 'ENGLISH')  { Fail "FOMOD: a default-language overwrite sources the ENGLISH file; it must source a translation" }
    if ($f.GetAttribute('priority') -ne '1')         { Fail "FOMOD: a default-language overwrite must be priority 1 to outrank the required ENGLISH file" }
}
foreach ($f in $bakNodes) {
    if ($f.GetAttribute('source') -notmatch 'fth_ItJustWorks_ENGLISH\.txt$') { Fail "FOMOD: the .bak sidecar must source the ENGLISH file, got '$($f.GetAttribute('source'))'" }
}
foreach ($f in $seedNodes) {
    if ($f.GetAttribute('priority') -ne '1') { Fail "FOMOD: toast-lang settings.ini seed must be priority 1" }
    $src = $f.GetAttribute('source')
    if ($src -notmatch 'fomod[/\\]toast-lang[/\\]settings_([A-Z]+)\.ini$') {
        Fail "FOMOD: toast-lang seed source must be fomod/toast-lang/settings_<LANG>.ini, got '$src'"
    }
    $seedLang = $Matches[1]
    if (-not $toastLangIndex.ContainsKey($seedLang)) { Fail "FOMOD: seed for unknown lang $seedLang" }
    $want = [int]$toastLangIndex[$seedLang]
    $seedBody = [IO.File]::ReadAllText((Join-Path $pkg $src))
    if ($seedBody -notmatch "(?m)^iToastLang\s*=\s*$want\s*$") {
        Fail "FOMOD: $src must set iToastLang = $want"
    }
}
$step2Deps = @($defStep.SelectNodes('.//plugin/typeDescriptor/dependencyType/patterns/pattern/dependencies/flagDependency') | ForEach-Object { $_.GetAttribute('flag') })
if ($step2Deps.Count -ne 9) { Fail "FOMOD: expected 9 default-language flag dependencies, got $($step2Deps.Count)" }
foreach ($dep in $step2Deps)  { if ($step1Flags -notcontains $dep)  { Fail "FOMOD: default-language option depends on flag '$dep' that no step-1 checkbox raises" } }
foreach ($flag in $step1Flags) { if ($step2Deps -notcontains $flag) { Fail "FOMOD: step-1 flag '$flag' is raised but no default-language option consumes it" } }

$fomodOrphans = @(Get-ChildItem $pkg -Recurse -File | Where-Object { $_.FullName -notlike "*\fomod\*" -and -not $fomodRefs.Contains($_.FullName.ToLower()) })
if ($fomodOrphans.Count -gt 0) { Fail "FOMOD: $($fomodOrphans.Count) shipped file(s) not referenced, would not install: $($fomodOrphans.Name -join ', ')" }
Write-Host "  fomod: valid; all $($fomodRefs.Count) shipped files referenced; 9 checkboxes + 10 default options; flags linked; ENGLISH overwrite + .bak + iToastLang seed"

# Translation key-set: every $fth_IJW_* used by MCM config or scripts must exist in all
# ten UTF-16 tables; no orphan keys left from retired UX (Trace toggle, old confirm, ...).
$usedKeys = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
$keyPat = [regex]'\$fth_IJW_[A-Za-z0-9_]+'
foreach ($src in @(
        (Join-Path $root "mcm\Config\fth_ItJustWorks\config.json"),
        (Join-Path $root "scripts\fth_IJW_Watcher.psc"),
        (Join-Path $root "scripts\fth_IJW_MCM.psc")
    )) {
    $raw = Get-Content $src -Raw -Encoding UTF8
    foreach ($m in $keyPat.Matches($raw)) { [void]$usedKeys.Add($m.Value) }
}
if ($usedKeys.Count -eq 0) { Fail "translation gate: no `$fth_IJW_* keys found in config/scripts" }

$transDir = Join-Path $pkg "Interface\translations"
$transFiles = @(Get-ChildItem $transDir -Filter "fth_ItJustWorks_*.txt" | Sort-Object Name)
if ($transFiles.Count -ne 10) { Fail "translation gate: expected 10 language tables, got $($transFiles.Count)" }

function Get-TranslationKeys([string]$path) {
    # UTF-16 LE (BOM). Lines are `$key\tvalue`; every non-blank line must be keyed.
    $text = [IO.File]::ReadAllText($path, [Text.Encoding]::Unicode)
    $set = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $ln = 0
    foreach ($line in ($text -split "`r?`n")) {
        $ln++
        if ($line -match '^\s*$') { continue }
        if ($line -match '^(\$fth_IJW_[A-Za-z0-9_]+)\t(.*)$') {
            [void]$set.Add($Matches[1])
        } else {
            Fail "translation gate: $(Split-Path $path -Leaf) line $ln is not `$key<TAB>value"
        }
    }
    return $set
}

$engKeys = $null
foreach ($tf in $transFiles) {
    $keys = Get-TranslationKeys $tf.FullName
    if ($keys.Count -eq 0) { Fail "translation gate: no keys parsed in $($tf.Name) (encoding or format?)" }
    $missing = @($usedKeys | Where-Object { -not $keys.Contains($_) } | Sort-Object)
    if ($missing.Count -gt 0) {
        Fail "translation gate: $($tf.Name) missing $($missing.Count) key(s) used by config/scripts: $($missing -join ', ')"
    }
    # Toast keys are used by the bake, not by a $key literal in config/scripts.
    $orphans = @($keys | Where-Object { -not $usedKeys.Contains($_) -and $_ -notmatch '^\$fth_IJW_Toast_' } | Sort-Object)
    if ($orphans.Count -gt 0) {
        Fail "translation gate: $($tf.Name) has $($orphans.Count) orphan key(s) not referenced by config/scripts or the toast bake: $($orphans -join ', ')"
    }
    if ($null -eq $engKeys) {
        $engKeys = $keys
    } else {
        $onlyHere = @($keys | Where-Object { -not $engKeys.Contains($_) } | Sort-Object)
        $onlyEng  = @($engKeys | Where-Object { -not $keys.Contains($_) } | Sort-Object)
        if ($onlyHere.Count -gt 0 -or $onlyEng.Count -gt 0) {
            Fail "translation gate: $($tf.Name) key-set differs from ENGLISH (extra: $($onlyHere -join ', '); missing: $($onlyEng -join ', '))"
        }
    }
}
Write-Host "  translations: $($usedKeys.Count) keys used; all 10 tables complete, no orphans, key-sets match"

# --- 7. Zip ------------------------------------------------------------------
Step 7 "Package"
$zip = Join-Path $dist "It Just Works $Version.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $pkg "*") -DestinationPath $zip -Force

# --- 8. Nexus paste helpers (NOT shipped in the zip) -------------------------
# Author-side upload helpers for the Nexus mod page. Never part of the archive.
#
# 8a. Plain-text CHANGELOG dump -- always runs, no tools. Flat lines (no "- "):
#     CHANGELOG.txt (full history with version markers) + <version>.txt bodies.
#     Nexus's paste fields are inconsistent; plain has been the least painful.
# 8b. BBCode for the English manual only (docs/manual.md -> manual.en.bb) via the
#     pinned dotnet tool. Non-critical: restore failure warns and skips.
Step 8 "Nexus paste helpers"
$bbOut = Join-Path $dist "bbcode"
if (Test-Path $bbOut) { Remove-Item $bbOut -Recurse -Force }
New-Item -ItemType Directory -Force $bbOut | Out-Null

# Flat one-line note from a markdown fragment (links/bold/code/list markers gone).
function Format-ChangelogNoteLine([string]$s) {
    $t = [regex]::Replace($s, '\[([^\]]+)\]\([^)]+\)', '$1')
    $t = [regex]::Replace($t, '\*\*([^*]+)\*\*', '$1')
    $t = [regex]::Replace($t, '(?<!\*)\*([^*]+)\*(?!\*)', '$1')
    $t = [regex]::Replace($t, '`([^`]+)`', '$1')
    return (($t -replace '\*\*', '' -replace '\s+', ' ').Trim() -replace '^[-*+]\s+', '')
}

# Parse CHANGELOG.md into version -> flat one-line notes (no markdown, no "- ").
# Nexus prefixes every paste line with ">", so list markers are poison.
# Free prose under a version (e.g. "Packaging and docs...") is kept as a note line.
function Get-ChangelogNotesByVersion([string]$mdPath) {
    $lines = Get-Content $mdPath -Encoding UTF8
    $sections = [System.Collections.Generic.List[object]]::new()
    $curVer = $null
    $curNotes = $null
    $para = $null

    foreach ($raw in $lines) {
        $line = $raw
        if ($line -match '^#\s+') {
            if ($null -ne $para -and $null -ne $curNotes) {
                $t = Format-ChangelogNoteLine $para
                if ($t.Length -gt 0) { [void]$curNotes.Add($t) }
            }
            $para = $null
            continue
        }
        if ($line -match '^##\s+(\S+)') {
            if ($null -ne $para -and $null -ne $curNotes) {
                $t = Format-ChangelogNoteLine $para
                if ($t.Length -gt 0) { [void]$curNotes.Add($t) }
            }
            $para = $null
            if ($null -ne $curVer) {
                [void]$sections.Add([pscustomobject]@{ Version = $curVer; Notes = $curNotes })
            }
            $curVer = $Matches[1].Trim()
            $curNotes = [System.Collections.Generic.List[string]]::new()
            continue
        }
        if ($null -eq $curVer) { continue }
        if ($line -match '^\s*-\s+') {
            if ($null -ne $para) {
                $t = Format-ChangelogNoteLine $para
                if ($t.Length -gt 0) { [void]$curNotes.Add($t) }
            }
            $para = ($line -replace '^\s*-\s+', '')
            continue
        }
        if ($null -ne $para) {
            if ($line -match '^\s*$') {
                $t = Format-ChangelogNoteLine $para
                if ($t.Length -gt 0) { [void]$curNotes.Add($t) }
                $para = $null
                continue
            }
            $para = $para + ' ' + $line.Trim()
            continue
        }
        if ($line -match '^\s*$') { continue }
        $para = $line.Trim()
    }
    if ($null -ne $para -and $null -ne $curNotes) {
        $t = Format-ChangelogNoteLine $para
        if ($t.Length -gt 0) { [void]$curNotes.Add($t) }
    }
    if ($null -ne $curVer) {
        [void]$sections.Add([pscustomobject]@{ Version = $curVer; Notes = $curNotes })
    }
    return $sections
}

# 8a is an author-side paste helper like 8b -- a failure here must never fail a build
# whose zip is already written (Step 7). Warn-and-skip, matching 8b's posture.
try {
    $clMd = Join-Path $root "CHANGELOG.md"
    $utf8 = [Text.UTF8Encoding]::new($false)
    if (-not (Test-Path $clMd)) {
        Write-Host "  WARN: CHANGELOG.md missing -- skipping plain-text dumps" -ForegroundColor Yellow
    } else {
        $sections = @(Get-ChangelogNotesByVersion $clMd)
        # Full history: version marker line, then one line per change (no blanks, no dashes).
        # Split on the version lines when filling Nexus Documentation entries.
        $full = [System.Collections.Generic.List[string]]::new()
        foreach ($sec in $sections) {
            [void]$full.Add($sec.Version)
            foreach ($n in $sec.Notes) { [void]$full.Add($n) }
        }
        $clTxt = Join-Path $bbOut "CHANGELOG.txt"
        [IO.File]::WriteAllText($clTxt, (($full -join "`r`n") + "`r`n"), $utf8)
        # One file per version: <version>.txt -- body only (Nexus stores the version field).
        # Sanitize the heading token to a filesystem-safe name so a stray '/' or ':' in a
        # CHANGELOG heading can't throw on the path and abort an otherwise-good build.
        $nVer = 0
        foreach ($sec in $sections) {
            $safeVer = ($sec.Version -replace '[^0-9A-Za-z._-]', '_')
            $body = if ($sec.Notes.Count -eq 0) { '' } else { ($sec.Notes -join "`r`n") + "`r`n" }
            [IO.File]::WriteAllText((Join-Path $bbOut "$safeVer.txt"), $body, $utf8)
            $nVer++
        }
        Write-Host "  plain: CHANGELOG.txt + $nVer version file(s) (e.g. $Version.txt) -> dist\bbcode\"
    }
} catch {
    Write-Host "  WARN: plain-text changelog dump failed ($_) -- skipping (the mod zip is unaffected)." -ForegroundColor Yellow
}

& dotnet tool restore 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "  WARN: 'dotnet tool restore' failed -- skipping BBCode (the mod zip is unaffected)." -ForegroundColor Yellow
} else {
    # English manual only -- other languages live on GitHub; Nexus article titles are not i18n.
    $manualEn = Join-Path $root "docs\manual.md"
    $bbFile = Join-Path $bbOut "manual.en.bb"
    if (-not (Test-Path $manualEn)) {
        Write-Host "  WARN: docs\manual.md missing -- skipping BBCode" -ForegroundColor Yellow
    } else {
        & dotnet tool run markdown_to_bbcodenm -i $manualEn -o $bbFile 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0 -and (Test-Path $bbFile)) {
            Write-Host "  bbcode: manual.en.bb -> dist\bbcode\"
        } else {
            Write-Host "  WARN: BBCode conversion failed for manual.md" -ForegroundColor Yellow
        }
    }
}

Write-Host "`nBUILD OK -> $zip" -ForegroundColor Green
Get-ChildItem $pkg -Recurse -File | ForEach-Object { "  " + $_.FullName.Substring($pkg.Length + 1) } | Sort-Object
