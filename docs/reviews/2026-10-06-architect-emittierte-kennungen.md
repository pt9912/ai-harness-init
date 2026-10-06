# Architect — Kennungen des Werkzeugs in emittierten Dateien

Rolle Architect, 2026-10-06. Eingang: Frage des Auftraggebers. Ausgang: Verdikt ohne MR und ohne ADR.

## Messung

Kommando: `git grep -nE 'ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}' -- internal/emit/templates ':!*_test.go'`, dazu dieselbe Suche über `internal/emit/*.go` ohne Zeilen, die mit `//` beginnen (Go-Strings, die ins Ziel gehen). `commands/*`, `agents/*`, `observations/*` tragen nur Platzhalter-Formen (`LH-`, `ADR-NNNN`) — kein Treffer.

Emittiert 49 Zeilen mit Kennung (Datei: Zeilen): `traeger-fetch.sh` 19, `traeger.mk` 7, `selbstpruefung.sh` 5, `span-emit.sh` 4, `hooks-install.mk` 4, `selbstpruefung.mk` 3, `emit.go` (Doc-Gate-Fragment) 3, `baseline-verify.sh` 2, `e2e-abdeckung.mk` 1, `d-check.yml` 1. Nicht emittiert: Kommentare und Fehler des Werkzeugs selbst (`enforce.go:468`, `baumaussage.go:327`, alle `//`-Zeilen).

Trennung: 37 Kommentare; 10 Meldungen, die ein Anwender sieht (`hooks-install.mk:48`, `selbstpruefung.sh:203`, `traeger-fetch.sh:43,59,67,96,101,130`, `emit.go:106,114`); 2 funktionale Nutzlast (`selbstpruefung.sh:87`, `selbstpruefung.mk:39`: der Default-Commit-Text `LH-FA-01` muss ein Kennungs-Muster des Ziels treffen, ein Ziel überschreibt ihn).

## Verdikt

- **(1) Eigenschaft:** Ein emittierter Kommentar oder Meldungstext trägt keine Kennung, die im Ziel nicht auflöst; die Zusage steht in Worten, die Herkunft hält Release und git des Werkzeugs. Zulässig bleiben Kennungen, die das Ziel selbst führt (Platzhalter-Form, vom Lauf emittierte Register), und funktionale Nutzlast, die ein Muster treffen muss (die zwei Default-Texte). Meldungen: Wortlaut statt Kennung; der Anwender handelt nach dem Satz, nicht nach einem Verweis ins Werkzeug-Repo.
- **(2) Weder MR noch ADR.** Der Satz folgt der Baseline 1:1: `grundlagen-harness-dateien.md` §Was ein Kommentar trägt verlangt die Herkunft als *auflösbares* Feld; im Ziel löst `ADR-0054` nicht auf. Ein MR ist hier falsch — er bindet die Dogfood-Ebene, und `MR-059` Setzung 4 weist die emittierte Ebene ausdrücklich dem Vorgang zu, der die Tool-Ebene entscheidet (`AGENTS.md` §3.7). Eine ADR braucht es nicht: keine Accepted-ADR wird berührt, nur emittierter Text wird an die Baseline angeglichen. Der Slice trägt die Entscheidung.
- **(3) Wächter-Form:** Go-Test in `internal/emit/`, der alle Lauf-Varianten (Sprache, `--arch`, mit/ohne Erfassung) in ein Temp-Verzeichnis emittiert, jede Datei durchläuft und das Muster oben (`\b`-gebunden) sucht. Fundmenge nach `MR-059`: namentliche Ausnahmeliste *Datei → Kennungs-Menge* (heute die zwei Nutzlast-Zeilen), Vergleich auf Gleichheit in beide Richtungen, nicht nur „keine Treffer außerhalb". Rot herstellen: eine `ADR-0001` in eine Vorlage schreiben, Test fällt mit Dateiname; dazu die Ausnahme streichen.
- **Ohne Wächter:** Zweige, die der Test nicht fährt (nicht gesetzte Flag-Kombinationen); Prosa-Verweise ohne Ziffernform (`slice-…`, `Modul 13`, `ADR` ohne Nummer); ob der Ersatz-Wortlaut die Zusage wirklich trägt (Urteil, kein Sensor). Bestehende Tests, die Meldungen mit Kennung zitieren, zieht der Slice mit.
- **Übergabe an den Planner:** Gegenstand: ein Slice „emittierte Dateien tragen keine nicht auflösende Kennung" (Kommentare umformulieren, 10 Meldungen in Worte, Wächter-Test); Fundmenge 49 Zeilen in 10 Dateien, davon 2 Ausnahmen; Wächter-Form wie (3). Größe: Schnitt in zwei Slices prüfen (traeger-Familie 26 Zeilen vs. Rest), da ≤ 3 Liefer-Punkte.

Laufzeit: siehe letzte Zeile der Antwort.
