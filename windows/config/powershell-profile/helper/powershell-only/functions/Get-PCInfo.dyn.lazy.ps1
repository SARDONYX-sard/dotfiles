# System Information
$ReturnData = New-Object PSObject | Select-Object HostName, Manufacturer, Model, SN, CPUName, PhysicalCores, Sockets, MemorySize, DiskInfos, OS

$Win32_BIOS = Get-WmiObject Win32_BIOS
$Win32_Processor = Get-WmiObject Win32_Processor
$Win32_ComputerSystem = Get-WmiObject Win32_ComputerSystem
$Win32_OperatingSystem = Get-WmiObject Win32_OperatingSystem

$ReturnData.HostName = hostname

# Maker Name
$ReturnData.Manufacturer = $Win32_BIOS.Manufacturer

# Motherboard Model
$ReturnData.Model = $Win32_ComputerSystem.Model

$ReturnData.SN = $Win32_BIOS.SerialNumber

$ReturnData.CPUName = @($Win32_Processor.Name)[0]

$PhysicalCores = 0
$Win32_Processor.NumberOfCores | ForEach-Object { $PhysicalCores += $_ }
$ReturnData.PhysicalCores = $PhysicalCores

$ReturnData.Sockets = $Win32_ComputerSystem.NumberOfProcessors

$Total = 0
Get-WmiObject -Class Win32_PhysicalMemory | ForEach-Object { $Total += $_.Capacity }
$ReturnData.MemorySize = [int]($Total / 1GB)

# DiskInfos
[array]$DiskDrives = Get-WmiObject Win32_DiskDrive | Where-Object { $_.Caption -notmatch "Msft" } | Sort-Object Index
$DiskInfos = @()
foreach ( $DiskDrive in $DiskDrives ) {
  $DiskInfo = New-Object PSObject | Select-Object Index, DiskSize
  $DiskInfo.Index = $DiskDrive.Index
  $DiskInfo.DiskSize = [int]($DiskDrive.Size / 1GB)
  $DiskInfos += $DiskInfo
}
$ReturnData.DiskInfos = $DiskInfos

$OS = $Win32_OperatingSystem.Caption
$SP = $Win32_OperatingSystem.ServicePackMajorVersion
if ( $SP -ne 0 ) { $OS += "SP" + $SP }
$ReturnData.OS = $OS

return $ReturnData
