param (
  # required parameter for dashcam api key
  [Parameter(Mandatory = $true)]
  [string]$ApiKey,

  # paths to log files to track, newline separated
  [string]$LogFilePaths,

  # required parameter for the timeout
  [Parameter(Mandatory = $true, HelpMessage = "The timeout in seconds.")]
  [int]$Timeout
)


Write-Host "::group::Checking Dashcam availability."
$AppName = "Dashcam"
$Elapsed = 0

# Loop until the application is found or timeout is reached
while (-not (Get-Process -Name $AppName -ErrorAction SilentlyContinue) -and $Elapsed -lt $Timeout) {
  Write-Host "Waiting for $AppName to start..."
  Start-Sleep -Seconds 1
  $Elapsed++
}

if ($Elapsed -ge $Timeout) {
  Write-Host "Timeout reached. $AppName was not available from shell."
  exit 1
} else {
  Write-Host "$AppName has started."
}
Write-Host "::endgroup::"

Write-Host "Dashcam GUI started and ready to begin recording."

Write-Host "::group::Starting Dashcam recording."
# Environment variable set by the dashcam-install action
$env:PATH = "$env:DASHCAM_NODE_DIR;$env:DASHCAM_NODE_DIR\npm-installs;$env:PATH"

# The output of Dashcam after a successful auth is:
# Connected as: google-oauth2|<token>!
$authenticationOutput = dashcam auth "$ApiKey"
Write-Host $authenticationOutput
# The output of Dashcam after a successful auth is:
# Connected as: google-oauth2|<token>!
if ($authenticationOutput -like "*Connected as*") {
  Write-Host "Dashcam authenticated."
} else {
  Write-Host "Failed to authenticate with Dashcam."
  exit 1
}

# Split on both \r\n and just \n
$lines = "$LogFilePaths" -split "`r?`n"
# Iterate over each line skipping any that are empty
for ($i = 0; $i -lt $lines.Length; $i++) {
  $currentLine = $lines[$i].Trim()
  if ($currentLine -eq "") {
    continue
  }

  Write-Output "Dashcam will tail $currentLine"
  dashcam track --type application --name "log-file-$i" --pattern "$currentLine"
}

dashcam start
Write-Host "Dashcam recording has started."
Write-Host "::endgroup::"
