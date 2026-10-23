# Changelog

This log records user-facing changes. Git commits provide the detailed history.
Earlier development builds are not exhaustively reconstructed here.

## 0.34.16 — 2026-10-23

- Connected the in-game GitHub button to the official KerimAnkaUI repository.
- Included the KerimAnka UI Limited Use License 1.0 in all nine addon folders.
- Prepared the first public distribution with an English user guide, installation
  instructions, screenshots, contact information and issue templates.
- Added optional development support links on GitHub, outside the game client.
- Existing character profiles, layouts and sound settings are unchanged.

## 0.34.15 — 2026-10-23

- Removed obsolete installation and development notes from the distribution.
- Added a consolidated English user guide and refreshed addon descriptions.
- Preserved the included Ubuntu font and LibSerialize license notices.
- Updated packaging and installation checks without changing gameplay behavior.

## 0.34.14

- Added GitHub and Twitch footer buttons with a selectable address popup.
- Added translated link guidance and preserved the pending-reload indicator.
- Removed the obsolete first-version footer message.

## 0.34.13

- Fixed ready sound-group previews failing when the requested sound file was
  already muted but was not present in the custom sound list.
- Preview playback temporarily unmutes the file, then restores the configured
  muting preferences.

## Current compatibility and limitations

- Targets the World of Warcraft: Forever client, Interface 16001. Retail and
  Classic Era compatibility is not claimed.
- Ready layouts are tuned for 1920 x 1080. Other resolutions or UI scales may
  require adjustment.
- Nine panel languages are available. Native game text and optional integration
  text may follow the client or third-party addon language.
- The wand mute group targets launch sounds. A short preparation sound may
  remain; not every wand damage type has been individually verified.
- Bartender4 and Questie are optional. Details! is required only for the optional
  Details skin integration and is not bundled.
