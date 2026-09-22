**Vorgang:** slice-lifecycle-werkzeuge-tragen-die-kennung
**Fund:** DoD (3) der ersten Fassung erweiterte die Kennungs-**Erkennung** in
`commit-msg-traceability.sh`/`.d-check.yml` — genau die Bedingung, die das absorbierte, bereits
geschlossene `slice-werkzeug-commits-tragen-eine-kennung` in seiner §4 explizit zur
**Start-Bedingung** eines anderen, weiterhin offenen Siblings macht (*„die Erkennung trägt die
Form, in der die Kennung geschrieben wird"*), und die `slice-kennungs-erkennung-traegt-die-zugelassenen-formen`
(unverändert in `open/`) in eigener §1/§3 als seinen Gegenstand führt. Der ausführende Lauf
erklärte diese Bedingung im Plan-Diff für erfüllt, indem er sie unter §1 Ausschluss 1 des
**eigenen** Plans ablegte („die Erweiterung bleibt innerhalb der von
[`MR-059`](../../../../../../../harness/conventions.md#mr-059) bereits erklärten Menge") — ein
Ausschluss, der nur die **Form**-Frage beantwortet, nicht die
**Zuständigkeits**-Frage, die zwei fremde, bereits geschriebene Planner-Dokumente längst anders
beantwortet hatten. Reviewer-Finding HIGH-1
(`docs/reviews/2026-09-22-slice-lifecycle-werkzeuge-tragen-die-kennung.md`), Architect-Verdikt (a)
DoD (3) zurücknehmen, Implementer-Rücknahme `c360a2cd`, Planner-Neuschnitt `3f811f66`.
