// Copyright (c) 2026 Ryan Gubele
// SPDX-License-Identifier: MPL-2.0
//
// Generates fth_ItJustWorks.esp from code, so the plugin diffs in git and
// rebuilds byte-for-byte -- no Creation Kit authoring. One QUST record, ESL-
// flagged, master Skyrim.esm only, carrying two script bindings on its VMAD.

using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Binary.Parameters;
using Mutagen.Bethesda.Skyrim;

string version = "";
string outPath = Path.Combine("dist", "fth_ItJustWorks.esp");
string author = "Ryan Gubele";
for (int i = 0; i < args.Length; i++)
{
    switch (args[i])
    {
        case "--version" when i + 1 < args.Length: version = args[++i]; break;
        case "--out" when i + 1 < args.Length: outPath = args[++i]; break;
        case "--author" when i + 1 < args.Length: author = args[++i]; break;
    }
}

// Require a valid X.Y.Z; fail loud rather than stamp a bogus header.
if (!System.Text.RegularExpressions.Regex.IsMatch(version, @"^\d+\.\d+\.\d+$"))
{
    Console.Error.WriteLine($"FATAL: --version '{version}' is missing or not X.Y.Z");
    return 1;
}

outPath = Path.GetFullPath(outPath);
Directory.CreateDirectory(Path.GetDirectoryName(outPath)!);

var modKey = ModKey.FromNameAndExtension("fth_ItJustWorks.esp");
var mod = new SkyrimMod(modKey, SkyrimRelease.SkyrimSE);

// Header metadata (shown in Vortex/MO2/SSEEdit). The author credit is intended;
// overridable via --author for a fork or handover. Only the machine-local
// username/hostname are scrubbed, and only from the .pex.
mod.ModHeader.Author = author;
// Keeps the literal "v{version}" so the build's version gate can find it.
mod.ModHeader.Description = $"It Just Works v{version} - un-sticks the states Skyrim leaves stuck; scenes first";
mod.ModHeader.Flags |= SkyrimModHeader.HeaderFlag.Small; // ESL flag (bit 0x200)

// The one record.
var quest = mod.Quests.AddNew("fth_IJW");
quest.Name = "It Just Works";
quest.Flags = Quest.Flag.StartGameEnabled | Quest.Flag.RunOnce;

// ESL plugins must keep every new FormID in 0x800-0xFFF. Fail loud if Mutagen
// ever allocates outside that window rather than shipping a broken light master.
if (quest.FormKey.ID is < 0x800 or > 0xFFF)
{
    Console.Error.WriteLine($"FATAL: quest FormID 0x{quest.FormKey.ID:X} is outside the ESL range 0x800-0xFFF.");
    return 1;
}

// VMAD: two scripts on the quest. fth_IJW_Watcher gets PlayerRef; fth_IJW_MCM
// gets ModName (how MCM Helper binds this quest to config.json).
var adapter = new QuestAdapter();

var watcher = new ScriptEntry { Name = "fth_IJW_Watcher", Flags = ScriptEntry.Flag.Local };
var playerProp = new ScriptObjectProperty { Name = "PlayerRef", Flags = ScriptProperty.Flag.Edited };
playerProp.Object.SetTo(FormKey.Factory("000014:Skyrim.esm"));
watcher.Properties.Add(playerProp);
adapter.Scripts.Add(watcher);

// ModName must match the MCM/Config folder name. This inherited SKI_ConfigBase
// property doesn't actually bind through the VMAD, so MCM Helper falls back to the
// plugin filename regardless -- which is why the folder is named "fth_ItJustWorks".
var menu = new ScriptEntry { Name = "fth_IJW_MCM", Flags = ScriptEntry.Flag.Local };
menu.Properties.Add(new ScriptStringProperty { Name = "ModName", Flags = ScriptProperty.Flag.Edited, Data = "fth_ItJustWorks" });
adapter.Scripts.Add(menu);

quest.VirtualMachineAdapter = adapter;

mod.WriteToBinary(outPath, new BinaryWriteParameters
{
    // Derive the masters list from the record links (-> Skyrim.esm) rather than
    // trusting an in-memory list.
    MastersListContent = MastersListContentOption.Iterate,
});

Console.WriteLine($"Wrote {outPath}");
Console.WriteLine($"  QUST fth_IJW  FormID 0x{quest.FormKey.ID:X6}  (ESL-flagged)");
Console.WriteLine($"  Author='{mod.ModHeader.Author}'  Description='{mod.ModHeader.Description}'");
return 0;
