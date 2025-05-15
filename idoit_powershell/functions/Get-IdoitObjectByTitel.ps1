<#
.SYNOPSIS
    Retrieves i-doit objects by their title.

.DESCRIPTION
    This function searches for objects in the i-doit CMDB by their title.
    It requires an active API session and returns matching objects with their
    properties and configurations.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint (e.g., "https://idoit.example.com/src/jsonrpc.php")

.PARAMETER sessionId
    The active session ID for API authentication.

.PARAMETER apiKey
    The API key as a SecureString.

.PARAMETER title
    The title to search for in the CMDB objects.

.OUTPUTS
    Returns an array of PSObjects containing matching objects with their details:
    - ID
    - Title
    - Type
    - Status
    - Created/Updated dates

.NOTES
    File Name      : Get-IdoitObjectByTitle.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell, active i-doit API session
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/cmdb.objects.html#cmdbobjectsread

    Changelog:
    2025-04-15 - Initial version (lgo13)
    
.EXAMPLE
    $apiKey = ConvertTo-SecureString "yourApiKey" -AsPlainText -Force
    Get-IdoitObjectByTitle -apiUrl "https://idoit.example.com/api/jsonrpc.php" `
                          -sessionId "abc123" `
                          -apiKey $apiKey `
                          -title "Server01"
#>
function Get-IdoitObjectByTitle {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$apiUrl,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$sessionId,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [SecureString]$apiKey,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$title
    )

    # Create filter hashtable for title search
    $filter = @{
        "title" = $title
    }

    # Build parameter hashtable for API request
    $params = @{
        "filter"   = $filter
        "limit"    = "0,2"        # Retrieve up to 2 matching objects
        "apikey"   = (New-Object PSCredential 0, $apiKey).GetNetworkCredential().Password
        "language" = "en"
    }

    # Query i-doit API for objects matching the title
    try {
        $response = Invoke-Idoit -ApiUrl $apiUrl `
                                -SessionId $sessionId `
                                -Method "cmdb.objects.read" `
                                -Params $params `
                                -ErrorAction Stop
    }
    catch {
        throw "Failed to retrieve objects with title '$title': $_"
    }

    # Return the matching objects
    return $response
}