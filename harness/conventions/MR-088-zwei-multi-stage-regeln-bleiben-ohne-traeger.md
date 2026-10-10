# MR-088 — Zwei Multi-Stage-Regeln aus Modul 14 bleiben unentschieden und ohne Träger

- **Datum:** 2026-10-08
- **Wirksamkeits-Anlass:** welle-adopter-weg-im-ziel — Trigger-Audit der Welle-Closure; der in
  [`MR-048`](../conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag)
  genannte Träger `slice-146` ist ohne Lieferung entfallen (Auftraggeber-Entscheidung vom 2026-10-08).
- **Geltungsbereich:** der Halbsatz *„die [slice-146] hält … — die bleiben dort offen"* im Feld
  Geltungsbereich von `MR-048`, und die zwei Regeln, die er meint:
  [`modul-14-docker-harness.md`](../../.harness/baseline/v6.18.0/regelwerk/modul-14-docker-harness.md#multi-stage-build-die-operativen-disziplinen-modul-14)
  §Multi-Stage-Build, *Stages trennen … `runtime`* und *Image-Hash im Build-Output festhalten*.
  **Nicht** die übrigen Aussagen von `MR-048`; **nicht** die emittierte Ebene.
- **Ersetzt-Baseline-Regel:** keine — der Eintrag tritt an keine der zwei Regeln, er nennt ihren
  Stand; nach dem Wortlaut der Eintrags-Vorlage damit kein Fork.
- **Adaption.** Beide Regeln sind in diesem Repo **weder adoptiert noch als Abweichung
  deklariert**, und kein Slice trägt sie. Ob `Dockerfile` und `Makefile` sie erfüllen, behauptet
  kein Artefakt dieses Repos; wer sich auf eine davon beruft, misst zuerst.
- **Grenze.** Kein Sensor hält eine der zwei Regeln; der Eintrag ist eine benannte Lücke, kein
  Wächter.
- **Begründung.** `MR-048` verweist für beide Regeln auf einen Träger, der nichts mehr hält; der
  Rumpf eines angenommenen Eintrags bleibt wörtlich, darum ein kurzer Eintrag mit Kopf-Marke am
  Vorgänger nach
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger).
  Ein Ausgang je Regel wäre die Arbeit des entfallenen Slice; der Auftraggeber hat sie nicht
  beauftragt.
- **Auflösungs-Trigger:** ein Slice entscheidet eine der zwei Regeln (Adoption oder deklarierte
  Abweichung), **oder** dieses Repo führt ein Replay-Manifest nach
  [`modul-12-replay-evaluierung.md`](../../.harness/baseline/v6.18.0/regelwerk/modul-12-replay-evaluierung.md)
  — dann braucht dessen `image_hash`-Slot die zweite Regel, und die Lücke ist nicht mehr harmlos.
