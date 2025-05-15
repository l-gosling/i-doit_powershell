<#
.SYNOPSIS
    Retrieves operating system information for an i-doit object.

.DESCRIPTION
    This function retrieves operating system details from the i-doit CMDB for a 
    specified object. It returns information such as OS type, version, and other
    system-related configurations.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint (e.g., "https://idoit.example.com/src/jsonrpc.php")

.PARAMETER sessionId
    The active session ID for API authentication.

.PARAMETER apiKey
    The API key as a SecureString.

.PARAMETER id
    The numeric ID of the i-doit object to query operating system information for.

.NOTES
    File Name      : Get-IdoitObjectOperatingSystem.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell, active i-doit API session
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/cmdb.category.html#cmdbcategoryread
    
.EXAMPLE
    $apiKey = ConvertTo-SecureString "yourApiKey" -AsPlainText -Force
    Get-IdoitObjectOperatingSystem -apiUrl "https://idoit.example.com/api/jsonrpc.php" `
                                  -sessionId "abc123" `
                                  -apiKey $apiKey `
                                  -id 540
#>
function Get-IdoitObjectOperatingSystem {
    param (
        [Parameter(Mandatory=$true)][String]$apiUrl,
        [Parameter(Mandatory=$true)][String]$sessionId,
        [Parameter(Mandatory=$true)][SecureString]$apiKey,
        [Parameter(Mandatory=$true)][int]$id
    )

    #define the parameters
    $params = @{
        "objID" = $id
        "category" = "C__CATG__OPERATING_SYSTEM"
        "apikey" = (New-Object PSCredential 0, $apiKey).GetNetworkCredential().Password
        "language" = "en"
    }

    #send the request
    try {
        $response = Invoke-Idoit -ApiUrl $apiUrl -SessionId $sessionId -Method "cmdb.category.read" -Params $params -ErrorAction Stop
    }
    catch {
        throw $_
    }

    # return the response
    return $response
}