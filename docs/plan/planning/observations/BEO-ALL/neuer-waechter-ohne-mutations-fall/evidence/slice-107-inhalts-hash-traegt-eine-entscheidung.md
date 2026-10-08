**Vorgang:** slice-107-inhalts-hash-traegt-eine-entscheidung
**Fund:** [`ADR-0087`](../../../../../adr/0087-fingerabdruck-gilt-auch-fuer-das-emittierte.md) bindet `TestWriteToolGetsFingerprintFromFilesystem` als Fitness Function für die `Sha256Prefix`-Zeile in `internal/span/emit.go` — rot gesehen in der Verifikation, aber kein Fall in `test/mutations/` hält die Haltbarkeit.
