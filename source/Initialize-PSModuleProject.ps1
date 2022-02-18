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