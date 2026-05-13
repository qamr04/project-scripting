function logboek {
    # synopsis: dit schrijft een actie naar het installatie logbestand
    param ([string] $bericht)
    # Split-Path met -Parent haalt de bovenliggende map op.
    # In dit project gaan we zo van de map "modules" terug naar de hoofdmap "scripting".
    $projectmap = Split-Path $PSScriptRoot -Parent
    $logmap = Join-Path $projectmap "logs"
    $datum = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
    $logfile = Join-Path $logmap "InstallatieLogBOAY.txt"
    Add-Content -Path $logfile -Value "$datum - $bericht"
}

function get-servernaam {
    Clear-Host
    Write-Host "Welkom de basisconfiguratie begint nu."
    Write-Host "Server configuratie gaat van start" 

    $pc_settings = lees-computersettings
    if ($null -eq $pc_settings){
        write-host "configuratie gestop omdat Computer.settings.xml niet gevonden is"
        return
    }

    $server_naam = $pc_settings.Settings.name
    Write-Host "Servernaam in XML is: $server_naam"
    $keuze = Read-Host "Wil je deze naam veranderen? j/n"
    if($keuze -eq "j"){
        $server_naam = Read-host "Geef de nieuwe servernaam in"
        write-host "Nieuwe servernaam word: $server_naam"
        logboek "Gebruiker koos nieuwe servernaam: $server_naam"
    }
    else{
        Write-Host "naam uit XML word gebruikt: $server_naam"
        logboek "Servernaam uit XML wordt gebruikt: $server_naam"  
    }

    Rename-Computer $server_naam -WhatIf
    Logboek "Servernaam gewijzigd naar $server_naam"
    Restart-Computer -WhatIf
}

function get-workstationnaam {
    Clear-Host
    Write-Host "Workstation confguratie gaat nu van start"

    $WS_naam = Read-Host "Geef een naam in voor je workstation"
    Rename-Computer $WS_naam -WhatIf
    Logboek "Workstation naam gewijzigd naar $WS_naam" 
    Restart-Computer -WhatIf
}

function lees-computersettings {
    $projectMap = Split-Path $PSScriptRoot
    $settingsbestand = join-path $projectMap "settings\Computer.Settings.xml"

    if (!(test-path $settingsbestand)){
        Write-Host "Computer.Settings.xml niet gevonden"
        logboek "Computer.Settings.xml niet gevonden"
    }
    else {
        [xml]$computerSettings = Get-Content $settingsbestand -Raw
        Write-Host "Computer.Settings.xml werd ingelezen"
        logboek "Computer.Settings.xml werd ingelezen"
        return $computerSettings
    }
}

function Computersettings {
    # leest het computer.settings.xml bestand in 
    Clear-Host
    Write-Host "Server configuratie begint"
    $pc_settings 
}
function Configureer-Netwerk {
    param(
        [xml]$pc_settings,
        [string]$type  # "Server" of "Workstation"
    )

    foreach ($adapter in $pc_settings.Settings.networksettings.networkadapter) {
        if ($adapter.role -ne $type) { continue }  # alleen adapters voor deze rol

        if ([string]::IsNullOrEmpty($adapter.ip)) { continue }  # skip lege IP's

        New-NetIPAddress -InterfaceAlias $adapter.name -IPAddress $adapter.ip -PrefixLength $adapter.prefixlength -DefaultGateway $adapter.gateway
        Set-DnsClientServerAddress -InterfaceAlias $adapter.name -ServerAddresses $adapter.dns

        logboek "Adapter $($adapter.name) geconfigureerd voor $type IP $($adapter.ip), Gateway $($adapter.gateway), DNS $($adapter.dns)"
    }
}

function configureer-computer {
    param ([string]$type = "Server")

    Clear-Host
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

    Rename-Computer -NewName $comp_naam -WhatIf
    logboek "$type naam gewijzigd naar $comp_naam"

    # Netwerk configureren
    configuratie-netwerk -pc_settings $pc_settings

    #runonce regkey
    $scriptPad = $MyInvocation.MyCommand.Path
    $regKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    $regNaam = "VoerScriptUit"
    Set-ItemProperty -Path $regKey -Name $regNaam -Value "powershell.exe -ExecutionPolicy Bypass -File `"$scriptPad`""
    logboek "Script ingesteld om na reboot automatisch opnieuw te starten"

    Restart-Computer -WhatIf
}
