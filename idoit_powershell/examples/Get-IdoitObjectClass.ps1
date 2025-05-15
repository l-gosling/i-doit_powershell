<#
.SYNOPSIS
    Demonstrates retrieving object category information from i-doit API.

.DESCRIPTION
    This example script shows how to:
    - Connect to the i-doit API
    - Retrieve object category information using a specific ID
    - Handle credentials securely
    - Properly disconnect from the API

.NOTES
    File Name      : Get-IdoitObjectClass.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell, i-doit API access, stored credentials
    
.EXAMPLE
    .\Get-IdoitObjectClass.ps1
    Retrieves and displays object category information for ID 540
#>

#region Script Path Detection
# Determine script path based on the PowerShell host environment
$scriptPath = Switch ($host.name) {
    'Visual Studio Code Host'     { Split-Path $PsEditor.GetEditorContext().CurrentFile.Path }
    'Windows PowerShell ISE Host' { Split-Path -Path $psISE.CurrentFile.FullPath }
    'ConsoleHost'                { $PsScriptRoot }
}
Set-Location $scriptPath
#endregion

#region Function Import
# Import all PowerShell functions from the functions directory
$functionsPath = [System.IO.Path]::GetFullPath($scriptPath + "\.." * 1) + "\functions\"
foreach ($PSScriptFile in (Get-ChildItem -Path $functionsPath -Filter "*.ps1")) {
    . $PSScriptFile.FullName
    Write-Verbose "Imported function from: $($PSScriptFile.FullName)"
}
#endregion

#region Credential Management
# Define API endpoint
[string]$apiUrlIdoit = "https://demo.i-doit.com/src/jsonrpc.php"

# Set path for credential storage
$credsPath = [System.IO.Path]::GetFullPath($scriptPath + "\.." * 1) + "\creds\"

# Retrieve stored credentials
$idoitCredentials = Get-IdoitCredentials -CredsPath $CredsPath
[String]$usernameIdoit = $idoitCredentials.Username
[SecureString]$passwordIdoit = $idoitCredentials.Password
[SecureString]$apikeyIdoit = $idoitCredentials.ApiKey
#endregion

#region API Connection
# Establish connection to i-doit API
$sessionIDAllInfos = Connect-Idoit -ApiUrl $apiUrlIdoit `
                                 -Username $usernameIdoit `
                                 -Password $passwordIdoit `
                                 -ApiKey $apikeyIdoit

$sessionID = $sessionIDAllInfos.'session-id'

# Verify connection success
if ($sessionID) {
    Write-Output "Connection established successfully with session ID: $sessionID"
    Write-Output ""
}
else {
    throw "Connection to i-doit failed. Please check your credentials and API URL."
}
#endregion

#region Parameter Configuration
# Create standard parameter hashtable for API calls
$standardIdoitParams = @{
    apiUrl    = $apiUrlIdoit
    sessionId = $sessionID
    apiKey    = $apikeyIdoit
}
#endregion

#region Example Operation
# Retrieve object category information for ID 540
$singleObjectCategory = Get-IdoitObjectCategory @standardIdoitParams -id 540 -category "C__CATG__GLOBAL"
Write-Host "Got object category details:" -ForegroundColor Cyan
Write-Host "Title: $($singleObjectCategory.Title)" -ForegroundColor Green
Write-Host "Object ID: $($singleObjectCategory.objID)" -ForegroundColor Green
Write-Output ""
#endregion

#region Cleanup
# Terminate API session
Disconnect-Idoit @standardIdoitParams
#endregion