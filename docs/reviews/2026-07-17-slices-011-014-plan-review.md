# Review-Report: slice-011…014 (Baseline-Vendoring-Zug) — 2026-07-17

**Review-Art:** Plan — geprüft gegen Spec (`LH-QA-01/02/03`), aktive ADRs, Hard Rules
und das Betriebsregelwerk v3.1.0 (Modul 5 Slice-Schnitt, Modul 6 Wellen-Closure,
Modul 10 Reviewer-Skill).

**Gegenstand:** `docs/plan/planning/next/slice-011-baseline-vendoring.md`,
`slice-012-quellen-wahrheit.md`, `slice-013-vorlagen-und-slice-koepfe.md`,
`slice-014-reviewer-und-wellen-closure.md` (Arbeitsbaum, uncommitted).

**Skill:** `.harness/skills/reviewer.md` @ 1.0.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-4-8[1m] (Orchestrierung) + 3× claude-sonnet-5 (Reviewer-Linsen) ·
**Datum:** 2026-07-17

**Verfahren:** drei unabhängige Reviewer-Läufe mit getrennten Linsen — (a) Faktentreue,
(b) Harness-Konformität, (c) Slice-Schnitt und Plan-Kohärenz. Die Linsen (a) und (c)
prüften gegen den **real heruntergeladenen** `lab-regelwerk.zip` v3.1.0
(ZIP-sha256 `bd90c721…0220`, gemessen), nicht gegen erinnerte Inhalte. F-1 wurde von
zwei Linsen unabhängig gefunden.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne diese Liste ist der
Lauf nicht reproduzierbar):

- die vier Slice-Pläne (Gegenstand oben)
- aktive ADRs: ADR-0003 (Go-native/Docker-only), ADR-0004 (Durchsetzungs-Emission)
- berührte `LH-*`-IDs: LH-QA-01, LH-QA-02, LH-QA-03
- `AGENTS.md` (Hard Rules, insb. §3.3), `harness/conventions.md` (MR-000…MR-006), `.d-check.yml`
- Regelwerk v3.1.0 (`lab`-Baum), Vergleichsstände v3.0.0 und v1.2.0

**Anlass:** Die Pläne entstanden am 2026-07-16 gegen v3.0.0. Am 2026-07-17 03:54 UTC
erschien v3.1.0 — neun Stunden nach v3.0.0. Der Zug wurde auf v3.1.0 umgepinnt; dieser
Review prüft den umgepinnten Stand.

---

## Findings

Jedes Finding folgt dem §Output-Schema des Reviewer-Skills (verbindliche Single Source
of Truth; die Felder hier sind gespiegelt, nicht neu definiert).

### F-1 — „datei-disjunkt" ist falsch (slice-013 ↔ slice-014)

- `kategorie`: HIGH
- `quelle`: Maintainability (Abgrenzungs-Kohärenz, Modul 6 §Trigger)
- `pfad`: `docs/plan/planning/next/slice-013-vorlagen-und-slice-koepfe.md` §4 · `slice-014-reviewer-und-wellen-closure.md` §Abgrenzung, §4
- `befund`: slice-013 DoD 3 entfernt `**Status:**` aus „allen aktiven Slices (`open/` + `next/`)" — das schließt `next/slice-014-…md:3` ein. Beide Slices behaupten gleichzeitig, datei-disjunkt und voneinander unabhängig startbar zu sein. Beides zusammen ist nicht haltbar.
- `verifizierbar`: nein automatisiert (kein Gate prüft Cross-Slice-Dateiüberschneidung); ein realer Parallel-Versuch auf zwei Branches erzeugt den Merge-Konflikt in `slice-014-…md:3`.

### F-2 — slice-011 reißt beide objektiven Modul-5-Größenkriterien

- `kategorie`: HIGH
- `quelle`: Regelwerk v3.1.0 `modul-05:71-73` (Größen-Regel)
- `pfad`: `docs/plan/planning/next/slice-011-baseline-vendoring.md` §2, §3
- `befund`: Der Slice trägt 9 DoD-Häkchen und berührt Daten, Build, Tooling, Test, Gate-Config und Doku. Er reißt damit „mehr als drei DoD-Punkte" **und** „mehrere Schichten betroffen" — letzteres unabhängig von der in slice-013 §6 dokumentierten Zähl-Ambiguität, die nur die Zahl 3 betrifft.
- `verifizierbar`: ja — Auszählen der Checkbox-Zeilen und der Plan-Tabellenzeilen.

### F-3 — zweiter toter Kurs-Anker, für die geplante Prüfmethode unsichtbar

- `kategorie`: MEDIUM
- `quelle`: LH-QA-02 (Reproduzierbarkeit)
- `pfad`: `docs/plan/planning/slice.template.md:99` (im Scope von slice-013 DoD 1)
- `befund`: Der Anker `#worked-mini-example-bootstrap-modus-pro-sub-area-für-einen-slice-begründen` zeigt auf eine Sektion, die in v3.1.0 `modul-05` null Mal vorkommt; slice-013 benannte nur *einen* toten Anker. Der DoD-Beleg „jeder geänderte Link per `curl` erreichbar" kann das nicht aufdecken — eine GitHub-Blob-URL liefert HTTP 200 unabhängig vom Fragment.
- `verifizierbar`: ja — `grep -c "Worked Mini-Example" modul-05-planning-harness.md` → 0; `grep -n worked-mini-example docs/plan/planning/slice.template.md` → 99.

### F-4 — neues Gate fehlt in beiden kanonischen Gate-Aufzählungen

- `kategorie`: MEDIUM
- `quelle`: LH-QA-01 (Nachbarschaft) / Maintainability
- `pfad`: `docs/plan/planning/next/slice-011-baseline-vendoring.md` §3 vs. `harness/README.md` §Sensors und `AGENTS.md` §4
- `befund`: `baseline-verify` wird laut DoD Prerequisite von `gates`, aber die Plan-Tabelle listet weder `harness/README.md` §Sensors noch `AGENTS.md` §4 — die beiden einzigen kanonischen „welche Gates laufen"-Tabellen des Repos. Nach dem Merge liefe ein Gate, das die Doku nicht führt.
- `verifizierbar`: ja — Abgleich des `gates`-Targets im `Makefile` gegen beide Tabellen nach Umsetzung.

### F-5 — „fast alle" überzeichnet den Re-Pin-Anteil von v3.1.0

- `kategorie`: MEDIUM
- `quelle`: LH-QA-02 (Reproduzierbarkeit) / Maintainability
- `pfad`: `docs/plan/planning/next/slice-011-baseline-vendoring.md` §6 (`<tag>`-Politik)
- `befund`: „193 geänderte Zeilen, fast alle `blob/v3.0.0/` → `blob/v3.1.0/`" — gemessen sind 150 von 193 (77 %) reine Tag-Bumps; 43 Zeilen (22 %) sind inhaltlich, u. a. ein neuer Absatz „**Vendored gelesen?**" in `regelwerk/README.md`. Die Aussage stützt eine Risiko-Einschätzung („nur Link-Churn") und trägt sie in dieser Form nicht.
- `verifizierbar`: ja — `diff -r x-v3.0.0 x-v3.1.0` gegen die entpackten ZIPs, Tag-normalisiert paarweise gezählt.

### F-6 — vier Zeilenbereichs-Angaben greifen je eine Zeile zu weit

- `kategorie`: MEDIUM
- `quelle`: LH-QA-02 (Reproduzierbarkeit)
- `pfad`: `slice-011-…md` §1 (`modul-02:173-176`), §6 (`modul-02:180-181`) · `slice-013-…md` §6 (`modul-05:71-74`, `modul-05:79-80`)
- `befund`: Die zitierten Textstellen enden bzw. beginnen jeweils eine Zeile früher als angegeben (korrekt: `173-175`, `180`, `71-73`, `78-80`). Die Zitate selbst sind wortgleich korrekt.
- `verifizierbar`: ja — `awk 'NR>=a&&NR<=b'` gegen die v3.1.0-Moduldateien.

### F-7 — Verweis-Zählung nicht reproduzierbar

- `kategorie`: MEDIUM
- `quelle`: LH-QA-02 (Reproduzierbarkeit)
- `pfad`: `docs/plan/planning/next/slice-011-baseline-vendoring.md` §1
- `befund`: „15 `../templates/…`-Verweise in 13 der 21 Modul-Dateien, 12 eindeutige Ziele" ist mit keiner einzelnen Zählmethode reproduzierbar — je nach Muster liefert `grep` 15, 16 oder 19 Treffer und 12 oder 13 Dateien, weil Fließtext-Erwähnungen (`modul-02:185`) und echte Markdown-Links nicht getrennt werden.
- `verifizierbar`: ja — `grep -rhoP '\.\./templates/\S*?\.md' regelwerk/ | sort -u | wc -l` versus `grep -rn '\.\./templates/' regelwerk/`.

### F-8 — geschätzte statt gemessene Zeilenzahl

- `kategorie`: MEDIUM
- `quelle`: LH-QA-02 (Reproduzierbarkeit)
- `pfad`: `docs/plan/planning/next/slice-013-vorlagen-und-slice-koepfe.md` §6
- `befund`: „Modul 5 schrumpfte von ~200 auf 120 Zeilen" — der adoptierte v1.2.0-`lab`-Stand hat 219 Zeilen. Die Angabe war geschätzt, nicht gemessen, in einem Absatz, der genau aus einer Messung argumentiert.
- `verifizierbar`: ja — `wc -l .harness/cache/agents-regelwerk/modul-05-planning-harness.md` → 219.

### F-9 — „wörtlich" ohne zitierfähiges Diff-Ziel

- `kategorie`: LOW
- `quelle`: Maintainability (DoD-Prüfbarkeit)
- `pfad`: `docs/plan/planning/next/slice-011-baseline-vendoring.md` §2 (DoD 6)
- `befund`: Die DoD verlangt, der MR-Eintrag trage „alle vier Setzungen **wörtlich** (Formulierung siehe §6)"; §6 liefert sie als mehrsätzige Prosa über vier Absätze, nicht als einen zitierfähigen Blocktext. Zwei Reviewer könnten unterschiedlich urteilen, ob eine paraphrasierte Fassung „wörtlich" genug ist.
- `verifizierbar`: nur bedingt — kein Diff-Ziel.

### F-10 — kanonische Quelle vs. vendorter Baum sind nicht deckungsgleich

- `kategorie`: MEDIUM
- `quelle`: LH-QA-02 / Source Precedence (`AGENTS.md` §1)
- `pfad`: `docs/plan/planning/next/slice-012-quellen-wahrheit.md` §1, §2
- `befund`: Der geplante Ersatz-Pointer nennt „Kurs unter `/kurs/de/`, gepinnt auf `v3.1.0`". Der tatsächlich vendorte Baum stammt aus `lab-regelwerk.zip` und weicht inhaltlich ab (Modul 5: `kurs/de/` 300 Zeilen mit `SL-014`, `lab/regelwerk/` 120 ohne). Ein `kurs/de/`-Pointer löst die „wortgleich"-Zusage aus `AGENTS.md` §1 gegenüber dem vendorten Baum nicht ein.
- `verifizierbar`: ja — Diff zwischen dem in `AGENTS.md` §1 verlinkten Ziel und `.harness/baseline/<tag>/regelwerk/` nach Umsetzung; kein Gate deckt Inhaltsgleichheit ab (`docs-check` prüft Erreichbarkeit/Anker).

## Refutierte Befunde (mit Beleg — Modul 10: „REFUTED nur mit Beleg")

### R-1 — „Wave-Self-Close-Commit existiert in v1.2.0 doch"

- Gemeldet als MEDIUM gegen `slice-014-…md` §1 Punkt 2.
- **Refutiert.** Der Reviewer maß gegen `kurs/de/02-planung/modul-06-roadmap.md` @ v1.2.0
  (Treffer in Zeile 220, 239). Der **adoptierte** Stand ist der `lab`-Baum:
  `grep -c 'Wave-Self-Close-Commit' .harness/cache/agents-regelwerk/modul-06-roadmap.md`
  → **0**. Die Aussage im Slice ist korrekt.
- Folge trotzdem: Der Bezugs-Baum wird im Slice jetzt explizit benannt, weil die
  Verwechslung offenkundig naheliegt.

### R-2 — „Modul 5 hatte 300 Zeilen, nicht ~200"

- Gemeldet als MEDIUM gegen `slice-013-…md` §6.
- **Teilweise refutiert.** Die 300 Zeilen sind die `kurs/de/`-Fassung; der adoptierte
  `lab`-Stand hat **219** Zeilen (`wc -l`). Die Größenordnung des Slice war richtig,
  die Zahl unpräzise — als F-8 geführt und korrigiert.

**Systemischer Befund aus R-1/R-2:** Es existieren **zwei divergente Regelwerks-Bäume**
(`kurs/de/` didaktisch, `lab/regelwerk/` adoptiert). Wer gegen den falschen misst,
erzeugt falsche Refutationen. „Kanonisch" (`kurs/de/`, laut Selbstaussage des
`lab`-README) und „deckungsgleich" sind hier nicht dasselbe.

**Ursache — Eingangs-Kontext des Review-Laufs war unvollständig (Fehler des
Orchestrators, nicht der Linse).** Betroffen war **eine** der drei Linsen
(Faktentreue), dort zweimal; Linse (b) Konformität hat die Divergenz korrekt
*gefunden* und als F-10 gemeldet, Linse (c) hatte keinen v1.2.0-Bezug. Der Linse (a)
wurden als Grundwahrheit nur die Bäume v3.0.0 und v3.1.0 gegeben — die zu prüfenden
Aussagen betrafen aber **v1.2.0**, dessen `lab`-Baum unter
`.harness/cache/agents-regelwerk/` im Repo liegt und im Prompt nicht genannt wurde.
Gleichzeitig war `curl` sanktioniert. Die Linse brauchte einen v1.2.0-Fakt, hatte
keinen v1.2.0-Baum und holte das erreichbarste v1.2.0-Artefakt: `kurs/de/` unter
stabiler Raw-URL. Der `lab`-Baum existiert dagegen nur *innerhalb* eines
Release-ZIP-Assets — **das falsche Artefakt ist das leicht erreichbare**. Der
Referent „im adoptierten v1.2.0-Stand" im Slice-Text löst nur auf, wenn man bereits
weiß, dass „adoptiert" den `lab`-Baum meint.

Das ist ein Beleg *für* den Befund, den dieser Zug ohnehin adressiert: Der
Reviewer-Skill führt „Eingangs-Kontext (Pflicht — sonst nicht reproduzierbar)" als
erste Sektion; v3.1.0 `modul-10:52-57` härtet ihn zum „Operativen Pflichtteil". Der
Lauf verletzte die Vorbedingung des Skills, den er anwandte — und produzierte genau
die nicht-reproduzierbaren Refutationen, die die Regel verhindern soll. **Konsequenz
für künftige Läufe:** die Ground-Truth-Bäume *aller* im Prüfgegenstand genannten
Stände vollständig übergeben und den `lab`-vs-`kurs/de`-Unterschied explizit
benennen. Siehe slice-014 (Pflicht-Kontext-Eingang).

## Behandlung

| Finding | Behandlung |
|---|---|
| F-1 | **behoben** — „datei-disjunkt" gestrichen; die Überschneidung (eine Zeile, `slice-014`-Kopf) ist in beiden Slices benannt, Parallelbetrieb ausgeschlossen |
| F-2 | **bewusst getragen** (Nutzer-Entscheidung 2026-07-17) — Begründung in `slice-011` §6: jeder Schnitt wäre ein Schicht-Schnitt und bräche die unstrittige Regel „Schnitt nach Lieferwert" (`modul-05:75-77`), um die strittige (≤3) zu erfüllen |
| F-3 | **behoben** — beide toten Anker in `slice-013` §1/DoD 1 benannt; DoD verlangt jetzt Anker-Prüfung gegen den Modul-Text zusätzlich zum `curl`-Beleg |
| F-4 | **behoben** — `harness/README.md` §Sensors + `AGENTS.md` §4 als DoD-Punkt und Plan-Tabellenzeile ergänzt |
| F-5 | **behoben** — auf 150/193 (77 %) präzisiert, 43 inhaltliche Zeilen benannt |
| F-6 | **behoben** — alle vier Bereiche nachgemessen und korrigiert |
| F-7 | **behoben** — Zählmethode im Slice benannt; Kennzahl auf „12 eindeutige Ziele, 0 tot" reduziert |
| F-8 | **behoben** — 219 → 120, mit Bezugs-Baum benannt |
| F-9 | **akzeptiert, nicht behoben** — die vier Setzungen sind in §6 je mit „Setzung:"/„Der MR-Eintrag trägt" markiert; LOW, kein Merge-Blocker |
| F-10 | **bereits gedeckt** — `slice-011` DoD 7 streicht „wortgleich" aus `AGENTS.md`/`CLAUDE.md`; der `kurs/de/`-Pointer bleibt korrekt als *kanonische Quelle* im Sinne der Source Precedence (das `lab`-README sagt das über sich selbst: „derivative Sicht, bei Konflikt gilt die Quelle"). Kein Widerspruch, aber die Unterscheidung ist jetzt in `slice-014` §1 dokumentiert |

## Negativbefunde

- geprüft, ohne Befund: **Stilles-Grün-Pfad in `baseline-verify`** — das Risiko (`sha256sum -c` bleibt bei zusätzlich eingelegter Datei grün) ist im Slice selbst erkannt und mit einem Vollständigkeits-Check in der DoD adressiert.
- geprüft, ohne Befund: **ADR-0003 (Docker-only)** — kein Slice plant eine neue Host-Toolchain-Abhängigkeit; `unzip` entfällt sogar, `curl` bleibt Maintenance-only außerhalb `gates`.
- geprüft, ohne Befund: **Offline-grün** — `baseline-verify` netzlos in `gates`, `regelwerk-check` mit Netz außerhalb; entspricht dem bestehenden Makefile-Muster.
- geprüft, ohne Befund: **`.d-check.yml` `matrix`** — keine Referenz auf superseded/deprecated ADRs, keine Spec-Straten-Datei unter den vier, keine verbotene Referenz-Richtung.
- geprüft, ohne Befund: **`ids` `link-policy: always`** — alle `LH-*`/`ADR-*`/`MR-*`-Vorkommen in den vier Dokumenten sind verlinkt; `make docs-check` grün (33 Dateien, 0 Befunde).
- geprüft, ohne Befund: **MR-004/MR-006-Historie** — `slice-011` markiert beide als Historie statt sie zu überschreiben, konsistent zum bestehenden Muster.
- geprüft, ohne Befund: **Hard Rules außer §3.3** — keine Accepted-ADR verändert; `baseline-verify` ist Gate-Erweiterung, keine Lockerung.
- geprüft, ohne Befund: **Kalenderdatum als Trigger** — kein Slice verwendet eines (Modul 6 §Trigger eingehalten).
- geprüft, ohne Befund: **Abgrenzungs-Kohärenz** über alle vier Plan-Tabellen außer F-1 — keine doppelt beanspruchte Datei, keine unbeanspruchte Lücke.
- geprüft, ohne Befund: **Ziel-Form-Konformität** — alle vier führen die Sektionen 1–8 in Template-Reihenfolge; das `**Status:**`-Feld ist der Vorher-Zustand, den `slice-013` selbst herstellt.
- geprüft, ohne Befund: **verifizierte Kernfakten** — ZIP-sha256 `bd90c721…0220`, 42 Dateien (21+21), ~241 KB, 18 fremde MR-/ADR-Kennungen in 6 Dateien inkl. `modul-02:153,216`/`modul-08:82`/`modul-13:143`, Anker `#ziel-form-reviewer-skill`, Zitate `modul-10:54-57` und `modul-06:53-84`, `welle.template.md:10`, beide 404-Pointer, Release-Zeitstempel — alle exakt bestätigt.

**Nicht geprüft (Grenze dieses Laufs):** d-check-Pin-Sprung v0.10.0 → 0.43.1 (externes
Tool-Repo, keine Ground Truth); Zuordnung „Kurs-Welle 18" des Reviewer-Skills zu einem
Tag; vollständige Anker-Prüfung *jedes* Links in den vier Dokumenten (stichprobenartig).

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 2 |
| MEDIUM | 7 |
| LOW | 1 |
| INFO | 0 |
| refutiert (mit Beleg) | 2 |

## Verdikt

**Merge-blockierend:** nein — mit Begründung, nicht still entschieden.

HIGH und MEDIUM blockieren typischerweise. Beide HIGH sind adressiert: **F-1** ist
behoben (der Widerspruch existiert nicht mehr). **F-2** wird als bewusste, begründete
und im Slice dokumentierte Abweichung getragen — die Nutzer-Entscheidung vom
2026-07-17 folgt der unstrittigen Modul-5-Regel „Schnitt nach Lieferwert, nicht nach
Schichten" und ordnet sie der strittigen Zahl-Regel über, deren Einheit v3.1.0 selbst
nicht mehr definiert (Herleitung: `slice-013` §6). Sieben der acht MEDIUM sind behoben,
F-10 war bereits gedeckt; das LOW ist akzeptiert.

**Steering-Loop-Signal.** Dieselbe Klasse trat wiederholt auf: **behauptete statt
gemessene Zahlen** (F-5, F-6, F-7, F-8 — vier Findings, plus die schon vor dem Review
korrigierten „54 Dateien" und der v3.0.0-Pin). Nach Modul 10 §Kontext-Eskalation ist die
dritte Wiederholung einer Klasse ein Signal, Guide oder Sensor nachzuziehen statt nur zu
melden. Kein Gate deckt Faktentreue in Planungsdokumenten ab — `d-check` prüft Links,
Anker und IDs, nicht ob eine Zahl im Fließtext stimmt. Als benannte Lücke an die Planung
zurückgegeben (Kandidat für `open/`); dieser Report ist der Beleg.

**Nachtrag 2026-07-17 — die Klasse traf diesen Report selbst.** Die erste Fassung
behauptete unter R-1/R-2 „zwei von drei Linsen" hätten gegen den falschen Baum
gemessen; nachgezählt war es **eine** Linse, zweimal. Es wurden Findings gezählt und
Linsen geschrieben — dieselbe Fehlerklasse, im Absatz über diese Fehlerklasse,
begangen vom Orchestrator des Laufs. Korrigiert oben. Das schärft den Befund eher, als
es ihn entkräftet: Die Klasse überlebt bis in ein Dokument, dessen ausdrücklicher
Zweck ihre Bekämpfung ist, weil **nichts sie mechanisch fängt**. Ein Prosa-Zähler
(„zwei von drei") ist für jedes Gate dieses Repos unsichtbar. Das ist der stärkste
verfügbare Beleg dafür, dass die Lücke einen Sensor braucht und nicht mehr Sorgfalt.

**Übergabe:** Findings sind in den Plänen verarbeitet (Rückkante Review → Plan). Der
Report ersetzt keine Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11, anderes Prüf-Artefakt, anderer Eingabe-Kontext).
