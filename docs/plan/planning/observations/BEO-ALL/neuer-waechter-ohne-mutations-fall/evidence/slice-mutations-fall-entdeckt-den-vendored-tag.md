**Vorgang:** slice-mutations-fall-entdeckt-den-vendored-tag
**Fund:** Die neue Schranke *„genau ein Treffer"* in `resolve_file_spec` hat zwei Richtungen, und
nur die **obere** trägt einen Mutations-Fall: `test/mutations/324-mutate-files-schranke-erlaubt-mehrfachtreffer.sh`
entschärft `-eq 1` zu `-ge 1` und färbt seinen bats-Wächter rot. Die **Null-Treffer**-Richtung —
genau die, deren Fehlen den roten CI-Lauf ausgelöst und diesen Slice veranlasst hat — ist nur
bats-getestet und nicht mutations-bewacht; gemessen im Review: unter derselben Mutation bleibt der
Test *„OHNE Treffer"* grün. Der Rest ist offen, nicht benannt: Weder `harness/sensors/mutate.md`
§Grenze noch der Treiber-Kopf sagt, dass diese Richtung unbewacht ist. Ein zweiter Fall, der die
Null-Richtung entschärft, schlösse die Lücke.
