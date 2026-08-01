# ADR-0014: Ein aufgehobener Eintrag des Adaptions-Blocks behält seinen Kopf, nicht seinen Rumpf

**Status:** Proposed

**Datum:** 2026-08-01

**Autor:** ai-harness-init-Team (pt9912)

**Bezug:**
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (die emittierte
Doc-Chain — die Ebene, an der diese Entscheidung ausdrücklich nichts ändert),
[ADR-0013](0013-technik-stratum-als-zielort.md) (die Entscheidung, die den Fall
*aufgehobener Eintrag* überhaupt erzeugt; ihre verworfene Option D ist **nicht** diese hier)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie regelt die Form eines Dokuments, das in
keiner der beiden Precedence-Listen des Repos steht und dessen Gegenstand keine technische
Festlegung ist.

---

## Kontext

Die vendored Vorlage des repo-lokalen Konventionsdokuments
(`.harness/baseline/v3.5.2/templates/harness/conventions.template.md`, Kommentar über dem
Adaptions-Block) setzt für dessen Einträge eine append-only-Disziplin: *„chronologisch
nummeriert, keine nachträglichen inhaltlichen Änderungen an akzeptierten Einträgen — nur neue
Einträge oder explizite Aufhebungen via neuen MR."*

**Wo die Regel steht und wo nicht (gemessen 2026-08-01).** Sie lebt allein in einem
HTML-Kommentar der Vorlage; die Kopie im Repo trägt keinen davon
(`grep -c '<!--'` → **9** gegen **0**). Kein Prosa-Modul des vendored Regelwerks nennt sie
(`grep -rn 'nur neue Eintr\|explizite Aufhebung\|append-only'` über
`.harness/baseline/v3.5.2/regelwerk/` → **0** Treffer); `grundlagen-konventionen.md` beschreibt
den Block ohne sie. **Sie bindet hier trotzdem, und zwar aus zwei Quellen ungleicher Stärke:**
[`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) erklärt *„keine
inhaltlichen Adaptionen ggü. Baseline-Default"* — das trägt eine Form-Regel nur mittelbar; und
[`MR-019`](../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
zitiert den Satz wörtlich als seinen eigenen Grund und handelt danach. Die zweite Quelle ist
die tragende: die Regel bindet, weil ein bindender Eintrag sie aufgenommen hat, nicht weil ein
Kommentar überlebt hätte.

**Was der Satz nicht sagt.** Er verbietet *nachträgliche inhaltliche Änderungen* und erlaubt
*explizite Aufhebungen*. Ob das Entfernen des Rumpfs eines aufgehobenen Eintrags die verbotene
Änderung oder der Vollzug der erlaubten Aufhebung ist, entscheidet er nicht.

**Der Preis, gemessen 2026-08-01.** Die drei sitzungsfesten Posten der Einstiegs-Leseliste
(`harness/README.md`, [`AGENTS.md`](../../../AGENTS.md),
[`harness/conventions.md`](../../../harness/conventions.md)) messen zusammen **165.197 Bytes**
(`wc -l -c`). Der größte Eintrag des Adaptions-Blocks misst **824 Zeilen / 70.727 Bytes** —
**42,8 %** davon (Blockgrenzen über
`grep -nE '^### MR-[0-9]{3}|^## Modus-Deklaration' harness/conventions.md`, dann
`awk 'NR>=835&&NR<=1658' | wc -l -c`). Bliebe der Rumpf nach seiner Aufhebung stehen, wäre
dieser Anteil des Pflicht-Lesepfads Text ohne Bindung, und die darin geführte Festlegung stünde
an zwei Orten, von denen nur einer bindet — der Hinweis darauf rund 800 Zeilen unter dem, was
er entwertet.

**Annahme, auf der diese Entscheidung steht:** `git` ist auf jedem Checkout präsent und wird
benutzt. Das ist keine Vermutung — die Wachstumskurve dieses Eintrags und die Zahlen in
[ADR-0013](0013-technik-stratum-als-zielort.md) sind aus der Historie gemessen, nicht aus dem
Text. Wird ein Checkout ohne Historie zum Normalfall, kippt die Annahme und mit ihr die
Entscheidung.

## Entscheidung

**Wir wählen Option C: der Kopf bleibt, der Rumpf geht — beim Aufheben, nicht später.** Drei
Festlegungen:

1. **Append-only gilt dem Eintrag, nicht seinem Rumpf.** Erhalten bleiben die Nummer
   (chronologisch, nie neu vergeben), die Überschrift **wörtlich** — sie ist der Anker, auf den
   fremde Dokumente zeigen —, das `Datum` und **eine** Zeile, die den aufhebenden Eintrag nennt
   und je Posten-Art den Zielort. Den Rumpf trägt `git`.
2. **Entfernen ist der Vollzug einer Aufhebung, nie ein eigener Vorgang.** Drei Bedingungen,
   alle: (a) ein späterer Eintrag hebt **vollständig** auf — bei Teil-Aufhebung bleibt der
   Rumpf, weil sein Rest bindet; (b) jede bindende Aussage des Rumpfs steht an einem bindenden
   Ort oder ist im aufhebenden Eintrag als *ersatzlos* mit Grund verzeichnet; (c) Aufhebung und
   Entfernung sind **zwei Commits** — ein Diff, der nur löscht, ist prüfbar, ein vermischter
   macht Korrektur und Entfernung ununterscheidbar ([`AGENTS.md`](../../../AGENTS.md) §3.3 in
   der Sache). Fällig ist die Entfernung **mit** der Aufhebung: das Intervall dazwischen ist
   genau der Zustand, in dem eine Festlegung an zwei Orten steht und kein Sensor den bindenden
   nennt.
3. **Die Regel gilt dem Adaptions-Block und nirgends sonst.** ADRs bleiben unberührt
   ([`AGENTS.md`](../../../AGENTS.md) §3.4): ihr Rumpf steht in einer eigenen Datei hinter einem
   Index und außerhalb des Pflicht-Lesepfads — die Kosten, die diese Entscheidung tragen,
   entstehen dort nicht. Wer aus ihr eine Lizenz zum Ausräumen abgelöster ADRs liest, liest
   gegen ihren Grund.

**Dies ist nicht die Größen-Antwort, die [ADR-0013](0013-technik-stratum-als-zielort.md) als
Option D verworfen hat.** Auslöser ist die **Aufhebung**, nicht die Byte-Zahl: ein geltender
Eintrag darf unter dieser Regel unbegrenzt wachsen, ein aufgehobener Einzeiler fällt unter sie.
Eine Schranke über die Größe geltender Einträge bleibt unentschieden.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **so lassen**: der Rumpf bleibt Byte für Byte stehen | wortlaut-sicher ohne Auslegung; kein neuer Mechanismus | 42,8 % des Pflicht-Lesepfads sind aufgehobener Text, und die Festlegung bindet an einem von zwei Orten, ohne dass ein Sensor sie unterscheidet. Der Zeiger auf die Aufhebung steht rund 800 Zeilen **unter** dem, was er entwertet — die Leserichtung trifft zuerst das Überholte |
| B — **Rumpf in ein Archiv-Dokument** außerhalb des Pflicht-Lesepfads, Stumpf mit Zeiger | hält den Wortlaut („nichts gelöscht") und den Lesepfad zugleich; der Rumpf bleibt ohne `git`-Kommando lesbar | er leistet weniger als `git` — eine eingefrorene Kopie statt jeder Fassung samt aufhebendem Commit — und kostet mehr: eine zweite Quelle derselben Konvention ist genau das Drift-Risiko, vor dem das Regelwerk beim Konventionsdokument warnt. Unter `docs/` läge er zudem im Prüfbereich von `codepaths`/`ids` — jede Referenz in totem Text bliebe wartungspflichtig |
| **C — Kopf bleibt, Rumpf geht (gewählt)** | der Zweck der Disziplin — Nachvollziehbarkeit — bleibt vollständig bei `git`, das ihn ohnehin besser trägt; erhalten bleibt, was `git` **nicht** trägt: Nummer, Anker und die Reichweite am Ort des Lesens, für den Preis weniger Zeilen | es ist eine Lockerung der Baseline-Disziplin und braucht diese Entscheidung samt ihrem Eintrag. Wer den Rumpf lesen will, braucht die Historie; eine Ansicht ohne sie zeigt ihn nicht |
| D — **Eintrag ersatzlos entfernen**, Überschrift eingeschlossen | maximal knapp | bricht jeden Zeiger: die Umbenennung *einer* Eintrags-Überschrift färbt `make docs-check` mit **119** `anchor-missing` rot (gemessen, s. Fitness Function). Und die Nummer verschwände aus einer chronologischen Folge, deren Lückenlosigkeit die Regel schützt |

## Konsequenzen

- **Positiv:** der Pflicht-Lesepfad trägt bindenden Text. Ein aufgehobener Eintrag kostet den
  Leser die Zeilen seines Kopfes statt die seines Rumpfs.
- **Positiv:** die Reichweite steht am Ort des Lesens. Der Adaptions-Block braucht dafür
  **keinen** Index — der ADR-Index ist die Antwort auf ein anderes Problem (Aufheber und
  Aufgehobenes in getrennten Dateien); hier stehen beide in derselben Datei, und der Kopf sagt
  es an der Stelle, an der der Leser ankommt.
- **Negativ, und das ist der Preis:** wer den Rumpf lesen will, braucht `git`. Kein Sensor sagt
  dem Leser, dass es ihn gab — das sagt der Kopf, und sonst nichts.
- **Negativ:** die tragende Bedingung 2 (b) hat keinen Wächter. Ob jede bindende Aussage
  andernorts steht, entscheidet ein Mensch beim Aufheben; ein Doc-Gate kann diese Eigenschaft
  nicht messen ([`AGENTS.md`](../../../AGENTS.md) §3.6 — hier benannt, nicht geschlossen).
- **Folgepflicht 1 — die Abweichung gehört in den Adaptions-Block.** Eine Abweichung von der
  adoptierten Baseline ist genau sein Gegenstand; diese Entscheidung trägt die Begründung, der
  Eintrag [`MR-020`](../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  die Regel und ihre Reichweite.
- **Folgepflicht 2 — „akzeptiert" braucht eine Bedeutung.** Ein Eintrag des Blocks führt kein
  Status-Feld; ohne Festlegung hätte die Regel keinen bestimmbaren Auslöser. Sie steht im
  Eintrag: akzeptiert heißt committet.
- **Folgepflicht 3 — die emittierte Ebene bleibt unberührt, und das ist eine Entscheidung.**
  Das Zielrepo erhält `harness/conventions.md` aus derselben vendored Vorlage, und die Emission
  transformiert nur zweierlei (der `> **Template-Hinweis.**`-Blockquote entfällt,
  `<Projektname>` wird gestempelt — `internal/emit/templates.go`); die neun HTML-Kommentare und
  mit ihnen die Disziplin-Regel wandern unverändert mit. Dort gilt die Baseline-Regel: ein
  frisches Ziel hat keinen aufgehobenen Rumpf und damit nicht den gemessenen Preis, der diese
  Lockerung trägt. Die Vorlage selbst wird ohnehin nicht angefasst
  ([`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check (`anchors`) | Die Überschrift eines aufgehobenen Eintrags steht wörtlich fort; entfällt oder ändert sie sich, meldet jeder Zeiger darauf `anchor-missing` | `make docs-check` |

**Rot gesehen, mit Gegenprobe** (2026-08-01, gepinntes Image, `--network none`): die
Überschrift des größten Eintrags umbenannt → `make docs-check` Exit 2 mit **119**
`anchor-missing` über `harness/README.md`, `harness/conventions.md` selbst und die
Zeitdokumente; dieselbe Datei unverändert → `d-check: 275 Datei(en) geprüft, 0 Befund(e)`.

**Was hier bewusst NICHT steht.** Erstens ein Wächter über Bedingung 2 (b) — *„jede bindende
Aussage steht andernorts"* ist keine Eigenschaft, die ein Doc-Gate lesen kann. Zweitens ein
Wächter, der eine Entfernung **ohne** Aufhebung meldet: sein Gegenbeispiel wäre ein Diff, und
kein Gate dieses Repos liest Diffs. Drittens ein dauerhafter Fall in `test/mutations/` für die
Zeile oben — der Mutations-Treiber kennt genau zwei Fehlschlag-Formen (`--- FAIL:` der Go-Stufe,
`not ok N` der bats-Stufe, `harness/tools/mutate.sh`) und keine `docs-check`-Form; das Rot ist
einmalig gesehen und nicht laufend gebunden. Bewacht ist der **Kopf**, nicht der Vollzug.

## Re-Evaluierungs-Trigger

- **Wenn ein Checkout ohne Historie zum Normalfall wird** *(feedforward — an einem Zustand
  ablesbar, kein Gate)*: dann trägt allein der Rumpf, und Festlegung 1 ist falsch.
- **Wenn der Adaptions-Block einen Index bekommt** *(feedforward)*: dann steht die Reichweite an
  zwei Orten. Der Kopf ist dann gegen den Index zu prüfen, nicht zu verdoppeln.
- **Wenn die Baseline die Disziplin-Regel aus dem Vorlagen-Kommentar in ein Prosa-Modul hebt**
  *(feedforward — eine Textänderung upstream, kein Sensor)*: dann bindet sie unabhängig von
  ihrer Rezeption hier, und die Abweichung ist gegen den neuen Wortlaut neu zu begründen.
- **Wenn ein aufgehobener Rumpf eine Aussage trägt, die nirgends sonst steht** *(feedforward —
  die Entscheidung fällt beim Aufheben)*: dann ist Bedingung 2 (b) nicht erfüllt, und **dieser**
  Rumpf bleibt, bis sie es ist — die Regel fällt deswegen nicht.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-01 | **Proposed** | Architect-Verdikt zum Verbleib eines aufgehobenen Adaptions-Eintrags; Anlass war die Messung, dass ein aufgehobener Rumpf 42,8 % des sitzungsfesten Pflicht-Lesepfads einnähme |
