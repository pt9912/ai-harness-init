**Stand:** gestrichen

Die Beobachtung kann nicht mehr unbemerkt auftreten: `test/neutralisierung-marker.bats` hält jeden
Wortlaut-Marker aus `WortlautNeutralisierungen()` (`internal/emit/templates.go`) gegen seine Vorlage
im vendored Baum zu `DefaultTag` und seine erwartete Trefferzahl, gebunden durch den Mutations-Fall
561 (`slice-neutralisierung-haelt-ihren-wortlaut-am-gepinnten-stand`). `NeutralizeRoadmap` bleibt
entgegen `observation.md` bestehen — mit Erwartung 0 am Pin, weil ein älterer `COURSE_TAG` ihren
Marker trägt; ihr Test hält eine Fixture, die byte-gleich zur Vorlage an `v6.5.0` ist.
