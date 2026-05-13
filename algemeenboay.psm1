function logboek {
    # synopsis: dit schrijft een actie naar het installatie logbestand
    param ([string] $bericht)
    $projectmap = Split-Path $PSScriptRoot -Parent
    $logmap = Join-Path $projectmap "logs"
    $datum = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
    $logfile = Join-Path $logmap "InstallatieLogBOAY.txt"
    Add-Content -Path $logfile -Value "$datum - $bericht"
}

function get-servernaam {
    Write-Host "Welkom de basisconfiguratie begint nu."
    Write-Host "Server configuratie gaat van start" 

    $pc_settings = lees-computersettings
    if ($null -eq $pc_settings){
        Write-Host "configuratie gestopt omdat Computer.settings.xml niet gevonden is"
        return
    }

    $server_naam = $pc_settings.Settings.name
    Write-Host "Servernaam in XML is: $server_naam"
    $keuze = Read-Host "Wil je deze naam veranderen? j/n"
    if($keuze -eq "j"){
        $server_naam = Read-Host "Geef de nieuwe servernaam in"
        Write-Host "Nieuwe servernaam word: $server_naam"
        logboek "Gebruiker koos nieuwe servernaam: $server_naam"
    } else {
        Write-Host "naam uit XML wordt gebruikt: $server_naam"
        logboek "Servernaam uit XML wordt gebruikt: $server_naam"  
    }

    Rename-Computer $server_naam 
    logboek "Servernaam gewijzigd naar $server_naam"
    Restart-Computer 
}

function get-workstationnaam {
    Write-Host "Workstation configuratie gaat nu van start"
    $WS_naam = Read-Host "Geef een naam in voor je workstation"
    Rename-Computer $WS_naam 
    logboek "Workstation naam gewijzigd naar $WS_naam" 
    Restart-Computer 
}

function lees-computersettings {
    $projectMap = Split-Path $PSScriptRoot
    $settingsbestand = Join-Path $projectMap "settings\Computer.Settings.xml"

    if (!(Test-Path $settingsbestand)){
        Write-Host "Computer.Settings.xml niet gevonden"
        logboek "Computer.Settings.xml niet gevonden"
    } else {
        [xml]$computerSettings = Get-Content $settingsbestand -Raw
        Write-Host "Computer.Settings.xml werd ingelezen"
        logboek "Computer.Settings.xml werd ingelezen"
        return $computerSettings
    }
}

function Computersettings {
    Write-Host "Server configuratie begint"
    $pc_settings 
}

function configuratie-Netwerk {
    param([xml]$pc_settings)

    foreach ($adapter in $pc_settings.Settings.networksettings.networkadapter) {
        $naam = $adapter.name
        $ip = $adapter.ip
        $prefix = $adapter.prefixlength
        $gateway = $adapter.gateway
        $dns = $adapter.dns

        # Skip adapters zonder IP
        if ([string]::IsNullOrEmpty($ip)) { continue }

        # Stel statisch IP en gateway in
        New-NetIPAddress -InterfaceAlias $naam -IPAddress $ip -PrefixLength $prefix -DefaultGateway $gateway

        # Stel DNS in
        Set-DnsClientServerAddress -InterfaceAlias $naam -ServerAddresses $dns

        logboek "Adapter $naam statisch ingesteld: IP $ip, Gateway $gateway, DNS $dns"
    }
}

function configureer-computer {
    param ([string]$type = "Server")

    Write-Host "$type configuratie gaat nu van start"
    $pc_settings = lees-computersettings
    if ($null -eq $pc_settings) { return }

    $comp_naam = $pc_settings.Settings.name
    $keuze = Read-Host "Wil je de $type naam veranderen? j/n"
    if ($keuze -eq "j") {
        $comp_naam = Read-Host "Geef de nieuwe $type naam in"
        logboek "Gebruiker koos nieuwe $type naam: $comp_naam"
    } else {
        logboek "$type naam uit XML wordt gebruikt: $comp_naam"
    }

    Rename-Computer -NewName $comp_naam 
    logboek "$type naam gewijzigd naar $comp_naam"

    configuratie-netwerk -pc_settings $pc_settings

    # Stel RunOnce in zodat het script na reboot terugstart
$scriptPad = $MyInvocation.MyCommand.Path
$runOnceKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
$runOnceName = "VoerScriptUit"
Set-ItemProperty -Path $runOnceKey -Name $runOnceName -Value "powershell.exe -ExecutionPolicy Bypass -File `"$scriptPad`"" -Force
logboek "RunOnce key ingesteld voor automatische herstart"

# Tweede key: status flag voor project, bijvoorbeeld InitComplete
$secondKeyPath = "HKLM:\SOFTWARE\MijnProject"
$secondKeyName = "InitComplete"
$secondKeyValue = 1
if (-not (Test-Path $secondKeyPath)) { New-Item -Path $secondKeyPath -Force | Out-Null }
Set-ItemProperty -Path $secondKeyPath -Name $secondKeyName -Value $secondKeyValue
logboek "Tweede registry key ingesteld: $secondKeyPath\$secondKeyName = $secondKeyValue"

# Herstart
Restart-Computer -Force
}

# Zorg dat deze functies beschikbaar zijn buiten de module
Export-ModuleMember -Function configureer-computer, configuratie-netwerk, logboek, lees-computersettings, get-servernaam, get-workstationnaam, Computersettings
