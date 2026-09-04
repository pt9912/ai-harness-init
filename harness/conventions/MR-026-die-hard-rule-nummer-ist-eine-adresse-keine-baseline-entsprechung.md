# MR-026 — Die Hard-Rule-Nummer ist eine Adresse, keine Baseline-Entsprechung

- **Datum:** 2026-08-27
- **Geltungsbereich:** der Hard-Rule-Block [`AGENTS.md`](../../AGENTS.md) §3 gegenüber
  `.harness/baseline/v3.5.2/templates/AGENTS.template.md` §3. **Dieses Repo, nicht das
  emittierte:** die emittierte `AGENTS.md` entsteht aus jener Vorlage, nicht aus dieser
  Fassung — dort trägt jede Regel die Nummer der Vorlage.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  und die Messung ist am adoptierten Stand `v5.12.0` gefahren: das Regelwerk vergibt für Hard Rules
  keine Nummern und bindet keine.
  [`modul-09-implementierung.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-09-implementierung.md#hard-rules-repo-spezifisch)
  §Hard Rules (repo-spezifisch) führt *„Bewährte Muster"* ohne Nummerierung, §Ziel-Form: AGENTS.md
  verweist für die Form auf die Vorlage, und `grep -rn 'AGENTS.md §3' .harness/baseline/v5.12.0/regelwerk/`
  ist leer (Exit 1). Die eine Nummer, die im Regelwerk steht, ist ein **Form-Beispiel** des
  Herkunfts-Ankers (`### 3.3 <Hard Rule>   (seit welle-3)` in
  [`grundlagen-traceability.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-traceability.md#herkunfts-anker)),
  kein Zuordnungs-Satz. Damit tritt dieser Eintrag an keine Regel; er füllt, was die Vorlagen-Form
  offen lässt. **Sein Auflösungs-Trigger ist davon unberührt** und für §3.7 eingetreten — das trägt
  [`MR-031`](../conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline), nicht dieses Feld.
- **Setzung 1 — die beiden Sätze decken sich in der Nummer nicht, und sie sollen es nicht.**
  Eine Hard-Rule-Nummer adressiert einen Abschnitt **dieses** Repos; sie sagt weder eine
  Rangfolge noch eine Entsprechung in der Vorlage zu. Deckungsgleich ist **eine einzige**
  Überschrift, nämlich §3.3 —
  `comm -12 <(grep -E '^### 3\.' AGENTS.md | sort) <(grep -E '^### 3\.' .harness/baseline/v3.5.2/templates/AGENTS.template.md | sort) | wc -l`
  → **1**. Die Docker-only-Regel führt die Vorlage als §3.1, dieses Repo als §3.9. Die
  Architektur-Regel der Vorlage (§3.4) steht hier gar nicht in §3, sondern als Hard Rule im
  Kopf des Artefakts, das sie bindet —
  `grep -c 'sprach- und meilensteinfrei' spec/architecture.md` → **1**: eine Aussage hat
  einen Ort, und für diese ist es die Architektur-Sicht selbst.
- **Setzung 2 — eine neue Hard Rule wird angehängt, nicht eingeschoben.** Die Nummer folgt
  dem Zeitpunkt der Aufnahme, nicht der Wichtigkeit. Der Grund ist die Reichweite einer
  Umnummerierung: `git grep -oE '§ ?3\.[1-8]([^0-9]|$)' | wc -l` → **2292** Nennungen im
  Index (**kein Erwartungswert** — die Zahl wandert mit jedem neuen Verweis;
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2).
  Davon lägen **333** in lebenden Artefakten und wären nachzuziehen
  (`git grep -oE '§ ?3\.[1-8]([^0-9]|$)' -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' | wc -l`),
  **1958** in Zeitdokumenten
  (`git grep -oE '§ ?3\.[1-8]([^0-9]|$)' -- 'docs/reviews' 'docs/plan/planning/done' | wc -l`),
  die nicht nachgezogen werden
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  §Geltungsbereich) und danach eine **andere** Regel benennen würden als zum Zeitpunkt
  ihrer Messung. Diese Verschiebung sieht kein Gate: die Nennungen sind Fließtext, kein
  Anker — ein HTML-Anker mit der alten Kennung rettet sie darum nicht. Ein Anhängen kostet
  **0** Nachzüge.
- **Setzung 3 — die Durchsetzungsschicht nennt je Ebene die Nummer ihrer Ebene.** Der
  Begründungstext eines Guards zeigt auf den Abschnitt, den der geblockte Lauf lesen soll.
  Für die Dogfood-Fassung ist das die Nummer dieses Repos, für die emittierte die der
  Vorlage — `grep -c 'Hard Rule 3\.1' .claude/hooks/pretooluse-command-guard.sh` → **3**
  (diese drei Stellen nennen die Docker-only-Regel und gehören auf §3.9 gezogen; sie sind
  Implementer-Artefakt) gegenüber
  `grep -c 'Hard Rule 3\.1' internal/emit/templates/enforce/pretooluse-command-guard.sh`
  → **1**, die richtig steht und **nicht** mitwandert
  ([`ADR-0004`](../../docs/plan/adr/0004-durchsetzungs-emission.md) trennt die Ebenen,
  [`MR-002`](../conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) die Mechanik).
- **Begründung — dieselbe Kennung bezeichnet heute zwei Regeln.** Außerhalb dieses Eintrags,
  der sie zitiert, führen **drei** lebende Artefakte die Kennung „Hard Rule 3.1"
  (`git grep -lF 'Hard Rule 3.1' -- ':!docs/reviews' ':!docs/plan/planning/done' ':!.harness/baseline' ':!harness/conventions.md' | wc -l`);
  die **2** Nennungen der Roadmap
  (`grep -c 'Hard Rule 3\.1' docs/plan/planning/in-progress/roadmap.md`) meinen *Keine
  halluzinierten Gates*, die Guard-Nennungen meinen Docker-only. Eine Nummer, die beide
  Sätze zugleich adressieren soll, trägt genau diese Kollision; als bloße Adresse mit
  deklarierter Ebene trägt sie sie nicht.
- **Kein Wächter, und das gehört dazu.** Kein Modul der heutigen `.d-check.yml` hält eine
  Fließtext-Nennung „§3.N" gegen die Überschriften von [`AGENTS.md`](../../AGENTS.md)
  (`grep -m1 '^modules:' .d-check.yml` führt `links, anchors, ids, matrix, codepaths, spans`
  — `anchors` prüft Link-Ziele, nicht Prosa), und `make comment-claims` hat keine
  Markdown-Datei im Prüfbereich. Die Setzungen liegen im Feedforward-Quadranten; ihr Träger
  ist der Griff beim Anlegen einer Regel, nicht ein Gate danach.
- **Auflösungs-Trigger:** die Re-Baseline auf einen Stand, dessen AGENTS-Vorlage einen
  Hard-Rule-Satz führt, der sich mit dem hiesigen deckt — dann ist gegen die
  Upstream-Nummerierung zu halten und dieser Eintrag nach
  [`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) auf Kopf und
  Zeiger zurückzuführen. Bis dahin permanent.
- **Hebt die Blankett-Klausel aus [`MR-000`](../conventions.md#mr-000--baseline-aussage) für diesen Punkt auf**
  — *„keine inhaltlichen Adaptionen ggü. Baseline-Default"*.
  [`MR-000`](../conventions.md#mr-000--baseline-aussage) bleibt unangetastet, seine übrigen Setzungen gelten
  fort.
