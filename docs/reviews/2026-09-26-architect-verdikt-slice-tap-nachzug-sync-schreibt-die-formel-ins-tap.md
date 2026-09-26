# Architect-Verdikt: slice-tap-nachzug-sync-schreibt-die-formel-ins-tap — 2026-09-26

**Rolle:** Architect (Modul 8). Frage: *Trägt die ADR-Lage den Plan und den Code — und wo nicht, was ist zu entscheiden?* Kein Review (Diff gegen Plan/ADR) und keine Verifikation (DoD); das Verdikt ist das **Übergabe-Artefakt** an den Planner, der es in der Closure liest.

**Gegenstand:** Slice `slice-tap-nachzug-sync-schreibt-die-formel-ins-tap` (Kennung, nicht Pfad — der Plan wandert mit dem Lifecycle, `AGENTS.md` §3.11), HEAD `42c7df0c` bei Beginn des Laufs. **Eingang:** Slice-Plan (§1, §2, §6 Fragen 1 und 2, §8), `ADR-0064` und `ADR-0066` komplett, `ADR-0062` (`Proposed`), `ADR-0015`, `ADR-0028`, der Review-Report und der Verifikations-Report des Slice (Übergaben an den Architect), `harness/tools/tap-nachzug.sh`, `harness/tools/tap-nachzug-nutzlast.sh`, das Register-Verzeichnis `BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet` (3×, `offen`).

**Ausgang:** eine neue ADR im Status `Proposed` — `ADR-0068` (Fragen 2 und 3) —, dazu dieses Verdikt (Fragen 1 und 4 und die akzeptierten Negative). Kein Code, kein Test, keine Prozedur, keine Slice-Datei und keine Register-Datei berührt; keine `Accepted`-ADR geändert (`AGENTS.md` §3.4).

**Eigene Läufe:** zwei Schwächungen in Scratchpad-Kopien von `git archive HEAD`, `bats` im gepinnten Bild des Makefiles (`docker run --rm --network none -v <Kopie>:/code:ro -w /code <BATS_IMAGE> test/tap-nachzug.bats`); der unveränderte Baum ist grün. Sie stehen in `ADR-0068` §Fitness Function.

---

## Frage 1 — Trigger-Audit `ADR-0066`, dritter Re-Evaluierungs-Trigger: **nicht eingetreten, bestätigt**

Der Trigger lautet: *„Wenn ein Ergebnis der Nutzlast außerhalb von ‚gleich', ‚Unterschied' und ‚nicht ausführbar' entsteht oder ein zweiter Aufrufer der Nutzlast die Klasse aus ihr statt aus dem Skript liest"*, beobachtbar am Schnitt, der den Modus `sync` implementiert.

- **Kein viertes Ergebnis.** `grep -nE 'exit (0|10|2)\b|beende 2' harness/tools/tap-nachzug-nutzlast.sh` nennt die Enden mit 0, 10 und 2 (gemessen 2026-09-26, keine Erwartung); das Host-Skript bildet 0 auf 0, 10 auf 1, 2 auf 2 und jeden anderen Status auf Exit 2 mit Meldung. Die Ausgänge, die `sync` neu hat — Vorwärts-Schutz, Ablehnung, *„Ausgang ungewiss"*, *„bereits erfolgt"* — sind Status 2 mit eigener Meldung; `ADR-0064` Festlegung 2 führt sie in der Tabelle unter Klasse 2 auf (*„Anmeldung fehlt oder abgelehnt, `version`-Zeile …, Vorwärts-Schutz, Ausgang des Schreibens ungewiss"*). *„Nachgezogen"* (Schreiben, Nachkontrolle gleich) ist Klasse 0, *„Formel-Unterschied nach dem Schreiben"* Klasse 1: die Nachkontrolle ist der Vergleich der Klasse *gleich*/*Unterschied*, kein neues Ergebnis.
- **Kein zweiter produktiver Aufrufer.** Die Nutzlast wird allein von `harness/tools/tap-nachzug.sh` gelesen (`grep -rlnI 'tap-nachzug-nutzlast' --exclude-dir=.git --exclude-dir=.harness . | grep -v '^./docs/'` nennt außer der Nutzlast und ihrem Leser `harness/tools/tap-nachzug.sh` nur `test/tap-nachzug.bats` und Mutations-Fälle in `test/mutations/`).
- **Der Direktaufruf in den Fällen ist keine Lesart der Klasse.** `test/tap-nachzug.bats` fährt die Nutzlast direkt (etwa `sync fehlt-nachweis`) und liest ihren Status; das ist keine Verzweigung der Klasse, sondern die hermetische Schicht, die `ADR-0064` Festlegung 5 vorschreibt (*„die Nutzlast ist eine eigene Datei, die ein `bats`-Fall … fährt"*). Ein Test, der den Status liest, ist ein Test-Leser; der Trigger meint einen Aufrufer, der die Klasse **anders** herleitet als das Skript.

**Verdikt:** bestätigt, kein Folge-ADR. Der Trigger ist am Schnitt, der `sync` implementiert, ausgewertet und damit erledigt; ein weiteres Audit an einem späteren Schnitt hängt nicht an ihm. **Trigger 1 derselben ADR** (*„ein Aufrufer braucht die Klasse am Prozess-Exit"*) hat einen neuen möglichen Anlass — den Release-Job, der `make tap-nachzug` ruft —; er ist nicht Gegenstand dieses Audits, gehört aber in den Eingang des Laufs, der den Job schneidet (Frage 4, Übergabe).

## Frage 2 — Zuordnung der Antworten beim Schreiben: **bleibt als Setzung, jetzt benannt** (`ADR-0068` Festlegung 1 und 2)

Die Zuordnung im Code — 200 → Nachkontrolle; 401/403/409 → *„Tap unverändert"*; alles andere und keine Antwort → *„Ausgang ungewiss"* mit `make tap-check` — ist bestätigt. 404, 422 und 429 wandern **nicht** nach *„unverändert"*.

- **Grund.** *„Tap unverändert"* ist eine Zustandsaussage über ein Fremd-Repo; die Ursache hinter 404, 422 und 429 ist am realen Tap ungemessen (das Tap ist ungeschützt, der Fall *Schutz des Branches* dort nicht herstellbar). Die Enge kostet einen lesenden `make tap-check`, den die Prozedur ohnehin verlangt (`ADR-0064` Festlegung 6); eine zu weite Zusage kostet eine Meldung, der der Bediener glaubt. Ohne Messung fehlt jeder Grund zu weiten.
- **Die Annahme ist in der Norm zu benennen — und ist es jetzt.** `ADR-0064` nennt Ursachen, keine Status; die Abbildung Ursache → 401/403/409 ist eine **Setzung**, am realen Tap ungemessen. `ADR-0068` Festlegung 2 sagt das und bindet jede Erweiterung an einen Beleg des realen Tap. Ein Schutz des Branches ohne festen Status wird **nicht** als eigene Ursache geführt: er bleibt unter 403 gesetzt und ist ohne Messung nicht herstellbar.
- **Keine Klasse, kein Supersedes.** Beide Meldungen enden mit Exit 2; `ADR-0064` Festlegung 3 bleibt wörtlich wahr (*„ohne Antwort … ungewiss"* erweitert sich auf einen Status, den die ADR nicht klassifiziert — sie schärft, sie löst nichts ab). Der ADR-Index bekommt an `ADR-0064` keinen Zusatz.
- **Rot gesehen** (`AGENTS.md` §3.6): Zusage *„nur 401, 403, 409 melden unverändert"*; Gegenbeispiel 404/422/429 im Ablehnungs-Zweig → `sync abgelehnt` fällt an der Aussage `Ausgang des Schreibens ungewiss` (eigener Lauf; der Review hat die Schwächungen J und J2, der Verifier die Fall-Fahrt gesehen).
- **Für den Slice:** Frage 2 (§6) ist damit beantwortet; die Umsetzung des Implementers ist die Zuordnung, die das Verdikt bestätigt. Kein Code, kein Test und keine Zeile der Prozedur ist deswegen zu ändern.

## Frage 3 — ADR-Lücke aus R-2 (Meldung nach vollzogenem Schreiben): **Norm-Lücke geschlossen** (`ADR-0068` Festlegung 3)

Die Meldung *„das Schreiben ist bereits erfolgt (HTTP 200) …, Ergebnis mit `make tap-check` prüfen"* steht jetzt in einer Festlegung: nach einem 200 des Schreibaufrufs sagt jede Meldung der Nachkontrolle mit unlesbarem Tap, dass geschrieben ist, dass der Inhalt unbekannt bleibt, und nennt `make tap-check`; *„nichts verglichen"* ohne den Vollzug ist nicht zulässig. Klasse bleibt 2 (`ADR-0064` Festlegung 2). Sie hängt mit Frage 2 am selben Grundsatz (*eine Zustandsaussage nur, soweit die Antwort sie trägt*) und steht darum in **einer** ADR. Der Code und Fall 53 (`sync teilerfolg`) halten sie; rot gesehen (Bedingung der Meldung auf `false` → Fall rot, Ausgabe *„… es wurde nichts verglichen"*).

**Akzeptiertes Negativ — `ADR-0064` Folgepflicht 1, Verifier V-1.** Der Satz *„ohne Eintrag färbt das Doku-Gate im ersten Lauf rot"* ist gemessen nur wahr, wenn auch die README-Zeile fehlt (Eintrag und Zeile decken einander als Deklaration). Kein Folge-ADR: die Norm der Folgepflicht (beide Träger liefern) ist erfüllt, der Satz ist ihre Begründung und bindet kein Verhalten; ein Fehler dort kann keine Zusage brechen, die ein Lauf trägt. Die Zusage, die den Befund trägt, ist die **Abnahme-Formulierung des Slice** (DoD Liefer-Punkt 2) — das ist Planner-Arbeit (`AGENTS.md` §3.10), nicht Architect-Arbeit.

## Frage 4 — Verkörperung von *„Der Umbau einer Aussage steht im Eingang des Laufs, der ihn auslöst"*: **als Zeile im Anweisungssatz des Planners; keine Hard Rule, keine ADR, nicht gestrichen**

**Zuständigkeit — welche Quelle mir welchen Teil gibt.**

- `AGENTS.md` §3.8 und `ADR-0015` geben dem Architect **zwei** Artefakte: die Hard Rules in §3 und den Adaptions-Block. Eine Hard Rule wäre meine Arbeit. Eine ADR ebenso (`modul-08-agentenrollen.md` §Rollen-Regeln).
- Ein Anweisungssatz gehört der Rolle, die ihn **ausführt** (`ADR-0028` Festlegung 1): `.claude/commands/plan-welle.md` führt die Planner-Rolle (Eröffnungssatz). **Die Zeile schreibt der Planner, nicht ich.** Ich schreibe sie nicht und übergebe Wortlaut und Zielort.
- Dass die Zeile eine bindende Aussage *ohne Original* wäre (`ADR-0028` Festlegung 2, die offen bleibt), trifft nicht zu: das Original ist die Baseline, `modul-05-planning-harness.md` §Ziel-Form: Slice, §1 Klasse 1 — *„Ein Folge-Slice übernimmt es — mit Kennung. Das macht aus ‚später' eine Adresse. Die Adresse muss die Sendung annehmen."* Die Zeile distilliert diese Regel für den Ablauf des Planners; sie setzt keine neue rollenübergreifende Norm.

**Warum eine Zeile im Anweisungssatz und nicht die Hard Rule.**

1. **Die Regel bindet einen Moment einer Rolle** — den Schnitt und die Closure eines Slice —, und ihr eigener Inhalt verlangt, dass die Bedingung dort steht, wo der bindende Lauf liest. Der Träger, der das erfüllt, ist der Anweisungssatz dieser Rolle. `AGENTS.md` stünde zusätzlich in jedem Lauf im Kontext (`CLAUDE.md` importiert sie), auch dort, wo die Regel nichts bindet.
2. **Eine Hard Rule kostet mehr, als sie zusätzlich trägt**: Auflösungs-Trigger oder *permanent* (`modul-13-quality-gates.md` §Hard Rule), Cutoff, der Absatz *„Ein Wächter existiert nicht"*. Die Präzedenz `AGENTS.md` §3.10 führt einen ablesbaren Commit-Zuschnitt neu ein; hier gibt es keine ablesbare Form.
3. **Der Grund der Klasse ist eine Adresse ohne Träger.** Alle drei Belege sind derselbe Fall: die Bedingung steht in einem Artefakt (Plan, Bericht, Risiko), das der Lauf nicht liest oder das mit der Closure aus jedem Eingang fällt. Der Folge-Schnitt des Slice trägt die Bedingung *„noch ohne Kennung und ohne Datei"*; das ist nach Klasse 1 keine Adresse. Die Zeile setzt genau dort an.

**Warum keine ADR-Folgepflicht.** Eine ADR trägt Bedingungen für die Folgeläufe **ihres Gegenstands**; die Regel ist gegenstandsübergreifend. Und die **Instanz** — der Umbau von Schritt 7 mit dem Release-Job — ist für den Job-Implementer bereits gedeckt: `ADR-0064` Folgepflicht 2 und 3 (Job `tap`, Prozedur führt das Nachzug-Ergebnis des Jobs, `make tap-check` als unabhängigen Beleg und den lokalen Ausfallweg) stehen als `Accepted`-Constraint in seinem Eingang. Was fehlt, sind die Folgeaussagen, die daran altern (Handlung, Voraussetzung *„Token mit Schreibrecht"*, der Satz zur Rolle, der Absatz *Grenze*) — das ist die Klasse `zusage-neben-geaenderter-ableitung-bleibt-stehen`, die ihren eigenen Ausgang trägt.

**Vorgeschlagener Wortlaut** (Planner, `.claude/commands/plan-welle.md`, Abschnitt *Slices bereitstellen*; der Planner formuliert in seinem Stil):

> *Eine Bedingung, die ein Geber-Artefakt an einen Lauf richtet, der noch nicht existiert — ein Punkt unter „Ausdrücklich NICHT" mit Folge-Schnitt, ein Risiko-Ausgang, eine Übergabe eines Review- oder Verifikations-Berichts, eine Folgepflicht einer ADR —, steht im Slice-Plan dieses Laufs (§1 oder §3): der Plan ist das Artefakt, das der Lauf liest; der Geber wandert nach `done/` und liegt danach in keinem Eingang. Ein Folge-Schnitt ohne Datei ist keine Adresse (Modul 5 §Ziel-Form: Slice, §1 Klasse 1); hängt eine Bedingung an ihm, legt der Planner beim Schließen des Gebers die Datei in `open/` an (per `cp` aus dem Template) und trägt die Bedingung dort ein. · seit slice-<Kennung>*

**Gegenbeispiel, benannt (§3.6).** Die Zeile bricht, wenn ein Slice-Plan eine Bedingung seines Gebers nicht in §1/§3 trägt und der Lauf sie deshalb nicht erfüllt — die drei Belege der Klasse sind dieser Fall, real gesehen; der nächste mögliche ist der Schnitt des Release-Jobs. **Ein Wächter existiert nicht:** die Zeile ist Feedforward, kein Sensor; der Planner benennt das im Absatz *Grenze* seines Ausgangs, statt eine Erkennung zu behaupten. **Eskalation:** tritt die Klasse **nach** der Zeile noch einmal ein, ist die Trägerschaft der Befund, nicht die Wiederholung — dann ist die Hard Rule (Architect, `AGENTS.md` §3.8) der nächste Schritt.

**Ausgang der Beobachtung, für den Planner.** `verkörpert` — Zielort `.claude/commands/plan-welle.md` (Abschnitt *Slices bereitstellen*), Herkunfts-Anker `seit slice-<Kennung>` des Slice, in dessen Closure die Zeile landet (Anker-Paarung: der Zielort existiert und trägt den Anker). Bis die Zeile steht, bleibt der Stand `offen`; `geplant` verlangt einen Slice, der die Regel schreibt — das Schreiben einer Zeile im eigenen Anweisungssatz ist keiner.

## Übergaben

**An den Planner (Closure des Slice)**
1. Die Zeile aus Frage 4 in `.claude/commands/plan-welle.md` schreiben und den Ausgang der Beobachtung `bedingung-ohne-traeger-im-lauf-den-sie-bindet` setzen (Zielort, Anker, *„Ein Wächter existiert nicht"* in der Grenze). Die Zeile ist eigener Planner-Commit, nicht im Commit der Closure-Notiz.
2. Der Job-Schnitt (`ADR-0064` Folgepflicht 2) ist der nächste Anlass der Klasse. Sein Plan trägt in §1/§3: (a) den Umbau von Schritt 7 (Handlung wird der Job, das Ziel der lokale Ausfallweg, die Meldung des Schnitts hängt weiter an `make tap-check`), (b) die vier Aussagen, die daran altern (Handlung, Voraussetzung, Satz zur Rolle, Absatz *Grenze* zu den Wächtern von `sync`), (c) die Frage von `ADR-0066` Trigger 1: verzweigt der Job-Schritt auf die Klasse? (er soll es nicht — jedes Nicht-Null ist rot), (d) V-2 und V-3 des Verifikations-Berichts, falls der Umbau die Stellen ohnehin anfasst.
3. **Trigger-Audit `ADR-0066`, dritter Trigger:** nicht eingetreten (Frage 1) — in §7 nennen, mit der Kennung dieses Verdikts, nicht mit dem Pfad.
4. **Offene Frage 2 (§6)** ist beantwortet (Frage 2); Risiko *„Schreib-Pfad nur gegen eine nachgebildete Schnittstelle"* bleibt *weiter offen* (`zusage-ohne-herstellbares-gegenbeispiel`); `ADR-0068` ist die benannte Setzung, der erste reale Nachzug der Beleg.
5. Abnahme-Wortlaut Liefer-Punkt 2 (V-1) und der Ruhe-Marker der Roadmap beim Schließen: Planner-Urteil, unberührt.
6. Die Eigentums-Frage (§6 Frage 1) bleibt unbeantwortet: `ADR-0062` ist `Proposed` und zurückgestellt, dieses Verdikt und `ADR-0068` berühren sie nicht.

**An den Auftraggeber**
1. `ADR-0068` annehmen (`Proposed` → `Accepted`), sobald eine Reviewer-Runde sie gegen `ADR-0064`, `ADR-0066` und `ADR-0040` auf Konsistenz geprüft hat (Acceptance-Trigger der ADR). **Der Slice wartet nicht darauf:** der Code steht im Einklang mit dem Verdikt, keine Umsetzung ändert sich.
2. Den ersten realen Nachzug fahren und die Ausgabe lesen: er ist der Beleg der Setzung aus `ADR-0068` Festlegung 2 und des Schreib-Pfads.

**An den Implementer / Reviewer:** keine. Die Prozedur (`docs/user/releasing.md`) und die Köpfe von Skript und Nutzlast bleiben; die Folgepflicht 1 von `ADR-0068` ist ohne Nachrüsten (wer die Stelle ohnehin anfasst, nennt die Menge als Setzung).
