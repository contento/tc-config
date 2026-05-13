# tc-config

Personal Total Commander (x64) configuration.
Installed via Scoop — active INI is at:
`%USERPROFILE%\scoop\apps\totalcommander\current\wincmd.ini`
(hardlinked to `%USERPROFILE%\scoop\persist\totalcommander\wincmd.ini`)

This repo lives at `%APPDATA%\GHISLER` and is kept in sync with the persist location manually.

## Files

| File | Purpose |
|---|---|
| `WINCMD.INI` | Main TC config — colors, shortcuts, layout, history |
| `VERTICAL.BAR` | Vertical toolbar button layout |
| `tcignore.txt` | Files/dirs TC ignores in listings |
| `wcx_ftp.ini` | FTP plugin settings — gitignored (may contain credentials) |
| `themes/Set-TCTheme.ps1` | Theme switcher script |

## Themes

Six themes are available, grouped into 3 families × light/dark:

| Command | Theme | Mode |
|---|---|---|
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
|---|---|
| 1 | `*.exe;*.com;bin*.;plugins;system*.;run*.;*.lnk;*.dll` |
| 2 | `*.log` |
| 3 | `*.pdf` |
| 4 | `*.doc?;*.xls?;*.ppt?;*.vsd?` |
| 5 | `*.json;*.csv;` |
| 6 | `README.md;readme.txt` |
| 7 | `*.bat;*.cmd;*.sh;*.ps1` |
| 8 | `*.toml;*.ini;*.yaml;*.inf;.editorconfig` |

## Syncing changes

TC writes config on exit. After closing TC, commit from this directory:

```bash
git add WINCMD.INI VERTICAL.BAR tcignore.txt
git commit -m "update TC config"
git push
```

> Do not commit `wcx_ftp.ini` — it is gitignored.
