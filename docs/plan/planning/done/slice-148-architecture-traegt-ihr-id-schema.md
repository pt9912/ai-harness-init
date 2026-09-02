# Slice slice-148: `spec/architecture.md` trägt ihr `ARC-<NNN>`-Pflichtfeld

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-10](../welle-10-re-baseline.md) — Teil von Durchgang 2 (*Form*), abgetrennt aus
[slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §1/§6, dessen Form-Diff-Protokoll
das neue Pflichtfeld für dieses Artefakt bereits gemessen, aber nicht umgesetzt hat.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Doc-Gate, das per Abschnittsname statt per ID auf eine verschobene Zeile zeigen könnte, ist
das stille Grün, das diese Anforderung ausschließt),
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (jede nicht übernommene
Position der Ziel-Form ist als Abweichung zu begründen).

**Berührte Spec-Stellen:** `architecture.md §1` (Komponenten-Übersicht, vergibt `ARC-<NNN>`),
`§2` (Schichten und Constraints, referenziert die Kennung), `§3` (externe Abhängigkeiten, vergibt
`ARC-<NNN>`).

**Verantwortlich:** Architect (pt9912) — **Setzung, keine Ableitung**, dieselbe wie in
[slice-147](../done/slice-147-spezifikation-traegt-ihr-id-schema.md): keine Quelle benennt eine
schreibende Rolle für dieses Artefakt ([`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md)
grenzt die Architect-Zuordnung auf `AGENTS.md` §3 und den Adaptions-Block ein, Baseline-Regelwerk
`modul-03-spec.md` nennt für keines der drei Spec-Strata eine Rolle). Besetzt wird **gegen** den
Default aus `modul-05-planning-harness.md` §Lifecycle als State Machine
(Implementer-Rolleninhaber), weil der Liefergegenstand ein ID-Schema für ein normatives Dokument
ist — und bei diesem Artefakt zusätzlich, weil §1/§2 die **Komponenten- und Schichten-Sicht**
adressierbar machen, den Gegenstand, auf den die `Schärft:`-Felder von **10** ADRs zeigen (`grep -l "^\*\*Schärft:\*\*.*architecture\\.md" docs/plan/adr/*.md | wc -l`; keine Erwartungswerte). Die offene
Quellenfrage entscheidet das **nicht** — siehe §6, Risiko *Rollenfrage*.

**Autor:** Planner. **Datum:** 2026-08-31.

---

## 1. Ziel

`spec/architecture.md` bekommt das Pflichtfeld der Ziel-Fassung: `ARC-<NNN>` je Komponente (§1)
und je externer Abhängigkeit (§3), die Schichten-Tabelle in §2 referenziert die Kennung. Gemessen,
nicht neu entdeckt — der Form-Diff aus
[slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §1 führt diesen Ausgang bereits als
*„neues Pflichtfeld"*; dieser Slice ist die Umsetzung, die dort als zu groß für den einen
Durchgang zurückgeführt wurde.

**Die Ripple-Menge ist kleiner als bei `spezifikation.md` und liegt vollständig in immutablen
ADRs.** Zwei lebende Dateien außerhalb der Zeitdokumente zeigen per Abschnitts-Anker auf
`spec/architecture.md#…`
(`grep -rl 'architecture.md#' --include='*.md' . | grep -v '^\./\.harness/baseline' | grep -v
'^\./docs/reviews' | grep -v 'planning/done' | grep -v '^\./\.harness' | wc -l` → **2**):
[`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) und
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md), beide `Status:
Accepted` und beide auf **dieselbe** Zeile, `§5 Idempotenz, Fragment-Assembly und Resume`. Weder
Achse berührt dieser Slice inhaltlich — `ARC-<NNN>` wird in §1–§3 vergeben, §5 bleibt unangetastet.

> **Die Aussage stimmt, das Kommando gibt sie nicht aus** — nachgemessen im Umsetzungslauf. Es
> liefert **5**, weil seine `^\./`-verankerten Filter nicht greifen: `grep -rl <muster> .` gibt die
> Pfade **ohne** `./`-Präfix aus. **2** ist die Zahl der Dateien mit einem echten Anker-Verweis
> außerhalb von `done/` und dem vendored Baum, und das sind genau die zwei genannten ADRs
> (`grep -rl 'architecture\.md#5-idempotenz' --include='*.md' . | grep -v '\.harness' | grep -v
> 'planning/'`). Die restlichen Treffer des Kommandos tragen die Zeichenkette in einem
> Kommando-Block, nicht als Link. Dieselbe Klasse wie in slice-147, zweite Beobachtung — Ausgang
> in §7.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **(1) `ARC-<NNN>` je Komponente (§1) und externer Abhängigkeit (§3) vergeben, die
      Schichten-Tabelle (§2) referenziert die Kennung.** Ziel-Form aus dem Form-Diff-Protokoll
      ([slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §1, Zeile
      `spec/architecture.md`). Abschnitts-Überschriften bleiben unverändert, §5 bleibt
      inhaltlich unberührt.
- [x] **(2) Gegenprobe: `spec/architecture.md#5-idempotenz-fragment-assembly-und-resume` bleibt
      auflösbar.** Beide referenzierenden Accepted-ADRs ([`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md),
      [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)) sind nach
      `AGENTS.md` §3.4 immutabel — dieser Slice ändert keine von ihnen; die Gegenprobe ist
      Existenz-, keine Korrektur-Pflicht.
- [x] `make gates` grün.
- [x] Doku-Update: keiner über dieses Artefakt hinaus — die Kennungen sind die Doku-Änderung
      selbst.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register entfällt dauerhaft: dieses Repo hat keinen Brownfield-Bootstrap.
- [x] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler
      +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt
      Wellen-Betrieb, sie werden also von der nächsten Welle-Closure geprüft, nicht hier.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`spec/architecture.md`](../../../../spec/architecture.md) | update | `ARC-<NNN>` §1/§3, Referenz in §2 |
| [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md), [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) | prüfen, keine Änderung | Gegenprobe DoD (2) — beide immutabel, beide zeigen auf §5, das dieser Slice nicht anfasst |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): `in-progress/` trägt keinen Slice mehr (WIP-Limit 1) **und**
die Rollenfrage aus §6 ist entschieden — entweder durch eine benannte Quelle oder durch
Priorisierung mit `Verantwortlich:` = Implementer-Rolleninhaber als Default.

**Keine Reihenfolge-Bindung innerhalb der Welle.** Dieser Slice hängt an keinem anderen Mitglied
von [welle-10](../welle-10-re-baseline.md): [slice-147](../done/slice-147-spezifikation-traegt-ihr-id-schema.md)
berührt ein anderes Artefakt mit eigener Referenz-Menge, und die fortgeführte
`harness/conventions.md`-Arbeit in [slice-083](../done/slice-083-form-vergleich-pflichtfelder.md)
berührt keine spec-Datei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): unwahrscheinlich bei einer Ripple-Menge
  von zwei Dateien — träte sie dennoch ein (etwa weil §1/§3 stärker umgebaut werden müssen, als der
  Form-Diff zeigt), trennt der Schnitt Kennungs-Vergabe und Umbau.
- `in-progress` → `open` (blockiert — Carveout?): die Gegenprobe bricht an einem der zwei
  Accepted-ADR-Zeiger — dann wartet dieser Slice auf ein Folge-ADR (Architect-Zug), kein Carveout.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Kriterium 1** — DoD (1)/(2) abgehakt, die Kommando-Ausgabe aus §1 erneut gefahren: weiterhin
**2** lebende Referenzstellen, keine meldet `target-missing`. **Kriterium 2** — `make gates` grün.
**Lerneintrag** in §7 — ohne ihn geht der Slice nicht nach `done/`.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Rollenfrage: wer darf `spec/architecture.md` schreiben?** Keine kanonische Quelle benennt eine
  Rolle (Kopf oben). Wird ohne Klärung priorisiert, entscheidet der Default aus
  Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine (Implementer-
  Rolleninhaber) — das ist zulässig, aber eine **Setzung**, keine Ableitung, und sollte als solche
  im Priorisierungs-Commit benannt werden. — **Ausgang: weiter offen** → [`BEO-007`](../observations.md)
  auf **4×** erhöht, Beleg `slice-148`. Keine Quelle wurde benannt; das Feld steht als Setzung.
- **Die Gegenprobe (DoD 2) findet einen Anker-Bruch an einem der zwei Accepted-ADRs.** Beide
  zeigen auf dieselbe Zeile (§5), die dieser Slice nicht anfasst — das Risiko ist damit klein,
  aber nicht null, falls die Kennungs-Vergabe in §1/§3 eine Umnummerierung der nachfolgenden
  Abschnitte erzwingt. — **Ausgang: entfallen** — §5 bleibt an Position und Anker unverändert. Die
  Kennungs-Vergabe fügt Zeilen und eine Spalte hinzu und benennt keine Überschrift um; das
  Anker-Histogramm auf `architecture.md#…` ist vor und nach der Änderung dasselbe
  (`#5-idempotenz-fragment-assembly-und-resume` 8×), `make docs-check` meldet vorher wie nachher
  **486 Datei(en), 0 Befund(e)**. Keine der beiden ADRs ist angefasst.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren) · `grundlagen-traceability.md` §Herkunfts-Anker.

**Closure-Kriterien (beobachtet, nicht behauptet):**

1. **Die Gegenprobe aus §1/§5.** `make docs-check` → **486 Datei(en), 0 Befund(e)** vor und nach
   der Änderung; die zwei Anker-Verweise auf `#5-idempotenz-fragment-assembly-und-resume` lösen
   unverändert auf, das Histogramm ist dasselbe (8×). Die Zahl **2** aus §1 hält — ihr Kommando
   nicht, siehe die Notiz dort.
2. **`make gates` grün**, EXIT 0, nach dem Commit von `spec/architecture.md`; der
   Stop-Hook-Stempel deckt den Arbeitsbaum.

**Die Gestalt-Gegenprobe, gefahren statt vorausgesetzt.** Was in
[slice-147](../done/slice-147-spezifikation-traegt-ihr-id-schema.md) den einzigen realen Ripple
lieferte — eine Aussage über die **Gestalt** der geänderten Datei, die kein Anker-Check sieht —
ist hier vorab gefahren und **leer**: die zwei lebenden Aussagen über `spec/architecture.md`
halten (`grep -c 'sprach- und meilensteinfrei' spec/architecture.md` → **1**, unverändert; die
Wortgrenzen-Notiz in [ADR-0025](../../adr/0025-register-mit-gemischten-originalen.md) §Kontext
spricht über den vendored Baum, nicht über diese Datei). Kein Adaptions-Eintrag zählt Spalten
dieser Datei, also war
[`MR-044`](../../../../harness/conventions.md#mr-044--das-technik-stratum-trägt-die-id-spalte-der-ziel-form)
hier ohne Anwendungsfall.

- **Was hat funktioniert:** die Reihenfolge. Der größere Slice zuerst hat die Prüf-Achse
  geliefert, die der kleinere dann als Vorlauf fahren konnte — zwei Halbprüfungen statt einer:
  Anker (`docs-check`) und Gestalt (von Hand, ohne Gate).
- **Was ging anders als geplant:** dasselbe Kommando-Problem wie in slice-147, hier ein zweites
  Mal — das `grep -rl`-Idiom in §1 gibt **5** aus, wo der Satz **2** sagt. Die Aussage stimmt, ihr
  Beleg nicht; korrigiert steht er als Notiz in §1.
- **Steering-Loop-Eintrag: eine benannte Lücke** — *`spec/architecture.md` weicht über das
  `ID`-Feld hinaus an vier Stellen von der Ziel-Form ab, und eine davon ist nicht frei zu
  schließen.* Gemessen gegen `.harness/baseline/v5.12.0/templates/spec/architecture.template.md`:
  (1) das Kopf-Pflichtfeld `Rolle:` (*Sicht-Stratum — keine eigenen Anforderungen, derivativ*)
  fehlt; (2) die Hard Rule der Ziel-Form verbietet zusätzlich **ADR-Bezüge** und **Historie**;
  (3) §2 trägt `Verantwortung`/`Darf NICHT` statt `Verantwortlichkeit`/`Darf importieren`/`Darf
  NICHT importieren`; (4) §4 und §5 heißen anders als in der Vorlage (`Ablauf (Sequenzen)` /
  `Idempotenz, Fragment-Assembly und Resume` gegen `Sequenz-Diagramme` / `Fehlermodelle und
  Resilienz`) — `grep -n '^#\{2,3\} ' spec/architecture.md` gegen dasselbe Kommando auf der
  Vorlage. **Position (4) ist gesperrt:** §5 umzubenennen bräche den Anker, auf den
  [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) und
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) zeigen, und
  beide sind nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 immutabel. **Kein `liegt in`-Feld:**
  die `ARC-<NNN>`-Vergaberegel, die §1 jetzt trägt, stammt aus der Ziel-Form und nicht aus der
  3×-Schwelle — `grundlagen-traceability.md` §Herkunfts-Anker begrenzt den Anker ausdrücklich auf
  Steering-Loop-Regeln, und die Hard Rule dieses Artefakts verbietet Wellen- und Slice-Nennungen
  ohnehin.
- **Beobachtungs-Register (`../observations.md`):** keine neue Kennung, drei Erhöhungen.
  [`BEO-007`](../observations.md) 3× → **4×** (Rollenfrage, Beleg `slice-148`),
  [`BEO-010`](../observations.md) 1× → **2×** (die Form-Pflichten der Re-Baseline kommen einzeln
  als Nachzügler zurück — der Lerneintrag oben ist der Beleg: der Form-Diff führte für dieses
  Artefakt **eine** Position, gemessen sind es fünf), [`BEO-015`](../observations.md) 1× → **2×**
  (die Zahl neben dem nie gefahrenen Kommando, zweites Vorkommen in §1 dieses Plans).
- **Folge-Slices:** keine. Die vier offenen Ziel-Form-Positionen liegen als
  [`BEO-010`](../observations.md) im Register — bei 2× ist die Klasse ein **Symptom**, kein
  eigener Schnitt; der Lese-Schritt bei 3× liegt bei der Welle-Closure.
- **Risiken aus §6:** zwei benannt, zwei mit genau einem Ausgang — **eines entfallen**, **eines
  weiter offen** (im Register, [`BEO-007`](../observations.md)). Keines eingetreten.
- **Drei Paarungen:** hier **nicht** geprüft. Dieses Repo führt Wellen-Betrieb, und dieser Slice ist
  Mitglied von [welle-10](../welle-10-re-baseline.md); Modul 6 §Wellen-Closure-Prozedur legt die
  Paarungen auf Closure-Schritt 3c, Modul 8 §Rollen-Sequenz für eine Welle weist sie dem
  Planner-Kontext der Welle-Closure zu.

## 8. Sub-Area-Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** eine Sub-Area, `spec/` — Greenfield-Bestand nach der
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md), dieselbe
Einordnung wie in [slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §8,
[slice-136](../next/slice-136-roadmap-traegt-die-ziel-form.md) §8 und
[slice-147](../done/slice-147-spezifikation-traegt-ihr-id-schema.md) §8.

**Vorgelagert — offene Beobachtungen sichten:** Register vor der Arbeit durchgegangen
(`docs/plan/planning/observations.md`, **15** Einträge `BEO-001`–`BEO-015` zum Sichtungs-Zeitpunkt,
Sub-Area durchweg `*` per `BEO-004`; die Zahl wandert mit dem Register und ist kein Erwartungswert,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2 — `grep -c '^| BEO-' docs/plan/planning/observations.md`). **Drei Treffer, alle
unmittelbar:** [`BEO-007`](../observations.md) (3× — die Quellenfrage der schreibenden Rolle, sie
**ist** das erste Risiko in §6 und hat die Schwelle mit dem Vorgänger-Slice bereits erreicht),
[`BEO-009`](../observations.md) (2× — eine Änderung lässt die danebenstehende Zusage stehen; als
Gestalt-Gegenprobe vorab gefahren, §7) und [`BEO-015`](../observations.md) (1× — die Zahl neben
dem nie gefahrenen Kommando; §1 dieses Plans trägt dasselbe Idiom und wurde nachgemessen). Die
übrigen betreffen andere Mechaniken.

Alle berührten Sub-Areas GF: `spec/` gehört zum Greenfield-Bestand.
