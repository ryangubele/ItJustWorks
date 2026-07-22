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

// SEQ: reliably start the StartGameEnabled quest on a mid-playthrough save. A StartGameEnabled
// quest is NOT reliably started when its plugin is added to a save that predates it; Data/SEQ/
// <plugin>.seq is the engine's deterministic "start these quests on load" list. The entry is the
// quest's FILE FormID -- the object id (quest.FormKey.ID, forced into 0x800-0xFFF above) under the
// plugin's own index in its master list (= master count; 0x01 with one master -> 0x01000800),
// written little-endian. NOT the bare object id, and NOT the runtime FE address: the light-slot
// index is assigned at load order time, so it can never live in a static file. Master count is
// read back from the file we just wrote so it tracks the real masters, not an assumed 1.
// Read back masters + StartGameEnabled invariant. The SEQ is a single 4-byte entry;
// more than one SGE quest would ship unarmed extras if we only ever wrote one dword.
int masterCount;
int sgeCount = 0;
bool ourQuestIsSge = false;
using (var readback = SkyrimMod.CreateFromBinaryOverlay(outPath, SkyrimRelease.SkyrimSE))
{
    masterCount = readback.ModHeader.MasterReferences.Count;
    foreach (var q in readback.Quests)
    {
        if (!q.Flags.HasFlag(Quest.Flag.StartGameEnabled)) continue;
        sgeCount++;
        if (q.FormKey.ID == quest.FormKey.ID) ourQuestIsSge = true;
    }
}
if (masterCount is < 1 or > 0xFE)
{
    Console.Error.WriteLine($"FATAL: master count {masterCount} can't form a valid SEQ high byte.");
    return 1;
}
if (sgeCount != 1)
{
    Console.Error.WriteLine($"FATAL: expected exactly 1 StartGameEnabled quest (SEQ is single-entry), found {sgeCount}.");
    return 1;
}
if (!ourQuestIsSge)
{
    Console.Error.WriteLine("FATAL: fth_IJW is not StartGameEnabled after write -- SEQ would arm the wrong thing (or nothing).");
    return 1;
}
uint fileFormId = ((uint)masterCount << 24) | quest.FormKey.ID;
if ((fileFormId >> 24) == 0)
{
    Console.Error.WriteLine($"FATAL: SEQ dword 0x{fileFormId:X8} has a zero high byte -- that's a bare object id, not a file FormID.");
    return 1;
}
byte[] seqBytes =
{
    (byte)(fileFormId & 0xFF),
    (byte)((fileFormId >> 8) & 0xFF),
    (byte)((fileFormId >> 16) & 0xFF),
    (byte)((fileFormId >> 24) & 0xFF),
};
var seqPath = Path.Combine(Path.GetDirectoryName(outPath)!, "SEQ", "fth_ItJustWorks.seq");
Directory.CreateDirectory(Path.GetDirectoryName(seqPath)!);
File.WriteAllBytes(seqPath, seqBytes);

Console.WriteLine($"Wrote {outPath}");
Console.WriteLine($"  QUST fth_IJW  FormID 0x{quest.FormKey.ID:X6}  (ESL-flagged)");
Console.WriteLine($"  SEQ  0x{fileFormId:X8}  [{BitConverter.ToString(seqBytes).Replace('-', ' ')}]  -> {seqPath}");
Console.WriteLine($"  Author='{mod.ModHeader.Author}'  Description='{mod.ModHeader.Description}'");
return 0;
