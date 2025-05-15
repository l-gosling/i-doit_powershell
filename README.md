# i-doit_powershell
## Table of Contents
- [i-doit\_powershell](#i-doit_powershell)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
    - [Key Features](#key-features)
    - [Prerequisites](#prerequisites)
  - [Quick Start](#quick-start)
  - [Testing](#testing)
  - [Documentation](#documentation)
  - [Disclaimer and License](#disclaimer-and-license)


## Introduction
PowerShell module for interacting with the i-doit CMDB API. This module provides cmdlets for managing and retrieving information from your i-doit configuration management database.
The i-doit PowerShell module provides a simple and secure way to interact with the i-doit API using PowerShell. It handles authentication, session management, and common CMDB operations.

### Key Features

- Session-based authentication
- PowerShell-native parameter handling
- Support for i-doit API version 2.0

### Prerequisites

- PowerShell 7.0 or higher
- i-doit installation with API access
- API key and valid credentials

## Quick Start

1. Clone this repository
2. Run the credential setup script:
```powershell
foreach ($PSScriptFile in (Get-ChildItem -Path .\idoit_powershell\functions\)) {
    . $PSScriptFile.FullName
}
```
3. Import the module and connect to your i-doit instance:
```powershell
Import-Module .\idoit_powershell
$creds = Get-IdoitCredentials -CredsPath ".\idoit_powershell\creds"
$session = Connect-Idoit -ApiUrl "https://your-idoit.com/api/jsonrpc.php" -Username $creds.Username -Password $creds.Password -ApiKey $creds.ApiKey
```

## Testing

To perform API tests, the test scripts connect to the `i-doit Demo system <https://demo.i-doit.com>`_. 
It can be retrieved from the i-doit demo system by logging in, opening the user menu by hovering over the user name, choosing 'Administration', and clicking on 'Interfaces / External data`, 'JSON-RPC API', and 'Common Settings'.

## Documentation

For detailed documentation about the i-doit API, please visit:
[i-doit API Documentation](https://kb.i-doit.com/de/i-doit-add-ons/api/methoden/index.html)

## Disclaimer and License
This tool is provided as-is, with no warranties.
Code or documentation contributions, issue reports and feature requests are always welcome! 
Please use GitHub issue to review existing or create new issues.
The EntraOps project is MIT licensed.
