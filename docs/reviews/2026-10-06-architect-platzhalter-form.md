# Architect-Verdikt: Platzhalter-Form der emittierten Commands und Träger der emittierten Kennungs-Erkennung

Rolle: Architect. Gegenstand: Start-Trigger und Übergabe des Slice-Plans zur Platzhalter-Form.

## Verdikt 1 — `<Kennung>`, ohne Adaptions-Eintrag und ohne ADR

Die Baseline setzt die Form selbst: Namen statt Nummern
(`grundlagen-source-precedence.md` §Vergabe),
Anker `seit welle-<Kennung>` / `seit slice-<Kennung>`
(`grundlagen-traceability.md` §Herkunfts-Anker).
Die emittierten Commands folgen ihr 1:1; es gibt nichts, was eine Abweichung registrierte
(`MR-000`: kein Eintrag ohne Delta). `MR-057` und `MR-059` Setzung 4 weisen die emittierte Ebene dem
Vorgang zu, der die Tool-Ebene entscheidet — dieses Verdikt ist die Quelle, der Slice vollzieht sie.
Die Start-Bedingung des Platzhalter-Slice ist damit erfüllt.

## Verdikt 2 — die emittierte Erkennung bekommt einen eigenen Träger

- Der Platzhalter-Slice bleibt Text-Arbeit, der Erkennungs-Slice trägt nur die Dogfood-Seite
  (Ebene und Abgrenzung nennen die emittierte Seite ausdrücklich aus, `MR-059` Setzung 4). Ihn um die emittierte Seite zu
  erweitern hieße, seine Abgrenzung zu ändern (anderer Plan, andere Schicht: Emissions-Vorlage plus Go-Test statt Werkzeug-Skripte,
  andere Frist — Setzung 5 bindet nur die Dogfood-Vergabe). Ein **neuer Slice** ist der Träger; der Planner schneidet ihn.
- Gegenstand als Eigenschaft: die Zeile `patterns=` der emittierten commit-msg-Prüfung erkennt die Slice-Kennung in jeder Form,
  die die Baseline vergibt (Name; Nummernform des Bestands bleibt), und ein Test an der emittierten Fassung färbt rot,
  sobald ein benannter Slice nicht erkannt wird. Der unveränderte Bestand (`slice-12`) bleibt grün.
- §3.5: Das breitere Muster ist **keine Senkung, sondern eine Schärfung der Zusage** — die Prüfung sagt „Kennung anwesend" zu und
  weist heute die Kennungs-Form der Baseline zurück; die Schwelle (mindestens eine Kennung aus der Menge) bleibt. Akzeptiert wird
  mehr als nötig, wenn das Muster nur `slice-` plus Zeichen verlangt (`slice-based` im Fließtext geht durch); das ist das
  **akzeptierte Negativ** der Anwesenheits-Prüfung (GRENZE im Skriptkopf: geprüft wird Anwesenheit, nicht Wahrheit; ein Wort nach
  `slice-` ist ebenso unaufgelöst wie `slice-9999`). Die Prüfung auf Auflösung gibt es hier nicht und braucht keinen Träger.
- `ADR-0053` Festlegung 4 ist erfüllt (Werkzeug-Messages tragen Kennungen) und verlangt die emittierte Erkennung nicht; sie
  ändert sich nicht, die Entscheidung braucht keine Folge-ADR.

## Übergabe an den Planner (Pläne nicht von mir geändert)

1. Neuen Slice für die emittierte Seite schneiden (Eigenschaft oben); er ändert `patterns=` in
   `enforce/commit-msg-traceability.sh` und die zugehörigen Tests/`test/mutations`-Fälle, die das Muster `slice-[0-9]+` führen
   (`grep -rl 'slice-\[0-9\]' internal test`).
2. Platzhalter-Slice: im §1-Punkt „Das Muster `slice-[0-9]+` im emittierten Hook" den Satz „der Architect benennt den Träger" durch die
   Kennung des neuen Slice ersetzen (Klasse 1: Folge-Slice mit Kennung; er muss die Sendung annehmen), und den Start-Trigger als erfüllt führen.
3. Erkennungs-Slice (Dogfood): keine Änderung nötig; seine Abgrenzung zur emittierten Ebene bleibt wahr.
