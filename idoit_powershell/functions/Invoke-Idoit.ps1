<#
.SYNOPSIS
    Sends requests to the i-doit API using JSON-RPC 2.0 protocol.

.DESCRIPTION
    This function sends authenticated requests to the i-doit API using:
    - Session-based authentication via X-RPC-Auth-Session header
    - JSON-RPC 2.0 protocol formatting
    - Dynamic request IDs using GUIDs
    - Configurable API methods and parameters
    - Error handling for both HTTP and API-level errors

.PARAMETER apiUrl
    The URL of the i-doit API endpoint (e.g., "https://idoit.example.com/src/jsonrpc.php")

.PARAMETER sessionId
    The active session ID obtained from Connect-Idoit

.PARAMETER method
    The i-doit API method to call (e.g., "cmdb.objects.read", "cmdb.category.read")

.PARAMETER params
    Hashtable containing the required parameters for the API method

.OUTPUTS
    Returns the result property from the API response. Throws an error if the request fails.

.EXAMPLE
    $params = @{
        "id" = 123
        "apikey" = "your-apikey"
        "language" = "en"
    }
    
    $response = Invoke-Idoit -apiUrl "https://idoit.example.com/api/jsonrpc.php" `
                            -sessionId "abc123" `
                            -method "cmdb.category.read" `
                            -params $params

.NOTES
    File Name      : Invoke-Idoit.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell 7.0 or higher
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/index.html

    Changelog:
    2025-02-07 - Initial version (lgo13)
    2025-04-17 - Added error handling, increased JSON depth, implemented GUID for request ID (lgo13)
#>
function Invoke-Idoit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$apiUrl,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$sessionId,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$method,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [hashtable]$params
    )

    # Create request headers with session authentication
    $headers = @{
        "X-RPC-Auth-Session" = $sessionId
    }

    # Build JSON-RPC 2.0 compliant request body
    $body = @{
        "version" = "2.0"
        "method"  = $method
        "params"  = $params
        "id"      = [Guid]::NewGuid().ToString()
    } | ConvertTo-Json -Depth 10

    # Send request to API and handle any network/HTTP errors
    try {
        $response = Invoke-RestMethod -Uri $apiUrl `
                                    -Method Post `
                                    -ContentType "application/json" `
                                    -Headers $headers `
                                    -Body $body `
                                    -ErrorAction Stop
    }
    catch {
        throw "API request failed: $_"
    }

    # Check for API-level errors in the response
    if ($response.error) {
        throw "API error: $($response.error.message)"
    }

    # Return just the result data from the response
    return $response.result
}