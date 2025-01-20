$global:ErrorActionPreference = "Stop"
$global:ProgressPreference = "SilentlyContinue"
Set-StrictMode -Version Latest

& npm install --location=global dashcam

Write-Host "Verifying Dashcam CLI Install..."
& dashcam --help
& dashcam --version
