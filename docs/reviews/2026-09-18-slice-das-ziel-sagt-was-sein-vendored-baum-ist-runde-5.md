# Review-Report: `slice-das-ziel-sagt-was-sein-vendored-baum-ist` — 2026-09-18, Runde 5

**Review-Art:** Code — die Nacharbeit zu R4-1 und R4-2. **Keine** DoD-Abhakung.

**Gegenstand:** `193064a8`.

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5 · **Datum:** 2026-09-18

**Eingangs-Kontext:** der Slice-Plan §1 und §3 · `ADR-0007` Festlegung 3, `ADR-0054`
Festlegung 1 · `LH-QA-01`, `LH-FA-09` · `AGENTS.md` §3.7 · die Reports der Runden 1 bis 4.

---

## 1. Ist die neue Zusage wahr?

**Ja, und die Messung des Implementers geht über meinen Befund hinaus — zu Recht.** Ich habe
sie nachgefahren, nicht übernommen:

- **Genannt wird genau ein Pfad.** Die Melde-Zeile schreibt `writeSkipIfPresentTold`, erreicht
  über `writeEnforceFile`. Skip-if-present sind dort drei Gruppen: die sechs Rollen-Typen
  (`internal/emit/agents.go:52`), die drei Workflow-Commands (`internal/emit/commands.go:30-32`)
  und der Commit-Träger (`internal/emit/commitmsg.go:58`). Die ersten zwei Gruppen schreiben
  mit `io.Discard` (`agents.go:89`, `commands.go:61`) — ihre Zeile geht ins Leere. Einen
  echten Kanal bekommt allein `emit.Enforce(targetDir, notice)`
  (`cmd/ai-harness-init/main.go:439`, `notice io.Writer` aus `emitAll`), und dort ist der
  Commit-Träger der einzige skip-if-present-Eintrag. **Ein Pfad, nicht mehr** — und real
  belegt ist er durch die `full-smoke`-Stufe zur Klasse des Commit-Trägers.
- **Für alle anderen schweigt der Lauf.** `writeSkipIfPresent`
  (`internal/emit/enforce.go:510`) kehrt stumm zurück; `Templates`, `RootReadme`, `DocGate`
  und das Arch-Gate haben keinen Kanal. Und der Zusatz *„gleichgültig, ob er sie geschrieben
  oder stehen gelassen hat"* stimmt ebenfalls: Die Ausgabe des Init-Pfads besteht aus der
  einen Abschluss-Zeile (`main.go:403`) und Fehlern auf `stderr` — keine Zeile nennt einen
  geschriebenen Dokument-Pfad.

Die Aufzählung im Satz (Doku-Kette, Spec-Dateien, Roadmap, `README.md`, `.d-check.yml`,
Rollen-Typen, Workflow-Commands) trifft damit zu, und die Fälle, die sie nicht nennt — das
konditionale `.a-check.yml`, das Sprach-Skelett — deckt das vorangestellte *„Für jeden
anderen schweigt er"*.

## 2. Trägt das Erkennungs-Merkmal?

**Ja.** Es ist die einzige Auskunft, die ohne Lauf-Ausgabe zu haben ist, und sie ist
zutreffend: An einer skip-if-present-Adresse steht entweder der Text des Werkzeugs (dann hat
der Lauf geschrieben) oder ein anderer (dann hat er stehen gelassen) — genau die Zweiteilung,
die `ADR-0007` Festlegung 3 für diese Klasse setzt. Es ersetzt keine Melde-Zeile, und der
Satz behauptet das auch nicht; er nennt ein Merkmal, kein Verfahren.

## 3. Ist die Entscheidung gegen den Kanal-Ausbau in der Abgrenzung?

**Ja.** Der Slice füllt die emittierte Doku-Schicht; sein Kopf sagt ausdrücklich, dass er
keine Spec-Stelle ändert, und seine Plan-Tabelle §3 führt `cmd/` nicht. Ein Melde-Kanal für
`Templates`, `RootReadme` und `DocGate` wäre eine **Verhaltens**-Änderung des Bootstraps
statt einer Aussage über ihn — die Schicht-Abgrenzung aus §1, und damit ein eigener Vorgang.
Der gewählte Weg ist zugleich der, den Modul 13 §Hard Rule (Doku-Disziplin) vorzeichnet: die
Differenz benennen, statt sie mitzubehaupten. Hätte der Implementer stattdessen `cmd/`
angefasst, wäre das der Plan-Bruch gewesen, den F-7 als Klasse schon notiert hat.

## 4. R4-2 und neue Befunde

**R4-2 ist erledigt.** Die `GRENZE`-Notiz nennt jetzt `baseline-verify`, `span-report`,
`span-clean` und `GATE_CHECKS` — die vier, die real aus der Form-Regel fallen, und keines,
das in keiner Zelle vorkommt. Das deckt sich mit meiner eigenen Extraktion aus Runde 3.

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R5-1 | INFO | Die Aussage *„einen einzigen solchen Pfad nennt der Lauf"* ist eine gemessene Aussage über das Werkzeug ohne eigenen Wächter: Sie fiele still, sobald ein weiterer skip-if-present-Eintrag in eine Emissions-Stelle mit echtem Kanal käme oder `emit.Commands`/`emit.Agents` ihren `io.Discard` verlören. Die positive Hälfte hält die `full-smoke`-Stufe zum Commit-Träger; die Abgrenzung *„und sonst keiner"* hält nichts. | Maintainability · `LH-QA-01` | `internal/emit/baumaussage.go:302-303` gegen `internal/emit/agents.go:89` und `internal/emit/commands.go:61` | ja — ein Go-Test, der die skip-if-present-Einträge mit echtem Kanal zählt; heute gibt es ihn nicht | Gemessene Werkzeug-Aussage ohne Wächter für ihre Abgrenzung |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Zusage „genau ein Pfad" | geprüft, ohne Befund — über alle drei skip-if-present-Gruppen und alle Emissions-Stellen nachgezählt |
| Zusage „für jeden anderen schweigt er" | geprüft, ohne Befund — der Init-Pfad druckt eine Abschluss-Zeile und sonst nur Fehler |
| Erkennungs-Merkmal | geprüft, ohne Befund — entspricht der Klassen-Setzung aus `ADR-0007` Festlegung 3 |
| Abgrenzung §1 / Plan §3 | geprüft, ohne Befund — `cmd/` bleibt unberührt, der emittierte Datei-Satz unverändert |
| `GRENZE`-Notiz | geprüft, ohne Befund — vier reale Beispiele, `SHA256SUMS` entfernt |
| Wächter und Mutationen | geprüft, ohne Befund — funktional unverändert; 367, 368 und 369 treffen weiter ihre realen Zeilen |
| `AGENTS.md` §3.7, `MR-025`, `MR-033`, `MR-053` | geprüft, ohne Befund — beide Änderungen sind Text im Indikativ, keine neue Zahl, keine Baseline-Aussage ohne Mess-Stand, der Adaptions-Block unberührt |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 0 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Gemessene Werkzeug-Aussage ohne Wächter für ihre Abgrenzung

Über den ganzen Slice gerechnet steht die Familie *Zusage über das Ziel reicht weiter als das,
was dort passiert* bei drei Instanzen (F-3, R3-1, R4-1). Das ist der Eintrag für die
Closure-Notiz §7 und das Beobachtungs-Register — und der Steering-Loop-Ertrag dieses Slice:
Jede der drei wurde nicht durch ein Gate gefunden, sondern durch den Abgleich einer
emittierten Aussage mit dem Zweig des Emitters, den sie nicht nennt.

## Verdikt

**Die Closure ist frei.** Der Satz sagt jetzt, was der Lauf tut, und nicht mehr; die
Einschränkung ist die richtige Antwort auf R4-1, weil die Alternative den Slice über seine
eigene Schicht hinausgetrieben hätte. R5-1 ist eine Notiz ohne Handlungsdruck — sie gehört in
die Closure-Notiz, nicht in eine sechste Runde.

Unverändert offen und **keine** Bedingung dieses Slice: F-7 (Planner), F-8 (INFO), R2-1
(Architect) und die Klassenfrage aus F-5 (Architect).

**Übergabe:** keine Findings mehr an den Implementer; die Finding-Klassen der fünf Runden
gehen in die Slice-Closure §7. Dieser Report ist Lauf-Beleg und ersetzt keine Verifikation —
DoD-Konformität prüft der Verifier separat.
