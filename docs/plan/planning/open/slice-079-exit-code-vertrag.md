# Slice slice-079: Dieselbe Zahl bedeutet zweimal Verschiedenes — der Exit-Code-Vertrag steht in §4

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Konsolidierung einer Festlegung) — gegen
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 geprüft, alle drei Fragen samt Antwort in §3.

**Bezug:**
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#aufnahme-regel) §Aufnahme-Regel — sie
entscheidet, dass dieser Stoff hierher gehört: ein Wert, gegen den gemessen werden kann · ohne
Vertragsänderung fortschreibbar · wachsend mit seinem Gegenstand. Dieselbe Regel setzt die
Nummern der vendored Vorlage und hält fest, dass ein Abschnitt **ohne Inhalt seine Nummer frei
lässt** — §4 ist also nicht falsch leer, sondern **unbefüllt**, und dieser Slice füllt ihn.
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) — ein Aufrufer, der
zwei Familien gleich liest, bekommt aus demselben Code zwei Bedeutungen.
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) (**Accepted**) — der Zielort für
technische Festlegungen; dieser Slice trägt eine dorthin, die bisher in Kopfkommentaren lebt.
[`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence) —
Rang 2 der Source Precedence; ein Vertrag, der nur im Kommentar steht, hat diesen Rang nicht.

**Bewusst KEINE `LH-FA`-Kennung.** Geprüft: die funktionalen Anforderungen betreffen das
emittierte Zielprojekt; hier steht der Exit-Code-Vertrag **dieses** Repos, und die berührten
Familien sind das CLI-Binary und die Freshness-Prüfer. **Dieser Absatz steht unterhalb der
Leerzeile:** der Bezugs-Block wird bis zur ersten Leerzeile mechanisch gelesen, und eine
Ausschluss-Notiz darin trüge ein, was sie ausschließt.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-08-08.

---

## 1. Ziel

**`1` und `2` bedeuten in diesem Repo je zwei Verschiedenes, und der Vertrag steht nirgends.**
Gemessen am 2026-08-08:

- **Freshness-Familie** (`harness/tools/baseline-freshness.sh:16`, `go-freshness.sh:25` und die
  übrigen Prüfer): `0 = aktuell`, **`1` = VERALTET**, `2` = Fetch-/Vergleichsfehler. Die `1` ist
  hier ein **Sachbefund**, der Alarm selbst; die `2` heißt *kann nicht urteilen*.
- **CLI-Familie** (`cmd/ai-harness-init/main.go:86` ff.): `0 = Erfolg`, **`1` = Fehler**,
  `2` = Usage bzw. eine von der Sprache nicht getragene Kombination. Die `1` ist hier ein
  **Werkzeug-Fehler**, die `2` ein **Aufrufer**-Fehler.

Dieselbe `1` ist einmal das erwartete Ergebnis und einmal ein Defekt; dieselbe `2` einmal
*ich weiß es nicht* und einmal *du hast falsch gefragt*. **Der Preis ist real und schon einmal
knapp vermieden worden:** `harness/tools/cpp-freshness.sh:70-72` begründet ausdrücklich, warum
dort **nicht** `${VAR:?}` steht — das bräche mit Exit 1 ab *„und meldete Drift, wo der Pin nur
unlesbar ist"*. Ein Aufrufer, der `!= 0` gleich behandelt, macht genau diesen Fehler.

**Was NICHT dazugehört, und das ist eine Korrektur an einer verbreiteten Lesart:** die
Hook-Skripte sind **keine dritte Familie**. Die **drei** Dateien unter `.claude/hooks/` enden auf
**jedem** Pfad mit `exit 0` — `grep -n "exit [1-9]"` über alle drei liefert **null** Treffer
(2026-08-08); ihre Entscheidung reist als JSON-Ausgabe, nicht im Exit-Code. Wer sie als Familie
mitzählt, beschreibt das Protokoll des Werkzeugs, nicht die Praxis dieses Repos.

## 2. Definition of Done

- [ ] **(1) §4 trägt die Exit-Code-Familien dieses Repos — je Familie ihr Geltungsbereich und je
  Code seine Bedeutung, gemessen statt abgeschrieben.** Dazu ausdrücklich, dass die Hook-Skripte
  **keine** Familie sind und warum (Entscheidung als Ausgabe, nicht als Code). **Der Zusammenstoß
  wird entschieden oder deklariert, nicht verschwiegen:** entweder eine Familie zieht nach, oder
  §4 sagt, dass die zwei Bedeutungen nebeneinander gelten und woran ein Aufrufer sie
  unterscheidet. Ein Vertrag, der den Widerspruch weglässt, ist der heutige Zustand mit
  Überschrift.
  **Der bindende Text trägt keine Entscheidungs- und keine Planungs-Kennung**, auch keine nackte
  `slice-`-Kennung — dieselbe Formregel wie im Rest des Abschnitts.
- [ ] **(2) Je Familie bindet ein Test den dokumentierten Code an das reale Verhalten.**
  Vor dem Code zu messen: welche der Codes schon heute gebunden sind (die Freshness-Prüfer führen
  bats-Fälle, das CLI führt Go-Tests) — **ergänzt wird nur, was fehlt**, und die Lücke wird
  benannt statt behauptet. Ohne diese Bindung ist §4 eine Beschreibung, die still veraltet:
  `make comment-claims` prüft, dass ein genannter Test **existiert**, nie dass ein genannter
  **Code** herauskommt.
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | update | §4 aus DoD (1). **Keine neue Nummer:** die Aufnahme-Regel vergibt Nummern nie neu und lässt unbefüllte frei — §4 steht bereit. **Kein Eingriff in §5:** dessen Anker trägt [`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md), seit dem 2026-08-03 Accepted und damit immutabel |
| `harness/tools/*.sh` (Kopfkommentare) | update | die Familien-Aussagen zeigen künftig auf §4, statt jede für sich einen Vertrag zu behaupten — eine Quelle je Aussage. **Kein Verhaltens-Eingriff:** kein Exit-Code wird geändert, solange DoD (1) nicht ausdrücklich das Nachziehen einer Familie entscheidet |
| `test/` | update / neu | die Bindung aus DoD (2), und nur dort, wo die Messung eine Lücke zeigt |

**Offen, vor dem Code zu entscheiden:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | **Nachziehen oder nebeneinander?** | Nachziehen macht `1` und `2` repo-weit eindeutig, ändert aber das Verhalten laufender Prüfer — jeder Aufrufer (`Makefile`, CI, der Nachtlauf `upstream-drift`) hängt an der heutigen Bedeutung, und die Freshness-`1` ist der **erwartete** Ausgang eines veralteten Pins. Nebeneinander kostet nichts und schreibt die Unterscheidung auf. **Die Antwort entscheidet, ob dieser Slice Doku ist oder Verhalten ändert** — und im zweiten Fall gehört sie dem Architect, nicht diesem Plan |
| B | **Wie weit reicht der Geltungsbereich?** | Gemessen sind zwei Familien (Freshness, CLI). Ob `harness/tools/`-Prüfer außerhalb der Freshness-Klasse (`smoke.sh`, `span-check.sh`, `mutate.sh`) eine dritte bilden oder der CLI-Familie folgen, ist **nicht** gemessen. Vor dem Schreiben von §4 auszählen — ein Vertrag über einer unvollständig erhobenen Menge ist der Fehler, den er heilen soll |

**Welle oder nicht — der Test aus [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 1**

1. **Bündel?** Nein — Messung, §4 und die Bindung landen in **einem** Schnitt.
2. **Gemeinsames Closure-Kriterium?** Nein.
3. **Auslöser reaktiv oder gewollt?** **Reaktiv** — ein gemessener Widerspruch, keine neue
   Fähigkeit.

Dreimal *ohne Welle*. **Folge nach Setzung 2 und 3:** die Roadmap bekommt **keinen** Eintrag —
weder jetzt noch beim Abschluss.

## 4. Trigger

**`open` → `next`:** Frage B ist ausgezählt, und Frage A ist beantwortet — fällt sie auf
*nachziehen*, liegt vorher ein Architect-Verdikt vor, weil dann Verhalten geändert wird.

**`next` → `in-progress`:** WIP-Limit — kein anderer Slice in `in-progress/`.

Rückführungen:

- `in-progress` → `next`: falls die Auszählung aus Frage B eine dritte Familie zeigt, deren
  Konsolidierung eigene Zähne braucht. Dann trennt ein Re-Schnitt die **Beschreibung** von der
  **Vereinheitlichung**.
- `in-progress` → `open`: falls Frage A auf *nachziehen* fällt und der Architect die Änderung an
  eine Entscheidung bindet, die noch nicht steht.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit ausgestelltem Verdikt; Verifikation bestätigt
(Modul 11); `make gates` und `make mutate` grün; `git mv` nach `done/` in eigenem Move-Commit,
eingehende Links im Zug danach; Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Ein Vertrag, der nur beschreibt, was ist, verewigt den Widerspruch mit Autorität.** Genau
  deshalb verlangt DoD (1) *entschieden oder deklariert* — die dritte Möglichkeit, ihn
  aufzuschreiben und nicht zu benennen, ist die schlechteste von allen.
- **Verhaltensänderung an Freshness-Codes trifft den Nachtlauf.** `upstream-drift` ist in seiner
  ganzen sichtbaren Historie rot; eine umdefinierte `1` ändert dort die Lesart eines Zustands,
  der ohnehin niemandem auffällt. Wer nachzieht, prüft zuerst die Aufrufer.
- **Die Zahl-Bedeutungen sind nur so gut wie ihre Erhebung** (Frage B). Zwei gemessene Familien
  sind zwei, nicht alle.
- **Nicht in diesem Slice:** das **Mutations-Fall-Format** (`# files:` / `# expect:`, gemessen
  je **144** reale Vorkommen; `# verify:` dagegen nur **2**) — es erfüllt die Aufnahme-Regel und
  lebt heute allein im Parser von [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh),
  aber [slice-069](slice-069-zahn-bindet-zusicherung.md) fügt ihm ein Kopf-Feld hinzu. Es jetzt
  festzuschreiben hieße, eine Festlegung zu schreiben, die ihr eigener Nachfolger umschreibt;
  **Trigger:** slice-069 liegt in `done/`. Ebenfalls nicht hier: die Verlagerung des
  Span-Schemas aus §5 (reine Umschichtung an einem Anker, auf den eine immutable ADR zeigt), der
  Prüfbereich von `comment-claims` ([slice-070](slice-070-comment-claims-pruefbereich.md)) und
  die Zusicherungs-Granularität der Mutations-Fälle
  ([slice-069](slice-069-zahn-bindet-zusicherung.md)).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `spec/`,
`harness/tools/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
