**Stand:** offen

Die Lücke ist in [`harness/conventions.md`](../../../../../../harness/conventions.md)
§Adoptierte Konventions-Quellen benannt — *„Asset → vendored Baum hält nichts"* —, ein Sensor
dafür besteht nicht. Träger wäre ein `make`-Ziel, das den Baum aus dem gepinnten Asset erzeugt
statt ihn von Hand zu legen; `internal/fetch/baseline.go` kann es und wird heute nur im Init-Pfad
für Ziel-Repos gerufen. Geschnitten ist das als `slice-200`.
