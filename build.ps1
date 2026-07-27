# Copyright (c) 2026 Ryan Gubele
# SPDX-License-Identifier: MPL-2.0
#
# mutagen -> papyrus -> scrub -> assemble -> metadata -> verify gate -> zip.
# Versioned outputs read VERSION (no hardcoded X.Y.Z).
#
# No git writes. Clean-tree HEAD commit date stamps .pex compile time when set;
# git is optional and read-only for that.

[CmdletBinding()]
param(
    [string]$GameRoot = "",  # install root; else $env:SKYRIM_SE_PATH; else auto-detected
    [string]$Website = "https://www.nexusmods.com/skyrimspecialedition/mods/185927",  # Nexus mod page; stamped into fomod/info.xml
    [string]$Repo = "https://github.com/ryangubele/ItJustWorks",  # source repo, stamped into the license breadcrumb; override for forks
    [string]$Author = "Ryan Gubele",  # lead copyright holder in the license breadcrumb; override for a fork or on handover
    [switch]$SkipSanitization,  # outside builders with no identity of ours to strip
    [switch]$VerifyPublicLink   # release checklist: confirm -Repo actually resolves (the only network read)
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$root = $PSScriptRoot
Set-Location $root

function Fail($msg) { Write-Host "BUILD FAILED: $msg" -ForegroundColor Red; exit 1 }
function Step($n, $msg) { Write-Host "`n[$n] $msg" -ForegroundColor Cyan }

# SE root: SkyrimSE.exe present (Steam/GOG).
function Test-SE([string]$c) { return ($c -and (Test-Path (Join-Path $c "SkyrimSE.exe"))) }

# Auto-detect: Steam registry + libraryfolders.vdf, then common Steam/GOG paths.
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

# .pex compile time (unix seconds). Precedence: SOURCE_DATE_EPOCH -> clean HEAD %ct -> now.
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

# Install root: -GameRoot, else $env:SKYRIM_SE_PATH, else auto-detect.
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
# Toast bake: $fth_IJW_Toast_* tables -> fth_IJW_Toasts.psc. Missing cell -> English.
# Non-ASCII -> __IJW_*__ placeholders; PexScrub --replace writes UTF-8 after compile.
# $langOrder index matches MCM iToastLang and FOMOD seeds.
$langOrder = @("ENGLISH","FRENCH","GERMAN","ITALIAN","SPANISH","POLISH","RUSSIAN","CHINESE","JAPANESE","CZECH")
$toastAllow = @("Alert","NamesOff","StopOk","StopFail","StopChanged","StopNoAction","HotkeyInScene","HotkeyNoScene")
$toastByKey = [ordered]@{}
$toastCellSource = @{}
for ($li = 0; $li -lt $langOrder.Count; $li++) {
    $tp = Join-Path $root ("interface\translations\fth_ItJustWorks_{0}.txt" -f $langOrder[$li])
    if (-not (Test-Path $tp)) { Fail "bake: missing translation table $tp" }
    $tln = 0
    foreach ($line in ([IO.File]::ReadAllText($tp, [Text.Encoding]::Unicode) -split "`r?`n")) {
        $tln++
        if ($line -match '^(\$fth_IJW_Toast_[A-Za-z0-9_]+)\t(.*)$') {
            $k = $Matches[1]; $v = $Matches[2]
            $fn = $k -replace '^\$fth_IJW_Toast_',''
            if ($toastAllow -notcontains $fn) {
                Fail "bake: unexpected toast key $k (allow-list: $($toastAllow -join ', '))"
            }
            $cell = "$($langOrder[$li])|$k"
            if ($toastCellSource.ContainsKey($cell)) {
                Fail "bake: duplicate cell $k in $(Split-Path $tp -Leaf) -- first at line $($toastCellSource[$cell]), again at line $tln. Remove one; the later value must not silently win."
            }
            $toastCellSource[$cell] = $tln
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
[void]$sb.AppendLine("; Copyright (c) 2026 $Author")
[void]$sb.AppendLine("; SPDX-License-Identifier: MPL-2.0")
[void]$sb.AppendLine(";")
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
# Import: headers, scripts, then SKSE Source before vanilla Source (order matters).
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
$mcmOut = Join-Path $pkg "MCM"; New-Item -ItemType Directory -Force $mcmOut | Out-Null
Copy-Item (Join-Path $root "mcm\Config") $mcmOut -Recurse
$ifOut = Join-Path $pkg "Interface"; New-Item -ItemType Directory -Force $ifOut | Out-Null
Copy-Item (Join-Path $root "interface\translations") $ifOut -Recurse

# --- 5. Metadata (from $Version) --------------------------------------------
Step 5 "Metadata"
$fomodDir = Join-Path $pkg "fomod"
New-Item -ItemType Directory -Force $fomodDir | Out-Null
$tmpl = Get-Content (Join-Path $root "packaging\fomod-info.xml.tmpl") -Raw
$info = $tmpl.Replace("{{VERSION}}", $Version).Replace("{{WEBSITE}}", $Website).Replace("{{AUTHOR}}", $Author)
Set-Content -Path (Join-Path $fomodDir "info.xml") -Value $info -Encoding UTF8

# fth_ItJustWorks_LICENSE.md at Data root (namespaced; full MPL is LICENSE.txt in repo).
$repoRef = if ($Repo) { $Repo } else {
    Write-Host "  WARN: -Repo not set; breadcrumb points at the mod page instead of the repo" -ForegroundColor Yellow
    "(see the mod's Nexus description page for the source repository link)"
}
$licTmpl = Get-Content (Join-Path $root "packaging\license-notice.md.tmpl") -Raw
$lic = $licTmpl.Replace("{{VERSION}}", $Version).Replace("{{REPO}}", $repoRef).Replace("{{AUTHOR}}", $Author)
Set-Content -Path (Join-Path $pkg "fth_ItJustWorks_LICENSE.md") -Value $lic -Encoding UTF8

# Version footer in config.json; UTF-8 no BOM (Helper rejects BOM).
$cfgPath = Join-Path $pkg "MCM\Config\fth_ItJustWorks\config.json"
$utf8NoBom = [Text.UTF8Encoding]::new($false)
$cfg = [IO.File]::ReadAllText($cfgPath, $utf8NoBom)
$cfg = $cfg -replace '("text"\s*:\s*")Version \d+\.\d+\.\d+(")', "`${1}Version $Version`${2}"
if ($cfg.Length -gt 0 -and [int][char]$cfg[0] -eq 0xFEFF) { $cfg = $cfg.Substring(1) }
[IO.File]::WriteAllText($cfgPath, $cfg, $utf8NoBom)

# FOMOD: opt-in langs; default menu language (ENGLISH overwrite, .bak, iToastLang).
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
# FOMOD toast-lang index = $langOrder position.
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

# sanitization\private\*.ps1; -SkipSanitization for outside builders.
$sanRoot = Join-Path $root "sanitization"
$sanDir  = Join-Path $sanRoot "private"
# Active checks only under private\; top-level .ps1 is a stray (not run).
$stray = @(Get-ChildItem $sanRoot -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -eq ".ps1" })
if ($stray.Count -gt 0) {
    Write-Host "  WARN: $($stray.Count) .ps1 at sanitization\ top level - NOT run, NOT gitignored. Move active checks to sanitization\private\: $($stray.Name -join ', ')" -ForegroundColor Yellow
}
$sanScripts = @()
# Exact .ps1 only (not -Filter "*.ps1"; 8.3 can match .ps1.example).
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

$infoText = Get-Content (Join-Path $fomodDir "info.xml") -Raw
if ($infoText -notmatch [regex]::Escape($Version)) { Fail "version $Version missing from fomod/info.xml" }

$espBytes = [IO.File]::ReadAllBytes((Join-Path $pkg "fth_ItJustWorks.esp"))
if (-not (Contains-Bytes $espBytes ([Text.Encoding]::ASCII.GetBytes("v$Version")))) {
    Fail "version v$Version missing from ESP header description"
}

# SEQ: one StartGameEnabled quest, 4-byte LE file FormID, ESL window, dword in ESP.
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

# FOMOD: sources exist; default-lang wiring; no orphan files. GetAttribute (StrictMode).
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

if ($langPlugins.Count -ne 9) { Fail "FOMOD: expected 9 language checkboxes, got $($langPlugins.Count)" }
if (@($langFileNodes | Where-Object { $_.GetAttribute('source') -match 'ENGLISH' }).Count -gt 0) { Fail "FOMOD: ENGLISH must be required, not an optional checkbox" }
$step1Flags = @($langStep.SelectNodes('.//plugin/conditionFlags/flag') | ForEach-Object { $_.GetAttribute('name') })
if ($step1Flags.Count -ne 9) { Fail "FOMOD: expected 9 step-1 condition flags, got $($step1Flags.Count)" }

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

# Folder sources install everything under them. Deny junk; require exact known sets.
$strayUnderFolders = @(Get-ChildItem (Join-Path $pkg "Scripts"), (Join-Path $pkg "MCM"), (Join-Path $pkg "SEQ") -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object {
        $n = $_.Name
        $n -match '\.(bak|orig|tmp|swp|rej)$' -or $n -match '~$' -or $n -like '*.bak.*' -or $n -like '*~' -or $n -eq 'Thumbs.db' -or $n -eq '.DS_Store'
    })
if ($strayUnderFolders.Count -gt 0) {
    Fail "FOMOD: stray backup/temp file(s) under Scripts/MCM/SEQ would ship: $($strayUnderFolders.FullName -join ', ')"
}
$expectScript = @("fth_IJW_Watcher.pex", "fth_IJW_MCM.pex", "fth_IJW_Toasts.pex") | ForEach-Object { $_.ToLower() }
$gotScript = @(Get-ChildItem (Join-Path $pkg "Scripts") -File -ErrorAction SilentlyContinue | ForEach-Object { $_.Name.ToLower() }) | Sort-Object
$expScriptSorted = @($expectScript | Sort-Object)
if (($gotScript -join "|") -ne ($expScriptSorted -join "|")) {
    Fail "FOMOD: Scripts/ must be exactly $($expectScript -join ', '); got: $($gotScript -join ', ')"
}
$mcmCfg = Join-Path $pkg "MCM\Config\fth_ItJustWorks"
$expectMcm = @("config.json", "settings.ini") | ForEach-Object { $_.ToLower() }
$gotMcm = @(Get-ChildItem $mcmCfg -File -ErrorAction SilentlyContinue | ForEach-Object { $_.Name.ToLower() }) | Sort-Object
$extraMcm = @(Get-ChildItem (Join-Path $pkg "MCM") -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notlike "*\Config\fth_ItJustWorks\*" })
if ($extraMcm.Count -gt 0) {
    Fail "FOMOD: unexpected file(s) under MCM/ outside Config/fth_ItJustWorks: $($extraMcm.Name -join ', ')"
}
if (($gotMcm -join "|") -ne (($expectMcm | Sort-Object) -join "|")) {
    Fail "FOMOD: MCM/Config/fth_ItJustWorks/ must be exactly config.json + settings.ini; got: $($gotMcm -join ', ')"
}
$gotSeq = @(Get-ChildItem (Join-Path $pkg "SEQ") -File -ErrorAction SilentlyContinue | ForEach-Object { $_.Name.ToLower() })
if ($gotSeq.Count -ne 1 -or $gotSeq[0] -ne "fth_itjustworks.seq") {
    Fail "FOMOD: SEQ/ must contain only fth_ItJustWorks.seq; got: $($gotSeq -join ', ')"
}
Write-Host "  fomod: valid; all $($fomodRefs.Count) shipped files referenced; folder trees exact; 9 checkboxes + 10 default options; flags linked; ENGLISH overwrite + .bak + iToastLang seed"

# --- Papyrus source gates -----------------------------------------------------
# Invoke-PapyrusSourceGates $root: throws (not Fail) so fixtures can catch rejections.
function Invoke-PapyrusSourceGates([string]$gateRoot) {
    $watcherSrc = Join-Path $gateRoot "scripts\fth_IJW_Watcher.psc"
    $mcmSrc     = Join-Path $gateRoot "scripts\fth_IJW_MCM.psc"
    $toastSrc   = Join-Path $gateRoot "scripts\fth_IJW_Toasts.psc"
    $pscPaths   = @($watcherSrc, $mcmSrc, $toastSrc)
    foreach ($p in $pscPaths) { if (-not (Test-Path $p)) { Fail "source gate: missing $p" } }
    $watcherText = Get-Content $watcherSrc -Raw -Encoding UTF8

    # No GetCurrentRealTime (session clock).
    if ($watcherText -match 'GetCurrentRealTime') {
        $hits = @([regex]::Matches($watcherText, '(?m)^.*GetCurrentRealTime.*$') | ForEach-Object { $_.Value.Trim() })
        throw "process-clock gate: GetCurrentRealTime appears in fth_IJW_Watcher.psc ($($hits.Count) line(s)). Timing is save-relative (Game.GetRealHoursPassed): $($hits[0])"
    }

    # Retired accumulator symbols (denylist).
    $accumulatorDeny = @(
        'fAccReal', 'fSampleReal', 'fSampleGame', 'fSampleTs', 'bSampleInited',
        'bRateWasUsable', 'bSampleHeld', 'iRecoverPollsLeft',
        'ObserveAndAccumulate', 'InvalidateSample', 'SeedObservation'
    )
    $accHits = @()
    foreach ($p in @($watcherSrc, $mcmSrc)) {
        $txt = Get-Content $p -Raw -Encoding UTF8
        foreach ($sym in $accumulatorDeny) {
            if ($txt -match [regex]::Escape($sym)) { $accHits += "$(Split-Path $p -Leaf):$sym" }
        }
    }
    if ($accHits.Count -gt 0) {
        throw "accumulator ratchet: retired interval-accumulator symbol(s) present: $($accHits -join ', '). The endpoint clock replaces them; do not port them under new names."
    }

    # Dead helpers: zero refs outside own def. Events only if kind+script in $eventsFor.
    $eventsFor = @{
        'fth_IJW_Watcher.psc' = @('OnInit', 'OnUpdate', 'OnKeyDown')
        'fth_IJW_MCM.psc'     = @('OnConfigInit', 'OnConfigOpen', 'OnConfigClose', 'OnSettingChange')
        'fth_IJW_Toasts.psc'  = @()
    }
    function Remove-PapyrusNoise([string]$text) {
        $t = [regex]::Replace($text, '"[^"]*"', '""')
        return [regex]::Replace($t, '(?m);.*$', '')
    }
    $refCorpus = ""
    foreach ($p in $pscPaths) { $refCorpus += (Remove-PapyrusNoise (Get-Content $p -Raw -Encoding UTF8)) + "`n" }
    # MCM Helper "function" names (bare) = refs on the MCM script only.
    $cfgCallbacks = @([regex]::Matches(
        (Get-Content (Join-Path $gateRoot "mcm\Config\fth_ItJustWorks\config.json") -Raw -Encoding UTF8),
        '"function"\s*:\s*"([A-Za-z_][A-Za-z0-9_]*)"') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
    # Case-insensitive matchers (Papyrus).
    $defPat = [regex]'(?im)^\s*(?:(?:[A-Za-z_][A-Za-z0-9_]*(?:\[\])?)\s+)?(Function|Event)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\('
    $deadHelpers = @()
    $watcherVars = @([regex]::Matches($refCorpus, '(?im)fth_IJW_Watcher\s+([A-Za-z_][A-Za-z0-9_]*)\s*=') |
        ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
    $receiversFor = @{
        'fth_IJW_Watcher.psc' = @(@('GetWatcher\(\)') + @($watcherVars | ForEach-Object { [regex]::Escape($_) }))
        'fth_IJW_Toasts.psc'  = @('fth_IJW_Toasts')
        'fth_IJW_MCM.psc'     = @()
    }
    foreach ($p in $pscPaths) {
        $txt = Remove-PapyrusNoise (Get-Content $p -Raw -Encoding UTF8)
        $leaf = Split-Path $p -Leaf
        foreach ($m in $defPat.Matches($txt)) {
            $kind = $m.Groups[1].Value
            $name = $m.Groups[2].Value
            if ($kind -match '(?i)^Event$' -and ($eventsFor[$leaf] -contains $name)) { continue }
            if ($kind -match '(?i)^Function$' -and $leaf -eq 'fth_IJW_MCM.psc' -and ($cfgCallbacks -contains $name)) { continue }
            $bare = @([regex]::Matches($txt, '(?i)(?<![A-Za-z0-9_.])' + [regex]::Escape($name) + '\s*\(')).Count
            $ownDefs = @($defPat.Matches($txt) | Where-Object { $_.Groups[2].Value -eq $name }).Count
            $qualified = 0
            foreach ($rx in $receiversFor[$leaf]) {
                # Word-boundary on receiver so `w` does not match the tail of `show`.
                $qualified += @([regex]::Matches($refCorpus,
                    '(?i)(?<![A-Za-z0-9_])(?:' + $rx + ')\s*\.\s*' + [regex]::Escape($name) + '\s*\(')).Count
            }
            if ((($bare - $ownDefs) + $qualified) -le 0) { $deadHelpers += "${leaf}:$kind $name" }
        }
    }
    if ($deadHelpers.Count -gt 0) {
        throw "dead-helper gate: $($deadHelpers.Count) zero-reference declaration(s): $($deadHelpers -join ', '). Delete them, or if the engine really calls it, add it to `$eventsFor for the owning script."
    }

    # Log/LogTerminal: formatted calls under literal `if iLogLevel >= LOG_*` (eager args).
    function Get-LogGuardViolations([string]$path) {
        $bad = @()
        $curFn = ""
        $lines = Get-Content $path -Encoding UTF8
        $prev = @($null) * $lines.Count
        $lastMeaningful = ""
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $prev[$i] = $lastMeaningful
            $t = $lines[$i].Trim()
            if ($t -ne "" -and -not $t.StartsWith(";")) { $lastMeaningful = $t }
        }
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            # Blank string interiors before ';' (a quote-semicolon is not a comment).
            $blanked = [regex]::Replace($line, '"[^"]*"', { param($m) '"' + (' ' * ($m.Value.Length - 2)) + '"' })
            $cut = $blanked.IndexOf(';')
            if ($cut -ge 0) { $blanked = $blanked.Substring(0, $cut) }
            $code = $blanked
            $leaf = Split-Path $path -Leaf
            $where = "$leaf line $($i + 1)"
            # Track enclosing function name (Log / LogTerminal sinks).
            if ($code -match '^\s*(?:[A-Za-z_][A-Za-z0-9_]*(?:\[\])?\s+)?(?:Function|Event)\s+([A-Za-z_][A-Za-z0-9_]*)') {
                $curFn = $Matches[1]
                continue
            }
            if ($code -match '^\s*End(Function|Event)\b') { $curFn = "" }

            foreach ($m in [regex]::Matches($code, '(?<![A-Za-z0-9_])Log\s*\(\s*([^,]+),')) {
                $lvl = $m.Groups[1].Value.Trim()
                if ($lvl -notmatch '^LOG_(OFF|EVENTS|CHECK)$') {
                    $bad += "$where : Log() called with non-literal level '$lvl'"
                    continue
                }
                $tail = $code.Substring($m.Index)
                # Call must close on this line (no multi-line Log/Trace).
                $opens = ([regex]::Matches($tail, '\(')).Count
                $closes = ([regex]::Matches($tail, '\)')).Count
                if ($opens -ne $closes) {
                    $bad += "$where : Log($lvl, ...) does not close on one line; the guarded form must be single-line"
                    continue
                }
                # Blank literals; + or a call in the arg is eager (e.g. SceneKey(x)).
                $argCode = [regex]::Replace($tail, '"[^"]*"', '""')
                $argCode = $argCode.Substring($argCode.IndexOf(',') + 1)
                $needsGuard = ($argCode -match '\+') -or ($argCode -match '[A-Za-z_][A-Za-z0-9_]*\s*\(')
                if ($needsGuard) {
                    $g = $prev[$i]
                    if ($g -notmatch [regex]::Escape("iLogLevel >= $lvl")) {
                        $bad += "$where : Log($lvl, ...) builds its argument but is not directly under 'if iLogLevel >= $lvl' (saw: '$g')"
                    } elseif ($g -match '\|\|') {
                        $bad += "$where : level guard uses OR, which makes the formatted line reachable below $lvl"
                    } elseif ($g -match '!\s*\(?\s*iLogLevel' -or $g -match 'iLogLevel\s*<') {
                        $bad += "$where : level guard is inverted"
                    }
                }
            }

            if ($code -match '(?<![A-Za-z0-9_])LogTerminal\s*\(') {
                $g = $prev[$i]
                if ($g -notmatch [regex]::Escape("iLogLevel >= LOG_CHECK")) {
                    $bad += "$where : LogTerminal() is not directly under 'if iLogLevel >= LOG_CHECK' (saw: '$g')"
                } elseif ($g -match '\|\|') {
                    $bad += "$where : LogTerminal() guard uses OR"
                } elseif ($g -match '!\s*\(?\s*iLogLevel' -or $g -match 'iLogLevel\s*<') {
                    $bad += "$where : LogTerminal() guard is inverted"
                }
            }

            if ($code -match 'Debug\.Trace\s*\(') {
                $inSink = ($curFn -eq 'Log') -or ($curFn -eq 'LogTerminal')
                # Same eager rule as Log; count parens from "Debug.Trace(".
                $traceTail = $code.Substring($code.IndexOf('Debug.Trace(') + 11)
                $traceArg = [regex]::Replace($traceTail.Substring(1), '"[^"]*"', '""')
                if (([regex]::Matches($traceTail, '\(')).Count -ne ([regex]::Matches($traceTail, '\)')).Count) {
                    $bad += "$where : Debug.Trace() does not close on one line; the checkable form is single-line"
                } else {
                    $isLiteral = -not (($traceArg -match '\+') -or ($traceArg -match '[A-Za-z_][A-Za-z0-9_]*\s*\('))
                    if (-not $inSink -and -not $isLiteral) {
                        $bad += "$where : Debug.Trace() formats outside the approved Log/LogTerminal sinks"
                    }
                }
            }
        }
        return $bad
    }
    $logBad = @()
    foreach ($p in @($watcherSrc, $mcmSrc)) { $logBad += Get-LogGuardViolations $p }
    if ($logBad.Count -gt 0) {
        throw ("log-level guard: $($logBad.Count) violation(s):`n    " + ($logBad -join "`n    "))
    }
    Write-Host "  papyrus: no process clock, no accumulator symbols, no dead helpers, log levels gated"

    # config.json ids must have matching settings.ini keys.
    $cfgSrc = Get-Content (Join-Path $gateRoot "mcm\Config\fth_ItJustWorks\config.json") -Raw -Encoding UTF8
    $cfgIds = @([regex]::Matches($cfgSrc, '"id"\s*:\s*"([A-Za-z0-9_]+):([A-Za-z0-9_]+)"') |
        ForEach-Object { "$($_.Groups[2].Value)/$($_.Groups[1].Value)" } | Sort-Object -Unique)
    $iniText = Get-Content (Join-Path $gateRoot "mcm\Config\fth_ItJustWorks\settings.ini") -Raw -Encoding UTF8
    $iniKeys = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $section = ""
    foreach ($line in ($iniText -split "`r?`n")) {
        if ($line -match '^\s*\[([^\]]+)\]\s*$') { $section = $Matches[1]; continue }
        if ($line -match '^\s*([A-Za-z0-9_]+)\s*=') { [void]$iniKeys.Add("$section/$($Matches[1])") }
    }
    $missingIni = @($cfgIds | Where-Object { -not $iniKeys.Contains($_) })
    if ($missingIni.Count -gt 0) {
        throw "MCM settings gate: $($missingIni.Count) config.json id(s) with no settings.ini backing: $($missingIni -join ', ')"
    }
    $unusedIni = @($iniKeys | Where-Object { $cfgIds -notcontains $_ } | Sort-Object)
    if ($unusedIni.Count -gt 0) {
        throw "MCM settings gate: $($unusedIni.Count) settings.ini key(s) no config.json id reads: $($unusedIni -join ', ')"
    }
    Write-Host "  mcm: $($cfgIds.Count) config ids all backed by settings.ini, no orphan keys"
}
try { Invoke-PapyrusSourceGates $root } catch { Fail $_.Exception.Message }

# --- Source-gate negative fixtures --------------------------------------------
# Mutate a staged tree; Invoke-PapyrusSourceGates must throw. Control must pass.
$gfx = Join-Path $dist "gatefixtures"
function Reset-GateStage {
    if (Test-Path $gfx) { Remove-Item $gfx -Recurse -Force }
    New-Item -ItemType Directory -Force $gfx | Out-Null
    Copy-Item (Join-Path $root "scripts") $gfx -Recurse
    Copy-Item (Join-Path $root "mcm") $gfx -Recurse
}
function Test-GateStage { try { Invoke-PapyrusSourceGates $gfx *> $null; return $null } catch { return $_.Exception.Message } }
# Log-rule fixtures: call from OnUpdate so dead-helper does not fire first.
function Add-LiveLeak([string]$bodyLines) {
    $f = "$gfx\scripts\fth_IJW_Watcher.psc"
    $t = Get-Content $f -Raw -Encoding UTF8
    $t = [regex]::Replace($t, '(?m)^(Event OnUpdate\(\)\r?\n)', "`${1}    LeakFixture()`r`n", 1)
    Set-Content $f -Value ($t + "`r`nFunction LeakFixture()`r`n$bodyLines`r`nEndFunction`r`n") -Encoding UTF8
}
# expect = substring in throw message; mustPass = legal source (no throw).
$gateCases = [ordered]@{
    'process clock in watcher'   = @{ expect = 'process-clock gate';  do = { Add-Content "$gfx\scripts\fth_IJW_Watcher.psc" "`nfloat Function Oops()`n    return Utility.GetCurrentRealTime()`nEndFunction" } }
    'accumulator field'          = @{ expect = 'accumulator ratchet'; do = { Add-Content "$gfx\scripts\fth_IJW_Watcher.psc" "`nfloat fAccReal" } }
    'accumulator helper'         = @{ expect = 'accumulator ratchet'; do = { Add-Content "$gfx\scripts\fth_IJW_Watcher.psc" "`nFunction SeedObservation()`nEndFunction" } }
    'zero-reference helper'      = @{ expect = 'dead-helper gate';    do = { Add-Content "$gfx\scripts\fth_IJW_Watcher.psc" "`nint Function NobodyCallsThis()`n    return 1`nEndFunction" } }
    'helper referenced only in a comment' = @{ expect = 'dead-helper gate'; do = { Add-Content "$gfx\scripts\fth_IJW_Watcher.psc" "`n; see NobodyCallsThis() for details`nint Function NobodyCallsThis()`n    return 1`nEndFunction" } }
    'helper borrowing an unrelated native' = @{ expect = 'dead-helper gate'; do = { Add-Content "$gfx\scripts\fth_IJW_Watcher.psc" "`nint Function GetFormID()`n    return 0`nEndFunction" } }
    'helper borrowing an MCM callback name' = @{ expect = 'dead-helper gate'; do = { Add-Content "$gfx\scripts\fth_IJW_Watcher.psc" "`nFunction Refresh()`nEndFunction" } }
    'watcher Function wearing an event name' = @{ expect = 'dead-helper gate'; do = { Add-Content "$gfx\scripts\fth_IJW_Watcher.psc" "`nFunction OnConfigOpen()`nEndFunction" } }
    'MCM Event wearing a callback name'      = @{ expect = 'dead-helper gate'; do = { Add-Content "$gfx\scripts\fth_IJW_MCM.psc" "`nEvent Refresh()`nEndEvent" } }
    'lowercase unused function' = @{ expect = 'dead-helper gate'; do = { Add-Content "$gfx\scripts\fth_IJW_Watcher.psc" "`nint function nobodyCallsThis()`n    return 1`nendfunction" } }
    'receiver suffix lending a call' = @{ expect = 'dead-helper gate'; do = {
        Add-LiveLeak "    Form show = currentScene as Form`r`n    int probe = show.GetFormID()"
        Add-Content "$gfx\scripts\fth_IJW_Watcher.psc" "`nint Function GetFormID()`n    return 0`nEndFunction" } }
    'mixed-case call still counts' = @{ mustPass = $true; do = {
        Add-LiveLeak "    mixedcaseprobe()"
        Add-Content "$gfx\scripts\fth_IJW_Watcher.psc" "`nfunction MixedCaseProbe()`nendfunction" } }
    'dead helper borrowing a same-named callee' = @{ expect = 'dead-helper gate'; do = { Add-Content "$gfx\scripts\fth_IJW_MCM.psc" "`nint Function ModeNow()`n    return 0`nEndFunction" } }
    'ungated formatted log'      = @{ expect = 'is not directly under'; do = { Add-LiveLeak "    Log(LOG_EVENTS, `"leak `" + iHotkeyCode)" } }
    'ungated eager call arg'     = @{ expect = 'is not directly under'; do = { Add-LiveLeak "    Log(LOG_EVENTS, SceneKey(currentScene))" } }
    'OR bypass on the guard'     = @{ expect = 'guard uses OR';        do = { Add-LiveLeak "    if iLogLevel >= LOG_EVENTS || bEnabled`r`n        Log(LOG_EVENTS, `"x `" + iHotkeyCode)`r`n    endif" } }
    'inverted guard'             = @{ expect = 'is not directly under'; do = { Add-LiveLeak "    if iLogLevel < LOG_EVENTS`r`n        Log(LOG_EVENTS, `"x `" + iHotkeyCode)`r`n    endif" } }
    'unguarded LogTerminal'      = @{ expect = 'LogTerminal() is not directly under'; do = { Add-LiveLeak "    LogTerminal(`"timer`", None, 0, 0, `"-`", -1.0, -1.0, -1.0, `"-`", -1, `"none`", `"none`", `"-`")" } }
    'variable log level'         = @{ expect = 'non-literal level';    do = { Add-LiveLeak "    Log(iLogLevel, `"x`")" } }
    'multiline log call'         = @{ expect = 'does not close on one line'; do = { Add-LiveLeak "    Log(LOG_EVENTS, `"a`" + \`r`n        `"b`")" } }
    'eager Debug.Trace outside a sink'   = @{ expect = 'outside the approved';       do = { Add-LiveLeak "    Debug.Trace(SceneKey(currentScene))" } }
    'multiline Debug.Trace'      = @{ expect = 'Debug.Trace() does not close on one line'; do = { Add-LiveLeak "    Debug.Trace(\`r`n        SceneKey(currentScene))" } }
    'config id with no ini row'  = @{ expect = 'no settings.ini backing'; do = { $f="$gfx\mcm\Config\fth_ItJustWorks\settings.ini"; (Get-Content $f -Raw) -replace '(?m)^sRateStatus = --\r?\n','' | Set-Content $f -Encoding UTF8 -NoNewline } }
    'ini row no config reads'    = @{ expect = 'no config.json id reads'; do = { Add-Content "$gfx\mcm\Config\fth_ItJustWorks\settings.ini" "sGhost = --" } }
}
Reset-GateStage
$ctl = Test-GateStage
if ($null -ne $ctl) { Fail "source-gate fixtures: the unmutated control failed -- $ctl" }
$gateMissed = @()
foreach ($name in $gateCases.Keys) {
    Reset-GateStage
    & $gateCases[$name].do
    $msg = Test-GateStage
    if ($gateCases[$name].Contains('mustPass')) {
        if ($null -ne $msg) { $gateMissed += "$name (false positive: '$(($msg -split "`n")[0])')" }
    } elseif ($null -eq $msg) {
        $gateMissed += "$name (not caught at all)"
    } elseif ($msg -notmatch [regex]::Escape($gateCases[$name].expect)) {
        $gateMissed += "$name (died on the wrong rule: expected '$($gateCases[$name].expect)', got '$(($msg -split "`n")[0])')"
    }
}
Remove-Item $gfx -Recurse -Force
if ($gateMissed.Count -gt 0) {
    Fail ("source-gate fixtures: $($gateMissed.Count) problem(s):`n    " + ($gateMissed -join "`n    "))
}
$gatePositive = @($gateCases.Keys | Where-Object { $gateCases[$_].Contains('mustPass') }).Count
$gateNegative = $gateCases.Count - $gatePositive
Write-Host "  gate fixtures: control passes; $gateNegative rejecting mutations hit their own rule; $gatePositive legal mutation(s) pass"

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

# --- Translation table gates ---------------------------------------------------
# Invoke-TranslationGates $dir: throws so fixtures can catch.
function Invoke-TranslationGates([string]$transRoot, $usedKeys) {
    $transDir = $transRoot
    $transFiles = @(Get-ChildItem $transDir -Filter "fth_ItJustWorks_*.txt" | Sort-Object Name)
    if ($transFiles.Count -ne 10) { Fail "translation gate: expected 10 language tables, got $($transFiles.Count)" }

    function Get-TranslationKeys([string]$path) {
        # Require UTF-16 LE BOM (FF FE); game mis-decodes BOM-less files.
        $leaf = Split-Path $path -Leaf
        $raw = [IO.File]::ReadAllBytes($path)
        if ($raw.Length -lt 2 -or $raw[0] -ne 0xFF -or $raw[1] -ne 0xFE) {
            throw "translation gate: $leaf has no UTF-16 LE BOM (expected FF FE, got $(('{0:X2} {1:X2}' -f $raw[0], $raw[1])))"
        }
        $text = [IO.File]::ReadAllText($path, [Text.Encoding]::Unicode)
        $set = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        $firstLine = @{}
        $ln = 0
        foreach ($line in ($text -split "`r?`n")) {
            $ln++
            if ($line -match '^\s*$') { continue }
            if ($line -match '^(\$fth_IJW_[A-Za-z0-9_]+)\t(.*)$') {
                $k = $Matches[1]
                if ($Matches[2].Trim() -eq '') {
                    throw "translation gate: $leaf line $ln has key $k with an empty value"
                }
                if (-not $set.Add($k)) {
                    throw "translation gate: $leaf has duplicate key $k -- first at line $($firstLine[$k]), again at line $ln"
                }
                $firstLine[$k] = $ln
            } else {
                throw "translation gate: $leaf line $ln is not `$key<TAB>value"
            }
        }
        return $set
    }

    # Baseline is ENGLISH by name (not first-in-sort; that would be CHINESE).
    $engFile = $transFiles | Where-Object { $_.Name -eq 'fth_ItJustWorks_ENGLISH.txt' }
    if (-not $engFile) { Fail "translation gate: no fth_ItJustWorks_ENGLISH.txt to use as the key-parity baseline" }
    $engKeys = Get-TranslationKeys $engFile.FullName
    if ($engKeys.Count -eq 0) { Fail "translation gate: no keys parsed in the ENGLISH baseline (encoding or format?)" }

    foreach ($tf in $transFiles) {
        $keys = Get-TranslationKeys $tf.FullName
        if ($keys.Count -eq 0) { Fail "translation gate: no keys parsed in $($tf.Name) (encoding or format?)" }
        $missing = @($usedKeys | Where-Object { -not $keys.Contains($_) } | Sort-Object)
        if ($missing.Count -gt 0) {
            throw "translation gate: $($tf.Name) missing $($missing.Count) key(s) used by config/scripts: $($missing -join ', ')"
        }
        # Toast keys come from the bake, not config/script $key literals.
        $orphans = @($keys | Where-Object { -not $usedKeys.Contains($_) -and $_ -notmatch '^\$fth_IJW_Toast_' } | Sort-Object)
        if ($orphans.Count -gt 0) {
            throw "translation gate: $($tf.Name) has $($orphans.Count) orphan key(s) not referenced by config/scripts or the toast bake: $($orphans -join ', ')"
        }
        $onlyHere = @($keys | Where-Object { -not $engKeys.Contains($_) } | Sort-Object)
        $onlyEng  = @($engKeys | Where-Object { -not $keys.Contains($_) } | Sort-Object)
        if ($onlyHere.Count -gt 0 -or $onlyEng.Count -gt 0) {
            throw "translation gate: $($tf.Name) key-set differs from ENGLISH (extra: $($onlyHere -join ', '); missing: $($onlyEng -join ', '))"
        }
    }
    Write-Host "  translations: $($usedKeys.Count) keys used; all 10 tables complete, no orphans, key-sets match"

    # --- Display width (~40 units for MCM rows / notifications; _Help exempt) ---
    $WIDTH_BUDGET = 40
    # Reserve width for prefixes the runtime adds at the call site.
    $widthReserve = @{
        '$fth_IJW_Toast_Alert'         = 6    # + " ~123m" elapsed label
        '$fth_IJW_Toast_HotkeyInScene' = 0    # + scene label; its length is the game's, not ours
    }
    # MCM row budget = label + value (measured ~16 + ~24). Value-only rows omitted.
    $rowLabel = @{
        '$fth_IJW_Heal_None'='$fth_IJW_LastFix'; '$fth_IJW_Heal_Rebaseline'='$fth_IJW_LastFix'
        '$fth_IJW_Heal_Hist'='$fth_IJW_LastFix'; '$fth_IJW_Heal_Player'='$fth_IJW_LastFix'
        '$fth_IJW_Heal_Reassert'='$fth_IJW_LastFix'; '$fth_IJW_Heal_Migrate'='$fth_IJW_LastFix'
        '$fth_IJW_Heal_Rate'='$fth_IJW_LastFix'; '$fth_IJW_Heal_Timing'='$fth_IJW_LastFix'
        '$fth_IJW_Rate_Dual'='$fth_IJW_RateStatus'; '$fth_IJW_Rate_Missing'='$fth_IJW_RateStatus'
        '$fth_IJW_Rate_Frozen'='$fth_IJW_RateStatus'; '$fth_IJW_Rate_Invalid'='$fth_IJW_RateStatus'
        '$fth_IJW_Rate_Backward'='$fth_IJW_RateStatus'
        '$fth_IJW_Loop_Running'='$fth_IJW_LoopStatus'; '$fth_IJW_Loop_Off'='$fth_IJW_LoopStatus'
        '$fth_IJW_Loop_Dormant'='$fth_IJW_LoopStatus'; '$fth_IJW_Loop_Waking'='$fth_IJW_LoopStatus'
        '$fth_IJW_Loop_Late'='$fth_IJW_LoopStatus'
        '$fth_IJW_SceneNone'='$fth_IJW_Scene'
    }
    $widthKeys = @(
        '$fth_IJW_SceneNone',
        '$fth_IJW_Loop_Running','$fth_IJW_Loop_Off','$fth_IJW_Loop_Dormant','$fth_IJW_Loop_Waking','$fth_IJW_Loop_Late',
        '$fth_IJW_Heal_None','$fth_IJW_Heal_Rebaseline','$fth_IJW_Heal_Hist','$fth_IJW_Heal_Player',
        '$fth_IJW_Heal_Reassert','$fth_IJW_Heal_Migrate','$fth_IJW_Heal_Rate','$fth_IJW_Heal_Timing',
        '$fth_IJW_Rate_Dual','$fth_IJW_Rate_Missing','$fth_IJW_Rate_Frozen','$fth_IJW_Rate_Invalid','$fth_IJW_Rate_Backward',
        '$fth_IJW_StopArmed','$fth_IJW_StopCancelled','$fth_IJW_NoScene',
        '$fth_IJW_Toast_Alert','$fth_IJW_Toast_NamesOff','$fth_IJW_Toast_StopOk','$fth_IJW_Toast_StopFail',
        '$fth_IJW_Toast_StopChanged','$fth_IJW_Toast_StopNoAction','$fth_IJW_Toast_HotkeyInScene','$fth_IJW_Toast_HotkeyNoScene'
    )
    # CJK ~2x Latin width.
    function Get-DisplayWidth([string]$s) {
        $w = 0
        foreach ($ch in $s.ToCharArray()) {
            $c = [int]$ch
            if (($c -ge 0x1100 -and $c -le 0x115F) -or ($c -ge 0x2E80 -and $c -le 0xA4CF) -or
                ($c -ge 0xAC00 -and $c -le 0xD7A3) -or ($c -ge 0xF900 -and $c -le 0xFAFF) -or
                ($c -ge 0xFF00 -and $c -le 0xFF60) -or ($c -ge 0xFFE0 -and $c -le 0xFFE6)) { $w += 2 } else { $w += 1 }
        }
        return $w
    }
    $tooWide = @()
    foreach ($tf in $transFiles) {
        $vals = @{}
        foreach ($line in ([IO.File]::ReadAllText($tf.FullName, [Text.Encoding]::Unicode) -split "`r?`n")) {
            if ($line -match '^(\$fth_IJW_[A-Za-z0-9_]+)\t(.*)$') { $vals[$Matches[1]] = $Matches[2] }
        }
        foreach ($k in $widthKeys) {
            if (-not $vals.ContainsKey($k)) { continue }
            $reserve = 0
            if ($widthReserve.ContainsKey($k)) { $reserve = $widthReserve[$k] }
            $label = ''
            if ($rowLabel.ContainsKey($k) -and $vals.ContainsKey($rowLabel[$k])) {
                $label = $vals[$rowLabel[$k]]
                $reserve += (Get-DisplayWidth $label)
            }
            $w = (Get-DisplayWidth $vals[$k]) + $reserve
            if ($w -gt $WIDTH_BUDGET) {
                $lang = $tf.Name -replace '^fth_ItJustWorks_','' -replace '\.txt$',''
                $with = if ($label) { " (with label '$label')" } else { '' }
                $tooWide += "$lang $k = $w$with"
            }
        }
    }
    if ($tooWide.Count -gt 0) {
        throw ("display-width gate: $($tooWide.Count) value/notification string(s) over $WIDTH_BUDGET units (clipped or shrunk in game). Move the detail into the row's _Help, which is exempt:`n    " + ($tooWide -join "`n    "))
    }
    Write-Host "  widths: $($widthKeys.Count) row/notification strings x 10 languages within $WIDTH_BUDGET display units (MCM rows counted with their label)"
}
try { Invoke-TranslationGates (Join-Path $pkg "Interface\translations") $usedKeys } catch { Fail $_.Exception.Message }

# --- Translation-gate negative fixtures ---------------------------------------
# Staged mutations must throw; same pattern as source-gate fixtures.
$tfx = Join-Path $dist "transfixtures"
function Reset-TransStage {
    if (Test-Path $tfx) { Remove-Item $tfx -Recurse -Force }
    New-Item -ItemType Directory -Force $tfx | Out-Null
    Copy-Item (Join-Path $root "interface\translations\*") $tfx
}
function Test-TransStage { try { Invoke-TranslationGates $tfx $usedKeys *> $null; return $null } catch { return $_.Exception.Message } }
function Set-StagedValue([string]$lang, [string]$key, [string]$value) {
    $f = Join-Path $tfx "fth_ItJustWorks_$lang.txt"
    $t = [IO.File]::ReadAllText($f, [Text.Encoding]::Unicode)
    $t = [regex]::Replace($t, '(?m)^(' + [regex]::Escape($key) + '\t).*$', ('${1}' + $value.Replace('$', '$$')))
    [IO.File]::WriteAllText($f, $t, [Text.UnicodeEncoding]::new($false, $true))
}
function Add-StagedLine([string]$lang, [string]$line) {
    $f = Join-Path $tfx "fth_ItJustWorks_$lang.txt"
    $t = [IO.File]::ReadAllText($f, [Text.Encoding]::Unicode)
    [IO.File]::WriteAllText($f, ($t.TrimEnd("`r", "`n") + "`r`n" + $line + "`r`n"), [Text.UnicodeEncoding]::new($false, $true))
}
# expect = substring in throw; avoid mutations that trip an earlier rule first.
$transCases = [ordered]@{
    'missing UTF-16 BOM' = @{ expect = 'no UTF-16 LE BOM'; do = {
        $f = Join-Path $tfx "fth_ItJustWorks_FRENCH.txt"
        [IO.File]::WriteAllText($f, [IO.File]::ReadAllText($f, [Text.Encoding]::Unicode), [Text.UnicodeEncoding]::new($false, $false))
    } }
    'duplicate key'            = @{ expect = 'duplicate key'; do = { Add-StagedLine 'FRENCH' "`$fth_IJW_Rate_Dual`tdupe" } }
    'duplicate toast key'      = @{ expect = 'duplicate key'; do = { Add-StagedLine 'FRENCH' "`$fth_IJW_Toast_StopOk`tdupe" } }
    'empty value'              = @{ expect = 'empty value';   do = { Set-StagedValue 'ITALIAN' '$fth_IJW_Rate_Dual' '' } }
    'key-set drift from ENGLISH' = @{ expect = 'key-set differs from ENGLISH'; do = { Add-StagedLine 'ENGLISH' "`$fth_IJW_Toast_Ghost`tx" } }
    'key missing from a table' = @{ expect = 'key(s) used by config/scripts'; do = {
                                    $f = Join-Path $tfx "fth_ItJustWorks_GERMAN.txt"
                                    $t = [IO.File]::ReadAllText($f, [Text.Encoding]::Unicode) -replace '(?m)^\$fth_IJW_Rate_Dual\t.*\r?\n', ''
                                    [IO.File]::WriteAllText($f, $t, [Text.UnicodeEncoding]::new($false, $true)) } }
    'orphan key nothing uses'  = @{ expect = 'orphan key'; do = {
                                    foreach ($L in @('ENGLISH','CHINESE','CZECH','FRENCH','GERMAN','ITALIAN','JAPANESE','POLISH','RUSSIAN','SPANISH')) { Add-StagedLine $L "`$fth_IJW_Unused`tx" } } }
    'malformed line'           = @{ expect = 'is not $key<TAB>value'; do = { Add-StagedLine 'POLISH' "this line has no key" } }
    'value over the width budget' = @{ expect = 'display-width gate'; do = { Set-StagedValue 'GERMAN' '$fth_IJW_Heal_Timing' 'Szenen-Timer nach einem Problem vollstaendig repariert' } }
    # Alert body + reserved elapsed suffix exceeds budget.
    'width busted by the runtime suffix' = @{ expect = 'display-width gate'; do = { Set-StagedValue 'GERMAN' '$fth_IJW_Toast_Alert' 'Szene blockiert andere Szenen dauerhaft' } }
}
Reset-TransStage
$tctl = Test-TransStage
if ($null -ne $tctl) { Fail "translation-gate fixtures: the unmutated control failed -- $tctl" }
$transMissed = @()
foreach ($name in $transCases.Keys) {
    Reset-TransStage
    & $transCases[$name].do
    $msg = Test-TransStage
    if ($null -eq $msg) {
        $transMissed += "$name (not caught at all)"
    } elseif ($msg -notmatch [regex]::Escape($transCases[$name].expect)) {
        $transMissed += "$name (died on the wrong rule: expected '$($transCases[$name].expect)', got '$(($msg -split "`n")[0])')"
    }
}
Remove-Item $tfx -Recurse -Force
if ($transMissed.Count -gt 0) {
    Fail ("translation-gate fixtures: $($transMissed.Count) problem(s):`n    " + ($transMissed -join "`n    "))
}
Write-Host "  translation fixtures: control passes, all $($transCases.Count) mutations rejected by their own rule"

# --- Source and license -------------------------------------------------------
$licPath = Join-Path $root "LICENSE.txt"
if (-not (Test-Path $licPath)) { Fail "license gate: LICENSE.txt is missing from the repository" }
$licFull = Get-Content $licPath -Raw -Encoding UTF8
if ($licFull -notmatch 'Mozilla Public License Version 2\.0') {
    Fail "license gate: LICENSE.txt is not the MPL-2.0 text"
}
if (-not (Test-Path (Join-Path $root "NOTICE.md"))) { Fail "license gate: NOTICE.md is missing" }
if ($licText -notmatch 'MPL-2\.0' -and $licText -notmatch 'Mozilla Public License') {
    Fail "license gate: the shipped license breadcrumb does not name the MPL"
}

# Authored .psc in scripts/, or named bake (Toasts = tables + step 2).
$generatedScripts = @{
    'fth_IJW_Toasts' = 'build.ps1 step 2 from interface\translations'
}
$missingSrc = @()
foreach ($f in (Get-ChildItem (Join-Path $pkg "Scripts") -Filter *.pex)) {
    $stem = [IO.Path]::GetFileNameWithoutExtension($f.Name)
    if (Test-Path (Join-Path $root "scripts\$stem.psc")) { continue }
    if ($generatedScripts.ContainsKey($stem)) { continue }
    $missingSrc += $stem
}
if ($missingSrc.Count -gt 0) {
    Fail "source gate: shipped .pex with no Papyrus source in the repo: $($missingSrc -join ', ')"
}

# SPDX headers on authored sources (not the bake output).
$spdxTargets = @(
    (Join-Path $root "build.ps1"),
    (Join-Path $root "scripts\fth_IJW_Watcher.psc"),
    (Join-Path $root "scripts\fth_IJW_MCM.psc"),
    (Join-Path $root "src\Fth.ItJustWorks.PexScrub\Program.cs"),
    (Join-Path $root "src\Fth.ItJustWorks.Builder\Program.cs")
)
foreach ($t in $spdxTargets) {
    $head = (Get-Content $t -TotalCount 6) -join "`n"
    if ($head -notmatch '(?m)^\s*(#|;|//)\s*SPDX-License-Identifier:\s*MPL-2\.0\s*$') {
        Fail "source gate: $(Split-Path $t -Leaf) has no `SPDX-License-Identifier: MPL-2.0` on its own line in the first 6 lines"
    }
}

$buildingMd = Join-Path $root "docs\BUILDING.md"
if (-not (Test-Path $buildingMd)) { Fail "source gate: docs\BUILDING.md is missing" }
$buildingText = Get-Content $buildingMd -Raw -Encoding UTF8
foreach ($opt in @('-Repo', '-Website', '-Author', '-GameRoot', '-SkipSanitization', '-VerifyPublicLink')) {
    if ($buildingText -notmatch [regex]::Escape("``$opt")) {
        Fail "source gate: docs\BUILDING.md does not document the $opt build option"
    }
}
if ($VerifyPublicLink) {
    if ($Repo -notmatch '^https?://') {
        Fail "source gate: -VerifyPublicLink was requested but -Repo is not an http(s) URL ('$Repo')"
    }
    try {
        $resp = Invoke-WebRequest -Uri $Repo -Method Head -TimeoutSec 15 -ErrorAction Stop
        Write-Host "  source link: $Repo reachable (HTTP $($resp.StatusCode))"
    } catch {
        Fail "source gate: could not read the public source link $Repo -- $($_.Exception.Message)"
    }
}
Write-Host "  license: MPL-2.0 + NOTICE present; authored psc/SPDX ok; Toasts from bake + tables"

# --- PexScrub malformed-input fixtures ----------------------------------------
$fxDir = Join-Path $dist "pexfixtures"
if (Test-Path $fxDir) { Remove-Item $fxDir -Recurse -Force }
New-Item -ItemType Directory -Force $fxDir | Out-Null
function New-PexBytes {
    param([int]$StringCount = 1, [string[]]$Strings = @("x"), [switch]$OmitCount, [int]$TruncateTo = 0)
    $b = [System.Collections.Generic.List[byte]]::new()
    $b.AddRange([byte[]]@(0xFA, 0x57, 0xC0, 0xDE))            # magic
    $b.AddRange([byte[]]@(3, 2))                              # major, minor
    $b.AddRange([byte[]]@(0, 1))                              # gameID
    $b.AddRange([byte[]]@(0, 0, 0, 0, 0, 0, 0, 0))            # compileTime
    foreach ($s in @("a.psc", "u", "m")) {
        $ba = [Text.Encoding]::ASCII.GetBytes($s)
        $b.Add([byte]($ba.Length -shr 8)); $b.Add([byte]($ba.Length -band 0xFF)); $b.AddRange($ba)
    }
    if (-not $OmitCount) {
        $b.Add([byte]($StringCount -shr 8)); $b.Add([byte]($StringCount -band 0xFF))
        foreach ($s in $Strings) {
            $ba = [Text.Encoding]::UTF8.GetBytes($s)
            $b.Add([byte]($ba.Length -shr 8)); $b.Add([byte]($ba.Length -band 0xFF)); $b.AddRange($ba)
        }
    }
    $out = $b.ToArray()
    if ($TruncateTo -gt 0 -and $TruncateTo -lt $out.Length) { $out = $out[0..($TruncateTo - 1)] }
    return ,$out
}
$fixtures = [ordered]@{
    'truncated header'          = (New-PexBytes -TruncateTo 9)
    'not a pex'                 = ([byte[]]@(1, 2, 3, 4, 5, 6, 7, 8))
    'truncated string length'   = (New-PexBytes -StringCount 2 -Strings @("x") -TruncateTo 34)
    'payload beyond EOF'        = (New-PexBytes -StringCount 1 -Strings @("xxxxxxxx") -TruncateTo 36)
    'unreasonable count'        = (New-PexBytes -StringCount 40000 -Strings @("x"))
    'trailing partial structure' = (New-PexBytes -StringCount 3 -Strings @("x", "y") )
}
$fxScrub = Join-Path $root "src\Fth.ItJustWorks.PexScrub"
foreach ($fx in $fixtures.Keys) {
    $fxPath = Join-Path $fxDir (($fx -replace '[^A-Za-z0-9]', '_') + ".pex")
    [IO.File]::WriteAllBytes($fxPath, $fixtures[$fx])
    $before = [IO.File]::ReadAllBytes($fxPath)
    $out = (& dotnet run --project $fxScrub -c Release -- $fxPath 2>&1 | Out-String)
    if ($LASTEXITCODE -eq 0) { Fail "PexScrub fixture '$fx' was accepted; malformed input must fail" }
    if ($out -notmatch 'FATAL') { Fail "PexScrub fixture '$fx' failed without a named reason: $out" }
    if ($out -match 'IndexOutOfRange|ArgumentOutOfRange|Unhandled exception') {
        Fail "PexScrub fixture '$fx' threw an index exception instead of a controlled failure: $out"
    }
    $after = [IO.File]::ReadAllBytes($fxPath)
    if (($before -join ',') -ne ($after -join ',')) { Fail "PexScrub fixture '$fx' left a partially rewritten artifact" }
}
# Valid fixture round-trip.
$okPath = Join-Path $fxDir "valid.pex"
[IO.File]::WriteAllBytes($okPath, (New-PexBytes -StringCount 2 -Strings @("alpha", "beta")))
& dotnet run --project $fxScrub -c Release -- --time 0 $okPath 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { Fail "PexScrub rejected a well-formed fixture (exit $LASTEXITCODE)" }
$okBytes = [IO.File]::ReadAllBytes($okPath)
if (-not (Contains-Bytes $okBytes ([Text.Encoding]::ASCII.GetBytes("ItJustWorks")))) {
    Fail "PexScrub did not rewrite the user field in the valid fixture"
}
Remove-Item $fxDir -Recurse -Force
Write-Host "  pexscrub: $($fixtures.Count) malformed fixtures rejected by name, valid fixture round-trips"

# --- 7. Zip ------------------------------------------------------------------
Step 7 "Package"
$zip = Join-Path $dist "It Just Works $Version.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $pkg "*") -DestinationPath $zip -Force

# --- 8. Nexus paste helpers (not in the zip) ---------------------------------
Step 8 "Nexus paste helpers"
$bbOut = Join-Path $dist "bbcode"
if (Test-Path $bbOut) { Remove-Item $bbOut -Recurse -Force }
New-Item -ItemType Directory -Force $bbOut | Out-Null

function Format-ChangelogNoteLine([string]$s) {
    $t = [regex]::Replace($s, '\[([^\]]+)\]\([^)]+\)', '$1')
    $t = [regex]::Replace($t, '\*\*([^*]+)\*\*', '$1')
    $t = [regex]::Replace($t, '(?<!\*)\*([^*]+)\*(?!\*)', '$1')
    $t = [regex]::Replace($t, '`([^`]+)`', '$1')
    return (($t -replace '\*\*', '' -replace '\s+', ' ').Trim() -replace '^[-*+]\s+', '')
}

# CHANGELOG.md -> version -> flat one-line notes. Strip "- " (Nexus prefixes paste with ">").
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

try {
    $clMd = Join-Path $root "CHANGELOG.md"
    $utf8 = [Text.UTF8Encoding]::new($false)
    if (-not (Test-Path $clMd)) {
        Write-Host "  WARN: CHANGELOG.md missing -- skipping plain-text dumps" -ForegroundColor Yellow
    } else {
        $sections = @(Get-ChangelogNotesByVersion $clMd)
        $full = [System.Collections.Generic.List[string]]::new()
        foreach ($sec in $sections) {
            [void]$full.Add($sec.Version)
            foreach ($n in $sec.Notes) { [void]$full.Add($n) }
        }
        $clTxt = Join-Path $bbOut "CHANGELOG.txt"
        [IO.File]::WriteAllText($clTxt, (($full -join "`r`n") + "`r`n"), $utf8)
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
