# Slice slice-054: Das cpp-Arch-Gate hat Zähne — und die Doku sagt es

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-08-cpp-hexslice](../welle-08-cpp-hexslice.md) — der zweite und letzte Slice;
mit ihm wird das Closure-Kriterium der Welle wahr.

**Bezug:** [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) (das
Arch-Gate prüft die Schichten real), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Gate ohne rot gesehenes Gegenbeispiel ist eine Behauptung),
[`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (One-Shot-Kurzform),
[`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-27.

---

## 1. Ziel

Das emittierte C++-Arch-Gate wird **rot gesehen** — ein verbotener `domain → adapters`-Include
färbt es im realen Ziel —, der bisher ungeprüfte Root-One-Shot ist belegt, und **erst dann** sagt
die Nutzer-Doku, dass `hexslice` nicht mehr nur der Go-Renderer liefert.

## 2. Definition of Done

- [ ] **(1) Das cpp-Arch-Gate ist rot gesehen.** `make full-smoke` schmuggelt einen verbotenen
  `domain → adapters`-Include in das gebootstrappte cpp-hexSlice-Modul, fährt dessen Arch-Gate und
  verlangt **Exit ≠ 0 mit `core-impurity`/`wrong-direction`** — danach zurückgenommen. Dieselbe
  Zahn-Form, die welle-07 für Go etabliert hat; slice-053 hat Build und Lint belegt, **nicht** das
  Arch-Gate.
- [ ] **(2) Der Root-One-Shot ist belegt** (Review-F-5 aus slice-053): `--lang cpp --arch hexslice`
  am Repo-Root — `CMAKE_SOURCE_DIR` ist dort der Repo-Root, nicht ein Modul-Verzeichnis. Belegt
  wird, dass `make gates` im Ziel grün ist **und** das Arch-Gate real mitläuft.
- [ ] **(3) Die Doku sagt, was gilt.** „`hexslice` liefert derzeit nur der Go-Renderer" fällt in
  [Handbuch](../../../user/benutzerhandbuch.md)-Kopf und [`README.md`](../../../../README.md);
  Handbuch-Version + §11-Zeile. **Erst jetzt** — vorher hätte die Doku eine Fähigkeit beworben,
  deren Zusage noch keinen rot gesehenen Sensor hat.
- [ ] `make gates` grün, `make mutate` ohne Befund, `make full-smoke` grün.
- [ ] Doku-Update siehe (3) — kein weiterer öffentlicher Vertrag berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-27, live):**

| # | Aussage | Kommando / Beleg |
|---|---|---|
| 1 | `full-smoke` deckt für cpp heute Build und Lint, **nicht** das Arch-Gate | `grep -n "cpphex" harness/tools/full-smoke.sh` → Datei-Satz, `make gates`, Build-Zahn (`build-apps-cpphex`), Lint-Zahn (`lint-apps-cpphex`); **kein** `a-check-apps-cpphex`-Lauf mit verbotenem Include |
| 2 | Für Go existiert die Zahn-Form bereits | derselbe `grep` auf `apps/hex` → `teeth_out`-Block mit `core-impurity`-Erwartung |
| 3 | Der Root-One-Shot ist ungeprüft | im Skript kommt `--lang cpp` nirgends vor; geprüft werden Subdir-Module und der **go**-Root-Fall |
| 4 | Die Doku-Aussage steht an zwei Stellen | `grep -rn "nur der Go-Renderer" docs/user/benutzerhandbuch.md README.md` |

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/full-smoke.sh` | update | Arch-Gate-Zahn für cpp; Root-One-Shot-Block (eigenes tmp-Repo, wie der go-Root-Fall) |
| [`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md) | update | Kopf-Aussage + §11-Zeile |
| [`README.md`](../../../../README.md) | update | dieselbe Aussage |
| `test/mutations/` | update/neu | die cpp-Kanten-Menge ist bewacht (`adapters → ports` ist erforderlich, nicht optional) — prüfen, ob Fall 93 das schon trägt, sonst ergänzen |

## 4. Trigger

**`open` → `in-progress`:** [slice-053](../done/slice-053-cpp-hexslice-renderer.md) liegt in `done/` — der
Prüfbereich existiert, das Gate wird emittiert. Ohne ihn hätte dieser Slice ein Gate über einem
leeren Baum zu röten versucht.

Rückführungen:

- `in-progress` → `next`: falls der Root-One-Shot eine eigene Bootstrap-Mechanik braucht (etwa weil
  `CMAKE_SOURCE_DIR` am Root andere Globs verlangt) — dann ist das ein eigener Zuschnitt, kein
  Nebeneffekt dieses Slice.
- `in-progress` → `open`: falls der Arch-Gate-Zahn für cpp **nicht** rot wird, obwohl der Import
  verboten ist — dann ist die emittierte Config falsch und der Befund gehört zurück in den
  Renderer-Slice, nicht in einen Doku-Nachzug.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit ausgestelltem Verdikt; Verifikation bestätigt die
DoD (Modul 11); `make gates`/`make mutate`/`make full-smoke` grün; `git mv` nach `done/` (eigener
Move-Commit, Link-Reconciliation im Folge-Commit); Closure-Notiz mit Steering-Loop-Eintrag.
**Danach ist das Closure-Kriterium der [welle-08](../welle-08-cpp-hexslice.md) wahr.**

## 6. Risiken und offene Punkte

- **Der Zahn muss aus dem richtigen Grund rot sein.** Ein Include auf einen Adapter-Header kann
  auch den *Compiler* röten (fehlende Datei, Zyklus). Der Beleg prüft deshalb den **Befundtext**
  (`core-impurity`/`wrong-direction`), nicht nur den Exit-Code — die Lehre aus welle-07.
- **Der Root-One-Shot kostet einen weiteren vollen C++-Build** im `full-smoke` (apt-Toolchain).
  Das ist der Preis dafür, dass die Aussage belegt statt plausibel ist; die Alternative wäre, sie
  ungeprüft zu lassen (Review-F-5 hat genau das gemeldet).
- **Die Doku-Aussage ist die letzte Stelle, an der eine Zusage ohne Sensor entstehen kann.** Sie
  fällt deshalb erst, wenn (1) und (2) grün sind — die Reihenfolge ist Teil des Slice, nicht
  Geschmack.
- **Kein Carveout absehbar.**

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

**Alle berührten Sub-Areas GF** (siehe Kurs Modul 5 §Worked Mini-Example): die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) führt `*` (gesamtes Repo) und
`harness/tools/` als **Greenfield**. Der Vollblock entfällt damit laut Template.
