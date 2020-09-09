param(
    [Parameter(Mandatory=$false, Position=1)]
    [string]$ProjectRoot=$PSScriptRoot,
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
