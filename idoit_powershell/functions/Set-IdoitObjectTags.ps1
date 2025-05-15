<#
.SYNOPSIS
    Updates or removes tags for an i-doit object.

.DESCRIPTION
    This function manages tags for objects in the i-doit CMDB. It can:
    - Add new tags to existing ones
    - Replace all tags with new ones
    - Remove all tags
    - Validate tags against existing ones
    - Handle tag deduplication
    - Prevent accidental creation of new tags

.PARAMETER apiUrl
    The URL of the i-doit API endpoint (e.g., "https://idoit.example.com/src/jsonrpc.php")

.PARAMETER sessionId
    The active session ID for API authentication.

.PARAMETER apiKey
    The API key as a SecureString.

.PARAMETER id
    The numeric ID of the i-doit object to update tags for.

.PARAMETER tags
    Array of tag strings to set. Can be empty to remove all tags.

.PARAMETER extendTags
    Optional. When true, adds new tags to existing ones. When false, replaces all tags. Defaults to $true.

.PARAMETER tagVerificationList
    Optional. Array of allowed tags to validate against. If not provided, validates against existing i-doit tags.

.NOTES
    File Name      : Set-IdoitObjectTags.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell, active i-doit API session
    Source         : https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/v1/cmdb.category.html#cmdbcategorysave
    
.EXAMPLE
    $apiKey = ConvertTo-SecureString "yourApiKey" -AsPlainText -Force
    Set-IdoitObjectTags -apiUrl "https://idoit.example.com/api/jsonrpc.php" `
                       -sessionId "abc123" `
                       -apiKey $apiKey `
                       -id 540 `
                       -tags @("Production", "WebServer") `
                       -extendTags $true
#>
function Set-IdoitObjectTags {
    param (
        [Parameter(Mandatory=$true)][String]$apiUrl,
        [Parameter(Mandatory=$true)][String]$sessionId,
        [Parameter(Mandatory=$true)][SecureString]$apiKey,
        [Parameter(Mandatory=$true)][int]$id,
        [Parameter(Mandatory=$true)][AllowEmptyString()][string[]]$tags,
        [Parameter(Mandatory=$false)][bool]$extendTags = $true,
        [Parameter(Mandatory=$false)][string[]]$tagVerificationList
    )

    #if tags are empty, throw an error
    if ([string]::IsNullOrEmpty($tags)) {
        try {
            #get current tags
            $tagsCurrent = Get-IdoitObjectCategory -apiUrl $apiUrl -sessionId $sessionId -apiKey $apiKey `
            -id $id `
            -category "C__CATG__GLOBAL" -ErrorAction Stop | Select-Object -ExpandProperty tag
        } catch {
                throw "Error in function 'Set-IdoitObjectTags' occurred when getting currently assigend tags for write to log wiche tags are before wipeing with error: $($_)"
        }

        if ($tagsCurrent.Count -eq 0) {
            Write-Warning "No tags to wipe."
        }else {
            #genater string for output
            $outputTags =  $tagsCurrent.title -join '", "'
            $outputTags = '"' + $outputTags + '"'
            Write-Host "The following tags are wiped: $($outputTags)"
        }
    }else {
        
        #get tags if tagVerificationList is empty
        if ($null -eq $tagVerificationList) {
            #get exsisiting tags from idoit
            $tagsExsisting = Get-IdoitTags @standardIdoitParams
        } else {
            $tagsExsisting = @{"title" = $tagVerificationList}       
        }
        
        #check tags and only keep those that exist in idoit to avoid accidental creation of new tags
        foreach($tag in $tags) {
            #check if tag exists in idoit if not remove it from the list
            if ($tagsExsisting.title -notcontains $tag) {
                Write-Warning "Tag '$tag' does not exist in i-doit. Removing from list."
                $tags = $tags | Where-Object { $_ -ne $tag }
            }
        }

        #check if tags are empty
        if ($tags.Count -eq 0) {
            throw "No valid tags provided. Exiting function 'Set-IdoitObjectTags'."
        }

        #if extendTags is true, add the existing tags to the new list
        if ($extendTags -eq $true) {
            try {
                        #get current tags
            $tagsCurrent = Get-IdoitObjectCategory -apiUrl $apiUrl -sessionId $sessionId -apiKey $apiKey `
            -id $id `
            -category "C__CATG__GLOBAL" -ErrorAction Stop | Select-Object -ExpandProperty tag
            }
            catch {
                throw "Error in function 'Set-IdoitObjectTags' occurred when getting currently assigend tags for combination with error: $($_)"
            }

            #add the current tags to the new list if there are any
            if ($tagsCurrent.Count -eq 0) {
                $tags = $tags | Select-Object -Unique #remove duplicates do avoid error "i-doit system error: Duplicate entry '4239253-78' for key 'PRIMARY'"

                    $outputTags =  $tags -join '", "'
                        $outputTags = '"' + $outputTags + '"'
                        Write-Host "New tags will be added: $outputTags"
            }else {
                if ($null -eq ($tags | Sort-Object | Compare-Object -ReferenceObject ($tagsCurrent.title | Sort-Object))) {
                        Write-Warning "No new tags provided. Exiting function 'Set-IdoitObjectTags'."
                        exit
                    }else {
                        $outputTags =  $tagsCurrent.title -join '", "'
                        $outputTags = '"' + $outputTags + '"'
                        Write-Host "New tags will be added to the existing tags: $outputTags"

                        $tags = $tags + $tagsCurrent.title
                        $tags = $tags | Select-Object -Unique #remove duplicates do avoid error "i-doit system error: Duplicate entry '4239253-78' for key 'PRIMARY'"
                    }
            }
            
        }
    } 

    #define the data for change
    $data = @{
        "tag" = $tags
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