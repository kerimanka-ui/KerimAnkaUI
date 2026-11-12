# KerimAnka UI 0.40.4 — Forever cursor and inventory fixes

This update targets **WoW: Forever (1.60.1)**. The combined download preserves **Classic Era 0.37.0 unchanged**. Existing settings and recorded history are preserved.

- Inventory: uses fixed physical bag/slot ownership instead of writing the native bag-ID field, preserving native item-click, drag and modified-click handlers.
- Combat inventory: prepares item buttons outside combat for the standard layouts and Organized main/recent/footer views. Missing buttons and bank buttons are deferred until combat ends. Item removal, replacement, count, lock and readable-state updates continue on the existing slot.
- Hunter ammunition: the user successfully changed arrow types during combat, including equipping a newly purchased different type. The change uses the common inventory path; it does not automatically choose ammunition or add item/class exceptions.
- Mouse cursor: adds an optional cursor settings page with configurable shapes, color, size, opacity and visibility, GCD/cast/channel indicators, 2D trails and three built-in native effects (blue flow, blue electric and green electric). Camera initialization before model scaling preserves the latest test13 reload behavior. Native effects reuse game assets; extracted game assets are not distributed.

**Gameplay evidence:** the user reported successful item use/weapon equip in the earlier identity fix and successful arrow changes with the button-preparation fix. The latest cursor test13 received a provisional positive report for all three effects and /reload. These tests used the same feature code with private observation overlays; exact in-memory reconstruction verifies the overlays are the only installed differences. The user subsequently installed clean 0.40.4, reloaded and reported that it works with no current problems and appears stable. The installed 511-file Forever payload was verified against the clean release. This is a basic gameplay/reload approval; it does not establish every combat scenario or long-session performance.

**Hunter sound finding (no new code fix):** the existing six-file error-click mute remains unchanged. Installed Forever Dual Gathering 2.3 can unmute the shared file 567407. Disabling that addon and reloading appeared to restore the desired behavior for the user. This release does not implement a compatibility fix or change the macro; long-session confirmation remains open.

**Limitations:** full restart, long-session and actual CPU/GPU/FPS measurements are pending. Not all classes, item families or the immediate last-arrow-exhaustion sequence were tested in game. Combat-first loading or capacity beyond the prepared reserve can defer missing slots until combat ends. Existing QuestJournal secret-aura/Edit Mode warnings and previously recorded intermittent bag-open/UNKNOWN and combat private-chat limitations remain open; this update does not claim to resolve every protected-action report.

Private Diagnostic, Sound Probe, detailed BagBirth observers, cursor probes, personal SavedVariables and fake test data are excluded. The existing bounded public bag-status/actionlog commands are retained. All eight independent products remain separate, with their own sync/test status. CurseForge uses the existing suite webhook only; no duplicate manual ZIP upload.


# KerimAnka UI 0.40.3 — Forever economy and inventory improvements

This update targets **WoW: Forever (1.60.1)**. The combined download preserves **Classic Era 0.37.0 unchanged**. Existing settings and recorded economy history are preserved.

- Auction mail: matches batched money updates to the correct pending sales, prevents item-only mail from duplicating a sale, and keeps earlier pending receipts when a later native mail request fails. Sales and returned deposits remain separate.
- Auction purchases: records the real item ID/link and localized item name when the game's auction cache provides them. Taking an already-paid item from mail does not create a second expense.
- Economy previews: resolves older name-only entries through known account item identities and recorded bag/bank snapshots. Newly observed identities remain available after changing characters or selling an item. Unknown or ambiguous historical items may still have no preview.
- Economy navigation: source/period filters, list tabs, search, sorting and pagination preserve the current viewport position.
- Economy search: common Turkish and Latin accents are optional when searching item names, players, sources and transaction types. For example, `ucus` matches `Uçuş` and `egitim` matches `Eğitim`.
- Travel/training: use the existing transaction search to separate Flight and Training without changing the two-row source grid. Search totals show cash in/out across all matching result pages; the main summaries stay unchanged. Transaction searches cover retained details, not deleted historical records.
- Bag capacity: Classic, Compact and Leather/Metal layouts now explain general versus special space and per-bag free slots on hover, using the same tooltip as Organized. Reagent-only space is identified separately.
- Reagent sorting: routes confirmed crafting reagents into the dedicated reagent bag while preserving narrower profession/ammunition priorities; tools and general items are not guessed to be reagents.
- Quest tracker: keeps the custom secure-item viewport independent of the native tracker frame hierarchy.

**Verification:** one in-game bulk capture matched all 17 sales across 8 money updates. The newer mail-failure path, item metadata, previews, search/totals, bag variants and tracker protection were also checked in local regression tests. Local tests do not replace gameplay coverage of every race, class, locale or mailbox sequence.

**Known issues:** the reported QuestJournal secret-aura taint warning, including the Edit Mode path, remains under investigation. This release does not claim to fix that warning. The intermittent bag-open/UNKNOWN protected-action reports and previously documented combat private-chat limitations also remain unresolved. Old unclassified economy entries are not retroactively rewritten.

Guild bank retains its native appearance by default. Independent editions, private mail-report instrumentation and personal SavedVariables are excluded from the suite release.


# KerimAnka UI 0.40.2 — Forever bag and chat fixes

This maintenance update targets **WoW: Forever (1.60.1)**. The combined download preserves **Classic Era 0.37.0 unchanged**. Existing settings are preserved.

- Bags: stack-splitting dialogs opened by the modern game API are raised above KerimAnka inventory windows and return to their original layer when closed.
- Sorting: compatible items in ordinary bags are routed into available ammunition, soul and profession bags before the existing sorting passes. Matching partial stacks are filled first; full or unknown bag families retain their safe fallback.
- Inventory interactions: native bag identity is initialized through the game's bag-ID attribute path outside combat, preserving native item-click handlers.
- Chat: restores a displaced, unprotected primary message viewport to its cached position during combat, including level-up refreshes. Protected frames remain untouched.
- Hunter Range and Aspect Alert: removed routine ready messages on login/reload. Functional warnings and manual diagnostic commands remain available.
- Bag troubleshooting: `/kauibags status` now includes the last refresh error or blocked action observed during the current session; it does not add automatic chat messages.

**Gameplay verification:** Hunter ammunition sorting and a fresh character levelling up during combat were tested successfully by the author. Other specialty families and dialog restoration were checked in local regression tests; these are not substitutes for live gameplay coverage.

**Known limitations:** the intermittent report of bags refusing to open has not yet been reproduced conclusively. The exact cause of the reported `UNKNOWN()` protected-action error is also unconfirmed. If bags stop opening, capture `/kauibags status` before reloading. The previously documented combat private-tab limitations remain; this update does not claim to resolve them completely.

Guild bank keeps its original native appearance by default. Independent editions, personal SavedVariables and private diagnostic traces are excluded.


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
