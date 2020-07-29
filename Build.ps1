param(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$ProjectRoot,
    [Parameter(Mandatory=$false, Position=2)]
    [string]$OutRoot = "$ProjectRoot\out"
)

. "$PSScriptRoot\source\Build-ModuleProject.ps1"

$args = @{
    ProjectRoot = $ProjectRoot
}

if ($OutRoot) {
    $args.OutRoot = $OutRoot
}

Build-ModuleProject @args
