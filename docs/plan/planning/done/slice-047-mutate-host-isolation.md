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

- [x] Der Host-Arbeitsbaum ist während UND nach einem `make mutate`-Lauf **byte-unverändert**:
      ein Content-Hash der getrackten+ungetrackten Dateien vor dem Lauf == nach dem Lauf, und ein
      **paralleler** `make test`/Hash-Sample MITTEN im Lauf sieht keine Mutation (die F-12-Reproduktion
      aus [slice-044](../done/slice-044-generator-kompositions-seam.md) läuft jetzt sauber).
- [x] Der Mutations-Sensor bleibt **semantisch identisch** (dieselben Fälle, dieselben vier
      Befund-Wege aus `mutate.sh`): jede Mutation färbt ihren Wächter rot, ein veralteter/wirkungsloser
      Patch bleibt ein Befund. `make mutate` liefert weiter „N ok, M Befund(e)".
- [x] Ein **abgebrochener** Lauf (SIGKILL) hinterlässt **keine** Residuen im Host-Baum (die Isolation
      liegt außerhalb; kein `git checkout -- .`-Recovery mehr nötig).
- [x] `mutate.lock` wird überflüssig ODER bewacht nur noch die Isolations-Ressource — dokumentiert.
- [x] `make gates` grün (inkl. shellcheck auf das geänderte `mutate.sh`).
- [x] `make mutate` grün gegen die Isolation (Selbst-Beweis: der geänderte Sensor bewacht sich weiter).
- [x] Doku nachgezogen — **mit Plan-Drift:** einen MR-Block-Eintrag zu F-12/mutate gibt es in
      `harness/conventions.md` **nicht** ([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)…[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) kennen keinen; `mutate` erscheint dort nur in
      den CI-Absätzen). Nachgezogen wurde deshalb dort, wo der Sensor beschrieben wird:
      [`AGENTS.md`](../../../../AGENTS.md) §4 und [`harness/README.md`](../../../../harness/README.md)
      §Nicht-Gate-Verify. Vom Verifier als vollständiger Ersatz-Ort bestätigt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

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
**Geliefert.** `make mutate` fährt den Zyklus gegen eine **isolierte Kopie außerhalb des Repos**;
der Host-Arbeitsbaum wird nie beschrieben. Belegt, nicht zugesagt: der Treiber vergleicht den
Fingerabdruck der Zieldatei(en) **je Fall zwischen Mutation und Restore** (und einmal über alle
Ziele am Ende) und **bricht ab**, wenn der Baum betroffen ist. Real gesehen: `make gates` lief
mehrfach **grün parallel zu einem laufenden `make mutate`**, und während eines Laufs wurde die
Roadmap editiert — beides war vor diesem Slice die F-12-Reibung, die drei Slices lang jede lesende
Rolle blockiert hat. Sensoren: `make gates` grün (176 Dateien, 0 Befunde) · `make mutate`
**73 ok/0** mit den Fällen 72–77 je rot **an ihrem eigenen Wächter** · `shell-lint` clean.
Review Runde 1 und 2 NICHT KONFORM (je 3 MEDIUM), Runde 3 (eng, auf Abbruch-Pfad und Wächter)
NICHT KONFORM (1 MEDIUM) — alle aufgelöst; Verifier **DoD BESTÄTIGT** (Runde 2, beide TEILWEISE
geschlossen).

**Anders als geplant.** Drei Dinge, die der Plan nicht kannte:

1. **Die Kopie braucht `.git`.** Der Plan (und meine Messung) sahen nur `test/`; `make ci-lint`
   fährt aber actionlint, und das bricht ohne git-Projektwurzel ab. Der **Grün-Vorlauf** fing es
   beim allerersten Lauf — genau dafür gibt es ihn.
2. **Der Fingerabdruck musste zweimal umgebaut werden.** Erst lauf-weit über alle Ziele (rötete
   jede parallele Arbeit — der Nutzen des Slice hob sich selbst auf), dann fall-lokal mit Abbruch.
3. **Der Plan-Drift bei der Doku:** einen MR-Block-Eintrag zu F-12/mutate gibt es nicht; der
   Nachzug ging an die Orte, wo der Sensor wirklich beschrieben wird.

**Steering-Loop-Eintrag — die Lehre dieses Slice.**

Dieselbe Fehlerklasse ist **viermal** aufgetreten, jedes Mal eine Ebene tiefer:

| Die Zusage lag bei … | … der Wächter aber bei | gefunden von |
|---|---|---|
| fail-closed ohne git | `pipefail` propagierte den Fehler ohnehin | `make mutate`, Bedingung 3 |
| leere Ziel-Liste | ein leerlaufendes Glob scheiterte vorher | `make mutate`, Bedingung 3 |
| Ortsregel der Kopie | vorgelagerte Nicht-Leer-Assertion | Reviewer, Runde 2 |
| Abbruch nach erkanntem Bruch | Meldungstext statt Exit-Status | Reviewer, Runde 3 |

Die gemeinsame Ursache ist **Mehrfach-Absicherung**: wo eine Eigenschaft doppelt gesichert ist,
ist die *vordere* Schranke unbeobachtbar — und der Fall sieht trotzdem gut aus, weil er ja rot
wird. **Regel, schärfer als „eine Mutation muss Verhalten brechen": ein Fall belegt nur die
Schranke, die im Test-Szenario als ERSTE greifen kann. Wer eine Mutation schreibt, geht den Pfad
bis zur Assertion durch, statt sich mit „es wird rot" zufriedenzugeben.**

Zwei Nebenlehren:

- **Deckung ergänzen, nicht ersetzen.** Beim Re-Verankern von Fall 72 blieb der alte Wächter
  nackt zurück — die slice-034-Lehre „entfernte Mutation = entfernte Deckung", reproduziert,
  während sie in derselben Sitzung zitiert wurde. Kennen schützt nicht; nachzählen schützt.
- **Einen Rot-Beleg zu bauen ist selbst ein Sensor.** Der Versuch, die Isolationsprüfung rot zu
  sehen, förderte einen echten Reihenfolge-Fehler zutage: der Bruch wurde als „Patch veraltet"
  fehldiagnostiziert. Ohne den Beleg-Versuch wäre die Meldung im Ernstfall in die falsche
  Richtung gelaufen.

**Benannte Restrisiken (kein Folge-Slice):**

- Der Fingerabdruck deckt die `# files:`-Ziele, nicht den ganzen Baum — bewusster Preis dafür,
  dass parallele Arbeit den Lauf nicht rötet. Ein Defekt, der eine Host-Datei außerhalb dieser
  Menge schreibt, fiele hier nicht auf.
- Editierst du während eines Laufs die Zieldatei des gerade laufenden Falls, schlägt der Wächter
  an; host-seitig ist das nicht von einem echten Bruch zu unterscheiden. Die Meldung nennt beide
  Ursachen.
- Der Abbruch-Exit-Code ist nicht von „Befunde gefunden" unterscheidbar (beide 1).
- Die Reichweite des `exit` hängt am Aufrufkontext (heute plain in der Schleife, geprüft).
- `require_isolated` wird trotz Kommentar nur einmal in `main` gerufen; Fall 72 ankert auf
  Einrückungstiefe.
- **R-4:** der geteilte Docker-Tag `ai-harness-init:build` in `artifact`/`smoke` bleibt ein
  Ressourcen-Kanal; der Lock serialisiert `mutate`-Läufe, nicht ein paralleles `make artifact`.
- **In-Container** (Mutation *und* Test im Container) bleibt die sauberste Stufe und ein
  möglicher Folge-Slice; die Temp-Kopie liefert dieselbe Host-Unversehrtheit ohne den Umbau des
  Fall-Header-Vertrags.

**Folge-Slices:** keine neuen aus diesem Slice. Der Sensor für die **Wächter-zu-Fall-Zuordnung**
(diese vier Datenpunkte sind sein Bedarfsnachweis) ist als Achse 5 des Wartungs-Kandidaten in der
Roadmap eingetragen — mit der Schärfung, dass er nicht nur zählen darf, *ob* ein Wächter einen Fall
hat, sondern prüfen muss, ob der Fall den **Zweig trifft, den der Wächter im Namen führt**.


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
