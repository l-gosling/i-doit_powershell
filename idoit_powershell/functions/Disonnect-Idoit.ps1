<#
.SYNOPSIS
    Disconnects from an active i-doit API session.

.DESCRIPTION
    This function terminates an active i-doit API session using the provided
    session ID and API key. It performs a logout request and returns the 
    logout response message.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint.

.PARAMETER sessionId
    The active session ID to terminate.

.PARAMETER apiKey
    The API key as a SecureString.

.NOTES
    File Name      : Disconnect-Idoit.ps1
    Author         : l-gosling
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/index.html#idoitlogout
    
.EXAMPLE
    $apiKey = ConvertTo-SecureString "yourApiKey" -AsPlainText -Force
    Disconnect-Idoit -apiUrl "https://idoit.example.com/api/jsonrpc.php" -sessionId "abc123" -apiKey $apiKey
#>
function Disconnect-Idoit {
    param (
        [Parameter(Mandatory = $true)]
        [String]$apiUrl,
        
        [Parameter(Mandatory = $true)]
        [String]$sessionId,
        
        [Parameter(Mandatory = $true)]
        [SecureString]$apiKey
    )

    # Create parameter hashtable for logout request
    $params = @{
        "apikey"   = (New-Object PSCredential 0, $apiKey).GetNetworkCredential().Password
        "language" = "en"
    }

    # Attempt to send logout request to the API
    try {
        $response = Invoke-Idoit -ApiUrl $apiUrl `
                                -SessionId $sessionId `
                                -Method "idoit.logout" `
                                -Params $params `
                                -ErrorAction Stop
    }
    catch {
        throw $_
    }

    # Return the logout response message
    return $response.message
}