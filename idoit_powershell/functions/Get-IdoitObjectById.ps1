<#
.SYNOPSIS
    Retrieves object details from i-doit by object ID.

.DESCRIPTION
    This function retrieves detailed information about a specific object from 
    the i-doit CMDB using its unique ID. It requires an active API session
    and returns the object's properties and configurations.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint (e.g., "https://idoit.example.com/src/jsonrpc.php")

.PARAMETER sessionId
    The active session ID for API authentication.

.PARAMETER apiKey
    The API key as a SecureString.

.PARAMETER id
    The numeric ID of the i-doit object to retrieve.

.NOTES
    File Name      : Get-IdoitObjectById.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell, active i-doit API session
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/cmdb.objects.html#cmdbobjectread
    
.EXAMPLE
    $apiKey = ConvertTo-SecureString "yourApiKey" -AsPlainText -Force
    Get-IdoitObjectById -apiUrl "https://idoit.example.com/api/jsonrpc.php" `
                       -sessionId "abc123" `
                       -apiKey $apiKey `
                       -id 540
#>
function Get-IdoitObjectById {
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
        [ValidateRange(1, [int]::MaxValue)]
        [int]$id
    )

    # Create parameter hashtable for API request
    $params = @{
        "id"       = $id
        "apikey"   = (New-Object PSCredential 0, $apiKey).GetNetworkCredential().Password
        "language" = "en"
    }

    # Query i-doit API for object details
    try {
        $response = Invoke-Idoit -ApiUrl $apiUrl `
                                -SessionId $sessionId `
                                -Method "cmdb.object.read" `
                                -Params $params `
                                -ErrorAction Stop
    }
    catch {
        throw "Failed to retrieve object with ID: $_"
    }

    # Return the object details
    return $response
}