package emit

// export_test.go macht die vier Weichen, ueber die der Waechter aus
// ADR-0057 Festlegung 1 laeuft, aus dem externen Testpaket (emit_test)
// erreichbar — eine reine _test.go-Datei fliesst nie in ein
// Produktions-Binary. Jede Funktion ruft ihr unexportiertes Original ohne
// Umweg auf: kein Nachbau der Emit-Disposition, eine reine Sichtbarkeits-
// Bruecke.

// IsRecurring exportiert isRecurring fuers externe Testpaket.
func IsRecurring(base string) bool { return isRecurring(base) }

// IsDerivativeIndex exportiert isDerivativeIndex fuers externe Testpaket.
func IsDerivativeIndex(rel string) bool { return isDerivativeIndex(rel) }

// IsBrownfieldOnly exportiert isBrownfieldOnly fuers externe Testpaket.
func IsBrownfieldOnly(rel string) bool { return isBrownfieldOnly(rel) }

// InScope exportiert inScope fuers externe Testpaket.
func InScope(rel string) bool { return inScope(rel) }
