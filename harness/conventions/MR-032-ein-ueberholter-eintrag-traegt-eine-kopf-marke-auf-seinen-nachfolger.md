# MR-032 — Ein überholter Eintrag trägt eine Kopf-Marke auf seinen Nachfolger

> **ÜBERHOLT: die Prämisse von Setzung 2 — *„Dieses Repo führt den Block **inline**; eine Position gibt es nicht"* — samt der drei Zensus-Kommandos über `harness/conventions.md` → [`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht).** Die Setzungen 1–4, die Trennung der zwei Instrumente und die Auslegung der Nicht-Anfassen-Sätze gelten fort: die Verzeichnis-Position ist binär und trägt die Teil-Ablösung nicht.

- **Datum:** 2026-08-29
- **Wirksamkeits-Anlass:** slice-081 — dort entstand die erste Teil-Ablösung dieses Blocks
  ([`MR-029`](../conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)),
  und ihr Vorgänger blieb ohne Zeiger. slice-082 §2 (3) führt die Form als **einmal zu
  entscheidenden** Posten; entschieden ist sie hier, weil dieser Block dem Architect gehört
  ([`AGENTS.md`](../../AGENTS.md) §3.8). **Der Bestands-Durchgang jenes Slice ist damit nicht
  vorweggenommen:** gesetzt sind hier nur die Marken, die kein Zeichen eines bestehenden Eintrags
  ersetzen; was in der älteren `HISTORIE`-Beschriftung liegt, bleibt liegen (unten).
- **Geltungsbereich:** die **Form** eines Eintrags dieses Blocks, dessen Aussage ein späterer
  Eintrag ablöst. **Nicht** `docs/plan/adr/` — dort gilt [`AGENTS.md`](../../AGENTS.md) §3.4
  unverändert; **nicht** die emittierte Ebene.
- **Ersetzt-Baseline-Regel:**
  [`grundlagen-harness-dateien.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher)
  §harness/conventions.md als Konventionsspeicher — *„Der Zustand ist die Verzeichnis-Position,
  kein Status-Feld."*
- **Adaption:** Der Zustand *überholt* bekommt in diesem Block einen Träger im Text — eine
  Blockquote-Zeile im Kopf des überholten Eintrags —, weil die Verzeichnis-Position, die ihn in
  der Baseline trägt, hier nicht existiert.
- **Begründung:** Wer auf dem Vorgänger landet, erfährt sonst nichts. Gemessen ist der Fall:
  [`MR-029`](../conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
  löste eine Aussage von [`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  ab, und [`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) — der Eintrag,
  den jeder Lauf zuerst liest — sagte sie weiter unwidersprochen.
- **Setzung 1 — die Form ist eine Zeile, und sie wird gesetzt, nicht getauscht.** Direkt unter der
  Überschrift, vor der Feldliste, steht eine Blockquote-Zeile in dieser Gestalt:

  ```text
  > **ÜBERHOLT: <Reichweite> → <Ziel>.** <Fortgeltung, optional>
  ```

  `<Reichweite>` ist die abgelöste Aussage, benannt — oder *dieser Eintrag*, wenn alles fällt.
  `<Ziel>` ist die Anker-Adresse des ablösenden Eintrags, wie sie jeder Verweis
  auf eine Adaption trägt. Nehmen **mehrere** spätere Einträge dieselbe Aussage punktweise aus und
  ist die Menge offen, tritt an die Stelle des Links das **Kommando**, das die Menge ausgibt: ein
  Link auf einen von mehreren behauptete eine Rangfolge, die es nicht gibt, und eine Liste von
  Links müsste bei jedem weiteren Eintrag nachgezogen werden. `<Fortgeltung>` sagt in einem Satz,
  was am Eintrag weiter bindet. Weitere Blockquote-Zeilen sind frei.

  **Sonst wird am Eintrag nichts geändert:** der Rumpf bleibt wörtlich, kein Satz wird
  nachgezogen, keine Adresse getauscht — **und eine Marke, die in einer früheren Beschriftung
  schon dasteht, wird nicht umgeschrieben.** Sie zu ersetzen wäre genau das Überschreiben, das die
  Ziel-Form ausschließt; die Form bindet die Marke, die **gesetzt** wird.
- **Setzung 2 — warum das Setzen kein Überschreiben ist.** Die Ziel-Form sagt *„Einträge werden
  nie überschrieben"*. Die Marke ersetzt keine Aussage des Eintrags; sie tritt daneben und nennt
  seinen **Zustand**. Diesen Zustand trägt die Baseline in ihrer **Default-Form** ohne einen
  einzigen Zeichenwechsel im Eintrag: dort liegt jede Adaption in einer eigenen Datei, und mit dem
  Eintreten ihres Triggers wandert sie nach `conventions/done/` — *„Der Zustand ist die
  Verzeichnis-Position, kein Status-Feld."* Dieses Repo führt den Block **inline**; eine Position
  gibt es nicht, also braucht der Zustand einen Träger im Text.
- **Setzung 3 — wer sie setzt und wann.** Der **ablösende** Eintrag setzt sie in derselben
  Änderung, in der er entsteht. Ein Nachfolger ohne Marke am Vorgänger ist unvollständig.
- **Setzung 4 — wann sie fällig ist und wann nicht.** Fällig, wenn ein späterer Eintrag eine
  Aussage **namentlich** ablöst oder für überholt erklärt. **Nicht** fällig, wo ein Eintrag von
  vornherein eine datierte Momentaufnahme ist, deren lebender Wert anderswo deklariert steht: die
  d-check-Pin-Kette ist dieser Fall — §Baseline nennt den lebenden Pin und führt die Kette, und
  ein Pin-Eintrag löst keine Aussage ab, sondern datiert einen Sprung. Und **nicht** fällig macht
  sie ein Satz, der einem anderen Eintrag zusagt, er werde nicht **korrigiert**: einen solchen
  Satz löst die Marke nicht ab, sie hält ihn ein — siehe die Auslegung unten.
- **Die Nicht-Anfassen-Sätze dieses Blocks werden nicht aufgehoben, sondern in ihrer Reichweite
  ausgesprochen.** Sechs Sätze sagen über einen anderen Eintrag, er bleibe *unangetastet* bzw.
  werde *nicht angefasst*: in
  [`MR-019`](../conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence),
  [`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) und
  [`MR-026`](../conventions.md#mr-026--die-hard-rule-nummer-ist-eine-adresse-keine-baseline-entsprechung) über
  [`MR-000`](../conventions.md#mr-000--baseline-aussage), in
  [`MR-021`](../conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben) über
  [`MR-019`](../conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence), in
  [`MR-029`](../conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
  über [`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) und in
  [`MR-030`](../conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen) über
  [`MR-021`](../conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben).
  Was sie schützen, ist der **Rumpf**: keine Korrektur, kein nachgezogener Satz, keine getauschte
  Adresse. Genau das lässt die Marke unberührt (Setzung 2) — sie ist damit **erfüllt, nicht
  aufgehoben**, und keiner der sechs Einträge bekommt deswegen eine Marke.
  [`MR-029`](../conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
  sagt den Grund selbst: *„ihn zu überschreiben löschte, wann die Klassifikation noch stimmte"* —
  die Marke löscht davon nichts, sie sagt daneben, dass es nicht mehr stimmt. Diese Auslegung
  steht hier und nur hier; die sechs Einträge werden dafür nicht angefasst.

  **Die Menge ist gelesen, nicht gegrept.** Ein zeilenweises Muster findet sie nicht vollständig —
  der Satz in
  [`MR-021`](../conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  bricht zwischen *nicht* und *angefasst* um. Absatzweise gelesen liefert
  `awk 'BEGIN{RS=""} /unangetastet|nicht[[:space:]]+angefasst/ {n++} END{print n}' harness/conventions.md`
  die **Kandidaten**; welche davon ein Satz über einen anderen Eintrag sind, ist ein Urteil, kein
  Muster ([`AGENTS.md`](../../AGENTS.md) §3.6) — die Zahl der Kandidaten wandert mit dem Block
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2).
- **Warum `ÜBERHOLT` und nicht `HISTORIE`.** *Historie* ist das falsche Wort für ein Zustandsfeld:
  die Marke nennt den **Zustand** und den Beleg, nicht die Chronik
  ([`AGENTS.md`](../../AGENTS.md) §3.7, Zustandsfeld-Hälfte); die Chronik hält `git`. Das ist der
  ganze Grund. **Ein Zensus-Argument steht hier bewusst nicht:** eine Zählung der gesetzten Marken
  (`grep -c '^> \*\*ÜBERHOLT: ' harness/conventions.md`) misst, wie oft die Beschriftung gewählt
  wurde, nicht, ob die Wahl richtig war — und die Zahl im anderen Instrument
  (`grep -c '^- \*\*Aufgehoben durch ' harness/conventions.md`) hängt von der Beschriftung
  überhaupt nicht ab. Beide Zahlen wandern
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2).
- **Zwei Beschriftungen liegen im Bestand, und sie bleiben liegen.**
  [`MR-004`](../conventions.md#mr-004--sessionstart-regelwerk-injektor) und
  [`MR-006`](../conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) tragen ihre Marke
  in der älteren Beschriftung `HISTORIE` (`grep -c '^> \*\*HISTORIE' harness/conventions.md`; die Zahl wandert).
  Sie werden **nicht** umgeschrieben — Setzung 1 bindet die Marke, die gesetzt wird, und ein
  Tausch wäre ein Überschreiben. Der Preis ist benannt: bis zu einem Durchgang, der die zwei
  Einträge aus einem eigenen Grund anfasst, findet man Marken über **zwei** Muster statt über
  eines. Der Zuschnitt dieses Durchgangs liegt bei slice-082 §2 (3).
- **Zwei Instrumente, zwei Fälle, und sie werden nicht zusammengelegt.** **Teil-Ablösung** → Rumpf
  bleibt, Kopf-Marke; [`ADR-0014`](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)
  Festlegung 2 (a) lässt den Rumpf nur bei **vollständiger** Aufhebung fallen. **Vollständige
  Aufhebung** → Nummer, Überschrift wörtlich, `Datum` und eine `Aufgehoben durch`-Zeile, Rumpf
  entfällt ([`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)). Ein
  Eintrag trägt genau eines von beiden.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der `.d-check.yml` liest, ob
  ein Eintrag, dessen Aussage abgelöst ist, eine Marke trägt — `links` prüft Link-Ziele, `ids` die
  drei Muster —, und die Fälligkeit aus Setzung 4 ist ein **Urteil, kein Muster**
  ([`AGENTS.md`](../../AGENTS.md) §3.6). Ein `grep` zählt gesetzte Marken, nicht fehlende.
  Träger ist der Rollen-Wechsel vor der Änderung.
- **Auflösungs-Trigger:** die Migration dieses Blocks in die **Verzeichnis-Form**, die der
  adoptierte Stand zum Default macht und die
  [`MR-030`](../conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen) als eigenen,
  noch ungeschnittenen Vorgang benennt. Dann trägt die Verzeichnis-Position den Zustand, und die
  Marke wird gegenstandslos.
- **Hebt die Blankett-Klausel aus [`MR-000`](../conventions.md#mr-000--baseline-aussage) für diesen Punkt auf**
  — *„keine inhaltlichen Adaptionen ggü. Baseline-Default"*.
  [`MR-000`](../conventions.md#mr-000--baseline-aussage) behält seinen Rumpf wörtlich; dass die Klausel punktweise
  ausgenommen ist, sagt seit diesem Eintrag seine Kopf-Marke, und seine übrigen Setzungen gelten
  fort.
