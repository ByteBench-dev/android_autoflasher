
# Function to install Chocolatey if not installed
function Install-Chocolatey {
    if (-not (Test-Path "$env:ProgramData\chocolatey")) {
        $InstallDir='C:\ProgramData\chocoportable'
        $env:ChocolateyInstall="$InstallDir"
        Set-ExecutionPolicy Bypass -Scope Process -Force;
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
}

# Check if Chocolatey is installed
if (-not (Test-Path "$env:ProgramData\chocolatey")) {
    Install-Chocolatey
}

function Install-PackageIfNotInstalled {
    param (
        [string]$PackageName,
        [string]$InstallerScript
    )
    if (-not (Get-Command $PackageName -ErrorAction SilentlyContinue)) {
        Write-Output "Installing $PackageName..."
        Invoke-Expression $InstallerScript
    }
}

Install-PackageIfNotInstalled "git" "choco install git -y"
Install-PackageIfNotInstalled "python" "choco install python -y"
Install-PackageIfNotInstalled "virtualenv" "pip install virtualenv"

Install-PackageIfNotInstalled "adb" "choco install adb -y"
Install-PackageIfNotInstalled "fastboot" "choco install fastboot -y"


$nome = Read-Host "Do you wish to flash the image Y/N"
if ($nome -eq "Y") {
    Start-Process -Wait -FilePath python -ArgumentList "ports_finder.py FASTBOOT"
    Write-Output "Waiting for fastboot"
    do {
        Start-Sleep 1
        $fastbootDevices = fastboot devices
    } while (!$fastbootDevices)

    # Select file dialog
    Add-Type -AssemblyName System.Windows.Forms
    function Select-File {
        $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $fileDialog.InitialDirectory = "C:\"
        $fileDialog.Filter = "All files (*.*)|*.*"
        $fileDialog.Title = "Select a file"
        $fileDialog.ShowDialog() | Out-Null
        $selectedFile = $fileDialog.FileName
        return $selectedFile
    }

    $selectedFile = Select-File

    # Flashing operations
    fastboot flashing unlock
    fastboot -w
    fastboot reboot-fastboot
    fastboot flash system --disable-verity --disable-verification $selectedFile
    fastboot reboot
}

Write-Host "Flashing completed."

