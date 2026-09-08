**Vorgang:** slice-200
**Fund:** Vier Stellen — `cmd/ai-harness-init/vendor_baseline.go`, `cmd/ai-harness-init/main.go`,
`Makefile` und [`harness/README.md`](../../../../../../../harness/README.md) — sagten *„ein
vorhandenes `<tag>`-Verzeichnis wird ersetzt, kein zweites legt sich daneben"*. Der Code darunter
hielt den Geltungsbereich nur über **demselben** Tag: `internal/fetch.Baseline` bildet sein Ziel
als `filepath.Join(destDir, tag)`, und ein Lauf über einem abweichenden Tag legte das zweite
Verzeichnis daneben und färbte `make baseline-verify` rot — genau der Tag-Bump-Fall, für den der
Slice den Träger begründet. Gefunden vom Review, am Produkt-Binär nachgefahren; behoben durch eine
Sperre vor dem einzigen Netz-Aufrufpunkt, nicht durch eine Verengung der Zusage.
