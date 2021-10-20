# DockerMultipass (DMP)

PowerShell module to use [Multipass](https://multipass.run/) like [Docker Machine](https://github.com/docker/machine).

By using this module, you can create DockerMultipass instances, on which Docker is installed.

## Requirements

* [PowerShell](https://github.com/PowerShell/PowerShell/releases) 7 or higher
* [Multipass](https://multipass.run/)
* [Docker CLI](https://github.com/docker/cli) (not required unless you use Docker from outside of your Multipass instances)

## Installation

```powershell
git clone https://github.com/matt9ucci/DockerMultipass.git
Import-Module ./DockerMultipass/DockerMultipass
```

## Usage

Create a default DockerMultipass instance (Name = 'DockerMultipass'):

```powershell
New-DmpInstance
```

Ssh to the default instance:

```powershell
Enter-DmpInstance
```

You are now in the default instance. Try to run some docker commands like this:

```sh
ubuntu@DockerMultipass:~$ docker version
```

If you use Docker from outside of the default instance, exit it and run `Use-DmpInstance`.
It will create a Docker context (Name = 'DockerMultipass') and set it as the current Docker context.
If you are not familiar with Docker context, see the [official doc](https://docs.docker.com/engine/context/working-with-contexts/).

## Cmdlets and aliases

### Manage

Cmdlet | Alias
-- | --
New-DmpInstance | ndmp
Remove-DmpInstance | rdmp
Start-DmpInstance | sadmp
Stop-DmpInstance | spdmp
Restart-DmpInstance | rtdmp

### Use

Cmdlet | Alias
-- | --
Get-DmpInstance | gdmp
Enter-DmpInstance | etdmp
Use-DmpInstance | udmp

### Mount

Cmdlet | Alias
-- | --
Mount-DmpHostDirectory | mtdmphost
Dismount-DmpHostDirectory | dmdmphost

### Docker context

Cmdlet | Alias
-- | --
Get-DmpContext | -
New-DmpContext | -
Remove-DmpContext | -
