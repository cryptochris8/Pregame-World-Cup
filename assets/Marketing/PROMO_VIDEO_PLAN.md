# Pregame — Promo Video Plan (TikTok + X)

**Created:** 2026-05-21 · **Window:** ~3 weeks before the 2026 tournament (kickoff June 11)
**Production workflow:** app screen recordings + ElevenLabs AI voiceover + ffmpeg editing. No actors.

---

## 1. Trend research summary

Four parallel research passes (May 2026). Key findings:

- **Biggest opportunity — ticket-price outrage.** $32,970 final tickets, dynamic pricing, Infantino's "I'll personally deliver a hot dog" line, Trump saying he wouldn't pay it. Hottest 2026-tournament discourse on X right now. A gift for a *free* app.
- **Durable comedic formats:** "small trigger → full overreaction" spiral; reality-TV dramatic audio over mundane footage; "the app that…" deadpan narration; exaggerated problem/solution.
- **TikTok mechanics:** hook in 1–2s, 15–30s length, captions mandatory (most watch muted), pair with a trending sound, fan-reaction/stitch edits outperform polished ads.
- **X mechanics:** native upload only, sub-60s, opinionated/quote-tweetable caption, **App Store link goes in a reply — never the post** (X penalizes external links).
- **Avoid "brand fingerprints":** logo intros, studio polish, motion-graphic lower-thirds — audiences are trained to skip these instantly.

## 2. The five concepts

| # | Title | Platform | The bit | App feature |
|---|-------|----------|---------|-------------|
| 1 | The $32,970 Seat | X → TikTok | Deadpan: tickets cost a fortune, or watch free at a bar | Venue finder |
| 2 | Your friend who "played in college" | TikTok + X | The app knows more than the insufferable friend — and stops talking | AI match previews |
| 3 | Wrong Bar Nightmare | TikTok | You found a bar — muted corner TV while darts gets the big screen | Venue finder |
| 4 | The Spiral | TikTok | Opened the app to check one kickoff time, now fully unhinged | Schedule + teams |
| 5 | Group Chat | TikTok | Reality-TV audio over chat chaos; one venue link ends the war | Watch-party planning |

## 3. Platform mechanics cheat-sheet

- Hook in 1–2 seconds. No logo intro, no slow zoom-in on a static frame.
- 15–30s sweet spot, hard cap 60s.
- Burn in captions — large, high-contrast.
- X: native upload, opinionated caption, link in first reply.
- TikTok: trending sound layered low, generic hashtags for discovery.

## 4. IP caution

Keep on-screen text and voiceover on generic terms — "the tournament," "2026," "soccer's biggest summer." Do **not** imply official affiliation. Hashtags like `#WorldCup2026` are fine for discovery (everyone tags them); the app and its spoken/on-screen branding stay generic.

---

# 5. PRODUCTION SCRIPT — Concept #1: "The $32,970 Seat"

**Target runtime:** ~23 seconds · **Primary platform:** X (then re-cut for TikTok)
**Tone:** dry, deadpan, slightly tired — a friend telling you the obvious.

### Voiceover script (full, ~58 words)

> "World Cup final tickets are going for thirty-two thousand, nine hundred seventy dollars. One seat. Plus fees. To watch ninety minutes of soccer.
> …Or — hear me out — open Pregame, find a bar two blocks away with the game on and the sound up, and keep your thirty-three grand.
> Pregame. It's free. Shocking, I know."

### Shot-by-shot

| Time | Visual | On-screen text | Voiceover |
|------|--------|----------------|-----------|
| 0:00–0:04 | Real news headline screenshot, slow push-in (Ken Burns) | (headline is the text) | "World Cup final tickets are going for thirty-two thousand, nine hundred seventy dollars." |
| 0:04–0:08 | Same headline / second screenshot of fees or the Trump quote | `+ FEES` red stamp animates in | "One seat. Plus fees. To watch ninety minutes of soccer." |
| 0:08–0:10 | Hard cut to black, record-scratch SFX | `or.` | "Or — hear me out —" |
| 0:10–0:19 | Screen recording: Pregame venue finder — scroll nearby bars, tap into one venue | `🟢 SOUND ON` · `2 blocks away` · `FREE` | "open Pregame, find a bar two blocks away with the game on and the sound up, and keep your thirty-three grand." |
| 0:19–0:23 | App icon end card | `Pregame — Free on the App Store` | "Pregame. It's free. Shocking, I know." |

### Assets to capture

1. **Ticket-price headline screenshot** — grab from a real article (e.g. Yahoo Sports "$32,970 World Cup ticket", Fortune "Trump admits tickets too expensive"). One clean screenshot, ideally with the price visible.
2. **App screen recording** — open Pregame → venue finder → scroll the nearby-venues list → tap into one venue showing match details. Record ~10s clean, vertical, at native device resolution.
3. **App icon** — `assets/logos/pregame_logo.png` (already in repo).

### Caption variants

**X (link in first reply, never the post):**
- "the official resale site is a genuine hate crime. anyway — here's the plan 🍻"
- "$32,970 for one seat. we built the petty alternative."
- "imagine paying 33 grand to NOT have a bar tab"

**TikTok (generic hashtags for discovery):**
- "POV: you did the math 💀 #WorldCup2026 #soccertok #watchparty"
- "free > $32,970, this is just facts ⚽️ #WorldCup2026 #fyp"

### ElevenLabs voice direction

- Pick a dry/deadpan conversational voice (browse voices tagged *deadpan* / *narration* / *conversational*).
- Settings: Stability ~45–55%, Style exaggeration low, Similarity high.
- Deliver flat — no hype inflection. The pause before "Or — hear me out —" sells the joke; render it as a separate take if needed.

### ffmpeg edit plan

All clips normalized to **1080×1920, 30fps, H.264, yuv420p**.

1. **Headline still → moving clip (Ken Burns zoom):**
   ```
   ffmpeg -loop 1 -i headline.png -t 8 -vf "scale=1080:-1,zoompan=z='min(zoom+0.0012,1.25)':d=240:s=1080x1920,format=yuv420p" -r 30 shot1.mp4
   ```
2. **Trim the app screen recording to the payoff segment:**
   ```
   ffmpeg -i screenrec.mp4 -ss 00:00:03 -t 9 -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,format=yuv420p" -r 30 shot4.mp4
   ```
3. **Concatenate segments** (list each .mp4 in `concat.txt`, re-encode for safety):
   ```
   ffmpeg -f concat -safe 0 -i concat.txt -c:v libx264 -pix_fmt yuv420p -r 30 assembled.mp4
   ```
4. **Mix voiceover + low background music** (music ducked to ~12%):
   ```
   ffmpeg -i assembled.mp4 -i vo.mp3 -i music.mp3 \
     -filter_complex "[2:a]volume=0.12[m];[1:a][m]amix=inputs=2:duration=first[a]" \
     -map 0:v -map "[a]" -c:v copy -shortest mixed.mp4
   ```
5. **Burn in captions** — write an `.srt`, then:
   ```
   ffmpeg -i mixed.mp4 -vf "subtitles=captions.srt:force_style='FontName=Arial,FontSize=22,Bold=1,Outline=3,Alignment=2,MarginV=120'" -c:a copy final.mp4
   ```
   For the `+ FEES` and `or.` stamps, use a `drawtext` filter with `enable='between(t,4,8)'` timing instead of subtitles.

### Music / sound

- Dry, low-key comedic bed under the voiceover (keep it quiet — VO is the star).
- Add a record-scratch SFX on the 0:08 cut to black.
- **TikTok re-cut:** swap the music bed for a current trending sound layered low so VO stays intelligible.

---

## Sources

- Yahoo Sports — $32,970 World Cup ticket
- Fortune — Trump admits World Cup tickets too expensive
- SI — FIFA president ridicules ticket-price backlash (hot-dog promise)
- SocialPilot / Buffer / New Engen — TikTok trends May 2026
- HeyOrca / SocialBee — X media specs & algorithm 2026
- Spreshapp — converting ad formats 2026; virvid/Animoto — first-3-seconds hook
- Campaign US — Will Ferrell × Lay's "bandwagoner" campaign
