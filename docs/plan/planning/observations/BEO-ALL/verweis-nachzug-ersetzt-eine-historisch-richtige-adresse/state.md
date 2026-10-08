**Stand:** verkörpert

Zielort: [`ADR-0042`](../../../../../../docs/plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
Festlegung 4 und Festlegung 5 — der Verweis-Nachzug ersetzt eine Adresse und ändert keine Aussage;
die Fundstelle im Code-Block ist die mechanisch trennbare Gegenform, die drei übrigen bleiben
benannt. Für den Baum `docs/reviews/` schneidet
[`ADR-0070`](../../../../../../docs/plan/adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
Festlegung 1 die Reichweite: der Nachzug ersetzt dort nur die Adresse hinter `](`, und jede andere
Pfad-Adresse — reiner Span, Operand, Block, Fließtext — bleibt Byte für Byte; in den übrigen Bäumen
gilt Festlegung 4 der ersten Zielort-ADR unverändert. Ein zweiter Herkunfts-Anker steht nicht: Was aus einer
ADR folgt, trägt bereits eine ID; der Zielort trägt hier seine eigene Kennung.

**Umsetzung in den Trägern: geliefert.** `slice-lifecycle-move-schreibt-in-reports-nur-die-link-form`
(`make slice-mv`) und `slice-archive-welle-schreibt-in-reports-nur-die-link-form` (`archive-welle`)
führen die Form-Regel und liegen in `done/`
(`ls docs/plan/planning/done | grep -c -e slice-lifecycle-move-schreibt-in-reports-nur-die-link-form -e slice-archive-welle-schreibt-in-reports-nur-die-link-form`
→ 2); `slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt` liefert ihre
Kopplung an `codepaths.exempt-paths` und liegt in `done/`
(`ls docs/plan/planning/done | grep -c slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt`
→ 1). Der Übergang aus Festlegung 5 der
ADR-Entscheidung zur `docs/reviews/`-Reichweite ist mit den zwei Trägern beendet.

**Grenze der Verkörperung, benannt.** Der Zielort nennt sie selbst (§Fitness Function): „diese
Entscheidung behauptet den Wächter dafür nicht" — `make docs-check` meldet über dem umgeschriebenen
wie über dem ursprünglichen Stand dasselbe. Träger bleibt der Lauf, der die Mess-Aussage schreibt:
er wählt eine Form ohne Pfad-Literal oder trägt den Nachzug seiner eigenen Zahlen nach. Für
`docs/reviews/` halten beide Träger die Regel. Ihre Grenzen
stehen im Zielort: das Link-Zitat im Code-Span wird mitersetzt (Trigger 6), die Referenz-Definition
ist nicht Teil der Regel (Trigger 7), und die Operand-Form in `done/` bleibt ersetzt. Die Regel hängt
an `codepaths.exempt-paths` für `docs/reviews/**` in der `.d-check.yml`; diese Kopplung hält
`test/codepaths-reviews-ausnahme.bats` (läuft in `make gates`), und die Mutations-Fälle
`474-codepaths-reviews-ausnahme-entfaellt` und `475-codepaths-reviews-ausnahme-wandert-in-einen-nachbar-block`
binden Blockanfang und Blockende seiner Abschnitts-Erkennung. Der Wächter hält die **Zeile** in einer einzeiligen
Flow-Liste mit doppelten Anführungszeichen, nicht die Wahrheit der Gate-Begründung und nicht die Implikation
*Regel ⇒ Zeile*; Träger für Trigger 1 der ADR bleibt der Folge-ADR-Vorgang, den seine Meldung nennt.

**Sensor:** `internal/archive/refs_test.go` und `cmd/ai-harness-init/slice_mv_echt_test.go`
(`make test`) halten die Form-Regel aus [`ADR-0070`](../../../../../../docs/plan/adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md) Festlegung 1 in beiden Trägern.
