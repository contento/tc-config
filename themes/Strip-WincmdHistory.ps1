# Git clean filter — strips history sections from WINCMD.INI on git add.
# Working copy is never touched; only the staged/committed version is cleaned.
# Registered via: git config filter.strip-tc-history.clean "powershell ... -File Strip-WincmdHistory.ps1"

$historyPattern = '^\[(Command line history|LeftHistory|RightHistory|SearchText|SearchName|SearchIn|NewFileHistory|MkDirHistory|Selection|RenameTemplates|RenameSearchReplace)\]$'

$inHistory = $false
while ($null -ne ($line = [Console]::In.ReadLine())) {
    if ($line -match $historyPattern) {
        $inHistory = $true
        continue
    }
    if ($inHistory -and $line -match '^\[') {
        $inHistory = $false
    }
    if (-not $inHistory) {
        [Console]::Out.WriteLine($line)
    }
}
