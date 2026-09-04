# Get-Process | Select-Object ProcessName, id, Threads

#Handle -ссылка на процессы на системный обьект - файл окно
#событие мютекс ключи реестра итд.

# Get-Process | Sort-Object Handle -Descending |
# Select-Object -First 10 ProcessName, id, Handle

#процесс ↓
#память
#поток
#файлы
#окна
#другие системные обьекты

# #Родительское PID древо
# Get-Process Win32_Process |
# Select-Object Name,ProcessId,ParentProcessId |
# Select-Object -First 5

# #Приоритет процесса
# Get-Process notepad |
# Select-Object ProcessName, PriorityClass

$proc = Get-Process notepad
$proc.PriorityClass = "BelowNormal"

#Планировки ОС использует приоритеты чтобы решать каким потокам раньше дать процессерное время
#Высший приоитет который лучше не ставить но можно попробовать

#RealTime


# Get-Process
# WorkingSet64
# PrivateMemorySize64
# VirtualMemorySize64
# PageFileUsege
# Thread.Count - потоки
# Headles - Системные объекты
# CPU - процессорное время
# PriorityClass - работа планировщика

# #Синхронное асинхронное выполнение задач
# Write-Host "Начало"
# Start-Sleep -Seconds 2
# Write-Host "задача завершена"

# Start-Sleep -Seconds 2
# Write-Host "задача завершена"

# Start-Sleep -Seconds 2
# Write-Host "задача завершена"

# Write-Host "конец"

#Разница в асинхронном выполнении на примере цикла

# Write-Host "SINC"
# Measure-Command{
#     1..5 | ForEach-Object{
#         Start-Sleep -Seconds 2
#         Write-Host "задача завершена"
#     }
# }

# #паралельное выполнение
# Write-Host "ASINC"
# Measure-Command{
#     1..5 | ForEach-Object -Parallel {
#         Write-Host "print" | Start-Sleep -Seconds 2
#     }
# }

#процесс↓
#поток 1
#поток 2
#поток 3
#процесс имеет - память
# -собственное адресное пространство
# -ресурсы

#несколько пооков внутри процесса могут работа с общей памятью
# именно на этом моменте появляется проблема синхронизации


# Главная проблема общей переменной
#допустим у нас есть counter = 0
# 2 или более потока хотят сделать counter++

# из чего состоит операция
# 1 - прочитать counter
# 2 - прибавить 1
# 3 - записать counter

# с несколькими потоками counter = 10
# поток A       поток B
# читает 10      читает 10
#прибавояет +1     прибавляет +1
#получает 11      получает 11
#пишет 11      пишет 11
#мы ожидаем 12
# а получили 11

#по другому называется race condition - состояние гонки
# и для чего нужна синхронизация

#запуск нескольких задая использования -Parallel
# первые проблемы для синхронизхации
#он использует отдельные runspace
#поэтому обысную переменную нелья совместно изменять
#ps1 специально изолирует паралельный runspace чтобы уменьша 
#колличество конфликтов памяти

#самый прочтой пример синхронизации через lock
#создать обьект блокировки
$lock = New-Object object

# пока один поток находится внутри критической секции другой ждет

#Критичесая секция участок программы где несколько потоков

#работают с общими данными и

#куда одновременно входит только один поток


#.NET

# [Sustem.Threading.Monitor]::Enter($lock)

# [System.Threading.Monitor]::Exit($lock)

#принцип
[Sustem.Threading.Monitor]::Enter($lock)
try {
    #критическая секция
}
finally{
    [System.Threading.Monitor]::Exit($lock)
}

#Mutex

