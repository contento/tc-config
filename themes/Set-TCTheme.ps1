#Requires -Version 5.1
param(
    [Parameter(Mandatory)]
    [ValidateSet('github', 'rosepine', 'catppuccin', 'solarized')]
    [string]$Theme,
    [ValidateSet('light', 'dark')]
    [string]$Mode = 'light'
)

$ErrorActionPreference = 'Stop'
$iniPath = Join-Path $env:APPDATA 'GHISLER\wincmd.ini'
$tcExe   = Join-Path $env:USERPROFILE 'scoop\apps\totalcommander\current\TOTALCMD64.EXE'

# Color values: COLORREF decimal = B*65536 + G*256 + R
# Each theme: Back/Fore/Mark/Cursor/CursorText for panels,
#             F[] = light-mode file-type colors (8 filters)
#             FD[] = dark-mode file-type colors (8 filters)
$themes = @{
    'github-light' = @{
        Back=16447734; Back2=-1; Fore=3090724; Mark=14313737
        Cursor=14313737; CursorText=16777215; DarkMode=0
        F =@(8484718,  26522,   3023567, 3637018, 11423749, 14635138, 2387937, 6893578)
        FD=@(10392715, 2267602, 7502847, 5290303, 16760953, 16754898, 5744383, 16766629)
    }
    'github-dark' = @{
        Back=1511693; Back2=-1; Fore=15986150; Mark=15429407
        Cursor=15429407; CursorText=16777215; DarkMode=1
        F =@(10392715, 2267602, 7502847, 5290303, 16760953, 16754898, 5744383, 16766629)
        FD=@(10392715, 2267602, 7502847, 5290303, 16760953, 16754898, 5744383, 16766629)
    }
    'rosepine-light' = @{
        Back=15594746; Back2=-1; Fore=7950935; Mark=8612136
        Cursor=8612136; CursorText=15594746; DarkMode=0
        F =@(10851224, 3448298, 8020916, 8612136, 10458198, 11106960, 8291031, 7561499)
        FD=@(8809070,  7848438, 9596907, 11374397, 14208924, 15181764, 12238059, 13287291)
    }
    'rosepine-dark' = @{
        Back=2365209; Back2=-1; Fore=16047840; Mark=9596907
        Cursor=9401393; CursorText=16047840; DarkMode=1
        F =@(8809070,  7848438, 9596907, 11374397, 14208924, 15181764, 12238059, 13287291)
        FD=@(8809070,  7848438, 9596907, 11374397, 14208924, 15181764, 12238059, 13287291)
    }
    'catppuccin-light' = @{
        Back=16118255; Back2=-1; Fore=6901580; Mark=16082462
        Cursor=16082462; CursorText=16118255; DarkMode=0
        F =@(9666428, 1937119, 3739602, 2859072, 10064407, 15677832, 746750,  15049988)
        FD=@(8810604, 11526905, 11045875, 10609574, 14017172, 16230091, 8893434, 15517556)
    }
    'catppuccin-dark' = @{
        Back=3022366; Back2=-1; Fore=16045773; Mark=16430217
        Cursor=4469297; CursorText=16045773; DarkMode=1
        F =@(8810604, 11526905, 11045875, 10609574, 14017172, 16230091, 8893434, 15517556)
        FD=@(8810604, 11526905, 11045875, 10609574, 14017172, 16230091, 8893434, 15517556)
    }
    # Solarized: accent colors are identical in light and dark (by design)
    # Light bg: #FDF6E3 (base3)  Dark bg: #002B36 (base03 — teal)
    'solarized-light' = @{
        Back=14939901; Back2=-1; Fore=8616805; Mark=13798182
        Cursor=13798182; CursorText=14939901; DarkMode=0
        F =@(7695960, 35253, 3093212, 39301, 10002730, 12874092, 1461195, 13798182)
        FD=@(9868419,  35253, 3093212, 39301, 10002730, 12874092, 1461195, 13798182)
    }
    'solarized-dark' = @{
        Back=3549952; Back2=-1; Fore=9868419; Mark=13798182
        Cursor=4339207; CursorText=10592659; DarkMode=1
        F =@(9868419, 35253, 3093212, 39301, 10002730, 12874092, 1461195, 13798182)
        FD=@(9868419, 35253, 3093212, 39301, 10002730, 12874092, 1461195, 13798182)
    }
}

$filterPatterns = @(
    '*.exe;*.com;bin*.;plugins;system*.;run*.;*.lnk;*.dll',
    '*.log',
    '*.pdf',
    '*.doc?;*.xls?;*.ppt?;*.vsd?',
    '*.json;*.csv;',
    'README.md;readme.txt',
    '*.bat;*.cmd;*.sh;*.ps1',
    '*.toml;*.ini;*.yaml;*.inf;.editorconfig'
)

$key = "$Theme-$Mode"
$c = $themes[$key]

# Build the replacement [Colors] block
$newColors = [System.Collections.Generic.List[string]]::new()
$newColors.AddRange([string[]]@(
    '[Colors]',
    'InverseCursor=0',
    'ThemedCursor=1',
    'InverseSelection=1',
    "BackColor=$($c.Back)",
    "BackColor2=$($c.Back2)",
    "ForeColor=$($c.Fore)",
    "MarkColor=$($c.Mark)",
    "CursorColor=$($c.Cursor)",
    "CursorText=$($c.CursorText)",
    ''
))
for ($i = 0; $i -lt 8; $i++) {
    $n = $i + 1
    $newColors.Add("ColorFilter$n=$($filterPatterns[$i])")
    $newColors.Add("ColorFilter${n}Color=$($c.F[$i])")
    $newColors.Add("ColorFilter${n}ColorDark=$($c.FD[$i]),$($c.F[$i])")
}
$newColors.Add('')

# Read INI preserving original encoding (Windows-1252 keeps TC's SetEncoding bytes intact)
$enc = [System.Text.Encoding]::GetEncoding(1252)
$lines = [System.IO.File]::ReadAllLines($iniPath, $enc)

$output = [System.Collections.Generic.List[string]]::new()
$inColors = $false

foreach ($line in $lines) {
    if ($line -eq '[Colors]') {
        $inColors = $true
        $output.AddRange($newColors)
        continue
    }
    if ($inColors) {
        if ($line -match '^\[') {
            $inColors = $false
            $output.Add($line)
        }
        continue
    }
    if ($line -match '^DarkMode=') {
        $output.Add("DarkMode=$($c.DarkMode)")
        continue
    }
    $output.Add($line)
}

[System.IO.File]::WriteAllLines($iniPath, $output, $enc)

# Restart Total Commander
Get-Process TOTALCMD64 -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 700
Start-Process $tcExe
