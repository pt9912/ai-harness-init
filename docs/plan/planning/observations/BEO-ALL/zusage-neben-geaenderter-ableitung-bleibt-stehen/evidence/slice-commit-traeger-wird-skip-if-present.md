**Vorgang:** slice-commit-traeger-wird-skip-if-present
**Fund:** [`harness/README.md`](../../../../../../../harness/README.md) §Traceability trug die
Lieferung des Trägers **unbedingt**: *„Er reist als `.githooks/commit-msg` mit dem Klon, seine Prüfung
als `tools/harness/commit-msg-traceability.sh` daneben, und der Hook ruft die Prüfung über sein
eigenes Verzeichnis auf"* — ohne die Bedingung, die derselbe Absatz zwei Sätze später und die
Entscheidung §Konsequenzen setzen (*„in einem Ziel mit belegtem Pfad kommt der Träger nicht an"*).
Gelesen als Zusage an den Überflieger sagte sie, der Werkzeug-Träger liege im Ziel und rufe die
Prüfung — was im neu geschaffenen belegten Fall gerade nicht gilt.

```sh
git show d7fd8227^:harness/README.md | grep -n 'Er reist als'                                 # :156
sed -n '/^## Traceability/,/^## /p' harness/README.md | grep -n 'nur an einem freien Pfad'    # :69
```

Der Vorgang faßte den Absatz an **und** schuf den Fall, in dem die unbedingte Lesart falsch wird
([`ADR-0054`](../../../../../../../docs/plan/adr/0054-emittierter-commit-traeger-skip-if-present.md)
Folgepflicht 1 nennt ihn namentlich); gezogen hat ihn die Review-Runde, kein Gate — kein Modul liest
diese Prosa. Sie steht jetzt bedingt: *„den Träger `.githooks/commit-msg` legt der Lauf daneben nur an
einem freien Pfad ab"*.
