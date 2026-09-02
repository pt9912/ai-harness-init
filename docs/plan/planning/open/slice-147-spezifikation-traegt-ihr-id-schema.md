# Slice slice-147: `spec/spezifikation.md` trägt ihr `SPEC-<NNN>`-Pflichtfeld

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-10](../welle-10-re-baseline.md) — Teil von Durchgang 2 (*Form*), abgetrennt aus
[slice-083](../in-progress/slice-083-form-vergleich-pflichtfelder.md) §1/§6, dessen Form-Diff-Protokoll
das neue Pflichtfeld für dieses Artefakt bereits gemessen, aber nicht umgesetzt hat.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Doc-Gate, das per Abschnittsname statt per ID auf eine verschobene Zeile zeigen könnte, ist
das stille Grün, das diese Anforderung ausschließt),
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (jede nicht übernommene
Position der Ziel-Form ist als Abweichung zu begründen).

**Berührte Spec-Stellen:** `spezifikation.md §2`–`§6` (die Tabellen, die das `SPEC-<NNN>`-Feld
bekommen) und `§7` (die dortige `ADR`-Spalte entfällt — Decken-Regel: kein ADR-Bezug in einem
Spec-Stratum, [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) §Kontext).

**Verantwortlich:** — bis zur Priorisierung. **Keine Quelle benennt eine schreibende Rolle für
dieses Artefakt** — [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) grenzt die
Architect-Zuordnung ausdrücklich auf `AGENTS.md` §3 und den Adaptions-Block in
`harness/conventions.md` ein (*„Über die übrigen Norm-Artefakte trifft diese ADR **keine**
Aussage"*), und Baseline-Regelwerk `modul-03-spec.md` §Ziel-Form: Spezifikation nennt für keines
der drei Spec-Strata eine Rolle. `AGENTS.md` §3.8 bestätigt das ausdrücklich für dieses Artefakt.
Siehe §6, Risiko *Rollenfrage*.

**Autor:** Planner. **Datum:** 2026-08-31.

---

## 1. Ziel

`spec/spezifikation.md` bekommt das Pflichtfeld der Ziel-Fassung: jede Tabelle in §2–§6 eine
`ID`-Spalte mit fortlaufendem `SPEC-<NNN>`, §7 verliert die `ADR`-Spalte. Gemessen, nicht neu
entdeckt — der Form-Diff aus [slice-083](../in-progress/slice-083-form-vergleich-pflichtfelder.md) §1
führt diesen Ausgang bereits als *„neues Pflichtfeld"*; dieser Slice ist die Umsetzung, die dort
als zu groß für den einen Durchgang zurückgeführt wurde (§4 dort, *„zwei weitere schwere
Posten"*).

**Der Liefer-Wert ist nicht die Spalte allein, sondern dass kein lebender Verweis unter ihr
bricht.** `spec/spezifikation.md` ist das am dichtesten referenzierte Artefakt dieses Repos
außerhalb der Singleton-Norm-Dateien selbst: **23** lebende Dateien zeigen per Abschnitts-Anker
darauf (`grep -rl 'spezifikation.md#' --include='*.md' . | grep -v '^\./\.harness/baseline' | grep
-v '^\./docs/reviews' | grep -v 'planning/done' | wc -l`), davon **6** ADRs mit `Status: Accepted`
oder `Proposed` (`… | xargs grep -l '^\*\*Status' 2>/dev/null` eingeschränkt auf
`docs/plan/adr/`, `wc -l` → **6**) — Accepted-ADRs sind nach `AGENTS.md` §3.4 immutabel und dürfen
von diesem Slice **nicht** editiert werden, auch wenn ihr Zeiger korrekturbedürftig würde.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) `SPEC-<NNN>`-Spalte in jeder Tabelle §2–§6, fortlaufend über die Datei; die
      `ADR`-Spalte in §7 entfällt.** Ziel-Form aus dem Form-Diff-Protokoll
      ([slice-083](../in-progress/slice-083-form-vergleich-pflichtfelder.md) §1, Zeile
      `spec/spezifikation.md`). Abschnitts-Überschriften bleiben unverändert — die Spalte fügt
      Inhalt hinzu, sie verschiebt keine Zeile und benennt keinen Anker um.
- [ ] **(2) Gegenprobe: jeder lebende Anker-Verweis auf `spec/spezifikation.md#…` bleibt
      auflösbar.** Vorher/Nachher-Diff derselben Kommando-Ausgabe aus §1 (die Dateiliste plus
      `docs-check`-Zählzeile); kein neuer `target-missing`-Befund. Bricht einer, ist er ein
      Risiko-Ausgang (§6), kein stiller Fix an einem ggf. immutablen Artefakt.
- [ ] `make gates` grün.
- [ ] Doku-Update: keiner über dieses Artefakt hinaus — die Spalte ist die Doku-Änderung selbst.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register entfällt dauerhaft: dieses Repo hat keinen Brownfield-Bootstrap.
- [ ] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler
      +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt
      Wellen-Betrieb, sie werden also von der nächsten Welle-Closure geprüft, nicht hier.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | update | `SPEC-<NNN>`-Spalte §2–§6, `ADR`-Spalte in §7 entfernt |
| die **23** referenzierenden Dateien (§1) | prüfen, keine Änderung erwartet | Gegenprobe DoD (2) — Abschnitts-Anker bleiben stehen, nur die Existenz wird geprüft |

**Nicht in dieser Liste:** `docs/plan/adr/*` — sechs davon zeigen auf `spezifikation.md#…`, fünf
mit `Status: Accepted` sind nach `AGENTS.md` §3.4 immutabel. Dieser Slice ändert **keine** ADR;
bricht die Gegenprobe an einer von ihnen, ist der Ausgang in §6 benannt, nicht hier stillschweigend
behoben.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): `in-progress/` trägt keinen Slice mehr (WIP-Limit 1) **und**
die Rollenfrage aus §6 ist entschieden — entweder durch eine benannte Quelle oder durch
Priorisierung mit `Verantwortlich:` = Implementer-Rolleninhaber als Default.

**Keine Reihenfolge-Bindung innerhalb der Welle.** Dieser Slice hängt an keinem anderen Mitglied
von [welle-10](../welle-10-re-baseline.md): [slice-148](slice-148-architecture-traegt-ihr-id-schema.md)
berührt ein anderes Artefakt mit eigener Referenz-Menge, und die fortgeführte
`harness/conventions.md`-Arbeit in [slice-083](../in-progress/slice-083-form-vergleich-pflichtfelder.md)
berührt keine spec-Datei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Gegenprobe DoD (2) findet mehr als
  eine Handvoll betroffener Zeilen, deren Klärung selbst Recherche pro Fundstelle verlangt (dieselbe
  Klasse, die [slice-083](../in-progress/slice-083-form-vergleich-pflichtfelder.md) reißen ließ) — dann
  trennt der Schnitt Spalten-Einfügung und Ripple-Klärung.
- `in-progress` → `open` (blockiert — Carveout?): die Gegenprobe bricht an einem
  Accepted-ADR-Zeiger, dessen Korrektur nur ein Folge-ADR leisten kann (§3.4) — dann wartet dieser
  Slice auf den Architect-Zug, kein Carveout (eine Ausnahme legte hier nichts fest, was nicht
  schon feststeht).

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Kriterium 1** — DoD (1)/(2) abgehakt, die Kommando-Ausgabe aus §1 erneut gefahren und im
Umsetzungs-Commit belegt: dieselbe Dateizahl referenziert `spezifikation.md#…`, keine davon meldet
`target-missing`. **Kriterium 2** — `make gates` grün. **Lerneintrag** in §7 — ohne ihn geht der
Slice nicht nach `done/`.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Rollenfrage: wer darf `spec/spezifikation.md` schreiben?** Keine kanonische Quelle benennt
  eine Rolle (Kopf oben). Wird ohne Klärung priorisiert, entscheidet der Default aus
  Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine (Implementer-
  Rolleninhaber) — das ist zulässig, aber eine **Setzung**, keine Ableitung, und sollte als solche
  im Priorisierungs-Commit benannt werden. — **Ausgang:** <eingetreten: eine Quelle wurde benannt,
  Feld gesetzt | entfallen: n/a — die Lücke besteht per Messung | weiter offen: → Beobachtung im
  nächsten Slice-Closure-Lauf notiert (kein neuer BEO-Eintrag vor Closure dieses Slice, Modul 6
  §Das Beobachtungs-Register: geschrieben wird bei Slice-Closure)>
- **Die Gegenprobe (DoD 2) findet einen Anker-Bruch an einem Accepted-ADR.** Fünf der sechs
  referenzierenden ADRs sind immutabel (§1); trifft die Spalten-Einfügung eine Zeile, auf die einer
  von ihnen zeigt, kann dieser Slice die ADR nicht korrigieren. — **Ausgang:** <eingetreten:
  Folge-ADR mit `supersedes` vorgeschlagen, dieser Slice liefert nur die Spalte und dokumentiert den
  Bruch | entfallen: keine der 23 Referenzstellen bricht (Abschnitts-Anker bleiben unverändert) |
  weiter offen>
- **Die Ripple-Menge (23 Dateien) ist größer als beim Schnitt von
  [slice-083](../in-progress/slice-083-form-vergleich-pflichtfelder.md) angenommen** (dort nur
  [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md),
  [`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben),
  [`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
  genannt) — die
  volle Gegenprobe zieht auch offene Slices in `open/`
  (`slice-071`, `slice-074`, `slice-075`, `slice-077`, `slice-078`, `slice-079`) und `AGENTS.md`
  selbst mit hinein. Keiner davon wird editiert (§3) — die Gegenprobe ist Existenz-, keine
  Korrektur-Pflicht. — **Ausgang:** <eingetreten: einzelne offene Slices brauchen bei ihrer eigenen
  Ausführung eine Nachmessung, notiert in ihrem eigenen §6 | entfallen: kein Slice betroffen |
  weiter offen>

## 7. Closure-Notiz

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** eine Sub-Area, `spec/` — Greenfield-Bestand nach der
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md), dieselbe
Einordnung wie in [slice-083](../in-progress/slice-083-form-vergleich-pflichtfelder.md) §8 und
[slice-136](slice-136-roadmap-traegt-die-ziel-form.md) §8.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen
(`docs/plan/planning/observations.md`, neun Einträge `BEO-001`–`BEO-009`, Sub-Area durchweg `*`
per `BEO-004`). Inhaltlich passt keiner auf eine ID-Spalten-Einfügung in einer Spec-Datei —
`BEO-008` (Kurzschluss bei Adaptions-Durchgängen) und `BEO-003` (`slice-mv`-Referenzformen)
betreffen andere Mechaniken; am nächsten kommt `BEO-009` (eine Ableitungs-Korrektur lässt eine
danebenstehende Zusage unverändert), dessen Muster hier als DoD (2) bereits eingepreist ist, statt
ein viertes Auftreten zu riskieren. **Keine unmittelbaren Treffer über die pauschale
`*`-Zuordnung hinaus.**

Alle berührten Sub-Areas GF: `spec/` gehört zum Greenfield-Bestand.
