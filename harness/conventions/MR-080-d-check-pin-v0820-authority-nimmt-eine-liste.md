# MR-080 — d-check-Pin v0.82.0 (`targets.authority` nimmt eine Liste)

- **Datum:** 2026-10-06
- **Wirksamkeits-Anlass:** slice-d-check-pin-nimmt-die-authority-liste.
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`, Kopfkommentar),
  `internal/emit/emit.go` (emittierter Default-Pin); setzt
  [`MR-079`](../conventions.md#mr-079--d-check-pin-v0810-vcs-bricht-über-leerer-range-ab) fort.
  **Nicht** die Modul-Liste und nicht der `targets`-Block der [`.d-check.yml`](../../.d-check.yml),
  **nicht** die emittierte Startkonfiguration
  ([`MR-054`](../conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel))
  und **nicht** die Methode der Gegenmessung
  ([`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)).
- **Ersetzt-Baseline-Regel:** keine. Nach dem Wortlaut der Eintrags-Vorlage ist der Eintrag damit
  ein **Fork**, aus demselben Grund wie
  [`MR-079`](../conventions.md#mr-079--d-check-pin-v0810-vcs-bricht-über-leerer-range-ab):
  ein Pin-Sprung tritt an keine Baseline-Stelle.
- **Adaption.** Der Pin springt **v0.81.0 → v0.82.0**, Digest
  `sha256:d28e9437888554a262ad9a2e8a63fdb1717e5b5860824fdef263a877d532e0c8`
  (`docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.82.0`, Commit `6fb5058f`). Der
  lebende Pin steht in `d-check.mk`
  ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)).
  `--print-mk` unterscheidet sich zwischen den Digests in einem Hunk (`DCHECK_IMAGE`); das
  Fragment weicht von `--print-mk` in sechs Hunks ab — Kommando im Kopfkommentar von `d-check.mk` —,
  die fünf Handgriffe aus
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) und
  [`MR-062`](../conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff)
  sind unverändert. **Verfügbar** wird allein: `targets.authority` nimmt neben einem Pfad eine
  Liste wörtlicher Pfade, `gate-undocumented` misst gegen ihre Vereinigung. Das Dogfood führt
  weiter eine Autoritäts-Datei.
- **Strenge-Bilanz — keine Senkung, keine Verschärfung.** Gegenmessung nach
  [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
  Setzung 2, netzlos, je Digest eine Kopie (Angabe nach
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  Setzung 1: kein Objektspeicher). `OLD`/`NEW` sind die Digests von `v0.81.0`/`v0.82.0`.

  **Prüf-Bedingung vor dem Lauf**
  ([`MR-067`](../conventions.md#mr-067--eine-aufbau-anleitung-nennt-ihre-prüf-bedingung-vor-ihren-kommandos)
  Setzung 1):
  - Die Symlinks bleiben stehen: `find .claude/rules -type l | wc -l` in der Kopie ist gleich
    `git ls-tree 6fb5058f .claude/rules/ | grep -c '^120000'` (10), `find .claude/rules -type f`
    ist leer.
  - Die alte Kopie trägt `d-check.mk` aus `6fb5058f~1`.
  - In Stufe 3 hat jedes aktive Modul mindestens einen Befund (`grep -m1 '^modules:' .d-check.yml`
    in Dogfood und Ziel).

  **Kommandos** wie in
  [`MR-079`](../conventions.md#mr-079--d-check-pin-v0810-vcs-bricht-über-leerer-range-ab)
  §Strenge-Bilanz, mit `6fb5058f` statt `dd26964c` als Kopie-Quelle
  (`git archive 6fb5058f | tar -x -C "$K"`), `make -s -C "$K" docs-check DCHECK_DIGEST=<OLD|NEW>`,
  und Stufe 2 über jede `*.md` außer `.harness/baseline/` **und außer Symlinks**. Die Sonden sind
  nach derselben Bedingung am Stand `6fb5058f` neu geschnitten.

  | Stufe | `v0.81.0` | `v0.82.0` | `diff` |
  |---|---|---|---|
  | Dogfood unverändert | 2278 Dateien, 0 Befunde | gleich | leer |
  | Marker entwertet | 76 Befunde (39 `codepath-missing`, 37 `id-unlinked`) | gleich | leer |
  | zusätzlich Sonden | 88 Befunde, 13 Grund-Codes, alle neun Module mit Basis | gleich | leer |
  | Ziel `--lang go` unverändert | 20 Dateien, 0 Befunde | gleich | leer |
  | Ziel mit Sonden | 22 Dateien, 10 Befunde, alle sechs Module mit Basis | gleich | leer |

  **Keine Erwartungswerte**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2); gemessen an `6fb5058f`, einem Stand ohne diesen Eintrag
  ([`MR-058`](../conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)).
  Tragend sind die 0 der unveränderten Stufen und die Gleichheit der Mengen. Die Sonden-Skripte
  bleiben unversioniert — dasselbe akzeptierte Negativ wie in `MR-079`.
- **Byte-Identität mit einer Datei.** `targets` im Dogfood unter `authority: harness/README.md`
  gegen `authority: [harness/README.md]`, unter `v0.82.0`: Normallauf, `--json` und
  `make doc-targets` byte-gleich, grün und mit einer `gate-undocumented`-Sonde rot; `--doctor`
  byte-gleich bei getrennten Strömen. Mit `2>&1` verzahnt ist ein Lauf einmal verschieden
  ausgefallen; Ursache ist die Reihenfolge der Ströme, nicht der Inhalt — darum ist die Aussage auf
  getrennte Ströme beschränkt. Die Probe ändert `.d-check.yml` nicht dauerhaft.
- **Kein ADR nötig ([`AGENTS.md`](../../AGENTS.md) §3.5):** die aktiven Module zeigen gleiche
  Befundmengen; die neue Fähigkeit ist ungenutzt.
- **Grenze.**
  - Die Gegenmessung fährt den VCS-Port nicht (`git archive`-Kopie).
  - Der Digest ist über die Werkzeug-Ausgabe belegt; kein Sensor hält ihn gegen den Tag
    (`BEO-ALL/pin-digest-ohne-waechter` im Beobachtungs-Register).
  - Eine `authority` mit **mehr als einer** Datei ist nicht gemessen; sie hat hier keinen
    Gegenstand.
  - Die Adaptions-Liste in Zeile 2 von `d-check.mk` endet bei `MR-066`; die reinen Pin-Sprünge
    seither (`MR-068`, `MR-073`, `MR-079`, dieser) stehen dort nicht. **Akzeptiertes Negativ:**
    der lebende Pin steht zwei Zeilen tiefer, die Einträge datieren ihre Aussage (`MR-053`), und
    keiner dieser Sprünge setzt einen neuen Handgriff.
  - Datierte Momentaufnahme (`MR-053`): jede Werkzeug-Aussage nennt `v0.81.0` oder `v0.82.0` als
    Mess-Operand.
- **Begründung.** Der Digest ist die Reproduzierbarkeits-Zusage
  ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Der Sprung macht die
  Listen-`authority` verfügbar, die ein Doc-Gate mit mehr als einer Autoritäts-Datei braucht —
  Voraussetzung für das Modul `targets` im emittierten Ziel, das ein eigener Slice nach
  [`MR-054`](../conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  prüft. Keine Aussage eines früheren Eintrags wird abgelöst; der Sprung datiert nur
  ([`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 4), darum trägt `MR-079` keine Kopf-Marke.
- **Auflösungs-Trigger:** permanent, wie `MR-079`. **Neu zu prüfen** ist die Byte-Identitäts-Aussage,
  sobald eine `authority` dieses Repos oder des emittierten Ziels mehr als eine Datei führt.
