// Copyright (c) 2026 Ryan Gubele
// SPDX-License-Identifier: MPL-2.0
//
// Scrub .pex user/machine/compile time. Optional --replace rewrites string-table
// entries by exact key (toast bake: ASCII placeholders -> UTF-8). Table length may
// change; opcodes hold indices only. --time is unix-epoch.

using System.Text;
using System.Text.Json;

const uint Magic = 0xFA57C0DE;
const string NewUser = "ItJustWorks";
const string NewMachine = "BUILD";

long compileTime = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
string? replaceMapPath = null;
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
    else if (args[i] == "--replace")
    {
        if (i + 1 >= args.Length)
        {
            Console.Error.WriteLine("FATAL: --replace requires a path to a JSON object map");
            return 1;
        }
        replaceMapPath = args[++i];
    }
    else
    {
        files.AddRange(ExpandArg(args[i]));
    }
}

if (files.Count == 0)
{
    Console.Error.WriteLine(
        "PexScrub: no .pex files matched. Usage: PexScrub [--time <epoch>] [--replace <map.json>] <file-or-glob> [...]");
    return 1;
}

Dictionary<string, string>? replaceMap = null;
if (replaceMapPath is not null)
{
    if (!File.Exists(replaceMapPath))
    {
        Console.Error.WriteLine($"FATAL: --replace map not found: {replaceMapPath}");
        return 1;
    }
    try
    {
        var json = File.ReadAllText(replaceMapPath);
        replaceMap = JsonSerializer.Deserialize<Dictionary<string, string>>(json)
            ?? new Dictionary<string, string>();
    }
    catch (Exception ex)
    {
        Console.Error.WriteLine($"FATAL: --replace map parse failed: {ex.Message}");
        return 1;
    }
}

int scrubbed = 0;
foreach (var path in files)
{
    try
    {
        Scrub(path, compileTime, replaceMap);
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

static void Scrub(string path, long compileTime, Dictionary<string, string>? replaceMap)
{
    byte[] data = File.ReadAllBytes(path);

    Need(data, 0, 4, "magic");
    uint magic = (uint)((data[0] << 24) | (data[1] << 16) | (data[2] << 8) | data[3]);
    if (magic != Magic)
        throw new InvalidDataException($"bad magic 0x{magic:X8} (expected 0x{Magic:X8}) -- not a Skyrim .pex");

    int pos = 4;
    Need(data, pos, 12, "fixed header (major/minor/gameID/compileTime)");
    pos += 1; // major
    pos += 1; // minor
    pos += 2; // gameID
    int timeOff = pos;
    pos += 8; // compileTime

    (string src, pos) = ReadStrAscii(data, pos, "sourceFile");
    (string oldUser, pos) = ReadStrAscii(data, pos, "user");
    (string oldMachine, pos) = ReadStrAscii(data, pos, "machine");

    Need(data, pos, 2, "string table count");
    int stringCount = (data[pos] << 8) | data[pos + 1];
    pos += 2;
    // Min entry size 2 bytes; reject a count that cannot fit the remainder.
    if ((long)stringCount * 2 > data.Length - pos)
        throw new InvalidDataException(
            $"string table count {stringCount} cannot fit in {data.Length - pos} remaining byte(s) at offset {pos}");

    var strings = new List<byte[]>(stringCount);
    for (int i = 0; i < stringCount; i++)
    {
        Need(data, pos, 2, $"string {i} length");
        int len = (data[pos] << 8) | data[pos + 1];
        pos += 2;
        Need(data, pos, len, $"string {i} payload (len={len})");
        var bytes = new byte[len];
        Buffer.BlockCopy(data, pos, bytes, 0, len);
        pos += len;
        strings.Add(bytes);
    }
    int bodyOff = pos;
    if (bodyOff > data.Length)
        throw new InvalidDataException($"string table ends past end of file (offset {bodyOff} > {data.Length})");

    int replaced = 0;
    var missing = new List<string>();
    if (replaceMap is not null && replaceMap.Count > 0)
    {
        var usedKeys = new HashSet<string>(StringComparer.Ordinal);
        for (int i = 0; i < strings.Count; i++)
        {
            string key = Encoding.UTF8.GetString(strings[i]);
            if (replaceMap.TryGetValue(key, out var value))
            {
                strings[i] = Encoding.UTF8.GetBytes(value);
                usedKeys.Add(key);
                replaced++;
            }
        }
        foreach (var k in replaceMap.Keys)
        {
            if (!usedKeys.Contains(k))
                missing.Add(k);
        }
        // Partial apply fails; zero hits OK (non-toast pex). build.ps1 checks Toasts.pex leftovers.
        if (replaced > 0 && missing.Count > 0)
            throw new InvalidDataException(
                $"{Path.GetFileName(path)}: {missing.Count} toast placeholder(s) not found in string table " +
                $"(first: {missing[0]}). Rebuild the bake or recompile fth_IJW_Toasts.");
    }

    using var ms = new MemoryStream();
    ms.Write(data, 0, timeOff);
    WriteU64BE(ms, (ulong)compileTime);
    WriteStrAscii(ms, src);
    WriteStrAscii(ms, NewUser);
    WriteStrAscii(ms, NewMachine);
    if (strings.Count > 0xFFFF)
        throw new InvalidDataException("string table too large");
    ms.WriteByte((byte)(strings.Count >> 8));
    ms.WriteByte((byte)(strings.Count & 0xFF));
    foreach (var s in strings)
    {
        if (s.Length > 0xFFFF)
            throw new InvalidDataException("string too long for pex u16 length");
        ms.WriteByte((byte)(s.Length >> 8));
        ms.WriteByte((byte)(s.Length & 0xFF));
        ms.Write(s, 0, s.Length);
    }
    ms.Write(data, bodyOff, data.Length - bodyOff);

    // Temp + move: avoid leaving a truncated .pex on mid-write I/O failure.
    var tmp = path + ".pexscrub.tmp";
    File.WriteAllBytes(tmp, ms.ToArray());
    File.Move(tmp, path, overwrite: true);

    Console.WriteLine(
        $"  {Path.GetFileName(path)}: user '{oldUser}'->'{NewUser}', machine '{oldMachine}'->'{NewMachine}', " +
        $"time={compileTime}" + (replaced > 0 ? $", strings replaced={replaced}" : ""));
}

static void Need(byte[] data, int pos, int count, string what)
{
    if (pos < 0 || count < 0 || (long)pos + count > data.Length)
        throw new InvalidDataException(
            $"truncated: need {count} byte(s) for {what} at offset {pos}, file is {data.Length} byte(s)");
}

static (string, int) ReadStrAscii(byte[] data, int pos, string what)
{
    Need(data, pos, 2, $"{what} length");
    int len = (data[pos] << 8) | data[pos + 1];
    pos += 2;
    Need(data, pos, len, $"{what} payload (len={len})");
    string s = Encoding.ASCII.GetString(data, pos, len);
    return (s, pos + len);
}

static void WriteStrAscii(Stream s, string value)
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
