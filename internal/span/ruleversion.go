package span

// CurrentRuleVersion ist die Fassung der Erfassungsregel, unter der dieser Traeger seine
// Zeilen schreibt: Pflichtfeld `rule_version` (SPEC-088 in spec/spezifikation.md §5).
// Sie steigt um eins, sobald ein vorhandenes Feld bei gleicher Payload einen anderen Wert
// traegt oder anders anwesend ist (SPEC-089); die Fassungen stehen dort als Tabelle, und
// diese Zahl ist deren letzte Zeile.
// Bewacht von TestCurrentRuleVersionIsTheLastSpecFassung (Kopplung an die Tabelle) und
// TestSpanCarriesCurrentRuleVersion (die Zeile traegt sie).
const CurrentRuleVersion = 4
