# Photo Fetching - Quick Start Guide

## 5-Minute Setup

### 1. Prerequisites
- Node.js 22+
- Firebase service account key at `D:\Pregame-World-Cup\service-account-key.json`

### 2. Install
```bash
cd D:\Pregame-World-Cup\functions
npm install
```

### 3. Check Current Status
```bash
npm run check-photos-v2
```

### 4. Fetch Photos

**Option A: All Players**
```bash
npm run fetch-player-photos-v2
```

**Option B: All Managers**
```bash
npm run fetch-manager-photos-v2
```

**Option C: Both (Sequential)**
```bash
npm run fetch-all-photos-v2
```

**Option D: Test First (Limited)**
```bash
npm run fetch-player-photos-v2 -- --limit=10
```

### 5. Verify Results
```bash
npm run check-photos-v2
```

---

## Command Reference

| Command | What it Does | Time |
|---------|--------------|------|
| `npm run check-photos-v2` | Show photo status | < 1m |
| `npm run fetch-player-photos-v2` | Fetch all player photos | 10-15m |
| `npm run fetch-manager-photos-v2` | Fetch all manager photos | 1-2m |
| `npm run fetch-all-photos-v2` | Fetch both (sequential) | 15-20m |
| `npm run fetch-player-photos-v2 -- --limit=10` | Test with 10 players | < 2m |
| `npm run check-photos-v2 -- --players` | Check only players | < 1m |

---

## Expected Output Examples

### Status Check
```
==================================================
Players Photo Status
==================================================

SUMMARY
Total players:        1200
With Photo:           1050 (87.5%)
Without Photo:        150 (12.5%)

PHOTO SOURCES
TheSportsDB              650 (61.9%)
Wikipedia                400 (38.1%)
```

### Fetch Progress
```
[150/1200] Lionel Messi
   ETA: 12m 30s
   Status: SUCCESS
   Source: TheSportsDB
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Can't find service key | Place at `D:\Pregame-World-Cup\service-account-key.json` |
| Scripts fail immediately | Check internet connection, Firebase console access |
| Very slow processing | This is normal - API rate limiting (~2 requests/sec) |
| Some photos not found | Expected - not all players have photos online |

---

## Photo Source Hierarchy

Scripts automatically try sources in this order:
1. **TheSportsDB** (highest priority, best quality)
2. **Wikipedia** (good fallback coverage)
3. **Wikimedia Commons** (highest resolution)

---

## What Gets Updated

When photos are fetched, Firestore documents are updated with:

```
photoUrl: "https://firebasestorage.googleapis.com/..."
photoSource: "TheSportsDB" or "Wikipedia"
photoUpdatedAt: timestamp
```

---

## Files Created

```
D:\Pregame-World-Cup\functions\src\
  ├── photo-fetcher-utils.ts          (Core utilities - NEW)
  ├── fetch-player-photos-v2.ts       (Player fetcher - NEW)
  ├── fetch-manager-photos-v2.ts      (Manager fetcher - NEW)
  └── check-photos-v2.ts              (Status checker - NEW)
```

---

## Next Steps

1. Run: `npm run check-photos-v2`
2. Run: `npm run fetch-player-photos-v2 -- --limit=10`
3. Check results: `npm run check-photos-v2 -- --players`
4. If satisfied, run: `npm run fetch-all-photos-v2`

---

For detailed guide, see: `D:\Pregame-World-Cup\PHOTO_FETCHING_GUIDE.md`
