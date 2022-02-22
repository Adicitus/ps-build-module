<#
.SYNOPSIS
Initializes a Module Project in the given directory.

.DESCRIPTION
Initializes a Module Project in the given directory.

The following directiry structure is constructed:

$ProjectDirectiryRoot
    |- build.settings
        |- manifest
            |- AliasesToExport.ps1
            |- CmdletsToExport.ps1
            |- CompanyName
            |- FunctionsToExport.ps1
            |- ModuleVersion
            |- RootModule.ps1
            |- VariablesToExport.ps1
        |- modulename.ps1
    |- source
        |- .assets

Module manifest details are added as files to the vuild.settings/manifest
folder, while script files to be included in the module should be added
to the source folder.

#>
function Initialize-PSModuleProject{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$ProjectDirectoryPath,
        [Parameter(Mandatory=$true, Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName,
        [Parameter(Mandatory=$true, Position=3)]
        [ValidateNotNullOrEmpty()]
        [string]$Author
    )
    
    _ensureProjectDirectory $ProjectDirectoryPath $ModuleName $Author
}