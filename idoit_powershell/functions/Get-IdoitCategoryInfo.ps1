<#
.SYNOPSIS
    Retrieves metadata about i-doit CMDB categories.

.DESCRIPTION
    This function retrieves metadata about specified i-doit categories using the API.
    It provides information about category attributes, field types, and configurations.
    Requires an active API session and proper authentication.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint (e.g., "https://idoit.example.com/src/jsonrpc.php")

.PARAMETER sessionId
    The active session ID for API authentication

.PARAMETER apiKey
    The API key as a SecureString

.PARAMETER category
    The category identifier to retrieve information about (e.g., "C__CATG__GLOBAL")

.OUTPUTS
    Returns a PSObject containing the category metadata including attributes and configurations

.NOTES
    File Name      : Get-IdoitCategoryInfo.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell 7.0 or higher
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/cmdb.category_info.html
    
.EXAMPLE
    $apiKey = ConvertTo-SecureString "your-apikey" -AsPlainText -Force
    Get-IdoitCategoryInfo -apiUrl "https://idoit.example.com/api/jsonrpc.php" `
                         -sessionId "abc123" `
                         -apiKey $apiKey `
                         -category "C__CATG__GLOBAL"
#>

function Get-IdoitCategoryInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$apiUrl,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$sessionId,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [SecureString]$apiKey,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$category
    )

    # Create parameter hashtable for category info request
    $params = @{
        "category" = $category
        "apikey"   = (New-Object PSCredential 0, $apiKey).GetNetworkCredential().Password
        "language" = "en"
    }

    # Query the i-doit API for category information
    try {
        $response = Invoke-Idoit -ApiUrl $apiUrl `
                                -SessionId $sessionId `
                                -Method "cmdb.category_info.read" `
                                -Params $params `
                                -ErrorAction Stop
    }
    catch {
        throw "Failed to retrieve category info: $_"
    }

    # Return the category metadata
    return $response
}