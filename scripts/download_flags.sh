#!/bin/bash

# FIFA World Cup 2026 Flag Download Script
# Downloads all 48 national team flags from flagcdn.com
#
# Usage: ./scripts/download_flags.sh

echo "🏴 FIFA World Cup 2026 Flag Download Script"
echo "==========================================="
echo ""

# Array of FIFA codes mapped to ISO 2-letter codes
declare -A countries=(
  # Host Nations
  ["usa"]="us"
  ["mex"]="mx"
  ["can"]="ca"

  # UEFA (Europe) - Expected qualifiers
  ["ger"]="de"
  ["fra"]="fr"
  ["eng"]="gb-eng"
  ["esp"]="es"
  ["ned"]="nl"
  ["por"]="pt"
  ["bel"]="be"
  ["ita"]="it"
  ["cro"]="hr"
  ["den"]="dk"
  ["sui"]="ch"
  ["pol"]="pl"
  ["swe"]="se"
  ["aut"]="at"
  ["sco"]="gb-sct"
  ["wal"]="gb-wls"

  # CONMEBOL (South America)
  ["bra"]="br"
  ["arg"]="ar"
  ["uru"]="uy"
  ["col"]="co"
  ["chi"]="cl"
  ["ecu"]="ec"

  # CONCACAF (North/Central America & Caribbean)
  ["crc"]="cr"
  ["jam"]="jm"
  ["pan"]="pa"
  ["hon"]="hn"

  # AFC (Asia)
  ["jpn"]="jp"
  ["kor"]="kr"
  ["irn"]="ir"
  ["aus"]="au"
  ["ksa"]="sa"
  ["qat"]="qa"
  ["irq"]="iq"
  ["uae"]="ae"

  # CAF (Africa)
  ["mar"]="ma"
  ["sen"]="sn"
  ["nga"]="ng"
  ["egy"]="eg"
  ["tun"]="tn"
  ["cmr"]="cm"
  ["gha"]="gh"
  ["alg"]="dz"
  ["civ"]="ci"

  # OFC (Oceania)
  ["nzl"]="nz"
)

# Create output directory
OUTPUT_DIR="assets/worldcup/flags"
mkdir -p "$OUTPUT_DIR"

echo "📁 Output directory: $OUTPUT_DIR"
echo "🌍 Total teams to download: ${#countries[@]}"
echo ""

# Counter for progress
count=0
total=${#countries[@]}

# Download each flag
for fifa_code in "${!countries[@]}"; do
  iso_code="${countries[$fifa_code]}"
  count=$((count + 1))

  echo "[$count/$total] Downloading $fifa_code ($iso_code)..."

  # Download 512x384 PNG from flagcdn.com (free API)
  curl -s -o "$OUTPUT_DIR/${fifa_code}.png" \
    "https://flagcdn.com/512x384/${iso_code}.png"

  # Check if download was successful
  if [ -f "$OUTPUT_DIR/${fifa_code}.png" ]; then
    file_size=$(stat -f%z "$OUTPUT_DIR/${fifa_code}.png" 2>/dev/null || stat -c%s "$OUTPUT_DIR/${fifa_code}.png" 2>/dev/null)
    if [ "$file_size" -gt 1000 ]; then
      echo "   ✅ Success ($file_size bytes)"
    else
      echo "   ⚠️  Warning: File seems too small ($file_size bytes)"
    fi
  else
    echo "   ❌ Failed to download"
  fi

  # Small delay to be respectful to the API
  sleep 0.3
done

echo ""
echo "==========================================="
echo "✅ Flag download complete!"
echo "📊 Downloaded: $total flags"
echo "📁 Location: $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "1. Verify all flags downloaded correctly"
echo "2. Update pubspec.yaml to include: assets/worldcup/flags/"
echo "3. Test loading flags in Flutter app"
echo ""
