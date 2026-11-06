# KerimAnka UI 0.40.1 — Forever interface improvements

This update targets **WoW: Forever (1.60.1)**. The combined archive keeps **Classic Era 0.37.0 unchanged**. Existing settings and character records are preserved.

- Chat: a gear menu opens settings, copies the selected tab into a selectable text window, or searches that tab's snapshot. Search results can be navigated without changing the live conversation. The windows follow the selected chat theme and support nine panel languages.
- Chat: improved Battle.net conversation labels, colors and message indicators; corrected menu mouse handling and a missing mouse-over API error. Restricted names remain guarded rather than guessed.
- Bags: stopped repeated container hook registration that could grow into a stack overflow. Added hover descriptions for empty ordinary and reagent bag slots, removed the white selection outline, and improved Chinese tooltip font handling.
- Bank warnings: bank-slot insufficient-funds, limit and banker errors are retained when important warnings are enabled. The native game still owns purchase and transaction operations.
- Unit Frames: improved portrait combat feedback and localized dodge/parry/miss results; incoming-heal and player cast-mana predictions, a mana-spending trail, localized dead/ghost labels, native resting animation and player health-loss feedback.
- Unit Frames: opaque stone backgrounds and cleaner bar edges; native brown/gold level rings for Paladin, Priest, Shaman, Warrior, Warlock, Druid, Mage and Hunter while retaining each class's frame layout.
- Sound shortcut: music, ambience and master sound can now be toggled during combat. Position editing and unrelated settings retain their combat restrictions.
- Hunter Range: the suite no longer registers an unused separate options window.

**Guild bank:** the original Blizzard appearance is used by default. The optional experimental skin remains off and resets off on reload. Guild permissions, item transfers, purchasing, money controls and logs are native; purchased-tab server operations have not been gameplay-tested by us.

**Known limitation:** closing private chat tabs during combat may still encounter native blocked-action or temporary-view issues. This release does not claim a complete fix; the final closed-view compatibility guard is included and enabled at startup at the user’s request. It hides only confirmed closed orphaned views and restores genuinely reused views; `/kachatclosedview off` disables the guard for the current session. Diagnostic traces are excluded.

No independent products, personal SavedVariables, Diagnostics addon, fake economy data or diagnostic test instrumentation are included. All Forever suite version labels now report **0.40.1**; Classic Era remains **0.37.0**. Additional class/client visual feedback is welcome.


# KerimAnka UI 0.39.0 — Forever bags, bank and interface fixes

This update targets **WoW: Forever (1.60.1)**. The combined archive preserves **Classic Era 0.37.0** unchanged.

- Distinct micro-menu symbols for Forever's expanded menu.
- Organized bags: separate keyring access and ammunition/Soul Shard categories, with nine-language labels.
- Separate bag and bank text-size controls; resizing handles across bag designs; improved large-text toolbar, capacity and recorded-bank layouts.
- Personal bank: updated purchased-slot controls, native purchase flow, item visibility and bank-service closing. Removed a shared bag-owner reset from our handoff. The latest opening handoff runs after native window placement to reduce the initial position flash.
- Optional room-for-loot feature, **off by default**: after a full-bag loot failure, a normal input may replace an eligible cheaper grey stack with more valuable vendor-price loot. Quest, locked and pinned candidates remain protected; actual deletion and acquisition are reported separately with item links. No auction-price comparison or fabricated sale income.
- Unit Frames: skip portrait combat-feedback payloads that contain restricted secret values, preserving normal public feedback.
- Experimental guild-bank theme, **off by default**: `/kaguildskin on` enables it for the current session; `/kaguildskin off` restores the native appearance. Native tabs, permissions, money controls and logs remain native. `/kaguildpreview` is a clearly labeled read-only example requiring no guild membership.

The personal-bank fixes have local regression coverage and user gameplay checks; the final initial-position refinement still needs broader gameplay feedback. Real guild-bank permissions, money, purchasing and server item operations have **not** been verified on a guild member. The guild theme is therefore opt-in and resets off on reload/login.

No independent products, separate Diagnostics addon, personal SavedVariables, test ledger data or disposable loot-probe addon are bundled. Existing settings are preserved. Classic Era receives no new changes in this release.


# KerimAnka UI 0.38.0 — Forever

This release updates **WoW: Forever (1.60.1)**. The combined suite archive retains the existing **Classic Era 0.37.0** files unchanged; no new Classic features or fixes are included.

- Updated settings pages, compact switches, text sizes and nine-language presentation.
- New chat and micro menu adapted to Forever, including the friend counter and scrolling toolbar.
- Four bag designs, Organized view, combined bags/bank, recorded inventories and item owner tooltips.
- Separate Economy page with bounded history, summaries, filters, search and item links.
- Updated Unit Frames preview/settings, target-of-target controls, minimap and experience/reputation settings.
- Full and partial profile transfer, audio preference fixes, and Hunter ready-layout native swing timer activation.
- Details integration is optional; Details is not required to use the suite.

Classic and Forever use separate client TOCs and settings namespaces. Install the ten suite folders as siblings in Interface/AddOns. Independent editions, Diagnostics and personal/test SavedVariables are not included.

Existing Forever limitations around protected/secret combat data remain, including Aspect Alert's combat restrictions. Account/guild bank management remains native.


# Changelog

This log records user-facing changes. Git commits provide the detailed history.
Earlier development builds are not exhaustively reconstructed here.

## 0.37.0 — Classic Era inventory, economy and settings update

This release updates Classic Era (1.15.9 / Interface 11509). Forever runtime files and standalone products are not updated by this release.

- Added the Organized bag layout with category filters, pinned quick access, recent items, category ordering and compatible empty-slot handling.
- Improved sorting options, bag backgrounds, bank and recorded-character inventory presentation, inventory tooltips and bag capacity warnings, including specialty bags.
- Added a character-focused Economy page for recorded money movements, income/expense summaries, charts, source filters, item details, search and sorting. Includes merchant, travel/training, auction/deposit, mail and player-trade tracking, with own-character transfers shown separately.
- Bounded Economy detail history to 5,000 records with separate retained summaries, cached reports and lists. Recording is event-driven; reports/charts are prepared when viewed. Historical activity before tracking began is not reconstructed.
- Reorganized Home, Chat and Micro Menu, Bar Backdrop, Class Art, Unit Frames, Minimap, Bags, Experience/Reputation and Threat settings with clearer groups and tabs, shared compact switches, help and three settings-text sizes.
- Improved Unit Frames preview navigation and aura visibility; added Druid cat-form combo-point and energy-tick support.
- Improved audio preference reapplication and combat-safe bag interactions. Classic Quest Tracker placeholder and unsupported native damage-meter controls are hidden; existing quest addons remain independent.
- Completed missing Aspect settings translations and preserved custom warning text. Nine panel languages retain their existing font fallbacks.

Existing character preferences are retained; no WTF/SavedVariables or diagnostic/fake test datasets are included. The suite contains ten dependent addon folders; standalone Bags and other independent products are excluded and will be updated separately.

## 0.36.0 — Classic Era Chat and Micro Menu

- Added a suite-dependent Chat and Micro Menu module with a sidebar enable/disable control.
- Added chat themes, persistent input, draft clearing, tab overflow, optional channel-colored tabs, and three visibility modes.
- Added position/size controls, drag resizing, horizontal/vertical/automatic control layouts, and configurable micro-menu size and spacing.
- Improved detached chat windows, combat-log header ownership, tooltips and tab layering.
- Consolidated micro-menu settings into Chat and Micro Menu; translated chat controls into nine languages.
- Added two-step chat-only reset and new vertical defaults. Existing character settings and native channels/filters/history are retained.
- Improved XP/reputation/pet-bar readability, optional glossy texture, decorative frame alignment, and independent background visibility.
- Removed the inapplicable combat-tracking warning from Classic Aspect Alert settings.

Bag designs/search/layout improvements were already released in 0.35.1. Standalone product folders are not installed by the suite archive.
Forever runtime files are unchanged. These additions target Classic Era only.

## 0.35.1 — 2026-10-28

- Refined Classic Era bags with three selectable designs: Classic, Compact, and Leather & Metal.
- Improved bag controls, search, compact layouts, quest-item highlighting and multilingual text.
- Fixed excessive bag refresh work and updated bag settings, previews and Details skin wording.
- Added separate packaging for the optional KerimAnka Bags independent edition; it is not installed by the suite ZIP.
- Forever behavior is unchanged. These bag changes currently apply to Classic Era only.

## 0.35.0 — 2026-10-26

- Added Classic Era support alongside Forever, with separate client loaders and saved settings.
- Added Classic ready layouts for all nine classes, including backed-up Blizzard Edit Mode and optional Bartender4 transfers.
- Added a unified layout editor with quick settings, previews, save/cancel and access to disabled elements.
- Added combined bags and bank views, item cooldown counters and recorded character inventories.
- Added Classic main-hand/off-hand/ranged swing timers, portable Rogue combo points and a configurable player cast bar.
- Added energy ticks, mana ticks/five-second-rule indicators and independent target-of-target name scaling.
- Added minimap coordinates and clock/day-night positioning controls, plus optional World latency beside FPS (off by default).
- Improved name scaling, multilingual text and custom class-panel color coverage.

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

- Supports Forever (Interface 16001) and Classic Era (Interface 11509). Retail
  support is not claimed.
- Ready layouts are tuned for 1920 x 1080. Other resolutions or UI scales may
  require adjustment.
- Nine panel languages are available. Native game text and optional integration
  text may follow the client or third-party addon language.
- The wand mute group targets launch sounds. A short preparation sound may
  remain; not every wand damage type has been individually verified.
- Bartender4 and Questie are optional. Details! is required only for the optional
  Details skin integration and is not bundled.
