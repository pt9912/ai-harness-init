# Architect-Verdikt: drei Beobachtungs-Übertritte aus der Closure von `slice-204-das-programm-feld-nennt-das-programm` und zwei offene Register-Fragen — 2026-09-27

**Rolle:** Architect (Modul 8), Zug „Planner → Architect → Planner" (Lese-Schritt / Verkörperung,
wellenlos — Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht). Kein Review,
keine Verifikation; dieses Verdikt ist das
**Übergabe-Artefakt** an Planner, Reviewer und Implementer.

**Gelesen:** `AGENTS.md` §3 (§3.4, §3.6, §3.7, §3.8, §3.10); `modul-06-roadmap.md` §Das
Beobachtungs-Register; `modul-08-agentenrollen.md`; `grundlagen-traceability.md` §Herkunfts-Anker;
[`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md);
[`ADR-0069`](../plan/adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
vollständig; das Vorgänger-Verdikt
[`2026-09-26-verdikt-regel-rand-ohne-benannte-luecke-und-dod-haken-paarung.md`](2026-09-26-verdikt-regel-rand-ohne-benannte-luecke-und-dod-haken-paarung.md);
`docs/plan/planning/observations/README.md`; §7 von
[`done/slice-204-das-programm-feld-nennt-das-programm.md`](../plan/planning/done/slice-204-das-programm-feld-nennt-das-programm.md),
[`done/slice-archive-welle-schreibt-in-reports-nur-die-link-form.md`](../plan/planning/done/slice-archive-welle-schreibt-in-reports-nur-die-link-form.md)
und
[`done/slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt.md`](../plan/planning/done/slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt.md);
`observation.md`, `state.md` und alle `evidence/*.md` der drei Gegenstände sowie ihrer vier
genannten Nachbarn; die Reviewer- und Verifier-Reports aller drei belegenden Vorgänge (Runde 1/2 zu
slice-204, je eine Runde zu den zwei Geschwistern); `.harness/skills/reviewer.md` v2.1.0 vollständig;
`.claude/commands/implement-slice.md` vollständig; `git log` über den vollen Bestand (Kommandos je
Fund unten).

---

## Gegenstand 1 — `zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel`

### (a) Dieselbe Klasse?

Drei Belege, alle geprüft:

| Vorgang | Fund | Klasse? |
|---|---|---|
| `slice-archive-welle-schreibt-in-reports-nur-die-link-form` | Link-Regel: Kommentar sagt zu, weder Link- noch Zeilengrenze werde überquert, Verzeichnis ende am Schrägstrich; `\n` aus beiden Zeichenklassen, Schrägstrich, Namens-Maskierung — zwei gebunden (Fälle 472/473), Maskierung ohne Zahn | **ja, exakt** |
| `slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt` | Kommentar der Abschnitts-Erkennung sagt zwei Grenzen zu (Top-Level-Ende, Kommentar-Filter); Fall 474 bindet nur die Start-Grenze, Block-Ende ungebunden bis Fall 475 | **ja, exakt** — Modul 6 zählt das Auftreten, nicht den Behebungs-Zeitpunkt im selben Vorgang |
| `slice-204-das-programm-feld-nennt-das-programm` | Kommentar/`SPEC-031` sagen `splitWords` zwei Grenzen zu (Tab-Wortgrenze, Fortsetzungs-Bedingung); je eine Hälfte ungebunden, bis Fälle 480/483/484 sie banden | **ja, exakt** |

Kein Vorbehalt nötig — anders als beim Nachbar-Gegenstand 3 unten ist hier jeder Beleg eine
Kommentar-**Zusage über eine Regel-Grenze**, deren eine Hälfte **keinen Mutations-Fall** trägt; das
Muster ist in allen drei identisch, und `observation.md` grenzt selbst korrekt gegen die vier
Nachbarn ab (gemessen, nicht nur gelesen — die dortige Abgrenzung zu
`zeichenmenge-mitglied-ohne-eigenen-zahn` und `zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`
trägt: erstere prüft ein Wort gegen eine Zeichenmenge Mitglied für Mitglied, letztere setzt eine
**vorhandene** Assertion voraus, die nur der Mutations-Fall nicht bewacht — hier fehlt für die
Hälfte **beides**, Assertion und Fall). Keine Überlappung mit `regel-rand-ohne-benannte-luecke`
(dort fehlt die **Nennung** eines Rands, hier ist der Rand genannt und nur der Fall fehlt) oder
`mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere` (andere Achse: dort färbt eine
Mutation mehrere Tests, hier bindet keiner die Hälfte). Keine Zusammenführungs-Empfehlung.

**Übertritt steht.**

### (b) Ausgang: **verkörpert**, Reviewer-Skill

Zielort: [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md), neue Zeile unter
**LOW/INFO mit Eskalation**, neben der bestehenden Zeile „Grenzen-Aufzählung …" — Familie, aber
andere Achse (dort: eine **Aufzählung** ohne genannte Form; hier: eine **Zusage über die Grenze
einer Regel** ohne Mutations-Deckung je Teil). Anweisungssatz gehört der ausführenden Rolle
([`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)) — die Zeile
schreibt der **Reviewer**, ich liefere den Wortlaut als Übergabe-Artefakt.

**Gegen die Alternativen:**

| Ausgang | Warum nicht |
|---|---|
| Hard Rule (§3.6 erweitern) | Verschärfung wäre ADR-frei möglich, aber `AGENTS.md` kostet Kontext in **jedem** Lauf jeder Rolle; die Klasse trägt bisher nur MEDIUM/LOW-Gewicht und wird vom Review gefunden, bevor sie den Bestand erreicht. Kein Missverhältnis-Beleg für den Preis |
| `MR`-Eintrag | keine Abweichung von der Baseline (`MR-000`) |
| Gate | nicht baubar: „hält jede genannte Teil-Grenze einen Fall" ist keine mechanisch prüfbare Eigenschaft über beliebige Prosa — dieselbe Grenze wie bei der Aufzählungs-Zeile |
| *geplant* (Folge-Slice) | keine Lieferung nötig, eine Doku-Zeile genügt |
| *gestrichen* | Klasse ist am HEAD lebend: die Namens-Maskierung in `slice-archive-welle` ist bis heute ohne Zahn (`observation.md` nennt sie unbehoben) |

**Herkunfts-Anker:** `seit slice-204-das-programm-feld-nennt-das-programm` — dieser Slice trug den
dritten Beleg; sein §7 nennt die Beobachtung namentlich
(`grep -c 'zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel' docs/plan/planning/done/slice-204-das-programm-feld-nennt-das-programm.md`
→ 1; dieselbe Zeile steht auch in den zwei Geschwister-§7, aber die Traceability-Regel nennt den
Slice, dessen Closure den Übertritt auf 3× auslöste, und das ist slice-204, chronologisch der
letzte der drei).

### Textvorschlag (wörtlich, Übergabe an den Reviewer)

Neue Zeile in `.harness/skills/reviewer.md`, Abschnitt **LOW/INFO mit Eskalation**, direkt nach der
bestehenden Zeile „Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe":

```markdown
- **Mehrteilige Regel-Zusage im Kommentar ohne Mutations-Deckung je Teil** — ein Kommentar oder eine
  referenzierte Spec-Zeile sagt einer Regel mehrere Grenzen in einem Satz zu (z. B. „überquert weder
  Link- noch Zeilengrenze", „endet am Verzeichnis", „bricht die Fortsetzung nur vor dem
  Zeilenende"). Der Reviewer prüft für **jede genannte Teil-Grenze einzeln**, ob ein Mutations-Fall
  oder Test sie bindet — dass irgendein Fall zur Zusage existiert, genügt nicht: die Suite kann für
  eine Hälfte grün bleiben, während die andere gebunden ist. Eine Teil-Grenze ohne eigenen,
  bindenden Fall: INFO; LOW, wenn die ungebundene Hälfte praktisch erreichbar ist (Whitespace,
  Maskierung, Sonderzeichen); HIGH, wenn kein Gate die Folge meldet (Stilles-Grün-Pfad). Gilt für
  Zusagen, die der Diff anlegt oder ändert, nicht für den Bestand. Kein Gate fängt das
  ([`AGENTS.md`](../../AGENTS.md) §3.6; seit slice-204-das-programm-feld-nennt-das-programm)
```

Versionierung: 2.1.0 → 2.2.0, Datum des Reviewer-Laufs, der die Zeile schreibt.

### Kennzeichnung (§3.6/§3.7)

**Grenze der Verkörperung, benannt.** Kein Wächter existiert: `make mutate` prüft die Haltbarkeit
gelisteter Fälle, nicht das Fehlen eines Falls für eine benannte Kommentar-Zusage, und
`make comment-claims` prüft nur, ob ein genannter Sensor existiert. Träger ist der Review, der bei
jeder mehrteiligen Zusage die Mutations-Deckung je Teil hält; die Zeile deckt Zusagen, die der Diff
anlegt oder ändert, nicht den Bestand (die Namens-Maskierung in `slice-archive-welle` bleibt ein
akzeptiertes Negativ, bis ein künftiger Diff die Stelle anfasst).

**Was passieren müsste, damit die Zeile bricht:** ein Review-Report zu einem Diff, der eine
mehrteilige Regel-Zusage anlegt oder ändert, nennt in der Negativbefund-Zeile keine geprüfte
Teil-Grenze und lässt eine ungebundene Hälfte passieren. **Gegenprobe, die der Reviewer beim
Schreiben fährt** (von mir nicht gefahren, kein Reviewer-Lauf): die Zeile auf den bestehenden Fund
in `slice-archive-welle` (Namens-Maskierung) angewandt muss ihn als offenen Befund ausweisen —
`observation.md` bestätigt bereits, dass er unbehoben ist.

---

## Gegenstand 2 — `aenderung-nach-der-letzten-review-runde-bleibt-ungesehen`

### (a) Dieselbe Klasse — und ist der Nachtrag zweier älterer Vorgänge zulässig?

**Ja, zulässig — geprüft an Form, Lage und Substanz, nicht nur behauptet.**

**Form + Lage** (Modul 6, „Der Beleg ist formgebunden"): Dateiname = Kennung, Kennung löst über
`done/<Kennung>.md` auf. Beide erfüllt für die zwei nachgetragenen Vorgänge.

**Timing** — Modul 6 sagt: *„Wer schreibt: die Slice-Closure"* — das ist die Closure, die die Datei
anlegt, nicht zwingend die Closure **des benannten Vorgangs selbst**. Die Klasse existierte vor der
Closure von `slice-204` als Register-Kennung nicht; ihre zwei älteren Vorgänge konnten sie zu ihrer
eigenen Zeit nicht zitieren, weil es nichts zu zitieren gab. Ein Nachtrag beim **erstmaligen**
Anlegen einer neuen Klasse ist in diesem Repo bereits geübte Praxis — der Commit `690984de`
(Closure von `slice-archive-welle`) benennt selbst *„zwei [Beobachtungen] mit je zwei Belegen (2×,
je ein Beleg für den Shell-Träger nachgetragen)"*, und `zeichenmenge-mitglied-ohne-eigenen-zahn`
trägt bis heute einen Beleg für den **älteren** Vorgang
`slice-program-feld-nennt-weder-operator-noch-wertfragment`, sichtbar erst ab einer späteren
Closure. Modul 6 begrenzt die Beleg-Form (Kennung, Existenz, Lage), nicht den Zeitpunkt der
Erst-Erkennung relativ zum Vorgang.

**Substanz — nachgemessen an den zwei alten §7, nicht nur an den neuen `evidence/`-Texten:**

- `slice-archive-welle-schreibt-in-reports-nur-die-link-form` §7 (Zeile 267–278, `done/`): *„Der
  Review (Runde 1 …) fand R-1 … Nachrunde ist nicht gelaufen und wird nicht behauptet; das Häkchen
  Review durchgeführt bestätigt Runde 1 samt gezogenen [Findings]."* — deckt sich mit dem
  Evidence-Text (Commits `fc638444`, `a038a349`, `335edffe`, `f982adb8` nach dem letzten Report,
  keine Nachrunde).
- `slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt` §7 (Zeile 255–260,
  `done/`): *„… hat kein Reviewer gelesen, der Verifier hat sie gemessen (V-2) … Entscheidung zur
  Nachrunde: keine erneute Reviewer-Runde … ein zweiter Review-Report besteht nicht …"* — deckt sich
  mit dem Evidence-Text (Commits `22d24bfa`, `85643b3b`).

Beide §7 bestätigen wörtlich dieselbe Lage, die die neuen Evidence-Dateien beschreiben. Der Nachtrag
ist kein erfundener Beleg — er zitiert eine Tatsache, die am benannten Vorgang bereits dokumentiert
war, nur noch nicht unter dieser Kennung.

**Keine Überlappung mit einer der vier genannten Nachbar-Klassen** (die drei Mutations-/
Zeichenmengen-Klassen und `regel-rand-ohne-benannte-luecke` betreffen Testabdeckung bzw.
Formen-Vollständigkeit; diese Klasse betrifft die **Reichweite der Reviewer-Runde relativ zum
Commit-Stand**, eine eigene Achse). Keine Zusammenführungs-Empfehlung.

**Übertritt steht, 3× valide.**

### (b) Ausgang: **verkörpert**, Planner-Closure-Schritt in `.claude/commands/implement-slice.md`

Zielort: `.claude/commands/implement-slice.md`, Abschnitt **„## Closure — Planner-Rolle"**, als
Ergänzung zu Schritt 24. Der Abschnitt wird bereits von der **Planner**-Rolle ausgeführt (die
Datei selbst weist ihn so aus: *„Closure — Planner-Rolle"*), und genau die Planner-Closure ist die
Stelle, an der die drei bisherigen Vorgänge diese Prüfung — unterschiedlich ausführlich, aber jedes
Mal mit begründeter Entscheidung — bereits geleistet haben. Anweisungssatz-Eigentum nach
[`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md): der **Planner**
schreibt die Ergänzung.

**Gegen die Alternativen:**

| Ausgang | Warum nicht |
|---|---|
| Hard Rule (`AGENTS.md`) | Die Praxis ist bereits dreimal korrekt und konsistent gelebt worden (dokumentierte Abwägung, kein stilles Überspringen); es fehlt keine Verbots-Regel, sondern eine **Erinnerung im Ablauf**, die dort billiger sitzt als in jedem Laufkontext |
| Reviewer-Skill | Der Reviewer sieht diese Commits per Definition nicht (er ist vor ihrer Entstehung tätig) — die Zeile träfe die falsche Rolle |
| Gate | „Ist eine dritte Runde nötig?" ist ein Urteil (Kritikalität, Konvergenz, Größe des Rests), kein Gate-Fall |
| *geplant* (Folge-Slice) | keine Lieferung, ein Absatz genügt |
| *gestrichen* | Klasse ist real und wiederkehrend (drei von drei kürzlich geschlossenen Slices mit Post-Review-Commits betroffen) |

**Herkunfts-Anker:** `seit slice-204-das-programm-feld-nennt-das-programm` (dritter Beleg, seine
Closure löste den Übertritt aus).

### Textvorschlag (wörtlich, Übergabe an den Planner)

Neuer Absatz nach Schritt 24 in `.claude/commands/implement-slice.md` (Abschnitt „Closure —
Planner-Rolle"):

```markdown
24a. **Liegen Commits nach dem letzten Reviewer-Report vor** (Tests, Produktcode, Mutations-Fälle,
     Sensor-Doku — nicht nur Vorbereitung der Closure selbst), benennt die Closure-Notiz sie
     einzeln mit Hash und Kurzbeschreibung und trifft eine von zwei Entscheidungen, mit
     Begründung: eine weitere Reviewer-Runde über genau diesen Rest — oder eine begründete
     Entscheidung dagegen (etwa: der Verifier hat die Commits gemessen und gefahren, die Änderung
     setzt nur einen bereits vom Review benannten Schließungs-Vorschlag um, die Runden
     konvergieren in der Schwere). Ein Häkchen *Review durchgeführt*, das eine frühere Runde
     bestätigt, bestätigt **nicht** stillschweigend Commits danach — Reviewer und Verifier prüfen
     verschiedene Fragen (Plan/ADR/Hard-Rules gegen DoD/Spec), und die erste Frage stellt an den
     Nachrunden-Diff sonst niemand. Kein Gate fängt das; Träger ist diese Closure
     ([`AGENTS.md`](../../AGENTS.md) §3.10; seit slice-204-das-programm-feld-nennt-das-programm)
```

### Kennzeichnung (§3.6/§3.7)

**Grenze der Verkörperung, benannt.** Kein Wächter existiert: kein Sensor liest Reviewer-Report und
nachfolgende Commits gegeneinander. Träger ist die Closure selbst.

**Was passieren müsste, damit der Absatz bricht:** eine künftige Closure-Notiz, die Commits nach dem
letzten Report weder benennt noch eine Entscheidung dazu trägt. **Gegenprobe** (nicht von mir
gefahren): die drei bisherigen §7 gegen den vorgeschlagenen Wortlaut gelesen — alle drei erfüllen
ihn bereits inhaltlich (sie benennen die Commits und begründen die Entscheidung); der Absatz macht
diese Praxis zur **Pflicht statt zum Zufall**, sein Bruch zeigt sich erst an einer künftigen
Closure, die es unterlässt.

---

## Gegenstand 3 — `regel-rand-ohne-benannte-luecke`, vierter Beleg

### Messung: wie oft ist die Klasse seit Skill v2.1.0 (`bea34b9b`, 2026-09-26 20:13) überhaupt aufgetreten?

```sh
git log bea34b9b..HEAD --format='%h %s' | grep -c '^Rolle Planner: Closure des Slice'
# 1 — der einzige seither geschlossene Slice ist slice-204-das-programm-feld-nennt-das-programm
```

**Genau ein Vorgang** ist seit Existenz der Skill-Zeile überhaupt geschlossen worden. Der vierte
Beleg der Beobachtung ist damit nicht „die Klasse trat nach der Zeile viermal auf", sondern: **die
Zeile hatte bisher genau eine Gelegenheit zu wirken — und wirkte teilweise.**

An dieser einen Gelegenheit selbst zeigt sich Konvergenz, nicht Wiederholung ohne Wirkung:

| Runde | Schwere der Grenzen-Aufzählungs-Funde |
|---|---|
| Runde 1 (`6bddaaef`) | H-1 (Aufzählung fehlt komplett für eine Wortklasse) + L-1 (Aufzählung nennt `a&&b`, nicht die übrigen Formen) |
| Runde 2 (`e1ad8ccf`) | I-1 (zwei gefahrene Formen in der Aufzählung nicht genannt) — **keine** HIGH, **keine** LOW mehr für diese Klasse |

Das ist der Gegenbeleg zur „läuft unkontrolliert weiter"-Lesart: dieselbe Klasse, in derselben
Sitzung, fällt von HIGH auf INFO. Beide Lesarten des Aufgabentexts treffen zugleich zu — die Zeile
**wirkt** (der Review findet die Lücken zuverlässig und mit sinkender Schwere), und die
**Autor-Seite bleibt unverändert offen** (der Implementer fuhr die Formen-Probe in keiner der beiden
Runden vor der Abgabe; das bestätigt die Evidence-Datei selbst: *„die Autor-Seite blieb offen: der
Lauf, der die Aufzählung schrieb, fuhr die Formen nicht"*).

### (a) Klasse korrekt, kein Vorbehalt bei der Zählung

Der vierte Beleg ist eine korrekte Instanz derselben Klasse (Modul 6: „Ein Vorgang zählt einmal" —
H-1/L-1/I-1 sind ein Beleg für `slice-204`, richtig so gezählt). Keine Überlappung mit einem der
Nachbarn über die im Vorgänger-Verdikt bereits gemessene Abgrenzung hinaus.

### (b) Ausgang: **kein AGENTS.md-Eintrag jetzt** — stattdessen Eskalation auf die Autor-Seite im Implementer-Anweisungssatz, Hard-Rule-Text bleibt Vorrat

**Gegen das Schreiben der Falsch/Richtig-Zeile in `AGENTS.md` §3.6, jetzt:**

1. **Ein Datenpunkt trägt keine Eskalation.** Seit die Skill-Zeile existiert, gab es genau eine
   Gelegenheit; eine Stichprobe von n=1 belegt weder „die Reviewer-Seite reicht nicht" noch „sie
   reicht". Die „vierter Beleg"-Zählung im Register zählt über den gesamten Beobachtungszeitraum
   (auch vor der Skill-Zeile), nicht über die Zeit, in der die Zeile hätte wirken können — genau der
   Unterschied, den die Aufgabenstellung selbst als zu prüfen benennt.
2. **Konvergenz statt Eskalation.** Die Schwere sinkt innerhalb der einen Gelegenheit (HIGH →
   INFO); das ist das erwartete Bild einer wirkenden Kontrolle, nicht das einer wirkungslosen.
3. **Hard-Rule-Kosten bleiben unverändert hoch** (jeder Lauf, jede Rolle) gegenüber dem
   Autor-seitigen Befund, der eine einzelne Rolle betrifft.

**Aber die Autor-Seite ist real und unverändert unbehandelt** — dieselbe Lücke, die das
Vorgänger-Verdikt bereits als *„akzeptiertes Negativ"* benannte, ist beim einzigen Test seither
erneut eingetreten. Die im Vorgänger-Verdikt selbst vorgesehene, aber nicht empfohlene
Zweitstelle — eine Zeile im **Implementer**-Anweisungssatz — ist jetzt die proportionale
Eskalation: billiger als eine Hard Rule (ein Absatz in einer einzigen Rollen-Datei statt in jedem
Lauf jeder Rolle), trifft den Fehler an seiner Entstehungsstelle, und ist die von
[`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) vorgesehene Adresse
(„der Implementer schreibt seinen eigenen Anweisungssatz").

**Eskalationsleiter, damit sie nicht bei jedem Datenpunkt neu erfunden wird:**

1. Reviewer-Skill-Zeile (existiert, wirkt nachweislich).
2. **Implementer-Anweisungssatz** (Textvorschlag unten) — jetzt fällig.
3. Hard Rule `AGENTS.md` §3.6 (Text unten, **Vorrat** — nur bei erneutem Auftreten **nach** Schritt 2
   und mit ausdrücklicher Zustimmung des Auftraggebers, siehe §Zustimmung).

Zielort für Schritt 2: `.claude/commands/implement-slice.md`, Abschnitt **Schritt 13** („Plan vor
Code"), wo die Datei bereits Planungsdisziplin für Aufzählungen und Begründungen behandelt.
Anweisungssatz-Eigentum: der **Implementer** schreibt die Ergänzung
([`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).

### Textvorschlag (wörtlich, Übergabe an den Implementer) — Ergänzung zu Schritt 13

```markdown
    **Legt der Plan oder der Diff eine Grenzen-Aufzählung einer erkennenden Regel an oder ändert
    er sie** — eine Liste oder Zahl von Rändern, Formen oder Ausnahmen in einem Kommentar, einer
    Spec-Zeile, einem Test-Kopf oder einer Meldung —, fährt der Lauf, der sie schreibt, die Formen
    der Sprache, über die die Regel spricht, **selbst**, bevor er den Satz abschließt: dieselbe
    Formen-Probe, die sonst erst der Review nachträgt (Skill-Zeile „Grenzen-Aufzählung einer
    erkennenden Regel ohne Formen-Probe"). Eine gefahrene Form, die die Aufzählung nicht nennt,
    wird vor der Abgabe entweder ergänzt oder die Aufzählung als nicht vollständig gekennzeichnet
    — nicht erst im Review gefunden
    (seit slice-204-das-programm-feld-nennt-das-programm)
```

### Hard-Rule-Text, Vorrat (nicht jetzt zu schreiben — Zustimmung des Auftraggebers erforderlich)

Wörtlich übernommen aus dem Vorgänger-Verdikt (unverändert tragfähig):

```markdown
Falsch: eine Aufzählung „N Grenzen" oder „vier Ränder", die die Formen der Sprache nicht gefahren
hat. Richtig: die Formen fahren und je Form das Ergebnis nennen — oder die Aufzählung als nicht
vollständig kennzeichnen.
```

**Trigger für den Vorrat:** die Klasse tritt in einem Slice auf, der **nach** der
Implementer-Anweisung aus diesem Verdikt (Schritt 2) geschlossen wird — dann hat auch die
billigere, näher an der Fehlerquelle sitzende Maßnahme nicht gegriffen, und die Hard Rule ist mit
dieser Evidenz neu zu wägen.

### Kennzeichnung (§3.6/§3.7)

**Grenze, benannt.** Kein Wächter existiert für die Autor-Seite: Ob ein Implementer-Lauf vor der
Abgabe tatsächlich eine Formen-Probe fuhr, ist nur am Diff-Zeitpunkt beobachtbar (mitgeführte
Test-/Fall-Commits), nicht mechanisch erzwingbar. Träger ist der Lauf selbst, der die Aufzählung
schreibt.

**Was passieren müsste, damit die Ergänzung bricht:** der nächste Slice, der eine
Grenzen-Aufzählung anlegt oder ändert, liefert sie ohne vorab gefahrene Formen-Probe, und der
Review findet erneut eine ungenannte Form — **Gegenprobe von mir nicht gefahren** (kein
Implementer-Lauf; die einzige verfügbare Realdatenquelle ist der nächste tatsächliche Slice dieser
Art).

---

## (d) Zwei offene Fragen aus dem Vorgänger-Verdikt

### (i) Gestrichenes Register-Verzeichnis ohne Beleg — zählt es weiter als Befund der Paarung?

**Befund, gemessen:**

```sh
for d in docs/plan/planning/observations/BEO-ALL/*/; do
  n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -eq 0 ] && echo "$d"; done
# ci-rennt-gegen-die-publikation-des-gepinnten-releases/
# cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht/
# einstiegs-datei-weicht-von-der-pflichtgliederung-ab/
# planungs-bestand-waechst-schneller-als-er-abgebaut-wird/
```

`einstiegs-datei-weicht-von-der-pflichtgliederung-ab` trägt seit `f678bf1c` `state.md: gestrichen`
mit einer am lebenden Baum verifizierten Begründung (die Aussage trifft nicht mehr zu). Die
mechanische Schleife zählt es dennoch weiter, weil sie nur `evidence/*.md` zählt, nicht `state.md`
liest.

**Verdikt: das ist keine Fehlfunktion der Schleife, sondern die von
[`ADR-0069`](../plan/adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
selbst offengelassene Lücke — und sie ist damit noch nicht zu schließen.**

`ADR-0069` Festlegung 2 ist an dieser Stelle **absichtlich absolut**: *„Jedes Verzeichnis ohne nicht
leeres `evidence/*.md` ist ein Befund; es gibt keine Liste, keinen Marker und keine Klasse, die ihn
ausnimmt."* Ein `gestrichen`-Zustand wäre genau eine solche Klasse. Zugleich benennt die ADR unter
*„Was hier NICHT entschieden ist"* fast wortgleich dieses Szenario: *„Was mit einem Verzeichnis
geschieht, das nie einen Beleg bekommen kann — … Die Baseline kennt für ein nie gezähltes
Verzeichnis weder `gestrichen` … noch den Rückbau; das ist der Re-Evaluierungs-Trigger 1, nicht eine
Festlegung."* Der Re-Evaluierungs-Trigger 1 ist mit diesem Fall **erstmals real ausgelöst**: ein
Verzeichnis ohne Beleg, dessen Klasse nach dem Urteil des Planners keinen Vorgang mehr treffen wird
(die Ursache ist verifiziert entfallen).

Trigger 1 verlangt ausdrücklich: *„dann trägt (a) nicht, und (b) … ist mit dieser Evidenz neu zu
wägen, **als Folge-ADR**."* Eine Norm-Änderung an dieser Stelle — und genau das wäre eine Ausnahme
für `gestrichen`-Verzeichnisse in der Paarung — ist damit **nicht** per Planner-Notiz oder
README-Satz zu erledigen (das wäre die stille Norm-Umgehung, die §3.4 verbietet), sondern braucht
den von der ADR selbst benannten Weg.

**Empfehlung: kein Folge-ADR jetzt schreiben.** Der aktuelle Zustand ist **nicht** falsch — er ist
genau das, was `ADR-0069` heute verlangt: die Closure nennt das Verzeichnis namentlich und behauptet
die Paarung nicht als getragen (das tut die Planner-Notiz zu `slice-204` bereits, siehe
Commit-Message). Der Preis ist Verzeichnis-Rauschen in der Meldung, kein Blockade- oder
Korrektheits-Schaden (`ADR-0069` selbst: „keine Senkung nach §3.5: er ändert keine Schwelle, er
benennt einen Bestand"). Ein Folge-ADR für **ein** kosmetisches Rauschen wäre unverhältnismäßig
gegen den erreichbaren Nutzen. Stattdessen:

- **Textvorschlag für eine künftige Folge-ADR** (Vorrat, damit die Frage nicht wieder von vorn
  gedacht werden muss, sobald ein zweites `gestrichen`-Verzeichnis diesen Trigger erneut auslöst):
  neue Festlegung, die `ADR-0069` Festlegung 2 **ergänzt** (`supersedes` nur den absoluten
  Nebensatz „keine Klasse, die ihn ausnimmt"): *„Ein Verzeichnis mit `state.md: gestrichen` und
  verifizierter Begründung ist kein Befund der Paarung (c), zweite Hälfte, mehr — die Streichung
  selbst ist der Ausgang, den Modul 6 für ein Vorkommen unter der Schwelle vorsieht. Die
  mechanische Schleife und ein künftiger Wächter filtern `state.md: gestrichen` heraus, bevor sie
  zählen."*
- **Wer schreibt sie, und wann:** der Architect, sobald der Planner ein zweites Mal an diesen
  Trigger stößt (oder sofort, falls der Auftraggeber die Priorität anders setzt) — nicht dieses
  Verdikt.
- Die zwei übrigen strukturell unheilbaren Verzeichnisse (`ci-rennt-…`, `cpp-skelett-…`) sind nach
  `ADR-0069` Festlegung 3/„Was hier NICHT entschieden ist" **kein** Gegenstand dieses Triggers,
  solange kein Vorgang sie trifft **und** der Planner nicht urteilt, dass keiner sie je treffen
  wird — das bleibt offen, wie im Vorgänger-Verdikt.

### (ii) `observation.md` „unveränderlich ab Anlage" — Commit `47d89ce4` verletzt die Regel

**Gemessen:**

```sh
git show 690984de -- docs/plan/planning/observations/BEO-ALL/regel-rand-ohne-benannte-luecke/observation.md
# neue Datei, 9 Zeilen, KEIN Abschnitt "Benannt, nicht gezählt"
git show 47d89ce4 -- docs/plan/planning/observations/BEO-ALL/regel-rand-ohne-benannte-luecke/observation.md
# 15 Zeilen ANGEHÄNGT, in einem separaten, späteren Commit
```

Das ist eine echte nachträgliche Änderung einer bereits angelegten `observation.md` — im Unterschied
zu `zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel/observation.md`, deren Abschnitt
„Benannt, nicht gezählt" **von Anfang an**, im selben Anlage-Commit (`690984de`), Teil der Datei war
(`git log --follow` zeigt dort genau einen Commit).

**Ursache: die Register-`README.md` weist ausdrücklich in dieses immutable Artefakt.** Ihr Wortlaut
— *„es gehört trotzdem in `observation.md` unter ‚Benannt, nicht gezählt'"* — ist **spezifischer**
als die Baseline (`modul-06-roadmap.md`: *„es gehört trotzdem in **den Eintrag**"*, ohne
Datei-Festlegung) und widerspricht Modul 6s eigener Formregel zwei Zeilen davor in derselben
`README.md`: *„`observation.md` (unveränderlich ab Anlage: Bezeichnung, Sub-Area,
Kurzbeschreibung)"*.

**Verdikt: die `README.md`-Formulierung ist der Fehler, nicht `47d89ce4` als Handlung an sich — aber
der Ort, an dem `47d89ce4` schrieb, ist der falsche.** Ein „Benannt, nicht gezählt"-Vorkommen, das
bei der **Erst-Anlage** einer Beobachtung schon bekannt ist, gehört in `observation.md` (Teil des
einen Anlage-Commits, wie bei der `zusage-im-doc-kommentar…`-Beobachtung). Ein Vorkommen, das erst
**nach** der Anlage entdeckt wird, kann nach Modul 6 nur noch in `state.md` landen — das einzige
Feld, das die Baseline als „veränderlich" führt.

**Empfehlung (Planner-Arbeit, kein ADR — dies korrigiert keine Norm, sondern eine Falschanwendung
der bestehenden):**

1. **Korrektur-Commit:** den Abschnitt aus `regel-rand-ohne-benannte-luecke/observation.md` nach
   `state.md` verschieben (reiner Move-Inhalt, ein Commit, Begründung in der Message).
2. **Textvorschlag für die Register-`README.md`** (Planner-eigenes Artefakt, wie bereits im
   Vorgänger-Verdikt zur Kästchen-Frage gehandhabt):

   ```markdown
   Ein Vorkommen ohne abgeschlossenen Vorgang gehört in den Eintrag der Klasse — bei der
   Erst-Anlage der Beobachtung in `observation.md` (Teil des Anlage-Commits); wird es **nach** der
   Anlage entdeckt, in `state.md`, da `observation.md` ab Anlage unveränderlich bleibt.
   ```

Kein ADR nötig: Modul 6 selbst entscheidet bereits eindeutig, was veränderlich ist und was nicht;
hier korrigiert sich eine repo-lokale Anleitung, die dem widersprach, nicht die Norm selbst.

---

## Zustimmung des Auftraggebers

- **Gegenstand 1, 2:** nein. Skill-Zeile bzw. Command-Ergänzung sind Anweisungssätze der
  ausführenden Rolle (`ADR-0028`), keine Architect-Norm (§3.8); keine ADR, kein `Proposed`.
- **Gegenstand 3, Schritt 2 (Implementer-Anweisung):** nein, aus demselben Grund.
- **Gegenstand 3, Schritt 3 (Hard-Rule-Text):** **ja, ausdrücklich** — jede Änderung an
  `AGENTS.md` §3 wartet auf die Zustimmung des Auftraggebers; der Text bleibt Vorrat, nicht
  geschrieben.
- **(d)(i):** nein für die Empfehlung, kein Folge-ADR jetzt zu schreiben (Planner-Praxis bleibt
  unverändert `ADR-0069`-konform). **Ja**, falls der Auftraggeber ein Folge-ADR zur
  `gestrichen`-Ausnahme jetzt statt später will — der Textvorschlag liegt bereit.
- **(d)(ii):** nein — Korrektur einer bestehenden Norm-Anwendung, keine neue Norm.

## Übergaben

| An | Artefakt |
|---|---|
| **Reviewer** | Zeile + Version 2.2.0 für `.harness/skills/reviewer.md` (Gegenstand 1), Gegenprobe an der Namens-Maskierung in `slice-archive-welle` |
| **Planner** | Absatz 24a für `.claude/commands/implement-slice.md` (Gegenstand 2); `state.md`-Ausgänge für die drei Beobachtungen (verkörpert/verkörpert/kein Ausgang-Wechsel bei Gegenstand 3 — dort bleibt `verkörpert` mit fortgeschriebenem Belegzähler, keine neue Eskalation in die Norm); Korrektur-Commit + README-Satz für (d)(ii); Kenntnisnahme (d)(i), kein Handlungsbedarf jetzt |
| **Implementer** | Ergänzung zu Schritt 13 in `.claude/commands/implement-slice.md` (Gegenstand 3, Autor-Seite) |
| **Auftraggeber** | Vorrat-Text für `AGENTS.md` §3.6 (Gegenstand 3, nur bei erneutem Auftreten nach der Implementer-Ergänzung); optional ein Folge-ADR zu `ADR-0069` Trigger 1 ((d)(i)) |

## Was offen bleibt

- Gegenstand 3: nur ein Datenpunkt seit der Skill-Zeile — die Eskalationsleiter bleibt auf Stufe 2;
  ob Stufe 3 je nötig wird, entscheidet der nächste tatsächliche Vorgang dieser Art, nicht eine
  weitere Wartezeit.
- (d)(i): zwei strukturell unheilbare Register-Verzeichnisse (`ci-rennt-…`, `cpp-skelett-…`) bleiben
  ungeklärt, wie im Vorgänger-Verdikt.
- Keine der drei Gegenprobe-Läufe (Reviewer-Zeilen, Command-Ergänzungen) ist von mir gefahren — ich
  bin kein Reviewer- oder Implementer-Lauf; das bleibt Aufgabe der Rolle, die den Text übernimmt.
