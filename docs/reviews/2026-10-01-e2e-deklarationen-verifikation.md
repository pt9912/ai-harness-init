# Verifikation: E2E-Deklarationen LH-FA-10, 13-17 (baaeff66)

Rolle: Verifier. Gegenstand: `e2e_abdeckung`-Deklarationen in `harness/tools/full-smoke.sh`
(Stufen 2, 3, 5, 6, 18), Anforderungen LH-FA-10, LH-FA-13 bis LH-FA-17 (LH-FA-12).
Maßstab: Stufe prüft im Ziel mindestens ein Akzeptanzkriterium (AK) und schlägt dabei mit
`FEHLER` + Exit 1 fehl. Gelesen: Stufen-Körper, `rollen_typen_im_ziel` (302), `feldliste_im_ziel`
(339), `traeger_im_ziel` (1292), `leser_und_aufraeumen_im_ziel` (1075), Lastenheft-AKs.
Stufenregion = Deklaration bis nächste Kopfzeile (Stufe 3 reicht bis 1632, schließt den Aufruf
`traeger_im_ziel` Zeile 1377 ein; Stufe 6 den Aufruf Zeile 2271). E2E selbst nicht gefahren.

| Stufe | Anforderung | Urteil | Kriterium + Fehlschlag-Zeile |
|---|---|---|---|
| 3 | LH-FA-10 | gemessen | Happy Path (Span mit Pflicht-Spalte: 1346, 1347), Ablageort `git check-ignore` (1350), Träger/Hook-Eintrag (1296-1320), Wrapper schweigt ohne Träger (1371). Nicht: „Lauf ohne Pflichtfeld fällt auf", Reproduzierbarkeit |
| 6 | LH-FA-10 | gemessen | dieselbe Funktion, Aufruf 2271 |
| 2, 5 | LH-FA-10 | teilweise | nur Rollen-Typen-Anwesenheit (311, 316), Beschreibungs-Satz, kein AK |
| 18 | LH-FA-10 | teilweise | nur skip-if-present eines Rollen-Typs (3280), Beschreibungs-Satz, kein AK |
| 3, 6 | LH-FA-13 | teilweise | Pflichtfeld-Schlüssel stehen in der Zeile (1342-1348), Feldliste deckt Zeile (385-395). Nicht: Optionalfelder, Werte Slice/Anforderung/Zweig/Stand, Token-/Cache-Felder, „leer = unbekannt" |
| 2, 5 | LH-FA-13 | teilweise | „Liste liegt im Zielrepo lesbar" (343) und Feld-Zeilen (360) |
| 18 | LH-FA-13 | nicht gemessen | prüft nur, dass der 2. Lauf Handänderung der Feldliste heilt (3287); kein AK von FA-13 |
| 2, 5 | LH-FA-14 | teilweise | geschlossene, lesbare Feldliste und Satz „Über den Bestand ist nichts zugesagt" (358); nicht: Umfang fail-closed, Ableitung statt Inhalt, Modell-Schranke, Erfassungs-Umfang |
| 2, 5 | LH-FA-15 | nicht gemessen | `rollen_typen_im_ziel` prüft `name:` je Typ-Datei (316), aber nicht die sechs Namen, nicht die Ableitung, keinen Span mit Rolle; Vorbedingung, kein AK |
| 3, 6 | LH-FA-16 | teilweise | AK Aufbewahrung: Zusage-Text (1161), `span-clean` räumt/meldet (1171-1189); fail-open nur für einen gültigen Payload (Exit 0 und stdout leer, 1325/1329). Nicht: Strom/Folgenummer (nur `"seq":1`), Lock, kaputter Payload |
| 3, 6 | LH-FA-17 | teilweise | AK Leser: Abdeckung zuerst (1128), keine Bilanz ohne Zähler (1139, 1145), Grund-Satz (1135). Nicht: Abdeckung mit Zählern, Sammelposten-Aufteilung, Berichtsgröße (kein Span mit Zählern im E2E) |

Gegenproben (Funktionen isoliert aus einer Scratchpad-Kopie gefahren, Ziel nachgebaut):
- `rollen_typen_im_ziel`, `name: planner` verfälscht: Exit 1, „FEHLER — Rollen-Typ (x) ohne
  'name: planner' im Frontmatter"; unverfälscht Exit 0. Die Meldung nennt LH-FA-15 nicht.
- `feldliste_im_ziel`, Satz „Über den Bestand ist nichts zugesagt" entfernt: Exit 1,
  „die Feldliste fuehrt eine Grenze nicht … (slice-098)"; unverfälscht Exit 0. Nennt LH-FA-14 nicht.
- Lücke: Werte-Mutation in `traeger_im_ziel`/`leser_…` ist ohne Docker-E2E nicht fahrbar
  (Ziel braucht Träger-Binary und `make`-Fragmente); Urteile dort sind Lesebefund, nicht rot gesehen.

## Zu weite Deklarationen

- Stufe 18, LH-FA-13: streichen. Kein AK der Anforderung wird geprüft.
- Stufen 2 und 5, LH-FA-15: streichen. Der AK „Rolle besetzt/abgeleitet" hat im E2E keine
  Messung; deckt `internal/span`-Test, nicht der E2E.
- Stufen 2, 5, LH-FA-14: belassen nur, wenn die Kurzbeschreibung „Feldliste und Grenz-Sätze
  liegen im Ziel" nennt; sonst streichen. Empfehlung: streichen und LH-FA-14 an Stufe 3/6 nur
  mit einem Redaktions-Fall (Payload-Inhalt darf nicht in der Zeile stehen) neu deklarieren.
- Stufe 18, LH-FA-10 und Stufen 2, 5, LH-FA-10: belassen (Rollen-Typen sind laut Beschreibung
  Teil der Emission), aber als „teilweise" lesen.
- Stufen 3, 6, LH-FA-13/16/17: belassen; „teilweise" — die Datei sagt von sich, sie sei
  eine Deklaration, die Lücken (s. Tabelle) stehen nicht in ihr.

## Offen für Planner

- Die FEHLER-Zweige nennen die Anforderung nicht (nur Slice-Kennungen, Ausnahme 1128 und 1161);
  die Rückführung Fehlschlag → Anforderung hängt am Leser.
- Die Spalte der Datei kann „gemessen" und „teilweise" nicht trennen; ein Urteil über Teil-Deckung
  bleibt beim Leser.
- Die übrigen Deklarationen (LH-FA-01, 03-09, QA) nur gelesen, nicht je Zweig geprüft (Stichprobe: Stufe 18 LH-FA-05, 3276 README-Klobber-Prüfung: gemessen).
