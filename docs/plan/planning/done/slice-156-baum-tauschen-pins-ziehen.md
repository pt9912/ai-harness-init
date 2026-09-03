# Slice slice-156: Der vendored Baum zieht auf `v5.18.0` — Tausch und Pins

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-14](../welle-14-re-baseline.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(`<tag>`-Politik: ein Tag zur Zeit, Tag-String hat genau eine Quelle),
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (die Adoptions-Erklärung).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**`.harness/baseline/v5.18.0/` liegt vendored, `v5.12.0` ist fort, und jeder Pin und jeder
Baseline-Pfad im lebenden Bestand zeigt auf den neuen Tag.** Geschnitten aus Position 1 des
Katalogs in [slice-155](../done/slice-155-inventur-vor-dem-schnitt.md) §9 (die Stand-Zeile
des Regelwerk-Index, die `harness/conventions.md` §Baseline zitiert).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **Baum getauscht, Pins gezogen:** `BASELINE_TAG`, `BASELINE_ZIP_SHA256` und der
      `sources`-Pin in [`.d-check.yml`](../../../../.d-check.yml) tragen `v5.18.0`;
      `make baseline-verify` meldet `v5.18.0 OK`, `make regelwerk-check` ist grün.
      **Die Menge der mechanischen Stellen ist größer als die drei genannten** — dazu
      `DefaultTag` und `DefaultBaselineSHA256` in `internal/fetch/baseline.go` (per Test ans
      `Makefile` gekoppelt), die vier Symlinks unter [`.claude/rules/`](../../../../.claude/rules/)
      ([`MR-035`](../../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl))
      und die `files:`-Köpfe von `test/mutations/219` und `220`. Die zwei letzten Klassen führen
      den Tag im **Pfad** und stehen in keiner Pin-Liste.
- [x] **Kein `v5.12.0`-Pfad bleibt im lebenden Bestand** — gemessen statt behauptet, mit dem
      Kommando im Plan; Zeitdokumente (`docs/reviews/**`, `docs/plan/planning/done/**`) und die
      nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefrorenen ADRs bleiben unangetastet.
      **Getragen, und die Restmenge ist zerlegt statt pauschal benannt.** Gate-sichtbar
      (Markdown-Link,
      `grep -cE '\]\([^)]*\.harness/baseline/v5\.12\.0/[^)]*\)' harness/conventions.md`)
      waren **62**, alle in [`harness/conventions.md`](../../../../harness/conventions.md) und
      alle im Adaptions-Block — damit Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8), siehe
      den nächsten Punkt; sie sind gezogen, dasselbe Kommando gibt **0** aus und `make docs-check`
      meldet `505 Datei(en) geprüft, 0 Befund(e)`. Stumm (kein Link,
      `git grep -n 'v5\.12\.0' -- ':!.harness/baseline'
      ':!docs/reviews' ':!docs/plan/planning/done' ':!docs/plan/adr' | grep -vc ']('` → **148**)
      bleibt der Bestand, den
      [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
      regelt; sein Träger ist [slice-165](../open/slice-165-praesens-aussagen-gegen-v5180.md), für
      die **85** in dieser Datei
      [slice-157](../open/slice-157-adaptions-durchgang-v5180.md).
      Keine Erwartungswerte
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2). **Gezogen ist die Menge außerhalb dieser zwei:** 12 Links in
      [`spec/spezifikation.md`](../../../../spec/spezifikation.md), 3 in
      [slice-114](../open/slice-114-jede-aussage-hat-einen-abschnitt.md), 1 in
      [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) — jeder Anker
      einzeln gegen die Zieldatei geprüft, dazu die Substanz der zitierten Aussage; **5** Adressen
      in zwei Zeitdokumenten sind entfallen, während ihr sichtbarer Text Zeichen für Zeichen steht
      ([ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4).
- [x] **Die Adoptions-Erklärung nennt den neuen Stand:**
      [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) und §Baseline
      führen `v5.18.0` samt der Regelwerk-Stand-Zeile des neuen Index. Adaptions-Block heißt
      Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8) — eigener Commit.
- [x] `make gates` grün.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/baseline/` | neu / refactor | der Tausch selbst |
| `Makefile`, `.d-check.yml` | update | die drei Pins |
| `harness/conventions.md` | update | §Baseline und [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) — Architect, eigener Commit |
| lebende Verweise auf `.harness/baseline/v5.12.0/` | update | der Tag steht im Pfad |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-155](../done/slice-155-inventur-vor-dem-schnitt.md)
liegt in `done/` — der Katalog steht, und mit ihm die Menge der Positionen, die dieser Tausch
auslöst.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn das Nachziehen der Baseline-Pfade
  einen eigenen Entscheidungs-Bedarf erzeugt (eingefrorene Adresse in einem `Accepted`-Artefakt,
  Klasse `BEO-017`) — dann trägt den zweiten Teil ein eigener Slice.
- `in-progress` → `open` (blockiert — Carveout?): wenn das Release-Asset des Tags netzlos nicht
  gegen einen zweiten unabhängigen Ladeweg zu belegen ist.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; `make baseline-verify` meldet `v5.18.0 OK`; Closure-Notiz mit
Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Tausch bricht die emittierte Ebene, und `make gates` sieht es nicht** — genau das
  passierte beim letzten Baum-Tausch; sichtbar wurde es allein über `make full-smoke`, das nicht
  in `make gates` läuft (Closure-Trigger von [welle-14](../welle-14-re-baseline.md) §3).
  — **Ausgang: entfallen**, weil die Gegenprobe gefahren ist statt vermutet: `make full-smoke`
  über dem getauschten Baum endet mit **Exit 0** und meldet *„frisch gebootstrapptes Repo faehrt
  make -j gates out-of-the-box gruen"*. Der Unterschied zum letzten Sprung ist inhaltlich und
  nicht glücklich: dort brachte die neue Fassung Vorlagen mit Platzhalter-Links, hier zwei
  Vorlagen ohne. Die **Klasse** bleibt und trägt beim nächsten Sprung dieselbe Pflicht — der
  Beleg ist der Lauf, nicht die Erwartung.
- **Ein Baseline-Pfad in einem eingefrorenen Artefakt wird durch den Tausch tot** — die Klasse
  liegt als `BEO-017` im [Register](../observations.md), erste gemessene Instanz war genau dieser
  Fall. — **Ausgang: weiter offen → `BEO-017`.** Eingetreten ist die Klasse, aber in einer Form,
  die keine der drei bisherigen Instanzen hatte: **stumm**. Vier `Accepted`-ADRs
  ([ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md),
  [ADR-0026](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
  [ADR-0027](../../adr/0027-tote-adresse-in-eingefrorener-adr.md),
  [ADR-0030](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)) nennen
  `.harness/baseline/v5.12.0/…` als **Kommando-Operanden**, deren Pfad seit dem Tausch ins Leere
  zeigt. Gate-sichtbar ist davon **nichts**: die Sonde vor dem Tausch (Baum umbenannt,
  `make docs-check`, zurückbenannt) meldet `503 Datei(en) geprüft, 88 Befund(e)`, alle
  `target-missing`, **null** in `docs/plan/adr/` — `codepaths.roots` in
  [`.d-check.yml`](../../../../.d-check.yml) ist `[spec, docs, harness]`, und `.harness/` liegt
  außerhalb. Damit fällt weg, was die drei Vorgänger je gekostet haben: keine ADR, keine
  Gate-Senkung, kein Folge-Slice. Was bleibt, ist die Zeile im Register — die Klasse zählt weiter,
  und ihre Grenze ist jetzt vermessen.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** Die Provenienz-Kette ist gefahren statt zugesagt — derselbe
  containerisierte Ladeweg reproduziert über `v5.12.0` den bestehenden `BASELINE_ZIP_SHA256`, und
  der vom Produkt-Binär vendorte `v5.12.0`-Baum ist byte-identisch zum bisherigen Bestand. Der
  neue Baum entsteht damit über einen Weg, der an der alten Seite belegt ist. Und der Nachzug der
  Verweise ist **je Ziel** geprüft statt per `sed` über den Tag-String
  ([ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md) Folgepflicht 1): 29 eindeutige Ziele
  hinter 62 Links, 28 lösen am neuen Stand unverändert auf, eines nicht.
- **Was ging anders als geplant:** Der Plan führt drei Pins; getragen haben den Tag **fünf**
  Klassen. Zwei davon nennen ihn im **Pfad** statt als Wert — die vier `.claude/rules/`-Symlinks
  und die `files:`-Köpfe zweier Mutations-Fälle — und keine Pin-Liste kennt sie. Und der
  Diff-Katalog aus [slice-155](../done/slice-155-inventur-vor-dem-schnitt.md) §9 hat jeder
  geänderten **Position** einen Träger gegeben, nicht jedem **Konsumenten** einer Position: die
  zwei neuen Vorlagen gingen an [slice-158](../open/slice-158-archivierungs-schritt.md), während
  der Emitter sie in keiner seiner Listen führt und `test/courseset-fixture.bats` an drei Fällen
  rot steht. Beim toten Anker trennt sich zudem, was der Plan als eine Aufgabe führte: die
  **Adresse** ist mechanisch, die **Substanz** nicht — der umbenannte Abschnitt trägt die von
  [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)
  zitierte Zeile nicht mehr, und welchen der fünf Ausgänge das dem Eintrag gibt, entscheidet
  [slice-157](../open/slice-157-adaptions-durchgang-v5180.md).
- **Steering-Loop-Eintrag:** Sensor benannt, nicht gebaut — der **Pin-Sensor für lebende
  Artefakte** aus [ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md) §Fitness Function
  (Kandidat 2): *jede Zeichenkette `.harness/baseline/<X>/` in einem lebenden Artefakt erfüllt
  `<X> == BASELINE_TAG`*. Sein Gegenbeispiel ist genau der Zustand zwischen Tausch und Nachzug,
  und dieser Slice hat ihn zweimal durchlaufen — erst mit 62 `target-missing`, dann mit den
  stummen Nennungen, die kein Gate sieht. Träger ist
  [slice-162](../open/slice-162-versions-sensor-baseline-pins.md).
  Auslöser: `BEO-017` (slice-154, slice-156 — 2×, unter der Schwelle).
- **Beobachtungs-Register (`../observations.md`):** `BEO-017` auf 2× erhöht, Beleg `slice-156`
  ergänzt. Die Zeile trägt jetzt die **stumme** Unterform: vier `Accepted`-ADRs nennen
  `.harness/baseline/v5.12.0/…` als Kommando-Operanden, deren Pfad seit dem Tausch ins Leere
  zeigt, und `codepaths.roots` der [`.d-check.yml`](../../../../.d-check.yml) ist
  `[spec, docs, harness]` — `.harness/` liegt außerhalb, also meldet kein Gate sie.
- **Folge-Slices:** [slice-164](../done/slice-164-emitter-klassifiziert-die-zwei-neuen-vorlagen.md)
  (Emitter-Klassifikation der zwei neuen Vorlagen) ·
  [slice-165](../open/slice-165-praesens-aussagen-gegen-v5180.md) (die stummen Nennungen und ihr
  [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)-Ausgang)
  — beide Dateien im Planning-Lifecycle, beide Mitglieder von [welle-14](../welle-14-re-baseline.md) §4.
- **Risiken aus §6:** zwei, je genau ein Ausgang — *entfallen* (emittierte Ebene, mit
  `full-smoke`-Lauf) · *weiter offen → `BEO-017`* (eingefrorene Adresse, stumme Unterform).
- **Drei Paarungen:** dieses Repo führt Wellen-Betrieb — die Paarungen prüft die Closure von
  [welle-14](../welle-14-re-baseline.md).

### Was der Architect-Anteil geliefert hat ([`AGENTS.md`](../../../../AGENTS.md) §3.8)

Ein eigener Commit, nur Architect-Artefakte, Rolle in der Message. Gemessen, nicht geschätzt:

1. **DoD 3 getragen** — [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage),
   §Baseline und §Adoptierte Konventions-Quellen von
   [`harness/conventions.md`](../../../../harness/conventions.md) nennen `v5.18.0` samt der
   Stand-Zeile des neuen Regelwerk-Index (**Kurs-Welle 111 · 2026-08-31**,
   `sed -n '3p' .harness/baseline/v5.18.0/regelwerk/README.md`). Die zwei von [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) zitierten
   Belege sind gegen den neuen Stand **nachgemessen** und stehen dort.
2. **DoD 2, gate-sichtbare Hälfte, getragen** — alle 62 Markdown-Links dieser Datei zeigen auf
   `v5.18.0`; `make docs-check` meldet `505 Datei(en) geprüft, 0 Befund(e)`, und im lebenden
   Bestand bleibt kein `v5.12.0`-Link
   (`git grep -cE '\]\([^)]*\.harness/baseline/v5\.12\.0/[^)]*\)' -- ':!docs/reviews' ':!docs/plan/planning/done' ':!docs/plan/adr'`
   → leer). **Der eine tote Anker ist korrigiert:**
   `grundlagen-durchsetzungsschicht.md#referenz-implementierung` heißt am neuen Stand
   §Das vollständige Artefakt-Set; beide Nennungen
   ([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks),
   [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption))
   tragen Anker und Abschnittsnamen gemeinsam. Die von [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption) zitierte Zeile führt der neue
   Baum **nicht** (`grep -rc 'tools/harness' .harness/baseline/v5.18.0/regelwerk/ .harness/baseline/v5.18.0/templates/`
   → keine Nicht-Null-Zeile); das Zitat steht als Tree-Operand nach
   [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
   Ausgang 2, den Ausgang des Eintrags entscheidet
   [slice-157](../open/slice-157-adaptions-durchgang-v5180.md).
   Die **stumme** Hälfte bleibt stehen — 148 Nennungen im lebenden Bestand, davon 85 in dieser
   Datei (`git grep -n 'v5\.12\.0' -- ':!.harness/baseline' ':!docs/reviews'
   ':!docs/plan/planning/done' ':!docs/plan/adr' | grep -vc ']('`, dasselbe auf die Datei
   eingeschränkt; keine Erwartungswerte,
   [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 2): sie sind datierte Mess-Zeitbezüge nach
   [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
   und Gegenstand von [slice-157](../open/slice-157-adaptions-durchgang-v5180.md) bzw.
   [slice-165](../open/slice-165-praesens-aussagen-gegen-v5180.md).
3. **Der `ignore-refs`-Eintrag zu `v3.5.2`** in [`.d-check.yml`](../../../../.d-check.yml) ist von
   diesem Tausch **nicht** berührt und bleibt gültig — er nennt einen Baum, den schon der letzte
   Sprung ablöste. [ADR-0026](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md)
   §Re-Evaluierungs-Trigger sagt für den neuen abgelösten Tag ausdrücklich, dass ein Eintrag für
   ihn von jener Entscheidung nicht gedeckt wäre; **gebraucht wird keiner** (Befund 2 war
   reparierbar, nicht eingefroren).

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die Modus-Deklaration
in [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
führt für den vendored Baum keine engere.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-017` (Zähler-Stand siehe
[Register](../observations.md)) steht als Risiko in §6; `BEO-010` und `BEO-011` tragen den
Zuschnitt dieser Welle und sind dort verbucht. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
