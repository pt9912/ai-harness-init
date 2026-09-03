# MR-033 — Eine Aussage über die Baseline nennt den Tag, gegen den sie gemessen ist

- **Datum:** 2026-08-29
- **Wirksamkeits-Anlass:** die vollständige Aufhebung von
  [`MR-023`](../conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung) durch
  [`MR-031`](../conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline). Der Satz stand in
  jenem Rumpf und band über dessen Gegenstand hinaus;
  [`ADR-0014`](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (b)
  verlangt für ihn einen bindenden Ort oder einen Vermerk *ersatzlos mit Grund*. Dies ist der Ort.
- **Geltungsbereich:** die **lebenden**, repo-eigenen Markdown-Artefakte — derselbe Ausschnitt,
  den [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  §Geltungsbereich über vier Kommandos definiert; er steht hier nicht ein zweites Mal, weil zwei
  Fassungen desselben Ausschnitts driften. **Dieses Repo, nicht das emittierte:** was ein
  emittiertes Repo an Beleg-Regeln bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**.
  Dieselbe Einordnung und dieselbe offene Folge wie bei
  [`MR-031`](../conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline): was daraus für den
  Block folgt, entscheidet slice-083 §2.
- **Setzung 1, wörtlich aus dem aufgehobenen Rumpf übernommen:** *„Eine Aussage über die Baseline
  nennt darum den Tag, gegen den sie gemessen ist."* Wer schreibt, die Baseline führe etwas oder
  führe es nicht, sage es so oder anders, nennt den Stand, an dem er nachgesehen hat — im selben
  Absatz und nicht implizit über den gerade gepinnten Tag. Ein Kommando, dessen Pfad den Tag
  enthält, erfüllt die Setzung; ein Satz ohne Tag erfüllt sie nicht.
- **Setzung 2 — was die Setzung nicht verlangt.** Sie verlangt keine bestimmte Verweis-Form. Wo
  ein Artefakt unveränderlich wird, gilt daneben
  [`ADR-0016`](../../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 mit ihren drei
  Teilen; wo es lebt, genügt der Tag. Und sie bindet die **Aussage über die Baseline**, nicht jede
  Nennung eines Pfad-Musters: eine Layout-Beschreibung nennt keinen Tag, sonst beschriebe sie
  einen Einzelfall — die Unterscheidung ist dieselbe, die
  [`ADR-0016`](../../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 zwischen Beleg
  und Layout zieht.
- **Adaption:** Die Eintrags-Vorlage verlangt den Baseline-Stand als Pflichtfeld nur zusammen mit
  `Löst auf`. Hier gilt er für jede Baseline-Aussage in einem lebenden Artefakt dieses Repos,
  unabhängig von Feld und Datei.
- **Begründung (gemessen, nicht postuliert):** Der Schaden ist eingetreten und protokolliert. Eine
  Hard Rule samt Adaptions-Eintrag wurde in Kraft gesetzt auf eine behauptete Baseline-Abweichung,
  die es nicht gab — *„gemessen gegen einen Tag, den zwei Releases überholt hatten, und ohne die
  Mess-Version zu nennen"* ([`AGENTS.md`](../../AGENTS.md) §3.8 §Begründung, wo derselbe Vorfall die
  Rollen-Trennung trägt). Ohne den Tag ist eine Baseline-Aussage nicht falsch, sondern
  **unprüfbar**: der Baum unter `.harness/baseline/` wandert mit jeder Re-Baseline, und ein Leser
  kann nicht unterscheiden, ob eine Aussage am heutigen Stand gemessen wurde oder an einem, den
  niemand mehr sehen kann.
- **Warum ein eigener Eintrag und nicht ein Satz in
  [`MR-031`](../conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline).** Die Setzung hat
  einen anderen Gegenstand als jener Eintrag; unter dessen Überschrift fände sie niemand, der sie
  sucht. Eine Aussage hat einen Ort.
- **Der Ort ist offen, die Verbindlichkeit nicht.** Wie
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) §*Der Ort ist
  offen* für seine Schwester-Setzung festhält, gehört eine Regel, die eine **Lücke füllt** statt
  von der Baseline abzuweichen, nach [`AGENTS.md`](../../AGENTS.md) §3.8 nicht in diesen Block. Bis
  über den Block entschieden ist (slice-083 §2), gilt die Setzung von hier: er ist normativ wie
  eine ADR, nur ohne deren Immutabilität.
- **Cutoff — ab diesem Eintrag, kein Nachrüsten.** Gebunden ist die Baseline-Aussage, die
  geschrieben oder geändert wird; der **Bestand ist kein Arbeitsauftrag**. Seine Fläche ist
  gemessen, nicht geschätzt:
  `git grep -l 'Baseline' -- '*.md' ':!docs/reviews/**' ':!docs/plan/planning/done/**' ':!.harness/baseline/**' ':!*.template.md' | wc -l`
  nennt die lebenden Markdown-Dateien, in denen das Wort überhaupt vorkommt. Das ist die
  **Obergrenze der Fläche** und **kein Erwartungswert**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2) —
  keine Zahl von Verstößen: wie viele dieser Dateien eine Aussage ohne Tag tragen, sagt kein
  Kommando, weil die Zugehörigkeit ein Urteil ist ([`AGENTS.md`](../../AGENTS.md) §3.6). Ein Maßstab
  über diesen Bestand wäre dauerhaft rot und entwertete die Setzung, statt sie zu tragen —
  dieselbe Begründung trägt den Cutoff in
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) und in
  [`AGENTS.md`](../../AGENTS.md) §3.7.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der `.d-check.yml` prüft, ob
  ein Satz über die Baseline einen Tag nennt; `links` prüft Auflösbarkeit, `ids` drei Kennungs-
  Muster. `make comment-claims` hat keine Markdown-Datei in seinem Prüfbereich. Die Setzung liegt
  im Feedforward-Quadranten; ihr Träger ist der Rollen-Wechsel vor der Änderung und die
  Review-Runde danach — der Vorfall aus der Begründung ist von einem zweiten Kontext gefunden
  worden, nicht von einem Gate.
- **Auflösungs-Trigger:** permanent. Ein Tag, gegen den gemessen wurde, hört nicht auf, die
  Prüfbarkeit zu tragen. Fällt die Setzung, dann durch Verlegung nach
  [`AGENTS.md`](../../AGENTS.md) §3 — dann bleiben hier nach
  [`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) Kopf und Zeiger.
