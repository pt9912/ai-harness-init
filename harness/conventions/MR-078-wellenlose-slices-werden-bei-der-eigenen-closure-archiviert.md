# MR-078 — Wellenlose Slices werden bei der eigenen Closure archiviert

- **Datum:** 2026-10-05
- **Wirksamkeits-Anlass:** [`ADR-0077`](../../docs/plan/adr/0077-wellenlose-slices-archivieren-bei-der-slice-closure.md)
  Festlegung 4 (die Abweichung besteht; der Eintrag folgt nach `Accepted`).
- **Geltungsbereich:** der Archivierungs-Weg wellenloser Slices in diesem Repo **und** im
  emittierten Ziel (Festlegung 1 der ADR gilt für beide). **Nicht** die Wellen-Archivierung der
  Mitglieder einer Welle und **nicht** der Altbestand — für ihn gilt
  [`ADR-0041`](../../docs/plan/adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)
  unverändert.
- **Ersetzt-Baseline-Regel:**
  [`modul-06-roadmap.md`](../../.harness/baseline/v6.16.0/regelwerk/modul-06-roadmap.md#wann-arbeit-eine-welle-braucht-modul-6)
  §Wann Arbeit eine Welle braucht, Tabelle *Träger im Repo ohne Wellen*, Zeile *Zeitdokumente
  archivieren* (Träger: Slice-Closure), samt Schritt 4 der Wellen-Closure-Prozedur (die Welle
  sammelt die wellenlos Geschlossenen ein); und
  [`modul-05-planning-harness.md`](../../.harness/baseline/v6.16.0/regelwerk/modul-05-planning-harness.md#lifecycle-als-state-machine)
  §Lifecycle als State Machine, der Absatz, der `done/slice-<Kennung>-archiv.zip` als Ablage
  nennt.
- **Adaption:** Die Baseline weist die Slice-Archivierung der Slice-Closure des Repos **ohne**
  Wellen zu; ein Repo mit Wellen sammelt die wellenlosen Slices in der Wellen-Closure ein. Dieses
  Repo und das emittierte Ziel fahren Wellen und archivieren einen wellenlosen Slice **zusätzlich**
  bei dessen eigener Closure, als `done/slice-<Kennung>-archiv.zip` neben dem gekürzten Stub, über
  das Unterkommando `archive-slice` (Träger und Folge-Arbeiten: Festlegung 3 der ADR). Die
  Wellen-Closure nimmt einen Slice mit eigenem Archiv aus ihrer Einsammel-Menge aus. Sperrt die
  Verweis-Vorprüfung, bleibt der Slice flach und die Wellen-Closure sammelt ihn wie in der
  Baseline ein (Rückfall, Festlegung 1).
- **Begründung:** Der flache Bestand wächst sonst bis zur nächsten Wellen-Closure; Schlüssel ist
  der Slice selbst, eine Zuordnung zu einer Welle entfällt. Die Abwägung gegen die Alternativen
  steht in der ADR, nicht hier.
- **Auflösungs-Trigger:** die Re-Evaluierungs-Trigger der
  [`ADR-0077`](../../docs/plan/adr/0077-wellenlose-slices-archivieren-bei-der-slice-closure.md)
  — insbesondere: dieses Repo fährt keine Wellen mehr (dann gilt die Baseline-Form unmittelbar
  und der Eintrag entfällt), oder die Baseline ändert die genannte Tabelle bzw. Schritt 4.
- **Grenze:** Der Eintrag beschreibt die Abweichung, nicht den Träger: solange das Unterkommando
  nicht gebaut ist, übt niemand den Weg aus. Ob ein wellenloser Slice ein eigenes Archiv hat und
  die Wellen-Closure ihn auslässt, hält heute kein Sensor
  ([`ADR-0077`](../../docs/plan/adr/0077-wellenlose-slices-archivieren-bei-der-slice-closure.md)
  §Fitness Function benennt die Lücke und das Rot, das der Folge-Slice herstellt).
