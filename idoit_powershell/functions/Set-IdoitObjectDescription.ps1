<#
.SYNOPSIS
    Updates the description of an i-doit object.

.DESCRIPTION
    This function updates or extends the description of a specified object in the i-doit CMDB.
    It can either replace the existing description or append new content to it in HTML format.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint (e.g., "https://idoit.example.com/src/jsonrpc.php")

.PARAMETER sessionId
    The active session ID for API authentication.

.PARAMETER apiKey
    The API key as a SecureString.

.PARAMETER id
    The numeric ID of the i-doit object to update.

.PARAMETER description
    The description text to set or append. Supports HTML formatting.

.PARAMETER extendDescription
    Optional. When true, appends the new description to the existing one.
    When false, replaces the current description. Defaults to $true.

.NOTES
    File Name      : Set-IdoitObjectDescription.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell, active i-doit API session
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/cmdb.category.html#cmdbcategorysave
    
.EXAMPLE
    $apiKey = ConvertTo-SecureString "yourApiKey" -AsPlainText -Force
    Set-IdoitObjectDescription -apiUrl "https://idoit.example.com/api/jsonrpc.php" `
                              -sessionId "abc123" `
                              -apiKey $apiKey `
                              -id 540 `
                              -description "New server for testing" `
                              -extendDescription $true
#>
function Set-IdoitObjectDescription {
    param (
        [Parameter(Mandatory=$true)][String]$apiUrl,
        [Parameter(Mandatory=$true)][String]$sessionId,
        [Parameter(Mandatory=$true)][SecureString]$apiKey,
        [Parameter(Mandatory=$true)][int]$id,
        [Parameter(Mandatory=$true)][string]$description,
        [Parameter(Mandatory=$false)][bool]$extendDescription = $true
    )

    #build description
    if ($extendDescription -eq $true) {

        #get current description
        $descriptionCurrent = (Get-IdoitObjectCategory -apiUrl $apiUrl -sessionId $sessionId -apiKey $apiKey `
            -id $id `
            -category "C__CATG__GLOBAL").description

        #build new description, add extended description to new line 
        $description = $descriptionCurrent + "<p>" + $description + "</p>"
    }

    #define the data for change
    $data = @{
        "description" = $description
    }

    #define the parameters
    $params = @{
        "object" = $id
        "category" = "C__CATG__GLOBAL"
        "data" = $data
        "apikey" = (New-Object PSCredential 0, $apiKey).GetNetworkCredential().Password
        "language" = "en"
    }

    #send the request
    try {
        $response = Invoke-Idoit -ApiUrl $apiUrl -SessionId $sessionId -Method "cmdb.category.save" -Params $params -ErrorAction Stop
    }
    catch {
        throw $_
    }

    # return the response
    return $response
}