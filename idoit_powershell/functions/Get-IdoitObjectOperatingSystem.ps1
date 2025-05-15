<#
.SYNOPSIS
    Retrieves contact assignments for an i-doit object.

.DESCRIPTION
    This function retrieves all contact assignments (roles) for a specified object
    from the i-doit CMDB. It requires an active API session and returns the 
    contact relationships configured for the object.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint (e.g., "https://idoit.example.com/src/jsonrpc.php")

.PARAMETER sessionId
    The active session ID for API authentication.

.PARAMETER apiKey
    The API key as a SecureString.

.PARAMETER id
    The numeric ID of the i-doit object to query contacts for.

.OUTPUTS
    Returns an array of PSObjects containing contact assignments:
    - Contact ID
    - Contact Name
    - Role
    - Primary flag
    - Description

.NOTES
    File Name      : Get-IdoitObjectContactAssignment.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell, active i-doit API session
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/cmdb.category.html#cmdbcategoryread

    Changelog:
    2025-04-15 - Initial version (lgo13)
    
.EXAMPLE
    $apiKey = ConvertTo-SecureString "yourApiKey" -AsPlainText -Force
    Get-IdoitObjectContactAssignment -apiUrl "https://idoit.example.com/api/jsonrpc.php" `
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