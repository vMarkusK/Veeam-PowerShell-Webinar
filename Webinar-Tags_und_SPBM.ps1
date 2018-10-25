#region: Add Veeam PSSnapin and Connect
Add-PSSnapin VeeamPSSnapin
$VeeamCred = Get-Credential -Message "Veeam Credential"
Connect-VBRServer -Server "192.168.3.100" -Credential $VeeamCred
Find-VBRViEntity
#endregion

#region: VMware Module and vCenter Connection
Get-Module -ListAvailable -Name VMware* | Import-Module
Set-PowerCLIConfiguration -DefaultVIServerMode Single -InvalidCertificateAction Ignore -Scope Session -Confirm:$false
$vCenterCred = Get-Credential -Message "vCenter Credential"
Connect-VIServer -Server "192.168.3.101" -Credential $vCenterCred
#endregion

#region: List Objects in Backup Jobs
$VBRJobs = (Get-VBRJob).where({$_.JobType -eq "Backup" -and $_.Name -like "*Location*"})
## List Backup Jobs that match the filter
$VBRJobs | Select Name, JobType, SourceType | ft

$VBRJobToLocationA = $VBRJobs.where({$_.Name -like "*LocationA*"})
## list Objects in Job
$VBRJobToLocationA.GetObjectsInJob().GetObject() | Select ViType, Name, ObjectId | ft
#endregion

#region: Get Veeam Tag Details
## Veeam Inventory
(Find-VBRViEntity -Tags).where({$_.Type -eq "Tag"}) | Select Path, Reference | ft -AutoSize
## vSphere Tag
Get-Tag | Select Category, Name, Id | ft -AutoSize
#endregion

#region: Get VMs per Location by Tag
$LocationTagCategory = Get-TagCategory -Name "Location"
[Array]$LocationTags = Get-Tag -Category $LocationTagCategory
$DatastoreLocationA = Get-Datastore -Tag $LocationTags.where({$_.Name -eq "LocationA" })
$DatastoreLocationB = Get-Datastore -Tag $LocationTags.where({$_.Name -eq "LocationB" })
$VMsLocaltionA = $DatastoreLocationA | Get-VM
$VMsLocaltionB = $DatastoreLocationB | Get-VM
#endregion

#region: Tag VMs
$DestinationnTagCategory = Get-TagCategory -Name "VeeamDestination"
$VMsLocaltionB | New-TagAssignment -Tag $(Get-Tag -Category $DestinationnTagCategory -Name "LocationA")
$VMsLocaltionA | New-TagAssignment -Tag $(Get-Tag -Category $DestinationnTagCategory -Name "LocationB")
#endregion

#region: Get Tag Tag Assignment
$VMsLocaltionB | Get-TagAssignment 
$VMsLocaltionA | Get-TagAssignment
#endregion

#region: Remove Tag Tag Assignment
$VMsLocaltionB | Get-TagAssignment | Remove-TagAssignment -Confirm:$false
$VMsLocaltionA | Get-TagAssignment | Remove-TagAssignment -Confirm:$false
#endregion

#region: Tag VMs by SPBM
Get-SpbmStoragePolicy -Name "NetApp-LocationB" | Get-VM | New-TagAssignment -Tag $(Get-Tag -Category $DestinationnTagCategory -Name "LocationA")
#endregion
