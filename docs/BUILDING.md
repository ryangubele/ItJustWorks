# Building It Just Works

The whole mod builds from source with one script: `build.ps1`. It generates the
plugin, compiles the scripts, assembles the archive tree, checks it, and drops a
ready-to-install zip in `dist\`. There is no Creation Kit *authoring* - the ESP is
generated from code (Mutagen) so it diffs in git and rebuilds byte-for-byte.

This is a Windows build (Skyrim's Papyrus compiler is Windows-only).

## Prerequisites

- **Windows**, with **PowerShell 7** (`pwsh`) or Windows PowerShell 5.1.
- **.NET 10 SDK** - the plugin generator and the `.pex` scrubber are small C#
  programs the script runs with `dotnet run`. (SDK, not just the runtime.)
  <https://dotnet.microsoft.com/download>
- **Skyrim Special Edition**, installed. The script auto-detects it (Steam or GOG,
  any drive); if that fails, see Options below.
- **The Creation Kit**, installed under the game (free, on Steam). This is what
  supplies the Papyrus compiler (`Papyrus Compiler\PapyrusCompiler.exe`), the flags
  file, and the base-game script *sources* the compiler needs on its import path.
- **Internet**, for the first build only - it restores the Mutagen NuGet package and the
  pinned BBCode-converter dotnet tool (see *Nexus paste helpers* below).

### Dependency script sources (the `headers/` folder)

The scripts compile against APIs from MCM Helper, powerofthree's Papyrus Extender,
SkyUI (`SKI_*`), PapyrusUtil (`StorageUtil`), and UIExtensions, plus a few
SKSE-augmented base-game signatures. This repo does **not** redistribute those `.psc`
files - they belong to their authors - so a fresh clone's `headers/` folder is empty
and you must supply them before building. Either:

- drop each API's `.psc` into `headers/` from that mod's own script sources / SDK, or
- have those mods' sources on the compiler's import path (`Data\Scripts\Source` /
  `Data\Source\Scripts`).

The base-game and SKSE-augmented scripts come from the Creation Kit and SKSE. (Planned:
the build script will learn to locate these from an installed setup; until then,
`headers/` is on you.)

## Build

From the repo root:

```
pwsh -File build.ps1 -SkipSanitization
```

`-SkipSanitization` is required when building from a clone of the public repo. The
identity-scrub checks live in a private, gitignored folder that isn't part of this
repo, so the build refuses to run them unless you opt out. (The generic `.pex`
scrub - which strips the compiling machine's username and hostname - runs either
way, so your own identity is still cleaned.)

Output: `dist\It Just Works <version>.zip`, plus the staged tree in `dist\pkg\`.

The package includes a standard `Data/SEQ/fth_ItJustWorks.seq` (one file FormID for the
mod's single StartGameEnabled quest) so the watchdog can arm on mid-playthrough installs.
The Builder derives that dword and asserts exactly one SGE quest; `build.ps1`'s verify
gate checks the SEQ file's shape and that its bytes appear in the ESP.

## Nexus paste helpers (`dist\bbcode\`)

As a final, non-shipping step, the build drops author-side files for the Nexus mod page
into `dist\bbcode\` (gitignored like the rest of `dist\`; never in the zip):

1. **Plain changelog dumps** (always, no tools; from `CHANGELOG.md`):
   - **`CHANGELOG.txt`** — full history for splitting on Nexus: each version is a bare
     marker line (`0.3.2`), then **one line per change**, no dashes, no blank lines, no
     markup. Nexus prefixes every paste line with `>`, so list markers are never emitted.
   - **`<version>.txt`** — one file per release (e.g. `0.3.2.txt`): body only (Nexus
     already stores the version field). Paste that file into the matching Documentation
     changelog entry.
2. **`.bb` files** — NexusMods-flavour BBCode for manuals (Articles), `README.md`
   (description), and `CHANGELOG.md` (if you still want BBCode). One file per doc, all ten
   manual languages included (e.g. `manual.en.bb`, `manual.ru.bb`).

The BBCode converter is a **pinned dotnet tool** declared in `.config\dotnet-tools.json`
(BUTR's `Converter.MarkdownToBBCodeNM.Tool`). The build restores it with `dotnet tool restore`,
so a fresh clone just needs internet on the first build. The tool targets .NET 7; the
manifest's `rollForward` runs it on your installed SDK with no extra setup.

BBCode conversion is **non-critical**: if the tool can't be restored, the build warns and
skips it; the zip and `CHANGELOG.txt` are unaffected. One known limitation - the converter
flattens markdown *tables* into literal pipes, so hand-fix the README's single table if you
paste `README.bb` as the description (the manuals and changelog have none).

## Options

Pass these as parameters to `build.ps1`:

- `-GameRoot "X:\...\steamapps\common\Skyrim Special Edition"` - set the game path
  explicitly when auto-detect can't find it. You can also set the `SKYRIM_SE_PATH`
  environment variable instead. Precedence: `-GameRoot`, then `SKYRIM_SE_PATH`,
  then auto-detect.
- `-SkipSanitization` - skip the private identity-scrub checks (see Build above).
- `-Repo "https://github.com/you/your-fork"` - stamped into the shipped license
  breadcrumb so it points back at the source. Optional.
- `-Website "https://www.nexusmods.com/..."` - the mod page URL for the FOMOD
  metadata. Optional; blank until the page exists.

## Troubleshooting

- **"could not locate Skyrim Special Edition"** - pass `-GameRoot` or set
  `SKYRIM_SE_PATH`.
- **"PapyrusCompiler not found"** - the Creation Kit isn't installed under the game
  folder. Install it from Steam.
- **Compiler can't find a base script** (e.g. `Actor.psc`, `Utility.psc`) - the
  base-game Papyrus sources aren't on disk. The script looks in `Data\Scripts\Source`
  and `Data\Source\Scripts`; make sure the CK's script sources are extracted there
  (some setups ship them zipped).
- **Compiler can't find a dependency script** (e.g. `PO3_SKSEFunctions.psc`,
  `MCM_ConfigBase.psc`, `SKI_ConfigBase.psc`) - the `headers/` stubs aren't present.
  Supply them (see "Dependency script sources" above).
- **`dotnet` not recognized** - install the .NET 10 SDK and reopen the terminal.
- **BBCode docs skipped / `dotnet tool restore` failed** - non-critical; the mod zip still
  builds. The step needs internet on the first run to pull the pinned converter from NuGet.
  Re-run online, or ignore it if you don't need the `.bb` files.
