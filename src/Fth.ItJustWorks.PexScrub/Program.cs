// Copyright (c) 2026 Ryan Gubele
// SPDX-License-Identifier: MPL-2.0
//
// Rewrites Skyrim .pex headers to strip machine-local identity. A compiled .pex
// embeds, in plaintext, the account username and hostname of whoever built it.
// Those are machine trivia that don't belong in a shipped binary. We replace
// them with fixed constants and set the compile timestamp to a caller-supplied
// value instead of a machine clock. (Pinning it keeps the one field we control stable
// and coherent; it does not by itself make the .pex byte-reproducible -- the compiler's
// string-table order isn't deterministic.)
//
// The timestamp comes from --time <unix-epoch>. build.ps1 resolves it
// (SOURCE_DATE_EPOCH env var, else the clean-tree HEAD commit date, else the
// current time) and passes it in. Absent --time, it defaults to now.
//
// Skyrim PEX header (big-endian):
//   u32 magic (0xFA57C0DE) | u8 major | u8 minor | u16 gameID
//   u64 compileTime | str sourceFile | str username | str machineName
//   ...body...
// where str = u16 length prefix + ASCII bytes.

using System.Text;

const uint Magic = 0xFA57C0DE;
const string NewUser = "ItJustWorks";
const string NewMachine = "BUILD";

// Compile timestamp (unix seconds). Overridden by --time; defaults to now.
long compileTime = DateTimeOffset.UtcNow.ToUnixTimeSeconds();

var files = new List<string>();
for (int i = 0; i < args.Length; i++)
{
    if (args[i] == "--time")
    {
        if (i + 1 >= args.Length || !long.TryParse(args[i + 1], out compileTime))
        {
            Console.Error.WriteLine("FATAL: --time requires an integer unix-epoch value");
            return 1;
        }
        i++;
    }
    else
    {
        files.AddRange(ExpandArg(args[i]));
    }
}

if (files.Count == 0)
{
    Console.Error.WriteLine("PexScrub: no .pex files matched. Usage: PexScrub [--time <epoch>] <file-or-glob> [...]");
    return 1;
}

int scrubbed = 0;
foreach (var path in files)
{
    try
    {
        Scrub(path, compileTime);
        scrubbed++;
    }
    catch (Exception ex)
    {
        Console.Error.WriteLine($"FATAL: {path}: {ex.Message}");
        return 2;
    }
}

Console.WriteLine($"PexScrub: scrubbed {scrubbed} file(s).");
return 0;

static List<string> ExpandArg(string a)
{
    var result = new List<string>();
    if (a.Contains('*') || a.Contains('?'))
    {
        var dir = Path.GetDirectoryName(a);
        dir = string.IsNullOrEmpty(dir) ? "." : dir;
        var pattern = Path.GetFileName(a);
        if (Directory.Exists(dir))
            result.AddRange(Directory.GetFiles(dir, pattern));
    }
    else if (File.Exists(a))
    {
        result.Add(a);
    }
    else
    {
        Console.Error.WriteLine($"WARN: no match for '{a}'");
    }
    return result;
}

static void Scrub(string path, long compileTime)
{
    byte[] data = File.ReadAllBytes(path);

    uint magic = (uint)((data[0] << 24) | (data[1] << 16) | (data[2] << 8) | data[3]);
    if (magic != Magic)
        throw new InvalidDataException($"bad magic 0x{magic:X8} (expected 0x{Magic:X8}) -- not a Skyrim .pex");

    int pos = 4;
    pos += 1;                 // major
    pos += 1;                 // minor
    pos += 2;                 // gameID
    int timeOff = pos;
    pos += 8;                 // compileTime (u64)

    // sourceFile string -- kept as-is
    (string src, pos) = ReadStr(data, pos);
    // username + machineName -- the fields we replace
    (string oldUser, pos) = ReadStr(data, pos);
    (string oldMachine, pos) = ReadStr(data, pos);
    int bodyOff = pos;

    using var ms = new MemoryStream();
    // header up through gameID, unchanged
    ms.Write(data, 0, timeOff);
    // caller-supplied timestamp
    WriteU64BE(ms, (ulong)compileTime);
    // source filename, unchanged
    WriteStr(ms, src);
    // scrubbed identity
    WriteStr(ms, NewUser);
    WriteStr(ms, NewMachine);
    // remaining body, unchanged
    ms.Write(data, bodyOff, data.Length - bodyOff);

    File.WriteAllBytes(path, ms.ToArray());

    Console.WriteLine($"  {Path.GetFileName(path)}: user '{oldUser}'->'{NewUser}', machine '{oldMachine}'->'{NewMachine}', time={compileTime}");
}

static (string, int) ReadStr(byte[] data, int pos)
{
    int len = (data[pos] << 8) | data[pos + 1];
    pos += 2;
    string s = Encoding.ASCII.GetString(data, pos, len);
    return (s, pos + len);
}

static void WriteStr(Stream s, string value)
{
    var bytes = Encoding.ASCII.GetBytes(value);
    if (bytes.Length > 0xFFFF) throw new InvalidDataException("string too long");
    s.WriteByte((byte)(bytes.Length >> 8));
    s.WriteByte((byte)(bytes.Length & 0xFF));
    s.Write(bytes, 0, bytes.Length);
}

static void WriteU64BE(Stream s, ulong v)
{
    for (int shift = 56; shift >= 0; shift -= 8)
        s.WriteByte((byte)((v >> shift) & 0xFF));
}
