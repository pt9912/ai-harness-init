# Slice slice-147: `spec/spezifikation.md` trägt ihr `SPEC-<NNN>`-Pflichtfeld

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

**Berührte Spec-Stellen:** `spezifikation.md §2`–`§6` (die Tabellen, die das `SPEC-<NNN>`-Feld
bekommen) und `§7` (die dortige `ADR`-Spalte entfällt — Decken-Regel: kein ADR-Bezug in einem
Spec-Stratum, [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) §Kontext).

**Verantwortlich:** Architect (pt9912) — **Setzung, keine Ableitung.** Keine Quelle benennt eine
schreibende Rolle für dieses Artefakt: [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md)
grenzt die Architect-Zuordnung auf `AGENTS.md` §3 und den Adaptions-Block ein, und
Baseline-Regelwerk `modul-03-spec.md` §Ziel-Form: Spezifikation nennt für keines der drei
Spec-Strata eine Rolle. Besetzt wird **gegen** den Default aus
`modul-05-planning-harness.md` §Lifecycle als State Machine (Implementer-Rolleninhaber), weil der
Liefergegenstand ein ID-Schema für ein normatives Dokument mit repo-weiter Ripple-Wirkung ist —
dieselbe Klasse wie die Norm-Artefakte, die `AGENTS.md` §3.8 dem Architect gibt, und dieselbe
Personalunion, die [slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §3 für
`.harness/skills/reviewer.md` bereits eingegangen ist. Die offene Quellenfrage entscheidet das
**nicht** — siehe §6, Risiko *Rollenfrage*.

**Autor:** Planner. **Datum:** 2026-08-31.

---

## 1. Ziel

`spec/spezifikation.md` bekommt das Pflichtfeld der Ziel-Fassung: jede Tabelle in §2–§6 eine
`ID`-Spalte mit fortlaufendem `SPEC-<NNN>`, §7 verliert die `ADR`-Spalte. Gemessen, nicht neu
entdeckt — der Form-Diff aus [slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §1
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

> **Die Zahl 23 reproduziert nicht, und das Kommando misst nicht, was der Satz sagt** — nachgemessen
> im Umsetzungslauf, Ausgang in §7. Das Kommando gibt **24** aus, und die zwei `^\./`-verankerten
> Filter greifen gar nicht, weil `grep -rl <muster> .` die Pfade **ohne** `./`-Präfix ausgibt; die
> Zeitdokumente und die vendored Vorlage bleiben also drin. **19** ist die Zahl, die der Satz meint
> (`grep -rl 'spezifikation.md#' --include='*.md' . | grep -v '\.harness/baseline' | grep -v
> 'docs/reviews' | grep -v 'planning/done' | wc -l`). Die Sätze oben bleiben als geschriebene
> Fassung stehen; die Messung steht hier daneben.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **(1) `SPEC-<NNN>`-Spalte in jeder Tabelle §2–§6, fortlaufend über die Datei; die
      `ADR`-Spalte in §7 entfällt.** Ziel-Form aus dem Form-Diff-Protokoll
      ([slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §1, Zeile
      `spec/spezifikation.md`). Abschnitts-Überschriften bleiben unverändert — die Spalte fügt
      Inhalt hinzu, sie verschiebt keine Zeile und benennt keinen Anker um.
- [x] **(2) Gegenprobe: jeder lebende Anker-Verweis auf `spec/spezifikation.md#…` bleibt
      auflösbar.** Vorher/Nachher-Diff derselben Kommando-Ausgabe aus §1 (die Dateiliste plus
      `docs-check`-Zählzeile); kein neuer `target-missing`-Befund. Bricht einer, ist er ein
      Risiko-Ausgang (§6), kein stiller Fix an einem ggf. immutablen Artefakt.
- [x] `make gates` grün.
- [x] Doku-Update: keiner über dieses Artefakt hinaus — die Spalte ist die Doku-Änderung selbst.
      **Nicht gehalten:** zwei weitere Dateien, je mit Grund in §7 (`harness/conventions.md` —
      Architect-Artefakt, eigener Commit; `open/slice-148…` — vier Verweise, die der
      Lifecycle-Wechsel dieses Slice brach).
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
von [welle-10](../welle-10-re-baseline.md): [slice-148](../done/slice-148-architecture-traegt-ihr-id-schema.md)
berührt ein anderes Artefakt mit eigener Referenz-Menge, und die fortgeführte
`harness/conventions.md`-Arbeit in [slice-083](../done/slice-083-form-vergleich-pflichtfelder.md)
berührt keine spec-Datei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Gegenprobe DoD (2) findet mehr als
  eine Handvoll betroffener Zeilen, deren Klärung selbst Recherche pro Fundstelle verlangt (dieselbe
  Klasse, die [slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) reißen ließ) — dann
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
  im Priorisierungs-Commit benannt werden. — **Ausgang: weiter offen** → [`BEO-007`](../observations.md)
  auf **3×** erhöht, Beleg `slice-147`. Keine Quelle wurde benannt; das Feld steht als Setzung
  (Kopf oben, Commit `cd5d2bb`).
- **Die Gegenprobe (DoD 2) findet einen Anker-Bruch an einem Accepted-ADR.** Fünf der sechs
  referenzierenden ADRs sind immutabel (§1); trifft die Spalten-Einfügung eine Zeile, auf die einer
  von ihnen zeigt, kann dieser Slice die ADR nicht korrigieren. — **Ausgang: entfallen** — keine
  der Referenzstellen bricht. Die Anker-Menge ist vor und nach der Änderung dieselbe
  (`#5-metriken-und-tracing-felder` 86×, `#3-defaults-und-konstanten` 8×, `#aufnahme-regel` 7×),
  `make docs-check` meldet vorher wie nachher **486 Datei(en), 0 Befund(e)**. Zum
  Accepted-Grenzfall, der **kein** Anker-Bruch ist, siehe §7.
- **Die Ripple-Menge (23 Dateien) ist größer als beim Schnitt von
  [slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) angenommen** (dort nur
  [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md),
  [`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben),
  [`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
  genannt) — die
  volle Gegenprobe zieht auch offene Slices in `open/`
  (`slice-071`, `slice-074`, `slice-075`, `slice-077`, `slice-078`, `slice-079`) und `AGENTS.md`
  selbst mit hinein. Keiner davon wird editiert (§3) — die Gegenprobe ist Existenz-, keine
  Korrektur-Pflicht. — **Ausgang: eingetreten**, aber an einer anderen Achse als hier erwartet:
  keiner der offenen Slices braucht eine Nachmessung (ihre Zeiger sind Abschnitts-Anker und
  stehen), dafür brach eine **Aussage über die Gestalt** der Tabelle — die Spaltenzahl in
  [`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  Punkt 1. Kein Folge-Slice: der Ausgang ist
  [`MR-044`](../../../../harness/conventions.md#mr-044--das-technik-stratum-trägt-die-id-spalte-der-ziel-form),
  geschrieben im selben Lauf und in eigenem Commit (§7).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren) · `grundlagen-traceability.md` §Herkunfts-Anker.

**Closure-Kriterien (beobachtet, nicht behauptet):**

1. **Die Gegenprobe aus §1/§5, vorher und nachher identisch.** `make docs-check` → **486
   Datei(en), 0 Befund(e)** vor und nach der Änderung; das Anker-Histogramm auf
   `spezifikation.md#…` ist unverändert (86 / 8 / 7). Keine Überschrift bewegt, kein Anker
   umbenannt — die `ID`-Spalte fügt eine Zelle je Zeile hinzu.
2. **`make gates` grün**, EXIT 0, nach dem Commit von `spec/spezifikation.md` und
   [`MR-044`](../../../../harness/conventions.md#mr-044--das-technik-stratum-trägt-die-id-spalte-der-ziel-form);
   der Stop-Hook-Stempel deckt den Arbeitsbaum.

**Der Accepted-Grenzfall, benannt statt übergangen.**
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) Festlegung 3 sagt *„Provenienz lebt
allein in seiner Historie-Tabelle"*, und §7 trägt seit diesem Slice keine `ADR`-Spalte mehr. Das
ist **kein** Widerspruch und darum auch kein Folge-ADR: das Wort ist *allein*, also eine
Ausschließlichkeits-Schranke und keine Pflicht, dort etwas zu führen — und die Begründung derselben
Festlegung trägt die Verengung ausdrücklich (*„ein Abwärts-Zeiger rottet, sobald eine ADR abgelöst
wird, und die Auffindbarkeit läuft ohnehin über das `Schärft:`-Feld der ADR"*). Die ADR ist
**nicht** angefasst ([`AGENTS.md`](../../../../AGENTS.md) §3.4). Dieselbe Richtung entscheidet
[`MR-042`](../../../../harness/conventions.md#mr-042--der-anlass-einer-lastenheft-änderung-steht-nicht-in-der-historie-sondern-in-der-closure-notiz)
für das Lastenheft; der dortige Bestandsschutz für vorhandene Zeilen hängt am Cutoff von
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
und gilt für dieses Artefakt nicht — hier verlangt die Ziel-Form die Spalte selbst nicht mehr.

- **Was hat funktioniert:** der Vorlauf. §8 hatte
  [`BEO-009`](../observations.md) ausdrücklich als das Muster benannt, das hier drohte — *eine
  Änderung korrigiert die Sache und lässt die danebenstehende Zusage stehen* —, und genau dieser
  Fall trat ein: [`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  Punkt 1 zählt für §5 vier Spalten, seit der `ID`-Spalte sind es fünf. Er wurde **im selben Lauf**
  gefunden und aufgelöst, statt von einem späteren Lauf. Der Zähler von `BEO-009` steigt deshalb
  **nicht**: die Beobachtung lautet *„lässt … unverändert stehen"*, und das ist nicht eingetreten.
- **Was ging anders als geplant — zwei Posten.** (1) **Die Ripple-Prüfung dieses Plans war auf
  Anker-Auflösbarkeit geschnitten und konnte den einen realen Treffer nicht sehen.** `docs-check`
  meldet 0 Befunde, während eine Aussage über die *Gestalt* der Tabelle falsch wird; kein Modul aus
  `modules:` der [`.d-check.yml`](../../../../.d-check.yml) hält einen Satz gegen die Datei, die er
  beschreibt. (2) **Die Zahl 23 in §1/§3 reproduziert nicht** — das Kommando gibt 24 aus, und seine
  zwei `^\./`-verankerten Filter greifen nicht, weil `grep -rl <muster> .` ohne `./`-Präfix ausgibt;
  die Zahl, die der Satz meint, ist **19**. Neue Beobachtung, siehe unten.
- **Steering-Loop-Eintrag: eine geschärfte Regel, verkörpert** — *eine registrierte Abweichung
  trägt ihren Umfang, und wer den beschriebenen Gegenstand ändert, zählt ihn neu* — liegt in
  [`harness/conventions.md` §MR-044](../../../../harness/conventions.md#mr-044--das-technik-stratum-trägt-die-id-spalte-der-ziel-form).
  Geschrieben hat sie der **Architect** in eigenem Commit ([`AGENTS.md`](../../../../AGENTS.md)
  §3.8, `da208dc`);
  [`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  bekam dabei die Kopf-Marke nach
  [`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 1, sein Rumpf blieb unangetastet. **Herkunfts-Anker:** der Zielort trägt ihn als
  `Wirksamkeits-Anlass: slice-147`, blank — die Feld-Form dieses Blocks
  ([`MR-028`](../../../../harness/conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt)).
- **Beobachtungs-Register (`../observations.md`):** eine neue Kennung und eine Erhöhung.
  **`BEO-015`** (neu, 1×): *eine Zahl steht neben einem Kommando, das nie gefahren wurde — sie
  reproduziert nicht, und ein Filter des Kommandos greift gar nicht*; Beleg `slice-147`.
  [`BEO-007`](../observations.md) von 2× auf **3×**, Beleg `slice-147`: die Quellenfrage der
  schreibenden Rolle trifft zum dritten Mal zu, diesmal außerhalb von `.claude/commands/`. Damit ist
  die Schwelle erreicht; der **Lese-Schritt liegt bei der Closure von
  [welle-10](../welle-10-re-baseline.md)** (dieses Repo fährt Wellen-Betrieb, Modul 6
  §Wellen-Closure-Prozedur Schritt 3, Rollen-Zug Planner → Architect → Planner nach Modul 8). Ein
  Slice-Schnitt an dieser Stelle wäre Planner-Arbeit im Architect-Kontext und damit genau der Fall,
  den [`AGENTS.md`](../../../../AGENTS.md) §3.8 ausschließt.
- **Folge-Slices:** keine. Der einzige eingetretene Ripple ist mit
  [`MR-044`](../../../../harness/conventions.md#mr-044--das-technik-stratum-trägt-die-id-spalte-der-ziel-form)
  aufgelöst; `BEO-007` und `BEO-015` liegen im Register.
- **Risiken aus §6:** drei benannt, drei mit genau einem Ausgang — **eines entfallen**, **eines
  eingetreten** (aufgelöst, kein Folge-Slice), **eines weiter offen** (im Register,
  [`BEO-007`](../observations.md)).
- **Drei Paarungen:** hier **nicht** geprüft. Dieses Repo führt Wellen-Betrieb, und dieser Slice ist
  Mitglied von [welle-10](../welle-10-re-baseline.md); Modul 6 §Wellen-Closure-Prozedur legt die
  Paarungen auf Closure-Schritt 3c, Modul 8 §Rollen-Sequenz für eine Welle weist sie dem
  Planner-Kontext der Welle-Closure zu.

## 8. Sub-Area-Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** eine Sub-Area, `spec/` — Greenfield-Bestand nach der
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md), dieselbe
Einordnung wie in [slice-083](../done/slice-083-form-vergleich-pflichtfelder.md) §8 und
[slice-136](../next/slice-136-roadmap-traegt-die-ziel-form.md) §8.

**Vorgelagert — offene Beobachtungen sichten:** Register vor der Arbeit durchgegangen
(`docs/plan/planning/observations.md`, **14** Einträge `BEO-001`–`BEO-014` zum Sichtungs-Zeitpunkt,
Sub-Area durchweg `*` per `BEO-004`; die Zahl wandert mit dem Register und ist kein Erwartungswert,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2 — `grep -c '^| BEO-' docs/plan/planning/observations.md`). **Zwei Treffer, beide
unmittelbar:** [`BEO-007`](../observations.md) (2× — die Quellenfrage der schreibenden Rolle; sie
**ist** das erste Risiko in §6 und erreicht mit diesem Slice die Schwelle) und
[`BEO-009`](../observations.md) (2× — eine Änderung lässt die danebenstehende Zusage stehen; hier
als Vorab-Prüfung eingepreist, statt sie als DoD (2) allein zu tragen: die Anker-Gegenprobe sieht
eine Gestalt-Aussage nicht). Die übrigen betreffen andere Mechaniken.

Alle berührten Sub-Areas GF: `spec/` gehört zum Greenfield-Bestand.
