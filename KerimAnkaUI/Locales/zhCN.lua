-- UTF-8 panel translations. Missing entries fall back to English.
local _,K=...
K.locales.zhCN = {
 ["uf_nameOffsetY"]="名称垂直偏移",
 ["uf_petTextScale"]="宠物文字大小",
 ["art_petBar"]="宠物动作条",
 ["art_petPanelEnabled"]="显示宠物动作条背景",
 ["art_petPanelAlpha"]="宠物动作条背景不透明度",
 ["art_petPanelPadding"]="宠物动作条边距",
 ["warlockArtTitle"]="术士 — 职业装饰",
 ["artSkinFel"]="邪能黑曜石",
 ["artSkinRitual"]="灵魂仪式",
 ["art_ritualRailWidth"]="顶部饰条宽度（%）",
 ["art_ritualRailX"]="顶部饰条水平偏移",
 ["warlockRitualTitle"]="术士 — 灵魂仪式",
 ["warlockRitualHelp"]="通过上方卡片选择灵魂仪式或邪能黑曜石。底部图案保持原始比例，使用整体垂直偏移调整位置。顶部饰条独立调整，深色背景跟随所选动作条。",
 ["art_ritualBacking"]="显示深色背景",
 ["art_ritualOpacity"]="背景不透明度",
 ["art_ritualDock"]="底部装饰贴近屏幕底边",
 ["art_ritualInset"]="距屏幕底边高度",
 ["art_ritualRail"]="显示独立顶部饰条",
 ["art_ritualRailY"]="顶部饰条垂直偏移",
 ["art_ritualRailHeight"]="顶部饰条高度",
 ["abIntro"]="设置保存在当前角色。根据所选动作条来源，通过游戏设置或 Bartender 调整布局和按键绑定。",
 ["flAppliedCharacter"]="已应用配置和角色专用暴雪布局，未更改其他角色选中的布局。请检查动作条和伤害统计，恢复之前的设置可同时撤销两部分。",
 ["flAccountPlan"]="布局范围：账号，其他角色也可选择。",
 ["flCharacterPlan"]="布局范围：仅限当前角色，账号布局已满时也可使用。",
 ["flTitle"]="完整界面 — 通用暴雪布局",
 ["flHelp"]="将所选 KerimAnka UI 配置与 1920 × 1080 暴雪布局一起应用。使用内容一致的 KerimAnka UI 布局，否则新建账号布局。账号布局已满时新建角色专用布局，具体范围显示在下方。职业装饰另行决定。",
 ["flChecklist"]="测试后请检查所需动作条和伤害统计（Schadenanzeige）是否已启用。此代码不保证动作条可见性、按键绑定或所有游戏设置。使用其他分辨率或界面缩放时请检查位置。",
 ["flApply"]="所选配置 + 暴雪布局",
 ["flWarning"]="重新加载后，将应用所选插件配置和下方指定范围的暴雪布局。保存之前的设置和当前布局恢复信息，不删除已有布局。再次点击新按钮确认，然后重新加载界面。",
 ["flUnavailable"]="暴雪布局系统尚未就绪或此版本不支持，未安排更改。请打开并关闭编辑模式后重试。",
 ["flCloseEdit"]="请先保存或放弃暴雪编辑模式中的更改并关闭编辑模式，然后重试。",
 ["flInvalid"]="暴雪无法读取此布局代码，未安排更改。请检查与当前游戏版本的兼容性。",
 ["flFull"]="所选布局类别没有空位。账号和角色布局分别计数，未删除任何布局，请在编辑模式中检查布局列表。",
 ["flFailed"]="无法应用暴雪布局。插件配置可能已应用，之前的设置仍保存在撤销备份中，可使用“恢复之前的设置”返回。",
 ["flApplied"]="已应用配置和暴雪布局。请检查动作条可见性及伤害统计。恢复操作会还原之前的插件设置并选择之前的暴雪布局。",
 ["imItemLooksHelp"]="将可出售的低劣品质物品图标去色并添加小硬币，同时突出优秀及以上品质物品的边框颜色。适用于游戏自带的整合背包和独立背包。Bagnon 等背包插件保留自身外观。不会自动出售或删除物品。",
 ["aaCombatNoticeTitle"]="测试版：战斗中的守护追踪",
 ["aaCombatNotice"]="脱离战斗时可以追踪守护。战斗中，游戏会限制增益信息：即使能检测到初始状态或第一次变化，也可能无法追踪后续变化，提示也可能消失。没有提示并不表示守护未激活。请通过游戏自带的增益／光环图标确认当前守护。本功能在测试版期间开发，游戏的限制和行为今后可能发生变化。",
 ["abAlpha"]="装饰不透明度",
 ["abArt"]="显示职业装饰",
 ["abAuto"]="自动跟随动作条",
 ["abBorder"]="外边框大小",
 ["abFixed"]="固定大小和位置",
 ["abFollow"]="重新适配动作条",
 ["abGap"]="动作条周围间距",
 ["abHeight"]="装饰高度（%）",
 ["abShade"]="按钮边框亮度",
 ["abShow"]="显示按钮背景",
 ["abSlot"]="空栏位不透明度",
 ["abWidth"]="装饰宽度（%）",
 ["abX"]="水平偏移",
 ["abY"]="垂直偏移",
 ["add"]="添加",
 ["addonControl"]="插件加载",
 ["alerts"]="提醒",
 ["ambience"]="静音环境音",
 ["art"]="职业外观",
 ["artSkinHunter"]="猎人",
 ["artSkinMetal"]="简洁金属",
 ["artSkinSelected"]="已选择",
 ["artSkinUse"]="使用此外观",
 ["artSkins"]="动作条外观",
 ["aspect"]="守护提醒",
 ["backdrop"]="动作条背景",
 ["background"]="后台静音",
 ["barsAuto"]="自动",
 ["barsBT"]="Bartender",
 ["barsEditor"]="打开编辑模式",
 ["barsNative"]="暴雪",
 ["barsSource"]="动作条来源",
 ["camera"]="镜头",
 ["cardGlow"]="柔和卡片光晕",
 ["cardTone"]="卡片背景亮度",
 ["center"]="窗口居中",
 ["clicks"]="静音技能错误音效",
 ["combat"]="战斗与输入",
 ["combatLock"]="请在脱离战斗后进行此更改。",
 ["custom"]="自定义声音文件",
 ["details"]="Details 外观",
 ["dialog"]="静音对话",
 ["disableDeathEffect"]="移除幽灵灰度效果",
 ["effects"]="静音音效",
 ["errorCustom"]="自定义过滤",
 ["errorImportantOnly"]="仅显示重要提示",
 ["errorShowAll"]="显示所有提示",
 ["errors"]="隐藏红色错误提示",
 ["failed"]="游戏客户端无法应用此更改。",
 ["featureOff"]="功能已关闭",
 ["fileIds"]="声音文件 ID",
 ["ftDefault"]="默认",
 ["ftFont"]="字体",
 ["glowBlue"]="效果颜色：蓝",
 ["glowGreen"]="效果颜色：绿",
 ["glowRadius"]="阴影／光晕范围",
 ["glowRed"]="效果颜色：红",
 ["glowReset"]="恢复默认外观",
 ["glowStrength"]="阴影／光晕强度",
 ["glowStyle"]="卡片外观",
 ["goldPreset"]="暖金色",
 ["heightResize"]="窗口高度",
 ["home"]="主页",
 ["hunterOnly"]="仅限猎人",
 ["imAlign"]="放在聊天窗口下方",
 ["imBagSize"]="背包图标大小",
 ["imDock"]="将背包图标放入背包窗口",
 ["imExpanded"]="显示背包图标行",
 ["imGap"]="菜单按钮间距",
 ["imHideNativeBar"]="隐藏默认背包栏",
 ["imIconSize"]="菜单按钮大小",
 ["imJunk"]="将可出售的灰色物品去色并标记硬币",
 ["imLocked"]="锁定菜单位置",
 ["imMicro"]="自定义微型菜单",
 ["imQuality"]="增强物品品质边框",
 ["interface"]="界面",
 ["inventory"]="背包与菜单",
 ["keepImportantErrors"]="保留重要提示",
 ["language"]="语言",
 ["languageHelp"]="选择面板语言。简体中文为试用翻译，未翻译的内容显示为英语。",
 ["lightPreset"]="柔和亮光",
 ["listen"]="试听",
 ["music"]="静音音乐",
 ["notLoaded"]="未加载",
 ["off"]="关闭",
 ["on"]="开启",
 ["overview"]="概览",
 ["pendingOff"]="禁用 · 需重载",
 ["pendingOn"]="启用 · 需重载",
 ["pets"]="静音宠物声音",
 ["profiles"]="配置方案",
 ["quests"]="任务日志",
 ["queue"]="技能队列窗口",
 ["queueHelp"]="允许提前输入下一个技能的时间，单位为毫秒。数值并非越低越好，请根据延迟调整。",
 ["quick"]="快捷设置",
 ["range"]="猎人射程",
 ["reload"]="重新加载界面",
 ["reloadHelp"]="重新加载界面以应用插件启用状态的更改。保留已保存的设置。",
 ["reloadLater"]="稍后",
 ["reloadNow"]="立即重新加载",
 ["reloadPromptTitle"]="重新加载界面",
 ["remove"]="移除",
 ["resize"]="调整窗口大小",
 ["restore"]="恢复之前的设置",
 ["saved"]="设置自动保存。",
 ["scale"]="窗口缩放",
 ["shadowPreset"]="深色阴影",
 ["sounds"]="声音",
 ["speech"]="静音语音错误提示",
 ["stop"]="停止",
 ["threat"]="仇恨",
 ["ufAuras"]="增益与减益效果",
 ["ufCast"]="目标施法条",
 ["ufGeneral"]="常规与外观",
 ["ufIndicators"]="状态图标",
 ["ufPositions"]="框体位置",
 ["uf_enabled"]="自定义单位框体",
 ["uf_healthTextScale"]="生命值数字缩放",
 ["uf_levelTextScale"]="等级字体缩放",
 ["uf_locked"]="锁定位置",
 ["uf_powerTextScale"]="法力／能量数字缩放",
 ["uf_pvpSize"]="PvP 图标大小",
 ["uf_restIconSize"]="休息图标大小",
 ["uf_scale"]="框体缩放",
 ["uf_targetCastEnabled"]="显示目标施法条",
 ["uf_textScale"]="姓名字体缩放",
 ["unavailable"]="此客户端不支持",
 ["units"]="单位框体",
 ["upBuffs"]="增益效果",
 ["upCast"]="施法示例",
 ["upControl"]="预览控制",
 ["upControlHelp"]="拖动以移动图标组，使用鼠标滚轮调整大小。更改在脱离战斗后保存。",
 ["upDebuffs"]="减益效果",
 ["upExamples"]="示例效果",
 ["upNote"]="拖动／滚轮 · 点击跳转至设置 · 首行示例",
 ["upPet"]="宠物",
 ["upPetName"]="宠物示例",
 ["upPlayer"]="玩家",
 ["upPlayerName"]="玩家示例",
 ["upTarget"]="目标",
 ["upTargetName"]="目标示例",
 ["upTitle"]="实时预览",
 ["upVisible"]="显示预览",
 ["welcome"]="你的界面。你的设置。集中管理。",
 ["zoom"]="最大镜头距离",
 ["zoomHelp"]="调整镜头的最大缩放倍率，不改变当前镜头位置。游戏可能限制可用数值。",
}

-- Native damage meter appearance.
K.locales.zhCN["details"]="伤害统计"
K.locales.zhCN["dmBlizzard"]="暴雪"
K.locales.zhCN["dmDetails"]="Details 外观"
K.locales.zhCN["dmEnabled"]="显示暴雪统计窗口外观"
K.locales.zhCN["dmTrim"]="显示装饰边框"
K.locales.zhCN["dmTrimAlpha"]="边框不透明度"
K.locales.zhCN["dmBackground"]="背景不透明度"
K.locales.zhCN["dmPadding"]="边框偏移"

K.locales.zhCN["xpClassColorActive"]="职业颜色已启用。关闭后可自定义经验条颜色。"

K.locales.zhCN["mcTitle"]="小地图坐标"
K.locales.zhCN["mcHelp"]="调整游戏原有的坐标文字。请在游戏设置中开启坐标显示。调整立即生效；进入战斗或关闭窗口时停止拖动。"
K.locales.zhCN["mcUnavailable"]="此客户端的小地图坐标框体不可用。"
K.locales.zhCN["mcEnabled"]="自定义坐标位置和字体"
K.locales.zhCN["mcX"]="坐标：水平偏移"
K.locales.zhCN["mcY"]="坐标：垂直偏移"
K.locales.zhCN["mcSize"]="坐标字号"
K.locales.zhCN["mcOutline"]="坐标文字描边"
K.locales.zhCN["mcDrag"]="拖动调整位置"
K.locales.zhCN["mcLock"]="锁定位置"
K.locales.zhCN["mcReset"]="恢复默认坐标显示"

K.locales.zhCN["ufPortraitCombat"]="头像战斗文字"
K.locales.zhCN["uf_portraitCombatPlayer"]="玩家头像战斗文字"
K.locales.zhCN["uf_portraitCombatPet"]="宠物头像战斗文字"
K.locales.zhCN["uf_portraitCombatSize"]="头像战斗文字字号"
K.locales.zhCN["ufPortraitCombatHelp"]="在玩家或宠物头像上显示暴雪战斗反馈，包括受到的伤害、治疗、躲闪和吸收等结果。暴击文字更大。默认关闭，不影响目标头像或场景中的战斗文字。"

K.locales.zhCN["ufQuestie"]="Questie目标图标"
K.locales.zhCN["uf_questieTargetIcon"]="在目标头像旁显示Questie图标"
K.locales.zhCN["uf_questieIconSize"]="任务图标大小"
K.locales.zhCN["uf_questieIconX"]="任务图标：水平偏移"
K.locales.zhCN["uf_questieIconY"]="任务图标：垂直偏移"
K.locales.zhCN["ufQuestieHelp"]="显示Questie选择的任务目标图标。需要启用Questie及其目标框体图标。使用Questie的图标主题与任务进度，并遵循其Forever副本限制。位置相对于头像右上角。"

K.locales.zhCN["ufHunterSummons"]="猎人临时召唤"
K.locales.zhCN["uf_hunterSummons"]="显示猎人临时召唤"
K.locales.zhCN["uf_hunterSummonSize"]="召唤图标大小"
K.locales.zhCN["uf_hunterSummonGap"]="召唤图标间距"
K.locales.zhCN["uf_hunterSummonX"]="召唤：水平位置"
K.locales.zhCN["uf_hunterSummonY"]="召唤：垂直位置"
K.locales.zhCN["ufHunterSummonsHelp"]="使用暴雪图腾栏位及剩余时间显示猎鹰等临时召唤。仅限猎人，与光环及常驻宠物独立。预览显示两个示例。位置相对于玩家框体左下角。"

-- Independent damage-meter border edges.
K.locales.zhCN["dmEdgeTop"]="上边缘调整"
K.locales.zhCN["dmEdgeBottom"]="下边缘调整"
K.locales.zhCN["dmEdgeLeft"]="左边缘调整"
K.locales.zhCN["dmEdgeRight"]="右边缘调整"
K.locales.zhCN["dmEdgeHelp"]="正值仅将此边向外移动，负值向内移动。与通用边框偏移相加，总值不低于零。战斗外生效。"

-- Optional independent minimap icon drawer.
K.locales.zhCN["mbTitle"]="小地图插件图标"
K.locales.zhCN["mbEnabled"]="将图标收集到面板"
K.locales.zhCN["mbLocked"]="锁定面板按钮"
K.locales.zhCN["mbColumns"]="每行图标数"
K.locales.zhCN["mbSize"]="图标大小"
K.locales.zhCN["mbAngle"]="按钮环绕地图的位置"
K.locales.zhCN["mbRadius"]="距地图距离"
K.locales.zhCN["mbCount"]="个插件图标"
K.locales.zhCN["mbClick"]="左键：图标面板。右键：职业设计设置。解锁后可沿地图边缘拖动。"
K.locales.zhCN["mbHelp"]="收集已启用小地图显示的受支持插件图标。排除隐藏图标、仅鼠标悬停显示的图标及地图标记。关闭后恢复原位置。战斗外更改设置。"
K.locales.zhCN["mbConflict"]="MinimapButtonButton 已启用。为防止两个面板争用图标，KerimAnka 正在等待。请在插件列表禁用 MinimapButtonButton，然后 /reload。"

-- Dedicated minimap page and per-icon collection preferences.
K.locales.zhCN["minimap"]="小地图"
K.locales.zhCN["mmArtUnavailable"]="小地图外观设置需要加载 KerimAnka UI 职业设计模块。坐标和图标面板独立工作。"
K.locales.zhCN["mbPreferences"]="图标偏好"
K.locales.zhCN["mbCollect"]="收集到面板"
K.locales.zhCN["mbPreferencesHelp"]="关闭后图标恢复至小地图周围的原位置，不会被隐藏。若要完全隐藏，请使用该插件自身的小地图设置。"
K.locales.zhCN["mbEmpty"]="没有可列出的可见图标。请启用图标收集，并先关闭其他图标收集插件。"
K.locales.zhCN["mbClick"]="左键：图标面板。右键：小地图设置。解锁后可沿地图边缘拖动。"

-- Independent icon-drawer button art and size.
K.locales.zhCN["mbAppearance"]="面板按钮外观"
K.locales.zhCN["mbRound"]="圆形"
K.locales.zhCN["mbSquare"]="方形"
K.locales.zhCN["mbButtonSize"]="面板按钮大小"
K.locales.zhCN["mbSize"]="面板内插件图标大小"

-- Optional full-icon action range coloring.
K.locales.zhCN["arEnabled"]="为超出距离的技能着色"
K.locales.zhCN["arColor"]="距离颜色"
K.locales.zhCN["arReset"]="恢复默认红色"
K.locales.zhCN["arHelp"]="超出距离时为整个技能图标着色，与快捷键文字是否显示无关。进入距离后恢复游戏原色。支持暴雪及 Bartender 动作条；宠物动作条单独处理。"

K.locales.zhCN["mbBlockedTitle"]="图标收集不可用：MinimapButtonButton 已加载"
K.locales.zhCN["mbBlockedHelp"]="MinimapButtonButton 正在管理相同的图标，因此 KerimAnka 图标收集暂停，启用开关不可用。若要使用 KerimAnka 面板，请在插件列表中禁用 MinimapButtonButton，然后输入 /reload。地图装饰和坐标不受影响，面板偏好设置会保留。"

K.locales.zhCN["artSkinAncestral"]="先祖图腾"
K.locales.zhCN["artSkinElements"]="四大元素"
K.locales.zhCN["shamanArtTitle"]="萨满祭司 — 职业装饰"
K.locales.zhCN["shamanArtHelp"]="默认使用先祖图腾，也可在上方选择四大元素。正值将相应一侧向外移动，负值向内移动。两侧立柱和中央徽记保持原始比例，仅拉伸底部连接段。顶部饰条可以独立调整。"
K.locales.zhCN["art_shamanBackingEnabled"]="显示深色背景"
K.locales.zhCN["art_shamanBackingAlpha"]="背景不透明度"
K.locales.zhCN["art_shamanRailEnabled"]="显示顶部饰条"
K.locales.zhCN["art_shamanRailX"]="顶部饰条水平偏移"
K.locales.zhCN["art_shamanRailY"]="顶部饰条垂直偏移"
K.locales.zhCN["art_shamanRailWidth"]="顶部饰条宽度 (%)"
K.locales.zhCN["art_shamanRailHeight"]="顶部饰条高度 (%)"

K.locales.zhCN["art_shamanLeftSpread"]="左侧扩展"

K.locales.zhCN["art_shamanRightSpread"]="右侧扩展"

K.locales.zhCN["art_mageBackingEnabled"]="显示深色背景"
K.locales.zhCN["art_mageBackingAlpha"]="背景不透明度"
K.locales.zhCN["art_mageRailEnabled"]="显示顶部饰条"
K.locales.zhCN["art_mageRailX"]="顶部饰条水平偏移"
K.locales.zhCN["art_mageRailY"]="顶部饰条垂直偏移"
K.locales.zhCN["art_mageRailWidth"]="顶部饰条宽度 (%)"
K.locales.zhCN["art_mageRailHeight"]="顶部饰条高度 (%)"
K.locales.zhCN["art_mageLeftSpread"]="左侧扩展"
K.locales.zhCN["art_mageRightSpread"]="右侧扩展"
K.locales.zhCN["artSkinMageArcane"]="奥术 — 紫晶"
K.locales.zhCN["artSkinMageFire"]="火焰 — 余烬熔炉"
K.locales.zhCN["artSkinMageFrost"]="冰霜 — 晶体封印"
K.locales.zhCN["mageArtTitle"]="法师外观"
K.locales.zhCN["mageArtHelp"]="四种外观共用布局。顶部横条和左右边缘可独立调整。外观不受专精限制。"

K.locales.zhCN["artSkinMageAcademy"]="法师学院 — 三重封印"

K.locales.zhCN["art_priestBackingEnabled"]="显示深色背景"
K.locales.zhCN["art_priestBackingAlpha"]="背景不透明度"
K.locales.zhCN["art_priestRailEnabled"]="显示顶部饰条"
K.locales.zhCN["art_priestRailX"]="顶部饰条水平偏移"
K.locales.zhCN["art_priestRailY"]="顶部饰条垂直偏移"
K.locales.zhCN["art_priestRailWidth"]="顶部饰条宽度 (%)"
K.locales.zhCN["art_priestRailHeight"]="顶部饰条高度 (%)"
K.locales.zhCN["art_priestLeftSpread"]="左侧扩展"
K.locales.zhCN["art_priestRightSpread"]="右侧扩展"
K.locales.zhCN["artSkinPriestLight"]="光明圣所 — 神圣 / 戒律"
K.locales.zhCN["artSkinPriestShadow"]="蚀影礼拜堂 — 暗影"
K.locales.zhCN["priestArtTitle"]="牧师外观"
K.locales.zhCN["priestArtHelp"]="两种外观共用布局。顶部横条和左右边缘可独立调整。外观不受专精限制。"

K.locales.zhCN["art_druidBackingEnabled"]="显示深色背景"
K.locales.zhCN["art_druidBackingAlpha"]="背景不透明度"
K.locales.zhCN["art_druidRailEnabled"]="显示顶部饰条"
K.locales.zhCN["art_druidRailX"]="顶部饰条水平偏移"
K.locales.zhCN["art_druidRailY"]="顶部饰条垂直偏移"
K.locales.zhCN["art_druidRailWidth"]="顶部饰条宽度 (%)"
K.locales.zhCN["art_druidRailHeight"]="顶部饰条高度 (%)"
K.locales.zhCN["art_druidLeftSpread"]="左侧扩展"
K.locales.zhCN["art_druidRightSpread"]="右侧扩展"
K.locales.zhCN["artSkinDruidGrove"]="远古林地"
K.locales.zhCN["artSkinDruidMoon"]="月之守护"
K.locales.zhCN["artSkinDruidWild"]="野性之心"
K.locales.zhCN["artSkinDruidSeasons"]="四季之约"
K.locales.zhCN["druidArtTitle"]="德鲁伊外观"
K.locales.zhCN["druidArtHelp"]="四种外观共用布局，默认野性之心。顶部横条和左右边缘可独立调整，外观不受专精或变形形态限制。"

K.locales.zhCN["imBagHelp"]="打开暴雪合并背包时，可用的材料包和钥匙链会作为独立的原生窗口在旁边打开。对应图标可开关这些窗口，普通背包图标仅隐藏或显示自己的格子。使用 Bagnon 等背包插件时停用此布局。"

K.locales.zhCN["imBagHelp"]="打开暴雪合并背包时，材料包会作为独立窗口在旁边打开。点击材料包图标可隐藏或显示窗口，隐藏时图标变暗。关闭并重新打开背包会保留此选择。钥匙链仅在点击图标时打开。普通背包图标可隐藏或显示自己的格子。使用 Bagnon 等背包插件时停用此布局。"

K.locales.zhCN["imBagBackground"]="背包图标栏背景"
K.locales.zhCN["imBagFrame"]="背包图标栏边框"
K.locales.zhCN["imBagIconBorder"]="图标黑色边框"
K.locales.zhCN["imBagAppearanceHelp"]="可分别隐藏背包图标栏的背景和装饰边框。黑色边框仅用于图标。大小和间距设置应用于所有背包图标，包括材料包和钥匙链。"
K.locales.zhCN["mbShowTooltip"]="显示启动按钮提示"

K.locales.zhCN["bsTitle"]="背包快捷按钮"
K.locales.zhCN["bsHelp"]="点击此按钮可开关背包。默认显示并锁定，初始位置在屏幕右下方。解锁后可拖动，再重新锁定。隐藏按钮不影响键盘快捷键。标准布局使用 B 和 Shift+B，下方显示你当前的按键绑定，可在游戏设置中修改。"
K.locales.zhCN["bsEnabled"]="显示背包快捷按钮"
K.locales.zhCN["bsLocked"]="锁定位置"
K.locales.zhCN["bsSize"]="快捷按钮图标大小"
K.locales.zhCN["bsReset"]="重置位置"
K.locales.zhCN["bsAllBags"]="所有背包"
K.locales.zhCN["bsBackpack"]="行囊"
K.locales.zhCN["bsUnbound"]="未绑定"
K.locales.zhCN["bsDrag"]="拖动以移动。"

K.locales.zhCN["quests"]="任务追踪"
K.locales.zhCN["qjNativeHelp"]="保留暴雪任务追踪器的原始外观、图标和任务按钮。在任务区域滚动鼠标滚轮即可查看容纳不下的已追踪任务。旧版 Questie 皮革背景和羽毛笔设计已移除。"
K.locales.zhCN["qjScrollEnabled"]="启用鼠标滚轮滚动"
K.locales.zhCN["qjScrollStep"]="滚动步长"
K.locales.zhCN["qjHeightHelp"]="在游戏编辑模式中更改追踪器位置和高度。此功能不会自动追踪任务，只滚动暴雪已追踪的任务。进入编辑模式时暂时恢复原始布局。"
K.locales.zhCN["qjActive"]="暴雪任务追踪器滚动已启用。"
K.locales.zhCN["qjOtherTracker"]="Questie 追踪器已启用。请在 Questie 设置中禁用其追踪器以使用暴雪追踪器；可继续使用 Questie 地图图标。"
K.locales.zhCN["qjNativeWaiting"]="暴雪追踪器尚未就绪，或滚动已禁用。"
K.locales.zhCN["qjUpdate"]="为暴雪任务追踪器添加滚动功能，不包含 Questie 皮肤。"

K.locales.zhCN["qjGroupByZone"]="按区域分组"
K.locales.zhCN["qjZoneHelp"]="使用任务日志中的区域/类别标题分组。点击标题可折叠或展开，任务仍保持追踪。分组需要启用滚动。受保护任务按钮的布局在战斗结束后更新。"
K.locales.zhCN["qjNativeHelp"]="保留暴雪追踪器的外观、图标和任务按钮。可用鼠标滚轮滚动，展开或折叠区域分组。不需要 Questie。"
K.locales.zhCN["qjHeightHelp"]="在游戏编辑模式中设置位置和高度，仅显示暴雪已追踪的任务。编辑模式暂时恢复原始布局。存在受保护按钮时，列表更新可能等待战斗结束。"

K.locales.zhCN["backingColorTitle"]="背景颜色"
K.locales.zhCN["backingColorHelp"]="更改按钮后方的填充颜色，保留装饰和按钮边框。"
K.locales.zhCN["backingOriginal"]="原始外观"
K.locales.zhCN["backingCustom"]="自定义颜色"
K.locales.zhCN["backingPickColor"]="选择颜色"
K.locales.zhCN["backingCream"]="奶油色"
K.locales.zhCN["backingBrown"]="棕色"
K.locales.zhCN["backingGrey"]="深灰色"
K.locales.zhCN["backingBlack"]="黑色"
K.locales.zhCN["backingOpacityHelp"]="使用下方背景不透明度设置调整透明度。"

K.locales.zhCN["imBTBags"]="Bartender 背包栏已启用，我们的背包图标栏暂停。只需关闭 Bartender 的 Bag Bar 模块，无须关闭动作条。"
K.locales.zhCN["imBTMicro"]="Bartender 微型菜单已启用，仅暂停我们的微型菜单布局，不影响背包图标栏。关闭 Bartender 的 Micro Menu 模块后若按钮未恢复，请 /reload。"
K.locales.zhCN["imBTBoth"]="Bartender 背包栏与微型菜单已启用。只需关闭对应模块即可使用我们的布局，动作条可保持启用。若微型菜单按钮未恢复，请 /reload。"

K.locales.zhCN["readyHunterTitle"]="猎人完整布局 · 1920×1080"
K.locales.zhCN["readyHunterHelp"]="同时应用猎人外观、暴雪布局和 KerimAnka UI 设置。重载前备份当前设置，保留原有按键绑定。"
K.locales.zhCN["readyUsesBT"]="自动选择来源：创建 Bartender 配置，同时启用暴雪动作条 2 和 3 作为备用。"
K.locales.zhCN["readyUsesNative"]="使用暴雪动作条，并启用动作条 2 和 3。"
K.locales.zhCN["readyApplyHunter"]="应用猎人完整布局"
K.locales.zhCN["readyMissing"]="此职业尚无预设布局。"
K.locales.zhCN["readyUnavailable"]="目前无法访问所需的游戏设置。"
K.locales.zhCN["readyBTUnavailable"]="此 Bartender 版本或配置系统与预设不兼容。"
K.locales.zhCN["readyApplyFailed"]="未能完整应用布局。可在配置页面恢复备份。"

-- First-open account introduction.
K.locales.zhCN["introReplay"]="重新显示入门介绍"
K.locales.zhCN["introWelcome"]="欢迎使用 KerimAnka UI"
K.locales.zhCN["introWelcomeBody"]="从配置页面开始安装职业预设。点击下方的显示配置，或点击高亮的配置按钮。可以跳过此介绍；每个角色仅自动显示一次。"
K.locales.zhCN["introProfilesTitle"]="配置 · 从这里开始"
K.locales.zhCN["introReadyBody"]="高亮的职业预设会安装 1920×1080 布局和外观，备份当前设置，保留按键绑定并重载界面。关闭此说明，准备好后点击应用。"
K.locales.zhCN["introNoPresetBody"]="此职业暂时没有预设。你可以在此保存当前设置，或从其他角色复制兼容的配置。后续职业预设将在此显示。"
K.locales.zhCN["introSkip"]="跳过"
K.locales.zhCN["introGoProfiles"]="显示配置"
K.locales.zhCN["introDone"]="知道了"

K.locales.zhCN["petBarBTDisabled"]="使用 Bartender 时，请启用其宠物动作条模块；我们的背景会跟随该动作条。若要使用暴雪宠物动作条，请停用 Bartender 并重载界面。"

K.locales.zhCN["hunterRange_ranged"]="远程范围内"
K.locales.zhCN["hunterRange_dead"]="死区"
K.locales.zhCN["hunterRange_melee"]="近战范围"
K.locales.zhCN["hunterRange_far"]="太远"
K.locales.zhCN["hunterRange_close"]="太近"
K.locales.zhCN["hunterRange_unknown"]="距离未知"
K.locales.zhCN["hunterAspect_cheetahText"]="猎豹守护生效：请切换守护！"
K.locales.zhCN["hunterAspect_missingText"]="请选择一个守护！"
K.locales.zhCN["hunterTextTitle"]="自定义提示文字"
K.locales.zhCN["hunterTextHelp"]="默认文字随界面语言切换。自定义文字保持不变。清空或重置文本框可恢复自动语言。"
K.locales.zhCN["hunterTextReset"]="恢复默认"

K.locales.zhCN["hunterHintPreview"]="预览"
K.locales.zhCN["hunterHintMove"]="拖动以移动 • 在设置中锁定"
K.locales.zhCN["hunterHintRangeMove"]="拖动以移动 • 右键：设置"
K.locales.zhCN["hunterRangeReady"]="猎人距离提示已就绪。设置：KerimAnka UI。"
K.locales.zhCN["hunterAspectReady"]="守护提醒已就绪。设置：KerimAnka UI。"
K.locales.zhCN["hunterAspectUnknown"]="守护信息不可用或受限制。为避免错误提醒，已隐藏提示。"

K.locales.zhCN["soundInfo"]="声音设置按角色保存，包括在游戏选项中的更改。新角色使用客户端默认值。"
K.locales.zhCN["soundMaster"]="静音所有声音"
K.locales.zhCN["soundShortcutTitle"]="声音快捷菜单"
K.locales.zhCN["soundShortcutShow"]="显示声音快捷按钮"
K.locales.zhCN["soundShortcutLock"]="锁定声音快捷按钮位置"
K.locales.zhCN["soundShortcutReset"]="重置声音快捷按钮位置"
K.locales.zhCN["soundShortcutTip"]="点击：音乐、环境及所有声音。"
K.locales.zhCN["soundShortcutDrag"]="点击：声音菜单。拖动：移动按钮。"
K.locales.zhCN["soundShortcut_music"]="音乐"
K.locales.zhCN["soundShortcut_ambience"]="环境"
K.locales.zhCN["soundShortcut_all"]="所有声音"
K.locales.zhCN["soundShortcutOn"]="开启"
K.locales.zhCN["soundShortcutOff"]="关闭"
K.locales.zhCN["soundMasterHelp"]=K.locales.zhCN["soundInfo"]
K.locales.zhCN["soundShortcutShowHelp"]=K.locales.zhCN["soundInfo"]
K.locales.zhCN["soundShortcutLockHelp"]=K.locales.zhCN["soundInfo"]
K.locales.zhCN["soundShortcutResetHelp"]=K.locales.zhCN["soundInfo"]

K.locales.zhCN["imCombinedBags"]="使用合并背包"
K.locales.zhCN["imCombinedBagsHelp"]="按角色保存。新角色默认使用合并背包。在游戏设置或背包菜单中的选择也会保存。勾选状态与实际背包布局同步恢复。Bagnon 等背包插件保留控制权。"

K.locales.zhCN["qjSafetyPaused"]="任务追踪增强功能暂时停用"
K.locales.zhCN["qjSafetyHelp"]="暴雪原生任务追踪仍可使用。区域分组与滚轮滚动因污染编辑模式和受限光环更新而暂停。已保存的偏好设置保留。"
K.locales.zhCN["readyMeterStageRequired"]="统计窗口必须在重载前完成准备。请重新应用职业预设布局。"
K.locales.zhCN["readyMeterPrepareFailed"]="统计窗口准备失败。请取消待应用的配置并重载界面后重试。"

K.locales.zhCN["qjNativeHelp"]="按区域分组暴雪已追踪任务并支持鼠标滚轮。独立任务视图不会替换暴雪共享布局模块。点击任务可在地图中打开，旁边的图标可使用任务物品。"
K.locales.zhCN["qjHeightHelp"]="在游戏编辑模式中设置位置和高度；编辑时恢复原始视图。由于任务物品按钮受保护，列表更新和滚动将在战斗结束后进行。"

K.locales.zhCN["fpsTitle"]="帧率显示"
K.locales.zhCN["fpsShow"]="显示帧率"
K.locales.zhCN["fpsLock"]="锁定帧率位置"
K.locales.zhCN["fpsReset"]="重置帧率位置"
K.locales.zhCN["fpsShowHelp"]="显示游戏帧率，按角色保存，不依赖 MoveAny。"
K.locales.zhCN["fpsLockHelp"]="关闭后可用鼠标左键拖动；锁定后不阻挡鼠标点击。"
K.locales.zhCN["fpsHomeHelp"]="默认显示在右侧经验条和伤害统计区域上方。解锁后拖动，再重新锁定。如使用 MoveAny，请关闭其帧率选项。游戏自带的 Ctrl+R 计数器独立运行。"

K.locales.zhCN["readyRogueTitle"]="潜行者完整布局 · 1920×1080"

K.locales.zhCN["readyRogueHelp"]="同时应用潜行者外观、暴雪布局和 KerimAnka UI 设置。重载前备份当前设置，保留原有按键绑定。"

K.locales.zhCN["readyApplyRogue"]="应用潜行者完整布局"

K.locales.zhCN["readyBTDeferredFailed"]="Bartender 自动配置失败，已保留原有配置。可在配置页重新应用职业完整布局以重试。"

K.locales.zhCN["ftPreviewHint"]="预览 - 拖动 / 右键：设置"
K.locales.zhCN["ftDragHint"]="拖动 / 右键：设置"

K.locales.zhCN["art_paladinBackingEnabled"]="显示深色背景"
K.locales.zhCN["art_paladinBackingAlpha"]="背景不透明度"
K.locales.zhCN["art_paladinRailEnabled"]="显示顶部饰条"
K.locales.zhCN["art_paladinRailX"]="顶部饰条水平偏移"
K.locales.zhCN["art_paladinRailY"]="顶部饰条垂直偏移"
K.locales.zhCN["art_paladinRailWidth"]="顶部饰条宽度 (%)"
K.locales.zhCN["art_paladinRailHeight"]="顶部饰条高度 (%)"
K.locales.zhCN["art_paladinLeftSpread"]="左侧扩展"
K.locales.zhCN["art_paladinRightSpread"]="右侧扩展"
K.locales.zhCN["artSkinPaladinAlliance"]="联盟 · 白银之手"
K.locales.zhCN["artSkinPaladinHorde"]="部落 · 血骑士"
K.locales.zhCN["paladinArtTitle"]="圣骑士外观"
K.locales.zhCN["paladinArtHelp"]="初始外观随阵营选择，两种均可手动使用；动作条、小地图和单位框体一起切换。顶部横条与背景可分别调整。"

K.locales.zhCN["art_paladinBottomHeight"]="底部横条厚度"

K.locales.zhCN["art_paladinRailHeight"]="顶部横条厚度"
K.locales.zhCN["paladinArtHelp"]="完整边框位于所选按钮外侧。宽度、高度和位置统一调整整个边框，连接处保持连续。上下横条厚度可分别调整，两种阵营外观均可选择。"

K.locales.zhCN["readyPaladinTitle"]="圣骑士完整布局 · 1920×1080"

K.locales.zhCN["readyPaladinHelp"]="同时应用圣骑士外观、暴雪布局和 KerimAnka UI 设置。重载前备份当前设置，保留原有按键绑定。"

K.locales.zhCN["readyApplyPaladin"]="应用圣骑士完整布局"

K.locales.zhCN["qjQuestieTracker"]="使用 Questie 任务追踪器"

K.locales.zhCN["qjQuestieHelp"]="默认关闭，避免显示重复的追踪器。地图和小地图标记仍然可用。更改在重载界面后生效。"

K.locales.zhCN["qjQuestieReload"]="请重载界面以应用 Questie 追踪器选择。"

K.locales.zhCN["introWelcomeBody"]="从这里开始：打开配置文件，为当前职业应用预设布局。\n\n职业装饰和额外显示默认关闭，直到你选择布局或手动启用。本引导每个角色只显示一次。"

K.locales.zhCN["introReadyBody"]="点击下方按钮应用职业预设，同时安装1920×1080布局、装饰和保存的设置。\n\n当前设置会备份，按键绑定保持不变。所有位置初始锁定。应用后会重载界面。"

K.locales.zhCN["introNoPresetBody"]="此职业暂时没有预设布局。\n\n你可以手动启用并排列需要的模块，或导入兼容的配置。位置默认锁定，仅在移动时解锁。"

K.locales.zhCN["introSkip"]="手动设置"

K.locales.zhCN["ufMoveHelp"]="移动实际单位框体：关闭位置锁定，在非战斗状态下按住ALT并用鼠标左键拖动。完成后重新锁定。仅解锁并不能直接拖动。"

K.locales.zhCN["introPreparedTitle"]="准备完成安装"

K.locales.zhCN["introPreparedBody"]="布局已准备好，当前设置已备份。\n\n点击下方的重载并完成来完成设置。单独点击可将重载请求直接发送给游戏。取消会还原已准备的更改。"

K.locales.zhCN["introReload"]="重载并完成"

K.locales.zhCN["introReadyBody"]="点击下方按钮准备职业预设，包括1920×1080布局、装饰和保存的设置。\n\n当前设置会备份，按键绑定保持不变。所有位置初始锁定。下一步重载界面以完成安装。"

K.locales.zhCN["introCancel"]="取消设置"

K.locales.zhCN["artSkinWarriorAlliance"]="联盟 · 钢铁先锋"
K.locales.zhCN["artSkinWarriorHorde"]="部落 · 钢铁先锋"
K.locales.zhCN["artSkinWarriorIron"]="黑铁 · 仅动作条"
K.locales.zhCN["artSkinWarriorArena"]="竞技场 · 仅动作条"
K.locales.zhCN["art_backingRailEnabled"]="显示顶部饰条"
K.locales.zhCN["artSkinWarriorHelp"]="联盟和部落选项同时切换动作条、小地图、单位框架和伤害统计外观。黑铁和竞技场仅更改动作条，并保留上次选择的阵营配色。首次使用角色所属阵营。"

K.locales.zhCN["plLegacy"]="旧记录：仅包含 KerimAnka UI。请登录来源角色并退出一次，以保存暴雪和 Bartender 布局。"
K.locales.zhCN["plBoth"]="应用 KerimAnka UI、上次保存的暴雪布局和 Bartender 配置。"
K.locales.zhCN["plEdit"]="应用 KerimAnka UI 和上次保存的暴雪布局。"
K.locales.zhCN["plBT"]="应用 KerimAnka UI 和上次保存的 Bartender 配置。"
K.locales.zhCN["plInvalid"]="布局记录无效，请在来源角色重新保存。"
K.locales.zhCN["plBTIncompatible"]="保存的 Bartender 版本或模块与当前安装不兼容。"
K.locales.zhCN["plBTFailed"]="无法应用 Bartender 配置，已保留之前的配置。"
K.locales.zhCN["pfIntro"]="角色记录会在登录、打开配置页面和退出时更新。应用时复制最近保存的 KerimAnka UI、暴雪和可用的 Bartender 布局。请登录一次旧的来源角色以补全记录。命名配置保留保存时的快照。"
K.locales.zhCN["pfApplyWarning"]="将应用所选 KerimAnka UI 设置及已保存的暴雪和 Bartender 布局，并备份之前的设置。确认后请重载界面。"
K.locales.zhCN["pfTransferHelp"]="代码仅包含 KerimAnka UI 设置。暴雪和 Bartender 布局通过上方的已保存配置进行复制。"
K.locales.zhCN["pfTransfer"]="代码传输 · 仅 KerimAnka UI"

K.locales.zhCN["plNativeName"]="暴雪布局：%s"

K.locales.zhCN["readyWarriorTitle"]="战士完整布局 · 1920×1080"

K.locales.zhCN["readyWarriorHelp"]="同时应用战士外观、暴雪布局和 KerimAnka UI 设置。重载前备份当前设置，保留原有按键绑定。"

K.locales.zhCN["readyApplyWarrior"]="应用战士完整布局"

K.locales.zhCN["ufShamanTotems"]="萨满图腾"

K.locales.zhCN["uf_shamanTotems"]="显示激活的图腾"

K.locales.zhCN["uf_shamanTotemSize"]="图腾图标大小"

K.locales.zhCN["uf_shamanTotemGap"]="图腾间距"

K.locales.zhCN["uf_shamanTotemX"]="图腾：水平位置"

K.locales.zhCN["uf_shamanTotemY"]="图腾：垂直位置"

K.locales.zhCN["ufShamanTotemsHelp"]="将暴雪的激活图腾显示移到玩家框体下方。图标、剩余时间和图腾交互由游戏管理，不为玩家提供增益的图腾也会显示。预览提供四个示例。位置相对于玩家框体左下角。"

K.locales.zhCN["readyShamanTitle"]="萨满完整布局 · 1920×1080"

K.locales.zhCN["readyShamanHelp"]="同时应用萨满外观、暴雪布局和 KerimAnka UI 设置。重载前备份当前设置，保留原有按键绑定。"

K.locales.zhCN["readyApplyShaman"]="应用萨满完整布局"

K.locales.zhCN["readyWarlockTitle"]="术士完整布局 · 1920×1080"

K.locales.zhCN["readyWarlockHelp"]="同时应用术士外观、暴雪布局和 KerimAnka UI 设置。重载前备份当前设置，保留原有按键绑定。"

K.locales.zhCN["readyApplyWarlock"]="应用术士完整布局"

K.locales.zhCN["readyMageTitle"]="法师完整布局 · 1920×1080"

K.locales.zhCN["readyMageHelp"]="同时应用法师外观、暴雪布局和 KerimAnka UI 设置。重载前备份当前设置，保留原有按键绑定。"

K.locales.zhCN["readyApplyMage"]="应用法师完整布局"

K.locales.zhCN["readyPriestTitle"]="牧师完整布局 · 1920×1080"

K.locales.zhCN["readyPriestHelp"]="同时应用牧师外观、暴雪布局和 KerimAnka UI 设置。重载前备份当前设置，保留原有按键绑定。"

K.locales.zhCN["readyApplyPriest"]="应用牧师完整布局"

K.locales.zhCN["readyDruidTitle"]="德鲁伊完整布局 · 1920×1080"

K.locales.zhCN["readyDruidHelp"]="同时应用德鲁伊外观、暴雪布局和 KerimAnka UI 设置。重载前备份当前设置，保留原有按键绑定。"

K.locales.zhCN["readyApplyDruid"]="应用德鲁伊完整布局"

K.locales.zhCN["readyConfirmWarning"]="当前设置将先备份，再替换为预设布局，随后重新加载界面。请确认后继续。"

K.locales.zhCN["readyConfirmApply"]="确认并应用"

K.locales.zhCN["readyConfirmCancel"]="取消"

K.locales.zhCN["pfSelectedHint"]="点击应用此记录。继续前需要确认。"

K.locales.zhCN["pfPendingActions"]="设置已准备好。重新加载界面以应用，或取消待处理的更改。"

K.locales.zhCN["addonChangeFailed"]="插件更改失败："

K.locales.zhCN["addonChanging"]="正在检查插件更改。"

K.locales.zhCN["addonControlHelp"]="更改此角色实际启用的插件列表。更改后请重新加载界面。外观开关独立控制已加载插件的显示效果。"

K.locales.zhCN["addonStateUnknown"]="无法读取插件状态"

K.locales.zhCN["ambienceHelp"]="关闭风声、水声等环境背景音效。"

K.locales.zhCN["backgroundHelp"]="游戏窗口未激活时停止播放游戏声音。"

K.locales.zhCN["badgeDisable"]="点击为此角色禁用此插件。"

K.locales.zhCN["badgeEnable"]="点击为此角色启用此插件。"

K.locales.zhCN["badgeHelp"]="绿色：插件已加载，但其显示功能可能已关闭。灰暗：已禁用或未加载。黄色：插件加载更改需要重新加载界面。"

K.locales.zhCN["clicksHelp"]="静音宏中使用的六个音频文件：569772–569776 和 567407。语音错误提示由其他选项控制。"

K.locales.zhCN["customHelp"]="输入数字音频文件 ID，以逗号或空格分隔。这些是文件 ID，不是音效组 ID。游戏不会验证文件是否能发声。"

K.locales.zhCN["dialogHelp"]="关闭游戏对话音频频道。语音错误提示由其他选项控制。"

K.locales.zhCN["disableDeathEffectHelp"]="关闭死亡或灵魂状态的全屏灰色效果，保留世界原有颜色。开启此选项会禁用该效果，关闭则恢复。使用游戏设置，不添加轮询检查，并随界面配置保存。若客户端不提供此设置，则该选项不可用。"

K.locales.zhCN["disabled"]="已禁用"

K.locales.zhCN["effectsHelp"]="关闭整个音效频道，包括战斗音效和许多界面声音。如需静音某个声音，请使用下方的文件 ID。"

K.locales.zhCN["empty"]="尚未添加自定义音频文件。"

K.locales.zhCN["enable"]="为此角色启用"

K.locales.zhCN["enableHelp"]="更改此角色的插件列表。需要重新加载界面；已经加载的插件会继续运行，直到重新加载。不会自动启用或禁用依赖插件。"

K.locales.zhCN["errorCustomHelp"]="开启会隐藏该类错误，关闭会显示。重要或未识别的错误仍然可见。此模式仅过滤已知错误；如需隐藏其他所有类型，请选择仅保留重要提示模式。"

K.locales.zhCN["errorImportantHelp"]="隐藏所有红色错误，但保留背包或银行已满、任务日志已满、金币不足以及物品数量上限提示。关闭保留重要提示后也会隐藏这些错误。任务进度消息不受影响。"

K.locales.zhCN["errorShowHelp"]="使用暴雪默认错误显示，不进行额外文本过滤。"

K.locales.zhCN["error_cooldown"]="隐藏冷却错误"

K.locales.zhCN["error_direction"]="隐藏朝向／视线错误"

K.locales.zhCN["error_movement"]="隐藏移动错误"

K.locales.zhCN["error_range"]="隐藏距离错误"

K.locales.zhCN["error_resources"]="隐藏资源错误"

K.locales.zhCN["error_target"]="隐藏目标错误"

K.locales.zhCN["errorsHelp"]="关闭以显示所有默认红色错误。开启后使用主页“提示”中选择的过滤模式。默认仅保留其中列出的重要提示。声音设置独立控制。"

K.locales.zhCN["experience"]="经验与声望"

K.locales.zhCN["hunterOnlyHelp"]="此模块仅供猎人使用。其他职业会自动在插件列表中禁用它。手动禁用的猎人模块不会被重新启用。若模块已加载，请重新加载界面以停止运行。"

K.locales.zhCN["invalidIds"]="仅可输入正整数文件 ID，最多 30 个自定义条目。"

K.locales.zhCN["keepImportantErrorsHelp"]="在仅保留重要提示模式下，保留背包或银行已满、任务日志已满、金币不足及物品数量上限错误。关闭后隐藏所有红色错误。"

K.locales.zhCN["loaded"]="已加载"

K.locales.zhCN["missing"]="未安装"

K.locales.zhCN["musicHelp"]="关闭全部游戏音乐，包括区域和战斗音乐。"

K.locales.zhCN["note"]="初始版本 · 保留现有模块设置。"

K.locales.zhCN["pending"]="需要重新加载"

K.locales.zhCN["petsHelp"]="若客户端支持该设置，则关闭宠物声音。"

K.locales.zhCN["reloadPromptBody"]="重新加载界面以应用插件更改。也可以稍后使用底部按钮重新加载。"

K.locales.zhCN["reloadWaiting"]="插件更改待生效 · 请使用右侧按钮重新加载。"

K.locales.zhCN["soundNote"]="其他声音插件可能控制相同文件。请避免在多个插件中重复静音同一 ID。"

K.locales.zhCN["speechHelp"]="静音法力不足等语音错误提示。其他对话音频由独立选项控制。"

K.locales.zhCN["state"]="模块状态"

K.locales.zhCN["zoomNote"]="此设置定义距离上限。设置后请使用鼠标滚轮拉远镜头。"

-- Bar Backdrop: settings, sources, range tint and help texts.
K.locales.zhCN["abBar"]="动作条"
K.locales.zhCN["abBars"]="包含的 Bartender 动作条"
K.locales.zhCN["abBorder"]="外边框厚度"
K.locales.zhCN["abHelp"]="更改在脱离战斗后应用。至少保留一条选中的动作条。亮度为 0 时显示黑色，为 1 时保留原色。外边框大小设为 0 可隐藏外边框。"
K.locales.zhCN["abIntro"]="设置按角色保存。请根据所选来源，在游戏设置或 Bartender 中调整动作条和按键绑定。"
K.locales.zhCN["abMin"]="至少保留一条选中的动作条。"
K.locales.zhCN["abShade"]="按钮边框亮度"
K.locales.zhCN["abShow"]="显示按钮背景"
K.locales.zhCN["abSlot"]="空栏位不透明度"
K.locales.zhCN["abUpdate"]="请安装附带的 Bar Backdrop 模块更新以使用这些设置。"
K.locales.zhCN["arColor"]="超出距离颜色"
K.locales.zhCN["arEnabled"]="为超出距离的技能着色"
K.locales.zhCN["arHelp"]="技能超出距离时为整个图标着色，与按键文字显示独立。进入有效距离后恢复游戏原色。支持暴雪和 Bartender 动作条；宠物动作条独立处理。"
K.locales.zhCN["arReset"]="恢复默认红色"
K.locales.zhCN["barsAuto"]="自动"
K.locales.zhCN["barsBT"]="Bartender"
K.locales.zhCN["barsBTActive"]="正在使用 Bartender 动作条。保留现有的 Bartender 装饰布局。"
K.locales.zhCN["barsConflict"]="Bartender 仍在管理或隐藏暴雪动作条。请在游戏插件列表中禁用 Bartender 并重新加载界面，再使用暴雪动作条。"
K.locales.zhCN["barsEditor"]="打开暴雪编辑模式"
K.locales.zhCN["barsLocked"]="固定模式下暂停跟随动作条。请先选择上方的重新适配动作条，再更改此选择。"
K.locales.zhCN["barsMissingBT"]="已选择 Bartender，但其动作条未启用。请启用并重新加载界面，或选择自动／暴雪。"
K.locales.zhCN["barsNative"]="暴雪"
K.locales.zhCN["barsNativeActive"]="正在使用暴雪动作条。请在游戏设置中启用动作条 2 和 3，并在编辑模式中将三条水平动作条上下排列。装饰跟随选中且可见的动作条。"
K.locales.zhCN["barsNativeList"]="包含的暴雪动作条"
K.locales.zhCN["barsNoEditor"]="暴雪编辑模式目前不可用。请在脱离战斗后通过游戏菜单打开。"
K.locales.zhCN["barsSource"]="动作条来源"
K.locales.zhCN["barsSourceHelp"]="自动模式在 Bartender 管理动作条时使用 Bartender，否则使用暴雪。每个来源分别保存尺寸、位置和选中的动作条。此选择不会启用或禁用插件。如需从 Bartender 切回暴雪，请在插件列表中禁用 Bartender 并重新加载界面。不会复制或更改动作栏位及按键绑定。"
K.locales.zhCN["dependency"]="若此模块无法加载，请在游戏插件列表中检查所需的依赖插件。"
K.locales.zhCN["hideNativeHotkeys"]="隐藏按键绑定文字"
K.locales.zhCN["hideNativeHotkeysHelp"]="隐藏此角色全部八条暴雪动作条的按键标签，不更改按键绑定或距离指示。Bartender 独立管理自己的标签。"
K.locales.zhCN["hideNativeMacroNames"]="隐藏宏名称"
K.locales.zhCN["hideNativeMacroNamesHelp"]="隐藏暴雪动作按钮图标下方的宏名称，不更改宏、物品数量或冷却数字。"
K.locales.zhCN["inactiveHelp"]="此插件未加载。请为此角色启用插件并重新加载界面后使用其设置，同时检查所需的依赖插件。"

-- Class Art: gallery, layout, backing, rails, pet bar and help.
K.locales.zhCN["abArtHelp"]="调整当前职业装饰。宽度和高度使用百分比。X 为正数时向右移动，Y 为正数时向上移动。跟随模式会跟随所选动作条；切回跟随模式会将宽度和高度重置为 100%。"
K.locales.zhCN["abLock"]="保持当前尺寸和位置"
K.locales.zhCN["abMode"]="当前模式："
K.locales.zhCN["abUnsupported"]="此角色没有可用的职业装饰。"
K.locales.zhCN["artSkinHelp"]="预览并切换此角色的动作条装饰。更改在脱离战斗后生效。小地图和单位框体保留各自的装饰。所选样式会包含在保存的配置方案中。"
K.locales.zhCN["art_artConfirm"]="再次点击以确认重置"
K.locales.zhCN["art_artExtraHelp"]="更改仅保存到此角色。这些选项调整装饰，不改变动作按钮的布局。不可用的设置会显示为灰色。"
K.locales.zhCN["art_artReset"]="恢复装饰默认设置"
K.locales.zhCN["art_backing"]="动作条底板和顶部装饰条"
K.locales.zhCN["art_enabled"]="启用"
K.locales.zhCN["art_opacity"]="底板不透明度"
K.locales.zhCN["art_padding"]="框体边距"
K.locales.zhCN["art_rail"]="顶部装饰条高度"
K.locales.zhCN["art_railY"]="顶部装饰条偏移"
K.locales.zhCN["hideActionBarStatues"]="隐藏暴雪动作条雕像"
K.locales.zhCN["hideActionBarStatuesHelp"]="隐藏动作条两端的狮鹫或双足飞龙雕像。不使用 Bartender 时也适用于暴雪动作条，并会隐藏 Bartender 的同类雕像。不隐藏动作按钮、经验条或小地图边框。关闭后本插件会停止隐藏雕像，但其他插件仍可能将其隐藏。更改在脱离战斗后生效，并保存到此角色。"

-- Unit Frames: options, auras, summon rows, preview and help.
K.locales.zhCN["ufHelp"]="调整单位框体的所选设置。X 控制水平位置，Y 控制垂直位置。更改已依附的宠物或目标的目标框体的 X/Y 会解除其位置依附。请在脱离战斗后调整。"
K.locales.zhCN["ufNote"]="新增的光环和施法显示默认关闭，已有设置会保留。光环创建后，更改原生光环的布局、数量或冷却转圈效果可能需要重新加载界面。"
K.locales.zhCN["ufUpdate"]="请安装随附的单位框体模块更新以使用这些设置。"
K.locales.zhCN["uf_auraCooldown"]="光环冷却转圈效果"
K.locales.zhCN["uf_auraStacks"]="光环层数"
K.locales.zhCN["uf_castFontSize"]="法术名称字体大小"
K.locales.zhCN["uf_castHeight"]="施法条和图标高度"
K.locales.zhCN["uf_castIcon"]="显示法术图标"
K.locales.zhCN["uf_castWidth"]="施法条宽度"
K.locales.zhCN["uf_castX"]="施法条 X"
K.locales.zhCN["uf_castY"]="施法条 Y"
K.locales.zhCN["uf_classificationTextScale"]="精英和稀有文字缩放"
K.locales.zhCN["uf_combatIconSize"]="战斗图标大小"
K.locales.zhCN["uf_happinessOffsetX"]="快乐值图标 X"
K.locales.zhCN["uf_happinessOffsetY"]="快乐值图标 Y"
K.locales.zhCN["uf_happinessSize"]="快乐值图标大小"
K.locales.zhCN["uf_hideNative"]="隐藏暴雪框体"
K.locales.zhCN["uf_leaderSize"]="队长和助理图标大小"
K.locales.zhCN["uf_levelOffsetY"]="等级垂直偏移"
K.locales.zhCN["uf_pet.x"]="宠物 X"
K.locales.zhCN["uf_pet.y"]="宠物 Y"
K.locales.zhCN["uf_petAuraBelow"]="宠物: 光环置于框体下方"
K.locales.zhCN["uf_petAuraColumns"]="宠物: 每行图标数"
K.locales.zhCN["uf_petAuraGap"]="宠物: 图标间距"
K.locales.zhCN["uf_petAuraMax"]="宠物: 每类图标上限"
K.locales.zhCN["uf_petAuraSingleRow"]="宠物: 单行光环"
K.locales.zhCN["uf_petAuraSize"]="宠物: 图标大小"
K.locales.zhCN["uf_petBuffX"]="宠物: 增益 X"
K.locales.zhCN["uf_petBuffY"]="宠物: 增益 Y"
K.locales.zhCN["uf_petBuffs"]="宠物: 增益"
K.locales.zhCN["uf_petDebuffX"]="宠物: 减益 X"
K.locales.zhCN["uf_petDebuffY"]="宠物: 减益 Y"
K.locales.zhCN["uf_petDebuffs"]="宠物: 减益"
K.locales.zhCN["uf_petScale"]="宠物框体缩放"
K.locales.zhCN["uf_player.x"]="玩家 X"
K.locales.zhCN["uf_player.y"]="玩家 Y"
K.locales.zhCN["uf_playerAuraBelow"]="玩家: 光环置于框体下方"
K.locales.zhCN["uf_playerAuraColumns"]="玩家: 每行图标数"
K.locales.zhCN["uf_playerAuraGap"]="玩家: 图标间距"
K.locales.zhCN["uf_playerAuraMax"]="玩家: 每类图标上限"
K.locales.zhCN["uf_playerAuraSingleRow"]="玩家: 单行光环"
K.locales.zhCN["uf_playerAuraSize"]="玩家: 图标大小"
K.locales.zhCN["uf_playerBuffX"]="玩家: 增益 X"
K.locales.zhCN["uf_playerBuffY"]="玩家: 增益 Y"
K.locales.zhCN["uf_playerBuffs"]="玩家: 增益"
K.locales.zhCN["uf_playerDebuffX"]="玩家: 减益 X"
K.locales.zhCN["uf_playerDebuffY"]="玩家: 减益 Y"
K.locales.zhCN["uf_playerDebuffs"]="玩家: 减益"
K.locales.zhCN["uf_pvpOffsetX"]="PvP 水平偏移"
K.locales.zhCN["uf_pvpOffsetY"]="PvP 垂直偏移"
K.locales.zhCN["uf_raidMarkerOffsetX"]="团队标记 X"
K.locales.zhCN["uf_raidMarkerOffsetY"]="团队标记 Y"
K.locales.zhCN["uf_raidMarkerSize"]="团队标记大小"
K.locales.zhCN["uf_showCombo"]="额外盗贼连击点"
K.locales.zhCN["uf_showPet"]="显示宠物框体"
K.locales.zhCN["uf_showPetHappiness"]="显示宠物快乐值"
K.locales.zhCN["uf_showToT"]="显示目标的目标"
K.locales.zhCN["uf_target.x"]="目标 X"
K.locales.zhCN["uf_target.y"]="目标 Y"
K.locales.zhCN["uf_targetAuraBelow"]="目标: 光环置于框体下方"
K.locales.zhCN["uf_targetAuraColumns"]="目标: 每行图标数"
K.locales.zhCN["uf_targetAuraGap"]="目标: 图标间距"
K.locales.zhCN["uf_targetAuraMax"]="目标: 每类图标上限"
K.locales.zhCN["uf_targetAuraSingleRow"]="目标: 单行光环"
K.locales.zhCN["uf_targetAuraSize"]="目标: 图标大小"
K.locales.zhCN["uf_targetBuffX"]="目标: 增益 X"
K.locales.zhCN["uf_targetBuffY"]="目标: 增益 Y"
K.locales.zhCN["uf_targetBuffs"]="目标: 增益"
K.locales.zhCN["uf_targetDebuffX"]="目标: 减益 X"
K.locales.zhCN["uf_targetDebuffY"]="目标: 减益 Y"
K.locales.zhCN["uf_targetDebuffs"]="目标: 减益"
K.locales.zhCN["uf_targettarget.x"]="目标的目标 X"
K.locales.zhCN["uf_targettarget.y"]="目标的目标 Y"
K.locales.zhCN["uf_totScale"]="目标的目标缩放"
K.locales.zhCN["upElite"]="精英"

-- Minimap: artwork, coordinates, fonts, icon drawer and help.
K.locales.zhCN["art_hideBorder"]="隐藏暴雪小地图边框"
K.locales.zhCN["art_hideBorderHelp"]="仅隐藏小地图的原生边框。不隐藏动作条的狮鹫雕像或 Bartender 装饰。关闭此选项后，其他插件仍可能继续隐藏小地图边框。"
K.locales.zhCN["art_hunterMatte"]="猎人哑光装饰"
K.locales.zhCN["art_minimap"]="小地图装饰"
K.locales.zhCN["art_reset"]="恢复小地图默认设置"
K.locales.zhCN["art_size"]="框体大小（%）"
K.locales.zhCN["art_x"]="水平偏移"
K.locales.zhCN["art_y"]="垂直偏移"
K.locales.zhCN["xpFontBold"]="Ubuntu 粗体"
K.locales.zhCN["xpFontGame"]="游戏字体"
K.locales.zhCN["xpFontRegular"]="Ubuntu 常规"

-- Bags and Menu: shortcut, bag shelf, micro menu, compatibility and help.
K.locales.zhCN["imBagToggleHelp"]="显示或隐藏背包图标行"
K.locales.zhCN["imBags"]="暴雪背包"
K.locales.zhCN["imBartender"]="Bartender 已启用。原生背包和微型菜单的自定义功能会等待 Bartender 停用后再生效。"
K.locales.zhCN["imHelp"]="使用暴雪背包和菜单按钮。设置仅作用于此角色。背包图标行与整个窗口同宽，其显示按钮位于标题关闭按钮旁。点击背包图标只会隐藏或恢复该背包的格子，其他背包保持可见。"
K.locales.zhCN["imHideNativeBarHelp"]="隐藏独立的暴雪背包栏，加载 Bagnon 时也有效。背包窗口和键盘快捷键仍可使用。Bartender 继续控制自己的栏位。关闭此选项可恢复显示。"
K.locales.zhCN["imManage"]="自定义微型菜单"
K.locales.zhCN["imMicroHelp"]="保留暴雪菜单按钮及其功能，调整大小、间距和位置。关闭后恢复原始布局。游戏的编辑模式会暂时优先控制布局。"
K.locales.zhCN["imMove"]="微型菜单 — 拖动以移动"
K.locales.zhCN["imMoveHelp"]="解除位置锁定后，菜单上方会显示拖动区域。在脱离战斗时拖动，完成后重新锁定。“放在聊天框下方”会对齐主聊天框，不会移动聊天框。如果聊天框贴着屏幕底部，请先上移聊天框以留出空间。"
K.locales.zhCN["imOtherBags"]="已加载其他背包插件，由其控制背包图标和物品样式。仍可隐藏标准背包栏并调整微型菜单。"
K.locales.zhCN["imReset"]="重置微型菜单布局"
K.locales.zhCN["imUnavailable"]="此客户端没有提供所需的整合背包框体。若支持微型菜单，仍可使用其设置。"

-- Quest Tracker: native tracker, Questie compatibility, scrolling and help.
K.locales.zhCN["qjBorder"]="皮革边框宽度"
K.locales.zhCN["qjHelp"]="调整 Questie 追踪器的装饰，可选择显示羽毛笔。任务、折叠、字体、背景颜色和追踪器位置仍由 Questie 控制。这些开关不会停用 Questie 插件本身。"
K.locales.zhCN["qjNote"]="任务内容和追踪器行为仍由 Questie 控制。此页面调整任务日志装饰。"
K.locales.zhCN["qjOpacity"]="背景不透明度"
K.locales.zhCN["qjOriginal"]="打开原始任务日志设置"
K.locales.zhCN["qjQuill"]="显示可选羽毛笔"
K.locales.zhCN["qjShow"]="显示皮革装饰"
K.locales.zhCN["qjWaiting"]="尚未连接 Questie 追踪器。请确认 Questie 已启用，且其追踪器处于可见状态。"

-- Damage Meter: Blizzard appearance, Details skin, borders and help.
K.locales.zhCN["dmDetailsMissing"]="可选的 KerimAnka UI Details Skin 模块尚未加载。如果使用 Details，请在下方启用该模块。"
K.locales.zhCN["dmHelp"]="仅调整外观，设置保存到此角色。关闭装饰会恢复原生背景并隐藏本插件的边框，不会启用或停用游戏自带的伤害统计。更改在脱离战斗后生效。"
K.locales.zhCN["dmHidden"]="游戏自带的伤害统计已关闭。请在游戏设置中启用；其他伤害统计插件也可能将其隐藏。"
K.locales.zhCN["dmNote"]="调整暴雪现有伤害统计窗口的外观。统计数据、条目、菜单和位置仍由游戏控制，不需要安装 Details。"
K.locales.zhCN["dmReady"]="已检测到暴雪伤害统计，装饰会跟随其现有窗口。"
K.locales.zhCN["dmUnavailable"]="暴雪伤害统计窗口尚未加载，或此客户端不支持。请先启用游戏自带的伤害统计。"
K.locales.zhCN["dtAll"]="将 Forever Hunter 应用于所有窗口"
K.locales.zhCN["dtAllHelp"]="将 Forever Hunter 应用于所有已初始化且已启用的 Details 窗口，包括自动隐藏的窗口。不创建新窗口。切换样式会应用所选模板的外观设置。"
K.locales.zhCN["dtAlpha"]="装饰不透明度"
K.locales.zhCN["dtApply"]="应用所选样式"
K.locales.zhCN["dtCurrent"]="当前样式："
K.locales.zhCN["dtDone"]="样式已应用。"
K.locales.zhCN["dtEmpty"]="尚无已启用且就绪的 Details 窗口。请打开一个 Details 窗口，然后刷新此页面。"
K.locales.zhCN["dtFailed"]="应用样式失败："
K.locales.zhCN["dtFonts"]="保留字体和字号"
K.locales.zhCN["dtHelp"]="外部装饰仅显示在使用 Forever Hunter 的窗口上。保留字体会在切换样式时保留条目和标题的字体及字号；其他外观设置来自所选样式。"
K.locales.zhCN["dtNative"]="打开 Details 设置"
K.locales.zhCN["dtNote"]="在此管理 Details 外观。统计数据、报告和高级设置仍在 Details 中调整。猎人装饰可用于所有职业。"
K.locales.zhCN["dtRefresh"]="刷新"
K.locales.zhCN["dtSelection"]="使用 − / + 选择已注册的样式，然后点击应用。不会自动切换样式。"
K.locales.zhCN["dtTrim"]="显示外部装饰"
K.locales.zhCN["dtUpdate"]="请安装随附的 ForeverDetailsHunter 模块更新以使用这些设置。"
K.locales.zhCN["dtWaiting"]="样式尚未注册，请稍候再刷新。"
K.locales.zhCN["dtWindow"]="窗口"
K.locales.zhCN["dtWindows"]="Details 窗口"

-- Experience and Reputation: widget, text, colors, preview and help.
K.locales.zhCN["xpApplyColor"]="应用 HEX"
K.locales.zhCN["xpBackgroundAlpha"]="面板背景不透明度"
K.locales.zhCN["xpCenter"]="居中"
K.locales.zhCN["xpChooseColor"]="选择颜色"
K.locales.zhCN["xpClassColor"]="使用职业颜色"
K.locales.zhCN["xpColorMain"]="主经验条颜色"
K.locales.zhCN["xpColorPet"]="宠物经验颜色"
K.locales.zhCN["xpColorQuest"]="待交任务经验颜色"
K.locales.zhCN["xpColorRep"]="声望颜色"
K.locales.zhCN["xpColorRested"]="休息经验颜色"
K.locales.zhCN["xpColors"]="进度条颜色"
K.locales.zhCN["xpCompact"]="紧凑布局"
K.locales.zhCN["xpConflict"]="ExperienceForever 也已加载。两个面板可以同时显示，请分别在各自的设置中调整。"
K.locales.zhCN["xpDayShort"]="天"
K.locales.zhCN["xpEnabled"]="显示经验面板"
K.locales.zhCN["xpFrameSize"]="装饰边框粗细"
K.locales.zhCN["xpHeight"]="主经验条高度"
K.locales.zhCN["xpHelp"]="设置仅用于此角色，并包含在配置方案中。预览使用示例数据。任务经验指日志中已完成但尚未交付任务的经验奖励，并非所有已完成任务的数量。每小时经验和剩余时间按本次界面会话计算，重新加载界面后重置。游戏时间由游戏提供。隐藏原生进度条会隐藏经验和声望追踪容器；本面板关闭或无内容可显示时，原生容器会恢复。"
K.locales.zhCN["xpHideNative"]="隐藏原生经验和声望条"
K.locales.zhCN["xpHorizontal"]="细长水平布局"
K.locales.zhCN["xpHourShort"]="时"
K.locales.zhCN["xpIntro"]="紧凑的经验面板，各段文字可独立调整。请在下方启用。声望仅显示当前追踪的阵营；宠物经验仅在猎人的活动宠物可以获得经验时显示。"
K.locales.zhCN["xpInvalidHex"]="请输入六位颜色代码，例如 #55AA77。"
K.locales.zhCN["xpLabelVisible"]="显示所选文字"
K.locales.zhCN["xpLabel_levelTime"]="当前等级游戏时间"
K.locales.zhCN["xpLabel_pet"]="宠物经验"
K.locales.zhCN["xpLabel_rate"]="每小时经验"
K.locales.zhCN["xpLabel_remaining"]="剩余时间"
K.locales.zhCN["xpLabel_reputation"]="声望"
K.locales.zhCN["xpLabel_total"]="总游戏时间"
K.locales.zhCN["xpLabel_xp"]="等级和经验"
K.locales.zhCN["xpLeft"]="左对齐"
K.locales.zhCN["xpLevel"]="等级"
K.locales.zhCN["xpLevelTime"]="本级"
K.locales.zhCN["xpLocked"]="锁定面板位置"
K.locales.zhCN["xpMinuteShort"]="分"
K.locales.zhCN["xpNoMeter"]="请先打开暴雪伤害统计。"
K.locales.zhCN["xpPanelSpace"]="面板额外高度"
K.locales.zhCN["xpPickerUnavailable"]="原生颜色选择器不可用，仍可输入 HEX 颜色代码。"
K.locales.zhCN["xpPlaceMeter"]="置于暴雪统计窗口上方"
K.locales.zhCN["xpPlaceTop"]="置于屏幕顶部"
K.locales.zhCN["xpPreviewNote"]="示例数据 · 点击文字以选择 · 拖动或使用滚轮 · 位置和大小即时更新"
K.locales.zhCN["xpRate"]="经验/小时"
K.locales.zhCN["xpRemaining"]="剩余"
K.locales.zhCN["xpResetColor"]="默认颜色"
K.locales.zhCN["xpResetSession"]="重置会话统计"
K.locales.zhCN["xpResetText"]="恢复文字布局"
K.locales.zhCN["xpRight"]="右对齐"
K.locales.zhCN["xpSampleFaction"]="阵营示例"
K.locales.zhCN["xpSamplePet"]="宠物示例"
K.locales.zhCN["xpShowPet"]="显示猎人宠物经验"
K.locales.zhCN["xpShowQuest"]="显示待交任务经验"
K.locales.zhCN["xpShowRate"]="显示每小时经验和剩余时间"
K.locales.zhCN["xpShowRep"]="显示追踪声望"
K.locales.zhCN["xpShowRested"]="显示休息经验"
K.locales.zhCN["xpShowTime"]="显示游戏时间"
K.locales.zhCN["xpSubHeight"]="声望和宠物进度条高度"
K.locales.zhCN["xpTextColor"]="所选文字颜色"
K.locales.zhCN["xpTextSettings"]="独立文字设置"
K.locales.zhCN["xpTextSize"]="所选文字大小"
K.locales.zhCN["xpTextX"]="文字水平偏移"
K.locales.zhCN["xpTextY"]="文字垂直偏移"
K.locales.zhCN["xpTotal"]="总计"
K.locales.zhCN["xpTrim"]="显示装饰边框"
K.locales.zhCN["xpWidth"]="面板宽度"

-- Threat: options, fonts, fixed colors, preview and help.
K.locales.zhCN["ftBlue"]="蓝色"
K.locales.zhCN["ftCenter"]="居中并解锁"
K.locales.zhCN["ftColorHelp"]="选择固定颜色会关闭自动仇恨着色。可在上方重新启用游戏原生仇恨颜色。"
K.locales.zhCN["ftColors"]="固定颜色"
K.locales.zhCN["ftFontHelp"]="可选择本插件已有字体及 LibSharedMedia 提供的字体。粗体、描边和阴影可分别设置。"
K.locales.zhCN["ftGold"]="金色"
K.locales.zhCN["ftGreen"]="绿色"
K.locales.zhCN["ftHelp"]="在脱离战斗后调整仇恨显示。隐藏 % 只移除符号，数字仍为百分比。原始模式使用原始仇恨百分比，而不是默认的缩放百分比。"
K.locales.zhCN["ftNote"]="使用此角色已有设置。解锁后拖动数字，完成后重新锁定。无数据时，解锁状态下的 75 仅为位置示例；锁定后会隐藏。"
K.locales.zhCN["ftOriginal"]="打开原始仇恨设置"
K.locales.zhCN["ftRed"]="红色"
K.locales.zhCN["ftRefresh"]="刷新数值"
K.locales.zhCN["ftUpdate"]="请安装随附的 ForeverThreat 模块更新以使用这些设置。"
K.locales.zhCN["ftWhite"]="白色"
K.locales.zhCN["ft_alpha"]="不透明度（%）"
K.locales.zhCN["ft_autoColor"]="使用原生仇恨颜色"
K.locales.zhCN["ft_bold"]="粗体文字"
K.locales.zhCN["ft_enabled"]="启用仇恨显示"
K.locales.zhCN["ft_locked"]="锁定位置"
K.locales.zhCN["ft_outline"]="文字描边"
K.locales.zhCN["ft_raw"]="使用原始仇恨百分比"
K.locales.zhCN["ft_shadow"]="文字阴影"
K.locales.zhCN["ft_showPercent"]="显示 % 符号"
K.locales.zhCN["ft_size"]="字体大小"
K.locales.zhCN["ft_x"]="水平位置"
K.locales.zhCN["ft_y"]="垂直位置"

-- Profiles: saved records, transfer, undo, class presets and help.
K.locales.zhCN["pfApply"]="应用配置方案"
K.locales.zhCN["pfBackup"]="最后的撤销备份 — 当前角色"
K.locales.zhCN["pfBackupHelp"]="每个角色仅保留一份撤销备份，直到删除或被下次配置应用替换。恢复备份时，会将刚离开的设置保存为新备份。普通设置更改不会生成备份历史。"
K.locales.zhCN["pfBadName"]="请使用唯一的配置名称，长度为 1–48 字节，且不含控制字符或竖线。"
K.locales.zhCN["pfBeforeApply"]="应用配置之前"
K.locales.zhCN["pfBeforeRestore"]="恢复备份之前"
K.locales.zhCN["pfCancelPending"]="取消待处理更改"
K.locales.zhCN["pfCancelled"]="已取消待处理更改，当前设置未改变。"
K.locales.zhCN["pfCharacter"]="角色"
K.locales.zhCN["pfChoose"]="已保存的配置和角色"
K.locales.zhCN["pfConfirmApply"]="确认选择"
K.locales.zhCN["pfConfirmDelete"]="再次点击以删除"
K.locales.zhCN["pfConfirmRestore"]="确认恢复"
K.locales.zhCN["pfDelete"]="删除所选记录"
K.locales.zhCN["pfDeleteBackup"]="删除撤销备份"
K.locales.zhCN["pfDeleted"]="记录已删除。"
K.locales.zhCN["pfEmpty"]="暂无已保存的配置。"
K.locales.zhCN["pfExists"]="该名称已存在。请使用其他名称，或先删除旧配置。"
K.locales.zhCN["pfFailed"]="操作失败，未接受新配置。"
K.locales.zhCN["pfFull"]="配置存储空间已满。请删除不用的配置后重试。"
K.locales.zhCN["pfGenerate"]="生成当前代码"
K.locales.zhCN["pfGenerated"]="代码已生成。Ctrl+A 全选，Ctrl+C 复制。可在此粘贴其他代码以导入。"
K.locales.zhCN["pfInvalid"]="配置代码无效、已损坏或不受支持。未更改任何设置。"
K.locales.zhCN["pfLoadCode"]="显示或分享代码"
K.locales.zhCN["pfManualReload"]="重新加载不可用或被阻止。待处理设置已保留，请在聊天中输入 /reload。"
K.locales.zhCN["pfNamed"]="配置方案"
K.locales.zhCN["pfNeedsValidation"]="应用前请先验证代码。尚未更改设置。"
K.locales.zhCN["pfNoBackup"]="此角色没有撤销备份。"
K.locales.zhCN["pfPending"]="请先应用待处理的插件加载更改，并重新加载界面后再导入配置。"
K.locales.zhCN["pfPendingProfile"]="已有配置等待应用。请点击重新加载界面以应用，或先取消。"
K.locales.zhCN["pfQueued"]="设置已准备好。请点击下方的重新加载界面以应用，或在此取消。"
K.locales.zhCN["pfRestore"]="恢复先前设置"
K.locales.zhCN["pfRestoreWarning"]="确认以准备恢复备份，然后点击下方的重新加载界面。现有备份会受到保护，直到恢复完成。"
K.locales.zhCN["pfSave"]="保存当前设置"
K.locales.zhCN["pfSaveName"]="新配置名称"
K.locales.zhCN["pfSaved"]="配置已保存。每个已保存配置都是独立副本。"
K.locales.zhCN["pfStorage"]="配置存储：%.1f / %.0f KiB · %d 条记录"
K.locales.zhCN["pfStorageHelp"]="最多保存 32 个命名配置和 64 条角色记录；总计 2 MiB，包括暴雪和 Bartender 布局。角色记录更新时会替换先前版本。空间不足时可能移除最旧的角色记录；命名配置不会自动删除。撤销备份单独保存。"
K.locales.zhCN["pfTestOK"]="配置自检已通过。"
K.locales.zhCN["pfTooLarge"]="配置代码超过大小限制。未更改任何设置。"
K.locales.zhCN["pfUseSelected"]="应用到此角色"
K.locales.zhCN["pfValid"]="代码有效。"
K.locales.zhCN["pfValidate"]="验证"
K.locales.zhCN["pfValidated"]="有效配置 · 来源职业：%s · %d 个模块设置表。将使用当前职业装饰。面板外观也会跨角色应用。"

-- Interface: appearance, scale, window controls, introduction and help.
K.locales.zhCN["cardGlowHelp"]="在卡片周围添加柔和阴影或光晕。可在下方调整颜色、强度和扩散范围，或关闭效果。仅影响此设置面板。"
K.locales.zhCN["glowStyleHelp"]="选择深色阴影或彩色光晕。强度、扩散范围和 RGB 控制效果，卡片亮度控制背景。这些面板设置跨角色生效。关闭柔和光晕即可隐藏效果。"
K.locales.zhCN["heightResizeHelp"]="向下拖动底部中央把手，可增加窗口高度而不改变文字大小。角落把手仍会缩放整个面板。"
K.locales.zhCN["launcher"]="显示小地图图标"
K.locales.zhCN["launcherHelp"]="在小地图旁显示 KerimAnka UI 启动按钮，兼容的图标收集器可以收纳此按钮。"
K.locales.zhCN["resizeHelp"]="按住右下角并沿对角线拖动，可等比例缩放整个面板。大小和位置会保存，仍可在“界面”中调整缩放。"
K.locales.zhCN["restoreHelp"]="仅将通过此面板更改的数值恢复为此前记录的值，不改变模块的启用状态。"
K.locales.zhCN["scaleHelp"]="仅缩放此设置窗口。拖动标题栏可移动窗口，位置会自动记住。"

-- Minimap launcher tooltip.
K.locales.zhCN["openTip"]="左键点击：打开设置"

-- Clarify copy sources, sound preset and shared artwork color controls.
K.locales.zhCN["pfSourceHint"]="所选记录是复制来源。在此修改角色专属设置不会更改来源记录。设置窗口的外观由所有角色共用。"
K.locales.zhCN["clicksHelp"]="静音六个预设的技能错误和点击音效。语音错误提示需单独设置。"
K.locales.zhCN["backingColorHelp"]="更改动作按钮后方的职业装饰背景，保留装饰边框和按钮边框。“职业外观”和“动作条背景”中的控件使用同一项设置。"

-- Custom sound muting: per-character state, honest test results and preview controls.
K.locales.zhCN["custom"]="自定义音效静音"
K.locales.zhCN["customHelp"]="输入音频文件编号，用逗号或空格分隔。添加后会为当前角色自动请求静音。请使用文件编号，而非音效组编号。同一事件可能使用多个文件。试听会临时绕过静音，测试不会。"
K.locales.zhCN["empty"]="尚未添加需要静音的自定义音效。"
K.locales.zhCN["soundCustomInfo"]="添加编号即可为当前角色启用静音。试听会临时绕过静音；测试保留静音并尝试播放，此时应听不到声音。"
K.locales.zhCN["soundMuteActive"]="已启用静音"
K.locales.zhCN["soundMuteFailed"]="无法应用静音"
K.locales.zhCN["soundMuteUnavailable"]="静音功能不可用"
K.locales.zhCN["soundMuteTest"]="测试静音"
K.locales.zhCN["soundTestPlayed"]="测试已开始播放。若听到声音，此文件未被静音。请检查编号和其他音效插件。"
K.locales.zhCN["soundTestSilent"]="未开始播放。这与静音效果一致，但关闭的声道或无效文件也可能导致此结果。请用试听确认文件。"
K.locales.zhCN["soundAdded"]="音频编号已保存到当前角色。请查看各行的静音状态。"
K.locales.zhCN["soundRemoved"]="已从自定义静音列表移除。预设或其他插件仍可能静音此文件。"
K.locales.zhCN["stopPreview"]="停止预览"
K.locales.zhCN["stopPreviewHelp"]="仅停止在此通过试听或测试开始的播放，不会开启或关闭静音。"

-- Small curated sound groups; no automatic muting.
K.locales.zhCN["sgTitle"]="预设音效组"
K.locales.zhCN["sgHelp"]="音效组使用同一份角色专属自定义列表。静音会添加组内文件，恢复会将其移除。共用文件也可能影响其他玩家的声音。不会自动启用任何组。"
K.locales.zhCN["sgBow"]="拉弓"
K.locales.zhCN["sgBowHelp"]="拉弓时的三种音效。放箭及命中音效保留。"
K.locales.zhCN["sgGun"]="枪械射击"
K.locales.zhCN["sgGunHelp"]="经典枪械射击的三种音效。装填音效另有分组。"
K.locales.zhCN["sgReload"]="枪械装填"
K.locales.zhCN["sgReloadHelp"]="射击前的机械及装填音效。射击音效另有分组。"
K.locales.zhCN["sgWand"]="魔杖发射"
K.locales.zhCN["sgWandHelp"]="不同魔法类型的魔杖发射音效。命中音效可能保留。"
K.locales.zhCN["sgEnabled"]="已开启静音"
K.locales.zhCN["sgPartial"]="部分静音"
K.locales.zhCN["sgDisabled"]="未开启静音"
K.locales.zhCN["sgFailed"]="无法完成操作。"
K.locales.zhCN["sgMuted"]="已将此组添加到自定义静音列表。"
K.locales.zhCN["sgRestored"]="已将组内文件从自定义列表移除。其他设置或插件仍可能静音这些文件。"
K.locales.zhCN["sgVerified"]="已在 Forever 中确认"
K.locales.zhCN["sgPending"]="等待游戏内确认"
K.locales.zhCN["sgListenHelp"]="每次点击试听下一个文件。展开显示文件可逐一试听各个版本。"
K.locales.zhCN["sgUnmute"]="恢复"
K.locales.zhCN["sgMute"]="静音"
K.locales.zhCN["sgHideFiles"]="隐藏文件"
K.locales.zhCN["sgFiles"]="显示文件"

-- Hunter range: settings, live state labels and custom-text help.
K.locales.zhCN["hrHelp"]="在脱离战斗时调整现有距离条。X 为正时向右移动，Y 为正时向上移动。状态颜色保持不变；彩色文字与状态图标一致。距离条较窄时文字可能缩小以适应。"
K.locales.zhCN["hrLive"]="返回实时检测"
K.locales.zhCN["hrLiveMode"]="实时检测"
K.locales.zhCN["hrMode"]="模式："
K.locales.zhCN["hrNote"]="使用当前角色的设置。解锁后可将距离条拖到攻击计时条上方。背景保持不透明黑色。"
K.locales.zhCN["hrOriginal"]="打开原距离设置"
K.locales.zhCN["hrPreview"]="状态预览"
K.locales.zhCN["hrPreviewHelp"]="在实际距离条上显示示例，并非测量目标距离。请先启用显示。离开此页或关闭窗口会结束临时预览。解锁的距离条在没有目标时仍可能显示用于定位的示例。"
K.locales.zhCN["hrRefresh"]="刷新数值"
K.locales.zhCN["hrSample"]="示例："
K.locales.zhCN["hrUpdate"]="安装附带的 ForeverHunterRange 更新后即可使用这些控件。"
K.locales.zhCN["hr_coloredText"]="文字颜色随距离状态变化"
K.locales.zhCN["hr_enabled"]="启用距离显示"
K.locales.zhCN["hr_fontSize"]="字号"
K.locales.zhCN["hr_height"]="高度"
K.locales.zhCN["hr_locked"]="锁定位置"
K.locales.zhCN["hr_outline"]="文字描边"
K.locales.zhCN["hr_shadow"]="文字阴影"
K.locales.zhCN["hr_width"]="宽度"
K.locales.zhCN["hr_x"]="水平位置"
K.locales.zhCN["hr_y"]="垂直位置"

-- Community links and copy window.
K.locales.zhCN["communityGithubTitle"]="GitHub · 问题与建议"
K.locales.zhCN["communityGithubHelp"]="项目、更新和问题反馈。打开链接并复制地址。"
K.locales.zhCN["communityTwitchTitle"]="Twitch · 直播"
K.locales.zhCN["communityTwitchHelp"]="观看 KerimAnka 的直播。直播语言：土耳其语。请在 GitHub 上报告问题。"
K.locales.zhCN["communityPending"]="GitHub 项目页面尚未创建。后续更新将添加地址。"
K.locales.zhCN["communityCopy"]="按 Ctrl+C 复制 · 按 Esc 关闭"
K.locales.zhCN["communityReloadWaiting"]="插件更改待生效 · 请重新加载界面。"
