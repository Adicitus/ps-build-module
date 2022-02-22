# ps-build-module
Build script used to compile Module Projects into modules.

## Installation

This module can be installed from PSGallery, where it is called 'PSB>uildModule':

`Install-Module PSBuildModule`

## Commands

### Export-PSModuleProject
Used to build a Module Project.

#### Parameters

###### [string] ProjectRoot
The root directory of the Module Project (containing the "source" and "build.settings" folders).

This defaults to the current directory (same as specifying '.').

###### [string] OutRoot
The directory where the module folder should be generated.

This defaults to './out' if not specified.

#### Initialize-ModuleProjectDirectory
Used to initialize a new Module Project folder.

#### Parameters

###### [string] ProjectDirectoryPath
The directory that should contain the Module Project.

If this is an existing folder, the cmdlet will verify the structure of the project directory and replace any missing files.

Versions before 1.2.0 will throw an exception to prevent overwriting existing work.

###### [string] ModuleName
The name of the module, this will be added to "$ProjectDirectoryRoot\build.settings\modulename" file.


###### [string] Author
This will be added to the "$ProjectDirectoryRoot\build.settings\manifest\author" file.


## Build instructions
This repostiory is in Module Project format. All the scripts and assets to be included in the module are located under the "source" folder.

Since this is the module intended to build modules from Module Projects, the Build.ps1 script is included as a shortcut for the Build-ModuleProject Cmdlet and can be used to generate a module from the project files, e.g.:

`.\Build.ps1`

This will generate a folder called "out" in the project directory containing the module.

In order to add the module directly to the PSModulesPath add the destination path as the second parameter, e.g.:

`.\Build.ps1 . "C:\Program Files\WindowsPowerShell\Modules"`

This will add the module directly to the PSModulesPath under "C:\Program Files\WindowsPowerShell\Modules" and make available to import.

## The Module Project format

A Module Project is a folder with 2 folder:
* source
* build.settings

### The "source" folder
The "source" folder is a folder containing a set of Powershell script files, and a ".assets" folder.

When the project is built, each of the powershell scripts will be appended to the .psm1 file in lexical order. So if you have statements that you wish to be run before any functions, cmdlets or aliases (etc.) are defined these can be added to a file called (for example, assuming the other files start with an alphanumeric character) .bootstrap.ps1 and they will be added to the .psm1 file before anything else.

Any files placed in the .assets folder will be copied straight to the .assets folder in the generated module folder.

This scheme will be repeated in subfolders to "source". Each subfolder will be added to the project in lexical order once the contents of the root folder has been processed.

The .assets folders in the subfolders will be merged into a common .assets folder when the project is built.

This process is repeated recursively in a breadth-first manner for each subfolder.

### The "build.settings" folder
The "build.settings" folder consists of 2 parts:
* Any files located in the folder will be interpreted as "build settings". Currently the settings recognized is "modulename" which specifies the name of the module.
* The files in the manifest folder will be used to generate the .psd1 file (the module manifest). Each file sould be named for the manifest entry it represents: the script will attempt to use *all* the files in this directory as parameters when generating the manifest file (for information on accepted entries, see [the Microsoft documentation](https://docs.microsoft.com/sv-se/powershell/scripting/developer/module/how-to-write-a-powershell-module-manifest?view=powershell-7)).

Any .ps1 files under build.settings will be executed in order to generate the intended value, and the file ending ".ps1" will be dropped from the setting's name. For any other files, their contents will be read from the file and the entire filename will be used as setting name.
