from pathlib import Path
import re,json,hashlib,shutil,zipfile
import argparse
parser=argparse.ArgumentParser(description='Generate independent Classic Era Bags from repository sources')
parser.add_argument('--source',type=Path,required=True)
parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args()
G=args.source.resolve()/'KerimAnkaUI'
W=Path(__file__).resolve().parent
P=args.output.resolve()
if P.exists():raise SystemExit('Generation output must be a new directory')
P.mkdir(parents=True)

origin={}
def read(n):
 b=(G/n).read_bytes()
 origin[n]=hashlib.sha256(b).hexdigest()
 return b.decode('utf-8-sig').replace('\r\n','\n')

def transform(s):
 s=s.replace('KAClassic_KerimAnkaUIDB','K.account')
 s=s.replace('Interface\\\\AddOns\\\\KerimAnkaUI\\\\','Interface\\\\AddOns\\\\KerimAnkaUI_Bags\\\\')
 s=s.replace('KerimAnkaUIPanelFont','KerimAnkaBagsPanelFont').replace('KAClassicInventoryStateFont','KerimAnkaBagsInventoryFont')
 return s
GUARD='if select(2,...).blocked then return end\n'
def emit(n,s,guard=True):
 p=P/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_text((GUARD if guard else'')+s,encoding='utf-8',newline='\n')
releaseVersion=re.search(r'^## Version: (.+)$',read('KerimAnkaUI_Vanilla.toc'),re.M).group(1).strip()
assert re.fullmatch(r'[0-9]+\.[0-9]+\.[0-9]+',releaseVersion)
emit('Bootstrap.lua',(W/'src/Bootstrap.lua').read_text(encoding='utf-8-sig').replace('0.1.0-test5',releaseVersion),False)
# Only language and font machinery, not suite-specific class/helper globals.
s=read('ClassicEra/Locales.lua').split('-- Defaults follow the UI language;',1)[0]
for line in s.splitlines():
 if any(x in line for x in ['ForeverHunterRangeAPI','HunterAspectAlertAPI','ForeverThreatAPI']):s=s.replace(line+'\n','')
emit('Shared/LocaleFonts.lua',transform(s))
statusText={'en':('Independent bag settings. Changes are saved for this character.','Another bag replacement is active. It retains control of the bag windows.'),'tr':('Bağımsız çanta ayarları. Değişiklikler bu karakter için kaydedilir.','Başka bir çanta eklentisi etkin. Çanta pencerelerinin yönetimi o eklentide kalır.'),'de':('Eigenständige Tascheneinstellungen. Änderungen werden für diesen Charakter gespeichert.','Eine andere Taschenerweiterung ist aktiv und verwaltet die Taschenfenster.'),'zhCN':('独立背包设置。更改按角色保存。','其他背包插件已启用，背包窗口仍由其管理。'),'frFR':('Réglages indépendants des sacs. Modifications enregistrées pour ce personnage.','Un autre module de sacs est actif et conserve le contrôle des fenêtres.'),'itIT':('Impostazioni indipendenti delle borse, salvate per questo personaggio.','Un altro addon delle borse è attivo e mantiene il controllo delle finestre.'),'esES':('Ajustes independientes de bolsas. Se guardan para este personaje.','Otro addon de bolsas está activo y mantiene el control de las ventanas.'),'ptBR':('Configurações independentes de bolsas, salvas para este personagem.','Outro addon de bolsas está ativo e mantém o controle das janelas.'),'ruRU':('Независимые настройки сумок сохраняются для этого персонажа.','Другой аддон сумок активен и сохраняет управление окнами.') }
for lang in ['en','de','tr','zhCN','frFR','itIT','esES','ptBR','ruRU']:
 s=read('ClassicEra/Locales/'+lang+'.lua');values={}
 pat=re.compile(r'^\s*\["([^"\n]+)"\]\s*=\s*("(?:\\.|[^"\\])*")\s*,?|^K\.locales\.\w+\["([^"\n]+)"\]\s*=\s*("(?:\\.|[^"\\])*")',re.M)
 for m in pat.finditer(s):
  key=m.group(1)or m.group(3);value=m.group(2)or m.group(4)
  if key.startswith(('im','bs','bag','merchant'))or key in ['inventory','on','off','reload','close','language','saved','unavailable','combatLock','home','backdrop','art','units','minimap','experience','quests','details','range','threat','aspect','profiles','interface','leTitle','resize','resizeHelp','heightResize','heightResizeHelp','reloadHelp','languageHelp'] or key.startswith('community'):
   values[key]=value
 values['kbSettingsHelp']=json.dumps(statusText[lang][0],ensure_ascii=False);values['kbOtherBags']=json.dumps(statusText[lang][1],ensure_ascii=False)
 editionText={
 'en':('Independent edition','Bags only. Other categories belong to the full KerimAnka UI suite.','Available in the full KerimAnka UI suite. This independent edition includes Bags only.'),
 'tr':('Bağımsız sürüm','Yalnız çanta. Diğer kategoriler tam KerimAnka UI paketinde bulunur.','Tam KerimAnka UI paketinde kullanılabilir. Bu bağımsız sürüm yalnızca çantayı içerir.'),
 'de':('Eigenständige Ausgabe','Nur Taschen. Weitere Kategorien gehören zur vollständigen KerimAnka-UI-Suite.','In der vollständigen KerimAnka-UI-Suite verfügbar. Diese Ausgabe enthält nur Taschen.'),
 'zhCN':('独立版','仅提供背包功能。其他分类属于完整的 KerimAnka UI 套件。','此功能在完整的 KerimAnka UI 套件中可用。此独立版仅包含背包。'),
 'frFR':('Édition indépendante','Sacs uniquement. Les autres catégories appartiennent à la suite complète KerimAnka UI.','Disponible dans la suite complète KerimAnka UI. Cette édition contient uniquement les sacs.'),
 'itIT':('Edizione indipendente','Solo borse. Le altre categorie appartengono alla suite completa KerimAnka UI.','Disponibile nella suite completa KerimAnka UI. Questa edizione include solo le borse.'),
 'esES':('Edición independiente','Solo bolsas. Las demás categorías pertenecen a la suite completa KerimAnka UI.','Disponible en la suite completa KerimAnka UI. Esta edición solo incluye bolsas.'),
 'ptBR':('Edição independente','Somente bolsas. As outras categorias pertencem à suíte completa KerimAnka UI.','Disponível na suíte completa KerimAnka UI. Esta edição inclui somente bolsas.'),
 'ruRU':('Независимая версия','Только сумки. Другие разделы доступны в полном наборе KerimAnka UI.','Доступно в полном наборе KerimAnka UI. Эта независимая версия содержит только сумки.')}
 for key,value in zip(['kbIndependent','kbIndependentHelp','kbRequiresSuite'],editionText[lang]):values[key]=json.dumps(value,ensure_ascii=False)

 assert 'bagSettingsTab'in values and'imCombinedBags'in values
 emit('Locales/'+lang+'.lua','local _,K=...\nK.locales.'+lang+'={\n'+''.join(' ['+json.dumps(k,ensure_ascii=False)+']='+v+',\n'for k,v in values.items())+'}\n')
# The existing native bag manager, with all micro-menu code and hooks removed.
core=read('ClassicEra/Core.lua');a=core.index('-- Native inventory shelf and micro-menu layout.');z=core.index('-- Additive item overlays;',a);s=core[a:z]
a=s.index('local microFields=');z=s.index('local function WatchBartender()',a);s=s[:a]+s[z:]
s=s.replace('local function BTMicro() return M.BartenderOwns("MicroMenu") end\n','')
s=s.replace('local bagState,microState,bagRow,bagToggle,microArt,mover,hiddenNativeBar','local bagState,bagRow,bagToggle,hiddenNativeBar')
s=s.replace(',microEnabled=true,microSize=28,microGap=1,microLocked=true','')
s=s.replace(',microSize={18,48},microGap={0,16},microX={0,10000},microY={0,10000}','')
s=s.replace('{"BagBar","MicroMenu"}','{"BagBar"}').replace('{"ToggleModule","OnEnable","OnDisable","ApplyConfig","MicroMenuBarShow","RestoreMicroButtonParent","MicroMenuSetParent","UpdateMicroButtonsParent"}','{"ToggleModule","OnEnable","OnDisable","ApplyConfig"}')
s=s.replace('WatchBartender();WatchMicro()','WatchBartender()').replace('ApplyBags();M.ApplyNativeBagHide();ApplyMicro()','ApplyBags();M.ApplyNativeBagHide()')
s=s.replace('if mover then mover:Hide() end;','').replace('if mover then mover:Hide() end','')
s=s.replace(' if BT() and BTMicro() then return "imBTBoth" end\n','').replace(' if BTMicro() then return "imBTMicro" end\n','')
s=s.replace(' return "imHelp"',' return "kbSettingsHelp"').replace('return "imOtherBags"','return "kbOtherBags"').replace('then return "imUnavailable" end','then return "kbSettingsHelp" end').replace('-- Native inventory shelf and micro-menu layout.','-- Bag-only native shelf manager extracted from the suite.')
s=s.replace('if type(value)~="number" then return false end','if type(value)~="number"or value~=value or math.abs(value)==math.huge then return false end')
assert 'MicroMenu'not in s and 'microEnabled'not in s and 'ApplyMicro'not in s
emit('Shared/BagManager.lua','local _,K=...\n'+transform(s))
a=core.index('-- Additive item overlays;');z=core.index('-- Optional native Edit Mode companion',a)
emit('Shared/NativeItemLooks.lua','local _,K=...\n'+transform(core[a:z]))
# Existing compact settings widgets; no suite navigation, profiles, cvars or modules.
window=read('ClassicEra/Window.lua');a=window.index('local function Backdrop(');z=window.index('local function ToggleRow(',a)
prefix="local _,K=...\nlocal gold,white,muted={.73,.62,.41},{.9,.91,.88},{.59,.63,.61}\nlocal pool,used,labels,labelUsed={},0,{},0\nlocal page,heading,subtitle,footer\nlocal nav,tabs={},{}\nlocal languageButton,languageMenu,languageDismiss\nlocal UpdateLanguageLabel\nlocal panelDefaults={scale=.8721474221494858,height=819.36083984375,position={x=0,y=0}}\n"
# Share the actual suite shell (not a visually similar replacement). Only the
# capability adapter differs: all navigation except Bags is inert.
helpers=window[window.index('UpdateLanguageLabel=function()'):window.index('-- One visible first-open guide')]
shell=window[window.index('function K.ApplyWindowScale()'):window.index('-- Profile page shares')]
shell=shell.replace('KerimAnkaUIWindow','KerimAnkaBagsSettings')
shell=shell.replace('    local f=CreateFrame("Frame","KerimAnkaBagsSettings"','    if K.window then return end\n    local f=CreateFrame("Frame","KerimAnkaBagsSettings"')
start=shell.index('    f:SetScript("OnHide",function()')
end=shell.index('\n    local header=',start)
shell=shell[:start]+'    f:SetScript("OnHide",function() K.CloseCommunity();SavePosition();if languageMenu then languageMenu:Hide();languageDismiss:Hide()end;K.HideTooltip()end)'+shell[end:]
start=shell.index('    local layoutButton=');end=shell.index('    languageButton=',start)
shell=shell[:start]+shell[end:]
shell=shell.replace('ver:SetText(K.version)','ver:SetText("KerimAnka Bags — "..K.L("kbIndependent").." | "..K.version);f.edition=ver')
start=shell.index('    local keys={"home"}');end=shell.index('\n    for i,key in ipairs(keys)',start)
shell=shell[:start]+'    local keys={"home","backdrop","art","units","minimap","inventory","experience","quests","details","range","threat","aspect"}'+shell[end:]
start=shell.index('        for _,module in ipairs(K.modules)');end=shell.index('        NavAccent(b);',start)
shell=shell[:start]+shell[end:]
start=shell.index('    introProfiles=profiles');end=shell.index('    heading=',start)
shell=shell[:start]+shell[end:]
shell=shell.replace('local heightGrip=CreateFrame("Button",nil,f);','local heightGrip=CreateFrame("Button",nil,f); f.heightGrip=heightGrip;')
shell=shell.replace('if not K.db.onboardingSeen then K.StartIntro(false) elseif not K.openingPage then K.Render() end','K.Render()')
shell=shell.replace('    K.LayoutWindow()\n    f:SetScript("OnShow"','    f.nav=nav\n    for _,button in ipairs(nav)do\n        button.available=button.key=="inventory"\n        if not button.available then\n            button:SetScript("OnClick",nil)\n            button:SetScript("OnEnter",function(self)K.ShowTooltip(self,K.L(self.key),K.L("kbRequiresSuite"))end)\n            button:SetScript("OnLeave",K.HideTooltip)\n        end\n    end\n    K.LayoutWindow()\n    f:SetScript("OnShow"')
# The independent header has no layout-editor button. Its whole free region
# must remain draggable, without overlapping the language/close buttons.
shell=shell.replace('title:SetSize(450,60)','title:SetSize(772,60);f.dragHandle=title')
# Keep the content viewport tied to the actual height, above the fixed footer.
shell=shell.replace('    local count=math.max(1,#nav-2)', '''
    if K.scroll then
        local viewport=math.max(1,height-270)
        K.scroll:SetHeight(viewport)
        local content=K.scroll:GetScrollChild()
        if content and page then content:SetHeight(math.max(viewport,page:GetHeight()+20))end
    end
    local count=math.max(1,#nav-2)''')
shell=shell.replace('content:SetHeight(math.max(415,height+20))','content:SetHeight(math.max(K.scroll:GetHeight(),height+20))')
shell=shell.replace('K.ApplyWindowScale();K.Render()','K.ApplyWindowScale();if not K.openingPage then K.Render()end')
assert 'ModuleBadge' not in shell and 'K.modules' not in shell and 'StartIntro' not in shell and 'K.VisibleModules' not in shell
emit('Settings/Panel.lua',prefix+transform(window[a:z]).replace('frame.label:SetTextColor(unpack(white)); frame.label:SetWidth(w-10)', 'frame.label:SetTextColor(unpack(white)); frame.label:SetWidth(w-10);frame.label:SetHeight(math.max(1,h-8));frame.label:Show()')+transform(helpers)+transform(shell)+'\n'+(W/'src/PanelShell.lua').read_text(encoding='utf-8-sig'))
emit('Settings/Community.lua',transform(read('ClassicEra/Community.lua')).replace('KerimAnkaUICommunityPopup','KerimAnkaBagsCommunityPopup'))
options=read('ClassicEra/ActionBarOptions.lua');a=options.index("local inventoryTab='settings'");b=options.index('function K.DrawMicroMenuPage',a);c=options.index('function K.DrawInventoryPage',b);z=options.index('function K.DrawErrorOptions',c)
emit('Settings/BagOptions.lua','local _,K=...\n'+transform(options[a:b]+options[c:z]).replace("or 'imMicroHelp'","or 'imBagHelp'"))
modules=['Keyring.lua','BagCompanions.lua','BagShortcut.lua','ClassicInventoryStyle.lua','ClassicBagDesigns.lua','ClassicBags.lua','ClassicItemRecords.lua','ClassicBank.lua','ClassicMerchant.lua']
for n in modules:emit('ClassicEra/'+n,transform(read('ClassicEra/'+n)))
# Media are original KerimAnka assets, copied without conversion/resampling.
assets=['LICENSE','Fonts/Ubuntu-R.ttf','Fonts/Ubuntu-B.ttf','Fonts/LICENCE.txt']+['Media/'+n for n in ['RoundedFill.tga','RoundedBorder.tga','CardGlow.tga','Circle.tga','Plus.tga','Minus.tga','Close.tga','BagShortcut.tga','Phoenix.tga','CommunityGitHub.tga','CommunityTwitch.tga']]+['ClassicEra/BagMedia/'+n for n in ['ClassicFrame.tga','LeatherFrame.tga','ControlAtlas.tga','IconAtlas.tga']]
for n in assets:
 p=P/n;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(G/n,p);origin[n]=hashlib.sha256((G/n).read_bytes()).hexdigest()
order=['Bootstrap.lua','Shared/LocaleFonts.lua']+['Locales/'+l+'.lua'for l in ['en','de','tr','zhCN','frFR','itIT','esES','ptBR','ruRU']]+['Shared/BagManager.lua','Shared/NativeItemLooks.lua','ClassicEra/Keyring.lua','ClassicEra/BagCompanions.lua','ClassicEra/BagShortcut.lua','Settings/Community.lua','Settings/Panel.lua','Settings/BagOptions.lua','ClassicEra/ClassicInventoryStyle.lua','ClassicEra/ClassicBagDesigns.lua','ClassicEra/ClassicBags.lua','ClassicEra/ClassicItemRecords.lua','ClassicEra/ClassicBank.lua','ClassicEra/ClassicMerchant.lua']
toc='''## Interface: 11509
## Title: KerimAnka Bags - Independent [Classic Era]
## Notes: Independent KerimAnka bag, bank and item-record settings. Classic Era edition.
## Group: KerimAnkaUI_Bags
## Category: Bags & Inventory
## X-Category: Bags & Inventory
## Author: Kerim Anka
## Version: 0.1.0-test5
## SavedVariables: KAClassic_KerimAnkaBagsDB
## SavedVariablesPerCharacter: KAClassic_KerimAnkaBagsCharacterDB
## OptionalDeps: KerimAnkaUI, Bartender4
## X-KerimAnka-Independent: 1
## IconTexture: Interface\\AddOns\\KerimAnkaUI_Bags\\Media\\BagShortcut.tga

'''+''.join(n.replace('/','\\')+'\n'for n in order)
toc=toc.replace('0.1.0-test5',releaseVersion)
(P/'KerimAnkaUI_Bags_Vanilla.toc').write_text(toc,encoding='utf-8');(P/'KerimAnkaUI_Bags.toc').write_text(toc,encoding='utf-8')
manifest=[]
for p in sorted(P.rglob('*')):
 if p.is_file():manifest.append({'Path':p.relative_to(P).as_posix(),'SHA256':hashlib.sha256(p.read_bytes()).hexdigest(),'Bytes':p.stat().st_size})
(P.parent/'package-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
(P.parent/'independent-source-report.json').write_text(json.dumps({'source':'Repository sources; Classic Era independent Bags','originalFiles':origin,'transforms':['private account table','owned asset root','bag-only manager extraction','settings-widget and bag-page extraction','bag translation subset','host guard before all runtime files'],'runtimeOrder':order},indent=2)+'\n')
print(json.dumps({'generatedFiles':len(manifest),'output':str(P)}))
