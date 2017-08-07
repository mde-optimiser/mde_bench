# Install chocolatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
# Enable global configuration
choco feature enable -n allowGlobalConfirmation

Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -Force

# Install utilities
choco install ruby
choco install docker-compose
choco install javaruntime
choco install git

# Remove net nat to allow docker to create containers
#Get-NetNat | Remove-NetNat

# Hack for docker nat
net stop hns;
Remove-Netnat;
net start hns;