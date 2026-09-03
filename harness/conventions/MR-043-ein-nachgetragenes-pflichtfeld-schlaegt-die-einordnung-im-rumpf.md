# MR-043 — Ein nachgetragenes Pflichtfeld schlägt die Einordnung im Rumpf

- **Datum:** 2026-09-02
- **Wirksamkeits-Anlass:** slice-150 — dritter Posten, aus dem Form-Durchgang slice-083 §6.
- **Geltungsbereich:** [`MR-028`](../conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt)
  — die **Einordnung** *„Zusatz zur Vorlagen-Form, keine Abweichung von einer Baseline-Regel"*, und
  darüber hinaus die **Form** jedes Eintrags dieses Blocks, dessen nachgetragenes Pflichtfeld einer
  Einordnung im Rumpf widerspricht. **Nicht** die Setzung von [MR-028](../conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt) (eigenes Feld
  `Wirksamkeits-Anlass`, blanke statt verlinkter Slice-Nummer) — sie bindet unverändert fort.
  **Nicht** `docs/plan/adr/`, wo [`AGENTS.md`](../../AGENTS.md) §3.4 gilt; **nicht** die emittierte
  Ebene.
- **Löst auf:** die Einordnung von [MR-028](../conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt), nicht seine Setzung.
- **Ausgelöst durch Baseline-Stand:** `v5.12.0`.
- **Ersetzt-Baseline-Regel:**
  [`grundlagen-traceability.md`](../../.harness/baseline/v5.18.0/regelwerk/grundlagen-traceability.md#herkunfts-anker)
  §Herkunfts-Anker — *„Der Adaptions-Block trägt das Muster bereits über sein Feld Begründung."*
  Dieselbe Zelle, die [MR-028](../conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt)s eigenes `Ersetzt-Baseline-Regel`-Feld nennt; dieser Eintrag spricht
  aus, welche der beiden Aussagen jenes Eintrags gilt.
- **Der Befund: zwei Sätze im selben Eintrag, gegen zwei verschiedene Tags gemessen.** [MR-028](../conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt)s
  Adaptions-Absatz misst gegen die Pflichtfeld-Liste der Vorlage von `v3.5.2` und schließt daraus
  *„keine Abweichung von einer Baseline-Regel"*. Das Feld `Ersetzt-Baseline-Regel`, das
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 1 in jedem vor dem Sprung geschriebenen Eintrag nachträgt, misst gegen `v5.12.0` und
  kommt zum Gegenteil. Beide Sätze sind für ihren Mess-Stand richtig
  ([`MR-033`](../conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)) —
  aber der Block ist nach seiner Ziel-Form ein *Index der Abweichungen*, und ein Eintrag, der die
  Leserfrage *weicht dieses Repo hier ab?* zweimal gegensätzlich beantwortet, beantwortet sie nicht.
- **Setzung — das Feld gilt, der Rumpf bleibt, die Marke trägt den Zustand.** Widerspricht ein nach
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 1 nachgetragenes Pflichtfeld einer Einordnung im Rumpf, gilt das **Feld**: es ist gegen den
  adoptierten Stand gemessen, die Einordnung gegen einen abgelösten. Der Rumpf wird dafür **nicht**
  angefasst — die Einordnung ist die historisch korrekte Aussage über ihren Mess-Stand —, und der
  Eintrag bekommt die Kopf-Marke nach
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger), deren
  `<Reichweite>` die **Einordnung** benennt und nicht die Setzung.
- **Damit ist [MR-032](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger) Setzung 4 an einer Stelle erweitert, nicht umgestoßen.** Dort ist die Marke
  fällig, wenn ein **späterer Eintrag** eine Aussage ablöst; hier steht die ablösende Aussage im
  Eintrag selbst. Der Träger ist trotzdem ein späterer: der adoptierte Baseline-Stand, den das
  nachgetragene Feld zitiert. Die Alternative — Nicht-Fälligkeit, weil kein späterer Eintrag
  existiert — ließe die zwei gegensätzlichen Sätze unvermittelt nebeneinander stehen und machte die
  Marke abhängig davon, **wo** die ablösende Aussage steht, statt davon, **dass** sie eine ist.
- **Ausgang: teilweise überholt → engere Nachfolgerin.** [MR-028](../conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt) behält seinen vollen Rumpf und
  bekommt die Kopf-Marke; die Setzung des Feldes `Wirksamkeits-Anlass` und seine Blank-Form binden
  unverändert fort.
- **Cutoff — ab diesem Eintrag, kein Nachrüsten.** Gebunden ist der Eintrag, dessen Widerspruch
  festgestellt wird; der **Bestand ist kein Arbeitsauftrag.** Ob ein nachgetragenes Feld einer
  Einordnung widerspricht, ist ein **Urteil, kein Muster**
  ([`AGENTS.md`](../../AGENTS.md) §3.6) — ein `grep` fände Einträge mit beiden Bestandteilen, nicht
  Widersprüche zwischen ihnen —, und ein Maßstab über den Bestand wäre darum nicht einmal
  formulierbar. Träger ist der Form-Durchgang der nächsten Re-Baseline, der diese drei Posten auch
  gefunden hat.
- **Auflösungs-Trigger:** permanent, solange dieser Block in der **Inline-Form** läuft; er fällt mit
  dem Umzug in die Verzeichnis-Form, in der der Zustand die Verzeichnis-Position trägt und die
  Kopf-Marke gegenstandslos wird
  ([`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  §Auflösungs-Trigger).
