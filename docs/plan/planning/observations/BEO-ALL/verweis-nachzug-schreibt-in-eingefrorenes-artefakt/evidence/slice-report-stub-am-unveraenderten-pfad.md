**Vorgang:** slice-report-stub-am-unveraenderten-pfad
**Fund:** Kein Treffer der Klasse und ein Fortgang der verkörperten Form: der
Lauf schreibt keine Adresse um — kein Verweis-Nachzug, kein `ignore-refs`-Paar,
und die Report-Adressen stehen in keiner Bewegungsliste (je Review 2026-11-28,
Abschnitt *Kein Nachzug, kein Ventil*: `Bewegte()` enthält Reports nie, Alt und
Neu geprüft). Der schreibende Archiv-Lauf hinterlässt je Review seinen Stub am
**unveränderten Pfad** `docs/reviews/<datei>.md` ([ADR-0061](../../../../../docs/plan/adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md) Festlegung 1) —
die 399 Report-Verweis-Adressen des Bestands lösen unverändert auf, und die
`[haenger]`-Verweis-Sperre trägt keinen Report-Ziel-Fall mehr:

```sh
.harness/state/bin/ai-harness-init archive-welle --vorschau altbestand
# -> Sperren: keine — der schreibende Lauf liefe.
#    Review-Reports (mit Stub): 399
```

Gekoppelt: das **weiter offen**-Risiko aus §6 des Slice-Plans — die drei
Gegenformen an Report-Stubs (Zustandssatz neben der Adresse, Operand in einem
Mess-Kommando, Abschnitts-Anker auf den gekürzten Stub) bleiben je
[ADR-0061](../../../../../docs/plan/adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md) Festlegung 4 benannt, nicht geschlossen; die Grenze der
Verkörperung trägt die `state.md` dieses Eintrags. Kein neuer Folge-Slice:
Re-Evaluierungs-Trigger 1 der ADR greift erst beim realen Anker-Fall.
