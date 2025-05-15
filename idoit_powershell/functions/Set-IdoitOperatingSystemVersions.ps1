<#
.SYNOPSIS
    Retrieves operating system version information from i-doit.

.DESCRIPTION
    This function queries the i-doit CMDB to retrieve version information for a specific
    object. It returns details about the installed operating system version,
    service pack level, and patch status from the version category.

.PARAMETER apiUrl
    The URL of the i-doit API endpoint (e.g., "https://idoit.example.com/src/jsonrpc.php")

.PARAMETER sessionId
    The active session ID for API authentication.

.PARAMETER apiKey
    The API key as a SecureString.

.PARAMETER id
    The numeric ID of the object to query version information for.
    Found in Software -> Operationg System -> *Choose OS* -> Version

.NOTES
    File Name      : Get-IdoitWindowsServerOperatingSystemVersions.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell, active i-doit API session
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/cmdb.category.html#cmdbcategoryread
    
.EXAMPLE
    $apiKey = ConvertTo-SecureString "yourApiKey" -AsPlainText -Force
    Get-IdoitWindowsServerOperatingSystemVersions -apiUrl "https://idoit.example.com/api/jsonrpc.php" `
                                                -sessionId "abc123" `
                                                -apiKey $apiKey `
                                                -id 540
#>
function Set-IdoitOperatingSystemVersions {
    param (
        [Parameter(Mandatory=$true)][String]$apiUrl,
        [Parameter(Mandatory=$true)][String]$sessionId,
        [Parameter(Mandatory=$true)][SecureString]$apiKey,
        [Parameter(Mandatory=$true)][int]$id,
        [Parameter(Mandatory=$true)][string]$version,
        [Parameter(Mandatory=$false)][string]$description,
        [Parameter(Mandatory=$false)][int]$OSid,
        [Parameter(Mandatory=$false)][bool]$extendDescription = $true,
        [Parameter(Mandatory=$false)][string[]]$osVerificationList
    )

    #get os if osVerificationList is empty
    if ($null -eq $osVerificationList) {
        #get exsisiting tags from idoit
        $OSExsisting = Get-IdoitOperatingSystemVersions -apiUrl $apiUrl -sessionId $sessionId -apiKey $apiKey -id $OSid
    } else {
        $OSExsisting = @{"title" = $osVerificationList}       
    }

    #check if the version is valid
    if ($OSExsisting.title -notcontains $version) {
        Write-LogAndConsole -Level ERROR -Logfile $scriptLogFile -Value "Version '$version' does not exist in i-doit. Check if your input is correct."
        throw "Version '$version' does not exist in i-doit. Check if your input is correct."
        exit
    }

    #build description
    if ($extendDescription -eq $true) {

        #get current description
        $descriptionCurrent = (Get-IdoitObjectCategory -apiUrl $apiUrl -sessionId $sessionId -apiKey $apiKey `
            -id $id `
            -category "C__CATG__OPERATING_SYSTEM").description

        #build new description, add extended description to new line 
        $description = $descriptionCurrent + "<p>" + $description + "</p>"
    }

    #define the data for change
    $data = @{
        "assigned_version" = $version
    }

    #add description to data if provided
    if ($null -ne $description) {
        $data.description = $description
        if ($OSInfo.description -ne "" -and $extendDescription -eq $false) {
            Write-LogAndConsole -Level "INFO" -Logfile $scriptLogFile -Value "The following description will be replaced: '$($OSInfo.description)'"
        }
    }

    #define the parameters
    $params = @{
        "object" = $id
        "category" = "C__CATG__OPERATING_SYSTEM"
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