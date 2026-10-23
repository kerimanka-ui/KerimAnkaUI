-- UTF-8 panel translations. Missing entries fall back to English.
local _,K=...
K.locales.en = {
 ["uf_nameOffsetY"]="Name Vertical Offset",
 ["uf_petTextScale"]="Pet Text Size",
 ["art_petBar"]="Pet Action Bar",
 ["art_petPanelEnabled"]="Show Pet Bar Backing",
 ["art_petPanelAlpha"]="Pet Bar Backing Opacity",
 ["art_petPanelPadding"]="Pet Bar Padding",
 ["warlockArtTitle"]="Warlock — Class Artwork",
 ["artSkinFel"]="Fel Obsidian",
 ["artSkinRitual"]="Soul Ritual",
 ["art_ritualRailWidth"]="Top Rail Width (%)",
 ["art_ritualRailX"]="Top Rail Horizontal Offset",
 ["warlockRitualTitle"]="Warlock — Soul Ritual",
 ["warlockRitualHelp"]="Choose Soul Ritual or Fel Obsidian using the cards above. Lower symbols retain their aspect ratio; position them using the shared vertical offset. The top rail is independent. Dark backing follows the selected bars.",
 ["art_ritualBacking"]="Show Dark Backing",
 ["art_ritualOpacity"]="Backing Opacity",
 ["art_ritualDock"]="Dock Lower Ornament to Screen Bottom",
 ["art_ritualInset"]="Distance from Screen Bottom",
 ["art_ritualRail"]="Show Independent Top Rail",
 ["art_ritualRailY"]="Top Rail Vertical Offset",
 ["art_ritualRailHeight"]="Top Rail Height",
 ["flAppliedCharacter"]="Profile and character-specific Blizzard layout applied. Other characters’ selected layouts were not changed. Check action bars and the Damage Meter. Restore Previous Settings undoes both parts.",
 ["flAccountPlan"]="Layout scope: Account — also selectable on other characters.",
 ["flCharacterPlan"]="Layout scope: This character only — usable even when account slots are full.",
 ["flTitle"]="Full Interface — Shared Blizzard Layout",
 ["flHelp"]="Applies the selected KerimAnka UI profile with the 1920 × 1080 Blizzard layout. Reuses a matching KerimAnka UI layout, otherwise creates an account layout. If account slots are full, creates a character layout. The scope is shown below. Class artwork is selected separately.",
 ["flChecklist"]="After testing, check that the required action bars and Damage Meter (Schadenanzeige) are enabled. This code does not guarantee bar visibility, keybindings or all game preferences. Check positions at other resolutions and UI scales.",
 ["flApply"]="Selected Profile + Blizzard Layout",
 ["flWarning"]="After reloading, the selected addon profile and a Blizzard layout of the scope shown below will be applied. Previous settings and active-layout recovery information are saved. No layouts are deleted. Click the new button again to confirm, then reload the UI.",
 ["flUnavailable"]="Blizzard’s layout system is not ready or is unsupported. Nothing was queued. Open and close Edit Mode, then try again.",
 ["flCloseEdit"]="Save or discard your Blizzard Edit Mode changes and close Edit Mode before trying again.",
 ["flInvalid"]="Blizzard could not read this layout code. Nothing was queued; check compatibility with this game version.",
 ["flFull"]="No free slot in the selected layout category. Account and character slots are counted separately. No layouts were deleted; check your layout list in Edit Mode.",
 ["flFailed"]="The Blizzard layout could not be applied. The addon profile may have been applied; previous settings remain in the undo backup. Use “Restore Previous Settings” to return.",
 ["flApplied"]="Profile and Blizzard layout applied. Check action bar visibility and the Damage Meter. Undo restores the previous addon settings and selects the previous Blizzard layout.",
 ["aaCheetah"]="Cheetah Warning Text",
 ["aaEnabled"]="Enable Aspect Warnings",
 ["aaGlow"]="Cheetah Combat Glow",
 ["aaHelp"]="Controls the loaded alert separately from addon loading. Unlearned aspects and travelling keep their existing suppression rules. Unlocking shows a placement sample; lock again when finished.",
 ["aaLive"]="Return to Live Alerts",
 ["aaLock"]="Lock Position",
 ["aaMissing"]="Missing Aspect Text",
 ["aaNote"]="Settings now belong to this character. Existing shared settings are copied on first use. Unlock and drag the alert to position it.",
 ["aaCombatNoticeTitle"]="Beta: Aspect Tracking in Combat",
 ["aaCombatNotice"]="Tracking works outside combat. During combat, the game restricts buff information: an initial state or change may be detected, but later changes may not be tracked and the alert may disappear. No alert does not mean your aspect is inactive. Check your active aspect using the game’s own buff/aura icons. This feature was developed during beta; game restrictions and behavior may change.",
 ["aaOriginal"]="Open Original Aspect Settings",
 ["aaPreview"]="Cheetah Preview",
 ["aaPreviewHelp"]="Shows a temporary sample on the actual alert. Enable the alert first. Page change or closing the hub ends this sample. An unlocked alert can still show its placement sample. Travel suppression remains active.",
 ["aaPreviewMissing"]="Missing Aspect Preview",
 ["aaRefresh"]="Refresh Values",
 ["aaResetPosition"]="Reset Alert Position",
 ["aaResetTexts"]="Restore Default Warning Texts",
 ["aaText"]="Show Warning Text",
 ["aaTextHelp"]="Your warning text, up to 100 characters. Changes save while typing. The text is character-specific; changing the panel language does not translate your custom warning.",
 ["aaUpdate"]="Install the included HunterAspectAlert update to use these controls.",
 ["abAdvanced"]="Open Original Advanced Settings",
 ["abAlpha"]="Artwork Opacity",
 ["abArt"]="Show Class Artwork",
 ["abArtHelp"]="Changes the existing class artwork. Width/height are percentages. Positive X moves right; positive Y moves up. Follow mode tracks the selected bars. Returning to follow mode resets width/height to 100%.",
 ["abAuto"]="Automatically Follow Bars",
 ["abBar"]="Bar",
 ["abBars"]="Affected Bartender Bars",
 ["abBorder"]="Outer Border Size",
 ["abFixed"]="Fixed Size and Position",
 ["abFollow"]="Fit to Bars Again",
 ["abGap"]="Padding Around Bars",
 ["abHeight"]="Artwork Height (%)",
 ["abHelp"]="Changes are applied outside combat. Keep at least one bar selected. Brightness: 0 is black, 1 is the original color. A border size of 0 hides the outer border.",
 ["abIntro"]="Settings are saved for this character. Arrange bars and keybindings through the game settings or Bartender, depending on the selected source.",
 ["abLock"]="Keep Current Size and Position",
 ["abMin"]="Keep at least one bar selected.",
 ["abMode"]="Current mode: ",
 ["abShade"]="Button Frame Brightness",
 ["abShow"]="Show Button Backdrop",
 ["abSlot"]="Empty Slot Opacity",
 ["abUnsupported"]="No class artwork is available for this character.",
 ["abUpdate"]="Install the included ForeverBarBackdrop update to use these controls.",
 ["abWidth"]="Artwork Width (%)",
 ["abX"]="Horizontal Offset",
 ["abY"]="Vertical Offset",
 ["active"]="Active",
 ["add"]="Add",
 ["addonChangeFailed"]="Addon change failed:",
 ["addonChanging"]="The addon change is still being checked.",
 ["addonControl"]="Addon Loading",
 ["addonControlHelp"]="Changes the real addon list for this character. Reload after a change. The design switches above control the loaded addon's appearance separately.",
 ["addonStateUnknown"]="Addon state could not be read",
 ["alerts"]="Alerts",
 ["ambience"]="Mute Ambience",
 ["ambienceHelp"]="Disables environmental background sounds such as wind and water.",
 ["art"]="Class Art",
 ["artSkinHelp"]="Preview and switch this character's action bar artwork. Changes apply outside combat. Minimap and unit frames keep their own artwork. Skin selection is included in saved profiles.",
 ["artSkinHunter"]="Hunter",
 ["artSkinMetal"]="Simple Metal",
 ["artSkinSelected"]="Selected",
 ["artSkinUse"]="Use This Skin",
 ["artSkins"]="Action Bar Skin",
 ["art_alpha"]="Frame Opacity",
 ["art_artConfirm"]="Click Again to Confirm Reset",
 ["art_artExtraHelp"]="Changes save to this character. These controls change artwork, not action button layout. Unavailable settings are dimmed.",
 ["art_artReset"]="Restore Artwork Defaults",
 ["art_backing"]="Action Bar Backing and Top Trim",
 ["art_center"]="Decorate Timers and Pet Bar",
 ["art_centerPadding"]="Center Frame Padding",
 ["art_edge"]="Corner Size",
 ["art_enabled"]="Enabled",
 ["art_hideBorder"]="Hide Blizzard Minimap Border",
 ["art_hideBorderHelp"]="Hides only the native border around the minimap. Does not hide action bar gryphon statues or Bartender artwork. Another addon hiding the minimap border may keep it hidden when this option is off.",
 ["art_hunterHUD"]="Hunter HUD",
 ["art_hunterMatte"]="Matte Hunter Artwork",
 ["art_minimap"]="Minimap Artwork",
 ["art_opacity"]="Backing Opacity",
 ["art_padding"]="Frame Padding",
 ["art_rail"]="Top Rail Height",
 ["art_railY"]="Top Rail Offset",
 ["art_reset"]="Restore Minimap Defaults",
 ["art_resource"]="Hide Personal Resource Display",
 ["art_size"]="Frame Size (%)",
 ["art_units"]="Decorate Blizzard Unit Frames",
 ["art_x"]="Horizontal Offset",
 ["art_y"]="Vertical Offset",
 ["aspect"]="Aspect Alert",
 ["backdrop"]="Bar Backdrop",
 ["background"]="Mute While in Background",
 ["backgroundHelp"]="Stops game audio when the game window is not active.",
 ["badgeDisable"]="Click to disable this addon for this character.",
 ["badgeEnable"]="Click to enable this addon for this character.",
 ["badgeHelp"]="Green: the addon is loaded. Its own display feature can still be off. Dim: disabled or not loaded. Amber: a loading change awaits reload.",
 ["barsAuto"]="Automatic",
 ["barsBT"]="Bartender",
 ["barsBTActive"]="Using Bartender bars. Your existing Bartender decoration layout is preserved.",
 ["barsConflict"]="Bartender is still managing/hiding Blizzard bars. Disable Bartender in the game addon list and reload to use Blizzard.",
 ["barsEditor"]="Open Blizzard Edit Mode",
 ["barsLocked"]="Bar following is paused in fixed mode. Choose Fit to Bars Again above to edit this selection.",
 ["barsMissingBT"]="Bartender was selected but its action bars are not active. Enable it and reload, or select Automatic / Blizzard.",
 ["barsNative"]="Blizzard",
 ["barsNativeActive"]="Using Blizzard bars. Enable bars 2 and 3 in game settings and place the three horizontal bars one above another in Edit Mode. The artwork follows selected visible bars.",
 ["barsNativeList"]="Affected Blizzard Bars",
 ["barsNoEditor"]="Blizzard Edit Mode is not available right now. Use the game menu outside combat.",
 ["barsSource"]="Action Bar Source",
 ["barsSourceHelp"]="Automatic uses Bartender when it owns the bars; otherwise Blizzard. Width, position and selected bars are stored separately for each source. Changing this selection does not enable or disable addons. To use Blizzard after Bartender, disable Bartender in the game addon list and reload. Existing action slots and key bindings are not copied or changed.",
 ["bridge"]="This first version opens the module's existing settings. Its detailed controls and translations will move into this panel in later versions.",
 ["camera"]="Camera",
 ["cardGlow"]="Soft Card Glow",
 ["cardGlowHelp"]="Adds a soft shadow or glow around cards. Adjust its color, intensity and spread below, or turn it off. Only affects this settings panel.",
 ["cardTone"]="Card Background Brightness",
 ["center"]="Center Window",
 ["character"]="Character",
 ["classChanged"]="Hunter-only addons were disabled for this character. Reload the UI to finish.",
 ["clicks"]="Mute Ability Error Clicks",
 ["clicksHelp"]="Mutes the six sound files from your macro: 569772–569776 and 567407. This is separate from spoken error messages.",
 ["combat"]="Combat & Input",
 ["combatLock"]="Make this change outside combat.",
 ["custom"]="Custom Sound Files",
 ["customHelp"]="Enter numeric sound file IDs, separated by commas or spaces. These are file IDs, not sound-kit IDs. The game does not validate whether an ID is audible.",
 ["dependency"]="Check required addons in the addon list if this module does not load.",
 ["details"]="Details",
 ["dialog"]="Mute Dialogue",
 ["dialogHelp"]="Disables the game's dialogue sound channel. Spoken error messages have a separate option.",
 ["disableDeathEffect"]="Disable Grey Death Screen",
 ["disableDeathEffectHelp"]="Turns off the full-screen death/ghost effect so the world can keep its normal colours. ON disables the effect; OFF enables it again. Uses the game setting and adds no polling. Saved with your UI profile. If the client does not provide this setting, the switch is unavailable.",
 ["disabled"]="Disabled",
 ["dragTip"]="Drag: move icon",
 ["dtAll"]="Apply Forever Hunter to All Windows",
 ["dtAllHelp"]="Applies Forever Hunter to all initialized, enabled Details windows, including a window hidden by automatic visibility. It does not create new windows. Skin changes apply the selected template's appearance settings.",
 ["dtAlpha"]="Artwork Opacity",
 ["dtApply"]="Apply Selected Skin",
 ["dtCurrent"]="Current skin: ",
 ["dtDone"]="Skin applied.",
 ["dtEmpty"]="No enabled Details windows are ready. Open a Details window, then refresh this page.",
 ["dtFailed"]="Skin application failed:",
 ["dtFonts"]="Keep Font Faces and Sizes",
 ["dtHelp"]="The outer artwork only appears on windows using Forever Hunter. Font preservation keeps row and title font faces and sizes when changing skins; other appearance settings come from the selected skin.",
 ["dtNative"]="Open Details Settings",
 ["dtNote"]="Manage Details appearance here. Meter data, reports and advanced settings remain in Details. The Hunter artwork works on every class.",
 ["dtRefresh"]="Refresh",
 ["dtSelection"]="Use − / + to select a registered skin, then Apply. No skin is changed automatically.",
 ["dtTrim"]="Show Outer Artwork",
 ["dtUpdate"]="Install the included ForeverDetailsHunter update to use these controls.",
 ["dtWaiting"]="The skin is not registered yet. Wait a moment and refresh.",
 ["dtWindow"]="Window",
 ["dtWindows"]="Details Windows",
 ["effects"]="Mute Sound Effects",
 ["effectsHelp"]="Disables the entire effects channel, including combat and many interface sounds. For a specific sound, use a file ID below.",
 ["empty"]="No custom sound files added.",
 ["enable"]="Enable for This Character",
 ["enableHelp"]="Changes the addon list for this character. A reload is required; an already loaded addon continues running until then. Required addons are not enabled or disabled automatically.",
 ["errorCustom"]="Custom Filters",
 ["errorCustomHelp"]="ON hides that error group; OFF shows it. Important and unrecognized errors remain visible. This mode filters only known errors; use Hide All Except Important to suppress all other error types.",
 ["errorImportantHelp"]="Hides every red error except inventory/bank full, quest log full, not enough money and item-count limits. Turning off Keep Important Warnings hides these too. Informational quest progress messages are unaffected.",
 ["errorImportantOnly"]="Hide All Except Important",
 ["errorShowAll"]="Show All",
 ["errorShowHelp"]="Normal Blizzard error display. No additional text filtering.",
 ["error_cooldown"]="Hide Cooldown Errors",
 ["error_direction"]="Hide Facing / Sight Errors",
 ["error_movement"]="Hide Movement Errors",
 ["error_range"]="Hide Range Errors",
 ["error_resources"]="Hide Resource Errors",
 ["error_target"]="Hide Target Errors",
 ["errors"]="Hide Red Error Messages",
 ["errorsHelp"]="Turn off to show all native red errors. Turn on to use the selected filtering mode in Home > Alerts. The default hides all errors except the important warnings listed there. Sound settings are separate.",
 ["failed"]="The client could not apply this change.",
 ["featureOff"]="Feature Off",
 ["fileIds"]="Sound file IDs",
 ["ftBlue"]="Blue",
 ["ftCenter"]="Center Position and Unlock",
 ["ftColorHelp"]="Choosing a fixed color turns off automatic threat coloring. You can turn native threat colors back on above.",
 ["ftColors"]="Fixed Color",
 ["ftDefault"]="Default",
 ["ftFont"]="Font",
 ["ftFontHelp"]="Choose from the addon's existing fonts and fonts supplied by LibSharedMedia. Bold, outline and shadow are independent options.",
 ["ftGold"]="Gold",
 ["ftGreen"]="Green",
 ["ftHelp"]="Changes the current threat display outside combat. Hiding % only removes the sign; the number remains a percentage. Raw mode uses raw threat instead of the default scaled percentage.",
 ["ftNote"]="Uses your existing character settings. Unlock and drag the number, then lock it. Without data, the unlocked 75 is only a placement sample; a locked display hides.",
 ["ftOriginal"]="Open Original Threat Settings",
 ["ftRed"]="Red",
 ["ftRefresh"]="Refresh Values",
 ["ftUpdate"]="Install the included ForeverThreat update to use these controls.",
 ["ftWhite"]="White",
 ["ft_alpha"]="Opacity (%)",
 ["ft_autoColor"]="Use Native Threat Colors",
 ["ft_bold"]="Bold Text",
 ["ft_enabled"]="Enable Threat Display",
 ["ft_locked"]="Lock Position",
 ["ft_outline"]="Text Outline",
 ["ft_raw"]="Use Raw Threat Percentage",
 ["ft_shadow"]="Text Shadow",
 ["ft_showPercent"]="Show % Sign",
 ["ft_size"]="Font Size",
 ["ft_x"]="Horizontal Position",
 ["ft_y"]="Vertical Position",
 ["glowBlue"]="Effect Color: Blue",
 ["glowGreen"]="Effect Color: Green",
 ["glowRadius"]="Shadow / Glow Spread",
 ["glowRed"]="Effect Color: Red",
 ["glowReset"]="Restore Appearance Defaults",
 ["glowStrength"]="Shadow / Glow Intensity",
 ["glowStyle"]="Card Appearance",
 ["glowStyleHelp"]="Choose a dark shadow or colored glow. Intensity, spread and RGB adjust the effect; card brightness changes its background. Settings apply to this panel across characters. Turn Soft Card Glow off to hide the effect.",
 ["goldPreset"]="Warm Gold",
 ["heightResize"]="Window Height",
 ["heightResizeHelp"]="Drag the bottom-center handle down to make the window taller without changing text size. The corner handle still scales the whole panel.",
 ["hideActionBarStatues"]="Hide Blizzard Action Bar Statues",
 ["hideActionBarStatuesHelp"]="Hide the gryphon or wyvern statues at both ends of the action bar. Works with Blizzard bars without Bartender. Also hides Bartender replicas when present. Does not hide the action buttons, XP bar, or the minimap border. Turning this off stops our hiding; another addon may still hide the statues. Changes apply outside combat and save to this character.",
 ["hideNativeHotkeys"]="Hide Key Binding Text",
 ["hideNativeHotkeysHelp"]="Hides binding labels on all eight Blizzard action bars for this character. Key bindings and the range indicator remain unchanged. Bartender manages its own labels.",
 ["hideNativeMacroNames"]="Hide Macro Names",
 ["hideNativeMacroNamesHelp"]="Hides macro names below Blizzard action button icons. Macros, item counts and cooldown numbers remain unchanged.",
 ["home"]="Home",
 ["hrHelp"]="Changes the existing range bar outside combat. Positive X moves right and positive Y up. State colors stay the same; colored text follows the state icon. Text may shrink to fit a narrow bar.",
 ["hrLive"]="Return to Live Tracking",
 ["hrLiveMode"]="Live tracking",
 ["hrMode"]="Mode: ",
 ["hrNote"]="Existing character settings are used. Unlock to drag the range bar above your swing timer. The background stays opaque black.",
 ["hrOriginal"]="Open Original Range Settings",
 ["hrPreview"]="State Preview",
 ["hrPreviewHelp"]="Shows a sample on the real range bar, not a measured target distance. Enable the display first. Leaving this page or closing the hub ends its temporary sample. Unlocked bars may still show a placement sample without a target.",
 ["hrRefresh"]="Refresh Values",
 ["hrSample"]="Sample: ",
 ["hrUpdate"]="Install the included ForeverHunterRange update to use these controls.",
 ["hr_coloredText"]="Color Text by Range State",
 ["hr_enabled"]="Enable Range Display",
 ["hr_fontSize"]="Font Size",
 ["hr_height"]="Height",
 ["hr_locked"]="Lock Position",
 ["hr_outline"]="Text Outline",
 ["hr_shadow"]="Text Shadow",
 ["hr_width"]="Width",
 ["hr_x"]="Horizontal Position",
 ["hr_y"]="Vertical Position",
 ["hunterOnly"]="Hunter Only",
 ["hunterOnlyHelp"]="This module is only used by Hunters in this UI. It is automatically disabled in the addon list for other classes. Your manually disabled Hunter modules stay disabled. If already loaded, reload to stop the module.",
 ["imAlign"]="Place Below Chat",
 ["imBagHelp"]="Click a bag icon to hide or restore its slots without closing the combined window. Hidden slots leave gaps in the native grid. Dim bag icons indicate hidden bags. Modified clicks and dragging items retain their native behavior. Split bag mode remains available.",
 ["imBagSize"]="Bag Icon Size",
 ["imBagToggleHelp"]="Show / hide bag icon row",
 ["imBags"]="Blizzard Bags",
 ["imBartender"]="Bartender is active. Native bag and micro-menu customization waits until Bartender is disabled.",
 ["imDock"]="Attach Bag Icons to Combined Bags",
 ["imExpanded"]="Show Bag Icon Row",
 ["imGap"]="Space Between Icons",
 ["imHelp"]="Uses Blizzard bags and menu buttons. Settings affect this character. The bag row joins the full window width; its show/hide button stays beside the title close button. Click a bag icon to hide or restore only its slots; other bags remain visible.",
 ["imHideNativeBar"]="Hide Standard Bag Bar",
 ["imHideNativeBarHelp"]="Hides the standalone Blizzard bag bar, including while Bagnon is loaded. Bag windows and keyboard shortcuts remain available. Bartender keeps control of its own bars. Turn OFF to restore.",
 ["imIconSize"]="Micro Menu Icon Height",
 ["imItemLooksHelp"]="Desaturates poor-quality items with vendor value and adds a small coin; gives uncommon and better items clearer quality-colored borders. Works in Blizzard combined and separate bags. Bagnon and other bag replacements keep their own styling. No automatic selling or deletion.",
 ["imJunk"]="Gray Out Vendor Junk and Show a Coin",
 ["imLocked"]="Lock Micro Menu Position",
 ["imManage"]="Customize Micro Menu",
 ["imMicro"]="Micro Menu",
 ["imMicroHelp"]="Keeps Blizzard menu buttons and their actions. Changes size, spacing and position. Turn off to restore the original layout. Native Edit Mode temporarily takes priority.",
 ["imMove"]="Micro Menu — drag to move",
 ["imMoveHelp"]="Unlock the position to show a drag handle above the menu. Drag outside combat, then lock again. Place Below Chat aligns with the main chat without moving it. If chat touches the screen bottom, move chat up to leave space.",
 ["imOtherBags"]="Another bag addon is loaded. It manages bag icons and item styling. Standard bag bar hiding and micro-menu settings remain available.",
 ["imQuality"]="Stronger Item Quality Borders",
 ["imReset"]="Reset Micro Menu Layout",
 ["imUnavailable"]="This client does not expose the required combined bag frames. The micro menu remains available where supported.",
 ["inactiveHelp"]="This addon is not loaded. Enable it for this character and reload to use its settings. Also check its required addons.",
 ["installed"]="Installed",
 ["interface"]="Interface",
 ["invalidIds"]="Use positive numeric file IDs only (maximum 30 custom entries).",
 ["inventory"]="Bags & Menu",
 ["keepImportantErrors"]="Keep Important Warnings",
 ["keepImportantErrorsHelp"]="In Hide All Except Important mode, keeps inventory/bank full, quest log full, insufficient money and item-count limit errors visible. Turn OFF for complete red-error silence.",
 ["language"]="Language",
 ["languageHelp"]="Choose the panel language. Untranslated text uses English.",
 ["launcher"]="Show Minimap Icon",
 ["launcherHelp"]="Shows the KerimAnka UI launcher beside the minimap. A compatible icon collector can collect it.",
 ["lightPreset"]="Soft Light",
 ["listen"]="Listen",
 ["loaded"]="Loaded",
 ["missing"]="Not Installed",
 ["moduleError"]="The module's settings could not be opened. Check that it is enabled and loaded.",
 ["modules"]="Modules",
 ["music"]="Mute Music",
 ["musicHelp"]="Disables all game music, including zone and combat music.",
 ["noPanel"]="This module has no settings window. Use the character switch above to enable or disable it.",
 ["notLoaded"]="Not Loaded",
 ["note"]="First release · Existing module settings are preserved.",
 ["off"]="OFF",
 ["on"]="ON",
 ["open"]="Open Module Settings",
 ["openTip"]="Left click: open settings",
 ["overview"]="Overview",
 ["pending"]="Reload required",
 ["pendingOff"]="Disable · Reload",
 ["pendingOn"]="Enable · Reload",
 ["pets"]="Mute Pet Sounds",
 ["petsHelp"]="Disables pet sounds when this client supports the pet-sound setting.",
 ["pfApply"]="Apply Profile",
 ["pfApplyWarning"]="Confirm to queue the selected settings, then click Reload UI below. Your previous settings remain protected.",
 ["pfBackup"]="Last Undo Backup — This Character",
 ["pfBackupHelp"]="One undo backup per character. It stays until deleted or replaced by the next profile application. Restoring replaces it with the settings you just left. Ordinary setting changes do not create backup history.",
 ["pfBadName"]="Use a unique profile name of 1–48 bytes, without control characters or |.",
 ["pfBeforeApply"]="Before profile application",
 ["pfBeforeRestore"]="Before restoring the backup",
 ["pfCancelPending"]="Cancel Queued Change",
 ["pfCancelled"]="Queued change cancelled. Your current settings were not changed.",
 ["pfCharacter"]="Character",
 ["pfChoose"]="Saved Profiles / Characters",
 ["pfConfirmApply"]="Confirm Selection",
 ["pfConfirmDelete"]="Click Again to Delete",
 ["pfConfirmRestore"]="Confirm Restore",
 ["pfDelete"]="Delete Selected",
 ["pfDeleteBackup"]="Delete Undo Backup",
 ["pfDeleted"]="Entry deleted.",
 ["pfEmpty"]="No saved profiles yet.",
 ["pfExists"]="That name already exists. Use another name or delete the old profile first.",
 ["pfFailed"]="The operation failed. No new profile was accepted.",
 ["pfFull"]="Profile storage is full. Delete an unused saved profile and try again.",
 ["pfGenerate"]="Generate Current Code",
 ["pfGenerated"]="Code generated. Ctrl+A selects all; Ctrl+C copies it. Paste another code here to import.",
 ["pfIntro"]="Select a saved profile or character, then Apply to This Character. Click Reload UI below to apply the queued settings. Saved profiles are independent copies; editing this character does not overwrite them. Bartender layouts and Details/Questie profiles are separate.",
 ["pfInvalid"]="Invalid, damaged or unsupported profile code. Nothing was changed.",
 ["pfLoadCode"]="Show / Share Code",
 ["pfManualReload"]="Reload was unavailable or blocked. Your queued settings are preserved. Type /reload in chat.",
 ["pfNamed"]="Profile",
 ["pfNeedsValidation"]="Validate the code before applying it. No settings have been changed.",
 ["pfNoBackup"]="No undo backup is stored for this character.",
 ["pfPending"]="Apply pending addon loading changes first, then reload before importing a profile.",
 ["pfPendingProfile"]="A profile is already queued. Click Reload UI to apply it or cancel it first.",
 ["pfQueued"]="Settings queued. Click Reload UI below to apply, or cancel here.",
 ["pfRestore"]="Restore Previous Settings",
 ["pfRestoreWarning"]="Confirm to queue the backup, then click Reload UI below. Your existing backup stays protected until the restore completes.",
 ["pfSave"]="Save Current Settings",
 ["pfSaveName"]="New profile name",
 ["pfSaved"]="Profile saved. Each saved profile is an independent copy.",
 ["pfStorage"]="Profile storage: %.1f / %.0f KiB · %d saved entries",
 ["pfStorageHelp"]="Up to 32 named profiles and 64 character snapshots; 256 KiB total. Snapshots update on login/logout and replace the previous version. Oldest character snapshots may be removed when full; named profiles are never automatically removed. Undo backup is separate, at most 64 KiB.",
 ["pfTestOK"]="Profile self-tests passed.",
 ["pfTooLarge"]="The profile code exceeds the size limit. Nothing was changed.",
 ["pfTransfer"]="Import / Export Code",
 ["pfTransferHelp"]="Generate a sharing code or paste one here. Validate and confirm it, then click Reload UI below.",
 ["pfUseSelected"]="Apply to This Character",
 ["pfValid"]="Code is valid.",
 ["pfValidate"]="Validate",
 ["pfValidated"]="Valid profile · source class: %s · %d module settings tables. It will use your current class artwork. Panel appearance also applies across characters.",
 ["previewFail"]="This file could not be played. Check its ID and your game audio settings.",
 ["profiles"]="Profiles",
 ["qjBorder"]="Leather Border Width",
 ["qjHelp"]="Styles the Questie tracker. The quill is optional. Questie continues to control quests, collapsing, font, background color and tracker position. These switches do not disable the addon itself.",
 ["qjNote"]="Questie keeps quest content and tracker behavior. This page controls the journal artwork.",
 ["qjOpacity"]="Background Opacity",
 ["qjOriginal"]="Open Original Journal Settings",
 ["qjQuill"]="Show Optional Quill",
 ["qjShow"]="Show Leather Design",
 ["qjUpdate"]="Install the included ForeverQuestJournal update to use these controls.",
 ["qjWaiting"]="Questie tracker is not attached yet. Check that Questie is enabled and its tracker is visible.",
 ["quests"]="Quest Journal",
 ["queue"]="Spell Queue Window",
 ["queueHelp"]="Time in milliseconds during which the next ability can be queued. Lower is not always better; choose a value that suits your latency.",
 ["quick"]="Quick Settings",
 ["range"]="Hunter Range",
 ["reload"]="Reload UI",
 ["reloadHelp"]="Reloads the interface to apply addon enable/disable changes. Saved settings are kept.",
 ["reloadLater"]="Later",
 ["reloadNow"]="Reload Now",
 ["reloadPromptBody"]="Reload to apply your addon changes. You can also reload later using the button at the bottom.",
 ["reloadPromptTitle"]="Reload Interface",
 ["reloadWaiting"]="Addon changes are waiting · Reload using the button on the right.",
 ["remove"]="Remove",
 ["resetHelp"]="/kaui opens settings · /kaui center centers the window",
 ["resize"]="Resize Window",
 ["resizeHelp"]="Hold the bottom-right corner and drag diagonally. The whole panel scales proportionally; your size and position are saved. The Interface scale controls remain available.",
 ["restore"]="Restore Previous Values",
 ["restoreHelp"]="Restores only values changed through this panel to their captured earlier values. Module enable states are not changed.",
 ["saved"]="Settings save automatically.",
 ["scale"]="Panel Scale",
 ["scaleHelp"]="Scales this settings window only. Drag its title bar to move it; the position is remembered.",
 ["settings"]="Open KerimAnka UI",
 ["shadowPreset"]="Dark Shadow",
 ["soundInfo"]="Choose individual categories. Broad categories also silence useful sounds.",
 ["soundNote"]="Other sound addons can control the same files. Avoid muting the same ID in more than one addon.",
 ["sounds"]="Sounds",
 ["speech"]="Mute Spoken Errors",
 ["speechHelp"]="Mutes spoken warnings such as not enough mana. Other dialogue is controlled separately.",
 ["state"]="Module Status",
 ["stop"]="Stop",
 ["threat"]="Threat",
 ["ufAuras"]="Buffs & Debuffs",
 ["ufCast"]="Target Cast Bar",
 ["ufGeneral"]="General & Appearance",
 ["ufHelp"]="Changes the selected setting on the original unit frames. X moves horizontally; Y moves vertically. For attached pet/target-of-target frames, changing X/Y detaches their position. Make changes outside combat.",
 ["ufIndicators"]="Status Icons",
 ["ufNote"]="New aura/cast displays start OFF. Existing settings are preserved. Native aura layout/count/spiral changes may need a UI reload after auras have been created.",
 ["ufPositions"]="Frame Positions",
 ["ufUpdate"]="Install the included ForeverLeatherUnits update to use these controls.",
 ["uf_auraCooldown"]="Aura Cooldown Spiral",
 ["uf_auraStacks"]="Aura Stack Counts",
 ["uf_castFontSize"]="Spell Name Font Size",
 ["uf_castHeight"]="Cast Bar / Icon Height",
 ["uf_castIcon"]="Show Spell Icon",
 ["uf_castWidth"]="Cast Bar Width",
 ["uf_castX"]="Cast Bar X",
 ["uf_castY"]="Cast Bar Y",
 ["uf_classificationTextScale"]="Elite / Rare Font Scale",
 ["uf_combatIconSize"]="Combat Icon Size",
 ["uf_enabled"]="Custom Unit Frames",
 ["uf_happinessOffsetX"]="Happiness Icon X",
 ["uf_happinessOffsetY"]="Happiness Icon Y",
 ["uf_happinessSize"]="Happiness Icon Size",
 ["uf_healthTextScale"]="Health Number Scale",
 ["uf_hideNative"]="Hide Blizzard Frames",
 ["uf_leaderSize"]="Leader / Assistant Icon Size",
 ["uf_levelOffsetY"]="Level Vertical Offset",
 ["uf_levelTextScale"]="Level Font Scale",
 ["uf_locked"]="Lock Positions",
 ["uf_pet.x"]="Pet X",
 ["uf_pet.y"]="Pet Y",
 ["uf_petAuraBelow"]="Pet: Place Auras Below Frame",
 ["uf_petAuraColumns"]="Pet: Icons per Row",
 ["uf_petAuraGap"]="Pet: Icon Spacing",
 ["uf_petAuraMax"]="Pet: Maximum Icons per Type",
 ["uf_petAuraSingleRow"]="Pet: Single Aura Row",
 ["uf_petAuraSize"]="Pet: Icon Size",
 ["uf_petBuffX"]="Pet: Buff X",
 ["uf_petBuffY"]="Pet: Buff Y",
 ["uf_petBuffs"]="Pet: Buffs",
 ["uf_petDebuffX"]="Pet: Debuff X",
 ["uf_petDebuffY"]="Pet: Debuff Y",
 ["uf_petDebuffs"]="Pet: Debuffs",
 ["uf_petScale"]="Pet Frame Scale",
 ["uf_player.x"]="Player X",
 ["uf_player.y"]="Player Y",
 ["uf_playerAuraBelow"]="Player: Place Auras Below Frame",
 ["uf_playerAuraColumns"]="Player: Icons per Row",
 ["uf_playerAuraGap"]="Player: Icon Spacing",
 ["uf_playerAuraMax"]="Player: Maximum Icons per Type",
 ["uf_playerAuraSingleRow"]="Player: Single Aura Row",
 ["uf_playerAuraSize"]="Player: Icon Size",
 ["uf_playerBuffX"]="Player: Buff X",
 ["uf_playerBuffY"]="Player: Buff Y",
 ["uf_playerBuffs"]="Player: Buffs",
 ["uf_playerDebuffX"]="Player: Debuff X",
 ["uf_playerDebuffY"]="Player: Debuff Y",
 ["uf_playerDebuffs"]="Player: Debuffs",
 ["uf_powerTextScale"]="Mana / Energy Number Scale",
 ["uf_pvpOffsetX"]="PvP Horizontal Offset",
 ["uf_pvpOffsetY"]="PvP Vertical Offset",
 ["uf_pvpSize"]="PvP Icon Size",
 ["uf_raidMarkerOffsetX"]="Raid Marker X",
 ["uf_raidMarkerOffsetY"]="Raid Marker Y",
 ["uf_raidMarkerSize"]="Raid Marker Size",
 ["uf_restIconSize"]="Resting (ZZZ) Icon Size",
 ["uf_scale"]="Frame Scale",
 ["uf_showCombo"]="Extra Rogue Combo Points",
 ["uf_showPet"]="Show Pet Frame",
 ["uf_showPetHappiness"]="Show Pet Happiness",
 ["uf_showToT"]="Show Target of Target",
 ["uf_target.x"]="Target X",
 ["uf_target.y"]="Target Y",
 ["uf_targetAuraBelow"]="Target: Place Auras Below Frame",
 ["uf_targetAuraColumns"]="Target: Icons per Row",
 ["uf_targetAuraGap"]="Target: Icon Spacing",
 ["uf_targetAuraMax"]="Target: Maximum Icons per Type",
 ["uf_targetAuraSingleRow"]="Target: Single Aura Row",
 ["uf_targetAuraSize"]="Target: Icon Size",
 ["uf_targetBuffX"]="Target: Buff X",
 ["uf_targetBuffY"]="Target: Buff Y",
 ["uf_targetBuffs"]="Target: Buffs",
 ["uf_targetCastEnabled"]="Show Target Cast Bar",
 ["uf_targetDebuffX"]="Target: Debuff X",
 ["uf_targetDebuffY"]="Target: Debuff Y",
 ["uf_targetDebuffs"]="Target: Debuffs",
 ["uf_targettarget.x"]="Target of Target X",
 ["uf_targettarget.y"]="Target of Target Y",
 ["uf_textScale"]="Name Font Scale",
 ["uf_totScale"]="Target of Target Scale",
 ["unavailable"]="Unavailable on this client",
 ["units"]="Unit Frames",
 ["upBuffs"]="Buffs",
 ["upCast"]="Sample cast",
 ["upControl"]="Preview control",
 ["upControlHelp"]="Drag to reposition this icon group. Mouse wheel changes its size. Changes are saved outside combat.",
 ["upDebuffs"]="Debuffs",
 ["upExamples"]="Sample effects",
 ["upNote"]="Drag / wheel · Click to jump to settings · First row samples",
 ["upPet"]="Pet",
 ["upPetName"]="Pet sample",
 ["upPlayer"]="Player",
 ["upPlayerName"]="Player sample",
 ["upTarget"]="Target",
 ["upTargetName"]="Target sample",
 ["upTitle"]="Live Preview",
 ["upVisible"]="Show Preview",
 ["version"]="Version 0.12.0",
 ["welcome"]="Your interface. Your settings. One place.",
 ["zoom"]="Maximum Camera Distance",
 ["zoomHelp"]="Changes the maximum zoom factor, not your current camera position. The game may limit the accepted value.",
 ["zoomNote"]="The slider sets a limit. Use the mouse wheel to zoom out afterwards.",
}

-- Native damage meter appearance.
K.locales.en["details"]="Damage Meter"
K.locales.en["dmBlizzard"]="Blizzard"
K.locales.en["dmDetails"]="Details Skin"
K.locales.en["dmNote"]="Styles Blizzard’s existing damage meter windows. Measurements, rows, menus and positioning remain controlled by the game. Details is not required."
K.locales.en["dmHelp"]="Appearance only, saved for this character. Turning the design off restores the native background and hides our trim. This does not enable or disable the game’s damage meter. Changes apply outside combat."
K.locales.en["dmEnabled"]="Show Blizzard Meter Design"
K.locales.en["dmTrim"]="Show Decorative Border"
K.locales.en["dmTrimAlpha"]="Border Opacity"
K.locales.en["dmBackground"]="Background Opacity"
K.locales.en["dmPadding"]="Border Offset"
K.locales.en["dmReady"]="Blizzard meter detected. The design follows its existing windows."
K.locales.en["dmHidden"]="The game’s damage meter is disabled. Enable it in the game settings; another meter addon may also have hidden it."
K.locales.en["dmUnavailable"]="Blizzard meter windows are not loaded yet or are unavailable on this client. Enable the game’s damage meter first."
K.locales.en["dmDetailsMissing"]="The optional KerimAnka UI Details Skin module is not loaded. Enable it below if you use Details."

-- Experience and reputation widget.
K.locales.en["experience"]="Experience & Reputation"
K.locales.en["xpTotal"]="Total"
K.locales.en["xpLevelTime"]="This level"
K.locales.en["xpLevel"]="Level"
K.locales.en["xpRemaining"]="Remaining"
K.locales.en["xpRate"]="XP/hour"
K.locales.en["xpDayShort"]="d"
K.locales.en["xpHourShort"]="h"
K.locales.en["xpMinuteShort"]="m"
K.locales.en["xpIntro"]="A compact experience widget with independent text controls. Turn it on below. Reputation appears only for the watched faction; pet XP appears only for an active Hunter pet that can gain XP."
K.locales.en["xpConflict"]="ExperienceForever is also loaded. Both widgets can remain visible; control each one through its own settings."
K.locales.en["xpHelp"]="Settings belong to this character and are included in profiles. The preview uses sample data. Quest XP means rewards from completed quests still in your log, not a count of all completed quests. XP/hour and remaining time use this UI session and reset on reload. Played time comes from the game. Hiding the default bar hides the native XP/reputation tracking container; it returns when our widget is off or has nothing to show."
K.locales.en["xpPreviewNote"]="Sample data · Click a text to select it · Drag or use the mouse wheel · Position and size update immediately"
K.locales.en["xpCompact"]="Compact Layout"
K.locales.en["xpHorizontal"]="Thin Horizontal Layout"
K.locales.en["xpEnabled"]="Show Experience Widget"
K.locales.en["xpLocked"]="Lock Widget Position"
K.locales.en["xpShowRep"]="Show Watched Reputation"
K.locales.en["xpShowPet"]="Show Hunter Pet XP"
K.locales.en["xpShowTime"]="Show Played Times"
K.locales.en["xpShowRate"]="Show XP/hour and Time Remaining"
K.locales.en["xpShowQuest"]="Show Ready-to-Turn-In Quest XP"
K.locales.en["xpShowRested"]="Show Rested XP"
K.locales.en["xpTrim"]="Show Decorative Border"
K.locales.en["xpHideNative"]="Hide Native XP / Reputation Bar"
K.locales.en["xpClassColor"]="Use Class Color"
K.locales.en["xpWidth"]="Widget Width"
K.locales.en["xpHeight"]="Main XP Bar Height"
K.locales.en["xpSubHeight"]="Reputation / Pet Bar Height"
K.locales.en["xpPlaceTop"]="Place at Screen Top"
K.locales.en["xpPlaceMeter"]="Place Above Blizzard Meter"
K.locales.en["xpNoMeter"]="Open the Blizzard damage meter first."
K.locales.en["xpTextSettings"]="Individual Text Settings"
K.locales.en["xpLabel_total"]="Total Played"
K.locales.en["xpLabel_levelTime"]="Time at This Level"
K.locales.en["xpLabel_xp"]="Level and XP"
K.locales.en["xpLabel_remaining"]="Time Remaining"
K.locales.en["xpLabel_rate"]="XP/hour"
K.locales.en["xpLabel_reputation"]="Reputation"
K.locales.en["xpLabel_pet"]="Pet XP"
K.locales.en["xpLabelVisible"]="Show Selected Text"
K.locales.en["xpLeft"]="Left"
K.locales.en["xpCenter"]="Center"
K.locales.en["xpRight"]="Right"
K.locales.en["xpTextX"]="Text Horizontal Offset"
K.locales.en["xpTextY"]="Text Vertical Offset"
K.locales.en["xpTextSize"]="Selected Text Size"
K.locales.en["xpFontRegular"]="Ubuntu Regular"
K.locales.en["xpFontBold"]="Ubuntu Bold"
K.locales.en["xpFontGame"]="Game Font"
K.locales.en["xpResetText"]="Restore Text Layout"
K.locales.en["xpResetSession"]="Reset Session Statistics"

K.locales.en["xpPanelSpace"]="Extra Panel Height"
K.locales.en["xpFrameSize"]="Decorative Border Thickness"
K.locales.en["xpBackgroundAlpha"]="Panel Background Opacity"

K.locales.en["xpColors"]="Bar Colors"
K.locales.en["xpColorMain"]="Main XP Color"
K.locales.en["xpColorQuest"]="Ready Quest XP Color"
K.locales.en["xpColorRested"]="Rested XP Color"
K.locales.en["xpColorRep"]="Reputation Color"
K.locales.en["xpColorPet"]="Pet XP Color"
K.locales.en["xpTextColor"]="Selected Text Color"
K.locales.en["xpChooseColor"]="Choose Color"
K.locales.en["xpApplyColor"]="Apply HEX"
K.locales.en["xpResetColor"]="Default Color"
K.locales.en["xpInvalidHex"]="Enter a six-digit color code, for example #55AA77."
K.locales.en["xpPickerUnavailable"]="The native color picker is unavailable. You can still enter a HEX code."

K.locales.en["xpClassColorActive"]="Class color is active. Turn it off to choose a custom XP color."

K.locales.en["mcTitle"]="Minimap Coordinates"
K.locales.en["mcHelp"]="Styles the game’s existing coordinates. Enable coordinates in the game settings. Changes appear immediately on the minimap. Dragging ends in combat or when this window closes."
K.locales.en["mcUnavailable"]="This client’s native minimap coordinate frame is unavailable."
K.locales.en["mcEnabled"]="Customize Coordinate Position and Font"
K.locales.en["mcX"]="Coordinates: Horizontal Offset"
K.locales.en["mcY"]="Coordinates: Vertical Offset"
K.locales.en["mcSize"]="Coordinate Font Size"
K.locales.en["mcOutline"]="Outline Coordinate Text"
K.locales.en["mcDrag"]="Drag to Position"
K.locales.en["mcLock"]="Lock Position"
K.locales.en["mcReset"]="Restore Default Coordinates"

K.locales.en["ufPortraitCombat"]="Portrait Combat Text"
K.locales.en["uf_portraitCombatPlayer"]="Player Portrait Combat Text"
K.locales.en["uf_portraitCombatPet"]="Pet Portrait Combat Text"
K.locales.en["uf_portraitCombatSize"]="Portrait Combat Text Size"
K.locales.en["ufPortraitCombatHelp"]="Shows Blizzard combat feedback on your own or your pet’s portrait: received damage, healing and results such as dodge or absorb. Critical hits use a larger font. Disabled by default. Target portraits and world combat text are unchanged."

K.locales.en["ufQuestie"]="Questie Target Icon"
K.locales.en["uf_questieTargetIcon"]="Show Questie Icon on Target"
K.locales.en["uf_questieIconSize"]="Quest Icon Size"
K.locales.en["uf_questieIconX"]="Quest Icon: Horizontal Offset"
K.locales.en["uf_questieIconY"]="Quest Icon: Vertical Offset"
K.locales.en["ufQuestieHelp"]="Shows the objective icon selected by Questie beside the target portrait. Requires Questie and its target-frame icons to be enabled. Uses Questie’s icon theme and objective progress; respects its Forever instance restrictions. Position is relative to the portrait’s upper-right corner."

K.locales.en["ufHunterSummons"]="Hunter Temporary Summons"
K.locales.en["uf_hunterSummons"]="Show Active Hunter Summons"
K.locales.en["uf_hunterSummonSize"]="Summon Icon Size"
K.locales.en["uf_hunterSummonGap"]="Summon Icon Spacing"
K.locales.en["uf_hunterSummonX"]="Summons: Horizontal Position"
K.locales.en["uf_hunterSummonY"]="Summons: Vertical Position"
K.locales.en["ufHunterSummonsHelp"]="Shows active temporary summons, such as Hawks, using Blizzard’s totem-slot data and remaining times. Hunter only; separate from auras and your permanent pet. The preview shows two examples. Position is relative to the player frame’s bottom-left corner."

-- Independent damage-meter border edges.
K.locales.en["dmEdgeTop"]="Top Edge Adjustment"
K.locales.en["dmEdgeBottom"]="Bottom Edge Adjustment"
K.locales.en["dmEdgeLeft"]="Left Edge Adjustment"
K.locales.en["dmEdgeRight"]="Right Edge Adjustment"
K.locales.en["dmEdgeHelp"]="Positive moves only this edge outward; negative moves it inward. Added to the general border offset; the total cannot fall below zero. Applies outside combat."

-- Optional independent minimap icon drawer.
K.locales.en["mbTitle"]="Minimap Addon Icons"
K.locales.en["mbEnabled"]="Collect Icons in Panel"
K.locales.en["mbLocked"]="Lock Panel Button"
K.locales.en["mbColumns"]="Icons per Row"
K.locales.en["mbSize"]="Icon Size"
K.locales.en["mbAngle"]="Button Position around Map"
K.locales.en["mbRadius"]="Distance from Map"
K.locales.en["mbCount"]="addon icons"
K.locales.en["mbClick"]="Left click: icon panel. Right click: Class Design settings. Unlock to drag the button around the map."
K.locales.en["mbHelp"]="Collects supported addon icons whose minimap display is enabled. Hidden icons, mouseover-only icons and map pins are excluded. Turning this off restores previous positions. Change settings outside combat."
K.locales.en["mbConflict"]="MinimapButtonButton is active. KerimAnka is waiting to avoid two collectors moving the same icons. Disable MinimapButtonButton in the addon list, then /reload."

-- Dedicated minimap page and per-icon collection preferences.
K.locales.en["minimap"]="Minimap"
K.locales.en["mmArtUnavailable"]="Load the KerimAnka UI Class Design module for minimap artwork settings. Coordinates and the icon panel work independently."
K.locales.en["mbPreferences"]="Icon Preferences"
K.locales.en["mbCollect"]="Collect in panel"
K.locales.en["mbPreferencesHelp"]="Turning this off returns the icon to its previous position around the minimap; it does not hide it. To hide it completely, use that addon’s minimap setting."
K.locales.en["mbEmpty"]="No visible icons to list. Enable icon collection and disable any other active collector first."
K.locales.en["mbClick"]="Left click: icon panel. Right click: Minimap settings. Unlock to drag the button around the map."

-- Independent icon-drawer button art and size.
K.locales.en["mbAppearance"]="Panel Button Appearance"
K.locales.en["mbRound"]="Round"
K.locales.en["mbSquare"]="Square"
K.locales.en["mbButtonSize"]="Panel Button Size"
K.locales.en["mbSize"]="Addon Icon Size in Panel"

-- Optional full-icon action range coloring.
K.locales.en["arEnabled"]="Tint Out-of-Range Abilities"
K.locales.en["arColor"]="Range Color"
K.locales.en["arReset"]="Reset to Default Red"
K.locales.en["arHelp"]="Tints the entire ability icon when out of range, independently of hotkey visibility. Restores the normal game color when in range. Supports Blizzard and Bartender action bars; pet bars are separate."

K.locales.en["mbBlockedTitle"]="Icon collection unavailable: MinimapButtonButton is loaded"
K.locales.en["mbBlockedHelp"]="MinimapButtonButton manages the same icons. KerimAnka icon collection is therefore inactive and its enable switch is unavailable. To use the KerimAnka panel, disable MinimapButtonButton in the addon list and /reload. Map artwork and coordinates are unaffected; panel preferences are preserved."

K.locales.en["artSkinAncestral"]="Ancestral Totems"
K.locales.en["artSkinElements"]="Four Elements"
K.locales.en["shamanArtTitle"]="Shaman — Class Artwork"
K.locales.en["shamanArtHelp"]="Ancestral Totems is the default; choose Four Elements above. Positive edge expansion moves that side outward; negative moves inward. Side columns and the central emblem keep their proportions; only the bottom connecting spans stretch. The top trim is independently adjustable."
K.locales.en["art_shamanBackingEnabled"]="Show Dark Backing"
K.locales.en["art_shamanBackingAlpha"]="Backing Opacity"
K.locales.en["art_shamanRailEnabled"]="Show Top Trim"
K.locales.en["art_shamanRailX"]="Top Trim Horizontal Offset"
K.locales.en["art_shamanRailY"]="Top Trim Vertical Offset"
K.locales.en["art_shamanRailWidth"]="Top Trim Width (%)"
K.locales.en["art_shamanRailHeight"]="Top Trim Height (%)"

K.locales.en["art_shamanLeftSpread"]="Left Edge Expansion"

K.locales.en["art_shamanRightSpread"]="Right Edge Expansion"

K.locales.en["art_mageBackingEnabled"]="Show Dark Backing"
K.locales.en["art_mageBackingAlpha"]="Backing Opacity"
K.locales.en["art_mageRailEnabled"]="Show Top Trim"
K.locales.en["art_mageRailX"]="Top Trim Horizontal Offset"
K.locales.en["art_mageRailY"]="Top Trim Vertical Offset"
K.locales.en["art_mageRailWidth"]="Top Trim Width (%)"
K.locales.en["art_mageRailHeight"]="Top Trim Height (%)"
K.locales.en["art_mageLeftSpread"]="Left Edge Expansion"
K.locales.en["art_mageRightSpread"]="Right Edge Expansion"
K.locales.en["artSkinMageArcane"]="Arcane — Violet Crystal"
K.locales.en["artSkinMageFire"]="Fire — Ember Forge"
K.locales.en["artSkinMageFrost"]="Frost — Crystal Seal"
K.locales.en["mageArtTitle"]="Mage Artwork"
K.locales.en["mageArtHelp"]="All four styles share one layout. Adjust the top rail and side edges independently. Your choice is independent of specialization."

K.locales.en["artSkinMageAcademy"]="Mage Academy — Threefold Seal"

K.locales.en["art_priestBackingEnabled"]="Show Dark Backing"
K.locales.en["art_priestBackingAlpha"]="Backing Opacity"
K.locales.en["art_priestRailEnabled"]="Show Top Trim"
K.locales.en["art_priestRailX"]="Top Trim Horizontal Offset"
K.locales.en["art_priestRailY"]="Top Trim Vertical Offset"
K.locales.en["art_priestRailWidth"]="Top Trim Width (%)"
K.locales.en["art_priestRailHeight"]="Top Trim Height (%)"
K.locales.en["art_priestLeftSpread"]="Left Edge Expansion"
K.locales.en["art_priestRightSpread"]="Right Edge Expansion"
K.locales.en["artSkinPriestLight"]="Sanctuary of Light — Holy / Discipline"
K.locales.en["artSkinPriestShadow"]="Eclipse Chapel — Shadow"
K.locales.en["priestArtTitle"]="Priest Artwork"
K.locales.en["priestArtHelp"]="Both styles share one layout. Adjust the top rail and side edges independently. Your choice is independent of specialization."

K.locales.en["art_druidBackingEnabled"]="Show Dark Backing"
K.locales.en["art_druidBackingAlpha"]="Backing Opacity"
K.locales.en["art_druidRailEnabled"]="Show Top Trim"
K.locales.en["art_druidRailX"]="Top Trim Horizontal Offset"
K.locales.en["art_druidRailY"]="Top Trim Vertical Offset"
K.locales.en["art_druidRailWidth"]="Top Trim Width (%)"
K.locales.en["art_druidRailHeight"]="Top Trim Height (%)"
K.locales.en["art_druidLeftSpread"]="Left Edge Expansion"
K.locales.en["art_druidRightSpread"]="Right Edge Expansion"
K.locales.en["artSkinDruidGrove"]="Ancient Grove"
K.locales.en["artSkinDruidMoon"]="Moon Guardian"
K.locales.en["artSkinDruidWild"]="Wild Heart"
K.locales.en["artSkinDruidSeasons"]="Covenant of Seasons"
K.locales.en["druidArtTitle"]="Druid Artwork"
K.locales.en["druidArtHelp"]="All four styles share one layout. Wild Heart is the default. Adjust the top rail and side edges independently. Your choice is independent of specialization and shapeshift form."

K.locales.en["imBagHelp"]="Opening Blizzard combined bags also opens an available reagent bag and keyring beside it as separate native windows. Their icons open or close those windows. Normal bag icons hide or show their own slots. This layout is disabled while using bag replacements such as Bagnon."

K.locales.en["imBagHelp"]="The reagent bag opens beside Blizzard combined bags as a separate window. Click its icon to hide or show it; the icon dims when hidden. Your choice is kept when closing and reopening bags. The keyring opens only when clicked. Normal bag icons hide or show their own slots. This layout is disabled with bag replacements such as Bagnon."

K.locales.en["imBagBackground"]="Bag Shelf Background"
K.locales.en["imBagFrame"]="Bag Shelf Frame"
K.locales.en["imBagIconBorder"]="Black Icon Borders"
K.locales.en["imBagAppearanceHelp"]="Hide the bag shelf background and decorative frame independently. Black borders apply only to the icons. Size and spacing affect all bag icons, including the reagent bag and keyring."
K.locales.en["mbShowTooltip"]="Show Launcher Tooltip"

K.locales.en["bsTitle"]="Bag Shortcut"
K.locales.en["bsHelp"]="One button to open or close your bags. Visible and locked by default, initially near the lower right. Unlock to drag it, then lock it again. Hiding the button keeps keyboard shortcuts working. Standard layouts use B and Shift+B for bags; your current bindings appear below. Change bindings in game settings."
K.locales.en["bsEnabled"]="Show Bag Shortcut"
K.locales.en["bsLocked"]="Lock Position"
K.locales.en["bsSize"]="Shortcut Icon Size"
K.locales.en["bsReset"]="Reset Position"
K.locales.en["bsAllBags"]="All bags"
K.locales.en["bsBackpack"]="Backpack"
K.locales.en["bsUnbound"]="Unbound"
K.locales.en["bsDrag"]="Drag to move."

K.locales.en["quests"]="Quest Tracker"
K.locales.en["qjNativeHelp"]="Uses the original Blizzard quest tracker appearance, icons and quest buttons. Roll the mouse wheel over its quest section to see watched quests that do not fit. The old Questie leather background and quill design have been removed."
K.locales.en["qjScrollEnabled"]="Mouse Wheel Scrolling"
K.locales.en["qjScrollStep"]="Scroll Step"
K.locales.en["qjHeightHelp"]="Change tracker position and height in game Edit Mode. This feature does not watch quests automatically; it scrolls quests already watched by Blizzard. Native layout temporarily returns in Edit Mode."
K.locales.en["qjActive"]="Scrolling is active for the Blizzard quest tracker."
K.locales.en["qjOtherTracker"]="Questie tracker is enabled. Disable its tracker in Questie settings to use the Blizzard tracker; you may keep Questie map icons."
K.locales.en["qjNativeWaiting"]="Blizzard tracker is not ready yet, or scrolling is disabled."
K.locales.en["qjUpdate"]="Adds scrolling to the Blizzard quest tracker; no Questie skin."

K.locales.en["qjGroupByZone"]="Group by Zone"
K.locales.en["qjZoneHelp"]="Groups quests under the same zone/category headers as the quest log. Click a header to collapse or expand; quests stay watched. Scrolling must be enabled for grouping. Protected quest-button layouts refresh after combat."
K.locales.en["qjNativeHelp"]="Preserves Blizzard tracker appearance, icons and quest buttons. Scroll with the mouse wheel and expand or collapse zone groups. Questie is not required."
K.locales.en["qjHeightHelp"]="Set position and height in game Edit Mode. Only Blizzard-watched quests are shown. Native layout returns temporarily in Edit Mode. List updates may wait until combat ends while protected buttons are present."

K.locales.en["backingColorTitle"]="Backing Color"
K.locales.en["backingColorHelp"]="Changes the fill behind buttons. Decorative frames and button borders are preserved."
K.locales.en["backingOriginal"]="Original look"
K.locales.en["backingCustom"]="Custom color"
K.locales.en["backingPickColor"]="Choose color"
K.locales.en["backingCream"]="Cream"
K.locales.en["backingBrown"]="Brown"
K.locales.en["backingGrey"]="Charcoal"
K.locales.en["backingBlack"]="Black"
K.locales.en["backingOpacityHelp"]="Use the backing opacity control below to adjust transparency."

K.locales.en["imBTBags"]="Bartender Bag Bar is enabled; our bag shelf is paused. Disable only Bartender → Bag Bar → Enabled to use our shelf. Action bars can remain enabled."
K.locales.en["imBTMicro"]="Bartender Micro Menu is enabled; only our micro-menu layout is paused. The bag shelf is unaffected. Disable Micro Menu in Bartender to use ours; /reload if its buttons do not return."
K.locales.en["imBTBoth"]="Bartender Bag Bar and Micro Menu are enabled. Disable only the corresponding Bartender module to use our layout; action bars can remain enabled. /reload if micro-menu buttons do not return."

K.locales.en["readyHunterTitle"]="Hunter ready layout · 1920×1080"
K.locales.en["readyHunterHelp"]="Installs the final Hunter artwork, Blizzard layout and KerimAnka UI settings together. Existing settings are backed up before a UI reload. Key bindings are preserved."
K.locales.en["readyUsesBT"]="Automatic source: creates a Bartender profile and also prepares Blizzard bars 2 and 3."
K.locales.en["readyUsesNative"]="Blizzard bars will be used; action bars 2 and 3 will be enabled."
K.locales.en["readyApplyHunter"]="Apply Hunter ready layout"
K.locales.en["readyMissing"]="No ready layout is available for this class yet."
K.locales.en["readyUnavailable"]="Required game settings are currently unavailable."
K.locales.en["readyBTUnavailable"]="This Bartender version or profile system is incompatible with the preset."
K.locales.en["readyApplyFailed"]="The ready layout could not be fully applied. Restore the backup from Profiles."

-- First-open account introduction.
K.locales.en["introReplay"]="Show introduction again"
K.locales.en["introWelcome"]="Welcome to KerimAnka UI"
K.locales.en["introWelcomeBody"]="Start in Profiles to install a ready class layout. Choose Show Profiles below, or click the highlighted Profiles button. You can skip this guide; it only appears once for this character."
K.locales.en["introProfilesTitle"]="Profiles · your starting point"
K.locales.en["introReadyBody"]="The highlighted class preset installs the 1920×1080 layout and artwork. It backs up your current settings, keeps your key bindings and reloads the UI. Close this guide, then click Apply when you are ready."
K.locales.en["introNoPresetBody"]="There is no ready preset for this class yet. You can save your current settings here or copy a compatible profile from another character. Ready class layouts will appear here when available."
K.locales.en["introSkip"]="Skip"
K.locales.en["introGoProfiles"]="Show Profiles"
K.locales.en["introDone"]="Got it"

K.locales.en["petBarBTDisabled"]="While Bartender is active, enable its Pet Bar module. Our backing follows that bar. To use Blizzard's pet bar, disable Bartender and reload the UI."

K.locales.en["hunterRange_ranged"]="RANGED"
K.locales.en["hunterRange_dead"]="DEAD ZONE"
K.locales.en["hunterRange_melee"]="MELEE"
K.locales.en["hunterRange_far"]="TOO FAR"
K.locales.en["hunterRange_close"]="TOO CLOSE"
K.locales.en["hunterRange_unknown"]="RANGE ?"
K.locales.en["hunterAspect_cheetahText"]="Cheetah active: Switch aspect!"
K.locales.en["hunterAspect_missingText"]="Choose an aspect!"
K.locales.en["hunterTextTitle"]="Custom warning text"
K.locales.en["hunterTextHelp"]="Default text follows the UI language. Your own text stays unchanged. Clear a field or reset it to use automatic language again."
K.locales.en["hunterTextReset"]="Use default"

K.locales.en["hunterHintPreview"]="PREVIEW"
K.locales.en["hunterHintMove"]="Drag to move • Lock in settings"
K.locales.en["hunterHintRangeMove"]="Drag to move • Right-click: settings"
K.locales.en["hunterRangeReady"]="Hunter Range ready. Settings: KerimAnka UI."
K.locales.en["hunterAspectReady"]="Aspect Alert ready. Settings: KerimAnka UI."
K.locales.en["hunterAspectUnknown"]="Aspect information is unavailable or restricted. The alert is hidden to avoid an incorrect warning."

K.locales.en["soundInfo"]="Sound settings are saved per character, including changes made in the game options. New characters start with the client defaults."
K.locales.en["soundMaster"]="Mute all sounds"
K.locales.en["soundShortcutTitle"]="Sound shortcut"
K.locales.en["soundShortcutShow"]="Show sound shortcut"
K.locales.en["soundShortcutLock"]="Lock sound shortcut position"
K.locales.en["soundShortcutReset"]="Reset sound shortcut position"
K.locales.en["soundShortcutTip"]="Click: music, ambience and all sounds."
K.locales.en["soundShortcutDrag"]="Click: sound menu. Drag: move shortcut."
K.locales.en["soundShortcut_music"]="Music"
K.locales.en["soundShortcut_ambience"]="Ambience"
K.locales.en["soundShortcut_all"]="All sounds"
K.locales.en["soundShortcutOn"]="On"
K.locales.en["soundShortcutOff"]="Off"
K.locales.en["soundMasterHelp"]=K.locales.en["soundInfo"]
K.locales.en["soundShortcutShowHelp"]=K.locales.en["soundInfo"]
K.locales.en["soundShortcutLockHelp"]=K.locales.en["soundInfo"]
K.locales.en["soundShortcutResetHelp"]=K.locales.en["soundInfo"]

K.locales.en["imCombinedBags"]="Use combined bags"
K.locales.en["imCombinedBagsHelp"]="Saved per character. New characters use combined bags. Native game settings and the bag menu also update this preference. The checkbox and actual bag layout are restored together. Bag replacements such as Bagnon keep control."

K.locales.en["qjSafetyPaused"]="Quest tracker enhancements temporarily paused"
K.locales.en["qjSafetyHelp"]="Blizzard's original tracker remains active. Zone grouping and mouse-wheel scrolling are paused because they tainted Edit Mode and restricted aura updates. Saved preferences are retained."
K.locales.en["readyMeterStageRequired"]="Meter setup must be prepared before reload. Apply the class ready layout again."
K.locales.en["readyMeterPrepareFailed"]="Meter preparation failed. Cancel the queued profile and reload before retrying."

K.locales.en["qjNativeHelp"]="Groups Blizzard-watched quests by zone and adds mouse-wheel scrolling. Rows use an independent view without replacing shared Blizzard layout modules. Click a quest to open it on the map; use its item from the adjacent icon."
K.locales.en["qjHeightHelp"]="Set position and height in game Edit Mode. Native appearance returns while editing. List updates and scrolling wait until combat ends because quest item buttons are protected."

K.locales.en["fpsTitle"]="FPS Display"
K.locales.en["fpsShow"]="Show FPS Display"
K.locales.en["fpsLock"]="Lock FPS Position"
K.locales.en["fpsReset"]="Reset FPS Position"
K.locales.en["fpsShowHelp"]="Displays the game’s FPS value. Saved per character; MoveAny is not required."
K.locales.en["fpsLockHelp"]="Turn off to drag the FPS display with the left mouse button. Locked displays allow mouse clicks to pass through."
K.locales.en["fpsHomeHelp"]="Defaults to the right, above the XP and damage meter area. Unlock, drag, then lock again. If using MoveAny, disable its FPS option. The game’s Ctrl+R counter is separate."

K.locales.en["readyRogueTitle"]="Rogue ready layout · 1920×1080"

K.locales.en["readyRogueHelp"]="Installs the final Rogue artwork, Blizzard layout and KerimAnka UI settings together. Existing settings are backed up before a UI reload. Key bindings are preserved."

K.locales.en["readyApplyRogue"]="Apply Rogue ready layout"

K.locales.en["readyBTDeferredFailed"]="Automatic Bartender setup failed. Your previous profile was kept. You can retry by applying the class ready layout in Profiles."

K.locales.en["ftPreviewHint"]="PREVIEW - Drag / right-click: settings"
K.locales.en["ftDragHint"]="Drag / right-click: settings"

K.locales.en["art_paladinBackingEnabled"]="Show Dark Backing"
K.locales.en["art_paladinBackingAlpha"]="Backing Opacity"
K.locales.en["art_paladinRailEnabled"]="Show Top Trim"
K.locales.en["art_paladinRailX"]="Top Trim Horizontal Offset"
K.locales.en["art_paladinRailY"]="Top Trim Vertical Offset"
K.locales.en["art_paladinRailWidth"]="Top Trim Width (%)"
K.locales.en["art_paladinRailHeight"]="Top Trim Height (%)"
K.locales.en["art_paladinLeftSpread"]="Left Edge Expansion"
K.locales.en["art_paladinRightSpread"]="Right Edge Expansion"
K.locales.en["artSkinPaladinAlliance"]="Alliance · Silver Hand"
K.locales.en["artSkinPaladinHorde"]="Horde · Blood Knight"
K.locales.en["paladinArtTitle"]="Paladin Artwork"
K.locales.en["paladinArtHelp"]="Faction selects the initial style. You can use either style; action bars, minimap and unit frames change together. The top rail and backing are independently adjustable."

K.locales.en["art_paladinBottomHeight"]="Bottom Rail Thickness"

K.locales.en["art_paladinRailHeight"]="Top Rail Thickness"
K.locales.en["paladinArtHelp"]="A connected frame fitted outside the selected buttons. Width, height and position adjust the whole frame; corner joints stay connected. Upper and lower thickness are adjustable. Faction selects the initial style; either style is available."

K.locales.en["readyPaladinTitle"]="Paladin ready layout · 1920×1080"

K.locales.en["readyPaladinHelp"]="Installs the final Paladin artwork, Blizzard layout and KerimAnka UI settings together. Existing settings are backed up before a UI reload. Key bindings are preserved."

K.locales.en["readyApplyPaladin"]="Apply Paladin ready layout"

K.locales.en["qjQuestieTracker"]="Use Questie quest tracker"

K.locales.en["qjQuestieHelp"]="Off by default to avoid duplicate trackers. Map and minimap markers remain available. Changes take effect after reloading the UI."

K.locales.en["qjQuestieReload"]="Reload the UI to apply the Questie tracker choice."

K.locales.en["introWelcomeBody"]="Start here: open Profiles and apply the ready layout for your class.\n\nClass artwork and extra displays start OFF until you choose a layout or enable them yourself. This guide appears once per character."

K.locales.en["introReadyBody"]="Apply your class ready layout with the button below. It installs the 1920×1080 layout, artwork and saved settings together.\n\nYour current settings are backed up and key bindings are preserved. Positions start LOCKED. The interface reloads after applying."

K.locales.en["introNoPresetBody"]="This class does not have a ready layout yet.\n\nEnable and arrange the modules you want, or import a compatible profile. Positions start locked; unlock a module only while moving it."

K.locales.en["introSkip"]="Set up manually"

K.locales.en["ufMoveHelp"]="To move live unit frames: turn OFF Lock Positions, then hold ALT and drag with the LEFT mouse button outside combat. Turn the lock back ON when finished. Unlocking alone does not start dragging."

K.locales.en["introPreparedTitle"]="Ready to finish"

K.locales.en["introPreparedBody"]="Your layout is prepared and the backup is saved.\n\nClick Reload and Finish below to complete setup. This is a separate click so the game receives the reload request directly. Cancel restores the prepared changes."

K.locales.en["introReload"]="Reload and Finish"

K.locales.en["introReadyBody"]="Apply your class ready layout with the button below. It prepares the 1920×1080 layout, artwork and saved settings together.\n\nYour current settings are backed up and key bindings are preserved. Positions start LOCKED. The next step asks you to reload and finish."

K.locales.en["introCancel"]="Cancel setup"

K.locales.en["artSkinWarriorAlliance"]="Alliance · Iron Vanguard"
K.locales.en["artSkinWarriorHorde"]="Horde · Iron Vanguard"
K.locales.en["artSkinWarriorIron"]="Black Iron · Action Bar Only"
K.locales.en["artSkinWarriorArena"]="Arena · Action Bar Only"
K.locales.en["art_backingRailEnabled"]="Show Top Trim"
K.locales.en["artSkinWarriorHelp"]="Alliance and Horde switch the action bar, minimap, unit frames and damage meter together. Black Iron and Arena change only the action bar and keep the last faction palette. Initially the character faction is used."

K.locales.en["plLegacy"]="Legacy record: KerimAnka UI only. Visit and log out of the source character once to capture Blizzard/Bartender."
K.locales.en["plBoth"]="Applies KerimAnka UI + last saved Blizzard layout + Bartender profile."
K.locales.en["plEdit"]="Applies KerimAnka UI + last saved Blizzard layout."
K.locales.en["plBT"]="Applies KerimAnka UI + last saved Bartender profile."
K.locales.en["plInvalid"]="Invalid layout snapshot. Save a new record on the source character."
K.locales.en["plBTIncompatible"]="The saved Bartender version or modules are incompatible with this installation."
K.locales.en["plBTFailed"]="The saved Bartender profile could not be applied. The previous Bartender profile was kept."
K.locales.en["pfIntro"]="Character records update on login, when opening Profiles, and at logout. Apply copies the last saved KerimAnka UI, Blizzard and available Bartender layouts. Visit old source characters once to complete their records. Named profiles keep their saved snapshot."
K.locales.en["pfApplyWarning"]="Applies the selected KerimAnka UI settings and any saved Blizzard/Bartender layouts. Your previous layout is backed up. Confirm, then reload the UI."
K.locales.en["pfTransferHelp"]="Code transfer contains KerimAnka UI settings only. Blizzard/Bartender transfer is included when applying a saved profile above."
K.locales.en["pfTransfer"]="Code Transfer · KerimAnka UI Only"

K.locales.en["plNativeName"]="Blizzard layout: %s"

K.locales.en["readyWarriorTitle"]="Warrior ready layout · 1920×1080"

K.locales.en["readyWarriorHelp"]="Installs the final Warrior artwork, Blizzard layout and KerimAnka UI settings together. Existing settings are backed up before a UI reload. Key bindings are preserved."

K.locales.en["readyApplyWarrior"]="Apply Warrior ready layout"

K.locales.en["ufShamanTotems"]="Shaman Totems"

K.locales.en["uf_shamanTotems"]="Show Active Totems"

K.locales.en["uf_shamanTotemSize"]="Totem Icon Size"

K.locales.en["uf_shamanTotemGap"]="Totem Spacing"

K.locales.en["uf_shamanTotemX"]="Totems: Horizontal Position"

K.locales.en["uf_shamanTotemY"]="Totems: Vertical Position"

K.locales.en["ufShamanTotemsHelp"]="Moves Blizzard’s active totem display below the player frame. The game handles icons, remaining times and totem interactions, including totems that do not grant a player buff. The preview shows four examples. Position is relative to the player frame’s bottom-left corner."

K.locales.en["readyShamanTitle"]="Shaman ready layout · 1920×1080"

K.locales.en["readyShamanHelp"]="Installs the final Shaman artwork, Blizzard layout and KerimAnka UI settings together. Existing settings are backed up before a UI reload. Key bindings are preserved."

K.locales.en["readyApplyShaman"]="Apply Shaman ready layout"

K.locales.en["readyWarlockTitle"]="Warlock ready layout · 1920×1080"

K.locales.en["readyWarlockHelp"]="Installs the final Warlock artwork, Blizzard layout and KerimAnka UI settings together. Existing settings are backed up before a UI reload. Key bindings are preserved."

K.locales.en["readyApplyWarlock"]="Apply Warlock ready layout"

K.locales.en["readyMageTitle"]="Mage ready layout · 1920×1080"

K.locales.en["readyMageHelp"]="Installs the final Mage artwork, Blizzard layout and KerimAnka UI settings together. Existing settings are backed up before a UI reload. Key bindings are preserved."

K.locales.en["readyApplyMage"]="Apply Mage ready layout"

K.locales.en["readyPriestTitle"]="Priest ready layout · 1920×1080"

K.locales.en["readyPriestHelp"]="Installs the final Priest artwork, Blizzard layout and KerimAnka UI settings together. Existing settings are backed up before a UI reload. Key bindings are preserved."

K.locales.en["readyApplyPriest"]="Apply Priest ready layout"

K.locales.en["readyDruidTitle"]="Druid ready layout · 1920×1080"

K.locales.en["readyDruidHelp"]="Installs the final Druid artwork, Blizzard layout and KerimAnka UI settings together. Existing settings are backed up before a UI reload. Key bindings are preserved."

K.locales.en["readyApplyDruid"]="Apply Druid ready layout"

K.locales.en["readyConfirmWarning"]="Your current settings will be backed up and replaced with the ready layout, then the UI will reload. Confirm to continue."

K.locales.en["readyConfirmApply"]="Confirm and Apply"

K.locales.en["readyConfirmCancel"]="Cancel"

K.locales.en["pfSelectedHint"]="Click to apply this record. You will be asked to confirm before continuing."

K.locales.en["pfPendingActions"]="Your settings are ready. Reload the UI to apply them, or cancel the pending change."

-- Unit Frames: options, auras, summon rows, preview and help.
K.locales.en["upElite"]="ELITE"

-- Experience and Reputation: widget, text, colors, preview and help.
K.locales.en["xpSampleFaction"]="Sample faction"
K.locales.en["xpSamplePet"]="Sample pet"

-- Profiles: saved records, transfer, undo, class presets and help.
K.locales.en["pfStorageHelp"]="Up to 32 named profiles and 64 character records; 2 MiB total, including Blizzard/Bartender layouts. Character records replace their previous version when updated. Oldest character records may be removed when full; named profiles are never automatically removed. The undo backup is separate."

-- Clarify copy sources, sound preset and shared artwork color controls.
K.locales.en["pfSourceHint"]="The selected record is a copy source. Character-specific changes here do not change the source record. Panel appearance is shared across characters."
K.locales.en["clicksHelp"]="Mutes six preset ability error and click sound files. Spoken error messages are controlled separately."
K.locales.en["backingColorHelp"]="Changes the class artwork background behind action buttons. Decorative frames and button borders are preserved. This is the same setting shown under Class Art and Bar Backdrop."

-- Custom sound muting: per-character state, honest test results and preview controls.
K.locales.en["custom"]="Custom Sound Muting"
K.locales.en["customHelp"]="Add numeric sound file IDs, separated by commas or spaces. Adding a file requests muting automatically for this character. Use file IDs, not sound-kit IDs. A sound event can use more than one file. Listen temporarily bypasses muting; Test does not."
K.locales.en["empty"]="No custom sounds selected for muting."
K.locales.en["soundCustomInfo"]="Adding a number enables muting for this character. Listen bypasses muting for the preview. Test tries playback with muting kept in place; it should be silent."
K.locales.en["soundMuteActive"]="Muting enabled"
K.locales.en["soundMuteFailed"]="Muting could not be applied"
K.locales.en["soundMuteUnavailable"]="Muting unavailable"
K.locales.en["soundMuteTest"]="Test mute"
K.locales.en["soundTestPlayed"]="The test started playback. If you hear it, this file is not being muted. Check the number and other sound addons."
K.locales.en["soundTestSilent"]="Playback did not start. This is consistent with muting, but closed sound channels or an invalid file can give the same result. Use Listen to check the file."
K.locales.en["soundAdded"]="Sound IDs saved for this character. Check each row for the muting status."
K.locales.en["soundRemoved"]="Removed from custom muting. A preset or another addon may still mute the same file."
K.locales.en["stopPreview"]="Stop Preview"
K.locales.en["stopPreviewHelp"]="Stops only playback started here with Listen or Test. It does not turn muting on or off."

-- Small curated sound groups; no automatic muting.
K.locales.en["sgTitle"]="Ready Sound Groups"
K.locales.en["sgHelp"]="Groups manage the same per-character custom sound list. Mute adds their files; Restore removes them. Shared files can also affect other players’ sounds. No group is enabled automatically."
K.locales.en["sgBow"]="Bow draw"
K.locales.en["sgBowHelp"]="Three bow draw variations. Arrow release and impact sounds remain."
K.locales.en["sgGun"]="Gunfire"
K.locales.en["sgGunHelp"]="Three classic gunshot variations. Reload sounds have their own group."
K.locales.en["sgReload"]="Gun reload"
K.locales.en["sgReloadHelp"]="The mechanism and reload sounds before a shot. Gunfire has its own group."
K.locales.en["sgWand"]="Wand launch"
K.locales.en["sgWandHelp"]="Launch sounds for different wand magic types. Target impact sounds may remain."
K.locales.en["sgEnabled"]="Muting on"
K.locales.en["sgPartial"]="Partially muted"
K.locales.en["sgDisabled"]="Muting off"
K.locales.en["sgFailed"]="The action could not be completed."
K.locales.en["sgMuted"]="The group was added to custom muting."
K.locales.en["sgRestored"]="The group’s files were removed from the custom list. Another setting or addon may still mute them."
K.locales.en["sgVerified"]="Confirmed in Forever"
K.locales.en["sgPending"]="In-game confirmation pending"
K.locales.en["sgListenHelp"]="Each click previews the next file. Open Show Files to listen to individual variations."
K.locales.en["sgUnmute"]="Restore"
K.locales.en["sgMute"]="Mute"
K.locales.en["sgHideFiles"]="Hide Files"
K.locales.en["sgFiles"]="Show Files"

-- Community links and copy window.
K.locales.en["communityGithubTitle"]="GitHub · Bugs and suggestions"
K.locales.en["communityGithubHelp"]="Project, updates and bug reports. Open the link and copy the address."
K.locales.en["communityTwitchTitle"]="Twitch · Live streams"
K.locales.en["communityTwitchHelp"]="Watch KerimAnka. Stream language: Turkish. Use GitHub for bug reports."
K.locales.en["communityPending"]="The GitHub project page has not been created yet. Its address will be added in a future update."
K.locales.en["communityCopy"]="Ctrl+C to copy · Esc to close"
K.locales.en["communityReloadWaiting"]="Add-on changes pending · Reload to apply."
