**Stand:** offen

Ein Wächter besteht seit `slice-126`, und er deckt eine benannte Teilmenge: Der PreToolUse-Zusatz
[`.claude/hooks/pretooluse-commit-msg-guard.sh`](../../../../../../.claude/hooks/pretooluse-commit-msg-guard.sh)
spiegelt einen `git commit`-Aufruf mit Message-Datei (`-F`/`--file`/`--file=`) vor der Ausführung
nach `make commit-msg-check` und blockt bei Exit ≠ 0. Außerhalb seiner Reichweite liegen strukturell
die Commits, die aus einem Repo-Werkzeug heraus entstehen (`slice-mv`, `archive-welle`), und
praktisch die `-m`-Form; das Modul `commits` steht weiterhin nicht in `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml), und `--range` ist am gepinnten Stand unbedienbar.
Die Reichweite selbst hängt zusätzlich an einer Konvention ohne durchgängigen Träger
([`waechter-abdeckung-haengt-an-uninstruierter-konvention`](../waechter-abdeckung-haengt-an-uninstruierter-konvention/observation.md));
`slice-215` trägt die Träger-Frage. Die zweite offene Hälfte des Eintrags — die Bezugseinheit
*jeder Commit* gegen *die Änderung als ganze* — ist unberührt und liegt bei `slice-121`.
