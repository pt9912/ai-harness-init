# Review-Report: slice-c7-adaptions-nachzuege-v7-0-0

**Review-Range:** `c3687763..cf8e88a3` (13 Commits: 0f4e3b0d, 97195c79, 6d721a64,
8243ead5, b3a646c5, 46dfb1b1, 78d0a0c4, a807b933, 7c750972, 39a5c7ba, a55b2ef1,
12c01f9c, cf8e88a3) · **Plan:**
[`docs/plan/planning/in-progress/slice-c7-adaptions-nachzuege-v7-0-0.md`](../plan/planning/in-progress/slice-c7-adaptions-nachzuege-v7-0-0.md)
· **Datum:** 2026-11-26 · **Rollinhaber:** Reviewer (Modul 10, Skill-Version 2.3.0)

**Findings:** 0 HIGH · 1 MEDIUM · 4 LOW · 2 INFO

---

## Findings

### F1 — Rot-Beleg des zehnten `ignore-refs`-Paars ist in keinem Übergabe-Artefakt dokumentiert

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (`MR-051`-Form der Übergabe)
- `pfad`: `docs/plan/planning/in-progress/slice-c7-adaptions-nachzuege-v7-0-0.md:149` (§7a), Commit `8243ead5` (Message-Zeile „… `test/ignore-refs-restbreite.bats` grün (beide Richtungen)")
- `befund`: Die Zusage am zehnten Paar (`.d-check.yml` Z. 410: `# Deckung: 1`, „bewacht in beiden Richtungen") ist nur als Grün-Lauf belegt. Die Meldung von `8243ead5` nennt allein den Grün-Lauf und Plan §7a trägt die `adr-immutable`-Proben — aber kein Übergabe-Artefakt trägt den Rot-Lauf des `restbreite`-Wächters für dieses Paar.
- `verifizierbar`: ja — `make test` (dort `test-bats`) hält die Deklaration dauerhaft in beide Richtungen
- `klasse`: Zusage trägt den Rot-Beleg außerhalb des Übergabe-Artefakts

**Bruchprobe des Reviews (Kopie `/tmp/c7bruchprobe/repo`, nach dem Lauf entfernt; kein Rest im Baum):**
der Wächter an gleicher Stelle, `docker run --network none bats/bats@sha256:e8f18e0a … test/ignore-refs-restbreite.bats`:

- intakte Kopie → `ok 1`/`ok 2` (Paar deckt den deklarierten 1 Link, das ist der Ist-Bestand von ADR-0100: Z. 76/82 sind Inline-Code und zählen nicht, Z. 134 ist der eine `](…)`-Link — `Deckung: 1` ist gegen den Ist-Bestand richtig);
- Kopie mit `sed -i '410s/# Deckung: 1/# Deckung: 2/'` → `not ok 2`, Meldung: `docs/plan/adr/0100-die-gegenmessung-schrumpft-auf-die-einheimische-flaeche.md -> .harness/baseline/**: 1 aufloesende(r) Link(s), deklariert sind 2`.

Der Rot-Beleg ist damit **reproduzierbar** — der Befund ist nur die fehlende Dokumentation im Übergabe-Artefakt. Der Auftrags-Wortlaut des Laufs („`Deckung: 2` → 4 Befund, revertiert") entspricht an der Form nicht der beobachteten Ausgabe (ein Paar-Befund je Lauf); ein rotaufgezeichnetes Protokoll, das die 4 erklären würde, existiert im Bestand nicht.

### F2 — Doppelte Absatz-Zeile in Plan §7b

- `kategorie`: LOW
- `quelle`: Maintainability ([`AGENTS.md`](../../AGENTS.md) §3.7 Zustandsfelder — die Fundliste ist der Übergabe-Beleg)
- `pfad`: `docs/plan/planning/in-progress/slice-c7-adaptions-nachzuege-v7-0-0.md:158-159`
- `befund`: Die Zeile „Rest-Fundstellen unter der Schwelle, datiert geblieben …" (MR-031 sechs weite `v5.12.0`-Zeilen, migration.md 36 weitere Fundstellen) steht inhaltsgleich zweimal hintereinander.
- `verifizierbar`: nein — kein Sensor liest den Plan-Fließtext
- `klasse`: Fundlisten-Zeile dupliziert

### F3 — „Festlegung 2" in ADR-0101 löst nicht auf

- `kategorie`: LOW
- `quelle`: Maintainability ([`AGENTS.md`](../../AGENTS.md) §3.7 — Zeiger, nicht Erzählung)
- `pfad`: `docs/plan/adr/0101-die-baseline-verweis-form-in-adrs.md:57`, `:92`; daneben `.d-check.yml:395` (Kommentar „ADR-0101 Festlegung 2") und Commit-Meldung `8243ead5`
- `befund`: ADR-0101 nennt in Kontext und Konsequenzen zweimal „(Festlegung 2)", trägt aber keine nummerierten Festlegungen (struktur: Kontext / Entscheidung / Verglichene Alternativen / Konsequenzen / Re-Evaluierungs-Trigger / Geschichte). Der verwiesene Inhalt (tote Adresse am Ventil, Rest der ADR-0100 regiert) steht als Konsequenzen-Bullet — aber die Nummer existiert nicht, auch nicht als Anker.
- `verifizierbar`: nein — kein Link-/Anker-Sensor liest in-ADR-Verweise
- `klasse`: Verweis zeigt auf nicht existierende Festlegungs-Nummer

### F4 — §7a bricht die vom Plan selbst deklarierte Fundlisten-Form

- `kategorie`: LOW
- `quelle`: Maintainability (Plan §1, MR-057-Fundlisten-Form der C5-F2-Schreibweisen)
- `pfad`: `docs/plan/planning/in-progress/slice-c7-adaptions-nachzuege-v7-0-0.md:148-149`
- `befund`: §1 deklariert „Pfad-Angaben in Fundlisten stehen im fenced Block, nicht als Inline-Span"; der `diff <(git show 39f57f73:docs/plan/adr/0100-…)`-Befehl steht in §7a im Inline-Span mit Pfad. Der Pfad existiert, färbt darum nicht (codepaths) — die Form der eigenen Deklaration wird dennoch verletzt, und die Begründung der Deklaration („blanke Kennung im Span färbt") greift für diesen Befehl gerade nicht tragend, weil hier keine blanke Kennung im Span steht.
- `verifizierbar`: ja — `make docs-check` (grün, weil der Pfad auflöst)
- `klasse`: Selbstdeklarierte Fundlisten-Form im eigenen §7 verletzt

### F5 — Architect-Commit `8243ead5` trägt zwei Plan-Artefakte mit

- `kategorie`: INFO
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.8 (Kompositions-Anspruch), Modul 8 (kein Rollenwechsel ohne Artefakt)
- `pfad`: Commit `8243ead5` — `docs/plan/planning/in-progress/roadmap.md` (Ruhe-Marker gezogen), `docs/plan/planning/in-progress/slice-c7-adaptions-nachzuege-v7-0-0.md` (Referenz-Formen)
- `befund`: Neben den Architect-Artefakten (zwei ADR-Dateien, ADR-Index, `.d-check.yml`-Paar, MR-094/MR-063) trägt der Commit den Ruhe-Marker — das gehört zum Claim-Übergang `0f4e3b0d` und wurde als planning-drift im ADR-Commit nachgeholt — und die Plan-Referenz-Formen. Keine Hard Rule/Adaption liegt im Commit, darum bindet der strenge §3.8-Zuschnitt nicht; es ist ein Rollen-Fremdartefakt mit Übergabe-Charakter (Verweis-Formen) bzw. Nachhol-Zug (Marker).
- `verifizierbar`: nein
- `klasse`: Rollen-Fremdartefakt im Architektur-Commit

### F6 — MR-048-Eintrags-Nachzug in situ statt Kopf-Marke

- `kategorie`: INFO
- `quelle`: [`MR-039`](../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)/[`MR-032`](../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)-Form
- `pfad`: `harness/conventions/MR-048-der-reproduzierbarkeits-anker-ist-die-rezept-form-die-skelette-pinnen-per-tag.md` (Geltungsbereich-Zelle), Index-Spiegel `harness/conventions.md:146`
- `befund`: Der Geltungsbereich-Begriff eines angenommenen Eintrags wurde in situ neu gefasst (Anker-Frage → Träger-Frage) — keine Teil-Ablösung gegenüber einem nachfolgenden Eintrag, sondern Terminologie-Anpassung an den regierenden `v7.0.0`-Vokabularstand, am Ort dokumentiert (Kopf-Zusatz „Terminologie-Stand", datiert je [`MR-053`](../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)-Nenner, Titel bleibt Adresse). Die Abwägung „in situ statt Kopf-Marke" ist getroffen, aber nirgends als Wahl benannt.
- `verifizierbar`: nein
- `klasse`: Terminologie-Nachzug an angenommenem Eintrag ohne ausgeschriebene Form-Wahl

---

### F7 — §7c-Fundliste trägt „0" an einem Befehl, der 1 liefert

- `kategorie`: LOW
- `quelle`: [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)/[`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)-Form
- `pfad`: `docs/plan/planning/in-progress/slice-c7-adaptions-nachzuege-v7-0-0.md:163` (§7c), Befehl `grep -rn 'Reproduzierbarkeits\|Zwei Formen' harness/sensors/ harness/mk/`
- `befund`: Die zweite Hälfte des 0-Fund-Befehls kann am Stand des Laufs nicht „0" liefern: `harness/mk/` existiert in diesem Repo nicht (der Lauf würde „No such file or directory" melden), und in `harness/sensors/commit-msg-check.md:47` steht „Zwei Formen erkennt der Matcher nicht …" — ein Prosa-Treffer des Suchmusters, inhaltlich ein anderes Thema (Matcher-Formen des Commit-Aufrufs, nicht die Modul-14-Träger-Terminologie). Die Schlussfolgerung §7c („kein Code-Text-Zug, damit kein Test-Nachzug (R2: entfallen)") trägt inhaltlich weiter — aber der Wert neben dem Befehl stimmt nicht, und der fehlende `harness/mk/`-Operand wurde nicht bemerkt (Review-Nachmessung: Treffer `harness/sensors/commit-msg-check.md:47`; die baumaussage-Hälfte ist 0).
- `verifizierbar`: nein — kein Sensor liest die Fundlisten-Zahl
- `klasse`: Fundlisten-Wert trägt nicht am Befehl

---

## Prüffelder — je ein Urteil

1. **ADR-0100-Supersede-Form / ADR-0101 / Paar + Rot-Beleg — ok mit MEDIUM F1, LOW F3.** Der Revert ist byte-gleich am Entstehungsstand: `diff <(git show 39f57f73:docs/plan/adr/0100-… | cat) docs/plan/adr/0100-…` → einzige Differenz Z. 3 (`**Status:** Accepted` → `Superseded by [ADR-0101](0101-die-baseline-verweis-form-in-adrs.md)`). Die Status-Form deckt sich mit der kopfseitig verankerten `head-allow`-Form (`.d-check.yml` Z. 549: `Superseded by \[ADR-[0-9]{4}\]\([0-9]{4}-[^)]+\)` — die gelebte Link-Form; die bare Kennung des Werkzeug-Vorschlags färbt dort rot), der Plan §7a trägt die Gegenprobe über der roten Basis (`97195c79..HEAD` → 1 Befund `core-drift-vcs` an Z. 3). ADR-0101 folgt der `v7`-Vorlagen-Form (Status/Datum/Autor/Bezug/`Supersedes:`/Schärft-Strich/Regeln/Kontext/3 Alternativen/Konsequenzen/Re-Evaluierungs-Trigger permanent mit zwei Bedingungen/Geschichte), Status Accepted. Die index-Zeilen (ADR-0100 auf Superseded, neue Zeile ADR-0101) stehen. Das zehnte Paar trägt die `Deckung: 1` nach Ist-Bestand (ein `](…)`-Link), die Begründung nennt den ganzen Gegenstand der eingefrorenen Datei und die GRENZE „EXTENSIONAL GESCHLOSSEN"; `internal/ausnahmegrund` erfasst den `in`-Wert (Glob-Klasse aus dem Kopf von `ausnahmegrund.go`), es schaltet kein weiterer Baum still.
2. **Architect-Sub-Zug-Formen — ok mit INFO F5.** `6d721a64` trägt nur die ADR-0100-Zeile; `8243ead5` die ADR-Formen samt Gate-Config und zwei Konventions-Einträgen (Architect-Artefakte) „nebst F5". Beide b/c-Züge (`b3a646c5`, `46dfb1b1`, `78d0a0c4`, `a807b933`, `7c750972`) führen **keine** ADR-Datei (Filelisten geprüft).
3. **Handbuch-/Verweis-Nachzüge — ok.** Z. 513: `56` am Kommando (`find .harness/baseline -type f | wc -l` → 56, nachgemessen). Z. 529: Zielform `specification.md` im Baum-Bild, die Dogfood-Instanz bleibt `spec/spezifikation.md`. Z. 816/826: Pin `v0.93.0` (`DECHCK_IMAGE`-Zeile `d-check.mk:79` nachgemessen). MR-031 Z. 106–107: die zwei Mess-Kommandos auf den `v7.0.0`-Vorlagen-Pfad, Zahlen 1/1 (nachgemessen), die sechs übrigen `v5.12.0`-Fundstellen bleiben datiert (`MR-053`-Nenner in §7). migration.md Z. 140–144: Registerzeilen auf den `v7.0.0`-Vorlagen-Pfad (je am Baum existent, `specification.template.md` nachgemessen); Z. 145 und der Rest bleiben die datierte Form, Fundliste in §7b.
4. **Terminologie-Zellen — ok mit INFO F6.** Titel/Anker-Slug von MR-048 unverändert (§3.11 erfüllt — `git show 46dfb1b1` zeigt die drei Zellen und die unveränderten Anker), Index-Spiegel der Geltungsbereich-Zelle gezogen, keine Zahl in den Zellen geändert (keine `MR-051`-Berührung). MR-047 trägt keine solche Zelle (`grep 'Anker\|Repro'` → 0, nachgemessen).
5. **Der R3-Trail (Archivierungs-Fragment) — ok.** Die Rezept-Zeile liest `"$(WAVE)"` (vormals entstellt `"1001 27 1000 1001WAVE)"`); der Wächter `TestArchivierungFragment_RezeptRuftMitWaveKeying` hält die Rezept-Form und trägt Ziel-Herkunft („seit slice-c7-…") plus Grenze (der reale Lauf in `full-smoke` trägt die Kette). Der Rot-Beleg ist dokumentiert (Plan §7: mutate-once `"$(WELLE)"` → `FAIL internal/emit`; Commit `7c750972`; Wächter-Kommentar) — die full-smoke-Stufen sind der Welle-Beleg. Die matrix-downward-Probe (`a807b933`) liest jetzt die Zielfassung `specification.md`, die Dogfood-Benennung bleibt.
6. **Der Traeger-Fetch-R3-Fund — getragen, kein Review-Blocker.** §7 (Stand `cf8e88a3`) trägt ihn als *weiter offen*: die Fetch-Stufe bricht am `[untergrenze]`-Sperre mit dem aus `TRAEGER_TAG` `v0.10.0` gezogenen Träger; die Entscheidung (Pin ziehen / Stufe schärfen / Release-Schnitt) ist als Planner/Architect-Adresse benannt, der Release-Schnitt liegt außerhalb der Welle und ist kein Slice-Bestandteil dieses Zuges. Nicht still geheilt. Die Closure muss den Register-Eintrag (Modul 6, Ausgang *weiter offen*) setzen; der `full-smoke`-Replay-Beleg für LP2 verbleibt an der Welle-Closure.
7. **Plan §7-Formen — ok mit LOW F2/F4/F7.** Fundlisten je Kommando im fenced Block (§7b) und 0-Fund-Zeilen (§7c, die Sensoren-Hälfte der §7c-Zeile ist F7); die `adr-immutable`-Übertragung trägt drei Ranges samt Gegenprobe über der roten Basis als beobachtbare Form (Trigger-Form, kein Datum).

---

## Negativbefund-Zeilen (geprüft, ohne Befund)

- **ADR-0100-Kern:** byte-gleich am Entstehungsstand `39f57f73` mit Ausnahme der `head-allow`-Statuszeile; keine zweite Kern-Zeile im Diff (`6d721a64` = 1 Zeile).
- **ADR-0101 gegen die `v7`-Vorlage:** Feld-Satz und Abschnitte in der Vorlagen-Form; `Supersedes:`-Feld trägt den Scope (die eine Verweis-Zeile), Status Accepted.
- **ADR-Index:** ADR-0100-Zeile auf Superseded gezogen, ADR-0101-Zeile angesetzt, Bindungs-Spalten vollständig.
- **`ignore-refs`-Paar gegen den Ist-Bestand:** genau ein aufgelöster Markdown-Link (ADR-0100 Z. 134); Inline-Code-Nennungen Z. 76/82 zählen nicht — `Deckung: 1` korrekt (bruch-probe-begründet in F1).
- **Architect-Commit-Zuschnitt:** `6d721a64` eine Datei; b/c-Züge ohne ADR-Änderung.
- **Handbuch-Zahl und Pfade:** 56 / `specification.md`-Zielform / Pin `v0.93.0` — alle drei Kommando-Belege selbst nachgemessen.
- **MR-031/Migration:** nur die übereigneten Stellen ziehen,übrige Fundstellen datiert (`MR-053`-Form) mit Fundliste.
- **Terminologie:** Titel-Anker unverändert; Test-, Sensor- und Emitter-Texte tragen die `v7`-Formen bereits (MR-047 und die Emitter-Texte nachgemessen → 0; die Sensoren-Hälfte von §7c ist F7).
- **Archivierungs-Fragment:** `"$(WAVE)"`-Form und Wächter mit Herkunfts-Anker; Rot-Beleg dokumentiert (Mutate-once-Zeile in §7/Meldung).
- **`full-smoke` matrix-downward-Probe:** Zielfassung im Span, Dogfood-Benennung unberührt.
- **Traeger-Fetch-R3:** als *weiter offen* mit Entscheidung-Adresse in §7 getragen, nicht still geheilt.
- **Stempel:** Baum grün, der `gates`-Stempel deckt HEAD `cf8e88a3` (Review fährt keinen `make gates`-Lauf, Auftrag).

## Verbleibende Risiken

- F1 ist der eine Punkt, der vor der Closure mit einer Zeile in §7a gehoben werden sollte (der Restbreite-Rot-Lauf mit der beobachteten Ausgabe); F2–F4 und F7 sind kleine Plan-/ADR-Text-berichtigungen — Form, nicht Substanz. Blocker für die Closure: **nein.**
