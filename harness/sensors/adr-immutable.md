# `make adr-immutable` — hält den Kern einer `Accepted`-ADR über einer Range unverändert

## Vertrag

`make adr-immutable RANGE=<base>..<head>` (oder `STAGED=1`) kettet
[`history-range-guard`](history-range-guard.md) vor den eigentlichen `vcs`-Modul-Lauf
(`make doc-immutable`). Wie `history-range-guard` kein Gate, in keiner Prerequisite-Kette —
die Range variiert pro Aufruf. Geprüft wird [`AGENTS.md`](../../AGENTS.md) §3.4: der Kern
einer über die Range `Accepted` gebliebenen ADR ändert sich nicht.

## Grenze — was das Grün nicht abdeckt

`make adr-immutable RANGE=<base>..<head>` (oder `STAGED=1`) kettet diesen Wächter vor den
eigentlichen `vcs`-Modul-Lauf (`make doc-immutable`, `d-check.mk`) — **wie `history-range-guard`
kein Gate, in keiner Prerequisite-Kette**, denn die Range variiert pro Aufruf und ist damit kein
hermetischer Prüfbereich ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
Geprüft wird [`AGENTS.md`](../../AGENTS.md) §3.4: der Kern einer über die Range `Accepted`
gebliebenen ADR ändert sich nicht. Der `vcs:`-Block in `.d-check.yml` ist gegen den **gelebten**
Bestand gesetzt, nicht gegen den Vorschlag aus `d-check --print-config` — die Abweichungen
tragen die Zusage und sind an einem Wegwerf-Klon außerhalb des Repos gemessen, nicht
angenommen: `exclude-sections: [Geschichte]` nimmt den Abschnitt aus dem Kern, in dem eine ADR
ihre Fortschreibung führt — jede ADR dieses Repos endet mit `## Geschichte`, und ohne die
Ausnahme färbte jede Fortschreibung statt nur eine Kern-Änderung rot. `head-allow` ist **voll
verankert** (`^…$`, kein Präfix-Match — ein Zusatz hinter `Accepted`, etwa
„Accepted (überholt, siehe ADR-NNNN)“, färbt seit diesem Anker rot statt durchzurutschen) und
trägt drei Werte: `Accepted` unverändert, `Deprecated` (Vokabular der ADR-Vorlage und von
[`docs/plan/adr/README.md`](../../docs/plan/adr/README.md), Ausgang ohne Nachfolger) und die im
Bestand gelebte Link-Form des Supersede-Übergangs (`Superseded by [ADR-NNNN](NNNN-titel.md)`) —
nicht die vom Werkzeug vorgeschlagene bare Kennung, und nicht die vom Index ebenfalls geführte
bare Supersede-Form (`Superseded by ADR-NNNN` ohne Klammern): Letztere bleibt ausgeschlossen, aber
**nicht**, weil ein anderes Modul sie ohnehin fängt — gemessen ist das Gegenteil: `ids`
(`link-policy: always` auf `ADR-\d{4}`) prüft Kennungen nur **außerhalb** ihres eigenen
Zieldateibaums `docs/plan/adr/`. Dieselbe bare Erwähnung (`echo 'Text mit bare ADR-0005.' >>
<datei>`, ein Commit, `make docs-check`) trifft in `docs/plan/planning/in-progress/roadmap.md`
`id-unlinked` (1 Befund), in einer Datei unter `docs/plan/adr/` `0 Befund(e)`. `head-allow` ist
an dieser Stelle die **einzige** Durchsetzung der im Bestand gelebten Link-Form, kein redundanter
zweiter Schutz.
`status-line` markiert, welche Zeile diesem `head-allow` statt der vollen
Kern-Unveränderlichkeit unterliegt; ohne sie fällt die Statuszeile in den Kern und jeder erlaubte
Übergang färbt rot. Was `vcs` **kann**, bleibt eine gemessene Eigenschaft des vendored Werkzeugs
und keine dieses Repos.

**Ein Aufrufer existiert:** der Job `adr-immutable` in `.github/workflows/ci.yml` bestimmt die
Range ereignisabhängig — bei `pull_request` Base gegen Head, bei `push` den vorherigen
Ref-Stand (`github.event.before`) gegen den neuen — und überspringt einen Push ohne vorherigen
Stand (neuer Branch, `before` ist die Nullreferenz), statt eine Basis zu erfinden. Sein Checkout
trägt `fetch-depth: 0`; alle übrigen Checkouts des Repos bleiben bei der Default-Tiefe
(Begründung im Kopf von `.github/workflows/ci.yml`).

**Ein reiner `git mv` einer ADR-Datei ist gemessen, nicht offen:** Das Modul trennt ihn **nicht**
von einer Kern-Änderung — es zählt Pfad-Stabilität zur Immutabilität. Gegen einen Wegwerf-Klon,
ein Commit, der eine `Accepted`-ADR ohne Inhaltsänderung umbenennt:

```sh
git mv docs/plan/adr/0003-go-native-binaries.md docs/plan/adr/0003-umbenannt.md
git commit -qm "reiner git mv einer Accepted-ADR"
make adr-immutable RANGE=<base>..HEAD
# docs/plan/adr/0003-go-native-binaries.md:1  core-drift-vcs
#   immutable Datei geloescht oder umbenannt — der Pfad einer immutablen Datei ist stabil
```

Operativ folgenlos bleibt das heute: ADR-Pfade sind ortsfest, und
[`AGENTS.md`](../../AGENTS.md) §3.11 nimmt sie ausdrücklich von der wandernden Klasse aus — ein
realer `slice-mv`-artiger Umzug einer ADR-Datei ist in diesem Repo nicht vorgesehen. Träte er ein,
wäre der Fehlalarm hier der Beleg dafür, dass die Bewegung als zwei Commits (Hard Rule 3.3) allein
nicht reicht: `vcs` bräuchte eine eigene Ausnahme für den reinen Move, die es heute nicht gibt.

**Was innerhalb von `## Geschichte` stehen darf, ist entschieden, nicht offen gelassen.** Die
Ausnahme ist die Voraussetzung dafür, dass der Sensor an der Kopfzeile statt am Dateiende
anschlägt (s. o.); sie kostet, dass ein Absatz, der dort statt in einer Folge-ADR landet,
unbewacht bleibt. Der Umfang der so ungeschützten Fläche ist gemessen und wächst mit jeder
Fortschreibung:

```sh
t=0; g=0; for f in docs/plan/adr/[0-9]*.md; do
  t=$((t+$(wc -c < "$f"))); g=$((g+$(awk '/^## Geschichte/{i=1} i' "$f" | wc -c))); done
awk -v a=$g -v b=$t 'BEGIN{printf "%d von %d Bytes = %.1f%%\n", a, b, 100*a/b}'   # 8.0 % im Schnitt, bis 28,1 % je Datei
```

Die Alternative — `exclude-sections: []` — ist keine engere, sondern eine strengere Variante mit
einem anderen Fehler: Jede ADR dieses Repos endet mit `## Geschichte`; ohne die Ausnahme würde
**jede** Fortschreibung einer angenommenen ADR rot färben, nicht nur eine Kern-Änderung — 100 %
der heutigen Fortschreibungen wären Fehlalarme gegen 0 gemessenen normativen Sätzen im
Geschichte-Abschnitt heute (`git grep -n 'Revidiert (Teil-Supersede)' -- 'docs/plan/adr/0*.md'`
gegen die Zeilennummer von `^## Geschichte` derselben Datei zeigt: die drei bestehenden
Teil-Supersede-Anordnungen liegen im geschützten Kern, keine im Geschichte-Abschnitt). `vcs`
kennt keine dritte, feinere Stufe — der Schlüssel schließt einen benannten Abschnitt vollständig
aus dem Kern oder gar nicht, eine partielle (append-only) Prüfung bietet das Modul nicht. Dieses
Repo trägt deshalb bewusst die zweite Fehlform (ein still bleibender Verstoß ist möglich, aber
heute nicht eingetreten) statt der ersten (ein Gate, das bei jeder legitimen Fortschreibung
blockiert): Die Kosten der ersten sind sicher und laufend, die der zweiten sind hypothetisch und
liegen bei der Review-Disziplin ([`AGENTS.md`](../../AGENTS.md) §3.7 für den Kommentar-Fall,
[`docs/plan/adr/README.md`](../../docs/plan/adr/README.md) für den Zusatz-Umfang einer
Teil-Supersede-Anordnung).

**Eine Grenze bleibt offen, benannt statt geschlossen:** ob `vcs` dieselbe
`exclude-sections`-Liste wie `matrix` braucht (`[Historie, "7. Historie", Geschichte]`), ist
geprüft, aber nicht übernommen, solange kein ADR-Kopf eine dieser zwei zusätzlichen
Überschriften trägt.

## Bindung

[`AGENTS.md`](../../AGENTS.md) §3.4/§3.5; Vorlauf-Wächter [`history-range-guard`](history-range-guard.md).
Aufgerufen vom Job `adr-immutable` in `.github/workflows/ci.yml`.
