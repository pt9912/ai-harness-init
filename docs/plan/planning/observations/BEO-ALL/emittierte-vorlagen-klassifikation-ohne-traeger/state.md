**Stand:** geplant

Kennung: `slice-194` — er emittiert den letzten Ort, den ein mitemittierter Text im Indikativ
führt und den kein Emissions-Pfad anlegt, und schließt damit die offene Anwendung.

**Was schon entschieden ist, und warum das den Stand nicht auf *verkörpert* hebt.** Das Kriterium
steht: [`ADR-0037`](../../../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md) Festlegung 1
macht die **Eigenschaft** maßgeblich statt der Namensliste, Festlegung 2 entscheidet für den
Register-Ort seinen **Träger**, Festlegung 3 seine Idempotenz-Klasse, Festlegung 4 den Ausschluss.
Eine ADR ist aber eine **Entscheidung**, kein Zielort einer Verkörperung: Baseline-Regelwerk
`modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle führt als verkörperte Regel *Hard Rule ·
Gate · Skill · `MR`*, und *verkörpert* verlangt einen Zielort, der den Herkunfts-Anker **trägt** —
was eine ab `Accepted` unveränderliche Datei
([`AGENTS.md`](../../../../../../AGENTS.md) §3.4) nicht mehr aufnehmen kann.

**Grenze, benannt: die Regel hat auch nach der Anwendung keinen Sensor.**
[`ADR-0037`](../../../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md) §Fitness Function
stellt das selbst fest — Bedingung (a) ist ein Urteil, und die **Deckung zwischen emittiertem Text
und emittiertem Bestand** hat keinen Wächter: Das Doku-Gate des Ziels fährt `codepaths` nicht, und
im Dogfood liegt der emittierte Bestand außerhalb des Prüfbereichs. Gedeckt ist allein die
Mengengleichheit des emittierten Baums (`TestTemplates_EmittierterBestandVollstaendig`, in
`make gates`). `slice-194` schließt die Anwendung, nicht diese Lücke.
