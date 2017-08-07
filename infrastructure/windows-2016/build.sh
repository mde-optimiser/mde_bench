#!/bin/bash
vagrant up --provider virtualbox

ruby -e '
require "winrm"
opts = {
  transport: :plaintext,
  endpoint: "http://127.0.0.1:55985/wsman",
  user: "vagrant",
  password: "vagrant"
}
cmd = "
  echo \"Search Windows Updates\"
  $sess = New-CimInstance -Namespace root/Microsoft/Windows/WindowsUpdate -ClassName MSFT_WUOperationsSession
  echo \"Apply Windows Updates - This takes some time... (15 Minutes)\"
  Invoke-CimMethod -InputObject $sess -MethodName ApplyApplicableUpdates
  echo \"Restart Machine\"
  Restart-Computer -Force
"
WinRM::Connection.new(opts).shell(:powershell).run(cmd) do |stdout, stderr|
  STDOUT.print stdout
  STDERR.print stderr
end'


echo "Sleep for 10 seconds to be sure computer is restarted"
sleep 10

ruby -e '
require "winrm"
opts = {
  transport: :plaintext,
  endpoint: "http://127.0.0.1:55985/wsman",
  user: "vagrant",
  password: "vagrant"
}
cmd = "
echo \"Install Docker Depedency\"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
echo \"Install Docker Repo\"
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
#Do i need this?
#echo \"Set-PSRepository trusted ...\"
#Set-PSRepository -InstallationPolicy Trusted -Name PSGallery
Import-Module -Name DockerMsftProvider -Verbose -Force
Import-Packageprovider -Name DockerMsftProvider -Force
echo Install Docker Package
Install-Package -Name docker -ProviderName DockerMsftProvider -Verbose -Force
Restart-Computer -Force
"
WinRM::Connection.new(opts).shell(:powershell).run(cmd) do |stdout, stderr|
  STDOUT.print stdout
  STDERR.print stderr
end'

ruby -e '
require "winrm"
opts = {
  transport: :plaintext,
  endpoint: "http://127.0.0.1:55985/wsman",
  user: "vagrant",
  password: "vagrant"
}
cmd = "
echo Bind Docker on a port and allow outside connection
New-NetFirewallRule -DisplayName \"Docker Insecure Port 2375\" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 2375
Stop-Service docker
dockerd --unregister-service
dockerd -H npipe:// -H 0.0.0.0:2375 --register-service
Start-Service docker
echo Prepull nanoserver image
docker pull microsoft/nanoserver
echo Stop Computer
Stop-Computer -Force
"
WinRM::Connection.new(opts).shell(:powershell).run(cmd) do |stdout, stderr|
  STDOUT.print stdout
  STDERR.print stderr
end'

sleep 5
echo "Package nanoserver_docker box"
vagrant package --output nanoserver_docker_virtualbox.box --vagrantfile vagrantfile-package
vagrant destroy -f