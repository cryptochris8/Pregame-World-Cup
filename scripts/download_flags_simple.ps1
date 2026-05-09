# FIFA World Cup 2026 Flag Download Script (PowerShell for Windows)
# Downloads all 48 national team flags from flagcdn.com

Write-Host "FIFA World Cup 2026 Flag Download Script" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Hashtable of FIFA codes mapped to ISO 2-letter codes
$countries = @{
    "usa" = "us"; "mex" = "mx"; "can" = "ca"
    "ger" = "de"; "fra" = "fr"; "eng" = "gb-eng"; "esp" = "es"
    "ned" = "nl"; "por" = "pt"; "bel" = "be"; "ita" = "it"
    "cro" = "hr"; "den" = "dk"; "sui" = "ch"; "pol" = "pl"
    "swe" = "se"; "aut" = "at"; "sco" = "gb-sct"; "wal" = "gb-wls"
    "bra" = "br"; "arg" = "ar"; "uru" = "uy"; "col" = "co"
    "chi" = "cl"; "ecu" = "ec"; "crc" = "cr"; "jam" = "jm"
    "pan" = "pa"; "hon" = "hn"; "jpn" = "jp"; "kor" = "kr"
    "irn" = "ir"; "aus" = "au"; "ksa" = "sa"; "qat" = "qa"
    "irq" = "iq"; "uae" = "ae"; "mar" = "ma"; "sen" = "sn"
    "nga" = "ng"; "egy" = "eg"; "tun" = "tn"; "cmr" = "cm"
    "gha" = "gh"; "alg" = "dz"; "civ" = "ci"; "nzl" = "nz"
}

# Create output directory
$outputDir = "assets\worldcup\flags"
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

Write-Host "Output directory: $outputDir" -ForegroundColor Yellow
Write-Host "Total teams to download: $($countries.Count)" -ForegroundColor Yellow
Write-Host ""

$count = 0
$total = $countries.Count
$success = 0

foreach ($entry in $countries.GetEnumerator()) {
    $fifaCode = $entry.Key
    $isoCode = $entry.Value
    $count++

    Write-Host "[$count/$total] Downloading $fifaCode ($isoCode)..." -NoNewline

    $url = "https://flagcdn.com/512x384/$isoCode.png"
    $outputPath = "$outputDir\$fifaCode.png"

    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $outputPath)

        if (Test-Path $outputPath) {
            $fileSize = (Get-Item $outputPath).Length
            if ($fileSize -gt 1000) {
                Write-Host " SUCCESS ($fileSize bytes)" -ForegroundColor Green
                $success++
            } else {
                Write-Host " WARNING: File too small ($fileSize bytes)" -ForegroundColor Yellow
            }
        }
    }
    catch {
        Write-Host " FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }

    Start-Sleep -Milliseconds 300
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Flag download complete!" -ForegroundColor Green
Write-Host "Successfully downloaded: $success/$total flags" -ForegroundColor Yellow
Write-Host "Location: $outputDir" -ForegroundColor Yellow
Write-Host ""
