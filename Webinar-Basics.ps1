#region: Add Veeam PSSnapin and Connect
## Veeam PowerShell SnapIn
Get-PSSnapin -Registered | fl *
Add-PSSnapin VeeamPSSnapin
## Commands
(Get-Command VeeamPSSnapIn\*).Count
## Online Help 
Start-Process "https://helpcenter.veeam.com/docs/backup/powershell/getting_started.html?ver=95"

## Basic Commands
### Connect Veeam Server
$VeeamCred = Get-Credential -Message "Veeam Credential"
Connect-VBRServer -Server "192.168.3.100" -Credential $VeeamCred

Get-VBRServerSession

(Get-VBRServer).where({$_.type -eq "Local"})

### List all Entities
Find-VBRViEntity
#endregion

#region: Useful Cmdlets
## List all Jobs
Get-VBRJob | Select-Object Name, JobType, SourceType | Format-Table -AutoSize

## Get Members of a Backup Job
Get-VBRJobObject -Job "Backup PhotonOS" | Format-Table -AutoSize

### Get Members of a Backup Job using methode 
$Job = Get-VBRJob -Name "Backup PhotonOS" 
$Job.GetObjectsInJob() | Format-Table -AutoSize

## Get Last Backup Session of a Job
Get-VBRSession -Job $Job -Last

### Extract Log
(Get-VBRSession -Job $Job -Last).Log.Title

## Get All Backup Repositories
Get-VBRBackupRepository  | Select-Object Name, Path, Type | Format-Table -AutoSize

## Get All Backup Repositories Advanced
[Array]$RepoList = Get-VBRBackupRepository | Where-Object {$_.Type -ne "SanSnapshotOnly"} 
[Array]$ScaleOuts = Get-VBRBackupRepository -ScaleOut
if ($ScaleOuts) {
    foreach ($ScaleOut in $ScaleOuts) {
        $Extents = Get-VBRRepositoryExtent -Repository $ScaleOut
        foreach ($Extent in $Extents) {
            $RepoList = $RepoList + $Extent.repository
        }
    }
}
$RepoList | Select-Object Name, Path, `@{Name="CachedTotalSpaceGB"; Expression= {[Math]::Round([Decimal]$_.info.CachedTotalSpace/1GB,2)}}, `@{Name="CachedFreeSpaceGB"; Expression= {[Math]::Round([Decimal]$_.info.CachedFreeSpace/1GB,2)}} | Format-Table -AutoSize
#endregion