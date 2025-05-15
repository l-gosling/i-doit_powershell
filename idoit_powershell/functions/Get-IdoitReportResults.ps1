<#
.SYNOPSIS
    Retrieves results from a specific report in i-doit CMDB.

.DESCRIPTION
    This function executes a specific report in the i-doit CMDB and retrieves 
    its results. It requires an active API session and the ID of the report
    to be executed.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint (e.g., "https://idoit.example.com/src/jsonrpc.php")

.PARAMETER sessionId
    The active session ID for API authentication.

.PARAMETER apiKey
    The API key as a SecureString.

.PARAMETER id
    The numeric ID of the report to execute.

.NOTES
    File Name      : Get-IdoitReportResults.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell, active i-doit API session
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/cmdb.reports.html#cmdbreportsread
    
.EXAMPLE
    $apiKey = ConvertTo-SecureString "yourApiKey" -AsPlainText -Force
    Get-IdoitReportResults -apiUrl "https://idoit.example.com/api/jsonrpc.php" `
                          -sessionId "abc123" `
                          -apiKey $apiKey `
                          -id 42
#>
function Get-IdoitReportResults {
    param (
        [Parameter(Mandatory=$true)][String]$apiUrl,
        [Parameter(Mandatory=$true)][String]$sessionId,
        [Parameter(Mandatory=$true)][SecureString]$apiKey,
        [Parameter(Mandatory=$true)][int]$id
    )

    #define the parameters
    $params = @{
        "id" = $id
        "apikey" = (New-Object PSCredential 0, $apiKey).GetNetworkCredential().Password
        "language" = "en"
    }

    #send the request
    try {
        $response = Invoke-Idoit -ApiUrl $apiUrl -SessionId $sessionId -Method "cmdb.reports.read" -Params $params -ErrorAction Stop
    }
    catch {
        throw $_
    }

    # return the response
    return $response
}