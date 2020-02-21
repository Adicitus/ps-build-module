

param(
    $OutRoot="$PSScriptRoot\out"
)

# Build manifest
$manifestArgs = @{}
$buildArgs = @{}

Get-ChildItem "$PSScriptRoot\build.settings" -File | ForEach-Object {
    $name = $_.Name.split(".")[0]
    $buildArgs.$name = & $_.FullName
}

Get-ChildItem "$PSScriptRoot\build.settings\manifest" -File | ForEach-Object {
    $name = $_.Name.split(".")[0]
    $manifestArgs.$name = & $_.FullName
}

$moduleName = $buildArgs.modulename

$outDir = "$OutRoot\$moduleName"
$assetsOutDir = "$outDir\.assets"
$srcDir = "$PSScriptRoot\source"

$moduleFile     = "{0}\{1}.psm1" -f $outDir, $moduleName
$manifestFile   = "{0}\{1}.psd1" -f $outDir, $moduleName

if (Test-Path $outDir) {
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

    Get-ChildItem $item.FullName -Filter *.ps1 | ForEach-Object {
        Get-Content $_.FullName >> $moduleFile
    }

}

# Start with the root dir
. $addFolder (Get-Item $srcDir)

# Then include subfolders
Get-ChildItem $srcDir -Directory | ForEach-Object {
    $item = $_

    . $addFolder $item $item.Name
}

New-ModuleManifest -Path $manifestFile @manifestArgs

$manifest = Get-Content $manifestFile

# Trim the manifest
Remove-Item $manifestFile

$manifest | Where-Object {
    $_ -notmatch "^\s*$"
} | Where-Object {
    $_ -notmatch "^\s*\#"
} | ForEach-Object {
    $_ -replace "\#.*$", "" >> $manifestFile
}