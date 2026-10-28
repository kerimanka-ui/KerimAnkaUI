-- Classic Era/Hardcore only: no execution in Forever or Retail.
if not WOW_PROJECT_CLASSIC or WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end
-- UTF-8 panel translations. Missing entries fall back to English.
local _,K=...
K.locales.de = {
 ["uf_nameOffsetY"]="Name vertikal verschieben",
 ["uf_petTextScale"]="Schriftgröße des Begleiters",
 ["art_petBar"]="Begleiter-Aktionsleiste",
 ["art_petPanelEnabled"]="Hintergrund der Begleiterleiste anzeigen",
 ["art_petPanelAlpha"]="Deckkraft der Begleiterleiste",
 ["art_petPanelPadding"]="Randabstand der Begleiterleiste",
 ["warlockArtTitle"]="Hexenmeister — Klassendesign",
 ["artSkinFel"]="Felobsidian",
 ["artSkinRitual"]="Seelenritual",
 ["art_ritualRailWidth"]="Breite der oberen Leiste (%)",
 ["art_ritualRailX"]="Obere Leiste horizontal verschieben",
 ["warlockRitualTitle"]="Hexenmeister — Seelenritual",
 ["warlockRitualHelp"]="Oben zwischen Seelenritual und Felobsidian wählen. Untere Symbole behalten ihre Proportionen; die Position wird über den allgemeinen vertikalen Versatz eingestellt. Die obere Leiste ist unabhängig. Der dunkle Hintergrund folgt den ausgewählten Aktionsleisten.",
 ["art_ritualBacking"]="Dunklen Hintergrund anzeigen",
 ["art_ritualOpacity"]="Hintergrunddeckkraft",
 ["art_ritualDock"]="Unteres Ornament am Bildschirmrand andocken",
 ["art_ritualInset"]="Abstand zum unteren Bildschirmrand",
 ["art_ritualRail"]="Unabhängige obere Leiste anzeigen",
 ["art_ritualRailY"]="Obere Leiste vertikal verschieben",
 ["art_ritualRailHeight"]="Höhe der oberen Leiste",
 ["flAppliedCharacter"]="Profil und charakterspezifisches Blizzard-Layout übernommen. Die Layoutauswahl anderer Charaktere bleibt unverändert. Prüfe Aktionsleisten und Schadenanzeige. Vorherige Einstellungen wiederherstellen nimmt beide Teile zurück.",
 ["flAccountPlan"]="Geltungsbereich: Account — auch auf anderen Charakteren auswählbar.",
 ["flCharacterPlan"]="Geltungsbereich: Nur dieser Charakter — auch bei vollen Accountplätzen nutzbar.",
 ["flTitle"]="Gesamte Oberfläche — Gemeinsames Blizzard-Layout",
 ["flHelp"]="Übernimmt das gewählte KerimAnka-UI-Profil und das Blizzard-Layout für 1920 × 1080. Verwendet ein passendes KerimAnka-UI-Layout oder erstellt ein accountweites Layout. Sind Accountplätze voll, wird es charakterspezifisch erstellt. Der Geltungsbereich steht unten. Klassenverzierungen werden getrennt bestimmt.",
 ["flChecklist"]="Prüfe anschließend, ob die benötigten Aktionsleisten und die Schadenanzeige aktiv sind. Der Code garantiert weder Leistensichtbarkeit noch Tastenzuweisungen oder alle Spieleinstellungen. Prüfe bei anderer Auflösung oder UI-Skalierung die Positionen.",
 ["flApply"]="Gewähltes Profil + Blizzard-Layout",
 ["flWarning"]="Nach dem Neuladen werden das gewählte Addon-Profil und das Blizzard-Layout im unten angegebenen Geltungsbereich übernommen. Vorherige Einstellungen und Wiederherstellungsdaten des aktiven Layouts werden gesichert. Keine Layouts werden gelöscht. Erneut bestätigen, danach die Oberfläche neu laden.",
 ["flUnavailable"]="Blizzards Layoutsystem ist noch nicht bereit oder wird nicht unterstützt. Nichts wurde vorgemerkt. Öffne und schließe den Bearbeitungsmodus und versuche es erneut.",
 ["flCloseEdit"]="Speichere oder verwirf Änderungen im Blizzard-Bearbeitungsmodus und schließe ihn, bevor du es erneut versuchst.",
 ["flInvalid"]="Blizzard konnte diesen Layoutcode nicht lesen. Nichts wurde vorgemerkt; prüfe die Kompatibilität mit dieser Spielversion.",
 ["flFull"]="Kein freier Platz in der gewählten Layoutkategorie. Account- und Charakterplätze zählen getrennt. Keine Layouts wurden gelöscht; prüfe die Liste im Bearbeitungsmodus.",
 ["flFailed"]="Das Blizzard-Layout konnte nicht übernommen werden. Das Addon-Profil wurde möglicherweise übernommen; die vorherigen Einstellungen sind gesichert. Mit „Vorherige Einstellungen wiederherstellen“ kannst du zurückkehren.",
 ["flApplied"]="Profil und Blizzard-Layout übernommen. Prüfe Aktionsleisten und Schadenanzeige. Die Wiederherstellung setzt vorherige Addon-Einstellungen zurück und wählt das vorherige Blizzard-Layout.",
 ["aaCheetah"]="Geparden-Warntext",
 ["aaEnabled"]="Aspektwarnungen aktivieren",
 ["aaGlow"]="Geparden-Leuchten im Kampf",
 ["aaHelp"]="Steuert die geladene Warnung getrennt vom Laden des Addons. Unterdrückung bei ungelernten Aspekten und Reisen bleibt erhalten. Entsperren zeigt ein Platzierungsbeispiel; anschließend wieder sperren.",
 ["aaLive"]="Zur Live-Warnung zurück",
 ["aaLock"]="Position sperren",
 ["aaMissing"]="Text bei fehlendem Aspekt",
 ["aaNote"]="Einstellungen gelten nun für diesen Charakter. Bisherige gemeinsame Werte werden bei erster Nutzung kopiert. Zum Platzieren entsperren und ziehen.",
 ["aaCombatNoticeTitle"]="Beta: Aspektverfolgung im Kampf",
 ["aaCombatNotice"]="Die Erkennung funktioniert außerhalb des Kampfes. Im Kampf schränkt das Spiel Buffinformationen ein: Ein anfänglicher Zustand oder Wechsel wird eventuell erkannt, spätere Änderungen jedoch nicht. Die Warnung kann verschwinden. Keine Warnung bedeutet nicht, dass kein Aspekt aktiv ist. Prüfe deinen Aspekt anhand der Buff-/Aurasymbole des Spiels. Diese Funktion entstand während der Beta; Einschränkungen und Verhalten des Spiels können sich ändern.",
 ["aaOriginal"]="Bisherige Aspekteinstellungen öffnen",
 ["aaPreview"]="Geparden-Vorschau",
 ["aaPreviewHelp"]="Zeigt ein vorübergehendes Beispiel auf der echten Warnung. Zuerst die Warnung aktivieren. Seitenwechsel oder Schließen beendet das Beispiel. Entsperrt bleibt ggf. das Platzierungsbeispiel sichtbar. Reiseunterdrückung bleibt aktiv.",
 ["aaPreviewMissing"]="Fehlender Aspekt: Vorschau",
 ["aaRefresh"]="Werte aktualisieren",
 ["aaResetPosition"]="Warnposition zurücksetzen",
 ["aaResetTexts"]="Standardwarntexte wiederherstellen",
 ["aaText"]="Warntext anzeigen",
 ["aaTextHelp"]="Eigener Warntext mit bis zu 100 Zeichen. Änderungen werden beim Tippen gespeichert. Der Text gilt für diesen Charakter; ein Sprachwechsel übersetzt eigene Warntexte nicht.",
 ["aaUpdate"]="Das mitgelieferte HunterAspectAlert-Update für diese Einstellungen installieren.",
 ["abAdvanced"]="Bisherige erweiterte Einstellungen",
 ["abAlpha"]="Deckkraft des Designs",
 ["abArt"]="Klassendesign anzeigen",
 ["abArtHelp"]="Ändert das bestehende Klassendesign. Breite/Höhe in Prozent. Positives X verschiebt nach rechts, positives Y nach oben. Automatik folgt den ausgewählten Leisten. Rückkehr zur Automatik setzt Breite/Höhe auf 100%.",
 ["abAuto"]="Leisten automatisch folgen",
 ["abBar"]="Leiste",
 ["abBars"]="Betroffene Bartender-Leisten",
 ["abBorder"]="Äußerer Rand",
 ["abFixed"]="Feste Größe und Position",
 ["abFollow"]="Wieder an Leisten anpassen",
 ["abGap"]="Abstand zu den Leisten",
 ["abHeight"]="Designhöhe (%)",
 ["abHelp"]="Änderungen außerhalb des Kampfes. Mindestens eine Leiste auswählen. Helligkeit: 0 = schwarz, 1 = Originalfarbe. Randgröße 0 blendet den äußeren Rand aus.",
 ["abIntro"]="Einstellungen gelten für diesen Charakter. Leisten und Tastenzuweisungen werden je nach gewählter Quelle über die Spieleinstellungen oder Bartender angepasst.",
 ["abLock"]="Aktuelle Größe und Position fixieren",
 ["abMin"]="Mindestens eine Leiste auswählen.",
 ["abMode"]="Aktueller Modus: ",
 ["abShade"]="Helligkeit der Tastenrahmen",
 ["abShow"]="Tastenhintergrund anzeigen",
 ["abSlot"]="Deckkraft leerer Plätze",
 ["abUnsupported"]="Für diesen Charakter gibt es noch kein Klassendesign.",
 ["abUpdate"]="Das mitgelieferte ForeverBarBackdrop-Update installieren, um diese Einstellungen zu nutzen.",
 ["abWidth"]="Designbreite (%)",
 ["abX"]="Horizontaler Versatz",
 ["abY"]="Vertikaler Versatz",
 ["active"]="Aktiv",
 ["add"]="Hinzufügen",
 ["addonChangeFailed"]="Addon-Änderung fehlgeschlagen:",
 ["addonChanging"]="Die Addon-Änderung wird noch geprüft.",
 ["addonControl"]="Addon laden",
 ["addonControlHelp"]="Ändert die tatsächliche Addonliste dieses Charakters. Nach Änderungen neu laden. Die Designschalter oben steuern das Aussehen des geladenen Addons separat.",
 ["addonStateUnknown"]="Addonstatus konnte nicht gelesen werden",
 ["alerts"]="Warnungen",
 ["ambience"]="Umgebung stummschalten",
 ["ambienceHelp"]="Deaktiviert Hintergrundgeräusche wie Wind und Wasser.",
 ["art"]="Klassenkunst",
 ["artSkinHelp"]="Designvorschau und Auswahl für diesen Charakter. Änderungen außerhalb des Kampfes. Minimap und Einheitenrahmen behalten ihr Design. Die Auswahl wird im Profil gespeichert.",
 ["artSkinHunter"]="Jäger",
 ["artSkinMetal"]="Schlichtes Metall",
 ["artSkinSelected"]="Ausgewählt",
 ["artSkinUse"]="Design verwenden",
 ["artSkins"]="Aktionsleisten-Design",
 ["art_alpha"]="Rahmendeckkraft",
 ["art_artConfirm"]="Zum Bestätigen erneut klicken",
 ["art_artExtraHelp"]="Änderungen gelten für diesen Charakter. Diese Optionen ändern das Design, nicht die Tastenanordnung. Nicht verfügbare Optionen sind abgedunkelt.",
 ["art_artReset"]="Design zurücksetzen",
 ["art_backing"]="Aktionsleisten-Hintergrund und obere Zierleiste",
 ["art_center"]="Timer und Begleiterleiste verzieren",
 ["art_centerPadding"]="Abstand des mittleren Rahmens",
 ["art_edge"]="Eckengröße",
 ["art_enabled"]="Aktiviert",
 ["art_hideBorder"]="Blizzard-Minimap-Rand ausblenden",
 ["art_hideBorderHelp"]="Blendet nur den Blizzard-Rand der Minimap aus. Greifen an den Aktionsleisten und Bartender-Grafiken werden nicht verändert. Blendet ein anderes Addon den Rand aus, kann er auch bei ausgeschalteter Option verborgen bleiben.",
 ["art_hunterHUD"]="Jäger-HUD",
 ["art_hunterMatte"]="Mattes Jäger-Design",
 ["art_minimap"]="Minimap-Design",
 ["art_opacity"]="Deckkraft des Hintergrunds",
 ["art_padding"]="Rahmenabstand",
 ["art_rail"]="Höhe der oberen Leiste",
 ["art_railY"]="Versatz der oberen Leiste",
 ["art_reset"]="Minimap-Standardwerte",
 ["art_resource"]="Persönliche Ressourcenanzeige ausblenden",
 ["art_size"]="Rahmengröße (%)",
 ["art_units"]="Blizzard-Einheitenrahmen verzieren",
 ["art_x"]="Horizontaler Versatz",
 ["art_y"]="Vertikaler Versatz",
 ["aspect"]="Aspektwarnung",
 ["backdrop"]="Aktionsleisten-Hintergrund",
 ["background"]="Im Hintergrund stummschalten",
 ["backgroundHelp"]="Stoppt die Spielklänge, wenn das Spielfenster nicht aktiv ist.",
 ["badgeDisable"]="Klicken, um dieses Addon für den Charakter zu deaktivieren.",
 ["badgeEnable"]="Klicken, um dieses Addon für den Charakter zu aktivieren.",
 ["badgeHelp"]="Grün: Das Addon ist geladen. Die eigene Anzeige kann trotzdem ausgeschaltet sein. Gedimmt: deaktiviert oder nicht geladen. Gelb: Ladeänderung wartet auf Neuladen.",
 ["barsAuto"]="Automatisch",
 ["barsBT"]="Bartender",
 ["barsBTActive"]="Bartender-Leisten aktiv. Die bisherigen Bartender-Designeinstellungen bleiben erhalten.",
 ["barsConflict"]="Bartender verwaltet/versteckt die Blizzard-Leisten noch. Bartender in der Addonliste deaktivieren und neu laden.",
 ["barsEditor"]="Blizzard-Bearbeitungsmodus öffnen",
 ["barsLocked"]="Im festen Modus werden Leisten nicht verfolgt. Oben Wieder an Leisten anpassen wählen, um die Auswahl zu ändern.",
 ["barsMissingBT"]="Bartender ist ausgewählt, aber seine Leisten sind nicht aktiv. Aktivieren und neu laden oder Automatisch / Blizzard wählen.",
 ["barsNative"]="Blizzard",
 ["barsNativeActive"]="Blizzard-Leisten aktiv. Leisten 2 und 3 in den Spieleinstellungen einschalten und drei horizontale Leisten im Bearbeitungsmodus übereinander platzieren. Das Design folgt sichtbaren ausgewählten Leisten.",
 ["barsNativeList"]="Betroffene Blizzard-Leisten",
 ["barsNoEditor"]="Der Blizzard-Bearbeitungsmodus ist gerade nicht verfügbar. Außerhalb des Kampfes das Spielmenü nutzen.",
 ["barsSource"]="Aktionsleisten-Quelle",
 ["barsSourceHelp"]="Automatisch nutzt Bartender, wenn es die Leisten verwaltet, sonst Blizzard. Größe, Position und Leistenauswahl werden getrennt gespeichert. Diese Auswahl aktiviert/deaktiviert keine Addons. Für Blizzard Bartender in der Addonliste deaktivieren und neu laden. Aktionsplätze und Tastenbelegung werden weder kopiert noch geändert.",
 ["bridge"]="Diese erste Version öffnet die bisherigen Moduleinstellungen. Detaillierte Bedienelemente und Übersetzungen werden später hierher übernommen.",
 ["camera"]="Kamera",
 ["cardGlow"]="Weicher Kartenschimmer",
 ["cardGlowHelp"]="Weicher Schatten oder Schimmer um die Karten. Farbe, Stärke und Ausdehnung unten einstellen oder den Effekt ausschalten. Betrifft nur dieses Fenster.",
 ["cardTone"]="Helligkeit des Kartenhintergrunds",
 ["center"]="Fenster zentrieren",
 ["character"]="Charakter",
 ["classChanged"]="Jägermodule wurden für diesen Charakter deaktiviert. Zum Abschluss UI neu laden.",
 ["clicks"]="Fähigkeits-Fehlertöne stummschalten",
 ["clicksHelp"]="Schaltet die sechs Dateien aus deinem Makro stumm: 569772–569776 und 567407. Gesprochene Fehler werden separat eingestellt.",
 ["combat"]="Kampf & Eingabe",
 ["combatLock"]="Diese Änderung außerhalb des Kampfes vornehmen.",
 ["custom"]="Eigene Klangdateien",
 ["customHelp"]="Numerische Klangdatei-IDs mit Komma oder Leerzeichen trennen. Keine Sound-Kit-IDs. Der Client bestätigt nicht, ob eine ID hörbar ist.",
 ["dependency"]="Falls das Modul nicht lädt, benötigte Addons in der Addonliste prüfen.",
 ["details"]="Details",
 ["dialog"]="Dialoge stummschalten",
 ["dialogHelp"]="Deaktiviert den Dialogkanal. Gesprochene Fehlermeldungen haben eine eigene Option.",
 ["disableDeathEffect"]="Grauen Todesbildschirm deaktivieren",
 ["disableDeathEffectHelp"]="Schaltet den Vollbildeffekt beim Tod bzw. als Geist aus, damit die Welt ihre normalen Farben behalten kann. AN deaktiviert den Effekt; AUS aktiviert ihn wieder. Nutzt die Spieleinstellung ohne regelmäßige Abfragen. Wird im UI-Profil gespeichert. Ohne Unterstützung im Client ist die Option nicht verfügbar.",
 ["disabled"]="Deaktiviert",
 ["dragTip"]="Ziehen: Symbol verschieben",
 ["dtAll"]="UI-Design auf alle Details-Fenster anwenden",
 ["dtAllHelp"]="Wendet das KerimAnka-UI-Design auf alle initialisierten, aktivierten Details-Fenster an, auch automatisch ausgeblendete. Erstellt keine neuen Fenster.",
 ["dtAlpha"]="Deckkraft des Designs",
 ["dtApply"]="Gewählten Skin anwenden",
 ["dtCurrent"]="Aktueller Skin: ",
 ["dtDone"]="Skin angewendet.",
 ["dtEmpty"]="Keine aktivierten Details-Fenster bereit. Ein Details-Fenster öffnen und diese Seite aktualisieren.",
 ["dtFailed"]="Skin konnte nicht angewendet werden:",
 ["dtFonts"]="Schriftarten und Größen behalten",
 ["dtHelp"]="Die äußere Gestaltung erscheint in Details-Fenstern mit dem KerimAnka-UI-Design. Schriftarten und Schriftgrößen von Zeilen und Titeln bleiben bei aktivierter Schrifterhaltung erhalten; andere Darstellungswerte folgen dem gewählten Skin.",
 ["dtNative"]="Details-Einstellungen öffnen",
 ["dtNote"]="Hier das Aussehen von Details verwalten. Messdaten, Berichte und erweiterte Einstellungen bleiben in Details. Das Jägerdesign funktioniert mit jeder Klasse.",
 ["dtRefresh"]="Aktualisieren",
 ["dtSelection"]="Mit − / + einen registrierten Skin wählen und dann anwenden. Kein automatischer Skinwechsel.",
 ["dtTrim"]="Äußeres Design anzeigen",
 ["dtUpdate"]="Das mitgelieferte ForeverDetailsHunter-Update für diese Einstellungen installieren.",
 ["dtWaiting"]="Der Skin wurde noch nicht registriert. Kurz warten und aktualisieren.",
 ["dtWindow"]="Fenster",
 ["dtWindows"]="Details-Fenster",
 ["effects"]="Soundeffekte stummschalten",
 ["effectsHelp"]="Deaktiviert den gesamten Effektkanal, einschließlich Kampf- und vieler Oberflächenklänge. Einzelne Dateien können unten stummgeschaltet werden.",
 ["empty"]="Keine eigenen Klangdateien hinzugefügt.",
 ["enable"]="Für diesen Charakter aktivieren",
 ["enableHelp"]="Ändert die Addonliste dieses Charakters. Neuladen erforderlich; geladene Addons laufen bis dahin weiter. Abhängigkeiten werden nicht automatisch geändert.",
 ["errorCustom"]="Eigene Filter",
 ["errorCustomHelp"]="AN blendet die Fehlergruppe aus; AUS zeigt sie. Wichtige und unbekannte Fehler bleiben sichtbar. Für alle anderen Fehler den Modus Nur wichtige anzeigen verwenden.",
 ["errorImportantHelp"]="Blendet alle roten Fehler außer vollen Taschen/Bank, vollem Questlog, fehlendem Geld und Gegenstandslimits aus. Wichtige Warnungen beibehalten auf AUS blendet auch diese aus. Questfortschritt bleibt unverändert.",
 ["errorImportantOnly"]="Nur wichtige anzeigen",
 ["errorShowAll"]="Alle anzeigen",
 ["errorShowHelp"]="Normale Blizzard-Fehleranzeige ohne zusätzliche Textfilter.",
 ["error_cooldown"]="Abklingzeitfehler ausblenden",
 ["error_direction"]="Blick-/Sichtfehler ausblenden",
 ["error_movement"]="Bewegungsfehler ausblenden",
 ["error_range"]="Reichweitenfehler ausblenden",
 ["error_resources"]="Ressourcenfehler ausblenden",
 ["error_target"]="Zielfehler ausblenden",
 ["errors"]="Rote Fehlermeldungen ausblenden",
 ["errorsHelp"]="AUS zeigt alle normalen roten Fehler. AN verwendet den Filtermodus unter Start > Warnungen. Standardmäßig werden nur die dort genannten wichtigen Warnungen beibehalten. Toneinstellungen sind separat.",
 ["failed"]="Der Client konnte diese Änderung nicht anwenden.",
 ["featureOff"]="Funktion aus",
 ["fileIds"]="Klangdatei-IDs",
 ["ftBlue"]="Blau",
 ["ftCenter"]="Position zentrieren und entsperren",
 ["ftColorHelp"]="Eine feste Farbe schaltet automatische Bedrohungsfarben aus. Diese können oben wieder aktiviert werden.",
 ["ftColors"]="Feste Farbe",
 ["ftDefault"]="Standard",
 ["ftFont"]="Schriftart",
 ["ftFontHelp"]="Aus vorhandenen Schriftarten und den von LibSharedMedia angebotenen Schriften wählen. Fett, Umrandung und Schatten sind unabhängig.",
 ["ftGold"]="Gold",
 ["ftGreen"]="Grün",
 ["ftHelp"]="Ändert die Bedrohungsanzeige außerhalb des Kampfes. Ohne %-Zeichen bleibt die Zahl ein Prozentwert. Der Rohmodus nutzt rohe statt standardmäßig skalierter Bedrohung.",
 ["ftNote"]="Nutzt bisherige Charaktereinstellungen. Zahl entsperren, ziehen und wieder sperren. Ohne Daten ist die entsperrte 75 nur ein Platzierungsbeispiel; gesperrt wird sie ausgeblendet.",
 ["ftOriginal"]="Bisherige Bedrohungseinstellungen öffnen",
 ["ftRed"]="Rot",
 ["ftRefresh"]="Werte aktualisieren",
 ["ftUpdate"]="Das mitgelieferte ForeverThreat-Update für diese Einstellungen installieren.",
 ["ftWhite"]="Weiß",
 ["ft_alpha"]="Deckkraft (%)",
 ["ft_autoColor"]="Bedrohungsfarben verwenden",
 ["ft_bold"]="Fette Schrift",
 ["ft_enabled"]="Bedrohungsanzeige aktivieren",
 ["ft_locked"]="Position sperren",
 ["ft_outline"]="Schriftumrandung",
 ["ft_raw"]="Rohen Bedrohungswert verwenden",
 ["ft_shadow"]="Schriftschatten",
 ["ft_showPercent"]="%-Zeichen anzeigen",
 ["ft_size"]="Schriftgröße",
 ["ft_x"]="Horizontale Position",
 ["ft_y"]="Vertikale Position",
 ["glowBlue"]="Effektfarbe: Blau",
 ["glowGreen"]="Effektfarbe: Grün",
 ["glowRadius"]="Ausdehnung des Effekts",
 ["glowRed"]="Effektfarbe: Rot",
 ["glowReset"]="Darstellung zurücksetzen",
 ["glowStrength"]="Schatten- / Leuchtstärke",
 ["glowStyle"]="Kartendarstellung",
 ["glowStyleHelp"]="Dunkler Schatten oder farbiges Leuchten. Stärke, Ausdehnung und RGB verändern den Effekt; Kartenhelligkeit verändert den Hintergrund. Gilt charakterübergreifend für dieses Fenster. Kartenschimmer ausschalten blendet den Effekt aus.",
 ["goldPreset"]="Warmes Gold",
 ["heightResize"]="Fensterhöhe",
 ["heightResizeHelp"]="Den Griff unten in der Mitte nach unten ziehen: mehr Höhe ohne Änderung der Schriftgröße. Der Eckgriff skaliert weiterhin das gesamte Fenster.",
 ["hideActionBarStatues"]="Blizzard-Aktionsleistenfiguren ausblenden",
 ["hideActionBarStatuesHelp"]="Blendet die Greifen oder Wyvern an beiden Enden der Aktionsleiste aus. Funktioniert ohne Bartender mit Blizzard-Leisten sowie mit vorhandenen Bartender-Nachbildungen. Aktionstasten, EP-Leiste und Minimap-Rand bleiben unverändert. Ausschalten beendet nur unser Ausblenden; andere Addons können die Figuren weiter ausblenden. Änderungen außerhalb des Kampfes, pro Charakter gespeichert.",
 ["hideNativeHotkeys"]="Tastenbelegungen ausblenden",
 ["hideNativeHotkeysHelp"]="Blendet die Tastenbeschriftung auf allen acht Blizzard-Aktionsleisten für diesen Charakter aus. Belegungen und Reichweitenanzeige bleiben erhalten. Bartender verwaltet seine eigenen Texte.",
 ["hideNativeMacroNames"]="Makronamen ausblenden",
 ["hideNativeMacroNamesHelp"]="Blendet Makronamen unter den Blizzard-Aktionssymbolen aus. Makros, Gegenstandsmengen und Abklingzeiten bleiben erhalten.",
 ["home"]="Startseite",
 ["hrHelp"]="Ändert die vorhandene Reichweitenleiste außerhalb des Kampfes. Positives X verschiebt nach rechts, positives Y nach oben. Zustandsfarben bleiben gleich; farbiger Text folgt dem Symbol. Text wird bei schmalen Leisten ggf. verkleinert.",
 ["hrLive"]="Zur Live-Anzeige zurück",
 ["hrLiveMode"]="Live-Anzeige",
 ["hrMode"]="Modus: ",
 ["hrNote"]="Bisherige Charaktereinstellungen werden genutzt. Zum Ziehen über den Swing-Timer die Position entsperren. Der Hintergrund bleibt schwarz und undurchsichtig.",
 ["hrOriginal"]="Bisherige Reichweiteneinstellungen öffnen",
 ["hrPreview"]="Zustandsvorschau",
 ["hrPreviewHelp"]="Zeigt ein Beispiel auf der echten Leiste, keine gemessene Zielentfernung. Anzeige zuerst aktivieren. Beim Seitenwechsel oder Schließen endet dieses Beispiel. Entsperrte Leisten können ohne Ziel weiter ein Platzierungsbeispiel zeigen.",
 ["hrRefresh"]="Werte aktualisieren",
 ["hrSample"]="Beispiel: ",
 ["hrUpdate"]="Das mitgelieferte ForeverHunterRange-Update für diese Einstellungen installieren.",
 ["hr_coloredText"]="Textfarbe nach Zustand",
 ["hr_enabled"]="Reichweitenanzeige aktivieren",
 ["hr_fontSize"]="Schriftgröße",
 ["hr_height"]="Höhe",
 ["hr_locked"]="Position sperren",
 ["hr_outline"]="Schriftumrandung",
 ["hr_shadow"]="Schriftschatten",
 ["hr_width"]="Breite",
 ["hr_x"]="Horizontale Position",
 ["hr_y"]="Vertikale Position",
 ["hunterOnly"]="Nur Jäger",
 ["hunterOnlyHelp"]="Dieses Modul wird in dieser UI nur von Jägern verwendet. Für andere Klassen wird es automatisch in der Addonliste deaktiviert. Manuell deaktivierte Jägermodule bleiben deaktiviert. Bereits geladene Module enden nach dem Neuladen.",
 ["imAlign"]="Unter dem Chat platzieren",
 ["imBagHelp"]="Ein Taschenklick blendet nur deren Plätze aus oder ein, ohne die Gesamttasche zu schließen. Im Blizzard-Raster bleiben Lücken. Abgedunkelte Symbole kennzeichnen ausgeblendete Taschen. Modifizierte Klicks und Gegenstandsziehen behalten ihre normale Funktion. Einzelne Taschen bleiben verfügbar.",
 ["imBagSize"]="Größe der Taschensymbole",
 ["imBagToggleHelp"]="Taschensymbolleiste ein- / ausblenden",
 ["imBags"]="Blizzard-Taschen",
 ["imBartender"]="Bartender ist aktiv. Die Anpassung der Blizzard-Taschen und des Mikromenüs wartet, bis Bartender deaktiviert ist.",
 ["imDock"]="Taschensymbole an Gesamttasche anheften",
 ["imExpanded"]="Taschensymbolleiste anzeigen",
 ["imGap"]="Abstand zwischen Symbolen",
 ["imHelp"]="Verwendet Blizzard-Taschen und Menütasten. Einstellungen gelten für diesen Charakter. Die Taste neben dem Schließen-Knopf zeigt oder verbirgt die angeheftete Symbolleiste. Ein Taschenklick blendet nur deren Plätze aus oder ein; andere Taschen bleiben sichtbar.",
 ["imHideNativeBar"]="Standard-Taschenleiste ausblenden",
 ["imHideNativeBarHelp"]="Blendet die separate Blizzard-Taschenleiste auch bei geladenem Bagnon aus. Taschenfenster und Tastenkürzel bleiben verfügbar. Bartender verwaltet weiterhin seine eigenen Leisten. AUS stellt die Leiste wieder her.",
 ["imIconSize"]="Höhe der Mikromenü-Symbole",
 ["imItemLooksHelp"]="Zeigt verkäufliche graue Gegenstände entsättigt mit einer kleinen Münze an und verstärkt Qualitätsfarben ab ungewöhnlicher Qualität. Gilt für kombinierte und einzelne Blizzard-Taschen. Bagnon und andere Taschen-Addons behalten ihr Design. Kein automatisches Verkaufen oder Löschen.",
 ["imJunk"]="Verkäuflichen Plunder grau und mit Münze anzeigen",
 ["imLocked"]="Mikromenü-Position sperren",
 ["imManage"]="Mikromenü anpassen",
 ["imMicro"]="Mikromenü",
 ["imMicroHelp"]="Behält Blizzards Menütasten und Funktionen. Größe, Abstand und Position sind anpassbar. Ausschalten stellt das ursprüngliche Layout wieder her. Der Bearbeitungsmodus hat vorübergehend Vorrang.",
 ["imMove"]="Mikromenü — zum Verschieben ziehen",
 ["imMoveHelp"]="Position entsperren, um den Griff über dem Menü außerhalb des Kampfes zu ziehen. Danach wieder sperren. Unter dem Chat richtet sich am Hauptchat aus, ohne ihn zu verschieben. Am unteren Bildschirmrand muss ggf. der Chat etwas nach oben.",
 ["imOtherBags"]="Ein Taschen-Addon ist geladen und verwaltet Taschensymbole und Gegenstandsanzeige. Standard-Taschenleiste ausblenden und Mikromenü-Einstellungen bleiben verfügbar.",
 ["imQuality"]="Deutlichere Gegenstandsqualitäts-Rahmen",
 ["imReset"]="Mikromenü-Layout zurücksetzen",
 ["imUnavailable"]="Dieser Client stellt die benötigten Gesamttaschen-Fenster nicht bereit. Das Mikromenü bleibt bei Unterstützung verfügbar.",
 ["inactiveHelp"]="Dieses Addon ist nicht geladen. Für diesen Charakter aktivieren und neu laden. Auch die benötigten Addons prüfen.",
 ["installed"]="Installiert",
 ["interface"]="Oberfläche",
 ["invalidIds"]="Nur positive Datei-IDs eingeben (höchstens 30 eigene Einträge).",
 ["inventory"]="Taschen",
 ["keepImportantErrors"]="Wichtige Warnungen beibehalten",
 ["keepImportantErrorsHelp"]="Im Modus Nur wichtige anzeigen bleiben volle Taschen/Bank, volles Questlog, fehlendes Geld und Gegenstandslimits sichtbar. AUS unterdrückt alle roten Fehler.",
 ["language"]="Sprache",
 ["languageHelp"]="Sprache des Fensters wählen. Nicht übersetzte Texte erscheinen auf Englisch.",
 ["launcher"]="Minikartensymbol anzeigen",
 ["launcherHelp"]="Zeigt den KerimAnka-UI-Startknopf an der Minikarte. Kompatible Symbolsammel-Addons können ihn einsammeln.",
 ["lightPreset"]="Sanftes Licht",
 ["listen"]="Anhören",
 ["loaded"]="Geladen",
 ["missing"]="Nicht installiert",
 ["moduleError"]="Moduleinstellungen konnten nicht geöffnet werden. Prüfe, ob das Modul aktiviert und geladen ist.",
 ["modules"]="Module",
 ["music"]="Musik stummschalten",
 ["musicHelp"]="Deaktiviert sämtliche Spielmusik, auch Gebiets- und Kampfmusik.",
 ["noPanel"]="Dieses Modul hat kein Einstellungsfenster. Mit dem Schalter oben für diesen Charakter aktivieren oder deaktivieren.",
 ["notLoaded"]="Nicht geladen",
 ["note"]="Erste Version · Vorhandene Moduleinstellungen bleiben erhalten.",
 ["off"]="AUS",
 ["on"]="AN",
 ["open"]="Moduleinstellungen öffnen",
 ["openTip"]="Linksklick: Einstellungen öffnen",
 ["overview"]="Übersicht",
 ["pending"]="Neuladen erforderlich",
 ["pendingOff"]="Deaktivieren · Neuladen",
 ["pendingOn"]="Aktivieren · Neuladen",
 ["pets"]="Begleiterklänge stummschalten",
 ["petsHelp"]="Deaktiviert Begleiterklänge, sofern dieser Client die Einstellung unterstützt.",
 ["pfApply"]="Profil anwenden",
 ["pfApplyWarning"]="Bestätigen merkt die Auswahl vor. Danach unten Oberfläche neu laden anklicken. Bisherige Einstellungen bleiben geschützt.",
 ["pfBackup"]="Letzte Rücksicherung — Dieser Charakter",
 ["pfBackupHelp"]="Eine Rücksicherung pro Charakter. Sie bleibt bis zum Löschen oder nächsten Profilwechsel. Wiederherstellen ersetzt sie durch die gerade verlassenen Werte. Normale Einstellungsänderungen erzeugen keinen Verlauf.",
 ["pfBadName"]="Eindeutigen Namen mit 1–48 Bytes wählen, ohne Steuerzeichen oder |.",
 ["pfBeforeApply"]="Vor Profilanwendung",
 ["pfBeforeRestore"]="Vor Wiederherstellung",
 ["pfCancelPending"]="Vorgemerkte Änderung abbrechen",
 ["pfCancelled"]="Änderung abgebrochen. Aktuelle Einstellungen unverändert.",
 ["pfCharacter"]="Charakter",
 ["pfChoose"]="Gespeicherte Profile / Charaktere",
 ["pfConfirmApply"]="Auswahl bestätigen",
 ["pfConfirmDelete"]="Zum Löschen erneut klicken",
 ["pfConfirmRestore"]="Wiederherstellen bestätigen",
 ["pfDelete"]="Auswahl löschen",
 ["pfDeleteBackup"]="Rücksicherung löschen",
 ["pfDeleted"]="Eintrag gelöscht.",
 ["pfEmpty"]="Noch keine gespeicherten Profile.",
 ["pfExists"]="Der Name existiert bereits. Anderen Namen wählen oder das alte Profil löschen.",
 ["pfFailed"]="Vorgang fehlgeschlagen. Kein neues Profil übernommen.",
 ["pfFull"]="Profilspeicher voll. Ein ungenutztes Profil löschen und erneut versuchen.",
 ["pfGenerate"]="Aktuellen Code erzeugen",
 ["pfGenerated"]="Code erzeugt. Strg+A markiert alles, Strg+C kopiert. Zum Import einen anderen Code hier einfügen.",
 ["pfIntro"]="Profil oder Charakter auswählen und auf diesen Charakter anwenden. Danach unten Oberfläche neu laden anklicken. Gespeicherte Profile sind unabhängige Kopien und werden bei Änderungen am Charakter nicht überschrieben. Bartender-Layouts und Details-/Questie-Profile sind separat.",
 ["pfInvalid"]="Ungültiger, beschädigter oder nicht unterstützter Profilcode. Nichts geändert.",
 ["pfLoadCode"]="Code anzeigen / teilen",
 ["pfManualReload"]="Neuladen war nicht verfügbar oder wurde blockiert. Vorgemerkte Einstellungen bleiben erhalten. /reload im Chat eingeben.",
 ["pfNamed"]="Profil",
 ["pfNeedsValidation"]="Code vor dem Anwenden prüfen. Es wurden keine Einstellungen geändert.",
 ["pfNoBackup"]="Für diesen Charakter ist keine Rücksicherung gespeichert.",
 ["pfPending"]="Zuerst ausstehende Addon-Ladeänderungen anwenden und die UI neu laden.",
 ["pfPendingProfile"]="Ein Profil ist vorgemerkt. Unten neu laden oder zuerst abbrechen.",
 ["pfQueued"]="Einstellungen vorgemerkt. Unten Oberfläche neu laden anklicken oder hier abbrechen.",
 ["pfRestore"]="Vorherige Werte herstellen",
 ["pfRestoreWarning"]="Sicherung bestätigen, danach unten neu laden. Die Sicherung bleibt bis zum Abschluss geschützt.",
 ["pfSave"]="Aktuelle Werte speichern",
 ["pfSaveName"]="Name des neuen Profils",
 ["pfSaved"]="Profil gespeichert. Jedes gespeicherte Profil ist eine unabhängige Kopie.",
 ["pfStorage"]="Profilspeicher: %.1f / %.0f KiB · %d Einträge",
 ["pfStorageHelp"]="Bis zu 32 benannte Profile und 64 Charakterkopien; insgesamt 256 KiB. Kopien werden beim Ein-/Ausloggen aktualisiert. Bei Platzmangel können die ältesten Charakterkopien entfallen; benannte Profile werden nie automatisch gelöscht. Rücksicherung separat, maximal 64 KiB.",
 ["pfTestOK"]="Profil-Selbsttests bestanden.",
 ["pfTooLarge"]="Profilcode überschreitet die Größenbegrenzung. Nichts geändert.",
 ["pfTransfer"]="Import- / Exportcode",
 ["pfTransferHelp"]="Code erstellen oder hier einfügen. Prüfen und bestätigen, danach unten neu laden.",
 ["pfUseSelected"]="Auf diesen Charakter anwenden",
 ["pfValid"]="Code ist gültig.",
 ["pfValidate"]="Prüfen",
 ["pfValidated"]="Gültig · Ursprungsklasse: %s · %d Moduleinstellungstabellen. Das Design passt sich deiner Klasse an. Das Panel-Aussehen gilt auch für andere Charaktere.",
 ["previewFail"]="Datei konnte nicht abgespielt werden. ID und Klangeinstellungen prüfen.",
 ["profiles"]="Profile",
 ["qjBorder"]="Breite des Lederrands",
 ["qjHelp"]="Gestaltet den Questie-Tracker. Der Federkiel ist optional. Quests, Ein-/Ausklappen, Schrift, Hintergrundfarbe und Position bleiben bei Questie. Diese Schalter deaktivieren nicht das Addon selbst.",
 ["qjNote"]="Questie verwaltet Aufgaben und Tracker-Verhalten. Diese Seite steuert das Journaldesign.",
 ["qjOpacity"]="Hintergrunddeckkraft",
 ["qjOriginal"]="Bisherige Journal-Einstellungen öffnen",
 ["qjQuill"]="Optionalen Federkiel anzeigen",
 ["qjShow"]="Lederdesign anzeigen",
 ["qjUpdate"]="Das mitgelieferte ForeverQuestJournal-Update für diese Einstellungen installieren.",
 ["qjWaiting"]="Der Questie-Tracker ist noch nicht verbunden. Prüfe, ob Questie aktiv und der Tracker sichtbar ist.",
 ["quests"]="Questtagebuch",
 ["queue"]="Zauberwarteschlange",
 ["queueHelp"]="Zeit in Millisekunden, in der die nächste Fähigkeit vorgemerkt wird. Niedriger ist nicht immer besser; berücksichtige deine Latenz.",
 ["quick"]="Schnelleinstellungen",
 ["range"]="Hunter-Reichweite",
 ["reload"]="Oberfläche neu laden",
 ["reloadHelp"]="Lädt die Oberfläche für Änderungen am Addon-Status neu. Gespeicherte Einstellungen bleiben erhalten.",
 ["reloadLater"]="Später",
 ["reloadNow"]="Jetzt neu laden",
 ["reloadPromptBody"]="Zum Anwenden der Addon-Änderungen neu laden. Das geht auch später mit der Schaltfläche unten.",
 ["reloadPromptTitle"]="Oberfläche neu laden",
 ["reloadWaiting"]="Addon-Änderungen warten · Mit der Schaltfläche rechts neu laden.",
 ["remove"]="Entfernen",
 ["resetHelp"]="/kaui öffnet Einstellungen · /kaui center zentriert das Fenster",
 ["resize"]="Fenstergröße ändern",
 ["resizeHelp"]="Die Ecke unten rechts halten und diagonal ziehen. Das gesamte Fenster wird proportional skaliert; Größe und Position werden gespeichert. Die Skalierung unter Oberfläche bleibt verfügbar.",
 ["restore"]="Vorherige Werte wiederherstellen",
 ["restoreHelp"]="Stellt nur die hier geänderten Werte auf die zuvor gespeicherten Werte zurück. Modulschalter bleiben unverändert.",
 ["saved"]="Einstellungen werden automatisch gespeichert.",
 ["scale"]="Fensterskalierung",
 ["scaleHelp"]="Skaliert nur dieses Einstellungsfenster. Zum Verschieben die Titelleiste ziehen; die Position wird gespeichert.",
 ["settings"]="KerimAnka UI öffnen",
 ["shadowPreset"]="Dunkler Schatten",
 ["soundInfo"]="Kategorien einzeln wählen. Breite Kategorien unterdrücken auch nützliche Klänge.",
 ["soundNote"]="Andere Klang-Addons können dieselben Dateien steuern. Dieselbe ID möglichst nur in einem Addon stummschalten.",
 ["sounds"]="Klänge",
 ["speech"]="Gesprochene Fehler stummschalten",
 ["speechHelp"]="Schaltet gesprochene Fehler wie nicht genug Mana stumm. Dialoge werden separat eingestellt.",
 ["state"]="Modulstatus",
 ["stop"]="Stopp",
 ["threat"]="Bedrohung",
 ["ufAuras"]="Buffs & Debuffs",
 ["ufCast"]="Zauberleiste des Ziels",
 ["ufGeneral"]="Allgemein & Darstellung",
 ["ufHelp"]="Ändert die Einstellung an den bisherigen Einheitenfenstern. X verschiebt horizontal, Y vertikal. X/Y löst angeheftete Begleiter-/Ziel-des-Ziels-Fenster. Außerhalb des Kampfes einstellen.",
 ["ufIndicators"]="Statussymbole",
 ["ufNote"]="Neue Aura-/Zauberanzeigen starten AUS. Bisherige Einstellungen bleiben erhalten. Änderungen an nativem Aura-Layout, Anzahl und Animation benötigen ggf. Neuladen.",
 ["ufPositions"]="Rahmenpositionen",
 ["ufUpdate"]="Das mitgelieferte ForeverLeatherUnits-Update für diese Einstellungen installieren.",
 ["uf_auraCooldown"]="Aura-Abklinganimation",
 ["uf_auraStacks"]="Aura-Stapelzahlen",
 ["uf_castFontSize"]="Zaubernamen-Schriftgröße",
 ["uf_castHeight"]="Zauberleisten-/Symbolhöhe",
 ["uf_castIcon"]="Zaubersymbol anzeigen",
 ["uf_castWidth"]="Zauberleistenbreite",
 ["uf_castX"]="Zauberleiste X",
 ["uf_castY"]="Zauberleiste Y",
 ["uf_classificationTextScale"]="Elite-/Rare-Schrift skalieren",
 ["uf_combatIconSize"]="Kampfsymbolgröße",
 ["uf_enabled"]="Eigene Einheitenfenster",
 ["uf_happinessOffsetX"]="Zufriedenheit X",
 ["uf_happinessOffsetY"]="Zufriedenheit Y",
 ["uf_happinessSize"]="Zufriedenheit: Symbolgröße",
 ["uf_healthTextScale"]="Lebenspunkte skalieren",
 ["uf_hideNative"]="Blizzard-Fenster ausblenden",
 ["uf_leaderSize"]="Anführer-/Assistentensymbolgröße",
 ["uf_levelOffsetY"]="Level: vertikaler Versatz",
 ["uf_levelTextScale"]="Levelschrift skalieren",
 ["uf_locked"]="Positionen sperren",
 ["uf_pet.x"]="Begleiter X",
 ["uf_pet.y"]="Begleiter Y",
 ["uf_petAuraBelow"]="Begleiter: Auren unter dem Rahmen",
 ["uf_petAuraColumns"]="Begleiter: Symbole pro Zeile",
 ["uf_petAuraGap"]="Begleiter: Symbolabstand",
 ["uf_petAuraMax"]="Begleiter: Max. Symbole je Typ",
 ["uf_petAuraSingleRow"]="Begleiter: Nur eine Aurazeile",
 ["uf_petAuraSize"]="Begleiter: Symbolgröße",
 ["uf_petBuffX"]="Begleiter: Buff X",
 ["uf_petBuffY"]="Begleiter: Buff Y",
 ["uf_petBuffs"]="Begleiter: Buffs",
 ["uf_petDebuffX"]="Begleiter: Debuff X",
 ["uf_petDebuffY"]="Begleiter: Debuff Y",
 ["uf_petDebuffs"]="Begleiter: Debuffs",
 ["uf_petScale"]="Begleiterfenster skalieren",
 ["uf_player.x"]="Spieler X",
 ["uf_player.y"]="Spieler Y",
 ["uf_playerAuraBelow"]="Spieler: Auren unter dem Rahmen",
 ["uf_playerAuraColumns"]="Spieler: Symbole pro Zeile",
 ["uf_playerAuraGap"]="Spieler: Symbolabstand",
 ["uf_playerAuraMax"]="Spieler: Max. Symbole je Typ",
 ["uf_playerAuraSingleRow"]="Spieler: Nur eine Aurazeile",
 ["uf_playerAuraSize"]="Spieler: Symbolgröße",
 ["uf_playerBuffX"]="Spieler: Buff X",
 ["uf_playerBuffY"]="Spieler: Buff Y",
 ["uf_playerBuffs"]="Spieler: Buffs",
 ["uf_playerDebuffX"]="Spieler: Debuff X",
 ["uf_playerDebuffY"]="Spieler: Debuff Y",
 ["uf_playerDebuffs"]="Spieler: Debuffs",
 ["uf_powerTextScale"]="Mana-/Energiezahlen skalieren",
 ["uf_pvpOffsetX"]="PvP: horizontaler Versatz",
 ["uf_pvpOffsetY"]="PvP: vertikaler Versatz",
 ["uf_pvpSize"]="PvP-Symbolgröße",
 ["uf_raidMarkerOffsetX"]="Zielmarkierung X",
 ["uf_raidMarkerOffsetY"]="Zielmarkierung Y",
 ["uf_raidMarkerSize"]="Zielmarkierungsgröße",
 ["uf_restIconSize"]="Erholungssymbol (ZZZ)",
 ["uf_scale"]="Rahmenskalierung",
 ["uf_showCombo"]="Zusätzliche Schurken-Combopunkte",
 ["uf_showPet"]="Begleiterfenster anzeigen",
 ["uf_showPetHappiness"]="Zufriedenheit anzeigen",
 ["uf_showToT"]="Ziel des Ziels anzeigen",
 ["uf_target.x"]="Ziel X",
 ["uf_target.y"]="Ziel Y",
 ["uf_targetAuraBelow"]="Ziel: Auren unter dem Rahmen",
 ["uf_targetAuraColumns"]="Ziel: Symbole pro Zeile",
 ["uf_targetAuraGap"]="Ziel: Symbolabstand",
 ["uf_targetAuraMax"]="Ziel: Max. Symbole je Typ",
 ["uf_targetAuraSingleRow"]="Ziel: Nur eine Aurazeile",
 ["uf_targetAuraSize"]="Ziel: Symbolgröße",
 ["uf_targetBuffX"]="Ziel: Buff X",
 ["uf_targetBuffY"]="Ziel: Buff Y",
 ["uf_targetBuffs"]="Ziel: Buffs",
 ["uf_targetCastEnabled"]="Zauberleiste des Ziels anzeigen",
 ["uf_targetDebuffX"]="Ziel: Debuff X",
 ["uf_targetDebuffY"]="Ziel: Debuff Y",
 ["uf_targetDebuffs"]="Ziel: Debuffs",
 ["uf_targettarget.x"]="Ziel des Ziels X",
 ["uf_targettarget.y"]="Ziel des Ziels Y",
 ["uf_textScale"]="Namensschrift skalieren",
 ["uf_totScale"]="Ziel des Ziels skalieren",
 ["unavailable"]="Auf diesem Client nicht verfügbar",
 ["units"]="Einheitenfenster",
 ["upBuffs"]="Buffs",
 ["upCast"]="Beispielzauber",
 ["upControl"]="Vorschau-Bedienung",
 ["upControlHelp"]="Ziehen verschiebt diese Symbolgruppe. Mausrad ändert die Größe. Änderungen außerhalb des Kampfes.",
 ["upDebuffs"]="Debuffs",
 ["upExamples"]="Beispieleffekte",
 ["upNote"]="Ziehen / Mausrad · Klick öffnet Einstellung · Erste Beispielzeile",
 ["upPet"]="Begleiter",
 ["upPetName"]="Begleiterbeispiel",
 ["upPlayer"]="Spieler",
 ["upPlayerName"]="Spielerbeispiel",
 ["upTarget"]="Ziel",
 ["upTargetName"]="Zielbeispiel",
 ["upTitle"]="Live-Vorschau",
 ["upVisible"]="Vorschau anzeigen",
 ["version"]="Version 0.12.0",
 ["welcome"]="Deine Oberfläche. Deine Einstellungen. Ein Ort.",
 ["zoom"]="Maximale Kameradistanz",
 ["zoomHelp"]="Ändert den maximalen Zoomfaktor, nicht die aktuelle Kameraposition. Der Client kann den Wert begrenzen.",
 ["zoomNote"]="Der Regler setzt ein Limit. Danach mit dem Mausrad herauszoomen.",
}

-- Native damage meter appearance.
K.locales.de["details"]="Schadensanzeige"
K.locales.de["dmBlizzard"]="Blizzard"
K.locales.de["dmDetails"]="Details-Design"
K.locales.de["dmNote"]="Gestaltet die vorhandenen Blizzard-Anzeigefenster. Messung, Zeilen, Menüs und Position bleiben beim Spiel. Details wird nicht benötigt."
K.locales.de["dmHelp"]="Nur Darstellung, für diesen Charakter gespeichert. Ausschalten stellt den ursprünglichen Hintergrund wieder her und blendet unseren Rand aus. Schaltet die Schadensanzeige des Spiels nicht ein oder aus. Änderungen außerhalb des Kampfes."
K.locales.de["dmEnabled"]="Blizzard-Anzeigedesign anzeigen"
K.locales.de["dmTrim"]="Zierrahmen anzeigen"
K.locales.de["dmTrimAlpha"]="Deckkraft des Rahmens"
K.locales.de["dmBackground"]="Hintergrunddeckkraft"
K.locales.de["dmPadding"]="Rahmenversatz"
K.locales.de["dmReady"]="Blizzard-Anzeige erkannt. Das Design folgt den vorhandenen Fenstern."
K.locales.de["dmHidden"]="Die Schadensanzeige des Spiels ist ausgeschaltet. In den Spieleinstellungen aktivieren; ein anderes Anzeige-Addon kann sie ebenfalls ausgeblendet haben."
K.locales.de["dmUnavailable"]="Blizzard-Anzeigefenster sind noch nicht geladen oder hier nicht verfügbar. Zuerst die Schadensanzeige des Spiels aktivieren."
K.locales.de["dmDetailsMissing"]="Das optionale KerimAnka UI Details-Design ist nicht geladen. Bei Verwendung von Details unten aktivieren."

-- Experience and reputation widget.
K.locales.de["experience"]="Erfahrung & Ruf"
K.locales.de["xpTotal"]="Gesamt"
K.locales.de["xpLevelTime"]="Dieses Level"
K.locales.de["xpLevel"]="Level"
K.locales.de["xpRemaining"]="Verbleibend"
K.locales.de["xpRate"]="EP/Stunde"
K.locales.de["xpDayShort"]="T"
K.locales.de["xpHourShort"]="Std"
K.locales.de["xpMinuteShort"]="Min"
K.locales.de["xpIntro"]="Kompakte Erfahrungsanzeige mit einzeln einstellbaren Texten. Unten einschalten. Ruf erscheint nur für die beobachtete Fraktion; Begleiter-EP nur für einen aktiven Jägerbegleiter, der EP erhalten kann."
K.locales.de["xpConflict"]="ExperienceForever ist ebenfalls geladen. Beide Anzeigen können sichtbar bleiben und werden unabhängig in ihren eigenen Einstellungen gesteuert."
K.locales.de["xpHelp"]="Einstellungen gelten für diesen Charakter und gehören zum Profil. Die Vorschau verwendet Beispieldaten. Quest-EP sind Belohnungen abgeschlossener, noch nicht abgegebener Quests im Log, keine Gesamtzahl abgeschlossener Quests. EP/Stunde und Restzeit basieren auf dieser UI-Sitzung und starten nach Neuladen neu. Spielzeit kommt vom Spiel. Ausblenden betrifft die native EP-/Rufanzeige; sie kehrt zurück, wenn unser Widget aus ist oder nichts anzeigen kann."
K.locales.de["xpPreviewNote"]="Beispieldaten · Text zum Auswählen anklicken · Ziehen / Mausrad · Position und Größe sofort sichtbar"
K.locales.de["xpCompact"]="Kompaktes Layout"
K.locales.de["xpHorizontal"]="Flaches horizontales Layout"
K.locales.de["xpEnabled"]="Erfahrungsanzeige anzeigen"
K.locales.de["xpLocked"]="Anzeigeposition sperren"
K.locales.de["xpShowRep"]="Beobachteten Ruf anzeigen"
K.locales.de["xpShowPet"]="Jägerbegleiter-EP anzeigen"
K.locales.de["xpShowTime"]="Spielzeiten anzeigen"
K.locales.de["xpShowRate"]="EP/Stunde und Restzeit anzeigen"
K.locales.de["xpShowQuest"]="EP abgabebereiter Quests anzeigen"
K.locales.de["xpShowRested"]="Erholungsbonus anzeigen"
K.locales.de["xpTrim"]="Zierrahmen anzeigen"
K.locales.de["xpHideNative"]="Native EP- / Rufleiste ausblenden"
K.locales.de["xpClassColor"]="Klassenfarbe verwenden"
K.locales.de["xpWidth"]="Anzeigenbreite"
K.locales.de["xpHeight"]="Höhe der EP-Leiste"
K.locales.de["xpSubHeight"]="Höhe der Ruf- / Begleiterleiste"
K.locales.de["xpPlaceTop"]="Am oberen Bildschirmrand platzieren"
K.locales.de["xpPlaceMeter"]="Über Blizzard-Anzeige platzieren"
K.locales.de["xpNoMeter"]="Zuerst die Blizzard-Schadensanzeige öffnen."
K.locales.de["xpTextSettings"]="Einzelne Texte einstellen"
K.locales.de["xpLabel_total"]="Gesamte Spielzeit"
K.locales.de["xpLabel_levelTime"]="Zeit auf diesem Level"
K.locales.de["xpLabel_xp"]="Level und EP"
K.locales.de["xpLabel_remaining"]="Verbleibende Zeit"
K.locales.de["xpLabel_rate"]="EP/Stunde"
K.locales.de["xpLabel_reputation"]="Ruf"
K.locales.de["xpLabel_pet"]="Begleiter-EP"
K.locales.de["xpLabelVisible"]="Ausgewählten Text anzeigen"
K.locales.de["xpLeft"]="Links"
K.locales.de["xpCenter"]="Mitte"
K.locales.de["xpRight"]="Rechts"
K.locales.de["xpTextX"]="Horizontaler Textversatz"
K.locales.de["xpTextY"]="Vertikaler Textversatz"
K.locales.de["xpTextSize"]="Größe des ausgewählten Texts"
K.locales.de["xpFontRegular"]="Ubuntu Normal"
K.locales.de["xpFontBold"]="Ubuntu Fett"
K.locales.de["xpFontGame"]="Spielschrift"
K.locales.de["xpResetText"]="Textlayout wiederherstellen"
K.locales.de["xpResetSession"]="Sitzungsstatistik zurücksetzen"

K.locales.de["xpPanelSpace"]="Zusätzliche Fensterhöhe"
K.locales.de["xpFrameSize"]="Stärke des Zierrahmens"
K.locales.de["xpBackgroundAlpha"]="Deckkraft des Fensterhintergrunds"

K.locales.de["xpColors"]="Leistenfarben"
K.locales.de["xpColorMain"]="Farbe der EP-Leiste"
K.locales.de["xpColorQuest"]="Farbe abgabebereiter Quest-EP"
K.locales.de["xpColorRested"]="Farbe des Erholungsbonus"
K.locales.de["xpColorRep"]="Ruffarbe"
K.locales.de["xpColorPet"]="Begleiter-EP-Farbe"
K.locales.de["xpTextColor"]="Farbe des ausgewählten Texts"
K.locales.de["xpChooseColor"]="Farbe wählen"
K.locales.de["xpApplyColor"]="HEX anwenden"
K.locales.de["xpResetColor"]="Standardfarbe"
K.locales.de["xpInvalidHex"]="Sechsstelligen Farbcode eingeben, zum Beispiel #55AA77."
K.locales.de["xpPickerUnavailable"]="Die Farbauswahl des Spiels ist nicht verfügbar. Ein HEX-Code kann weiterhin eingegeben werden."

K.locales.de["xpClassColorActive"]="Klassenfarbe aktiv. Für eine eigene EP-Farbe die Klassenfarbe ausschalten."

K.locales.de["mcTitle"]="Minikartenkoordinaten"
K.locales.de["mcHelp"]="Passt die Koordinaten des Spiels an. Koordinaten in den Spieloptionen einschalten. Änderungen sind sofort auf der Minikarte sichtbar. Ziehen endet im Kampf oder beim Schließen dieses Fensters."
K.locales.de["mcUnavailable"]="Die Koordinatenanzeige der Minikarte ist in diesem Client nicht verfügbar."
K.locales.de["mcEnabled"]="Koordinatenposition und Schrift anpassen"
K.locales.de["mcX"]="Koordinaten: Horizontaler Versatz"
K.locales.de["mcY"]="Koordinaten: Vertikaler Versatz"
K.locales.de["mcSize"]="Schriftgröße der Koordinaten"
K.locales.de["mcOutline"]="Koordinatenschrift umranden"
K.locales.de["mcDrag"]="Zum Positionieren ziehen"
K.locales.de["mcLock"]="Position sperren"
K.locales.de["mcReset"]="Standardkoordinaten wiederherstellen"

K.locales.de["ufPortraitCombat"]="Kampftext im Porträt"
K.locales.de["uf_portraitCombatPlayer"]="Kampftext im Spielerporträt"
K.locales.de["uf_portraitCombatPet"]="Kampftext im Begleiterporträt"
K.locales.de["uf_portraitCombatSize"]="Schriftgröße des Porträt-Kampftexts"
K.locales.de["ufPortraitCombatHelp"]="Zeigt Blizzards Kampfrückmeldung im eigenen oder im Begleiterporträt: erlittenen Schaden, Heilung und Ergebnisse wie Ausweichen oder Absorbieren. Kritische Treffer erscheinen größer. Standardmäßig ausgeschaltet. Zielporträts und schwebender Kampftext bleiben unverändert."

K.locales.de["ufQuestie"]="Questie-Zielsymbol"
K.locales.de["uf_questieTargetIcon"]="Questie-Symbol am Ziel anzeigen"
K.locales.de["uf_questieIconSize"]="Größe des Questsymbols"
K.locales.de["uf_questieIconX"]="Questsymbol: Horizontaler Versatz"
K.locales.de["uf_questieIconY"]="Questsymbol: Vertikaler Versatz"
K.locales.de["ufQuestieHelp"]="Zeigt das von Questie gewählte Zielsymbol am Zielporträt. Questie und dessen Zielrahmensymbole müssen aktiviert sein. Verwendet Questies Symboldesign und Aufgabenfortschritt und berücksichtigt dessen Instanzbeschränkungen in Forever. Position relativ zur oberen rechten Porträtecke."

K.locales.de["ufHunterSummons"]="Temporäre Jägerbeschwörungen"
K.locales.de["uf_hunterSummons"]="Aktive Jägerbeschwörungen anzeigen"
K.locales.de["uf_hunterSummonSize"]="Symbolgröße der Beschwörungen"
K.locales.de["uf_hunterSummonGap"]="Symbolabstand der Beschwörungen"
K.locales.de["uf_hunterSummonX"]="Beschwörungen: Horizontale Position"
K.locales.de["uf_hunterSummonY"]="Beschwörungen: Vertikale Position"
K.locales.de["ufHunterSummonsHelp"]="Zeigt aktive temporäre Beschwörungen wie Falken mit Blizzards Totemplätzen und Restlaufzeiten. Nur für Jäger; unabhängig von Auren und dem dauerhaften Begleiter. Die Vorschau zeigt zwei Beispiele. Position relativ zur unteren linken Ecke des Spielerrahmens."

-- Independent damage-meter border edges.
K.locales.de["dmEdgeTop"]="Oberen Rand anpassen"
K.locales.de["dmEdgeBottom"]="Unteren Rand anpassen"
K.locales.de["dmEdgeLeft"]="Linken Rand anpassen"
K.locales.de["dmEdgeRight"]="Rechten Rand anpassen"
K.locales.de["dmEdgeHelp"]="Positive Werte verschieben nur diesen Rand nach außen, negative nach innen. Wird zum allgemeinen Randabstand addiert; insgesamt mindestens null. Änderungen außerhalb des Kampfes."

-- Optional independent minimap icon drawer.
K.locales.de["mbTitle"]="Minimap-Addonsymbole"
K.locales.de["mbEnabled"]="Symbole im Fenster sammeln"
K.locales.de["mbLocked"]="Fensterschaltfläche sperren"
K.locales.de["mbColumns"]="Symbole pro Zeile"
K.locales.de["mbSize"]="Symbolgröße"
K.locales.de["mbAngle"]="Schaltflächenposition am Kartenrand"
K.locales.de["mbRadius"]="Abstand zur Karte"
K.locales.de["mbCount"]="Addonsymbole"
K.locales.de["mbClick"]="Linksklick: Symbolfenster. Rechtsklick: Klassendesign. Zum Verschieben am Kartenrand entsperren."
K.locales.de["mbHelp"]="Sammelt unterstützte Addonsymbole, deren Minimap-Anzeige aktiv ist. Versteckte Symbole, reine Mauszeiger-Anzeigen und Kartenmarkierungen bleiben ausgenommen. Ausschalten stellt die bisherigen Positionen wieder her. Änderungen außerhalb des Kampfes."
K.locales.de["mbConflict"]="MinimapButtonButton ist aktiv. KerimAnka wartet, damit nicht zwei Sammler dieselben Symbole verschieben. MinimapButtonButton in der Addonliste ausschalten, dann /reload."

-- Dedicated minimap page and per-icon collection preferences.
K.locales.de["minimap"]="Minimap"
K.locales.de["mmArtUnavailable"]="Für das Minimap-Design muss das KerimAnka UI Klassendesign-Modul geladen sein. Koordinaten und Symbolfenster arbeiten unabhängig."
K.locales.de["mbPreferences"]="Symbolauswahl"
K.locales.de["mbCollect"]="Im Fenster sammeln"
K.locales.de["mbPreferencesHelp"]="Ausschalten bringt das Symbol an seine vorherige Position am Kartenrand zurück; es wird nicht versteckt. Zum vollständigen Ausblenden die Minimap-Einstellung des jeweiligen Addons nutzen."
K.locales.de["mbEmpty"]="Keine sichtbaren Symbole gefunden. Sammlung einschalten und andere aktive Sammler zuerst ausschalten."
K.locales.de["mbClick"]="Linksklick: Symbolfenster. Rechtsklick: Minimap-Einstellungen. Zum Verschieben am Kartenrand entsperren."

-- Independent icon-drawer button art and size.
K.locales.de["mbAppearance"]="Aussehen der Fensterschaltfläche"
K.locales.de["mbRound"]="Rund"
K.locales.de["mbSquare"]="Quadratisch"
K.locales.de["mbButtonSize"]="Größe der Fensterschaltfläche"
K.locales.de["mbSize"]="Addonsymbolgröße im Fenster"

-- Optional full-icon action range coloring.
K.locales.de["arEnabled"]="Fähigkeiten außer Reichweite einfärben"
K.locales.de["arColor"]="Reichweitenfarbe"
K.locales.de["arReset"]="Standardrot wiederherstellen"
K.locales.de["arHelp"]="Färbt bei fehlender Reichweite das gesamte Fähigkeitssymbol, unabhängig von der Tastenbeschriftung. In Reichweite erscheint die normale Spielfarbe. Unterstützt Blizzard- und Bartender-Aktionsleisten; Begleiterleisten sind ausgenommen."

K.locales.de["mbBlockedTitle"]="Symbolsammlung nicht verfügbar: MinimapButtonButton ist aktiv"
K.locales.de["mbBlockedHelp"]="MinimapButtonButton verwaltet dieselben Symbole. Die KerimAnka-Symbolsammlung ist deshalb inaktiv und kann nicht eingeschaltet werden. Für das KerimAnka-Panel MinimapButtonButton in der Addonliste deaktivieren und /reload ausführen. Kartendesign und Koordinaten bleiben aktiv; die Panel-Einstellungen bleiben erhalten."

K.locales.de["artSkinAncestral"]="Ahnentotems"
K.locales.de["artSkinElements"]="Vier Elemente"
K.locales.de["shamanArtTitle"]="Schamane — Klassendesign"
K.locales.de["shamanArtHelp"]="Ahnentotems ist der Standard; Vier Elemente oben auswählen. Positive Werte verschieben die jeweilige Seite nach außen, negative nach innen. Seitensäulen und mittleres Emblem behalten ihre Proportionen; nur die unteren Verbindungsstücke werden gestreckt. Die obere Leiste ist separat einstellbar."
K.locales.de["art_shamanBackingEnabled"]="Dunklen Hintergrund anzeigen"
K.locales.de["art_shamanBackingAlpha"]="Hintergrunddeckkraft"
K.locales.de["art_shamanRailEnabled"]="Obere Zierleiste anzeigen"
K.locales.de["art_shamanRailX"]="Zierleiste horizontal verschieben"
K.locales.de["art_shamanRailY"]="Zierleiste vertikal verschieben"
K.locales.de["art_shamanRailWidth"]="Breite der Zierleiste (%)"
K.locales.de["art_shamanRailHeight"]="Höhe der Zierleiste (%)"

K.locales.de["art_shamanLeftSpread"]="Linke Seite erweitern"

K.locales.de["art_shamanRightSpread"]="Rechte Seite erweitern"

K.locales.de["art_mageBackingEnabled"]="Dunklen Hintergrund anzeigen"
K.locales.de["art_mageBackingAlpha"]="Hintergrunddeckkraft"
K.locales.de["art_mageRailEnabled"]="Obere Zierleiste anzeigen"
K.locales.de["art_mageRailX"]="Zierleiste horizontal verschieben"
K.locales.de["art_mageRailY"]="Zierleiste vertikal verschieben"
K.locales.de["art_mageRailWidth"]="Breite der Zierleiste (%)"
K.locales.de["art_mageRailHeight"]="Höhe der Zierleiste (%)"
K.locales.de["art_mageLeftSpread"]="Linke Seite erweitern"
K.locales.de["art_mageRightSpread"]="Rechte Seite erweitern"
K.locales.de["artSkinMageArcane"]="Arkan — Violetter Kristall"
K.locales.de["artSkinMageFire"]="Feuer — Glutofen"
K.locales.de["artSkinMageFrost"]="Frost — Kristallsiegel"
K.locales.de["mageArtTitle"]="Magier-Design"
K.locales.de["mageArtHelp"]="Alle vier Designs verwenden dieselbe Anordnung. Oberleiste und Seiten sind getrennt einstellbar. Das Design ist unabhängig von der Spezialisierung."

K.locales.de["artSkinMageAcademy"]="Magierakademie — Dreifachsiegel"

K.locales.de["art_priestBackingEnabled"]="Dunklen Hintergrund anzeigen"
K.locales.de["art_priestBackingAlpha"]="Hintergrunddeckkraft"
K.locales.de["art_priestRailEnabled"]="Obere Zierleiste anzeigen"
K.locales.de["art_priestRailX"]="Zierleiste horizontal verschieben"
K.locales.de["art_priestRailY"]="Zierleiste vertikal verschieben"
K.locales.de["art_priestRailWidth"]="Breite der Zierleiste (%)"
K.locales.de["art_priestRailHeight"]="Höhe der Zierleiste (%)"
K.locales.de["art_priestLeftSpread"]="Linke Seite erweitern"
K.locales.de["art_priestRightSpread"]="Rechte Seite erweitern"
K.locales.de["artSkinPriestLight"]="Heiligtum des Lichts — Heilig / Disziplin"
K.locales.de["artSkinPriestShadow"]="Kapelle der Finsternis — Schatten"
K.locales.de["priestArtTitle"]="Priester-Design"
K.locales.de["priestArtHelp"]="Beide Designs verwenden dieselbe Anordnung. Oberleiste und Seiten sind getrennt einstellbar. Das Design ist unabhängig von der Spezialisierung."

K.locales.de["art_druidBackingEnabled"]="Dunklen Hintergrund anzeigen"
K.locales.de["art_druidBackingAlpha"]="Hintergrunddeckkraft"
K.locales.de["art_druidRailEnabled"]="Obere Zierleiste anzeigen"
K.locales.de["art_druidRailX"]="Zierleiste horizontal verschieben"
K.locales.de["art_druidRailY"]="Zierleiste vertikal verschieben"
K.locales.de["art_druidRailWidth"]="Breite der Zierleiste (%)"
K.locales.de["art_druidRailHeight"]="Höhe der Zierleiste (%)"
K.locales.de["art_druidLeftSpread"]="Linke Seite erweitern"
K.locales.de["art_druidRightSpread"]="Rechte Seite erweitern"
K.locales.de["artSkinDruidGrove"]="Uralter Hain"
K.locales.de["artSkinDruidMoon"]="Mondwächter"
K.locales.de["artSkinDruidWild"]="Wildes Herz"
K.locales.de["artSkinDruidSeasons"]="Bund der Jahreszeiten"
K.locales.de["druidArtTitle"]="Druiden-Design"
K.locales.de["druidArtHelp"]="Alle vier Designs verwenden dieselbe Anordnung. Wildes Herz ist der Standard. Oberleiste und Seiten sind getrennt einstellbar. Das Design ist unabhängig von Spezialisierung und Gestalt."

K.locales.de["imBagHelp"]="Mit der Blizzard-Gesamttasche öffnen sich die verfügbare Reagenzientasche und der Schlüsselbund daneben als eigene Fenster. Ihre Symbole öffnen oder schließen diese Fenster. Normale Taschensymbole blenden deren Plätze aus oder ein. Bei Taschen-Addons wie Bagnon ist diese Anordnung deaktiviert."

K.locales.de["imBagHelp"]="Die Reagenzientasche öffnet sich neben der Blizzard-Gesamttasche als eigenes Fenster. Ihr Symbol blendet sie aus oder ein und wird beim Ausblenden abgedunkelt. Die Auswahl bleibt beim Schließen und Öffnen der Taschen erhalten. Der Schlüsselbund öffnet sich nur per Klick. Normale Taschensymbole blenden ihre Plätze aus oder ein. Bei Taschen-Addons wie Bagnon ist diese Anordnung deaktiviert."

K.locales.de["imBagBackground"]="Hintergrund der Taschenleiste"
K.locales.de["imBagFrame"]="Rahmen der Taschenleiste"
K.locales.de["imBagIconBorder"]="Schwarze Symbolränder"
K.locales.de["imBagAppearanceHelp"]="Hintergrund und Zierrahmen der Taschenleiste lassen sich getrennt ausblenden. Schwarze Ränder gelten nur für die Symbole. Größe und Abstand gelten für alle Taschensymbole einschließlich Reagenzientasche und Schlüsselbund."
K.locales.de["mbShowTooltip"]="Tooltip am Symbol anzeigen"

K.locales.de["bsTitle"]="Taschen-Schnellzugriff"
K.locales.de["bsHelp"]="Eine Taste zum Öffnen und Schließen deiner Taschen. Standardmäßig sichtbar und gesperrt, anfangs unten rechts. Zum Verschieben entsperren und danach wieder sperren. Die Tastenkürzel funktionieren auch bei ausgeblendetem Symbol. Standardbelegungen verwenden B und Umschalt+B; unten stehen deine aktuellen Belegungen. Diese lassen sich in den Spieleinstellungen ändern."
K.locales.de["bsEnabled"]="Taschen-Schnellzugriff anzeigen"
K.locales.de["bsLocked"]="Position sperren"
K.locales.de["bsSize"]="Symbolgröße"
K.locales.de["bsReset"]="Position zurücksetzen"
K.locales.de["bsAllBags"]="Alle Taschen"
K.locales.de["bsBackpack"]="Rucksack"
K.locales.de["bsUnbound"]="Nicht belegt"
K.locales.de["bsDrag"]="Zum Verschieben ziehen."

K.locales.de["quests"]="Questverfolgung"
K.locales.de["qjNativeHelp"]="Verwendet Aussehen, Symbole und Questtasten der originalen Blizzard-Questverfolgung. Mit dem Mausrad über dem Questbereich lassen sich weitere verfolgte Quests anzeigen. Das alte Questie-Lederdesign mit Feder wurde entfernt."
K.locales.de["qjScrollEnabled"]="Mit dem Mausrad scrollen"
K.locales.de["qjScrollStep"]="Scrollschritt"
K.locales.de["qjHeightHelp"]="Position und Höhe im Bearbeitungsmodus des Spiels ändern. Diese Funktion verfolgt Quests nicht automatisch; sie scrollt bereits von Blizzard verfolgte Quests. Im Bearbeitungsmodus kehrt vorübergehend das Standardlayout zurück."
K.locales.de["qjActive"]="Scrollen für die Blizzard-Questverfolgung ist aktiv."
K.locales.de["qjOtherTracker"]="Die Questie-Verfolgung ist aktiv. Deaktiviere sie in den Questie-Einstellungen, um Blizzard zu verwenden. Questie-Kartensymbole können aktiv bleiben."
K.locales.de["qjNativeWaiting"]="Die Blizzard-Verfolgung ist noch nicht bereit oder Scrollen ist deaktiviert."
K.locales.de["qjUpdate"]="Ergänzt Scrollen für die Blizzard-Questverfolgung, ohne Questie-Design."

K.locales.de["qjGroupByZone"]="Nach Gebiet gruppieren"
K.locales.de["qjZoneHelp"]="Gruppiert Quests nach den Gebiets-/Kategorieüberschriften des Questlogs. Ein Klick klappt die Gruppe ein oder aus; Quests bleiben verfolgt. Scrollen muss aktiv sein. Geschützte Questtasten werden nach dem Kampf neu angeordnet."
K.locales.de["qjNativeHelp"]="Behält Aussehen, Symbole und Questtasten der Blizzard-Verfolgung. Mit dem Mausrad scrollen und Gebietsgruppen ein- oder ausklappen. Questie wird nicht benötigt."
K.locales.de["qjHeightHelp"]="Position und Höhe im Bearbeitungsmodus des Spiels ändern. Es erscheinen nur von Blizzard verfolgte Quests. Dort kehrt vorübergehend das Standardlayout zurück. Bei geschützten Tasten können Listenupdates bis zum Kampfende warten."

K.locales.de["backingColorTitle"]="Hintergrundfarbe"
K.locales.de["backingColorHelp"]="Ändert die Fläche hinter den Tasten. Dekoration und Tastenränder bleiben erhalten."
K.locales.de["backingOriginal"]="Originalansicht"
K.locales.de["backingCustom"]="Eigene Farbe"
K.locales.de["backingPickColor"]="Farbe wählen"
K.locales.de["backingCream"]="Creme"
K.locales.de["backingBrown"]="Braun"
K.locales.de["backingGrey"]="Anthrazit"
K.locales.de["backingBlack"]="Schwarz"
K.locales.de["backingOpacityHelp"]="Die Transparenz lässt sich unten über die Hintergrunddeckkraft einstellen."

K.locales.de["imBTBags"]="Bartenders Taschenleiste (Bag Bar) ist aktiv; unsere Taschenablage wartet. Deaktiviere nur Bartender → Taschenleiste → Aktiviert. Die Aktionsleisten können aktiv bleiben."
K.locales.de["imBTMicro"]="Bartenders Mikromenü ist aktiv; nur unsere Mikromenü-Anordnung wartet. Die Taschenablage bleibt verfügbar. Deaktiviere Bartenders Mikromenü; falls die Tasten nicht zurückkehren, nutze /reload."
K.locales.de["imBTBoth"]="Bartenders Taschenleiste und Mikromenü sind aktiv. Deaktiviere nur das jeweilige Modul, um unsere Anordnung zu nutzen. Aktionsleisten können aktiv bleiben. Bei fehlenden Mikromenütasten /reload verwenden."

K.locales.de["readyHunterTitle"]="Hunter-Komplettlayout · 1920×1080"
K.locales.de["readyHunterHelp"]="Installiert Hunter-Design, Blizzard-Layout und KerimAnka-UI-Einstellungen gemeinsam. Vor dem Neuladen wird der bisherige Zustand gesichert. Tastenbelegungen bleiben erhalten."
K.locales.de["readyUsesBT"]="Automatische Quelle: neues Bartender-Profil; Blizzard-Leisten 2 und 3 werden ebenfalls vorbereitet."
K.locales.de["readyUsesNative"]="Blizzard-Leisten werden verwendet; Aktionsleisten 2 und 3 werden aktiviert."
K.locales.de["readyApplyHunter"]="Hunter-Komplettlayout anwenden"
K.locales.de["readyMissing"]="Für diese Klasse gibt es noch kein fertiges Layout."
K.locales.de["readyUnavailable"]="Benötigte Spieleinstellungen sind momentan nicht verfügbar."
K.locales.de["readyBTUnavailable"]="Diese Bartender-Version oder ihr Profilsystem ist nicht mit der Vorlage kompatibel."
K.locales.de["readyApplyFailed"]="Das Layout konnte nicht vollständig angewendet werden. Die Sicherung unter Profile kann wiederhergestellt werden."

-- First-open account introduction.
K.locales.de["introReplay"]="Einführung erneut anzeigen"
K.locales.de["introWelcome"]="Willkommen bei KerimAnka UI"
K.locales.de["introWelcomeBody"]="Beginne unter Profile, um ein fertiges Klassenlayout einzurichten. Wähle Profile anzeigen oder die markierte Schaltfläche Profile. Du kannst diese Einführung überspringen; sie erscheint nur einmal pro Charakter."
K.locales.de["introProfilesTitle"]="Profile · dein Einstieg"
K.locales.de["introReadyBody"]="Das markierte Klassenlayout installiert Anordnung und Design für 1920×1080. Deine bisherigen Einstellungen werden gesichert, Tastenbelegungen bleiben erhalten und die UI wird neu geladen. Schließe diesen Hinweis und wähle dann Anwenden."
K.locales.de["introNoPresetBody"]="Für diese Klasse gibt es noch kein fertiges Layout. Hier kannst du Einstellungen speichern oder ein passendes Profil eines anderen Charakters kopieren. Neue Klassenlayouts erscheinen hier, sobald sie verfügbar sind."
K.locales.de["introSkip"]="Überspringen"
K.locales.de["introGoProfiles"]="Profile anzeigen"
K.locales.de["introDone"]="Verstanden"

K.locales.de["petBarBTDisabled"]="Aktiviere bei laufendem Bartender dessen Begleiterleiste. Unser Hintergrund folgt dieser Leiste. Für die Blizzard-Begleiterleiste deaktiviere Bartender und lade die UI neu."

K.locales.de["hunterRange_ranged"]="FERNKAMPF"
K.locales.de["hunterRange_dead"]="TOTE ZONE"
K.locales.de["hunterRange_melee"]="NAHKAMPF"
K.locales.de["hunterRange_far"]="ZU WEIT"
K.locales.de["hunterRange_close"]="ZU NAH"
K.locales.de["hunterRange_unknown"]="REICHWEITE ?"
K.locales.de["hunterAspect_cheetahText"]="Gepard aktiv: Aspekt wechseln!"
K.locales.de["hunterAspect_missingText"]="Wähle einen Aspekt!"
K.locales.de["hunterTextTitle"]="Eigene Warntexte"
K.locales.de["hunterTextHelp"]="Standardtexte folgen der Oberflächensprache. Eigene Texte bleiben unverändert. Für automatische Texte das Feld leeren oder zurücksetzen."
K.locales.de["hunterTextReset"]="Standardtext"

K.locales.de["hunterHintPreview"]="VORSCHAU"
K.locales.de["hunterHintMove"]="Zum Verschieben ziehen • In den Einstellungen sperren"
K.locales.de["hunterHintRangeMove"]="Zum Verschieben ziehen • Rechtsklick: Einstellungen"
K.locales.de["hunterRangeReady"]="Hunter Range bereit. Einstellungen: KerimAnka UI."
K.locales.de["hunterAspectReady"]="Aspect Alert bereit. Einstellungen: KerimAnka UI."
K.locales.de["hunterAspectUnknown"]="Aspektinformationen sind nicht verfügbar oder eingeschränkt. Die Anzeige wird ausgeblendet, um eine falsche Warnung zu vermeiden."

K.locales.de["soundInfo"]="Soundeinstellungen gelten pro Charakter, auch Änderungen in den Spieloptionen. Neue Charaktere starten mit den Client-Standardwerten."
K.locales.de["soundMaster"]="Alle Sounds stummschalten"
K.locales.de["soundShortcutTitle"]="Sound-Schnellzugriff"
K.locales.de["soundShortcutShow"]="Sound-Schnellzugriff anzeigen"
K.locales.de["soundShortcutLock"]="Position des Sound-Schnellzugriffs sperren"
K.locales.de["soundShortcutReset"]="Position des Sound-Schnellzugriffs zurücksetzen"
K.locales.de["soundShortcutTip"]="Klicken: Musik, Umgebung und alle Sounds."
K.locales.de["soundShortcutDrag"]="Klicken: Soundmenü. Ziehen: verschieben."
K.locales.de["soundShortcut_music"]="Musik"
K.locales.de["soundShortcut_ambience"]="Umgebung"
K.locales.de["soundShortcut_all"]="Alle Sounds"
K.locales.de["soundShortcutOn"]="An"
K.locales.de["soundShortcutOff"]="Aus"
K.locales.de["soundMasterHelp"]=K.locales.de["soundInfo"]
K.locales.de["soundShortcutShowHelp"]=K.locales.de["soundInfo"]
K.locales.de["soundShortcutLockHelp"]=K.locales.de["soundInfo"]
K.locales.de["soundShortcutResetHelp"]=K.locales.de["soundInfo"]

K.locales.de["imCombinedBags"]="Taschen kombinieren"
K.locales.de["imCombinedBagsHelp"]="Wird pro Charakter gespeichert. Neue Charaktere starten mit kombinierten Taschen. Änderungen in den Spieloptionen und im Taschenmenü werden übernommen. Auswahl und tatsächliche Taschenansicht werden gemeinsam wiederhergestellt. Taschenaddons wie Bagnon behalten die Kontrolle."

K.locales.de["qjSafetyPaused"]="Erweiterungen des Questtrackers vorübergehend pausiert"
K.locales.de["qjSafetyHelp"]="Blizzards ursprünglicher Tracker bleibt aktiv. Gebietsgruppen und Mausrad-Scrolling sind pausiert, da sie den Bearbeitungsmodus und eingeschränkte Aura-Aktualisierungen beeinflusst haben. Einstellungen bleiben gespeichert."
K.locales.de["readyMeterStageRequired"]="Die Meter-Einrichtung muss vor dem Neuladen vorbereitet werden. Das fertige Klassenlayout erneut anwenden."
K.locales.de["readyMeterPrepareFailed"]="Meter-Vorbereitung fehlgeschlagen. Den ausstehenden Profilvorgang abbrechen und vor einem neuen Versuch neu laden."

K.locales.de["qjNativeHelp"]="Gruppiert von Blizzard verfolgte Quests nach Gebiet und ergänzt Mausrad-Scrollen. Eine unabhängige Ansicht ersetzt keine gemeinsamen Blizzard-Layoutmodule. Quests per Klick auf der Karte öffnen und Questgegenstände über das Symbol daneben benutzen."
K.locales.de["qjHeightHelp"]="Position und Höhe im Bearbeitungsmodus einstellen. Während der Bearbeitung erscheint die Standardansicht. Wegen geschützter Questgegenstand-Tasten warten Listenaktualisierungen und Scrollen bis zum Kampfende."

K.locales.de["fpsTitle"]="FPS-Anzeige"
K.locales.de["fpsShow"]="FPS-Anzeige einblenden"
K.locales.de["fpsLock"]="FPS-Position sperren"
K.locales.de["fpsReset"]="FPS-Position zurücksetzen"
K.locales.de["fpsShowHelp"]="Zeigt den FPS-Wert des Spiels. Pro Charakter gespeichert; MoveAny ist nicht nötig."
K.locales.de["fpsLockHelp"]="Zum Verschieben mit der linken Maustaste ausschalten. Gesperrt werden Mausklicks durchgelassen."
K.locales.de["fpsHomeHelp"]="Standardposition rechts über EP und Schadensanzeige. Entsperren, verschieben und wieder sperren. Bei MoveAny dessen FPS-Option ausschalten. Der spielinterne Strg+R-Zähler ist unabhängig."

K.locales.de["readyRogueTitle"]="Rogue-Komplettlayout · 1920×1080"

K.locales.de["readyRogueHelp"]="Installiert Rogue-Design, Blizzard-Layout und KerimAnka-UI-Einstellungen gemeinsam. Vor dem Neuladen wird der bisherige Zustand gesichert. Tastenbelegungen bleiben erhalten."

K.locales.de["readyApplyRogue"]="Rogue-Komplettlayout anwenden"

K.locales.de["readyBTDeferredFailed"]="Die automatische Bartender-Einrichtung ist fehlgeschlagen. Dein bisheriges Profil bleibt erhalten. Wende das Klassen-Komplettlayout unter Profile erneut an, um es noch einmal zu versuchen."

K.locales.de["ftPreviewHint"]="VORSCHAU - Ziehen / Rechtsklick: Einstellungen"
K.locales.de["ftDragHint"]="Ziehen / Rechtsklick: Einstellungen"

K.locales.de["art_paladinBackingEnabled"]="Dunklen Hintergrund anzeigen"
K.locales.de["art_paladinBackingAlpha"]="Hintergrunddeckkraft"
K.locales.de["art_paladinRailEnabled"]="Obere Zierleiste anzeigen"
K.locales.de["art_paladinRailX"]="Zierleiste horizontal verschieben"
K.locales.de["art_paladinRailY"]="Zierleiste vertikal verschieben"
K.locales.de["art_paladinRailWidth"]="Breite der Zierleiste (%)"
K.locales.de["art_paladinRailHeight"]="Höhe der Zierleiste (%)"
K.locales.de["art_paladinLeftSpread"]="Linke Seite erweitern"
K.locales.de["art_paladinRightSpread"]="Rechte Seite erweitern"
K.locales.de["artSkinPaladinAlliance"]="Allianz · Silberne Hand"
K.locales.de["artSkinPaladinHorde"]="Horde · Blutritter"
K.locales.de["paladinArtTitle"]="Paladin-Design"
K.locales.de["paladinArtHelp"]="Die Fraktion bestimmt das erste Design. Beide Designs sind wählbar; Aktionsleisten, Minikarte und Einheitenfenster wechseln gemeinsam. Oberleiste und Hintergrund sind separat einstellbar."

K.locales.de["art_paladinBottomHeight"]="Dicke der unteren Leiste"

K.locales.de["art_paladinRailHeight"]="Dicke der oberen Leiste"
K.locales.de["paladinArtHelp"]="Ein zusammenhängender Rahmen außerhalb der gewählten Schaltflächen. Breite, Höhe und Position ändern den gesamten Rahmen; die Ecken bleiben verbunden. Obere und untere Dicke sind einstellbar. Beide Fraktionsdesigns sind wählbar."

K.locales.de["readyPaladinTitle"]="Paladin-Komplettlayout · 1920×1080"

K.locales.de["readyPaladinHelp"]="Installiert Paladin-Design, Blizzard-Layout und KerimAnka-UI-Einstellungen gemeinsam. Vor dem Neuladen wird der bisherige Zustand gesichert. Tastenbelegungen bleiben erhalten."

K.locales.de["readyApplyPaladin"]="Paladin-Komplettlayout anwenden"

K.locales.de["qjQuestieTracker"]="Questie-Questtracker verwenden"

K.locales.de["qjQuestieHelp"]="Standardmäßig aus, damit keine doppelten Tracker erscheinen. Karten- und Minikartensymbole bleiben verfügbar. Änderungen werden nach dem Neuladen wirksam."

K.locales.de["qjQuestieReload"]="UI neu laden, um die Questie-Tracker-Auswahl anzuwenden."

K.locales.de["introWelcomeBody"]="Hier beginnen: Öffne Profile und wende das fertige Layout deiner Klasse an.\n\nKlassendesigns und zusätzliche Anzeigen bleiben AUS, bis du ein Layout wählst oder sie selbst aktivierst. Diese Einführung erscheint einmal pro Charakter."

K.locales.de["introReadyBody"]="Wende das fertige Klassenlayout mit der Schaltfläche unten an. Layout für 1920×1080, Design und gespeicherte Einstellungen werden gemeinsam installiert.\n\nDeine bisherigen Einstellungen werden gesichert und Tastenbelegungen bleiben erhalten. Positionen beginnen GESPERRT. Danach wird das Interface neu geladen."

K.locales.de["introNoPresetBody"]="Für diese Klasse gibt es noch kein fertiges Layout.\n\nAktiviere und ordne die gewünschten Module selbst an oder importiere ein kompatibles Profil. Positionen beginnen gesperrt; entsperre sie nur zum Verschieben."

K.locales.de["introSkip"]="Manuell einrichten"

K.locales.de["ufMoveHelp"]="Live-Einheitenfenster verschieben: Positionssperre ausschalten, dann außerhalb des Kampfes ALT halten und mit der LINKEN Maustaste ziehen. Anschließend wieder sperren. Entsperren allein reicht zum Verschieben nicht aus."

K.locales.de["introPreparedTitle"]="Bereit zum Abschließen"

K.locales.de["introPreparedBody"]="Das Layout ist vorbereitet und die Sicherung wurde gespeichert.\n\nKlicke unten auf Neu laden und abschließen. Dieser separate Klick übermittelt dem Spiel die Neulade-Anforderung direkt. Abbrechen stellt die vorbereiteten Änderungen zurück."

K.locales.de["introReload"]="Neu laden und abschließen"

K.locales.de["introReadyBody"]="Bereite das fertige Klassenlayout mit der Schaltfläche unten vor: Layout für 1920×1080, Design und gespeicherte Einstellungen.\n\nDeine bisherigen Einstellungen werden gesichert und Tastenbelegungen bleiben erhalten. Positionen beginnen GESPERRT. Im nächsten Schritt lädst du die UI neu."

K.locales.de["introCancel"]="Abbrechen"

K.locales.de["artSkinWarriorAlliance"]="Allianz · Eiserne Vorhut"
K.locales.de["artSkinWarriorHorde"]="Horde · Eiserne Vorhut"
K.locales.de["artSkinWarriorIron"]="Schwarzeisen · Nur Aktionsleiste"
K.locales.de["artSkinWarriorArena"]="Arena · Nur Aktionsleiste"
K.locales.de["art_backingRailEnabled"]="Obere Zierleiste anzeigen"
K.locales.de["artSkinWarriorHelp"]="Allianz und Horde wechseln Aktionsleiste, Minikarte, Einheitenrahmen und Schadensanzeige gemeinsam. Schwarzeisen und Arena ändern nur die Aktionsleiste und behalten die letzte Fraktionsauswahl. Anfangs gilt die Fraktion des Charakters."

K.locales.de["plLegacy"]="Alter Eintrag: nur KerimAnka UI. Den Quellcharakter einmal betreten und ausloggen, um Blizzard/Bartender zu speichern."
K.locales.de["plBoth"]="Übernimmt KerimAnka UI + zuletzt gespeichertes Blizzard-Layout + Bartender-Profil."
K.locales.de["plEdit"]="Übernimmt KerimAnka UI + zuletzt gespeichertes Blizzard-Layout."
K.locales.de["plBT"]="Übernimmt KerimAnka UI + zuletzt gespeichertes Bartender-Profil."
K.locales.de["plInvalid"]="Ungültige Layout-Aufzeichnung. Beim Quellcharakter neu speichern."
K.locales.de["plBTIncompatible"]="Gespeicherte Bartender-Version oder Module sind mit dieser Installation nicht kompatibel."
K.locales.de["plBTFailed"]="Bartender-Profil konnte nicht übernommen werden. Das vorherige Profil wurde beibehalten."
K.locales.de["pfIntro"]="Charaktereinträge werden beim Einloggen, Öffnen der Profile und Ausloggen aktualisiert. Übernommen werden die zuletzt gespeicherten KerimAnka-UI-, Blizzard- und verfügbaren Bartender-Layouts. Alte Quellcharaktere einmal besuchen. Benannte Profile behalten ihren gespeicherten Stand."
K.locales.de["pfApplyWarning"]="Übernimmt KerimAnka UI und vorhandene Blizzard-/Bartender-Layouts. Der vorherige Stand wird gesichert. Bestätigen und anschließend die Oberfläche neu laden."
K.locales.de["pfTransferHelp"]="Der Code enthält nur KerimAnka-UI-Einstellungen. Blizzard/Bartender werden über die gespeicherten Profile oben übernommen."
K.locales.de["pfTransfer"]="Code-Übertragung · Nur KerimAnka UI"

K.locales.de["plNativeName"]="Blizzard-Layout: %s"

K.locales.de["readyWarriorTitle"]="Krieger-Komplettlayout · 1920×1080"

K.locales.de["readyWarriorHelp"]="Installiert Krieger-Design, Blizzard-Layout und KerimAnka-UI-Einstellungen gemeinsam. Vor dem Neuladen wird der bisherige Zustand gesichert. Tastenbelegungen bleiben erhalten."

K.locales.de["readyApplyWarrior"]="Krieger-Komplettlayout anwenden"

K.locales.de["ufShamanTotems"]="Schamanentotems"

K.locales.de["uf_shamanTotems"]="Aktive Totems anzeigen"

K.locales.de["uf_shamanTotemSize"]="Totemsymbolgröße"

K.locales.de["uf_shamanTotemGap"]="Abstand zwischen Totems"

K.locales.de["uf_shamanTotemX"]="Totems: Horizontale Position"

K.locales.de["uf_shamanTotemY"]="Totems: Vertikale Position"

K.locales.de["ufShamanTotemsHelp"]="Verschiebt Blizzards Anzeige aktiver Totems unter den Spielerrahmen. Symbole, Restlaufzeiten und Toteminteraktionen werden vom Spiel verwaltet, auch bei Totems ohne Spielerbuff. Die Vorschau zeigt vier Beispiele. Die Position bezieht sich auf die linke untere Ecke des Spielerrahmens."

K.locales.de["readyShamanTitle"]="Schamane-Komplettlayout · 1920×1080"

K.locales.de["readyShamanHelp"]="Installiert Schamane-Design, Blizzard-Layout und KerimAnka-UI-Einstellungen gemeinsam. Vor dem Neuladen wird der bisherige Zustand gesichert. Tastenbelegungen bleiben erhalten."

K.locales.de["readyApplyShaman"]="Schamane-Komplettlayout anwenden"

K.locales.de["readyWarlockTitle"]="Hexenmeister-Komplettlayout · 1920×1080"

K.locales.de["readyWarlockHelp"]="Installiert Hexenmeister-Design, Blizzard-Layout und KerimAnka-UI-Einstellungen gemeinsam. Vor dem Neuladen wird der bisherige Zustand gesichert. Tastenbelegungen bleiben erhalten."

K.locales.de["readyApplyWarlock"]="Hexenmeister-Komplettlayout anwenden"

K.locales.de["readyMageTitle"]="Magier-Komplettlayout · 1920×1080"

K.locales.de["readyMageHelp"]="Installiert Magier-Design, Blizzard-Layout und KerimAnka-UI-Einstellungen gemeinsam. Vor dem Neuladen wird der bisherige Zustand gesichert. Tastenbelegungen bleiben erhalten."

K.locales.de["readyApplyMage"]="Magier-Komplettlayout anwenden"

K.locales.de["readyPriestTitle"]="Priester-Komplettlayout · 1920×1080"

K.locales.de["readyPriestHelp"]="Installiert Priester-Design, Blizzard-Layout und KerimAnka-UI-Einstellungen gemeinsam. Vor dem Neuladen wird der bisherige Zustand gesichert. Tastenbelegungen bleiben erhalten."

K.locales.de["readyApplyPriest"]="Priester-Komplettlayout anwenden"

K.locales.de["readyDruidTitle"]="Druiden-Komplettlayout · 1920×1080"

K.locales.de["readyDruidHelp"]="Installiert Druiden-Design, Blizzard-Layout und KerimAnka-UI-Einstellungen gemeinsam. Vor dem Neuladen wird der bisherige Zustand gesichert. Tastenbelegungen bleiben erhalten."

K.locales.de["readyApplyDruid"]="Druiden-Komplettlayout anwenden"

K.locales.de["readyConfirmWarning"]="Deine aktuellen Einstellungen werden gesichert und durch das fertige Layout ersetzt. Danach wird die Benutzeroberfläche neu geladen. Zum Fortfahren bestätigen."

K.locales.de["readyConfirmApply"]="Bestätigen und anwenden"

K.locales.de["readyConfirmCancel"]="Abbrechen"

K.locales.de["pfSelectedHint"]="Klicke, um diesen Eintrag anzuwenden. Vor dem Fortfahren ist eine Bestätigung erforderlich."

K.locales.de["pfPendingActions"]="Die Einstellungen sind vorbereitet. Lade die Benutzeroberfläche neu, um sie anzuwenden, oder verwirf die ausstehende Änderung."

-- Unit Frames: options, auras, summon rows, preview and help.
K.locales.de["upElite"]="ELITE"

-- Experience and Reputation: widget, text, colors, preview and help.
K.locales.de["xpSampleFaction"]="Beispielfraktion"
K.locales.de["xpSamplePet"]="Beispielbegleiter"

-- Profiles: saved records, transfer, undo, class presets and help.
K.locales.de["pfStorageHelp"]="Bis zu 32 benannte Profile und 64 Charakteraufzeichnungen; insgesamt 2 MiB einschließlich Blizzard-/Bartender-Layouts. Charakteraufzeichnungen ersetzen bei Aktualisierung ihre vorherige Version. Bei Platzmangel können die ältesten entfernt werden; benannte Profile werden nie automatisch gelöscht. Die Sicherung zum Rückgängigmachen wird separat gespeichert."

-- Clarify copy sources, sound preset and shared artwork color controls.
K.locales.de["pfSourceHint"]="Der gewählte Eintrag ist die Kopierquelle. Charakterspezifische Änderungen hier ändern den Quelleintrag nicht. Das Aussehen des Einstellungsfensters gilt für alle Charaktere."
K.locales.de["clicksHelp"]="Schaltet sechs voreingestellte Fähigkeitsfehler- und Klickgeräusche stumm. Gesprochene Fehlermeldungen werden separat eingestellt."
K.locales.de["backingColorHelp"]="Ändert den Hintergrund der Klassengestaltung hinter den Aktionstasten. Dekoration und Tastenränder bleiben erhalten. Unter Klassengestaltung und Leistenhintergrund wird dieselbe Einstellung angezeigt."

-- Custom sound muting: per-character state, honest test results and preview controls.
K.locales.de["custom"]="Eigene Geräusche stummschalten"
K.locales.de["customHelp"]="Numerische Sounddatei-IDs durch Kommas oder Leerzeichen trennen. Hinzufügen aktiviert die Stummschaltung für diesen Charakter. Datei-IDs statt SoundKit-IDs verwenden. Ein Ereignis kann mehrere Dateien nutzen. Anhören umgeht die Stummschaltung kurzzeitig; Prüfen nicht."
K.locales.de["empty"]="Keine eigenen Geräusche zum Stummschalten eingetragen."
K.locales.de["soundCustomInfo"]="Eine hinzugefügte ID aktiviert die Stummschaltung für diesen Charakter. Anhören umgeht sie zur Vorschau. Prüfen versucht die Wiedergabe mit aktiver Stummschaltung; es sollte still bleiben."
K.locales.de["soundMuteActive"]="Stummschaltung aktiv"
K.locales.de["soundMuteFailed"]="Stummschaltung fehlgeschlagen"
K.locales.de["soundMuteUnavailable"]="Stummschaltung nicht verfügbar"
K.locales.de["soundMuteTest"]="Prüfen"
K.locales.de["soundTestPlayed"]="Der Test hat die Wiedergabe gestartet. Hörst du den Ton, wird diese Datei nicht stummgeschaltet. Prüfe die ID und andere Sound-Addons."
K.locales.de["soundTestSilent"]="Die Wiedergabe startete nicht. Das passt zur Stummschaltung; deaktivierte Tonkanäle oder eine ungültige Datei können dasselbe bewirken. Prüfe die Datei mit Anhören."
K.locales.de["soundAdded"]="Sound-IDs für diesen Charakter gespeichert. Den Status zeigen die einzelnen Einträge."
K.locales.de["soundRemoved"]="Aus der eigenen Stummschaltung entfernt. Eine Voreinstellung oder ein anderes Addon kann die Datei weiterhin stummschalten."
K.locales.de["stopPreview"]="Vorschau stoppen"
K.locales.de["stopPreviewHelp"]="Stoppt nur die hier mit Anhören oder Prüfen gestartete Wiedergabe. Ändert die Stummschaltung nicht."

-- Small curated sound groups; no automatic muting.
K.locales.de["sgTitle"]="Vorgefertigte Geräuschgruppen"
K.locales.de["sgHelp"]="Gruppen verwalten dieselbe charakterbezogene Soundliste. Stummschalten fügt Dateien hinzu, Freigeben entfernt sie. Gemeinsame Dateien können auch andere Spieler betreffen. Keine Gruppe wird automatisch aktiviert."
K.locales.de["sgBow"]="Bogen spannen"
K.locales.de["sgBowHelp"]="Drei Varianten beim Spannen des Bogens. Abschuss- und Treffergeräusche bleiben erhalten."
K.locales.de["sgGun"]="Gewehrschüsse"
K.locales.de["sgGunHelp"]="Drei klassische Schussvarianten. Nachladegeräusche haben eine eigene Gruppe."
K.locales.de["sgReload"]="Gewehr nachladen"
K.locales.de["sgReloadHelp"]="Mechanik- und Nachladegeräusche vor dem Schuss. Schüsse haben eine eigene Gruppe."
K.locales.de["sgWand"]="Zauberstab abschießen"
K.locales.de["sgWandHelp"]="Abschussgeräusche für verschiedene Magiearten des Zauberstabs. Treffergeräusche können bleiben."
K.locales.de["sgEnabled"]="Stummschaltung an"
K.locales.de["sgPartial"]="Teilweise stumm"
K.locales.de["sgDisabled"]="Stummschaltung aus"
K.locales.de["sgFailed"]="Die Aktion konnte nicht abgeschlossen werden."
K.locales.de["sgMuted"]="Die Gruppe wurde zur eigenen Stummschaltung hinzugefügt."
K.locales.de["sgRestored"]="Die Gruppendateien wurden aus der eigenen Liste entfernt. Andere Einstellungen oder Addons können sie weiterhin stummschalten."
K.locales.de["sgVerified"]="In Forever bestätigt"
K.locales.de["sgPending"]="Bestätigung im Spiel ausstehend"
K.locales.de["sgListenHelp"]="Jeder Klick spielt die nächste Datei ab. Unter Dateien anzeigen lassen sich Varianten einzeln anhören."
K.locales.de["sgUnmute"]="Freigeben"
K.locales.de["sgMute"]="Stummschalten"
K.locales.de["sgHideFiles"]="Dateien ausblenden"
K.locales.de["sgFiles"]="Dateien anzeigen"

-- Community links and copy window.
K.locales.de["communityGithubTitle"]="GitHub · Fehler und Vorschläge"
K.locales.de["communityGithubHelp"]="Projekt, Updates und Fehlermeldungen. Link öffnen und Adresse kopieren."
K.locales.de["communityTwitchTitle"]="Twitch · Livestreams"
K.locales.de["communityTwitchHelp"]="KerimAnka ansehen. Streamsprache: Türkisch. Fehler bitte auf GitHub melden."
K.locales.de["communityPending"]="Die GitHub-Projektseite wurde noch nicht erstellt. Die Adresse folgt mit einem späteren Update."
K.locales.de["communityCopy"]="Strg+C zum Kopieren · Esc zum Schließen"
K.locales.de["communityReloadWaiting"]="Add-on-Änderungen ausstehend · Neu laden."

K.locales.de["bagSettingsTab"]="Einstellungen"

K.locales.de["bagMoneyTab"]="Charaktergold"

K.locales.de["bagRecordsTab"]="Taschen & Bank"
