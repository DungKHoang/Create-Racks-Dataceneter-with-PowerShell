# Create-Racks-Datacenter-with-PowerShell
The sample script leverage OneView PowerShell librarty to generate racks configuration and data center in OneView.
It reads an Excel file and collect ionofrmation to generate racks



Note: The script is generated using the Convertto-OVPowerShellscript cmdlet !

Enjoy!


## Prerequisites
   * OneView PowerShell library v5.0
   * ImportExcel module from PowerShell gallery
   * Excel file containting racks information ( see Samples)

## Syntax

```
    .\1-create-racks.ps1 -OVApplianceIP <OV-IP-Address> -OVAdminName <Admin-name> -OVAdminPassword <password> -sourceXLS <Excel_file>
    .\2-create-datacenter.ps1 -OVApplianceIP <OV-IP-Address> -OVAdminName <Admin-name> -OVAdminPassword <password>

```
