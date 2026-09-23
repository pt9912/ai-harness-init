**Vorgang:** slice-das-werkzeug-sagt-seine-fassung
**Fund:** [`ADR-0063`](../../../../../../docs/plan/adr/0063-das-werkzeug-sagt-seine-fassung.md)
Festlegung 1 ließ den ersten Wert ins Binary reisen (die Fassung, per `ldflags` am Tag-Bau); die
Nachbar-Zusage im Formel-Skelett (`internal/emit/templates/homebrew-formula.rb.tmpl` — *„kein
Wert reist im Binary"*) blieb unverändert stehen. Review-F-3
(`docs/reviews/2026-09-23-slice-das-werkzeug-sagt-seine-fassung.md`), Verifier V-1 — Ausgang:
Folge-Slice `slice-formel-skelett-nennt-die-fassungs-ausnahme` (der Skelett-Satz liegt außerhalb
der Abgrenzung des Fassungs-Slices, [`ADR-0063`](../../../../../../docs/plan/adr/0063-das-werkzeug-sagt-seine-fassung.md)
Festlegung 3).