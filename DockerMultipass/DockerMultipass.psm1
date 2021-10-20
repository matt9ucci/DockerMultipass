$DEFAULT_INSTANCE_NAME = 'DockerMultipass'

<#
.NOTES
	Dependencies: Multipass
#>
function Enter-DmpInstance {
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string]
		$Name = $DEFAULT_INSTANCE_NAME
	)

	multipass shell $Name
}

<#
.NOTES
	Dependencies: Multipass
#>
function Get-DmpInstance {
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Name = $DEFAULT_INSTANCE_NAME
	)

	multipass info --format csv @Name | ConvertFrom-Csv
}

<#
.NOTES
	Dependencies: Multipass
.EXAMPLE
	# create default instance
	New-DmpInstance
.EXAMPLE
	# create customized instance
	$params = @{
		Name = 'Example'
		Cpu = 1
		Disk = 8GB
		Memory = 1GB
		Image = 'focal'
	}
	New-DmpInstance @params
#>
function New-DmpInstance {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string]
		$Name = $DEFAULT_INSTANCE_NAME,

		[ValidateRange(1, [UInt16]::MaxValue)]
		[UInt16]
		$Cpu = 2,

		[ValidateRange(512MB, [UInt64]::MaxValue)]
		[UInt64]
		$Disk = 16GB,

		[ValidateRange(128MB, [UInt64]::MaxValue)]
		[UInt64]
		$Memory = 2GB,

		[string]
		$Image = 'lts'
	)

	$param = @(
		'--cloud-init', (Join-Path $PSScriptRoot DockerMultipass.yaml)
		'--name', $Name
		'--cpus', $Cpu
		'--disk', $Disk
		'--mem', $Memory
		$Image
	)

	if ($PSCmdlet.ShouldProcess($Name, 'Create instances')) {
		multipass launch @param
		Mount-DmpHostDirectory -Name $Name
	}
}

<#
.NOTES
	Dependencies: Multipass
#>
function Remove-DmpInstance {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Name = 'DockerMultipass'
	)

	if ($PSCmdlet.ShouldProcess($Name, 'Delete and purge instances')) {
		multipass delete --purge @Name
	}
}

<#
.NOTES
	Dependencies: Multipass
#>
function Restart-DmpInstance {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Name = $DEFAULT_INSTANCE_NAME
	)

	if ($PSCmdlet.ShouldProcess($Name, 'Restart instances')) {
		multipass restart @Name
	}
}

<#
.NOTES
	Dependencies: Multipass
#>
function Start-DmpInstance {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Name = $DEFAULT_INSTANCE_NAME
	)

	if ($PSCmdlet.ShouldProcess($Name, 'Start instances')) {
		multipass start @Name
	}
}

<#
.NOTES
	Dependencies: Multipass
#>
function Stop-DmpInstance {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Name = $DEFAULT_INSTANCE_NAME
	)

	if ($PSCmdlet.ShouldProcess($Name, 'Stop instances')) {
		multipass stop @Name
	}
}

<#
.NOTES
	Dependencies: Docker CLI
#>
function Use-DmpInstance {
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string]
		$Name = $DEFAULT_INSTANCE_NAME
	)

	if (!(Get-DmpInstance -Name $Name -ErrorAction Ignore)) {
		throw "Instance not found: $Name"
	}

	$existing = (docker context ls --quiet) -contains $Name
	if (!$existing) {
		New-DmpContext -Name $Name -Confirm -ErrorAction Stop
	}
	docker context use $Name
}

<#
.NOTES
	Dependencies: Multipass
#>
function Mount-DmpHostDirectory {
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[ValidateScript({ Test-Path $_ -PathType Container })]
		[string]
		$Source = $env:USERPROFILE,

		[Parameter(Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string]
		$Name = $DEFAULT_INSTANCE_NAME,

		[Parameter(Position = 2, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string]
		$Target = ($Source | ToDmpMountTargetPath)
	)

	if (!(Test-local.privileged-mounts)) {
		Write-Verbose "local.privileged-mounts=$(multipass get local.privileged-mounts) is being changed"
		multipass set local.privileged-mounts=true
		Write-Verbose "Successfully changed: local.privileged-mounts=$(multipass get local.privileged-mounts)"
	}

	$params = @(
		$Source,
		"$Name`:$Target"
	)
	multipass mount @params
}

<#
.NOTES
	Dependencies: Multipass
#>
function Dismount-DmpHostDirectory {
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string]
		$Name = $DEFAULT_INSTANCE_NAME,

		[Parameter(Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string]
		$Target = ($env:USERPROFILE | ToDmpMountTargetPath)
	)

	multipass unmount "$Name`:$Target"
}

<#
.EXAMPLE
	# mount host's current directory and create volume for it
	New-DmpHostMountVolume -Confirm
.NOTES
	Dependencies: Docker CLI
#>
function New-DmpHostMountVolume {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[string]
		$Path = (Get-Location),

		[string]
		$Name = (Split-Path $Path -Leaf)
	)

	$dst = "/mnt/HostMountVolume/$Name"
	if ($PSCmdlet.ShouldProcess($Path, "Create Docker volume: $Name")) {
		multipass mount $Path DockerMultipass:$dst
		docker volume create --driver local --opt device=$dst --opt type=none --opt o=bind $Name
	}
}

<#
.NOTES
	Dependencies: Docker CLI
#>
function Get-DmpContext {
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Name = $DEFAULT_INSTANCE_NAME
	)

	docker context inspect @Name | ConvertFrom-Json
}

<#
.NOTES
	Dependencies: Docker CLI
#>
function New-DmpContext {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Name = $DEFAULT_INSTANCE_NAME
	)

	foreach ($n in $Name) {
		if ($PSCmdlet.ShouldProcess($n, 'Create Docker context')) {
			$params = @(
				$n
				'--docker', "host=ssh://ubuntu@$n.mshome.net"
				'--description', 'Created by DockerMultipass'
			)
			docker context create @params
		}
	}
}

<#
.NOTES
	Dependencies: Docker CLI
#>
function Remove-DmpContext {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]
		$Name = $DEFAULT_INSTANCE_NAME
	)

	if ($PSCmdlet.ShouldProcess($Name, 'Remove Docker contexts')) {
		docker context rm @Name
	}
}

function Test-local.privileged-mounts {
	$value = multipass get local.privileged-mounts
	if ($value -in ('on', 'yes', '1', 'true')) {
		$true
	} elseif ($value -in ('off', 'no', '0', 'false')) {
		$false
	} else {
		throw "Invalid configuration: local.privileged-mounts=$value"
	}
}

<#
.SYNOPSIS
	Convert path to '/mnt/*'.
.EXAMPLE
	'C:\User\Me' | ToDmpMountTargetPath
	/mnt/c/User/Me
.NOTES
	For non-existing paths, [System.IO.Path] is used in the filter instead of "path-related" cmdlets: Get-Item, Resolve-Path, etc.
#>
filter ToDmpMountTargetPath {
	$fullPath = [System.IO.Path]::GetFullPath($_)

	$linuxPath = if ($IsLinux -or $IsMacOS) {
		$fullPath
	} else {
		$fullPath `
			-replace [regex]::Escape($([System.IO.Path]::DirectorySeparatorChar)), '/' `
			-replace "^([A-Z])$([System.IO.Path]::VolumeSeparatorChar)", { '/' + $_[0].Groups[1].Value.ToLower() }
	}

	"/mnt$linuxPath"
}

Set-Alias etdmp Enter-DmpInstance
Set-Alias gdmp Get-DmpInstance
Set-Alias ndmp New-DmpInstance
Set-Alias rdmp Remove-DmpInstance
Set-Alias rtdmp Restart-DmpInstance
Set-Alias sadmp Start-DmpInstance; Set-Alias spdmp Stop-DmpInstance
Set-Alias udmp Use-DmpInstance

Set-Alias mtdmphost Mount-DmpHostDirectory; Set-Alias dmdmphost Dismount-DmpHostDirectory
