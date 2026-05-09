# FIFA World Cup 2026 Flag Download Script (PowerShell for Windows)
# Downloads all 48 national team flags from flagcdn.com
#
# Usage: .\scripts\download_flags.ps1

Write-Host "🏴 FIFA World Cup 2026 Flag Download Script" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# Hashtable of FIFA codes mapped to ISO 2-letter codes
$countries = @{
    # Host Nations
    "usa" = "us"
    "mex" = "mx"
    "can" = "ca"

    # UEFA (Europe)
    "ger" = "de"
    "fra" = "fr"
    "eng" = "gb-eng"
    "esp" = "es"
    "ned" = "nl"
    "por" = "pt"
    "bel" = "be"
    "ita" = "it"
    "cro" = "hr"
    "den" = "dk"
    "sui" = "ch"
    "pol" = "pl"
    "swe" = "se"
    "aut" = "at"
    "sco" = "gb-sct"
    "wal" = "gb-wls"

    # CONMEBOL (South America)
    "bra" = "br"
    "arg" = "ar"
    "uru" = "uy"
    "col" = "co"
    "chi" = "cl"
    "ecu" = "ec"

    # CONCACAF
    "crc" = "cr"
    "jam" = "jm"
    "pan" = "pa"
    "hon" = "hn"

    # AFC (Asia)
    "jpn" = "jp"
    "kor" = "kr"
    "irn" = "ir"
    "aus" = "au"
    "ksa" = "sa"
    "qat" = "qa"
    "irq" = "iq"
    "uae" = "ae"

    # CAF (Africa)
    "mar" = "ma"
    "sen" = "sn"
    "nga" = "ng"
    "egy" = "eg"
    "tun" = "tn"
    "cmr" = "cm"
    "gha" = "gh"
    "alg" = "dz"
    "civ" = "ci"

    # OFC (Oceania)
    "nzl" = "nz"
}

# Create output directory
$outputDir = "assets\worldcup\flags"
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

Write-Host "📁 Output directory: $outputDir" -ForegroundColor Yellow
Write-Host "🌍 Total teams to download: $($countries.Count)" -ForegroundColor Yellow
Write-Host ""

# Counter for progress
$count = 0
$total = $countries.Count

# Download each flag
foreach ($entry in $countries.GetEnumerator()) {
    $fifaCode = $entry.Key
    $isoCode = $entry.Value
    $count++

    Write-Host "[$count/$total] Downloading $fifaCode ($isoCode)..." -ForegroundColor White

    $url = "https://flagcdn.com/512x384/$isoCode.png"
    $outputPath = "$outputDir\$fifaCode.png"

    try {
        # Download using WebClient
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $outputPath)

        # Check file size
        if (Test-Path $outputPath) {
            $fileSize = (Get-Item $outputPath).Length
            if ($fileSize -gt 1000) {
                Write-Host "   ✅ Success ($fileSize bytes)" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️  Warning: File seems too small ($fileSize bytes)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "   ❌ Failed to download" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Small delay to be respectful to the API
    Start-Sleep -Milliseconds 300
}

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "✅ Flag download complete!" -ForegroundColor Green
Write-Host "📊 Downloaded: $total flags" -ForegroundColor Yellow
Write-Host "📁 Location: $outputDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Verify all flags downloaded correctly" -ForegroundColor White
Write-Host "2. Update pubspec.yaml to include: assets/worldcup/flags/" -ForegroundColor White
Write-Host "3. Test loading flags in Flutter app" -ForegroundColor White
Write-Host ""
