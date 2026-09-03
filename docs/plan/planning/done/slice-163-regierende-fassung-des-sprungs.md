# Slice slice-163: Die regierende Fassung des Sprungs `v5.12.0` → `v5.18.0` — und wo eine Zielstand-Setzung künftig steht

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-14](../welle-14-re-baseline.md) — er löst die offene Übergabe aus deren §5.

**Bezug:** [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (Festlegung 3, zweiter
Fall — die Wahl ist offen und in diesem Sprung begründet zu entscheiden; ihr erster
Re-Evaluierungs-Trigger sagt dasselbe),
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) (die Wahl der normativen Quelle
ist eine Architektur-Frage), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Welche Regelwerks-Fassung den Sprung `v5.12.0` → `v5.18.0` regiert, steht auf Rang 4 der Source
Precedence — und mit ihr der Ort, an dem eine künftige Zielstand-Setzung samt Delta-Nachweis
wohnt.**

Die Messung liegt vor und ist in
[slice-155](../done/slice-155-inventur-vor-dem-schnitt.md) §9 belegt: **beide** Fassungen
führen die Migrations-Prozedur — der Abschnitt §Freshness-Audit der vendored Baseline (Schritt 2)
ist zwischen den Tags byte-gleich. Damit greift der **zweite** Fall von
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 3, und die Wahl ist
neu zu begründen. Dass die praktische Differenz null ist, hebt die Begründungspflicht nicht auf —
jene ADR nennt sie selbst als Preis ihrer Zurückhaltung.

Der zweite Posten hängt daran: §Geschichte jener ADR ist mit ihrer Annahme geschlossen, jede
weitere Bewegung des Zielstands ist eine Folge-ADR mit `Supersedes`. Die Setzung, die
[welle-14](../welle-14-re-baseline.md) trägt, hat damit heute keinen Ort, an dem sie mit
Delta-Nachweis stünde.

**Dieser Slice ist Architect-Arbeit** — die Wahl der normativen Quelle ist eine Architektur-Frage,
und [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) §Verglichene Alternativen
verwirft Option A — sie im Wellenplan zu halten — ausdrücklich.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **Die regierende Fassung dieses Sprungs ist entschieden und begründet**, auf Rang 4 der
      Source Precedence — als Folge-ADR mit `Supersedes` auf
      [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) oder als eigenständige
      ADR, die deren Festlegung 3 anwendet statt sie zu ändern
      ([`AGENTS.md`](../../../../AGENTS.md) §3.4). Die Messung wird **zitiert**, nicht wiederholt.
- [x] **Der Ort einer künftigen Zielstand-Setzung ist benannt** — samt der Frage, welchen
      Beleg-Mindestumfang sie trägt. Bleibt die Frage offen, steht **das** als Aussage da, nicht
      als Lücke.
- [x] `make gates` grün.
- [x] Doku-Update: der ADR-Index ist fortgeschrieben ([`AGENTS.md`](../../../../AGENTS.md) §5).
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
| `docs/plan/adr/` | neu | die Entscheidung |
| [`docs/plan/adr/README.md`](../../adr/README.md) | update | der Index — Architect-Artefakt derselben Rolle |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-155](../done/slice-155-inventur-vor-dem-schnitt.md)
liegt in `done/` — die Messung nach Festlegung 3 ist gefahren und belegt, und ohne sie hätte die
Entscheidung keine Grundlage.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der zweite Posten — der Ort einer
  Zielstand-Setzung samt Beleg-Mindestumfang — eine eigene Abwägung verlangt, die die erste nicht
  trägt. Dann sind es zwei ADRs und zwei Slices.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Entscheidung eine Setzung des
  Auftraggebers voraussetzt, die nicht vorliegt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; die Entscheidung steht als ADR im Index; Closure-Notiz mit
Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Entscheidung wird zur Formalie, weil die praktische Differenz null ist** — beide
  Fassungen führen denselben Wortlaut. Eine ADR, die nur feststellt, dass es egal ist, verbraucht
  einen Rang-4-Platz; eine, die es *nicht* feststellt, lässt die Pflicht ungelöst. —
  **Ausgang: entfallen**, gemessen statt vermutet: Der Wortlaut ist byte-gleich, die **Regel**
  ist es nicht. Der Abschnitt delegiert vier Fragen in Dateien mit Delta
  (`grundlagen-harness-dateien.md` **17** geänderte Zeilen, drei weitere je **2**), und eine
  dieser 17 ändert genau die delegierte Pflichtgliederung für
  [`harness/conventions.md`](../../../../harness/conventions.md). Die Kommandos stehen in
  [ADR-0031](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) §Kontext; die
  Klasse liegt als `BEO-019` im [Register](../observations.md).
- **Eine `Accepted`-ADR wird angefasst statt abgelöst** —
  [`AGENTS.md`](../../../../AGENTS.md) §3.4 und dieselbe Regel in der Baseline verbieten das;
  §Geschichte von [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) sagt zu
  genau dieser Bahn, dass ab *Accepted* nur die Folge-ADR bleibt. —
  **Ausgang: entfallen.** Jene Datei ist byte-unverändert
  (`git diff <vor diesem Slice>..HEAD -- docs/plan/adr/0018-*.md` → leer), und
  [ADR-0031](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) trägt kein
  `Supersedes`: Sie wendet deren Festlegung 3 an, statt sie zu ändern — genau der Weg, den jene
  Festlegung für ihren zweiten Fall vorsieht.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** Die Messung, auf der die Entscheidung steht, ist in diesem Lauf noch
  einmal selbst gefahren statt aus [slice-155](../done/slice-155-inventur-vor-dem-schnitt.md) §9
  übernommen — beide Fassungen des Abschnitts extrahiert, `diff` leer, je 123 Zeilen. Das kostete
  zwei Kommandos und trug die Entscheidung: erst beim eigenen Lesen fiel auf, dass der Abschnitt
  **delegiert**, und genau daran hängt Festlegung 1.
- **Was ging anders als geplant:** §6 nahm an, die Entscheidung werde zur Formalie, weil die
  praktische Differenz null sei. Sie ist nicht null. Der byte-gleiche Abschnitt verweist für vier
  Fragen in andere Dateien seines Baums, und eine davon — `grundlagen-harness-dateien.md`, 17
  geänderte Zeilen — ändert genau die Pflichtgliederung, die er für
  [`harness/conventions.md`](../../../../harness/conventions.md) abfragt. Die Wahl hat damit eine
  Wirkung, und der zweite Grund kam beim Lesen des Welle-Schnitts dazu: der Tausch liegt **vor**
  den Durchgängen, also ist die gepinnte Fassung ab
  [slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md) gar nicht mehr vendored. Und der
  zweite Posten fiel kleiner aus als die Rückführungs-Bedingung in §4 befürchtete: der Ort einer
  Zielstand-Setzung brauchte keine zweite ADR, weil dieselbe Abwägung ihn trägt —
  [ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md) §*Wer den Zielstand bewegt*
  benennt ihn als offene Frage derselben Entscheidung.
- **Steering-Loop-Eintrag:** neue Beobachtung statt geschärfter Regel — *eine Byte-Gleichheits-
  Messung an einem Abschnitt ist keine Aussage über die Regel, die er stellt*, weil der Abschnitt
  delegiert. Angelegt als `BEO-019` im [Register](../observations.md), mit der gemessenen
  Reichweite: sieben ADRs schließen einen Delta-Nachweis über Byte-Gleichheit tragender Quellen.
  Verkörpert ist damit nichts — der Eintrag ist gezählt, nicht verkörpert, und wartet auf 3×.
- **Beobachtungs-Register (`../observations.md`):** neue `BEO-019` angelegt (`*` (gesamtes Repo),
  1×, Beleg `slice-163`). **Nicht** erhöht wurden die zwei in §8 gesichteten Einträge, und beides
  mit Grund: `BEO-011` (gesammelte Sprünge) berührt der Slice, ohne sie zu beobachten — die
  Adoptions-Rhythmus-Frage bleibt offen und ist von
  [ADR-0031](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) ausdrücklich
  nicht entschieden. `BEO-017` (eingefrorene Adresse) trat nicht auf: die neue ADR führt **keinen**
  Markdown-Link in den vendored Baum
  (`grep -cE '\]\([^)]*\.harness/baseline/[^)]*\)' docs/plan/adr/0031-*.md` → **0**), und ihre
  sechs Nennungen des Verzeichnisses sind Kommando-Operanden, die
  [ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 als *Gegenstand der
  Sonde* zulässt.
- **Folge-Slices:** keine. Die Entscheidung ist vollständig in der ADR, und ihre einzige
  Folgepflicht — die Zeile in §Baseline — ist im selben Architect-Commit eingelöst.
- **Offene Übergabe an den Planner:** Die ADR steht auf `Proposed`. Wer eine ADR annimmt, sagt
  keine Quelle dieses Repos ([ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md)
  §Geschichte hat das gemessen), und dieser Lauf hat keine Einwilligung des Auftraggebers. Ein
  Annahme-Trigger braucht einen Träger — dieselbe Lage wie bei
  [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (Träger
  [slice-145](../done/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md)) und
  [ADR-0029](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) (Träger
  [slice-152](../open/slice-152-adr-0029-acceptance-trigger.md)). Das Schneiden dieses Slice ist
  Planner-Arbeit und steht hier als Übergabe, nicht als Folge-Slice-ID.
- **Risiken aus §6:** zwei, je genau ein Ausgang. *„Die Entscheidung wird zur Formalie"* —
  **entfallen**, und zwar gemessen statt vermutet: die praktische Differenz ist nicht null (vier
  delegierte Abschnitte mit Delta, einer davon an der delegierten Pflichtgliederung). *„Eine
  `Accepted`-ADR wird angefasst statt abgelöst"* — **entfallen**:
  [ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md) ist byte-unverändert
  (§6 nennt das Kommando), und die neue ADR trägt kein `Supersedes`
  — sie wendet deren Festlegung 3 an, statt sie zu ändern.
- **Drei Paarungen:** dieses Repo führt Wellen-Betrieb — die Paarungen prüft die Closure von
  [welle-14](../welle-14-re-baseline.md).

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — eine Entscheidung über
die normative Quelle eines Vorgangs liegt in keiner engeren Sub-Area der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area).

**Vorgelagert — offene Beobachtungen sichten:** `BEO-011` (gesammelte Sprünge kosten
überproportional) berührt den zweiten Posten — ihre Zeile nennt die Frage nach dem
Adoptions-Rhythmus ausdrücklich als Architect-Sache und verwandt mit
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) §*Wer den Zielstand bewegt*.
Ob dieser Slice sie mitnimmt, entscheidet er; sie ist die verwandte Frage, nicht dieselbe.
`BEO-017` (eingefrorene Adresse) berührt die Verweis-Form der neuen ADR. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
