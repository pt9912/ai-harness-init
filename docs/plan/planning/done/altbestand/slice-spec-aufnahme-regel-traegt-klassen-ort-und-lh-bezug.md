# Slice slice-spec-aufnahme-regel-traegt-klassen-ort-und-lh-bezug: Klassen, Ort der Messprotokolle und LH-Bezug-Spalte von Spec §5 sind entschieden (Architect)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — dieselbe Feststellung wie im Slice
`slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert` (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht): keine Closure-Bedingung über die DoDs hinaus.

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (Arbeits-Bezug wie
im Vorgänger-Slice),
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) (Festlegung 1: §5 ist Zielort; **Accepted**,
wird nicht revidiert, sondern durch die neue ADR geschärft),
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) und
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (wer Norm-Artefakte
schreibt),
[`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (der ADR-Index
gehört dem Architect),
[`ADR-0071`](../../adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md) (`Proposed`; bindet die
Tabellenform von §5),
[`AGENTS.md`](../../../../AGENTS.md) §3.4 (Immutabilität), §3.5 (Senkung braucht eine ADR), §3.8
(Architect schreibt ADRs), §3.11 (Adressen in einfrierenden Artefakten).

**Berührte Spec-Stellen:**
[§Aufnahme-Regel](../../../../spec/spezifikation.md#aufnahme-regel) und
[§5](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) — die ADR nennt sie in ihrem
`Schärft:`-Feld; dieser Slice ändert sie nicht.

**Verantwortlich:** Architect (pt9912). Ausführende Rolle: **Architect**
([`AGENTS.md`](../../../../AGENTS.md) §3.8, [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md)).
Der Planner schreibt keinen ADR-Text; dieser Plan ist das Übergabe-Artefakt.

**Autor:** Planner. **Datum:** 2026-09-30.

---

## 1. Ziel und Abgrenzung


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Eine ADR, geschrieben vom Architect auf der Menge aus `slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert`,
entscheidet die Klassen des Spec-Fließtexts, den Ort der Messprotokolle und die LH-Bezug-Spalte — und
gibt dem Planner den Hinweis, nach dem er die Umbau-Slices schneidet.

**Zu entscheiden — Fragen an den Architect** (der Planner beantwortet keine, er benennt die Kanten):

1. **Klassenraster.** Arbeitshypothese des Auftraggebers: Festlegung · Begründung · Messprotokoll.
   Der Vorgänger-Slice führt zwei Zeilen mehr: *Abweichung von der Baseline* (Aufnahme-Regel Zeilen 20
   bis 23 weist sie ins Konventionsdokument, die §5-Einleitung führt sie hier; Widerspruch innerhalb der
   Spec, betrifft rund 18 KB; der Adaptions-Eintrag [`MR-021`](../../../../harness/conventions.md#mr-021)
   ist bei der Planung nicht gelesen) und *passt in keine*. Die fünf Kommentar-Klassen aus
   [`AGENTS.md`](../../../../AGENTS.md) §3.7 passen nach Befund des Planners nicht als Raster.
   *Ergänzung aus dem Klassifikationsbericht des Vorgänger-Slice* (Zeitdokument unter `docs/reviews/`,
   Klassenverteilung in seinem §2): Klasse `d` und Klasse `e` tragen je einen erheblichen Anteil des
   Fließtexts; Klasse `e` bezeichnet die Spec selbst als unbewacht. Der Bericht markiert Grenzfälle
   und entscheidet keinen — die Zuordnung jedes markierten Grenzfalls urteilt der Architect am
   Wortlaut. Die Prozess-Konventionen des Fließtexts (Einheiten `U09`, `U10`, `U13`, `U15` des
   Berichts) sind gegen die Klassen zu halten.
   **Auftraggeber-Frage, die der Architect stellt und nicht beantwortet:** Gehört die Abweichung von
   der Baseline in die Spezifikation ([`MR-021`](../../../../harness/conventions.md#mr-021)) oder ins
   Konventionsdokument (Aufnahme-Regel, Zeile 21)? Die Spec widerspricht sich hier selbst; die
   Antwort entscheidet, ob Klasse `d` eine Klasse der Spec bleibt.

   *Messung zu dieser Frage* (Planner, Stand vendored `v6.13.0`; „Konventionsdokument" ist
   [`harness/conventions.md`](../../../../harness/conventions.md) samt dem Eintrags-Verzeichnis
   `harness/conventions/`, dem Adaptions-Block). Ausgangspunkt der Menge:
   `grep -n 'Sechs erklärte Abweichungen' spec/spezifikation.md`; die Nummern sind die der Spec.

   **(a) Die sechs erklärten Abweichungen und die Regel, der die Spec sie zuordnet.** Die Zuordnung
   (Spalte 3) ist die der Spezifikation, **nicht gegengeprüft**; Spalte 4 ist gemessen mit
   `grep -n '' .harness/baseline/v6.13.0/regelwerk/modul-15-observability.md`.

   | Nr. | Abweichung | Regel des Moduls 15 (laut Spec) | Regelwerk, Zeile |
   |---|---|---|---|
   | 1 | Cache-Status unerreichbar | Pflicht-Minimum | Z. 34 |
   | 2 | PR-Nummer steht nicht im Span, `branch`/`commit` schon | Mindestfelder eines Tool-Call-Spans | Z. 33 |
   | 3 | `agent_role` durchweg leer | Pflicht-Minimum | Z. 34 |
   | 4 | Altbestände werden nicht entfernt | keine Modul-Regel; Entscheidung des Repos über Aufbewahrung | — (Z. 36–37: Emissions-Pfad inkl. Aufbewahrung ist Repo-Entscheidung) |
   | 5 | Hintergrund-Lauf ohne Verbrauchs-Achse | Token-Attributions-Regeln | Z. 39–49 (Summe je Rolle Z. 41–45, Sammelposten Z. 46–49) |
   | 6 | Haupt-Kontext ohne Zahl | Token-Attributions-Regeln | Z. 39–49 |

   Z. 34 erlaubt die Abweichung vom Pflicht-Minimum ausdrücklich mit Begründung („jede Abweichung
   davon begründest du"). Ob das für 2, 5 und 6 ebenso gilt, ist **ungeprüft**: Z. 33 und Z. 41–49
   enthalten keinen Abweichungs-Satz. Die Cache-Counter-Regeln (ab Z. 51) nennt die Spec für keine
   der sechs.

   **(b) Abgleich gegen die vom Werkzeug emittierte Feldliste** (`internal/span/fieldlist.go`: die
   Feldtabelle `SchemaNotes` und die Sätze `limitAgentGuard`, `limitCounters`, `limitStore`; das Zielrepo
   bekommt sie als werkzeug-erzeugtes Dokument über denselben Einstiegspunkt wie dieses Repo). Gelesen:
   die Datei ab Zeile 60 und die Anfangsabsätze der sechs Abweichungen.

   | Nr. | Deckung | Was die Feldliste sagt / nicht sagt |
   |---|---|---|
   | 3 | gedeckt (Mechanismus) | `limitAgentGuard`: `agent_role` besetzt sich, wenn `agent_type` eine der sechs kanonischen Rollen nennt; „leer heißt unbekannt, nie rollenlos". Nicht gedeckt ist die Messung „heute durchweg leer". |
   | 5 | gedeckt | `limitCounters`: Zähler erreichen eine Zeile nur, wenn das Werkzeug sie mitliefert; ein Hintergrund-Lauf liefert sie nicht. |
   | 1 | teilweise | `limitCounters` deckt „Zähler nur, wenn mitgeliefert"; nicht die Unterscheidung Haupt-Kontext (dauerhaft) / Subagent (seit der Vordergrund nicht mehr anforderbar ist). |
   | 6 | teilweise | wie 1; dass der Haupt-Kontext gar keine Zahl trägt, steht nicht dort. |
   | 2 | teilweise | `branch`, `commit` stehen als Felder (Abgeleitet aus dem git-Zustand); dass die PR-Nummer bewusst fehlt und warum, steht nicht dort. |
   | 4 | nicht gedeckt | `limitStore` betrifft Vertraulichkeit des Bestands, nicht Aufbewahrung; `span-clean` erscheint in der Feldliste nicht (`grep -n -i 'span-clean\|aufbewahr' internal/span/fieldlist.go` liefert nichts). Der Vertrag dazu ist ein ausdrückliches Aufräum-Kommando ([`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren), Aufbewahrung). |

   Korrektur an der Vorab-Zuordnung des Auftrags: keine; zu 4 ist ergänzt, dass das emittierte
   Makefile-Fragment `span-clean` führt (`grep -n 'span-clean' internal/emit/baumaussage.go`), die
   Feldliste es aber nicht nennt. **Nicht geprüft:** der gerenderte Dokument-Text im Zielrepo (nur die
   Quelle im Code gelesen); die Wortlaut-Deckung jenseits der genannten Sätze; ob die Tests in
   `internal/emit/` die Sätze binden.

   **(c) Fragen an den Architect, die daraus folgen.**
   - Für **jede** der sechs Abweichungen: bleibt die Aussage als Festlegung in der Spezifikation (ohne
     Messprotokoll) · wandert sie in die emittierte Feldliste (dann Zielrepo-relevant, Code-Änderung,
     eigener Slice) · wird sie ein Eintrag im Adaptions-Block (Abweichung von einer Baseline-Regel;
     [`MR-021`](../../../../harness/conventions.md#mr-021) ist dafür zu überholen,
     [`MR-032`](../../../../harness/conventions.md#mr-032)) · oder entfällt sie? Abweichung 4 kann nach
     (a) keine Baseline-Regel-Abweichung sein; Deckung nach (b) gibt es für sie nicht.
   - Der Widerspruch zwischen der Aufnahme-Regel (Zeile 21: die Abweichung von der adoptierten Baseline
     gehört ins Konventionsdokument) und [`MR-021`](../../../../harness/conventions.md#mr-021), das die
     sechs Abweichungen nach §5 weist (`grep -rn 'erklärten' harness/conventions/ | grep -c 'Abweichungen'` → **1**, Stand dieser Messung, keine Erwartungszahl): welcher
     Text gilt, und welcher wird angepasst (ADR gegen Eintrag; ein Eintrag wird nicht überschrieben).
   - **Rückmeldung des Kurses zu Modul 15 — Eingabe, keine Bestätigung** (der Kurs hat die
     Spezifikation dieses Repos ausdrücklich nicht gelesen). Sachverhalt: Das Pflicht-Minimum
     (`modul-15-observability.md` Z. 34, vendored `v6.13.0`) ist eine **Schema-Forderung**;
     „Abweichung" heißt dort, ein Minimum-Feld nicht ins Schema aufzunehmen oder optional zu machen
     und das zu begründen. Ob die Quelle den **Wert** liefert, ist eine getrennte Frage: Ein nicht
     gelieferter Wert ist nach dem Wortlaut keine Abweichung vom Schema; das Feld bleibt Pflicht, der
     Wert ist ausdrücklich „unbekannt". Der Kurs sieht darin eine Lücke des Moduls und hält eine
     eigene Kennzeichnung „Quelle liefert das Feld nicht" statt „Abweichung" für richtig.
     *Folge für diese Frage — Anwendung, nicht geprüft, dem Architect zur Prüfung:* 3, 5 und 6
     betreffen den Wert und wären im Sinne des Moduls keine Abweichungen (die Feldliste sagt, Pflicht
     heiße: das Feld steht in jeder Zeile, auch leer). Fundstelle des Wortlauts:
     `grep -n 'heißt: das Feld steht in jeder Zeile' internal/span/fieldlist.go` → Zeile 188 (im
     Quelltext mit Markdown-Sternen, `**Pflicht** heißt …`; ein Muster `Pflicht heißt` verfehlt ihn).
     Der Satz gehört zur Konstante `fieldListHead` (Zeile 160), die `span.FieldList` schreibt
     (`grep -n 'WriteString(fieldListHead)' internal/span/fieldlist.go`); `internal/emit/fieldlist.go`
     schreibt deren Ausgabe **verbatim** ins Zielrepo (Kopfkommentar dort: „VERBATIM: geschrieben wird,
     was span.FieldList liefert"). **Nicht geprüft:** ein gerendertes Dokument im Zielrepo.
     1 und 2 wären mögliche echte Schema-Abweichungen: 1, weil die Cache-Zähler in der Spezifikation
     als `Optional` stehen (Tabellenzeile `SPEC-024`, `grep -n 'SPEC-024' spec/spezifikation.md`
     → Zeile 117, Spalte Pflicht = `Optional`); 2, weil die PR-Nummer nicht im Schema steht und
     `branch`/`commit` an ihrer Stelle stehen. 4 bleibt Festlegung des Repos ohne Modul-Bezug.
     Ob dieses Repo die Bezeichnung „Quelle liefert das Feld nicht" bis zu einer Modul-Änderung als
     eigene Wortwahl führt, entscheidet der Architect.

   **Auftraggeber-Setzung zu Frage 1, dem Architect zur Ausführung und Prüfung** (kein Norm-Text):
   Nicht alle sechs Abweichungen werden Adaptions-Einträge.
   - **3, 5, 6** betreffen nach der Rückmeldung des Kurses den Wert („unbekannt") und sind im Sinne des
     Moduls keine Abweichung. Die Aussage zur Verfügbarkeit gehört in die **emittierte Feldliste**
     (Code-Änderung, eigener Slice, ohne Kennung — der Planner schneidet ihn nach der ADR; er deckt 1, 2
     und 6, soweit dort Aussagen fehlen, Tabelle (b) Zeilen 1, 2, 6 „teilweise"). In der Spezifikation
     bleibt je Fall **eine kurze Festlegung als Tabellenzeile** (Feld Pflicht; Wert „unbekannt", wenn die
     Quelle ihn nicht liefert), ohne Messung und ohne „heute durchweg leer".
   - **1** (Cache-Zähler stehen als `Optional`, `SPEC-024`) und **2** (PR-Nummer nicht im Schema,
     `branch`/`commit` an ihrer Stelle) sind **mögliche** echte Schema-Abweichungen: höchstens für diese
     beiden kommt ein Adaptions-Eintrag in Frage, **erst nach Prüfung durch den Architect**;
     [`MR-021`](../../../../harness/conventions.md#mr-021) wäre dann zu überholen
     ([`MR-032`](../../../../harness/conventions.md#mr-032)).
   - **4** (Altbestände) ist eine Festlegung des Repos und bleibt eine Tabellenzeile in der
     Spezifikation.
   - **Der Architect prüft noch:** ob die Feldliste alle Punkte trägt (Tabelle (b) ist nicht Abweichung
     für Abweichung gegen den Wortlaut gelesen); ob 1 und 2 tatsächlich „echt" sind (die Einstufung ist
     vorläufig); ob „Quelle liefert das Feld nicht" als eigene Kennzeichnung geführt wird.
2. **Ort, Konsument und Form der Messprotokolle.** *Auftraggeber-Setzung, dem Architect zur Ausführung
   und Prüfung:* **kein neuer Ordner.** Ort für datierte Messungen ist `docs/reviews/`
   (Zeitdokument-Ort). Wo eine Messung als Beleg gebraucht wird (ADR, Sensor), steht sie dort oder in
   der ADR; der Rest entfällt (git hält ihn). Ob ein Klasse-`c`-Block einen Konsumenten hat, prüft der
   Umbau je Block. Randbedingungen, die die ADR beantworten muss: ein **Konsument** (sonst kein
   Artefakt, [`MR-025`](../../../../harness/conventions.md#mr-025)); **Form mit Kommando und Ausgabe**;
   die Spec darf **nicht dorthin zeigen** (die `matrix`-Klasse `spec-straten` verbietet den Weg nach
   außen), und kein eingefrorenes Dokument nennt ein wanderndes Artefakt als Pfad
   ([`AGENTS.md`](../../../../AGENTS.md) §3.11). Eine Erweiterung der `exempt-paths` in der
   `.d-check.yml` entfällt mit dieser Setzung: `docs/reviews/**` ist bereits ausgenommen
   (`grep -n 'docs/reviews' .d-check.yml` → Zeilen 311, 327, 331, 343, 374, 387), also keine Senkung
   nach [`AGENTS.md`](../../../../AGENTS.md) §3.5. *Nicht geprüft:* welches Modul jede der Zeilen ausnimmt und ob
   der Ausschluss für jedes Modul gilt, das ein Messprotokoll berühren könnte.
   *Ergänzung aus dem Bericht:* das Messprotokoll mischt vier Aussagearten; die ADR sagt, ob alle vier
   denselben Ort bekommen. [`MR-021`](../../../../harness/conventions.md#mr-021) nennt bereits ein
   Zeitdokument unter `docs/reviews/` als Ort einer Messreihe — Bestand, an dem die Option gemessen
   wird, keine Vorentscheidung.
3. **LH-Bezug-Spalte.** Name (Auftraggeber: „Präzisiert LH-…“), Form der Fundstelle (Anker-Link, die
   link-policy verlangt ihn), Behandlung einer Zeile ohne Lastenheft-Element (benannte Spec-Lücke; eine
   LH-Änderung wäre ein Change Request nach [`MR-015`](../../../../harness/conventions.md#mr-015), nicht
   Sache der Spec), und ob §5 als Ganzes ein Lastenheft-Element präzisiert.
   *Ergänzung aus dem Bericht:* Kandidaten mit Bindungsstufe (`einzeln` / `pauschal` / `nahe`) und die
   Zeilen „kein LH gefunden“ (benannte Spec-Lücke) stehen im LH-Vorschlag des Berichts. Die Kandidaten
   tragen einen Ebenen-Vorbehalt: [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) beschreibt das Verhalten im **Zielrepo**, die Spec-Zeile
   teils das **dieses** Repos — die ADR entscheidet die Ebenen-Passung der Bindung.
   **Auftraggeber-Setzung, dem Architect zur Ausführung und Prüfung:** kein Change Request je Zeile.
   Die zehn Zeilen ohne LH-Bezug stellt der Bericht fest —
   `sed -n '470,520p' <Klassifikationsbericht> | grep -E '^\| .SPEC-[0-9]+. .*kein LH gefunden' | grep -oE 'SPEC-[0-9]+'`
   → `SPEC-001`, `002`, `003`, `008`, `014`, `016`, `019`, `026`, `027`, `028` (Bericht: §6.2, Zeilen
   470 bis 520; Zeitdokument unter `docs/reviews/`, Kennung
   `slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert`). Der Architect prüft **zuerst**, ob
   [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) jede dieser Zeilen
   als **Präzisierung** trägt (Ebenen-Passung: [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) fordert den Träger im Zielrepo, der Bericht nennt
   die Ebenen-Frage offen). Nur wo eine Zeile eine Anforderung setzt, die im Vertrag fehlt, ist es ein
   Change Request nach [`MR-015`](../../../../harness/conventions.md#mr-015) — dann **gebündelt**,
   Entscheidung des Auftraggebers; der Architect benennt die Lücke und schreibt keine Anforderung. Wo
   keine Anforderung dahintersteht, bleibt es eine **benannte Lücke**, kein Change Request.
   **Offen:** der Inhalt der zehn Zeilen ist vom Planner nicht vollständig gelesen; der Bericht prüft sie
   nur gegen Schlüsselwörter im Lastenheft (Verifikationsbericht, Zeile 76).
4. **Wohin die Begründungen (Klasse b) gehen:** eine Sammel-ADR zu §5 oder je Umbau-Block eine
   schärfende ADR. Das entscheidet, ob ein Umbau-Slice einen Architect-Schritt in der Mitte hat.
5. **Wer §5 schreibt.** `slice-151-spec-straten-haben-eine-schreibende-rolle` (offen) führt die Frage;
   bisher haben Implementer-Läufe §5 geändert. Die ADR darf sie mitentscheiden, muss nicht.
6. **Bindungs-Bilanz.** Die Nennung eines Wächters in der Spec ist unbewacht (Kopf von §5); ob der
   Umbau einen Sensor braucht, oder ob `slice-feldabdeckung-existenz-sensor` ihn trägt — und wie sich
   dessen Tabellenparser zur neuen Spalte verhält.
7. **Das emittierte Gegenstück** (die Spezifikations-Vorlage im Emit-Baum) ist ein anderer
   Vorgang (Dogfood vs. emittiert); die ADR sagt, ob er entsteht.
8. **Zwei Zeiger ohne Gegenstück in eingefrorenen ADRs.**
   [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (Zeile 214) und
   [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (Zeilen 72 und 652) erwarten
   eine Spec-Passage, die es nicht gibt (Randbefunde im Klassifikationsbericht des Vorgänger-Slice).
   Beide sind `Accepted` und unveränderlich ([`AGENTS.md`](../../../../AGENTS.md) §3.4); die ADR sagt,
   ob eine Folge-ADR sie auffängt oder die Lücke als bekannt stehen bleibt.
9. **Schnitt der Umbau-Slices.** Der Bericht schneidet den Fließtext feiner als der Plan des
   Vorgänger-Slice (die Abweichung steht in seinem §1); ob die Umbau-Slices dem Einheiten-Schnitt des
   Berichts folgen, hält die ADR im Schnitt-Hinweis für den Planner fest.

10. **Der Abschnitt „Bewacht" der Spezifikation** (`grep -n 'Bewacht — die Zusicherungen' spec/spezifikation.md`
    → Zeile 591; Klasse-e-Anteil). *Auftraggeber-Setzung:* Der Abschnitt gehört als Prosa nicht in
    die Spezifikation. *Vorschlag, dem Architect zur Entscheidung:* die Wächter-Prosa (Test- und
    Fallnamen) entfällt; jede Zusicherung, die dort steht und in keiner Tabellenzeile vorkommt, wird
    eine Zeile mit SPEC-Kennung und Sensor-Spalte; wo eine Zusicherung keinen Wächter hat, ist das
    eine benannte Lücke ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Die Sensor-Spalte ist eine
    Abweichung von der Vorlagen-Form nach [`MR-021`](../../../../harness/conventions.md#mr-021); ob
    auch sie fällt, ist eine weitere Entscheidung gegen diesen Eintrag. Vor dem Umbau misst ein
    Implementer, welche Zuordnungen nur im Fließtext stehen und ob der Test die Zusicherung in Namen
    oder Kommentar trägt — sonst geht die Zuordnung als Kommentar an den Test, statt verloren.
    *Gegen-Sachverhalt:* Kein Sensor hält die Richtung Spezifikation → Wächter; der Verifier des
    Klassifikations-Slice hat gemessen, dass kein Test und kein Sensor den Wortlaut der
    Spezifikation liest.
11. **Rest der Klasse e nach dem Umbau, und ein möglicher Ort unter `docs/`.** Was nach dem Umzug
    der Zusicherungen in Tabellenzeilen und dem Wegfall der Wächter-Prosa aus Klasse e bleibt
    (Prozess-Konventionen `U09`, `U10`, `U13`, `U15` des Berichts: START-KONVENTION, *DASS
    Rollen-Arbeit als Rolle läuft*), ist kein Wert, Feld oder Schranke. Mögliche Orte, dem Architect
    zur Wahl: ein `MR`-Eintrag · ein Abschnitt in [`harness/README.md`](../../../../harness/README.md) ·
    ein Dokument unter `docs/user/` (Rang 6 der Source Precedence, kein neuer Rang; die Nutzerdoku
    trägt nur den Ist-Zustand, also geltende Regel statt Messung; die Spezifikation darf dorthin
    nicht zeigen, die `matrix`-Klasse `spec-straten` verbietet den Weg nach außen). Jeder Ort ist
    Norm-Text und damit Architect-Arbeit. Sinnvoll nur bei mehreren Blöcken derselben Art; der Rest
    wird erst nach dem Umbau gemessen (Implementer-Messung im Umbau-Slice).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein ADR-Text vom Planner.** Der Rollenwechsel braucht ein Artefakt, keine Vorwegnahme
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8); die Fragen oben sind die Übergabe.
- **Kein Edit an `spec/`.** Die Norm ist die ADR; der Spec-Text folgt im Slice
  `slice-spec-tabellen-tragen-die-lh-bezug-spalte` und in den Umbau-Slices — sonst schreibt derselbe
  Lauf Norm und Bestand.
- **Keine Klassifikation einzelner Absätze.** Sie ist die Eingabe aus dem Vorgänger-Slice; die ADR
  nennt die Menge (Zahl mit Kommando), keine Zeile.
- **Kein emittiertes Gegenstück** (Frage 7) — anderer Vorgang, Tool-Ebene.
- **Keine Code-Änderung an der emittierten Feldliste** (Frage 1, Setzung) — Tool-Ebene, anderer
  Vorgang; der Planner schneidet den Slice nach der ADR, eine Kennung existiert noch nicht.
- **Kein Change Request und kein neuer Ordner für Messprotokolle** (Fragen 2 und 3, Setzungen) — ein
  Change Request ist Entscheidung des Auftraggebers und nur gebündelt, wo eine Zeile eine im Vertrag
  fehlende Anforderung setzt; Messungen gehören nach `docs/reviews/` oder in die ADR.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [x] **Liefer-Punkt 1 — die ADR.** *(bedingt bestätigt, Einschränkung in §7)* Sie liegt vor, `Schärft:` nennt die Aufnahme-Regel und §5 als
      Link, und sie beantwortet die Fragen 1 bis 3 mit Festlegungen (4 bis 11: beantwortet oder als
      offen mit Trigger benannt). Ihre Fitness Function nennt **je Festlegung, was rot werden muss**;
      die Rot-Beobachtung liegt im Bericht des Verifiers. Eine Festlegung ohne benanntes
      Gegenbeispiel gilt als nicht fertig ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [x] **Liefer-Punkt 2 — der ADR-Index** trägt die Zeile (derivativ, Architect,
      [`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update entfällt: die ADR ändert keinen öffentlichen Vertrag; der Spec-Text folgt in den
      Folge-Slices.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)


Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| ADR unter `docs/plan/adr/` (Architect) | neu | Liefer-Punkt 1; Kopf nennt den Bericht des Vorgänger-Slice bei seiner **Kennung**, nicht als Pfad (§3.11: er wandert) |
| `docs/plan/adr/README.md` (Architect) | update | Liefer-Punkt 2, derivativ |

- Eingang: der Bericht des Vorgänger-Slice (Klassifikationstabelle, Zeiger-Inventar, LH-Vorschlag).
  Grenzfälle daraus urteilt der Architect selbst am Wortlaut.
- Die Zeiger-Inventar-Zeilen bestimmen, welche Passagen-Namen („Abweichung 1“, „Lesevorschrift“, …) die
  Umbau-Slices als Namen erhalten oder nachziehen müssen; die ADR hält das als Folgepflicht fest.

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): der Slice `slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert`
liegt in `done/` und sein Bericht ist gelesen (die Menge steht, nach der entschieden wird).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Fragen 1 bis 3 nicht in einer
  Review-Sitzung prüfbar sind — dann eine ADR je Frage-Gruppe (Klassen · Ort · Spalte).
- `in-progress` → `open` (blockiert — Carveout?): wenn der Bericht des Vorgängers Klassen zeigt, die
  keines der Raster trägt (Klasse „passt in keine“ überwiegt) — dann geht der Vorgänger zurück, nicht
  die ADR vor.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) die ADR ist `Accepted` **und** ihr ADR-Index-Eintrag steht;
(2) `make gates` grün mit Stempel, der den Arbeitsbaum deckt. Dazu der Lerneintrag (geschärfte Regel ·
neuer Sensor · benannte Spec-Lücke). Den Abschluss schreibt der Planner in frischem Kontext
([`AGENTS.md`](../../../../AGENTS.md) §3.10). Bei der Closure legt der Planner die Umbau-Slices an, die
die ADR in ihrem Schnitt-Hinweis nennt (per `cp` in `open/`).

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die ADR wird vor ihrer Bewährung unveränderlich**; ein Fehlgriff kostet einen Folge-ADR. —
  **Ausgang: eingetreten** — Folge-Slice `slice-spec-5-entscheidungen-nach-dem-umbau` (Ausgänge von E1, E3, E4, Fitness-Zeile 13, zwei Begründungen ohne Träger).
- **`slice-feldabdeckung-existenz-sensor` liest die Tabelle von §5**; eine neue Spalte oder ein
  geänderter Zeilen-Schnitt berührt seinen Parser. — **Ausgang: weiter offen** — Register
  `BEO-ALL/feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor` (sein Sensor ist der Parser-Slice); die Bedingung
  (Kopfzeilen-Präfix und Spalte 2) steht im Plan von `slice-feldabdeckung-existenz-sensor`.
- **Eine Senkung durch `exempt-paths` wird als Ortsentscheidung getarnt.** — **Ausgang: entfallen** — die ADR trägt keine Senkung und führt die
  Ortsentscheidung als eigene Festlegung ([`AGENTS.md`](../../../../AGENTS.md) §3.5); der Verifier hat `git log 3a5ccf54..HEAD -- .d-check.yml` leer gefunden.

## 7. Closure-Notiz


Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

**Geliefert:** die Entscheidung zu Klassen, Ort der Messprotokolle und Spalte `Präzisiert` als [`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) und die Sammel-ADR [`ADR-0075`](../../adr/0075-begruendungen-zu-spec-5-sammel-adr.md), beide
`Accepted`, beide im ADR-Index; dazu die Adaptions-Einträge [`MR-075`](../../../../harness/conventions.md#mr-075),
[`MR-076`](../../../../harness/conventions.md#mr-076), [`MR-077`](../../../../harness/conventions.md#mr-077) und die Kopf-Marken an
[`MR-021`](../../../../harness/conventions.md#mr-021) und [`MR-044`](../../../../harness/conventions.md#mr-044).

**Verifikation:** `docs/reviews/2026-09-30-slice-spec-aufnahme-regel-und-umbau-verifikation.md` — Verdikt **bedingt bestätigt**. Review der ADR: 0 HIGH, vier MEDIUM, vor der Annahme nachgebessert. Commit-Zuschnitt
nach [`AGENTS.md`](../../../../AGENTS.md) §3.8 hält bis auf einen Commit (`docs/user/rollen-laeufe.md` unter „Rolle Architect", keine Quelle für die schreibende Rolle).

**Einschränkung zu Liefer-Punkt 1 (Häkchen gesetzt, bedingt):** Rot gesehen hat der Verifier acht von vierzehn Festlegungen (Datum im Fließtext,
Link nach unten, „Abweichung [1-6]", Anker, Kopfzeilen-Präfix, Fall- und Testnamen im Fließtext, Kernsätze der Sammel-ADR, dazu die leere Zelle als benannte Lücke).
**Nicht rot gesehen:** die Immutabilität (grün belegt, `make adr-immutable` über beide Ranges; ein Rot war nicht herstellbar), Festlegung 9, 10 und 14; Festlegung 13 misst
den Gegenwert (Fitness-Zeile verlangt für `START-KONVENTION` den Wert vor dem Umbau, Ist-Wert 0). Diese Festlegungen gelten als **nicht rot gesehen**, nicht als bestätigt.
Die Nachprobe trägt `slice-spec-5-entscheidungen-nach-dem-umbau`.

**Ausgänge der Risiken:** in §6.

**Register:** keine Beobachtung über den Umbau hinaus; die Einträge dieses Vorgangs stehen in §7 von `slice-spec-5-wird-nach-adr-0074-umgebaut`.

**Folge-Slices** (nur Pläne in `open/`, nicht ausgeführt): `slice-spec-5-entscheidungen-nach-dem-umbau` (Übergaben A-1 bis A-5 und A-7 der Verifikation),
`slice-spec-5-tabellen-sensor-und-zeiger-nach-dem-umbau` (Übergabe A-6). Übergabe A-8 steht als Bedingung im Plan von `slice-feldabdeckung-existenz-sensor`.

**Lerneintrag (benannte Spec-Lücke):** Zeilen von Spec §5 tragen `Lücke`, weil ihnen kein Lastenheft-Element zugeordnet ist; ob [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) sie als Präzisierung trägt, ist eine
Ebenen-Frage ohne Sensor (Verifikation, Abschnitt 2.5). Adresse der Entscheidung: `slice-spec-5-entscheidungen-nach-dem-umbau`; ein Change Request nach
[`MR-015`](../../../../harness/conventions.md#mr-015) bleibt Entscheidung des Auftraggebers.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist die Sub-Area `*` (gesamtes Repo, Kürzel `ALL`,
Modus Greenfield laut Modus-Deklaration in `harness/conventions.md`). Die Deklaration führt für
`spec/` keine feinere Sub-Area, und alle Beobachtungen des Registers tragen diese eine; die Schwelle
≥ 2 von 3 Achsen lässt sich damit nicht feiner prüfen, als die Deklaration es zulässt — benannt, nicht
gelöst.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen, gemergter Stand; Zähler =
Dateien unter `evidence/` (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`). Treffer
am Gegenstand „Spec-Text, Messungen, Kopplung an Code“:

- [`spec-aenderung-ohne-historie-zeile`](../observations/BEO-ALL/spec-aenderung-ohne-historie-zeile/observation.md)
  — 1×, offen: eine Änderung an Lastenheft oder Spezifikation ohne Zeile in der Historie.
- [`spec-zeile-enger-als-der-code-den-sie-beschreibt`](../observations/BEO-ALL/spec-zeile-enger-als-der-code-den-sie-beschreibt/observation.md)
  — 1×, offen.
- [`festlegung-und-ihr-rumpf-nennen-verschiedene-reichweiten`](../observations/BEO-ALL/festlegung-und-ihr-rumpf-nennen-verschiedene-reichweiten/observation.md)
  — 1×, offen.
- [`feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor`](../observations/BEO-ALL/feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor/observation.md)
  — 1×, offen; sein Existenz-Sensor ist `slice-feldabdeckung-existenz-sensor` (`open/`, hängt an einer
  `Proposed`-ADR).
- [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md)
  — 6×, geplant (`slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle`); berührt die
  „gemessen am …“-Zeilen des Fließtexts unmittelbar.
- [`mess-zusage-trifft-das-eigene-zitat`](../observations/BEO-ALL/mess-zusage-trifft-das-eigene-zitat/observation.md)
  — 5×, verkörpert ([`MR-058`](../../../../harness/conventions.md#mr-058), Adaptions-Block).

Kein Eintrag erreicht mit diesem Slice die 3×-Schwelle: ein Slice legt je Eintrag höchstens eine
Beleg-Datei an, die drei Einträge mit einem Beleg kämen auf 2×.
Dieser Slice ändert keine Zeile der Spec; die Einträge sind Kontext für die Slices, die es tun.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF.
