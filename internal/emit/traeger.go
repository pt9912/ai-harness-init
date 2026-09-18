package emit

// TraegerMkPath ist der Zielort des Fragments des Traeger-Fetch: das
// Gate-Fragment-Verzeichnis des Ziels (ADR-0058 Festlegung 3, Muster MR-010). Das
// Praefix ist die Adresse, unter der der Root-Aggregator die Fragmente per Glob
// einbindet; nur dort fahren die `make`-Laeufe des Adopters es.
const TraegerMkPath = "harness/mk/traeger.mk"

// traegerMkSrc ist der eingebettete Quellpfad des Fragments (enforceFS).
const traegerMkSrc = "templates/enforce/traeger.mk"

// traegerMkFile bildet das Fragment auf seinen Ziel-Relpfad ab — KONVERGENT wie die
// uebrige tool-eigene Infrastruktur (ADR-0007 Festlegung 3), UNBEDINGT wie das
// Fragment der Wellen-Archivierung: es behauptet nichts ueber einen Lauf. Gerade der
// frische Klon OHNE Traeger ist sein Fall — haette es den Zweig des Traegers geteilt,
// waere der Fetch genau dort nicht erreichbar, wo er die Grenze aus ADR-0022
// Festlegung 5(b) mit einem Kommando ueberwindbar machen soll (ADR-0058 Festlegung 5).
func traegerMkFile() enforceFile {
	return enforceFile{src: traegerMkSrc, dst: TraegerMkPath, mode: 0o644, class: Konvergent}
}

// TraegerFetchShPath ist der Ort des Transport-Skripts im emittierten Layout
// tools/harness/ (LH-FA-06, MR-005); das Fragment ruft genau diesen Pfad, und der
// Dogfood-Zwilling liegt byte-gleich daneben — die Kopplung haelt test/traeger-fetch.bats.
const TraegerFetchShPath = "tools/harness/traeger-fetch.sh"

// traegerFetchShSrc ist der eingebettete Quellpfad des Skripts (enforceFS).
const traegerFetchShSrc = "templates/enforce/traeger-fetch.sh"

// traegerFetchShFile bildet das Skript auf seinen Ziel-Relpfad ab — KONVERGENT,
// 0755 wie jedes ausfuehrbare Werkzeug (carrierMode-Klasse): ein Traeger-Fetch, der
// nicht starten kann, ist keiner.
func traegerFetchShFile() enforceFile {
	return enforceFile{src: traegerFetchShSrc, dst: TraegerFetchShPath, mode: 0o755, class: Konvergent}
}