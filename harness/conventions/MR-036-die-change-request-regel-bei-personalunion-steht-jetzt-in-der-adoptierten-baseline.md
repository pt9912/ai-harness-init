# MR-036 — Die Change-Request-Regel bei Personalunion steht jetzt in der adoptierten Baseline

> **ÜBERHOLT: §Achse 2 — [`MR-015`](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 3 als eigener, nicht eingetretener Bedarf → [`MR-042`](../conventions.md#mr-042--der-anlass-einer-lastenheft-änderung-steht-nicht-in-der-historie-sondern-in-der-closure-notiz).** Die übrigen Setzungen dieses Eintrags gelten fort.

- **Datum:** 2026-08-31
- **Wirksamkeits-Anlass:** slice-082 — Adaptions-Durchgang von welle-10, Achse 1.
- **Geltungsbereich:** [`MR-015`](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  Setzungen 1–3, der zitierte "adoptierte Wortlaut" und die Begründung. **Nicht** der
  Cutoff-Absatz — er bindet fort, siehe die Kopf-Marke an [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler).
- **Löst auf:** die Adaption selbst. Die adoptierte Baseline `v5.12.0` regelt den Fall
  "Auftraggeber- und Entwickler-Rolle fallen zusammen" jetzt an derselben Stelle, aus der
  [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) seinen Wortlaut zitierte.
- **Ausgelöst durch Baseline-Stand:** `v5.12.0`.
- **Ersetzt-Baseline-Regel:**
  [`grundlagen-source-precedence.md`](../../.harness/baseline/v5.18.0/regelwerk/grundlagen-source-precedence.md)
  — der Absatz **„Fallen Auftraggeber- und Entwickler-Rolle zusammen"**: *„fehlt nicht der
  Vorgang, sondern nur seine Ticket-Form: Die Rolle ist besetzt, und der annehmende Akt ist die
  Entscheidung, die vor der Umsetzung fällt. Was die Regel trägt, ist nicht die Externalität,
  sondern die Trennung von Entscheidung und Umsetzung — und die ist auch ohne Ticket
  herstellbar. Der Träger ist dann der Commit: Ein angenommener Change Request ändert in einem
  eigenen Commit ausschließlich das Lastenheft und liegt vor dem Slice, der ihn umsetzt."*
- **Gemessen, nicht vermutet.** Der v3.5.2-Wortlaut, den [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) als "adoptierten Wortlaut"
  zitiert, steht am Zielstand unverändert
  (`grep -c 'bewusst kein Harness-Konstrukt' .harness/baseline/v5.12.0/regelwerk/grundlagen-source-precedence.md`
  → **1**) — die Basisregel selbst war also nie der Adaptions-Gegenstand von [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler). Gegenstand
  war die **Lücke**, die die Baseline für Personalunion offen ließ, und [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) füllte sie
  selbst. Diese Lücke ist jetzt geschlossen — Satz für Satz deckungsgleich mit [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)s drei
  Setzungen: *„Die Rolle ist besetzt … der annehmende Akt ist die Entscheidung, die vor der
  Umsetzung fällt"* deckt Setzung 1; *„Der Träger ist dann der Commit: … ausschließlich das
  Lastenheft … vor dem Slice"* deckt Setzung 2 wörtlich; die neue Draft/In-Review/Accepted-
  Schwelle für den CR-Beginn ergänzt, ohne [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) zu widersprechen. [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) selbst benannte die
  Lücke, die jetzt schließt: *„Dieses Repo hat keinen externen Auftraggeber … nur die
  Ticket-Form fehlt."*
- **Ausgang: gegenstandslos → Rückbau, als Teil-Ablösung.** Der Cutoff-Absatz wird an zwei
  Stellen dieses Repos als Präzedenz zitiert
  ([`AGENTS.md`](../../AGENTS.md) §3.7 und
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert): *„dieselbe
  Begründung trägt den Cutoff in [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)"*) und bindet damit fort
  ([ADR-0014](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (a):
  *„bei Teil-Aufhebung bleibt der Rumpf, weil sein Rest bindet"*). [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) behält deshalb seinen
  vollständigen Rumpf und bekommt nur die Kopf-Marke
  ([`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)) —
  keine Entfernung, kein zweiter Commit.
- **Achse 2 — eigener Bedarf.** [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 3 (Verweis-Spalte nennt die annehmende Instanz
  statt eines Tickets) trägt einen eigenen Auflösungs-Trigger — *„fällt, sobald ein externer
  Auftraggeber existiert"*. Der ist unverändert nicht eingetreten und bleibt an [MR-015](../conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  gebunden, nicht an diesem Eintrag.
- **Auflösungs-Trigger:** permanent als Sachstands-Feststellung — eine eingeholte Adaption wird
  nicht ein zweites Mal eingeholt. Neu zu entscheiden ist der Gegenstand erst, wenn ein
  künftiger Baseline-Stand diesen Absatz erneut ändert; dann gegen den dann geltenden Tag zu
  messen und als neuer Eintrag zu führen.
