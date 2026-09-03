# Slice slice-166: Der Adaptions-Block wird ein Verzeichnis

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** — (ohne Welle)

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die Anker- und Kennungs-Verträge des Doku-Gates bleiben unverändert streng),
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) (der Adaptions-Block gehört dem Architect),
[`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (die Index-Tabelle ist ein derivatives Register und gehört derselben Rolle).

**Berührte Spec-Stellen:** — (kein Spec-Stratum berührt; `harness/conventions.md` rangiert außerhalb der drei Straten).

**Verantwortlich:** Architect

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

**`harness/conventions.md` trägt Kopf und eine Index-Tabelle; jeder `MR`-Rumpf liegt in
`harness/conventions/MR-NNN-<titel>.md` — und kein bestehender Verweis wird dabei angefasst.**

### Der gemessene Anlass

Die Datei misst **3202** Zeilen (`wc -l < harness/conventions.md`) über **45** Einträge
(`grep -c '^### MR-' harness/conventions.md`). **Beide Zahlen wandern mit dem Baum und sind keine
Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Wer wissen will, ob **ein** Eintrag ihn betrifft, lädt heute alle
fünfundvierzig — und der Adaptions-Block ist keine Datei, die ein Lauf überspringt: `AGENTS.md`
§1 verweist aus vier Absätzen in ihn hinein.

Das Beobachtungs-Register führt den Befund als
[`BEO-014`](../observations.md) — *ein erheblicher Teil des Adaptions-Blocks beschreibt keine
Abweichung von einer Baseline-Regel, sondern Buchführung über den Block selbst*. Dieser Slice löst
`BEO-014` **nicht** auf: Er ändert den **Träger**, nicht den Inhalt. Er macht die Buchführung
sichtbar, indem sie eine eigene Datei bekommt statt Zeilen im Fließtext — und er macht damit den
Schnitt möglich, den eine Auflösung von `BEO-014` bräuchte.

### Die Grenze aus welle-10 §6 ist an ihrer eigenen Begründung zu prüfen

[welle-10](../done/welle-10-re-baseline.md) §6 stellt diesen Umbau ausdrücklich out-of-scope,
und zwar mit *diesem* Preis: „der Umzug zöge **jede** `MR-`Kennung des Repos auf einen neuen Pfad,
und die sind nach
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
linkpflichtig."

**Die Prämisse trägt nicht.** Alle **2123** externen Verweis-Vorkommen in **261** Dateien
(`git grep -oihP 'conventions\.md#mr-\d{3}--[^)]+\)' -- ':!harness/conventions.md' | wc -l`
bzw. dasselbe Muster mit `-lihP … | wc -l`) tragen die Form `conventions.md#mr-<NNN>--<slug>` —
**Datei plus Anker**. Bleibt die Datei als Index stehen und trägt ihre Index-Zeile den alten Slug als
expliziten HTML-Anker, zeigt jeder dieser Verweise weiterhin auf eine existierende Datei und einen
existierenden Anker. Der Umzug kostet dann **eine Index-Zeile je Eintrag**, keinen Verweis-Nachzug.

Vorgemacht hat das Nachbar-Repo `/Development/a-check`: seine Index-Zeilen tragen je **zwei**
Anker — die stabile Kennung `mr-<NNN>` und daneben den alten Überschriften-Slug. Es fährt denselben
d-check-Pin wie wir (`grep -m1 '^DCHECK_IMAGE' /Development/a-check/d-check.mk` und
`grep -m1 '^DCHECK_IMAGE' d-check.mk` nennen beide `ghcr.io/pt9912/d-check:v0.69.0`).
[slice-132](../done/slice-132-adaptions-block-ohne-totes-ziel.md) §1 hat die tragende Vorfrage
bereits an einer Sonde gemessen: ein Link auf ein `<a id="…"></a>` mit abweichendem
Überschriften-Text meldet nichts, ein erfundener Anker in derselben Datei meldet `anchor-missing`.
**Diese Sonde datiert vor dem Pin-Sprung und wird in §3 Schritt 0 neu gefahren** — eine Messung an
einem abgelösten Pin ist ein Anlass, keine Deckung.

### Was dieser Slice nicht ist

Er ist **nicht** der Ort, an dem ein Text des Adaptions-Blocks umgeschrieben wird. Die Rümpfe
reisen **byte-gleich** um; der einzige zulässige Eingriff ist die **Pfad-Präfix-Korrektur** an den
**276** blockinternen Selbstverweisen (`grep -ohP '\(#mr-\d{3}' harness/conventions.md | wc -l`),
die aus `](#mr-NNN--…)` ein `](../conventions.md#mr-NNN--…)` macht. Dass diese Korrektur die
Append-only-Disziplin des Blocks **nicht** verletzt, ist die Entscheidung, die Liefer-Punkt (3)
trägt — nicht eine Annahme, die der Vollzug nebenbei mitnimmt.

Er ist auch **nicht** der Adaptions-Durchgang gegen `v5.18.0`
([slice-157](../open/slice-157-adaptions-durchgang-v5180.md)) und **nicht** die Auflösung von
`BEO-014`.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Verzeichnis-Form vollzogen.** Jeder Eintrag, den
      `grep -c '^### MR-' harness/conventions.md` vor dem Vollzug zählt, liegt danach als eigene
      Datei `harness/conventions/MR-NNN-<titel>.md`; `harness/conventions.md` trägt Kopf,
      Adaptions-Block-Disziplin und eine Index-Tabelle mit den Spalten
      `MR | Titel | Geltungsbereich | Ersetzt-Baseline-Regel`. **Beleg der Verlustfreiheit:** der
      Rumpf jedes Eintrags ist in seiner Zieldatei byte-gleich wiederzufinden — geprüft über einen
      Vergleich gegen den Stand vor dem Vollzug (`git show HEAD~<n>:harness/conventions.md`),
      Ergebnis als Kommando + Ausgabe in §7. Zeilenzahl der Index-Datei danach unter **300**
      (`wc -l < harness/conventions.md`).
- [ ] **(2) Anker-Deckung: kein Verweis wird angefasst.** Jede Index-Zeile trägt **zwei** Anker —
      `<a id="mr-NNN"></a>` und `<a id="mr-NNN--<alter-slug>"></a>`. Der Nachweis ist eine
      Mengengleichheit, keine Stichprobe: die Menge der vor dem Vollzug referenzierten Anker
      (`git grep -oihP 'conventions\.md#mr-\d{3}--[^)]+\)' -- ':!harness/conventions.md' | sed 's/.*#//; s/)$//' | sort -u`,
      am 2026-09-03 **46** Zeilen, davon eine ein Prosa-Artefakt ohne Überschrift)
      ist **Teilmenge** der Menge der danach in `harness/conventions.md` deklarierten
      (`grep -ohP '(?<=<a id=")mr-[^"]+' harness/conventions.md | sort -u`) — Differenz **leer**
      bis auf das Artefakt, das vor dem Vergleich namentlich abgezogen wird.
      Und: `git diff --stat` des Vollzugs nennt **keine** der 261 referenzierenden Dateien.
- [ ] **(3) Die Form ist deklariert, nicht bloß vollzogen.** Ein neuer Eintrag
      (`MR-<nächste freie>`) im Adaptions-Block deklariert die Verzeichnis-Form, den Doppel-Anker
      als Adress-Vertrag und die Pfad-Präfix-Korrektur als **nicht** inhaltliche Änderung im Sinne
      der Append-only-Disziplin. Er trägt die Pflichtfelder inklusive
      *Ersetzt-Baseline-Regel* und *Auflösungs-Trigger*.
- [ ] `make gates` grün.
- [ ] `make docs-check` meldet **0** Befunde, und die geprüfte Referenz-Zahl liegt **nicht unter**
      der des Laufs unmittelbar vor dem Vollzug — ein Umzug, der Referenzen aus dem Prüfbereich
      fallen lässt, ist grün ohne gemessen zu haben.
- [ ] Doku-Update: [`AGENTS.md`](../../../../AGENTS.md) §1 nennt `harness/conventions.md` als
      Strukturregel-Ort — der Satz bleibt wahr und wird nur angefasst, falls die Index-Form ihn
      falsch macht. `harness/README.md` ebenso.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations.md`) fortgeschrieben —
      [`BEO-014`](../observations.md) wird **zitiert, nicht neu angelegt**; seine `Stand`-Spalte
      bekommt den Zeiger auf diesen Slice als Zustand, nicht als Chronik.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieser Slice läuft
      **ohne** Wellen-Betrieb, also hier geprüft.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort.

**Schritt 0 — die zwei Werkzeug-Fragen sonden, bevor irgendetwas umzieht.** Beide sind heute
*unbelegt für diesen Pin*, und keine darf angenommen werden:

- **(a) Löst der gepinnte d-check ein `<a id="…"></a>` als Link-Ziel auf?** Sonde in einer
  Wegwerf-Datei, danach zurückgenommen. **Rot gesehen** heißt hier: ein *erfundener* Anker in
  derselben Datei muss `anchor-missing` melden — sonst misst die Sonde nichts
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- **(b) Trägt `ids` mit `target: harness/conventions.md` eine Kennung, die in
  `harness/conventions/MR-NNN-….md` steht?** Betroffen sind zwei Stellen: die unverlinkte
  Selbstnennung in der H1 der Zieldatei und die Index-Zellen-Verlinkung
  `[MR-<NNN>](conventions/MR-<NNN>-<titel>.md)`. Im Nachbar-Repo tragen beide Formen **ohne**
  `d-check:ignore`-Marker und **ohne** `exempt-path`
  (`grep -rc 'd-check:ignore' --include='MR-*.md' /Development/a-check/harness/conventions/` → je 0;
  `grep -n 'exempt-paths' /Development/a-check/.d-check.yml` nennt nur `CHANGELOG.md` und
  `docs/reviews/**`). **Das ist ein Anlass, keine Deckung** — die Sonde läuft über *unserem*
  Korpus.

  **Die Strenge ist über diesem Baum gemessen und nicht vermutet:** `make docs-check` meldet
  `id-unlinked` für eine unverlinkte `MR-`Kennung auch dann, wenn sie bloß als Bestandteil eines
  Dateipfads in einem zitierten Kommando steht. Der Befund fällt also **an**, wenn ihn nichts
  ausnimmt — was die Sonde beantworten muss, ist allein, **ob** der Ort
  `harness/conventions/MR-<NNN>-<titel>.md` ausgenommen ist. **Rot gesehen** ist damit bereits, was
  passiert, wenn die Ausnahme fehlt.

  **Fällt (b) rot aus, endet dieser Slice hier** — die Reparatur wäre ein Eingriff in
  `.d-check.yml`, und jede Lockerung dort ist nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 eine
  ADR. Dann greift die Rückführung aus §4.

**Schritt 1 — Vollzug, mechanisch statt von Hand.** Die Extraktion läuft über ein Kommando
(`awk` auf `^### MR-` als Trennmarke), nicht über 45 Handgriffe: nur so ist Byte-Gleichheit
*prüfbar* statt behauptet. Die Pfad-Präfix-Korrektur der 276 Selbstverweise ist ein zweites,
ebenso mechanisches Kommando über den extrahierten Rümpfen.

**Schritt 2 — Index schreiben.** Eine Zeile je Eintrag, zwei Anker je Zeile. `Geltungsbereich` und
`Ersetzt-Baseline-Regel` werden aus den Pflichtfeldern des jeweiligen Rumpfs übernommen; wo ein
Rumpf das Feld nicht führt, steht `—` — **nachgetragen wird es nicht**, das entschiede
[`MR-039`](../../../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
und nicht dieser Slice.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/conventions.md` | refactor | wird Kopf + Index-Tabelle mit Doppel-Anker; Rümpfe ziehen aus |
| `harness/conventions/MR-<NNN>-<titel>.md` (eine je Eintrag) | neu | ein Rumpf je Datei, byte-gleich |
| `harness/conventions.md` (Adaptions-Block) | update | neuer `MR`-Eintrag deklariert die Form — Liefer-Punkt (3) |
| `docs/plan/planning/observations.md` | update | `BEO-014` `Stand`-Zeiger |
| `.d-check.yml` | **keine Änderung erwartet** | eine Änderung hier ist der Abbruch-Fall aus Schritt 0 (b), nicht der Erfolgsfall |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Ein Architect-Rolleninhaber übernimmt, und
`git status --porcelain -- harness/conventions.md` ist leer — die Datei ist in keinem anderen Lauf
in Arbeit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Vollzug lässt sich nicht mechanisch
  fahren — etwa weil ein Rumpf die Trennmarke `^### MR-` in einem Code-Block führt und die
  Extraktion ihn zerschneidet. Dann zerfällt der Slice in *Form-Entscheidung + `MR`-Eintrag* und
  *Vollzug*, weil die Byte-Gleichheit sonst nicht mehr prüfbar ist.
- `in-progress` → `open` (blockiert — Carveout?): Schritt 0 (b) fällt rot aus, oder eine der zwei
  Sonden verlangt einen Eingriff in `.d-check.yml`. Der Slice geht zurück, und vor ihm steht eine
  ADR nach [`AGENTS.md`](../../../../AGENTS.md) §3.5.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien:

1. Die Anker-Mengengleichheit aus DoD (2) steht mit Kommando und Ausgabe in §7, Differenz leer —
   und `git diff --stat` des Vollzugs nennt keine der referenzierenden Dateien.
2. `make gates` grün, `make docs-check` mit **0** Befunden und einer Referenz-Zahl nicht unter der
   des Vorlaufs.

Dazu der Lerneintrag in §7 und, weil dieser Slice **ohne** Wellen-Betrieb läuft, der
Trigger-Audit und der Lese-Schritt über das Beobachtungs-Register bei der Closure
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht, Tabelle *Träger im Repo
ohne Wellen*).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Ein paralleler Lauf schreibt in denselben Bereich.**
  [slice-157](../open/slice-157-adaptions-durchgang-v5180.md) (Adaptions-Durchgang gegen
  `v5.18.0`, Mitglied von [welle-14](../welle-14-re-baseline.md)) legt neue `MR`-Einträge an und
  ändert damit genau die Menge, die dieser Slice umzieht. Beide Reihenfolgen sind gangbar und
  kosten Verschiedenes: **157 zuerst** heißt, dieser Slice zieht mehr Einträge um; **166 zuerst**
  heißt, 157 schreibt seine neuen Einträge gleich in der Verzeichnis-Form an. **Welche zuerst
  läuft, entscheidet dieser Plan nicht** — das ist die Priorisierung beim Übergang
  `open→next`, und beide liegen als Datei vor, ohne dass `next/` einen Rang ausdrückte
  (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht: eine Reihenfolge
  einzelner Slices kennt der Harness nicht). Sichergestellt ist nur die **Nicht-Gleichzeitigkeit**,
  und zwar über den Start-Trigger in §4.
  — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im Register>
- **Die `Ersetzt-Baseline-Regel`-Spalte steht überwiegend auf `—`.** Das Feld ist ein Pflichtfeld
  jüngeren Datums; ältere Einträge führen es nicht, und nachgetragen wird es nicht. Eine
  Index-Spalte, die fast leer ist, sieht aus wie ein Formfehler und ist keiner. Sie bleibt drin,
  weil sie mit jedem neuen Eintrag füllt — und der Index-Kopf sagt, warum sie leer steht.
  — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im Register>
- **Die Zeitdokumente verweisen weiter auf einen Ort, an dem der Rumpf nicht mehr steht.**
  **167** der 261 referenzierenden Dateien liegen in `docs/reviews/**` oder
  `docs/plan/planning/done/**` (Differenz aus `… | wc -l` → 261 und derselben Suche mit
  `':!docs/reviews/**' ':!docs/plan/planning/done/**'` → 94). Ihre Links lösen weiter auf — der
  Index-Eintrag existiert —, führen aber auf eine Index-Zeile statt auf den Rumpf. Das ist ein
  Klick mehr, kein Bruch, und Zeitdokumente werden nicht nachgezogen
  ([welle-10](../done/welle-10-re-baseline.md) §6 zieht dieselbe Linie).
  — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im Register>
- **Der Umzug ändert den Träger, nicht den Inhalt — `BEO-014` bleibt offen.** Wer die
  Verzeichnis-Form für die Auflösung der Beobachtung hält, schließt eine Zeile, die weiter zutrifft.
  — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im Register>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren) · `grundlagen-traceability.md` §Herkunfts-Anker für
Steering-Loop-Regeln.

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations.md`):** `BEO-014` — Beleg `slice-166` ergänzt,
  Zähler nach der Regel des Registers fortgeschrieben.
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung.

**Umfang.** Alle berührten Sub-Areas sind GF; der Modus-Begründungsblock unten steht trotzdem,
weil die berührte Sub-Area eine offene Beobachtung trägt.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) aus der
Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area —
die Datei selbst ist dort keine eigene Zeile. Die drei Inklusions-Achsen für einen feineren
Schnitt *Harness-Konventionen* (`harness/conventions.md` samt dem Verzeichnis, das mit diesem
Slice daneben entsteht) wären erfüllt:
eine eigene `MR`-Adaption ist plausibel formulierbar (Liefer-Punkt 3 **ist** eine), eine eigene
Inventur-Linie ist sinnvoll, und mit diesem Slice entsteht eine eigene Pfad-Familie — 3 von 3.
**Der Schnitt wird hier nicht vollzogen:** die Modus-Deklaration zu ändern ist eine Aussage über
Sub-Areas des Repos und ein eigener Vorgang; dieser Slice benennt die Reife und überlässt die
Zeile dem Architect-Lauf, der sie schreibt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen
(`docs/plan/planning/observations.md`). Treffer für `*` (gesamtes Repo):
[`BEO-014`](../observations.md), Zähler **1×**, Beleg `slice-150`. Mit diesem Slice erreicht der
Eintrag **nicht** die Schwelle 3× — er wird belegt, nicht verkörpert. Weitere Treffer auf `*`
werden beim Vollzug erneut gesichtet, weil das Register zwischen Schnitt und Übernahme
fortgeschrieben wird und beim Lesen so alt ist wie der letzte Merge.

### Sub-Area: `*` (gesamtes Repo)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — der Gegenstand **ist** das Konventionsdokument. Die Disziplin
  des Blocks (chronologische Nummerierung, Pflichtfelder, Append-only) steht in ihm selbst; vier
  Einträge sind der Buchführung über den Block gewidmet.
- **Phase-Reife:** Phase 5 — Form und Sensor bestehen seit langem, die Datei ist unter
  `docs-check` und unter der `ids`-Linkpflicht.
- **Evidenz-/Diskrepanz-Risiko:** niedrig für den Inhalt (Doc führt, kein Code-Bestand dagegen zu
  halten), **erhöht für die Adressierbarkeit**: 2123 Verweise hängen an Ankern, die heute vom
  Überschriften-Text erzeugt werden statt deklariert zu sein. Genau dieses Risiko schließt
  Liefer-Punkt (2) — der Doppel-Anker macht die Adresse zur Deklaration. `BEO-014` steht auf
  1× und wird durch diesen Slice belegt, nicht aufgelöst.
- **Reconciliation-Aufwand:** keiner (GF). Graduation entfällt; der Folge-Trigger für den feineren
  Sub-Area-Schnitt *Harness-Konventionen* steht im Vorgelagert-Block oben.
