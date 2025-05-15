<#
.SYNOPSIS
    Retrieves operating system version information from i-doit.

.DESCRIPTION
    This function queries the i-doit CMDB to retrieve version information for a specific
    object. It returns details about the installed operating system version,
    service pack level, and patch status from the version category.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint (e.g., "https://idoit.example.com/src/jsonrpc.php")

.PARAMETER sessionId
    The active session ID for API authentication.

.PARAMETER apiKey
    The API key as a SecureString.

.PARAMETER id
    The numeric ID of the object to query version information for.
    Found in Software -> Operationg System -> *Choose OS* -> Version

.NOTES
    File Name      : Get-IdoitWindowsServerOperatingSystemVersions.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell, active i-doit API session
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/cmdb.category.html#cmdbcategoryread
    
.EXAMPLE
    $apiKey = ConvertTo-SecureString "yourApiKey" -AsPlainText -Force
    Get-IdoitWindowsServerOperatingSystemVersions -apiUrl "https://idoit.example.com/api/jsonrpc.php" `
                                                -sessionId "abc123" `
                                                -apiKey $apiKey `
                                                -id 540
#>
function Get-IdoitOperatingSystemVersions {
    param (
        [Parameter(Mandatory=$true)][String]$apiUrl,
        [Parameter(Mandatory=$true)][String]$sessionId,
        [Parameter(Mandatory=$true)][SecureString]$apiKey,
        [Parameter(Mandatory=$true)][int]$id
    )

    #define the parameters
    $params = @{
        "objID" = $id
        "category" = "C__CATG__VERSION"
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