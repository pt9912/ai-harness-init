# Review-Report: ADR-0047 — 2026-09-13

**Review-Art:** Design-Review — geprüft wird die Entscheidung gegen die Entscheidungen, auf die
sie sich beruft, und gegen die Hard Rules.

**Gegenstand:** Commit `771a1dd8` (4 Dateien, +454/−4), Status `Proposed`; Accept-Übergang nach
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2
(kein Selbst-Accept).

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5 (1M) · **Datum:** 2026-09-13

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein `pfad`-Feld
> auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den
> Stand des Laufs und darf ihn festhalten (`v<X.Y.Z>` ·
> `regelwerk/grundlagen-harness-dateien.md` §harness/README.md als
> Einstiegspunkt — diese Zeile ist selbst ein Beispiel der Form).

**Eingangs-Kontext:**

- [ADR-0047](../plan/adr/0047-ziel-fassung-regiert-den-sprung-v680.md) (`Proposed`, der Gegenstand)
- [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md),
  [ADR-0043](../plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md),
  [ADR-0044](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md),
  [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) — die vier, die
  der Acceptance-Trigger namentlich verlangt
- daneben [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md),
  [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md),
  [ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
  [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (`Proposed`),
  [ADR-0036](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md)
- [`AGENTS.md`](../../AGENTS.md) §3.4, §3.8, §3.11 ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)

**Kein Slice-Plan im Eingang:** Dieser Vorgang ist eine Norm-Entscheidung ohne Slice; der Plan,
den der Skill sonst verlangt, existiert nicht. Der Slice, den die ADR beauftragt (Baum-Tausch),
ist Folgepflicht und nicht Gegenstand dieser Runde.

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | **MEDIUM** | Der Beleg im Acceptance-Trigger nennt Regelwerks-Datei, Abschnitt und Zitat verbatim, aber **keinen Tag**: *„die Aufteilung, die das Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln verbatim vorschreibt"*. Der Satz ist nicht neu — **vier weitere Sprung-ADRs führen ihn wortgleich und tag-los** (ADR-0036, ADR-0038, ADR-0043, ADR-0044), alle vier `Accepted` und damit nach [`AGENTS.md`](../../AGENTS.md) §3.4 unerreichbar; die tag-tragenden Fassungen desselben Zitats (ADR-0015, ADR-0019, ADR-0024, ADR-0033, ADR-0040) stehen in einer anderen Satzform. Der Befund gilt deshalb **nur dieser Datei** — sie ist als einzige der fünf noch `Proposed`. | [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 (drei Teile), Festlegung 3 (a) (*„Bevor der Status eines ADR auf Accepted wechselt, werden seine Baseline-Belege in die Form aus Festlegung 2 gebracht"*) und Festlegung 1 (Cutoff: gebunden ist der Verweis, der geschrieben wird; der Bestand ist kein Arbeitsauftrag) · [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) Setzung 1 | `docs/plan/adr/0047-ziel-fassung-regiert-den-sprung-v680.md:301-304` | **nein** — kein Modul der [`.d-check.yml`](../../.d-check.yml) liest Mess-Tags in Prosa; die Form-Sonde, die ADR-0016 §Der Träger kann einen Sensor haben beschreibt, ist nicht gebaut. Dass die Form vier Accept-Runden überstanden hat, ist gemessen: eine davon nahm an ihrem Prüfpunkt 6 ausdrücklich das Gegenteil zu Protokoll | Baseline-Aussage ohne Mess-Tag |
| F-2 | **LOW** | Die zwei derivativen Register zitieren die Entscheidung als *„Festlegung 1"*; die Datei führt **„Eine Festlegung."** und eine unnummerierte `###`-Überschrift. Für die zwei gleich gebauten Vorgänger mit einer Festlegung nennt dasselbe Register die Form *„einzige Festlegung"* (ADR-0036, ADR-0038) — die abweichende Form liest sich als Unterschied, der keiner ist, und die Adresse löst im Ziel nicht auf. | Maintainability · [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (was ein Eintrag setzt, setzt seine Datei) | `harness/conventions.md:56` · `harness/migration.md:47` | **nein** — `anchors` prüft Markdown-Anker, keine Prosa-Adresse *„Festlegung N"* | Nummerierte Festlegungs-Adresse ohne Nummer im Ziel |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Zitate der berufenen Entscheidungen** (Prüfpunkt 1) | geprüft, ohne Befund. Die Vorgabe zur vollständigen Übernahme steht wörtlich in ADR-0044 §Konsequenzen (*„Der Adaptions-Durchgang übernimmt die Ziel-Fassung vollständig; eine Abweichung wird nicht gesetzt."*), samt der Zuordnung zum Ausgang *widerspricht*; ADR-0047 zitiert sie verbatim und schreibt sie nicht um. Auch die vier Trigger-Zitate aus ADR-0044 (Nr. 1, 3, 4, 5) und die Leseregel aus ADR-0043 Festlegung 2 sind wörtlich und in der richtigen Bedeutung wiedergegeben. |
| **Kein Instanz-Durchgang** (Prüfpunkt 2) | geprüft, ohne Befund. Eigene Messung: das Vorlagen-Delta über die zwei Tags ist **leer** (0 Dateien), die 25 vendorten Vorlagen sind byte-gleich. Die Folgerung der ADR — Instanz-Register und Report-Form haben *keinen Gegenstand*, statt *ausgesetzt* zu sein — ist damit die richtige Lesart und nicht die bequemere. Ebenso reproduziert: 4 Dateien `+36/−4`, genau ein Tag in der Range, null Delta über Prozedur und alle vier Delegate, Achse 28/58/**0**. |
| **Freshness-Review als Folgepflicht** (Prüfpunkt 3) | geprüft, ohne Befund. Sie steht als Auftrag mit benanntem Gegenstand (alle **55** aktiven Einträge, nicht eine Vorauswahl) und trägt zweimal ausdrücklich den Verzicht auf ein Ergebnis (*„führt die Review nicht aus und nimmt kein Ergebnis vorweg"* · *„Ein Ausgang, der hier stünde, wäre ein Urteil ohne den Durchgang"*). **Die Vorsichtung der neun Kandidaten steht bewusst nicht in der Datei** — sie stünde als Ausschnitt in einem einfrierenden Artefakt und verengte die Fundmenge, die der Durchgang über die volle Liste ziehen muss; die zwei namentlich genannten (`MR-035`/`MR-056`) sind ausdrücklich als *nicht vorgegriffen* markiert. Der Durchgang leitet sie neu ab; das ist seine Aufgabe, kein verlorener Übergang. |
| **Symlink-Nachzug** (Prüfpunkt 4) | geprüft, ohne Befund. Die ADR misst selbst, dass die Zeiger den Tag im Pfad tragen, nennt das Umhängen ausdrücklich **nicht automatisch**, ordnet es dem Baum-Tausch-Slice zu und grenzt es gegen eine Auswahl-Entscheidung ab (Mitglieder-Menge bleibt, Inhalt wechselt). Eigene Messung: **7** tag-tragende Zeiger, **3** der 4 geänderten Dateien darunter (`modul-05`, `modul-11`, `modul-13`; `README.md` ist nicht verlinkt). |
| **Commit-Zuschnitt und Eigentum** ([`AGENTS.md`](../../AGENTS.md) §3.8, Prüfpunkt 5) | geprüft, ohne Befund. Vier Dateien, alle Architect-Eigentum: ADR, ADR-Index und `harness/migration.md` als derivative Register ihrer Originale (ADR-0024), §Baseline von `harness/conventions.md` nach §3.8. Die Message nennt die Rolle. Kein Selbst-Accept: Status bleibt `Proposed`, und die Message sagt es. |
| **Zahlen und Baseline-Aussagen** ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)/[`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist), Prüfpunkt 6) | geprüft, ein Befund (F-1). Jede Zahl steht neben dem Kommando, das sie liefert; jede **wandernde** Zahl trägt den Vermerk *kein Erwartungswert* (28/58/0 · 3/7 · 55 · `ls -1 .harness/baseline/`). Die zwei Zahlen ohne Vermerk sind tag-gebunden (`+36/−4` zwischen zwei Tags, 25 Vorlagen unter einem Pfad mit Tag) und wandern nicht. Alle übrigen Baseline-Belege nennen Tag, Datei, Abschnitt und — wo zitiert — den Wortlaut verbatim; beide Zitate am `v6.8.0`- **und** am vendorten Stand nachgeschlagen. |
| **Status-Hygiene der Zitate** | geprüft, ohne Befund. Keine superseded Entscheidung zitiert; die einzige nicht angenommene (ADR-0031) trägt ihren `Proposed`-Status an **allen drei** Zitatstellen, und die offene Frage, ob sie so zitiert werden darf, ist als Lücke benannt statt still beantwortet. ADR-0043 ist nur in seiner **nicht** abgelösten Festlegung 2 in Anspruch genommen. |
| **Form der einfrierenden Datei** ([`AGENTS.md`](../../AGENTS.md) §3.11, [ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 3) | geprüft, ohne Befund. Überschriften-Folge identisch mit `v6.7.2` · `templates/docs/plan/adr/NNNN-titel.template.md`; keine Pfad-Adresse auf ein Artefakt, das der Prozess bewegt (die vier Slice-Nennungen stehen als Kennung in einer Kommando-Ausgabe); genannte Verzeichnisse sind ortsfest; alle Links lösen auf, alle vier `MR`-Anker existieren. |
| **Gate-Aussagen** ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) | geprüft, ohne Befund. Die vier in §Fitness Function genannten Ziele existieren und sind in `harness/README.md` mit derselben Bindung geführt; *kein Sensor* ist als Negativ-Konsequenz benannt statt verschwiegen. |
| **Substanz der Wahl** (der eigens benannte Prüfgegenstand) | geprüft, ohne Befund — in **beide** Richtungen. *Zu viel*: keine allgemeine Regel entsteht; §Was diese Festlegung nicht tut und Alternative C lehnen sie ausdrücklich ab, und der nächste Sprung erbt die Messpflicht (Re-Evaluierungs-Trigger 1). *Zu wenig*: die Wahl wird nicht für beliebig erklärt — der zweite Grund (Tag-Klammer, [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) trägt allein und wird als **Adress**-Grund und damit als schwächer als der der Vorgängerin offen in §Konsequenzen als negativ gebucht. Der erste Grund ist korrekt als *entlastend, nicht tragend* beschrieben. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Baseline-Aussage ohne Mess-Tag · Nummerierte Festlegungs-Adresse
ohne Nummer im Ziel

## Verdikt

**Merge-blockierend: nein** — und die Abweichung von der Faustregel *„MEDIUM blockiert
typischerweise"* wird hier begründet, nicht still entschieden: F-1 ist kein Defekt der
Entscheidung, sondern der **Form eines Belegs**, und ADR-0016 Festlegung 3 (a) weist genau diesem
Übergang — dem Wechsel nach `Accepted` — die Reparatur zu. Solange die Datei `Proposed` ist,
kostet sie eine Zeile; danach eine Folge-ADR. F-2 betrifft zwei **lebende** Register und ist
jederzeit nachziehbar. Die Substanz beider Prüfgegenstände trägt: beide tragenden Gründe sind
eigenständig nachgemessen, und keine der sechs berufenen Entscheidungen ist falsch zitiert.

**Bedingung für den Accept-Übergang:** F-1 ist vor dem Umschlag zu beheben, F-2 mit ihm oder
danach. **Grenze dieser Runde, benannt statt verschwiegen:** Behebt derselbe Lauf F-1, der ihn
gefunden hat, so ist das nach [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 2 unbedenklich, weil kein **blockierender** Befund vorliegt — eine unabhängige
Bestätigung der behobenen Fassung hat es dann trotzdem nicht gegeben, und die Accept-Zeile sagt
das.

**Übergabe:** Die Findings gehen an den Architect (die ADR ist Architect-Eigentum,
[`AGENTS.md`](../../AGENTS.md) §3.8); die Finding-Klassen gehen in die Closure des Vorgangs, der
diese Runde einsammelt, und von dort in den Zähler. Dieser Report ist ein **Lauf-Beleg** und wird
über Läufe hinweg nicht wieder gelesen. Er ersetzt keine Verifikation.
