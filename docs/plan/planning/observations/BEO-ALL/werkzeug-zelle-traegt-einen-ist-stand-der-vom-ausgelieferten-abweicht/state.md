**Stand:** offen

Der `traeger-fetch`-Fall ist behoben: [`harness/sensors/traeger-fetch.md`](../../../../../../harness/sensors/traeger-fetch.md)
nennt den Tag über `TRAEGER_TAG` im `Makefile` statt als Zahl. Der `artifact-host`-Fall steht:
[`harness/sensors/artifact-host.md`](../../../../../../harness/sensors/artifact-host.md) nennt
`slice-048` (`grep -n 'slice-048' harness/sensors/artifact-host.md`). Kein Sensor liest den Wortlaut
einer Zelle gegen den Stand; die Klasse kann weiter auftreten.
