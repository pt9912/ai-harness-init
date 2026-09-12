# `make archive-welle` — archiviert die Zeitdokumente einer geschlossenen Welle

## Vertrag

`make archive-welle WELLE=<welle-id>` archiviert die Zeitdokumente einer geschlossenen Welle —
Schritt 4 der Wellen-Closure. Kein Gate, in keiner Prerequisite-Kette: es archiviert, es prüft
nicht ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Der
Träger ist das Produkt-Binär, die Operation sein Unterkommando
([`ADR-0033`](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 1);
das Target hängt an `host-bin` und fährt
`.harness/state/bin/ai-harness-init archive-welle "$(WELLE)"`.

Eingesammelt wird **nach der Welle, nicht nach dem Verzeichnis**: die Slices, deren `Welle:`-Feld
diese Welle nennt, und die wellenlosen, die seit der letzten Closure geschlossen wurden. Die
Slice-Dateien, der Welle-Plan und die Review-Reports dieser Slices wandern nach
`docs/plan/planning/done/<welle-id>/archiv.zip`; an der Stelle von Slice und Plan bleibt je ein
gekürzter Stub aus den zwei vendored Vorlagen, die Ergebnisnotiz bleibt vollständig und flach,
Review-Reports bekommen keinen. Gepackt wird aus der Go-Standardbibliothek — kein gepinntes Bild
und kein `zip`-Binär; kein Eintrag trägt einen Zeitstempel aus der Uhr des Laufs, zwei Läufe über
demselben Inhalt liefern also dieselben Bytes
([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).

Voraussetzung ist ein **sauberer Arbeitsbaum** — gemessen mit `git status --porcelain`,
einschließlich untrackter Dateien, weil der Inhalts-Commit der Wave-Self-Close-Punkt ist. Der Lauf
setzt **zwei getrennte Commits** (Hard Rule 3.3): zuerst der reine `git mv` nach
`done/<welle-id>/`, danach Archiv, Stubs und Verweis-Nachzug, gestagt über benannte Pfade statt
über den ganzen Baum. Der Nachzug läuft in drei Formen — mit Verzeichnis-Präfix,
geschwister-relativ und aufsteigend (`](../../<datei>)` in den Dateien unter `done/<welle-x>/`).

`ai-harness-init archive-welle --vorschau <welle-id>` sagt, was derselbe Lauf täte, und schreibt
dabei nichts: der Schalter hält den Aufruf nach der Vorprüfung an. Erreicht wird er über denselben
Träger, `.harness/state/bin/ai-harness-init archive-welle --vorschau <welle-id>`; ein eigenes
`make`-Ziel hat er nicht. Er ist keine zweite Fassung der Operation, sondern derselbe Code: die
Vorschau ist die Vorprüfung des schreibenden Laufs, und was sie an Sperren nennt, sind genau die
Ausgänge, an denen er abbricht.

## Grenze — was das Grün nicht abdeckt

1. **Der Unterkommando-Name in der Rezept-Zeile ist ein zweites Vorkommen desselben Literals** —
   `Makefile` und der Dispatch in `cmd/ai-harness-init/main.go` müssen übereinstimmen; ein
   Tippfehler geht als Zeichenkette durch und wird erst innerhalb des Trägers zum Fehler, nicht als
   fehlender Dateipfad — heilbar durch Namensgleichheit, sonst dauerhaft stumm bis zum Aufruf.
2. **Zwei Aufrufer liegen im Prüfbereich** — `Makefile` und `.claude/settings.json`, dessen Hooks
   den Träger direkt rufen, ohne das Wrapper-Skript, das ein emittiertes Repo bekommt.
3. **Der Suchraum der Verweis-Vorprüfung nimmt allein `.git` und `.harness/baseline/**` aus** —
   `docs/reviews/**` steht darin, denn `links`/`anchors` prüfen die Zeitdokumente wie jede andere
   Datei, und Reports verlinken einander quer über Wellen-Grenzen. Verweise auf ein
   verschwindendes Zeitdokument können auch außerhalb von Markdown stehen (Shell-Skripte,
   Go-Kommentare, Test-Fixtures) — permanent begrenzt sind nur die zwei **relativen**
   Verweis-Formen auf `.md`, weil sie Markdown-Link-Ziele sind und außerhalb einer Markdown-Datei
   gegen nichts auflösen.
4. **Auf eine Welle dieses Repos ist das Werkzeug noch nicht anwendbar**, und das ist eine
   Messung, keine Vorsicht: der Altbestand hat keine Untergrenze (kein `done/*/archiv.zip`), und
   die Review-Reports der einzusammelnden Slices tragen lebende Verweise aus
   [`spec/lastenheft.md`](../../spec/lastenheft.md), aus `docs/plan/carveouts/done/`, aus nach
   [`AGENTS.md`](../../AGENTS.md) §3.4 eingefrorenen ADRs und aus anderen Review-Reports, die
   einander quer über Wellen-Grenzen verlinken. Beides sind eigene Vorgänge, die vor der ersten
   Archivierung liegen — permanent, bis sie einzeln aufgelöst sind.
5. **Vier Grenzen bleiben unabhängig vom Bestand, alle permanent:** der Nachzug hängt Pfade um,
   keine Zustandssätze (ein Satz „liegt in `done/`" wird richtig verlinkt und bleibt ungenau); ein
   eingehender Verweis in Inline-Code ohne Verzeichnis-Segment trägt keine Link-Klammer und wird
   nicht getroffen — `make docs-check` nach dem Lauf zeigt den Rest; das Feld `Geschlossen:` nimmt
   das Datum aus der `**Rolle:** … **Datum:**`-Zeile der Closure-Notiz und sonst das
   Abschluss-Datum der Welle; und ein Review-Report über mehrere Slices trägt die Plural-Form im
   Namen („…-slices-011-014-…"), fällt damit durch die Einsammel-Regel und bleibt flach liegen.

## Ausgabe und Ausgänge

Ausgegeben werden — von beiden Zweigen (Lauf und `--vorschau`), denn es ist dieselbe Vorprüfung —
die vier Einsammel-Zahlen (Mitglieder · wellenlos · fremd · Review-Reports), der Blast-Radius
(jede Datei mit einem Verweis auf etwas Bewegtes, aufgeschlüsselt nach den drei Nachzugs-Formen aus
§Grenze) und die Sperren.

| Exit | Bedeutung |
|---|---|
| 0 | Lauf bzw. Vorschau gefahren, keine Sperre |
| 1 | Laufzeit-Fehler |
| 2 | Aufruf-Fehler |
| 3 | mindestens eine Sperre — geschrieben wurde nichts |

## Sperren

Fail-closed, geprüft **bevor** der Lauf etwas anfasst — dieselbe Vorprüfung, die `--vorschau`
ausgibt. Am ruhenden Baum sind es acht (`grep -c 'Kennung: "' internal/archive/vorschau.go`, kein
Erwartungswert):

- `untergrenze` — kein `done/*/archiv.zip` im wellenlosen Bestand → Altbestand als eigenen Vorgang
  archivieren, bevor die erste Welle läuft
- `haenger` — ein noch referenziertes Zeitdokument würde bewegt oder gelöscht → den Verweis lösen
  oder den betroffenen Vorgang aus dieser Welle herausnehmen
- „schon archiviert" — `done/<welle-id>/archiv.zip` existiert bereits → keine zweite Archivierung
- „unsauberer Baum" — `git status --porcelain` meldet Änderungen → committen oder verwerfen
- fehlende Ergebnisnotiz — `done/<welle-id>-results.md` fehlt → Closure-Notiz zuerst schreiben
- fehlender Welle-Plan → genau eine flache `<welle-id>.md` bereitstellen
- mehrdeutiger Welle-Plan (mehr als eine passende Datei) → auf eine reduzieren
- „kein Slice eingesammelt" — weder wellengebundene noch wellenlose Kandidaten gefunden → `WELLE=`
  prüfen oder die Closure-Zuordnung der Slices

Zwei Ausgänge stehen daneben, weil sie am ruhenden Baum nicht beobachtbar sind: das fehlende
`WELLE=` fängt der Aufrufer vorher ab, und eine verletzte Stub-Form bricht **zwischen** den zwei
Commits ab und nennt den Rückweg (`git reset --hard HEAD~1 && git clean -fd`).

## Bindung

[`ADR-0033`](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md); kein
Gate-Versprechen; Schritt 4 der Wellen-Closure
([Modul 6](../../.harness/baseline/v6.5.0/regelwerk/modul-06-roadmap.md#wellen-closure-prozedur-modul-6)).
