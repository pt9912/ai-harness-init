# Delta-Review slice-144 — Nacharbeit `fc1fc54` plus Nachtrag zu `f9697d7`

**Gegenstand:** Commit `fc1fc54` (`.claude/commands/implement-slice.md`,
`harness/tools/slice-mv.sh`, `test/slice-mv.bats`) und ein Nachtrag zu `f9697d7`.
**Plan:** [`slice-144`](../plan/planning/in-progress/slice-144-lifecycle-move-zieht-seine-verweise-nach.md).
**Erstreview:** [`2026-08-31-slice-144-review.md`](2026-08-31-slice-144-review.md).
**Maßstab:** Modul 10 — gegen Plan, ADRs und Hard Rules; die DoD prüft der Verifier.

**Zur Ablage:** Der Delta-Lauf hat diese Datei nicht selbst angelegt und seine
Befunde als Text zurückgegeben; der koordinierende Lauf hat sie hier übernommen.
Der Nachtrag am Ende von HIGH-1 stammt aus dem koordinierenden Lauf und ist als
solcher markiert.

## Findings

### HIGH-1 — `make slice-mv` bündelt Move und Inhaltsänderung in einem Commit, ohne Deckung im Adaptions-Block

**Quelle:** [`AGENTS.md`](../../AGENTS.md) §3.3, §3.5, §3.8 · Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine · `modul-09-implementierung.md`
§Hard Rules (repo-spezifisch).

**Pfad:** `harness/tools/slice-mv.sh` (Kopf-Abgrenzung; `main()`),
`.claude/commands/implement-slice.md` (Schritt 9, Schritt 23).

**Befund.** Die Baseline verlangt für den Übergang einen reinen `git mv`;
Inhaltsänderungen stehen in einem eigenen Commit, begründet mit der
50-%-Similarity-Schwelle der Rename-Detection. `make slice-mv` führt Move und
Verweis-Nachzug zusammen und empfiehlt in seiner Ausgabe **einen** Commit; seit
`fc1fc54` steht das als Anweisung für jeden künftigen Implementer-Lauf.

Drei Messungen:

```sh
grep -rniE 'slice-mv|move-werkzeug|make .*mv' .harness/baseline/v5.12.0/ | grep -v SHA256SUMS
grep -niE 'slice-mv|Link-Abgleich|Verweise nachziehen' harness/conventions.md
git log --format=%h --grep='Link-Abgleich nach dem Move' | wc -l
```

Die ersten zwei sind leer: die Baseline kennt kein solches Werkzeug, und der
Adaptions-Block trägt keinen Eintrag dazu. Das dritte zählt die Commits, in denen
dieses Repo die Trennung bisher selbst gefahren hat.

Empirisch: ein 507-zeiliger Slice ergibt nach Move plus Ersetzung **99 %**
Similarity; bei einer sehr kurzen Datei meldet `git` `delete mode` und
`create mode` statt `rename` — die Rename-Erkennung verschwindet, nicht sie
degradiert. Das ist das von der Baseline-Begründung vorhergesagte Versagen.

**Nachtrag des koordinierenden Laufs.** Die Rechtfertigung in der Skript-Ausgabe
lautet *„die Verweise liegen in ANDEREN Dateien"*. Vier Zeilen darüber ersetzt
dasselbe Skript die ausgehenden Ziele **in der bewegten Datei selbst**
(`rewrite_outgoing_bare_in_file "$PLANNING/$TO/$base"`), wie DoD (2) es verlangt.
Der Satz ist über das Verhalten des Skripts falsch, und damit greift §3.3
wörtlich statt nach Auslegung: Move und Inhaltsänderung derselben Datei.

**Träger.** Eine Norm-Lockerung verlangt ADR und Registereintrag
([`AGENTS.md`](../../AGENTS.md) §3.5, §3.8) — beide fehlen. Alternativ trennt das
Werkzeug Move und Inhalt wieder.

### MEDIUM-1 — HIGH-1 des Erstreviews ruht auf einer `Proposed`-ADR

**Quelle:** [`AGENTS.md`](../../AGENTS.md) §3.4 · Baseline `grundlagen-bootstrap.md`
§Vier Trigger-Klassen · `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz.

**Befund.** [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
steht auf `Proposed` und hält sich bei einer Folgepflicht ausdrücklich zurück — der
Zeiger aus §3.8 wartet auf Annahme. Bei der zweiten tut sie das nicht: der durch sie
gedeckte Inhalt in `.claude/commands/implement-slice.md` ist bereits geschrieben.
Fällt die Review-Runde anders aus, ist genau das die Selbstentscheidung, die HIGH-1
des Erstreviews beanstandete.

Modul 8 verlangt für Verdikt 3 zwei Artefakte — Folge-ADR **und** Erinnerungs-Slice
in `next/`. Der zweite fehlt (`ls docs/plan/planning/next/`).

**Nicht berührt:** Festlegung 2 der ADR. Der geschriebene Text operationalisiert
bestehende Regeln und setzt keine neue Norm.

### MEDIUM-2 — Die falsifizierte Zusage steht weiter im Original

**Quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6, §3.7.

**Pfad:** `harness/tools/slice-mv.sh`, Laufzeitausgabe von `main()`.

**Befund.** Die Ausgabe sagt *„der Rename bleibt bei 100 %"*. Gemessen sind 99 %
bei einer realistischen Datei und keine Rename-Erkennung bei einer kurzen. Der
Implementer hat die Falsifikation im selben Lauf gemessen und die **Ableitung** in
`.claude/commands/implement-slice.md` auf *„Similarity-nah"* korrigiert — die
**Quelle** blieb stehen. Kein Test ruft `main()` auf, und `comment-claims` prüft die
Existenz eines genannten Sensors, nicht den Wahrheitsgehalt einer Aussage: kein Gate
fängt sie.

## Negativbefunde

- **LOW-1 des Erstreviews (Testname „14"):** geschlossen. Die technische Begründung
  der Namens-Einschränkung trägt — das gepinnte bats-Image führt kein `git`, und
  BusyBox-`grep` kennt `--exclude-dir` nicht. Name und Messung stimmen überein.
- **MEDIUM-1 des Erstreviews (DoD-(2)-Reparatur, `7a9943c`):** kein Befund. Indikativ
  über den geltenden Zustand, kein neuer Liefer-Punkt, §6 Risiko 1 als *weiter offen
  → `BEO-003`* statt *vollständig abgedeckt*. Die Ehrlichkeit der Implementierung
  (Grenze 3 im Skriptkopf) bestand vorher; die Doku holt sie nach.
- **[`AGENTS.md`](../../AGENTS.md) §3.9 (Docker-only):** kein Befund im Delta.

## Kategorie-Summary

HIGH 1 · MEDIUM 2 · LOW 0.

**Wiederkehrende Finding-Klassen für das Beobachtungs-Register:** (1) eine rot
gesehene Zusage wird an der Ableitung korrigiert und an der Quelle stehen gelassen;
(2) eine Rollen- oder Norm-Entscheidung wird operativ vollzogen, bevor ihr
Trägerartefakt bindend ist.

## Verdikt

Der Weg zum Verifier ist nicht frei. HIGH-1 blockiert: der Commit-Zuschnitt weicht
von einer Hard Rule und ihrer Baseline-Begründung ab, ist seit `fc1fc54` normativ
festgeschrieben und hat keinen Träger. Vor der Weitergabe braucht er eine ADR mit
Registereintrag — oder das Werkzeug trennt Move und Inhalt wieder.
