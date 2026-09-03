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
- [ ] **Kein `v5.12.0`-Pfad bleibt im lebenden Bestand** — gemessen statt behauptet, mit dem
      Kommando im Plan; Zeitdokumente (`docs/reviews/**`, `docs/plan/planning/done/**`) und die
      nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefrorenen ADRs bleiben unangetastet.
      **Offen, und die Restmenge ist zerlegt statt pauschal benannt.** Gate-sichtbar (Markdown-Link,
      `git grep -oE '\]\([^)]*\.harness/baseline/v5\.12\.0/[^)]*\)' -- ':!.harness/baseline' | wc -l`)
      bleiben **62**, alle in [`harness/conventions.md`](../../../../harness/conventions.md) und
      alle im Adaptions-Block — damit Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8), siehe
      den nächsten Punkt. Stumm (kein Link, `git grep -n 'v5\.12\.0' -- ':!.harness/baseline'
      ':!docs/reviews' ':!docs/plan/planning/done' ':!docs/plan/adr' | grep -vc ']('` → **148**)
      bleibt der Bestand, den
      [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
      regelt; sein Träger ist [slice-165](../open/slice-165-praesens-aussagen-gegen-v5180.md).
      Keine Erwartungswerte
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2). **Gezogen ist die Menge außerhalb dieser zwei:** 12 Links in
      [`spec/spezifikation.md`](../../../../spec/spezifikation.md), 3 in
      [slice-114](../open/slice-114-jede-aussage-hat-einen-abschnitt.md), 1 in
      [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) — jeder Anker
      einzeln gegen die Zieldatei geprüft, dazu die Substanz der zitierten Aussage; **5** Adressen
      in zwei Zeitdokumenten sind entfallen, während ihr sichtbarer Text Zeichen für Zeichen steht
      ([ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4).
- [ ] **Die Adoptions-Erklärung nennt den neuen Stand:**
      [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) und §Baseline
      führen `v5.18.0` samt der Regelwerk-Stand-Zeile des neuen Index. Adaptions-Block heißt
      Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8) — eigener Commit.
- [ ] `make gates` grün.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

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

**Noch nicht geschrieben — der Slice liegt in `in-progress/`.** Was hier steht, ist der Stand des
Tausch-Laufs; die Closure folgt, wenn DoD 2 und 3 getragen sind. Der Register-Eintrag entsteht
**bei** der Closure und nicht davor: der Beleg ist formgebunden an eine Datei in `done/`
(Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register, Lage-Prüfung).

- **Was hat funktioniert:** Die Provenienz-Kette ist gefahren statt zugesagt — derselbe
  containerisierte Ladeweg reproduziert über `v5.12.0` den bestehenden `BASELINE_ZIP_SHA256`, und
  der vom Produkt-Binär vendorte `v5.12.0`-Baum ist byte-identisch zum bisherigen Bestand. Der
  neue Baum entsteht damit über einen Weg, der an der alten Seite belegt ist.
- **Was ging anders als geplant:** Der Plan führt drei Pins; getragen haben den Tag **fünf**
  Klassen. Zwei davon nennen ihn im **Pfad** statt als Wert — die vier `.claude/rules/`-Symlinks
  und die `files:`-Köpfe zweier Mutations-Fälle — und keine Pin-Liste kennt sie. Und der
  Diff-Katalog aus [slice-155](../done/slice-155-inventur-vor-dem-schnitt.md) §9 hat jeder
  geänderten **Position** einen Träger gegeben, nicht jedem **Konsumenten** einer Position: die
  zwei neuen Vorlagen gingen an [slice-158](../open/slice-158-archivierungs-schritt.md), während
  der Emitter sie in keiner seiner Listen führt und `test/courseset-fixture.bats` an drei Fällen
  rot steht.
- **Steering-Loop-Eintrag:** *(offen — wird bei der Closure geschrieben.)*
- **Beobachtungs-Register (`../observations.md`):** *(offen — vorgesehen: `BEO-017` auf 2×
  erhöht, Beleg `slice-156`, mit der gemessenen stummen Unterform; dazu die Frage, ob die zwei
  Nachzügler `slice-164`/`slice-165` `BEO-010` auf 3× bringen — darüber urteilt die Closure von
  [welle-14](../welle-14-re-baseline.md), nicht dieser Lauf.)*
- **Folge-Slices:** [slice-164](../open/slice-164-emitter-klassifiziert-die-zwei-neuen-vorlagen.md)
  (Emitter-Klassifikation der zwei neuen Vorlagen) ·
  [slice-165](../open/slice-165-praesens-aussagen-gegen-v5180.md) (die stummen Nennungen und ihr
  [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)-Ausgang)
  — beide Dateien in `open/`, beide Mitglieder von [welle-14](../welle-14-re-baseline.md) §4.
- **Risiken aus §6:** zwei, je genau ein Ausgang — *entfallen* (emittierte Ebene, mit
  `full-smoke`-Lauf) · *weiter offen → `BEO-017`* (eingefrorene Adresse, stumme Unterform).
- **Drei Paarungen:** dieses Repo führt Wellen-Betrieb — die Paarungen prüft die Closure von
  [welle-14](../welle-14-re-baseline.md).

### Offen für den Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8)

Ein eigener Commit, nur Architect-Artefakte, Rolle in der Message. Gemessen, nicht geschätzt:

1. **DoD 3** — [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) und
   §Baseline von [`harness/conventions.md`](../../../../harness/conventions.md) nennen `v5.18.0`
   samt der Stand-Zeile des neuen Regelwerk-Index
   (`head -20 .harness/baseline/v5.18.0/regelwerk/README.md`).
2. **62 Markdown-Links** in derselben Datei, alle im Adaptions-Block, zeigen in den abgelösten
   Baum. `make docs-check` → `503 Datei(en) geprüft, 62 Befund(e)`, und **jeder** Befund liegt
   dort. **Einer der Anker ist tot und nicht bloß der Tag:**
   `grundlagen-durchsetzungsschicht.md#referenz-implementierung` — die Überschrift heißt am neuen
   Stand *Das vollständige Artefakt-Set* (Position 3 des Katalogs, dort
   [slice-157](../open/slice-157-adaptions-durchgang-v5180.md) zugeordnet). Die übrigen 35 Ziele
   lösen auf; drei davon über explizite `<a id="">`-Anker statt über die Überschrift.
3. **Der `ignore-refs`-Eintrag zu `v3.5.2`** in [`.d-check.yml`](../../../../.d-check.yml) ist von
   diesem Tausch **nicht** berührt und bleibt gültig — er nennt einen Baum, den schon der letzte
   Sprung ablöste. [ADR-0026](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md)
   §Re-Evaluierungs-Trigger sagt für den neuen abgelösten Tag ausdrücklich, dass ein Eintrag für
   ihn von jener Entscheidung nicht gedeckt wäre; **gebraucht wird keiner** (Befund 2 ist
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
