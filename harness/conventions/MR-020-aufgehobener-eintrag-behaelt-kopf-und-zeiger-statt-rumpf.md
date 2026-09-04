# MR-020 — Aufgehobener Eintrag behält Kopf und Zeiger statt Rumpf

> **ÜBERHOLT: die Aufgehoben-durch-Form für baseline-getriebene Rückbauten → [`MR-038`](../conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte).** Festlegung 1–3 (Kopf bleibt, Rumpf geht bei vollständiger Aufhebung) gelten fort — geprüft und bestätigt gegen `v5.12.0`, nicht widerlegt.

- **Datum:** 2026-08-01
- **Geltungsbereich:** dieser Adaptions-Block. **Nicht** `docs/plan/adr/` — dort gilt
  [`AGENTS.md`](../../AGENTS.md) §3.4 unverändert.
- **Ersetzt-Baseline-Regel:**
  [`grundlagen-harness-dateien.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher)
  §harness/conventions.md als Konventionsspeicher — *„Einträge werden nie überschrieben."* An ihre
  Stelle tritt die Festlegung unten: bei **vollständiger** Aufhebung fällt der Rumpf in einem
  eigenen, additionsfreien Commit; Nummer, Überschrift wörtlich, `Datum` und die Zeiger-Zeile
  bleiben. Der Satz ist am adoptierten Stand `v5.12.0` derselbe, den der Rumpf aus dem
  Vorlagen-Kommentar von `v3.5.2` zitiert — nur wohnt er jetzt im Regelwerk statt im Kommentar;
  dass die Abweichung deshalb gegen den neuen Wortlaut **neu begründet** wurde, trägt
  [`MR-038`](../conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte).
  Die Pflichtfeld-Aufzählung im Absatz *„Akzeptiert" heißt committet* unten ist die von `v3.5.2`
  und führt `Ersetzt-Baseline-Regel` nicht; die geltende steht an derselben Baseline-Stelle.
- **Adaption:** Die Disziplin-Regel der vendored Vorlage
  (`.harness/baseline/v3.5.2/templates/harness/conventions.template.md`, Kommentar über dem
  Adaptions-Block) verlangt *„keine nachträglichen inhaltlichen Änderungen an akzeptierten
  Einträgen — nur neue Einträge oder explizite Aufhebungen via neuen MR"*. Davon weicht dieses
  Repo in **einem** Punkt ab: **der Rumpf eines vollständig aufgehobenen Eintrags wird
  entfernt.** Es bleiben stehen die Nummer, die Überschrift **wörtlich** (sie ist der Anker),
  das `Datum` und **eine** Zeile mit dem aufhebenden Eintrag und den Zielorten je Posten-Art;
  die Historie trägt `git`. Bedingungen, Abwägung und Reichweite:
  [`ADR-0014`](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md).
- **„Akzeptiert" heißt committet.** Ein Eintrag hier führt kein Status-Feld (Pflichtfelder: ID ·
  Datum · Geltungsbereich · Adaption · Begründung · Auflösungs-Trigger); ohne diese Festlegung
  hätte die Regel keinen bestimmbaren Auslöser.
- **Hebt die Blankett-Klausel aus [`MR-000`](../conventions.md#mr-000--baseline-aussage) für diesen Punkt auf** —
  *„keine inhaltlichen Adaptionen ggü. Baseline-Default"*.
  [`MR-000`](../conventions.md#mr-000--baseline-aussage) bleibt unangetastet, seine übrigen Setzungen gelten
  fort.
- **Nur die Dogfood-Ebene.** Das emittierte `harness/conventions.md` ist dieselbe vendored
  Vorlage mit zwei Transformationen (Hinweis-Blockquote entfernt, `<Projektname>` gestempelt);
  ihre neun HTML-Kommentare und mit ihnen die Disziplin-Regel wandern unverändert ins Zielrepo,
  wo die Baseline-Regel gilt.
- **Begründung (gemessen 2026-08-01 am Stand `c145f2b`).** Die drei sitzungsfesten Posten der
  Einstiegs-Leseliste messen zusammen 165.197 Bytes; der größte Eintrag dieses Blocks misst 824
  Zeilen / 70.727 Bytes und damit 42,8 % davon. Ein stehengelassener aufgehobener Rumpf dieser
  Größe macht diesen Anteil des Pflicht-Lesepfads zu Text ohne Bindung und führt seine
  Festlegung an zwei Orten, von denen nur einer bindet. Was die append-only-Führung dagegen
  leisten soll — Nachvollziehbarkeit — leistet `git` vollständig und besser: jede Fassung, ihr
  Autor und der aufhebende Commit. Nicht in `git` steht, was der Kopf hält: Nummer, Anker und
  die Reichweite am Ort des Lesens.
- **Auflösungs-Trigger:** an [`ADR-0014`](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)
  gebunden — fällt ihre Annahme (die Historie ist da, wo der Rumpf gebraucht wird), fällt diese
  Adaption mit ihr.
