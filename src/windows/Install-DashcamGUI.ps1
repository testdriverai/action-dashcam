param (
  [Parameter(Mandatory = $true)]
  [string]$Version
)

$global:ErrorActionPreference = "Stop"
$global:ProgressPreference = "SilentlyContinue" # Accelerates Invoke-WebRequest
Set-StrictMode -Version Latest

function Invoke-Group([string]$Title, [ScriptBlock]$Block) {
    Write-Host "::group::$Title"
    & $Block
    Write-Host "::endgroup::"
}

$InstallDir = "$Env:TEMP\Dashcam"
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

$ExeFilename = "Dashcam-$Version.exe"
$ExePath = "$InstallDir\$ExeFilename"

Invoke-Group "Downloading Dashcam." {
    # Use the portable version rather than the installer, which was randomly failing
    $ExeUrl = "https://github.com/replayableio/replayable/releases/download/v$Version-portable/$ExeFilename"
    Invoke-WebRequest -Uri $ExeUrl -OutFile $ExePath
}

Invoke-Group "Creating configuration files." {
    # Create the directory
    $UserDataDir = "$InstallDir\user_data"
    New-Item -ItemType Directory -Path $UserDataDir -Force | Out-Null

    # Some settings are controlled by the existence of dummy files
    $ConfigFileNames = @(
        # Indicate that the GUI was visible at least once
        ".replayable--mainwindow-ever-launched",
        # Indicate that the TOS were accepted in the GUI
        ".replayable--has-accepted-tos",
        # No idea
        ".replayable--segment-done",
        # Indicate that the GUI app has launched at least once
        ".replayable--ever-launched",
        # Do not allow the GUI to auto-update
        ".replayable--do-not-update",
        # Do not allow the GUI to open a browser after uploading a video
        ".replayable--do-not-open-browser"
    )

    foreach ($ConfigFileName in $ConfigFileNames) {
        $FilePath = Join-Path -Path $UserDataDir -ChildPath $ConfigFileName
        if (-not (Test-Path -Path $FilePath)) {
            New-Item -ItemType File -Path $FilePath
        }
    }

    # Other settings are defined in a json file
    $Settings = @{
        "EDIT_ON_CLIP" = $false
        "CAPTURE_ERROR" = $false
        "DETECT_ERRORS_ONCE" = $true
    }

    # Convert to JSON with Dashcam-friendly formatting
    $SettingsJsonString = $Settings | ConvertTo-Json -Depth 1 -Compress
    
    # Use WriteAllText for UTF-8 without BOM
    $SettingsFilePath = Join-Path -Path $UserDataDir -ChildPath "settings.json"
    [System.IO.File]::WriteAllText($SettingsFilePath, $SettingsJsonString) 
}

Invoke-Group "Start Dashcam." {
    Start-Process -FilePath $ExePath | Out-Null
}
