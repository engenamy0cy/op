$proc = Get-Process POWERPNT
$proc.PriorityClass = "High"

Get-Process POWERPNT | Select-Object ProcessName, Id, PriorityClass, Thread.Count, Headles, CPU, PriorityClass,
@{Name="Memory (MB)"; Expression={[Math]::Round($_.WorkingSet64 / 1MB)}},
@{Name="Private Memory (MB)"; Expression={[Math]::Round($_.PrivateMemorySize64 / 1MB)}}, 
@{Name="Virtual Memory Size (MB)"; Expression={[Math]::Round($_.VirtualMemorySize64 / 1MB)}}  |
Sort-Object PriorityClass -Descending | Select-Object -First 8 | Format-Table -AutoSize
