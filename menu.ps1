Import-Module "C:\Program Files\WindowsPowerShell\Modules\project-scripting\algemeenBOAY.psm1"

do {
    Clear-Host
    Write-Host "Welkom dit is mijn project voor scripting"
    Write-Host ""
    Write-Host "1) Basisconfiguratie server"
    Write-Host "2) Basisconfiguratie workstation"
    Write-Host "3) Domain configuratie"
    Write-Host "4) Stoppen"
    Write-Host ""

    [int]$keuze = Read-Host "Wat is je keuze"

    switch ($keuze) {
        1 {
            Get-Servernaam
            Read-Host "Druk op Enter om verder te gaan"
        }

        2 {
            Get-Workstationnaam
            Read-Host "Druk op Enter om verder te gaan"
        }

        3 {
            Write-Host "Domain configuratie"
            Read-Host "Druk op Enter om verder te gaan"
        }

        4 {
            Clear-Host
            Write-Host "Programma stopt"
        }

        Default {
            Write-Host "Ongeldige keuze, kies 1, 2, 3 of 4"
            Read-Host "Druk op Enter om verder te gaan"
        }
    }

} while ($keuze -ne 4)
