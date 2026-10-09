# Verifikations-Bericht: slice-kotlin-freshness — 2026-10-09

**Rolle:** Verifier (Baseline `v6.17.0` · `regelwerk/modul-11-verification.md`), frischer Kontext.
**Gegenstand:** `db31ad13` (Arbeit) und `440a1ac6` (Antwort auf Review LOW-1/INFO-1), HEAD `440a1ac6`.
**Prüfgrundlage:** `slice-kotlin-freshness` §1–§6, `LH-FA-04`, `LH-QA-02`, `LH-QA-01`, `ADR-0088`
Festlegung 2, `MR-089`, Review `2026-10-09-slice-kotlin-freshness` (`cd601431`).
**Modell:** claude-opus-5-5.

## Urteil

DoD-Liefer-Punkte 1–4 **bestätigt**; Punkte 5–8 sind Closure-Arbeit und offen. Zwei INFO-Befunde,
keiner blockiert die Closure.

## Verdikte je DoD-Punkt

- **1 — Skript + `make freshness-kotlin` + Zeile in §Werkzeuge mit `kein Gate`:** *bestätigt.*
  `grep -n freshness-kotlin Makefile harness/README.md` → Ziel Zeile 436 (`## … NICHT in gates`),
  README-Zeile 100 mit `kein Gate — nur nächtlich · ADR-0088`. Nicht in `record-gates`/`gates`
  (Abhängigkeitsliste Zeile 662, kein `freshness`).
- **2 — bats-Fall veraltet → Meldung, aktuell → still; Rot gesehen:** *bestätigt.* Die Fälle 629–634
  decken Filter, Pin-Quelle, Pin-Form und die drei Urteils-Zweige, aber keiner zielt auf die zwei in
  der DoD genannten Richtungen; den Rot-Beleg dafür habe ich nachgetragen (Scratch-Klon von
  `440a1ac6`, je `make test-bats BATS_TARGET=test/kotlin-freshness.bats`):
  - Mutation A, `extract_latest` nimmt `head -n 1` statt `tail -n 1` → `not ok 2 … veralteter Pin
    meldet VERALTET` mit `[ "$latest" = "9.9.0-jdk21" ]' failed`, dazu 3, 5–8 rot; 1, 4, 9, 10 grün.
  - Mutation B, Vergleicher invertiert (`latest" != "`, Form von Fall 46) → `not ok 3 … aktueller Pin
    meldet keinen Drift` mit `[ "$status" -eq 0 ]' failed`, dazu 2, 7, 8 rot. Beide werden also aus
    dem behaupteten Grund rot.
  - Fälle selbst gefahren: `make mutate MUTATE_CASES='629-… 630-… 631-… 632-… 633-… 634-…'` →
    `mutate: 6 ok, 0 Befund(e)` (TEILLAUF 6 von 621).
- **3 — `make gates` grün:** *bestätigt*, Lauf am Ende dieser Verifikation auf dem Baum mit diesem
  Bericht (Ergebnis in der Commit-Message).
- **4 — Review, kein Self-Review:** *bestätigt.* Report `cd601431`, eigener Kontext. LOW-1 ist durch
  `440a1ac6` behoben (Live-Beleg unten: ein Pin über der Seite gibt `KEIN URTEIL` statt `aktuell`);
  INFO-1 ebenso (README-Zeile nennt jetzt Seite 1, 100, `last_updated`). Die Nachbesserung selbst hat
  kein zweites Review gesehen; ihr Verhalten ist hier gemessen.
- **5–8 — Closure-Notiz, Register, Risiko-Ausgänge, Paarungen:** *offen* — Planner.

## Urteils-Zweige, live mit Netz

Echter Pin und verfälschter **echter** Pin (`DefaultKotlinVersion` in `internal/gen/kotlin.go` per
`sed` umgeschrieben, danach `git checkout`), je `make freshness-kotlin`:

| Pin in der Quelle | Meldung | Skript-Exit |
|---|---|---|
| `9.8.1-jdk21` (real) | `kotlin-gradle: aktuell — gepinnt und latest sind beide 9.8.1-jdk21.` | 0 |
| `9.7.0-jdk21` | `VERALTET …` `gepinnt: 9.7.0-jdk21` `latest:  9.8.1-jdk21` + Hebe-Hinweis | 1 |
| `8.14.6-jdk21` | `VERALTET …` `latest:  9.8.1-jdk21` | 1 |
| `9.99.0-jdk21` | `KEIN URTEIL: gepinnt 9.99.0-jdk21 steht nicht unter den gelieferten Tags, und keiner liegt darueber (hoechster gelieferter: 9.8.1-jdk21) — gelesen wird eine Seite, sortiert nach last_updated.` | 2 |
| `9.8-jdk21` | `KEIN URTEIL: kein gepinnter Wert in der Form X.Y.Z-jdk<NN> — gelesen: '9.8-jdk21' …` | 2 |

Die Meldungen treffen je ihren Fall. Leere Antwort (Fetch-Ausfall-Pfad, netzlos):
`bash harness/tools/kotlin-freshness.sh --judge 9.8.1-jdk21 ""` → `FETCH-FEHLER (kein
Freshness-Urteil)`, Exit 2. Die Seite gemessen: `curl …/gradle/tags/?page_size=100&name=jdk21` →
`"count":657`, Kandidaten auf Seite 1 nur `8.14.6-jdk21`, `9.8.1-jdk21`.

## Befunde

### INFO-V1 — Die Seiten-Grenze steht an drei von fünf Orten der Aussage

- Steht: Skript-Kopf (`Grenze: gelesen wird EINE Seite (page_size=100), sortiert nach last_updated`),
  README-Zeile 100, `KEIN URTEIL`-Meldung.
- Fehlt: in den Laufzeit-Meldungen `aktuell`/`VERALTET` (sie kommen aus dem gemeinsamen Vergleicher
  `component-freshness.sh`) und im `## `-Hilfetext des Ziels. Die Nachtlauf-Zeile `aktuell` liest sich
  als „upstream nichts Neueres“, gemessen ist „Seite 1 nichts Neueres“ — bei 2 Kandidaten unter 100
  Einträgen. Eine Zusage breiter als ihr Sensor im Sinn von `AGENTS.md` §3.6, nur in der
  Laufzeit-Ausgabe; die Dokumentation trägt die Grenze. Für den Planner: hinnehmen oder einen Satz in
  die Ausgabe des Wrappers nehmen.

### INFO-V2 — Plan-vs-Code: `.d-check.yml` ohne Zeile in §3

- Code ohne Plan: `db31ad13` ändert `.d-check.yml` (`exempt-targets` + Gruppen-Kommentar), §3 führt die
  Datei nicht. Die Änderung folgt zwingend aus der Werkzeug-Zeile (README §Werkzeuge: kuratiert in
  `targets.exempt-targets`), verschiebt keine Abnahme.
- Plan ohne Code: keiner. Die §3-Erweiterung um `upstream-drift.yml` und `test/mutations/` ist gebaut
  (Step mit `if: '!cancelled()'`, wie `freshness-cpp`; Fälle 629–634).

## Negativbefunde

- **`ADR-0088` Festlegung 2:** Pin per Tag `gradle:<ver>-jdk<NN>`, gelesen aus `DefaultKotlinVersion`
  — ohne Befund; Fall 632 bindet die Quelle.
- **`LH-QA-01`:** nicht in `gates`, README-Zeile `kein Gate` — ohne Befund.
- **`LH-QA-02` / `LH-FA-04`:** der Sensor mutiert nichts (`git status` nach allen Läufen nur meine
  zurückgesetzte Pin-Fälschung); der Pin bleibt Tag-gepinnt — ohne Befund.
- **§6-Risiko (Netz):** ein Ausfall blockiert keinen Gate-Lauf — nicht in `record-gates`, Fetch-Fehler
  endet in Exit 2. Vorschlag für den Ausgang: *entfallen*, Begründung „läuft nur nächtlich, außerhalb
  `gates`“.
- **Achsen-Grenze:** ein `8.x`-Pin bekommt `VERALTET` mit `9.8.1` — eine Major-Linie kennt der Sensor
  nicht; der Kopf sagt „höchster Kandidat nach `sort -V`“, also zugesagt, ohne Befund.
- **`MR-089`:** keine Laufzeit-Aussage über einen Lauf im Ziel oder einen E2E-Lauf; die Mutations-Zeiten
  (längster Fall 186,31 s, gesamt 1021,3 s Fall-Arbeit, 7 min 54 s Wand) sind Dogfood-`make mutate`
  bei lokal vorhandenen Images und warmem Build-Cache, außerhalb des Geltungsbereichs.

## Offen für die Closure (Planner)

- DoD 5–8: Closure-Notiz, Register, Ausgang des §6-Risikos, Paarungen über `welle-kotlin-skelett`.
- INFO-V1 entscheiden (hinnehmen oder Ausgabe ergänzen).
