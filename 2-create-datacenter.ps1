
param (
    [string]$Site               = '',
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

$silasParams  		  = @{

   Name             = "Silas";
   Width            = 10668;
   Depth            = 13716;
   Millimeters      = $True;
   DefaultVoltage   = 120;
   PowerCosts       = 0.10;
   CoolingCapacity  = 350;

}

$dcParams           = $silasParams
if ($NULL -ne $dcParams)
{
	 $dc = New-HPOVDataCenter @dcParams
}
else
{
	write-host -foreground YELLOW "No site found.... exit"
	exit 1
}

$currentX 			  	= $startX 	= 2
$currentY 			  	= $startY 	= 2
$increment			  	= 4

$currentRow				= ''
$rackArray 				= @()

$rackList				= Get-HPOVRack 
foreach ( $r in $rackList)
{
	$row 	= $r.Name.Split('-')[1].Split('.')[0]    # Format is '1S-79.201'
	if ($currentRow -eq $row)
	{
		$rackArray 	+= $r
	}
	else 
	{
		# Have racks in a row
		for ($i=0; $i -lt $rackArray.Count -1; $i++)
		{
			$X 		= $startX + ($i * $increment)
			$Y 		= $currentY
			$rackArray[$i] | Add-HPOVRackToDataCenter -DataCenter $dc -X $X  -Y $Y
		}
		$currentY 	+= $increment
		$rackArray 	= @()
		$currentRow = $row

	}
} 	




#################################################################################################################
# END														#
#################################################################################################################

