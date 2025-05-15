<#
.SYNOPSIS
    Retrieves stored credentials for i-doit API access.

.DESCRIPTION
    This function retrieves the stored credentials and API key for i-doit API access
    from encrypted files in the specified credentials directory. It returns a hashtable
    containing the username, password (SecureString), and API key (SecureString).

.PARAMETER CredsPath
    The path to the directory containing the credential files.

.NOTES
    File Name      : Get-IdoitCredentials.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell
    
.EXAMPLE
    $credentials = Get-IdoitCredentials -CredsPath "C:\Path\To\Creds\"
    Returns a hashtable with the stored credentials and API key.
#>
function Get-IdoitCredentials {
    param (
        [Parameter(Mandatory = $true)]
        [string]$CredsPath
    )

    # Define paths for credential and API key files
    $credFile  = "$($CredsPath)Credentials_idoit_credentials_${env:USERNAME}.xml"
    $tokenFile = "$($CredsPath)Credentials_idoit_apikey_${env:USERNAME}.txt"

    # Verify that both credential files exist
    if (!(Test-Path $credFile) -or !(Test-Path $tokenFile)) {
        throw "No credentials found for i-doit. Please run the script 'New-idoitCredentialFile.ps1' first."
    }
    
    # Import stored credentials from XML file
    try {
        $credentialIdoit = Import-CliXml -Path $credFile -ErrorAction Stop
    }
    catch {
        throw "Cannot get credentials for i-doit. Error: $_"
    }

    # Import and convert stored API key
    try {
        [SecureString]$apikeyIdoit = Get-Content -Path $tokenFile -ErrorAction Stop | 
                                    ConvertTo-SecureString -ErrorAction Stop        
    }
    catch {
        throw "Cannot get API key for i-doit. Error: $_"
    }

    # Return hashtable containing credentials and API key
    return @{
        Username = [String]$credentialIdoit.UserName
        Password = [SecureString]$credentialIdoit.Password
        ApiKey   = [SecureString]$apikeyIdoit
    }
}