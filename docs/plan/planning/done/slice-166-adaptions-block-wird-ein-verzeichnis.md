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
([slice-157](../done/slice-157-adaptions-durchgang-v5180.md)) und **nicht** die Auflösung von
`BEO-014`.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **(1) Verzeichnis-Form vollzogen.** Jeder Eintrag, den
      `grep -c '^### MR-' harness/conventions.md` vor dem Vollzug zählt, liegt danach als eigene
      Datei `harness/conventions/MR-NNN-<titel>.md`; `harness/conventions.md` trägt Kopf,
      Adaptions-Block-Disziplin und eine Index-Tabelle mit den Spalten
      `MR | Titel | Geltungsbereich | Ersetzt-Baseline-Regel`. **Beleg der Verlustfreiheit:** der
      Rumpf jedes Eintrags ist in seiner Zieldatei byte-gleich wiederzufinden — geprüft über einen
      Vergleich gegen den Stand vor dem Vollzug (`git show HEAD~<n>:harness/conventions.md`),
      Ergebnis als Kommando + Ausgabe in §7. Zeilenzahl der Index-Datei danach unter **300**
      (`wc -l < harness/conventions.md`).
- [x] **(2) Anker-Deckung: kein Verweis wird angefasst.** Jede Index-Zeile trägt **zwei** Anker —
      `<a id="mr-NNN"></a>` und `<a id="mr-NNN--<alter-slug>"></a>`. Der Nachweis ist eine
      Mengengleichheit, keine Stichprobe: die Menge der vor dem Vollzug referenzierten Anker
      (`git grep -oihP 'conventions\.md#mr-\d{3}--[^)]+\)' -- ':!harness/conventions.md' | sed 's/.*#//; s/)$//' | sort -u`,
      am 2026-09-03 **46** Zeilen, davon eine ein Prosa-Artefakt ohne Überschrift)
      ist **Teilmenge** der Menge der danach in `harness/conventions.md` deklarierten
      (`grep -ohP '(?<=<a id=")mr-[^"]+' harness/conventions.md | sort -u`) — Differenz **leer**
      bis auf das Artefakt, das vor dem Vergleich namentlich abgezogen wird.
      Und: `git diff --stat` des Vollzugs nennt **keine** der 261 referenzierenden Dateien.
- [x] **(3) Die Form ist deklariert, nicht bloß vollzogen.** Ein neuer Eintrag
      (`MR-<nächste freie>`) im Adaptions-Block deklariert die Verzeichnis-Form, den Doppel-Anker
      als Adress-Vertrag und die Pfad-Präfix-Korrektur als **nicht** inhaltliche Änderung im Sinne
      der Append-only-Disziplin. Er trägt die Pflichtfelder inklusive
      *Ersetzt-Baseline-Regel* und *Auflösungs-Trigger*.
- [x] `make gates` grün.
- [x] `make docs-check` meldet **0** Befunde, und die geprüfte Referenz-Zahl liegt **nicht unter**
      der des Laufs unmittelbar vor dem Vollzug — ein Umzug, der Referenzen aus dem Prüfbereich
      fallen lässt, ist grün ohne gemessen zu haben.
- [x] Doku-Update: [`AGENTS.md`](../../../../AGENTS.md) §1 nennt `harness/conventions.md` als
      Strukturregel-Ort — der Satz bleibt wahr und wird nur angefasst, falls die Index-Form ihn
      falsch macht. `harness/README.md` ebenso.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations.md`) fortgeschrieben —
      [`BEO-014`](../observations.md) wird **zitiert, nicht neu angelegt**; seine `Stand`-Spalte
      bekommt den Zeiger auf diesen Slice als Zustand, nicht als Chronik.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieser Slice läuft
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

**Rückführung im ersten Anlauf — `in-progress` → `open`. Grund: Schritt 0 (b) war rot.**
Was daraus wurde, steht in §7; der Befund und seine Messung bleiben hier stehen.

Der Vollzug selbst trägt: die Extraktion lief mechanisch über die Trennmarke, 45 Zieldateien
entstanden, und die Umkehrung der Pfad-Präfix-Korrekturen reproduziert den Vorher-Stand
**byte-gleich** (identischer sha256 gegen den Ausschnitt aus
`git show ba4574e:harness/conventions.md`); der Index misst **146** Zeilen. Auch die
Anker-Mengengleichheit steht: der aus den Überschriften erzeugte Slug-Satz deckt die **45**
referenzierten Anker exakt — beide Differenzen leer, das 46. Element der Mess-Ausgabe ist das in
DoD (2) benannte Prosa-Artefakt.

Rot ist die **Adressierbarkeit**. `make docs-check` meldet über dem vollzogenen Stand
`552 Datei(en) geprüft, 56 Befund(e)` in drei Klassen, und **jede** Reparatur greift in
[`.d-check.yml`](../../../../.d-check.yml) ein:

1. **54× `id-unlinked`** in 12 der 45 Zieldateien. Das Modul `ids` nimmt bei
   `link-policy: always` die eigene `target`-Datei von der Linkpflicht aus — die Rümpfe nutzen das
   54-mal, etwa im `Löst auf:`-Feld von
   [`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst),
   das eine Kennung unverlinkt nennt. Dieselben Bytes sind im heutigen Stand grün und im Ziel-Ort
   rot. Reparatur wäre ein `exempt-paths`-Eintrag auf das neue Verzeichnis — eine Senkung nach
   [`AGENTS.md`](../../../../AGENTS.md) §3.5 — oder nachträgliches Verlinken in angenommenen
   Einträgen, was die Append-only-Disziplin bricht, die
   [`MR-039`](../../../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
   führt.
2. **1× `target-missing`** aus dem Rumpf von
   [`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben).
   Das `ignore-refs`-Paar, das diese Referenz stummschaltet, ist auf die Index-Datei geschlüsselt
   (`in:`) und nach
   [`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) **extensional
   geschlossen**; den Schlüssel nachzuziehen ist eine neue Senkung mit eigener ADR.
3. **1× `citation-out-of-range`**: [slice-135](../open/slice-135-d-check-pin-v0661.md) zitiert eine
   Zeilen-Nummer der Index-Datei, die der 146-Zeilen-Stand nicht mehr hat. Die Datei ist zugleich
   eine der referenzierenden — DoD (2) schließt aus, sie anzufassen.

**Zwei Prämissen des Plans sind an derselben Messung gefallen** und gehören in den nächsten
Schnitt:

- §1 nennt für `/Development/a-check` und dieses Repo denselben d-check-Pin.
  `grep -m1 '^DCHECK_IMAGE' d-check.mk` nennt hier **v0.65.0**, dasselbe Kommando im Nachbar-Repo
  **v0.69.0** — die Referenz-Form ist an einem neueren Pin gemessen als unser Korpus.
- §1 nennt die Korrektur an den blockinternen Selbstverweisen als **einzigen** zulässigen Eingriff.
  Gemessen sind es drei Klassen: dazu **259** aufwärts-relative Ziele (eine Ebene tiefer) und
  **8** geschwister-relative. Alle drei sind mechanisch und umkehrbar; die Byte-Gleichheit ist über
  die Umkehrung geprüft, nicht über den Verzicht.

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
  [slice-157](../done/slice-157-adaptions-durchgang-v5180.md) (Adaptions-Durchgang gegen
  `v5.18.0`, Mitglied von [welle-14](../welle-14-re-baseline.md)) legt neue `MR`-Einträge an und
  ändert damit genau die Menge, die dieser Slice umzieht. Beide Reihenfolgen sind gangbar und
  kosten Verschiedenes: **157 zuerst** heißt, dieser Slice zieht mehr Einträge um; **166 zuerst**
  heißt, 157 schreibt seine neuen Einträge gleich in der Verzeichnis-Form an. **Welche zuerst
  läuft, entscheidet dieser Plan nicht** — das ist die Priorisierung beim Übergang
  `open→next`, und beide liegen als Datei vor, ohne dass `next/` einen Rang ausdrückte
  (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht: eine Reihenfolge
  einzelner Slices kennt der Harness nicht). Sichergestellt ist nur die **Nicht-Gleichzeitigkeit**,
  und zwar über den Start-Trigger in §4.
  — **Ausgang: entfallen** — die Nicht-Gleichzeitigkeit hat gehalten. Der Start-Trigger war beim
  Übergang erfüllt (`git status --porcelain -- harness/conventions.md` leer), und
  [slice-157](../done/slice-157-adaptions-durchgang-v5180.md) liegt unverändert in `open/`. Er
  schreibt seine Einträge damit gleich in der Verzeichnis-Form an.
- **Die `Ersetzt-Baseline-Regel`-Spalte steht überwiegend auf `—`.** Das Feld ist ein Pflichtfeld
  jüngeren Datums; ältere Einträge führen es nicht, und nachgetragen wird es nicht. Eine
  Index-Spalte, die fast leer ist, sieht aus wie ein Formfehler und ist keiner. Sie bleibt drin,
  weil sie mit jedem neuen Eintrag füllt — und der Index-Kopf sagt, warum sie leer steht.
  — **Ausgang: entfallen** — die Annahme trug nicht. **42** der **46** Einträge führen das Feld
  (`grep -c '^- \*\*Ersetzt-Baseline-Regel:\*\*' harness/conventions/*.md | grep -vc ':0'`), und
  genau **4** Index-Zeilen tragen `—` (`grep -c '| — |$' harness/conventions.md`) — die vier
  retirierten aus [`MR-039`](../../../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 2. Keine Erwartungswerte
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Die Spalte ist voll, nicht leer.
- **Die Zeitdokumente verweisen weiter auf einen Ort, an dem der Rumpf nicht mehr steht.**
  **167** der 261 referenzierenden Dateien liegen in `docs/reviews/**` oder
  `docs/plan/planning/done/**` (Differenz aus `… | wc -l` → 261 und derselben Suche mit
  `':!docs/reviews/**' ':!docs/plan/planning/done/**'` → 94). Ihre Links lösen weiter auf — der
  Index-Eintrag existiert —, führen aber auf eine Index-Zeile statt auf den Rumpf. Das ist ein
  Klick mehr, kein Bruch, und Zeitdokumente werden nicht nachgezogen
  ([welle-10](../done/welle-10-re-baseline.md) §6 zieht dieselbe Linie).
  — **Ausgang: entfallen** — gebrochen ist nichts. Der Doppel-Anker trägt **alle** referenzierenden
  Dateien, die Zeitdokumente eingeschlossen: `make docs-check` meldet `554 Datei(en) geprüft,
  0 Befund(e)`, und die geprüfte Datei-Zahl steigt gegenüber dem Vorlauf (`507`), fällt also nicht.
  Der eine Klick mehr bleibt und ist die gewählte Form, kein offener Punkt.
- **Der Umzug ändert den Träger, nicht den Inhalt — `BEO-014` bleibt offen.** Wer die
  Verzeichnis-Form für die Auflösung der Beobachtung hält, schließt eine Zeile, die weiter zutrifft.
  — **Ausgang: weiter offen** → [`BEO-014`](../observations.md) im Register, Zähler auf 2×, Beleg
  `slice-166` ergänzt. Der Träger ist gewechselt, die Buchführungs-Fracht des Blocks unverändert.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren) · `grundlagen-traceability.md` §Herkunfts-Anker für
Steering-Loop-Regeln.

- **Was hat funktioniert:** Der mechanische Vollzug in **zwei** Stufen mit je eigener Umkehrung.
  Stufe 1 (Extraktion + Pfad-Präfix) reproduziert den Vorher-Stand byte-gleich
  (`sha256` `f955673b…` auf beiden Seiten), Stufe 2 (Verlinkung) ist geprüft, indem aus beiden
  Ständen jede Kennungs-Link-Hülle abgezogen wird — dann sind sie über alle **45** Dateien
  identisch. Erst diese Trennung macht *„der Rumpf reist byte-gleich"* zu einer Messung statt zu
  einer Behauptung, wenn **zwei** Eingriffs-Klassen nötig sind. Der Doppel-Anker trägt: **2129**
  Anker-Vorkommen vorher, **2133** nachher, alle vier Neuzugänge, **kein** Verweis nachgezogen.
- **Was ging anders als geplant:** §3 Schritt 0 (b) erwartete beim Rot das Ende des Slice und eine
  Gate-Senkung per ADR. Der Befund war ein anderer, und die Reparatur auch. Die **54**
  `id-unlinked` sind zwei Klassen: **52** blanke Kennungen in Prosa, für die die Ziel-Form der
  Baseline (`templates/harness/conventions/MR-NNN-titel.template.md`, Feld `Löst auf`) den Link
  ohnehin vorschreibt — sie werden verlinkt, nicht ausgenommen; und **2** Kennungen als
  Such-*String* in einem `git grep`-Kommando, die kein Link tragen kann, ohne das Kommando zu
  zerstören. Die Antwort auf die zweite Klasse ist keine Ausnahme, sondern die **Adresse des
  Definitions-Orts**: `ids.target` nennt jetzt `harness/conventions/`, weil dort die Kennungen
  wohnen. Gegenüber dem Stand vor dem Umzug ist das **Scoping, keine Senkung** — jedes so
  ausgenommene Byte lag vorher in der Index-Datei und war dort ebenso ausgenommen, und
  `harness/conventions.md` tritt **neu** unter die Link-Pflicht
  ([`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
  Setzung 2). Eine ADR war deshalb nicht für die **Kennungen** fällig, sondern für den
  `ignore-refs`-Schlüssel: [`ADR-0032`](../../adr/0032-eingefrorene-referenz-folgt-ihrem-rumpf.md).
- **Die dritte Klasse war ein Konflikt in der DoD selbst, und er ist aufgelöst.** DoD (2) verbietet,
  eine der referenzierenden Dateien anzufassen; die Zeilen-Zitation auf Zeile 1015 der Index-Datei
  in [slice-135](../open/slice-135-d-check-pin-v0661.md) musste trotzdem fallen. Aufgelöst über die
  **Referenz-Klasse**: DoD (2) gibt eine Zusage über **Anker**-Verweise, und der Doppel-Anker hält
  sie — an einer Zeilen-Zitation ist kein Anker beteiligt, sie kann von diesem Vertrag nicht
  getragen werden. Die Zusage ist gemessen eingehalten: **null** gelöschte Zeilen mit einem
  `conventions.md#mr-`-Anker im ganzen Diff, und die eine geänderte Anker-Zeile
  (die Index-Zeile zu [`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md)) trägt vorher wie nachher dieselbe Anker-Menge. DoD (2) bleibt für die
  **263** Anker-referenzierenden Dateien unverändert gültig.
- **Steering-Loop-Eintrag (geschärfte Regel, verkörpert):** *Ein Umzug, der ein Artefakt aus dem
  `ids`-`target` heraus bewegt, zieht den `target` mit — er nimmt den Ort nicht aus.* Verkörpert in
  [`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
  Setzung 2 (`seit slice-166`) und im Config-Kommentar der
  [`.d-check.yml`](../../../../.d-check.yml). Der Unterschied zur naheliegenden Antwort ist die
  Richtung: `exempt-paths` senkt, ein nachgezogener `target` verschiebt — und hier vergrößert er
  den geprüften Bestand, weil die Index-Datei neu hineinfällt.
- **Beobachtungs-Register (`../observations.md`):** `BEO-014` — Beleg `slice-166` ergänzt,
  Zähler nach der Regel des Registers fortgeschrieben.
- **Trigger-Audit (wellenlos, bei dieser Closure).** **ADR:** der erste Re-Evaluierungs-Trigger von
  [`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) ist eingetreten
  und hat seinen Ausgang in
  [`ADR-0032`](../../adr/0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) (Folge-ADR mit
  Teil-Supersede). **Adaptions-Einträge:** der Auflösungs-Trigger von
  [`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger),
  [`MR-039`](../../../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  und [`MR-043`](../../../../harness/conventions.md#mr-043--ein-nachgetragenes-pflichtfeld-schlägt-die-einordnung-im-rumpf)
  ist mit dem Umzug eingetreten — alle drei sind an die Inline-Form gebunden. Ihre Re-Evaluierung
  verlangt je Eintrag ein `Löst auf`-Urteil; sie geht als [`BEO-020`](../observations.md) ins
  Register, nicht in diesen Slice. **Bootstrap-aware
  Gate:** keines berührt.
- **Folge-Slices:** keiner. Der offene Posten des Trigger-Audits — die drei Einträge, deren
  Auflösungs-Trigger der Umzug gefeuert hat — geht als [`BEO-020`](../observations.md) ins
  Register statt in einen Schnitt. Das ist der Ausgang, den [`BEO-001`](../observations.md)
  verlangt: nicht jede Beobachtung wird ein Slice. Ein Slice-Plan wäre außerdem ein
  Planner-Artefakt, und dieser Lauf trägt die Architect-Rolle.
- **Risiken aus §6:** vier, jedes mit genau einem Ausgang — dreimal *entfallen* (mit Messung),
  einmal *weiter offen* → `BEO-014`.
- **Drei Paarungen:** **Anker** — der Steering-Loop-Eintrag ist verkörpert in
  [`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
  Setzung 2, und der Zielort trägt den Herkunfts-Anker
  (`grep -l 'seit slice-166' harness/conventions/*.md | wc -l`
  → **1**). **Folge-Slice** — kein Feld, also kein Gegenstand der Paarung. **Register** —
  `BEO-014` (2×, zwei Belege) und `BEO-020` (1×, ein Beleg) existieren als Zeilen und tragen je
  mindestens einen Beleg.

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
