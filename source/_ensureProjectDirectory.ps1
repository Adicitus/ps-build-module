function _ensureProjectDirectory{
    param(
        [string]$ProjectPath,
        [string]$ModuleName,
        [string]$ModuleAuthor,
        [guid]$ModuleGuid = [guid]::NewGuid()
    )

    "Building project directory at '{0}'..." -f $ProjectPath | Write-Debug

    $directoryStructure = @{
        type='directory'

        children = @{
            'build.settings' = @{
                type = 'directory'

                children = @{
                    'manifest' = @{
                        type = 'directory'
                        src = "$PSScriptRoot\.assets\defaultManifest"
                        children = @{
                            author = @{
                                type = 'file'
                                content = $ModuleAuthor
                            }
                            guid = @{
                                type = 'file'
                                content = $ModuleGuid
                            }
                        }
                    }
                    'modulename' = @{
                        type='file'
                        content=$ModuleName
                    }
                }
            }
            'source' = @{
                type='directory'
            }
        }
    }

    $buildDirectory = {
        param($path, $itemSpec, $prefixLength=0)
        
        switch ($prefixLength) {
            0 {
                $itemPrefix = ""
                $infoPrefix = ""
            }

            3 {
                $itemPrefix = "|- "
                $infoPrefix = "   "
            }

            default {
                $itemPrefix = "|- ".PadLeft($prefixLength + 3, " ")
                $infoPrefix = "   ".PadLeft($prefixLength + 3, " ")
            }
        }

        $exists = switch ($itemSpec.type) {
            file {
                Test-Path $path -PathType Leaf
            }

            directory {
                Test-Path -Path $path -PathType Container
            }
        }

        $leaf = Split-Path $path -Leaf

        if ($exists) {
            "{0}{2} '{1}': Found!" -f $itemPrefix, $leaf, $itemSpec.type.ToUpper() | Write-Debug
        } else {
            "{0}{2} '{1}': Missing!" -f $itemPrefix, $leaf, $itemSpec.type.ToUpper() | Write-Debug
        }

        if (!$exists) {
            switch($itemSpec.type) {
                file {
                    if ($itemSpec.src) {
                        Copy-Item -Path $itemSpec.src -Destination $path
                        "{0}Copying from '{1}'" -f $infoPrefix, $itemSpec.src | Write-Debug
                    } else {
                        "{0}Creating blank file" -f $infoPrefix | Write-Debug
                        New-Item -Path $path -ItemType File | Out-Null
                    }

                    if ($itemSpec.content) {
                        "{0}Setting content to '{1}'" -f $infoPrefix, $itemSpec.content | Write-Debug
                        Set-Content -Path $path -Value $itemSpec.content
                    }
                }

                directory {
                    if ($itemSpec.src) {
                        "{0}Copying from '{1}'" -f $infoPrefix, $itemSpec.src | Write-Debug
                        Copy-Item -Path $itemSpec.src -Destination $path -Recurse
                    } else {
                        "{0}Creating empty directory" -f $infoPrefix | Write-Debug
                        New-Item -Path $path -ItemType Directory | Out-Null
                    }
                }
            }
        }
                
        if ($children = $itemSpec.children) {
            foreach ($childName in $children.Keys) {
                $childPath = "{0}\{1}" -f $path, $childName

                & $buildDirectory $childPath $children[$childName] ($prefixLength + 3)
            }
        }

    }

    & $buildDirectory $ProjectPath $directoryStructure

}