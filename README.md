# CrickClash 🏏

An image-based cricket player guessing game built with Flutter — pick a difficulty, identify players from photos, and test your cricket knowledge.

🔗 **Live Demo:** [crickclash.netlify.app](https://crickclash.netlify.app)

---

## Features

- **Difficulty levels** — Easy, Medium, and Hard with separate player pools
- **Image-based guessing** — identify players from photos, not stats
- **Typo tolerance** — smart answer validation accepts close spelling variations
- **Timer-based questions** — auto-progression on timeout keeps the game moving
- **Instant feedback** — correct/wrong state shown immediately with the right answer
- **Score tracking** — cumulative score displayed throughout and summarised at the end
- **CSK-themed UI** — dark background with Chennai Super Kings yellow/blue palette

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Web) |
| Language | Dart |
| Data | Local JSON |
| Answer matching | `string_similarity` package |
| Deployment | Netlify |

---

## Project Structure

```
lib/
├── data/
│   ├── player_data.dart      # JSON loading and difficulty filtering
│   └── players.json          # Player dataset (~40 players)
├── models/
│   └── player.dart           # Player model (id, name, imageUrl, difficulty, country)
├── screens/
│   ├── home_screen.dart      # Difficulty selection
│   ├── game_screen.dart      # Main quiz screen
│   └── result_screen.dart    # Final score view
├── widgets/                  # Reusable UI components
└── theme/
    └── app_theme.dart        # Colors, text styles, input decoration

assets/
└── images/
    └── players/              # Local player image assets
```

---

## Running Locally

```bash
git clone https://github.com/varshiniuis/cricket_quiz_gift
cd cricket_quiz_gift
flutter pub get
flutter run -d chrome
```

> Requires Flutter SDK ≥ 3.0.0

---

## Current Limitations

- Dataset covers ~40 players — content is intentionally limited given the project scope
- Images are locally bundled assets (no CDN)

---

## Roadmap

- [ ] Expand player dataset across more nations and eras
- [ ] Visual countdown timer indicator
- [ ] Leaderboard with local score history
- [ ] Additional game modes (country guess, jersey number, etc.)
- [ ] Mobile app packaging (Android / iOS)

---

## About

Built as a short-form challenge to ship a complete, functional application — from UI to deployment. The goal was a working end-to-end product, not a large dataset.

---

*Feedback and suggestions welcome — open an issue or reach out.*
