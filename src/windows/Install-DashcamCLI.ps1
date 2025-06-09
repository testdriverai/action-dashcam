param (
  [Parameter(Mandatory = $true)]
  [string]$Version
)

$global:ErrorActionPreference = "Stop"
$global:ProgressPreference = "SilentlyContinue"
Set-StrictMode -Version Latest

Write-Host "Installing Dashcam CLI $Version..."

& npm install --location=global dashcam@$Version

Write-Host "Verifying Dashcam CLI Install..."
& dashcam --help
& dashcam --version
