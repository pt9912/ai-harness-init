**Vorgang:** slice-kotlin-root-bootstrap
**Fund:** Die Fälle 626 und 627 nannten `TestRun_BootstrapKotlinRoot`; mit `t.Skip` allein in diesem Test blieben beide rot — 626 färbt `TestKotlinCodeGateFragment_RootUndSubdir`, 627 vier `TestArchGateConfig_*`-Tests, die dieselbe Stelle in `internal/gen/` schon allein binden (Review LOW-1). Die Fälle nennen jetzt den direkt lesenden Test (`a96c30e0`).
