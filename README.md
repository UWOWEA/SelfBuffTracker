# SelfBuffTracker

**SelfBuffTracker** is a lightweight, customizable World of Warcraft addon designed to keep track of missing self-buffs (like _Mark of the Wild_, _Well Fed_, flasks, or stances) and alert you before you enter combat without them.

***

## 🌟 Key Features

*   **Multi-Buff Tracking:** Track as many buffs or spells as you want simultaneously.
*   **Drag & Drop Position:** Easily unlock and move the display frame anywhere on your screen.
*   **Spellbook & Chat Integration:** Quickly add or remove spells by **Shift-clicking** them directly from your Spellbook or chat links into the command line.
*   **Audio Alerts:** Plays a clear warning sound when you are missing buffs upon entering combat or at regular intervals.
*   **Per-Character Profiles:** Each character maintains its own independent list of tracked buffs and settings.
*   **Minimalist & Clean UI:** Dynamic icon frames that scale and auto-adjust based on how many buffs are currently missing.

***
## Screenshots

<p align="center">
  <img src="docs/images/tracked_missing.png" alt="Missing buff" width="45%">
  <img src="docs/images/tracked_active.png" alt="Active buff" width="45%">
  <br>
  <img src="docs/images/settings.png" alt="Settings" width="45%">
  <img src="docs/images/settings_buffs.png" alt="Settings" width="45%">
  <img src="docs/images/settings_buffs_spellbook.png" alt="Settings" width="45%">
</p>

***

## 💻 Chat Commands

Use `/sbt` or `/buff` in chat to configure the addon:

*   `/sbt add [Spell Link or Name]` – Adds a buff to track _(Tip: Shift-click from your Spellbook!)_
*   `/sbt remove [Spell Link or Name]` – Removes a buff from tracking
*   `/sbt list` – Displays all currently tracked buffs in your chat frame
*   `/sbt sound` – Toggles audio warning alerts ON/OFF
*   `/sbt size [number]` – Changes the icon size (Default: `50`)

***

## ⚙️ Installation

### Curseforge
[Curseforge Link](https://www.curseforge.com/wow/addons/uwowea-selfbuftracker)

### Manual
1.  Download the latest release.
2.  Extract the `SelfBuffTracker` folder into your WoW directory: `World of Warcraft\_retail_\Interface\AddOns\`
3.  Restart or reload your game UI (`/reload`).
