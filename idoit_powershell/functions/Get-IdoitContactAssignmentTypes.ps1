<#
.SYNOPSIS
    Retrieves contact assignment types from i-doit.

.DESCRIPTION
    This function retrieves all available contact assignment types (roles) from
    the i-doit CMDB dialog system. It requires an active API session and returns
    the list of possible contact roles that can be assigned.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint.

.PARAMETER sessionId
    The active session ID for API authentication.

.PARAMETER apiKey
    The API key as a SecureString.

.NOTES
    File Name      : Get-IdoitContactAssignmentTypes.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell, active i-doit API session
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/cmdb.dialog.html#cmdbdialogread
    
.EXAMPLE
    $apiKey = ConvertTo-SecureString "yourApiKey" -AsPlainText -Force
    Get-IdoitContactAssignmentTypes -apiUrl "https://idoit.example.com/api/jsonrpc.php" `
                                   -sessionId "abc123" `
                                   -apiKey $apiKey
#>
function Get-IdoitContactAssignmentTypes {
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

    # Define the parameters for dialog read request
    $params = @{
        "category" = "C__CATG__CONTACT"
        "property" = "role"
        "apikey"   = (New-Object PSCredential 0, $apiKey).GetNetworkCredential().Password
        "language" = "en"
    }

    # Query i-doit API for contact assignment types
    try {
        $response = Invoke-Idoit -ApiUrl $apiUrl `
                                -SessionId $sessionId `
                                -Method "cmdb.dialog.read" `
                                -Params $params `
                                -ErrorAction Stop
    }
    catch {
        throw "Failed to retrieve contact assignment types: $_"
    }

    # Return the list of assignment types
    return $response
}