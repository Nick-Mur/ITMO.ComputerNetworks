# .\script.ps1 -Mode DHCP -Interface "Ethernet"
# .\script.ps1 -Mode Static -Interface "Ethernet" -Address 192.168.1.100 -Mask 24 -Gateway 192.168.1.1 -DNS 8.8.8.8

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

# Включаем UTF-8, чтобы русский текст отображался корректно
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

# Любую ошибку считаем критической и останавливаем выполнение
$ErrorActionPreference = "Stop"

function Test-Admin {
    # Получаем текущую учетную запись Windows
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()

    # Создаем объект для проверки ролей пользователя
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)

    # Возвращаем True, если скрипт запущен от имени администратора
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Show-Menu {
    # Показываем главное меню скрипта
    Write-Host "=== Network Configurator ==="
    Write-Host "1. Configure DHCP"
    Write-Host "2. Configure Static IP"
    Write-Host "3. Show Interface Info"
    Write-Host "4. List Interfaces"
    Write-Host "5. Help"
    Write-Host "6. Exit"
}

function Show-Help {
    # Показываем примеры запуска скрипта
    Write-Host "Usage:"
    Write-Host "  DHCP config:     .\script7.ps1 -Mode DHCP -Interface 'Ethernet'"
    Write-Host "  Static IP:       .\script7.ps1 -Mode Static -Interface 'Ethernet' -Address 192.168.1.100 -Mask 24 -Gateway 192.168.1.1 -DNS 8.8.8.8"
    Write-Host "  Interface info:  .\script7.ps1 -Mode Info -Interface 'Ethernet'"
    Write-Host "  List interfaces: .\script7.ps1 -List"
    Write-Host "  Help:            .\script7.ps1 -Help"
}

function Show-InterfaceConfig {
    param([string]$Name)

    # Печатаем заголовок
    Write-Host ""
    Write-Host "Current configuration:" -ForegroundColor Cyan

    # Показываем текущую IP-конфигурацию выбранного интерфейса
    Get-NetIPConfiguration -InterfaceAlias $Name | Format-List
}

function Get-DuplexMode {
    param([string]$Name)

    try {
        # Ищем среди расширенных свойств адаптера параметр, связанный с duplex
        $duplexProp = Get-NetAdapterAdvancedProperty -Name $Name -ErrorAction Stop |
            Where-Object {
                $_.DisplayName -match 'duplex' -or $_.RegistryKeyword -match 'duplex'
            } |
            Select-Object -First 1

        # Если свойство найдено — возвращаем его значение
        if ($duplexProp) {
            return $duplexProp.DisplayValue
        }
        else {
            return "Unknown"
        }
    }
    catch {
        # Если определить duplex не удалось — возвращаем Unknown
        return "Unknown"
    }
}

# Проверяем запуск от администратора
if (-not (Test-Admin)) {
    Write-Host "Error: run script as Administrator." -ForegroundColor Red
    exit 1
}

# Если указан ключ -List, выводим список сетевых интерфейсов и выходим
if ($List) {
    Get-NetAdapter | Format-Table Name, InterfaceDescription, Status, LinkSpeed, MacAddress -AutoSize
    exit
}

# Если указан ключ -Help, выводим справку и выходим
if ($Help) {
    Show-Help
    exit
}

# Если режим не передан параметром, показываем меню
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

# Если имя интерфейса не передано, просим ввести его вручную
if (-not $Interface) {
    $Interface = Read-Host "Enter interface name"
}

try {
    # Проверяем, существует ли интерфейс с таким именем
    $Adapter = Get-NetAdapter -Name $Interface -ErrorAction Stop
}
catch {
    Write-Host "Error: Interface '$Interface' not found." -ForegroundColor Red
    exit 1
}

# Выбираем нужный режим работы скрипта
switch ($Mode.ToUpper()) {
    'DHCP' {
        # Включаем автоматическое получение IPv4-параметров по DHCP
        Set-NetIPInterface -InterfaceAlias $Interface -Dhcp Enabled -AddressFamily IPv4

        # Сбрасываем DNS на автоматическое получение
        Set-DnsClientServerAddress -InterfaceAlias $Interface -ResetServerAddresses

        # Обновляем сетевую конфигурацию
        ipconfig /renew | Out-Null

        # Сообщаем об успешном применении настроек
        Write-Host "DHCP configuration applied." -ForegroundColor Green

        # Показываем итоговую конфигурацию
        Show-InterfaceConfig -Name $Interface
    }

    'STATIC' {
        # Если IP-адрес не передан, запрашиваем его у пользователя
        if (-not $Address) { $Address = Read-Host "Enter IP address" }

        # Если маска не передана, запрашиваем длину префикса (например 24)
        if (-not $Mask) { $Mask = [int](Read-Host "Enter prefix length (e.g. 24)") }

        # Если шлюз не передан, запрашиваем его
        if (-not $Gateway) { $Gateway = Read-Host "Enter gateway" }

        # Если DNS не передан, запрашиваем его
        if (-not $DNS) { $DNS = Read-Host "Enter DNS server" }

        # Получаем старые IPv4-адреса интерфейса
        $oldIPs = Get-NetIPAddress -InterfaceAlias $Interface -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Where-Object { $_.PrefixOrigin -ne "WellKnown" }

        # Удаляем старые IP-адреса, чтобы не было конфликтов
        foreach ($ip in $oldIPs) {
            Remove-NetIPAddress -InputObject $ip -Confirm:$false -ErrorAction SilentlyContinue
        }

        # Получаем старые маршруты по умолчанию (старые шлюзы)
        $oldRoutes = Get-NetRoute -InterfaceAlias $Interface -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Where-Object { $_.DestinationPrefix -eq "0.0.0.0/0" }

        # Удаляем старые маршруты по умолчанию
        foreach ($route in $oldRoutes) {
            Remove-NetRoute -InputObject $route -Confirm:$false -ErrorAction SilentlyContinue
        }

        # Создаем новый IPv4-адрес, маску и шлюз
        New-NetIPAddress -InterfaceAlias $Interface -IPAddress $Address -PrefixLength $Mask -DefaultGateway $Gateway | Out-Null
Ethernet
        # Устанавливаем DNS-сервер
        Set-DnsClientServerAddress -InterfaceAlias $Interface -ServerAddresses $DNS

        # Сообщаем об успешном применении настроек
        Write-Host "Static configuration applied." -ForegroundColor Green

        # Показываем итоговую конфигурацию
        Show-InterfaceConfig -Name $Interface
    }

    'INFO' {
        # Получаем основную информацию об адаптере
        $AdapterInfo = Get-NetAdapter -Name $Interface

        # Определяем режим duplex
        $duplex = Get-DuplexMode -Name $Interface

        # Определяем наличие физического подключения
        if ($AdapterInfo.Status -eq 'Up') {
            $link = 'Connected'
        } else {
            $link = 'Disconnected'
        }

        # Выводим сведения об адаптере
        Write-Host "Adapter information"
        Write-Host "Interface Name      = $($AdapterInfo.Name)"
        Write-Host "MAC Address         = $($AdapterInfo.MacAddress)"
        Write-Host "Adapter Model       = $($AdapterInfo.InterfaceDescription)"
        Write-Host "Physical Link       = $link"
        Write-Host "Speed               = $($AdapterInfo.LinkSpeed)"
        Write-Host "Duplex Mode         = $duplex"
    }
}
