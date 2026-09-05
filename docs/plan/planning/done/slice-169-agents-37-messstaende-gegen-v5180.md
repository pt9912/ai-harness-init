# Slice slice-169: Die vier Mess-Stände in `AGENTS.md` §3.7 stehen gegen `v5.18.0`

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-14](welle-14-re-baseline.md).

**Bezug:** [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
(Ausgang 1 — nachgemessen),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(Setzung 1 — Zahl neben ihrem Kommando),
[`AGENTS.md`](../../../../AGENTS.md) §3.8 (die Rolle, die diesen Text schreibt).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** Architect (pt9912) — der Liefergegenstand ist der Schreib-Akt an einer Hard
Rule, den [`AGENTS.md`](../../../../AGENTS.md) §3.8 dieser Rolle zuweist. Das Feld weicht damit von
der Default-Besetzung ab, die Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als
State Machine nennt.

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Der Herkunfts-Absatz von [`AGENTS.md`](../../../../AGENTS.md) §3.7 nennt den gepinnten Stand,
und seine drei Kommandos sind gegen ihn gefahren.**

Der Absatz führt vier stumme Nennungen des abgelösten Tags — einmal als Stand-Angabe
(*„die adoptierte Baseline `v5.12.0` **führt** diese Regel"*) und dreimal als Pfad-Operand eines
`grep -c`, dessen Ergebnis im selben Satz zitiert wird. Bezugsmenge, beim Lauf neu zu erheben:

```sh
git grep -n 'v5\.12\.0' -- AGENTS.md | grep -v ']('   # 2026-09-03: 4, alle in §3.7
```

**Die Messung liegt vor, das Schreiben nicht.** [slice-165](../done/slice-165-praesens-aussagen-gegen-v5180.md)
hat die drei Kommandos gegen `v5.18.0` gefahren — alle drei geben unverändert **1** aus
(`grep -c '^### 3\.7 Ein Kommentar beschreibt, was da ist$' .harness/baseline/v5.18.0/templates/AGENTS.template.md`,
`grep -c '^### Was ein Kommentar trägt — Code, Konfiguration, Skripte$' .harness/baseline/v5.18.0/regelwerk/grundlagen-harness-dateien.md`,
`grep -c 'nennt sie als \*\*ein\*\* auflösbares Feld' .harness/baseline/v5.18.0/regelwerk/grundlagen-harness-dateien.md`),
und die Deckungs-Aussage des Absatzes trägt damit unverändert. Was fehlt, ist der **Schreib-Akt**:
§3 dieser Datei ist Hard Rule und gehört nach [`AGENTS.md`](../../../../AGENTS.md) §3.8 dem
**Architect**; ein Planner-Lauf, der ihn im Vorbeigehen mitnimmt, ist genau der Fall, den jene
Regel benennt.

**Was dieser Slice nicht tut.** Er ändert die Regel nicht und prüft die Baseline-Deckung nicht neu
gegen ihren Inhalt — [`MR-031`](../../../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline)
hält sie, und ob sie am neuen Stand inhaltlich fortgeschrieben ist, ist der Gegenstand des
Adaptions-Durchgangs [slice-157](../done/slice-157-adaptions-durchgang-v5180.md), nicht dieses
Nachzugs.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **Die vier Nennungen tragen `v5.18.0`, und die drei Ergebnisse sind im Lauf dieses Slice
      selbst gefahren** — nicht aus §1 übernommen. Weicht eines ab, wird die Folgerung des
      Absatzes gezogen, nicht die Ziffer angepasst
      ([`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
      Ausgang 1). Gefahren sind **alle zehn** Kommandos des Abschnitts, nicht nur die drei — §7.
- [x] **Der Commit erfüllt den Zuschnitt aus [`AGENTS.md`](../../../../AGENTS.md) §3.8:** er
      berührt nur Artefakte der schreibenden Rolle (diese Datei, ADRs, den Konventionsspeicher)
      und nennt die Rolle in seiner Message. An `git show --stat` ablesbar.
- [x] `make gates` grün.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt — **keiner berührt**: die Zahlen dieses
      Abschnitts sind in keinem lebenden Artefakt zitiert
      (`git grep -nE '289 Dateien|464 solche|124 mit Slice' -- '*.md' ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done'` gibt nichts aus).
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
| [`AGENTS.md`](../../../../AGENTS.md) §3.7 | update | die vier Nennungen; Hard Rule, also Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): der Rolleninhaber der **Architect**-Rolle übernimmt — die
Messung aus §1 liegt vor, ein weiterer Vorlauf ist nicht nötig.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn eines der drei Ergebnisse abweicht
  und die Folgerung des Absatzes dadurch neu zu fassen ist — das ist eine Norm-**Entscheidung**
  über die Deckung, nicht ein Nachzug, und braucht einen eigenen Schnitt.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Deckung gegen `v5.18.0` nicht mehr
  trägt und [`MR-031`](../../../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline)
  darüber vor diesem Slice zu entscheiden ist.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **das Erhebungs-Kommando aus §1 gibt nichts mehr aus** (Exit 1), und
**`make gates` ist grün**. Dazu die Closure-Notiz mit Steering-Loop-Lerneintrag und je Risiko aus
§6 genau ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Lauf übernimmt die drei Einsen aus §1, statt sie zu fahren** — dieselbe Klasse, gegen die
  [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
  steht, eine Ebene weiter. — **Ausgang:** **entfallen** — alle zehn Kommandos des Abschnitts sind
  in diesem Lauf gefahren, je Kommando steht das Ergebnis in der Tabelle in §7.
- **Der Commit nimmt ein fremdes Artefakt mit** — der Absatz nennt
  [`MR-031`](../../../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline), und ein Nachzug dort
  liegt nahe. Zulässig ist er nur, weil der Konventionsspeicher derselben Rolle gehört; ein
  Slice-Plan oder eine Roadmap-Zeile im selben Commit ist es nicht. — **Ausgang:** **entfallen** —
  der Norm-Commit berührt eine einzige Datei ([`AGENTS.md`](../../../../AGENTS.md), `git show --stat`);
  [`MR-031`](../../../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline)
  ist unberührt, sein `Ausgelöst durch Baseline-Stand` nennt den Tag, der den Trigger feuerte, und
  bleibt darum auf `v5.12.0` stehen.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Zehn Kommandos, je eines mit Ausgang — die Verteilung ist einseitig: 10× nachgemessen, 0×
Tree-Operand, 0× entfallen.** Der Abschnitt führt keine Aussage über die Vor-Tausch-Seite und
keine, die ihren Gegenstand verloren hat.

| Kommando in §3.7 | im Text | in diesem Lauf | Ausgang |
|---|---|---|---|
| Ränge der Source Precedence | 9 | 9 | nachgemessen, unverändert |
| Zensus: Dateien im Prüfbereich | 289 | **296** | nachgemessen |
| Zensus: Dateien mit Befund-Kennung | 38 | 38 | nachgemessen, unverändert |
| Zensus: Zeilen mit Befund-Kennung | 65 | 65 | nachgemessen, unverändert |
| Zensus: Dateien mit Slice-Nummer | 124 | **126** | nachgemessen |
| Zensus: Zeilen mit Slice-Nummer | 464 | **472** | nachgemessen |
| Zensus: zulässige Feld-Form | 0 | **1** | nachgemessen — **Folgerung gewandert** |
| Vorlage führt die Hard Rule | 1 | 1 | nachgemessen, unverändert |
| Grundlagen-Abschnitt schreibt sie aus | 1 | 1 | nachgemessen, unverändert |
| Hard-Rule-Satz, den die Quellen-Klausel anwendet | 1 | 1 | nachgemessen, unverändert |

**Die vier Tag-Nennungen tragen `v5.18.0`, und die Deckungs-Aussage trägt unverändert:** die drei
`grep -c` der letzten drei Zeilen geben gegen den neuen Baum dasselbe **1** aus. Der Zensus daneben
ist repo-eigen — er läuft gegen den Index, nicht gegen den vendored Baum — und trägt seinen
Messpunkt jetzt als `Stand 2026-09-03`. Die zwei **Cutoff**-Daten des Abschnitts (2026-08-30 für
die Quellen-Klausel, 2026-08-29 für die Zustandsfeld-Hälfte) sind normativ und unberührt.

**Ein Wert hat die Folgerung bewegt, nicht nur die Ziffer:** `zulässige Feld-Form` stand auf **0**
und steht auf **1** — der `Makefile` trägt einen Herkunfts-Anker in der Form `· seit slice-<NNN>`.
Die Aussage des Absatzes bleibt: der Bestand ist kein Arbeitsauftrag, und der Ausschnitt, den ein
`grep` trifft, ist kein Gesamtmaß.

**Closure-Kriterien (beobachtet, nicht behauptet):**

1. **Das Erhebungs-Kommando aus §1 gibt nichts mehr aus** — `git grep -n 'v5\.12\.0' -- AGENTS.md | grep -v ']('`
   endet mit Exit 1.
2. **`make gates` grün** nach dem Commit dieser Notiz; der Stop-Hook-Stempel deckt den Arbeitsbaum.

- **Was hat funktioniert:** Das Übergabe-Artefakt aus [slice-165](../done/slice-165-praesens-aussagen-gegen-v5180.md)
  trug die Messung mit, und dieser Lauf musste sie nur wiederholen statt sie zu suchen. Der
  Rollen-Wechsel kostete damit einen Lauf, nicht eine zweite Erhebung.
- **Was ging anders als geplant:** §3 nennt als Gegenstand *die vier Nennungen*. Gefahren wurden
  alle zehn Kommandos des Abschnitts, und **vier** der sechs Zensus-Werte hatten sich bewegt — die
  Plan-Tabelle war eine Kandidaten-Liste, keine Ausschluss-Liste. Alle vier liegen in derselben
  Sektion, derselben Datei und damit im selben Commit-Zuschnitt nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.8; ein zweiter Schnitt war dafür nicht nötig.
- **Steering-Loop-Eintrag: eine benannte Spec-Lücke, geschärft** —
  *[`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
  Ausgang 1 verlangt, die **Folgerung** zu ziehen statt die Ziffer zu runden — aber nur für die
  Baum-Hälfte einer Aussage; für den repo-eigenen Zensus daneben verlangt keine Quelle den Lauf.*
  [slice-165](../done/slice-165-praesens-aussagen-gegen-v5180.md) hat die Lücke benannt; dieser
  Lauf misst sie an ihrem Ernstfall: Der Zensus **derselben Sektion** hatte eine Folgerung bewegt
  (`0` → `1`), und der Tag-Nachzug in dieser Datei war einen Slice zuvor daran vorbeigelaufen. Kein
  Zielort — die Lücke bleibt **benannt**, nicht verkörpert; sie liegt als siebter Beleg an
  `BEO-009`, und ihr Ausgang hängt an dem dort geplanten
  [slice-153](../open/slice-153-wellen-commands-nennen-die-roadmap-abschnitte.md).
- **Beobachtungs-Register (`../observations.md`):** keine neue Kennung —
  `BEO-009` von 6× auf **7×** erhöht, Beleg `slice-169`.
  `BEO-022` bleibt bei 2×: dieser Slice **ist** die Rollen-Übergabe, die jene
  Zeile vermisst, also kein weiteres Auftreten.
- **Folge-Slices:** keine. Der Ausgang der Klasse hängt an
  [slice-153](../open/slice-153-wellen-commands-nennen-die-roadmap-abschnitte.md); einen neuen
  Schnitt macht der Planner, nicht dieser Lauf ([`AGENTS.md`](../../../../AGENTS.md) §3.8).
- **Risiken aus §6:** zwei benannt, beide **entfallen** — siehe §6.
- **Drei Paarungen:** hier **nicht** geprüft. Dieses Repo führt Wellen-Betrieb, und dieser Slice
  ist Mitglied von [welle-14](welle-14-re-baseline.md); Modul 6 §Wellen-Closure-Prozedur legt
  die Paarungen auf Closure-Schritt 3c.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die Modus-Deklaration
in [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
führt keine engere.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-009` (*Fix ändert die Ableitung, die Zusage
daneben bleibt stehen*, Schwelle erreicht) trägt die Klasse dieses Nachzugs; `BEO-022` (*der
Lese-Schritt erkennt den Übertritt, der Ausgang gehört einer anderen Rolle*) trägt seinen
**Anlass** — dieser Slice ist die Rollen-Übergabe, die jene Zeile vermisst. Zähler-Stände siehe
Register. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
