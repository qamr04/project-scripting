do{
    clear-host
    write-host "Welkom dit is mijn project voor scripting"
    write-host "Dit is de menu kies hier uit
    1) Basisconfiguratie
    2) Domain configuratie
    3) Stoppen"
    [int] $keuze = read-host "Wat is je keuze"
    switch ($keuze) {    
            1 { Write-Host "dingus"}
            2 { Write-Host "binusds"}
            3 { 
                Clear-Host
                write-host "Programma stopt" 
            }
        Default {
            Write-Host "Ongeldige keuze, kies 1,2 of 3"
            Read-Host "Geef een keuze in"
        }
    }
}

while ($keuze -ne 3)

