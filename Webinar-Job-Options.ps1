#region: Add Veeam PSSnapin and Connect
Add-PSSnapin VeeamPSSnapin
$VeeamCred = Get-Credential -Message "Veeam Credential"
Connect-VBRServer -Server "192.168.3.100" -Credential $VeeamCred
Find-VBRViEntity
#endregion

#region: My VeeamJobConfig Module
Import-Module "C:\Users\Administrator\Documents\PowerShell\VeeamJobConfig\VeeamJobConfig.psd1"
#endregion

#region: Get Job Options
$ExampleJob = Get-VBRJob -Name "Backup Job 1"
$ExampleJobOptions = $ExampleJob.GetOptions()

##Output Job Options as JSON
$ExampleJobOptions | ConvertTo-Json
#endregion

#region: Basic - Set Job Options
$BackupJob = Get-VBRJob -Name "Backup Job 2"
Set-VBRJobOptions -Job $BackupJob -Options $ExampleJobOptions
#endregion



