# Install chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
# Enable global configuration
choco feature enable -n allowGlobalConfirmation

Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -Force

# Install utilities
choco install ruby
#choco install docker
choco install docker-compose --version 1.7.0
#choco install docker-machine
choco install javaruntime
choco install git

# Remove net nat
Get-NetNat | Remove-NetNat