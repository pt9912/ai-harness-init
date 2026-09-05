# Gate-Fläche hängt am Arbeitsbaum

**Sub-Area:** `*` (gesamtes Repo)

Ein repo-weiter Gate urteilt über die Dateien, die im Arbeitsbaum **liegen**, statt über eine
deklarierte Fläche: ein unversioniertes Verzeichnis darin färbt denselben Commit rot, ohne dass
sich ein Byte des Repos geändert hat. `.gitignore` verkleinert die Fläche nicht — weder für den
gepinnten `d-check` hinter `make docs-check` noch für das `find` in
[`harness/tools/comment-claims.sh`](../../../../../../harness/tools/comment-claims.sh); beide lesen
das Dateisystem, nicht den Index.
