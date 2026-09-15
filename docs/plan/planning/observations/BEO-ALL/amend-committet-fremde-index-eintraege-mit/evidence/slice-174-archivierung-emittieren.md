**Vorgang:** slice-174-archivierung-emittieren
**Fund:** Die Verifikation dieses Slice hat ihren Commit mit `git commit --amend` korrigiert,
während im Index die zwei Dateien des Planner-Commits `8ba83822` lagen, der **parallel** entstanden
war — der fremde Commit wurde mitgerissen. Der Lauf hat das selbst offengelegt und aus dem
Reflog-Objekt repariert: `git reset --soft 8ba83822`, danach den eigenen Bericht als neuer Commit
(zwei Dateien, 13/1, geprüft). Der fremde Commit steht unverändert in der Historie, der Baum ist
sauber. Am Reflog nachfahrbar:

```sh
git reflog -4    # commit → commit (amend) → reset: moving to 8ba83822 → commit
```
