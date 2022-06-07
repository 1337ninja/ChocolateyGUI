$ErrorActionPreference = 'Stop';
$toolsDir     = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation = Join-Path $toolsDir 'ChocolateyGUI.msi'

if(!$PSScriptRoot){ $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }
. "$PSScriptRoot\helper.ps1"

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  softwareName  = 'Chocolatey GUI'
  file          = $fileLocation
  fileType      = 'msi'
  silentArgs    = "/qn /norestart /l*v `"$env:TEMP\$env:ChocolateyPackageName.$env:ChocolateyPackageVersion.log`""
  validExitCodes= @(0,1641,3010)
}

Install-ChocolateyInstallPackage @packageArgs

Remove-Item -Force $packageArgs.file

$installDirectory = Get-AppInstallLocation $packageArgs.softwareName

if ($installDirectory) {
  Install-BinFile -Name "chocolateygui" -Path "$installDirectory\ChocolateyGui.exe" -UseStart
  Install-BinFile -Name "chocolateyguicli" -Path "$installDirectory\ChocolateyGuiCli.exe"
}

Update-SessionEnvironment

# Process package parameters
Set-UserSettings

Write-Host "Migrating old logs if any.."
$oldChocolateyDir = $env:ProgramData + "\ChocolateyGUI"
$oldChocolateyLogsDir = $oldChocolateyDir + "\Logs"
$newChocolateyLogsDir = $env:ProgramData + "\Chocolatey GUI\Archive Logs"
if (Test-Path -Path $oldChocolateyLogsDir) {
    Move-Item -Path $oldChocolateyLogsDir\* -Destination $newChocolateyLogsDir
    Remove-Item $oldChocolateyDir -Recurse
    Write-Host "Warning - Logs from a previous version are moved to $newChocolateyLogsDir. If you don't need them, fire up a Powershell and use Remove-Item to delete it"
}
