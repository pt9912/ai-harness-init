# Review: slice-sprung-auf-v6160-wird-vollzogen

**Rolle:** Reviewer (Modul 8/10), frischer Kontext · **Datum:** 2026-10-06 · **Bezug:** `ADR-0078`,
`ADR-0079`, `MR-007`, `MR-033`, `MR-040`, `MR-025`
**Gegenstand:** `b106f3e3..9b909aff` (acht Commits: `f39b62d9`, `2f15a178`, `0605f5ac`, `794ff85b`,
`feb0b83b`, `3cae5736`, `ddb33516`, `9b909aff`) gegen den Slice-Plan
`slice-sprung-auf-v6160-wird-vollzogen` und die genannten Entscheidungen.

## Summary

0 HIGH · 3 MEDIUM · 0 LOW · 1 INFO. Herkunft, Pins, Symlinks, Paare aus `ADR-0079` und die
emittierte Ebene halten. Offen sind zwei Eintrags-Stellen, die keinen der drei Ausgänge aus
`MR-040` tragen, ein gefeuerter Prüf-Trigger in `MR-080` ohne Antwort und die nicht gesetzten
Ausgänge des Vorlagen-Berichts.

## Findings

### M-1 — zwei Aussagen über den alten Baum tragen keinen der drei Ausgänge

- `kategorie`: MEDIUM
- `quelle`: `MR-040` (Ausgang 2 *Tree-Operand*), `MR-025` Setzung 1
- `pfad`: `harness/conventions/MR-056-die-auswahl-im-auto-kontext-haengt-an-der-lauf-beruehrung.md` ·
  „`cat .harness/baseline/v6.13.0/regelwerk/modul-1[13]-*.md | wc -c`" (Z. 83, 88);
  `harness/conventions/MR-080-d-check-pin-v0820-authority-nimmt-eine-liste.md` ·
  „`grep -c 'es gibt nur einen Index' .harness/baseline/v6.13.0/templates/.d-check.yml`" (Z. 103)
- `befund`: Beide Kommandos zeigen auf ein Verzeichnis, das seit `f39b62d9` fehlt. Ausgang 2 aus
  `MR-040` verlangt die Form `git show <ref>:…` und den Grund daneben; der Grund steht nur in der
  Commit-Message von `794ff85b`. Gefahren: das awk-Kommando aus MR-056 gibt jetzt `0.0` statt
  `27,4` aus (`neu=0`, und `ganz` liest über die Symlinks schon `v6.16.0`, also 125120 statt
  119270). Das grep aus MR-080 endet mit Exit 2.
- `verifizierbar`: nein (Inline-Pfade sieht kein Gate, `harness/sensors/docs-check.md` §Modul `codepaths`)
- `klasse`: datierte Messung ohne Tree-Operand-Form

### M-2 — der Prüf-Trigger in `MR-080` ist mit dem Sprung eingetreten, und niemand hat ihn beantwortet

- `kategorie`: MEDIUM
- `quelle`: `MR-080` §Neu zu prüfen; `ADR-0078` Festlegung 2 (Freshness-Durchgang)
- `pfad`: `harness/conventions/MR-080-d-check-pin-v0820-authority-nimmt-eine-liste.md` · „**Neu zu prüfen**, sobald eine adoptierte Baseline einen Index-Teil je Werkzeug als eigene Datei führt (… im Kurs ab `v6.16.0`, hier nicht adoptiert)" (Z. 106–107)
- `befund`: Mit diesem Slice ist `v6.16.0` adoptiert (§Baseline), damit ist die erste Bedingung
  erfüllt, und „hier nicht adoptiert" stimmt nicht mehr. Die Zeile im Übergabe-Artefakt
  (`docs/reviews/2026-10-06-slice-sprung-auf-v6160-wird-vollzogen-freshness.md` Z. 73) sagt
  „bleibt gültig" und begründet das nur mit der emittierten Ebene (`MR-054`). Die Bedingung der
  Dogfood-Ebene, die der Eintrag selbst stellt, wird dort nicht geprüft. Folge: Der nächste Leser
  hält den Trigger für offen, während er schon eingetreten ist. Kein Sensor meldet das.
  Messung: `grep -c 'es gibt nur einen Index' .harness/baseline/v6.16.0/templates/.d-check.yml`
  → 1. Die Folgerung des Eintrags hält also inhaltlich weiter; es fehlt die Antwort auf den Trigger.
- `verifizierbar`: nein
- `klasse`: gefeuerter Eintrags-Trigger ohne Antwort im Freshness-Durchgang

### M-3 — die Ausgänge im Vorlagen-Bericht sind weiter Vorschlag

- `kategorie`: MEDIUM
- `quelle`: `ADR-0018` Festlegung 2; `harness/migration.md` §5
- `pfad`: `docs/migrations/v6.16.0.md` · „sind Vorschlag**; gesetzt werden sie im Architect-Schritt" (Z. 46) und „entscheidet der Architect-Schritt" (Z. 67)
- `befund`: Drei Zeilen tragen weiter „schon erfüllt (Vorschlag)". Den Grenz-Absatz, der die
  Einordnung an den Architect übergibt, beantwortet kein Commit im Diff: `794ff85b` berührt die
  Datei nicht (`git show --stat 794ff85b`). Beim vorigen Sprung lag dieser Schritt als eigener
  Architect-Commit vor (`3ef54b82`). Folge: Schließt der Slice so, friert der Bericht mit
  unentschiedenen Ausgängen ein, und der nächste Sprung liest sie als Ist-Maßstab.
- `verifizierbar`: nein
- `klasse`: Übergabe an den Architect ohne Quittung

### I-1 — Adress-Nachzug in Planner-Plänen im Implementer-Commit

- `kategorie`: INFO
- `quelle`: `AGENTS.md` §3.8 (Absatz *Über andere Norm-Artefakte*)
- `pfad`: `2f15a178` · sieben Pläne in `docs/plan/planning/{open,next}/`
- `befund`: Geändert wurden nur Adressen. Keine Quelle nennt für Slice-Pläne die schreibende
  Rolle, und die Eigentümer-Liste in DoD 1 des Plans führt sie nicht. Zuständig ist der Planner
  bzw. der Architect, falls die Frage geregelt werden soll.
- `verifizierbar`: nein
- `klasse`: Rollen-Zuordnung nicht benannter Artefakte

## Negativbefunde (geprüft, ohne Befund)

- **Herkunft (a):** `make baseline-verify` → `v6.16.0 OK — 54 Dateien`, EXIT 0;
  `make regelwerk-check` → `2301 Datei(en) geprüft, 0 Befund(e)`, EXIT 0. Gegen den Kurs-Klon
  (`git show v6.16.0:lab/…`, nur gelesen) alle 26 Regelwerk-Dateien und alle 28 Vorlagen
  verglichen. Abweichungen gibt es nur in den Zeilen, die der Release beim Packen umschreibt
  (`Quelle:`-Link auf `blob/v6.16.0`, `releases/latest` → `releases/download/v6.16.0`). Sechs
  Träger stehen auf `v6.16.0`: Makefile Z. 25/34, `.d-check.yml` Z. 538/539,
  `internal/fetch/baseline.go` Z. 48/54, `InventurMessTag`. Rot gesehen: die `sources`-URL in
  einer Kopie auf `v6.13.0` gesetzt → `not ok 2 sources-url … traegt den aktuellen BASELINE_TAG`,
  danach zurückgesetzt.
- **Adress-Nachzug (b):** `git grep 'baseline/v6.13.0'` außerhalb der Zeitdokumente. Übrig sind
  M-1, die eingefrorenen ADRs 0074 (Z. 236) und 0077 (Z. 28), beide `Accepted` und als
  Inline-Pfad, die ADRs 0075/0076 (über `ADR-0079`), das Vergleichs-Kommando in ADR-0078 (Z. 62),
  der eigene Plan und `docs/migrations/v6.13.0.md` (ein Bericht über diesen Tag, als Tag-Aussage
  datiert). Alle Symlinks zeigen auf `v6.16.0` (7). Nachgefahren:
  `cat .harness/baseline/v6.16.0/regelwerk/*.md | wc -c` → 384237, 26 Module, `make mutate` → 0,
  `sicherheits- oder korrektheitskritischen` → 1. Alle Werte stimmen mit AGENTS.md §1/§3.6 überein.
- **Rollen-Zuschnitt (c):** `git show --stat` je Commit. Der Architect hat `AGENTS.md`,
  `harness/conventions*` und `harness/migration.md` geändert (ein derivatives Register über ADRs,
  §Zweck „leitet ab", `ADR-0024`), dazu ADR-0061 (Proposed) sowie ADR-0079 mit Index. Der
  Reviewer hat nur den Skill geändert. Der Implementer hat Baum, Pins, Symlinks, Go-Kommentare,
  Sensor-Dateien, Pläne (I-1), `.d-check.yml` und den Bericht geändert. Alle 13 Commits sind noch
  nicht gepusht und gehen in einen Push (`git log origin/main..HEAD`).
- **ADR-0079 (d):** Die Paare stimmen wörtlich mit Festlegung 1 überein, `in` ist je eine Datei.
  Die Deckung 1/2 entspricht den Links (`grep -oE '\]\([^)]*\.harness/baseline'` → 1 bzw. 2).
  Rot gesehen: `# Deckung: 1` am Paar von ADR-0076 → `not ok 2 … 0076 … 2 aufloesende(r) Link(s),
  deklariert sind 1`. Weitere Treffer in den zwei Dateien kann es nicht geben, weil beide
  eingefroren sind.
- **Freshness (e):** Stichprobe gegen die Hunks selbst gelesen. `MR-076`: der Hunk in modul-15
  („Liefert deine Quelle den Wert nicht, ist das keine Abweichung") widerspricht dem Eintrag, das
  Verdikt hält. `MR-075`: die Spec-Straten-Ergänzung (Werkzeug-Festlegungen, Kennung als
  Verfeinerung oder `SPEC-<NNN>`) setzt die Bindungs-Spalte nicht außer Kraft, der Eintrag bleibt
  gültig. `MR-080`: siehe M-2.
- **Vorlagen-Bericht (f):** Die drei Fälle „schon erfüllt" beschränken sich ausdrücklich auf das
  Dogfood (`ls harness/mk` → Exit 2). Die emittierte Ebene, die `harness/mk/*.mk` schreibt
  (`internal/emit/commitmsg.go:28` u. a.), trägt `slice-targets-modul-im-emittierten-doc-gate`
  zusammen mit `ADR-0078` Festlegung 5. Offen bleibt nur M-3.
- **Emittierte Ebene (g):** Der Träger wurde über `make host-bin` gebaut und in ein frisches
  Scratch-Repo gebootstrappt. Ergebnis: `.harness/baseline/v6.16.0`, im Ziel
  `make baseline-verify` → `v6.16.0 OK — 54 Dateien`, `make docs-check` →
  `20 Datei(en) geprüft, 0 Befund(e)`, beide EXIT 0. Das Ziel enthält keine Nennung von `v6.13.0`.
- **Sensoren:** `make gates` einmal am Ende, Ergebnis im Commit dieses Reports.
