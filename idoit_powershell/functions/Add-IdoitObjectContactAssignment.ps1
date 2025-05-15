<#
.SYNOPSIS
    Adds a new contact assignment to an i-doit object.

.DESCRIPTION
    This function adds a new contact assignment (role) to a specified object
    in the i-doit CMDB. It validates that the contact isn't already assigned
    and that the specified contact type exists before creating the assignment.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint (e.g., "https://idoit.example.com/src/jsonrpc.php")

.PARAMETER sessionId
    The active session ID for API authentication.

.PARAMETER apiKey
    The API key as a SecureString.

.PARAMETER id
    The numeric ID of the i-doit object to add the contact to.

.PARAMETER contactId
    The ID of the contact to be assigned.

.PARAMETER primary
    Optional. Set to 1 to make this the primary contact (default: 0).

.PARAMETER contactType
    Optional. The role/type of the contact assignment (default: "Contact Partner").

.PARAMETER contactAssignmentTypesList
    Optional. List of predefined contact assignment types to validate against.

.NOTES
    File Name      : Add-IdoitObjectContactAssignment.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell, active i-doit API session
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/cmdb.category.html#cmdbcategorysave

.EXAMPLE
    $apiKey = ConvertTo-SecureString "yourApiKey" -AsPlainText -Force
    Add-IdoitObjectContactAssignment -apiUrl "https://idoit.example.com/api/jsonrpc.php" `
                                   -sessionId "abc123" `
                                   -apiKey $apiKey `
                                   -id 540 `
                                   -contactId 123 `
                                   -primary 1 `
                                   -contactType "Administrator"
#>
function Add-IdoitObjectContactAssignment {
    param (
        [Parameter(Mandatory=$true)][String]$apiUrl,
        [Parameter(Mandatory=$true)][String]$sessionId,
        [Parameter(Mandatory=$true)][SecureString]$apiKey,
        [Parameter(Mandatory=$true)][int]$id,
        [Parameter(Mandatory=$true)][string]$contactId,
        [Parameter(Mandatory=$false)][ValidateSet(0,1)][int]$primary = 0,
        [Parameter(Mandatory=$false)][string]$contactType = "Contact Partner",
        [Parameter(Mandatory=$false)][string[]]$contactAssigmentTypesList
    )

    #check if there are currente contact assigments
    try {
        $contacts = Get-IdoitObjectContactAssgiment -apiUrl $apiUrl -sessionId $sessionId -apiKey $apiKey -id $id
    }
    catch {
        throw "Cant read contact assigments. The following error occurred: $_"
    }

    #check if the contact is already assigned
    $duplicate = $contacts | Where-Object { $_.contact_object.id -eq $contactId }
    if ($duplicate) {
        throw "The contact with ID '$($contactId)' and the name '$($duplicate.contact_object.title)' is already assigned to the object with ID '$($id)'."
    }

    #get contactAssigmentTypes if contactAssigmentTypesExsisting is empty
    if ($null -eq $contactAssigmentTypesList) {
        $contactAssigmentTypesExsisting = Get-IdoitContactAssigmentTypes -apiUrl $apiUrl -sessionId $sessionId -apiKey $apiKey
    } else {
        $contactAssigmentTypesExsisting = @{"title" = $contactAssigmentTypesList}       
    }
    
    #check if tag exists in idoit if not remove it from the list
    if ($contactAssigmentTypesExsisting.title -notcontains $contactType) {
       throw "Contact assigment type '$contactType' does not exist in i-doit. Removing from list."
    }

    #define the data for change
    $data = @{
        "contact" = $contactId
        "primary" = $primary
        "role" = $contactType
    }   

    #define the parameters
    $params = @{
        "object" = $id
        "category" = "C__CATG__CONTACT"
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