<#
.SYNOPSIS
    Retrieves category information for an i-doit object.

.DESCRIPTION
    This function retrieves category information for a specified i-doit object 
    using the object ID and category name. It requires an active API session
    and returns the category details as a response object.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint.

.PARAMETER sessionId
    The active session ID for API authentication.

.PARAMETER apiKey
    The API key as a SecureString.

.PARAMETER id
    The numeric ID of the i-doit object to query.

.PARAMETER category
    The category name to retrieve. Defaults to "C__CATG__GLOBAL".

.NOTES
    File Name      : Get-IdoitObjectCategory.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell, active i-doit API session
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/index.html#cmdocategoryread
    
.EXAMPLE
    $apiKey = ConvertTo-SecureString "yourApiKey" -AsPlainText -Force
    Get-IdoitObjectCategory -apiUrl "https://idoit.example.com/api/jsonrpc.php" -sessionId "abc123" -apiKey $apiKey -id 540
#>
function Get-IdoitObjectCategory {
    param (
        [Parameter(Mandatory = $true)]
        [String]$apiUrl,
        
        [Parameter(Mandatory = $true)]
        [String]$sessionId,
        
        [Parameter(Mandatory = $true)]
        [SecureString]$apiKey,
        
        [Parameter(Mandatory = $true)]
        [int]$id,
        
        [Parameter(Mandatory = $false)]
        [string]$category = "C__CATG__GLOBAL"
    )

    # Create parameter hashtable for API request
    $params = @{
        "objID"    = $id
        "category" = $category
        "apikey"   = (New-Object PSCredential 0, $apiKey).GetNetworkCredential().Password
        "language" = "en"
    }

    # Send request to i-doit API and handle any errors
    try {
        $response = Invoke-Idoit -ApiUrl $apiUrl `
                                -SessionId $sessionId `
                                -Method "cmdb.category.read" `
                                -Params $params `
                                -ErrorAction Stop
    }
    catch {
        throw $_
    }

    # Return the category information
    return $response
}