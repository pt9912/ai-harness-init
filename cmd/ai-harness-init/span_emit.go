// Das Unterkommando `span-emit` schreibt EINEN Span je Tool-Call in den
// gitignorierten Zustands-Bereich. Es ist der Hook-Einstieg zu internal/span; die
// Policy steht in ADR-0011, die Mechanik dort, hier steht nur die KLEMME.
//
// ZWEI EIGENSCHAFTEN SIND NICHT VERHANDELBAR (ADR-0011 Festlegung 6), und beide sind
// hier konstruktiv hergestellt, nicht durch Sorgfalt:
//
//  1. Der Exit-Code ist auf 0 geklemmt. Das ist kein Formalismus: ein Hook, der mit
//     2 endet, BLOCKT den Tool-Call. Der Lauf, den die Telemetrie nur beobachten
//     soll, stuende dann still, weil ihr Beobachter stolperte.
//     Bewacht von test/mutations/107-span-klemme-entfernt.sh gegen die
//     Exit-Zusicherung in TestClampSurvivesBrokenPayload.
//  2. stdout bleibt LEER. Dort liegt bei Hooks der ENTSCHEIDUNGS-Kanal; wer dort
//     schreibt, entscheidet ueber Berechtigungen mit, statt zu beobachten.
//     Bewacht von test/mutations/112-span-stdout-geschwaetzig.sh gegen die
//     stdout-Zusicherung derselben Tests.
//
// DIE ZWEI HAENGEN AN VERSCHIEDENEN FAELLEN, und das ist der Punkt: Mutation 107
// laesst den Schreiber ueber den Panic-Pfad enden, und dessen Ausgabe geht auf STDERR.
// Die stdout-Zusicherung kann unter 107 also gar nicht feuern; sie braucht ihren
// eigenen Fall (ADR-0011 Folgepflicht 5 verlangt ihn ausdruecklich).
//
// DER TRAEGER IST DAS PRODUKT-BINAER (ADR-0022 Festlegung 2), und der Zweig steht als
// ERSTE Anweisung in main(): vor os.Getwd(), vor jeder Flag-Auswertung. Die Stelle ist
// tragend. Was davor liegt, deckt die Klemme nicht — der Getwd-Fehlerpfad des Init
// endet mit einer Zeile auf stderr und Exit 1, und an einem Hook waere das ein
// Beobachter, der ueber den Lauf mitentscheidet.
//
// Was `forbidigo` (make lint) beitraegt, ist WENIGER als die Eigenschaft: es verbietet
// die Form `fmt.Print*`, nicht das Schreiben nach stdout. `os.Stdout.Write`,
// `fmt.Fprintln(os.Stdout, …)` und das eingebaute `println` passieren es.
// Die Eigenschaft haengt an den zwei Faellen oben, nicht am Linter.

package main

import (
	"io"
	"os"
	"time"

	"github.com/pt9912/ai-harness-init/internal/span"
)

// maxPayload begrenzt, was von stdin gelesen wird. Eine Write-Payload traegt den
// Datei-INHALT, kann also gross sein; jenseits dieser Grenze kostet der Aufruf seinen
// Span (fail-open, benannt) statt den Speicher des Rechners.
const maxPayload = 64 << 20

// spanEmit ist der Einstieg des Unterkommandos. Er kehrt nie zurueck: der einzige
// Ausgang ist clamp().
//
// DIE KLEMME ist TRAGEND: emitSpan() laesst jeden Fehlschlag als panic hochkommen,
// statt ihn an Ort und Stelle zu schlucken. Erst dadurch hat die Klemme ueberhaupt
// etwas zu fangen — und erst dadurch ist sie MUTIERBAR. Wird die defer-Zeile
// entfernt, endet ein kaputtes JSON auf stdin mit Exit 2, dem Wert, mit dem ein Hook
// blockiert.
func spanEmit(stdin io.Reader) {
	defer clamp()
	emitSpan(stdin)
}

func clamp() {
	_ = recover()
	os.Exit(0)
}

// emitSpan ist der Weg von stdin in den Strom. Er gibt KEINEN Fehler zurueck: der
// einzige Ausgang fuer einen Fehlschlag ist die Klemme oben.
func emitSpan(stdin io.Reader) {
	wd, err := os.Getwd()
	mustEmit(err)
	root, ok := span.FindRoot(wd)
	if !ok {
		// Ohne Repo-Wurzel gibt es keinen Ablageort. Der Schreiber raet keinen.
		return
	}
	payload, err := io.ReadAll(io.LimitReader(stdin, maxPayload))
	mustEmit(err)
	if len(payload) == 0 {
		return
	}
	mustEmit(span.Emit(root, payload, time.Now()))
}

func mustEmit(err error) {
	if err != nil {
		panic(err)
	}
}
