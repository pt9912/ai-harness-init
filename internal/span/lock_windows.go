//go:build windows

// lock_windows.go — die zwei Stellen der Sperre aus emit.go, auf Windows getragen:
// LockFileEx über kernel32 statt POSIX-Flock, RemoveDirectory statt POSIX-Rmdir.
// Beide sind EIN Versuch; die begrenzte Wiederholung und die fail-open-Folge stehen
// beim Aufrufer in emit.go.

package span

import (
	"os"
	"syscall"
	"unsafe"
)

// Die zwei LockFileEx-Flags: nicht blockierend und exklusiv — dieselbe Semantik
// wie LOCK_EX|LOCK_NB auf POSIX. syscall (stdlib) führt die Konstanten nicht;
// LockFileEx selbst liegt ebenfalls nicht in syscall, darum der lazy Proc.
const (
	lockfileFailImmediately = 0x00000001
	lockfileExclusiveLock   = 0x00000002
)

var procLockFileEx = syscall.NewLazyDLL("kernel32.dll").NewProc("LockFileEx")

// tryLockExclusive hält die Datei-Sperre auf Windows: eine Byte-Sperre über Offset
// 0 der Lock-Datei. Der zweite Emitter bekommt den Lock-Violation-Fehler und
// verliert seinen Versuch, nicht seinen Lauf.
func tryLockExclusive(f *os.File) error {
	ol := new(syscall.Overlapped)
	r1, _, callErr := procLockFileEx.Call(
		uintptr(syscall.Handle(f.Fd())),
		uintptr(lockfileFailImmediately|lockfileExclusiveLock),
		0, // reserved
		1, // bytesLow — die Sperre liegt über einem Byte bei Offset 0
		0, // bytesHigh
		uintptr(unsafe.Pointer(ol)),
	)
	// Call liefert den letzten Fehler stets ungleich nil; ein Erfolg erkennt sich
	// am Rückgabewert, nicht am Fehler.
	if r1 == 0 {
		return callErr
	}
	return nil
}

// removeStaleDir entfernt das Altlast-Verzeichnis an der Ablage. RemoveDirectory
// nimmt nur Verzeichnisse — dieselbe Grenze, die POSIX-Rmdir in lock_unix.go
// trägt: eine DATEI an der Stelle wird nicht angetastet.
func removeStaleDir(path string) error {
	p, err := syscall.UTF16PtrFromString(path)
	if err != nil {
		return err
	}
	return syscall.RemoveDirectory(p)
}