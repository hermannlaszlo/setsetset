# SET multiplayer – helyi javítás és tesztkörnyezet

A forrás a https://github.com/hermannlaszlo/setsetset `main` ágáról származik.
A letöltéskor az `index.html` megegyezett az éles GitHub Pages oldallal.

## Indítás

```sh
npm ci
npm run dev
```

Nyisd meg a http://127.0.0.1:8080/setsetset/ címet. Két külön
böngészőablakban/profilban ugyanazt az asztalnevet megadva lehet játszani.
Ez a kiszolgáló a valódi Supabase háttérszolgáltatást használja.

## Tesztek

```sh
npm test
npm run test:live
```

Az `npm test` két vagy három izolált Chrome-profillal fut. A WebRTC és
DataChannel valódi böngészőfunkció; csak az adatbázis és a Supabase
jelzésközvetítés helyi tesztpéldány. Az időzítési határeseteket a tesztek
kizárólag a tesztkiszolgáló által beillesztett vezérlőfelülettel állítják elő.
Az alkalmazás éles HTML-fájljaiban nincs ilyen vezérlőfelület.

Az `npm run test:live` valódi Supabase SDK-val és a meglévő háttérszolgáltatással
tesztel. Egyedi `codex-test-*` asztalt hoz létre, amelyet a végén a saját
jelzéseivel és eredményeivel együtt töröl. Más asztalt nem módosít.

A Chrome alapértelmezett helye `/usr/bin/google-chrome`; más telepítéshez
állítsd be a `CHROME_PATH` környezeti változót. A tesztfüggőségek között
projektlokális Node 22 is szerepel, ezért az `npm` parancsok nem igénylik a
rendszer Node-verziójának módosítását.

## Javítások

- A régi WebRTC-kapcsolatok későn lefutó eseményei nem törlik az új kapcsolatot.
- A jelzésüzenetek kapcsolatazonosítót kapnak; a régi válaszok és ICE-jelzések
  nem keverednek egy új kapcsolódási kísérletbe. A feldolgozás soros és deduplikált.
- Csatlakozáskor és Realtime-helyreállításkor a kliens egyszer lekéri a tárolt
  jelzéseket. Folyamatos adatbázis-lekérdezés csak jelzett Realtime-hiba esetén fut;
  észrevétlenül elveszett jelzésnél a kapcsolódási időkorlát és a relay segít.
- A WebRTC-jelzések értesítése rövid életű Broadcast-csatornán történik,
  így nem függ a jelzéstábla Postgres Changes publikációjától. Az adatbázissor
  megmarad a kapcsolódási felzárkóztatáshoz, és feldolgozás után törlődik.
- Sikertelen közvetlen WebRTC esetén automatikus Supabase Broadcast tartalék
  kapcsolat működik. A játékszabályokat mindkét útvonalon ugyanaz a host ellenőrzi.
- A vendég kártyahúzási műveletet kér; többé nem írhatja felül a teljes
  játékállapotot. A host ellenőrzi az időzítést, a gondolkodási kéréseket,
  a SET-jogot, a kimaradást és a megfigyelő szerepet.
- Beérkező jelenlét- vagy állapotfrissítés nem cseréli le a változatlan
  kártyagombokat, így az egér lenyomása és felengedése közti frissítés nem
  nyeli el a kijelölést.
- Az első kijelölés visszavonása nem indítja újra a hárommásodperces
  kezdési határidőt.
- Újracsatlakozáskor egy régebbi adatbázis-mentés nem írja felül a frissebb
  élő állapotot. A mentések sorosak, verzió- és hostazonosító-feltétellel íródnak.
- A host kiesésekor aktív játékos veheti át a szerepet, sikertelen elérhetőségi
  próba után, feltételes adatbázis-frissítéssel. Átmeneti szakadás nem indít
  azonnali hostváltást. A visszatérő régi host ellenőrzi a jogosultságát.
- Kilépéskor leállnak az újracsatlakozási és mentési időzítők, a függő kérések
  lezárulnak, és nem marad másik asztalhoz tartozó jelenlét vagy chat.
- Játék végén nem marad függő SET-privilégium az új játékban.
- A vendég időzítői a host órájához igazodnak, és azonos aktív játékosnevek
  külön pontozási nevet kapnak.

## Supabase-forgalom csökkentése (2026-09-30)

| Működés | Korábbi helyi javítás | Optimalizált változat |
| --- | --- | --- |
| Host jelzéslekérdezése stabil kapcsolatnál | 2 másodpercenként | Nincs időzített lekérdezés |
| Jelzett Realtime-hiba | Lekérdezés tovább fut | 2 másodperces tartalék lekérdezés, helyreálláskor leáll |
| Változatlan állapot periodikus mentése | Percenként kiírta | Nem írja újra a már mentett verziót |
| Host adatbázis-életjele | 15 másodpercenként | Nincs rendszeres írás; ellenőrzés csak helyreállításkor |
| Vendég játék-relay előfizetése | Belépéstől nyitva | Csak helyreállításkor vagy tartalék kapcsolatra váltáskor nyílik meg |
| Relay életjel | Mindkét fél pingelt | Host pingel, vendég válaszol: feleannyi üzenet |
| Játék végi eredmény | Újrarajzoláskor ismét menthette | A sikeresen archivált azonos eredményt nem menti újra |

Stabil, tétlen asztalnál megszűnik a host körülbelül 1800 jelzéslekérdezése
óránként. Az első sikeres állapotmentés után a percenkénti változatlan mentések
sem járnak adatbázis-írással. Ezek a kód időzítéseiből számolt értékek, nem
órás használatmérés vagy számlázási adatok.

A periodikus host-életjel adatbázis-írását is kivettük. Ez további legfeljebb
kb. 240 írást takarít meg óránként és asztalonként. Stabil, tétlen P2P-asztalnál
az első mentés után nincs rendszeres alkalmazásszintű adatbáziskérés. A Supabase
WebSocket saját kapcsolatfenntartása ettől még megmarad; ez nem nulla bájtos
hálózati forgalmat vagy a teljes számla megszűnését jelenti.

Kapcsolatvesztéskor a játékos a Broadcast tartalék útvonalon megkérdezi a hostot.
A host csak ekkor erősíti meg adatbázisban a jogosultságát, majd válaszol.
Elérhető hosthoz először új közvetlen WebRTC-kapcsolatot építünk; stabil
kapcsolatnál a próbához nyitott vendég-relay csatorna is bezárul.
Ha két, szerver által visszaigazolt kérdésre 8 másodperc alatt sem érkezik
válasz, a vendég feltételesen átveheti a szerepet. Az összehasonlítás a korábbi
hostazonosítót, állapotverziót és aktivitás-időbélyeget is ellenőrzi: közben
mentő vagy válaszoló hostot, illetve másik nyertes jelöltet nem írhat felül.
A 8 másodperc a kapcsolatvesztés felismerésén és a csatorna felépítésén felüli
várakozás. Elromlott ellenőrző csatorna vagy sikertelen küldés nem engedélyez
hostváltást. Megfigyelő továbbra sem veheti át a host szerepét.

A visszatérő régi host hálózati/Realtime-helyreálláskor, a lap előtérbe
kerülésekor és elutasított mentéskor ellenőrzi a jogosultságát. A nyertes
átvételről külön értesíti a régi hostot is. Teljes hálózati szétválásnál nincs
minden kliensre azonnali konzisztenciagarancia: az elszigetelt régi host a
helyreállásig ideiglenesen régi állapotot mutathat, de a hostazonosítóval védett
mentése nem írhatja felül az új hostét.

A változás utáni 800 ms-os mentési késleltetés megmarad. A percenkénti helyi
ellenőrzés továbbra is újrapróbálja a sikertelen mentést, a változatlan állapotot
viszont nem írja újra. A mentés és az alkalmi hostellenőrzés sorosan fut.

A host Broadcast-előfizetése megmarad, hogy fogadni tudja a közvetlen
kapcsolatot létrehozni nem tudó vendégeket. A Supabase tehát továbbra is
szükséges a szobákhoz, a kapcsolódáshoz, az állapotmentéshez és a relayhez.
A WebRTC felépítéséhez a vendég külön, átmeneti Broadcast-jelzéscsatornát
használ; ez a közvetlen kapcsolat stabilizálódása után bezárul. Az értesítések
a Realtime üzenetkeretébe beleszámítanak, játék közben viszont nincs rajta
állandó üzenetforgalom.

## GitHub Pages fájlok

Az `index.html` a szerkesztendő alkalmazás. Módosítása után:

```sh
npm run sync:pages
```

Ez frissíti a `404.html` másolatot; a név szerinti meghívási URL-ekhez is
ugyanaz a javított alkalmazás szükséges. A teszt ellenőrzi a két fájl azonosságát.
Az élesítéshez az `index.html`, `404.html` és `github-pages-config.js` tartozik
össze. Az új jelzésformátum miatt a már nyitott régi klienseket is frissíteni kell.

A javítás a meglévő adatbázissémát használja; új SQL-migráció nem szükséges.
Az eredeti `supabase_p2p_signaling.sql` a jelzéstábla beállítását dokumentálja.
A közvetlen kapcsolathoz opcionálisan saját `window.SET_RTC_CONFIG` adható meg
a konfigurációs fájlban. A tartalék továbbítás internetet és működő Supabase
Realtime szolgáltatást igényel.

A helyi javítás nem publikálja automatikusan a GitHub Pages oldalt.

## Asztalonkénti időkorlátok

Egyszer futtasd a `supabase_rules.sql` fájlt a Supabase SQL Editorban (ha a
`rules` mezőt már létrehoztad, nincs további adatbázis-módosítás).
A játék képernyőjén az **Asztalszabályok / Table rules / Tischregeln** panelen
állíthatók az idők. A host az első SET-hívás vagy kártyahúzás előtt alkalmazhat
új értékeket. Új játék indítása után a korábbi szabályok megmaradnak és ismét
módosíthatók; a vendégek csak olvashatják a panelt.

| JSON-kulcs | Jelentés | Alapérték | Tartomány |
| --- | --- | --- | --- |
| `think_seconds` | Gondolkodási idő | 30 s | 1–300 s |
| `set_seconds` | Kijelölési idő az első kártyától | 10 s | 1–120 s |
| `set_start_seconds` | Első kártya kiválasztásának határideje | 3 s | 1–30 s |
| `priority_seconds` | Elsőbbség sikeres SET után | 3 s | 1–30 s |
| `round_seconds` | Várakozás új kártyára | 30 s | 1–300 s |

Csak egész másodpercek adhatók meg. A hiányzó vagy érvénytelen tárolt értékek
az adott mező alapértékére esnek vissza, így a korábbi `{}` konfiguráció is
működik. A szóló mód a korábbi alapértékeket használja.

A szabályok a `rooms.rules` mezőben, a meglévő soros állapotmentéssel együtt
íródnak. P2P-n és relayen a teljes játékállapot részeként jutnak el a kliensekhez;
hostváltáskor is megmaradnak. Azonos beállítások alkalmazása nem indít új írást.
A pontozás és büntetések ebben a változatban továbbra is a korábbiak.
A hostellenőrzés az alkalmazás protokolljára vonatkozik; a nyilvános adatbázis
közvetlen elérésének jogosultságait továbbra is a projekt meglévő RLS-szabályai
határozzák meg.

## SET-súgó kapcsolói

Az Asztalszabályok panelen két külön kapcsoló található:

- **Lekérdezhető, hogy van-e SET**: rövid kattintásra igen/nem választ ad.
- **SET megmutatása 2 másodperces nyomásra**: egy megoldás három kártyáját
  5 másodpercre kiemeli. A kiemelés nem kijelölés és nem pontszerzés; a tábla
  megváltozásakor azonnal eltűnik. Egérrel, érintéssel és a fókuszált gombon
  Space/Enter nyomva tartásával használható. A megszakított nyomás nem fed fel
  megoldást. Ha mindkét kapcsoló ki van kapcsolva, a gomb letiltott.

JSON-kulcsok: `allow_set_query` (alapérték `true`), `allow_set_reveal`
(alapérték `false`). Ezek is a meglévő `rooms.rules` objektumba kerülnek;
nem kell új SQL-módosítás. A ✋ gomb idejét a `think_seconds` szabály állítja.

## Közös várakozás, téves lapkérés és feltöltés

- `round_wait_enabled` (alapérték `true`): a közös várakozás külön
  kikapcsolható; az időt továbbra is a `round_seconds` adja. A kikapcsolás
  megőrzi a beírt időt. A ✋ gombbal kért idő független ettől és továbbra is
  blokkolja a lapkérést. Új lap kérése nem kér automatikusan ✋ időt.
- `penalize_missed_set` (alapérték `false`): bekapcsolva a host ellenőrzi,
  van-e SET a lapkérés pillanatában. Ha van, nem oszt új lapot: az utolsó
  három asztallapot a pakli aljára teszi, és minden csatlakozott aktív játékos
  pontjából levon egyet, minimum nulláig. A megfigyelők és kilépett játékosok
  pontjai megmaradnak; nulla pontért nincs külön kimaradás. A visszavett
  lapokat nem tölti azonnal vissza. A piros keret 3 másodperc alatt 6-ot
  villan, ezalatt további lapkérés nem engedélyezett. Csökkentett mozgás
  beállításával ugyaneddig statikus piros jelzés látszik.
- SET utáni feltöltéskor először a 12. hely utáni megmaradt lapok kerülnek
  az első 12 hely üres pozícióiba. Csak ezután húzunk a pakliból. Például
  13/14/15 lapból egy SET levétele után rendre 2/1/0 új lap szükséges.
  Ha a megmaradt lapok száma még mindig 12 feletti, megtartjuk őket,
  hozzájuk nem húzunk újakat. Ez szólóban és multiplayerben is érvényes.
  A SET-sorozat alatt az üres helyek továbbra is megmaradnak; rendezés a
  sorozat végén történik. Üres pakliból természetesen nem húzunk.

A két új kapcsoló is a meglévő `rules` JSON-mezőbe kerül, új SQL nem kell.
A büntetés pont- és lapváltozását a host egy állapotverzióként menti;
a vendég saját szabályjavaslattal nem kerülheti meg az ellenőrzést.
