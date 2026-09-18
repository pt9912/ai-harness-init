**Vorgang:** slice-spec-straten-zeigen-nicht-nach-aussen

**Fund:** Der Vorgang legt an drei Trägern frische Zusicherungen an — fünf Fälle in
`test/mutations/` (`372`–`376`) über vier Zusicherungen in `internal/emit/emit_test.go`, zwei Zähne
in `harness/tools/full-smoke.sh` und die neue `matrix`-Regel. Die Klasse ist in **drei** Review-Läufen
dieses Vorgangs unter demselben Namen geführt worden:

- **F-2 (Runde 2):** eine Zusicherung des Paares *Vorhandensein/Position* war von keinem gelisteten
  Fall gebunden.
- **R3-1 (Runde 3, MEDIUM):** dieselbe Lage an der Positions-Zusicherung. Der Mutant, der sie
  bricht, färbte zusätzlich die Vorhandenseins-Meldung — der Fall trug ihren **Text**, nicht ihre
  **Zähne**.
- **R4-1 (Runde 4, LOW):** der symmetrische Rest an der Vorhandenseins-Zusicherung. Ihre
  Regel-Klausel steht in gar keinem Fall — gemessen: ein Mutant, der **nur** die Regel-Zeile
  entfernt, färbt allein `emit_test.go:73`, und `grep -l 'to: aussen' test/mutations/*.sh` nennt
  keine Datei.

In den Runden 1 bis 3 ist je ein Fall ergänzt worden, der die gebrochene Zusicherung bindet; die
zugehörige Gegenprobe ist mitgewachsen: mit **intaktem** Muster fällt der benannte Fall, mit
**geweitetem** Muster entkommt er. Der unveränderte Bestand bleibt still.

**Wirkung und Grenze.** Kein gelisteter Mutant entkommt; der Rest ist einer an der **Diagnose** und
an der **Unit-Ebene**, nicht an der gelieferten Eigenschaft — die bleibt hinter dem Test durch den
`matrix-aussen`-Zahn des `full-smoke` gedeckt, den die CI am realen Ziel fährt. Der Review hat den
Rest als nicht blockierend geführt. Benannt, nicht geschlossen.

**Geschärfte Kategorie (Vorschlag des Reviews, nicht beschlossen):** *ein gelisteter Fall muss seine
Zusicherung binden; nimmt man ihr den Zahn, muss er grün werden.* Ihr Zielort liegt außerhalb dieses
Vorgangs — `AGENTS.md` §3.6 gehört dem Architect
([`AGENTS.md`](../../../../../../../AGENTS.md) §3.8), eine Zeile in `.harness/skills/reviewer.md` der
Rolle, die sie ausführt. Der Beleg gehört hierher, die Regel dorthin.
