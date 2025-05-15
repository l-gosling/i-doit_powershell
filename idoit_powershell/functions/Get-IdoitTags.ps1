<#
.SYNOPSIS
    Retrieves all available tags from the i-doit CMDB.

.DESCRIPTION
    This function queries the i-doit API to retrieve all defined tags from the 
    global category. It returns a list of tags that can be used for object 
    tagging and categorization.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint (e.g., "https://idoit.example.com/src/jsonrpc.php")

.PARAMETER sessionId
    The active session ID for API authentication.

.PARAMETER apiKey
    The API key as a SecureString.

.NOTES
    File Name      : Get-IdoitTags.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell, active i-doit API session
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/cmdb.dialog.html#cmdbdialogread

.EXAMPLE
    $apiKey = ConvertTo-SecureString "yourApiKey" -AsPlainText -Force
    Get-IdoitTags -apiUrl "https://idoit.example.com/api/jsonrpc.php" `
                  -sessionId "abc123" `
                  -apiKey $apiKey
#>
function Get-IdoitTags {
    param (
        [Parameter(Mandatory=$true)][String]$apiUrl,
        [Parameter(Mandatory=$true)][String]$sessionId,
        [Parameter(Mandatory=$true)][SecureString]$apiKey
    )

    #define the parameters
    $params = @{
        "category" = "C__CATG__GLOBAL"
        "property" = "tag"
        "apikey" = (New-Object PSCredential 0, $apiKey).GetNetworkCredential().Password
        "language" = "en"
    }

    #send the request
    try {
        $response = Invoke-Idoit -ApiUrl $apiUrl -SessionId $sessionId -Method "cmdb.dialog.read" -Params $params -ErrorAction Stop
    }
    catch {
        throw $_
    }

    # return the response
    return $response
}