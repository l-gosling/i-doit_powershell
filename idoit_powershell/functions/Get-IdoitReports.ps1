<#
.SYNOPSIS
    Retrieves a list of available reports from i-doit CMDB.

.DESCRIPTION
    This function queries the i-doit API to retrieve all configured reports 
    and their metadata. It requires an active API session and returns a list
    of reports that can be executed.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint (e.g., "https://idoit.example.com/src/jsonrpc.php")

.PARAMETER sessionId
    The active session ID for API authentication.

.PARAMETER apiKey
    The API key as a SecureString.

.NOTES
    File Name      : Get-IdoitReports.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell, active i-doit API session
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/cmdb.reports.html#cmdbreportsread
    
.EXAMPLE
    $apiKey = ConvertTo-SecureString "yourApiKey" -AsPlainText -Force
    Get-IdoitReports -apiUrl "https://idoit.example.com/api/jsonrpc.php" `
                     -sessionId "abc123" `
                     -apiKey $apiKey
#>
function Get-IdoitReports {
    param (
        [Parameter(Mandatory=$true)][String]$apiUrl,
        [Parameter(Mandatory=$true)][String]$sessionId,
        [Parameter(Mandatory=$true)][SecureString]$apiKey
    )

    #define the parameters
    $params = @{
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