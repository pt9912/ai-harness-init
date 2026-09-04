# MR-045 — Der Adaptions-Block läuft in der Verzeichnis-Form

- **Datum:** 2026-09-03
- **Wirksamkeits-Anlass:** slice-166 — der Umzug selbst; dieser Eintrag entsteht in derselben
  Änderung, die ihn wahr macht.
- **Geltungsbereich:** dieser Block — [`harness/conventions.md`](../conventions.md) als Index und
  das Verzeichnis [`conventions/`](../conventions/) daneben. **Nicht** `docs/plan/adr/`, wo
  [`AGENTS.md`](../../AGENTS.md) §3.4 unverändert gilt; **nicht** die emittierte Ebene.
- **Ersetzt-Baseline-Regel:**
  [`grundlagen-harness-dateien.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher)
  §harness/conventions.md als Konventionsspeicher — *„Einträge werden nie überschrieben"*.
  Dieselbe Zelle tragen [`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf),
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  und [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines);
  dies ist ein vierter Ausnahmefall zu derselben Regel, keine zweite Fassung von ihr. Die drei
  binden unverändert fort.
- **Die Form selbst ist keine Abweichung, und das ist gemessen.** Die Verzeichnis-Form ist der
  Baseline-**Default** (*„Der Default ist die Verzeichnis-Form, weil sie mit der Adaptions-Zahl
  nicht mitwächst"*), und der zweite Anker je Index-Zeile ist von derselben Quelle für genau
  diesen Umzug vorgesehen:
  `grep -c 'trägt die Index-Zeile den alten Überschriften-Slug \*\*zusätzlich\*\*' .harness/baseline/v5.18.0/regelwerk/grundlagen-harness-dateien.md`
  → **1**. Dieser Eintrag setzt darum nichts über die Form; er setzt, was der **Umzug** an
  angenommenen Rümpfen kosten darf.
- **Setzung 1 — zwei Klassen von Zeichenwechseln am angenommenen Rumpf sind keine inhaltliche
  Änderung.** Sie stellen die Adresse wieder her, die der Umzug bricht, und ändern kein Wort:
  - **(a) Pfad-Präfix.** Ein Rumpf liegt eine Verzeichnis-Ebene tiefer als vorher. Ein relatives
    Linkziel bekommt die Ebene, die ihm fehlt — aufwärts (`](../` → `](../../`), geschwisterlich
    (`](conventions.md` bzw. `](README.md` → `](../…`) und blockintern
    (`](#mr-<NNN>--…` → `](../conventions.md#mr-<NNN>--…`). Ziel und Linktext bleiben dieselben.
  - **(b) Verlinkte Kennung.** Eine `MR-`Kennung, die im Rumpf blank stand, wird zum Verweis auf
    ihre Index-Zeile. Der Linktext **ist** die Kennung; gelesen steht dasselbe da. Die Ziel-Form
    schreibt genau diese Gestalt vor — die Vorlage
    [`MR-NNN-titel.template.md`](../../.harness/baseline/v6.0.0/templates/harness/conventions/MR-NNN-titel.template.md)
    führt `Löst auf` als Link auf `../conventions.md#mr-<NNN>` —, und
    [`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
    verlangt sie ohnehin für jede Kennung außerhalb des Definitions-Orts. Blank standen sie
    allein, weil der Definitions-Ort sie deckte.
- **Setzung 2 — der Definitions-Ort folgt dem Rumpf, und das ist keine Senkung** · seit slice-166.
  Das Muster `MR-\d{3}` in [`.d-check.yml`](../../.d-check.yml) nennt als `target` das Verzeichnis
  `harness/conventions/` statt der Index-Datei. Der Prüfumfang wird dadurch nicht um Bestand
  gekürzt, den dieses Repo autoritativ schreibt — der Test, mit dem
  [`MR-029`](../conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
  Scoping von Senkung trennt: **jedes** Byte, das jetzt im Definitions-Ort liegt, lag vorher in
  der Index-Datei und damit ebenfalls darin. Umgekehrt tritt der Index **neu** unter die
  Link-Pflicht. Der geprüfte Bestand wächst also; er schrumpft nicht.
- **Setzung 3 — der Index ist derivativ und sagt es.** Die Tabelle trägt je Eintrag Kennung,
  Titel und den **Anfang** der Felder `Geltungsbereich` und `Ersetzt-Baseline-Regel`; bei
  Abweichung gilt die Eintrags-Datei
  ([`ADR-0024`](../../docs/plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)).
  Ein abgeschnittenes Feld trägt `…`, ein fehlendes `—`. Ohne diese Ansage läse sich eine
  Index-Zelle wie ein vollständiges Feld, und zwei Fassungen desselben Felds driften.
- **Begründung (gemessen, nicht postuliert).** Der Umzug ist mechanisch gefahren und in zwei
  Stufen umgekehrt worden: die Extraktion samt Pfad-Präfix reproduziert den Vorher-Stand
  byte-gleich, und nach Abzug jeder Kennungs-Link-Hülle sind Vor- und Endstand jeder der
  Eintrags-Dateien identisch. Beide Läufe stehen mit ihrem Kommando in §7 des Slice-Plans. Wäre
  Setzung 1 nicht gesetzt, hätte der Umzug nur zwei Auswege: jeden Verweis des Repos nachziehen
  oder die Rümpfe mit toten Adressen zurücklassen — der erste bricht an der Menge, der zweite an
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).
- **Kein Wächter für Setzung 1, und das gehört dazu.** Kein Modul aus `modules:` der
  [`.d-check.yml`](../../.d-check.yml) unterscheidet eine Adress-Korrektur von einer inhaltlichen
  Änderung (`grep -n '^modules:' .d-check.yml`); `links` und `anchors` prüfen, **dass** eine
  Adresse auflöst, nicht **warum** sie sich bewegt hat. Träger ist der Rollen-Wechsel vor der
  Änderung. Für Setzung 2 dagegen ist der Wächter der Gate-Lauf selbst: fällt der Definitions-Ort
  auf die falsche Adresse, meldet `ids` jede blanke Kennung des Verzeichnisses.
- **Auflösungs-Trigger:** permanent, solange dieser Block in der Verzeichnis-Form läuft. Mit dem
  Umzug ist der Auflösungs-Trigger von
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger),
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  und [`MR-043`](../conventions.md#mr-043--ein-nachgetragenes-pflichtfeld-schlägt-die-einordnung-im-rumpf)
  eingetreten — alle drei sind an die Inline-Form gebunden. Ihre Re-Evaluierung ist ein eigener
  Vorgang und nicht dieser Eintrag: sie verlangt je Eintrag ein `Löst auf`-Urteil, und dieser
  Umzug wechselt den Träger, nicht den Inhalt.
