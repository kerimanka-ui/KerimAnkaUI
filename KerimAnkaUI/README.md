# KerimAnka UI

KerimAnka UI supports World of Warcraft: Forever (Interface 16001) and
Classic Era (Interface 11509), using separate loaders and saved settings.
Retail support is not claimed. This package contains all nine addon folders.

## Install

Extract all nine KerimAnkaUI folders directly into the game client's
Interface/AddOns directory. Do not place the containing release folder there.
The main file should be Interface/AddOns/KerimAnkaUI/KerimAnkaUI.toc.
Install the folders before starting the client for the first time.
When updating an existing installation, replace the addon files and use /reload.
If the client does not detect a newly added addon folder, restart the client.
Keep your WTF folder and SavedVariables when updating; these contain your settings.

## Get started

Open the panel with /kaui, /kerimanka, or its minimap icon.
The first-use guide leads you to Profiles. Choose the ready layout for your
current class, read the confirmation, and confirm the application.
Use the Reload UI button when prompted. The included ready layouts were tuned
for 1920 x 1080; other resolutions or UI scales may need positioning adjustments.
Applying a ready layout is optional. You can also enable and configure modules
individually from the panel. Module loading changes take effect after /reload.

All nine classes have a ready layout. Saved character records and named profiles
can copy KerimAnka UI settings together with a captured Blizzard Edit Mode layout
and a Bartender layout when available. Imported settings are copies; editing the
destination character does not edit the source record. Panel appearance preferences
are shared across the account. Read the confirmation before replacing a layout.

## Modules and optional integrations

The package contains the main panel and eight companion modules:
- KerimAnkaUI_AspectAlert: Hunter aspect reminders.
- KerimAnkaUI_BarBackdrop: backgrounds and borders for action buttons.
- KerimAnkaUI_ClassArt: class artwork and themed minimap presentation.
- KerimAnkaUI_DetailsSkin: optional skin integration for Details!.
- KerimAnkaUI_HunterRange: Hunter range display.
- KerimAnkaUI_QuestJournal: watched quests with grouping and scrolling.
- KerimAnkaUI_Threat: target threat percentage.
- KerimAnkaUI_UnitFrames: player, target, pet and target-of-target frames.

Bartender4 is optional; supported Blizzard action bars can be used instead.
Details! is required only for the optional Details skin module. The client’s own
damage meter is configured through its supported interface where available.
Questie is optional. Its separate tracker is disabled by default through this
suite to avoid duplicate trackers; its map markers can still be used.
Hunter Range and Aspect Alert are intended for Hunters.
Third-party addons are not included in this download.

## Positioning and appearance

Ready layouts use locked positions. Unlock the relevant element in the panel
before moving it, and lock it again afterwards. Unlocked unit frames move with
Alt + left mouse drag. Use each option's help tooltip for other controls.
/kaui center brings the settings window back to the center of the screen.

## Classic Era additions

Right-click the minimap launcher or choose Edit Positions in the panel to open
the layout editor. Drag an element to move it; right-click for quick settings.
Use Save and Exit to retain changes or Cancel to restore the starting layout.
Disabled elements remain discoverable in the editor. Combat closes the editor.

Classic includes combined bags and bank views, recorded inventory, item cooldown
counters, configurable swing timers, Rogue combo points, a player cast bar,
energy/mana tick indicators and minimap coordinates. World latency beside FPS
is optional and off by default; enable it in the FPS or editor quick settings.

The nine ready layouts are class-specific. Applying one backs up current
settings and transfers its captured Blizzard layout and optional Bartender
profile. A managed character-specific Blizzard layout is reused for repeated
applications rather than creating a new layout every time. UI language remains
your own preference and starts in English for a new installation.

Classic ready layouts were prepared at 1920 x 1080 and 100% UI scale. Automatic
adaptation of saved positions when changing the game's UI scale is deferred.
The new Classic-only features have not been added to the Forever loader.

## Languages

English, German, Turkish, Simplified Chinese, French, Italian, Spanish,
Brazilian Portuguese and Russian can be selected in the panel.
Some client-provided names and optional integration text follow the game or
third-party addon language. Report any remaining untranslated or unreadable text.

## Sound controls

Sound muting and custom FileDataID entries are saved per character.
A custom entry takes effect when added. Listen temporarily allows that file to
play; Stop Preview stops the preview, not all game audio. Removing a custom entry
restores it unless another enabled preset in this suite also requests its mute.
SoundKit IDs and item IDs are not sound FileDataIDs.

The bow draw, gunfire and gun reload groups were tested in the Forever client.
The wand group targets launch sounds; a short preparation sound may remain,
and not every wand damage type has been individually verified.
Other sound addons can affect the same files. A successful mute request does not
prove that every sound associated with a weapon or spell uses that file.

## Project and feedback

Twitch: https://www.twitch.tv/kerimanka (streams are in Turkish).
Project source and issue tracker: https://github.com/kerimanka-ui/KerimAnkaUI
Use the in-game GitHub button to select and copy the project address.
The repository and release downloads are public.
When reporting a problem, include the addon version, client build, character
class, Blizzard/Bartender bar choice, steps to reproduce, and any Lua error.
Do not post account credentials or an unreviewed copy of your WTF folder.

## Third-party notices

Keep Fonts/LICENCE.txt with the bundled Ubuntu fonts and
LibSerialize-LICENSE.txt with LibSerialize. These notices are part of the package.

## License

Free use and private modifications are permitted under the included LICENSE
(KerimAnka UI Limited Use License 1.0). Redistribution, published modifications,
and reuse of project-owned code or original artwork in another project require
prior written permission. Normal gameplay streams, videos and screenshots,
including monetized content, are allowed. Third-party licenses and applicable
platform rights remain unaffected. See LICENSE for the full terms.
