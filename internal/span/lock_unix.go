//go:build !windows

package span

import (
	"os"
	"syscall"
)

// tryLockExclusive hält die Datei-Sperre auf POSIX-Systemen: Flock mit LOCK_EX und
// LOCK_NB, EIN Versuch. Die begrenzte Wiederholung (lockTries, lockWait) und die
// fail-open-Folge stehen beim Aufrufer in emit.go — die Plattform-Datei trägt nur
// den einen Syscall.
func tryLockExclusive(f *os.File) error {
	return syscall.Flock(int(f.Fd()), syscall.LOCK_EX|syscall.LOCK_NB)
}

// removeStaleDir entfernt das Altlast-Verzeichnis an der Ablage. Rmdir und NICHT
// os.Remove: letzteres unlinkt auch DATEIEN. Treffen zwei Emitter dasselbe
// Altlast-Verzeichnis, könnte der zweite die frische, bereits geflockte
// Lock-DATEI des ersten löschen — zwei Inodes, dieselbe Folgenummer, also wieder
// die Doppelvergabe, die das Schloss verhindern soll. Rmdir scheitert an einer
// Datei und kann diesen Weg nicht gehen.
func removeStaleDir(path string) error {
	return syscall.Rmdir(path)
}