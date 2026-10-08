# MR-086 — Das Modul reviews bleibt als dritte Position aus dem emittierten Doc-Gate

> **ÜBERHOLT: der Vergleich *„in derselben Form wie `codepaths`"* im Feld Adaption → [`MR-087`](../conventions.md#mr-087--das-modul-codepaths-verlässt-die-ausbleibenden-positionen-des-emittierten-doc-gates).** Die Form des Kommentar-Blocks bindet fort; `codepaths` ist keine ausbleibende Position mehr.

- **Datum:** 2026-10-08
- **Wirksamkeits-Anlass:** slice-emittierte-gate-vorlage-traegt-targets-und-reviews.
- **Geltungsbereich:** die Positions-Aufzählung in Setzung 3 von
  [`MR-054`](../conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  (*„zwei Positionen bleiben aus"*) und der Kommentar-Block `reviews` in
  `internal/emit/templates/d-check.yml`. **Nicht** die drei Kriterien, nicht die Form des Blocks
  und nicht die `.d-check.yml` dieses Repos.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  aus demselben Grund wie
  [`MR-054`](../conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel):
  die Ebene ist die Emission.
- **Adaption.** Setzung 3 von `MR-054` führt eine **dritte** Position: das Modul `reviews` bleibt
  aus, als begründeter Kommentar-Block mit eigenem Trigger, in derselben Form wie `codepaths` und
  das Requirement-Muster von `ids`. Gemessen scheitert es an zwei der drei Kriterien aus Setzung 1:
  Kriterium 1 — der Dogfood fährt es nicht (`grep -m1 '^modules:' .d-check.yml` nennt kein
  `reviews`); Kriterium 2 — aktiv geschaltet startet ein frisches Ziel rot, weil das gepinnte
  d-check eine leere Prüfmenge fail-closed als `review-missing` meldet (Review-Report des
  Wirksamkeits-Anlasses, Sonde B, Pin v0.84.0).
- **Grenze.** Kein Sensor hält die Positions-Liste gegen die emittierte Datei; der Go-Test
  `TestDCheckConfig_ReviewsBleibtKommentarBlock` hält allein, dass der Block auskommentiert bleibt.
  Der Trigger **im** Kommentar-Block ist die Bedingung für den Adopter, das Modul in seinem Repo
  einzuschalten; der Auflösungs-Trigger unten ist die Bedingung für das Werkzeug, es zu emittieren.
- **Begründung.** Eine Position, die `MR-054` nicht nennt, stünde in der emittierten Datei ohne
  Träger, und der Eintrag schließt das ausdrücklich aus (*„für die Positionen aus Setzung 3 und
  für keine weitere"*). Ein Satz in einem neuen Eintrag ist der kleinste Träger; eine ADR wäre
  für eine Aufzählung in einem Konventions-Eintrag die falsche Ebene.
- **Auflösungs-Trigger:** das gepinnte d-check startet ein frisch gebootstrapptes Ziel mit
  aktivem `reviews` grün **und** erkennt die Review-Zeile der emittierten Slice-Vorlage als
  Zusage, gleich in welcher Kennungs-Form. Dann entscheiden die drei Kriterien aus Setzung 1 von
  `MR-054` über die Aktivierung, Kriterium 1 eingeschlossen.
