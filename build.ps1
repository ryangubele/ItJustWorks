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

foreach ($psc in @("fth_IJW_Watcher.psc", "fth_IJW_MCM.psc")) {
    $src = Join-Path $root "scripts\$psc"
    & $compiler $src -i="$importPath" -o="$scriptsOut" -f="$flags"
    if ($LASTEXITCODE -ne 0) { Fail "PapyrusCompiler failed on $psc (exit $LASTEXITCODE)" }
}
$pex = Get-ChildItem $scriptsOut -Filter *.pex
if ($pex.Count -lt 2) { Fail "expected 2 .pex, got $($pex.Count)" }
Write-Host "  compiled: $($pex.Name -join ', ')"

# --- 3. Scrub .pex identity --------------------------------------------------
Step 3 "Scrub .pex headers"
$compileEpoch = Resolve-CompileTime
& dotnet run --project (Join-Path $root "src\Fth.ItJustWorks.PexScrub") -c Release -- `
    --time $compileEpoch (Join-Path $scriptsOut "*.pex")
if ($LASTEXITCODE -ne 0) { Fail "PexScrub exited $LASTEXITCODE" }

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

# stamp version into the MCM "Version" footer row (not the menu name)
$cfgPath = Join-Path $pkg "MCM\Config\fth_ItJustWorks\config.json"
$cfg = Get-Content $cfgPath -Raw
$cfg = $cfg -replace '("text"\s*:\s*")Version \d+\.\d+\.\d+(")', "`${1}Version $Version`${2}"
Set-Content -Path $cfgPath -Value $cfg -Encoding UTF8

# FOMOD installer, two steps:
#   1. "Extra language files" - opt-in checkboxes; each installs its own
#      fth_ItJustWorks_<LANG>.txt (the file the game reads when its language matches)
#      and raises a flag so step 2 can offer it.
#   2. "Default menu language" - one radio pick that overwrites the ENGLISH file the
#      game reads on an English-language install (and drops an English .bak sidecar so the
#      original strings can be restored by rename). English is the default; every other
#      option is greyed out until its box is ticked in step 1. Picking one there installs
#      BOTH language files, so the menu shows through whatever the game's language is.
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
$fomodDescPath = Join-Path $root "packaging\fomod-descriptions.json"
if (-not (Test-Path $fomodDescPath)) { Fail "FOMOD: missing packaging\fomod-descriptions.json" }
$fomodDesc = Get-Content $fomodDescPath -Raw -Encoding UTF8 | ConvertFrom-Json
$engRel = "Interface\translations\fth_ItJustWorks_ENGLISH.txt"
$fomodLangFiles = ""   # step 1: install the native-name file, raise a flag
$fomodDefaults  = ""   # step 2: overwrite ENGLISH (+ English .bak), greyed until the step-1 flag is set
foreach ($lang in $fomodLangs.Keys) {
    $rel = "Interface\translations\fth_ItJustWorks_$lang.txt"
    if (-not (Test-Path (Join-Path $pkg $rel))) { Fail "FOMOD: missing translation $rel" }
    if (-not ($fomodDesc.PSObject.Properties.Name -contains $lang)) { Fail "FOMOD: no descriptions for $lang in fomod-descriptions.json" }
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
# and an English .bak sidecar is preserved); and no shipped file is left unreferenced.
# GetAttribute + SelectNodes throughout: the "English (default)" option has no <files>, and
# property access on a missing node/attribute trips Set-StrictMode.
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
# sidecar, and (c) gate on a flagDependency that a step-1 checkbox actually raises.
if ($defPlugins.Count -ne 10) { Fail "FOMOD: expected 10 default-language options (English + 9), got $($defPlugins.Count)" }
$transNodes = @($defFileNodes | Where-Object { $_.GetAttribute('destination') -match 'fth_ItJustWorks_ENGLISH\.txt$' })
$bakNodes   = @($defFileNodes | Where-Object { $_.GetAttribute('destination') -match 'fth_ItJustWorks_ENGLISH\.txt\.bak$' })
if ($transNodes.Count -ne 9) { Fail "FOMOD: expected 9 default-language overwrites of the ENGLISH file, got $($transNodes.Count)" }
if ($bakNodes.Count   -ne 9) { Fail "FOMOD: expected 9 English .bak sidecars, got $($bakNodes.Count)" }
foreach ($f in $transNodes) {
    if ($f.GetAttribute('source') -match 'ENGLISH')  { Fail "FOMOD: a default-language overwrite sources the ENGLISH file; it must source a translation" }
    if ($f.GetAttribute('priority') -ne '1')         { Fail "FOMOD: a default-language overwrite must be priority 1 to outrank the required ENGLISH file" }
}
foreach ($f in $bakNodes) {
    if ($f.GetAttribute('source') -notmatch 'fth_ItJustWorks_ENGLISH\.txt$') { Fail "FOMOD: the .bak sidecar must source the ENGLISH file, got '$($f.GetAttribute('source'))'" }
}
$step2Deps = @($defStep.SelectNodes('.//plugin/typeDescriptor/dependencyType/patterns/pattern/dependencies/flagDependency') | ForEach-Object { $_.GetAttribute('flag') })
if ($step2Deps.Count -ne 9) { Fail "FOMOD: expected 9 default-language flag dependencies, got $($step2Deps.Count)" }
foreach ($dep in $step2Deps)  { if ($step1Flags -notcontains $dep)  { Fail "FOMOD: default-language option depends on flag '$dep' that no step-1 checkbox raises" } }
foreach ($flag in $step1Flags) { if ($step2Deps -notcontains $flag) { Fail "FOMOD: step-1 flag '$flag' is raised but no default-language option consumes it" } }

$fomodOrphans = @(Get-ChildItem $pkg -Recurse -File | Where-Object { $_.FullName -notlike "*\fomod\*" -and -not $fomodRefs.Contains($_.FullName.ToLower()) })
if ($fomodOrphans.Count -gt 0) { Fail "FOMOD: $($fomodOrphans.Count) shipped file(s) not referenced, would not install: $($fomodOrphans.Name -join ', ')" }
Write-Host "  fomod: valid; all $($fomodRefs.Count) shipped files referenced; 9 checkboxes + 10 default options; flags linked, priorities correct, English .bak preserved"

# --- 7. Zip ------------------------------------------------------------------
Step 7 "Package"
$zip = Join-Path $dist "It Just Works $Version.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $pkg "*") -DestinationPath $zip -Force

# --- 8. Nexus BBCode docs (NOT shipped in the zip) ---------------------------
# Convert the markdown docs to NexusMods-flavour BBCode for pasting into the mod
# page: manuals -> Articles, README -> description, CHANGELOG -> changelog. Uses
# the pinned dotnet tool in .config/dotnet-tools.json (BUTR's md->NexusMods-BBCode
# converter); its manifest rollForward lets that .NET 7 tool run on the installed
# runtime with no extra flags. Non-critical: a hiccup here warns and skips -- these
# are author-side upload helpers, never part of the shipped archive.
Step 8 "Nexus BBCode docs"
$bbOut = Join-Path $dist "bbcode"
if (Test-Path $bbOut) { Remove-Item $bbOut -Recurse -Force }
New-Item -ItemType Directory -Force $bbOut | Out-Null
& dotnet tool restore 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "  WARN: 'dotnet tool restore' failed -- skipping BBCode docs (the mod zip is unaffected)." -ForegroundColor Yellow
} else {
    # manual.md -> manual.en.bb; manual.<lang>.md keeps its language; README/CHANGELOG by name.
    $srcDocs = @(Get-ChildItem (Join-Path $root "docs") -Filter "manual*.md" -File)
    $srcDocs += Get-Item (Join-Path $root "README.md")
    $srcDocs += Get-Item (Join-Path $root "CHANGELOG.md")
    $bbOk = 0
    foreach ($doc in $srcDocs) {
        $name = if ($doc.BaseName -eq "manual") { "manual.en" } else { $doc.BaseName }
        $bbFile = Join-Path $bbOut "$name.bb"
        & dotnet tool run markdown_to_bbcodenm -i $doc.FullName -o $bbFile 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0 -and (Test-Path $bbFile)) { $bbOk++ }
        else { Write-Host "  WARN: BBCode conversion failed for $($doc.Name)" -ForegroundColor Yellow }
    }
    Write-Host "  bbcode: $bbOk file(s) -> dist\bbcode\  (NB: the converter flattens markdown tables -- hand-fix the README's one if you use it)"
}

Write-Host "`nBUILD OK -> $zip" -ForegroundColor Green
Get-ChildItem $pkg -Recurse -File | ForEach-Object { "  " + $_.FullName.Substring($pkg.Length + 1) } | Sort-Object
