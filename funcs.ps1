$vmConfigs = @{
	"Windows10" = @{
		MemoryStartupBytes = 4GB
		NewVHDSizeBytes = 16GB
		Generation = 2
		Path = "D:\VM"
		IsoPath = "D:\ISOs\win10-tweaked.iso"
	}
}

function New-VmParams {
	Param(
		[Parameter(Mandatory)]
		[string] $Name,
		[Parameter(Mandatory)]
		[string] $TemplateName
	)
	$template = $vmConfigs[$TemplateName]
	if ( $template -eq $null ) { throw "$TemplateName is not a template name. Valid names are $($vmConfigs.Keys)"}

	$config = [hashtable]::new($template)

	$config.Name = $Name
	$config.Path = "$($template.Path)/$Name"
	$config.NewVHDPath = "$($template.Path)/$Name/$Name.vhdx"

	return $config
}

function New-TemplateVm {
	Param(
		[Parameter(Mandatory)]
		[string] $Name,
		[Parameter(Mandatory)]
		[string] $TemplateName
	)

	$parms = New-VMParams -Name $Name -TemplateName $TemplateName

	$vmParms = [hashtable]::new($parms)
	$vmParms.Remove("IsoPath")
	$vm = New-VM @vmParms
	if ( $vm -eq $null ) { throw "Failed to create VM."}

	Add-VMDvdDrive -VM $vm -Path $parms.IsoPath
	Set-VM -VM $vm -CheckpointType Disabled -AutomaticStartAction Nothing -AutomaticStopAction ShutDown -ProcessorCount 6
	Get-VMIntegrationService -VM $vm | Enable-VMIntegrationService

	return $vm
}