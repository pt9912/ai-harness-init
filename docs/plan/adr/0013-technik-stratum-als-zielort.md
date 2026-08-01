# ADR-0013: Fortschreibbare technische Festlegungen leben im Technik-Stratum, nicht im Adaptions-Block

**Status:** Accepted

**Datum:** 2026-08-01

**Autor:** ai-harness-init-Team (pt9912)

**Bezug:**
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (der emittierte
**Doc-Chain** trägt alle drei Spec-Straten — die Zusage, die das Werkzeug an jedes Zielrepo
gibt und die der Dogfood bis hierher nicht einlöste),
[`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)
(*„der Gate-Config wächst mit den Artefakten"* — die Regel, unter der die neue Spec-Datei ihre
`matrix`-Klasse bekommt),
[ADR-0011](0011-telemetrie-erfassung-policy.md) (**Accepted** — Festlegung 1 begründet, warum
die Feldtabelle nicht in der ADR steht; ihre Folgepflichten 1 und 2 nennen dafür Zielorte, die
diese ADR ersetzt)

**Revidiert (Teil-Supersede):** die **Zielort-Setzungen der Folgepflichten 1 und 2** von
[ADR-0011](0011-telemetrie-erfassung-policy.md) — *„das Span-Schema … wird als `MR-<NNN>` in
`harness/conventions.md` geführt"* und, für die Abweichungs-Begründungen, *„steht in diesem
`MR`-Eintrag"*: derselbe Ort für denselben Gegenstand, er wechselt für beide oder für keine.
**Nicht** revidiert ist, was daneben steht: die **Begründung** von Folgepflicht 1 (*„es ist
eine Strukturregel, kein Implementierungsdetail, und der nächste Leser muss es ohne Code
finden"*), das Verbot aus Folgepflicht 2 (*„nicht in einem Kommentar"*) und mit ihnen jede
übrige Setzung von [ADR-0011](0011-telemetrie-erfassung-policy.md): die sechs Festlegungen,
die Fitness Function und die Folgepflichten 3–5 bleiben unberührt und **Accepted**. Weil
[`AGENTS.md`](../../../AGENTS.md) §3.4 nur den **Voll**-Supersede kennt, wird die Teil-Revision
**im ADR-Index an [ADR-0011](0011-telemetrie-erfassung-policy.md) annotiert** — derselbe Weg,
den [ADR-0006](0006-durchsetzung-commands-tool-als-quelle.md) für
[ADR-0004](0004-durchsetzungs-emission.md) und
[ADR-0009](0009-hexslice-arch-realisierung.md) für
[ADR-0008](0008-arch-achse-emittiertes-skelett.md) gegangen ist. So kann kein Slice die
revidierten Zielort-Setzungen als aktiv zitieren.

**Schärft:** [`spezifikation.md §5 Metriken und Tracing-Felder`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
und [`§3 Defaults und Konstanten`](../../../spec/spezifikation.md#3-defaults-und-konstanten).
Aufwärts-Deklaration: wer diese ADR ändert, zieht beide nach — Zielort, nicht Fundort.

---

## Kontext

Der Kurs kennt drei Spec-Straten — **Vertrag** › **Technik** › **Sicht** — und stellt frei, das
mittlere zu führen: *„Nur Vertrag und Sicht sind obligatorisch; das Technik-Stratum ist
optional"*
([`grundlagen-konventionen.md` §Spec-Straten](../../../.harness/baseline/v3.5.2/regelwerk/grundlagen-konventionen.md#spec-straten-mehr-als-ein-spec-dokument)).
Dieses Repo hat es bis zum 2026-08-01 nicht geführt; die Freistellung war eine Wahl, und diese
ADR bewertet ihre Folgen.

**Wohin die technischen Festlegungen stattdessen liefen** (gemessen 2026-08-01 am Stand
`5200da6` über die Blockgrenzen `grep -nE '^### MR-[0-9]{3}|^## Modus-Deklaration'`): ein
**einziger** Eintrag des Adaptions-Blocks trägt **824** Zeilen — mehr als **alle übrigen
zusammen** (801 in achtzehn Einträgen). Am 2026-07-28 waren es **47**; von den 803 Zeilen
Dateiwachstum seither entfielen **777** auf ihn. Er ist die Feldtabelle der Span-Erfassung
samt ihren erklärten Abweichungen.

**Der Bestand hat seine eigene Regel hergeleitet und das falsche Gefäß genommen.**
[ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 1 sagt, warum die Tabelle nicht in
der ADR steht: sie *„wächst mit jedem Feld, das seine Incident-Frage verdient — eine ab
Accepted immutable ADR ist der falsche Ort dafür"*. Das ist wortgleich das Kriterium, mit dem
der Kurs das Technik-Stratum vom Vertrags-Stratum trennt (*„technisch verbindlich,
fortschreibbar"* gegen *„vertraglich abnahmebindend"*). Die Folgerung war richtig, das Ziel
nicht: Folgepflicht 1 schickte die Tabelle in den Adaptions-Block, weil das der einzige Ort
war, an dem Fortschreiben ausdrücklich erlaubt ist.

**Der Adaptions-Block ist für diesen Inhalt aus zwei gemessenen Gründen das falsche Gefäß.**
Erstens steht er in **keiner** der beiden Precedence-Listen des Repos
([`AGENTS.md`](../../../AGENTS.md) §2, [`harness/README.md`](../../../harness/README.md)
§Source precedence führen ihn beide nicht) — eine bindende technische Festlegung lag damit in
einem ungerangten Dokument. Zweitens ist sein Gegenstand ein anderer: er registriert
**Abweichungen von der adoptierten Baseline**. Die Feldtabelle weicht von nichts ab; sie *ist*
die Festlegung.

**Was sich seit [ADR-0011](0011-telemetrie-erfassung-policy.md) geändert hat:** das Gefäß
existiert. `spec/spezifikation.md` ist angelegt, als Rang 2 gerangt und als Technik-Stratum
deklariert; die Deklaration verlangt der Kurs an genau dieser Stelle und nennt ein
undeklariertes Spec-Dokument *„nicht normativ zitierbar"*. Damit sind die Zielorte aus den
Folgepflichten nicht mehr alternativlos, sondern die zweitbeste von zwei Möglichkeiten.

**Annahme, auf der diese ADR steht:** die Feldtabelle und ihre erklärten Abweichungen sind
technische Festlegungen dieses Repos und keine Abweichungen von der Baseline. Kippt das — etwa
weil eine Abweichung sich als Regelwerks-Delta und nicht als eigene Festlegung erweist —, so
gehört **dieser** Posten in den Adaptions-Block und nicht ins Stratum; die Entscheidung gilt
dann für den Rest.

## Entscheidung

**Wir wählen Option C: Teil-Revision.** Der Zielort aus
[ADR-0011](0011-telemetrie-erfassung-policy.md) Folgepflichten 1 und 2 wechselt vom
Adaptions-Block ins Technik-Stratum; die Vorgängerin bleibt im Übrigen **Accepted** und
unangetastet. Drei Festlegungen:

1. **Der Zielort ist `spec/spezifikation.md`.** Die Feldtabelle der Span-Erfassung (Feld ·
   Pflicht/Optional · Incident-Frage) und die je Abweichung vom Pflicht-Minimum geschuldete
   Begründung leben in §5; Werte, die als Schranke oder Default fest sind, in §3. Die
   **Begründung** von Folgepflicht 1 bleibt tragend und wird durch den Wechsel erfüllt, nicht
   aufgehoben: der Leser findet das Schema ohne Code — jetzt in einer Quelle, die einen Rang
   hat.
2. **Was nicht mitwandert, wandert nicht.** Ins Stratum geht ausschließlich, was seine
   Aufnahme-Regel trifft. Die **Begründung** einer Entscheidung bleibt in der Entscheidung; die
   **Abweichung von der Baseline** bleibt im Adaptions-Block; der **Prozess-Zustand** (wer
   trägt was, was ist offen) gehört in keinen von beiden. Ein Umzug, der diese Trennung nicht
   zieht, verlagert das Problem, statt es zu lösen.
3. **Die Aufwärts-Regel gilt ab der ersten Zeile.** Der bindende Text des Stratums trägt
   **keine** Entscheidungs- und keine Planungs-Kennung; Provenienz lebt allein in seiner
   Historie-Tabelle. Das ist keine Stilfrage: ein Abwärts-Zeiger rottet, sobald eine ADR
   abgelöst wird, und die Auffindbarkeit läuft ohnehin über das `Schärft:`-Feld der ADR. Der
   Doku-Gate hält die Regel **unvollständig** — wie weit, steht bei der Fitness Function.

**Diese ADR verschiebt keinen Bestand.** Sie entscheidet den Zielort. Wer welchen Satz wohin
bewegt, ist Planungs- und Umsetzungsarbeit mit eigenem Diff — sie mit der Entscheidung zu
mischen, machte im Review eine **Korrektur** von einer **Entfernung** ununterscheidbar
([`AGENTS.md`](../../../AGENTS.md) §3.3 in der Sache).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **nichts tun**: Folgepflicht 1 bleibt, der Eintrag wächst weiter | kein Aufwand; der Text steht schon | die oben gemessene Kurve ist der Gegenbeweis (47 → 824 Zeilen in vier Tagen, 777 von 803 Zeilen Dateiwachstum). Der Inhalt bleibt in einem Dokument ohne Precedence-Rang, das jeder Agentenlauf mitliest — und die Regel, die ihn dort hält, ist eine Folgepflicht, deren eigene Begründung auf ein anderes Gefäß zeigt |
| B — **Voll-Supersede** von [ADR-0011](0011-telemetrie-erfassung-policy.md) | der von [`AGENTS.md`](../../../AGENTS.md) §3.4 wörtlich genannte Weg; keine Auslegung nötig | er erklärt sechs geltende Festlegungen für abgelöst, um **zwei** Folgepflichten zu ersetzen — die Entscheidung selbst hat sich nicht geändert. Und er bricht, was von ihr abhängt: eine Slice darf *„nur aktive ADRs"* normativ referenzieren, und der Doku-Gate verbietet Verweise auf `superseded` (`matrix.status.forbidden`). Der Preis ist ein Vielfaches des Nutzens |
| D — **den Eintrag im Adaptions-Block kürzen** statt seinen Inhalt zu verlagern | fasst keine ADR an; die Byte-Achse ist mechanisch messbar | es behandelt die Größe, nicht die Zuständigkeit: die Feldtabelle bliebe in einem ungerangten Dokument, dessen Gegenstand Abweichungen von der Baseline sind. Der nächste Sensor müsste eine Schranke gegen die Sache verteidigen, die dort legitim wächst |
| **C — Teil-Revision, Zielort wechselt ins Technik-Stratum (gewählt)** | die Vorgängerin bleibt vollständig gültig; nur die revidierten Sätze verlieren ihre Wirkung, und der Index sagt, welche. Der Inhalt bekommt ein Gefäß, dessen Änderungs-Prozess zu ihm passt und das einen Precedence-Rang trägt | [`AGENTS.md`](../../../AGENTS.md) §3.4 nennt diesen Weg nicht — er steht in der Kurs-Fassung der Hard Rule (*„der abgelösten **oder geschärften** Vorgängerin"*) und lebt im Repo als zweimal angewandte Praxis. Wer nur §3.4 liest, findet ihn nicht; die Auffindbarkeit hängt am ADR-Index, nicht an der revidierten ADR selbst — die darf nicht darauf zeigen |

## Konsequenzen

- **Positiv:** die technische Festlegung bekommt ein Gefäß, dessen Änderungs-Prozess sie
  erlaubt (fortschreibbar ohne Vertragsänderung) und das einen Rang in der Source Precedence
  trägt. Der Adaptions-Block bekommt seinen Gegenstand zurück.
- **Positiv:** das `Schärft:`-Feld hat wieder ein Ziel. Vor dieser ADR gab es im Repo genau
  zwei Entscheidungen mit `Schärft: —`, beide mit derselben Begründung *„ohne Spec-Stratum"* —
  und beide sind die, deren Inhalt in den Adaptions-Block gewachsen ist. Das war kein Zufall,
  sondern dasselbe fehlende Gefäß, zweimal gesehen.
- **Negativ, und das ist der Preis:** eine ab *Accepted* immutable ADR trägt jetzt zwei
  Folgepflichten, deren Zielort nicht mehr gilt, und **darf es nicht sagen**. Wer
  [ADR-0011](0011-telemetrie-erfassung-policy.md) allein liest, liest eine überholte Anweisung.
  Dagegen steht der Index und sonst nichts — kein Sensor prüft, ob ein Leser ihn konsultiert
  hat. Das ist die Kante der Immutabilität und keine Nachlässigkeit dieser ADR; sie wird
  benannt, nicht geschlossen.
- **Negativ:** der Umzug kostet mehr als ein Verschieben. Der bindende Text des Stratums darf
  keine Entscheidungs- und keine Planungs-Kennung tragen — der heutige Bestand tut es an vielen
  Stellen. Jede solche Stelle ist einzeln zu entscheiden: Zeiger streichen, Aussage umformen
  oder Posten anderswohin geben.
- **Folgepflicht 1 — der Umzug ist Planungsarbeit und braucht ein Inventar.** Wer den Bestand
  bewegt, entscheidet posten-weise nach der Aufnahme-Regel und zählt nach, dass kein Posten
  still verschwindet. Der Wortlaut einer bindenden Aussage wird beim Umzug **nicht**
  mitkorrigiert; was dabei als falsch auffällt, wird benannt und getrennt behoben.
- **Folgepflicht 2 — keine Zusage verliert ihren Sensor.** Der heutige Eintrag bindet
  Zusicherungen an namentlich genannte Wächter. Steht eine solche Bindung nach dem Umzug
  nirgends mehr, ist die Zusage unbewacht ([`AGENTS.md`](../../../AGENTS.md) §3.6) — nachzählen
  gegen den Ist-Bestand, nicht behaupten.
- **Folgepflicht 3 — die emittierte Ebene bleibt unberührt, und das ist eine Entscheidung.**
  Das Zielrepo bekommt `spec/spezifikation.md` bereits aus der vendored Vorlage, und seine
  emittierten Briefings rangen es bereits als Rang 2. An der Emission ändert sich **nichts**.
  Insbesondere wandert die `matrix`-Klasse unten **nicht** mit: die emittierte Gate-Config
  fährt heute `links` und `anchors`; welche Doc-Gate-Module ein Ziel bekommt, ist eine eigene
  Entscheidung mit eigenem Prüfbereich.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check (`matrix`, Klasse `spec-straten`) | Ein Link im bindenden Text von `spec/spezifikation.md` (außerhalb der Historie), dessen **Ziel** in der `matrix`-Klasse `adr` oder `slice` liegt, meldet `matrix-forbidden` — rot wird die **Klasse des Ziels**, nicht der Text der Kennung | `make docs-check` |
| d-check (`ids`) | Eine **nackte** Entscheidungs-Kennung dort meldet `id-unlinked`: sie ist linkpflichtig, und ihr Link auf die eigene Datei fällt unter Zeile 1 | `make docs-check` |
| **keines** | Eine **nackte** Planungs-Kennung meldet **nichts** — `ids.patterns` führt kein Muster für sie —, und ebensowenig meldet eine Kennung, deren Link an einem Ziel außerhalb beider Klassen endet. Diesen Rest von Festlegung 3 trägt der Mensch | — |

**Alle drei Zeilen gemessen** (2026-08-01, gepinntes Image, `--network none`, Sonden im
bindenden Text von §3): eine Zeile `siehe ADR-0011` meldet `ADR-0011 id-unlinked`; ein Link auf
die Datei dieser Entscheidung meldet
`../docs/plan/adr/0011-telemetrie-erfassung-policy.md matrix-forbidden`, ein Link auf eine Datei
der Klasse `slice` dieselbe Form — **auch dann, wenn im Linktext gar keine Kennung steht**.
Still bleiben eine nackte Planungs-Kennung und jede verlinkte Kennung, deren Ziel außerhalb
beider Klassen liegt (gemessen mit `AGENTS.md` als Ziel): `make docs-check` bei Exit 0. Die
Gegenprobe zeigt, dass die **Klassen-Mitgliedschaft** die Ursache ist und nicht ein Nebeneffekt:
derselbe Link bleibt still, sobald `spec/spezifikation.md` aus `spec-straten` entfernt wird.

**Was hier bewusst NICHT steht.** Erstens ein Wächter über der **Größe** eines Eintrags im
Adaptions-Block: er wäre die Schranke gegen ein Symptom, nicht der Sensor dieser Entscheidung,
und er gehört dem, der die Schranke setzt. Zweitens ein Wächter, der prüft, ob ein Leser der
revidierten ADR den Index konsultiert — die Kante aus den Konsequenzen ist real und hat kein
Gegenbeispiel, das rot werden könnte. Drittens ein **dauerhafter** Fall in `test/mutations/`
für die zwei roten Zeilen: der Mutations-Treiber kennt heute keine `docs-check`-Fehlerform, ihr
Rot ist also einmalig gesehen und nicht laufend gebunden. Das ist die ehrliche Reichweite, und
sie ist geringer als „bewacht".

## Re-Evaluierungs-Trigger

- **Wenn ein Posten der Aufnahme-Regel widerspricht** *(feedforward — die Entscheidung fällt
  beim Umzug, kein Sensor meldet sie)*: erweist sich ein Teil des Bestands als Abweichung von
  der Baseline statt als eigene Festlegung, bleibt **dieser** Posten im Adaptions-Block, und
  die Annahme oben ist für ihn falsch — nicht für die Entscheidung.
- **Wenn das Technik-Stratum leer bleibt** *(feedforward — an einem Zustand ablesbar, nicht an
  einem Gate)*: trägt es nach dem Umzug keinen Abschnitt mit Inhalt, war die Diagnose falsch
  und der Rang ist ein Rang ohne Gegenstand. Dann ist nicht der Umzug nachzubessern, sondern
  diese Entscheidung abzulösen.
- **Wenn [`AGENTS.md`](../../../AGENTS.md) §3.4 die Teil-Revision aufnimmt** *(feedforward —
  eine Textänderung, kein Sensor)*: dann entfällt der Contra-Punkt aus Option C, und die
  Auffindbarkeit hängt nicht mehr allein am Index. Bis dahin ist die Index-Annotation der
  einzige Träger.
- **Wenn Spans emittiert werden** *(feedforward — eine Vertragsänderung, kein Sensor)*: dann
  ist zu entscheiden, ob das Zielrepo die Feldtabelle in seinem Technik-Stratum mitbekommt.
  Folgepflicht 3 hält die heutige Antwort fest, nicht die künftige.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-01 | **Proposed** | Architect-Verdikt zur Einführung des Technik-Stratums; Anlass war ein Befund am Adaptions-Block (ein Eintrag größer als alle übrigen zusammen) und die zwei Entscheidungen mit `Schärft: —` |
| 2026-08-01 | **Accepted** | Annahme durch den Auftraggeber; ab hier immutabel ([`AGENTS.md`](../../../AGENTS.md) §3.4) — spätere Schärfungen als neue ADR mit *Supersedes* |
