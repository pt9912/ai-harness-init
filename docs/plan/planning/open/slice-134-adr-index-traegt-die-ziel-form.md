# Slice slice-134: Der ADR-Index trägt die Ziel-Form, die seine Vorlage seit je verlangt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Das Kriterium ist nicht die Größe der Arbeit, sondern ob es eine
beobachtbare Closure-Bedingung gibt, die **mehr** beobachtet als die DoD dieses Slice —
Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht: *„Bei einem einzelnen
Slice ist das der Regelfall: Sein Closure-Trigger würde die eigene DoD abschreiben."* Hier gibt
es sie nicht: keines der Closure-Kriterien von [welle-10](../welle-10-re-baseline.md) §3 wird von
diesem Slice belegt, und keines braucht ihn. **Der Grund ist gemessen, nicht angenommen:** der
Befund unten stammt **nicht** aus dem Re-Baseline-Delta (§1) — also trägt ihn auch nicht die
Welle, die das Delta abarbeitet. Die drei Paarungen (Anker · Folge-Slice · Register) prüft
gleichwohl die nächste Welle-Closure: dieses Repo fährt Wellen-Betrieb, und die liest *„alles,
was seit der letzten Welle in `done/` liegt — auch Slices ohne Wellen-Zugehörigkeit"* (dasselbe
Modul). **Wellenlose Arbeit erscheint nicht in der Roadmap**, ebenfalls von dort; ihr Zustand ist
allein die Verzeichnis-Position.

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) — die Aussage
*„keine inhaltlichen Adaptionen ggü. Baseline-Default"* ist genau die, über die dieser Slice
etwas herausfindet: ein Posten der Ziel-Form, der weder übernommen noch als Abweichung erklärt
ist, ist keines von beidem.
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(die Link-Pflicht, an der die `Bezug`-Spalte des Index hängt),
[ADR-0015](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) (§Kontext — dieselbe offene
Frage eine Stelle weiter: für dieses Artefakt benennt keine Quelle die schreibende Rolle, §6).

**Berührte Spec-Stellen:** — Dieser Slice berührt keine. Der ADR-Index ist eine **derivative
Sicht** auf `docs/plan/adr/` und steht in keiner der beiden Precedence-Listen; was eine
Entscheidung sagt, sagt ihre Datei. Der Verweis zeigt ohnehin **aufwärts**: die Spec nennt diesen
Slice nie (Baseline-Regelwerk `grundlagen-referenz-richtung.md` §Referenz-Richtung (SDP)).

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-08-29.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Jeder Posten, in dem `docs/plan/adr/README.md` von seiner vendored Ziel-Form abweicht, trägt
eine Entscheidung — übernommen oder als Abweichung erklärt —, und keiner steht unbeantwortet da.**

### Die drei Posten, je mit dem Kommando, das sie zeigt

Ziel-Form ist `.harness/baseline/v5.12.0/templates/docs/plan/adr/README.template.md`
([`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert):
die Vorlage wird referenziert, nicht kopiert).

| # | Posten | Ist | Ziel-Form |
|---|---|---|---|
| 1 | Kopfzelle der Tabelle | `ADR` | `ID` |
| 2 | Konventionen-Bullet | fehlt | *„Bei `Accepted`: diesen Index aktualisieren (Status, Datum)."* |
| 3 | Konventionen-Bullet | fehlt | die `**Schärft:**`-Aufwärts-Deklaration je ADR |

```sh
T=.harness/baseline/v5.12.0/templates/docs/plan/adr/README.template.md
grep -m1 '^| ' docs/plan/adr/README.md    # 1: | ADR | Titel | Status | Bezug |
grep -m1 '^| ' "$T"                       # 1: | ID | Titel | Status | Bezug |
grep -c 'diesen Index aktualisieren' docs/plan/adr/README.md   # 2: 0
grep -c 'Schärft' docs/plan/adr/README.md                      # 3: 0
```

**Kein Erwartungswert:** die zwei Nullen wie die Kopfzeile wandern, sobald jemand den Index
anfasst
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — tragend ist, dass zu jedem Posten eine Entscheidung existiert, nicht die Ziffer.

**Posten 2 trägt eine Frage an die Ziel-Form selbst, und sie gehört mit übernommen.** Der Bullet
verlangt, *„(Status, Datum)"* nachzuziehen — die Tabelle der Vorlage führt aber **keine**
Datums-Spalte (`grep -m1 '^| ' "$T"`, oben), und die des Repos ebenso wenig. Wer den Satz
wörtlich übernimmt, schreibt eine Pflicht auf eine Spalte, die es nicht gibt. Der Slice
entscheidet damit **auch**, worauf sich *Datum* bezieht — Spalte, Kopffeld der Zieldatei oder
nichts —, statt die Unschärfe mit zu kopieren.

### Der Befund stammt nicht aus dem Delta — und das entscheidet, wohin er gehört

Die Vorlage sagt beide fehlenden Sätze und die Kopfzelle `ID` **schon am abgelösten Stand**; der
Sprung `v3.5.2` → `v5.12.0` hat an ihnen nichts geändert, sondern nur die Referenz-Form zweier
Bullets (Kurs-URL → `Baseline-Regelwerk …`) und eine Kennungs-Präzisierung ergänzt:

```sh
diff <(git show c6cc56f:.harness/baseline/v3.5.2/templates/docs/plan/adr/README.template.md) \
     .harness/baseline/v5.12.0/templates/docs/plan/adr/README.template.md
```

→ zwei Hunks, beide in der Bullet-**Begründung**, keiner an Kopfzelle oder Bullet-Bestand
(`c6cc56f` ist der Vor-Tausch-Stand, s. `git log --oneline -- .harness/baseline/`).

Damit ist der Fund **kein** Re-Baseline-Delta, sondern die Klasse, die Baseline-Regelwerk
`modul-07-carveouts.md` ausdrücklich **außerhalb** des Carveout-Trichters führt — dort verbatim:
*„Ein Fund aus der Stichprobe des Freshness-Audits — eine Baseline-Regel, die nie ins ausgefüllte
Artefakt übernommen wurde — liegt zwischen adoptierter Norm und Artefakt. Punktuell behandelt der
Trichter ihn richtig: Übernahme im nächsten Slice, oder Carveout mit Auflösungs-Trigger."* Die
Klasse ist durch *„nie übernommen"* definiert, nicht durch die **Tür**, durch die der Fund
hereinkam; dieser kam durch eine Verifikation statt durch die Stichprobe, und das ändert an der
Behandlung nichts. Dieser Slice ist die **Übernahme**. Ein Carveout wäre das falsche Gefäß: er
nimmt ein **Gate** aus, und hier hängt an keinem der Posten eines — kein Modul aus `modules:` der
`.d-check.yml` liest eine Kopfzelle oder eine fehlende Bullet-Zeile (§6).

**Er ist auch nicht die Stichprobe.** Die führt
[slice-084](slice-084-stichprobe-gegen-bestand.md) — *ein* Abschnitt pro Audit, rotierend, mit
belegter Wahl. Dieser Fund ist ihr **Ergebnis-Typ**, nicht ihre Ausführung: er fiel bei der
Verifikation von [slice-081](../in-progress/slice-081-baum-tauschen-pin-ziehen.md) an, weil dort
der ADR-Index über vier Commits umgeschrieben wurde, ohne dass ein Plan-Posten ihn führte. Die
Rotation aus 084 bleibt davon unberührt und darf diesen Abschnitt nicht als *„schon geprüft"*
abziehen.

### Was daneben liegt und hier nicht mitkommt

[slice-083](slice-083-form-vergleich-pflichtfelder.md) trägt den Form-Vergleich der **Singletons**
und des Reviewer-Skills; seine Menge ist dort namentlich aufgezählt und nennt den ADR-Index nicht.
Beide Slices machen dieselbe Art Arbeit an verschiedenen Artefakten — die Trennung steht in
083 §2 (1) und hier, damit kein Lauf sie doppelt tut.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Jeder der drei Posten aus §1 trägt genau einen Ausgang — übernommen oder begründete
      Abweichung —, und keiner bleibt offen.** Die Prüfung läuft **je Posten**, nicht als
      Paket: die drei sind verschiedene Aussagen und können verschieden ausgehen. Fällt einer auf
      *Abweichung*, steht die Begründung **am Index**, nicht in diesem Plan, und sie nennt, wovon
      abgewichen wird ([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage):
      eine unerklärte Abweichung ist keine Adaption, sondern ein Fork). Die Kommandos aus §1 sind
      danach erneut zu fahren — sie sind der Nachweis, nicht die Erinnerung.
- [ ] **(2) Für beide fehlenden Bullets ist zwischen Wiederholung und Zeiger entschieden — und
      die Wahl steht mit ihrem Grund am Index.** Die Frage stellt sich, weil beide Regeln im Repo
      **schon einen Ort haben**, und wie weit, ist gemessen statt geschätzt:
      - Die `**Schärft:**`-Aufwärts-Deklaration ist **vollständig befolgt** — sie steht in jeder
        ADR-Datei (`grep -l '^\*\*Schärft:\*\*' docs/plan/adr/0*.md | wc -l` gegen
        `ls docs/plan/adr/0*.md | wc -l` → am 2026-08-29 **23** zu **23**; beide Zahlen wachsen
        mit jeder neuen ADR,
        [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
        Setzung 2). Hier geht es allein darum, ob der Index sie **wiederholt**.
      - Die Index-Pflicht ist nur **teilweise** anderswo getragen:
        [`AGENTS.md`](../../../../AGENTS.md) §5 sagt *„Neue ADRs aktualisieren den ADR-Index."*
        (`grep -c 'ADR-Index' AGENTS.md` → am 2026-08-29 **1**) — das deckt den **neuen**
        Eintrag, nicht den späteren `Accepted`-Wechsel und nicht das *Datum* (§1). Was fehlt, ist
        also nicht nur eine Wiederholung, sondern ein Stück Regel.
      **Dagegen steht *„eine Aussage hat einen Ort"*, dafür die Ziel-Form** — die Entscheidung ist
      je Bullet zu treffen und zu begründen, nicht offen zu lassen. **Eine dritte Antwort — die
      Frage nicht stellen — ist ausgeschlossen**, denn genau so entstand der heutige Zustand.
- [ ] `make gates` grün.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist — `docs/plan/adr/README.md` ist
      **keiner**: er ist derivativ, und keine ADR-Datei wird von diesem Slice angefasst
      ([`AGENTS.md`](../../../../AGENTS.md) §3.4).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (die `observations.md` neben den Wellen): das Repo führt **keines** —
      die Datei existiert nicht. Das Item entfällt nicht still, sondern mit diesem Grund; er wird
      in §7 notiert. Dasselbe gilt für das Reconciliation-Register: das Repo hat keinen
      Brownfield-Bootstrap.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt
      Wellen-Betrieb, sie werden also von der nächsten Welle-Closure geprüft, nicht hier (auch
      für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/adr/README.md` | update | die einzige Datei, die dieser Slice ändert — Kopfzelle und Konventionen-Abschnitt, je Posten mit seinem Ausgang |
| `docs/plan/adr/0*.md` | **unverändert** | sämtlich `Accepted` und damit immutabel ([`AGENTS.md`](../../../../AGENTS.md) §3.4); der Index bessert nicht nach, was in der Quelle nicht mehr änderbar ist — das sagt er heute schon selbst |
| [`AGENTS.md`](../../../../AGENTS.md) §5 | **unverändert** | trägt die Index-Pflicht bereits (§2 (2)); ob der Index sie wiederholt, wird **dort** nicht entschieden, und eine zweite Fassung derselben Regel entsteht hier nicht ohne die Entscheidung aus §2 (2) |
| `.harness/baseline/v5.12.0/templates/` | **unverändert** | committet vendored Fremd-Blob; ein Edit wäre ein Fork und bräche [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) |
| `.d-check.yml` | **unverändert** | der Slice baut keinen Wächter; ob einer baubar ist, ist eine benannte Frage, kein Liefer-Punkt (§6) |

**Die schreibende Rolle ist ungeklärt, und das steht hier statt in einer Fußnote.**
[`AGENTS.md`](../../../../AGENTS.md) §3.8 bindet ausdrücklich nur die Hard Rules und den
Adaptions-Block an den Architect und sagt daneben: *„Über andere Norm-Artefakte sagt diese Regel
nichts. … wo keine sie benennt, bleibt die Frage offen."* Für diese Datei benennt keine Quelle
eine (`git grep -n 'adr/README' AGENTS.md harness/conventions.md` → kein Treffer). **Faktisch**
schreiben sie Architect-Läufe: `git log --format='%s' -- docs/plan/adr/README.md | head -4` nennt
viermal *„Rolle Architect"*. Praxis ist keine Zuständigkeit — der Slice klärt sie zuerst oder gibt
den Punkt als Übergabe hinaus, wie es
[slice-083](slice-083-form-vergleich-pflichtfelder.md) §3 für den Reviewer-Skill vorsieht.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): das **WIP-Limit von 1 ist frei** —
`ls docs/plan/planning/in-progress/ | grep -c '^slice-'` liefert **0**, gelesen auf dem
Hauptzweig (am 2026-08-29 liefert es **1**, den laufenden
[slice-081](../in-progress/slice-081-baum-tauschen-pin-ziehen.md)). Eine inhaltliche Vorbedingung
hat dieser Slice **nicht**: die Ziel-Form liegt
vendored im Baum und wechselt bis dahin nicht ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache):
ein Tag zur Zeit). Insbesondere wartet er **nicht** auf
[slice-083](slice-083-form-vergleich-pflichtfelder.md) — andere Artefakt-Menge, andere Ziel-Form
(§1).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Entscheidung aus §2 (2) für
  einen der zwei Bullets bedeutet, dass **die Regel selbst** (nicht ihre Wiedergabe im Index) zu
  schreiben ist — dann trennt der Schnitt die Übernahme in den Index von der Norm-Arbeit, denn
  die liegt in fremden Artefakten und in einer fremden Rolle (§3).
- `in-progress` → `open` (blockiert — Carveout?): wenn die Zuständigkeits-Frage aus §3 vor der
  ersten Zeile beantwortet werden muss und die Antwort nicht in diesem Lauf fällt. Ein Carveout
  entsteht dabei nicht: es gibt kein Gate, das auszunehmen wäre (§1).

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **die Kommandos aus §1 sind erneut gefahren und ihre Ausgabe steht
neben der jeweiligen Entscheidung** (übernommen → der Posten ist fort; Abweichung → er steht und
trägt seine Begründung im Index), und **`make gates` ist grün**. Dazu die Closure-Notiz
mit Steering-Loop-Lerneintrag und je Risiko aus §6 genau ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Übernahme kann eine Aussage verdoppeln, statt sie zu tragen.** Beide fehlenden Bullets
  haben im Repo bereits einen Ort (§2 (2)); wer sie in den Index schreibt, ohne die Frage zu
  entscheiden, erzeugt zwei Fassungen derselben Regel — und die driften, wie es der Index für die
  Zusatz-Spalte selbst notiert (*„zwei Fassungen derselben Aussage driften auseinander"*). —
  **Ausgang:** <entfallen: die Entscheidung aus §2 (2) ist je Bullet getroffen und begründet |
  eingetreten: Folge-Slice, der den doppelten Ort auflöst>
- **Keiner der drei Posten hat einen Wächter, und dieser Slice baut keinen.** Kein Modul aus
  `modules:` der `.d-check.yml` vergleicht eine Tabellen-Kopfzelle oder einen Bullet-Bestand mit
  einer vendored Vorlage; der Index sagt das über seine eigenen Titel- und Status-Regeln bereits
  (*„Kein Sensor hält die Titel- und die Status-Regel"*). Was hier entschieden wird, hält also die
  nächste Änderung nur, wenn jemand sie liest. **Ob ein solcher Wächter baubar ist, ist eine
  Werkzeug-Frage an `d-check`, keine Grenze** — die Datei ist ein Nachbar-Repo, nicht ein
  Fremd-Produkt. — **Ausgang:** <entfallen: der Slice baut ihn und benennt seine Grenze |
  eingetreten: Folge-Slice mit der Anforderung an das Werkzeug, benannt und adressiert>
- **Die Zuständigkeit für diese Datei ist offen (§3), und der Slice kann sie nicht selbst
  setzen.** Wer sie setzt, setzt sie für eine Klasse von Artefakten, nicht für eine Datei — das
  ist der Gegenstand von [ADR-0015](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) und
  nicht der eines Slice. — **Ausgang:** <entfallen: die Antwort stand schon in einer Quelle, die
  der Lauf gefunden hat | eingetreten: Übergabe an den Architect, mit Adresse>
- **Der Fund kann nicht der einzige seiner Klasse sein.** *„Nie übernommen und nie geändert"* ist
  unsichtbar, solange niemand gegen die Vorlage hält; ein zweiter Fund derselben Art würde nicht
  diesen Slice größer machen, sondern die
  [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)-Aussage treffen —
  genau die Schwelle, die [slice-084](slice-084-stichprobe-gegen-bestand.md) §2 zieht. — **Ausgang:**
  <entfallen: der Abgleich dieses einen Artefakts bleibt punktuell | eingetreten: der Fund geht
  als Beleg in slice-084, und dessen Mehrfach-Fund-Zweig greift>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

<!-- Erst nach Abschluss füllen. -->

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist genau **eine**: `docs/plan/adr/` (eigener
Zuschnitt mit eigener ID-Reihe, eigene Ziel-Form, eigene Regel-Lage über
[`AGENTS.md`](../../../../AGENTS.md) §3.4 — drei von drei Achsen). Die Schwelle ≥ 2 ist erfüllt,
und der Schnitt ist nicht zu grob: `docs/plan/` als Ganzes trüge Planung, Carveouts und ADRs
zusammen und vermischte drei Regel-Lagen in einem Block.

**Vorgelagert — offene Beobachtungen sichten:** das Repo führt **kein** Beobachtungs-Register —
eine `observations.md` unter `docs/plan/planning/` existiert nicht. Keine Treffer, und der Grund
ist die fehlende Datei, nicht ein leeres Register; er wird in §7 notiert.

Alle berührten Sub-Areas GF: `docs/plan/` gehört zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md). Der
Modus-Begründungsblock entfällt damit nach dem *Umfang*-Absatz oben.
