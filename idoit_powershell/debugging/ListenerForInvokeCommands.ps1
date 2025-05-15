<#
.SYNOPSIS
    Creates a TCP listener for testing i-doit API commands.

.DESCRIPTION
    This script sets up a TCP listener on localhost port 8080 to capture and display
    incoming connections. It's useful for debugging and testing i-doit API requests
    by showing the raw data being sent.
    Start this script in another PowerShell window.

.PARAMETER None
    This script does not accept any parameters.

.NOTES
    File Name      : ListenerForInvokeCommands.ps1
    Author         : l-gosling
    Prerequisite   : PowerShell
    Port           : 8080
    
.EXAMPLE
    .\ListenerForInvokeCommands.ps1
    # Starts listening on http://localhost:8080 and displays incoming connections
#>

Clear-Host
Write-Host "Waiting for connections to 'http://localhost:8080'" -ForegroundColor Green

# Set up endpoint and start listening
$endpoint = New-Object System.Net.IPEndPoint([IPAddress]::Any, 8080)
$listener = New-Object System.Net.Sockets.TcpListener $endpoint
$listener.Start()

# Wait for an incoming connection
$data = $listener.AcceptTcpClient()

# Stream setup
$stream = $data.GetStream()
$bytes = New-Object System.Byte[] 1024

# Read data from stream and write it to host
while (($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0) {
    $EncodedText = New-Object System.Text.ASCIIEncoding
    $data = $EncodedText.GetString($bytes, 0, $i)
    Write-Output $data
}

# Close TCP connection and stop listening
$stream.Close()
$listener.Stop()
