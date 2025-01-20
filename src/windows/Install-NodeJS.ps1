[CmdletBinding(PositionalBinding = $false)]
param(
  [Parameter(Mandatory = $true)]
  [string] $Version,
  [Parameter(Mandatory = $true)]
  [string] $Directory,
  [Parameter(Mandatory = $true)]
  [string] $Prefix
)

$global:ErrorActionPreference = "Stop"
$global:ProgressPreference = "SilentlyContinue"
Set-StrictMode -Version Latest

$NodeInstallerName = "node-v$Version-x64.msi"
Write-Host "Downloading NodeJS $Version..."
$NodeUrl = "https://nodejs.org/dist/v$Version/$NodeInstallerName"
$NodeShaSum256Url = "https://nodejs.org/dist/v$Version/SHASUMS256.txt"
$NodeInstallerPath = "$env:TEMP\$NodeInstallerName"
$NodeShaSum256Path = "$env:TEMP\SHASUMS256.txt"
Invoke-WebRequest -Uri $NodeUrl -OutFile $NodeInstallerPath
Invoke-WebRequest -Uri $NodeShaSum256Url -OutFile $NodeShaSum256Path

# Check the SHA256 hash of the downloaded file against the expected value
# Search for the SHASUMS256 text file for the line matching the installer downloaded.
# The file format is a line delimited list of <SHASUM256><tab><filename>
$ExpectedNodeInstallerShaSum256 = Get-Content -Path $NodeShaSum256Path | ForEach-Object {
    $LineParts = $_ -split "\s+", 2
    if ($LineParts[1] -eq $NodeInstallerName) {
        return $LineParts[0]
    }
}

$ActualNodeInstallerSha256 = (Get-FileHash $NodeInstallerPath -Algorithm SHA256).Hash
if ($ActualNodeInstallerSha256 -ne $ExpectedNodeInstallerShaSum256) {
    throw "Failed to verify sentry-cli.exe (Wanted $ExpectedNodeInstallerShaSum256; Got $ActualNodeInstallerSha256)"
}

Write-Host "Installing Node.js $Version..."
& msiexec.exe /qn /i $NodeInstallerPath INSTALLDIR=$Directory | Write-Host

# For the moment, use 16 as that matches the major version of $Version, but
# eventually make this include the value of $Version in some way
$env:PATH = "$Directory;$env:PATH"
& npm config set prefix $Directory

Write-Host "NPM configuration, local"
& npm config list

Write-Host "NPM configuration, global"
& npm config list -g
