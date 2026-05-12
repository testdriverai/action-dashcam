param (
  # required parameter for dashcam api key
  [Parameter(Mandatory = $true)]
  [string]$ApiKey,

  # optional project slug to associate with this recording
  [string]$ProjectId,

  # optional recording title
  [string]$Title,

  # paths to log files to track, newline separated
  [string]$LogFilePaths
)

Write-Host "::group::Starting Dashcam recording."
# Environment variable set by the dashcam-install action
$env:PATH = "$env:DASHCAM_NODE_DIR;$env:DASHCAM_NODE_DIR\npm-installs;$env:PATH"
$authenticationOutput = dashcam auth "$ApiKey"
Write-Host $authenticationOutput
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

$startArgs = @("start")

if ($ProjectId -and $ProjectId.Trim() -ne "") {
  $startArgs += @("--project", $ProjectId)
}

if ($Title -and $Title.Trim() -ne "") {
  $startArgs += @("-t", $Title)
}

dashcam @startArgs
Write-Host "Dashcam recording has started."
Write-Host "::endgroup::"
