param(
    [Parameter(Mandatory=$false, Position=1)]
    [string]$ProjectRoot=$PSScriptRoot,
    [Parameter(Mandatory=$false, Position=2)]
    [string]$OutRoot = "$ProjectRoot\out"
)

. "$PSScriptRoot\source\Export-PSModuleProject.ps1"

$args = @{
    ProjectRoot = $ProjectRoot
}

if ($OutRoot) {
    $args.OutRoot = $OutRoot
}

Export-ModuleProject @args
