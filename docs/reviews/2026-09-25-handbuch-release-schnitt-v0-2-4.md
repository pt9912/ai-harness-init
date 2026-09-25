# Review-Report: Handbuch-Änderungen des Release-Schnitts v0.2.4 — 2026-09-25

**Review-Art:** Doku-Diff gegen den Ist-Zustand des Produkts (Modul 10). Nicht gegen die DoD (das ist der Verifier).

**Gegenstand:** `git diff 2665ee27..HEAD -- docs/user/benutzerhandbuch.md` — die zwei Handbuch-Commits `03c187af` und `e9e07c56`
(HEAD `e9e07c56`, Baum sauber). Der Range trägt daneben `traeger.mk`, `test/traeger-fetch.bats` und einen Slice-Plan; sie sind
**nicht** Gegenstand (`git diff --numstat 2665ee27..HEAD -- docs/user/benutzerhandbuch.md` → 37 hinzu, 11 entfernt).

**Prüfmaßstab:** `AGENTS.md` §3.6, §3.7, §3.9; Setzung des Auftraggebers (Handbuch trägt nur den Ist-Zustand: keine Chronik, keine Prognose,
nichts Unimplementiertes); `MR-025`; `ADR-0065`; `ADR-0067`; Modul 8 und 10.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-25

**Eingangs-Kontext:** Diff · `ADR-0067` (Festlegungen 1 bis 5, §Konsequenzen) · `internal/emit/enforce.go`, `zeilenenden.go`, `agents.go`,
`commands.go`, `commitmsg.go`, `emit.go`, `templates.go`, `templates/d-check.yml` · `docs/user/releasing.md` §Schnitt · Handbuch, `README.md`,
`docs/user/*.md`. Die Commit-Messages und der Implementer-Bericht waren Behauptung; die Aussagen sind gegen Code und gegen einen gefahrenen
Träger geprüft.

**Eigene Sensor-Läufe dieses Laufs** (nur `make`/Docker/git; kein Host-Toolchain-Aufruf; alle Ziele im Scratchpad, kein Eingriff in den Baum):

- **`make host-bin`** → Träger gebaut. **Bootstrap** `--lang go` (flat), `--lang go --arch hexslice`, `--lang cpp --arch hexslice` in tmp-Zielen, jeweils EXIT 0.
- **Klassen-Sonde (Re-Lauf):** an **jede** Datei des Ziels (ohne `.harness/baseline/`, `.harness/state/`, `.gitkeep`) die Zeile `# PROBE` angehängt,
  denselben Aufruf wiederholt (EXIT 0), dann gelesen, welche Datei die Zeile noch trägt. **Unberührt** (trägt `# PROBE`): `AGENTS.md`, `README.md`,
  `.claude/agents/*` (6), `.claude/commands/*` (3), `.d-check.yml`, `.golangci.yml`, `Dockerfile`, `go.mod`, `cmd/app/main.go`, `.githooks/commit-msg`,
  `.githooks/.gitattributes`, `harness/mk/.gitattributes`, `.claude/hooks/.gitattributes`, `harness/conventions.md`, `harness/README.md`, `spec/*` (3),
  `docs/plan/planning/README.md`, `roadmap.md`, `observations/README.md`. **Neu geschrieben** (`# PROBE` weg): `Makefile`, `d-check.mk`, alle zwölf
  `harness/mk/*.mk`, alle `tools/harness/*` samt `blocked/go` und den zwei `.gitattributes`, `.claude/settings.json`, die drei Hook-Skripte unter
  `.claude/hooks/`, `.harness/skills/*`, `.harness/.gitignore`, `.harness/.gitattributes`, `harness/erfassung-feldliste.md`, der Baum unter
  `.harness/baseline/` (0 von 55 Dateien trugen die Zeile danach). Das entspricht der Zwei-Klassen-Tabelle des Handbuchs.
- **Meldungs-Sonde:** der Re-Lauf schrieb genau **vier** Meldungen (`.githooks/commit-msg`, `harness/mk/.gitattributes`, `.claude/hooks/.gitattributes`,
  `.githooks/.gitattributes`); für die übrigen Dateien der zweiten Klasse (auch `.d-check.yml`) keine. Das deckt Handbuch Zeile 359 und 504.
- **Zahl-Sonde:** `find . -name .gitattributes -not -path './.harness/baseline/*' | wc -l` → **5** in allen drei Zielen (go flat, go hexslice, cpp hexslice).
- **Zeilenenden-Sonde:** Klon des committeten Ziels mit `git clone -c core.autocrlf=true`: `grep -lc $'\r'` über `tools/harness/*.sh`, `.claude/hooks/*.sh`,
  `.githooks/commit-msg`, `harness/mk/*.mk` → **0** Dateien; `README.md` → 44 CR-Zeilen, `Makefile` der Wurzel → 23, `d-check.mk` → 68. Mit einer
  committeten Wurzel-`.gitattributes` `* text=auto eol=crlf` unverändert 0 in den Verzeichnissen. Das deckt Zeile 489 für die Verzeichnisse.
- **Kennungs-Form-Sonde:** frisches Ziel (`--arch hexslice`) → `make docs-check` → `d-check: 20 Datei(en) geprüft, 0 Befund(e)`. Rot: eine blanke
  `ADR-IDX-0004` in `README.md` → `id-unlinked`; ein Link aus `spec/architecture.md` auf `docs/plan/planning/welle-x.md` → `matrix-forbidden`
  (`Referenz spec-straten → welle ist nicht erlaubt`). Beide Gegenbeispiele nach der Sonde zurückgenommen.
- Kein `make mutate`, keine Fremd-Repos, kein Host-Go.

---

## Findings

Kein HIGH; ein MEDIUM.

### MEDIUM

**M-1**
- `kategorie`: MEDIUM
- `quelle`: `LH-FA-06`, `ADR-0007` Festlegung 3 (Klassen je Pfad), Kopplung derselben Aussage über mehrere Fundorte
- `pfad`: `README.md:55-57`; `cmd/ai-harness-init/main.go:53-55` (der Hilfetext des Programms, `--help`)
- `befund`: Beide führen die Fassung, die das Handbuch mit diesem Diff ersetzt: „das Werkzeug frischt seine eigenen Dateien auf den Stand auf, den es selbst
  mitbringt“ (README) bzw. „tool-eigene Infrastruktur wird kanonisch neu geschrieben (heilt Drift), adopter-gefuellte Dateien … bleiben unberuehrt“
  (`--help`). Die Klassen-Sonde zeigt: `.d-check.yml`, `.githooks/commit-msg`, die Rollen-Anweisungen, `.golangci.yml` und `Dockerfile` sind
  mitgelieferte, „eigene“ Dateien, die der Re-Lauf **nicht** schreibt. Das Handbuch sagt es jetzt richtig (Zeilen 203, 352-361, 573, 582, 594); die Startseite
  und die Hilfe des Programms sagen es weiter falsch.
- `failure-szenario`: Ein Adopter liest im README, der Re-Lauf „frische das Werkzeug auf“, ändert nichts an seiner verbogenen `.d-check.yml` und erwartet Heilung;
  sie bleibt ohne Meldung liegen (Sonde: keine Zeile für `.d-check.yml`). Ein Fundort ist keine Fundmenge: das Handbuch trägt die neue Fassung an sechs Stellen,
  zwei weitere Fundorte der alten Fassung stehen im Baum.
- `verifizierbar`: nein — kein Gate hält diese Prosa gegen die Klassen-Deklaration. Die Sonde oben ist die Gegenprobe.
- `klasse`: „Dieselbe Zusage an mehreren Fundorten, einer nachgezogen“

### LOW

**L-1**
- `kategorie`: LOW · `quelle`: Maintainability (Struktur des Handbuchs)
- `pfad`: `docs/user/benutzerhandbuch.md:506` (Absatz), Überschrift `docs/user/benutzerhandbuch.md:487`
- `befund`: Der neue `###`-Abschnitt „Zeilenenden und Kennungs-Form der Prüf-Konfiguration“ ist **vor** den Absatz „Die Dateien mit der Endung `.template.md` unter
  `.harness/baseline/` sind Vorlagen …“ gesetzt; der Absatz stand vorher am Ende von Phase 2 und liest sich jetzt als Teil des neuen Abschnitts (Diff: der
  Absatz ist unverändert, seine Überschrift hat gewechselt).
- `failure-szenario`: Ein Adopter, der unter „Phase 2“ nach den Vorlagen sucht, findet sie nicht; ein Adopter, der den neuen Abschnitt liest, trifft auf einen
  Absatz ohne Bezug zu Zeilenenden oder Kennungs-Form.
- `verifizierbar`: nein · `klasse`: „Einschub trennt einen Absatz von seiner Überschrift“

**L-2**
- `kategorie`: LOW · `quelle`: `ADR-0067` Festlegung 4; `AGENTS.md` §3.6 (die Zusage trägt, was der Code hält)
- `pfad`: `docs/user/benutzerhandbuch.md:500`
- `befund`: Die Zelle führt die Meldung in Anführungszeichen als Wortlaut: „Trägt sie die Zeile … tragen die Dateien in `<verzeichnis>/` …“. Die Meldung des
  Programms lautet (Sonde, `harness/mk/`): „ai-harness-init: harness/mk/.gitattributes liegt bereits — die Datei bleibt unberuehrt (skip-if-present). **Traegt** sie
  die Zeile `* text=auto eol=lf` nicht, **tragen** die Dateien in harness/mk/ im Klon mit core.autocrlf=true CRLF.“ (`zeilenenden.go`, `zeilenendenMeldung`). Umlaut-Form
  und Präfix weichen ab; der Anfangsteil („liegt bereits …“) fehlt.
- `failure-szenario`: Ein Adopter sucht die zitierte Zeile in der Ausgabe oder im Log und findet sie nicht (Byte-Suche nach „Trägt“).
- `verifizierbar`: ja, durch Zeichenkettenvergleich der Handbuch-Zeichenkette mit der Ausgabe (kein Gate fährt ihn) · `klasse`: „Zitierter Wortlaut weicht vom Programm-Wortlaut ab“

**L-3**
- `kategorie`: LOW · `quelle`: `ADR-0067` Festlegung 5 und §Konsequenzen (Negativ); `AGENTS.md` §3.6
- `pfad`: `docs/user/benutzerhandbuch.md:489`
- `befund`: „Die Wurzel bekommt keine `.gitattributes`: Ihre Dateien dort schreibt git nach Ihrer eigenen Einstellung.“ Die Wurzel trägt auch **Werkzeug-Dateien**: `Makefile`
  und `d-check.mk` (Sonde im autocrlf-Klon: 23 bzw. 68 CR-Zeilen); die ADR benennt sie als „Wurzel-Dateien … ohne Attribut“ und die Wirkung eines Windows-`make` als
  ungemessen. Das Handbuch nennt weder das noch die Vorbedingung der Zusage „kein CR“ (die Datei liegt mit LF im Index).
- `failure-szenario`: Ein Windows-Adopter liest „Ihre Dateien dort“ und hält die Wurzel-Makefile für seine; die Zusage „kein CR in diesen Verzeichnissen“ ist auf die fünf
  Verzeichnisse begrenzt, aber die Begrenzung führt den Fall `Makefile` nicht.
- `verifizierbar`: nein (Messung an einem Klon, siehe oben) · `klasse`: „Zusage benennt ihre Grenze unvollständig“

**L-4**
- `kategorie`: LOW · `quelle`: `MR-025` (Zahl neben dem Kommando, das sie liefert), Modul 13 §Hard Rule (ein Kommando ist so genau wie sein Ausschnitt)
- `pfad`: `docs/user/benutzerhandbuch.md:489` und `:492`
- `befund`: „Die fünf Dateien **listet** … `find … | wc -l  # 5`“ — das Kommando zählt, es listet nicht. Es zählt außerdem **jede** `.gitattributes` außerhalb von
  `.harness/baseline/`; in einem Ziel mit einer eigenen Wurzel-`.gitattributes` (die der Text selbst als möglich nennt) gibt es **6** aus (Sonde, Wurzel-Datei committet).
- `failure-szenario`: Ein Adopter mit Wurzel-`.gitattributes` fährt das Kommando, sieht 6 und hält das Ziel für falsch aufgesetzt.
- `verifizierbar`: ja (Sonde oben) · `klasse`: „Kommando misst einen weiteren Ausschnitt als die Prosa“

**L-5**
- `kategorie`: LOW · `quelle`: Maintainability (Vollständigkeit einer Klassen-Tabelle)
- `pfad`: `docs/user/benutzerhandbuch.md:356-357`
- `befund`: Die Tabelle ordnet Dateien zwei Klassen zu und trägt den Anspruch, die Aufteilung zu sein. Nach der Sonde bleibt ungenannt: konvergent `.harness/.gitignore`
  und `harness/erfassung-feldliste.md`; unberührt `harness/README.md`, `docs/plan/planning/README.md`, `roadmap.md`, `observations/README.md`. Die Zeile „Ihre gefüllten
  Dateien — die Dokumente unter `spec/`, `README.md`, `AGENTS.md`, `harness/conventions.md`“ nennt vier von acht solcher Dateien.
- `failure-szenario`: Ein Adopter, der `harness/README.md` angepasst hat, findet sie in keiner Klasse und kann nicht entscheiden, ob der Re-Lauf sie überschreibt (sie bleibt
  unberührt, Sonde).
- `verifizierbar`: ja (Sonde) · `klasse`: „Klassen-Tabelle nennt die Menge nicht vollständig“

**L-6**
- `kategorie`: LOW · `quelle`: Handbuch-Zweck („nicht, wie das Werkzeug intern funktioniert“, Zeile 8); Prüffrage 5 des Auftrags
- `pfad`: `docs/user/benutzerhandbuch.md:489`, `:502`, `:504`
- `befund`: Der Abschnitt setzt Vokabular voraus, das das Handbuch nirgends erklärt: „Interpreter“, „Byte-Prüfung des Regelwerks“ (gemeint: `make baseline-verify`), „Klassen `slice`
  und `welle`“, „Präfix-Token“, „Regel `spec-straten → welle`“, „Adaptions-Block“, `id-unlinked`, `matrix-forbidden`, „Bereichs-Segment“. Die Nachtragsliste (Zeile 504)
  nennt vier Positionen der `.d-check.yml`, aber nicht, in welchem Block (`matrix.classes`, `matrix.rules`) die zwei ersten stehen.
- `failure-szenario`: Ein Adopter mit einer älteren `.d-check.yml` soll „von Hand nachtragen“ und kann die Positionen nicht lokalisieren, ohne das Repo des Werkzeugs zu lesen.
- `verifizierbar`: nein · `klasse`: „Repo-Vokabular im Adopter-Text ohne Erklärung“

### INFO

**I-1** — `quelle`: Setzung „nichts Unimplementiertes“; `docs/user/releasing.md` Schritt 5
- `pfad`: `docs/user/benutzerhandbuch.md:3`, `:73`, `:318`
- `befund`: „aktuell ausgeliefert wird `v0.2.4`“, „das veröffentlichte `v0.2.4`“, „wer das `v0.2.4` heruntergeladen hat“. Zum Stand von HEAD ist der Tag nicht gesetzt
  (`git tag -l 'v0.2.*'` → `v0.2.0` bis `v0.2.3`), der Hauptzweig steht 4 Commits vor `origin/main`. Die Aussagen werden mit Tag-Push und Publikation wahr; der Handbuch-Text
  gehört nach dem Handbuch-Standard des Repos in den Baum, den der Tag trägt. Bis dahin sind sie Prognose. Kein Fund gegen den Diff, aber die Reihenfolge Push → Tag → Release
  ist die Bedingung; für den Verifier/den Schnitt.
- `verifizierbar`: ja (`gh release view v0.2.4` nach der Publikation) · `klasse`: „Versions-Aussage vor der Publikation“

**I-2** — `quelle`: `AGENTS.md` §3.7 (Kommentar beschreibt, was da ist); außerhalb des Diffs
- `pfad`: `internal/emit/enforce.go:249` (Kommentar von `EnforcePaths`)
- `befund`: Der Kommentar nennt `blocked/<lang>` „skip-if-present“; der Kommentar an der Schreibstelle (`enforce.go:444`) und die Sonde (`blocked/go` wird vom `--lang`-Lauf
  neu geschrieben) sagen konvergent. Das Handbuch folgt der Sonde. Bestand, kein Auftrag dieses Reviews; Hinweis an den Implementer.
- `verifizierbar`: nein · `klasse`: „Zwei Kommentare desselben Pfads nennen verschiedene Klassen“

**I-3** — `quelle`: Setzung „keine Chronik“
- `pfad`: `README.md:59` („Ab `v0.1.0` liegen fertige Programme …“); außerhalb des Diffs
- `befund`: Die Setzung gilt nach dem Wortlaut der Nutzerdoku; die README-Zeile trägt die Form „ab v0.x“. Nicht Gegenstand des Diffs; zusammen mit M-1 nachziehbar.
- `verifizierbar`: nein · `klasse`: „Versions-Chronik in Nutzerdoku“

---

## Geprüft, ohne Befund

- **Klassen-Aufteilung (Zeilen 356-357, 359, 573, 582, 594):** gegen die Klassen-Sonde und `enforce.go`/`zeilenenden.go`/`agents.go`/`commands.go`/`commitmsg.go`/`emit.go`/`templates.go`
  Datei für Datei — jede genannte Datei liegt in der genannten Klasse; die Aussage „kanonisch … eine von Hand geänderte Datei ist danach wieder die mitgelieferte“ trägt;
  „nur bei fehlender Datei“ trägt; „löschen Sie sie vor dem Re-Lauf“ (Klasse 2) entspricht `writeSkipIfPresent` (schreibt bei fehlendem Pfad). (Lücken der Mengen: L-5.)
- **Zahl „fünf“ und ihre Aufteilung (zwei konvergent, drei skip-if-present)** gegen `zeilenendenFiles()` und die Sonde: trägt in allen drei Zielen.
- **Meldung „nennt Datei und Folge“ für vier Pfade, still für den Rest der zweiten Klasse:** Sonde trägt (Wortlaut: L-2).
- **Eigenschaft „ein Klon mit `core.autocrlf=true` trägt in diesen Verzeichnissen kein CR“ und „unabhängig von einer Wurzel-`.gitattributes`“:** beide Klone, 0 Dateien mit CR.
- **Kennungs-Form der `.d-check.yml`:** Token `slice-`/`welle-`, Regel `spec-straten → welle` (und die Nachbarregeln auf `adr`, `slice`, `adaptionsblock`, `aussen`), Muster
  `ADR-([A-Z]+-)?\d{4}` mit `link-policy: always`, Klasse `adr` mit beiden Globs gegen `templates/d-check.yml`; grüner Start und beide roten Gegenbeispiele mit ihren Regel-Namen
  gefahren (`id-unlinked`, `matrix-forbidden`). Die Nachtragsliste entspricht der Liste im Kommentar der Vorlage (vier Positionen); die Klasse `welle` selbst trug schon `v0.2.3`.
- **„Vorhandene `.d-check.yml` bleibt unberührt, ohne Meldung“:** Sonde trägt.
- **Übrige Vorkommen der geänderten Aussage im Handbuch** (`grep` über Handbuch, `docs/user/*.md`, `README.md` auf aufgefrischt/werkzeug-eigen/Prüf-Konfiguration/idempotent/
  Re-Lauf/überschr/unangetastet/unberührt/Soll-Stand): Zeilen 3, 201, 203, 225, 251, 318, 342-361, 417, 543, 573, 582, 592, 594, 611 konsistent; `werkzeug-eigen`/`aufgefrischt` steht im
  Handbuch nirgends mehr. Restfund: M-1 (README, `--help`). `docs/user/e2e-abdeckung.md:37` ist die generierte Sicht der Stufen-Deklarationen und trägt keine Zusage über die Klassen.
- **Chronik/Prognose/Konjunktiv in den hinzugefügten Zeilen:** kein Konjunktiv über eine verworfene Fassung; „auch ein Repository, das mit einer früheren Fassung des Programms aufgesetzt
  wurde, behält seine“ (Zeile 504) beschreibt eine Eigenschaft des Ist-Zustands (die Datei wird nicht geschrieben), keine Chronik. Nichts Unimplementiertes: kein Windows-`make`, keine
  Restdateien-Zahl im Diff. Versions-Aussagen: I-1.
- **Versionszeilen (`Software-Stand`, `Stand`, Weg A, Zeile 318):** stimmen untereinander; Zeile 318 (`direction:`-Rollen-Form für `v0.2.4`) ist bis auf die Version unverändert.
- **§3.9 Docker-only im Diff:** das einzige Kommando im hinzugefügten Text ist `find … | wc -l` **im aufgesetzten Repository**; kein Host-Toolchain-Aufruf in einer Anweisung an den Adopter.
- **HIGH-Liste des Skills:** Verstoß gegen aktive ADR/Hard Rule (`ADR-0065`/`ADR-0067`-Aussagen gegen Code) — kein Fund; Gate-Lockerung — der Diff berührt kein Gate; Stilles-Grün-Pfad —
  keiner (der Diff ist Prosa); halluziniertes Gate — keines (`make docs-check` existiert, im Beispiel nur aufgerufen); superseded ADR — `ADR-0060`, `0065`, `0067` sind Accepted (`0065`, `0067`
  gelesen); Norm nur im Template-Kommentar — nicht berührt; Kommentar-Klassen — `<!-- d-check:ignore … -->` trägt eine Klasse (Grenze: der Pfad entsteht erst im Ziel); Zustandsfeld mit
  Chronik — die Zeile `Stand: 2026-09-25` ist Datum des Standes, keine Chronik.
- **Nicht Gegenstand:** `traeger.mk`, `test/traeger-fetch.bats`, der Slice-Plan; DoD und Plan-Konformität (Verifier).

---

**Summary:** 0 HIGH · 1 MEDIUM · 6 LOW · 3 INFO — Klassen: „Dieselbe Zusage an mehreren Fundorten, einer nachgezogen“ (M-1), „Einschub trennt einen Absatz von seiner Überschrift“,
„Zitierter Wortlaut weicht vom Programm-Wortlaut ab“, „Zusage benennt ihre Grenze unvollständig“, „Kommando misst einen weiteren Ausschnitt als die Prosa“, „Klassen-Tabelle nennt die Menge nicht
vollständig“, „Repo-Vokabular im Adopter-Text ohne Erklärung“.

**Übergabe:** Die Findings gehen an den Implementer (keine Korrektur in diesem Lauf, kein Rollen-Konflikt). Der Verifier prüft danach die DoD.
