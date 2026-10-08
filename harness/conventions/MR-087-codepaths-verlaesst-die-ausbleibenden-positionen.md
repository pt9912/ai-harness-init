# MR-087 — Das Modul codepaths verlässt die ausbleibenden Positionen des emittierten Doc-Gates

- **Datum:** 2026-10-08
- **Wirksamkeits-Anlass:** slice-211-codepaths-im-emittierten-doc-gate.
- **Geltungsbereich:** die Position `codepaths` in Setzung 3 von
  [`MR-054`](../conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  und der Vergleich *„in derselben Form wie `codepaths`"* im Feld Adaption von
  [`MR-086`](../conventions.md#mr-086--das-modul-reviews-bleibt-als-dritte-position-aus-dem-emittierten-doc-gate).
  **Nicht** die drei Kriterien aus Setzung 1, nicht die Positionen **innerhalb** des Blocks
  `codepaths` (die Ziel-Form der Startkonfiguration ist dafür die Autorität, Geltungsbereich von
  `MR-054`) und nicht die `.d-check.yml` dieses Repos.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  aus demselben Grund wie `MR-054`: die Ebene ist die Emission.
- **Adaption.** `codepaths` ist keine ausbleibende Position mehr: das Modul steht in der
  `modules:`-Liste von `internal/emit/templates/d-check.yml`
  (`sed -n 's/^modules: \[\(.*\)\]$/\1/p' internal/emit/templates/d-check.yml`), entschieden nach
  den drei Kriterien aus Setzung 1, nachdem sein Auflösungs-Trigger eingetreten ist. Setzung 3 von
  `MR-054` führt damit **zwei** ausbleibende Positionen: das Requirement-Muster von `ids` und das
  Modul `reviews` (`MR-086`). Der Vergleich in `MR-086` nennt die **Form** eines begründeten
  Kommentar-Blocks mit eigenem Trigger; sie bindet fort, ihr verbleibendes Beispiel ist das
  Requirement-Muster von `ids`.
- **Grenze.** Kein Sensor hält die Positions-Liste dieses Blocks gegen die emittierte Datei. Dass
  `codepaths` im Ziel prüft, hält der Zahn *codepath-missing* in `harness/tools/full-smoke.sh`
  (`grep -n 'codepath-missing' harness/tools/full-smoke.sh`), nicht dieser Eintrag.
- **Begründung.** Die Kopf-Marke von `MR-054` führt den Trigger als eingetreten, der Rumpf führt
  die Position weiter als offen; ohne Träger für den Wegfall liest der nächste Lauf eine
  entschiedene Position als ausstehend. Ein kurzer Eintrag mit Kopf-Marken an beiden Vorgängern
  ist die Form aus
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger).
- **Auflösungs-Trigger:** `codepaths` verlässt die emittierte `modules:`-Liste wieder. Dann trägt
  der Eintrag, der das entscheidet, die Position neu.
