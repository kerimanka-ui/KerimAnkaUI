local _,K=...
local keys={'Title','Help','Idle','Off','On','Enabled','Disabled','Unavailable','Combat','NoLast','Last','Status','Together','Received','FreedMessage','MissingMessage','Unverified','Stopped','Blocked','ActionError','CursorError','CursorRetained','Done','Freed','Missing','NoProof','Expired','Changed','NoCandidate','Waiting','NativeFailed','Armed','NoLoot','WorldLeft'}
local rows={
en={
 'Make room for more valuable loot',
 'Off by default. After a full-bag loot failure, your next normal movement or mouse input can delete one cheaper grey stack to collect an item with a higher total vendor value. Whole-stack values are compared. Quest, pinned and locked items are protected. Loot must remain open and in range. Deleted items cannot be restored by this addon.',
 'Ready','Off','On','Automatic grey replacement enabled.','Automatic grey replacement disabled.','Required game functions are unavailable.','Change this setting outside combat.','No attempt recorded this session.',
 'Last candidate: %s x%d; target: %s x%d | %s','Enabled: %s; attempts=%d deleted=%d collected=%d pending=%s | %s',
 '%s x%d deleted; %s x%d collected.','Collected %s x%d in its place.','%s x%d deleted to make room for %s.','Collection of %s was not confirmed; click the loot again if needed.',
 'Could not confirm deletion of %s x%d (target: %s). Automatic replacement disabled.','Automatic replacement disabled: %s',
 'Deletion did not finish; candidate %s x%d. %s','Action failed; deletion of %s is awaiting confirmation: %s','Cursor item verification failed','Item remained on the cursor',
 'Deletion and collection confirmed','Deleted; awaiting collection','Deleted; collection unconfirmed','Deletion unconfirmed','Pending loot request expired','Loot changed','No eligible cheaper grey stack, or space already available','Awaiting inventory confirmation','Space freed; native loot call failed','Ready; awaiting normal movement or mouse input','Attempted loot could not be identified','Left the world before confirmation'},
tr={
 'Değerli ganimet için yer aç',
 'Varsayılan olarak kapalıdır. Dolu çantada ganimet alınamadığında, sonraki normal hareket veya fare girdisinde daha ucuz bir gri yığın silinerek toplam satıcı değeri daha yüksek eşya alınabilir. Yığının tamamının değeri kıyaslanır. Görev, sabitlenmiş ve kilitli eşyalar korunur. Ganimet penceresi açık ve menzilde olmalıdır. Silinen eşya bu eklentiyle geri getirilemez.',
 'Hazır','Kapalı','Açık','Otomatik gri eşya değişimi açıldı.','Otomatik gri eşya değişimi kapatıldı.','Gerekli oyun işlevleri kullanılamıyor.','Bu ayarı savaş dışında değiştir.','Bu oturumda kayıtlı deneme yok.',
 'Son aday: %s x%d; hedef: %s x%d | %s','Etkin: %s; deneme=%d silinen=%d alınan=%d bekleyen=%s | %s',
 '%s x%d silindi; %s x%d alındı.','Yerine %s x%d alındı.','%s x%d silindi; %s için yer açıldı.','%s alındığı doğrulanmadı; gerekirse ganimete yeniden tıkla.',
 '%s x%d silindiği doğrulanamadı (hedef: %s). Otomatik değişim kapatıldı.','Otomatik değişim kapatıldı: %s',
 'Silme tamamlanmadı; aday %s x%d. %s','İşlem hatası; %s silme sonucu bekleniyor: %s','İmleçteki eşya doğrulanamadı','Eşya imleçte kaldı',
 'Silme ve alım doğrulandı','Silindi; alım bekleniyor','Silindi; alım doğrulanmadı','Silme doğrulanmadı','Bekleyen ganimet isteğinin süresi doldu','Ganimet değişti','Uygun ucuz gri yığın yok veya zaten yer var','Çanta güncellemesinden doğrulama bekleniyor','Yer açıldı; oyunun ganimet çağrısı başarısız','Hazır; normal hareket veya fare girdisi bekleniyor','Alınmaya çalışılan ganimet belirlenemedi','Doğrulamadan önce dünyadan çıkıldı'},
de={
 'Platz für wertvollere Beute schaffen',
 'Standardmäßig aus. Scheitert das Plündern an vollen Taschen, kann die nächste normale Bewegung oder Mauseingabe einen billigeren grauen Stapel löschen, um Beute mit höherem gesamten Händlerwert aufzunehmen. Ganze Stapel werden verglichen. Quest-, markierte und gesperrte Gegenstände bleiben geschützt. Das Beutefenster muss offen und in Reichweite sein. Dieses Addon kann gelöschte Gegenstände nicht wiederherstellen.',
 'Bereit','Aus','An','Automatischer Austausch grauer Gegenstände aktiviert.','Automatischer Austausch grauer Gegenstände deaktiviert.','Benötigte Spielfunktionen sind nicht verfügbar.','Diese Einstellung außerhalb des Kampfes ändern.','In dieser Sitzung wurde kein Versuch aufgezeichnet.',
 'Letzter Kandidat: %s x%d; Ziel: %s x%d | %s','Aktiv: %s; Versuche=%d gelöscht=%d erhalten=%d ausstehend=%s | %s',
 '%s x%d gelöscht; %s x%d erhalten.','Stattdessen %s x%d erhalten.','%s x%d gelöscht, um Platz für %s zu schaffen.','Die Aufnahme von %s wurde nicht bestätigt; bei Bedarf erneut auf die Beute klicken.',
 'Löschung von %s x%d nicht bestätigt (Ziel: %s). Automatischer Austausch deaktiviert.','Automatischer Austausch deaktiviert: %s',
 'Löschung nicht abgeschlossen; Kandidat %s x%d. %s','Aktion fehlgeschlagen; Löschung von %s wird geprüft: %s','Gegenstand am Mauszeiger konnte nicht bestätigt werden','Gegenstand blieb am Mauszeiger',
 'Löschung und Aufnahme bestätigt','Gelöscht; Aufnahme ausstehend','Gelöscht; Aufnahme unbestätigt','Löschung unbestätigt','Ausstehende Beuteanfrage abgelaufen','Beute geändert','Kein geeigneter billigerer grauer Stapel oder bereits Platz vorhanden','Bestätigung durch Taschenaktualisierung ausstehend','Platz geschaffen; Beuteaufruf des Spiels fehlgeschlagen','Bereit; normale Bewegung oder Mauseingabe ausstehend','Angeforderte Beute konnte nicht bestimmt werden','Spielwelt vor der Bestätigung verlassen'},
frFR={
 'Libérer de la place pour un meilleur butin',
 'Désactivé par défaut. Si les sacs pleins empêchent de ramasser un butin, le prochain déplacement ou clic normal peut supprimer une pile grise moins chère pour prendre un objet de valeur marchande totale supérieure. Les piles entières sont comparées. Les objets de quête, favoris et verrouillés sont protégés. Le butin doit rester ouvert et à portée. Cet addon ne peut pas restaurer les objets supprimés.',
 'Prêt','Désactivé','Activé','Remplacement automatique des objets gris activé.','Remplacement automatique des objets gris désactivé.','Les fonctions de jeu requises sont indisponibles.','Modifiez ce réglage hors combat.','Aucun essai enregistré pendant cette session.',
 'Dernier candidat : %s x%d ; cible : %s x%d | %s','Actif : %s ; essais=%d supprimés=%d ramassés=%d en attente=%s | %s',
 '%s x%d supprimé ; %s x%d ramassé.','%s x%d ramassé à la place.','%s x%d supprimé pour faire de la place à %s.','Le ramassage de %s n’a pas été confirmé ; cliquez à nouveau sur le butin si nécessaire.',
 'Suppression de %s x%d non confirmée (cible : %s). Remplacement automatique désactivé.','Remplacement automatique désactivé : %s',
 'Suppression inachevée ; candidat %s x%d. %s','Échec de l’action ; vérification de la suppression de %s : %s','Impossible de vérifier l’objet sur le curseur','L’objet est resté sur le curseur',
 'Suppression et ramassage confirmés','Supprimé ; ramassage en attente','Supprimé ; ramassage non confirmé','Suppression non confirmée','Demande de butin expirée','Butin modifié','Aucune pile grise moins chère admissible ou place déjà disponible','En attente de la mise à jour des sacs','Place libérée ; échec du ramassage par le jeu','Prêt ; déplacement ou clic normal attendu','Impossible d’identifier le butin demandé','Monde quitté avant confirmation'},
itIT={
 'Fai spazio al bottino di maggior valore',
 'Disattivato inizialmente. Se le borse piene impediscono il saccheggio, il prossimo movimento o clic normale può eliminare una pila grigia meno costosa per raccogliere un oggetto con valore totale dal mercante più alto. Si confrontano pile intere. Oggetti di missione, preferiti e bloccati sono protetti. Il bottino deve restare aperto e a portata. Questo addon non può ripristinare gli oggetti eliminati.',
 'Pronto','Disattivato','Attivato','Sostituzione automatica degli oggetti grigi attivata.','Sostituzione automatica degli oggetti grigi disattivata.','Le funzioni di gioco richieste non sono disponibili.','Modifica questa impostazione fuori dal combattimento.','Nessun tentativo registrato in questa sessione.',
 'Ultimo candidato: %s x%d; obiettivo: %s x%d | %s','Attivo: %s; tentativi=%d eliminati=%d raccolti=%d in attesa=%s | %s',
 '%s x%d eliminato; %s x%d raccolto.','Raccolto %s x%d al suo posto.','%s x%d eliminato per fare spazio a %s.','La raccolta di %s non è confermata; clicca di nuovo sul bottino se necessario.',
 'Eliminazione di %s x%d non confermata (obiettivo: %s). Sostituzione automatica disattivata.','Sostituzione automatica disattivata: %s',
 'Eliminazione non completata; candidato %s x%d. %s','Azione fallita; verifica dell’eliminazione di %s: %s','Verifica dell’oggetto sul cursore fallita','L’oggetto è rimasto sul cursore',
 'Eliminazione e raccolta confermate','Eliminato; raccolta in attesa','Eliminato; raccolta non confermata','Eliminazione non confermata','Richiesta di bottino scaduta','Bottino cambiato','Nessuna pila grigia meno costosa idonea o spazio già disponibile','In attesa dell’aggiornamento delle borse','Spazio liberato; raccolta del gioco fallita','Pronto; in attesa di un movimento o clic normale','Impossibile identificare il bottino richiesto','Mondo lasciato prima della conferma'},
esES={
 'Hacer sitio para botín más valioso',
 'Desactivado por defecto. Si las bolsas llenas impiden recoger botín, el siguiente movimiento o clic normal puede eliminar una pila gris más barata para recoger un objeto con mayor valor total de venta. Se comparan pilas completas. Los objetos de misión, favoritos y bloqueados están protegidos. El botín debe seguir abierto y al alcance. Este addon no puede restaurar los objetos eliminados.',
 'Listo','Desactivado','Activado','Sustitución automática de objetos grises activada.','Sustitución automática de objetos grises desactivada.','Las funciones necesarias del juego no están disponibles.','Cambia este ajuste fuera de combate.','No hay intentos registrados en esta sesión.',
 'Último candidato: %s x%d; objetivo: %s x%d | %s','Activo: %s; intentos=%d eliminados=%d recogidos=%d pendientes=%s | %s',
 '%s x%d eliminado; %s x%d recogido.','Se recogió %s x%d en su lugar.','Se eliminó %s x%d para hacer sitio a %s.','No se confirmó la recogida de %s; vuelve a pulsar el botín si es necesario.',
 'No se confirmó la eliminación de %s x%d (objetivo: %s). Sustitución automática desactivada.','Sustitución automática desactivada: %s',
 'Eliminación incompleta; candidato %s x%d. %s','La acción falló; comprobando la eliminación de %s: %s','No se pudo verificar el objeto del cursor','El objeto permaneció en el cursor',
 'Eliminación y recogida confirmadas','Eliminado; recogida pendiente','Eliminado; recogida no confirmada','Eliminación no confirmada','La solicitud de botín caducó','El botín cambió','No hay una pila gris más barata válida o ya hay sitio','Esperando la actualización de las bolsas','Sitio liberado; falló la recogida del juego','Listo; esperando un movimiento o clic normal','No se pudo identificar el botín solicitado','Se abandonó el mundo antes de la confirmación'},
ptBR={
 'Abrir espaço para saque mais valioso',
 'Desativado por padrão. Se as bolsas cheias impedirem o saque, o próximo movimento ou clique normal pode excluir uma pilha cinza mais barata para pegar um item com maior valor total de venda. Pilhas inteiras são comparadas. Itens de missão, favoritos e bloqueados são protegidos. O saque deve continuar aberto e ao alcance. Este addon não pode restaurar itens excluídos.',
 'Pronto','Desativado','Ativado','Troca automática de itens cinza ativada.','Troca automática de itens cinza desativada.','As funções necessárias do jogo não estão disponíveis.','Altere esta opção fora de combate.','Nenhuma tentativa registrada nesta sessão.',
 'Último candidato: %s x%d; alvo: %s x%d | %s','Ativo: %s; tentativas=%d excluídos=%d coletados=%d pendente=%s | %s',
 '%s x%d excluído; %s x%d coletado.','%s x%d coletado em seu lugar.','%s x%d excluído para abrir espaço para %s.','A coleta de %s não foi confirmada; clique no saque novamente se necessário.',
 'A exclusão de %s x%d não foi confirmada (alvo: %s). Troca automática desativada.','Troca automática desativada: %s',
 'Exclusão incompleta; candidato %s x%d. %s','A ação falhou; verificando a exclusão de %s: %s','Não foi possível verificar o item no cursor','O item permaneceu no cursor',
 'Exclusão e coleta confirmadas','Excluído; aguardando coleta','Excluído; coleta não confirmada','Exclusão não confirmada','A solicitação de saque expirou','O saque mudou','Nenhuma pilha cinza mais barata elegível ou já existe espaço','Aguardando atualização das bolsas','Espaço aberto; a coleta do jogo falhou','Pronto; aguardando movimento ou clique normal','Não foi possível identificar o saque solicitado','Saiu do mundo antes da confirmação'},
ruRU={
 'Освобождать место для более ценной добычи',
 'По умолчанию выключено. Если сумки полны и добычу взять не удалось, следующее обычное движение или нажатие мыши может удалить более дешёвую серую стопку ради предмета с большей общей ценой продажи торговцу. Сравнивается цена целых стопок. Задания, избранные и заблокированные предметы защищены. Окно добычи должно оставаться открытым и в пределах досягаемости. Аддон не может вернуть удалённые предметы.',
 'Готово','Выкл.','Вкл.','Автоматическая замена серых предметов включена.','Автоматическая замена серых предметов выключена.','Нужные функции игры недоступны.','Измените эту настройку вне боя.','В этом сеансе попыток ещё не было.',
 'Последний кандидат: %s x%d; цель: %s x%d | %s','Включено: %s; попыток=%d удалено=%d получено=%d ожидание=%s | %s',
 '%s x%d удалено; %s x%d получено.','Вместо этого получено %s x%d.','%s x%d удалено, чтобы освободить место для %s.','Получение %s не подтверждено; при необходимости нажмите на добычу ещё раз.',
 'Удаление %s x%d не подтверждено (цель: %s). Автоматическая замена выключена.','Автоматическая замена выключена: %s',
 'Удаление не завершено; кандидат %s x%d. %s','Ошибка действия; ожидается подтверждение удаления %s: %s','Не удалось проверить предмет на курсоре','Предмет остался на курсоре',
 'Удаление и получение подтверждены','Удалено; ожидается получение','Удалено; получение не подтверждено','Удаление не подтверждено','Время ожидания добычи истекло','Добыча изменилась','Нет подходящей более дешёвой серой стопки или место уже есть','Ожидание обновления сумок','Место освобождено; вызов получения добычи не выполнен','Готово; ожидается обычное движение или нажатие мыши','Не удалось определить запрошенную добычу','Выход из мира до подтверждения'},
zhCN={
 '为更值钱的战利品腾出空间',
 '默认关闭。背包已满导致拾取失败后，下次正常移动或鼠标操作可删除一组更便宜的灰色物品，以拾取商人出售总价更高的物品。比较的是整组物品的总价。任务物品、收藏固定物品和锁定物品受到保护。拾取窗口必须保持打开且目标仍在范围内。本插件无法恢复已删除的物品。',
 '就绪','关闭','开启','已开启自动替换灰色物品。','已关闭自动替换灰色物品。','所需游戏功能不可用。','请在脱离战斗后更改此设置。','本次登录尚无操作记录。',
 '上次候选：%s x%d；目标：%s x%d | %s','启用：%s；尝试=%d 已删除=%d 已拾取=%d 等待中=%s | %s',
 '已删除 %s x%d；已拾取 %s x%d。','已改为拾取 %s x%d。','已删除 %s x%d，为 %s 腾出空间。','尚未确认拾取 %s；如有需要，请再次点击战利品。',
 '未能确认删除 %s x%d（目标：%s）。已关闭自动替换。','已关闭自动替换：%s',
 '删除未完成；候选 %s x%d。%s','操作失败，正在等待确认删除 %s：%s','无法验证鼠标上的物品','物品仍在鼠标上',
 '已确认删除和拾取','已删除，等待拾取','已删除，尚未确认拾取','尚未确认删除','待处理的拾取请求已过期','战利品已改变','没有合适的更便宜灰色物品组，或已有可用空间','等待背包更新确认','已腾出空间，游戏拾取调用失败','已就绪，等待正常移动或鼠标操作','无法识别尝试拾取的战利品','确认前已离开游戏世界'},
}
for locale,values in pairs(rows)do
 assert(#values==#keys,'LootSpace locale key count: '..locale)
 K.locales[locale]=K.locales[locale]or{}
 for i,key in ipairs(keys)do K.locales[locale]['ls'..key]=values[i]end
end
