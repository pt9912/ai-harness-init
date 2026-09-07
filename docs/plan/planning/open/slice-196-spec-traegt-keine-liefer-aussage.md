# Slice slice-196: `spec/` trägt keine Liefer-Aussage

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Die Closure-Bedingung wäre die Abschrift der DoD unten
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).
Damit **nicht** in der Roadmap geführt.

**Ebene: Dogfood-Spec.** Gegenstand sind zwei Sätze in
[`spec/lastenheft.md`](../../../../spec/lastenheft.md) und
[`spec/architecture.md`](../../../../spec/architecture.md) — Dateien **dieses** Repos. Kein
emittiertes Byte ist berührt, und keine Anforderung ändert ihren Inhalt.

**Bezug:**
[`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) — die
Anforderung, die den einen Satz trägt; ihr Anforderungsgehalt bleibt unverändert.
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — die
Gegenkraft, falls dieser Slice einen Wächter setzt: kein Gate über einem Prüfbereich, den ein
Urteil und kein Muster abgrenzt (§2).
[`MR-036`](../../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)
— der Träger einer Lastenheft-Änderung bei Personalunion: ein angenommener Change Request in
eigenem Commit, vor dem umsetzenden Slice (§4).
[`AGENTS.md`](../../../../AGENTS.md) §3.8 — Hard Rules und Adaptions-Block schreibt der Architect;
daraus folgt, wer DoD (2) ausführt.

**Berührte Spec-Stellen:**
[`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) ·
[`spec/architecture.md`](../../../../spec/architecture.md) §Hard Rule (Kopfblock, vor §1).

**Verantwortlich:** — (bis zur Priorisierung).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-09-07.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Drei Dokumentklassen, drei Zeit-Domänen — und keine spricht über die andere.**
[`spec/`](../../../../spec) sagt, was gelten **soll**; [`docs/user/`](../../../../docs/user) sagt,
was **ist**; `docs/plan/planning/` sagt, **wann und in welcher Ordnung** es kommt. Das ist die
Source-Precedence-Disziplin (Baseline-Regelwerk `grundlagen-source-precedence.md`), angewandt auf
die Zeitform. Eine Liefer-Aussage in `spec/` ist damit an ihrem Ort falsch, auch wenn sie
inhaltlich stimmt: Sie steht im Dokument, dessen Aussagen **nicht** altern sollen, und altert.

**Zwei solche Sätze stehen in `spec/`, in zwei der drei Straten.** Die Fundstellen, nicht nur
ihre Zahl — die Unterscheidung *Ablauf* gegen *Lieferung* ist ein Urteil und kein Muster (§2):

```sh
grep -n 'cpp` (C++/CMake' spec/lastenheft.md              # 122 — Vertrag
grep -n 'zeitliche Schicht lebt in' spec/architecture.md  #   6 — Sicht
```

1. **`spec/lastenheft.md:122`** — *„`cpp` (C++/CMake: cmake/ctest/clang-tidy) **folgt**"*.
   Die Liste der unterstützten Sprachen darüber ist Zielbild und bleibt, wie sie ist; dass `cpp`
   darin steht **und** gebaut ist, ist kein Befund. Der Halbsatz daneben behauptet einen
   **Implementierungsstand** — *noch nicht da* — und ist damit Liefer-Reihenfolge, also Plan.
2. **`spec/architecture.md:6`** — `Die zeitliche Schicht lebt in docs/plan/planning/ *(folgt)*`.
   Der Satz **verletzt die Regel, die er in derselben Zeile aufstellt**: Er erklärt
   die zeitliche Schicht für auswärtig und setzt dann eine Zeit-Aussage in seine eigene Klammer.
   Die Ziel-Form des Satzes trägt sie nicht — sie nennt statt der Klammer den Ort:

   ```sh
   sed -n '/^oben ist ein Frische-Marker/,+1p' \
     .harness/baseline/v6.0.0/templates/spec/architecture.template.md
   ls docs/plan/planning/done/slice-*.md | wc -l   # 136
   ```

**Was kein Befund ist, und warum die Grenze nicht am Wort liegt.** Von sieben Treffern der
naheliegenden Muster im Rumpf der drei Straten tragen zwei eine Liefer-Aussage; die übrigen fünf
sind **Ablauf** (die Reihenfolge, in der ein *Lauf* abläuft) oder **Logik** (*daraus folgt*):

```sh
for f in spec/lastenheft.md spec/spezifikation.md spec/architecture.md; do
  e=$(grep -n '^## 7\. Historie' "$f" | cut -d: -f1); e=${e:-999999}
  awk -v E="$e" -v F="$f" 'FNR<E{print F":"FNR": "$0}' "$f"
done | grep -cE '\bfolgt\b|\bfolgen\b'          # 7 Treffer, davon 2 Fundstellen
```

Der schärfste Gegenfall steht in derselben Anforderung wie Fundstelle 1:
`spec/lastenheft.md:39` — *„Das **Sprachskelett** folgt als separater, wiederholbarer Schritt …
erst nachdem die Ziel-Architektur + ihr Sprach-ADR es entscheiden"*. Das beschreibt, **wie ein
Lauf abläuft**, nicht **wann wir etwas bauen**, und bleibt.

**Ausgenommen ist §7 Historie** (`grep -n '^## 7\. Historie' spec/lastenheft.md`) — sie ist
datierte Chronik von Beruf, und eine Zeit-Aussage darin ist ihr Gegenstand, nicht ihr Defekt.

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — jede Zahl wandert mit dem Baum. **Die Zwei ist eine Urteils-Zahl, keine
Muster-Zahl:** Die Sieben liefert das `grep`, die Zwei liefert der Leser, und die fünf
verworfenen Treffer stehen darum als Menge oben statt als Rest einer Subtraktion.

**Eine Korrektur derselben Klasse ist schon gelaufen und hat einen von zwei Fundorten
erreicht.** Der Change Request 0.15.0 nahm den Satz *„C++/CMake **folgt** sprach-agnostisch"* aus
§5 des Lastenhefts und ließ Fundstelle 1 stehen:

```sh
grep -c 'C++/CMake \*\*folgt\*\* sprach-agnostisch' spec/lastenheft.md   # 1 — nur noch in §7
grep -n 'Weitere$' spec/lastenheft.md                                    # die Ersatz-Fassung in §5
```

Damit ist die Klasse **nicht** einmalig, und *benennen und liegen lassen* ist der Zustand, der
Fundstelle 1 erzeugt hat. Der Slice liefert deshalb zweierlei: die zwei Sätze und den Träger, an
dem die Regel hängt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Beide Fundstellen tragen keine Liefer-Aussage mehr.** In
  [`spec/lastenheft.md`](../../../../spec/lastenheft.md)
  [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) entfällt der
  Halbsatz *„`cpp` … folgt"*; die Sprachenliste, die Architektur-Liste und jedes
  Akzeptanzkriterium bleiben unverändert. In
  [`spec/architecture.md`](../../../../spec/architecture.md) nennt die Hard Rule den Ort der
  zeitlichen Schicht statt einer Klammer über ihn — die Ziel-Form aus §1 liefert den Satz.
  **Rot:** `grep -c 'C++/CMake: cmake/ctest/clang-tidy) folgt' spec/lastenheft.md` bleibt `1`,
  oder `grep -c 'docs/plan/planning/ \*(folgt)\*' spec/architecture.md` bleibt `1`.
- [ ] **(2) Die Domänen-Regel hat einen Träger, oder ihre Ablehnung hat einen.** Die Regel aus §1
  — *`spec/` sagt Soll, `docs/user/` sagt Ist, `docs/plan/planning/` sagt wann; eine
  Liefer-Aussage in `spec/` ist an ihrem Ort falsch* — ist einem Norm-Artefakt zugewiesen. **Wer
  das schreibt und in welcher Form, entscheidet dieser Plan nicht:** Hard Rules und
  Adaptions-Block schreibt der **Architect**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8), und ob die Regel eine Hard Rule, ein
  Adaptions-Eintrag oder keines von beidem wird, ist seine Entscheidung. Dieser Plan **ist** das
  Übergabe-Artefakt der Kante Planner → Architect (Baseline-Regelwerk
  `modul-08-agentenrollen.md` §Die neun Übergaben). **Rot:** die Regel steht in keinem lebenden
  Norm-Artefakt **und** kein Artefakt hält fest, dass sie abgelehnt wurde — dann ist sie nur in
  einem Plan gesagt, den der Prozess nach `done/` legt.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

**Kein Wächter über der Klasse, und das ist gemessen statt vertagt.** Der naheliegende Sensor
wäre ein Muster-Verbot für `folgt`/`noch nicht`/`derzeit` in `spec/`. Die Messung aus §1 sagt,
was er wäre: **sieben** Treffer, **zwei** Fundstellen — fünf Falschmeldungen je Lauf, darunter
ein Satz in derselben Anforderung wie die eine echte. Ein Gate mit dieser Trefferquote wird
abgeschaltet oder mit Ausnahmen zugestellt, und beides ist schlechter als seine Abwesenheit
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
Träger ist damit die Regel aus DoD (2) und das Review, nicht ein Gate; die Lücke steht als
Risiko in §6.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`spec/lastenheft.md`](../../../../spec/lastenheft.md) [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) + §7 Historie | update | DoD (1), Fundstelle 1 — **im Change-Request-Commit**, nicht im Slice-Commit (§4) |
| [`spec/architecture.md`](../../../../spec/architecture.md) §Hard Rule | update | DoD (1), Fundstelle 2 — Sicht-Stratum, kein Change Request nötig ([`MR-036`](../../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline) bindet das Lastenheft) |
| ein Norm-Artefakt für die Domänen-Regel (Form offen: Hard Rule oder Adaptions-Eintrag) | neu | DoD (2) — **Architect-Commit**, getrennt von den beiden darüber ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | **unverändert** | die Messung aus §1 findet dort keine Fundstelle; die zwölf Treffer der breiten Muster sind Feld-Abwesenheiten und Plattform-Verhalten |
| `internal/`, [`docs/user/`](../../../../docs/user) | **unverändert** | kein emittiertes Byte und keine Ist-Beschreibung ist berührt — das Handbuch führt [slice-195](slice-195-handbuch-nennt-die-zugesagten-faehigkeiten.md) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**`open` → `next`:** ein **angenommener Change Request** liegt vor, der Fundstelle 1 aus
[`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) nimmt. Er ändert
in einem eigenen Commit ausschließlich das Lastenheft und liegt **vor** diesem Slice
([`MR-036`](../../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline),
Baseline-Regelwerk `grundlagen-source-precedence.md` §Fallen Auftraggeber- und Entwickler-Rolle
zusammen). **Das ist eine Prozess-Bedingung, keine offene Frage:** *dass* der Halbsatz eine
Liefer-Aussage ist, ist gemessen (§1); der Change Request ist der Commit-Zuschnitt, den eine
Lastenheft-Änderung hier verlangt. Fundstelle 2 hängt nicht daran — `architecture.md` ist
Sicht-Stratum.

**Start** (`next` → `in-progress`): Implementer übernimmt, WIP-Limit frei.

**Kein Anspruch auf eine fremde Datei.** Die drei offenen Pläne auf
[`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md)
([slice-111](slice-111-was-ein-bootstrap-anlegt-steht-in-der-nutzerdoku.md),
[slice-191](slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md),
[slice-195](slice-195-handbuch-nennt-die-zugesagten-faehigkeiten.md)) berühren `spec/` nicht;
dieser Slice berührt das Handbuch nicht. Die Domänen-Regel aus DoD (2) trägt für alle vier
dieselbe Grenze und verschiebt in keinem ihre DoD.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): falls das Architect-Verdikt zu DoD (2)
  einen eigenen Sensor oder eine Umschrift mehrerer Norm-Artefakte nach sich zieht. Dann trennt
  ein Re-Schnitt die zwei Sätze von ihrer Regel — die Sätze haben für sich Liefer-Wert, die Regel
  ohne sie auch.
- `in-progress` → `open` (blockiert — Carveout?): falls die Ziel-Form aus §1 den Satz für
  Fundstelle 2 nicht hergibt, weil der Kopfblock dieses Repos von der Vorlage abweicht und die
  Abweichung selbst zu entscheiden ist. Dann steht eine Form-Entscheidung aus, und dieser Slice
  ist nicht ihr Ort.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **(a)** die zwei *Rot*-Kommandos aus DoD (1) sind erneut gefahren
und geben beide `0` aus, und die Fundstellen-Messung aus §1 ist mit ihrer Ausgabe in der
Closure-Notiz wiederholt — die Sieben darf dabei fallen, tragend ist, dass keine Fundstelle
bleibt; **(b)** `make gates` grün.

Dazu: DoD vollständig; Review konform (Modul 10); Verifikation bestätigt (Modul 11); jedes Risiko
aus §6 mit Ausgang; Closure-Notiz mit Steering-Loop-Lerneintrag; `git mv` nach `done/` als
eigener Move-Commit. Den Abschluss schreibt der **Planner** in frischem Kontext
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Regel bekommt keinen Wächter, und die Klasse ist damit auf Aufmerksamkeit angewiesen.**
  §2 misst, warum ein Muster-Gate hier schadet; ein urteilender Sensor bräuchte ein Kriterium,
  das *Ablauf* von *Lieferung* trennt, und das ist der Urteilsschritt selbst. Die Klasse führt
  [`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  für die Nachbarform. — **Ausgang:** <offen>
- **Die Korrektur kann wieder einen Fundort statt der Fundmenge erreichen.** Genau das ist mit
  0.15.0 passiert (§1): ein Satz gestrichen, ein zweiter derselben Formulierung stehen geblieben.
  DoD (1) nennt darum **beide** Fundstellen namentlich und §5 (a) verlangt die Messung erneut,
  statt sich auf die zwei Einzel-`grep` zu verlassen. — **Ausgang:** <offen>
- **Das Architect-Verdikt kann die Regel ablehnen, und DoD (2) hätte dann nichts geliefert.**
  Der Fall ist vorgesehen — DoD (2) verlangt den Träger **oder** die festgehaltene Ablehnung —,
  aber eine Ablehnung ohne Artefakt sieht von außen aus wie eine vergessene Übergabe. Die Klasse
  führt
  [`BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md).
  — **Ausgang:** <offen>
- **Der Change Request kann mehr mitnehmen als den Halbsatz.** Wer
  [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) für den einen
  Satz öffnet, steht vor einer Sprachenliste, deren vier übrige Einträge nicht gebaut sind. Sie
  bleiben: Das Zielbild nennt, was gelten soll, und ein Abstand zum Bestand ist seine Aufgabe,
  nicht sein Mangel (§1). Ein Change Request, der die Liste kürzt, ändert die Anforderung — ein
  anderer Vorgang mit anderer Begründung. — **Ausgang:** <offen>

**Nicht in diesem Slice — der Bestand außerhalb von `spec/`.** Eine Liefer-Aussage in
[`docs/user/`](../../../../docs/user), in [`README.md`](../../../../README.md) oder in
[`harness/README.md`](../../../../harness/README.md) ist dieselbe Klasse an einem anderen Ort;
gemessen ist hier **nur** `spec/` (§1), und eine Regel aus DoD (2) gilt, sobald sie steht, ohne
dass dieser Slice den Bestand nachrüstet.

**Nicht in diesem Slice — die Soll/Ist-Deltas selbst.** Dass die Sprachenliste sechs Einträge
führt und der Generator zwei Profile, und dass
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) eine
`CLAUDE.md` im Zielrepo nennt, die kein Emissions-Pfad anlegt, sind **keine Befunde** — sie sind
der Normalfall zwischen einem Zielbild und einem Bestand. Gemessen stehen beide in
[slice-195](slice-195-handbuch-nennt-die-zugesagten-faehigkeiten.md) §6, und dieser Slice ändert
an keinem von beiden etwas.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-NNN>, <slice-MMM>, <slice-KKK> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-NNN.md` | `evidence/slice-NNN.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-NNN (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) —
[`spec/`](../../../../spec) liegt darunter und trägt beide geänderten Dateien; das Norm-Artefakt
aus DoD (2) liegt ebenfalls darunter. `harness/tools/` und `.codex/` sind **nicht** berührt:
dieser Slice ändert kein ausführbares Artefakt.

**Vorgelagert — offene Beobachtungen sichten:** Die Ablage
[`observations/`](../observations/README.md) ist durchgegangen; je Slug die Zahl der
`evidence/`-Dateien und die erste Zeile seiner `state.md`:

```sh
for s in zusage-neben-geaenderter-ableitung-bleibt-stehen \
         uebergabe-an-andere-rolle-ohne-traeger-artefakt \
         zusage-nennt-sensor-der-form-nicht-sieht \
         benannte-luecke-ohne-ausgang \
         praesens-aussage-in-einzufrierendem-artefakt-ohne-form \
         extensionale-zahl-unterschreitet-die-eigene-fundmenge; do
  d="docs/plan/planning/observations/BEO-ALL/$s"
  echo "$s $(ls "$d/evidence" 2>/dev/null | wc -l)x $(head -1 "$d/state.md")"
done
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die sechs Einträge des Kommandos berühren diesen Slice; weitere Treffer: keine.

- [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  — **berührt, Zuordnung offen.** Fundstelle 1 sieht wie ein Vorkommen aus: die Ableitung hat
  sich bewegt (`cpp` wurde gebaut), die Zusage daneben blieb stehen. Der tragende Grund ist hier
  aber ein **anderer** — der Satz gehört an seinen Ort nicht, auch wenn er stimmte; eine
  Liefer-Aussage im Soll-Dokument altert konstruktionsbedingt. Ob das dieselbe Beobachtung ist
  oder eine benachbarte, entscheidet der Lauf, der den Beleg schreibt; eine unveränderliche
  `observation.md` wird dafür nicht gedehnt.
- [`uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)
  — **berührt, nicht getroffen.** DoD (2) erklärt einen Teil des Gegenstands zur Übergabe an den
  Architect, und der Eintrag misst genau die Fassung, in der das Artefakt fehlt. Es fehlt hier
  nicht: dieser Plan **ist** das Artefakt, das Baseline-Regelwerk `modul-08-agentenrollen.md`
  §Die neun Übergaben für die Kante Planner → Architect nennt.
- [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  — berührt, **nicht getroffen**: dieser Slice sagt keinen Sensor zu. §2 misst, warum ein
  Muster-Gate hier fünf Falschmeldungen je Lauf gäbe, statt einen Wächter zu behaupten, der das
  Urteil nicht fällen kann.
- [`benannte-luecke-ohne-ausgang`](../observations/BEO-ALL/benannte-luecke-ohne-ausgang/observation.md)
  — **berührt.** §2 und §6 benennen je eine Grenze, und der Eintrag misst, dass für eine solche
  Grenz-Beschreibung kein Ausgang existiert. Die Grenzen stehen hier in einem Plan, den der
  Prozess nach `done/` legt; ob die Regel aus DoD (2) sie in ein lebendes Artefakt trägt und
  damit in den Prüfbereich des Eintrags, entscheidet das Architect-Verdikt.
- [`praesens-aussage-in-einzufrierendem-artefakt-ohne-form`](../observations/BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form/observation.md)
  — berührt, **nicht getroffen**: der Eintrag misst Aussagen in Artefakten, die nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.4 einfrieren. `spec/` friert nicht ein — es ist
  fortschreibbar, und genau darum ist die Fundstelle korrigierbar statt eingefroren. Die
  Verwandtschaft liegt in der Fehlerrichtung, nicht im Prüfbereich.
- [`extensionale-zahl-unterschreitet-die-eigene-fundmenge`](../observations/BEO-ALL/extensionale-zahl-unterschreitet-die-eigene-fundmenge/observation.md)
  — berührt, weil §1 seine Fundorte aufzählt **und** beziffert. **Nicht getroffen:** Aufzählung
  und Zahl sind hier deckungsgleich zwei, und die Sieben daneben trägt ihr eigenes Kommando und
  ist als Muster-Zahl von der Urteils-Zahl getrennt.

**Alle berührten Sub-Areas GF.** Der Modus-Begründungsblock entfällt damit (§Umfang oben); `*`
steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) als
Greenfield, und dieser Slice führt keine neue Sub-Area ein.
