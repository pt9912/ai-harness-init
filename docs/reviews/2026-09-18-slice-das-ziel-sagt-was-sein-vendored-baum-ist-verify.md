# Verifikations-Report: `slice-das-ziel-sagt-was-sein-vendored-baum-ist` — 2026-09-18

**Rolle:** Verifier (Modul 11). Frage: *Bauen wir es richtig?* — gegen DoD, Plan und Spec.
**Nicht** die Frage des Reviewers (Diff gegen Plan/ADR/Hard Rules) und **nicht** die des
Validators (realer Bedarf). Die zwei Review-Reports sind **nicht** Eingangs-Kontext dieses
Laufs; sie werden nur dort genannt, wo die DoD-Zeile *„Report liegt vor"* sie zum Gegenstand
macht.

**Gegenstand:** `docs/plan/planning/in-progress/slice-das-ziel-sagt-was-sein-vendored-baum-ist.md`
§2, geprüft gegen den Stand `5c45749a`. Umsetzung in `6db58a73`, `15cd2a82`, `872170f4`,
`d47c7c57`, `3b7d7baa`, `0b891130`.

**Eingangs-Kontext:** der Slice-Plan (§1 bis §6) · `ADR-0020` Festlegung 4 · `ADR-0022`
Festlegung 7 · `LH-FA-06`, `LH-FA-09`, `LH-QA-01`, `LH-QA-03` · `MR-025`, `MR-033`, `MR-053`,
`MR-054` · `AGENTS.md` §3.2, §3.5, §3.6 · Baseline-Regelwerk `modul-11-verification.md`.

**Modell:** claude-opus-5 · **Datum:** 2026-09-18.

---

## 1. Eigene Läufe — was ich selbst gemessen habe

Kein Posten dieses Abschnitts ist aus einem fremden Bericht übernommen.

| Lauf | Ergebnis |
|---|---|
| `make host-bin` | EXIT 0 — Träger gebaut, Grundlage der zwei Sonden |
| Sonde A: `git init` + `ai-harness-init --name Probe` (sprachlos) | EXIT 0 |
| Sonde B: `git init` + `ai-harness-init --lang go --name ProbeGo` | EXIT 0 |
| `make gates` (dieses Repo) | **EXIT 0** · `comment-claims: 65 Datei(en) geprueft, 0 Befund(e)` |
| `make full-smoke` (dieses Repo) | **EXIT 0** · die neue Stufe meldet in **beiden** Varianten |
| `make test-go` unter `test/mutations/365` | **rot**, aus dem behaupteten Grund |
| `make test-bats` unter `test/mutations/366` | **rot**, aus dem behaupteten Grund |
| `make baseline-verify` in Sonde A | `baseline-verify: v6.9.0 OK — 54 Dateien` |

Die zwei Mutations-Läufe liefen in je einer isolierten Kopie (`git archive HEAD | tar -x`)
im Scratchpad, nicht im Arbeitsbaum.

**Eine Nebenwirkung der Isolation, damit sie niemand als Befund liest:** In beiden Kopien
fällt zusätzlich `not ok 192 driver: die Kopie traegt den Sensor-Bedarf inklusive .git`. Das
ist eine Eigenschaft meiner `git archive`-Kopie (sie trägt kein `.git`), nicht der Mutation.

---

## 2. Verdikt je DoD-Punkt

### DoD 1 — Das Ziel nennt den Freshness-Audit als geschuldete Handlung — **erfüllt**

Der Abschnitt `### Der mitgelieferte Baum altert still` steht in der emittierten
`harness/conventions.md` **beider** Sonden. Die drei geforderten Bestandteile, jeder an
meinem eigenen Stand nachgemessen:

- **Gepinnter Tag** — der Block nennt `v6.9.0` literal (dritter Abschnitt) und im
  Freshness-Abschnitt die auflösbare Route: *„sein Verzeichnisname unter `.harness/baseline/`
  ist dieser Tag, und `make baseline-verify` nennt ihn in seiner Ausgabe."* Beide Hälften
  gefahren: `ls .harness/baseline/` → `v6.9.0`; `make baseline-verify` in Sonde A →
  `baseline-verify: v6.9.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)`. Die
  Zusage über `make baseline-verify` deckt sich mit dem, was der Lauf tut.
- **Release-**Listen**-Quelle** — der Text nennt die *Release-Übersicht des Repos, aus dem das
  Asset im Abschnitt „Adoptierte Konventions-Quellen" darüber stammt*, und grenzt die
  Asset-URL ausdrücklich aus. Der verwiesene Abschnitt existiert in derselben emittierten
  Datei (Zeile 35) und führt die Asset-URL; die Adresse löst damit am Dokument auf, ohne eine
  zweite URL-Fassung anzulegen.
- **Kein Sensor, und warum** — der Text sagt es und begründet es mit der Host-Schranke.

**Zwei Abweichungen vom Wortlaut des Plans, beide unschädlich** — siehe `V-3` und `V-4`.

### DoD 2 — Eine lebende Zeile weist den Baum als Kurs-Inhalt aus — **erfüllt**

Der Abschnitt `### Was der mitgelieferte Baum ist — und was er nicht verspricht` steht in
beiden Sonden. Er nennt die **Eigenschaft**, nicht eine Namensliste: *„Was er an
`make`-Namen nennt, sind Beispiele des Kurses, keine Ziele dieses Repos — maßgeblich ist
allein `make help`."* Eine Aufzählung von Kurs-Ziel-Namen steht nicht darin.

**Die prüfbare Gegenrichtung selbst gemessen.** In Sonde A:

```sh
comm -23 <(grep -ohE 'make [a-z][a-z0-9-]+' <block> | sed 's/^make //' | sort -u) \
         <(make -qp | grep -oE '^[a-zA-Z][a-zA-Z0-9_.-]*:' | tr -d ':' | sort -u)
```

→ leer. Der Block nennt sieben `make`-Namen (`archive-welle`, `baseline-verify`,
`docs-check`, `gates`, `help`, `hooks-install`, `slice-mv`); jeder ist ein Ziel des Sonden-Repos.
Dieselbe Richtung hält `harness/tools/full-smoke.sh` real über `make -n -C "$repo"`.

### DoD 3 — Jeder Abschnitt des Regelwerks trägt genau einen der drei Werte — **erfüllt**

Drei getrennte Messungen an Sonde A:

1. **Deckung gegen den Nenner.** `ls .harness/baseline/*/regelwerk/*.md | wc -l` → **26**.
   Distinkte Regelblöcke der Tabelle → **26**. `diff` der zwei sortierten Mengen → leer,
   **Deckung exakt**. Die Tabelle trägt 28 Zeilen; die zwei Mehrzeilen sind
   `modul-02-harness-bootstrap.md` und `modul-15-observability.md`, je mit `§`-Abschnitt und
   verschiedenen Werten — die vom Plan vorgesehene Form.
2. **Genau ein Wert je Zeile, keine leere Zelle.** Ein `awk` über alle Tabellenzeilen
   (Trefferzahl der drei Wert-Literale je Zeile ≠ 1 · leere Begründungs-Spalte ·
   Spaltenzahl ≠ 5) meldet **nichts**. Beide `kommt nicht mit`-Zellen tragen Grund **und**
   Dauer (*„Dauerhaft, solange diese drei die einzigen Host-Abhängigkeiten sind"* bzw.
   *„Dauerhaft: ein repräsentatives Golden Set kann kein Werkzeug von außen setzen"*).
3. **Keine Zelle behauptet eine Abwesenheit, die derselbe Lauf widerlegt.** Selbst rot
   gesehen — siehe §3, Fall `365`.

**Der Wortlaut der DoD ist damit erfüllt.** Daneben steht ein Korrektheits-Befund an einer
Zelle, den dieser Wortlaut nicht erreicht: `V-1`.

### `make gates` grün — **erfüllt**

Selbst gefahren, **EXIT 0**, über dem Stand `5c45749a` vor jeder eigenen Änderung.

### Review durchgeführt, Report liegt vor — **erfüllt**

`docs/reviews/2026-09-18-slice-das-ziel-sagt-was-sein-vendored-baum-ist.md` und
`…-runde-2.md` existieren. Kein Self-Review: die Commit-Messages trennen `Rolle Reviewer`
von `Rolle Implementer`, und der Reviewer-Commit `44602d47` liegt zwischen den
Implementer-Commits. **Inhaltlich** habe ich die Reports auftragsgemäß nicht ausgewertet.

### Doku-Update, emittierter Datei-Satz unverändert — **erfüllt**

- Berührt ist die emittierte Doku-Schicht selbst; der Block geht per `InjectBaumAussage` in
  die **vorhandene** `harness/conventions.md`, vor die Überschrift `## Adaptions-Block`.
- `git diff fd494fe7..0b891130 -- internal/emit/ | grep -E '^\+.*(dst:|Path\s*=)'` → leer:
  **keine neue Ziel-Adresse**.
- Die Änderung an `internal/emit/templates_test.go` betrifft ausschließlich die Fixture
  (`courseSet()` bekommt den Anker `## Adaptions-Block`); die Schlüsselmenge der Fixture-Map
  bleibt unverändert.
- Die oberste Gliederungs-Ebene der emittierten Datei bleibt unangetastet: der Block trägt
  nur `###`. Gemessen an Sonde A — `grep '^## '` liefert dieselben sieben Überschriften, die
  die Vorlage führt.

### Closure-Zeilen — **nicht geprüft** (auftragsgemäß; sie gehören dem Planner, `AGENTS.md` §3.10)

---

## 3. Rot-Belege nach `AGENTS.md` §3.6 — selbst gefahren und gelesen

**Fall `365-inventur-abwesenheit-vom-emit-widerlegt.sh`** (`# verify: test-go`). Der Operand
legt einen zweiten Träger unter `tools/harness/` ab, während die Freshness-Zelle dort weiter
Abwesenheit behauptet. `make test-go` → EXIT 2, gelesene Meldung:

```
--- FAIL: TestTraegerInventur_KeineZelleBehauptetEineAbwesenheitDieDerEmitWiderlegt (0.00s)
    baumaussage_test.go:95: modul-02-harness-bootstrap.md: der Bestand unter "tools/harness/"
    hat sich bewegt — die Zelle behauptet weiter Abwesenheit.
        ist:  [… tools/harness/baseline-freshness.sh …]
        soll: [… ohne baseline-freshness.sh …]
```

Die Meldung nennt **den behaupteten Grund**: die Zelle, das Präfix und die Datei, die der
Lauf dazulegt. Genau die Richtung, die DoD 3 zusagt. ✔

**Fall `366-inventur-regelblock-ohne-eintrag.sh`** (`# verify: test-bats`). Der Operand
streicht den Inventur-Eintrag eines Regelblocks. `make test-bats` → EXIT 2, gelesene Meldung:

```
not ok 35 jeder Regelblock des gepinnten Baums traegt einen Inventur-Eintrag
# Regelbloecke ohne Inventur-Eintrag: [modul-16-produktiver-betrieb.md]
```

Die Meldung nennt den fehlenden Block beim Namen — die Abdeckungs-Richtung gegen den Nenner. ✔

**Die drei übrigen habe ich nicht gefahren** (`364`, `367`, `368`); `367` kostet je Lauf einen
vollen E2E. Was ich statt eines eigenen Rot für `367` habe, steht bei Risiko 3 in §6 — und es
ist ausdrücklich **kein** Rot-Beleg aus eigener Hand.

---

## 4. Befunde

| ID | Schwere | Befund |
|---|---|---|
| `V-1` | **MEDIUM** | Eine Inventur-Zelle nennt eine Adresse, die im Ziel nicht existiert |
| `V-2` | LOW | Plan §3 deckt den berührten Datei-Satz in **beide** Richtungen nicht |
| `V-3` | INFO | DoD 1 verlangt den Grund *„weil er `curl` bräuchte"*; der Text sagt es allgemeiner |
| `V-4` | INFO | Der gepinnte Tag steht literal im dritten, nicht im Freshness-Abschnitt |

### `V-1` (MEDIUM) — `docs/plan/planning/roadmap.md` gibt es im Ziel nicht

Die Zeile `modul-06-roadmap.md` trägt den Wert *Träger kommt mit* mit der Begründung:
*„`docs/plan/planning/roadmap.md` und die Register-Ablage `docs/plan/planning/observations/`
liegen; …"*.

Gemessen an **beiden** Sonden: die Roadmap liegt unter
`docs/plan/planning/in-progress/roadmap.md`. Unter dem genannten Pfad liegt nichts. Ich habe
jeden in der Tabelle genannten Pfad gegen den Ist-Bestand von Sonde A gehalten — **27 von 28
Adressen lösen auf, diese eine nicht** (der 28. Treffer meiner Extraktion, `templates/`,
ist ein Artefakt des `grep`: gemeint ist der vendored `templates/`-Baum, und der liegt
samt ADR- und Carveout-Vorlage).

**Der Wert bleibt richtig, die Adresse nicht.** Eine Roadmap kommt mit; der Satz sagt nur, wo,
und sagt es falsch. Die eigene Quelle des Slice bestätigt die richtige Adresse: der
Kommentar in `internal/emit/templates.go` bei `structureGitkeeps` schreibt
*„in-progress/ traegt bereits die Roadmap"*.

**Warum kein Sensor das fängt — und das ist der eigentliche Punkt für den Planner.** Die
hermetische Hälfte prüft die **Abwesenheits**-Richtung (eine Zelle darf nicht die Abwesenheit
eines Trägers behaupten, den der Emit ablegt) und die **Nenner**-Deckung. Die positive
Richtung — *der genannte Träger liegt wirklich dort* — prüft keiner der beiden und auch
`full-smoke` nicht. Die Zusage der Zelle ist damit breiter als ihr Sensor. Das ist kein
DoD-Verstoß (DoD 3 verlangt diese Richtung nicht), aber genau die Lage, gegen die
`AGENTS.md` §3.6 schreibt.

**Empfehlung an den Planner:** die Adresse korrigieren (ein Einzeiler in
`internal/emit/baumaussage.go`); ob die positive Richtung einen Sensor bekommt, ist eine
eigene Entscheidung — sie wäre mechanisch (Pfad-Existenz gegen `emittierteKernpfade()`
und den Struktur-Satz), und §1 schließt sie nicht aus. Der dortige Ausschluss
*„kein Sensor, der Träger und Regel automatisch aufeinander abbildet"* betrifft die
**Zuordnung** (Urteil), nicht die **Existenz** einer genannten Adresse.

### `V-2` (LOW) — Plan §3 und der Diff decken sich in beide Richtungen nicht

- **Gebaut, nicht geplant:** `test/baum-inventur.bats` (neu) und `docs/user/e2e-abdeckung.md`
  (Regeneration). Der Implementer meldet diese Hälfte selbst.
- **Geplant, nicht gebaut:** die Zeile `internal/emit/templates/` *(betroffene Vorlage)* mit
  Änderungs-Art `update`. `git diff --name-only fd494fe7..0b891130` berührt unter diesem
  Pfad **keine** Datei. Diese Hälfte meldet der Implementer nicht.

Beides ist Plan-Pflege, kein Umsetzungsfehler: Der gewählte Weg (Injektion emit-seitig statt
Änderung der vendored Vorlage) ist der **richtige** — §1 schließt das Anfassen des vendored
Baums ausdrücklich aus, und `MR-007` bindet ihn byte-verifiziert. Der Plan hätte die Zeile
nicht führen dürfen. Träger der Korrektur ist der Planner (`AGENTS.md` §3.10: die ausführende
Rolle schreibt ihr eigenes Abnahmekriterium nicht um).

### `V-3` (INFO) — `curl` steht nicht im emittierten Text

DoD 1 verlangt *„die Aussage, dass kein Sensor mitkommt, weil er `curl` bräuchte"*. Der Text
sagt: *„Er bräuchte einen Netz-Abruf der Release-Liste und damit eine Host-Abhängigkeit über
`bash`, `git` und `docker` hinaus."* Sachgleich, und im Ziel **genauer**: `curl` ist der
Träger, den *dieses* Repo fährt; das Ziel fährt ihn nie, und ihn dort zu nennen hieße, ein
Werkzeug zu benennen, das mit dem Ziel nichts zu tun hat. Kein Mangel.

### `V-4` (INFO) — Ort des literalen Tags

Der Freshness-Abschnitt nennt den Tag als Route (`.harness/baseline/<tag>` und die Ausgabe
von `make baseline-verify`), literal steht er im Inventur-Abschnitt und in §Adoptierte
Konventions-Quellen. Beide Routen habe ich gefahren, beide führen auf `v6.9.0`. Die Wahl ist
die konsequente Anwendung von `MR-025` Setzung 2 — eine Zahl steht neben dem Kommando, das
sie liefert — und damit besser als eine zweite eingefrorene Fassung.

---

## 5. Plan gegen Code — Abgrenzung §1

Jeder der fünf Ausschlüsse aus §1 einzeln gegen den Diff gehalten:

| Ausschluss aus §1 | Gehalten? | Beleg dieses Laufs |
|---|---|---|
| Kein Freshness-Sensor im Ziel | **ja** | `ls tools/harness/` in Sonde A führt sieben Skripte, keines fragt Netz; `.githooks`/`harness/mk/` ebenso ohne |
| Der vendored Baum wird nicht angefasst | **ja** | `make baseline-verify` grün in beiden Sonden; kein Diff-Pfad unter `.harness/baseline/` |
| Der emittierte Datei-Satz wächst nicht | **ja** | keine neue Ziel-Adresse im Diff; Injektion in ein vorhandenes Dokument |
| Kein Träger↔Regel-Abbildungs-Sensor | **ja** | die Zuordnung steht als Literal in `traegerInventur()`; mechanisch geprüft wird nur der Nenner |
| Keine Aktivierung von `doc-targets` im Ziel | **ja** | `modules:` der emittierten `.d-check.yml` → `[links, anchors, ids, matrix, spans]`; kein `targets:`-Block |

**Keine Änderung verletzt die Abgrenzung.** Der Slice ist nicht über seinen Plan hinaus
gewachsen; er ist an einer Stelle **hinter** ihm geblieben (`V-2`, zweite Hälfte).

---

## 6. Belege für die vier Risiko-Ausgänge (§6) — für den Planner

Der Ausgang ist der Vorschlag dieses Laufs; setzen tut ihn der Planner.

**Risiko 1 — „DoD 3 sprengt die Review-Sitzung" → `entfallen`.**
Beleg: Der Slice ist in einer Sitzung prüfbar geblieben — die Rückführung aus §4
(`in-progress → next`) wurde nicht gezogen, und beide Review-Runden liegen als je *ein*
Report vor. Umfang der Inventur: 28 Tabellenzeilen über 26 Regelblöcken, eine Datei
(`internal/emit/baumaussage.go`, 288 Zeilen). Drei Liefer-Punkte, keiner nachgeschoben.

**Risiko 2 — „Eine Zelle verlangt einen Wert, den keine ADR setzt" → `entfallen`.**
Beleg: Meine Messung aus §2 zeigt **keine** Zelle ohne Wert. Die zwei Zellen, die eine ADR
brauchen, sind gedeckt:
- `modul-15-observability.md` §Doku-Konsistenz-Drift → *liegt bei, nicht verdrahtet*.
  `ADR-0020` Festlegung 4 setzt: *„Träger ist das bereits mitgelieferte `doc-targets`; neu ist
  nur seine Konfiguration."* Gemessen an Sonde A: `make doc-targets` existiert als Ziel,
  `modules:` führt `targets` nicht, ein `targets:`-Block steht nicht in der emittierten
  `.d-check.yml`. Der Zellwert bildet exakt diesen Ist-Zustand ab.
- `modul-15-observability.md` §Erfassung und Token-Attribution → *Träger kommt mit*, mit der
  Bedingung ausgeschrieben. `ADR-0022` Festlegung 7 setzt den stehenden Ort der Feldliste;
  `harness/mk/erfassung.mk`, `.claude/hooks/span-emit.sh` und
  `harness/erfassung-feldliste.md` liegen in Sonde A alle vor.

**Risiko 3 — „Der Marker hängt nur an einer Bootstrap-Variante" → `entfallen`, mit einer
Einschränkung, die in den Ausgang gehört.**
Beleg, zwei Teile:
1. *Beide Varianten werden wirklich geprüft* — selbst gemessen. Mein `make full-smoke`-Lauf
   gibt die Stufe **zweimal** aus, mit verschiedenen Etiketten und je eigenem Nenner:
   `Baum-Aussagen im Ziel (--lang go): … die Inventur deckt 26 Regelbloecke des ZIEL-Baums …`
   und `Baum-Aussagen im Ziel (sprachlos): … 26 Regelbloecke …`. Die Funktion
   `baum_aussagen_im_ziel` ist an jeder ihrer fünf Bedingungen fail-closed (fehlende Datei ·
   fehlende Marke · leerer Nenner · ungedeckter Block · nicht geführtes `make`-Ziel), jeweils
   mit `exit 1` und eigener Meldung.
2. *Der zweite Aufruf hat Zähne* — **nicht** von mir rot gefahren. `test/mutations/367`
   deckt genau das; sein `sed`-Anker trifft `harness/tools/full-smoke.sh:1784`
   (`baum_aussagen_im_ziel "$tmprepo_doc" "sprachlos"`) wortgleich, und der mutierte Operand
   zeigt auf ein Verzeichnis ohne `harness/conventions.md`, womit die erste Bedingung der
   Funktion greift. Das ist eine **Struktur**-Aussage, kein gelesenes Rot; der Fall kostet je
   Lauf einen vollen E2E, und der Auftrag verlangte zwei Fälle, nicht fünf.

**Risiko 4 — „Der Datei-Satz wächst doch" → `entfallen`.**
Beleg: `git diff fd494fe7..0b891130 -- internal/emit/ | grep -E '^\+.*(dst:|Path\s*=)'` ist
leer; `InjectBaumAussage` schreibt in die Zeichenkette einer Datei, die das Ziel ohnehin
bekommt. In beiden Sonden gemessen: der Block steht in `harness/conventions.md`, und kein
Pfad daneben ist neu. `LH-FA-06` bleibt damit unberührt — es ist keine Vertragsfrage
geworden.

---

## 7. ADR- und MR-Konformität

| Quelle | Verdikt | Beleg |
|---|---|---|
| `ADR-0020` Festlegung 4 | konform | siehe Risiko 2; die Zelle sagt den Ist-Zustand, nicht den Stand der Entscheidung |
| `ADR-0022` Festlegung 7 | konform | die Erfassungs-Zelle trennt das Unbedingte vom Bedingungs-Zweig und nennt die vier Artefakte |
| `MR-025` Setzung 2 | konform | der Block trägt **keine** eingefrorene Zahl; der Nenner steht als Kommando (`ls .harness/baseline/*/regelwerk/*.md`), die Stufen-Meldung von `full-smoke` erzeugt ihre `26` zur Laufzeit |
| `MR-033` | konform | *„Gemessen gegen den Kurs-Stand `v6.9.0`"*; fail-closed an den gefetchten Tag gekoppelt (`TestInventurMessTag_IstDerGefetchteStand`, Mutation `368`) |
| `MR-053` | konform | die `modul-14`-Zelle **zeigt** auf `d-check.mk` für Tag und Digest, statt eine zweite Fassung zu führen |
| `MR-054` | nicht berührt | kein Modul geht neu ins emittierte Doc-Gate; `modules:` unverändert |
| `AGENTS.md` §3.2 | konform | `git diff … | grep -E '^\+.*(//nolint|shellcheck disable)'` → kein Treffer im Code (der einzige Treffer ist Prosa im Review-Report) |
| `AGENTS.md` §3.5 | nicht berührt | keine Gate-Config im Diff (`.d-check.yml`, `.golangci*`, `Makefile`, `harness/mk/` unberührt) |
| `AGENTS.md` §3.6 | konform, mit `V-1` als Rest | jeder der drei Liefer-Punkte hat sein Rot-Kommando; zwei davon habe ich selbst rot gesehen. Die eine Zusage, die breiter ist als ihr Sensor, steht als `V-1` |

---

## 8. Gesamtverdikt

**Die DoD ist erfüllt.** Drei Liefer-Punkte, `make gates`, `make full-smoke`, Review-Report
und das Doku-Update tragen; der emittierte Datei-Satz ist unverändert. Alle vier Risiken aus
§6 haben einen belegten Ausgang, jeder *entfallen*.

**Ein MEDIUM bleibt offen** (`V-1`): eine Inventur-Zelle nennt eine Adresse, die im Ziel
nicht existiert — sichtbar nur, weil ich die Adressen einzeln gegen eine emittierte Sonde
gehalten habe, und von keinem Sensor gedeckt. Er hindert die Closure nicht (die DoD verlangt
diese Richtung nicht), gehört aber vor den `git mv` nach `done/` entschieden: entweder als
Korrektur in diesem Slice oder als Folge-Slice mit Kennung.

**`V-2` ist Planner-Arbeit** und keine Bedingung der Abnahme.
