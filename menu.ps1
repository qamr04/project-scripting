function logboek {
#synopsis dit schrijf een actie naar het installatie logbestand
param ([string] $bericht)
$logmap = "C:\scripting\logs"
$logfile = "C:\scripting\logs\InstallatieLogBOAY.txt"
if (!(Test-Path $logmap)){
#zoekt eerst uit of de map bestaat zo niet maakt die de juiste map aan
New-Item -Path $logmap -ItemType Directory
}
$datum = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
Add-Content -Path "$logMap\InstallatieLogBOAY.txt" -Value "$datum - $bericht"
}

function get-servernaam {
Clear-Host
Write-Host "Welkom de basisconfiguratie begint nu."
Write-Host "Server configuratie gaat van start" 
Start-Sleep -Seconds 2

$server_naam = Read-Host "Geef een naam in"
Rename-Computer $server_naam -WhatIf
Start-Sleep -Seconds 1
Logboek "Servernaam gewijzigd naar $server_naam" 
Restart-Computer -WhatIf
}

function get-workstationnaam{
clear-host
write-host "Workstation confguratie gaat nu van start"
$WS_naam = Read-Host "Geef en naam in voor je workstation"
Rename-Computer $WS_naam -WhatIf
Start-Sleep -Seconds 1
Logboek "Workstation naam gewijzigd naar $WS_naam" 
Restart-Computer -WhatIf
}
