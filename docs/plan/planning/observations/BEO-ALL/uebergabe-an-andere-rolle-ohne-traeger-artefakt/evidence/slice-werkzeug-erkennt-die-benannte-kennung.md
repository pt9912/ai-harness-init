**Vorgang:** slice-werkzeug-erkennt-die-benannte-kennung
**Fund:** Drei Übergaben an andere Rollen sind ausgesprochen, keine hat ein angelegtes
Träger-Artefakt. An den **Architect**: Die Grenzen-Formulierung in
[`MR-057`](../../../../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
sagt, `make slice-mv` finde die Verweise auf einen benannten Slice nicht; gemessen trifft das die
**ausgehende** Richtung und den Stub, während die eingehende Ersetzung und die Quellen-Auflösung
am Verzeichnis-Literal ankern und ohne Ziffer arbeiten — eine abwesende Fähigkeit, die es gibt.
An die Eigentümer zweier Träger: `Makefile:340` und `harness/tools/slice-mv.sh:170` führen die
Notation `SLICE=<slice-NNN>` unverändert weiter, und Grenze 3 desselben Skriptkopfs nennt
`BEO-003` — eine Register-Kennungsform, die die Ablage nicht mehr führt. Der einzige Träger bleibt
je die Closure-Notiz dieses Vorgangs, die mit dem `git mv` Chronik wird; einen Folge-Slice
schneidet die Closure nicht.
