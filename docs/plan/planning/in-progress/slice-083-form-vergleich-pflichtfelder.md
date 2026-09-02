# Slice slice-083: Form-Vergleich — Pflichtfelder und umbenannte Sektionen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-10](../welle-10-re-baseline.md).

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage),
[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
(die Templates werden referenziert, nicht kopiert — der Vergleich läuft gegen den vendored Baum).

**Verantwortlich:** Architect (pt9912) — §3 nennt
[`harness/conventions.md`](../../../../harness/conventions.md) und
[`AGENTS.md`](../../../../AGENTS.md) als Liefergegenstände: das neue Pflichtfeld
`Ersetzt-Baseline-Regel` trifft den Adaptions-Block, und die Singleton-Nacharbeit an `AGENTS.md`
ist dieselbe Artefaktklasse — beide **Architect-Artefakte** nach [`AGENTS.md`](../../../../AGENTS.md)
§3.8. Präzedenzfall [slice-082](../done/slice-082-adaptions-durchgang.md) trägt dieselbe Menge
(`harness/conventions.md`, `AGENTS.md`) und bekam dieselbe Besetzung. Das Feld weicht damit von der
Default-Besetzung ab, die Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State
Machine nennt (*„den Rolleninhaber der Implementer-Rolle"*).

**Autor:** Planner. **Datum:** 2026-08-09.

---

## 1. Ziel

Die Referenz-Form der Ziel-Fassung ist gegen die alte gehalten, und **was sie an Pflicht ändert,
steht in den ausgefüllten Artefakten**. Die fünfte Eigenschaft der Ziel-Prozedur begründet den
eigenen Durchgang: *„Der Review vergleicht auch die Form, nicht nur die Regeln"* — ein neuer Stand
kann die **Struktur** der Artefakte ändern, und dafür gibt es kein Trigger-Feld, das sich melden
könnte.

Der Umfang ist gemessen: die Templates wachsen **21 → 25** (neu: `observations`,
`reconciliation`, `welle-results`, `MR-NNN-titel` als Eintrags-Template für den Adaptions-Block),
und die Vorlagen der Singletons ändern sich substanziell — `conventions.template.md` um 136,
`AGENTS.template.md` um 103, die Spec-Vorlagen um 64 bis 80 Zeilen; über alle Vorlagen **24
Dateien, +1073/−359**
(`git diff --stat v3.5.2 v5.12.0 -- lab/templates/` gegen einen lokalen Kurs-Klon).

**Der schwerste Einzelpunkt ist ein neues Pflichtfeld:** die Pflichtgliederung des
Adaptions-Blocks verlangt je Eintrag `Ersetzt-Baseline-Regel` — **genau eine** Regel der Baseline,
als Link mit Abschnitts-Anker; ein Datei-Link benennt keine Regel. Ein Eintrag, der keine benannte
Regel ersetzt, ist nach dieser Fassung ein **Fork**, keine Adaption. Das trifft jeden
überlebenden Eintrag dieses Repos.

### Form-Diff-Protokoll (Lauf 1, gegen `b902b60`) — die Menge aus DoD-Punkt 1

Der Diff lief über Tree-Operanden (§6) je Singleton-Vorlage gegen ihre ausgefüllte Fassung. Sieben
Artefakte, sieben Ausgänge:

| Artefakt | Ausgang | Befund |
|---|---|---|
| [`harness/conventions.md`](../../../../harness/conventions.md) | **neues Pflichtfeld** | `Ersetzt-Baseline-Regel` je Eintrag (DoD-Punkt 2 unten) — **nicht erledigt in diesem Lauf**, siehe §6 |
| [`AGENTS.md`](../../../../AGENTS.md) | **neues Pflichtfeld** | §2 Source Precedence gewinnt einen Pflicht-Rang `docs/user/*` *(falls vorhanden)* — und er ist vorhanden (`ls docs/user/` führt drei gefüllte Dateien) — **erledigt**: Rang 6 eingefügt, 8 → 9 Ränge, die davon abhängige Zahl in §3.7 (*„→ N Ränge"*) nachgezogen (`sed -n '/^## 2\. Kanonische Quellen/,/^## 3\. Harte Regeln/p' AGENTS.md \| grep -cE '^[0-9]+\. '` → **9**). Die übrigen Textänderungen (§3.3-Nuance, §3.4/Architektur-Bezug, Rahmentext §4/§5) sind Präzisierungen ohne neues Feld oder neue Sektion — **optional**, keine Nacharbeit |
| [`harness/README.md`](../../../../harness/README.md) | **neues Pflichtfeld + neue Pflicht-Sektion** | dieselbe `docs/user/*`-Zeile in der Source-Precedence-Tabelle — **erledigt**, synchron mit `AGENTS.md`; zusätzlich verlangt `grundlagen-harness-dateien.md` §harness/README.md als Einstiegspunkt jetzt eine achte Pflichtgliederungs-Sektion `## Leseordnung` (drei bis fünf geordnete Zeiger für einen neuen Menschen) — **erledigt** |
| [`spec/lastenheft.md`](../../../../spec/lastenheft.md) | **optional** | die Kommentar-Blöcke der Vorlage präzisieren Version-/Status-Semantik und die §7-Regeln (Tatsachenberichtigung, Personalunion-Fall), ändern aber keine sichtbare Struktur der **ausgefüllten** Datei — keine Nacharbeit |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | **neues Pflichtfeld** | jede Tabelle in §2–§6 gewinnt eine `ID`-Spalte mit `SPEC-<NNN>` (fortlaufend über die Datei), §7 verliert die `ADR`-Spalte (Decken-Regel: kein ADR-Bezug in einem Spec-Stratum) — **ausgegliedert in [slice-147](../open/slice-147-spezifikation-traegt-ihr-id-schema.md)**, siehe §6 |
| [`spec/architecture.md`](../../../../spec/architecture.md) | **neues Pflichtfeld** | §1 vergibt `ARC-<NNN>` je Komponente, §2 referenziert sie in einer neuen Spalte, §3 vergibt `ARC-<NNN>` je externer Abhängigkeit — **ausgegliedert in [slice-148](../open/slice-148-architecture-traegt-ihr-id-schema.md)**, siehe §6 |
| [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) | **neues Pflichtfeld** | Output-Schema gewinnt `klasse` (sechstes Feld), die HIGH-Liste drei neue baseline-Einträge (Norm nur im Template-Kommentar · Kommentar trägt keine der fünf Kommentar-Klassen · Zustandsfeld trägt Chronik) — **erledigt**; Kopf/Versions-Kommentar auf `v5.12.0` nachgezogen (1.4.0 → 1.5.0) |

**Ausgang gemessen, nicht vermutet:** vier von sieben Artefakten sind mit diesem Lauf erledigt
(`AGENTS.md`, `harness/README.md`, `.harness/skills/reviewer.md` **und** die
Append-only-Behandlung der wiederkehrenden Vorlagen, DoD-Punkt 3 — `close-welle.md` zieht die
Results-Notiz jetzt per `cp`). Drei bleiben offen, und alle drei sind dieselbe Klasse: eine
**Ripple-Prüfung** über andere Artefakte, die per Abschnittsname statt per ID auf die betroffene
Stelle zeigen (§6).

## 2. Definition of Done

- [x] Der Form-Diff ist gefahren und je **ausgefülltem Artefakt dieser Ebene** mit Ausgang
      protokolliert: **neues Pflichtfeld · umbenannte Sektion · optional** (keine Nacharbeit). Ob
      ein Feld Pflicht ist, entscheidet die **Pflichtgliederung im Regelwerk**, nicht die Feldzahl
      im Template. Die Menge sind die Singletons ([`AGENTS.md`](../../../../AGENTS.md),
      [`harness/conventions.md`](../../../../harness/conventions.md),
      [`harness/README.md`](../../../../harness/README.md), die drei `spec/`-Dateien) **und
      `.harness/skills/reviewer.md`** — auch er entsteht per `cp` aus einer vendored Vorlage, deren
      Ziel-Form der neue Stand geändert hat, und auch bei ihm sieht das kein Gate. Sein Delta ist
      benannt: Kopf und Versions-Kommentar erklären `v3.5.2` zur Baseline (`grep -n 'v3\.5\.2'
      .harness/skills/reviewer.md`), und `modul-10-review-harness.md` führt im Output-Schema ein
      **sechstes** Feld `klasse`, das der Skill nicht hat. **Der Zuschnitt ist korrigiert, nicht
      gewachsen:** [slice-085](../open/slice-085-emittierte-ebene-zieht-nach.md) führte den Skill in §3, und
      das war eine Ebenen-Verwechslung — dort geht es um das **emittierte** Repo, hier um die
      ausgefüllten Artefakte **dieses**. Dieselbe Trennung, die der Absatz unter der Plan-Tabelle
      für die Commands zieht. **Die Aufzählung ist extensional, und ein Artefakt ist ausdrücklich
      nicht darin:** `docs/plan/adr/README.md` ist ebenfalls ein ausgefülltes Artefakt dieser
      Ebene mit vendored Ziel-Form, aber seine Abweichungen von ihr stammen **nicht** aus dem
      Delta dieses Sprungs — sie standen schon am abgelösten Stand offen. Er trägt deshalb
      [slice-134](../open/slice-134-adr-index-traegt-die-ziel-form.md), und dieser Slice zieht ihn nicht
      mit hinein. **Protokoll: siehe §1, Tabelle „Form-Diff-Protokoll"** — vier der sieben
      Ausgänge sind mit diesem Lauf umgesetzt (`AGENTS.md`, `harness/README.md`,
      `.harness/skills/reviewer.md`, DoD-Punkt 3); drei (`harness/conventions.md`,
      `spec/spezifikation.md`, `spec/architecture.md`) sind protokolliert, aber **nicht**
      umgesetzt — Rückführung, §4/§6.
- [ ] `Ersetzt-Baseline-Regel` steht in **jedem** Adaptions-Eintrag — den überlebenden **wie den
      unter dem neuen Stand geschriebenen** — und nennt genau eine Baseline-Regel als Anker-Link;
      wo keine benannt werden kann, ist der Eintrag als **Fork** entschieden, nicht stillschweigend
      belassen. Die zweite Hälfte ist nicht theoretisch: Einträge, die **nach** dem Tausch
      entstehen, sind keine überlebenden und fielen aus einer Fassung heraus, die nur diese nennt —
      ein Kriterium, das den Rückstand wachsen lässt, den es abbauen soll. Die heutige Menge liefert
      ein Kommando, keine Zahl im Text
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2): `grep -c '^### MR-' harness/conventions.md` gegen
      `grep -c 'Ersetzt-Baseline-Regel' harness/conventions.md`. **Nicht erledigt** — Rückführung,
      §4/§6.
- [x] Die **wiederkehrenden** Templates sind append-only behandelt: neue Instanzen folgen der neuen
      Form, bestehende werden nicht rückwirkend umgeschrieben. Eingeschlossen:
      [`/close-welle`](../../../../.claude/commands/close-welle.md) zieht die Results-Notiz künftig
      per `cp` aus dem nun vorhandenen `welle-results`-Template — die Bedingung, die dort seit
      jeher steht („Existiert je ein `welle-results`-Template, dann per `cp` daraus"), ist
      eingetreten.
- [x] `make gates` grün (über dem Stand dieses Laufs — siehe Bericht der Rolle).
- [x] Doku-Update: die Singleton-Artefakte, deren Form sich als Pflicht geändert hat **und** die
      in diesem Lauf umgesetzt wurden (`AGENTS.md`, `harness/README.md`,
      `.harness/skills/reviewer.md`, `.claude/commands/close-welle.md`). Die drei verschobenen
      Artefakte bleiben offen — kein Häkchen ohne Umsetzung.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag. **Nicht dieser Lauf** — der Slice schließt mit
      diesem Durchgang nicht ab (§4).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung | Stand |
|---|---|---|---|
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | das neue Pflichtfeld je überlebendem Eintrag | **verschoben** — §6 |
| [`AGENTS.md`](../../../../AGENTS.md) | update | §2 Source Precedence: Rang `docs/user/*` eingefügt, 8 → 9 Ränge, §3.7-Zahl nachgezogen | **erledigt** |
| [`harness/README.md`](../../../../harness/README.md) | update | Rang `docs/user/*` (synchron zu `AGENTS.md`) und neue Pflicht-Sektion `## Leseordnung`. Die **Bindung-Spalte** der Sensors-Tabelle bleibt unberührt: `grundlagen-harness-dateien.md` §harness/README.md als Einstiegspunkt verlangt, dass sie auf die `CO-<NNN>`-ID verweist, und heute tut sie es bei **keinem** aktiven Carveout (`grep -c 'CO-00' harness/README.md`). Das ist **kein** Delta des neuen Stands — die Zeile steht wortgleich schon in `v3.5.2` —, sondern eine nie übernommene Baseline-Regel; Modul 7 ordnet den punktuellen Fund dieser Art ausdrücklich der *„Übernahme im nächsten Slice"* zu, nicht diesem Durchgang | **erledigt** (Leseordnung + Precedence-Zeile); Bindung-Spalte bewusst nicht angefasst |
| `spec/lastenheft.md` | keine | Kommentar-Präzisierungen ohne Struktur-Delta an der ausgefüllten Datei | **optional, entfällt** |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | update | `SPEC-<NNN>`-Spalte je Tabelle §2–§6, `ADR`-Spalte in §7 entfällt | **ausgegliedert** — [slice-147](../open/slice-147-spezifikation-traegt-ihr-id-schema.md) |
| [`spec/architecture.md`](../../../../spec/architecture.md) | update | `ARC-<NNN>` je Komponente (§1) und externer Abhängigkeit (§3), Schichten-Tabelle referenziert (§2) | **ausgegliedert** — [slice-148](../open/slice-148-architecture-traegt-ihr-id-schema.md) |
| `.harness/skills/reviewer.md` | update | Kopf und Versions-Kommentar nennen `v3.5.2`; das Output-Schema führt fünf Felder gegen sechs der neuen Ziel-Form. Die **schreibende Rolle** benennt keine Quelle ([`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) §Kontext — dieselbe offene Frage wie beim Technik-Stratum); dieser Slice hat sie in Personalunion mit der Architect-Rolle geschrieben, ohne sie damit zu entscheiden | **erledigt** (1.4.0 → 1.5.0) |
| [`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md) | update | die `cp`-Quelle der Results-Notiz existiert jetzt | **erledigt** |

Die **emittierte** Fassung derselben Commands gehört zu
[slice-085](../open/slice-085-emittierte-ebene-zieht-nach.md) — zwei Ebenen, zwei Verträge.

## 4. Trigger

[slice-082](../done/slice-082-adaptions-durchgang.md) liegt in `done/` — ein Eintrag, der gegenstandslos
geworden ist, bekommt kein neues Pflichtfeld mehr.

Rückführungen: `in-progress` → `next`, wenn die Singleton-Nacharbeit und das Pflichtfeld zusammen
eine Sitzung sprengen (dann trennt der Schnitt beide). `in-progress` → `open`, wenn ein Pflichtfeld
eine Aussage verlangt, die erst der Bestands-Durchgang aus
[slice-084](../done/slice-084-stichprobe-gegen-bestand.md) liefert.

**Was tatsächlich eintrat (dieser Lauf, 2026-08-31):** die erste Rückführung greift, und ihr Umfang
ist größer als beim Schnitt angenommen. Der Schnitt sah **einen** schweren Posten
(`Ersetzt-Baseline-Regel`, „rund zwanzig Einträge", §6 im Ursprungstext); gemessen sind es **27**
Einträge mit vollem Rumpf (`grep -c '^### MR-' harness/conventions.md` → **39** Einträge insgesamt,
davon **4** kopf-only retiriert — `016`/`018`/`022`/`023` — und **8** bereits mit dem Feld —
`031`–`038`, organisch vor diesem Durchgang entstanden). Zusätzlich zeigte der Form-Diff (§1) **zwei
weitere** schwere Posten, die der Schnitt nicht vorgesehen hatte: `spec/spezifikation.md` und
`spec/architecture.md` verlangen je ein neues `ID`-Schema (`SPEC-<NNN>`, `ARC-<NNN>`), und beide
Umsetzungen sind nicht lokal — mindestens [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md)
§Schärft-Feld und die Zielort-Zeiger in
[`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)/[`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
zeigen heute auf `spec/spezifikation.md` §5 per **Abschnittsname**, nicht per ID — jede
Umnummerierung braucht eine Gegenprobe, wer auf welche Zeile zeigt, bevor eine `ID`-Spalte
eingefügt wird. Damit sprengt allein die **Pflichtfeld**-Hälfte (`harness/conventions.md` **und**
die zwei Spec-Dateien) eine Sitzung — unabhängig von der Singleton-Nacharbeit, die mit diesem Lauf
bereits erledigt ist (§1/§3). Die Rückführung `in-progress` → `next` greift damit **für den
verbliebenen Rest**, nicht für den ganzen Slice: vier von sieben Artefakten sind fertig, drei
brauchen einen eigenen, feineren Schnitt. Die zweite Rückführung
(`in-progress` → `open`, Abhängigkeit von slice-084) ist **nicht** eingetreten — keiner der drei
offenen Posten braucht eine Aussage aus dem Bestands-Durchgang.

**Zweiter Schnitt (Re-Cut, 2026-08-31): der Rest ist geteilt, nicht zusammen erneut versucht.** Von
den drei verbliebenen Posten trägt genau einer eine explizite, noch offene DoD-Zeile dieses Slice
— DoD-Punkt 2, `Ersetzt-Baseline-Regel` in `harness/conventions.md` (**27** Einträge mit vollem
Rumpf, gemessen oben). Die zwei Spec-Dateien standen dagegen nie als eigener DoD-Punkt dieses
Slice, sondern nur im Form-Diff-Protokoll (§1) und im Risiko-Register (§6) als *„entfallen als
Fracht dieses Laufs, wird Teil des Folge-Zuschnitts"* — dieser Slice hatte sie konzeptionell nie
als eigene Fracht angenommen. Der Re-Schnitt liest das wörtlich: **dieser Slice bleibt bei
DoD-Punkt 2 und schließt mit diesem Re-Cut nicht**, `spec/spezifikation.md` und
`spec/architecture.md` werden zwei eigene Slices —
[slice-147](../open/slice-147-spezifikation-traegt-ihr-id-schema.md) (**23** lebende
Referenzstellen) und [slice-148](../open/slice-148-architecture-traegt-ihr-id-schema.md) (**2**),
getrennt statt gebündelt, weil ihre Ripple-Prüfungen an unabhängigen Artefaktmengen hängen und
keiner der beiden am anderen wartet. Für keines der beiden neuen Artefakte nennt eine kanonische
Quelle eine schreibende Rolle — anders als bei `harness/conventions.md`/`AGENTS.md` grenzt
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) die Architect-Zuordnung
ausdrücklich ein; die beiden neuen Slices tragen die Lücke als eigenes Risiko statt einer
geratenen `Verantwortlich:`-Setzung. Beide sind [welle-10](../welle-10-re-baseline.md)-Mitglieder
(§4 dort) — Durchgang 2 ist über die Singleton-Artefakte **nicht** eingefroren (welle-10 §3) und
bindet neue Elemente derselben Menge weiter.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- **Der Vergleich braucht Zugriff auf beide Formen, nicht zwei Verzeichnisse.** Die Ziel-Prozedur
  zeigt `diff -r` über zwei `<tag>`-Verzeichnisse — das ist ihr Mittel. Verlangt ist, dass die Form
  verglichen wird und die alte erreichbar bleibt, bis der Review durch ist. Genau diesen Zugriff
  sichert [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  zu: *„ein Tag zur Zeit (Ersetzen), Historie liegt in git"*. Der Diff läuft deshalb über
  Tree-Operanden statt über zwei Verzeichnisse, ohne Entpacken — `git diff
  <Tausch-Commit>^:.harness/baseline/v3.5.2/templates <Tausch-Commit>:.harness/baseline/v5.12.0/templates`.
  **`v3.5.2` steht hier als Tree-Operand der Vor-Tausch-Seite, nicht als Zeiger auf einen Baum,
  der stehen bleiben müsste** — er wandert mit dem Zielstand nicht mit.
  Am letzten Re-Vendor dieses Repos vorgeführt (`ce4b611`, `v3.5.1` → `v3.5.2`): 15 Dateien,
  +47/−41, und weder vor noch nach dem Commit lag ein zweites `<tag>`-Verzeichnis im Baum.
  `harness/tools/baseline-verify.sh` ist damit kein Hindernis, sondern schützt die Eindeutigkeit,
  auf der dieser Zugriff beruht. — **Ausgang: entfallen.** Nicht eingetreten: der Zugriff lief
  über `git diff <Tausch-Commit>^:… <Tausch-Commit>:…` wie geplant, kein Hindernis.
- **Handgriff: der Tausch-Commit muss benannt sein.** Ohne ihn hat der Vergleich keine alte Seite.
  Er entsteht in [slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md) und steht zum
  Ausführungszeitpunkt als jüngster Eintrag in `git log --oneline -- .harness/baseline/`. —
  **Ausgang: entfallen.** `b902b60` war benannt und blieb während des ganzen Laufs eindeutig.
- **`Ersetzt-Baseline-Regel` über rund zwanzig Einträge ist die größte Einzelposition der Welle.
  Reißt sie die Sitzung, wird geteilt, nicht gedehnt.** — **Ausgang: eingetreten.** Gemessen sind
  es **27** Einträge mit vollem Rumpf, nicht rund zwanzig (§4); jeder verlangt echte Recherche
  gegen den vendored `v5.12.0`-Baum, um eine **konkrete, einzelne** Baseline-Regel zu benennen oder
  den Eintrag begründet als Fork zu entscheiden — ein Kurzschluss („die Baseline behandelt jetzt
  dasselbe Thema") ist nach `BEO-008` unzulässig und würde denselben Fehler wiederholen, den
  slice-082 in seinem eigenen Durchgang zweimal fand. Diese Recherche reißt zusammen mit den zwei
  neu gefundenen Spec-Datei-Posten (unten) die Sitzung. Der Rest dieses Slice geht per
  `in-progress` → `next` zurück; die drei offenen Artefakte werden beim nächsten Zuschnitt geteilt
  (je ein feinerer Slice oder eine geordnete Reihenfolge innerhalb dieses Slice).
- **Zwei weitere schwere Posten, vom ursprünglichen Schnitt nicht vorgesehen: die `ID`-Schemata von
  `spec/spezifikation.md` und `spec/architecture.md`.** Beide Dateien verlangen laut Form-Diff (§1)
  eine neue `ID`-Spalte (`SPEC-<NNN>` bzw. `ARC-<NNN>`) in mehreren Tabellen — kein isolierter
  Edit, weil andere Artefakte schon heute per **Abschnittsname** auf die betroffenen Zeilen zeigen
  (mindestens [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) §Schärft-Feld,
  [`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben),
  [`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
  — alle drei zeigen auf `spec/spezifikation.md` §5). Eine `ID`-Einführung ohne Ripple-Prüfung
  würde stille `Schärft:`-Zeiger hinterlassen, die auf eine Zeile zeigen, deren Adresse sich
  verschoben hat, ohne dass ein Gate das sieht (dieselbe Klasse Lücke wie
  [`MR-028`](../../../../harness/conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt)
  sie für Slice-Nummern benennt). — **Ausgang: entfallen als Fracht dieses Laufs, aufgeteilt in
  zwei eigene Slices beim Re-Schnitt vom 2026-08-31** (§4): [slice-147](../open/slice-147-spezifikation-traegt-ihr-id-schema.md)
  für `spec/spezifikation.md` (**23** lebende Referenzstellen, gemessen dort §1), [slice-148](../open/slice-148-architecture-traegt-ihr-id-schema.md)
  für `spec/architecture.md` (**2**, dieselbe Messart). Beide tragen ihre eigene Ripple-Prüfung und
  ihre eigene Rollenfrage — keine Quelle benennt für sie eine schreibende Rolle
  ([`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md), `AGENTS.md` §3.8). Nicht
  eingetreten als Blocker **dieses** Slice, aber sein Gewicht ist der Grund, warum die Rückführung
  nicht nur `harness/conventions.md` trifft.
- **Die Verzeichnis-Form des Adaptions-Blocks bleibt außen vor** (Welle §6). Wer sie hier
  mitnimmt, zieht jede `MR`-Kennung des Repos auf einen neuen Pfad — und die sind linkpflichtig. —
  **Ausgang: entfallen.** Nicht angefasst, wie geplant.
- **Eine der vier neuen Vorlagen ist keine Form, sondern ein Ort mit zwei Lese-Schritten, und die
  drei DoD-Punkte oben fangen sie nicht.** `observations` ist das **Beobachtungs-Register**: die
  Ziel-Fassung führt es in `v5.12.0`, `modul-05-planning-harness.md`, §Lifecycle als State
  Machine — *„`done` ist kein Endzustand der Information: Die Beobachtungen aus §7 sind bei der
  Slice-Closure ins Beobachtungs-Register eingetragen und werden von dort weitergelesen"* — und
  hängt es in `v5.12.0`, `templates/docs/plan/planning/slice.template.md` an einen **DoD-Punkt je
  Slice**: *„Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder
  Zähler +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7
  notiert."* Die gepinnte Fassung kennt den Begriff nicht
  (`git grep -l 'Beobachtungs-Register' v3.5.2 -- lab/regelwerk lab/templates | wc -l` → **0**,
  Exit 1; dasselbe für `v5.12.0` → **18** Dateien, lokaler Kurs-Klon; beide Beträge wandern mit
  dem Kurs-Stand, [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). **Die drei DoD-Punkte oben decken Singleton-Form, das Pflichtfeld und die
  Append-only-Behandlung wiederkehrender Vorlagen — eine neue Artefakt-Klasse mit eigener
  Lese-Pflicht fällt zwischen sie.** Dieser Durchgang **entscheidet** darum nur, ob das Register
  adoptiert wird; verlangt es eigene Arbeit, wird es nach [welle-10](../welle-10-re-baseline.md)
  §6 ein Slice in `open/`, keine Fracht dieses Slice. **Der Anlass ist gemessen und liegt in
  diesem Repo:** [slice-080](../done/slice-080-verweis-ueberlebt-tagwechsel.md) §7 hält zwei
  Fälle fest, in denen eine Beobachtung über ein **lebendes** Artefakt nur in einer
  Commit-Message stand und neunzehn Tage später neu gemacht werden musste. — **Ausgang: entfallen,
  bereits entschieden.** Das Register ist adoptiert — [slice-137](../done/slice-137-beobachtungs-register-bekommt-seinen-ort.md)
  (außerhalb dieser Welle) hat `docs/plan/planning/observations.md` angelegt, und dieser Slice
  selbst schreibt keine Zeile hinein (keine Beobachtung dieses Laufs erreicht 1× einen neuen
  Sachverhalt außerhalb des bereits Protokollierten).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/`, `spec/`,
`.claude/commands/` und die Briefing-Dateien im Wurzelverzeichnis gehören zum
Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
