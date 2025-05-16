<#
    .SYNOPSIS
    Remove a contact assignment from an object in the i-doit API.

    .DESCRIPTION
    This function removes a contact assignment from an object in the i-doit API. It retrieves the specific contact assignment and sends a request to archive it, effectively removing the assignment.

    Source:
    https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/cmdb.category.html#cmdbcategoryarchive

    .PARAMETER apiUrl
    The URL of the i-doit API endpoint.

    .PARAMETER sessionId
    The session ID for authentication.

    .PARAMETER apiKey
    The API key for authentication (as a SecureString).

    .PARAMETER id
    The ID of the object to update.

    .PARAMETER contactId
    The ID of the contact to remove from the object.

    .EXAMPLE
    $apiUrl = "https://your-idoit-instance.com/src/jsonrpc.php"
    $sessionId = "your-session-id"
    $apiKey = ConvertTo-SecureString "your-apikey" -AsPlainText -Force
    $id = 123
    $contactId = 456
    $response = Remove-IdoitObjectContactAssignment -apiUrl $apiUrl -sessionId $sessionId -apiKey $apiKey -id $id -contactId $contactId

    .NOTES
    changelog
    20250424 - First version (lgo13)
#>
function Remove-IdoitObjectContactAssignment {
    param (
        [Parameter(Mandatory=$true)][String]$apiUrl,
        [Parameter(Mandatory=$true)][String]$sessionId,
        [Parameter(Mandatory=$true)][SecureString]$apiKey,
        [Parameter(Mandatory=$true)][int]$id,
        [Parameter(Mandatory=$true)][string]$contactId

    )

    #check if there are currente contact assignments
    try {
        $contacts = Get-IdoitObjectContactAssgiment -apiUrl $apiUrl -sessionId $sessionId -apiKey $apiKey -id $id
    }
    catch {
        throw "Cant read contact assignments. The following error occurred: $_"
    }

    #get specific contact assignment
    $contactAssignment = $contacts | Where-Object { $_.contact_object.id -eq $contactId } 

    #define the parameters
    $params = @{
        "object" = $id
        "category" = "C__CATG__CONTACT"
        "entry" = $contactAssignment.id
        "apikey" = (New-Object PSCredential 0, $apiKey).GetNetworkCredential().Password
        "language" = "en"
    }

    #send the request
    try {
        $response = Invoke-Idoit -ApiUrl $apiUrl -SessionId $sessionId -Method "cmdb.category.archive" -Params $params -ErrorAction Stop
    }
    catch {
        throw $_
    }

    # return the response
    return $response
}