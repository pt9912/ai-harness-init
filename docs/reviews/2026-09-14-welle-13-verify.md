# Verifikation welle-13, Schritt 1 — Trigger prüfen: vier Closure-Kriterien, und zwei Zahlen des Abnahmekriteriums stimmen nicht mehr

**Rolle:** Verifier · **Datum:** 2026-09-14 · **Geprüfter Stand:** `cb5646dd` (Baum sauber,
`git status --porcelain` leer) · **Gegenstand:**
[`welle-13`](../plan/planning/done/welle-13-regeln-bekommen-ihren-sensor.md) §1, §2, §3, §4, §6 ·
**Auftrag:** Wellen-Closure-Prozedur, **Schritt 1** *Trigger prüfen*
(Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle — der eine Schritt
der Closure, der einen Rollenwechsel trägt; sein Beleg geht über die Slice-DoDs hinaus und steht in
keiner von ihnen).
**Nicht mein Gegenstand:** die Schritte 2–6 (Trigger-Audit, Lese-Schritt, Results-Notiz, `git mv`,
Archivierung, Roadmap).

**An diesem Stand nicht geschrieben.** Dieser Lauf hat weder Produktcode noch Plan- noch Normdatei
verfasst. Er hat gelesen, Sensoren gefahren und jedes neu verdrahtete Modul in einer Kopie unter
`/tmp/w13` **rot gefärbt**. Eine Ausnahme ist im Baum nicht mehr sichtbar und wird hier offengelegt:
ein Mutations-Aufruf hat einmal `d-check.mk` **im** Arbeitsbaum erweitert (das Skript arbeitet mit
relativen Pfaden), wurde mit `git checkout -- d-check.mk` zurückgesetzt, und der Baum ist seither
byte-gleich zu `cb5646dd` (`git status --porcelain` leer). Der in §2 zitierte `make gates`-Lauf
liegt **vor** diesem Vorfall über demselben Inhaltsstand.

**Ein §8 existiert in dieser Datei nicht.** Die Welle führt §1–§7; die Sichtung der offenen
Beobachtungen steht begründet in §1 (die Ziel-Form `welle.template.md` führt sieben Abschnitte).

---

## Ergebnis in einer Tabelle

| Kriterium (§3 der Welle) | Verdikt |
|---|---|
| **1** Alle sechs Slices liegen in `done/` | **erfüllt** — die Welle trägt allerdings **sieben** |
| **2** `make gates` grün, mit den neu aufgenommenen Modulen **in** der Modul-Liste | **erfüllt** — mit einer benannten, belegten Abweichung (§2) |
| **3** Je neu verdrahtetem Modul einmal rot gesehen, mit dem Kommando **im Umsetzungs-Commit** | **erfüllt in der Sache** (5 von 5 hier rot gefahren); **die geforderte Beleg-Form fehlt bei `targets`** (§3) |
| **4** Je `docs?-*`-Ziel entschieden; Ziele ohne Block sagen es in Ausgabe/Hilfetext | **erfüllt** — über **13** Ziele, nicht zwölf (§4) |
| **5** Closure-Notiz in `done/welle-13-results.md` | **nicht meins** (Schritt 3); `ls` → Datei existiert noch nicht |

---

## 1. Kriterium 1 — die Slices liegen in `done/`

```sh
for f in slice-123-ci-sieht-die-historie slice-124-gate-tabelle-hat-einen-waechter \
         slice-125-roadmap-und-verzeichnis-stimmen-ueberein slice-126-commit-message-traegt-eine-kennung \
         slice-127-adr-immutabilitaet-hat-einen-sensor slice-129-closure-notiz-hat-einen-sensor; do
  test -f docs/plan/planning/done/$f.md && echo "OK   $f" || echo "FEHLT $f"; done
# OK   slice-123-ci-sieht-die-historie
# OK   slice-124-gate-tabelle-hat-einen-waechter
# OK   slice-125-roadmap-und-verzeichnis-stimmen-ueberein
# OK   slice-126-commit-message-traegt-eine-kennung
# OK   slice-127-adr-immutabilitaet-hat-einen-sensor
# OK   slice-129-closure-notiz-hat-einen-sensor
```

An den **Dateien** geprüft, nicht an der §4-Tabelle. **Erfüllt.**

**Befund (Mitglieder-Zahl).** Die Welle trägt **sieben** Slices, nicht sechs:

```sh
grep -lE '^\*\*Welle:\*\*.*welle-13' docs/plan/planning/done/*.md | wc -l     # 7
grep -lE '^\*\*Welle:\*\*.*welle-13' docs/plan/planning/done/*.md
# … slice-123, -124, -125, -126, -127, -129 und slice-217-doc-ziel-nennt-seinen-pruefbereich.md
```

Das siebte Mitglied ist
[`slice-217`](../plan/planning/done/slice-217-doc-ziel-nennt-seinen-pruefbereich.md) — es trägt
**genau das welle-eigene Kriterium aus §3** (§4 der Welle kennt es nicht). Die Zugehörigkeit ist
nicht die Tabelle, sondern das Kopf-Feld; `slice-217` §1 sagt das selbst und nennt den Grund, warum
die Datei `welle-13` in seinem Zuschnitt **nicht** angefasst wird („Bestand bleibt bewusst stehen“).
Das Auflösen steht damit beim Closure-Lauf, nicht hier.

**Zur Zahl aus dem Auftrag:** `grep -l 'welle-13' docs/plan/planning/done/*.md | wc -l` liefert
**23** — das Muster trifft auch Herkunfts-Anker (`seit welle-13`) und Querverweise in fremden
Slices und Wellen. Tragend ist das `Welle:`-Feld; es liefert **7**.

## 2. Kriterium 2 — `make gates` grün

```sh
make gates            # EXIT=0
# d-check: 1366 Datei(en) geprüft, 0 Befund(e)
# comment-claims: 58 Datei(en) geprueft, 0 Befund(e)
# span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert
```

**Erfüllt — und die zweite Hälfte ist eine Entscheidung, kein Häkchen.** Verglichen wurde die
Modul-Liste bei Eröffnung der Welle, an ihrem Beginn und heute:

```sh
git show ebc0907f:.d-check.yml | grep -m1 '^modules:'   # [links, anchors, ids, matrix, codepaths, spans]
grep -m1 '^modules:' .d-check.yml                       # [links, anchors, ids, matrix, codepaths, spans, planning, targets]
grep -m1 '^modules:' .d-check.yml | tr ',' '\n' | wc -l # 8
```

Die Welle hat **zwei** Module in die Liste gebracht: `planning` ([slice-125](../plan/planning/done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md))
und `targets` ([slice-124](../plan/planning/done/slice-124-gate-tabelle-hat-einen-waechter.md)).
Die zwei übrigen der vier in §1/§4 genannten Module — `commits` und `vcs` — stehen **nicht** in
`modules:`, sondern laufen über eigene Ziele (`doc-commits`, `doc-immutable`). Wörtlich gelesen ist
das „daneben“, und damit die strengere Lesart des Kriteriums nicht erfüllt.

**Sie ist es mit geschriebenem Grund, und der Träger ist nicht still.** Beide Blöcke tragen die
Entscheidung in der Gate-Config selbst:

```sh
sed -n '326,330p' .d-check.yml   # "# vcs (git-basiert, braucht .git + eine Commit-Range — strikt opt-in, NICHT in
                                 #  modules: oben: ein hermetischer docs-check-Lauf ohne Range liefe damit ins
                                 #  Leere, LH-QA-01)."
sed -n '360,363p' .d-check.yml   # "# commits (git-basiert, braucht .git + eine Range ODER eine Message-Datei —
                                 #  strikt opt-in, NICHT in modules: oben: …)"
```

Und beide haben einen **Aufrufer**: `vcs` hängt an `make adr-immutable RANGE=…` (vorgeschaltet der
Historie-Vorlauf-Wächter aus [slice-123](../plan/planning/done/slice-123-ci-sieht-die-historie.md))
und an einem eigenen CI-Job mit `fetch-depth: 0` (`grep -n 'adr-immutable' .github/workflows/ci.yml`
→ Job-Zeile 99, Range-Aufruf Zeile 117); `commits` hängt am PreToolUse-Hook
(`.claude/hooks/pretooluse-commit-msg-guard.sh` → `make commit-msg-check`). Die Klasse, gegen die
das Kriterium geschrieben ist — ein Modul, das „neben“ dem Gate liegt und nie läuft — ist damit
**nicht** eingetreten. **Erfüllt, mit dieser Abweichung im Protokoll.**

## 3. Kriterium 3 — jedes neu verdrahtete Modul einmal rot gesehen

Drei neue Modul-Verdrahtungen und zwei neue Fähigkeiten; **jede hier selbst rot gefahren**, in einer
Kopie außerhalb des Repos (`/tmp/w13`, netzlos, Mount `:ro`, Digest aus `d-check.mk` — `LH-QA-02`):

| Modul / Fähigkeit | Umsetzungs-Commit | Rot gefahren (Kommando → Befund) |
|---|---|---|
| `targets` | `6f454e15` | Kopie + eine erfundene `make X`-**Tabellenzeile** in `harness/README.md` → `make doc-targets`: `harness/README.md:60  phantom-gate  gate-phantom  dokumentiertes Target `make phantom-gate` ohne Makefile-Regel`, `1 Befund(e)`, Exit 1 |
| `planning` (Überschrift/Ruhe-Marker) | `c63ef63b` | Kopie + Ruhe-Marker entzogen → `make doc-planning`: `roadmap.md:11  docs/plan/planning/in-progress  planning-drift  kein Slice … aber … Marker „Nichts in Arbeit.“ nicht`, Exit 1 |
| `commits` | `10ba393a` | `make commit-msg-check MSG=<datei ohne Kennung>` → `commit-untraceable`, Exit 1; dieselbe Datei **mit** Kennung → Exit 0 |
| `vcs` | `44427bec` | Kopie + Kern-Satz in `## Entscheidung` einer `Accepted`-ADR, `make adr-immutable RANGE=HEAD~1..HEAD` → `docs/plan/adr/0003-go-native-binaries.md:3  core-drift-vcs`, Exit 1. **Gegenrichtung:** derselbe Aufruf über den unveränderten Bestand dieses Repos → `1366 Datei(en) geprüft, 0 Befund(e)`, Exit 0 |
| `planning.closure` | `02937ed3` | Kopie + eine `done/`-Notiz mit **einem** Satz in §7 → `make doc-planning`: `closure-note-thin  Closure-Notiz trägt 1 Satzende-Zeichen …, verlangt sind 4`, Exit 1 |

Jedes Rot kam aus **dem eigenen Grund-Code** des Moduls, nicht aus irgendeinem Fehlschlag.

**Befund zur geforderten Beleg-Form.** Das Kriterium verlangt das Kommando **im jeweiligen
Umsetzungs-Commit**. Vier der fünf Commits tragen den Nachweis in ihrer Message
(`c63ef63b`: *„make docs-check meldete darauf vor dieser Aenderung planning-drift, Exit 1“*;
`10ba393a`: *„Rot gesehen an einer echten Message-Datei ohne Kennung (Exit 1, commit-untraceable)“*;
`44427bec`: *„faerbt `core-drift-vcs` (Exit 1)“*; `02937ed3`: *„Rot gesehen gegen eine Kopie
aussererhalb des Repos … -> closure-note-thin“*). **`6f454e15` (`targets`) trägt ihn nicht** — die
Message nennt die Aktivierung, die Kuratierung und die zwei Mutations-Fälle, aber weder Kommando
noch Grund-Code noch Exit; auch die drei Nacharbeits-Commits des Slice führen ihn nicht
(`git log --all --format='%s%n%b' | grep 'gate-phantom'` findet keine Slice-124-Message). Der
Nachweis existiert im Repo — als Mechanismus-Satz in `harness/README.md` (Teil von `6f454e15`) und
als Behauptung in §7 des Plans (*„Beide Grund-Codes sind rot gesehen“*) —, aber nicht dort, wo das
Kriterium ihn verlangt. Der Plan selbst hatte es schärfer gefordert: *„Beide gehören in den
Umsetzungs-Commit“* (DoD (1) des Slice).

## 4. Kriterium 4 — die `docs?-*`-Ziele und ihr Prüfbereich

```sh
grep -cE '^docs?-[a-z-]+:.*## ' d-check.mk   # 13
make doc-help                                 # listet dieselben 13 Ziele
```

**Die Welle nennt zwölf; gezählt sind dreizehn.** Entschieden ist für **alle dreizehn**, und zwar
in einem lebenden Artefakt: `harness/sensors/doc-tracked.md` §Grenze führt die vier Klassen, die
das Modul aus Ziel-Zeile, Rezept-Zeile und Block-Frage **ableitet** — A (kein `--enable`, fährt
d-check über dem Baum: `docs-check`, `doc-doctor`, `doc-repair`, `doc-trace`, `doc-complete`),
B (Modul + Top-Level-Block: `doc-immutable`, `doc-commits`, `doc-planning`, `doc-targets`),
C (Modul **ohne** Block: `doc-tracked`, `doc-structure`), D (kein Docker-Lauf über dem Baum:
`doc-usage`, `doc-help`) — und zu D steht ausdrücklich, dass die Frage nach einem Prüfbereich für
sie „sinnlos“ ist und „das **hier** [steht], statt stillschweigend zu fehlen“.

**Die zweite Hälfte des Kriteriums ist am laufenden Ziel selbst geprüft**, nicht am Hilfetext allein:

```sh
make doc-structure   # d-check: 1366 Datei(en) geprüft, 0 Befund(e)
                     # .d-check.yml fuehrt fuer dieses Modul keinen eigenen Block, siehe harness/sensors/…
make doc-tracked     # d-check: 1366 Datei(en) geprüft, 0 Befund(e)
                     # .d-check.yml fuehrt fuer dieses Modul keinen eigenen Block, siehe harness/sensors/…
make doc-help        # beide Ziele tragen die Marke auch in ihrer ##-Zeile
```

Die beiden C-Ziele sagen es also **in Ausgabe und Hilfetext** — genau wie der Präzedenzfall aus dem
Auftrag. **Erfüllt**, über der gemessenen Menge (13), nicht über der zitierten Zahl (12). Dass die
Null von `doc-structure` *inert* bedeutet und die von `doc-tracked` **nicht** (der Tool-Default
greift schon ohne Block), ist in derselben Datei je Zielsatz gegengeprüft und steht dort mit
Kommando — die Unterscheidung ist nicht weggelassen.

## 5. Kriterium 5 — nicht mein Schritt

`ls docs/plan/planning/done/welle-13-results.md` → keine Datei. Das ist der korrekte Stand vor
Schritt 3; ich melde es nur, damit „fehlt“ nicht als Befund gelesen wird.

---

## Verdikt

**Die vier prüfbaren Closure-Trigger sind erfüllt; zwei Befunde betreffen den Wortlaut des
Abnahmekriteriums, keiner davon die Lieferung.**

**Was der Planner für Schritt 2/3 wissen muss:**

1. Die Welle trägt **sieben** Mitglieder, ihre §4 listet sechs. Das siebte,
   [`slice-217`](../plan/planning/done/slice-217-doc-ziel-nennt-seinen-pruefbereich.md), ist der
   Träger des welle-eigenen Kriteriums aus §3; `make archive-welle` sammelt nach dem `Welle:`-Feld
   ein, nicht nach der Tabelle.
2. §3 nennt **zwölf** `docs?-*`-Ziele; gezählt sind **dreizehn**, und §3 zählt **sechs** Slices
   gegen **sieben** Träger. Beide Zahlen sind Bestandswerte in einem Abnahmekriterium; `slice-217`
   §1 hat die Korrektur ausdrücklich diesem Lauf überlassen („in denselben Zug“).
3. `commits` und `vcs` liegen bewusst außerhalb `make gates` (`.d-check.yml`-Kopfkommentar,
   `harness/README.md` §Sensors). Criterion 2 ist damit in der Sache erfüllt, wörtlich nur für
   `planning` und `targets` — die Zuordnung ist entschieden und aufgeschrieben.
4. Der Rot-Nachweis zu `targets` fehlt **im Umsetzungs-Commit** (`6f454e15`); er ist im Repo
   (Mechanismus-Satz in `harness/README.md`, §7 des Slice) und in diesem Lauf reproduziert
   (`gate-phantom`, Exit 1). Ob das die Welle schließt oder ein Nachtrag gehört, ist eine
   Planner-Entscheidung — die Substanz des Kriteriums trägt.

## Was ich nicht geprüft habe

- **`make mutate`** (der kuratierte Satz) nicht gefahren. Die Zähne der Verdrahtung
  (`test/mutations/301`, `302`, `307`, `277`–`279`, `285`–`287`) sind damit **nicht** nachgemessen;
  die sechs Wächter-Dateien existieren (`ls test/ | grep -E 'targets-modul|planning-modul|vcs-modul|closure-modul|commit-msg-guard|doc-block-marke'`), und das Rot habe ich stattdessen am
  **Modul selbst** gefahren (§3).
- **Der Wächter aus `slice-217`** (`test/doc-block-marke-wiring.bats`, Mutation `309`) ist nicht
  gelaufen. Der Versuch, ihn in der Kopie nachzufahren, hat die Mutation wegen ihres relativen
  Pfads zunächst im Arbeitsbaum angewandt; sie ist zurückgesetzt (§Kopf). Die im Commit `497564d7`
  genannten drei Rot-Lagen sind damit **Zitat, nicht Nachweis** — für Kriterium 4 nicht tragend
  (dieses prüft Ausgabe und Hilfetext, nicht den Wächter).
- **Der CI-Lauf selbst.** Gelesen ist die Job-Definition (`fetch-depth: 0`, Range-Aufruf), nicht
  ein Lauf auf einem frischen Klon.
- **Die Messungen aus §1 und §6 der Welle** (22 Module, die Zahlen je Modul, `reviews`/`workflows`)
  — sie sind nicht Gegenstand der vier Kriterien und wurden nicht nachgefahren.
- **Die Archivierungs- und `git mv`-Schritte** (Schritte 4 und 6) — nicht mein Auftrag.
