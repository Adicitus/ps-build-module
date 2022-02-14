# Build.ps1 - ps-build-module - https://github.com/Adicitus/ps-build-module

<#
Build script used to compile PS Modules arranged as:
 [ProjectRoot Dir]
    |- "source" folder
    |  |- 0-1 ".assets" folder.
    |  |- 0-* .ps1 files.
    |  |- 0-* additional nested source folders (can contain 1 .assets folder and  any number of .ps1 files).
    |- "build.settings" folder
       |- modulename.ps1
       |- "manifest" folder
          |- Manifest setting file(s)

The script will take all of the .ps1 under the "source" folder and flatten them into a
single .psm1 file under "$OutRoot\$modulename\" directory. All assets in the .assets
folders will similarly be combined in a ".assets" folder under "$OutRoot\$modulename\".

The .ps1 files i a directory will be processed in lexicographical order. Subdirectories
will also be processed in this order.
#>

function Export-ModuleProject {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$false, Position=1)]
        [string]$ProjectRoot=".",
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$false, Position=2)]
        [string]$OutRoot = "$ProjectRoot\out"
    )

    # Build manifest
    $manifestArgs = @{}
    $buildArgs = @{}

    Get-ChildItem "$ProjectRoot\build.settings" -File | ForEach-Object {
        $name = $_.Name.split(".")[0]
        if ($_.name -like "*.ps1") {
            $buildArgs.$name = & $_.FullName
        } else {
            $buildArgs.$name = Get-Content $_.FullName
        }
    }

    Get-ChildItem "$ProjectRoot\build.settings\manifest" -File | ForEach-Object {
        $name = $_.Name.split(".")[0]
        if ($_.name -like "*.ps1") {
            $manifestArgs.$name = & $_.FullName
        } else {
            $manifestArgs.$name = (Get-Content $_.FullName) -join "`n"
        }
    }

    $moduleName = $buildArgs.modulename

    if (-not $moduleName) {
        throw "No module name set ('-not `$modulename' evaluates to `$false)!"
    }

    $SrcDir = "$ProjectRoot\source"
    $outDir = "$OutRoot\$moduleName"
    $assetsOutDir = "$outDir\.assets"

    $moduleFile     = "{0}\{1}.psm1" -f $outDir, $moduleName
    $manifestFile   = "{0}\{1}.psd1" -f $outDir, $moduleName

    if (Test-Path $outDir -PathType Container) {
        Remove-Item $outDir -Force -Recurse
    }

    $null = New-Item $outDir -ItemType Directory

    # Build Script module

    $addFolder = {
        param(
            [System.IO.DirectoryInfo]$item,
            [String]$subname
        )
        
        if ($subname) {
            "# {0}.{1}" -f $moduleName, $subname >> $moduleFile
        }

        if ($assetsDir = Get-ChildItem $item.FullName -Filter ".assets" -Directory) {
            if ( !(Test-Path $assetsOutDir) ) {
                mkdir $assetsOutDir
            }

            $assetsDir | Get-ChildItem | ForEach-Object {
                Copy-Item $_.FullName -Destination "$assetsOutDir\" -Recurse 
            }
        }

        Get-ChildItem $item.FullName -Filter *.ps1 | Sort-Object -Property Name | ForEach-Object {
            Get-Content $_.FullName >> $moduleFile
        }

    }

    # Start with the root dir
    . $addFolder (Get-Item $srcDir)

    # Then include subfolders
    Get-ChildItem $srcDir -Directory -Exclude .assets | Sort-Object -Property Name | ForEach-Object {
        $item = $_

        . $addFolder $item $item.Name
    }

    $manifestArgs | Out-String | Write-Host

    # Generate the manifest
    New-ModuleManifest -Path $manifestFile @manifestArgs
}