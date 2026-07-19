# Sanitization

The `sanitization/` folder is the build's **identity gate**. Before `build.ps1`
packages a release, it runs every check under `sanitization/private/` against the
assembled files, so nothing that identifies the machine or account that built it
can ever ship.

## What's public vs private

- **`README.md`, `00-sample.ps1.example`** (this folder, top level) - public. Tracked
  by the main repo so a fresh clone can learn the system.
- **`private/`** - gitignored wholesale. This is where the *real* checks live, the ones
  that name actual identifiers. Nothing in it is ever pushed to the public repo, and
  keeping the real checks here is what stops you committing your own identity to the
  public repo by accident.

**Strongly recommended: make `private/` its own separate, private git repository.** Don't
leave the real checks as loose, untracked files - they encode exactly the identifiers you
most need to not lose, mangle, or leak. Track them in a private repo (a private GitHub
repo, a local bare repo, anything off the public remote) and `git clone` it into
`sanitization/private/`. You get history, backup, and a diff to review before every change
- and because it's a distinct repo with a distinct remote, there's no path by which a
stray `git add` in the public project sweeps it up.

## The contract

`build.ps1` discovers every `.ps1` file in `sanitization/private/` and runs them in
filename order (so name them `01-...`, `02-...`, init.d style). Each is invoked as:

```
& <check>.ps1 -PackageDir <path to the assembled package tree>
```

A check reports its result **through its exit**:

- **Clean** (nothing to report) -> exit **0**, or simply return without throwing.
- **Leak found** -> **throw**, or **exit non-zero**.

The build is **fatal** if:

- `sanitization/private/` has no check (and you didn't pass `-SkipSanitization`), or
- any check throws or exits non-zero.

That last rule is the whole point: a check that fails for *any* reason stops the build.
A silently-skipped scrub is exactly the risk the gate exists to prevent.

## Building without any checks of your own

If you're building your own copy and have no identity of the author's to strip, run:

```
.\build.ps1 -SkipSanitization
```

The generic `.pex` header scrub in build step 3 still runs regardless, so your own
username and hostname are stripped from the compiled scripts either way.

## Writing your own check

Start from `00-sample.ps1.example`. Copy it into `sanitization/private/` under an
active, numbered name (e.g. `01-my-identity.ps1`), swap the needle(s) for the strings
that identify *your* machine or account, and make sure it honors the exit contract
above before you trust it. Don't take the example on faith - read it against the
contract and confirm it does what you think.

(A `.ps1` left at this top level is ignored by the gate and *not* gitignored - `build.ps1` will warn you. Active checks belong in `private/`.)

## Exclusions, and auditing them

A broad needle sometimes matches a string that's genuinely safe to ship - most often
your own username buried inside your *public* GitHub handle in the repo URL. The fix is
**not** to narrow the needle (that quietly shrinks what you check); it's to keep the
needle broad and allow-list the exact safe string in the check's `$exclusions` list,
which the scan blanks out before matching. See `00-sample.ps1.example` for the pattern.

Treat every exclusion as a hole you deliberately cut in the net:

- **Add one only after you've read the actual match with your own eyes** and confirmed
  the string is public by design. When in doubt, leave it in and fix the real leak.
- **Keep the list short and specific.** Allow-list the whole safe string (the full URL,
  not a bare fragment), so the exclusion can't accidentally wave through more than the
  one case you meant.
- **Audit it periodically** - at minimum before a release. Re-read each entry and ask
  whether it's *still* a string you're fine shipping. An exclusion added a year ago
  against an assumption that's since changed is exactly how a leak slips out clean.

Because the exclusions live in `private/`, auditing them is one more reason to keep that
folder in its own version-controlled repo: the diff is your audit trail.
