# tc-config

Personal Total Commander (x64) configuration.
Installed via Scoop — active INI is at:
`%USERPROFILE%\scoop\apps\totalcommander\current\wincmd.ini`
(hardlinked to `%USERPROFILE%\scoop\persist\totalcommander\wincmd.ini`)

This repo lives at `%APPDATA%\GHISLER` — this is also the file TC actively reads and writes. It is the single source of truth for both TC and git.

## Files

| File | Purpose |
| --- | --- |
| `WINCMD.INI` | Main TC config — colors, shortcuts, layout, history |
| `VERTICAL.BAR` | Vertical toolbar button layout |
| `tcignore.txt` | Files/dirs TC ignores in listings |
| `wcx_ftp.ini` | FTP plugin settings — gitignored (may contain credentials) |
| `themes/Set-TCTheme.ps1` | Theme switcher script |

## Themes

Six themes are available, grouped into 3 families × light/dark:

| Command | Theme | Mode |
| --- | --- | --- |
| `em_ThemeGitHubLight` | GitHub | Light (default) |
| `em_ThemeGitHubDark` | GitHub | Dark |
| `em_ThemeRosePineDawn` | Rosé Pine | Light |
| `em_ThemeRosePineMain` | Rosé Pine | Dark |
| `em_ThemeCatppuccinLatte` | Catppuccin | Light |
| `em_ThemeCatppuccinMocha` | Catppuccin | Dark |

User commands live in `%USERPROFILE%\scoop\persist\totalcommander\usercmd.ini`.
Access in TC via **Commands → Start Menu**.

### Applying a theme manually

```powershell
# From %APPDATA%\GHISLER\themes\
powershell -ExecutionPolicy Bypass -File Set-TCTheme.ps1 -Theme github -Mode light
powershell -ExecutionPolicy Bypass -File Set-TCTheme.ps1 -Theme rosepine -Mode dark
powershell -ExecutionPolicy Bypass -File Set-TCTheme.ps1 -Theme catppuccin -Mode light
```

The script patches `[Colors]` + `DarkMode` in the active `wincmd.ini` and restarts TC.

### Color value format

TC stores colors as Windows COLORREF decimals: `B*65536 + G*256 + R`

```powershell
# Convert hex #RRGGBB to COLORREF decimal
function ConvertTo-COLORREF([string]$hex) {
    $hex = $hex.TrimStart('#')
    $r = [Convert]::ToInt32($hex.Substring(0,2), 16)
    $g = [Convert]::ToInt32($hex.Substring(2,2), 16)
    $b = [Convert]::ToInt32($hex.Substring(4,2), 16)
    return $b * 65536 + $g * 256 + $r
}
```

### Adding a new theme

1. Add a new entry to the `$themes` hashtable in `Set-TCTheme.ps1`
2. Add a corresponding `[em_ThemeXxx]` block to `usercmd.ini` in the persist dir
3. Commit both files

## Color filters (all themes)

| Filter | Pattern |
| --- | --- |
| 1 | `*.exe;*.com;bin*.;plugins;system*.;run*.;*.lnk;*.dll` |
| 2 | `*.log` |
| 3 | `*.pdf` |
| 4 | `*.doc?;*.xls?;*.ppt?;*.vsd?` |
| 5 | `*.json;*.csv;` |
| 6 | `README.md;readme.txt` |
| 7 | `*.bat;*.cmd;*.sh;*.ps1` |
| 8 | `*.toml;*.ini;*.yaml;*.inf;.editorconfig` |

## Syncing changes

TC writes config on exit. History sections are stripped automatically on `git add` via a git clean filter (`themes/Strip-WincmdHistory.ps1`) — the working copy TC reads is never touched.

```bash
git add WINCMD.INI VERTICAL.BAR tcignore.txt
git commit -m "update TC config"
git push
```

> Do not commit `wcx_ftp.ini` — it is gitignored.

### Sections stripped automatically on commit

`[Command line history]` · `[LeftHistory]` · `[RightHistory]` · `[SearchText]` · `[SearchName]` · `[SearchIn]` · `[NewFileHistory]` · `[MkDirHistory]` · `[Selection]` · `[RenameTemplates]` · `[RenameSearchReplace]` · `[DirMenu]` · `[lefttabs]` · `[righttabs]`

The last three (`[DirMenu]`, `[lefttabs]`, `[righttabs]`) hold personal bookmarks and open tabs — they live in the working copy for TC to use but are never committed.

### Re-registering the filter on a new machine

The filter is stored in `.git/config` (local only). After cloning, run once:

```powershell
$script = "$env:APPDATA\GHISLER\scripts\Strip-WincmdHistory.ps1"
git config filter.strip-tc-history.clean "powershell -NonInteractive -NoProfile -File `"$script`""
git config filter.strip-tc-history.smudge cat
git config filter.strip-tc-history.required true
```
