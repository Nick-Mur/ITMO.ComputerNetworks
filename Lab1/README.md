# Практическая работа №1

**Консольные утилиты настройки сетевых компонентов в ОС Windows**

---

## Цель работы

Получить практические навыки по конфигурированию сети в операционных системах Microsoft Windows,
ознакомится с утилитами командной строки, предназначенными для диагностики и настройки сети, разработать исполняемые
файлы, конфигурирующие сетевой интерфейс по заданным параметрам, ознакомиться с форматом записи пути до сетевого ресурса
UNC.

---

# Ход выполнения работы

---

## 1. Проверка свойств сетевого подключения

В ходе выполнения работы были открыты свойства используемого сетевого подключения (Wi-Fi адаптер).

![Свойства сети](files/images/img.png)

В свойствах подключения были проверены следующие компоненты:

* Клиент для сетей Microsoft
* Общий доступ к файлам и принтерам для сетей Microsoft
* Протокол Интернета версии 4 (TCP/IPv4)

Все указанные компоненты были активны.

---

### Назначение компонентов

**Клиент для сетей Microsoft**
Позволяет компьютеру подключаться к другим устройствам в сети и получать доступ к их ресурсам (общие папки, сетевые
диски, принтеры). Работает с использованием протокола SMB.

**Служба доступа к файлам и принтерам Microsoft**
Обеспечивает возможность предоставления ресурсов данного компьютера другим пользователям сети. При отключении данного
компонента другие устройства не смогут получить доступ к файлам и принтерам.

**Протокол TCP/IP**
Основной сетевой протокол, обеспечивающий передачу данных в сети.

* IP — отвечает за адресацию и маршрутизацию
* TCP — обеспечивает надежную доставку данных

---

## 2. Ограничение доступа к ресурсам

Для запрета доступа к ресурсам компьютера по сети был отключён компонент:

* **Общий доступ к файлам и принтерам для сетей Microsoft**

![Отключение компонента](files/images/img_1.png)

В результате компьютер перестал предоставлять доступ к своим ресурсам по протоколу SMB.

---

## 3. Работа с утилитой `ping`

### Назначение

Утилита `ping` используется для проверки доступности удалённого узла и измерения времени отклика.

---

### a) Проверка доступности

```cmd
ping my.itmo.ru
```

![ping](files/images/img_2.png)

Результат:

* узел доступен
* потерь пакетов нет
* среднее время ≈ 20 мс

---

### b) Бесконечная проверка

```cmd
ping -t my.itmo.ru
```

![ping -t](files/images/img_3.png)

Команда выполнялась до ручной остановки (Ctrl+C). Потерь не наблюдалось.

---

### c) Ограничение числа запросов

```cmd
ping -n 5 my.itmo.ru
```

![ping -n](files/images/img_4.png)

Было отправлено 5 пакетов, все успешно получены.

---

### d) Изменение размера пакета

```cmd
ping -l 1000 my.itmo.ru
```

![ping -l](files/images/img_5.png)

Увеличение размера пакета не привело к потерям, задержка немного увеличилась.

---

### e) Сохранение результата

```cmd
ping my.itmo.ru > file_3f.txt
```

Результаты были сохранены в файл.

---

## 4. Работа с утилитой `tracert`

### Назначение

Команда `tracert` позволяет определить маршрут прохождения пакетов до удалённого узла.

---

### a) Определение маршрута

```cmd
tracert my.itmo.ru
```

![tracert](files/images/img_6.png)

Маршрут проходит через:

* локальный роутер
* сеть провайдера
* промежуточные узлы

Некоторые узлы не отвечают (`*`), что допустимо.

---

### b) Ограничение числа хопов

```cmd
tracert -h 10 my.itmo.ru
```

![tracert -h](files/images/img_7.png)

Маршрут ограничен 10 узлами.

---

### c) Изменение времени ожидания

```cmd
tracert -w 150 my.itmo.ru
```

![tracert -w](files/images/img_8.png)

Увеличение таймаута позволило получить больше ответов от узлов.

---

## 5. Утилита `ipconfig` и `net`

---

### 5.1 Утилита `ipconfig`

#### a) Просмотр конфигурации

```cmd
ipconfig
```

![ipconfig](files/images/img_9.png)

---

#### b) Полная информация

```cmd
ipconfig /all
```

```
PS C:\Users\user> ipconfig /all

Настройка протокола IP для Windows

   Имя компьютера  . . . . . . . . . : MurSystem
   Основной DNS-суффикс  . . . . . . :
   Тип узла. . . . . . . . . . . . . : Гибридный
   IP-маршрутизация включена . . . . : Нет
   WINS-прокси включен . . . . . . . : Нет

Адаптер Ethernet Ethernet:

   DNS-суффикс подключения . . . . . :
   Описание. . . . . . . . . . . . . : VirtualBox Host-Only Ethernet Adapter
   Физический адрес. . . . . . . . . : 0A-00-27-00-00-05
   DHCP включен. . . . . . . . . . . : Нет
   Автонастройка включена. . . . . . : Да
   Локальный IPv6-адрес канала . . . : fe80::445d:dab6:8f1:5bcb%5(Основной)
   IPv4-адрес. . . . . . . . . . . . : 192.168.56.1(Основной)
   Маска подсети . . . . . . . . . . : 255.255.255.0
   Основной шлюз. . . . . . . . . :
   IAID DHCPv6 . . . . . . . . . . . : 789184551
   DUID клиента DHCPv6 . . . . . . . : 00-01-01-00-31-2E-96-F6-7C-FA-80-A6-56-03
   NetBios через TCP/IP. . . . . . . . : Включен

Адаптер беспроводной локальной сети Подключение по локальной сети* 9:

   Состояние среды. . . . . . . . : Среда передачи недоступна.
   DNS-суффикс подключения . . . . . :
   Описание. . . . . . . . . . . . . : Microsoft Wi-Fi Direct Virtual Adapter
   Физический адрес. . . . . . . . . : 7E-FA-80-A6-56-03
   DHCP включен. . . . . . . . . . . : Да
   Автонастройка включена. . . . . . : Да

Адаптер беспроводной локальной сети Подключение по локальной сети* 10:

   Состояние среды. . . . . . . . : Среда передачи недоступна.
   DNS-суффикс подключения . . . . . :
   Описание. . . . . . . . . . . . . : Microsoft Wi-Fi Direct Virtual Adapter #2
   Физический адрес. . . . . . . . . : 72-FA-80-A6-56-03
   DHCP включен. . . . . . . . . . . : Да
   Автонастройка включена. . . . . . : Да

Адаптер беспроводной локальной сети Беспроводная сеть:

   DNS-суффикс подключения . . . . . :
   Описание. . . . . . . . . . . . . : Realtek RTL8852BE WiFi 6 802.11ax PCIe Adapter
   Физический адрес. . . . . . . . . : 7C-FA-80-A6-56-03
   DHCP включен. . . . . . . . . . . : Да
   Автонастройка включена. . . . . . : Да
   Локальный IPv6-адрес канала . . . : fe80::d6e0:c39a:bff6:7f48%19(Основной)
   IPv4-адрес. . . . . . . . . . . . : 192.168.1.36(Основной)
   Маска подсети . . . . . . . . . . : 255.255.255.0
   Аренда получена. . . . . . . . . . : 22 марта 2026 г. 12:15:05
   Срок аренды истекает. . . . . . . . . . : 22 марта 2026 г. 19:34:34
   Основной шлюз. . . . . . . . . : 192.168.1.1
   DHCP-сервер. . . . . . . . . . . : 192.168.1.1
   IAID DHCPv6 . . . . . . . . . . . : 360512128
   DUID клиента DHCPv6 . . . . . . . : 00-01-01-00-31-2E-96-F6-7C-FA-80-A6-56-03
   DNS-серверы. . . . . . . . . . . : 192.168.1.1
   NetBios через TCP/IP. . . . . . . . : Включен

Адаптер Ethernet Сетевое подключение Bluetooth:

   Состояние среды. . . . . . . . : Среда передачи недоступна.
   DNS-суффикс подключения . . . . . :
   Описание. . . . . . . . . . . . . : Bluetooth Device (Personal Area Network)
   Физический адрес. . . . . . . . . : 7C-FA-80-A6-56-04
   DHCP включен. . . . . . . . . . . : Да
   Автонастройка включена. . . . . . : Да
```

---

#### c) Обновление IP

```cmd
ipconfig /renew
```

![renew](files/images/img_10.png)

---

#### d) Очистка DNS-кэша

```cmd
ipconfig /flushdns
```

![flushdns](files/images/img_11.png)

---

#### e) Просмотр DNS-кэша

```cmd
ipconfig /displaydns
```

![displaydns](files/images/img_12.png)

---

### 5.2 Утилита `net`

#### a) Просмотр открытых файлов

```cmd
net file
```

![net file](files/images/img_13.png)

---

#### b) Статистика

```cmd
net statistics workstation
```

![statistics](files/images/img_14.png)

---

#### c) Конфигурация станции

```cmd
net config workstation
```

![config workstation](files/images/img_15.png)

---

#### d) Конфигурация сервера

```cmd
net config server
```

![config server](files/images/img_16.png)

---

## 6. Скрипт на CMD (netsh)

Был разработан BAT-скрипт для настройки интерфейса:

<details>
<summary>Скрипт (нажмите, чтобы раскрыть)</summary>
@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: Проверка запуска от имени администратора
net session >nul 2>&1
if errorlevel 1 (
    echo Ошибка: скрипт нужно запускать от имени администратора.
    pause
    exit /b 1
)

:: Считываем параметры
set "mode=%~1"
set "interface=%~2"
set "address=%~3"
set "mask=%~4"
set "gateway=%~5"
set "dns=%~6"

:: Выбор режима
:choose_mode
if /i "%mode%"=="exit" goto end
if /i "%mode%"=="?" goto help
if /i "%mode%"=="/?" goto help
if /i "%mode%"=="help" goto help
if /i "%mode%"=="dhcp" goto check_interface
if /i "%mode%"=="static" goto check_interface

:invalid_mode
echo Неверный режим: "%mode%"
set "mode="
set /p "mode=Выберите режим (dhcp^|static^|help^|exit): "
goto choose_mode

:: Проверка интерфейса
:check_interface
if "%interface%"=="" goto request_interface

netsh interface show interface | find /I "%interface%" >nul
if errorlevel 1 (
    echo Ошибка: интерфейс "%interface%" не найден.
    set "interface="
    goto request_interface
) else (
    goto process_mode
)

:request_interface
echo.
echo Доступные интерфейсы:
netsh interface show interface
echo.
set /p "interface=Введите точное название интерфейса: "
goto check_interface

:: Обработка режима
:process_mode
if /i "%mode%"=="dhcp" goto dhcp_mode
if /i "%mode%"=="static" goto static_mode
goto invalid_mode

:dhcp_mode
echo Настройка по DHCP...
netsh interface ipv4 set address name="%interface%" source=dhcp
if errorlevel 1 (
    echo Ошибка при включении DHCP для IP.
    goto end
)

netsh interface ipv4 set dnsservers name="%interface%" source=dhcp
if errorlevel 1 (
    echo Ошибка при включении DHCP для DNS.
    goto end
)

goto result_check

:static_mode
echo Режим статической настройки

:get_ip
if "%address%"=="" (
    set /p "address=Введите IP-адрес: "
    goto get_ip
)

:get_mask
if "%mask%"=="" (
    set /p "mask=Введите маску подсети: "
    goto get_mask
)

:get_gateway
if "%gateway%"=="" (
    set /p "gateway=Введите основной шлюз: "
    goto get_gateway
)

:get_dns
if "%dns%"=="" (
    set /p "dns=Введите DNS-сервер: "
    goto get_dns
)

echo Применение заданных параметров...
netsh interface ipv4 set address name="%interface%" source=static address=%address% mask=%mask% gateway=%gateway% gwmetric=1
if errorlevel 1 (
    echo Ошибка при установке IP-адреса, маски или шлюза.
    goto end
)

netsh interface ipv4 set dnsservers name="%interface%" source=static address=%dns% register=primary
if errorlevel 1 (
    echo Ошибка при установке DNS.
    goto end
)

:result_check
echo.
echo Результат:
netsh interface ipv4 show config name="%interface%"
goto end

:help
echo.
echo Автоматическая настройка:
echo   %~nx0 dhcp "Имя интерфейса"
echo.
echo Ручная настройка:
echo   %~nx0 static "Имя интерфейса" 192.168.1.77 255.255.255.0 192.168.1.1 8.8.8.8
echo.
echo Интерактивный режим:
echo   %~nx0
echo.
goto end

:end
endlocal
</details>

### Возможности:

* DHCP режим
* статическая настройка

Пример запуска:
```cmd
script.bat dhcp "Беспроводная сеть"
script.bat static "Беспроводная сеть" 192.168.1.100 255.255.255.0 192.168.1.1 8.8.8.8
```

Результат проверки:

```cmd
netsh interface ip show config name="Беспроводная сеть"
```

Скрипт корректно изменяет настройки сети.

---

## 7. Скрипт PowerShell

Реализован аналогичный скрипт на PowerShell.

<details>
<summary>Скрипт (нажмите, чтобы раскрыть)</summary>
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
</details>

### Возможности:

* DHCP
* Static
* Info (дополнительно)

Пример работы:

```powershell
./script.ps1
```

Вывод:

* модель адаптера
* MAC-адрес
* статус подключения
* скорость
* duplex

---

# Ответы на вопросы

---

### 1. Запрет доступа через интерфейс

* Через брандмауэр Windows → создать правило → выбрать интерфейс → запретить подключение
* Или отключить:

    * сетевое обнаружение
    * общий доступ к файлам

---

### 2. Команда `net`

| Команда        | Назначение           |
|----------------|----------------------|
| net use        | подключение ресурсов |
| net view       | просмотр сети        |
| net stop/start | управление службами  |
| net share      | управление папками   |
| net config     | настройки            |
| net session    | сеансы               |
| net user       | пользователи         |
| net statistics | статистика           |
| net localgroup | группы               |

---

### 3. Как узнать DNS

```cmd
ipconfig /all
```

---

### 4. Команда net use

```cmd
net use R: \\SRV\TEST
```

Подключает сетевую папку как диск.

---

### 5. Переименование интерфейса

```powershell
Rename-NetAdapter -Name "Старое" -NewName "Новое"
```

---

### 6. Режимы duplex

* Полудуплекс — передача в одну сторону
* Полный дуплекс — одновременная передача
* Авто — автоматический выбор

---

# Вывод

В ходе работы были изучены основные консольные утилиты Windows (`ping`, `tracert`, `ipconfig`, `net`, `netsh`) и их
параметры. Были получены практические навыки диагностики сети и настройки сетевых интерфейсов, а также разработаны
скрипты для автоматизации этих процессов.
