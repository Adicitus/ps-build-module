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

    if (Test-Path $ProjectDirectoryPath -PathType Container) {
        throw ("Unable to initialize module project at '{0}', the directory already exists." -f $ProjectDirectoryPath)
    }
    mkdir $ProjectDirectoryPath

    $buildSettingsDirPath = "{0}\build.settings" -f $ProjectDirectoryPath
    mkdir $buildSettingsDirPath

    $manifestSourceDirPath = "$PSScriptRoot\.assets\defaultManifest"
    $manifestDestDirPath = "{0}\manifest" -f $buildSettingsDirPath

    Copy-Item -Path $manifestSourceDirPath -Destination $manifestDestDirPath -Recurse

    $buildSettingsModuleNamePath = "{0}\modulename" -f $buildSettingsDirPath
    $manifestAuthorPath = "{0}\author" -f $manifestDestDirPath
    
    $moduleGuid = [guid]::NewGuid() | % Guid
    $manifestGuidPath = "{0}\guid" -f $manifestDestDirPath
    
    $ModuleName | Out-File -FilePath $buildSettingsModuleNamePath -Encoding utf8
    $Author     | Out-File -FilePath $manifestAuthorPath -Encoding utf8
    $moduleGuid | Out-File -FilePath $manifestGuidPath -Encoding utf8



    $sourceScriptDirPath = "{0}\source" -f $ProjectDirectoryPath
    mkdir $sourceScriptDirPath
}