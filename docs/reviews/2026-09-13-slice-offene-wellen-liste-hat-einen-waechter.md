# Review — slice-offene-wellen-liste-hat-einen-waechter

**Rolle:** Reviewer (`.harness/skills/reviewer.md` v1.7.0) · **Datum:** 2026-09-13 ·
**Lauf:** Runde 1

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Gegenstand** | Commit `ba8698fc` — *„Rolle Implementer: … waves aktiviert, Listen-Haelfte von ‚Offene Wellen' bewacht"* |
| **Diff/Range** | `git show ba8698fc` (7 Dateien, +150/−35) |
| **Slice-Plan** | [`docs/plan/planning/in-progress/slice-offene-wellen-liste-hat-einen-waechter.md`](../plan/planning/in-progress/slice-offene-wellen-liste-hat-einen-waechter.md) |
| **`LH-*`** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| **Aktive ADRs im Bezug** | [ADR-0044](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) (§Konsequenzen — Anlass), [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) (Gate-*Anheben* über den Steering-Loop) |
| **Hard Rules** | [`AGENTS.md`](../../AGENTS.md) §3.5 (keine Senkung ohne ADR), §3.6 (kein Zusage ohne rot gesehenes Gegenbeispiel), §3.7 (ein Kommentar beschreibt, was da ist), §3.8 (Architect-Eigentum), §3.9 (Docker-only) |
| **Vorherige Findings am gleichen Modul** | [`2026-09-06-slice-125-planning-modul-review.md`](2026-09-06-slice-125-planning-modul-review.md) F-6 (*Begründung der `waves`-Nichtaktivierung zitiert das Werkzeug ohne den Schalter, der sein Verhalten bestimmt*) und F-8 (*die `waves`-Zusicherung ist über der leeren Menge wahr*); [`2026-09-06-slice-125-re-check-nacharbeit.md`](2026-09-06-slice-125-re-check-nacharbeit.md) N-2 |
| **Nicht erhalten / nicht Gegenstand** | DoD-Abhakung (Verifier), `make gates`-Lauf (Verifier) |

**Mess-Umgebung.** Alle d-check-Sonden liefen gegen **Kopien außerhalb des Repos**
(`git archive <ref> \| tar -x`), netzlos (`--network none`), Mount `:ro`, mit dem Digest aus
[`d-check.mk`](../../d-check.mk) (`ghcr.io/pt9912/d-check@sha256:e31a372b…d4641`, v0.74.1);
bats-Sonden gegen dasselbe gepinnte Bild wie `make test-bats`. **Das Repo ist unverändert**
(`git status --porcelain` leer vor und nach dem Lauf, `HEAD` = `ba8698fc`). Einzige geschriebene
Datei ist dieser Report.

---

## Findings

### HIGH-1 — Beide Deckungs-Träger behaupten eine Blindheit, die die Fähigkeit nicht hat — an genau der Stelle der deklarierten Repo-Konvention

- `kategorie`: **HIGH**
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · [`AGENTS.md`](../../AGENTS.md) §3.6 · §3.7
- `pfad`: [`.d-check.yml:41-43`](../../.d-check.yml) · [`harness/sensors/docs-check.md:32-44`](../../harness/sensors/docs-check.md)
- `befund`: Beide Träger sagen, `waves` lese außerhalb von *Offene Wellen* / *Abgeschlossene
  Wellen* nichts — die Config im Wortlaut *„bleibt `waves` blind"*, die Sensor-Prosa *„liest
  `waves` nichts"*, jeweils mit der Vorschau-Tabelle *„## Nächste Wellen"* als Beispiel. Gemessen
  liest die Fähigkeit die **erste Spalte** dieser Tabelle und meldet `wave-preview-exists`, sobald
  zu der dort genannten Kennung eine Datei existiert — verlinkt wie unverlinkt. Der Grund-Code
  `wave-preview-exists` kommt in **keinem** der beiden Träger vor
  (`grep -o 'wave-[a-z-]*' .d-check.yml harness/sensors/docs-check.md | sort -u` → `wave-drift`,
  `wave-results-missing`, `wave-unregistered` — drei von vier).
- `verifizierbar`: **ja** — d-check-Trockenlauf, hier gefahren:

  ```sh
  # Kopie von HEAD, eine flache Welle-Datei welle-77 angelegt, Zeile in die
  # Vorschau-Tabelle "## Naechste Wellen" (Spalte 1) eingehaengt, KEIN Zeiger
  # unter "## Offene Wellen" — der Zustand, den roadmap.md §Naechste Wellen
  # ausdruecklich erlaubt.
  docker run --rm --network none -v "$KOPIE:/repo:ro" \
    ghcr.io/pt9912/d-check@sha256:e31a372b66dbde26305982424854cfce7c9ab7ce555a94debeee7ee26e6d4641 \
    -disable links
  ```

  ```text
  docs/plan/planning/in-progress/roadmap.md:11  welle-77  wave-drift  in docs/plan/planning liegt
    das flache Wellendokument welle-77, aber der Abschnitt „## Offene Wellen“ nennt es nicht
  docs/plan/planning/in-progress/roadmap.md:37  welle-77  wave-preview-exists  Vorschau-Zeile nennt
    welle-77, für die bereits eine Datei existiert — eine geplante Welle steht in der Vorschau und
    nirgends sonst
  d-check: 1261 Datei(en) geprüft, 2 Befund(e)
  ```

  Vier weitere Lagen grenzen die Wirkung ein, alle gegen denselben Digest und netzlos:

  | Lage | Ergebnis (`-disable links`) |
  |---|---|
  | Datei flach + Zeiger unter *Offene Wellen* **und** Spalte 1 der Vorschau | **1 Befund** — `wave-preview-exists` |
  | Datei flach + **unverlinkter** Name in Spalte 1 der Vorschau | **1 Befund** — `wave-preview-exists` |
  | Datei flach + Nennung in **Spalte 3** (*Wichtigste Slices*) der Vorschau | **0 Befund(e)** |
  | **Toter** Vorschau-Zeiger `welle-88` ohne Datei (die im Text zitierte Messung) | **0 Befund(e)** |

  Die letzte Zeile ist die Messung, auf die sich beide Träger berufen — sie ist über der **leeren
  Menge** wahr: `wave-preview-exists` prädiziert *„für die bereits eine Datei existiert"*; ein
  toter Zeiger hat keine, das Prädikat ist trivial falsch. Das ist exakt die Klasse, die
  §6 Risiko 1 des Slice-Plans für den `dir`-Schalter vorab benannt hat
  ([`BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr`](../plan/planning/observations/BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr/observation.md),
  **1** Beleg zum 2026-09-13, `ls …/evidence/*.md | wc -l`) — sie ist am zweiten Schalter
  eingetreten, nicht am vorab benannten.

  Zusätzlich ist der Satz *„der einzige gefahrene Reproduktionsversuch deckte den korrekt an beiden
  Stellen verlinkten Zustand ab und blieb grün"*
  ([`harness/sensors/docs-check.md:41-43`](../../harness/sensors/docs-check.md)) als geschrieben
  widerlegt: dieser Zustand ist Zeile 1 der Tabelle oben und meldet **1 Befund**.

- `klasse`: **Zusicherung über der leeren Menge wahr** — eine Blindheits-Aussage, gemessen an einem
  Fall, in dem das Prädikat des Grund-Codes gar nicht greifen kann
  ([`BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr`](../plan/planning/observations/BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr/observation.md);
  Nachbarklasse
  [`BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../plan/planning/observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md),
  **2** Belege — die Vorrunde F-6 am selben Modul ist dort schon gebucht).
- **Failure-Szenario:** Der nächste Wellen-Schnitt legt die Plan-Datei an und verlinkt sie in
  *Nächste Wellen* — der von `roadmap.md` §Nächste Wellen wörtlich erlaubte Zustand. `make gates`
  wird rot mit zwei Befunden. Wer die Ursache sucht, liest den Begründungs-Kommentar direkt über
  dem Schlüssel und findet dort die Zusage, dass `waves` genau diese Stelle nicht liest.

### HIGH-2 — Die Aktivierung entscheidet die als offen übergebene Abweichungs-Frage faktisch, und das Übergabe-Artefakt sagt das Gegenteil

- `kategorie`: **HIGH**
- `quelle`: Slice-Plan §1 (*„Ob die Abweichungs-Frage mit der Aktivierung entfällt oder vorher einen
  Eintrag braucht, entscheidet dieser Slice nicht"*), §4 Rückführung `in-progress → open`,
  §6 Risiko 3 · [`AGENTS.md`](../../AGENTS.md) §3.8 ·
  [`welle-13`](../plan/planning/welle-13-regeln-bekommen-ihren-sensor.md) §1
- `pfad`: [`.d-check.yml:61-63`](../../.d-check.yml) (`waves: {dir, mode: many}`) und die
  Commit-Message-Zeile *„Nicht entschieden (Uebergabe an Architect, Slice-Plan §6 Risiko 3)"*
- `befund`: Die Abweichung dieses Repos lautet *„Welle-Datei geschnitten vor Eintritt des
  Start-Triggers"*. Mit der Aktivierung ist genau dieser Zustand gate-rot (Messung in HIGH-1,
  Zeile 1 und 2 der Tabelle: `wave-drift` **und** `wave-preview-exists`). Die Frage ist damit
  beantwortet — die Abweichung besteht nicht fort, sie ist verboten —, und zwar in dem Lauf, dem
  der Plan das Beantworten ausdrücklich untersagt. Das an den Architect übergebene Artefakt trägt
  die gegenteilige Tatsachenbehauptung (HIGH-1), sodass die Rückführungs-Bedingung aus §4 nicht
  greifen kann: Sie hängt an einer Antwort, deren Grundlage falsch beschrieben ist. Ein lebendes
  Planungs-Artefakt dieses Repos hatte die Anforderung an genau diesen Sensor vorab formuliert —
  [`welle-13`](../plan/planning/welle-13-regeln-bekommen-ihren-sensor.md) §1: *„Ein Sensor nach
  `slice-125` muss diese Abweichung tragen, sonst meldet er einen legitimen Zustand als Drift"*,
  daneben die damalige Messung *„`planning` mit der `waves`-Fähigkeit und `mode: many` → **4**
  (2 × `wave-drift`, 2 × `wave-preview-exists`, je auf `welle-11` und `welle-13`)"*. Der gelieferte
  Sensor trägt sie nicht.
- `verifizierbar`: **ja** — dieselbe Sonde wie HIGH-1; der heutige Bestand ist nur deshalb grün,
  weil in Spalte 1 der Vorschau-Tabelle derzeit **kein** Name mit Datei steht
  (`sed -n '/^## Nächste Wellen/,/^## /p' docs/plan/planning/in-progress/roadmap.md | grep -c '^| \[welle-'`
  → **0**, kein Erwartungswert).
- `klasse`: **Aktivierung entscheidet eine ausdrücklich offengelassene Frage** — verwandt mit
  [`BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../plan/planning/observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md):
  hier existiert das Trägerartefakt, trägt aber die falsche Tatsachengrundlage.
- **Failure-Szenario:** Der Architect entscheidet auf Grundlage des Übergabe-Textes, die Abweichung
  sei von der Aktivierung unberührt, und setzt (oder verwirft) einen Adaptions-Eintrag gegen eine
  Wirkung, die es so nicht gibt. Der nächste Wellen-Schnitt läuft in das Rot aus HIGH-1.

### HIGH-3 — `test/mutations/273` ist verwaist: der Fall zitiert die gelöschte Zusicherung, `make mutate` meldet Befund

- `kategorie`: **HIGH** (Kontext-Eskalation: der Defekt sitzt im Sensor-/Gate-Pfad, und
  [`harness/README.md`](../../harness/README.md) §Safety and scope boundaries führt `make mutate`
  als Pro-Push-Lauf der CI)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · [`harness/README.md`](../../harness/README.md)
  (*„GitHub Actions fährt `make gates` + `make smoke` + `make mutate` auf frischem Klon pro
  Push/PR"*)
- `pfad`: [`test/mutations/273-planning-block-rumpf-entfernt.sh:3`](../../test/mutations/273-planning-block-rumpf-entfernt.sh) ·
  [`test/planning-modul-wiring.bats`](../../test/planning-modul-wiring.bats) (entfernte Zusicherung)
- `befund`: Fall 273 trägt
  `# expect: planning: waves bleibt aus (Entscheidung dokumentiert in harness/README.md)` — der
  Titel der Zusicherung, die dieser Diff löscht. `run_case` verlangt nach dem Rot zusätzlich, dass
  die **Fehlschlag**-Ausgabe genau diese Zeichenkette trägt
  ([`harness/tools/mutate.sh:698-699`](../../harness/tools/mutate.sh)); sie kann es nicht mehr. Der
  Fall meldet `rot, aber '<expect>' faellt nicht — falscher Grund`. Der Umsetzungs-Lauf hat den
  vollen `make mutate` ausdrücklich nicht gefahren (*„kein `make mutate`-Volllauf"*, Commit-Message)
  — genau der Lauf, der den Defekt gezeigt hätte.
- `verifizierbar`: **ja** — `make mutate` (Nicht-Gate-Verify). Hier per Sonde nachgestellt: Fall 273
  auf eine Kopie von `HEAD` angewandt, `test/` im gepinnten bats-Bild gefahren, die
  Fehlschlag-Zeilen gegen die `# expect:`-Zeichenkette gehalten:

  ```sh
  ( cd "$KOPIE" && bash test/mutations/273-planning-block-rumpf-entfernt.sh )
  docker run --rm --network none -v "$KOPIE":/code:ro -w /code \
    bats/bats@sha256:e8f18e0acd4ea933bf019130b85033be75e8ce081db299e93578de83d7874e33 test/ > out
  grep -E -- '^not ok [0-9]+' out | grep -qF -- \
    'planning: waves bleibt aus (Entscheidung dokumentiert in harness/README.md)'   # Exit 1
  ```

  Gefallen sind stattdessen acht andere Zusicherungen (`not ok 34/35/36/160/209/210/211/212`);
  keine trägt den zitierten Titel.
- `klasse`: **Mutations-Fall überlebt die Umbenennung seines Wächters**
  ([`BEO-ALL/mutations-fall-ueberlebt-die-umbenennung-seines-waechters`](../plan/planning/observations/BEO-ALL/mutations-fall-ueberlebt-die-umbenennung-seines-waechters/observation.md),
  **1** Beleg zum 2026-09-13; dieser Vorgang wäre der zweite). Der Löschfall ist die Variante der
  Umbenennung: derselbe Kopplungsbruch an der `# expect:`-Zeile, dieselbe laute Fehlerrichtung.
- **Failure-Szenario:** Der nächste Push macht CI rot. Die Meldung nennt einen
  Buchhaltungs-Grund, keine Sache — genau die Gewöhnung ans Rot, die der Registereintrag als
  Schaden beschreibt.

### MEDIUM-1 — Ein lebender Plan in `open/` behauptet weiter, `waves` sei im Dogfood aus; keine Übergabe nennt ihn

- `kategorie`: **MEDIUM**
- `quelle`: [`MR-054`](../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  (Kriterium *Erprobung im Dogfood*) · [`AGENTS.md`](../../AGENTS.md) §3.8 (die Rollen-Grenze, die
  hier eine **Übergabe** statt einer Änderung verlangt)
- `pfad`: [`docs/plan/planning/open/slice-210-planning-modul-im-emittierten-doc-gate.md:101`](../plan/planning/open/slice-210-planning-modul-im-emittierten-doc-gate.md)
- `befund`: Der Ausschluss-Punkt dort lautet *„`waves` ist auch im Dogfood aus (die dokumentierte
  Abweichung dieses Repos)"*. Beides ist seit `ba8698fc` falsch. Die Datei ist ein **lebendes**
  Planungs-Artefakt (Lifecycle `open/`), kein Zeitdokument; sie gehört dem Planner, deshalb ist
  ihre Berichtigung keine Implementer-Arbeit — wohl aber ihre **Nennung** als Übergabe. Weder
  Commit-Message noch Slice-Plan §1 nennen sie; §1 führt `slice-210` nur als Nicht-Adresse für die
  emittierte Ebene.
- `verifizierbar`: **nein** am Gate — nachprüfbar mit
  `git grep -n 'waves' -- docs/plan/planning/open/slice-210-*.md` gegen
  `grep -n 'waves:' .d-check.yml`.
- `klasse`: **Übergabe an andere Rolle ohne Träger-Artefakt**
  ([`BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../plan/planning/observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)).
- **Failure-Szenario:** `slice-210` prüft nach `MR-054` die Erprobung im Dogfood als Aufnahme-Kriterium
  für das emittierte Doc-Gate und liest in seinem eigenen §1, `waves` sei dort aus — der Slice
  schließt eine Fähigkeit aus, deren Aufnahme-Kriterium inzwischen erfüllt ist.

### MEDIUM-2 — Zwei der vier neuen Zusicherungen tragen keinen Mutations-Fall

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (*„wer keinen Fall in `test/mutations/` hat, ist
  unbewacht"*)
- `pfad`: [`test/waves-modul-wiring.bats:47-53`](../../test/waves-modul-wiring.bats) (*„waves ist
  ueber dir aktiviert"*) und `:60-68` (*„der konfigurierte waves.dir existiert als Verzeichnis"*)
- `befund`: Angewandt und einzeln gemessen (bats im gepinnten Bild, Kopie außerhalb des Repos):

  | Fall | not ok | Zusicherung 1 | Zusicherung 3 |
  |---|---|---|---|
  | `319-waves-dir-entfernt` | 2, 3 | **grün** | rot — aber über die Leer-Vorprüfung, nicht über `[ -d … ]` |
  | `320-waves-mode-auf-one-zurueckgesetzt` | 4 | **grün** | **grün** |
  | `321-waves-dir-anderer-pfad` | 2 | **grün** | **grün** |

  Zusicherung 1 fällt unter **keinem** der drei Fälle; ihr einziges Gegenbeispiel wäre das
  Entfernen des ganzen `waves:`-Blocks, und dafür existiert kein Fall (ich habe es als Sonde
  gefahren: bats rot, `docs-check` **still grün** bei `0 Befund(e)`). Das `[ -d "$REPO/$d" ]`-Prädikat
  der Zusicherung 3 wird von keinem Fall erreicht: 319 bricht davor in der Leer-Vorprüfung ab, 321
  zeigt auf `docs/plan/planning/done`, das existiert. Die Kopfzeile von 321 nennt als Wirkung
  *„gegen den falschen Baum gebunden"* — die Zusicherung, die das messen würde, bleibt dabei grün;
  gehalten wird die Mutation allein von der Literal-Gleichheit in Zusicherung 2.
- `verifizierbar`: **ja** — die drei Fälle einzeln gegen `test/waves-modul-wiring.bats`; die
  Abdeckungs-**Lücke** selbst meldet kein Lauf (`make mutate` urteilt über seinen Fall-Satz, nicht
  über dessen Vollständigkeit).
- `klasse`: **Neuer Wächter ohne Mutations-Fall**
  ([`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../plan/planning/observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md),
  **5** Belege zum 2026-09-13; deren `state.md` weist ausdrücklich dem Review die Trägerschaft zu).
- **Failure-Szenario:** Zusicherung 1 ist die einzige, die das vollständige Verschwinden des
  `waves:`-Blocks meldet — der Zustand, in dem `docs-check` still grün wird. Verliert sie ihre
  Zähne, spricht kein Lauf davon.

### LOW-1 — Der Diff liefert einen Wächter, den §3 des Plans ausdrücklich nicht vorsieht

- `kategorie`: **LOW**
- `quelle`: Slice-Plan §3 (*„Kein Test-Eintrag, und das ist kein Vergessen … Ein `*_test.go` oder
  `*.bats` daneben hielte die Konfiguration gegen eine zweite Fassung ihrer selbst"*) · §1
  (*„Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan **geändert**"*)
- `pfad`: [`test/waves-modul-wiring.bats`](../../test/waves-modul-wiring.bats) (neu, 72 Zeilen)
- `befund`: Die Änderungs-Tabelle in §3 führt **drei** Dateien; geliefert sind sieben, darunter
  genau die Bauform, gegen die §3 argumentiert — vier Zusicherungen, die Config-Skalare gegen
  Literale halten. Inhaltlich ist der Wächter berechtigt: Fall 319 belegt, dass `docs-check` ohne
  `dir` still grün bleibt (gemessen: `1260 Datei(en) geprüft, 0 Befund(e)`), es gibt also eine
  Stelle, die nur ein solcher Test erreicht. Der Plan sagt das Gegenteil, und die Abweichung ist
  nirgends als Plan-Änderung markiert.
- `verifizierbar`: **nein** — Abgleich Plan §3 gegen `git show --stat ba8698fc`.
- `klasse`: **Geliefertes Artefakt widerspricht der Begründung im Plan-Abschnitt** (Nachbar von
  [`BEO-ALL/out-of-scope-und-doku-dod-widersprechen-sich`](../plan/planning/observations/BEO-ALL/out-of-scope-und-doku-dod-widersprechen-sich/observation.md)).

### LOW-2 — Der Rumpf-Kommentar von Fall 273 beschreibt einen Bestand, den es nicht mehr gibt

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7 (ein Kommentar beschreibt, was da ist — Skript-Scope)
- `pfad`: [`test/mutations/273-planning-block-rumpf-entfernt.sh:6-15`](../../test/mutations/273-planning-block-rumpf-entfernt.sh)
- `befund`: Der Kommentar rechnet *„Acht der zwoelf Zusicherungen (beide Wiring-Dateien zusammen)"*
  vor und nennt darin die `waves`-Zusicherung als fallenden Wächter. Es sind jetzt drei
  Wiring-Dateien, und die genannte Zusicherung existiert nicht mehr. Die Datei wurde von diesem
  Diff nicht angefasst — sie ist aber der unmittelbare Kollateralschaden von HIGH-3 und gehört
  in dieselbe Nacharbeit.
- `verifizierbar`: **nein** — Abgleich des Kommentars gegen `ls test/*-modul-wiring.bats`.
- `klasse`: **Kommentar beschreibt abwesenden Text** ([`AGENTS.md`](../../AGENTS.md) §3.7).

### INFO-1 — Die Datei-Zahl der Commit-Message stammt vom Vorgänger-Baum

- `kategorie`: **INFO**
- `quelle`: [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  (der Zahl-Beleg bindet die Commit-Message)
- `pfad`: Commit-Message `ba8698fc`, *„`d-check: 1259 Datei(en) geprueft, 0 Befund(e)`"*
- `befund`: Über `ba8698fc^` reproduziert die Zahl (`1259 Datei(en), 0 Befund(e)`), über `HEAD`
  nicht (`1260 Datei(en), 0 Befund(e)`). Der Trockenlauf lief also über dem Bestand **vor** dem
  Commit — was der DoD-Punkt (1) so verlangt (*„über dem unveränderten Bestand"*). Das **Verdikt**
  (`0 Befund(e)`, Exit 0) reproduziert über beiden Bäumen; nur die Zahl tut es nicht, und die
  Message sagt nicht, gegen welchen Baum sie gemessen ist.
- `verifizierbar`: **ja** — beide Läufe oben, gegen denselben Digest.
- `klasse`: **Zahl ohne den Baum, an dem sie gemessen ist.**

### INFO-2 — DoD-Punkt (3) verlangt wörtlich eine Aussage, die falsch ist; der Lauf hat sie zu Recht verweigert

- `kategorie`: **INFO**
- `quelle`: Slice-Plan §2 Liefer-Punkt (3)
- `pfad`: Slice-Plan §2, Zeilen 182–186
- `befund`: Der DoD-Punkt verlangt die Prosa *„Richtung B — ein Zeiger ohne Datei — fällt über das
  Modul `links` (`target-missing`), nicht über `waves`"*. Gemessen ist das falsch (siehe
  Negativbefund N-2): Ein Zeiger ohne passende flache Datei fällt unter `waves` als `wave-drift`,
  auch bei `-disable links`. Der Umsetzungs-Lauf hat die Korrektur gefahren und geschrieben — das
  ist [`AGENTS.md`](../../AGENTS.md) §3.6 richtig angewandt. Der DoD-Punkt selbst ist damit
  unerfüllbar-wie-geschrieben und ist ein **Planner**-Nachzug, kein Implementer-Fix
  ([`AGENTS.md`](../../AGENTS.md) §3.10: die ausführende Rolle schreibt ihr Abnahmekriterium nicht
  um).
- `verifizierbar`: **ja** — siehe N-2.
- `klasse`: **Abnahmekriterium enthält eine widerlegte Tatsachenbehauptung.**

---

## Negativbefunde (geprüft, ohne Befund)

- **N-1 — Richtung A ist real rot.** Zeiger auf `welle-13` aus *Offene Wellen* entfernt, Datei
  bleibt flach → `roadmap.md:11 welle-13 wave-drift`, `1 Befund(e)`. Reproduziert die
  Commit-Message-Angabe (dort `1259`, hier `1260` Dateien — siehe INFO-1).
- **N-2 — Die Korrektur an Richtung B stimmt.** Zeiger `welle-88` unter *Offene Wellen* ohne flache
  Datei → mit `links`: **2 Befunde** (`wave-drift` + `target-missing`), mit `-disable links`:
  **1 Befund** (`wave-drift`). `waves` trägt die Richtung eigenständig; die Plan-Annahme
  *„B fällt nur über `links`"* ist widerlegt, und die gelieferte Prosa sagt das jetzt korrekt.
- **N-3 — Der `done/`-Sonderfall der Sensor-Prosa stimmt.** Zeiger unter *Offene Wellen* auf eine
  **existierende** Datei in `done/` → `wave-drift`, mit und ohne `links` identisch.
- **N-4 — Die Nebenwirkung auf *Abgeschlossene Wellen* ist real und richtig benannt.** Registerzeile
  entfernt → `wave-unregistered` (`…/done/welle-14-results.md` liegt im Ruheort, das Register nennt
  sie nicht); erfundene Registerzeile `welle-99` → `wave-results-missing`. Beide Grund-Codes stehen
  wortgleich in beiden Trägern.
- **N-5 — Die Inertheits-Aussage stimmt.** Ohne `dir` meldet der Lauf `1260 Datei(en) geprüft,
  0 Befund(e)` über dem unveränderten Doku-Bestand; die Aussage *„ohne gesetztes `dir` bleibt die
  Fähigkeit inert"* ist gemessen und trägt.
- **N-6 — Die drei Mutations-Fälle haben Zähne.** Jeder färbt die in seinem `# expect:`-Kopf
  genannte Zusicherung rot (319 → Nr. 2, 320 → Nr. 4, 321 → Nr. 2), jeweils einzeln gegen eine
  frische Kopie gefahren. Die Grenze dieser Aussage steht in MEDIUM-2.
- **N-7 — Der tote `harness/README.md`-Zeiger ist genau einmal gezogen.**
  `grep -c 'harness/README.md' .d-check.yml` → **9** vor, **8** nach dem Commit; die drei im
  `planning:`-Kommentar verbleibenden Zeiger (Zeilen 28, 32, 35) gehören sämtlich zur
  `closure`-Fähigkeit. Deckt sich mit der Abgrenzung in Plan §1.
- **N-8 — Keine Gate-Lockerung.** `modules:` unverändert bei acht Einträgen, `scan.ignore`
  unverändert, die sieben `ignore-refs`-Paare unverändert (nur Zeilennummern verschoben). §3.5
  ist nicht berührt; die Aktivierung ist ein **Anheben** und läuft nach
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  über den Steering-Loop, korrekt ohne ADR.
- **N-9 — Kein Produkt-Code berührt.** `git show --stat ba8698fc` führt ausschließlich
  `.d-check.yml`, `harness/sensors/docs-check.md` und `test/**`; `internal/`, `cmd/` und
  `harness/tools/` sind unberührt. Die Schicht-Abgrenzung aus Plan §1 hält.
- **N-10 — Die emittierte Ebene ist unberührt.** `internal/emit/templates/d-check.yml` steht nicht
  im Diff; die Dogfood-/Emittiert-Trennung aus Plan §1 hält.
- **N-11 — Der Wegfall der Negativ-Zusicherung ist ersetzt.** Siehe Urteil zu Punkt 3 unten.
- **N-12 — Kein Verstoß gegen §3.4.** Keine `Accepted`-ADR ist im Diff.

### Ausdrücklich **nicht** geprüft

- **`make gates`, `make test`, `make mutate` als Volllauf** — Verifier-Rolle; ich habe einzelne
  Sonden gegen Kopien außerhalb des Repos gefahren, keinen Gate-Lauf im Arbeitsbaum. HIGH-3 ist
  eine Sonden-Nachstellung von `run_case`, kein `make mutate`-Lauf.
- **DoD-Abhakung** — Verifier-Rolle (`.harness/skills/reviewer.md` §Eingangs-Kontext).
- **Die übrigen 304 Mutations-Fälle** — nur die vier `waves`-berührenden gelesen
  (`grep -ln 'waves' test/mutations/*.sh`). Ob ein anderer Fall auf eine der drei geänderten
  Test-Dateien zielt, habe ich nicht über alle Fälle gemessen.
- **Der Text von `harness/sensors/docs-check.md` unterhalb §Modul `planning`** (die `closure`- und
  `targets`-Absätze) — außerhalb des Diffs.
- **Die Zahlen des Slice-Plans §8** (Register-Zähler, Sub-Area-Prüfungen) — Planner-Artefakt,
  nicht Gegenstand dieses Diffs.
- **Ob `wave-preview-exists` weitere Auslöse-Formen kennt** als die erste Spalte der
  Vorschau-Tabelle — vier Lagen gemessen (HIGH-1), keine Vollständigkeits-Aussage über das Modul.

---

## Kategorie-Summary

| Kategorie | Anzahl | Kennungen |
|---|---|---|
| HIGH | 3 | HIGH-1, HIGH-2, HIGH-3 |
| MEDIUM | 2 | MEDIUM-1, MEDIUM-2 |
| LOW | 2 | LOW-1, LOW-2 |
| INFO | 2 | INFO-1, INFO-2 |

**Wiederkehrende Klassen für die Closure §7** (Slice-Closure trägt sie ins Beobachtungs-Register,
je eine Evidence-Datei pro Klasse für **diesen** Vorgang):

- `BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr` (HIGH-1)
- `BEO-ALL/mutations-fall-ueberlebt-die-umbenennung-seines-waechters` (HIGH-3)
- `BEO-ALL/neuer-waechter-ohne-mutations-fall` (MEDIUM-2)
- `BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt` (MEDIUM-1)

HIGH-2 hat keine passende vorhandene Kennung; ob sie eine neue bekommt oder unter eine vorhandene
fällt, entscheidet die Closure — hier steht die Beobachtung, nicht ihre Einordnung.

---

## Verdikt

**BLOCKIERT** — drei HIGH und zwei MEDIUM.

Die Sache selbst ist richtig gebaut: Die Fähigkeit ist verdrahtet, der Bestand bleibt grün,
Richtung A ist real rot gesehen, und die **Korrektur** an der Plan-Annahme zu Richtung B ist
gemessen und trägt (N-2). Was blockiert, ist nicht die Aktivierung, sondern die Aussage über sie:

1. Beide Deckungs-Träger behaupten, `waves` lese die Vorschau-Tabelle nicht. Gemessen liest sie
   deren erste Spalte und meldet dort einen vierten Grund-Code, den kein Träger nennt (HIGH-1).
2. Genau dort liegt die Abweichung, die dieser Slice ausdrücklich **nicht** entscheiden wollte —
   sie ist mit der Aktivierung entschieden, und das Übergabe-Artefakt an den Architect sagt das
   Gegenteil (HIGH-2).
3. Der Löschung der Negativ-Zusicherung fehlt der Nachzug an ihrem Mutations-Fall; `make mutate`
   und damit CI sind rot (HIGH-3).

**Konflikt-Pfad (Modul 8):** HIGH-2 berührt Architect-Eigentum
([`AGENTS.md`](../../AGENTS.md) §3.8). Er ist **kein** Rollen-Widerspruch im Sinne des
Konflikt-Pfads — der Umsetzungs-Lauf hat die Frage nicht bestritten, sondern für offen gehalten;
widerlegt ist eine **Messung**, nicht eine Entscheidung. Der reguläre Weg Reviewer → Implementer
genügt; das korrigierte Übergabe-Artefakt geht danach an den Architect.
