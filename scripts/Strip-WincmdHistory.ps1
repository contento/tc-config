# Git clean filter for WINCMD.INI — runs automatically on git add.
# 1. Strips history sections and personal sections (local paths must not reach the repo).
# 2. Normalises theme to GitHub Light — the committed default regardless of
#    what theme is active locally.
# Working copy is never touched; only the staged/committed version is cleaned.

$historyPattern = '^\[(Command line history|LeftHistory|RightHistory|SearchText|SearchName|SearchIn|NewFileHistory|MkDirHistory|Selection|RenameTemplates|RenameSearchReplace|DirMenu|lefttabs|righttabs)\]$'

$filterPatterns = @(
    '*.exe;*.com;bin*.;plugins;system*.;run*.;*.lnk;*.dll',
    '*.log', '*.pdf', '*.doc?;*.xls?;*.ppt?;*.vsd?',
    '*.json;*.csv;', 'README.md;readme.txt',
    '*.bat;*.cmd;*.sh;*.ps1',
    '*.toml;*.ini;*.yaml;*.inf;.editorconfig'
)
$lightF  = @(8484718,  26522,   3023567, 3637018, 11423749, 14635138, 2387937, 6893578)
$darkF   = @(10392715, 2267602, 7502847, 5290303, 16760953, 16754898, 5744383, 16766629)

$githubLightColors = [System.Collections.Generic.List[string]]::new()
$githubLightColors.AddRange([string[]]@(
    '[Colors]',
    'InverseCursor=0', 'ThemedCursor=1', 'InverseSelection=1',
    'BackColor=16447734', 'BackColor2=-1', 'ForeColor=3090724',
    'MarkColor=14313737', 'CursorColor=14313737', 'CursorText=16777215',
    ''
))
for ($i = 0; $i -lt 8; $i++) {
    $n = $i + 1
    $githubLightColors.Add("ColorFilter$n=$($filterPatterns[$i])")
    $githubLightColors.Add("ColorFilter${n}Color=$($lightF[$i])")
    $githubLightColors.Add("ColorFilter${n}ColorDark=$($darkF[$i]),$($lightF[$i])")
}
$githubLightColors.Add('')

$inHistory = $false
$inColors  = $false
$inLeft    = $false
$inRight   = $false

while ($null -ne ($line = [Console]::In.ReadLine())) {
    # --- history/personal sections: skip entirely ---
    if ($line -match $historyPattern) {
        $inHistory = $true
        continue
    }
    if ($inHistory -and $line -match '^\[') { $inHistory = $false }
    if ($inHistory) { continue }

    # --- [left]/[right]: track section, normalise path= ---
    if ($line -eq '[left]')  { $inLeft = $true;  $inRight = $false }
    if ($line -eq '[right]') { $inRight = $true; $inLeft  = $false }
    if ($line -match '^\[' -and $line -ne '[left]' -and $line -ne '[right]') {
        $inLeft = $false; $inRight = $false
    }
    if ($line -match '^path=' -and ($inLeft -or $inRight)) {
        if ($inLeft)  { [Console]::Out.WriteLine('path=%APPDATA%\GHISLER\') }
        else          { [Console]::Out.WriteLine('path=%USERPROFILE%\scoop\apps\totalcommander\current\') }
        continue
    }

    # --- [Colors] section: replace with GitHub Light ---
    if ($line -eq '[Colors]') {
        $inColors = $true
        foreach ($cl in $githubLightColors) { [Console]::Out.WriteLine($cl) }
        continue
    }
    if ($inColors -and $line -match '^\[') { $inColors = $false }
    if ($inColors) { continue }

    # --- DarkMode: always commit as light ---
    if ($line -match '^DarkMode=') {
        [Console]::Out.WriteLine('DarkMode=0')
        continue
    }

    [Console]::Out.WriteLine($line)
}
