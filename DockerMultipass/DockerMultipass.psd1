@{
	RootModule           = 'DockerMultipass.psm1'
	ModuleVersion        = '0.0.1'
	CompatiblePSEditions = 'Core'
	GUID                 = '17d9cf36-1440-43e4-87ad-b42901bbb8e2'
	Author               = 'Masatoshi Higuchi'
	Copyright            = '(c) 2021 Masatoshi Higuchi. All rights reserved.'

	FunctionsToExport    = @(
		@(
			'Enter-DmpInstance'
			'Get-DmpInstance'
			'New-DmpInstance'
			'Remove-DmpInstance'
			'Restart-DmpInstance'
			'Start-DmpInstance', 'Stop-DmpInstance'
			'Use-DmpInstance'
		)
		@(
			'Mount-DmpHostDirectory', 'Dismount-DmpHostDirectory'
			'New-DmpHostMountVolume'
		)
		@(
			'Get-DmpContext'
			'New-DmpContext'
			'Remove-DmpContext'
		)
	)
	CmdletsToExport      = @()
	VariablesToExport    = @()
	AliasesToExport      = @(
		@(
			'etdmp'
			'gdmp'
			'ndmp'
			'rdmp'
			'rtdmp'
			'sadmp', 'spdmp'
			'udmp'
		)
		@(
			'mtdmphost', 'dmdmphost'
		)
	)

	PrivateData          = @{
		PSData = @{
			LicenseUri   = 'https://github.com/matt9ucci/DockerMultipass/blob/master/LICENSE'
			ProjectUri   = 'https://github.com/matt9ucci/DockerMultipass'
			ReleaseNotes = 'Initial release'
		}
	}
}

