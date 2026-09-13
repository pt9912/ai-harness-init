**Vorgang:** slice-werkzeug-erkennt-die-benannte-kennung
**Fund:** Die erste Review-Runde meldete die Notations-Aussage `SLICE=slice-NNN` an **drei**
Fundorten; die Behebung zog genau diese drei. Die zweite Runde fand dieselbe Aussage in einem
vierten Träger (`Makefile:340`, die `make help`-Zeile) und an einem der ersten drei unverändert
(`harness/tools/slice-mv.sh:170`, *„ohne Ziffern-Praefix"* neben einem Fundmuster, das auf
`slice-[0-9a-z]` bindet). Fundorte als Fundmenge gelesen, ohne die Ausdehnung der Aussage zu
messen — die Schleife verlängert sich um eine Runde, und das Reststück geht als Übergabe weiter,
statt geschlossen zu sein.
