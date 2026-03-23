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