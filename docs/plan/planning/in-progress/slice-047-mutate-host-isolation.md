# Slice slice-047: mutate gegen isolierte Kopie (Host-Baum nie mutieren)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Härtung — löst die F-12-Klasse strukturell auf).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (der Mutations-Sensor bewacht [`AGENTS.md` §3.6](../../../../AGENTS.md); dieser Slice ändert nur seine Ausführungs-Isolierung, nicht seine Semantik).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-24.

---

## 1. Ziel

`make mutate` fährt den gesamten Mutations-Zyklus (Mutation anwenden → Sensor `make test`)
gegen eine **isolierte Kopie** des Arbeitsbaums statt gegen die echten Host-Dateien — der
Host-Arbeitsbaum wird während eines mutate-Laufs **nie** verändert. Damit ist die F-12-Klasse
(paralleler Gate-Lauf misst mutierten Stand; Kill lässt Mutation liegen; mutate blockiert
lesende Rollen) **strukturell** aufgelöst statt per Disziplin umgangen.

## 2. Definition of Done

- [ ] Der Host-Arbeitsbaum ist während UND nach einem `make mutate`-Lauf **byte-unverändert**:
      ein Content-Hash der getrackten+ungetrackten Dateien vor dem Lauf == nach dem Lauf, und ein
      **paralleler** `make test`/Hash-Sample MITTEN im Lauf sieht keine Mutation (die F-12-Reproduktion
      aus [slice-044](../done/slice-044-generator-kompositions-seam.md) läuft jetzt sauber).
- [ ] Der Mutations-Sensor bleibt **semantisch identisch** (dieselben Fälle, dieselben vier
      Befund-Wege aus `mutate.sh`): jede Mutation färbt ihren Wächter rot, ein veralteter/wirkungsloser
      Patch bleibt ein Befund. `make mutate` liefert weiter „N ok, M Befund(e)".
- [ ] Ein **abgebrochener** Lauf (SIGKILL) hinterlässt **keine** Residuen im Host-Baum (die Isolation
      liegt außerhalb; kein `git checkout -- .`-Recovery mehr nötig).
- [ ] `mutate.lock` wird überflüssig ODER bewacht nur noch die Isolations-Ressource — dokumentiert.
- [ ] `make gates` grün (inkl. shellcheck auf das geänderte `mutate.sh`).
- [ ] `make mutate` grün gegen die Isolation (Selbst-Beweis: der geänderte Sensor bewacht sich weiter).
- [ ] Doku: `harness/conventions.md` (der MR-Block zu F-12 / mutate) auf „isoliert, kein Host-Baum-Kontakt" nachgezogen.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

Vor Code den Ist-Stand messen: `harness/tools/mutate.sh` lesen — heute sichert `restore()` per
tar-Backup und wendet die Fall-Seds (`sed -i <host-datei>`) auf den **Host-Baum** an; `make test`
läuft dann via `docker build` (Docker-only, [ADR-0003](../../adr/0003-go-native-binaries.md)). Die Mutation selbst ist NICHT containerisiert
— genau das löst dieser Slice.

**Isolations-Kandidaten (im ersten Impl-Lauf entscheiden, kleinste tragfähige Variante):**

| Ansatz | Skizze | Abwägung |
|---|---|---|
| **Temp-Kopie** (`cp -r`/`git archive`) | Baum in ein `mktemp -d` kopieren (getrackt+ungetrackt, aber `.git`/Artefakte sparsam), dort seddieren + `make test` (Build-Kontext = Kopie), danach Verzeichnis wegwerfen | einfach, kein git-Zustand berührt; Kopier-Kosten je Lauf einmalig |
| **`git worktree`** | temporäre Worktree anlegen, dort mutieren | git-nativ; ABER die slice-044-Falle: eine Worktree unter dem Repo liegt UNGETRACKT im Host-Baum → [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Hash verschiebt sich → Stop-Hook feuert. Muss AUSSERHALB des Repos liegen + ggf. gitignoren |
| **In-Container** | Mutation + Test in einem Schritt im Build-Kontext einer Kopie | am saubersten, aber die Fall-Seds müssten in den Build-Kontext wandern |

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/mutate.sh` | refactor | den Zyklus (Backup/sed/`make test`/restore) durch „in isolierter Kopie ausführen, Host-Baum nie anfassen" ersetzen; die vier Befund-Wege + `# files:`/`# expect:`/`# verify:`-Header-Semantik erhalten |
| `harness/conventions.md` (MR-Block) | update | den F-12-/mutate-Eintrag auf „isoliert" nachziehen (die Disziplin-Regel wird durch Struktur ersetzt) |
| ggf. `.gitignore` / Makefile | update | falls die Isolation ein ignorierbares/aufräumbares Artefakt braucht |

## 4. Trigger

- **Beginn (`next` → `in-progress`):** wann immer die Harness-Härtung priorisiert wird — keine harte
  Abhängigkeit. Motiviert durch die wiederholte F-12-Reibung in welle-07 (slice-045a/045b: mutate
  blockierte die lesenden Rollen, Background-Läufe wurden gekillt, Stop-Hook-Zyklen).
- **`in-progress` → `next` (zu groß):** falls die In-Container-Variante den Fall-Header-Vertrag
  umbaut — dann erst „Temp-Kopie" liefern (Host-Baum-Isolation), In-Container als Folge-Slice.
- **`in-progress` → `open` (blockiert):** falls die Kopie den Docker-Build-Kontext unpraktikabel
  aufbläht (Performance) — Carveout + Messung.

## 5. Closure-Trigger

DoD vollständig, `make gates` + `make mutate` grün, der Host-Baum-Unveränderlichkeits-Beweis (DoD 1)
real gesehen, Review konform + Verifier bestätigt die DoD, Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Docker-Build-Kontext:** die Kopie muss alles tragen, was `make test` braucht (Dockerfile,
  go.mod/Quellen, harness/mk, Fixtures) — eine zu sparsame Kopie ließe Tests scheitern, eine zu
  großzügige kostet Zeit. Messen.
- **slice-044-Worktree-Falle:** eine Isolation UNTER dem Repo-Root liegt ungetrackt im Host-Baum
  und verschiebt den [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Stop-Hook-Hash → die Isolation gehört AUSSERHALB des Repos (oder strikt
  gitignoriert + vom Hash-Sensor ausgenommen).
- **Semantik-Erhalt:** die vier Befund-Wege (Skript scheitert · Mutation wirkungslos · Sensor bleibt
  grün · rot aus falschem Grund) müssen 1:1 erhalten bleiben — ein Refactor, der einen Weg still
  verliert, schwächt den Sensor. Gegen den heutigen `mutate.sh` diffen.
- **Nicht-Ziel:** die Mutations-FÄLLE (`test/mutations/*.sh`) und ihre Semantik bleiben unberührt —
  nur die Ausführungs-Isolierung ändert sich.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Reiner **Refactor** bestehender Harness-Tooling (`harness/tools/mutate.sh`) ohne neue Sub-Area —
verhaltens-erhaltend (Sensor-Semantik identisch, nur die Ausführungs-Isolierung ändert sich).

### Sub-Area: harness/tools (Mutations-Sensor)

- **Modus:** BF (Bestandscode, hohe Konventionen-Dichte)
- **Konventionen-Dichte:** hoch — `mutate.sh` trägt die vier dokumentierten Befund-Wege, den
  `# files:`/`# expect:`/`# verify:`-Header-Vertrag und die F-12-/Lock-Kommentare; der MR-Block in
  `harness/conventions.md` referenziert das Verhalten.
- **Phase-Reife:** Phase 5 (etablierte, getestete Infrastruktur) — ein Umbau muss den Vertrag wahren.
- **Evidenz-/Diskrepanz-Risiko:** niedrig-mittel — das Diff gegen den heutigen `mutate.sh` macht jeden
  still verlorenen Befund-Weg sichtbar; der Selbst-Beweis (mutate bewacht sich) fängt Regressionen.
- **Reconciliation-Aufwand:** gering — eine Datei + der MR-Block; kein Folge-Slice nötig, außer die
  In-Container-Variante wird als Ausbaustufe abgespalten.
