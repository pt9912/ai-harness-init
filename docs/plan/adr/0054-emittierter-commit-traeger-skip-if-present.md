# ADR-0054: Der emittierte Commit-Träger liegt an einem Namen, den git fixiert — er wird skip-if-present abgelegt

**Status:** Proposed

**Datum:** 2026-09-15

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0007](0007-bootstrap-phasen.md) (**Accepted** — ihre Festlegung 3 führt die Idempotenz-Klassifikation
**je Datei**; die Wurzeln ihrer Tabelle nennen den Pfad dieses Trägers nicht, und ihre Zweifelsregel
entscheidet ihn. **Kein `Supersedes`** — die Begründung steht in §Konsequenzen),
[ADR-0053](0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) (Festlegung 1 wählt den
git-eigenen Träger; ihre §Kontext nimmt die **emittierte Ebene** ausdrücklich aus und verweist sie an
den Slice, der die Tool-Ebene entscheidet — die Klasse dieses Pfades ist damit die offene Hälfte
derselben Wahl),
[`MR-005`](../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption) (das
emittierte Layout, das den Prüfpfad des Ziels von dem dieses Repos trennt),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Baseline-Aussage nennt den Tag, gegen den sie gemessen ist),
[`MR-055`](../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)
(eine Stellen-Messung trägt keine Folgerung über eine Eigenschaft — der Grund, warum Festlegung 4 die
`.claude/`-Zeilen der Tabelle nicht mitzieht),
[`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(die Form der Kennung in §Konsequenzen),
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (sein Adopter ist ein
**bestehendes** Git-Repo; seine Boundary-Ak setzt die zwei Klassen in Kraft),
[`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (die
Durchsetzungsschicht, zu der die drei Dateien gehören),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Reichweiten-Aussage, die weiter ist als ihr Prüfbereich, behauptet mehr als sie mißt),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)

**Schärft:** [`ARC-003`](../../../spec/architecture.md#2-schichten-und-constraints) — die
Idempotenz-Klassifikation je Datei, hier verbindlich gemacht für die drei Träger-Dateien der
emittierten Commit-Kennung. Keine Spec-Aussage ändert sich; ihr Prüfbereich wächst um einen Pfad.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

### Ein Gegenstand, drei Dateien — und zwei ihrer Klassen stehen schon in der Tabelle

Die emittierte Kennungs-Zusage hängt an drei Dateien: dem git-eigenen Hook, der Prüfung, die er
aufruft, und dem Fragment, das ihn im Klon aktiviert. [ADR-0053](0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
Festlegung 1 entscheidet den **Träger**; ihre §Kontext nimmt die emittierte Ebene aus: *„was ein
gebootstrapptes Zielrepo an Commit-Wächtern bekommt, entscheidet der Slice, der die Tool-Ebene
entscheidet"*. Diese Datei entscheidet die **Klasse**, mit der die drei Dateien im Ziel abgelegt
werden.

```sh
grep -c 'commitMsgHookFile()\|commitMsgCheckFile()\|hooksInstallMkFile()' internal/emit/enforce.go   # 3
grep -n 'for _, f := range enforceFiles()' internal/emit/enforce.go                                  # :229 — die Schreib-Schleife; die zweite Nennung (:411) liest nur
grep -n 'writeFileMode(targetDir, f.dst, content, f.mode)' internal/emit/enforce.go                  # :234 — der Aufruf in dieser Schleife; :246 gehört zur Traeger-Schleife
```

Das erste Kommando gibt die **Zahl** der Einträge; die Schreib-Semantik trägt es nicht — sie steht im
Rumpf dieser Schleife und im Kommentar über `enforceFiles()`. Heute unterliegen alle drei dem
konvergenten Writer; **Festlegung 1 löst das für einen von ihnen ab**, und die Zahl des ersten
Kommandos bleibt dabei stehen. **Kein Erwartungswert** — die drei Zahlen wandern mit dem Code.

Zwei ihrer Klassen sind von [ADR-0007](0007-bootstrap-phasen.md) Festlegung 3 bereits gedeckt, weil
ihre Zielpfade unter Wurzeln fallen, die die Tabelle dort nennt: `tools/harness/*` (die Prüfung) und
`harness/mk/*.mk` (das Aktivierungs-Fragment). Für den dritten Pfad gilt das nicht:

```sh
grep -c 'githooks' docs/plan/adr/0007-bootstrap-phasen.md      # 0
```

**Kein Erwartungswert** ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahl wandert, wenn die Tabelle fortgeschrieben wird; tragend ist hier, dass sie
heute null ist.

### Was die Tabelle dort trägt — und was nicht

Die konvergente Zeile der Tabelle nennt `.harness/baseline/<tag>/`, `.harness/skills/*`,
`harness/mk/*.mk`, `d-check.mk`, `.claude/hooks/*.sh`, `.claude/settings.json`, `tools/harness/*`
und `tools/harness/blocked/<sprache>`. Jeder Eintrag ist eines von beidem: ein **Verzeichnis, das
die Emission selbst anlegt**, oder ein **Name, den das Werkzeug wählt**. `.githooks/` ist keines von
beidem.

### Der Pfad ist fremder Boden, und der Ausweg im Text entscheidet ihn nicht

`.githooks/` ist das Hook-Verzeichnis, das `git` über `core.hooksPath` aktiviert — es gehört zum
Repo, nicht zur Emission. Der Dateiname ist von `git` fixiert: git ruft einen Hook über seinen
nackten Namen auf, `commit-msg` ist also keine Wahl des Werkzeugs, sondern die Form der fremden
Regel. Das Werkzeug ist an diesem Pfad ein **Gast**.

Der emittierte Baum kennt dafür einen Ausweg, und er steht im Text zweier Dateien: der Kopf der
Prüfung sagt, ein Repo mit eigener Kennungs-Klasse setze `HOOKS_DIR` auf sein **eigenes**
Hook-Verzeichnis und führe dort seinen Träger; das Aktivierungs-Fragment beginnt mit
`HOOKS_DIR ?= .githooks`. Was dieser Ausweg leistet, ist die **Aktivierung**: er verschiebt, welches
Verzeichnis `core.hooksPath` bekommt. Was er nicht leistet, ist die Klasse der Datei unter
`.githooks/commit-msg` — und er ist erst **nach** dem Lauf lesbar. Ein Adopter, der den Pfad bereits
belegt hat, erfährt die Konvention aus der Datei, die seinen Träger ersetzt hat.

### Was die zwei Klassen an diesem Pfad jeweils kosten

**Konvergent** heißt nach ADR-0007 Festlegung 3 „kanonisch neu schreiben, nie prunen". Der Writer
dieser Klasse schreibt unbedingt — er prüft weder eine Marke noch eine Herkunft:

> „`writeFileMode` ist der KONVERGENTE Writer … schreibt content nach targetDir/rel (slash) mit mode
> IMMER (kanonisch, ueberschreibt)" — `internal/emit/enforce.go`

Ein Lauf kann an diesem Pfad darum nicht unterscheiden, ob die liegende Datei seine eigene ist. Bei
falscher Klasse heißt das: das Ziel verliert seinen Träger lautlos und steht danach **schlechter**
da als vor dem Lauf — genau die Fehl-Klasse, die ADR-0007 §Konsequenzen nennt.

**Skip-if-present** schreibt nur, wo nichts liegt. Der Preis ist derselbe Satz von der anderen
Seite: der Träger des Werkzeugs wird nach seinem ersten Schreiben nicht mehr geheilt. Er ist ein
Delegator — sein Inhalt besteht aus dem Aufruf der Prüfung —, und die **Prüfung** bleibt unter einer
konvergenten Wurzel, ihre Pflege also unberührt.

### Ein Repo, das diese Zusage führt, füllt den Pfad selbst

```sh
diff .githooks/commit-msg internal/emit/templates/enforce/commit-msg-hook.sh   # Exit 1
```

Die zwei Dateien rufen verschiedene Prüfpfade auf — dieses Repo den seinen unter `harness/tools/`,
der emittierte Träger den des **Ziels** unter `tools/harness/`. Der Grund ist hier die
Layout-Achse ([`MR-005`](../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)),
nicht eine Entscheidung über die Klasse: **was der Vergleich zeigt, ist, daß dieser Pfad
repo-eigenes Programm tragen kann; wie oft ein gebautes Ziel ihn belegt, ist damit nicht gemessen**
([`MR-055`](../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)).

Die Frage, die diese Entscheidung beantwortet, ist darum ein **Urteil** ([`AGENTS.md`](../../../AGENTS.md)
§3.6): Kann an diesem Pfad ein legitimer Adopter-Zustand bestehen, in dem die Datei nicht die des
Werkzeugs ist? Der Adopter dieses Werkzeugs ist ein **bestehendes** Git-Repo
([`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)), und ein Repo, das den
Traceability-Satz dieses Prozesses bereits führt, führt ihn am Commit — in dieser Familie unter genau
diesem Namen (`git ls-files -s .githooks/` → `100755 .githooks/commit-msg`). Die Zweifelsregel der
adoptierten Ordnung ist damit anwendbar, und sie ist eindeutig: `ARC-003` führt
*„im Zweifel konvergent klassifizieren"* als **Fehlerbild**, ADR-0007 Festlegung 3 als Satz —
*„im Zweifel gilt `skip-if-present` (nie Adopter-Inhalt clobbern — der sichere Default)"*.

## Entscheidung

**Wir legen `.githooks/commit-msg` skip-if-present ab und lassen die zwei übrigen Dateien, wo
ADR-0007 sie führt.** Vier Festlegungen.

**1. Die Klasse der drei Träger-Dateien, je Datei.**

| Ziel-Datei | Klasse | Herkunft der Klasse |
|---|---|---|
| `tools/harness/commit-msg-traceability.sh` (die Prüfung) | **konvergent** | **bestätigt** — Wurzel `tools/harness/*` der Tabelle in [ADR-0007](0007-bootstrap-phasen.md) Festlegung 3 |
| `harness/mk/hooks-install.mk` <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) --> (die Aktivierung) | **konvergent** | **bestätigt** — Wurzel `harness/mk/*.mk` derselben Tabelle |
| `.githooks/commit-msg` (der Träger) | **skip-if-present** | **neu festgelegt** — der Name ist von `git` fixiert, das Verzeichnis ist das des Repos; an diesem Pfad ist das Werkzeug ein Gast (§Kontext) |

**2. Der Unterschied ist der des Gegenstands, nicht der des Inhalts.** Die konvergente Klasse der
Tabelle ruht auf Wurzeln, an denen das Werkzeug **bestimmt**, was liegt: ein Verzeichnis, das die
Emission anlegt, oder ein Name, den sie wählt. Für einen Werkzeug-inhaltigen Delegator an einem
git-fixierten Namen in einem Repo-Verzeichnis gilt beides nicht. Die drei Dateien sind damit
**nicht** durch eine gemeinsame Regel zu lesen — ihre Klasse folgt dem Boden, auf dem sie liegen,
und der ist für zwei von dreien derselbe wie bisher.

**3. Skip-if-present heißt hier dreierlei.**

- **Der Pfad ist frei** — der Träger des Werkzeugs wird geschrieben. Das ist der Regelfall des
  leeren Ziels, und er ändert sich gegenüber heute nicht.
- **Der Pfad ist belegt** — die liegende Datei bleibt **unberührt**, und der Lauf **sagt es**.
  Ein stilles Übergehen wäre die zweite Hälfte desselben Fehlers: der Adopter soll erfahren, daß
  sein Träger stehenbleibt und die mitgelieferte Prüfung unter `tools/harness/` für ihn bereitliegt.
- **Die Prüfung bleibt konvergent** — was sich mit der Fassung des Werkzeugs ändert, wird weiter
  geheilt. Der Träger ist ein Delegator; sein Veralten bricht laut (ein `exec` auf einen
  verschobenen Prüfpfad endet mit Exit ≠ 0 im Commit-Pfad), es heilt nicht von selbst.

**4. Geltungsbereich: der git-eigene Hook-Pfad.** Diese Entscheidung bindet **einen** Pfad. Die
`.claude/`-Zeilen der Tabelle in ADR-0007 werden **nicht** mitgezogen: dieselbe Frage dort ist nicht
gemessen, und aus einer Messung an einer Stelle folgt nichts über eine Eigenschaft
([`MR-055`](../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)).
Ob sie neu zu wägen sind, entscheidet eine eigene Messung in einer eigenen Entscheidung.

## Verglichene Alternativen

Regeln dieser Sektion: **mindestens drei Optionen mit Pro/Contra** — „nichts tun" ist eine davon
(Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR)).

| Option | Pro | Contra |
|---|---|---|
| A — **konvergent, Tabelle um die Wurzel ergänzt** | der Bestand bleibt, wie er ist; der Träger heilt Drift, und die Zusage des Ziels steht ohne Vorbedingung; `HOOKS_DIR` bleibt der eine genannte Ausweg | der Lauf schreibt unbedingt und kann an diesem Pfad nicht erkennen, wessen Datei dort liegt: ein Repo, das seine Zusage schon führt, verliert seinen Träger **lautlos** und steht danach schlechter da als vor dem Lauf. Der Ausweg hilft nicht — er steht in der Datei, die den Träger ersetzt hat, und wird erst danach lesbar. Die Zweifelsregel ist damit überspielt, und `ARC-003` führt genau das als Fehlerbild |
| B — **skip-if-present, mit Meldung (gewählt)** | kein Adopter-Zustand wird schlechter als vorher; der Unterschied trägt den Gegenstand statt einer Fassung — zwei Wurzeln der Tabelle bleiben unverändert gültig; die Prüfung als das Werkzeug-gepflegte Stück bleibt konvergent | der Träger wird nach dem ersten Schreiben nicht mehr geheilt (§Entscheidung 3); in einem Ziel mit belegtem Pfad kommt der Träger des Werkzeugs nicht an, und die Prüfung liegt dort zunächst ohne Aufrufer |
| C — **konvergent mit Eigentums-Marke** (eine Marke im emittierten Träger; eine fremde Datei stehen lassen und melden) | der genaue Zustand: den eigenen Träger heilen, den fremden schonen | führt eine **dritte** Größe in eine zweiklassige Ordnung ein — Marke, eigener Writer, eigener Test und eine zweite Klasse neben der Fitness-Zeile *„jede emittierte Datei an ihre Klasse"* — für **einen** Pfad. Der Ertrag wiegt den Preis nicht auf: der Träger ist ein Delegator, dessen Veralten laut bricht (Festlegung 3), und die Regel, die sich mit der Fassung ändert, wird ohnehin konvergent geheilt |
| D — **nichts tun** (der Pfad bleibt unklassifiziert, der Code schreibt weiter konvergent) | keine Änderung an Text oder Code; der Bestand läuft und `make gates` bleibt grün | die Klasse bleibt dem Code überlassen, und der Code hat sie getroffen, ohne daß sie irgendwo steht: die Zusage des Repos, Adopter-Inhalt nicht zu überschreiben, hängt dann an einer Setzung, die niemand ausgesprochen hat. Das ist der Zustand, in dem eine Fehl-Klasse niemandem auffällt, bis sie zuschlägt |

## Konsequenzen

- **Positiv:** Die Klasse des Pfades hat eine Adresse. Die Zweifelsregel der Tabelle aus
  [ADR-0007](0007-bootstrap-phasen.md) Festlegung 3 ist damit **angewandt** und nicht stillschweigend
  übergangen.
- **Positiv:** Ein Repo, das seine Kennungs-Zusage bereits am Commit führt, behält seinen Träger. Ein
  Re-Lauf des Werkzeugs kann es nicht schlechter stellen als es vorher war.
- **Positiv:** Die zwei Dateien, deren Klasse schon gedeckt war — die Prüfung und die Aktivierung —,
  bleiben in ihrer Wurzel. Nur eine Datei wechselt die Klasse.
- **Negativ:** Der Träger des Werkzeugs wird nach seinem ersten Schreiben nicht mehr geheilt. Sein
  Veralten ist laut, aber es fällt auf den Adopter.
- **Negativ:** In einem Ziel mit belegtem Pfad kommt der Träger nicht an; die Aktivierung setzt
  `core.hooksPath` weiter auf das Verzeichnis und weiß nicht, wessen Programm dort liegt. Die
  Meldung aus Festlegung 3 macht den Zustand sichtbar, sie behebt ihn nicht.
- **Negativ, und das ist der Preis:** An einem belegten Pfad liegt die mitgelieferte Prüfung zunächst
  **ohne Aufrufer** — ein Artefakt, dessen Konsument fehlt. Benannt, nicht verhindert; der Adopter
  kann sie aus seinem Träger aufrufen, und die Zeile dazu steht in seinem Repo.
- **Kein `Supersedes`.** [ADR-0007](0007-bootstrap-phasen.md) wird **nicht** abgelöst und ihre
  Tabelle **nicht** fortgeschrieben: sie nennt den Pfad nicht, und was sie nicht nennt, entscheidet
  ihre Zweifelsregel — diese Datei wendet sie an und ist damit die spätere, nicht die abweichende.
  Ein `Supersedes` behauptete eine neue Entscheidung über denselben Gegenstand; hier gibt es keinen.
  Die Tabelle bleibt eingefroren wie jede `Accepted`-ADR
  ([`AGENTS.md`](../../../AGENTS.md) §3.4), und was sie nicht führt, führt diese Datei.
- **Folgepflicht 1 — der Vorgang, und er ist Implementer-Arbeit.** Der Träger verläßt die konvergente
  Menge **im Code**: die Aufzählung, die ihn führt, und jeder Nachbar, der über „jede emittierte
  Datei wird konvergent geschrieben" fährt, ziehen mit. Dazu die Meldung aus Festlegung 3 und die
  Sätze, die am Pfad behaupten, der Träger sei der des Werkzeugs — der Kopf und die Fehlermeldung des
  Aktivierungs-Fragments (*„den Traeger, den der Bootstrap schreibt"*), der Commit-Absatz des
  emittierten Anweisungssatzes (*„weist der git-eigene Hook `.githooks/commit-msg` ab"*) und der
  Absatz in [`harness/README.md`](../../../harness/README.md#traceability) §Traceability, der für das
  gebootstrappete Ziel *„beide schreibt der Bootstrap kanonisch neu"* sagt —, jedes an
  seiner Stelle gezogen auf das, was gilt. Die Kennung nach
  [`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  lautet **`slice-commit-traeger-wird-skip-if-present`**. Schnitt, Priorisierung und Vorschau-Zeile
  sind **Planner-Arbeit**; der Vorgang liegt im Planning-Lifecycle, und seine Kennung löst dort auf.
- **Folgepflicht 2 — die zwei Nachbar-Dateien brauchen nichts.** Ihre Klassen sind bestätigt, nicht
  geändert; wer sie liest, findet weiter die Wurzel aus der Tabelle.

## Fitness Function (falls maschinell prüfbar)

**Diese Entscheidung behauptet keinen neuen Sensor — sie zieht einen bestehenden auf den Gegenstand.**
Was die Klasse prüfbar macht, steht als Zeile in [ADR-0007](0007-bootstrap-phasen.md) §Fitness
Function und gilt fort:

| Tooling | Regel | Make-Target |
|---|---|---|
| `go test` | **ein emittierter Pfad, eine Klasse:** die Prüfung wird kanonisch neu geschrieben, der Träger **nicht**, wenn der Pfad belegt ist, und **doch**, wenn er fehlt | `make test` |
| `go test` | **jeder emittierte Pfad trägt genau eine Klasse** — ein Pfad ohne Klasse färbt rot (Zeile *„Klassifikation"* der Tabelle in ADR-0007 §Fitness Function). **Diese Vollständigkeit trägt heute nur einer der zwei Emitter**; welcher, steht unter dieser Tabelle | `make test` |
| **kein Gate** — die Meldung aus Festlegung 3 ist **Ausgabe**, kein Sensor. Ob ein belegter Pfad dem Adopter gemeldet wurde, prüft kein Modul des Doku-Gates (`grep -n '^modules:' .d-check.yml`), und `make mutate` kennt keine Fehlschlag-Form dafür. Benannt, nicht bewacht | — | — |

**Was heute gegen die erste Zeile läuft, ist der Test über die ganze Menge:** er hält für jeden Pfad
der Aufzählung die konvergente Klasse fest, also auch für den Träger. Er fällt mit dem Vorgang aus
Folgepflicht 1 — bis dahin ist er die Stelle, an der die zwei Klassen aufeinandertreffen, und das
ist eine Aussage über den Sensor, keine über den Bau.

**Die zweite Zeile trägt heute für eine Hälfte der Emitter.**
[`TestTemplates_EmittierterBestandVollstaendig`](../../../internal/emit/templates_test.go) hält den
Ist-Bestand der Vorlagen-Emission **vollständig** gegen eine Erwartungsliste — dort färbt jeder Pfad
rot, der nur auf einer der beiden Seiten steht. Der Enforce-Emitter führt dieselbe Inventur als
**Teil**mengen-Prüfung: `TestEnforce_EmitsAllMechanicFiles` sucht je erwartetem Pfad nach seinem
Vorkommen in der Aufzählung und meldet darum keinen Pfad, der umgekehrt nur in der Aufzählung steht;
und `TestEnforce_Convergent` läuft über **jeden** Pfad dieser Aufzählung und verlangt die konvergente
Klasse — ein korrekt skip-if-present geführter Pfad ist dort kein erkennbarer Zustand, sondern ein
Rot. Für die zweite Zeile trägt damit der Vorlagen-Emitter und der Enforce-Emitter nicht: **benannt,
nicht bewacht.**

## Re-Evaluierungs-Trigger

- **Wenn das Werkzeug die Herkunft entscheiden kann** — eine Marke im emittierten Träger, ein eigenes
  Hook-Verzeichnis, das `git` direkt aktiviert, oder ein Pfad, den das Werkzeug selbst wählt —, dann
  ist der Gast-Zustand dieses Pfades entfallen und mit ihm der Grund der Klasse.
- **Wenn gemessen ist, daß gebaute Ziele den Pfad nicht belegen** (eine Stichprobe tatsächlich
  gebootstrappter Ziele ohne fremden Träger), dann wiegt der Heilungs-Verlust schwerer als das
  Überschreib-Risiko, und die Klasse ist neu zu wägen. Bis dahin steht sie auf dem Urteil aus
  §Kontext und nicht auf einer Zahl.
- **Wenn `git` einen Hook aus dem Baum aktiviert**, verschiebt sich der Ort der Trägerschaft selbst
  — dann ist die Frage der Klasse hier gegenstandslos und die Wahl der Trägerschaft
  ([ADR-0053](0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)) neu zu fassen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-15 | **Proposed** | Architect-Lauf zur Klasse des emittierten Commit-Trägers, ausgelöst von dem Slice `slice-kennungs-waechter-geht-ins-ziel` ([`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) Kennungs-Form). Die Messungen in §Kontext stehen neben ihren Kommandos |
| 2026-09-16 | **Überarbeitet, weiter Proposed** | Die zweite Fitness-Zeile steht auf dem, was sie trägt: den vollständigen Ist-Bestand gegen eine Erwartungsliste hält der Vorlagen-Emitter, der Enforce-Emitter führt eine Teilmengen-Inventur und verlangt für **jeden** Pfad seiner Aufzählung die konvergente Klasse — die nicht gehaltene Hälfte ist damit benannt. Die Zahl der drei Träger-Einträge steht neben dem Kommando, das die Schreib-Semantik trägt; die Aufzählung der Folgepflicht nennt auch den Satz in [`harness/README.md`](../../../harness/README.md#traceability), und die Bedingung, unter der die Kennung „hier" auflöste, ist durch den Zustand ersetzt. Die Konsistenz-Runde ist gefahren und hat einen blockierenden Befund gemeldet; nach [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 ist der Beleg des Accept-Übergangs darum die nächste Runde derselben Rolle |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0054` (Baseline-Regelwerk `v6.8.0`, `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
