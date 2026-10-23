-- UTF-8 panel translations. Missing entries fall back to English.
local _,K=...
K.locales.tr = {
 ["uf_nameOffsetY"]="İsim Yukarı / Aşağı",
 ["uf_petTextScale"]="Pet Yazı Boyutu",
 ["art_petBar"]="Pet Yetenek Barı",
 ["art_petPanelEnabled"]="Pet Barı Arka Planını Göster",
 ["art_petPanelAlpha"]="Pet Barı Arka Plan Görünürlüğü",
 ["art_petPanelPadding"]="Pet Barı Kenar Payı",
 ["warlockArtTitle"]="Warlock — Sınıf Tasarımı",
 ["artSkinFel"]="Fel Obsidyen",
 ["artSkinRitual"]="Ruh Ritüeli",
 ["art_ritualRailWidth"]="Üst Çıta Genişliği (%)",
 ["art_ritualRailX"]="Üst Çıta Sağ / Sol",
 ["warlockRitualTitle"]="Warlock — Ruh Ritüeli",
 ["warlockRitualHelp"]="Ruh Ritüeli ve Fel Obsidyen arasında üstteki kartlardan seçim yapabilirsin. Alt simgeler en-boy oranını korur; konumu genel yukarı/aşağı ayarıyla belirle. Üst çıta bağımsızdır. Koyu panel seçilen barları takip eder.",
 ["art_ritualBacking"]="Koyu Arka Paneli Göster",
 ["art_ritualOpacity"]="Arka Panel Görünürlüğü",
 ["art_ritualDock"]="Alt Süslemeyi Ekranın Altına Yasla",
 ["art_ritualInset"]="Alt Kenardan Yükseklik",
 ["art_ritualRail"]="Bağımsız Üst Çıtayı Göster",
 ["art_ritualRailY"]="Üst Çıta Yukarı / Aşağı",
 ["art_ritualRailHeight"]="Üst Çıta Yüksekliği",
 ["flAppliedCharacter"]="Profil ve bu karaktere özel Blizzard yerleşimi uygulandı. Diğer karakterlerin seçili yerleşimi değişmedi. Action bar’ları ve Hasar Göstergesi’ni kontrol et. Önceki Ayarlara Dön iki tarafı birlikte geri alır.",
 ["flAccountPlan"]="Yerleşim türü: Hesap geneli — diğer karakterlerde de seçilebilir.",
 ["flCharacterPlan"]="Yerleşim türü: Yalnızca bu karakter — hesap yerleri doluysa da kullanılabilir.",
 ["flTitle"]="Tam Arayüz — Ortak Blizzard Yerleşimi",
 ["flHelp"]="Seçili KerimAnka UI profiliyle birlikte 1920 × 1080 Blizzard yerleşimini uygular. Uygun bir mevcut KerimAnka UI yerleşimini kullanır; yoksa hesap geneline ekler. Hesap doluysa bu karaktere özel oluşturur. Kullanılacak tür aşağıda gösterilir. Sınıf görselleri ayrıca belirlenir.",
 ["flChecklist"]="Testten sonra gerekli action bar’ların açık olduğunu ve Hasar Göstergesi’nin (Schadenanzeige) etkin olduğunu kontrol et. Bar görünürlüğü, tuş atamaları ve diğer bütün oyun tercihleri bu kodla garanti edilmez. Farklı çözünürlük ve UI ölçeğinde konumları kontrol et.",
 ["flApply"]="Seçili Profil + Blizzard Yerleşimi",
 ["flWarning"]="Seçili addon profili ve aşağıda belirtilen türdeki Blizzard yerleşimi yeniden yüklemeden sonra uygulanacak. Önceki ayarların ve aktif yerleşimin geri dönüş bilgisi saklanır. Hiçbir yerleşimin silinmez. Yeni düğmeye tekrar basarak onayla, ardından arayüzü yeniden yükle.",
 ["flUnavailable"]="Blizzard yerleşim sistemi henüz hazır değil veya bu sürümde desteklenmiyor. İşlem hazırlanmadı; Düzenleme Modu’nu açıp kapattıktan sonra tekrar dene.",
 ["flCloseEdit"]="Önce Blizzard Düzenleme Modu’ndaki değişiklikleri kaydet veya iptal et ve modu kapat. Ardından tekrar dene.",
 ["flInvalid"]="Blizzard bu yerleşim kodunu okuyamadı. İşlem hazırlanmadı; kodun bu oyun sürümüyle uyumunu kontrol et.",
 ["flFull"]="Seçilen yerleşim türünde boş yer yok. Hesap ve karakter yerleri ayrı sayılır. Hiçbir yerleşim silinmedi; Düzenleme Modu’ndan yerleşim listesini kontrol edebilirsin.",
 ["flFailed"]="Blizzard yerleşimi uygulanamadı. Addon profili uygulanmış olabilir; önceki ayarların geri alma yedeğinde saklı. “Önceki Ayarlara Dön” ile geri dönebilirsin.",
 ["flApplied"]="Profil ve Blizzard yerleşimi uygulandı. Action bar görünürlüğünü ve Hasar Göstergesi’ni kontrol et. Geri alma, önceki addon ayarlarını ve önceki Blizzard yerleşimini birlikte seçer.",
 ["aaCheetah"]="Geparden Savaş Uyarısı Metni",
 ["aaEnabled"]="Aspect Uyarılarını Aç",
 ["aaGlow"]="Geparden Savaş Parlaması",
 ["aaHelp"]="Yüklü uyarıyı addonun yüklenmesinden ayrı kontrol eder. Öğrenilmemiş aspektlerde ve yolculukta uyarıyı gizleyen mevcut kurallar korunur. Kilidi açınca yerleştirme örneği görünür; bitince yeniden kilitle.",
 ["aaLive"]="Canlı Uyarılara Dön",
 ["aaLock"]="Konumu Kilitle",
 ["aaMissing"]="Aspekt Yok Uyarısı Metni",
 ["aaNote"]="Ayarlar artık bu karaktere özeldir. Eski ortak ayarlar ilk kullanımda kopyalanır. Konumu ayarlamak için kilidi açıp uyarıyı sürükle.",
 ["aaCombatNoticeTitle"]="Beta: Savaş İçinde Aspekt Takibi",
 ["aaCombatNotice"]="Takip savaş dışında çalışır. Savaşta oyun buff bilgilerini gizlediği için ilk durum veya değişiklik algılansa bile sonraki değişiklikler izlenemeyebilir ve uyarı kaybolabilir. Uyarının görünmemesi, aspektinizin kapalı olduğu anlamına gelmez. Aktif aspektinizi oyunun kendi buff/aura simgelerinden kontrol edin. Bu özellik beta sürümünde hazırlanmıştır; oyunun kısıtları ve davranışı ileride değişebilir.",
 ["aaOriginal"]="Eski Aspect Ayarlarını Aç",
 ["aaPreview"]="Geparden Ön İzle",
 ["aaPreviewHelp"]="Gerçek uyarıda geçici bir örnek gösterir. Önce uyarıyı aç. Sayfadan çıkınca veya panel kapanınca bu örnek biter. Kilidi açık uyarı yerleştirme örneği göstermeye devam edebilir. Yolculukta gizleme kuralı korunur.",
 ["aaPreviewMissing"]="Aspekt Yok Ön İzle",
 ["aaRefresh"]="Değerleri Yenile",
 ["aaResetPosition"]="Uyarı Konumunu Sıfırla",
 ["aaResetTexts"]="Uyarı Metinlerini Varsayılana Döndür",
 ["aaText"]="Uyarı Yazısını Göster",
 ["aaTextHelp"]="En fazla 100 karakterlik kendi uyarın. Yazarken otomatik kaydedilir. Metin bu karaktere özeldir; panel dilini değiştirmek özel uyarı metnini çevirmez.",
 ["aaUpdate"]="Bu kontroller için paketteki HunterAspectAlert güncellemesini kur.",
 ["abAdvanced"]="Eski Gelişmiş Ayarları Aç",
 ["abAlpha"]="Tasarım Görünürlüğü",
 ["abArt"]="Sınıf Tasarımını Göster",
 ["abArtHelp"]="Mevcut sınıf tasarımını değiştirir. Genişlik/yükseklik yüzdedir. Pozitif X sağa, pozitif Y yukarı taşır. Otomatik mod seçilen barları takip eder. Otomatik moda dönüş genişlik/yüksekliği %100 yapar.",
 ["abAuto"]="Barları Otomatik Takip Et",
 ["abBar"]="Bar",
 ["abBars"]="Kapsanan Bartender Barları",
 ["abBorder"]="Dış Kenarlık Boyutu",
 ["abFixed"]="Sabit Boyut ve Konum",
 ["abFollow"]="Yeniden Barlara Uydur",
 ["abGap"]="Barlarla Arasındaki Boşluk",
 ["abHeight"]="Tasarım Yüksekliği (%)",
 ["abHelp"]="Değişiklikler savaş dışında uygulanır. En az bir bar seçili kalmalı. Parlaklık: 0 siyah, 1 orijinal renktir. Kenarlık boyutu 0 olursa dış kenarlık gizlenir.",
 ["abIntro"]="Ayarlar bu karaktere kaydedilir. Barların yerleşimi ve kısayolları, seçtiğin kaynağa göre oyunun kendi ayarlarından veya Bartender’dan düzenlenir.",
 ["abLock"]="Mevcut Boyutu ve Konumu Sabitle",
 ["abMin"]="En az bir bar seçili kalmalı.",
 ["abMode"]="Geçerli mod: ",
 ["abShade"]="Buton Çerçevesi Parlaklığı",
 ["abShow"]="Buton Arka Planını Göster",
 ["abSlot"]="Boş Slot Görünürlüğü",
 ["abUnsupported"]="Bu karakterin sınıfı için henüz tasarım yok.",
 ["abUpdate"]="Bu ayarlar için paketteki ForeverBarBackdrop güncellemesini kur.",
 ["abWidth"]="Tasarım Genişliği (%)",
 ["abX"]="Sağ / Sol Konumu",
 ["abY"]="Yukarı / Aşağı Konumu",
 ["active"]="Etkin",
 ["add"]="Ekle",
 ["addonChangeFailed"]="Addon değişikliği uygulanamadı:",
 ["addonChanging"]="Addon değişikliği hâlâ kontrol ediliyor.",
 ["addonControl"]="Addonun Yüklenmesi",
 ["addonControlHelp"]="Bu karakterin gerçek addon listesini değiştirir. Değişiklikten sonra yeniden yükle. Yukarıdaki tasarım anahtarları ise yüklü addonun görünümünü ayrıca kontrol eder.",
 ["addonStateUnknown"]="Addon durumu okunamadı",
 ["alerts"]="Uyarılar",
 ["ambience"]="Ortam Seslerini Sustur",
 ["ambienceHelp"]="Rüzgâr ve su gibi çevresel arka plan seslerini kapatır.",
 ["art"]="Sınıf Tasarımı",
 ["artSkinHelp"]="Bu karakterin action bar görselini ön izle ve değiştir. Savaş dışında uygulanır. Minimap ve unit frame kendi görünümünü korur. Seçimin kayıtlı profillere dahil edilir.",
 ["artSkinHunter"]="Avcı",
 ["artSkinMetal"]="Sade Metal",
 ["artSkinSelected"]="Seçili",
 ["artSkinUse"]="Bu Görünümü Kullan",
 ["artSkins"]="Action Bar Görünümü",
 ["art_alpha"]="Çerçeve Görünürlüğü",
 ["art_artConfirm"]="Sıfırlamak İçin Tekrar Tıkla",
 ["art_artExtraHelp"]="Ayarlar bu karaktere kaydedilir. Bu seçenekler tuş dizilimini değil, süslemeyi değiştirir. Kullanılamayan ayarlar soluk görünür.",
 ["art_artReset"]="Tasarım Varsayılanlarına Dön",
 ["art_backing"]="Action Bar Arka Paneli ve Üst Şerit",
 ["art_center"]="Timer ve Pet Barını Çerçevele",
 ["art_centerPadding"]="Orta Çerçeve Kenar Payı",
 ["art_edge"]="Köşe Boyutu",
 ["art_enabled"]="Etkinleştir",
 ["art_hideBorder"]="Blizzard Minimap Kenarlığını Gizle",
 ["art_hideBorderHelp"]="Yalnızca minimap çevresindeki Blizzard kenarlığını gizler. Action bar yanındaki kartal/heykel süslerini veya Bartender tasarımını değiştirmez. Başka bir addon da minimap kenarlığını gizliyorsa bu seçeneği kapatmak onu görünür yapmayabilir.",
 ["art_hunterHUD"]="Hunter Üst Çerçeveleri",
 ["art_hunterMatte"]="Mat Hunter Tasarımı",
 ["art_minimap"]="Minimap Tasarımı",
 ["art_opacity"]="Arka Panel Görünürlüğü",
 ["art_padding"]="Çerçeve Kenar Payı",
 ["art_rail"]="Üst Şerit Kalınlığı",
 ["art_railY"]="Üst Şerit Konumu",
 ["art_reset"]="Minimap Varsayılanlarına Dön",
 ["art_resource"]="Kişisel Kaynak Göstergesini Gizle",
 ["art_size"]="Çerçeve Boyutu (%)",
 ["art_units"]="Blizzard Unit Frame'lerini Süsle",
 ["art_x"]="Sağ / Sol Konumu",
 ["art_y"]="Yukarı / Aşağı Konumu",
 ["aspect"]="Aspect Uyarısı",
 ["backdrop"]="Bar Arka Planı",
 ["background"]="Oyun Arka Plandayken Sustur",
 ["backgroundHelp"]="Oyun penceresi aktif değilken oyun sesini durdurur.",
 ["badgeDisable"]="Bu karakterde addonu kapatmak için tıkla.",
 ["badgeEnable"]="Bu karakterde addonu açmak için tıkla.",
 ["badgeHelp"]="Yeşil: addon yüklü. İçindeki görünüm özelliği yine de kapalı olabilir. Soluk: devre dışı veya yüklenmemiş. Sarı: yükleme değişikliği yeniden yükleme bekliyor.",
 ["barsAuto"]="Otomatik",
 ["barsBT"]="Bartender",
 ["barsBTActive"]="Bartender barları kullanılıyor. Mevcut Bartender çerçeve düzenin korunuyor.",
 ["barsConflict"]="Bartender hâlâ Blizzard barlarını yönetiyor/gizliyor. Blizzard kullanmak için oyunun addon listesinden Bartender’ı kapatıp yeniden yükle.",
 ["barsEditor"]="Blizzard Düzenleme Modunu Aç",
 ["barsLocked"]="Sabit modda bar takibi kapalıdır. Bu seçimi değiştirmek için yukarıdan Yeniden Barlara Uydur'u seç.",
 ["barsMissingBT"]="Bartender seçili ama barları aktif değil. Açıp yeniden yükle veya Otomatik / Blizzard seç.",
 ["barsNative"]="Blizzard",
 ["barsNativeActive"]="Blizzard barları kullanılıyor. Oyun ayarlarından 2. ve 3. barı açıp Düzenleme Modu’nda üç yatay barı üst üste yerleştir. Tasarım, seçtiğin görünür barları takip eder.",
 ["barsNativeList"]="Kapsanan Blizzard Barları",
 ["barsNoEditor"]="Blizzard Düzenleme Modu şu anda kullanılamıyor. Savaş dışında oyunun menüsünden açmayı dene.",
 ["barsSource"]="Action Bar Kaynağı",
 ["barsSourceHelp"]="Otomatik, barları Bartender yönetiyorsa onu; aksi halde Blizzard barlarını kullanır. Boyut, konum ve bar seçimi iki kaynak için ayrı saklanır. Bu seçim addon açıp kapatmaz. Bartender’dan Blizzard’a geçmek için oyunun addon listesinden Bartender’ı kapatıp yeniden yükle. Yetenek dizilimi ve tuş atamaları kopyalanmaz veya değiştirilmez.",
 ["bridge"]="Bu ilk sürüm modülün mevcut ayarlarını açar. Ayrıntılı kontrolleri ve çevirileri sonraki sürümlerde buraya taşıyacağız.",
 ["camera"]="Kamera",
 ["cardGlow"]="Yumuşak Kart Halesi",
 ["cardGlowHelp"]="Kartların çevresine yumuşak gölge veya hale ekler. Aşağıdan rengini, yoğunluğunu ve yayılmasını ayarlayabilir ya da kapatabilirsin. Sadece bu ayar panelini etkiler.",
 ["cardTone"]="Kart Arka Plan Parlaklığı",
 ["center"]="Pencereyi Ortala",
 ["character"]="Karakter",
 ["classChanged"]="Hunter’a özel addonlar bu karakter için kapatıldı. Tamamlamak için arayüzü yeniden yükle.",
 ["clicks"]="Yetenek Hata Tıklarını Sustur",
 ["clicksHelp"]="Makrondaki altı ses dosyasını susturur: 569772–569776 ve 567407. Karakterin konuşarak verdiği hata uyarısı ayrı bir ayardır.",
 ["combat"]="Savaş ve Girdi",
 ["combatLock"]="Bu değişikliği savaş dışında yap.",
 ["custom"]="Özel Ses Dosyaları",
 ["customHelp"]="Sayısal ses dosyası numaralarını virgül veya boşlukla ayır. Sound kit numarası değil, dosya numarası kullanılır. Oyun numaranın duyulur bir sese ait olduğunu doğrulamaz.",
 ["dependency"]="Modül yüklenmezse addon listesinden gereken diğer addonları kontrol et.",
 ["details"]="Details",
 ["dialog"]="Diyalogları Sustur",
 ["dialogHelp"]="Oyunun diyalog ses kanalını kapatır. Konuşmalı hata uyarısının ayrı seçeneği vardır.",
 ["disableDeathEffect"]="Hayaletken Gri Ekranı Kapat",
 ["disableDeathEffectHelp"]="Öldüğünde veya hayaletken uygulanan tam ekran efektini kapatarak çevrenin normal renklerle görünmesini sağlar. AÇIK efekti kapatır; KAPALI geri açar. Oyunun kendi ayarını kullanır, arka planda tarama yapmaz. UI profiline kaydedilir. İstemci bu ayarı sunmuyorsa seçenek kullanılamaz.",
 ["disabled"]="Devre Dışı",
 ["dragTip"]="Sürükle: ikonu taşı",
 ["dtAll"]="Forever Hunter’ı Tüm Pencerelere Uygula",
 ["dtAllHelp"]="Forever Hunter tasarımını oluşturulmuş ve etkin Details pencerelerine uygular; otomatik görünürlükle gizlenmiş pencereler de dahildir. Yeni pencere oluşturmaz. Skin seçimi, şablonun görünüm ayarlarını uygular.",
 ["dtAlpha"]="Dış Tasarım Görünürlüğü",
 ["dtApply"]="Seçilen Skini Uygula",
 ["dtCurrent"]="Geçerli skin: ",
 ["dtDone"]="Skin uygulandı.",
 ["dtEmpty"]="Hazır ve etkin bir Details penceresi bulunamadı. Details penceresini açıp bu sayfayı yenile.",
 ["dtFailed"]="Skin uygulanamadı:",
 ["dtFonts"]="Yazı Tipi ve Boyutlarını Koru",
 ["dtHelp"]="Dış tasarım yalnızca Forever Hunter skini kullanılan pencerelerde görünür. Skin değiştirirken satır ve başlık yazılarının tipi ve boyutu korunur; diğer görünüm ayarları seçilen skinden gelir.",
 ["dtNative"]="Details Ayarlarını Aç",
 ["dtNote"]="Details görünümünü buradan yönet. Sayaç verileri, raporlar ve gelişmiş ayarlar Details’ta kalır. Hunter tasarımı bütün sınıflarda kullanılabilir.",
 ["dtRefresh"]="Yenile",
 ["dtSelection"]="− / + ile kayıtlı skinlerden birini seç, ardından Uygula’ya bas. Kendiliğinden skin değiştirilmez.",
 ["dtTrim"]="Dış Tasarımı Göster",
 ["dtUpdate"]="Bu kontroller için paketteki ForeverDetailsHunter güncellemesini kur.",
 ["dtWaiting"]="Skin henüz kaydedilmedi. Biraz bekleyip yenile.",
 ["dtWindow"]="Pencere",
 ["dtWindows"]="Details Pencereleri",
 ["effects"]="Ses Efektlerini Sustur",
 ["effectsHelp"]="Savaş ve birçok arayüz sesi dahil tüm efekt kanalını kapatır. Tek bir sesi kapatmak için aşağıdaki dosya numarası alanını kullan.",
 ["empty"]="Henüz özel ses dosyası eklenmedi.",
 ["enable"]="Bu Karakter İçin Etkinleştir",
 ["enableHelp"]="Bu karakterin addon listesini değiştirir. Yeniden yükleme gerekir; yüklü addon o zamana kadar çalışmaya devam eder. Gereken diğer addonlar otomatik açılmaz veya kapanmaz.",
 ["errorCustom"]="Özel Filtreler",
 ["errorCustomHelp"]="AÇIK o hata grubunu gizler; KAPALI gösterir. Önemli ve tanınmayan hatalar görünür kalır. Bu mod yalnızca bilinen hataları filtreler; diğer bütün hataları susturmak için Yalnızca Önemli Uyarılar modunu seç.",
 ["errorImportantHelp"]="Çanta/banka dolu, görev günlüğü dolu, yetersiz para ve eşya taşıma sınırı dışındaki tüm kırmızı hataları gizler. Önemli Uyarıları Koru kapatılırsa bunlar da gizlenir. Görev ilerleme bildirimleri etkilenmez.",
 ["errorImportantOnly"]="Yalnızca Önemli Uyarılar",
 ["errorShowAll"]="Hepsini Göster",
 ["errorShowHelp"]="Normal Blizzard hata gösterimi. Ek yazı filtresi uygulanmaz.",
 ["error_cooldown"]="Bekleme Süresi Hatalarını Gizle",
 ["error_direction"]="Yön / Görüş Hatalarını Gizle",
 ["error_movement"]="Hareket Hatalarını Gizle",
 ["error_range"]="Menzil Hatalarını Gizle",
 ["error_resources"]="Kaynak Hatalarını Gizle",
 ["error_target"]="Hedef Hatalarını Gizle",
 ["errors"]="Kırmızı Hata Yazılarını Gizle",
 ["errorsHelp"]="Kapatınca tüm normal kırmızı uyarılar görünür. Açınca Ana Sayfa > Uyarılar bölümündeki filtre modu uygulanır. Varsayılan olarak yalnızca orada belirtilen önemli uyarılar kalır. Ses ayarları ayrıdır.",
 ["failed"]="Oyun bu değişikliği uygulayamadı.",
 ["featureOff"]="Özellik Kapalı",
 ["fileIds"]="Ses dosyası numaraları",
 ["ftBlue"]="Mavi",
 ["ftCenter"]="Konumu Merkeze Getir ve Kilidi Aç",
 ["ftColorHelp"]="Sabit renk seçmek otomatik tehdit rengini kapatır. İstersen yukarıdan oyunun tehdit renklerini yeniden açabilirsin.",
 ["ftColors"]="Sabit Renk",
 ["ftDefault"]="Varsayılan",
 ["ftFont"]="Yazı Tipi",
 ["ftFontHelp"]="Addonun mevcut yazı tiplerinden ve LibSharedMedia’nın sağladığı fontlardan seç. Kalın yazı, kenarlık ve gölge birbirinden bağımsızdır.",
 ["ftGold"]="Altın",
 ["ftGreen"]="Yeşil",
 ["ftHelp"]="Mevcut tehdit göstergesini savaş dışında ayarlar. % işaretini kapatmak yalnızca işareti kaldırır; sayı yine yüzdedir. Ham mod, varsayılan ölçeklenmiş yüzde yerine ham tehdit yüzdesini kullanır.",
 ["ftNote"]="Mevcut karakter ayarların kullanılır. Kilidi açıp sayıyı sürükle, ardından kilitle. Veri yokken kilidi açık göstergedeki 75 yalnızca yerleştirme örneğidir; kilitliyken gizlenir.",
 ["ftOriginal"]="Eski Tehdit Ayarlarını Aç",
 ["ftRed"]="Kırmızı",
 ["ftRefresh"]="Değerleri Yenile",
 ["ftUpdate"]="Bu kontroller için paketteki ForeverThreat güncellemesini kur.",
 ["ftWhite"]="Beyaz",
 ["ft_alpha"]="Görünürlük (%)",
 ["ft_autoColor"]="Oyunun Tehdit Renklerini Kullan",
 ["ft_bold"]="Kalın Yazı",
 ["ft_enabled"]="Tehdit Göstergesini Aç",
 ["ft_locked"]="Konumu Kilitle",
 ["ft_outline"]="Yazı Kenarlığı",
 ["ft_raw"]="Ham Tehdit Yüzdesini Kullan",
 ["ft_shadow"]="Yazı Gölgesi",
 ["ft_showPercent"]="% İşaretini Göster",
 ["ft_size"]="Yazı Boyutu",
 ["ft_x"]="Sağ / Sol Konumu",
 ["ft_y"]="Yukarı / Aşağı Konumu",
 ["glowBlue"]="Efekt Rengi: Mavi",
 ["glowGreen"]="Efekt Rengi: Yeşil",
 ["glowRadius"]="Gölge / Hale Yayılması",
 ["glowRed"]="Efekt Rengi: Kırmızı",
 ["glowReset"]="Görünüm Varsayılanlarına Dön",
 ["glowStrength"]="Gölge / Hale Yoğunluğu",
 ["glowStyle"]="Kart Görünümü",
 ["glowStyleHelp"]="Koyu gölge veya renkli hale seçebilirsin. Yoğunluk, yayılma ve RGB efektin görünümünü; kart parlaklığı arka planı değiştirir. Bu panelin ayarları karakterler arasında ortaktır. Yumuşak Kart Halesi'ni kapatarak efekti gizleyebilirsin.",
 ["goldPreset"]="Sıcak Altın",
 ["heightResize"]="Pencere Yüksekliği",
 ["heightResizeHelp"]="Alt ortadaki tutamacı aşağı çekerek yazı boyutunu değiştirmeden pencereyi uzat. Köşedeki tutamaç panelin tamamını ölçeklemeye devam eder.",
 ["hideActionBarStatues"]="Blizzard Action Bar Heykellerini Gizle",
 ["hideActionBarStatuesHelp"]="Action bar’ın iki yanındaki kartal veya wyvern heykellerini gizler. Bartender olmadan Blizzard barlarında çalışır; varsa Bartender’ın aynı süslerini de gizler. Tuşları, deneyim çubuğunu veya minimap kenarlığını gizlemez. Kapatmak yalnızca bizim gizlememizi kaldırır; başka bir addon gizliyorsa süsler kapalı kalabilir. Ayar savaş dışında uygulanır ve bu karaktere kaydedilir.",
 ["hideNativeHotkeys"]="Tuş Ataması Yazılarını Gizle",
 ["hideNativeHotkeysHelp"]="Bu karakterin sekiz Blizzard action barındaki tuş yazılarını gizler. Tuş atamaları ve menzil göstergesi değişmez. Bartender kendi yazılarını yönetir.",
 ["hideNativeMacroNames"]="Makro İsimlerini Gizle",
 ["hideNativeMacroNamesHelp"]="Blizzard action bar ikonlarının altındaki makro isimlerini gizler. Makrolar, eşya adetleri ve bekleme süresi sayıları değişmez.",
 ["home"]="Ana Sayfa",
 ["hrHelp"]="Mevcut menzil barını savaş dışında ayarlar. Pozitif X sağa, pozitif Y yukarı taşır. Durum renkleri aynı kalır; renkli yazı durum ikonunu takip eder. Dar barda yazı sığmak için küçülebilir.",
 ["hrLive"]="Canlı Takibe Dön",
 ["hrLiveMode"]="Canlı takip",
 ["hrMode"]="Mod: ",
 ["hrNote"]="Mevcut karakter ayarların kullanılır. Kilidi açıp menzil barını swing timer’ın üstüne sürükleyebilirsin. Arka plan opak siyah kalır.",
 ["hrOriginal"]="Eski Menzil Ayarlarını Aç",
 ["hrPreview"]="Durum Ön İzlemesi",
 ["hrPreviewHelp"]="Gerçek bar üzerinde örnek durum gösterir; hedefin ölçülen mesafesi değildir. Önce göstergeyi aç. Sayfadan çıkınca veya paneli kapatınca bu geçici örnek biter. Kilidi açık bar, hedef yokken yerleştirme örneği göstermeye devam edebilir.",
 ["hrRefresh"]="Değerleri Yenile",
 ["hrSample"]="Örnek: ",
 ["hrUpdate"]="Bu kontroller için paketteki ForeverHunterRange güncellemesini kur.",
 ["hr_coloredText"]="Yazı Rengi Durumla Değişsin",
 ["hr_enabled"]="Menzil Göstergesini Aç",
 ["hr_fontSize"]="Yazı Boyutu",
 ["hr_height"]="Yükseklik",
 ["hr_locked"]="Konumu Kilitle",
 ["hr_outline"]="Yazı Kenarlığı",
 ["hr_shadow"]="Yazı Gölgesi",
 ["hr_width"]="Genişlik",
 ["hr_x"]="Sağ / Sol Konumu",
 ["hr_y"]="Yukarı / Aşağı Konumu",
 ["hunterOnly"]="Hunter’a Özel",
 ["hunterOnlyHelp"]="Bu modül bu UI içinde yalnızca Hunter’da kullanılır. Diğer sınıflarda addon listesinden otomatik kapatılır. Hunter’da kendin kapattığın modüller kapalı kalır. Yüklüyse kapanması için yeniden yükle.",
 ["imAlign"]="Chat’in Altına Yerleştir",
 ["imBagHelp"]="Çanta ikonuna tıklamak birleşik pencereyi kapatmadan o çantanın slotlarını gizler veya geri getirir. Blizzard diziliminde gizlenen slotların yeri boş kalır. Soluk ikon gizlenen çantayı belirtir. Değiştirici tuşla tıklama ve eşya sürükleme normal işlevini korur. Ayrı çanta görünümü kullanılabilir.",
 ["imBagSize"]="Çanta İkon Boyutu",
 ["imBagToggleHelp"]="Çanta ikon sırasını göster / gizle",
 ["imBags"]="Blizzard Çantaları",
 ["imBartender"]="Bartender açık. Blizzard çanta ve mikro menü düzenlemesi, Bartender kapatılana kadar bekler.",
 ["imDock"]="Çanta İkonlarını Birleşik Çantaya Bağla",
 ["imExpanded"]="Çanta İkon Sırasını Göster",
 ["imGap"]="İkonlar Arası Boşluk",
 ["imHelp"]="Blizzard çantalarını ve menü düğmelerini kullanır. Ayarlar bu karaktere kaydedilir. Başlıkta X’in solundaki sabit düğme, çantanın genişliğine hizalı ikon bölümünü açar/kapatır. Çanta ikonuna tıklamak yalnızca o çantanın slotlarını gizler veya geri getirir; diğerleri açık kalır.",
 ["imHideNativeBar"]="Standart Çanta Çubuğunu Gizle",
 ["imHideNativeBarHelp"]="Bagnon yüklüyken de bağımsız Blizzard çanta çubuğunu gizler. Çanta pencereleri ve klavye kısayolları çalışır. Bartender kendi çubuklarını yönetmeye devam eder. Kapatınca eski görünüm geri gelir.",
 ["imIconSize"]="Mikro Menü İkon Yüksekliği",
 ["imItemLooksHelp"]="Satılabilir gri eşyaların simgelerini grileştirir ve üzerlerine küçük bir para simgesi ekler; yeşil ve daha yüksek kaliteli eşyaların kenar rengini belirginleştirir. Birleşik ve ayrı Blizzard çantalarında çalışır. Bagnon gibi eklentiler kendi görünümünü kullanır. Otomatik satış veya silme yapmaz.",
 ["imJunk"]="Çöp Eşyaları Grileştir ve Para Simgesi Koy",
 ["imLocked"]="Mikro Menü Konumunu Kilitle",
 ["imManage"]="Mikro Menüyü Düzenle",
 ["imMicro"]="Mikro Menü",
 ["imMicroHelp"]="Blizzard menü düğmeleri ve işlevleri korunur. Boyut, aralık ve konum değiştirilebilir. Kapatmak eski yerleşimi geri getirir. Oyunun düzenleme modu açıkken kontrol geçici olarak oyuna bırakılır.",
 ["imMove"]="Mikro Menü — taşımak için sürükle",
 ["imMoveHelp"]="Konum kilidini kaldırınca menünün üstünde taşıma tutacağı görünür. Savaş dışında sürükleyip tekrar kilitle. Chat’in Altına Yerleştir, chat’i taşımadan ana chat’e hizalar. Chat ekranın dibindeyse yer açmak için biraz yukarı al.",
 ["imOtherBags"]="Başka bir çanta eklentisi açık; çanta ikonları ve eşya görünümü onda yönetilir. Standart çanta çubuğunu gizleme ve mikro menü ayarları kullanılabilir.",
 ["imQuality"]="Eşya Kalitesi Kenarlıklarını Belirginleştir",
 ["imReset"]="Mikro Menü Düzenini Sıfırla",
 ["imUnavailable"]="Bu istemcide gereken birleşik çanta pencereleri bulunamadı. Destekleniyorsa mikro menü kullanılabilir.",
 ["inactiveHelp"]="Bu addon yüklenmemiş. Ayarları kullanmak için bu karakterde açıp yeniden yükle. Gerekli diğer addonların da açık olduğunu kontrol et.",
 ["installed"]="Kurulu",
 ["interface"]="Arayüz",
 ["invalidIds"]="Yalnızca pozitif dosya numarası gir (en fazla 30 özel kayıt).",
 ["inventory"]="Çanta ve Menü",
 ["keepImportantErrors"]="Önemli Uyarıları Koru",
 ["keepImportantErrorsHelp"]="Yalnızca Önemli Uyarılar modunda çanta/banka dolu, görev günlüğü dolu, yetersiz para ve eşya taşıma sınırı görünür kalır. KAPALI olduğunda bütün kırmızı hata yazıları gizlenir.",
 ["language"]="Dil",
 ["languageHelp"]="Panel dilini seç. Henüz çevrilmemiş metinler İngilizce gösterilir.",
 ["launcher"]="Minimap İkonunu Göster",
 ["launcherHelp"]="Minimap yanında KerimAnka UI simgesini gösterir. Uyumlu ikon toplama addonları bunu toplayabilir.",
 ["lightPreset"]="Yumuşak Işık",
 ["listen"]="Dinle",
 ["loaded"]="Yüklü",
 ["missing"]="Kurulu Değil",
 ["moduleError"]="Modül ayarları açılamadı. Modülün etkin ve yüklü olduğunu kontrol et.",
 ["modules"]="Modüller",
 ["music"]="Müziği Sustur",
 ["musicHelp"]="Bölge ve savaş müzikleri dahil bütün oyun müziğini kapatır.",
 ["noPanel"]="Bu modülün ayar penceresi yok. Yukarıdaki anahtarla bu karakter için açıp kapatabilirsin.",
 ["notLoaded"]="Yüklenmemiş",
 ["note"]="İlk sürüm · Mevcut modül ayarların korunur.",
 ["off"]="KAPALI",
 ["on"]="AÇIK",
 ["open"]="Modül Ayarlarını Aç",
 ["openTip"]="Sol tık: ayarları aç",
 ["overview"]="Genel Bakış",
 ["pending"]="Yeniden yükleme gerekiyor",
 ["pendingOff"]="Kapanacak · Yeniden yükle",
 ["pendingOn"]="Açılacak · Yeniden yükle",
 ["pets"]="Pet Seslerini Sustur",
 ["petsHelp"]="Bu istemci pet sesi ayarını destekliyorsa pet seslerini kapatır.",
 ["pfApply"]="Profili Uygula",
 ["pfApplyWarning"]="Seçtiğin ayarları hazırlamak için onayla, ardından alttaki Arayüzü Yeniden Yükle düğmesine bas. Önceki ayarların korunur.",
 ["pfBackup"]="Son Geri Alma Yedeği — Bu Karakter",
 ["pfBackupHelp"]="Karakter başına tek geri alma yedeği tutulur. Silinene veya sonraki profil uygulamasına kadar kalır. Geri dönünce yerini az önceki ayarların alır. Her küçük ayar değişikliği ayrı geçmiş oluşturmaz.",
 ["pfBadName"]="1–48 bayt uzunlukta, kontrol karakteri veya | içermeyen farklı bir ad kullan.",
 ["pfBeforeApply"]="Profil uygulanmadan önce",
 ["pfBeforeRestore"]="Yedekten geri dönmeden önce",
 ["pfCancelPending"]="Bekleyen Değişiklikten Vazgeç",
 ["pfCancelled"]="Bekleyen değişiklik iptal edildi. Mevcut ayarların değişmedi.",
 ["pfCharacter"]="Karakter",
 ["pfChoose"]="Kayıtlı Profiller / Karakterler",
 ["pfConfirmApply"]="Seçimi Onayla",
 ["pfConfirmDelete"]="Silmek İçin Tekrar Tıkla",
 ["pfConfirmRestore"]="Geri Dönüşü Onayla",
 ["pfDelete"]="Seçileni Sil",
 ["pfDeleteBackup"]="Geri Alma Yedeğini Sil",
 ["pfDeleted"]="Kayıt silindi.",
 ["pfEmpty"]="Henüz kayıtlı profil yok.",
 ["pfExists"]="Bu ad zaten var. Başka ad seç veya eski profili sil.",
 ["pfFailed"]="İşlem tamamlanamadı. Yeni profil kabul edilmedi.",
 ["pfFull"]="Profil alanı dolu. Kullanmadığın bir profili silip tekrar dene.",
 ["pfGenerate"]="Mevcut Kodu Oluştur",
 ["pfGenerated"]="Kod oluşturuldu. Ctrl+A tümünü seçer, Ctrl+C kopyalar. İçe aktarmak için diğer kodu buraya yapıştır.",
 ["pfIntro"]="Profil veya karakter seçip Bu Karaktere Uygula’ya bas. Ardından alttaki Arayüzü Yeniden Yükle düğmesini kullan. Kayıtlı profiller bağımsız kopyalardır; karakterdeki değişiklikler onları otomatik değiştirmez. Bartender dizilimi ve Details/Questie profilleri ayrıdır.",
 ["pfInvalid"]="Kod geçersiz, bozulmuş veya desteklenmeyen sürümde. Ayarlar değiştirilmedi.",
 ["pfLoadCode"]="Kodu Göster / Paylaş",
 ["pfManualReload"]="Yeniden yükleme kullanılamadı veya engellendi. Bekleyen ayarların korunuyor. Sohbete /reload yaz.",
 ["pfNamed"]="Profil",
 ["pfNeedsValidation"]="Uygulamadan önce kodu doğrula. Ayarlar henüz değişmedi.",
 ["pfNoBackup"]="Bu karakter için geri alma yedeği yok.",
 ["pfPending"]="Önce bekleyen addon yükleme değişikliklerini uygula ve arayüzü yeniden yükle.",
 ["pfPendingProfile"]="Bekleyen bir profil var. Alttaki düğmeyle yeniden yükle veya önce vazgeç.",
 ["pfQueued"]="Ayarlar hazır. Uygulamak için alttaki Arayüzü Yeniden Yükle düğmesine bas veya buradan vazgeç.",
 ["pfRestore"]="Önceki Ayarlara Dön",
 ["pfRestoreWarning"]="Yedeği hazırlamak için onayla, ardından alttaki düğmeyle yeniden yükle. Mevcut yedek geri dönüş tamamlanana kadar korunur.",
 ["pfSave"]="Mevcut Ayarları Kaydet",
 ["pfSaveName"]="Yeni profil adı",
 ["pfSaved"]="Profil kaydedildi. Her kayıtlı profil bağımsız bir kopyadır.",
 ["pfStorage"]="Profil alanı: %.1f / %.0f KiB · %d kayıt",
 ["pfStorageHelp"]="En fazla 32 isimli profil ve 64 karakter kopyası; toplam 256 KiB. Karakter kopyası giriş/çıkışta güncellenip eskisinin yerini alır. Alan dolarsa en eski karakter kopyası kaldırılabilir; isimli profiller kendiliğinden silinmez. Geri alma yedeği ayrıca en fazla 64 KiB.",
 ["pfTestOK"]="Profil öz sınamaları geçti.",
 ["pfTooLarge"]="Profil kodu boyut sınırını aşıyor. Ayarlar değiştirilmedi.",
 ["pfTransfer"]="İçe / Dışa Aktarma Kodu",
 ["pfTransferHelp"]="Paylaşım kodu oluştur veya buraya yapıştır. Doğrula ve onayla, ardından alttaki düğmeyle yeniden yükle.",
 ["pfUseSelected"]="Bu Karaktere Uygula",
 ["pfValid"]="Kod geçerli.",
 ["pfValidate"]="Doğrula",
 ["pfValidated"]="Kod geçerli · kaynak sınıf: %s · %d modül ayar tablosu. Tasarım mevcut sınıfına uyarlanır. Panel görünümü diğer karakterlere de yansır.",
 ["previewFail"]="Dosya çalınamadı. Numarasını ve oyun ses ayarlarını kontrol et.",
 ["profiles"]="Profiller",
 ["qjBorder"]="Deri Kenarlık Kalınlığı",
 ["qjHelp"]="Questie görev takibini süsler. Kalem isteğe bağlıdır. Görevler, açılıp kapanma, yazı tipi, arka plan rengi ve konum Questie tarafından yönetilir. Bu anahtarlar addonun kendisini kapatmaz.",
 ["qjNote"]="Görevleri ve takip davranışını Questie yönetir. Bu sayfa defter tasarımını ayarlar.",
 ["qjOpacity"]="Arka Plan Görünürlüğü",
 ["qjOriginal"]="Eski Görev Günlüğü Ayarlarını Aç",
 ["qjQuill"]="İsteğe Bağlı Kalemi Göster",
 ["qjShow"]="Deri Tasarımını Göster",
 ["qjUpdate"]="Bu ayarlar için paketteki ForeverQuestJournal güncellemesini kur.",
 ["qjWaiting"]="Questie takip penceresine henüz bağlanmadı. Questie’nin açık ve takip penceresinin görünür olduğunu kontrol et.",
 ["quests"]="Görev Günlüğü",
 ["queue"]="Spell Queue Window",
 ["queueHelp"]="Sonraki yeteneğin sıraya alınabildiği süre, milisaniye cinsinden. Düşük değer her zaman daha iyi değildir; gecikmene uygun ayarla.",
 ["quick"]="Hızlı Ayarlar",
 ["range"]="Hunter Menzil",
 ["reload"]="Arayüzü Yeniden Yükle",
 ["reloadHelp"]="Addon açma/kapatma değişikliklerini uygulamak için arayüzü yeniden yükler. Kaydedilen ayarlar korunur.",
 ["reloadLater"]="Sonra",
 ["reloadNow"]="Şimdi Yeniden Yükle",
 ["reloadPromptBody"]="Addon değişikliklerini uygulamak için arayüzü yeniden yükle. İstersen daha sonra alttaki düğmeden de yapabilirsin.",
 ["reloadPromptTitle"]="Arayüzü Yeniden Yükle",
 ["reloadWaiting"]="Addon değişiklikleri bekliyor · Sağdaki düğmeyle yeniden yükle.",
 ["remove"]="Kaldır",
 ["resetHelp"]="/kaui ayarları açar · /kaui center pencereyi ortalar",
 ["resize"]="Pencereyi Boyutlandır",
 ["resizeHelp"]="Sağ alt köşeyi basılı tutup çapraz sürükle. Panel oranını koruyarak büyüyüp küçülür; boyutu ve konumu kaydedilir. Arayüz sekmesindeki ölçek ayarı da kullanılabilir.",
 ["restore"]="Önceki Değerleri Geri Getir",
 ["restoreHelp"]="Yalnızca bu panelden değiştirdiğin değerleri, kaydedilen önceki değerlerine döndürür. Modüllerin açık/kapalı durumunu değiştirmez.",
 ["saved"]="Ayarlar otomatik kaydedilir.",
 ["scale"]="Panel Ölçeği",
 ["scaleHelp"]="Yalnızca bu ayar penceresini büyütüp küçültür. Başlığından sürükleyebilirsin; konumu hatırlanır.",
 ["settings"]="KerimAnka UI’ı aç",
 ["shadowPreset"]="Koyu Gölge",
 ["soundInfo"]="Kategorileri ayrı ayrı seçebilirsin. Geniş kategoriler yararlı sesleri de kapatır.",
 ["soundNote"]="Diğer ses addonları aynı dosyaları kontrol edebilir. Aynı numarayı birden fazla addonda susturmamaya çalış.",
 ["sounds"]="Sesler",
 ["speech"]="Konuşmalı Hata Seslerini Sustur",
 ["speechHelp"]="Yeterli mana yok gibi sesli hata uyarılarını susturur. Diğer diyaloglar ayrı ayarlanır.",
 ["state"]="Modül Durumu",
 ["stop"]="Durdur",
 ["threat"]="Tehdit",
 ["ufAuras"]="Buff ve Debuff’lar",
 ["ufCast"]="Hedefin Cast Barı",
 ["ufGeneral"]="Genel ve Görünüm",
 ["ufHelp"]="Mevcut unit frame ayarını değiştirir. X yatay, Y dikey konumdur. Bağlı pet/hedefin hedefi için X/Y değiştirmek bağlantıyı ayırır. Ayarları savaş dışında değiştir.",
 ["ufIndicators"]="Durum İkonları",
 ["ufNote"]="Yeni aura/cast göstergeleri KAPALI başlar. Mevcut ayarların korunur. Yerleşik aura satır/sayı/aralık/süre ayarlarını değiştirdikten sonra yeniden yükleme gerekebilir.",
 ["ufPositions"]="Frame Konumları",
 ["ufUpdate"]="Bu kontroller için paketteki ForeverLeatherUnits güncellemesini de kur.",
 ["uf_auraCooldown"]="Aura Süre Animasyonu",
 ["uf_auraStacks"]="Aura Yığın Sayıları",
 ["uf_castFontSize"]="Büyü İsmi Yazı Boyutu",
 ["uf_castHeight"]="Cast Bar / İkon Yüksekliği",
 ["uf_castIcon"]="Büyü İkonunu Göster",
 ["uf_castWidth"]="Cast Bar Genişliği",
 ["uf_castX"]="Cast Bar X",
 ["uf_castY"]="Cast Bar Y",
 ["uf_classificationTextScale"]="Elite / Rare Yazısı Ölçeği",
 ["uf_combatIconSize"]="Combat İkon Boyutu",
 ["uf_enabled"]="Özel Unit Frame’ler",
 ["uf_happinessOffsetX"]="Mutluluk İkonu X",
 ["uf_happinessOffsetY"]="Mutluluk İkonu Y",
 ["uf_happinessSize"]="Mutluluk İkon Boyutu",
 ["uf_healthTextScale"]="Can Sayısı Ölçeği",
 ["uf_hideNative"]="Blizzard Frame’lerini Gizle",
 ["uf_leaderSize"]="Lider / Yardımcı İkon Boyutu",
 ["uf_levelOffsetY"]="Level Dikey Konumu",
 ["uf_levelTextScale"]="Level Yazısı Ölçeği",
 ["uf_locked"]="Konumları Kilitle",
 ["uf_pet.x"]="Pet X",
 ["uf_pet.y"]="Pet Y",
 ["uf_petAuraBelow"]="Pet: Auraları Frame’in Altına Yerleştir",
 ["uf_petAuraColumns"]="Pet: Satırdaki İkon",
 ["uf_petAuraGap"]="Pet: İkon Aralığı",
 ["uf_petAuraMax"]="Pet: Tür Başına Maksimum İkon",
 ["uf_petAuraSingleRow"]="Pet: Auraları Tek Satır Göster",
 ["uf_petAuraSize"]="Pet: İkon Boyutu",
 ["uf_petBuffX"]="Pet: Buff X",
 ["uf_petBuffY"]="Pet: Buff Y",
 ["uf_petBuffs"]="Pet: Buff’lar",
 ["uf_petDebuffX"]="Pet: Debuff X",
 ["uf_petDebuffY"]="Pet: Debuff Y",
 ["uf_petDebuffs"]="Pet: Debuff’lar",
 ["uf_petScale"]="Pet Frame Ölçeği",
 ["uf_player.x"]="Oyuncu X",
 ["uf_player.y"]="Oyuncu Y",
 ["uf_playerAuraBelow"]="Oyuncu: Auraları Frame’in Altına Yerleştir",
 ["uf_playerAuraColumns"]="Oyuncu: Satırdaki İkon",
 ["uf_playerAuraGap"]="Oyuncu: İkon Aralığı",
 ["uf_playerAuraMax"]="Oyuncu: Tür Başına Maksimum İkon",
 ["uf_playerAuraSingleRow"]="Oyuncu: Auraları Tek Satır Göster",
 ["uf_playerAuraSize"]="Oyuncu: İkon Boyutu",
 ["uf_playerBuffX"]="Oyuncu: Buff X",
 ["uf_playerBuffY"]="Oyuncu: Buff Y",
 ["uf_playerBuffs"]="Oyuncu: Buff’lar",
 ["uf_playerDebuffX"]="Oyuncu: Debuff X",
 ["uf_playerDebuffY"]="Oyuncu: Debuff Y",
 ["uf_playerDebuffs"]="Oyuncu: Debuff’lar",
 ["uf_powerTextScale"]="Mana / Enerji Sayısı Ölçeği",
 ["uf_pvpOffsetX"]="PvP Yatay Konumu",
 ["uf_pvpOffsetY"]="PvP Dikey Konumu",
 ["uf_pvpSize"]="PvP İkon Boyutu",
 ["uf_raidMarkerOffsetX"]="Hedef İşareti X",
 ["uf_raidMarkerOffsetY"]="Hedef İşareti Y",
 ["uf_raidMarkerSize"]="Hedef İşareti Boyutu",
 ["uf_restIconSize"]="Dinlenme (ZZZ) İkon Boyutu",
 ["uf_scale"]="Frame Ölçeği",
 ["uf_showCombo"]="Ek Rogue Kombo Puanları",
 ["uf_showPet"]="Pet Frame’ini Göster",
 ["uf_showPetHappiness"]="Pet Mutluluğunu Göster",
 ["uf_showToT"]="Hedefin Hedefini Göster",
 ["uf_target.x"]="Hedef X",
 ["uf_target.y"]="Hedef Y",
 ["uf_targetAuraBelow"]="Hedef: Auraları Frame’in Altına Yerleştir",
 ["uf_targetAuraColumns"]="Hedef: Satırdaki İkon",
 ["uf_targetAuraGap"]="Hedef: İkon Aralığı",
 ["uf_targetAuraMax"]="Hedef: Tür Başına Maksimum İkon",
 ["uf_targetAuraSingleRow"]="Hedef: Auraları Tek Satır Göster",
 ["uf_targetAuraSize"]="Hedef: İkon Boyutu",
 ["uf_targetBuffX"]="Hedef: Buff X",
 ["uf_targetBuffY"]="Hedef: Buff Y",
 ["uf_targetBuffs"]="Hedef: Buff’lar",
 ["uf_targetCastEnabled"]="Hedefin Cast Barını Göster",
 ["uf_targetDebuffX"]="Hedef: Debuff X",
 ["uf_targetDebuffY"]="Hedef: Debuff Y",
 ["uf_targetDebuffs"]="Hedef: Debuff’lar",
 ["uf_targettarget.x"]="Hedefin Hedefi X",
 ["uf_targettarget.y"]="Hedefin Hedefi Y",
 ["uf_textScale"]="İsim Yazısı Ölçeği",
 ["uf_totScale"]="Hedefin Hedefi Ölçeği",
 ["unavailable"]="Bu istemcide kullanılamıyor",
 ["units"]="Unit Frame’ler",
 ["upBuffs"]="Buff’lar",
 ["upCast"]="Örnek büyü",
 ["upControl"]="Ön İzleme Kontrolü",
 ["upControlHelp"]="Sürükleyerek ikon grubunu taşı. Fare tekerleğiyle boyutunu değiştir. Değişiklikler savaş dışında kaydedilir.",
 ["upDebuffs"]="Debuff’lar",
 ["upExamples"]="Örnek etkiler",
 ["upNote"]="Sürükle / tekerlek · Tıkla: ilgili ayar · İlk satır örnekleri",
 ["upPet"]="Pet",
 ["upPetName"]="Pet örneği",
 ["upPlayer"]="Oyuncu",
 ["upPlayerName"]="Oyuncu örneği",
 ["upTarget"]="Hedef",
 ["upTargetName"]="Hedef örneği",
 ["upTitle"]="Canlı Ön İzleme",
 ["upVisible"]="Ön İzlemeyi Göster",
 ["version"]="Sürüm 0.12.0",
 ["welcome"]="Arayüzün. Ayarların. Tek yerde.",
 ["zoom"]="Maksimum Kamera Mesafesi",
 ["zoomHelp"]="Mevcut kamera konumunu değil, maksimum uzaklaşma katsayısını değiştirir. Oyunun kabul ettiği değer sınırlı olabilir.",
 ["zoomNote"]="Kaydırıcı sınırı ayarlar. Sonrasında fare tekerleğiyle uzaklaşabilirsin.",
}

-- Native damage meter appearance.
K.locales.tr["details"]="Hasar Ölçer"
K.locales.tr["dmBlizzard"]="Blizzard"
K.locales.tr["dmDetails"]="Details Tasarımı"
K.locales.tr["dmNote"]="Oyunun mevcut hasar ölçer pencerelerini süsler. Ölçüm, satırlar, menüler ve konumlandırma oyunda kalır. Details gerekmez."
K.locales.tr["dmHelp"]="Yalnızca görünümü değiştirir ve bu karaktere kaydeder. Tasarımı kapatınca oyunun arka planı geri gelir ve bizim çerçevemiz gizlenir. Oyunun hasar ölçerini açıp kapatmaz. Değişiklikleri savaş dışında yap."
K.locales.tr["dmEnabled"]="Blizzard Ölçer Tasarımını Göster"
K.locales.tr["dmTrim"]="Dekoratif Çerçeveyi Göster"
K.locales.tr["dmTrimAlpha"]="Çerçeve Görünürlüğü"
K.locales.tr["dmBackground"]="Arka Plan Görünürlüğü"
K.locales.tr["dmPadding"]="Çerçeve Kenar Payı"
K.locales.tr["dmReady"]="Blizzard ölçeri algılandı. Tasarım mevcut pencereleri takip eder."
K.locales.tr["dmHidden"]="Oyunun hasar ölçeri kapalı. Oyun ayarlarından aç; başka bir ölçer addonu da gizlemiş olabilir."
K.locales.tr["dmUnavailable"]="Blizzard ölçer pencereleri henüz yüklenmedi veya bu istemcide kullanılamıyor. Önce oyunun hasar ölçerini aç."
K.locales.tr["dmDetailsMissing"]="İsteğe bağlı KerimAnka UI Details Tasarımı modülü yüklenmemiş. Details kullanıyorsan aşağıdan açabilirsin."

-- Experience and reputation widget.
K.locales.tr["experience"]="Deneyim ve İtibar"
K.locales.tr["xpTotal"]="Toplam"
K.locales.tr["xpLevelTime"]="Bu seviye"
K.locales.tr["xpLevel"]="Seviye"
K.locales.tr["xpRemaining"]="Kalan"
K.locales.tr["xpRate"]="XP/saat"
K.locales.tr["xpDayShort"]="g"
K.locales.tr["xpHourShort"]="sa"
K.locales.tr["xpMinuteShort"]="dk"
K.locales.tr["xpIntro"]="Yazıları bağımsız ayarlanabilen kompakt deneyim göstergesi. Aşağıdan açabilirsin. İtibar yalnızca takip edilen grupta, pet XP'si ise XP kazanabilen aktif Hunter pet'inde görünür."
K.locales.tr["xpConflict"]="ExperienceForever da açık. İki gösterge birlikte görünebilir; her birini kendi ayarından bağımsız açıp kapatabilirsin."
K.locales.tr["xpHelp"]="Ayarlar bu karaktere kaydedilir ve profillere dahildir. Ön izleme örnek veri kullanır. Görev XP'si, günlükte tamamlanmış ama teslim edilmemiş görevlerin ödülüdür; toplam bitirdiğin görev sayısı değildir. XP/saat ve kalan süre bu arayüz oturumuna göre hesaplanır; reload ile sıfırlanır. Oynama süresi oyundan gelir. Standart çubuğu gizlemek oyunun XP/itibar çubuk alanını gizler; bizim gösterge kapalıysa veya gösterecek bilgi yoksa geri gelir."
K.locales.tr["xpPreviewNote"]="Örnek veri · Seçmek için yazıya tıkla · Sürükle / fare tekerleği · Konum ve boyut anında güncellenir"
K.locales.tr["xpCompact"]="Kompakt Düzen"
K.locales.tr["xpHorizontal"]="İnce Yatay Düzen"
K.locales.tr["xpEnabled"]="Deneyim Göstergesini Aç"
K.locales.tr["xpLocked"]="Gösterge Konumunu Kilitle"
K.locales.tr["xpShowRep"]="Takip Edilen İtibarı Göster"
K.locales.tr["xpShowPet"]="Hunter Pet XP'sini Göster"
K.locales.tr["xpShowTime"]="Oynama Sürelerini Göster"
K.locales.tr["xpShowRate"]="XP/saat ve Kalan Süreyi Göster"
K.locales.tr["xpShowQuest"]="Teslime Hazır Görev XP'sini Göster"
K.locales.tr["xpShowRested"]="Dinlenmiş XP'yi Göster"
K.locales.tr["xpTrim"]="Dekoratif Çerçeveyi Göster"
K.locales.tr["xpHideNative"]="Standart XP / İtibar Çubuğunu Gizle"
K.locales.tr["xpClassColor"]="Sınıf Rengini Kullan"
K.locales.tr["xpWidth"]="Gösterge Genişliği"
K.locales.tr["xpHeight"]="Ana XP Çubuğu Yüksekliği"
K.locales.tr["xpSubHeight"]="İtibar / Pet Çubuğu Yüksekliği"
K.locales.tr["xpPlaceTop"]="Ekranın Üstüne Yerleştir"
K.locales.tr["xpPlaceMeter"]="Blizzard Ölçerinin Üstüne Yerleştir"
K.locales.tr["xpNoMeter"]="Önce Blizzard hasar ölçerini aç."
K.locales.tr["xpTextSettings"]="Yazıları Ayrı Ayrı Ayarla"
K.locales.tr["xpLabel_total"]="Toplam Oynama"
K.locales.tr["xpLabel_levelTime"]="Bu Seviyedeki Süre"
K.locales.tr["xpLabel_xp"]="Seviye ve XP"
K.locales.tr["xpLabel_remaining"]="Kalan Süre"
K.locales.tr["xpLabel_rate"]="XP/saat"
K.locales.tr["xpLabel_reputation"]="İtibar"
K.locales.tr["xpLabel_pet"]="Pet XP"
K.locales.tr["xpLabelVisible"]="Seçili Yazıyı Göster"
K.locales.tr["xpLeft"]="Sol"
K.locales.tr["xpCenter"]="Orta"
K.locales.tr["xpRight"]="Sağ"
K.locales.tr["xpTextX"]="Yazı Sağ / Sol Konumu"
K.locales.tr["xpTextY"]="Yazı Yukarı / Aşağı Konumu"
K.locales.tr["xpTextSize"]="Seçili Yazının Boyutu"
K.locales.tr["xpFontRegular"]="Ubuntu Normal"
K.locales.tr["xpFontBold"]="Ubuntu Kalın"
K.locales.tr["xpFontGame"]="Oyun Yazı Tipi"
K.locales.tr["xpResetText"]="Yazı Yerleşimini Sıfırla"
K.locales.tr["xpResetSession"]="Oturum İstatistiğini Sıfırla"

K.locales.tr["xpPanelSpace"]="Panel Ek Yüksekliği"
K.locales.tr["xpFrameSize"]="Dekoratif Çerçeve Kalınlığı"
K.locales.tr["xpBackgroundAlpha"]="Panel Arka Plan Görünürlüğü"

K.locales.tr["xpColors"]="Çubuk Renkleri"
K.locales.tr["xpColorMain"]="Ana XP Rengi"
K.locales.tr["xpColorQuest"]="Teslime Hazır Görev XP Rengi"
K.locales.tr["xpColorRested"]="Dinlenmiş XP Rengi"
K.locales.tr["xpColorRep"]="İtibar Rengi"
K.locales.tr["xpColorPet"]="Pet XP Rengi"
K.locales.tr["xpTextColor"]="Seçili Yazının Rengi"
K.locales.tr["xpChooseColor"]="Renk Seç"
K.locales.tr["xpApplyColor"]="HEX Uygula"
K.locales.tr["xpResetColor"]="Varsayılan Renk"
K.locales.tr["xpInvalidHex"]="Altı haneli renk kodu gir; örneğin #55AA77."
K.locales.tr["xpPickerUnavailable"]="Oyunun renk seçicisi kullanılamıyor. HEX kodu girerek renk seçebilirsin."

K.locales.tr["xpClassColorActive"]="Sınıf rengi açık. Özel XP rengi seçmek için sınıf rengini kapat."

K.locales.tr["mcTitle"]="Minimap Koordinatları"
K.locales.tr["mcHelp"]="Oyunun mevcut koordinat yazısını düzenler. Koordinatları oyun ayarlarından aç. Değişiklikler minimap üzerinde anında görünür. Sürükleme savaşta veya bu pencere kapanınca sona erer."
K.locales.tr["mcUnavailable"]="Bu oyun sürümünün minimap koordinat alanı bulunamadı."
K.locales.tr["mcEnabled"]="Koordinat Konumunu ve Fontunu Özelleştir"
K.locales.tr["mcX"]="Koordinat: Sağ / Sol Konumu"
K.locales.tr["mcY"]="Koordinat: Yukarı / Aşağı Konumu"
K.locales.tr["mcSize"]="Koordinat Yazı Boyutu"
K.locales.tr["mcOutline"]="Koordinat Yazısına Kontur Ekle"
K.locales.tr["mcDrag"]="Sürükleyerek Yerleştir"
K.locales.tr["mcLock"]="Konumu Kilitle"
K.locales.tr["mcReset"]="Oyunun Koordinat Görünümüne Dön"

K.locales.tr["ufPortraitCombat"]="Portrede Savaş Yazıları"
K.locales.tr["uf_portraitCombatPlayer"]="Oyuncu Portresinde Savaş Yazısı"
K.locales.tr["uf_portraitCombatPet"]="Pet Portresinde Savaş Yazısı"
K.locales.tr["uf_portraitCombatSize"]="Portre Savaş Yazısının Boyutu"
K.locales.tr["ufPortraitCombatHelp"]="Kendi veya petinin portresinde Blizzard savaş yazılarını gösterir: alınan hasar, iyileştirme ve kaçınma ya da emilme gibi sonuçlar. Kritiklerde yazı büyür. Başlangıçta kapalıdır. Hedef portresini ve karakterin çevresindeki savaş yazılarını değiştirmez."

K.locales.tr["ufQuestie"]="Questie Hedef Simgesi"
K.locales.tr["uf_questieTargetIcon"]="Hedefte Questie Simgesini Göster"
K.locales.tr["uf_questieIconSize"]="Görev Simgesi Boyutu"
K.locales.tr["uf_questieIconX"]="Görev Simgesi: Sağ / Sol Konumu"
K.locales.tr["uf_questieIconY"]="Görev Simgesi: Yukarı / Aşağı Konumu"
K.locales.tr["ufQuestieHelp"]="Questie’nin seçtiği görev simgesini hedef portresinde gösterir. Questie ve onun hedef çerçevesi simgeleri açık olmalıdır. Simge türü, tema ve görev ilerlemesi Questie’den alınır; Forever zindan kısıtlaması korunur. Konum portrenin sağ üst köşesine göredir."

K.locales.tr["ufHunterSummons"]="Hunter Geçici Çağrılar"
K.locales.tr["uf_hunterSummons"]="Aktif Hunter Çağrılarını Göster"
K.locales.tr["uf_hunterSummonSize"]="Çağrı Simgesi Boyutu"
K.locales.tr["uf_hunterSummonGap"]="Çağrı Simgeleri Arası Boşluk"
K.locales.tr["uf_hunterSummonX"]="Çağrılar: Sağ / Sol Konumu"
K.locales.tr["uf_hunterSummonY"]="Çağrılar: Yukarı / Aşağı Konumu"
K.locales.tr["ufHunterSummonsHelp"]="Falke gibi aktif geçici çağrıları Blizzard’ın totem yuvaları ve kalan süre verileriyle gösterir. Yalnızca Hunter içindir; auralardan ve kalıcı petinden ayrıdır. Ön izlemede iki örnek gösterilir. Konum oyuncu çerçevesinin sol alt köşesine göredir."

-- Independent damage-meter border edges.
K.locales.tr["dmEdgeTop"]="Üst Kenar Ayarı"
K.locales.tr["dmEdgeBottom"]="Alt Kenar Ayarı"
K.locales.tr["dmEdgeLeft"]="Sol Kenar Ayarı"
K.locales.tr["dmEdgeRight"]="Sağ Kenar Ayarı"
K.locales.tr["dmEdgeHelp"]="Pozitif değer yalnızca bu kenarı dışarı, negatif değer içeri taşır. Genel kenar payına eklenir; toplam pay sıfırın altına inmez. Savaş dışında uygulanır."

-- Optional independent minimap icon drawer.
K.locales.tr["mbTitle"]="Minimap Eklenti İkonları"
K.locales.tr["mbEnabled"]="İkonları Panelde Topla"
K.locales.tr["mbLocked"]="Panel Düğmesini Kilitle"
K.locales.tr["mbColumns"]="Satırdaki İkon Sayısı"
K.locales.tr["mbSize"]="İkon Boyutu"
K.locales.tr["mbAngle"]="Düğmenin Harita Çevresindeki Konumu"
K.locales.tr["mbRadius"]="Haritadan Uzaklık"
K.locales.tr["mbCount"]="eklenti ikonu"
K.locales.tr["mbClick"]="Sol tık: ikon paneli · Sağ tık: Sınıf Tasarımı ayarları. Kilidi kaldırınca düğmeyi harita çevresinde sürükleyebilirsin."
K.locales.tr["mbHelp"]="Minimap görünümü açık olan desteklenen eklenti ikonlarını toplar. Gizli, yalnızca fareyle gösterilen ikonlar ve görev işaretleri dışarıda kalır. Kapatınca ikonlar önceki yerlerine döner. Değişiklikleri savaş dışında yap."
K.locales.tr["mbConflict"]="MinimapButtonButton açık. İki panelin aynı ikonları taşımaması için KerimAnka paneli bekliyor. Eklenti listesinden MinimapButtonButton’ı kapatıp /reload yap."

-- Dedicated minimap page and per-icon collection preferences.
K.locales.tr["minimap"]="Minimap"
K.locales.tr["mmArtUnavailable"]="Minimap tasarım ayarları için KerimAnka UI Sınıf Tasarımı modülü yüklü olmalı. Koordinat ve ikon paneli bağımsız çalışır."
K.locales.tr["mbPreferences"]="İkon Tercihleri"
K.locales.tr["mbCollect"]="Panelde topla"
K.locales.tr["mbPreferencesHelp"]="Kapattığın ikon minimap çevresindeki önceki yerine döner; gizlenmez. Tamamen gizlemek için ilgili eklentinin minimap ayarını kullan."
K.locales.tr["mbEmpty"]="Listelenecek görünür ikon bulunamadı. İkon toplamayı aç; başka bir toplayıcı etkinse önce onu kapat."
K.locales.tr["mbClick"]="Sol tık: ikon paneli · Sağ tık: Minimap ayarları. Kilidi kaldırınca düğmeyi harita çevresinde sürükleyebilirsin."

-- Independent icon-drawer button art and size.
K.locales.tr["mbAppearance"]="Panel Düğmesi Görünümü"
K.locales.tr["mbRound"]="Yuvarlak"
K.locales.tr["mbSquare"]="Kare"
K.locales.tr["mbButtonSize"]="Panel Düğmesi Boyutu"
K.locales.tr["mbSize"]="Paneldeki Eklenti İkonlarının Boyutu"

-- Optional full-icon action range coloring.
K.locales.tr["arEnabled"]="Menzil Dışındaki Yetenekleri Renklendir"
K.locales.tr["arColor"]="Menzil Rengi"
K.locales.tr["arReset"]="Varsayılan Kırmızıya Dön"
K.locales.tr["arHelp"]="Menzili yetmeyen yeteneğin bütün ikonunu renklendirir. Kısayol yazılarının görünürlüğünden bağımsızdır. Menzile girince oyunun normal rengi geri gelir. Blizzard ve Bartender action bar’ları desteklenir; pet barı bu ayarın dışında kalır."

K.locales.tr["mbBlockedTitle"]="İkon toplama kullanılamıyor: MinimapButtonButton açık"
K.locales.tr["mbBlockedHelp"]="MinimapButtonButton aynı ikonları yönetiyor. KerimAnka ikon toplama paneli bu nedenle kapalı ve açma düğmesi kullanılamıyor. KerimAnka panelini kullanmak için eklenti listesinden MinimapButtonButton’ı kapatıp /reload yap. Harita tasarımı ve koordinatlar etkilenmez; panel tercihlerin korunur."

K.locales.tr["artSkinAncestral"]="Ata Totemleri"
K.locales.tr["artSkinElements"]="Dört Element"
K.locales.tr["shamanArtTitle"]="Shaman — Sınıf Tasarımı"
K.locales.tr["shamanArtHelp"]="Ata Totemleri varsayılandır; Dört Element alternatifini üstteki karttan seçebilirsin. Sol ve sağ kenar açıklığında artı değer dışa, eksi değer içe taşır. Yan sütunların ve ortadaki sembolün oranı korunur; yalnızca alt bağlantı şeritleri uzar. Üst şerit ayrı ayarlanabilir."
K.locales.tr["art_shamanBackingEnabled"]="Koyu Arka Paneli Göster"
K.locales.tr["art_shamanBackingAlpha"]="Arka Panel Görünürlüğü"
K.locales.tr["art_shamanRailEnabled"]="Üst Şeridi Göster"
K.locales.tr["art_shamanRailX"]="Üst Şerit Sağ / Sol Konumu"
K.locales.tr["art_shamanRailY"]="Üst Şerit Yukarı / Aşağı Konumu"
K.locales.tr["art_shamanRailWidth"]="Üst Şerit Genişliği (%)"
K.locales.tr["art_shamanRailHeight"]="Üst Şerit Yüksekliği (%)"

K.locales.tr["art_shamanLeftSpread"]="Sol Kenar Açıklığı"

K.locales.tr["art_shamanRightSpread"]="Sağ Kenar Açıklığı"

K.locales.tr["art_mageBackingEnabled"]="Koyu Arka Paneli Göster"
K.locales.tr["art_mageBackingAlpha"]="Arka Panel Görünürlüğü"
K.locales.tr["art_mageRailEnabled"]="Üst Şeridi Göster"
K.locales.tr["art_mageRailX"]="Üst Şerit Sağ / Sol Konumu"
K.locales.tr["art_mageRailY"]="Üst Şerit Yukarı / Aşağı Konumu"
K.locales.tr["art_mageRailWidth"]="Üst Şerit Genişliği (%)"
K.locales.tr["art_mageRailHeight"]="Üst Şerit Yüksekliği (%)"
K.locales.tr["art_mageLeftSpread"]="Sol Kenar Açıklığı"
K.locales.tr["art_mageRightSpread"]="Sağ Kenar Açıklığı"
K.locales.tr["artSkinMageArcane"]="Arcane — Mor Kristal"
K.locales.tr["artSkinMageFire"]="Fire — Kor Ocağı"
K.locales.tr["artSkinMageFrost"]="Frost — Kristal Mührü"
K.locales.tr["mageArtTitle"]="Mage Tasarımı"
K.locales.tr["mageArtHelp"]="Dört görünüm aynı yerleşimi paylaşır. Üst şeridi ve yan kenarları ayrı ayarlayabilirsiniz. Görünüm uzmanlığınızdan bağımsızdır."

K.locales.tr["artSkinMageAcademy"]="Büyü Akademisi — Üçlü Mühür"

K.locales.tr["art_priestBackingEnabled"]="Koyu Arka Paneli Göster"
K.locales.tr["art_priestBackingAlpha"]="Arka Panel Görünürlüğü"
K.locales.tr["art_priestRailEnabled"]="Üst Şeridi Göster"
K.locales.tr["art_priestRailX"]="Üst Şerit Sağ / Sol Konumu"
K.locales.tr["art_priestRailY"]="Üst Şerit Yukarı / Aşağı Konumu"
K.locales.tr["art_priestRailWidth"]="Üst Şerit Genişliği (%)"
K.locales.tr["art_priestRailHeight"]="Üst Şerit Yüksekliği (%)"
K.locales.tr["art_priestLeftSpread"]="Sol Kenar Açıklığı"
K.locales.tr["art_priestRightSpread"]="Sağ Kenar Açıklığı"
K.locales.tr["artSkinPriestLight"]="Işığın Mabedi — Holy / Discipline"
K.locales.tr["artSkinPriestShadow"]="Tutulma Şapeli — Shadow"
K.locales.tr["priestArtTitle"]="Priest Tasarımı"
K.locales.tr["priestArtHelp"]="İki görünüm aynı yerleşimi paylaşır. Üst şeridi ve yan kenarları ayrı ayarlayabilirsiniz. Görünüm uzmanlığınızdan bağımsızdır."

K.locales.tr["art_druidBackingEnabled"]="Koyu Arka Paneli Göster"
K.locales.tr["art_druidBackingAlpha"]="Arka Panel Görünürlüğü"
K.locales.tr["art_druidRailEnabled"]="Üst Şeridi Göster"
K.locales.tr["art_druidRailX"]="Üst Şerit Sağ / Sol Konumu"
K.locales.tr["art_druidRailY"]="Üst Şerit Yukarı / Aşağı Konumu"
K.locales.tr["art_druidRailWidth"]="Üst Şerit Genişliği (%)"
K.locales.tr["art_druidRailHeight"]="Üst Şerit Yüksekliği (%)"
K.locales.tr["art_druidLeftSpread"]="Sol Kenar Açıklığı"
K.locales.tr["art_druidRightSpread"]="Sağ Kenar Açıklığı"
K.locales.tr["artSkinDruidGrove"]="Kadim Koruluk"
K.locales.tr["artSkinDruidMoon"]="Ay Koruyucusu"
K.locales.tr["artSkinDruidWild"]="Vahşi Yürek"
K.locales.tr["artSkinDruidSeasons"]="Mevsimlerin Ahdi"
K.locales.tr["druidArtTitle"]="Druid Tasarımı"
K.locales.tr["druidArtHelp"]="Dört görünüm aynı yerleşimi paylaşır. Vahşi Yürek varsayılandır. Üst şeridi ve yan kenarları ayrı ayarlayabilirsiniz. Görünüm uzmanlıktan ve dönüşüm formundan bağımsızdır."

K.locales.tr["imBagHelp"]="Birleşik Blizzard çantası açıldığında, kullanılabilir meslek çantası ve anahtarlık yanında ayrı pencereler halinde açılır. İkonları bu pencereleri açıp kapatır. Normal çanta ikonları yalnızca kendi slotlarını gizler veya gösterir. Bagnon gibi çanta eklentileri kullanılırken bu düzenleme devre dışıdır."

K.locales.tr["imBagHelp"]="Birleşik Blizzard çantasıyla meslek çantası da yanında ayrı bir pencere olarak açılır. Meslek çantası ikonuna tıklamak bu pencereyi gizler veya gösterir; gizliyken ikon soluklaşır. Seçiminiz çantayı kapatıp açarken korunur. Anahtarlık yalnızca ikonuna tıkladığınızda açılır. Normal çanta ikonları kendi slotlarını gizler veya gösterir. Bagnon gibi çanta eklentilerinde bu düzenleme devre dışıdır."

K.locales.tr["imBagBackground"]="Çanta Şeridi Arka Planı"
K.locales.tr["imBagFrame"]="Çanta Şeridi Çerçevesi"
K.locales.tr["imBagIconBorder"]="İkonlara Siyah Kenarlık"
K.locales.tr["imBagAppearanceHelp"]="Çanta ikon şeridinin arka planı ve dekoratif kenar çizgileri ayrı ayrı kapatılabilir. Siyah kenarlık yalnızca ikonların etrafına eklenir. Boyut ve aralık ayarları meslek çantası ve anahtarlık dahil tüm çanta ikonlarına uygulanır."
K.locales.tr["mbShowTooltip"]="İkonun Üzerinde Açıklama Göster"

K.locales.tr["bsTitle"]="Çanta Kısayolu"
K.locales.tr["bsHelp"]="Çantaları açıp kapatan tek bir düğme. Varsayılan olarak görünür ve kilitlidir; ilk konumu ekranın sağ altına yakındır. Kilidi kapatıp sürükleyebilir, ardından yeniden kilitleyebilirsin. Düğmeyi gizlesen de klavye kısayolların çalışır. Standart düzende B ve Shift+B çantalar için kullanılır; aşağıda senin güncel atamaların gösterilir. Tuşlarını oyun ayarlarından değiştirebilirsin."
K.locales.tr["bsEnabled"]="Çanta Kısayolunu Göster"
K.locales.tr["bsLocked"]="Konumu Kilitle"
K.locales.tr["bsSize"]="Kısayol İkon Boyutu"
K.locales.tr["bsReset"]="İlk Konuma Döndür"
K.locales.tr["bsAllBags"]="Tüm çantalar"
K.locales.tr["bsBackpack"]="Sırt çantası"
K.locales.tr["bsUnbound"]="Tuş atanmamış"
K.locales.tr["bsDrag"]="Yerini değiştirmek için sürükle."

K.locales.tr["quests"]="Görev Takibi"
K.locales.tr["qjNativeHelp"]="Blizzard görev takipçisinin kendi görünümü, ikonları ve görev düğmeleri kullanılır. Listeye sığmayan takip edilen görevleri görmek için görev bölümünün üzerinde fare tekerleğini çevir. Questie için eski deri arka plan ve kalem tasarımı kaldırıldı."
K.locales.tr["qjScrollEnabled"]="Fare Tekerleğiyle Kaydır"
K.locales.tr["qjScrollStep"]="Kaydırma Adımı"
K.locales.tr["qjHeightHelp"]="Görev takipçisinin konumunu ve yüksekliğini oyunun Düzenleme Modu’ndan değiştir. Bu özellik görevleri otomatik takibe almaz; yalnızca Blizzard takipçisinde izlenen görevleri kaydırır. Düzenleme Modu’nda standart yerleşim geçici olarak geri gelir."
K.locales.tr["qjActive"]="Blizzard görev takibi için kaydırma etkin."
K.locales.tr["qjOtherTracker"]="Questie’nin kendi takipçisi açık. Blizzard takipçisini kullanmak için Questie ayarlarından kendi görev takipçisini kapat; Questie harita ikonlarını kullanmaya devam edebilirsin."
K.locales.tr["qjNativeWaiting"]="Blizzard görev takipçisi henüz hazır değil veya kaydırma kapalı."
K.locales.tr["qjUpdate"]="Bu sayfa Blizzard görev takipçisine kaydırma ekler; Questie tasarımı içermez."

K.locales.tr["qjGroupByZone"]="Bölgeye Göre Grupla"
K.locales.tr["qjZoneHelp"]="Görevler, büyük haritadaki görev günlüğünün bölge/kategori başlıklarına göre gruplanır. Başlıklara tıklayarak grupları açıp kapatabilirsin; görevler takipten çıkarılmaz. Gruplama için kaydırma açık olmalı. Korunan görev düğmelerinin yerleşimi savaş bitince yenilenir."
K.locales.tr["qjNativeHelp"]="Blizzard görev takipçisinin görünümü, ikonları ve görev düğmeleri korunur. Listeyi fare tekerleğiyle kaydırabilir, görevleri bölge başlıkları altında açıp kapatabilirsin. Questie gerekmez."
K.locales.tr["qjHeightHelp"]="Konum ve yüksekliği oyunun Düzenleme Modu’ndan değiştir. Yalnızca Blizzard takipçisinde izlenen görevler gösterilir. Düzenleme Modu’nda standart yerleşim geçici olarak geri gelir. Korunan düğmeler varken savaş sırasında liste güncellemesi bekletilebilir."

K.locales.tr["backingColorTitle"]="Arka Panel Rengi"
K.locales.tr["backingColorHelp"]="Butonların arkasındaki zemini değiştirir. Çerçeve ve buton kenarlıkları korunur."
K.locales.tr["backingOriginal"]="Orijinal görünüm"
K.locales.tr["backingCustom"]="Özel renk"
K.locales.tr["backingPickColor"]="Renk seç"
K.locales.tr["backingCream"]="Krem"
K.locales.tr["backingBrown"]="Kahverengi"
K.locales.tr["backingGrey"]="Antrasit"
K.locales.tr["backingBlack"]="Siyah"
K.locales.tr["backingOpacityHelp"]="Saydamlık için aşağıdaki arka panel görünürlüğü ayarını kullanabilirsin."

K.locales.tr["imBTBags"]="Bartender’ın Çanta Çubuğu (Bag Bar) açık; çanta rafı bekliyor. Bizim rafı kullanmak için yalnızca Bartender → Çanta Çubuğu → Etkin seçeneğini kapat. Action bar’ları kapatman gerekmez."
K.locales.tr["imBTMicro"]="Bartender’ın Mikro Menü (Micro Menu) bölümü açık; yalnızca bizim mikro menü düzenimiz bekliyor. Çanta rafı bundan etkilenmez. Bizim menüyü kullanmak için Bartender’da Mikro Menü bölümünü kapat; düğmeler geri gelmezse /reload yap."
K.locales.tr["imBTBoth"]="Bartender’ın Çanta Çubuğu ve Mikro Menü bölümleri açık. Bizim düzenimizi kullanmak istediğin bölümü Bartender’da kapat; action bar’lar açık kalabilir. Mikro menü düğmeleri geri gelmezse /reload yap."

K.locales.tr["readyHunterTitle"]="Hunter hazır düzeni · 1920×1080"
K.locales.tr["readyHunterHelp"]="Son Hunter görünümünü, Blizzard yerleşimini ve KerimAnka UI ayarlarını birlikte kurar. Uygulamadan önce mevcut ayarlar yedeklenir; arayüz yeniden yüklenir. Tuş atamaları değişmez."
K.locales.tr["readyUsesBT"]="Kaynak otomatik: Bartender profili kurulacak; Blizzard bar 2 ve 3 de hazır olacak."
K.locales.tr["readyUsesNative"]="Blizzard barları kullanılacak; action bar 2 ve 3 açılacak."
K.locales.tr["readyApplyHunter"]="Hunter hazır düzenini uygula"
K.locales.tr["readyMissing"]="Bu sınıf için henüz hazır düzen yok."
K.locales.tr["readyUnavailable"]="Hazır düzen için gerekli oyun ayarlarına şu anda erişilemiyor."
K.locales.tr["readyBTUnavailable"]="Bartender sürümü veya profil sistemi bu paketle uyumlu değil."
K.locales.tr["readyApplyFailed"]="Hazır düzen tam uygulanamadı. Profiller bölümündeki yedekten geri dönebilirsin."

-- First-open account introduction.
K.locales.tr["introReplay"]="Tanıtımı yeniden göster"
K.locales.tr["introWelcome"]="KerimAnka UI’a hoş geldin"
K.locales.tr["introWelcomeBody"]="Hazır sınıf düzenini kurmak için Profiller bölümünden başla. Aşağıdaki Profilleri göster düğmesine veya vurgulanan Profiller düğmesine tıkla. Tanıtımı atlayabilirsin; karakter başına yalnızca bir kez açılır."
K.locales.tr["introProfilesTitle"]="Profiller · başlangıç noktan"
K.locales.tr["introReadyBody"]="Vurgulanan sınıf düzeni, 1920×1080 yerleşimini ve görselleri kurar. Mevcut ayarlarını yedekler, tuş atamalarını korur ve arayüzü yeniden yükler. Bu açıklamayı kapatıp hazır olduğunda uygulama düğmesine bas."
K.locales.tr["introNoPresetBody"]="Bu sınıf için henüz hazır düzen yok. Buradan mevcut ayarlarını kaydedebilir veya başka karakterden uyumlu bir profil kopyalayabilirsin. Hazır sınıf düzenleri eklendikçe burada görünecek."
K.locales.tr["introSkip"]="Atla"
K.locales.tr["introGoProfiles"]="Profilleri göster"
K.locales.tr["introDone"]="Anladım"

K.locales.tr["petBarBTDisabled"]="Bartender açıkken pet barını Bartender → Begleiterleiste bölümünden etkinleştir. Arka planımız bu barı takip eder. Blizzard pet barı için Bartender'ı kapatıp /reload yap."

K.locales.tr["hunterRange_ranged"]="MENZİLDE"
K.locales.tr["hunterRange_dead"]="ÖLÜ BÖLGE"
K.locales.tr["hunterRange_melee"]="YAKIN DÖVÜŞ"
K.locales.tr["hunterRange_far"]="ÇOK UZAK"
K.locales.tr["hunterRange_close"]="ÇOK YAKIN"
K.locales.tr["hunterRange_unknown"]="MENZİL ?"
K.locales.tr["hunterAspect_cheetahText"]="Gepard aktif: Aspekti değiştir!"
K.locales.tr["hunterAspect_missingText"]="Bir aspekt seç!"
K.locales.tr["hunterTextTitle"]="Özel uyarı metinleri"
K.locales.tr["hunterTextHelp"]="Varsayılan metin arayüz dilini takip eder. Kendi yazdığın metin değişmez. Otomatik dile dönmek için alanı boşalt veya varsayılana döndür."
K.locales.tr["hunterTextReset"]="Varsayılana dön"

K.locales.tr["hunterHintPreview"]="ÖN İZLEME"
K.locales.tr["hunterHintMove"]="Taşımak için sürükle • Ayarlardan kilitle"
K.locales.tr["hunterHintRangeMove"]="Taşımak için sürükle • Sağ tık: ayarlar"
K.locales.tr["hunterRangeReady"]="Hunter Range hazır. Ayarlar: KerimAnka UI."
K.locales.tr["hunterAspectReady"]="Aspect Alert hazır. Ayarlar: KerimAnka UI."
K.locales.tr["hunterAspectUnknown"]="Aspekt bilgisi okunamıyor veya kısıtlı. Yanlış uyarı vermemek için gösterim gizlendi."

K.locales.tr["soundInfo"]="Ses ayarları karaktere özel kaydedilir; oyun ayarlarından yaptığın değişiklikler de buna dahildir. Yeni karakter oyun istemcisinin varsayılanlarıyla başlar."
K.locales.tr["soundMaster"]="Tüm sesleri sustur"
K.locales.tr["soundShortcutTitle"]="Ses kısayolu"
K.locales.tr["soundShortcutShow"]="Ses kısayolunu göster"
K.locales.tr["soundShortcutLock"]="Ses kısayolu konumunu kilitle"
K.locales.tr["soundShortcutReset"]="Ses kısayolu konumunu sıfırla"
K.locales.tr["soundShortcutTip"]="Tıkla: müzik, ortam ve tüm sesler."
K.locales.tr["soundShortcutDrag"]="Tıkla: ses menüsü. Sürükle: kısayolu taşı."
K.locales.tr["soundShortcut_music"]="Müzik"
K.locales.tr["soundShortcut_ambience"]="Ortam"
K.locales.tr["soundShortcut_all"]="Tüm sesler"
K.locales.tr["soundShortcutOn"]="Açık"
K.locales.tr["soundShortcutOff"]="Kapalı"
K.locales.tr["soundMasterHelp"]=K.locales.tr["soundInfo"]
K.locales.tr["soundShortcutShowHelp"]=K.locales.tr["soundInfo"]
K.locales.tr["soundShortcutLockHelp"]=K.locales.tr["soundInfo"]
K.locales.tr["soundShortcutResetHelp"]=K.locales.tr["soundInfo"]

K.locales.tr["imCombinedBags"]="Birleşik çantaları kullan"
K.locales.tr["imCombinedBagsHelp"]="Karaktere özel kaydedilir. Yeni karakter birleşik çantayla başlar. Oyunun ayarlarından veya çanta menüsünden yaptığın seçim de kaydedilir. Tik ve gerçek çanta düzeni birlikte uygulanır. Bagnon gibi çanta eklentileri yönetimi devralır."

K.locales.tr["qjSafetyPaused"]="Görev takipçisi ek özellikleri geçici olarak durduruldu"
K.locales.tr["qjSafetyHelp"]="Blizzard'ın kendi takipçisi çalışır. Bölgeleme ve fare tekerleğiyle kaydırma, Düzenleme Modu ve kısıtlı aura güncellemelerine taint taşıdığı için durduruldu. Kayıtlı tercihler korunur."
K.locales.tr["readyMeterStageRequired"]="Meter kurulumu reload öncesinde hazırlanmalı. Sınıf hazır düzenini yeniden uygula."
K.locales.tr["readyMeterPrepareFailed"]="Meter hazırlığı tamamlanamadı. Sıradaki profil işlemini iptal edip reload yaptıktan sonra tekrar dene."

K.locales.tr["qjNativeHelp"]="Blizzard tarafından takip edilen görevleri bölgelere ayırır ve fare tekerleğiyle kaydırır. Görev satırları ayrı bir görünümde çizilir; Blizzard’ın ortak yerleşim modülleri değiştirilmez. Göreve tıklayarak haritada açabilir, görev eşyasını yanındaki ikondan kullanabilirsin."
K.locales.tr["qjHeightHelp"]="Konumu ve yüksekliği oyunun Düzenleme Modu’ndan ayarla. Yerleşim düzenlerken standart görünüm geri gelir. Korumalı görev eşyası düğmeleri nedeniyle liste güncellemeleri ve kaydırma savaş bitene kadar bekler."

K.locales.tr["fpsTitle"]="FPS Göstergesi"
K.locales.tr["fpsShow"]="FPS Göstergesini Göster"
K.locales.tr["fpsLock"]="FPS Konumunu Kilitle"
K.locales.tr["fpsReset"]="FPS Konumunu Sıfırla"
K.locales.tr["fpsShowHelp"]="Oyunun FPS verisini gösterir. Karaktere özgü kaydedilir ve MoveAny gerektirmez."
K.locales.tr["fpsLockHelp"]="Kapatarak FPS göstergesini sol fare tuşuyla sürükleyebilirsin. Kilitliyken fare tıklamalarını engellemez."
K.locales.tr["fpsHomeHelp"]="Varsayılan konum sağda, XP ve damage meter alanının üzerindedir. Kilidi açıp sürükle; sonra tekrar kilitle. MoveAny kullanıyorsan onun FPS seçeneğini kapat. Oyunun Ctrl+R ile açılan sayacı ayrıdır."

K.locales.tr["readyRogueTitle"]="Rogue hazır düzeni · 1920×1080"

K.locales.tr["readyRogueHelp"]="Son Rogue görünümünü, Blizzard yerleşimini ve KerimAnka UI ayarlarını birlikte kurar. Uygulamadan önce mevcut ayarlar yedeklenir; arayüz yeniden yüklenir. Tuş atamaları değişmez."

K.locales.tr["readyApplyRogue"]="Rogue hazır düzenini uygula"

K.locales.tr["readyBTDeferredFailed"]="Otomatik Bartender kurulumu tamamlanamadı. Önceki profilin korundu. Profillerden sınıf hazır düzenini uygulayarak yeniden deneyebilirsin."

K.locales.tr["ftPreviewHint"]="Ön izleme - Sürükle / sağ tık: ayarlar"
K.locales.tr["ftDragHint"]="Sürükle / sağ tık: ayarlar"

K.locales.tr["art_paladinBackingEnabled"]="Koyu Arka Paneli Göster"
K.locales.tr["art_paladinBackingAlpha"]="Arka Panel Görünürlüğü"
K.locales.tr["art_paladinRailEnabled"]="Üst Şeridi Göster"
K.locales.tr["art_paladinRailX"]="Üst Şerit Sağ / Sol Konumu"
K.locales.tr["art_paladinRailY"]="Üst Şerit Yukarı / Aşağı Konumu"
K.locales.tr["art_paladinRailWidth"]="Üst Şerit Genişliği (%)"
K.locales.tr["art_paladinRailHeight"]="Üst Şerit Yüksekliği (%)"
K.locales.tr["art_paladinLeftSpread"]="Sol Kenar Açıklığı"
K.locales.tr["art_paladinRightSpread"]="Sağ Kenar Açıklığı"
K.locales.tr["artSkinPaladinAlliance"]="Alliance · Gümüş El"
K.locales.tr["artSkinPaladinHorde"]="Horde · Kan Şövalyesi"
K.locales.tr["paladinArtTitle"]="Paladin Tasarımı"
K.locales.tr["paladinArtHelp"]="İlk görünüm faction’a göre seçilir. İki görünümü de kullanabilirsin; action bar, minimap ve unit frame birlikte değişir. Üst şerit ve arka dolgu ayrı ayarlanabilir."

K.locales.tr["art_paladinBottomHeight"]="Alt Şerit Kalınlığı"

K.locales.tr["art_paladinRailHeight"]="Üst Şerit Kalınlığı"
K.locales.tr["paladinArtHelp"]="Seçili butonların dışına oturan birleşik çerçeve. Genişlik, yükseklik ve konum tüm çerçeveyi birlikte ayarlar; köşeler ayrılmaz. Üst ve alt kalınlık değiştirilebilir. İlk görünüm faction’a göre seçilir; iki görünüm de kullanılabilir."

K.locales.tr["readyPaladinTitle"]="Paladin hazır düzeni · 1920×1080"

K.locales.tr["readyPaladinHelp"]="Son Paladin görünümünü, Blizzard yerleşimini ve KerimAnka UI ayarlarını birlikte kurar. Uygulamadan önce mevcut ayarlar yedeklenir; arayüz yeniden yüklenir. Tuş atamaları değişmez."

K.locales.tr["readyApplyPaladin"]="Paladin hazır düzenini uygula"

K.locales.tr["qjQuestieTracker"]="Questie görev takipçisini kullan"

K.locales.tr["qjQuestieHelp"]="Çift takipçiyi önlemek için varsayılan olarak kapalıdır. Harita ve minimap işaretleri kullanılmaya devam eder. Değişiklik arayüz yeniden yüklendiğinde uygulanır."

K.locales.tr["qjQuestieReload"]="Questie takipçi seçimini uygulamak için arayüzü yeniden yükle."

K.locales.tr["introWelcomeBody"]="Buradan başla: Profiller bölümünü aç ve sınıfının hazır düzenini uygula.\n\nSınıf tasarımları ve ek göstergeler, bir düzen seçene veya kendin etkinleştirene kadar KAPALI başlar. Bu yönlendirme karakter başına bir kez gösterilir."

K.locales.tr["introReadyBody"]="Aşağıdaki düğmeyle sınıfının hazır düzenini uygula. 1920×1080 yerleşimi, tasarımlar ve kayıtlı ayarlar birlikte kurulur.\n\nMevcut ayarların yedeklenir, tuş atamaların korunur. Konumlar KİLİTLİ başlar. Uygulama sonrasında arayüz yeniden yüklenir."

K.locales.tr["introNoPresetBody"]="Bu sınıf için henüz hazır düzen yok.\n\nİstediğin modülleri kendin etkinleştirip düzenleyebilir veya uyumlu bir profil içe aktarabilirsin. Konumlar kilitli başlar; yalnızca taşırken kilidi aç."

K.locales.tr["introSkip"]="Kendim düzenleyeceğim"

K.locales.tr["ufMoveHelp"]="Ekrandaki unit frame’leri taşımak için Konumları Kilitle seçeneğini KAPAT; savaş dışında ALT basılıyken SOL fare tuşuyla sürükle. Bitince kilidi tekrar AÇ. Yalnızca kilidi kaldırmak sürüklemek için yeterli değildir."

K.locales.tr["introPreparedTitle"]="Kurulumu tamamlamaya hazır"

K.locales.tr["introPreparedBody"]="Düzen hazırlandı ve mevcut ayarların yedeği alındı.\n\nKurulumu tamamlamak için aşağıdaki Yeniden Yükle ve Tamamla düğmesine bas. Bu ayrı tıklama, yeniden yükleme isteğini doğrudan oyuna iletir. İptal, hazırlanan değişiklikleri geri alır."

K.locales.tr["introReload"]="Yeniden Yükle ve Tamamla"

K.locales.tr["introReadyBody"]="Aşağıdaki düğmeyle sınıfının hazır düzenini hazırla. 1920×1080 yerleşimi, tasarımlar ve kayıtlı ayarlar birlikte hazırlanır.\n\nMevcut ayarların yedeklenir, tuş atamaların korunur. Konumlar KİLİTLİ başlar. Sonraki adımda yeniden yükleyerek kurulumu tamamlarsın."

K.locales.tr["introCancel"]="Kurulumu iptal et"

K.locales.tr["artSkinWarriorAlliance"]="Alliance · Demir Öncü"
K.locales.tr["artSkinWarriorHorde"]="Horde · Demir Öncü"
K.locales.tr["artSkinWarriorIron"]="Kara Demir · Yalnızca Action Bar"
K.locales.tr["artSkinWarriorArena"]="Arena · Yalnızca Action Bar"
K.locales.tr["art_backingRailEnabled"]="Üst Şeridi Göster"
K.locales.tr["artSkinWarriorHelp"]="Alliance ve Horde seçimleri action bar, minimap, unit frame ve damage meter görünümünü birlikte değiştirir. Kara Demir ve Arena yalnızca action bar görünümünü değiştirir; son seçilen tarafı korur. İlk kullanımda karakterin tarafı seçilir."

K.locales.tr["plLegacy"]="Eski kayıt: yalnızca KerimAnka UI. Blizzard/Bartender kaydı için kaynak karaktere bir kez girip çık."
K.locales.tr["plBoth"]="KerimAnka UI + son kayıtlı Blizzard yerleşimi + Bartender profili birlikte uygulanır."
K.locales.tr["plEdit"]="KerimAnka UI + son kayıtlı Blizzard yerleşimi birlikte uygulanır."
K.locales.tr["plBT"]="KerimAnka UI + son kayıtlı Bartender profili birlikte uygulanır."
K.locales.tr["plInvalid"]="Yerleşim kaydı geçersiz. Kaynak karakterde yeni kayıt oluştur."
K.locales.tr["plBTIncompatible"]="Kayıtlı Bartender sürümü veya modülleri bu kurulumla uyumlu değil."
K.locales.tr["plBTFailed"]="Kayıtlı Bartender profili uygulanamadı. Önceki Bartender profili korundu."
K.locales.tr["pfIntro"]="Karakter kayıtları girişte, Profiller açıldığında ve çıkışta güncellenir. Kaynak karakterin son kaydedilmiş KerimAnka UI, Blizzard ve varsa Bartender düzeni birlikte uygulanır. Eski kayıtları tamamlamak için kaynak karaktere bir kez girip çık. Adlandırılmış profiller, kaydedildiği anı korur."
K.locales.tr["pfApplyWarning"]="Seçili kaydın KerimAnka UI, varsa Blizzard ve Bartender düzeni aktarılacak. Önceki düzen geri alma için saklanır. Onayladıktan sonra arayüzü yeniden yükle."
K.locales.tr["pfTransferHelp"]="Kodla aktarım yalnızca KerimAnka UI ayarlarını içerir. Blizzard/Bartender aktarımı yukarıdaki kayıtlı profil uygulamasına dahildir."
K.locales.tr["pfTransfer"]="Kodla Aktarım · Yalnızca KerimAnka UI"

K.locales.tr["plNativeName"]="Blizzard yerleşimi: %s"

K.locales.tr["readyWarriorTitle"]="Warrior hazır düzeni · 1920×1080"

K.locales.tr["readyWarriorHelp"]="Son Warrior görünümünü, Blizzard yerleşimini ve KerimAnka UI ayarlarını birlikte kurar. Uygulamadan önce mevcut ayarlar yedeklenir; arayüz yeniden yüklenir. Tuş atamaları değişmez."

K.locales.tr["readyApplyWarrior"]="Warrior hazır düzenini uygula"

K.locales.tr["ufShamanTotems"]="Şaman Totemleri"

K.locales.tr["uf_shamanTotems"]="Aktif Totemleri Göster"

K.locales.tr["uf_shamanTotemSize"]="Totem Simgesi Boyutu"

K.locales.tr["uf_shamanTotemGap"]="Totemler Arası Boşluk"

K.locales.tr["uf_shamanTotemX"]="Totemler: Sağ / Sol Konumu"

K.locales.tr["uf_shamanTotemY"]="Totemler: Yukarı / Aşağı Konumu"

K.locales.tr["ufShamanTotemsHelp"]="Blizzard’ın aktif totem göstergesini oyuncu çerçevesinin altına taşır. Simgeler, kalan süreler ve totem etkileşimleri oyun tarafından yönetilir. Oyuncuya buff vermeyen totemler de gösterilir. Ön izlemede dört örnek vardır; konum oyuncu çerçevesinin sol alt köşesine göredir."

K.locales.tr["readyShamanTitle"]="Shaman hazır düzeni · 1920×1080"

K.locales.tr["readyShamanHelp"]="Son Shaman görünümünü, Blizzard yerleşimini ve KerimAnka UI ayarlarını birlikte kurar. Uygulamadan önce mevcut ayarlar yedeklenir; arayüz yeniden yüklenir. Tuş atamaları değişmez."

K.locales.tr["readyApplyShaman"]="Shaman hazır düzenini uygula"

K.locales.tr["readyWarlockTitle"]="Warlock hazır düzeni · 1920×1080"

K.locales.tr["readyWarlockHelp"]="Son Warlock görünümünü, Blizzard yerleşimini ve KerimAnka UI ayarlarını birlikte kurar. Uygulamadan önce mevcut ayarlar yedeklenir; arayüz yeniden yüklenir. Tuş atamaları değişmez."

K.locales.tr["readyApplyWarlock"]="Warlock hazır düzenini uygula"

K.locales.tr["readyMageTitle"]="Mage hazır düzeni · 1920×1080"

K.locales.tr["readyMageHelp"]="Son Mage görünümünü, Blizzard yerleşimini ve KerimAnka UI ayarlarını birlikte kurar. Uygulamadan önce mevcut ayarlar yedeklenir; arayüz yeniden yüklenir. Tuş atamaları değişmez."

K.locales.tr["readyApplyMage"]="Mage hazır düzenini uygula"

K.locales.tr["readyPriestTitle"]="Priest hazır düzeni · 1920×1080"

K.locales.tr["readyPriestHelp"]="Son Priest görünümünü, Blizzard yerleşimini ve KerimAnka UI ayarlarını birlikte kurar. Uygulamadan önce mevcut ayarlar yedeklenir; arayüz yeniden yüklenir. Tuş atamaları değişmez."

K.locales.tr["readyApplyPriest"]="Priest hazır düzenini uygula"

K.locales.tr["readyDruidTitle"]="Druid hazır düzeni · 1920×1080"

K.locales.tr["readyDruidHelp"]="Son Druid görünümünü, Blizzard yerleşimini ve KerimAnka UI ayarlarını birlikte kurar. Uygulamadan önce mevcut ayarlar yedeklenir; arayüz yeniden yüklenir. Tuş atamaları değişmez."

K.locales.tr["readyApplyDruid"]="Druid hazır düzenini uygula"

K.locales.tr["readyConfirmWarning"]="Mevcut ayarların yedeklenerek hazır düzenle değiştirilecek ve arayüz yeniden yüklenecek. Devam etmek için onayla."

K.locales.tr["readyConfirmApply"]="Onayla ve Uygula"

K.locales.tr["readyConfirmCancel"]="Vazgeç"

K.locales.tr["pfSelectedHint"]="Bu kaydı uygulamak için düğmeye bas. Devam etmeden önce onayın istenir."

K.locales.tr["pfPendingActions"]="Ayarlar hazır. Uygulamak için Arayüzü Yeniden Yükle düğmesine bas veya bekleyen değişiklikten vazgeç."

-- Unit Frames: options, auras, summon rows, preview and help.
K.locales.tr["upElite"]="ELİT"

-- Experience and Reputation: widget, text, colors, preview and help.
K.locales.tr["xpSampleFaction"]="Örnek fraksiyon"
K.locales.tr["xpSamplePet"]="Örnek pet"

-- Profiles: saved records, transfer, undo, class presets and help.
K.locales.tr["pfStorageHelp"]="En fazla 32 adlandırılmış profil ve 64 karakter kaydı; Blizzard/Bartender yerleşimleri dahil toplam 2 MiB. Karakter kayıtları güncellenirken önceki sürümün yerini alır. Yer dolduğunda en eski karakter kayıtları kaldırılabilir; adlandırılmış profiller otomatik silinmez. Geri alma yedeği ayrı saklanır."

-- Clarify copy sources, sound preset and shared artwork color controls.
K.locales.tr["pfSourceHint"]="Seçili kayıt aktarım kaynağıdır. Buradaki karaktere özel değişiklikler kaynak kaydı değiştirmez. Ayar penceresinin görünümü karakterler arasında ortaktır."
K.locales.tr["clicksHelp"]="Önceden belirlenmiş altı yetenek hata ve tıklama sesini susturur. Sesli hata mesajları ayrı ayarlanır."
K.locales.tr["backingColorHelp"]="Sınıf tasarımında aksiyon düğmelerinin arkasındaki zemini değiştirir. Dekoratif çerçeve ve buton kenarlıkları korunur. Sınıf Tasarımı ve Bar Arka Planı bölümlerindeki kontrol aynı ayarı kullanır."

-- Custom sound muting: per-character state, honest test results and preview controls.
K.locales.tr["custom"]="Özel Ses Susturma"
K.locales.tr["customHelp"]="Sayısal ses dosyası numaralarını virgül veya boşlukla ayır. Eklenen dosya bu karakterde otomatik susturulur. Sound kit değil, dosya numarası kullanılır. Bir olay birden fazla ses dosyası kullanabilir. Dinle susturmayı geçici aşar; Sına aşmaz."
K.locales.tr["empty"]="Susturulacak özel ses eklenmedi."
K.locales.tr["soundCustomInfo"]="Numara eklemek bu karakterde susturmayı açar. Dinle, ön izleme için susturmayı geçici aşar. Sına, susturmayı koruyarak çalmayı dener; ses duyulmamalıdır."
K.locales.tr["soundMuteActive"]="Susturma etkin"
K.locales.tr["soundMuteFailed"]="Susturma uygulanamadı"
K.locales.tr["soundMuteUnavailable"]="Susturma kullanılamıyor"
K.locales.tr["soundMuteTest"]="Sına"
K.locales.tr["soundTestPlayed"]="Test oynatmayı başlattı. Ses duyuyorsan bu dosya susturulmuyor. Numarayı ve diğer ses addonlarını kontrol et."
K.locales.tr["soundTestSilent"]="Oynatma başlamadı. Bu, susturmayla uyumludur; kapalı ses kanalı veya geçersiz dosya da aynı sonucu verebilir. Dosyayı Dinle ile kontrol et."
K.locales.tr["soundAdded"]="Ses numaraları bu karaktere kaydedildi. Susturma durumunu satırlardan kontrol et."
K.locales.tr["soundRemoved"]="Özel susturma listesinden kaldırıldı. Hazır ayar veya başka bir addon aynı dosyayı susturuyor olabilir."
K.locales.tr["stopPreview"]="Ön İzlemeyi Durdur"
K.locales.tr["stopPreviewHelp"]="Yalnızca buradaki Dinle veya Sına ile başlatılan sesi durdurur. Susturmayı açıp kapatmaz."

-- Small curated sound groups; no automatic muting.
K.locales.tr["sgTitle"]="Hazır Ses Grupları"
K.locales.tr["sgHelp"]="Gruplar aynı karaktere özel ses listesini yönetir. Sustur, grubun dosyalarını ekler; Geri Aç listeden kaldırır. Ortak dosyalar diğer oyuncuların seslerini de etkileyebilir. Hiçbir grup kendiliğinden açılmaz."
K.locales.tr["sgBow"]="Yay germe"
K.locales.tr["sgBowHelp"]="Yay çekilirken çıkan üç ses çeşidi. Okun bırakılma ve hedefe çarpma sesleri kalır."
K.locales.tr["sgGun"]="Tüfek ateşi"
K.locales.tr["sgGunHelp"]="Klasik tüfek atışının üç ses çeşidi. Doldurma sesi ayrı gruptadır."
K.locales.tr["sgReload"]="Tüfek doldurma"
K.locales.tr["sgReloadHelp"]="Atış öncesindeki mekanizma ve doldurma sesleri. Ateş sesi ayrı gruptadır."
K.locales.tr["sgWand"]="Asa atışı (wand)"
K.locales.tr["sgWandHelp"]="Asanın farklı büyü türlerindeki atış başlangıç sesleri. Hedefe çarpma sesleri kalabilir."
K.locales.tr["sgEnabled"]="Susturma açık"
K.locales.tr["sgPartial"]="Kısmen susturuluyor"
K.locales.tr["sgDisabled"]="Susturma kapalı"
K.locales.tr["sgFailed"]="İşlem tamamlanamadı."
K.locales.tr["sgMuted"]="Grup özel susturma listesine eklendi."
K.locales.tr["sgRestored"]="Grubun dosyaları özel listeden kaldırıldı. Başka ayar veya addon aynı dosyaları susturuyor olabilir."
K.locales.tr["sgVerified"]="Forever içinde doğrulandı"
K.locales.tr["sgPending"]="Oyun içi doğrulama bekliyor"
K.locales.tr["sgListenHelp"]="Her tıklama sıradaki dosyayı dinletir. Tüm çeşitleri ayrı dinlemek için Dosyaları Göster seçeneğini aç."
K.locales.tr["sgUnmute"]="Geri Aç"
K.locales.tr["sgMute"]="Sustur"
K.locales.tr["sgHideFiles"]="Dosyaları Gizle"
K.locales.tr["sgFiles"]="Dosyaları Göster"

-- Community links and copy window.
K.locales.tr["communityGithubTitle"]="GitHub · Hata ve öneriler"
K.locales.tr["communityGithubHelp"]="Proje, güncellemeler ve hata bildirimleri. Bağlantıyı açıp adresi kopyalayabilirsin."
K.locales.tr["communityTwitchTitle"]="Twitch · Canlı yayınlar"
K.locales.tr["communityTwitchHelp"]="KerimAnka yayınları. Yayın dili: Türkçe. Hata bildirimleri için GitHub kullanılır."
K.locales.tr["communityPending"]="GitHub proje sayfası henüz oluşturulmadı. Adresi sonraki bir güncellemede eklenecek."
K.locales.tr["communityCopy"]="Ctrl+C ile kopyala · Esc ile kapat"
K.locales.tr["communityReloadWaiting"]="Addon değişiklikleri bekliyor · Yeniden yükle."
