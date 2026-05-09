# World Cup 2026 Asset Collection Guide

**Status**: 🔄 In Progress
**Priority**: HIGH
**Deadline**: Before June 2026

---

## Overview

This guide covers collecting all visual assets needed for the Pregame World Cup 2026 app.

### Asset Categories
1. **National Team Flags** - 48 teams
2. **Stadium Images** - 16 venues
3. **World Cup Branding** - FIFA logos, tournament branding
4. **Miscellaneous** - Icons, badges, etc.

---

## 1. National Team Flags (48 Teams)

### FIFA World Cup 2026 Qualified Teams

**Note:** As of December 2025, not all 48 teams have been confirmed. The list below includes the 3 host nations (auto-qualified) and expected qualifiers based on FIFA rankings.

### Host Nations (Auto-Qualified) ✅
| FIFA Code | Country | Confederation | Flag File |
|-----------|---------|---------------|-----------|
| USA | United States | CONCACAF | `usa.png` |
| MEX | Mexico | CONCACAF | `mex.png` |
| CAN | Canada | CONCACAF | `can.png` |

### UEFA (Europe) - Expected ~16 Teams
| FIFA Code | Country | Flag File | Status |
|-----------|---------|-----------|--------|
| GER | Germany | `ger.png` | Expected |
| FRA | France | `fra.png` | Expected |
| ENG | England | `eng.png` | Expected |
| ESP | Spain | `esp.png` | Expected |
| NED | Netherlands | `ned.png` | Expected |
| POR | Portugal | `por.png` | Expected |
| BEL | Belgium | `bel.png` | Expected |
| ITA | Italy | `ita.png` | Expected |
| CRO | Croatia | `cro.png` | Expected |
| DEN | Denmark | `den.png` | Expected |
| SUI | Switzerland | `sui.png` | Expected |
| POL | Poland | `pol.png` | Expected |
| SWE | Sweden | `swe.png` | Expected |
| AUT | Austria | `aut.png` | Expected |
| SCO | Scotland | `sco.png` | Expected |
| WAL | Wales | `wal.png` | Expected |

### CONMEBOL (South America) - Expected ~6 Teams
| FIFA Code | Country | Flag File | Status |
|-----------|---------|-----------|--------|
| BRA | Brazil | `bra.png` | Expected |
| ARG | Argentina | `arg.png` | Expected |
| URU | Uruguay | `uru.png` | Expected |
| COL | Colombia | `col.png` | Expected |
| CHI | Chile | `chi.png` | Expected |
| ECU | Ecuador | `ecu.png` | Expected |

### CONCACAF (North/Central America) - Expected ~6 Teams
| FIFA Code | Country | Flag File | Status |
|-----------|---------|-----------|--------|
| CRC | Costa Rica | `crc.png` | Expected |
| JAM | Jamaica | `jam.png` | Expected |
| PAN | Panama | `pan.png` | Expected |
| HON | Honduras | `hon.png` | Expected |

### AFC (Asia) - Expected ~8 Teams
| FIFA Code | Country | Flag File | Status |
|-----------|---------|-----------|--------|
| JPN | Japan | `jpn.png` | Expected |
| KOR | South Korea | `kor.png` | Expected |
| IRN | Iran | `irn.png` | Expected |
| AUS | Australia | `aus.png` | Expected |
| KSA | Saudi Arabia | `ksa.png` | Expected |
| QAT | Qatar | `qat.png` | Expected |
| IRQ | Iraq | `irq.png` | Expected |
| UAE | United Arab Emirates | `uae.png` | Expected |

### CAF (Africa) - Expected ~9 Teams
| FIFA Code | Country | Flag File | Status |
|-----------|---------|-----------|--------|
| MAR | Morocco | `mar.png` | Expected |
| SEN | Senegal | `sen.png` | Expected |
| NGA | Nigeria | `nga.png` | Expected |
| EGY | Egypt | `egy.png` | Expected |
| TUN | Tunisia | `tun.png` | Expected |
| CMR | Cameroon | `cmr.png` | Expected |
| GHA | Ghana | `gha.png` | Expected |
| ALG | Algeria | `alg.png` | Expected |
| CIV | Ivory Coast | `civ.png` | Expected |

### OFC (Oceania) - Expected ~1 Team
| FIFA Code | Country | Flag File | Status |
|-----------|---------|-----------|--------|
| NZL | New Zealand | `nzl.png` | Expected |

---

## Flag Image Specifications

### Requirements
- **Format**: PNG with transparency
- **Size**: 512x512px (minimum 256x256px)
- **Quality**: High resolution, clean edges
- **Background**: Transparent or white
- **Style**: Official rectangular flag ratio (usually 3:2 or 2:3)
- **Naming**: Lowercase FIFA 3-letter code (e.g., `usa.png`, `ger.png`)

### Recommended Sources

#### Option 1: Flagpedia (Free, High Quality)
**URL**: https://flagpedia.net/
- Format: SVG (convertible to PNG)
- License: Free for commercial use
- Quality: Official flag designs

**Download Instructions:**
1. Visit https://flagpedia.net/
2. Search for country name
3. Download SVG version
4. Convert to 512x512 PNG using tool like Inkscape or online converter

#### Option 2: Country Flags API (Automated)
**URL**: https://flagcdn.com/
- Direct PNG downloads
- Multiple sizes available
- Usage: `https://flagcdn.com/256x192/{country-code}.png`

**Example:**
```
USA: https://flagcdn.com/256x192/us.png
MEX: https://flagcdn.com/256x192/mx.png
GER: https://flagcdn.com/256x192/de.png
```

**Note:** Use ISO 2-letter codes (us, mx, de) not FIFA 3-letter codes

#### Option 3: Wikipedia Commons (Public Domain)
**URL**: https://commons.wikimedia.org/
- Search: "Flag of [Country Name]"
- Filter by SVG
- License: Public domain or CC0

#### Option 4: Flaticon (Paid, Consistent Style)
**URL**: https://www.flaticon.com/packs/countrys-flags
- Consistent design across all flags
- Premium quality
- License: Requires attribution or premium subscription (~$10/month)

### Automated Download Script

Create a script to download all flags automatically:

**File**: `scripts/download_flags.sh`
```bash
#!/bin/bash

# Array of FIFA codes mapped to ISO codes
declare -A countries=(
  ["usa"]="us"
  ["mex"]="mx"
  ["can"]="ca"
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
  ["bra"]="br"
  ["arg"]="ar"
  ["uru"]="uy"
  ["col"]="co"
  ["chi"]="cl"
  ["ecu"]="ec"
  ["crc"]="cr"
  ["jam"]="jm"
  ["pan"]="pa"
  ["hon"]="hn"
  ["jpn"]="jp"
  ["kor"]="kr"
  ["irn"]="ir"
  ["aus"]="au"
  ["ksa"]="sa"
  ["qat"]="qa"
  ["irq"]="iq"
  ["uae"]="ae"
  ["mar"]="ma"
  ["sen"]="sn"
  ["nga"]="ng"
  ["egy"]="eg"
  ["tun"]="tn"
  ["cmr"]="cm"
  ["gha"]="gh"
  ["alg"]="dz"
  ["civ"]="ci"
  ["nzl"]="nz"
)

# Create output directory
mkdir -p assets/worldcup/flags

# Download each flag
for fifa_code in "${!countries[@]}"; do
  iso_code="${countries[$fifa_code]}"
  echo "Downloading flag for $fifa_code ($iso_code)..."

  # Download 512x384 PNG from flagcdn.com
  curl -o "assets/worldcup/flags/${fifa_code}.png" \
    "https://flagcdn.com/512x384/${iso_code}.png"

  # Add small delay to be respectful to the API
  sleep 0.5
done

echo "✅ Downloaded ${#countries[@]} flags!"
```

**Usage:**
```bash
chmod +x scripts/download_flags.sh
./scripts/download_flags.sh
```

---

## 2. Stadium Images (16 Venues)

### United States (11 Stadiums)

| # | Stadium | City | State | Image File | Status |
|---|---------|------|-------|------------|--------|
| 1 | MetLife Stadium | East Rutherford | NJ | `metlife_stadium.jpg` | ⏳ |
| 2 | AT&T Stadium | Arlington | TX | `att_stadium.jpg` | ⏳ |
| 3 | Mercedes-Benz Stadium | Atlanta | GA | `mercedes_benz_atlanta.jpg` | ⏳ |
| 4 | SoFi Stadium | Inglewood | CA | `sofi_stadium.jpg` | ⏳ |
| 5 | Hard Rock Stadium | Miami Gardens | FL | `hard_rock_stadium.jpg` | ⏳ |
| 6 | NRG Stadium | Houston | TX | `nrg_stadium.jpg` | ⏳ |
| 7 | Lincoln Financial Field | Philadelphia | PA | `lincoln_financial_field.jpg` | ⏳ |
| 8 | Lumen Field | Seattle | WA | `lumen_field.jpg` | ⏳ |
| 9 | Levi's Stadium | Santa Clara | CA | `levis_stadium.jpg` | ⏳ |
| 10 | Gillette Stadium | Foxborough | MA | `gillette_stadium.jpg` | ⏳ |
| 11 | GEHA Field at Arrowhead | Kansas City | MO | `arrowhead_stadium.jpg` | ⏳ |

### Mexico (3 Stadiums)

| # | Stadium | City | Image File | Status |
|---|---------|------|------------|--------|
| 12 | Estadio Azteca | Mexico City | `estadio_azteca.jpg` | ⏳ |
| 13 | Estadio Akron | Guadalajara | `estadio_akron.jpg` | ⏳ |
| 14 | Estadio BBVA | Monterrey | `estadio_bbva.jpg` | ⏳ |

### Canada (2 Stadiums)

| # | Stadium | City | Image File | Status |
|---|---------|------|------------|--------|
| 15 | BMO Field | Toronto | `bmo_field.jpg` | ⏳ |
| 16 | BC Place | Vancouver | `bc_place.jpg` | ⏳ |

### Stadium Image Specifications

**Requirements:**
- **Format**: JPG or PNG
- **Size**: 1920x1080px (16:9 aspect ratio)
- **Quality**: High resolution, professional photography
- **View**: Exterior or interior panoramic view
- **Naming**: Lowercase, underscores (e.g., `metlife_stadium.jpg`)

### Recommended Sources

#### Option 1: Official Stadium Websites
Each stadium has official media/press pages with high-res images:
- MetLife Stadium: https://www.metlifestadium.com/
- AT&T Stadium: https://attstadium.com/
- Etc.

**Look for:** "Media", "Press Kit", "Downloads" sections

#### Option 2: Unsplash (Free, High Quality)
**URL**: https://unsplash.com/
- Search: "[Stadium Name]"
- License: Free for commercial use, no attribution required
- Quality: Professional photography

#### Option 3: Wikimedia Commons
**URL**: https://commons.wikimedia.org/
- Search: "[Stadium Name]"
- Filter by high resolution
- License: Usually CC-BY-SA or public domain

#### Option 4: Getty Images / Shutterstock (Paid)
- Professional quality
- Editorial use images available
- Cost: $10-50 per image

#### Option 5: Official FIFA Website
**URL**: https://www.fifa.com/
- Once World Cup 2026 content goes live
- Official tournament imagery
- May require licensing

### Manual Download Checklist

Create a checklist to track downloads:

**File**: `docs/STADIUM_IMAGE_CHECKLIST.md`

```markdown
# Stadium Image Download Checklist

- [ ] MetLife Stadium (NJ) - **FINAL venue**
- [ ] AT&T Stadium (TX) - Semi-final
- [ ] Mercedes-Benz Stadium (GA) - Semi-final
- [ ] SoFi Stadium (CA)
- [ ] Hard Rock Stadium (FL)
- [ ] NRG Stadium (TX)
- [ ] Lincoln Financial Field (PA)
- [ ] Lumen Field (WA)
- [ ] Levi's Stadium (CA)
- [ ] Gillette Stadium (MA)
- [ ] GEHA Field at Arrowhead (MO)
- [ ] Estadio Azteca (Mexico City) - **OPENING match**
- [ ] Estadio Akron (Guadalajara)
- [ ] Estadio BBVA (Monterrey)
- [ ] BMO Field (Toronto)
- [ ] BC Place (Vancouver)
```

---

## 3. World Cup Branding

### FIFA Official Logos

| Asset | Description | File Name | Status |
|-------|-------------|-----------|--------|
| FIFA World Cup 2026 Logo | Official tournament logo | `fifa_wc_2026_logo.png` | ⏳ |
| FIFA Logo | General FIFA logo | `fifa_logo.png` | ⏳ |
| Host Cities Logo | Combined USA/MEX/CAN | `host_cities_logo.png` | ⏳ |

### App Branding

| Asset | Description | File Name | Status |
|-------|-------------|-----------|--------|
| Pregame World Cup Logo | App logo with WC theme | `pregame_wc_logo.png` | ⏳ |
| App Icon | 1024x1024 app icon | `app_icon.png` | ⏳ |
| Splash Screen | Launch screen image | `splash_screen.png` | ⏳ |

### Sources for FIFA Branding

#### Official FIFA Media Resources
**URL**: https://www.fifa.com/legal/media-releases
- Official logos available for media use
- Strict usage guidelines
- May require application for commercial use

**Important:** FIFA logos are heavily trademarked. For commercial apps, you may need:
1. License agreement with FIFA
2. Official partner/sponsor status
3. Or avoid using FIFA logos directly

**Alternative:** Use generic soccer/football imagery instead of FIFA branding

### Recommended Approach for Branding

**Strategy:**
1. **DO NOT** use official FIFA logos without permission
2. **DO** create original Pregame World Cup branding
3. **DO** reference "World Cup 2026" in text (fair use)
4. **DO** use country flags (public domain)
5. **DO** use stadium names and photos (with proper licensing)

---

## 4. Additional Assets

### Icons & UI Elements

| Asset | Description | File Name | Status |
|-------|-------------|-----------|--------|
| Soccer Ball | Generic football icon | `soccer_ball.png` | ⏳ |
| Trophy | World Cup trophy style | `trophy.png` | ⏳ |
| Calendar | Match schedule icon | `calendar.png` | ⏳ |
| Location Pin | Venue marker | `location_pin.png` | ⏳ |
| Group Icon | Group stage icon | `group_icon.png` | ⏳ |
| Bracket Icon | Knockout stage icon | `bracket_icon.png` | ⏳ |

**Sources:**
- Google Material Icons (free)
- Font Awesome (free tier)
- Flaticon (premium with attribution)

---

## Folder Structure

```
assets/
├── worldcup/
│   ├── flags/              # 48 national team flags
│   │   ├── usa.png
│   │   ├── mex.png
│   │   ├── ger.png
│   │   └── ... (45 more)
│   │
│   ├── stadiums/           # 16 stadium images
│   │   ├── metlife_stadium.jpg
│   │   ├── att_stadium.jpg
│   │   └── ... (14 more)
│   │
│   ├── branding/           # FIFA & app branding
│   │   ├── fifa_wc_2026_logo.png
│   │   ├── pregame_wc_logo.png
│   │   └── app_icon.png
│   │
│   └── icons/              # UI icons
│       ├── soccer_ball.png
│       ├── trophy.png
│       └── ...
│
└── logos/                  # Legacy CFB logos (keep for reference)
    └── pregame_logo.png
```

---

## Update pubspec.yaml

Add World Cup assets to Flutter configuration:

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/logos/
    - assets/worldcup/flags/
    - assets/worldcup/stadiums/
    - assets/worldcup/branding/
    - assets/worldcup/icons/
```

---

## Legal Considerations

### ⚠️ Important Copyright & Trademark Notes

1. **National Flags**: Generally public domain, free to use
2. **Stadium Photos**:
   - Check license (CC-BY, public domain, or purchase)
   - Some may require attribution
3. **FIFA Logos**:
   - **HEAVILY TRADEMARKED**
   - Requires official licensing for commercial use
   - Safer to avoid or get explicit permission
4. **Team Crests/Badges**:
   - Owned by national football associations
   - May require licensing
   - Flags are safer alternative

### Recommended Safe Approach
- ✅ Use country flags (public domain)
- ✅ Use stadium names (fair use)
- ✅ Use stadium photos (with proper license)
- ✅ Create original Pregame branding
- ⚠️ Avoid FIFA official logos without permission
- ⚠️ Avoid team crests (use flags instead)

---

## Asset Collection Timeline

### Week 1 (Now)
- [x] Create folder structure
- [ ] Download all 48 flags (automated script)
- [ ] Create stadium image checklist

### Week 2
- [ ] Download all 16 stadium images
- [ ] Optimize all images for mobile
- [ ] Test loading in Flutter app

### Week 3
- [ ] Create Pregame World Cup branding
- [ ] Design app icon
- [ ] Collect UI icons

### Week 4
- [ ] Final review and optimization
- [ ] Update pubspec.yaml
- [ ] Test asset loading performance

---

## Next Steps

1. **Run Flag Download Script** (if created)
2. **Manually download stadium images** (stadium checklist)
3. **Create custom Pregame World Cup logo** (avoid FIFA trademarks)
4. **Update pubspec.yaml** with new asset paths
5. **Test assets in Flutter app**

---

## Asset Optimization Tips

### For Flags (PNG)
```bash
# Optimize PNG files
for file in assets/worldcup/flags/*.png; do
  pngquant --quality=80-90 --ext .png --force "$file"
done
```

### For Stadiums (JPG)
```bash
# Resize to consistent 1920x1080 and compress
for file in assets/worldcup/stadiums/*.jpg; do
  convert "$file" -resize 1920x1080^ -gravity center -extent 1920x1080 -quality 85 "$file"
done
```

---

**Total Assets Needed:**
- 🏴 48 National Team Flags
- 🏟️ 16 Stadium Images
- 🎨 5+ Branding Assets
- 🔣 10+ UI Icons

**Total Files:** ~80 image files
**Estimated Storage:** ~50-100 MB
**Estimated Time:** 8-12 hours of manual collection

---

**Created:** December 26, 2025
**Last Updated:** December 26, 2025
