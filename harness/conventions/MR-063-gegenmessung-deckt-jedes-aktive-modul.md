# MR-063 — Die Gegenmessung eines d-check-Sprungs gibt jedem aktiven Modul eine Basis und lässt die Symlinks stehen

- **Datum:** 2026-09-17
- **Wirksamkeits-Anlass:** slice-d-check-pin-bringt-die-stilllegungs-bedingung.
- **Geltungsbereich:** die **Gegenmessung auf Nicht-Null-Basis**, die die Strenge-Bilanz eines
  d-check-Sprungs verlangt
  ([`MR-027`](../conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt) und
  [`MR-052`](../conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte),
  je §Auflösungs-Trigger), und ihre Ausführung für den Sprung `v0.74.1 → v0.76.0` aus
  [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv);
  dazu die Spaltenzahl der Befund-Zeile. **Nicht** Pin, Digest, Quell-Differenz, Trockenlauf und
  die übrigen Messungen von
  [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv):
  Sie gelten fort. **Nicht** die emittierte Ebene.
- **Löst auf:**
  - In [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv):
    - der Absatz *„Gegenmessung auf Nicht-Null-Basis"*, mit Methode, Schluss und dem Satz über
      die vierte Ausgabe-Spalte;
    - im Absatz *„Kein ADR nötig"* der Satzteil *„auf einer Basis, die einen Wegfall gezeigt hätte,
      ist die Befundmenge identisch"*;
    - im Auflösungs-Trigger die Stelle *„an einer Gegenmessung auf Nicht-Null-Basis"*;
    - im Absatz über das Fragment *„Die vier Anker"*;
    - im Geltungsbereich *„ihre Zahl setzt MR-010 Setzung 1"*.
  - In [`MR-052`](../conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte):
    die Aussage *„Die Befund-Zeile trägt ab diesem Pin eine vierte, tab-getrennte Spalte"*.
- **Ausgelöst durch Baseline-Stand:** keiner. Ausgelöst hat die Ablösung ein Defekt der Messung
  dieses Repos, kein Baseline-Stand; dieselbe Lage führen
  [`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
  und
  [`MR-062`](../conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff)
  aus.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  dessen Verdikt nach
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 hier steht. Die Baseline kennt keine Gegenmessung für einen Pin-Sprung. Nahe liegt
  [`modul-11-verification.md`](../../.harness/baseline/v6.9.0/regelwerk/modul-11-verification.md#fitness-function-ohne-standard-tool-modul-11)
  §Fitness Function ohne Standard-Tool: Dort ist der Nachweis je Verstoßklasse ein Break-Test mit
  beiden Sensoren nebeneinander
  (`grep -c 'Break-Test mit beiden Sensoren' .harness/baseline/v6.9.0/regelwerk/modul-11-verification.md`
  → **1**). Diese Setzung wendet das auf zwei Digests desselben Werkzeugs an und tritt an keine
  Stelle.
- **Adaption — Setzung 1, was die Messung leistet.** Die Gegenmessung gibt **jedem** Modul der
  `modules:`-Zeile, die zum Sprung gilt, eine Nicht-Null-Basis. Sie nennt je Modul die Grund-Codes,
  die ihre Basis trägt. Ein Modul ohne Befund ist in der Wegfall-Richtung ungemessen und steht als
  Grenze im Eintrag des Sprungs; eine Gesamtzahl ersetzt die Aufteilung nicht
  ([`MR-055`](../conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)).
- **Setzung 2 — wie die Basis entsteht, ohne die Kopie zu brechen.**
  - **Kopie** außerhalb des Repos mit `git archive <commit>`. `tar` legt die Symlinks unter
    `.claude/rules/` als Symlinks an (`git ls-tree <commit> .claude/rules/` nennt ihren Modus
    `120000`).
  - **Marker nur in regulären Dateien entwerten:**
    `find . -type f -name '*.md' -not -path './.harness/baseline/*' -exec sed -i 's/d-check:ignore/d-check:IGNORIERT-NICHT/g' -- {} +`.
    Ein `sed -i` über einen Symlink ersetzt ihn durch eine reguläre Datei, deren relative Links ins
    Leere zeigen. Das erzeugt `target-missing`, das mit den Markern nichts zu tun hat. Kontrolle
    danach: `find .claude/rules -type l | wc -l` gleich der Symlink-Zahl aus `git ls-tree`, und
    `find .claude/rules -type f | wc -l` → 0.
  - **Je aktivem Modul eine Sonde**, die mindestens einen seiner Grund-Codes auslöst (Tabelle
    unten).
  - **Beide Digests je mit dem Fragment ihres Standes:** `make -C <kopie> docs-check DCHECK_DIGEST=<digest>`;
    die Kopie des alten Standes trägt `d-check.mk` aus dem Commit vor dem Sprung.
  - **Befundzeilen ab drei Spalten lesen** (`awk -F'\t' 'NF>=3'`). Die Befunde von `spans` tragen
    drei Spalten, die übrigen vier; ein Filter auf vier Spalten verwirft `spans` still.
  - **Vergleich** der sortierten vollen Befundzeilen (`diff`) und der Verteilung je Grund-Code
    (`cut -f3 | sort | uniq -c`).
- **Die Sonden.** Sie liegen in zwei neuen Dateien unter `docs/`, einem neuen Slice in `done/` und
  je einer Zeile in `spec/architecture.md`, `roadmap.md`, `harness/README.md` und `Makefile`.

  | Modul | Sonde | Grund-Code |
  |---|---|---|
  | `links` | Link auf eine fehlende Datei; Link, dessen Ziel über `..` die Repo-Wurzel verlässt | `target-missing`, `repo-escape` |
  | `anchors` | Link auf `AGENTS.md` mit fehlendem Anker | `anchor-missing` |
  | `ids` | je eine Kennung der drei `ids`-Muster ohne Link | `id-unlinked` |
  | `matrix` | Link aus `spec/architecture.md` auf eine ADR; Link aus einem `done/`-Slice auf eine ersetzte ADR | `matrix-forbidden`, `matrix-inactive` |
  | `codepaths` | fehlender Pfad unter `harness/`; Zeilen-Referenz hinter dem Datei-Ende | `codepath-missing`, `citation-out-of-range` |
  | `spans` | ungeschlossener Code-Span, der am Text klebt; Link im Linktext eines Links; offene Fence am Datei-Ende | `span-unclosed`, `span-nested-link`, `fence-unclosed` |
  | `planning` | Ruhe-Marker unter *Offene Wellen*, während `in-progress/` einen Slice trägt; `done/`-Slice ohne Closure-Abschnitt | `planning-drift`, `closure-note-missing` |
  | `targets` | `make`-Zeile ohne Rezept im Gate-Index; Makefile-Ziel ohne Index-Zeile | `gate-phantom`, `gate-undocumented` |

  `citation-out-of-range` meldet `codepaths` über `check-lines`. Der Code ist in
  `rules/citations.go` definiert, und diese Datei fehlt in der `numstat`-Liste der geteilten
  Infrastruktur aus
  [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv).
- **Die Messung für `v0.74.1 → v0.76.0`**, Kopie von `16295489`, netzlos. Die Werte sind an
  Commit, Digests und Sonden gebunden; die Dateizahl ist kein Erwartungswert.

  | Stufe | `v0.74.1` (Fragment `0fbefa46^`) | `v0.76.0` (Fragment `16295489`) | `diff` voll |
  |---|---|---|---|
  | unverändert | 0 Befunde, make-Exit 0 | 0 Befunde, make-Exit 0 | leer |
  | Marker entwertet, Symlinks stehen (10 von 10, 0 reguläre) | 57: 20 `codepath-missing`, 37 `id-unlinked` | 57: dieselben | leer |
  | dazu die Sonden | 74, make-Exit 2 | 74, make-Exit 2 | leer |

  In Stufe 3 zählt `cut -f3 | sort | uniq -c` unter **beiden** Digests: `anchor-missing` 1,
  `citation-out-of-range` 1, `closure-note-missing` 1, `codepath-missing` 21, `fence-unclosed` 1,
  `gate-phantom` 1, `gate-undocumented` 1, `id-unlinked` 40, `matrix-forbidden` 1,
  `matrix-inactive` 1, `planning-drift` 1, `repo-escape` 1, `span-nested-link` 1,
  `span-unclosed` 1, `target-missing` 1. Jedes der acht Module hat damit eine Basis. Dass die zwei
  Fragmente gefahren wurden, zeigt die `make`-Fehlerzeile: `d-check.mk:79` unter dem alten Stand,
  `d-check.mk:87` unter dem neuen.
- **Was die Stufen trennen.** Entwertete Marker allein geben nur `codepaths` und `ids` eine Basis;
  `target-missing` steht in Stufe 2 bei **0**
  (`awk -F'\t' '$3=="target-missing"' <befunde> | wc -l`). Die 319 `target-missing` der Messung in
  [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv)
  stammen aus den zehn Symlinks, die ihr `sed -i` in reguläre Dateien verwandelt hat. Die übrigen
  sechs Module trägt erst die Sonde.
- **Schluss: keine Senkung an allen acht aktiven Modulen.** Jeder Grund-Code der Tabelle ist
  unter beiden Digests gleich häufig, die vollen Befundzeilen sind gleich, und die Quell-Differenz
  der acht Regeldateien ist leer
  ([`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv)).
  Ein ADR nach [`AGENTS.md`](../../AGENTS.md) §3.5 ist nicht nötig.
- **Die Befund-Zeile hat drei oder vier Spalten, je nach Grund-Code, unter beiden Digests.**
  `awk -F'\t' '{print NF": "$3}' <befunde> | sort -u` nennt in Stufe 3 drei Spalten für
  `span-unclosed`, `span-nested-link` und `fence-unclosed` und vier für alle übrigen Codes der
  Tabelle. Die vierte Spalte ist der Klartext des Grundes; die drei `spans`-Codes führen keinen.
  Wer die letzte Spalte als Grund-Code liest (`$NF`), bekommt bei vierspaltigen Zeilen den
  Klartext und bei dreispaltigen den Code. Den Code liefert in beiden Fällen `$3`.
- **Die Anker aus
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) §Auflösungs-Trigger
  sind fünf:** `DCHECK_IMAGE ?=`, `.PHONY: doc-check`, `doc-check:` am Zeilenanfang, die leere
  `DCHECK_DIGEST ?=`-Zeile und `'^doc-[a-z-]+:`. Je ein `grep -c` bzw. `grep -cF` über der
  `v0.76.0`-Ausgabe von `--print-mk` und über `internal/emit/testdata/raw-print-mk.txt` ergibt für
  jeden **1**; die Fixture bleibt.
- **Die Zahl der Handgriffe setzen
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1 und
  [`MR-062`](../conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff)
  zusammen:** fünf.
- **Grenze.**
  - **Nicht jeder Code ist abgedeckt.** Die Sonden treffen je Modul die Codes der Tabelle. Ohne
    Basis bleiben unter anderem `symlink`, `link-stale`, `matrix-downward`, die übrigen
    `closure-note-*`-Codes und die `wave-*`-Codes; für sie trägt allein die Quell-Differenz den
    Schluss.
  - **Die Welle-Sonde bleibt stumm.** Eine flache Welle-Datei ohne Zeiger in der Roadmap
    (`welle-sonde.md`, flach im Planungs-Baum) meldet unter beiden Digests nichts. Warum, ist nicht
    untersucht, und darum steht sie nicht in der Tabelle.
  - **Die Messung ist nicht verkörpert.** Kein `make`-Ziel fährt sie; die Sonden stehen in der
    Tabelle, und ihr Träger ist der Lauf, der den Sprung bilanziert.
- **Begründung:** Eine Gegenmessung, deren Basis ein Modul nicht trifft, ist für dieses Modul
  informationsleer, und eine Gesamtzahl verdeckt das: Die 379 Befunde der Messung in
  [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv)
  trafen drei der acht Module, und eines davon nur über einen Nebeneffekt der Kopie.
  **Kopf-Marken** an
  [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv)
  und
  [`MR-052`](../conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte)
  nach
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 1 und 3. Die Ausnahme aus Setzung 4 für die Pin-Kette greift nicht: Dieser Eintrag
  datiert keinen Sprung, er löst Aussagen namentlich ab. Beide Dateien bleiben nach
  [`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)
  in [`conventions/`](../conventions/).
- **Auflösungs-Trigger:** permanent. Bei jedem d-check-Sprung läuft die Gegenmessung nach
  Setzung 2:
  - Kopie per `git archive`;
  - Marker nur in regulären Dateien entwertet, die Symlinks gezählt und erhalten;
  - je Modul der `modules:`-Zeile, die zum Sprung gilt, eine Sonde;
  - beide Digests je mit dem Fragment ihres Standes;
  - Befundzeilen ab drei Spalten;
  - Vergleich der vollen Zeilen und je Grund-Code.

  Ein Modul ohne Befund steht als Grenze im Eintrag des Sprungs. Kommt ein Modul in die
  `modules:`-Zeile, bekommt die Sonden-Tabelle eine Zeile, und zwar in einem neuen Eintrag. Neu
  zu entscheiden ist die Setzung, wenn ein Werkzeug dieses Repos die Messung fährt oder d-check je
  Befund das Modul ausgibt.
