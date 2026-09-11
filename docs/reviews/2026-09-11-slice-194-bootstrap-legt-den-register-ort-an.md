# Review — slice-194: Der Bootstrap legt den Register-Ort an

- **Rolle:** Reviewer (Modul 10) · **Datum:** 2026-09-11
- **Prüfgegenstand:** `git diff eb49b10f..HEAD -- internal/ test/` — vier Dateien, 93 Zeilen
  (`internal/emit/templates.go` +19 · `internal/emit/templates/observations/README.md` neu, 58 ·
  `internal/emit/templates_test.go` +6/−1 · `test/mutations/299-observations-readme-fehlt.sh` neu).
  Die drei Commits davor sind Lifecycle-Bewegung bzw. Marker-Nachzug.
- **Baum beim Lauf:** `git status --porcelain` leer; `HEAD` = `19bfcc1f` = `origin/main`
  (`git log origin/main..HEAD` leer) — die Implementer-Commits sind gepusht.
- **Plan:** `slice-194` (`in-progress/`), §1 Ziel und Abgrenzung, DoD (1) und (2), §3 Änderungs-Tabelle,
  §6 Risiken/Abgrenzung.
- **Referenzierte aktive ADRs:** `ADR-0037` (Festlegung 2 Ort und Träger, Festlegung 3
  Idempotenz-Klasse, Folgepflichten 1 und 2, Re-Evaluierungs-Trigger), `ADR-0034` (Festlegung 1
  Ablage-Form), `ADR-0007` (*skip-if-present*), `ADR-0006` (Tool als Quelle).
- **Anforderungen:** `LH-FA-01`, `LH-FA-02`, `LH-FA-03`, `LH-QA-01`, `LH-QA-02`.
- **Hard Rules:** `AGENTS.md` §3.5, §3.6, §3.7, §3.8, §3.11.
- **Adaptions-Einträge im Prüfbereich:** `MR-054` (Modul-Zusammensetzung des emittierten
  Doc-Gates), `MR-051` (Zahl-Beleg in der Commit-Message), `MR-025`, `MR-017`.
- **Vorherige Findings am gleichen Modul:** Review zu `slice-073` vom 2026-09-10, N-9 — *„Die
  Nicht-Emission von `codepaths` trägt … Sie hat eine Adresse: slice-194"*. Genau diese Adresse
  wird hier eingelöst; zwei Findings unten hängen daran.
- **Sensor-Lage:** kein eigener Gate-Lauf. `make gates` / `make mutate` / `make full-smoke` /
  `make test` / `make smoke` / `docker build` waren für diesen Lauf gesperrt (laufender
  Mutations-Vollauf teilt die Docker-Tags). Geprüft wurden **Stellen**, nicht Läufe; wo ein Befund
  an einem Lauf hängt, steht der Lauf im Feld `verifizierbar`. Ein `docker run` gegen den gepinnten
  d-check-Digest wurde **nicht** gebraucht und **nicht** gefahren.

---

## Findings

### HIGH-1 — Die emittierte Gate-Konfiguration begründet ihren abgeschalteten Modul mit dem Fehlen genau der Datei, die derselbe Lauf jetzt schreibt

- **kategorie:** HIGH
- **quelle:** `AGENTS.md` §3.7 (ein Kommentar beschreibt, was da ist); `LH-FA-02` (*out-of-the-box
  gate-sicher*); `MR-054` Setzung 3
- **pfad:** `internal/emit/templates/d-check.yml:17-20`
- **befund:** Die emittierte Startkonfiguration trägt im Präsens: *„codepaths bleibt aus: im
  frischen Ziel fehlt docs/plan/planning/observations/README.md (das Register entsteht erst mit der
  ersten Beobachtung), und drei mitemittierte Workflow-Commands nennen den Ort per Inline-Code —
  aktivieren, sobald dieser Ort emittiert wird oder die Commands ihn anders referenzieren."* Nach
  diesem Commit schreibt derselbe Init-Lauf beides: `cmd/ai-harness-init/main.go:418` legt
  `.d-check.yml` mit diesem Satz ab, `main.go:424` sechs Zeilen später über `emit.Templates` die
  Datei, deren Fehlen der Satz behauptet. Jedes ab hier gebootstrappte Ziel bekommt damit eine
  Konfiguration, die eine falsche Aussage über seinen eigenen Baum macht, und die Bedingung, die
  der Satz selbst für das Gegenteil nennt („sobald dieser Ort emittiert wird"), ist von demselben
  Commit erfüllt. Dass die Modul-Entscheidung nicht in diesen Slice gehört (Plan §3, `MR-054`
  Setzung 3), trägt für die **Entscheidung** — nicht dafür, dass der **Tatsachen-Satz** stehen
  bleibt.
- **verifizierbar:** nein, durch keinen Lauf dieses Repos. `make comment-claims` erreicht die Datei
  nicht (Prüfbereich `internal/**/*.go`, `cmd/**/*.go`, `harness/tools/*.sh`, `.claude/hooks/*.sh` —
  `AGENTS.md` §4), und kein aktives Modul des Doku-Gates urteilt über den Wahrheitsgehalt eines
  YAML-Kommentars. Beobachtbar ist der Widerspruch nur am emittierten Ziel: Ein Bootstrap-Lauf
  legt `.d-check.yml` und `docs/plan/planning/observations/README.md` nebeneinander ab.
- **Einschätzung (Über-Zusage):** **streichen**, nicht umformulieren — die erste Satzhälfte
  (fehlende Datei, „entsteht erst mit der ersten Beobachtung") ist ab diesem Commit unter keiner
  Lesart wahr. Was vom Block bleiben darf, ist die Modul-Entscheidung mit einem Grund, der trägt;
  welcher das ist, entscheidet der Vorgang, der `MR-054` Setzung 3 fortschreibt, nicht dieser Slice.
- **klasse:** `zusage-neben-geaenderter-ableitung-bleibt-stehen`

### MEDIUM-1 — Der Auflösungs-Trigger in `MR-054` ist eingetreten; der Eintrag sagt weiter das Gegenteil, und seine eigene Messung bemerkt es nicht

- **kategorie:** MEDIUM (Gate-Pfad, deshalb eine Stufe über der reinen Doku-Drift)
- **quelle:** `MR-054` Setzung 3; `AGENTS.md` §3.8 (Architect-Eigentum, deshalb Übergabe statt
  Reparatur im Implementations-Kontext)
- **pfad:** Eintragsdatei zu `MR-054`, Setzung 3, Zeilen 62-68
- **befund:** `MR-054` Setzung 3 begründet die Nicht-Emission von `codepaths` mit zwei Messungen
  und schreibt daneben: *„→ 0 — angelegt wird der Ort nicht."* Die Messung selbst
  (`sed -n '/^func structureGitkeeps/,/^}/p' internal/emit/templates.go | grep -c observations`)
  liefert nach dem Diff unverändert **0**, weil die Anlage nicht in `structureGitkeeps()` liegt,
  sondern in `planTemplates()` (`internal/emit/templates.go:407`) — die Zahl bleibt gleich, ihre
  Schlussfolgerung ist falsch geworden. Die Messung ist damit ein stiller Stellvertreter: Sie
  beobachtet einen Träger, den Festlegung 2 für diesen Ort ausdrücklich ausschließt. Der im selben
  Absatz genannte Auflösungs-Trigger — *„gleich ob die nennenden Stellen ihn nicht mehr per
  Inline-Code führen **oder der Ort mitemittiert wird**"* — ist mit diesem Commit eingetreten und
  nirgends verbucht.
- **verifizierbar:** ja, ohne Gate: die zwei abgedruckten Kommandos über `HEAD` fahren (`3` bzw.
  `0`) und gegen `internal/emit/templates.go:400-407` halten. Ein Gate-Lauf entscheidet ihn nicht —
  kein Modul des Doku-Gates liest die Adaptions-Einträge inhaltlich.
- **Einschätzung (Über-Zusage):** **umformulieren ist hier nicht zulässig** — der Eintrag ist
  angenommen, und die Disziplin des Adaptions-Blocks verbietet die nachträgliche inhaltliche
  Änderung (`harness/conventions.md` §Adaptions-Block: Kopf-Marke nach `MR-032`, Zeiger nach
  `MR-020`). Der Befund ist deshalb eine **Übergabe an den Architect**, kein Auftrag an den
  Implementer; er gehört zugleich in das Trigger-Audit der Closure.
- **klasse:** `zusage-neben-geaenderter-ableitung-bleibt-stehen`

### MEDIUM-2 — Die Idempotenz-Klasse aus DoD (1) hat für diese Datei kein rot gesehenes Gegenbeispiel

- **kategorie:** MEDIUM
- **quelle:** `AGENTS.md` §3.6 (DoD-Punkt ist namentlich ein Zusage-Träger); `ADR-0037`
  Festlegung 3; `ADR-0007`
- **pfad:** `internal/emit/templates.go:309-313` (die Klassen-Weiche) gegen
  `internal/emit/templates_test.go:474-511`
- **befund:** DoD (1) sagt für den neuen Ort ausdrücklich *skip-if-present* zu. Die Zusage hält
  heute strukturell — die Schleife in `Templates()` wählt `writeFileMode` nur für den Präfix
  `.harness/skills/`, alles andere fällt auf `writeSkipIfPresent` —, aber kein Wächter misst sie
  **für diese Datei**. `TestTemplates_SkipIfPresent` setzt seinen Sentinel allein auf
  `spec/lastenheft.md`, `test/mutations/50-skipifpresent-clobbert.sh` mutiert den *Writer* in
  `internal/emit/enforce.go`. Eine Mutation, die für genau diesen Zielpfad eine Ausnahme einträgt
  (`if rel == observationsReadmeTarget { write = writeFileMode }`), bliebe in `make test` und in
  `make mutate` **grün**; im realen Re-Lauf überschriebe sie die vom Adopter angepasste
  Register-README.
- **verifizierbar:** ja — ein Mutations-Fall dieser Form gegen `make test`; er bliebe heute grün
  und wäre damit selbst der Beleg des Befundes.
- **klasse:** `zusage-ohne-rot-gesehenes-gegenbeispiel`

### MEDIUM-3 — Der emittierte Text bindet alle drei Ausgänge an die Schwelle; das Regelwerk, auf das er verweist, bindet nur zwei

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register (Zeilen 142-145);
  `ADR-0034` Festlegung 1; DoD (1) („der Inhalt ist tool-autoriert und generisch … die drei
  Ausgänge")
- **pfad:** `internal/emit/templates/observations/README.md:42-53`
- **befund:** Die Datei überschreibt den Abschnitt mit *„Die drei Ausgänge ab 3×"* und führt
  `gestrichen` darunter; darunter steht *„Unterhalb der Schwelle ist `offen` der Normalzustand,
  kein Ausgang."* Das Modul, das die Datei in Zeile 3 als ihre Regel nennt, sagt das Gegenteil für
  einen der drei: *„Nur zwei der drei hängen an der Schwelle: verkörpert und geplant sind ihre
  Antwort. Gestrichen ist an sie nicht gebunden — fällt die Ursache weg, bevor der Zähler 3
  erreicht, wandert die Zeile mit Begründung in §Gestrichene Einträge."* Ein Adopter, dessen
  Beobachtung bei 1× gegenstandslos wird, findet in seiner mitgelieferten README keinen zulässigen
  Ausgang und hat zwei schlechte Auswege: den Eintrag dauerhaft `offen` stehen lassen oder das
  Verzeichnis löschen — Letzteres verbietet dasselbe Modul ausdrücklich.
- **verifizierbar:** nein, durch keinen Lauf: `ADR-0037` §Konsequenzen benennt selbst, dass die
  emittierte README eine zweite Fassung einer Regelwerks-Aussage ist und *„kein Gate hält die zwei
  zusammen"*. Entscheidbar ist er am Textvergleich der beiden genannten Stellen.
- **klasse:** `emittierte-zweitfassung-driftet-gegen-ihre-quelle`

### MEDIUM-4 — Der Vorher-Lauf aus DoD (2) ist behauptet, aber nirgends mit dem Kommando belegt, das ihn liefert

- **kategorie:** MEDIUM
- **quelle:** `MR-051` Setzung 1; `MR-025` Setzung 1; `AGENTS.md` §3.6 (der Plan verlangt den
  Vorher-Lauf ausdrücklich als Rot-Nachweis)
- **pfad:** Commit-Message `19bfcc1f`, Absatz *„Gemessen, netzlos, ueber d-check codepaths …"*
- **befund:** Die Message trägt zwei Messwerte — *„3 Befund(e) vorher … → 0 Befund(e) nachher"* —
  und nennt die Methode in Prosa (Modul, `roots`, zwei Sprach-Varianten), aber kein Kommando im
  Klartext, das genau diese Zahlen ausgibt. `MR-051` Setzung 1 stellt die Commit-Message
  ausdrücklich in den Geltungsbereich des Zahl-Belegs: *„sie nennt das Kommando, das genau sie
  ausgibt … Die Message trägt das Kommando im Klartext."* Damit ist der Rot-Nachweis, den DoD (2)
  und der Plan §2 als das tragende Stück fordern (*„ein Nachher-Lauf allein belegt nicht, dass die
  Änderung gewirkt hat"*), nicht nachvollziehbar: Ein zweiter Kontext kann weder den Aufruf
  wiederholen noch prüfen, über welchem Stand er lief. Die Arithmetik der `3` ist plausibel — drei
  mitemittierte Commands nennen den Ort (`grep -rl 'docs/plan/planning/observations'
  internal/emit/templates/commands/ | wc -l` → **3**, kein Erwartungswert) —, aber Plausibilität
  ist kein Beleg.
- **verifizierbar:** ja — derselbe netzlose d-check-Aufruf über einem Bootstrap aus `eb49b10f`
  gegen einen aus `HEAD`, mit der Kommandozeile im Protokoll. Dieser Lauf entscheidet den Befund.
- **Einschätzung (Über-Zusage):** Die Message ist gepusht und damit unveränderlich — genau der
  Grund, aus dem `MR-051` Setzung 1 den Träger vor den Commit legt. Zu **streichen** ist hier
  nichts; nachzuholen ist der Beleg an einem Ort, den es noch gibt (Closure-Notiz §7 oder der
  Verifikations-Bericht), samt Kommando und Stand.
- **klasse:** `zahl-neben-nie-gefahrenem-kommando`

### MEDIUM-5 — Der emittierte Text schickt den Adopter zu einer Spalte, die ein zweiter emittierter Text ihn zu streichen heißt

- **kategorie:** MEDIUM
- **quelle:** DoD (1) („generisch, nicht die repo-spezifische Fassung"); Baseline-Regelwerk
  `modul-06-roadmap.md` §Das Beobachtungs-Register (Kennung wird nachgeschlagen, nicht erfunden)
- **pfad:** `internal/emit/templates/observations/README.md:17-20` gegen die emittierte
  `harness/conventions.md`, Abschnitt *Modus-Deklaration pro Sub-Area* (Vorlagen-Zeilen 179-182)
- **befund:** Die neue README sagt: *„`<KUERZEL>` wird nachgeschlagen, nicht erfunden: es ist das
  Sub-Area-Kürzel aus der Modus-Deklaration in `harness/conventions.md`."* Die Vorlage, aus der
  dieselbe Emission die `harness/conventions.md` des Ziels stempelt, sagt im Fließtext — also
  nach dem Strippen der Kommentar-Hilfen weiterhin sichtbar: *„Die Kürzel-Spalte tragen nur Repos,
  deren Kennungen ein Bereichssegment führen (`ADR-<KUERZEL>-NNNN`, `slice-<KUERZEL>-NNN`); wer
  ohne Segment zählt, streicht sie."* Ein Adopter mit segmentlosen ADR-/Slice-Kennungen — der
  Regelfall, denn die Baseline vergibt keine — streicht die Spalte und hat bei seiner ersten
  Beobachtung nichts nachzuschlagen; er erfindet ein Kürzel, und genau davor steht die Regel.
  Der Widerspruch ist **geerbt, nicht erfunden** (die zwei Baseline-Texte tragen ihn gegeneinander),
  aber dieser Slice führt die Abhängigkeit neu in den emittierten Bestand ein. Dass die Ambiguität
  real zuschlägt, ist an diesem Repo ablesbar: `harness/conventions.md` §Modus-Deklaration muss
  eigens ausschreiben, dass die Spalte seit `v6.0.0` **nicht** bedingt ist, weil die
  Beobachtungs-Kennung das Segment trägt. Diese Auflösung bekommt das Ziel nicht mit.
- **verifizierbar:** nein, durch keinen Lauf — beide Texte sind für sich konsistent, und kein
  Modul hält zwei emittierte Dokumente gegeneinander. Entscheidbar am Textvergleich der zwei
  genannten Stellen.
- **klasse:** `emittierte-texte-widersprechen-einander`

### LOW-1 — Plan §1 nennt eine Zahl, die der Baum nicht trägt

- **kategorie:** LOW
- **quelle:** `MR-025` Setzung 1
- **pfad:** `slice-194` §1, Zeile 53
- **befund:** Der Plan begründet den Träger damit, dass *„drei mitemittierte Anweisungssätze
  namentlich auf `observations/README.md` zeigen"*. Gemessen zeigen **zwei** auf die Datei
  (`grep -rl 'observations/README.md' internal/emit/templates/commands/ | wc -l` → **2**:
  `close-welle.md`, `plan-welle.md`); der dritte (`implement-slice.md:153`) nennt das
  **Verzeichnis**. Keine Erwartungswerte. Der Go-Kommentar in `internal/emit/templates.go:403-407`
  formuliert es richtig („nennen den Ort"), der Plan nicht — und für DoD (2) ist die Unterscheidung
  tragend, weil die dritte Fundstelle nur über das Verzeichnis auflöst.
- **verifizierbar:** ja, ohne Gate: die zwei `grep`-Zeilen oben.
- **Einschätzung (Über-Zusage):** **umformulieren** — drei nennen den Ort, davon zwei die Datei.
- **klasse:** `korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge`

### LOW-2 — Die einzige reale Emissions-Kette kennt die neue Klasse nicht, und ihr Kommentar zählt zwei von drei auf

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.7; `LH-FA-02`
- **pfad:** `harness/tools/smoke.sh:61-68`
- **befund:** Der Kommentar über der Stichprobe sagt: *„emittiert werden Singletons (-> .md) und
  die Struktur-.gitkeep"* und wählt darunter *„je ein positiver Vertreter beider Klassen"*. Seit
  diesem Commit gibt es eine dritte Klasse — eine tool-autorierte Datei **mit Inhalt** ohne
  Baseline-Vorlage —, und sie hat in der Liste keinen Vertreter. `harness/tools/smoke.sh`
  beschreibt sich in denselben Zeilen als *„die einzige Stelle, an der die volle Kette real
  läuft"*; dass die Datei in einem echten Ziel ankommt, beobachtet damit kein Lauf — die Go-Tests
  messen über einer Fixture, und das emittierte Doc-Gate fährt `codepaths` nicht.
- **verifizierbar:** ja — `make smoke` bliebe grün, wenn die Emission der Datei ausfiele; nur
  `make test` fiele. Das ist der Lauf, der den Befund zeigt.
- **klasse:** `zusage-neben-geaenderter-ableitung-bleibt-stehen`

### LOW-3 — Der Ausgabe-Plan hält eine Alias-Referenz auf das eingebettete Paket-Global

- **kategorie:** LOW
- **quelle:** Maintainability
- **pfad:** `internal/emit/templates.go:407` mit `:459-460`
- **befund:** Alle übrigen Einträge des Plans sind frisch erzeugt (`[]byte(body)`, `[]byte{}`);
  dieser legt den eingebetteten Paket-Slice `observationsReadme` selbst in die Map. Solange nur
  gelesen und geschrieben wird, ist das folgenlos. Eine spätere In-Place-Transformation über den
  Plan-Werten — die naheliegende Form, wenn eine Neutralisierung wie `NeutralizeMakeClaims`
  einmal für alle Einträge laufen soll — verändert dann das Global für den restlichen Prozess;
  in `make test` laufen viele `emit.Templates`-Aufrufe in einem Prozess, die Verfälschung
  reiste also von Testfall zu Testfall.
- **verifizierbar:** nein, heute durch keinen Lauf — die Bedingung tritt erst mit einer solchen
  Transformation ein.
- **klasse:** `geteilter-zustand-im-rueckgabewert`

### INFO-1 — Der Mutations-Fall liegt außerhalb der Änderungs-Tabelle des Plans

- **kategorie:** INFO
- **quelle:** Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice
- **pfad:** `test/mutations/299-observations-readme-fehlt.sh` gegen `slice-194` §3
- **befund:** Die Tabelle in §3 führt `internal/emit/templates.go` und
  `internal/emit/templates_test.go`; ein Fall unter `test/mutations/` steht dort nicht. Das
  Wachstum geht in die richtige Richtung — `AGENTS.md` §3.6 verlangt zur neuen Zusage die rot
  färbende Mutation, und der Fall ist sauber gebaut (siehe N-3) —, benannt ist es im Plan nicht.
- **verifizierbar:** ja, ohne Gate: Diff gegen die Tabelle.
- **klasse:** `liefer-umfang-waechst-am-plan-vorbei`

### INFO-2 — Der emittierte Text liegt jetzt im Prüfbereich des eigenen Doku-Gates

- **kategorie:** INFO
- **quelle:** Dogfood-/Emissions-Ebenentrennung (`MR-054` §Geltungsbereich)
- **pfad:** `internal/emit/templates/observations/README.md:17` gegen `.d-check.yml` `scan.ignore`
- **befund:** `scan.ignore` nimmt `**/*.template.md` aus, nicht diese Datei; ihr Inline-Pfad
  `harness/conventions.md` wird deshalb von `codepaths` gegen **diesen** Baum existenzgeprüft,
  obwohl er eine Aussage über den Baum des Adopters ist. Heute grün, weil beide Bäume die Datei
  führen. Die Klasse ist nicht neu (`internal/emit/templates/commands/*.md` liegt ebenso im
  Prüfbereich), die Kopplung ist aber eine stille: Ein Umbau am eigenen `harness/`-Layout färbte
  `docs-check` an einem Satz rot, der von einem fremden Repo spricht.
- **verifizierbar:** ja — `make docs-check` nach einem Umbenennen von `harness/conventions.md`.
- **klasse:** `dogfood-prueft-eine-aussage-ueber-das-ziel`

---

## Negativbefunde (geprüft, ohne Befund)

- **N-1 — `skip-if-present` hält heute.** `Templates()` (`internal/emit/templates.go:295-317`)
  wählt `writeFileMode` ausschließlich für den Präfix `.harness/skills/`; der neue Zielpfad
  `docs/plan/planning/observations/README.md` fällt auf `writeSkipIfPresent`. Ein vorhandenes
  Ziel-Exemplar wird also nicht überschrieben — die Zusage aus DoD (1) trifft zu. Was fehlt, ist
  ihr Wächter (MEDIUM-2), nicht ihre Wahrheit.
- **N-2 — `TestTemplates_EmittierterBestandVollstaendig` misst die Eigenschaft, nicht die
  Implementierung, und zwar in beide Richtungen.** Der Vergleich ist Mengengleichheit über einen
  **gelaufenen** Baum (`emittedTree` läuft `filepath.WalkDir` über das ganze Zielverzeichnis,
  `internal/emit/templates_test.go:315-336`) gegen `want` als Zeichenkette — eine Datei zu viel bricht ihn
  genauso wie eine zu wenig. Beide Richtungen tragen einen eigenen Mutations-Fall:
  `26-recurring-emittiert.sh` (zu viel), `218-beobachtungsregister-nicht-emittiert.sh` (zu wenig).
  Die zweite `want`-Liste (`TestTemplates_MinimalQuelle`) ist mitgezogen; weitere Listen über dem
  emittierten Baum gibt es nicht (`grep -rn 'emittedTree\|TemplateTargets(' internal/emit/*_test.go`).
- **N-3 — Der neue Mutations-Fall trifft die Stelle des Aufrufers und misst sich nicht selbst.**
  Das `sed` löscht die Zeile in `planTemplates()` — genau den Pfad, den `emit.Templates()` und
  damit der Test benutzt; der Fall baut keine Verdrahtung nach. Das Muster trifft **genau eine**
  Zeile (`grep -cE '^\tout\[observationsReadmeTarget\] = observationsReadme$'
  internal/emit/templates.go` → **1**). Er kompiliert weiter: `observationsReadme` und
  `observationsReadmeTarget` bleiben als Paket-Deklarationen unbenutzt zurück, was Go zulässt, und
  `_ "embed"` bleibt durch die `//go:embed`-Direktive gedeckt. Die `# expect:`-Zeile nennt den
  Test, der wirklich fällt; dass daneben `TestTemplates_MinimalQuelle` ebenfalls rot wird, bricht
  Bedingung 4 des Treibers nicht — sie prüft Mitgliedschaft in den Fehlschlag-Zeilen
  (`harness/tools/mutate.sh:698`). Die Nummer 299 ist frei, und keine Zahl im Repo behauptet
  eine feste Fall-Anzahl.
- **N-4 — Der Inhalt der emittierten README ist gegen das Regelwerk gehalten und trägt bis auf
  MEDIUM-3 dessen Aussagen.** Baum-Darstellung, Kennung als Pfad `BEO-<KUERZEL>/<slug>`,
  „nachgeschlagen, nicht erfunden", Schreib-Rolle (Slice-Closure, nichts wird erhöht), Lese-Rollen
  (Welle-Closure bzw. — ohne Wellen-Betrieb — die Slice-Closure selbst; Slice-Planung für alles
  darunter), Beleg-Form (`evidence/<vorgangs-id>.md`, ein Vorgang zählt einmal, erzwungen vom
  Dateisystem) und die Aussage zur leeren Ablage decken sich mit Baseline-Regelwerk
  `modul-06-roadmap.md` §Das Beobachtungs-Register und mit `ADR-0034` Festlegung 1.
- **N-5 — Der Text ist generisch, mit der einen Ausnahme aus MEDIUM-5.** Er nennt kein Kürzel
  dieses Repos, keine Welle, keine Slice- oder ADR-Kennung, keinen tag-gepinnten Baseline-Pfad und
  keine Pfad-Form, die ein Ziel nicht hat; er trägt beide Betriebsarten (mit und ohne Wellen).
  Gemessen: `grep -nE 'ADR-[0-9]{4}|LH-[A-Z]+-[0-9]+|MR-[0-9]{3}|slice-[0-9]+|welle-[0-9]+'
  internal/emit/templates/observations/README.md` → keine Treffer.
- **N-6 — Die Auflage „keine Chronik, keine Slice-Referenzen" ist in den hinzugefügten Zeilen
  eingehalten.** Gemessen über den Prüfgegenstand: `git diff eb49b10f..HEAD -- internal/ test/ |
  grep -cE '^\+.*slice-[0-9]'` → **0**; dieselbe Zählung für `Review-Befund`/`Befund <X>-<N>` → **0**.
  Die Kommentare beschreiben die Stelle im Indikativ und tragen Kopplung bzw. Abgrenzung
  (`templates.go:400-404`, `:453-464`); Herkunft steht als auflösbares Feld (`ADR-0037`,
  `ADR-0034`, `ADR-0006`, `LH-FA-02`), nicht als Absatz. `make comment-claims` bleibt unberührt:
  keines der Trigger-Wörter aus `harness/tools/comment-claims.sh:31` kommt in den neuen
  Kommentaren vor.
- **N-7 — Das frische Ziel bleibt mit seinen aktiven Modulen grün.** Die neue Datei trägt keinen
  Markdown-Link (`links`, `anchors`), keine Kennung unter `link-policy: always` (`ids`), fällt in
  keine `matrix`-Klasse der emittierten Konfiguration (`slice-*`/`welle-*`/`adr`-Globs treffen den
  Pfad nicht) und enthält keine Tabelle mit Link-Zielen (`spans`). Ein künftiges `make <ziel>`
  darin fiele auf: `TestEmittierteDokumente_NurInitInvarianteZiele` läuft den **ganzen** emittierten
  Baum ab (`internal/emit/emitteddocs_test.go:138-204`), die Datei liegt also im Prüfbereich,
  obwohl sie die Neutralisierungs-Kette nicht durchläuft.
- **N-8 — Die Einbettung ist baubar.** `.dockerignore` schließt nur `.git` und `.harness` aus;
  `internal/emit/templates/observations/README.md` liegt im Build-Kontext der Go-Stufen, die
  `//go:embed`-Direktive löst dort auf.
- **N-9 — Die Abgrenzung des Plans ist eingehalten.** Unberührt sind die emittierte Modul-Liste,
  die `.d-check.yml` dieses Repos, jeder Migrationspfad für bereits gebootstrappte Repos und der
  vendored Baseline-Baum (`git diff --stat eb49b10f..HEAD` nennt außerhalb von `internal/` und
  `test/` nur Lifecycle-Dateien). `structureGitkeeps()` ist nicht angefasst — Festlegung 2
  entscheidet gegen diesen Träger, und der Kopfkommentar der Funktion sagt das weiterhin richtig.
- **N-10 — Folgepflicht 1 aus `ADR-0037` ist erfüllt.** Die Commit-Message von `19bfcc1f` benennt
  die drei Bedingungen aus Festlegung 1 für **diesen** Ort einzeln (a/b/c) und hält fest, dass die
  `want`-Listen nachgezogen und nicht aufgeweicht wurden. Das Zitat aus (a) ist am vendored Baum
  nachgeprüft (`modul-06-roadmap.md`, Zeile 87: `README.md … existiert ab Repo-Beginn`).
- **N-11 — Das Benutzerhandbuch wird nicht falsch.** §6 beschreibt den Baum grob
  (die Zeile zu `docs/plan/` nennt „Planung … Beobachtungs-Register") und bleibt wahr; die Zeile 1.13 der Änderungshistorie ist
  ein datierter Historie-Eintrag, den `ADR-0037` §Konsequenzen ausdrücklich von der Nachführung
  ausnimmt (Folgepflicht 2 adressiert allein die Präsens-Aussage des Bestandsbaums).
- **N-12 — Die Lifecycle-Bewegung davor ist sauber getrennt.** Die zwei `slice-mv`-Commits tragen
  Move und Verweis-Nachzug getrennt (`AGENTS.md` §3.3), der Ruhe-Marker-Commit begründet sich am
  `planning`-Modul und ändert sonst nichts.

---

## Kategorie-Summary

| Kategorie | Anzahl | Kennungen |
|---|---|---|
| HIGH | 1 | HIGH-1 |
| MEDIUM | 5 | MEDIUM-1 … MEDIUM-5 |
| LOW | 3 | LOW-1 … LOW-3 |
| INFO | 2 | INFO-1, INFO-2 |

**Wiederkehrende Klasse in diesem Lauf:** `zusage-neben-geaenderter-ableitung-bleibt-stehen` tritt
dreimal auf (HIGH-1, MEDIUM-1, LOW-2) — drei Stellen, ein Vorgang, also **eine** Gelegenheit für
den Zähler des Beobachtungs-Registers, nicht drei. Der Eintrag steht dort bereits mit dem Stand
`geplant`; die Häufung innerhalb eines einzigen Diffs gehört in die Closure-Notiz.

---

## Verdikt

**Blockierend: ja.** HIGH-1 blockiert den Merge: Ab diesem Commit emittiert das Werkzeug eine
Gate-Konfiguration, deren Begründung im selben Lauf widerlegt wird, und kein Sensor dieses Repos
sieht das. MEDIUM-1 bis MEDIUM-5 sind vor dem Merge zu klären; MEDIUM-1 ist dabei **keine**
Implementer-Arbeit, sondern eine Übergabe an den Architect (`AGENTS.md` §3.8), und MEDIUM-4 ist
nach dem Push nur noch an einem anderen Träger nachzuholen.

**Übergabe an den Verifier: noch nicht.** Die Arbeit am Gegenstand ist im Kern sauber — die
Emission hängt am richtigen Träger, der Mengen-Vergleich ist nachgezogen statt aufgeweicht, der
neue Mutations-Fall trifft die Stelle des Aufrufers, und der emittierte Text ist bis auf zwei
benannte Stellen gegen das Regelwerk gehalten. Was fehlt, ist nicht Code, sondern die
Widerspruchsfreiheit des Standes, den dieser Commit herstellt.

**Kein Gate-Beleg in diesem Report.** Dieser Lauf hat keinen Sensor gefahren; jede Aussage oben ist
an einer Stelle gemessen oder als „durch keinen Lauf entscheidbar" gekennzeichnet. Die offene
Messfrage für den Verifier ist MEDIUM-4: der Vorher-Lauf über `eb49b10f` mit seiner Kommandozeile.
