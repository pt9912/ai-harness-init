**Vorgang:** slice-kotlin-hexslice-mit-arch-gate
**Fund:** Review INFO-3: das Muster `importRe` (`^import (app\.[A-Za-z.]+)$`) in `internal/gen/kotlin_test.go` überspringt `import app.x.Y as Z` und `import app.x.*` stumm; ein so geschriebener Import fiele aus der Prüfung „jeder Import hat seine Kante". Am heutigen Skelett folgenlos, die Grenze ist im Test nicht benannt.
