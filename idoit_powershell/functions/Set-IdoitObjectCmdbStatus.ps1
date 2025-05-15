<#
.SYNOPSIS
    Updates the CMDB status of an i-doit object.

.DESCRIPTION
    This function updates the CMDB status of a specified object in the i-doit CMDB.
    The status must be one of the predefined values in the system, such as 
    'planned', 'in operation', or 'defect'.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint (e.g., "https://idoit.example.com/src/jsonrpc.php")

.PARAMETER sessionId
    The active session ID for API authentication.

.PARAMETER apiKey
    The API key as a SecureString.

.PARAMETER id
    The numeric ID of the i-doit object to update.

.PARAMETER status
    The ID of the status to set. Common values include:
    1  = planned
    2  = ordered
    3  = delivered
    4  = assembled
    5  = tested
    6  = in operation
    7  = defect
    8  = under repair
    9  = delivered from repair
    10 = inoperative
    11 = stored

.NOTES
    File Name      : Set-IdoitObjectCmdbStatus.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell, active i-doit API session
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/cmdb.category.html#cmdbcategorysave
    
.EXAMPLE
    $apiKey = ConvertTo-SecureString "yourApiKey" -AsPlainText -Force
    Set-IdoitObjectCmdbStatus -apiUrl "https://idoit.example.com/api/jsonrpc.php" `
                             -sessionId "abc123" `
                             -apiKey $apiKey `
                             -id 540 `
                             -status 6
#>
function Set-IdoitObjectCmdbStatus {
    param (
        [Parameter(Mandatory=$true)][String]$apiUrl,
        [Parameter(Mandatory=$true)][String]$sessionId,
        [Parameter(Mandatory=$true)][SecureString]$apiKey,
        [Parameter(Mandatory=$true)][int]$id,
        [Parameter(Mandatory=$true)][int]$status
    )

    #define the data for change
    $data = @{
        "cmdb_status" = $status
    }

    #define the parameters
    $params = @{
        "object" = $id
        "category" = "C__CATG__GLOBAL"
        "data" = $data
        "apikey" = (New-Object PSCredential 0, $apiKey).GetNetworkCredential().Password
        "language" = "en"
    }

    #send the request
    try {
        $response = Invoke-Idoit -ApiUrl $apiUrl -SessionId $sessionId -Method "cmdb.category.save" -Params $params -ErrorAction Stop
    }
    catch {
        throw $_
    }

    # return the response
    return $response
}