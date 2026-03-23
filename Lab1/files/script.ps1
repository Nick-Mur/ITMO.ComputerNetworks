param(
    [Parameter(Position=0)]
    [ValidateSet('DHCP','Static','Info')]
    [string]$Mode,

    [Parameter(Position=1)]
    [string]$Interface,

    [Parameter(Position=2)]
    [string]$Address,

    [Parameter(Position=3)]
    [int]$Mask,

    [Parameter(Position=4)]
    [string]$Gateway,

    [Parameter(Position=5)]
    [string]$DNS,

    [switch]$Help,
    [switch]$List
)

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$ErrorActionPreference = "Stop"

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Show-Menu {
    Write-Host "=== Network Configurator ==="
    Write-Host "1. Configure DHCP"
    Write-Host "2. Configure Static IP"
    Write-Host "3. Show Interface Info"
    Write-Host "4. List Interfaces"
    Write-Host "5. Help"
    Write-Host "6. Exit"
}

function Show-Help {
    Write-Host "Usage:"
    Write-Host "  DHCP config:     .\script7.ps1 -Mode DHCP -Interface 'Ethernet'"
    Write-Host "  Static IP:       .\script7.ps1 -Mode Static -Interface 'Ethernet' -Address 192.168.1.100 -Mask 24 -Gateway 192.168.1.1 -DNS 8.8.8.8"
    Write-Host "  Interface info:  .\script7.ps1 -Mode Info -Interface 'Ethernet'"
    Write-Host "  List interfaces: .\script7.ps1 -List"
    Write-Host "  Help:            .\script7.ps1 -Help"
}

function Show-InterfaceConfig {
    param([string]$Name)

    Write-Host ""
    Write-Host "Current configuration:" -ForegroundColor Cyan
    Get-NetIPConfiguration -InterfaceAlias $Name | Format-List
}

function Get-DuplexMode {
    param([string]$Name)

    try {
        $duplexProp = Get-NetAdapterAdvancedProperty -Name $Name -ErrorAction Stop |
            Where-Object {
                $_.DisplayName -match 'duplex' -or $_.RegistryKeyword -match 'duplex'
            } |
            Select-Object -First 1

        if ($duplexProp) {
            return $duplexProp.DisplayValue
        }
        else {
            return "Unknown"
        }
    }
    catch {
        return "Unknown"
    }
}

if (-not (Test-Admin)) {
    Write-Host "Error: run script as Administrator." -ForegroundColor Red
    exit 1
}

if ($List) {
    Get-NetAdapter | Format-Table Name, InterfaceDescription, Status, LinkSpeed, MacAddress -AutoSize
    exit
}

if ($Help) {
    Show-Help
    exit
}

if (-not $Mode) {
    Show-Menu
    $choice = Read-Host "Select action"

    switch ($choice) {
        '1' { $Mode = 'DHCP' }
        '2' { $Mode = 'Static' }
        '3' { $Mode = 'Info' }
        '4' {
            Get-NetAdapter | Format-Table Name, InterfaceDescription, Status, LinkSpeed, MacAddress -AutoSize
            exit
        }
        '5' {
            Show-Help
            exit
        }
        '6' { exit }
        default {
            Write-Host "Invalid choice." -ForegroundColor Red
            exit
        }
    }
}

if (-not $Interface) {
    $Interface = Read-Host "Enter interface name"
}

try {
    $Adapter = Get-NetAdapter -Name $Interface -ErrorAction Stop
}
catch {
    Write-Host "Error: Interface '$Interface' not found." -ForegroundColor Red
    exit 1
}

switch ($Mode.ToUpper()) {
    'DHCP' {
        Set-NetIPInterface -InterfaceAlias $Interface -Dhcp Enabled -AddressFamily IPv4
        Set-DnsClientServerAddress -InterfaceAlias $Interface -ResetServerAddresses
        ipconfig /renew | Out-Null

        Write-Host "DHCP configuration applied." -ForegroundColor Green
        Show-InterfaceConfig -Name $Interface
    }

    'STATIC' {
        if (-not $Address) { $Address = Read-Host "Enter IP address" }
        if (-not $Mask) { $Mask = [int](Read-Host "Enter prefix length (e.g. 24)") }
        if (-not $Gateway) { $Gateway = Read-Host "Enter gateway" }
        if (-not $DNS) { $DNS = Read-Host "Enter DNS server" }

        $oldIPs = Get-NetIPAddress -InterfaceAlias $Interface -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Where-Object { $_.PrefixOrigin -ne "WellKnown" }

        foreach ($ip in $oldIPs) {
            Remove-NetIPAddress -InputObject $ip -Confirm:$false -ErrorAction SilentlyContinue
        }

        $oldRoutes = Get-NetRoute -InterfaceAlias $Interface -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Where-Object { $_.DestinationPrefix -eq "0.0.0.0/0" }

        foreach ($route in $oldRoutes) {
            Remove-NetRoute -InputObject $route -Confirm:$false -ErrorAction SilentlyContinue
        }

        New-NetIPAddress -InterfaceAlias $Interface -IPAddress $Address -PrefixLength $Mask -DefaultGateway $Gateway | Out-Null
        Set-DnsClientServerAddress -InterfaceAlias $Interface -ServerAddresses $DNS

        Write-Host "Static configuration applied." -ForegroundColor Green
        Show-InterfaceConfig -Name $Interface
    }

    'INFO' {
        $AdapterInfo = Get-NetAdapter -Name $Interface
        $duplex = Get-DuplexMode -Name $Interface

        Write-Host "Adapter information"
        Write-Host "Interface Name      = $($AdapterInfo.Name)"
        Write-Host "MAC Address         = $($AdapterInfo.MacAddress)"
        Write-Host "Adapter Model       = $($AdapterInfo.InterfaceDescription)"
        Write-Host "Status              = $($AdapterInfo.Status)"
        Write-Host "Physical Link       = $($AdapterInfo.Status)"
        Write-Host "Speed               = $($AdapterInfo.LinkSpeed)"
        Write-Host "Duplex Mode         = $duplex"
    }
}