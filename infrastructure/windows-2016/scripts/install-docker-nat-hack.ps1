# Hack for docker nat
net stop hns;
Remove-Netnat;
net start hns;