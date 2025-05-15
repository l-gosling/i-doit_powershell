<#
.SYNOPSIS
    Establishes a connection to the i-doit API and returns a session ID.

.DESCRIPTION
    This function authenticates with the i-doit API using provided credentials 
    and API key. It performs a login request and returns the session ID for 
    subsequent API calls.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint.

.PARAMETER username
    The username for authentication.

.PARAMETER password
    The password as a SecureString.

.PARAMETER apiKey
    The API key as a SecureString.

.NOTES
    File Name      : Connect-Idoit.ps1
    Author         : l-gosling
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/index.html#idoitlogin
    
.EXAMPLE
    $password = ConvertTo-SecureString "yourPassword" -AsPlainText -Force
    $apiKey = ConvertTo-SecureString "yourApiKey" -AsPlainText -Force
    Connect-Idoit -apiUrl "https://idoit.example.com/api/jsonrpc.php" -username "admin" -password $password -apiKey $apiKey
#>

function Connect-Idoit {
    param (
        [Parameter(Mandatory = $true)]
        [String]$apiUrl,
        
        [Parameter(Mandatory = $true)]
        [String]$username,
        
        [Parameter(Mandatory = $true)]
        [SecureString]$password,
        
        [Parameter(Mandatory = $true)]
        [SecureString]$apiKey
    )

    # Create the request headers with authentication credentials
    $headers = @{
        "X-RPC-Auth-Username" = $username
        "X-RPC-Auth-Password" = (New-Object PSCredential 0, $password).GetNetworkCredential().Password
    }

    # Create the JSON-RPC request body
    $body = @{
        "version" = "2.0"
        "method"  = "idoit.login"
        "params"  = @{
            "apikey"   = (New-Object PSCredential 0, $apiKey).GetNetworkCredential().Password
            "language" = "en"
        }
        "id"      = 1
    } | ConvertTo-Json

    # Send the login request to the API
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -ContentType "application/json" `
            -Headers $headers -Body $body -ErrorAction Stop
    }
    catch {
        throw $_
    }

    # Check for API-level errors in the response
    if ($response.error) {
        throw $response.error.message
    }

    # Return the session ID for subsequent API calls
    return $response.result
}