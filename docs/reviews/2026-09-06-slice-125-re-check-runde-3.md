# Review-Report: slice-125 (Re-Check Runde 3, Konvergenz-Lauf) — 2026-09-06

**Review-Art:** Code — geprüft wird der Nacharbeits-Diff gegen den Report der Vorrunde, gegen den
Slice-Plan, gegen die aktiven ADRs und gegen die Hard Rules (Modul 10 §Drei Review-Arten).
**Nicht** geprüft: DoD-Abhakung und Closure-Notiz §7 — Verifier- bzw. Planner-Arbeit in
getrenntem Kontext ([`AGENTS.md`](../../AGENTS.md) §3.10, Modul 11).

**Runde:** 3 · **Vorrunde:**
[`2026-09-06-slice-125-re-check-nacharbeit.md`](2026-09-06-slice-125-re-check-nacharbeit.md)
(N-1 HIGH · N-2/N-3/N-4 MEDIUM · N-5/N-6 LOW) · **Erst-Report:**
[`2026-09-06-slice-125-planning-modul-review.md`](2026-09-06-slice-125-planning-modul-review.md)

**Gegenstand:** `slice-125` · Commit-Range `a019ea6..94c0080` (vier Commits: `487e326`, `bd25cb7`,
`cd7eaaf`, `94c0080`) auf `main` · 4 Dateien, +24/−12

**Skill:** `.harness/skills/reviewer.md` @ 1.7.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-09-06

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne diese Liste ist der Lauf
nicht reproduzierbar):

- Slice-Plan `slice-125` — als Kennung genannt, weil sein Ort im Lifecycle wandert
  ([`AGENTS.md`](../../AGENTS.md) §3.11)
- Aktive ADRs:
  [`ADR-0024`](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md),
  [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md),
  [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md),
  [`ADR-0017`](../plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)
- Berührte `LH-*`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- `MR`-Einträge: [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  [`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert),
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed),
  [`MR-053`](../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
- [`AGENTS.md`](../../AGENTS.md) Hard Rules — namentlich §3.5, §3.6, §3.7, §3.8, §3.9, §3.10, §3.11
- **Vorherige Findings am gleichen Modul:** die zwei Reports oben sowie das
  Beobachtungs-Register [`BEO-ALL/`](../plan/planning/observations/README.md), namentlich
  [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../plan/planning/observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  und [`zitat-grep-uebersieht-zeilenumbruch-und-markup`](../plan/planning/observations/BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup/observation.md)

## Prüfmittel und Sonden

Jede Aussage unten ist an diesem Stand neu gemessen, keine aus einer Commit-Message oder aus dem
Auftrag übernommen. Alle Läufe gegen **Kopien außerhalb des Arbeitsbaums**
(`git archive <ref> | tar -x -C <kopie>`), `--network none`, Mount `:ro`, `docs-check` mit dem
Digest aus `d-check.mk` (`sha256:e31a372…`), bats mit dem Digest aus `Makefile`
(`BATS_IMAGE`). Der Arbeitsbaum war vor und nach den Läufen sauber
(`git status --porcelain` leer).

| Sonde | Gegenstand | Ergebnis |
|---|---|---|
| **S1** | `--disable`-Satz **vor** `cd7eaaf` (sechs Flags) über einer Kopie mit verletzter Lifecycle-Invariante | `866 Datei(en) geprüft, 1 Befund(e)`, `planning-drift`, Exit **1** |
| **S2** | `--disable`-Satz **nach** `cd7eaaf` (sieben Flags) über derselben Kopie | `0 Befund(e)`, Exit **0** — isoliert |
| **S3** | derselbe Satz über der Ist-Kopie (Kontrolle) | `0 Befund(e)`, Exit **0** |
| **S4** | `--enable hostpaths` (nicht in `modules:`) über der Ist-Kopie | **76 Befunde** `hostpath-forbidden`, Exit 1 — unter S3 stumm, also gattet `modules:` real |
| **S5** | `test/planning-modul-wiring.bats` über der Ist-Kopie | 6× `ok`, Exit 0 |
| **S6** | Fall `273` gegen die **neue** bats-Fassung | `not ok 2/3/4/5/6`, **`ok 1`** — genau die Verteilung, die der neue Kopf behauptet |
| **S7** | Fall `273` gegen die **alte** bats-Fassung (`a019ea6`) | **`ok 5`** — der reparierte Vakuitäts-Bug, rot gesehen |
| **S8** | `planning:`-**Schlüssel** ganz entfernt (nicht nur Rumpf) | `not ok 2/3/4/5/6` — keine der fünf bleibt still |
| **S9** | `roadmap:` auf eine nicht existierende Datei gesetzt | `not ok 2`, Rest `ok` — Test 2 ist der Pin, kein stilles Grün |
| **S10** | Fall `272` (heading auf marker-lose Sektion) | `docs-check` `0 Befund(e)`, Exit 0 — **still**; bats `not ok 3` |
| **S11** | **nur** den N-3-Guard zurückgedreht, Fall `273` angewandt | `# expect:` (Test 6) fällt weiter → `make mutate` bliebe **grün** |
| **S12** | plain `docs-check` (alle sieben Module) über der Ist-Kopie | `866 Datei(en) geprüft, 0 Befund(e)`, Exit 0 |

Die Dateizahl ist kein Erwartungswert; tragend sind Befundzahl, Grund-Code und Exit-Code.

---

## Verdikt je Finding der Vorrunde

| Vorrunde | Kategorie | Verdikt | Beleg an diesem Stand |
|---|---|---|---|
| **N-1** | HIGH | **behoben** | S1/S2 sind der Rot-Nachweis, unabhängig nachgestellt: derselbe Baum, derselbe Digest, nur der Flag-Satz unterscheidet sich — `1 Befund planning-drift`/Exit 1 gegen `0 Befund(e)`/Exit 0. Der Kommentar `Makefile:181-182` sagt jetzt „sieben", und `grep -m1 '^modules:' .d-check.yml` liefert sieben. **Alle d-check-Aufrufe des Repos sind wieder konsistent:** die sieben Rezepte in `d-check.mk` disablen ohnehin erschöpfend, `Makefile:185` ist der einzige selektive und jetzt vollständig. Dass die Selektivität *überhaupt* trägt, ist gemessen und nicht angenommen — S4 zeigt an `hostpaths`, dass ein nicht in `modules:` geführtes Modul unter diesem Flag-Satz stumm bleibt. Die **Form**wahl bleibt als R-2 offen |
| **N-2** | MEDIUM | **behoben** | `harness/README.md:77-78` zieht die Aussage auf das zurück, was auflöst: `closure` → `slice-129`, `waves` → kein Träger. Gemessen: `git grep -ln 'waves' -- 'docs/plan/planning/{open,next,in-progress}/slice-*.md'` nennt nur `slice-125` selbst und `slice-135` (ein Pin-Slice). Der Widerspruch zum Satz vier Zeilen darüber („*was dieser Slice nicht entscheidet*") ist damit aufgelöst |
| **N-3** | MEDIUM | **behoben** | S7 gegen S6 ist der Rot-Nachweis: `ok 5` vorher, `not ok 5` nachher, mit der Meldung „*planning:-Block ist leer — heading-Zusicherung liefe ins Leere*". Der Kopf von `273` zählt jetzt **fünf** fallende Zusicherungen und benennt die sechste (die Aktivierungs-Zusicherung) als unberührt — S6 bestätigt genau diese Verteilung. **Alle sechs Zusicherungen sind vakuitätsfrei**, einzeln gemessen (S6, S8, S9), nicht nur die zwei reparierten. Die Reparatur selbst ist unbewacht → R-3 |
| **N-4** | MEDIUM | **nicht behoben — korrekt unterlassen** | `docs/plan/planning/in-progress/roadmap.md:59` führt weiter „*während `grep -n '^modules:' .d-check.yml` **sechs** führt*". Planner-Artefakt; nicht Gegenstand der Nacharbeit. Reist als Übergabe weiter, jetzt zusammen mit dem vollen Blast-Radius aus R-1 |
| **N-5** | LOW | **behoben** | Der Kopf von `test/planning-modul-wiring.bats:5-8` erklärt den Pfad nicht mehr zur Review-Sache, sondern nennt die Zusicherung und den Fall, der sie pinnt. Beide Hälften gemessen (S10): `docs-check` bleibt bei der Konfigurationsänderung still (`0 Befund(e)`, Exit 0), und `not ok 3` ist genau die `# expect:`-Zeile von `272` |
| **N-6** | LOW | **nicht behebbar** | Betrifft die Message von `ac237dc`, die in der Historie liegt. Kein Diff kann sie ändern; die Klasse geht über die Closure §7 in den Zähler |

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der verbindlichen Single
Source of Truth. Die Felder unten sind nur **gespiegelt**, nicht neu definiert; bei Abweichung
gilt der Skill bzw. dessen Quelle Baseline-Regelwerk `modul-10-review-harness.md`
§Ziel-Form: Reviewer-Skill.

### R-1 — Die Fundmengen-Messung meldet „ein Treffer", während ihre Ausschlüsse elf lebende, von diesem Slice falsch gemachte Stellen tragen — eine davon ist in keiner Runde benannt

- `kategorie`: MEDIUM
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  · [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  · [`AGENTS.md`](../../AGENTS.md) §3.7
- `pfad`: `docs/plan/adr/README.md:83-84` (die nirgends benannte Stelle) · die Messung selbst
  liegt in der Übergabe-Nachricht, in keinem Commit dieses Range
- `befund`: `planning` ist mit `c63ef63` als siebtes Modul dazugekommen — `git show c63ef63^:.d-check.yml`
  führt sechs, `grep -m1 '^modules:' .d-check.yml` führt sieben. Lebend, repo-eigen und von genau
  dieser Änderung falsch gemacht sind **elf** Stellen, nicht eine: `AGENTS.md:325` (Erst-Report
  F-5 a) · `docs/plan/adr/README.md:83-84` · `docs/plan/planning/in-progress/roadmap.md:59` (N-4) ·
  `docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md:319` · sowie
  `open/slice-116:273`, `open/slice-121:68-69`, `open/slice-124:48`, `open/slice-127:44`,
  `open/slice-129:54`, `open/slice-135:137`, `open/slice-139:133`. Zwei davon sind benannt
  (F-5 a, N-4), neun nicht. Der Ausschluss `docs/plan/adr/**` behandelt den **ADR-Index** wie eine
  eingefrorene ADR, obwohl er ein lebendes Register ist, das nach
  [`AGENTS.md`](../../AGENTS.md) §5 mit jeder neuen ADR fortgeschrieben wird und nach §3.8 dem
  **Architect** gehört (nicht §3.4). Er wäre der Messung zusätzlich durch die Methode entgangen:
  die Liste bricht nach `codepaths,` um, ein zeilenweiser `grep` auf die Sechser-Liste trifft sie
  nicht — dieselbe Klasse, die das Register als
  [`zitat-grep-uebersieht-zeilenumbruch-und-markup`](../plan/planning/observations/BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup/observation.md)
  führt.
- `verifizierbar`: ja, textuell —
  `git grep -nE 'sechs[[:space:]]*(\*\*)?[[:space:]]*Module|links, anchors, ids, matrix, codepaths' -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' ':!harness/conventions' ':!docs/plan/adr/0*' | grep -v 'spans, planning'`
  gegen `grep -m1 '^modules:' .d-check.yml`. **Kein Gate fängt es:** kein Modul aus `modules:`
  urteilt über den Wahrheitsgehalt einer Prosa-Zahl, und `make comment-claims` hat keine
  Markdown-Datei im Prüfbereich ([`harness/README.md`](../../harness/README.md) §Sensors).
- `klasse`: Fundmengen-Messung meldet ihr Ergebnis ohne die lebenden Instanzen in ihrem Ausschluss

### R-2 — Der reparierte Flag-Satz wählt die driftanfällige von zwei Formen, die dasselbe Repo führt

- `kategorie`: LOW
- `quelle`: Maintainability ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `pfad`: `Makefile:181-185` gegen `d-check.mk:92,96,100,104,108,112`
- `befund`: Die sechs `--enable <modul>`-Rezepte in `d-check.mk` nennen **jedes** übrige Modul des
  gepinnten Bildes im `--disable`-Satz (21 Stück, gemessen an `d-check.mk:100`); eine Erweiterung
  von `modules:` kann sie nicht brechen. `Makefile:185` nennt genau die Module aus `modules:` und
  ist damit an eine Ableitung gekoppelt, die wandert — das achte Modul reißt die Isolation erneut
  auf, so wie das siebte sie aufgerissen hat. Kein Sensor hält die zwei Listen zusammen: kein Fall
  in `test/mutations/` und keine `.bats`-Datei nennt `regelwerk-check` oder den `--disable`-Satz
  (`grep -rn 'regelwerk-check\|disable planning' test/` liefert nur vier unbeteiligte
  Kommentar-Treffer). Der Kommentar `Makefile:181-182` schreibt die Kopplung als Zahl („*genau die
  sieben Module*") mit hin.
- `verifizierbar`: ja — S4 zeigt den Mechanismus (`hostpaths` fällt mit 76 Befunden, sobald es
  aktiv ist, und ist unter dem Flag-Satz stumm); textuell die zwei `grep` oben. Kein Gate:
  `regelwerk-check` steht nicht in `make gates` (`grep -n '^record-gates:' Makefile`), und das
  `Makefile` liegt dauerhaft außerhalb von `make comment-claims`.
- `klasse`: Zusage neben geänderter Ableitung bleibt stehen

### R-3 — Die N-3-Reparatur ist von keinem gelisteten Mutations-Fall gehalten

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  [`harness/README.md`](../../harness/README.md) §Sensors
- `pfad`: `test/planning-modul-wiring.bats:53-64` gegen `test/mutations/273-planning-block-rumpf-entfernt.sh:3`
- `befund`: S11 misst es direkt: wird **allein** der neue `[ -n "$h" ]`-Guard zurückgedreht und
  Fall `273` angewandt, fällt die im `# expect:` benannte Zusicherung (Test 6) weiterhin — der
  Fall gilt als bestanden und `make mutate` bliebe grün, während Test 5 wieder über der leeren
  Menge wahr wäre. Von den sechs Zusicherungen der Datei sind vier `# expect:`-Ziel eines Falls
  (Test 1 ← `269`, Test 3 ← `270`/`272`, Test 4 ← `271`, Test 6 ← `273`); Test 2 und der gerade
  reparierte Test 5 sind es nicht — nach der eigenen Feststellung des Repos „*wer keinen Fall in
  `test/mutations/` hat, ist unbewacht*".
- `verifizierbar`: ja — S11, sowie
  `sed -n 's/^# expect: //p' test/mutations/27{0,1,2,3}-*.sh test/mutations/269-*.sh` gegen die
  sechs `@test`-Titel. §3.6 verlangt das rot gesehene Gegenbeispiel, und das liegt vor (S7); ein
  gelisteter Fall ist davon eine getrennte Frage.
- `klasse`: reparierter Wächter ohne eigenen gelisteten Fall

### R-4 — Die Begründung, mit der `.d-check.yml:23` stehen bleibt, nennt eine Ableitung, die sie nicht gemessen hat

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
- `pfad`: `.d-check.yml:23` · die Begründung in der Übergabe-Nachricht
- `befund`: Der Satz „*Der Ausschluss wirkt datei-weit ueber alle fuenf Module*" bleibt stehen mit
  der Begründung, er stamme aus `slice-081` und damit aus der Zeit **vor** `matrix`/`codepaths`/`spans`.
  Gemessen trifft das nicht zu: `git log -S'ueber alle fuenf Module' -- .d-check.yml` nennt genau
  einen Commit (`b902b60`), und `git show b902b60^:.d-check.yml | grep -m1 '^modules:'` liefert
  bereits `[links, anchors, ids, matrix, codepaths, spans]` — sechs. `matrix` kam mit `c615da7`
  ([`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids))
  lange davor. Die Zeile war am Tag ihrer Entstehung um eins falsch, nicht später falsch geworden.
  Das **Verdikt** (nicht von `slice-125` verursacht, bleibt stehen) trägt trotzdem — es ist die
  Begründung, die nicht trägt.
- `verifizierbar`: ja, textuell — die zwei `git`-Aufrufe oben. Kein Gate liest die Provenienz
  eines Kommentars.
- `klasse`: Zusage neben geänderter Ableitung bleibt stehen

---

## Negativbefunde

- **geprüft, ohne Befund: der `Makefile`-Fix in beide Richtungen.** S1 und S2 unterscheiden sich
  nur im Flag-Satz und liefern gegenläufige Verdikte; S3 ist die Kontrolle am unverletzten Baum.
  Der Rot-Nachweis des Auftrags ist damit unabhängig nachgestellt, nicht übernommen.
- **geprüft, ohne Befund: die Selektivität des Flag-Satzes trägt wirklich.** S4 belegt an
  `hostpaths`, dass ein nicht in `modules:` geführtes Modul unter diesem Satz stumm bleibt,
  obwohl es aktiviert 76 Befunde liefert — die Isolation hängt an `modules:` und nicht an Zufall.
  Die *Form*-Kritik daran steht als R-2 und ist keine Korrektheits-Kritik.
- **geprüft, ohne Befund: alle sechs bats-Zusicherungen auf Vakuität, einzeln.** S6 (leerer
  Rumpf), S8 (Schlüssel ganz weg) und S9 (`roadmap` auf eine nicht existierende Datei) erzeugen
  in keiner Konstellation ein stilles Grün. Test 1 bleibt in S6/S8 bewusst grün — er liest
  `modules:` und nicht den Block; das ist keine Vakuität, sondern der andere Gegenstand, und der
  neue Kopf von `273` sagt genau das.
- **geprüft, ohne Befund: der hart verdrahtete `$ROADMAP` in `setup()`.** Test 5 greppt eine
  Konstante statt des konfigurierten `roadmap`-Werts. Ein stilles Grün entsteht daraus nicht:
  zieht die Roadmap um, fällt entweder Test 2 (der Wert-Pin) oder das `grep` läuft gegen eine
  fehlende Datei und fällt (S9 zeigt die Kopplung). Laut, nicht still — kein Finding.
- **geprüft, ohne Befund: die zwei neuen Kommentare gegen [`AGENTS.md`](../../AGENTS.md) §3.7.**
  Der Guard-Kommentar in `planning-modul-wiring.bats:56-58` und der neue Kopf von `273` tragen
  keine Befund-Kennung, keine Slice-Nummer und kein Lauf-Protokoll
  (`grep -cE 'Review-Befund|slice-[0-9]' test/mutations/273-*.sh test/planning-modul-wiring.bats`
  → je 0). Die konditionale Form („*ein leerer Block macht `$h` zum leeren String*") beschreibt
  den Fehlerfall, den der Guard **abfängt** — Klasse *Grenze* —, nicht eine verworfene
  Alternative; dieselbe Form trug schon der `waves`-Guard der Vorrunde.
- **geprüft, ohne Befund: der Kopf von `273` gegen die Wirklichkeit.** „*Fuenf der sechs …
  (roadmap/heading/marker/heading-in-Roadmap/waves fallen); nur die Aktivierungs-Zusicherung …
  bleibt unberuehrt gruen*" — S6 liefert exakt `not ok 2/3/4/5/6` und `ok 1`. Die Vorher-Nachher-Form
  aus dem alten Kopf ist entfallen.
- **geprüft, ohne Befund: der N-2-Satz gegen den Lifecycle.** Kein Slice in `open/`, `next/` oder
  `in-progress/` hat die `waves`-Aktivierung zum Gegenstand; die zwei Treffer auf `waves` sind
  `slice-125` selbst und `slice-135` (d-check-Pin). Die Aussage deckt sich jetzt mit dem Satz vier
  Zeilen darüber.
- **geprüft, ohne Befund: die Ausschlüsse `harness/conventions*` und `docs/plan/adr/0*`.** Beide
  sind zu Recht ausgenommen, und der Beleg steht im Repo: die Einträge des Adaptions-Blocks sind
  append-only eingefroren, und
  [`MR-053`](../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
  §Cutoff sagt für genau diese Klasse „*der Bestand ist kein Arbeitsauftrag, und er ist ohnehin
  append-only eingefroren*"; die nummerierten ADRs sind nach
  [`AGENTS.md`](../../AGENTS.md) §3.4 ab `Accepted` immutabel. Acht `conventions/`-Einträge und
  `ADR-0035:208` tragen die Sechser-Liste und bleiben zu Recht liegen. Nur der **Index** in
  demselben Verzeichnis ist keine ADR → R-1.
- **geprüft, ohne Befund: die Vier-Modul-Prosa ist älterer Bestand.** `AGENTS.md:468`,
  `README.md:94` und `d-check.mk:71` nennen `links/anchors/ids/codepaths` — vier. Diese Stellen
  waren schon vor `c63ef63` falsch (seit `c615da7`, [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids))
  und sind als Arbeitspunkt (6) *Prosa-Aufzählung gegen ihre Config* in
  `roadmap.md:59` geführt, samt der Feststellung, dass `d-check.mk` ein tool-generiertes Fragment
  ist ([`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)) und
  eine andere Reparatur braucht. Nicht dieser Slice.
- **geprüft, ohne Befund: die emittierte Ebene ist unberührt.** Der Diff fasst `internal/` nicht
  an; `internal/emit/templates/d-check.yml:10` bleibt `modules: [links, anchors]`
  ([`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)),
  und `internal/emit/emit_test.go:17` koppelt das fail-closed.
- **geprüft, ohne Befund: keine Gate-Lockerung.** `grep -E '^[[:space:]]+(waves|closure|observations):' .d-check.yml`
  ist leer — der Diff schaltet keine Fähigkeit zu und berührt
  [`AGENTS.md`](../../AGENTS.md) §3.5 nicht. `scan.ignore` und die vier `ignore-refs`-Paare sind
  unverändert.
- **geprüft, ohne Befund: Hard Rules ohne Treffer.** §3.3 (kein `git mv` im Diff), §3.8 (kein
  Architect-Artefakt angefasst — `AGENTS.md`, `harness/conventions*` und `docs/plan/adr/` sind
  nicht im Diff), §3.9 (keine Host-Toolchain; `sed` im Fall-Skript läuft im Mutations-Treiber),
  §3.10 (kein Closure-Artefakt berührt), §3.11 (keine neue Adresse auf ein wanderndes Artefakt —
  `slice-129` steht in `harness/README.md` als Kennung in Inline-Code, die Datei selbst ist
  lebend).
- **geprüft, ohne Befund: die vier Commit-Messages.** Jede trägt das Rollen-Präfix
  `Rolle Implementation:`, eine `Bezug:`-Zeile mit Report-, Hard-Rule- und `LH-*`-Referenz und
  genau ein Anliegen — vier Findings, vier Commits, kein Bündel. Die N-6-Beanstandung der
  Vorrunde wiederholt sich nicht.
- **geprüft, ohne Befund: der enge Prüfbereich ist grün.** S5 (6× `ok`) und S12
  (`866 Datei(en) geprüft, 0 Befund(e)`, Exit 0) sind unabhängig nachgestellt. Der repo-weite
  Gate-Lauf ist Verifier-Sache und hier nicht behauptet.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 3 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Fundmengen-Messung meldet ihr Ergebnis ohne die lebenden
Instanzen in ihrem Ausschluss · Zusage neben geänderter Ableitung bleibt stehen (**2×**, R-2 und
R-4) · reparierter Wächter ohne eigenen gelisteten Fall

Stand der zwei bereits geführten Klassen am Tag dieses Laufs, je neben seinem Kommando:

```sh
ls docs/plan/planning/observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/evidence/*.md | wc -l  # 15
ls docs/plan/planning/observations/BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup/evidence/*.md | wc -l    # 2
```

Keine Erwartungswerte — die Zähler wandern mit dem Register. **Ein Vorgang zählt einmal**
(`modul-06-roadmap.md` §Das Beobachtungs-Register): Runde 1, 2 und 3 sind derselbe Vorgang
`slice-125` und gehören in **einen** Beleg je Klasse.

## Zur Konvergenz-Frage

**Wird eine vierte Runde weitere Instanzen derselben Klasse finden? Ja — und das ist kein Mangel
dieses Slice.** Der Grund steht im Repo selbst: `state.md` der Beobachtung
[`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../plan/planning/observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/state.md)
weist den Ausgang als `geplant` mit der Kennung `slice-153` aus und sagt, was jener Slice **nicht**
schließt: „*Offen bleibt jede Unterklasse, in der die Zusage kein Anker ist — Skript-Ausgabe,
Testname, Prosa-Zahl, Präsens-Satz*". Die Modul-Listen-Nennung ist genau die Unterklasse
*Prosa-Zahl*. Solange kein Sensor sie hält, produziert **jede** Änderung an `modules:` eine neue
Fundmenge, und ein Review findet sie. Von `slice-125` zu verlangen, das zu beenden, hieße, ihm die
Arbeit von `slice-153` aufzuladen.

**Was dieser Slice dagegen schuldet, ist die vollständige Übergabe — und die ist es, die fehlt.**
Die Messung war methodisch an zwei Stellen zu eng: der Ausschluss `docs/plan/adr/**` trennt nicht
zwischen eingefrorener ADR (§3.4) und lebendem, Architect-eigenem Index (§3.8), und ein
zeilenweiser `grep` auf die Modul-Liste findet die umbrochene Form nicht. Beides zusammen hat
`docs/plan/adr/README.md:83-84` unsichtbar gemacht. Die neun unbenannten Stellen aus R-1 sind
damit die belastbare Antwort auf „wo": sie liegen nicht in einem Winkel, den niemand vorhersehen
konnte, sondern in den zwei Verzeichnissen, die der Implementer bewusst ausgenommen hat, ohne zu
sagen, was darin liegt.

**Die Grenze „durch diese Änderung verursacht" vs. „älterer Drift" trägt** — sie ist die richtige
Trennung, und sie ist die einzige, die den Bestand nicht zum Arbeitsauftrag macht
([`AGENTS.md`](../../AGENTS.md) §3.7 Cutoff, [`MR-053`](../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
§Cutoff). `.d-check.yml:23` stehen zu lassen ist richtig; die Zeile ist keine Ausrede, sondern
sauber benannt. Nur die *Begründung* für die Einordnung ist ungemessen (R-4) — die Zeile war schon
bei ihrer Entstehung falsch, nicht erst später.

## Verdikt

**Merge-blockierend: nein.** Der Slice ist für den **Verifier freigegeben.**

**Kein HIGH, und der Diff selbst ist sauber.** Alle vier angegangenen Findings sind behoben, und
zwar gemessen statt gemeldet: N-1 mit gegenläufigen Verdikten über demselben Baum bei identischem
Digest (S1/S2), N-3 mit dem rot gesehenen `ok 5` gegen `not ok 5` (S7/S6), N-5 in beiden Hälften
(S10), N-2 gegen den Lifecycle-Bestand. Die zwei Punkte, die der Auftrag über die Fixes hinaus
gestellt hat, sind beantwortet: es ist **keine** neue Asymmetrie unter den d-check-Aufrufen
entstanden, und **alle sechs** bats-Zusicherungen sind vakuitätsfrei, einzeln geprüft.

**Warum das eine MEDIUM den Übergang nicht aufhält.** R-1 ist real, aber sein Gegenstand liegt
vollständig in **fremden Rollen-Artefakten**: `docs/plan/adr/README.md` und `AGENTS.md` gehören
nach [`AGENTS.md`](../../AGENTS.md) §3.8 dem **Architect**, die acht Lifecycle-Dateien dem
**Planner**. Der Implementer *darf* sie nicht ziehen; ihn darauf zu blockieren wäre ein Deadlock,
kein Qualitätsgewinn — und es wäre genau der vierte, falsche Konflikt-Pfad, den Modul 8 ausschließt
(ein Befund, den niemand beheben darf, hält den Vorgang dauerhaft an). Modul 8 sieht dafür den
anderen Weg vor: **kein Rollenwechsel ohne Übergabe-Artefakt** — und dieser Report ist es. R-1
reist als Übergabe mit, statt den Verifier-Übergang aufzuhalten. R-2, R-3 und R-4 sind LOW und
nach dem Skill („*bei isolierten LOW/INFO-Findings ist die Sequenz Overkill*") ohnehin
Implementer-Ermessen; R-2 und R-3 sind zudem latent, nicht aktuell — heute ist der Flag-Satz
korrekt und der Guard wirksam.

**Übergabe — drei Adressaten, getrennt:**

1. **Implementer:** R-2, R-3, R-4 — annehmen oder begründet ablehnen. Kein Blocker.
2. **Architect** ([`AGENTS.md`](../../AGENTS.md) §3.8): `AGENTS.md:325` und
   `docs/plan/adr/README.md:83-84`. Der Index-Fund ist in **keiner** Runde zuvor benannt worden;
   ohne diesen Report hätte ihn niemand.
3. **Planner** ([`AGENTS.md`](../../AGENTS.md) §3.10): `roadmap.md:59` (N-4),
   `welle-13-…:319` und die sieben Slice-Pläne in `open/` aus R-1 — dazu die Frage, ob die
   Unterklasse *Prosa-Zahl* an `slice-153` hängt oder einen eigenen Schnitt braucht.

Die **Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von dort in den Zähler; die
Klasse *Zusage neben geänderter Ableitung bleibt stehen* steht damit über drei Runden bei einem
Stand, den die Closure als **einen** Beleg für `slice-125` einträgt. Dieser Report ist ein
**Lauf-Beleg** und wird über Läufe hinweg nicht wieder gelesen. Er ersetzt keine Verifikation —
DoD-/Spec-Konformität prüft der Verifier separat (Modul 11, anderer Eingabe-Kontext).
