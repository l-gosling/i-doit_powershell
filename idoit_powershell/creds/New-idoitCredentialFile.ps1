<#
.SYNOPSIS
    Creates credential files for i-doit API access.

.DESCRIPTION
    This script creates encrypted credential files for i-doit API access.
    It stores the API key and credentials in separate files in a 'creds' directory.

.NOTES
    File Name      : New-idoitCredentialFile.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell
    
.EXAMPLE
    .\New-idoitCredentialFile.ps1
    Creates encrypted credential files for i-doit API access in the 'creds' directory.
#>

# Determine script path based on host environment
$ScriptPath = Switch ($host.name) {
    'Visual Studio Code Host'     { Split-Path $PsEditor.GetEditorContext().CurrentFile.Path }
    'Windows PowerShell ISE Host' { Split-Path -Path $psISE.CurrentFile.FullPath }
    'ConsoleHost'                { $PsScriptRoot }
}

# Set working directory to script location
Set-Location $ScriptPath

# Create credentials directory if it doesn't exist
if (!(Test-Path($ScriptPath))) {
    New-Item ($ScriptPath) -ItemType Directory | Out-Null
}

# Store encrypted API key and credentials
Read-Host "Enter apikey" -AsSecureString | 
    ConvertFrom-SecureString | 
    Out-File "$($ScriptPath)\Credentials_idoit_apikey_$($env:USERNAME).txt"

Get-Credential | 
    Export-CliXml -Path "$($ScriptPath)\Credentials_idoit_credentials_${env:USERNAME}.xml"