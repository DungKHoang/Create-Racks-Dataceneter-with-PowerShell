
param (
    [string]$SourceXLS 			= $(throw "Excel Inventory Sheet filename is required."),
    [string]$OVApplianceIP 	    = $(throw "OV Appliance IP is required."),
    [string]$OVAdminName	    = '' ,
    [string]$OVAdminPassword	= '' 	
)


#CONSTANTS#######################################################################################################

$CRLF 	= "`r`n"



#################################################################################################################
# MAIN														#
#################################################################################################################




### Import HPOVMgmt
Import-Module HPOneView.500
Import-Module ImportExcel


### Load data
write-host -foreground CYAN  "Importing Source and Target Server Data" 
$SourceXLS_Data     =  Import-Excel $SourceXLS  -DataOnly 
						### Connect to OV Appliance
$SecurePassword 	= ConvertTo-SecureString $OVAdminPassword -AsPlainText -Force

$cred 				= New-Object System.Management.Automation.PSCredential -ArgumentList ($OVAdminName,$SecurePassword)

								
write-host -foreground CYAN "Issuing a Disconnect HPOV Call for any exisitng connections" 
$errorOrigSetting 		= $errorActionPreference
$errorActionPreference 	= "SilentlyContinue"
if ($global:connectedSessions) 
{
	disconnect-hpOVMgmt
}
$errorActionPreference 	= $errorOrigSetting

write-host -foreground CYAN "Connecting to HPOV Management Appliance: $OVApplianceIP as $OVAdminName" 

Connect-HPOVMgmt -hostname $OVApplianceIP -Credential $cred | out-host


$currentRackName  		= ""
foreach ($entry in $SourceXLS_Data) 
{	
	$iLO_IPv4_Address 	= $entry.IPv4

	$dnsName 			= $entry.Hostname
	$iLoName 			= $entry.Hostname
	
	$assignedRole 		= $entry.Role
	$assignedEnv 		= $entry.Environment
	$serverProfileName 	= $entry.Profile

	$serverModel 		= $entry.model
	$grid 				= $entry.Grid
	$ru					= $entry.Elevation
	$cdu1 				= $entry.CDU1
	
	$grid				= $grid -replace "Zone ", ""	
	$rackName 			= "{0}-{1}" -f $grid, $ru			

	$rack 				= get-hpovrack | where name -like $rackName 

	if ($Null -eq $rack)
	{
		$rack 			= new-hpovrack -name $rackName  -uHeight 42
		write-host -foreground CYAN "Creating Rack $rackName...."		
	}


	$s 					= Get-HPOVServer | where name -like  "*$dnsName*" 

	if ($NULL -ne $s)   
	{
		$isInRack 		= $rack.rackMounts.mountUri -contains $s.Uri
		if (-not $isInRack)
		{
			$res 			= Add-HPOVResourceToRack -Rack $rack -ULocation $cdu1 -inputObject $s
			$text 			= "Add server {0} to rack {1}..." -f $dnsName, $rackName
			write-host -foreground CYAN $text
		}
		else
		{
				write-host -foreground CYAN "server $dnsName already in rack $rackName...."
		}

	}
	

}


Disconnect-HPOVMgmt



#################################################################################################################
# END														#
#################################################################################################################

