**Vorgang:** 2026-09-15-adr-0051-konsistenz-review
**Fund:** Die Konsistenz-Runde hat einen ihrer Commits mit `git commit --amend` korrigiert, während
im Index die Dateien des Implementer-Commits `db309c8c` lagen, der **parallel** entstanden war —
der fremde Commit wurde mitgerissen. Die Runde hat das selbst offengelegt und repariert: `git reset
--soft db309c8c`, danach die eigenen zwei Dateien pfadrein committet (Hash, Message, Inhalt
geprüft). Der fremde Commit steht unverändert in der Historie, der Baum ist sauber. Der Vorgang ist
am Reflog nachfahrbar — die Sequenz `commit` → `commit (amend)` → `reset: moving to db309c8c` steht
dort über dem Amend:

```sh
git reflog -15 | grep -F 'Rolle Reviewer: ADR-0051'
```
