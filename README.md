# tc-config

Personal [Total Commander](https://www.ghisler.com/) (x64) configuration with a multi-theme system.

## Background

Total Commander traces a direct lineage through three generations of file manager:

**[Norton Commander](https://en.wikipedia.org/wiki/Norton_Commander)** (1986) — John Socha at Peter Norton Computing introduced the definitive two-panel, keyboard-driven file manager for DOS. Its layout — dual panels, function-key bar, built-in viewer — established what is now formally called the *[Orthodox File Manager](https://en.wikipedia.org/wiki/Orthodox_file_manager)* (OFM) paradigm. Symantec acquired Peter Norton Computing in 1990 and continued the product through the mid-1990s.

**Windows Commander** (1993) — Swiss developer [Christian Ghisler](https://www.ghisler.com/whatsnew.htm) built a Windows counterpart that preserved the OFM model while adding built-in ZIP/ARJ support, a plugin architecture, and deep Windows shell integration. It became one of the most popular shareware utilities of the Windows 9x era.

**[Total Commander](https://en.wikipedia.org/wiki/Total_Commander)** (2002–present) — Microsoft objected to the "Windows" branding, prompting a rename to Total Commander. Ghisler has developed it solo ever since; it remains shareware and is still actively maintained. The `GHISLER` folder in `%APPDATA%` is a direct artifact of that history — TC has used the developer's surname as its config directory since the Windows Commander days.

## Themes

Eight themes across four families, each with a light and dark variant:

| Command | Family | Variant | Background |
| --- | --- | --- | --- |
| `github light` | GitHub | Light | `#F6F8FA` near-white |
| `github dark` | GitHub | Dark | `#0D1117` near-black |
| `rosepine light` | Rose Pine | Light (Dawn) | `#FAF4ED` warm cream |
| `rosepine dark` | Rose Pine | Dark (Main) | `#191724` deep plum |
| `catppuccin light` | Catppuccin | Light (Latte) | `#EFF1F5` cool off-white |
| `catppuccin dark` | Catppuccin | Dark (Mocha) | `#1E1E2E` deep blue-black |
| `solarized light` | Solarized | Light | `#FDF6E3` warm ivory |
| `solarized dark` | Solarized | Dark | `#002B36` dark teal |

Themes are switched via a PowerShell script that patches `WINCMD.INI` and restarts TC instantly.

## Installation

### 1. Install Total Commander

Pick any package manager:

```powershell
winget install Ghisler.TotalCommander                            # winget
scoop bucket add extras; scoop install totalcommander            # Scoop
choco install totalcommander                                     # Chocolatey
```

Or download the installer directly from [ghisler.com](https://www.ghisler.com/).

### 2. Clone this config into `$env:APPDATA\GHISLER`

```powershell
git clone https://github.com/contento/tc-config "$env:APPDATA\GHISLER"
```

### 3. Register the git clean filter

Strips all history sections and normalises the theme to GitHub Light on every `git add`.

```powershell
$script = "$env:APPDATA\GHISLER\scripts\Strip-WincmdHistory.ps1"
git -C "$env:APPDATA\GHISLER" config filter.strip-tc-history.clean "powershell -NonInteractive -NoProfile -File `"$script`""
git -C "$env:APPDATA\GHISLER" config filter.strip-tc-history.smudge cat
git -C "$env:APPDATA\GHISLER" config filter.strip-tc-history.required true
```

### 4. Register TC user commands

Copy or merge `usercmd.ini` from this repo into `$env:USERPROFILE\scoop\persist\totalcommander\usercmd.ini`
(or wherever your TC `usercmd.ini` lives).

### 5. Apply a theme

```powershell
& "$env:APPDATA\GHISLER\themes\Set-TCTheme.ps1" -Theme github -Mode light
& "$env:APPDATA\GHISLER\themes\Set-TCTheme.ps1" -Theme solarized -Mode dark
& "$env:APPDATA\GHISLER\themes\Set-TCTheme.ps1" -Theme rosepine -Mode dark
& "$env:APPDATA\GHISLER\themes\Set-TCTheme.ps1" -Theme catppuccin -Mode light
```

Or via TC's **Commands -> Start Menu** after step 4.

## Color filters

All themes share the same 8 file-type color filters, styled per palette:

| # | Pattern | Role |
| --- | --- | --- |
| 1 | `*.exe;*.com;*.dll;*.lnk` | Executables |
| 2 | `*.log` | Logs |
| 3 | `*.pdf` | PDFs |
| 4 | `*.doc?;*.xls?;*.ppt?;*.vsd?` | Office documents |
| 5 | `*.json;*.csv` | Data files |
| 6 | `README.md;readme.txt` | READMEs |
| 7 | `*.bat;*.cmd;*.sh;*.ps1` | Scripts |
| 8 | `*.toml;*.ini;*.yaml;*.inf;.editorconfig` | Config files |

## Repository layout

```text
GHISLER/
  WINCMD.INI                     Main TC config (committed as GitHub Light)
  VERTICAL.BAR                   Vertical toolbar layout
  tcignore.txt                   TC ignore list
  themes/
    Set-TCTheme.ps1              Theme switcher
  scripts/
    Strip-WincmdHistory.ps1      Git clean filter
```

## Git workflow

TC writes history (panel paths, searches, commands) into `WINCMD.INI` on exit. The git clean filter handles this automatically on `git add`:

- Strips all `[*History]` sections
- Normalises the theme to GitHub Light
- Working copy is never touched

```powershell
git add WINCMD.INI VERTICAL.BAR tcignore.txt
git commit -m "update TC config"
git push
```

> `wcx_ftp.ini` (FTP connections) and `wincmd.key` (license) are gitignored.

## Adding a new theme

1. Add a `'mytheme-light'` and `'mytheme-dark'` entry to `$themes` in `Set-TCTheme.ps1`
2. Add `[em_ThemeMyThemeLight]` / `[em_ThemeMyThemeDark]` blocks to `usercmd.ini`
3. Colors use Windows COLORREF format: `B*65536 + G*256 + R`

```powershell
# Convert #RRGGBB to COLORREF decimal
function ConvertTo-COLORREF([string]$hex) {
    $hex = $hex.TrimStart('#')
    $r = [Convert]::ToInt32($hex.Substring(0,2),16)
    $g = [Convert]::ToInt32($hex.Substring(2,2),16)
    $b = [Convert]::ToInt32($hex.Substring(4,2),16)
    return $b*65536 + $g*256 + $r
}
```
