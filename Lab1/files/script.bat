:: .\script.bat dhcp "Ethernet"
:: .\script.bat static "Ethernet" 192.168.1.10 255.255.255.0 192.168.1.1 8.8.8.8
:: .\script.bat

@echo off
:: Не показывать команды при выполнении

chcp 65001 > nul
:: Включить UTF-8 (чтобы русский текст отображался нормально)

setlocal enabledelayedexpansion
:: Включить локальные переменные (безопасно для скрипта)

:: Проверяем, запущен ли скрипт от администратора
net session >nul 2>&1
:: Эта команда работает только у администратора

if errorlevel 1 (
    echo Ошибка: скрипт нужно запускать от имени администратора.
    pause
    exit /b 1 :: Остановить выполнение
)

:: Получаем параметры из командной строки
set "mode=%~1"
:: Режим: dhcp или static

set "interface=%~2"
:: Имя сетевого адаптера (например "Ethernet")

set "address=%~3"
:: IP-адрес (например 192.168.1.10)

set "mask=%~4"
:: Маска подсети (например 255.255.255.0)

set "gateway=%~5"
:: Шлюз (обычно 192.168.1.1)

set "dns=%~6"
:: DNS-сервер (например 8.8.8.8)

:choose_mode
:: Здесь выбирается режим работы

if /i "%mode%"=="exit" goto end
:: Выход из скрипта

if /i "%mode%"=="help" goto help
:: Показать справку

if /i "%mode%"=="dhcp" goto check_interface
:: DHCP — автоматическая настройка

if /i "%mode%"=="static" goto check_interface
:: STATIC — ручная настройка

:: Если ввели что-то неправильное
echo Неверный режим
set /p "mode=Введите dhcp, static или help: "
goto choose_mode

:check_interface
:: Проверяем, указали ли интерфейс

if "%interface%"=="" goto request_interface
:: Если нет — спросить

netsh interface show interface | find /I "%interface%" >nul
:: Ищем интерфейс в списке

if errorlevel 1 (
    echo Ошибка: интерфейс "%interface%" не найден.
    set "interface="
    goto request_interface
)

goto process_mode
:: Если найден — идём дальше

:request_interface
:: Показываем список интерфейсов

echo.
echo Доступные интерфейсы:
netsh interface show interface

echo.
set /p "interface=Введите имя интерфейса: "
:: Пользователь вводит имя

goto check_interface
:: Проверяем снова

:process_mode
:: Определяем, какой режим выполнять

if /i "%mode%"=="dhcp" goto dhcp_mode
if /i "%mode%"=="static" goto static_mode

goto choose_mode

:dhcp_mode
:: Включаем автоматическое получение IP

echo Включение DHCP...

netsh interface ipv4 set address name="%interface%" source=dhcp
:: IP будет выдаваться автоматически

netsh interface ipv4 set dnsservers name="%interface%" source=dhcp
:: DNS тоже автоматически

goto result_check

:static_mode
:: Ручной ввод настроек

echo Ручная настройка

:get_ip
if "%address%"=="" (
    set /p "address=Введите IP: "
    goto get_ip
)

:get_mask
if "%mask%"=="" (
    set /p "mask=Введите маску: "
    goto get_mask
)

:get_gateway
if "%gateway%"=="" (
    set /p "gateway=Введите шлюз: "
    goto get_gateway
)

:get_dns
if "%dns%"=="" (
    set /p "dns=Введите DNS: "
    goto get_dns
)

echo Применяем настройки...

netsh interface ipv4 set address name="%interface%" source=static address=%address% mask=%mask% gateway=%gateway%
:: Устанавливаем IP, маску и шлюз

netsh interface ipv4 set dnsservers name="%interface%" source=static address=%dns%
:: Устанавливаем DNS

:result_check
:: Показываем результат

echo.
echo Текущие настройки:
netsh interface ipv4 show config name="%interface%"

goto end

:help
:: Подсказка, как использовать скрипт

echo.
echo Пример:
echo script.bat dhcp "Ethernet"
echo script.bat static "Ethernet" 192.168.1.10 255.255.255.0 192.168.1.1 8.8.8.8
echo.

:end
:: Конец скрипта

endlocal
:: Очистка переменных