# MR-058 — Eine Messung, die ihr eigener Vorgang bewegt, wird nach dem Vorgang genommen

- **Datum:** 2026-09-13
- **Wirksamkeits-Anlass:** slice-225 — der Architect-Nachtrag. Wirksam wird die Setzung mit dem
  Commit, der diesen Eintrag und seine Index-Zeile aufnimmt.
- **Geltungsbereich:** die Zahl neben dem `grep -c 'slice-NNN'`-Kommando im Feld `Löst auf` von
  [`MR-057`](../conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer),
  und die **Form** jeder Messung in einem lebenden, repo-eigenen Markdown-Artefakt, deren
  Bezugsmenge der schreibende Vorgang selbst verändert — derselbe Ausschnitt, den
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  §Geltungsbereich abgrenzt. **Nicht** der Rumpf jenes Eintrags: kein Wort darin wird geändert, und
  seine drei Setzungen samt Cutoff und Grenze binden fort. **Nicht** `docs/plan/adr/`, wo
  [`AGENTS.md`](../../AGENTS.md) §3.4 unverändert gilt; **nicht** die emittierte Ebene, deren
  Beleg-Regeln der Slice entscheidet, der die Tool-Ebene entscheidet.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  der nach
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 hier steht und sein Verdikt im Feld trägt. Am adoptierten Stand `v6.9.0` führt das
  Regelwerk den Gegenstand nicht: `grep -rl 'Bezugsmenge' .harness/baseline/v6.9.0/regelwerk/` ist
  leer (Exit 1). **Welche Wörter die Eigenschaft decken, sagt kein `grep`** — dass die Baseline
  keine Regel über den Zeitpunkt einer Messung führt, bleibt ein Urteil
  ([`AGENTS.md`](../../AGENTS.md) §3.6), und dieser Eintrag ist auf sich selbst angewandt: Das
  Kommando misst ein Wort, nicht eine Eigenschaft
  ([`MR-055`](../conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)).
- **Löst auf:**
  [`MR-057`](../conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  — allein die Zahl neben dem `grep -c 'slice-NNN'`-Kommando, keine seiner Setzungen und keine
  seiner übrigen Zahlen. Das Feld `Ausgelöst durch Baseline-Stand` bleibt aus, weil die Ablösung
  repo-intern getrieben ist
  ([`MR-038`](../conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte):
  dann *„gäbe es nichts zu nennen"*).
- **Setzung 1 — die Zahl ist gestrichen, nicht ersetzt.** Das Kommando gilt weiter, die Aussage
  daneben — *„allein das Token in seiner `Adaption:`-Zeile"* — ist sachlich richtig und bleibt.
  Gestrichen ist der Betrag:

  ```sh
  grep -c 'slice-NNN' harness/conventions/MR-000-baseline-aussage.md              # 2
  git show 3c2b4d82^:harness/conventions/MR-000-baseline-aussage.md \
    | grep -c 'slice-NNN'                                                         # 1
  ```

  **Kein Erwartungswert** — die erste Zahl wandert mit dem Eintrag. Die zweite Fundstelle ist die
  Kopf-Marke, die derselbe Commit gesetzt hat, der die `1` schrieb: Sie zitiert das gesuchte Token
  in ihrer eigenen Reichweiten-Angabe. Der Betrag `1` galt für den Stand **vor** dem Commit und in
  keinem Moment danach.
- **Setzung 2 — bewegt der schreibende Vorgang seine eigene Bezugsmenge, wird die Messung über den
  Zustand **nach** dem Vorgang genommen.** Sonst steht sie gar nicht da, und an ihrer Stelle steht
  die Eigenschaft, die tragen soll — hier: *dass* die Kopf-Marke die einzige weitere Fundstelle
  ist, nicht *wie viele* es sind. Ein Betrag, den der eigene Commit falsch macht, ist im Moment
  seines Schreibens falsch, nicht später.
- **Setzung 3 — die Kennzeichnung *kein Erwartungswert* trägt diesen Fall nicht.**
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2 deckt die Drift **nach** dem Schreiben — eine Zahl, die bricht, ohne dass am Gegenstand
  etwas bricht. Hier bewegt der schreibende Vorgang die Zahl **selbst**; der Zusatz machte aus
  einem falschen Betrag einen falschen Betrag mit Disclaimer. Dieselbe Unterscheidung trifft
  [`ADR-0040`](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
  §Konsequenzen für eine Zahl über `docs/reviews/**`
  (`grep -c 'Er deckt Drift \*\*nach\*\* dem Schreiben' docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md`
  → **1**); dieser Eintrag verallgemeinert sie von jener einen Zahl auf die Klasse. **Das ist kein
  zweiter Ort für dieselbe Aussage:** Jene Entscheidung ist ab `Accepted` eingefroren und spricht
  über ihren eigenen Trigger; hier steht die Form, an die sich ein künftiger Schreiber hält.
- **Begründung (gemessen, nicht postuliert).** Die Klasse steht im Beobachtungs-Register als
  `BEO-ALL/mess-zusage-trifft-das-eigene-zitat`; ihr Zähler ist die Zahl der Belege:

  ```sh
  ls docs/plan/planning/observations/BEO-ALL/mess-zusage-trifft-das-eigene-zitat/evidence/*.md | wc -l   # 3
  ```

  **Kein Erwartungswert** — er wandert mit dem Register, und der Fall dieses Eintrags ist darin
  noch nicht gebucht: Die Buchung eines Belegs und die Zuweisung des Ausgangs sind
  **Planner**-Arbeit ([`ADR-0024`](../../docs/plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md),
  [`AGENTS.md`](../../AGENTS.md) §3.10) und laufen bei der Closure. Die drei gebuchten Belege
  treffen Zusagen in Slice-Plänen; dieser Eintrag ist der erste Fall im Adaptions-Block selbst —
  dieselbe Mechanik, anderes Artefakt, und genau deshalb trägt die Setzung oben die **Eigenschaft**
  statt eine Artefaktklasse.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der
  [`.d-check.yml`](../../.d-check.yml) hält eine Zahl gegen das Kommando daneben — die Lücke, die
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  §Kein Wächter für sich selbst feststellt; für den Zeitpunkt einer Messung gilt sie erst recht, denn
  der verlangte Zustand ist der **nach** dem Commit, den ein Sensor vor dem Commit nicht sieht.
  `make comment-claims` liest keine Markdown-Datei. Träger ist der Rollen-Wechsel vor dem Schreiben.
- **Cutoff — ab diesem Eintrag, kein Nachrüsten.** Gebunden ist die Messung, die geschrieben oder
  geändert wird; der Bestand ist kein Arbeitsauftrag, und ein Maßstab über ihn wäre dauerhaft rot
  — dieselbe Begründung, die den Cutoff in
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  und in [`AGENTS.md`](../../AGENTS.md) §3.7 trägt.
- **Auflösungs-Trigger:** permanent, solange dieser Block und die lebenden Artefakte dieses Repos
  Messungen führen. **Neu fällig** wird der Eintrag, wenn ein künftiger Baseline-Stand den
  Zeitpunkt einer Messung selbst regelt: Dann ist nicht dieser Eintrag zu korrigieren, sondern ein
  Nachfolger zu schreiben, der ihn auflöst und den Stand nennt
  ([`MR-038`](../conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte)).
