<#
.SYNOPSIS
    Retrieves all possible CMDB status values from i-doit.

.DESCRIPTION
    This function queries the i-doit API to retrieve all available CMDB status values
    and their configurations. It requires an active session ID and API key for
    authentication.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint (e.g., "https://idoit.example.com/src/jsonrpc.php")

.PARAMETER sessionId
    The active session ID for API authentication

.PARAMETER apiKey
    The API key as a SecureString

.OUTPUTS
    Returns an array of PSObjects containing CMDB status details:
    - ID
    - Title
    - Constant
    - Status Type

.EXAMPLE
    $apiKey = ConvertTo-SecureString "your-apikey" -AsPlainText -Force
    $status = Get-IdoitCMDBStatus -apiUrl "https://idoit.example.com/src/jsonrpc.php" `
                                 -sessionId "abc123" `
                                 -apiKey $apiKey

.NOTES
    File Name      : Get-IdoitCMDBStatus.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell 7.0 or higher
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/cmdb.status.html#cmdbstatusread

    Changelog:
    2025-04-16 - Initial version (lgo13)
#>
function Get-IdoitCMDBStatus {
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
        [SecureString]$apiKey
    )

    # Create parameter hashtable for API request
    $params = @{
        "apikey"   = (New-Object PSCredential 0, $apiKey).GetNetworkCredential().Password
        "language" = "en"
    }

    # Query i-doit API for CMDB status values
    try {
        $response = Invoke-Idoit -ApiUrl $apiUrl `
                                -SessionId $sessionId `
                                -Method "cmdb.status.read" `
                                -Params $params `
                                -ErrorAction Stop
    }
    catch {
        throw "Failed to retrieve CMDB status values: $_"
    }

    # Return the status information
    return $response
}