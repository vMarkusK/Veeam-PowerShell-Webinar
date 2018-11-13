#region: Add Veeam PSSnapin and Connect
Add-PSSnapin VeeamPSSnapin
$VeeamCred = Get-Credential -Message "Veeam Credential"
Connect-VBRServer -Server "192.168.3.100" -Credential $VeeamCred
Find-VBRViEntity
#endregion

#region: My VeeamJobConfig Module
Remove-Module VeeamJobConfig -ErrorAction SilentlyContinue
Import-Module "C:\Users\Administrator\Documents\PowerShell\VeeamJobConfig\VeeamJobConfig.psd1"
#endregion

#region: Get Job Options
$ExampleJob = Get-VBRJob -Name "Backup Job 1"
$ExampleJobOptions = $ExampleJob.GetOptions()

##Output Job Options as JSON
$JsonObject = $ExampleJobOptions | ConvertTo-Json
$Object = $JsonObject | ConvertFrom-Json
$Object.PSObject.Properties.Remove('Options')
$Object | ConvertTo-Json | Out-File "C:\temp\ExampleJobOptions.json"
#endregion

#region: Basic - Set Job Options
$BackupJob = Get-VBRJob -Name "Backup Job 2"

## All Options
Set-VBRJobOptions -Job $BackupJob -Options $ExampleJobOptions

## Modified Options
$BackupJobOptions = $BackupJob.GetOptions()
$BackupJobOptions.BackupStorageOptions.EnableDeletedVmDataRetention = $True
Set-VBRJobOptions -Job $BackupJob -Options $BackupJobOptions
#endregion

#region: Working with Module
## Export a Config
$TemplateBackupJob = Get-VBRJob -Name "Template Job 1"
Export-VbrJobOptionsToFile -BackupJob $TemplateBackupJob -Path "C:\temp\ExampleJobOptions.json"

## Update Multiple Jobs from File
Get-VBRJob -Name "Backup Job*" | ft -AutoSize
(Get-VBRJob -Name "Backup Job*" | Get-VBRJobOptions).BackupStorageOptions | ft -AutoSize

Get-VBRJob -Name "Backup Job*" | Set-VBRJobOptionsFromFile -ReferenceFile "C:\temp\ExampleJobOptions.json" -BackupStorageOptions

(Get-VBRJob -Name "Backup Job*" | Get-VBRJobOptions).BackupStorageOptions | ft -AutoSize

## Update Multiple Jobs from Template
$TemplateBackupJob = Get-VBRJob -Name "Template Job 2"
Get-VBRJob -Name "Backup Job*" | Set-VBRJobOptionsFromRef -ReferenceBackupJob $TemplateBackupJob 

(Get-VBRJob -Name "Backup Job*" | Get-VBRJobOptions).BackupStorageOptions | ft -AutoSize
#endregion