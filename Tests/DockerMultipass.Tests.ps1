#Requires -Module @{ ModuleName = 'Pester'; ModuleVersion = '5.1' }

BeforeAll {
	$module = Import-Module $PSScriptRoot/../DockerMultipass -Force -PassThru
	$DEFAULT_INSTANCE_NAME = $module.Invoke({ $DEFAULT_INSTANCE_NAME })
}

Describe 'Get-DmpInstance' {
	It 'gets a default instance if it exists"' {
		$result = Get-DmpInstance
		$result.Name | Should -BeExactly $DEFAULT_INSTANCE_NAME
	}
}
