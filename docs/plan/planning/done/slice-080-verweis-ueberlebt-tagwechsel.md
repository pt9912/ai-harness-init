# Slice slice-080: Ein Verweis in die vendored Baseline überlebt den Tag-Wechsel

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-10](../welle-10-re-baseline.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tag ist
die Reproduzierbarkeits-Klammer), [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(ein Tag zur Zeit, `<tag>`-gescopter Pfad), [`AGENTS.md`](../../../../AGENTS.md) §3.4 und §3.5.

**Autor:** Planner. **Datum:** 2026-08-09.

---

## 1. Ziel

Es ist entschieden und in einer ADR festgehalten, **wie ein Verweis in den `<tag>`-gescopten
vendored Baum einen Tag-Wechsel übersteht, wenn er in einem unveränderlichen Artefakt steht** —
vor dem ersten Tausch, nicht danach.

**Der Konflikt, gemessen.** [`AGENTS.md`](../../../../AGENTS.md) §3.4 stellt ein ADR ab *Accepted*
unveränderlich; das Doku-Gate verlangt auflösbare Link-Ziele. Vier Accepted-ADRs zeigen in den
vendored Baum ([`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md),
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md),
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md),
[`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)) — gezählt über das Muster
**mit Folgepfad**: `git grep -lE 'baseline/v3\.5\.2/' -- 'docs/plan/adr/*.md' | wc -l` → **4**.
Auf den **bloßen Verzeichnisnamen** sind es **sechs** Dateien mit zusammen **neun** Zeilen
(dasselbe Kommando ohne den abschließenden Schrägstrich → **6**; mit `-hE` statt `-lE` → **9**;
dieselbe Liste durch `xargs grep -l '^\*\*Status:\*\* Accepted' | wc -l` → **6**, also durchweg
*Accepted*): dazu kommen [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) und
[`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md), die das Verzeichnis
als **Operand ihrer eigenen Umbenennungs-Sonde** nennen — ein mechanischer Tag-Tausch machte diese
zwei Sätze *falsch*, statt sie ins Leere zeigen zu lassen. Beide Zahlen zählen Verschiedenes und
sind **keine Erwartungswerte**; sie wandern mit dem ADR-Bestand
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) nennt den Baum an
**keiner** Stelle (`git grep -c '\.harness/baseline' -- 'docs/plan/adr/0015-*.md'` → kein Treffer,
Exit 1) und ist von der Frage nicht berührt. Verschwindet der Pfad, kollidieren zwei Regeln an
einem Artefakt, das keine von beiden ändern darf.

**Und die Kollision ist kleiner und zugleich schlimmer als sie aussieht — beides gemessen**
(Sonde im Arbeitsbaum, `make docs-check`, zurückgenommen):

| Verweis-Form | Beispiel | Gate |
|---|---|---|
| Markdown-Link | [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) → `grundlagen-konventionen.md#spec-straten-…` | **`target-missing`** — rot |
| Inline-Code-Pfad | [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md), [`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) | **stumm** |
| Zeilen-Referenz `datei:26-29` | [`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) | **stumm** |

Rot wird also **genau ein** Accepted-ADR. Die anderen drei tragen nach dem Tausch eine falsche
Aussage über einen Baum, den es nicht mehr gibt, **und kein Sensor sagt es** — `codepaths.roots`
führt `spec`, `docs`, `harness`, nicht `.harness`. Die stille Hälfte ist die Frage dieses Slice,
nicht die laute.

## 2. Definition of Done

- [x] Eine ADR ist *Accepted* und entscheidet den Konflikt: was mit einem `<tag>`-gepinnten
      Verweis in einem Accepted-Artefakt beim Tag-Wechsel geschieht — und welche Regel künftige
      Verweise bindet (**Eigenschaft statt Adresse**, oder ausdrücklich das Gegenteil).
- [x] Die ADR trägt den **Ist-Bestand mit Kommando und Zahl**, getrennt nach gate-sichtbar und
      stumm; die stille Hälfte wird nicht als bewacht ausgegeben
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [x] Ist die Entscheidung eine **Gate-Lockerung** (Ausnahme für Ziele unter `.harness/baseline/`),
      steht das als solche in der ADR — [`AGENTS.md`](../../../../AGENTS.md) §3.5 verlangt für jede
      Senkung genau dieses Gefäß, nicht einen Nebensatz.
- [x] `make gates` grün.
- [x] Doku-Update: ADR-Index.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/adr/00NN-<titel>.md` | neu (per `cp` aus dem vendored ADR-Template) | trägt die Entscheidung |
| `docs/plan/adr/README.md` | update | Index wächst mit der ADR ([`AGENTS.md`](../../../../AGENTS.md) §5) |

Kein Code, keine Gate-Config: die Umsetzung liegt bei
[slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md).

## 4. Trigger

Beginnt, sobald [welle-10](../welle-10-re-baseline.md) startet — dieser Slice ist ihr
erster; kein Vorgänger innerhalb der Welle.

Rückführungen: `in-progress` → `next`, wenn die Entscheidung mehr als eine Frage trägt (etwa
zusätzlich den Sensor für die stille Hälfte — der ist dann ein eigener Slice). `in-progress` →
`open`, wenn sie eine Baseline-Aussage braucht, die erst **nach** dem Tausch messbar ist; dann ist
die Reihenfolge dieser Welle falsch geschnitten und das gehört gemeldet, nicht umgangen.

## 5. Closure-Trigger

DoD vollständig, ADR *Accepted*, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- **Die bequeme Antwort ist die Ausnahme.** Ziele unter `.harness/baseline/` vom Link-Check
  auszunehmen macht die vier ADRs auf einen Schlag grün — und nimmt zugleich die 16 heute
  gate-sichtbaren Verweise aus [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
  und [`harness/conventions.md`](../../../../harness/conventions.md#mr-000--baseline-aussage) mit
  aus der Prüfung. Das ist eine Senkung mit weit größerem Geltungsbereich als der Anlass.
- **Die stille Hälfte hat keinen Wächter, und der Slice darf sie nicht so behandeln, als hätte
  sie einen.** Ob `codepaths.roots` um `.harness` erweiterbar ist, ohne den Prüfbereich
  aufzublähen, ist **ungemessen**. Der eine Kandidat, der dafür gemessen wurde, ist **verworfen**:
  das d-check-Modul `versions` (`DC-FA-VER-001`, im gepinnten Image vorhanden, in
  [`.d-check.yml`](../../../../.d-check.yml) nicht aktiviert) bindet jeden Versions-Pin an die
  aktuelle Version seines Paares und misst damit **Zeichenketten-Frische, nicht
  Verweis-Auflösung** — es trennt Adresse, datierte Aussage und Operand nicht, und sein
  zeilengenauer Ausweg ist eine Textänderung, die [`AGENTS.md`](../../../../AGENTS.md) §3.4 auf
  den **sechs** Accepted-ADRs aus §1 verbietet. Die Sonden, die das zeigen, die Bestandszahlen
  beider Adoptions-Wege und das Kriterium für den nächsten Kandidaten trägt
  [`ADR-0023`](../../adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md) Festlegung 3. Was der
  Trockenlauf belegt, bleibt richtig und bleibt weniger, als es zunächst schien: die stille Hälfte
  ist **messbar** — bewacht ist sie nicht, und keine Entscheidung dieses Slice macht sie es.
- **Was hier entschieden wird, gilt über den Anlass hinaus:** dieselbe Frage stellt sich bei
  jedem künftigen Bump. Eine Entscheidung, die nur `v3.5.2` → `v5.12.0` regelt, ist keine.

## 7. Closure-Notiz (nach `done/`)

**Rolle:** Planner (Modul 5 §Closure- und Lerneintrag-Regeln). **Datum:** 2026-08-28.
**Gegenstand:** HEAD `485da30`; sieben Commits — `b0fb093` (Move `next` → `in-progress`),
`363421c` (Link-Abgleich, vier Verweise), `fccc627` (die ADR, *Proposed*), `4e62366`
(Verifikation), `de1e4bc` (drei lebende Aussagen gegen den Ist-Stand gezogen), `560f558` (sechs
Posten vor der Annahme), `485da30` (die Annahme, im selben Commit wie
[ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md)).

Jede Zahl unten ist **in diesem Lauf** erhoben; die Zahlen aus ADR, Review und Verifikation waren
Eingabe, kein Beleg
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1).

### DoD-Stand — sechs Punkte, davon **drei** slice-eigen (Modul 5 §Ziel-Form: ≤ 3)

**(1) ADR *Accepted*, und sie entscheidet den Konflikt — ERFÜLLT.** Der Punkt ist eine
**Konjunktion**; die Verifikation maß das inhaltliche Glied als vollständig und das Status-Glied
als offen. Beide halten jetzt.
`grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md` →
`**Status:** Accepted`. Inhaltlich nennt
[ADR-0023](../../adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md) Festlegung 2 die vom
DoD-Text angebotene Alternative wörtlich (*„Die Regel für künftige Verweise bleibt Eigenschaft
statt Adresse — ausdrücklich nicht das Gegenteil"*) und Festlegung 1 den Ausgang für den Bestand
(*„Kein Supersede, kein Byte an beiden"*).

**Was zu diesem Punkt gemessen ist und in eine Closure gehört: wer eine ADR annimmt, sagt keine
Quelle dieses Repos.** Die Verifikation hat die gerankten Quellen,
[`AGENTS.md`](../../../../AGENTS.md), den Harness-Einstieg, den ADR-Index, die Rollen-Artefakte
und die vendored Baseline abgesucht; der einzige Treffer ist
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
dessen Geltungsbereich ausdrücklich `spec/lastenheft.md` ist. Die Annahme ist darum **als
Entscheidung des Auftraggebers in den Geschichte-Zeilen beider ADRs festgehalten und in der
Architect-Rolle vollzogen** — nachlesbar als Zustand, nicht als Behauptung über eine Regel, die es
nicht gibt. Der Record dieses Repos zeigt den Vollzug unter dem Label der schreibenden Rolle; die
Einwilligung dahinter zeigt `git` nicht.

**(2) Ist-Bestand mit Kommando und Zahl, getrennt nach laut und stumm — ERFÜLLT.** Die vier
Bestands-Kommandos, die [ADR-0023](../../adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md)
§*Ist-Bestand* im Wortlaut abdruckt, sind hier **verbatim von dort übernommen und über HEAD
gefahren** — Nennungen **56**, Dateien **14**, laute Hälfte **20**, stille Hälfte **36**;
20 + 36 = 56 geht auf. **Alle vier wandern mit dem Bestand und sind keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); die ADR nennt ihre Mess-Basis (`4e62366`) selbst, und die Beträge sind an HEAD
unverändert. Dass die stille Hälfte **nicht** als bewacht ausgegeben wird, steht dort an vier
Stellen ausdrücklich (Festlegung 3, zwei Konsequenzen-Punkte, Fitness Function *„Ausdrücklich
nicht: `versions`"*) — [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
ist damit an seiner scharfen Kante erfüllt, nicht an seiner bequemen.

**(3) Keine Gate-Lockerung, und sie steht als solche da — ERFÜLLT.** Festlegung 5 beantwortet die
Frage mit **nein** und führt vier Prüfungen. Die tragende ist über den ganzen Slice mechanisch
nachgemessen, nicht nur über den ADR-Commit:
`git diff --stat b0fb093^..HEAD -- .d-check.yml d-check.mk Makefile` ist **leer** — kein Byte an
der Gate-Konfiguration in irgendeinem der sieben Commits.

**(4) `make gates` grün — ERFÜLLT**, in diesem Lauf gefahren (Ausgabe im Closure-Commit).

**(5) Doku-Update ADR-Index — ERFÜLLT.**
`grep -c '0023-verweis-beschluss' docs/plan/adr/README.md` → **1**; die Zeile trägt Titel,
verlinkte Datei, den Bezugs-Satz und den Statuswert **Accepted**, gleichlautend mit der
Statuszeile der ADR.

**(6) Closure-Notiz mit Steering-Loop-Lerneintrag — ERFÜLLT**, diese Notiz.

**Rückführungen nach §4 — keine ausgelöst**, und beide Bedingungen sind gemessen: die Entscheidung
trägt **eine** Frage (der Sensor für die stille Hälfte ist nicht gebaut, sondern mit Kriterium
verworfen — Festlegung 3 und 4), und sie brauchte keine Baseline-Aussage, die erst nach dem Tausch
messbar wäre: alle tragenden Messungen liefen gegen den Ziel-Tag im Kurs-Klon und gegen Kopien
außerhalb des Repos, **vor** dem Tausch. Der Wellen-Schnitt — 080 entscheidet, 081 vollzieht — ist
an dieser Stelle bestätigt.

### Was funktionierte

**Die Reihenfolge trug.** Der Slice steht vor dem Tausch, und genau deshalb konnte die Frage nach
dem Wächter der stillen Hälfte **gemessen** statt vermutet beantwortet werden: der einzige
Kandidat wurde in einem Minimal-Repo gegen eine 2 × 2-Sonde gehalten und fiel an dem Feld, das
niemand vorhergesagt hatte — ein Verweis, der ins Leere zeigt und den aktuellen Tag trägt, lässt
`versions` schweigen. Ein Tausch-Lauf hätte diese Messung nicht mehr fahren können.

**Drei fremde Kontexte haben jede Zahl nachgefahren, und keine fiel.** Verifikation (Modul 11) und
Review (Modul 10) haben unabhängig voneinander sämtliche Messungen der ADR reproduziert —
einschließlich der zwei tragenden Sonden Feld für Feld und Datei für Datei. Die fünf MEDIUM des
Reviews betrafen ausnahmslos **Beiwerk mit langer Halbwertszeit**, keines die Entscheidung; alle
sechs Posten sind **vor** dem Umschlag geschlossen worden (`560f558`), also im letzten Fenster,
das [`AGENTS.md`](../../../../AGENTS.md) §3.4 offenlässt.

### Was anders lief — der Slice führte neunzehn Tage eine Frage, die am Tag seines Schnitts beantwortet wurde

**Gemessen, nicht erzählt.** Drei Zeitstempel, je mit
`git log -1 --format='%ad %s' --date=iso <commit>`: der Slice entstand am 2026-08-09 um
**11:15:58** (`6bf9950`, *„welle-10 geschnitten"*), die ADR, die seine Kernfrage entscheidet, ging
**31 Minuten und 2 Sekunden später** um **11:47:00** auf *Proposed* (`0f24119`) und war am selben
Abend um **20:07:03** *Accepted* (`b1bbbc7`). Sein §1 sagte
danach unverändert, es sei zu entscheiden, *„wie ein Verweis … einen Tag-Wechsel übersteht, wenn
er in einem unveränderlichen Artefakt steht"* — genau das, was
[ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegungen 1 bis 4 entschieden
hatten. Nach `in-progress` ging er am 2026-08-28 (`b0fb093`), **neunzehn Tage** später.

**Und die Beobachtung existierte am ersten Tag.** Um 20:33:41 desselben Abends schrieb ein
Planner-Lauf (`96d361e`) wörtlich: *„slice-080s Zustand passt nicht mehr zu `open/`. Vier seiner
DoD-Punkte sind mit der Annahme gedeckt"* — **in der Commit-Message**. Derselbe Commit hatte
`slice-080` offen und änderte §1
(`git show --pretty=format: --name-only 96d361e` → drei Plan-Dateien, darunter diese), aber nur
dort, wohin ein Link-Befund zeigte: eine Aufzählung von ADR-Namen. Die **Prämisse** darüber und
die **DoD** darunter blieben stehen. Neunzehn Tage später musste die Verifikation für DoD (1) das
Verdikt *„teilweise erfüllt"* erfinden, weil ein Punkt zwei Glieder trug, deren eines seit dem
ersten Tag gedeckt war.

**Dieselbe Klasse ein zweites Mal, im selben Slice.** `de1e4bc` fand dieselbe überholte Aussage an
**vier** Fundorten (drei genannt, ein vierter dazu). Der vierte entstand mechanisch: `363421c`
zog den **Pfad** der Roadmap-Zeile von `../next/` auf `../in-progress/` und ließ die **Prosa**
danebenstehen — *„liegt in `next/`"* —, weil der Sensor, der den Nachzug auslöst, Adressen prüft
und keine Aussagen.

### Steering-Loop-Eintrag — **benannte Spec-Lücke**, und der Träger ist geschnitten, nicht neu

**Die Klasse.** *Eine Beobachtung über ein **lebendes** Artefakt landet an einem Ort, den kein
späterer Lauf aufschlägt — und das Artefakt selbst wird nur dort angefasst, wohin ein mechanischer
Auslöser zeigt (Link, Pfad, Statuswert).* Zwei Instanzen in diesem Slice, oben je mit Commit
belegt: die Beobachtung in der Message von `96d361e`, und der Pfad-ohne-Prosa-Nachzug in
`363421c`.

**Die Lücke ist nicht der Regeltext.**
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
spricht die Diagnose bereits aus — *„Der Befund ist damit nicht die Wiederholung, sondern die
fehlende Trägerschaft: was allein in Zeitdokumenten steht, schlägt kein Lauf wieder auf"* — und
nennt unter seinen Fundorten ausdrücklich *„eine Commit-Message"*. Was fehlt, ist der **Ort**:
dieses Repo hat für eine Beobachtung über ein lebendes Artefakt keinen, den ein Lauf von sich aus
liest. Die Closure-Notiz ist keiner — sie liegt nach dem Übergang in `done/` und damit im
Zeitdokument-Bereich, den
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
§Geltungsbereich selbst ausnimmt.

**Und die adoptierte Baseline hat den Ort nicht, die Ziel-Fassung hat ihn.** Gemessen gegen einen
lokalen Kurs-Klon, je über den vendored Ausschnitt:
`git grep -l 'Beobachtungs-Register' v3.5.2 -- lab/regelwerk lab/templates | wc -l` → **0**
(Exit 1); dasselbe für `v5.12.0` → **18** Dateien. Beide Beträge wandern mit dem Kurs-Stand und
sind keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die Ziel-Fassung führt den Ort mit **zwei Lese-Schritten** statt nur mit einer
Schreibpflicht — `v5.12.0`, `modul-05-planning-harness.md`, §Lifecycle als State Machine:
*„`done` ist kein Endzustand der Information: Die Beobachtungen aus §7 sind bei der Slice-Closure
ins Beobachtungs-Register eingetragen und werden von dort weitergelesen"* — und hängt sie in
`v5.12.0`, `templates/docs/plan/planning/slice.template.md` an einen **DoD-Punkt je Slice**:
*„Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler +1 <!-- d-check:ignore (Pfad im Zitat der Ziel-Vorlage, existiert in diesem Repo nicht) -->
mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert."*
Ein Zähler *+1 mit Beleg* ist genau das, was hier fehlte: die Beobachtung vom 2026-08-09 wäre
beim zweiten Auftreten am 2026-08-28 nicht neu entstanden, sondern hochgezählt worden.

**Der Träger — und warum hier kein Slice geschnitten wird.**
[welle-10](../welle-10-re-baseline.md) §6 zieht die Grenze selbst: *„Ein Delta, das eigene Arbeit
verlangt, wird als Slice in `open/` notiert."* Der Durchgang, der die Form der Ziel-Fassung liest,
ist [slice-083](../open/slice-083-form-vergleich-pflichtfelder.md); sein §1 nennt `observations`
bereits als eine der vier neuen Vorlagen, seine drei DoD-Punkte decken aber **Singleton-Form**,
das Pflichtfeld `Ersetzt-Baseline-Regel` und die Append-only-Behandlung **wiederkehrender**
Vorlagen — eine **neue Artefakt-Klasse mit zwei Lese-Schritten** fällt zwischen sie. Der Posten
steht seit diesem Lauf dort in §6, mit den zwei Messungen oben. Ihn hier als eigenen Slice zu
schneiden hieße, im gepinnten Regime zu bauen, was das Ziel-Regime in derselben Welle mitbringt.

**Zwei benachbarte Schnitte tragen die Klasse nicht — geprüft, nicht angenommen.**
[slice-125](../open/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) verdrahtet die
Lifecycle-Invariante des Moduls `planning` (*Ruhe-Marker genau dann, wenn kein Slice im Block
liegt*) — sie sieht **Verzeichnis gegen Überschrift**, nicht einen veralteten Prosa-Satz; die
Drift, die `de1e4bc` zog, lag in einem Satz, den sein eigener Nachsatz bereits widerlegte, und
sein §1 misst für denselben Baum-Stand `0 Befund(e)`.
[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) trägt die Regel *„keiner
bleibt genannt"*, aber über eine **abgeschlossene Liste von zwölf** Posten, deren Quelle eine
Closure-Notiz und deren Ziel ein Norm-Artefakt ist; hier ist die Quelle eine Commit-Message und
das Ziel ein Plan-Artefakt. Die Liste zu erweitern hieße, eine DoD zu bewegen, die auf ihrer
Abgeschlossenheit steht.

### Ausgänge — jeder offene Posten hat einen, *„genannt"* ist keiner

| Posten | Herkunft | Ausgang |
|---|---|---|
| Die Migrations-Prozedur der Ziel-Fassung regiert ab jetzt | [ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 1, *Accepted* seit `485da30` | **bleibt gültig, kein Nachzug** — der Zuschnitt von 082–084 hängt an ihrem **Inhalt**, und der ist über beide Retargets unberührt (die Geschichte-Zeilen von `2026-08-27` sagen es, ihre Quelle `modul-02-harness-bootstrap.md` ist `v5.9.0` ↔ `v5.12.0` byte-gleich). [welle-10](../welle-10-re-baseline.md) §1 zeigt seit `b650730` auf Festlegung 1, statt sie zu doppeln; der Statuswechsel bewegt den Zeiger nicht |
| [ADR-0023](../../adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md) Folgepflicht 3 — die drei Klassen als **Sortier-Aufgabe**, nicht als Liste | die ADR, an die planende Rolle | **übernommen, und ausdrücklich ohne Liste** — [slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md) §1 führt bereits vier Klassen mit demselben Schnitt, einschließlich der Klasse *Tree-Operand der Vor-Tausch-Seite*, die stehen bleibt. Was fehlte, war der Zeiger auf die ADR; er steht seit diesem Lauf im Kopf jenes Slice. Eine Aufzählung der Treffer entsteht **beim Lauf**, wie die Folgepflicht es verlangt |
| [ADR-0023](../../adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md) Folgepflicht 1 — Links **und neue Dateinamen** ziehen, Anker einzeln, die [ADR-0017](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)-Ausnahme vollziehen | die ADR, an den Tausch-Slice | **an [slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md), dort schon verankert** — DoD (2) verlangt neuen Tag **und** neuen Dateinamen samt Anker-Einzelprüfung, §3 führt den einen `scan.ignore`-Eintrag als extensional geschlossen. Der Vollzug steht aus: `grep -c '0013-technik-stratum' .d-check.yml` → **0** (Exit 1), in diesem Lauf reproduziert |
| Die Bestandszahl in [slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md) ist überholt | dieser Lauf | **erledigt in jenem Plan** — die Sonde von 2026-08-09 zählte **21** gate-sichtbare Befunde über drei Fundorte; heute sind es **24** über vier, weil eine **lebende Plandatei** mit **3** hinzugekommen ist (`git grep -oE '\]\([^)]*\.harness/baseline/v3\.5\.2/[^)]*\)' -- ':!.harness/baseline' \| cut -d: -f1 \| sort \| uniq -c \| sort -rn`, Summe mit `\| wc -l` → **24**). Der Betrag wandert und ist kein Erwartungswert; die **Klassen** binden, nicht die Summe |
| [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)-Konstellation (Lockerung trifft Verschärfung) | [ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md) §*Dass die Wahl Folgen hat* | **bereits verankert, kein neuer Posten** — [slice-082](../done/slice-082-adaptions-durchgang.md) §6 führt ihn als **ersten** Punkt seiner Liste, mit dem Zweig *Carveout mit Auflösungs-Trigger* und der Rückführung `in-progress` → `open`, falls der Ausgang gegen [ADR-0014](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) fällt |
| Die Vorabmessung in [`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung) trägt bis zum Zielstand nicht | [ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md), Adaptions-Durchgang | **bereits verankert, in diesem Lauf gegengeprüft** — [slice-082](../done/slice-082-adaptions-durchgang.md) §6 führt ihn wörtlich als *„Posten dieses Durchgangs, keine Fußnote"*. Nachgemessen über **beide** Quellen des Eintrags: `git diff --shortstat v5.3.1 v5.12.0 -- lab/templates/AGENTS.template.md lab/regelwerk/grundlagen-harness-dateien.md` → **2 Dateien, +82/−12** (lokaler Kurs-Klon) — die Byte-Gleichheit, auf der die Vorabmessung ruht, besteht zum Zielstand für **keine** von beiden |
| LOW-1 und INFO-1 des Reviews (die Grundlagen-Datei ist am Bezugs-Tag nicht neu; *zwölf* gegen *elf* Muster-Alternativen) | Review `2026-08-28-adr-0023-review.md` | **erledigt vor der Annahme** (`560f558`, letzte zwei Posten): der Satz nennt jetzt die zwei neuen **Zeilen** statt der Datei, und dass der Vorgänger-Beschluss dasselbe Muster *„zwölf Wörter"* nennt, steht dabei |
| V-2 der Verifikation (*„vom damaligen Zielstand"* misst ab `v5.3.1`, [ADR-0016](../../adr/0016-verweis-traegt-tag-und-zitat.md) maß gegen `v5.3.0`) | Verifikation `2026-08-28-slice-080-verify.md` | **erledigt vor der Annahme** (`560f558`, Posten 6) — beide Tags stehen jetzt mit ihrem Betrag, und die Invarianz der Folgerungen ist mitgemessen |
| V-3 (*„sechs, nicht vier"* vergleicht zwei Mengen), V-4 (die Datei-Zahlen sind um eins gewandert), V-5 ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) in weiter Lesart) | Verifikation, drei Notizen | **kein Handlungsbedarf, und der Grund je einzeln** — V-3 ist mit der Mess-Basis aus `560f558` aufgelöst (beide Mengen sind benannt); V-4 erklärt die ADR vorab selbst (*„die geprüfte Datei-Zahl … wächst mit"*), die Befund-Zahlen sind unverändert; V-5 stellt Deckungsgleichheit von Plan und Artefakt fest und erfindet keine Regel. Keiner der drei ist nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 noch änderbar, und keiner müsste es sein |
| Der Slice führte neunzehn Tage eine beantwortete Frage | dieser Lauf | **Steering-Loop-Eintrag oben**, Träger [slice-083](../open/slice-083-form-vergleich-pflichtfelder.md) §6 |

### Übergabe an andere Rollen

- **An den Implementer, mit dem Start von [slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md):**
  die [ADR-0017](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)-Ausnahme ist
  **nicht** vollzogen (`grep -c '0013-technik-stratum' .d-check.yml` → 0, Exit 1); ohne sie wird
  `make docs-check` nach dem Tausch rot, an genau **einer** Datei —
  [ADR-0013](../../adr/0013-technik-stratum-als-zielort.md).
- **An den Planner (nicht dieser Lauf):** [welle-09](../welle-09-modul-15-konformitaet.md) §3/§4
  führen die Tool-Spalte auf dem Stand vor
  [ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md). Das ist derselbe
  Befund-Typ wie der Steering-Loop-Eintrag oben — eine überholte Aussage in einem **lebenden**
  Plan-Artefakt —, aber eine eigene Sitzung: dort sind vier Zellwerte, drei Closure-Kriterien und
  ein Slice-Zuschnitt aus acht Festlegungen neu abzuleiten.
- **An den Architect:** kein Posten. Beide ADRs sind seit `485da30` nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.4 unveränderlich; was an ihnen zu korrigieren gewesen
  wäre, ist im letzten Fenster davor geschlossen worden.

### Verifikation dieser Closure

`make gates` grün über dem Arbeitsbaum dieser Closure (Ausgabe im Closure-Commit).
**`make mutate` nicht gefahren** (Auflage, und gedeckt): der Slice berührt **keine** Code-Zeile —
`git diff --stat b0fb093^..HEAD -- ':!*.md'` ist leer —, kein Wächter kann durch diesen Diff seine
Zähne verloren haben; das vorliegende Protokoll meldet **198 ok, 0 Befund(e)** bei
`ls test/mutations/*.sh | wc -l` → **198**. **Kein `git push`.**

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `docs/plan/adr/` gehört
zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
