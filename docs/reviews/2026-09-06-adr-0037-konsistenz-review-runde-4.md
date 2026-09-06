# Review: ADR-0037 — Konsistenz-Review, Runde 4

**Review-Art:** Plan-Review gegen Spec/ADR (Modul 10 §Drei Review-Arten) — geprüft wird die
Entscheidung gegen ihre zitierten Quellen, **nicht** DoD-Konformität (Verifier-Rolle, getrennter
Kontext).

**Gegenstand:** [`docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md`](../plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md)
Status `Proposed`, Nacharbeit-Commit `3a90ceb` (Diff `3a90ceb^..3a90ceb` = `2c96074..3a90ceb`,
**eine** Datei: die ADR).

**Skill:** `.harness/skills/reviewer.md` @ 1.7.0 ·
**Modell:** claude-opus-5[1m] · **Datum:** 2026-09-06

**Reviewer:** frischer Kontext. Keines der geprüften Artefakte selbst geschrieben, an keinem etwas
geändert. **Jede Zahl und jedes Kommando dieses Reports ist in diesem Lauf selbst gefahren**;
nichts ist aus der Commit-Message von `3a90ceb`, aus dem Slice-Plan oder aus der ADR übernommen.
Die drei blockierenden Befunde der Vorrunde sind einzeln am Ist-Stand nachgeprüft, nicht am
Änderungsbericht.

---

## Eingangs-Kontext (fünf Pflicht-Punkte + Plan)

- **Diff-Range:** `3a90ceb` gegen `3a90ceb^` = `2c96074`. **Der Arbeitsbaum ruhte in diesem Lauf
  nicht** — anders als in Runde 3 und ausdrücklich abweichend von der Auftragslage („kein anderer
  Agent läuft"): Während der Prüfung sind **sieben** Commits einer Planner-Rolle gelandet
  (`git log --oneline 3a90ceb..HEAD | wc -l` → **7**, kein Erwartungswert), und `git status`
  wechselte mehrfach zwischen modifiziert und sauber. **Der Prüfgegenstand ist davon nicht
  berührt:** keiner der sieben fasst eine ADR an
  (`git log --oneline 3a90ceb..HEAD -- docs/plan/adr/ | wc -l` → **0**), und die geprüfte Datei ist
  über die Strecke byte-gleich
  (`git diff 3a90ceb HEAD -- docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md | wc -l`
  → **0**). Ebenso unberührt sind `spec/lastenheft.md`, `.harness/baseline/`, `internal/emit/`
  und der Slice-Plan. Die Feststellung steht hier, weil ein Report, der einen ruhenden Baum
  behauptet, den er nicht hatte, seine eigene Reproduzierbarkeit falsch beschriebe.
- **`LH-*`:** [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (Rang 1, der
  ausgelegte Absatz), [`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7),
  [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).
- **Referenzierte aktive ADRs**, Status in diesem Lauf gemessen
  (`for f in 0005 0006 0007 0016 0034; do grep -m1 '^\*\*Status:\*\*' docs/plan/adr/$f-*.md; done`):
  alle fünf `Accepted`. Keine `Superseded`/`Deprecated` unter den zitierten.
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3, insbesondere §3.4 (die Kosten-Asymmetrie, die
  diesen Report trägt), §3.5, §3.6, §3.8, §3.9, §3.10, §3.11. Dazu
  [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage),
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids),
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
  [`MR-036`](../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)
  und [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung).
- **Vorherige Findings am gleichen Modul:**
  [Runde 1](2026-09-06-adr-0037-konsistenz-review.md) (0 HIGH · 5 MEDIUM · 4 LOW · 3 INFO),
  [Runde 2](2026-09-06-adr-0037-konsistenz-review-runde-2.md) (0 HIGH · 2 MEDIUM · 4 LOW · 5 INFO)
  und [Runde 3](2026-09-06-adr-0037-konsistenz-review-runde-3.md) (0 HIGH · 3 MEDIUM · 1 LOW ·
  2 INFO), alle drei *Konsistenz NICHT BESTÄTIGT*.
- **Slice-Plan:** `slice-190` — das Übergabe-Artefakt, dessen zwei Fragen die ADR beantwortet.
  Seine Verzeichnis-Position steht hier bewusst nicht als Pfad
  ([`AGENTS.md`](../../AGENTS.md) §3.11); die Kommandos unten adressieren ihn über den Glob
  `docs/plan/planning/*/slice-190-*.md`, der in diesem Lauf **genau eine** Datei trifft
  (`ls -1 docs/plan/planning/*/slice-190-*.md | wc -l` → **1**, kein Erwartungswert).

**Gate-Lauf, Docker-only (§3.9).** `make docs-check` vor dem Schreiben dieses Reports →
`d-check: 887 Datei(en) geprüft, 0 Befund(e)`, EXIT 0. `make gates` **nach** dem Schreiben →
EXIT 0; dieser Lauf schließt `docs-check` ein und deckt damit auch diese Datei.

---

## Findings

Jedes Finding folgt dem §Output-Schema des Reviewer-Skills.

### M-1 — Die Datei erklärt eine Aussage des bedienten Plans für unberührt, die Festlegung 4 messbar entwertet; die Achse, auf der jene Aussage steht, ist nicht die genannte

- `kategorie`: **MEDIUM** (blockiert den Statuswechsel)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.10 (diese ADR ist das Übergabe-Artefakt, aus dem der
  Planner schöpft — so sagt es ihre eigene Folgepflicht 3 und 4) · Maintainability
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:556–563` (der Absatz
  *„Zwei weitere Stellen desselben Plans sind davon nicht betroffen"*)
- `befund`: Der Absatz stellt fest, `slice-190` §3 (*„ein Carveout-Ordner und damit gedeckt"*)
  **und** §1 (*„unstrittig"*) beantworteten beide die **Change-Request-Frage** und blieben deshalb
  richtig. Für §3 trifft das zu. Für §1 nicht: Das Wort steht dort auf der **Anlege-Achse**, und
  das ist an drei Stellen des Plans messbar. (i) §1 nennt die Change-Request-Frage **kein einziges
  Mal** — sie kommt im ganzen Plan erst in §3 vor, und §3 sagt über sie ausdrücklich, sie sei
  *„hier nicht entschieden"*; eine frühere Sektion kann sie also nicht beantwortet haben.
  (ii) **DoD (1)** knüpft das Wort direkt ans Anlegen: *„Der Bootstrap legt die zwei unstrittigen
  Orte an."* (iii) Entscheidend: `harness/conventions` ist **eine** der zwei von §1 als
  *„unstrittig"* geführten — und für genau diesen Ort hält §6 die Change-Request-Frage **offen**.
  Auf der CR-Achse unterscheiden sich die zwei also; §1 nennt sie gleich. Damit trägt §1 eine
  Prämisse, die Festlegung 4 aufhebt, und die Datei erklärt sie für unberührt. Denselben Weg geht
  ein zweiter Satz derselben Sektion, den der Absatz gar nicht erwähnt: §1 sagt, nach DoD (1)
  und (2) blieben *„drei Fundstellen stehen, alle aus dem Register-Konflikt"* — eine Zusage, die
  ohne den ausgeschlossenen Ort nicht hält.
- **Failure-Szenario:** Folgepflicht 4 schickt den Planner mit genau einer benannten Kollision los
  — **DoD (1)**. Er liest im selben Absatz, §1 bleibe richtig, lässt dessen Prämisse und die
  Drei-Fundstellen-Zusage stehen und zieht `slice-190` nach `next/`. Der Plan trägt dann in §1 eine
  Aussage, die einer `Accepted`-ADR widerspricht, und die ADR-Seite ist nach
  [`AGENTS.md`](../../AGENTS.md) §3.4 gesperrt: Die Korrektur ist eine Folge-ADR mit `Supersedes`,
  heute ist sie ein Satz. Der Preis fällt dort an, wo diese ADR ihren Wert hat — `slice-190` §4
  macht die beantwortete Change-Request-Frage zur Bedingung für `open → next`.
- **Was dieser Befund nicht bestreitet:** die **Entscheidung**, `docs/plan/carveouts/done/`
  draußen zu lassen; sie trägt (siehe Negativbefunde, M-1(a) der Vorrunde). Bestritten ist die
  **Reichweiten-Angabe** der Kollision, die die Datei daneben stellt. Und ausdrücklich bestätigt
  ist die Hälfte, in der die Datei meiner Vorrunde widerspricht: §3 beantwortet die
  Change-Request-Frage, nicht die Anlege-Frage — Runde 3 hat §3 als Anlege-Prämisse gelesen, und
  das war zu weit.
- `verifizierbar`: **nein** — kein Gate hält einen ADR-Satz gegen den Inhalt einer Plandatei.
  Reproduzierbar:
  ```sh
  P='docs/plan/planning/*/slice-190-*.md'
  A=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  sed -n '/^## 1\. Ziel/,/^## 2\./p' $P | grep -c 'Change Request\|Change-Request'   # 0
  sed -n '/^## 1\. Ziel/,/^## 2\./p' $P | grep -c 'Nur die ersten zwei sind unstrittig'   # 1
  sed -n '/^## 1\. Ziel/,/^## 2\./p' $P | grep -c 'Fundstellen stehen, alle aus dem'      # 1
  sed -n '/^## 2\. Definition of Done/,/^## 3\./p' $P \
    | grep -c 'legt die zwei unstrittigen Orte an'                                        # 1
  sed -n '/^## 3\./,/^## 4\./p' $P | grep -c 'ist \*\*hier nicht entschieden\*\*'         # 1
  sed -n '/^## 6\./,/^## 7\./p' $P | grep -c 'Ob `harness/conventions` unter'             # 1
  grep -c 'Beide Sätze beantworten die \*\*Change-Request-Frage\*\*' "$A"                 # 1
  grep -c 'Zwei weitere Stellen desselben Plans sind davon nicht betroffen' "$A"          # 1
  ```
  **Keine Erwartungswerte**; der Glob statt der Pfad-Adresse nach
  [`AGENTS.md`](../../AGENTS.md) §3.11.
- `klasse`: *Aussage über den Stand eines fremden Artefakts ohne Messung an ihm*

### L-1 — Die zwei neuen Kollisions-Regeln teilen ihr Prädikat; getrennt werden sie allein durch ein Adjektiv, das die Glosse der dritten Form wieder aufhebt

- `kategorie`: LOW
- `quelle`: Maintainability ·
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (Rang 1 nennt
  die Lifecycle-Ordner ausdrücklich)
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:284–286` (Form 2) gegen
  `:307–311` (die zwei Kollisions-Regeln)
- `befund`: Form 2 disqualifiziert eine Nennung als *„Ziel eines Vorgangs, der ein Ereignis
  voraussetzt"* und glossiert das mit *„Ein Text, der sagt, **wodurch** ein Ort entsteht, sagt
  damit, dass er vorher nicht da ist."* Kollisions-Regel 1 sagt, eine Nennung nach 1–3
  *„entkräftet nichts"*. Kollisions-Regel 2 sagt, *„ein mitemittierter Text, der sagt, der Ort
  entstehe erst durch ein Ereignis"* entkräfte *„jede Nennung, die man sonst als unbedingt läse"*.
  Beide Regeln beschreiben damit denselben Text-Typ und weisen ihm entgegengesetzte Wirkung zu;
  getrennt sind sie nur durch das Wort *„ausdrücklich"* in Regel 2 — das die Glosse von Form 2 mit
  *„sagt damit"* gerade überbrückt. Der Fall ist nicht konstruiert: `docs/plan/planning/done/`
  trägt in der Verzeichniskonvention eine **eigene, zusatzfreie Zeile** (Regel 1: (a) erfüllt) und
  wird in der emittierten `slice.template.md` als Ziel eines `git mv` geführt (Form 2 — und unter
  ihrer Glosse zugleich Regel 2: (a) nicht erfüllt). Der Bootstrap legt den Ort heute an, und
  Rang 1 nennt die Lifecycle-Ordner namentlich.
- **Failure-Szenario:** Ein späterer Lauf misst einen neuen Ort nach dem dann eingefrorenen
  Kriterium. Der Ort steht unbedingt im Regelwerks-Baum und wird in einer mitemittierten Vorlage
  als Ziel eines Umzugs genannt. Regel 1 liefert *(a) erfüllt*, Regel 2 unter der Form-2-Glosse
  *(a) nicht erfüllt*. Das Kriterium beantwortet die Frage, die Konsequenz 2 ihm zuschreibt
  (*„ohne eigene Runde"*), dann zweimal verschieden — und die Auflösung ist eine Folge-ADR.
- **Warum das nicht blockiert:** Die enge Lesart ist verfügbar und die Datei wendet durchweg sie
  an — Regel 2 wird nur auf eine **Existenz**-Aussage angewandt (*„done/ entsteht erst bei erster
  Carveout-Auflösung"*), nie auf eine Ziel-Nennung. Der Ausschluss von
  `docs/plan/carveouts/done/` steht ohne Regel 2 schon auf Form 3 und Form 2; Regel 2 tritt dort
  ausdrücklich nur *„dazu"*.
- `verifizierbar`: **nein**. Reproduzierbar:
  ```sh
  A=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  grep -c 'Ein Text, der sagt, \*\*wodurch\*\* ein Ort entsteht' "$A"                    # 1
  grep -c 'der Ort entstehe erst durch ein Ereignis' "$A"                                # 1
  grep -c '^docs/plan/planning/done/' \
    .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md                     # 1
  grep -c 'wechselt nur durch `git mv`' \
    .harness/baseline/v6.0.0/templates/docs/plan/planning/slice.template.md              # 1
  sed -n '/^func structureGitkeeps/,/^}/p' internal/emit/templates.go \
    | grep -c '"docs/plan/planning/done"'                                                # 1
  ```
  **Keine Erwartungswerte.**
- `klasse`: *Zwei Regeln desselben Kriteriums weisen demselben Prädikat entgegengesetzte Wirkung zu*

### INFO-1 — Der tragende Satz der Träger-Einordnung nennt seinen Bezug *„diese Festlegung"*, und der Antezedent ist zweideutig

- `kategorie`: INFO
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:415`
- `befund`: *„`docs/plan/planning/observations/` ist nach dieser Festlegung **keines**"* folgt auf
  ein Zitat aus [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3);
  gemeint ist der zitierte Rang-1-Satz. Die Datei nummeriert ihre eigenen vier Festlegungen
  durchgehend, und der Satz steht im Rumpf von Festlegung 2 — wer *„diese Festlegung"* als
  Festlegung 2 liest, bekommt einen Zirkel (Festlegung 2 gibt dem Ort eine `README.md`, deshalb
  ist er nicht leer, deshalb greift der `.gitkeep`-Satz nicht). Die Begründung selbst ist **nicht**
  zirkulär — sie hängt an der Ablage-Form, die das mitemittierte Regelwerk vorschreibt, nicht an
  Festlegung 2 —, aber der Zeiger lädt zur zirkulären Lesart ein, und zwar an der Stelle, die die
  M-3-Nacharbeit trägt.
- `verifizierbar`: nein.
  ```sh
  grep -c 'ist nach dieser Festlegung \*\*keines\*\*' \
    docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md   # 1
  ```
- `klasse`: *Zweideutiger Antezedent an einer tragenden Stelle*

### INFO-2 — Die Gegen-Lesart-Hälfte der Träger-Einordnung misst den Text der Anforderung, nicht ihre Befolgung

- `kategorie`: INFO
- `pfad`: `docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md:425–431`
- `befund`: Die Robustheits-Zusage lautet: Wer den `.gitkeep`-Satz als Vorgabe für **jedes**
  Struktur-Verzeichnis liest, *„findet trotzdem keine geänderte Anforderung, keine zurückgenommene
  Zusage des Lastenhefts und keinen berührten Out-of-Scope-Punkt"*. Die ersten zwei Prüfungen
  fragen nach dem **Text** von Rang 1 — der bleibt unverändert —, während unter genau dieser
  Gegen-Lesart die Frage die **Befolgung** wäre: Der Satz schriebe dann einen Träger vor, und die
  Entscheidung wählt einen anderen. Die Hälfte trägt das Verdikt nicht: Die Haupt-Lesart steht
  im Wortlaut (*„**Leere** Struktur-Verzeichnisse … werden mit `.gitkeep` gehalten"*, gemessen im
  Belegblock der Datei), und ein Ort mit einer vom Regelwerk verlangten Datei ist keines. Nur die
  Fallback-Begründung beantwortet eine andere Frage als die, die sie stellt.
- `verifizierbar`: nein.
  ```sh
  grep -c 'findet trotzdem keine geänderte Anforderung' \
    docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md   # 1
  ```
- `klasse`: *Fallback-Begründung prüft eine andere Frage als die, die ihre Lesart stellt*

---

## Negativbefunde (geprüft, ohne Befund)

**Alle 39 abgedruckten Kommandos der ADR in diesem Lauf nachgefahren — jedes liefert den
abgedruckten Wert.** Die Datei trägt **18** ` ```sh `-Zäune (auch eingerückte) mit zusammen **36**
Kommandos, dazu **drei** inline (Festlegung 3 und die zwei Geschichte-Zeilen, die eine Zahl
tragen). Die zwei Zahlen sind gemessen, nicht gezählt:

```sh
A=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
grep -cE '^[[:space:]]*```sh$' "$A"                                                       # 18
awk '/^[[:space:]]*```sh$/{inb=1;cont=0;next} /^[[:space:]]*```$/{inb=0;next}
     inb{ l=$0; sub(/^[[:space:]]+/,"",l); if(l==""||l ~ /^#/) next;
          if(cont==0) n++; cont = (l ~ /\\$/) }
     END{print n}' "$A"                                                                   # 36
```

**Keine Erwartungswerte.** Gefahren wurde blockweise über eine `awk`-Extraktion der Zäune, danach
`bash`. Ergebnisse in der Reihenfolge der Datei: `1` · `1` · `1` · `1` · `3` · `2` · `3` · `2` ·
die vierzeilige Klammer-Ausgabe · die einzeilige Lifecycle-Klammer · `4` · `3` ·
`| 0.8.0 | 2026-07-21` · `2026-09-03` · `0` · `1` · `0` (Form 3, neu) · `0` · `3` · `1` · `1` ·
`1` · `0` · die einzeilige `.gitkeep`-Satz-Ausgabe (neu) · `2` · `1` · die zweizeilige
Link-Ausgabe der zwei Index-Vorlagen · `1` · `1` · `0` · `1` · `1` · `1` · `1` (die fünf
`done/`-Belege, drei davon neu) · `1` · `1` (der `slice-190`-Block, neu) · **2** Zeilen
`git log --follow` · **2** (Register-Zähler) · **6** (Risiken ohne Ausgang, Geschichte-Zeile 1).
**Keine Abweichung.** Damit ist auch die Meldung des Architect-Laufs, alle abgedruckten
Kommandos seien ohne Abweicher gefahren worden, unabhängig
bestätigt.

**Die drei blockierenden Befunde der Vorrunde, einzeln am Ist-Stand nachgeprüft:**

- **M-1 (Runde 3) auf zwei von drei Achsen behoben — die dritte ist M-1 dieser Runde.**
  - **(a) Der gewählte Ausgang trägt, und er ist nicht nachträglich passend gemacht.** Die
    Tag-0-Verneinung steht im **vendored Fremdtext** — Baseline `v6.0.0`,
    `templates/docs/plan/carveouts/carveout.template.md` §Verifikation (nach Auflösung), an einer
    eigenen Zeile: *„done/ entsteht erst bei erster Carveout-Auflösung"*. Sie prädiziert die
    **Existenz** des Ortes, nicht das Ziel einer Bewegung, und ist damit von den Ziel-Nennungen
    unterschieden. Sie ist **älter als die ADR und stammt nicht von ihr**: `slice-190` §6 zitiert
    denselben Satz als Grund seines eigenen Risikos, geschrieben vor dieser Entscheidung. Die
    zwei behaupteten Überlebenswege sind je gegen die Quelle gehalten: die Vorlage ist
    *wiederkehrend* und liegt im Ziel unverändert im vendored Baum
    ([ADR-0005](../plan/adr/0005-ziel-repo-distribution.md), Rang-1-Satz in
    [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)), und der
    Template-Abbau nimmt die `d-check:ignore`-Marker ausdrücklich aus — Baseline `v6.0.0`,
    `grundlagen-harness-dateien.md` §Template-Schichtung, im Rumpf, verbatim geprüft.
  - **(b) Die Übergabe ist sauber und schreibt nichts Fremdes um.** Festlegung 4 nennt die
    Kollision im Klartext (*„der DoD-Punkt ist in seiner heutigen Fassung mit ihr nicht
    erfüllbar"*), Folgepflicht 4 nennt die Rolle und sagt ausdrücklich, sie schlage keinen Wortlaut
    vor; die offene Frage zur Messzahl in **DoD (3)** ist benannt statt entschieden. **Der Commit
    berührt genau eine Datei** (`git show --pretty=format: --name-only 3a90ceb` → die ADR), also
    kein Planner-Artefakt — [`AGENTS.md`](../../AGENTS.md) §3.10 gewahrt. Dass §6 die Wahl dem
    *Slice* zuwies und die ADR sie ihm nimmt, ist kein Übergriff: Der Fall ist ein Konflikt mit
    einer Baseline-Aussage und damit eine Norm-Frage (§3.8); die Datei sagt, welchen der zwei Wege
    sie schließt.
  - **(c) Der Architect hat zur Hälfte recht, und die Hälfte gehört ausgesprochen.** §3 des Plans
    beantwortet die Change-Request-Frage — der Satz steht im Absatz *„Die Change-Request-Frage
    steht vor dem Code"* und mündet in *„ist hier nicht entschieden"*. Runde 3 hat ihn als
    Anlege-Prämisse gelesen; das war zu weit, und dieser Report korrigiert seine Vorrunde an
    dieser Stelle. Für §1 gilt es nicht — das ist M-1.
- **M-2 (Runde 3) behoben; die benannte Lücke ist geschlossen, nicht versetzt.** Die
  Auswertungs-Regel trägt jetzt drei Formen und zwei Kollisions-Regeln. **Form 3 ist real messbar
  und nimmt dem Befund seine Prämisse:** In der Verzeichniskonvention ist `harness/conventions/`
  der Eintrag und *„done/ = aufgelöst"* die Glosse rechts des `#`; eine eigene Baumzeile hat
  weder `harness/conventions/done/` noch `docs/plan/carveouts/done/`
  (`… | grep -cE '^harness/conventions/done/|^docs/plan/carveouts/done/'` → **0**, in diesem Lauf
  gefahren). Damit ist die *unbedingte Nennung*, an der Runde 3 hing, gar keine. **Kollisions-Regel
  1 schließt die genannte Richtung** — *eine bedingte Nennung entkräftet keine unbedingte* — und
  sie ist die Richtung, die fehlte. **Gegenprobe auf Selbst-Widerlegung gefahren:** Kein
  mitemittierter Text trägt eine Tag-0-Verneinung für den Hauptfall `observations/` — die drei
  emittierten Anweisungssätze nennen den Ort ohne Zusatz
  (`grep -rn 'observations' internal/emit/templates/commands/*.md`, drei Treffer), und der
  vendored Planning-Index führt ihn unbedingt im Indikativ (*„Neben den Lifecycle-Verzeichnissen
  liegt flach in `planning/` das Beobachtungs-Register (`observations/`)"*). Was von M-2 bleibt,
  ist nicht die alte Lücke, sondern die Überlappung der zwei neuen Regeln — L-1, und die ist
  kleiner.
- **M-3 (Runde 3) behoben; die Einordnung trägt gegen den Wortlaut.** Beide *„weicht ab"*-Sätze
  sind weg (`grep -c 'weicht davon für \*\*einen\*\* benannten Ort ab' …` → **0**,
  `grep -c 'Abweichung davon — wie sie Festlegung 2' …` → **0**). Die Einordnung steht jetzt für
  **beide** Gegenstände — Aufnahme (Festlegung 1) und Träger (Festlegung 2) —, im Rumpf und im
  `Bezug`-Kopf. **Sie trägt im Wortlaut:** Das Subjekt des Rang-1-Satzes ist *„**Leere**
  Struktur-Verzeichnisse"*, das Adjektiv ist restriktiv, und ein Ort, den das mitemittierte
  Regelwerk mit einer `README.md` als Bestandteil der Ablage führt, ist keines — dieselbe Form,
  die [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 1 für den Dogfood vorschreibt. Die Begründung ist nicht zirkulär; sie hängt an der
  Ablage-Form der Quelle, nicht an der Wahl der ADR. Was daneben schwächer ist, steht als INFO-1
  und INFO-2 und trägt das Verdikt nicht.

**Die übrigen Posten der Vorrunde, je am Ist-Stand geprüft:**

- **L-1 (Runde 3) behoben.** Beide gekürzten Zitate tragen jetzt die Auslassungsmarke, in diesem
  Lauf gegen die Quelle gehalten; der Sinn ist unverändert.

  ```sh
  A=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  grep -c 'anlegen …' "$A"              # 1
  grep -c 'carveouts/done/` …' "$A"     # 1
  ```
- **INFO-2 (Runde 3) mitgezogen und korrekt beschrieben.** Die Kommentar-Lage des zweiten
  Carveout-Belegs steht in der Datei, samt dem Grund, warum er trotzdem zählt. **Kein HIGH nach
  der Klasse *Norm nur im Template-Kommentar*:** Die Vorlage ist wiederkehrend, sie wird nicht
  gestempelt, und der Template-Abbau nimmt genau diese Marker aus — beides in diesem Lauf gegen
  die Baseline gehalten.
- **INFO-1 (Runde 3) nicht behoben — die Begründung trägt, gegen die Quelle geprüft.**
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 definiert *verbatim*
  als *„der Wortlaut ohne Auszeichnung, Whitespace normalisiert. Nicht die Quell-Bytes."* und
  bindet damit die **Treue** des Zitats, nicht die Auszeichnung im zitierenden Text; eine
  Asymmetrie in den Code-Spans verletzt keine bindende Quelle. Die substanzielle Hälfte — ein
  grünes Gate sagt über den **emittierten** Stand nichts — steht als *nicht gebaut* in der
  Fitness-Function-Tabelle. Der Ist-Stand ist unverändert — der Pfad steht dreimal als Klartext
  und nie als Code-Span. Das ist die in Runde 2 einmal falsch gefallene Sorte Entscheidung; hier
  fällt sie richtig.

  ```sh
  A=docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md
  grep -c '`docs/plan/planning/reconciliation.md`' "$A"   # 0
  grep -c 'docs/plan/planning/reconciliation.md' "$A"     # 3
  ```

**Sonstiges, geprüft ohne Befund:**

- **Gegen die Entscheidung selbst steht in vier Läufen kein Befund.** Die zwei Kern-Argumentationen
  ([ADR-0007](../plan/adr/0007-bootstrap-phasen.md) beantwortet *wie*, nicht *ob*;
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 1 schreibt die `README.md` als Bestandteil der Ablage vor) sind unverändert; der
  emittierte Selbstwiderspruch ist in diesem Lauf erneut gemessen (`3` Anweisungssätze, `2` davon
  namentlich, `3` Go-Fundstellen, keine schreibend).
- **[`AGENTS.md`](../../AGENTS.md) §3.8 — Commit-Zuschnitt korrekt.**
  `git show --pretty=format: --name-only 3a90ceb` gibt **eine** Datei, die ADR; die Message nennt
  die Rolle im Präfix. Der ADR-Index braucht keinen Nachzug — Titel, Status und die Reihenfolge
  der Bezugs-IDs sind unverändert, und die Index-Zeile führt keine der Parenthesen, die der Kopf
  ergänzt hat (in diesem Lauf gegen `docs/plan/adr/README.md:44` gehalten).
- **§3.4 nicht verletzt.** Die Datei steht auf `Proposed`; Überarbeitungen sind in diesem Fenster
  zulässig, und [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 verlangt
  die Beleg-Korrektur ausdrücklich hier. Die Zitate der alten Fassungen in den Geschichte-Zeilen
  sind als solche gekennzeichnet.
- **§3.11 gewahrt.** Kein Pfad in den Planning-Lifecycle:
  `grep -coE 'docs/plan/planning/(open|next|in-progress|done)/'` über der Datei → **0**; die Links
  in den Planning-Baum zeigen auf `observations/…`, nach
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  Festlegung 5 ortsfest. Der Slice wird über den Glob adressiert.
- **§3.5 — keine Gate-Lockerung**, kein Schwellwert, kein `ignore`-Eintrag, keine
  Modul-Abschaltung berührt; die Datei trägt **null** HTML-Kommentare und damit auch keinen
  `d-check:ignore`-Marker (`grep -c '<!--' …` → **0**; die sechs `d-check:ignore`-Treffer stehen
  sämtlich in Zitaten und Kommandos).
- **[`ADR-0016`](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a) — die
  Vorbedingung des Accept-Übergangs steht weiter erfüllt.** Die vier in dieser Runde neu oder
  geändert hinzugekommenen Baseline-Belege tragen je Tag, Datei, Abschnitt und Zitat; alle
  Abschnittsnamen existieren wörtlich (`### Verzeichniskonvention`,
  `### Template-Schichtung — …`, `## Adaptions-Block`, `## Slices vs. Wellen — …`,
  `## Verifikation (nach Auflösung)`), und beide zitierten Vorlagen-Sätze liegen im **Rumpf**
  außerhalb jedes Kommentarblocks — der eine Beleg in der Kommentar-Schicht ist als solcher
  benannt.
- **[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  und [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  gewahrt.** Jede Messwert-Zahl steht neben ihrem Kommando und ist als kein Erwartungswert
  gekennzeichnet — auch die vier in dieser Runde neuen (`1`/`0` an Form 3, `0` und `1` im
  `done/`-Belegblock, `1`/`1` am `slice-190`-Block). Jede Baseline-Aussage nennt den Tag `v6.0.0`.
  Der Register-Zähler ist datiert und trägt sein Ableitungs-Kommando; nachgefahren → **2**.
- **[`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) — kein Adaptions-Eintrag
  fällig.** Keine der vier Festlegungen weicht von einer **Baseline**-Regel ab; die Entscheidung
  stellt Baseline-Konformität her.
- **[`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  gewahrt.** `LH-FA-02` steht **21**× in der Datei, davon **15**× als Link; die übrigen sind
  Kommando-/Zitat-Zeilen in Codeblöcken und die `# `-Überschrift. `make docs-check` ist mit
  `ids: link-policy: always` grün.
- **[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — kein
  halluziniertes Gate.** `TestTemplates_EmittierterBestandVollstaendig` existiert, `make full-smoke`
  existiert und ist als Nicht-Gate ausgewiesen; die zwei nicht gebauten Deckungen sind benannt
  statt behauptet.
- **Ziel-Form vollständig.** Gegen
  [`NNNN-titel.template.md`](../../.harness/baseline/v6.0.0/templates/docs/plan/adr/NNNN-titel.template.md)
  geprüft: Status · Datum · Autor · Bezug · Schärft · Regeln · Kontext · Entscheidung ·
  Verglichene Alternativen (fünf Optionen, *nichts tun* dabei) · Konsequenzen · Fitness Function ·
  Re-Evaluierungs-Trigger (**sechs**, und **alle sechs** tragen eine Ablesestelle:
  `… | grep -c 'ablesbar)\*'` → **6**) · Geschichte · Immutabilitäts-Schluss.
- **Docker-only (§3.9).** Kein Host-Paketmanager, keine Host-Toolchain in diesem Lauf; alles über
  `make`, `git`, `grep`, `sed`, `awk`, `ls`, `find`, `bash`.
- **Nicht geprüft (fremde Rolle):** DoD-Abhakung und Plan-vs-Code-Konformität — Verifikation,
  getrennter Kontext, anderes Prüf-Artefakt. Ebenso **nicht** Gegenstand: die parallel laufende
  Planner-Arbeit an `slice-125` und den `open/`-Plänen.

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** *Aussage über den Stand eines fremden Artefakts ohne Messung an
ihm* · *Zwei Regeln desselben Kriteriums weisen demselben Prädikat entgegengesetzte Wirkung zu* ·
*Zweideutiger Antezedent an einer tragenden Stelle* · *Fallback-Begründung prüft eine andere Frage
als die, die ihre Lesart stellt*

**Das Muster ist diesmal geschlossen, und das ist die Antwort auf die ausdrücklich gestellte
Frage.** *„Das Kriterium verspricht eine Reichweite, die sein geschriebener Text nicht hat"* lief
über drei Runden sechsmal: Runde 1 an der Träger-Frage und am zweiten `done/`-Ort, Runde 2 an der
fehlenden Auswertungs-Regel, Runde 3 an der zu engen. **In dieser Runde findet sich keine Instanz
mehr.** Die Regel steht geschrieben, ihre dritte Form ist **messbar** statt auslegbar, sie deckt
beide Anwendungsfälle aus eigenem Text, und die Gegenprobe — trägt sie ihren eigenen Hauptfall? —
ist gefahren und positiv. L-1 ist **nicht** dieselbe Klasse: Dort fehlt keine Reichweite, dort
überlappen zwei geschriebene Regeln. Das ist eine andere Bauart und ein kleinerer Posten.

**Was sich gegenüber Runde 3 verschoben hat.** Drei blockierende MEDIUM sind auf **eines** gefallen
und die Gesamtzahl der Findings von sechs auf vier. Zwei der drei MEDIUM sind vollständig behoben,
das dritte auf zwei von drei Achsen — geblieben ist eine **Teil**-Aussage innerhalb der Nacharbeit
zu M-1, kein neuer Gegenstand. Zum ersten Mal in vier Runden korrigiert der Report **seine eigene
Vorrunde**: §3 des Plans beantwortet die Change-Request-Frage, und Runde 3 hat ihn zu weit gelesen.
Die Zahl der Befunde gegen die Entscheidung selbst bleibt **null**.

---

## Verdikt

**Konsistenz NICHT BESTÄTIGT — ein blockierendes MEDIUM, kein HIGH.**

**Was trägt, und es ist fast alles.** Alle **39** abgedruckten Kommandos reproduzieren ohne
Abweichung. Die Auswertungs-Regel zu (a) ist keine Zusage mehr, sondern Text: drei
Disqualifikations-Formen, davon eine **maschinell messbar**, zwei Kollisions-Regeln, und beide
`done/`-Ausschlüsse aus ihr hergeleitet statt neben sie gestellt. Die Gegenprobe, an der ein
selbstwiderlegendes Kriterium gescheitert wäre — trägt (a) den eigenen Hauptfall
`observations/`? —, ist in diesem Lauf gefahren: kein mitemittierter Text verneint ihn, der
vendored Planning-Index führt ihn unbedingt im Indikativ. Die Träger-Einordnung hält am
Rang-1-**Wortlaut**: *„Leere"* ist restriktiv, und der Register-Ort ist keines. Der in Runde 3
gewählte Ausgang für `docs/plan/carveouts/done/` trägt, seine Quelle ist vendored Fremdtext und
älter als diese Entscheidung, und die Übergabe an den Planner ist als Folgepflicht benannt, ohne
dass ein Planner-Artefakt angefasst wurde. Gegen die **Entscheidung** steht in vier Läufen kein
einziger Befund.

**Was blockiert, ist ein Satz und liegt im Text der ADR.** Der Absatz, der die Reichweite der
Kollision zieht, erklärt zwei Stellen des bedienten Plans für unberührt. Für §3 stimmt das. Für §1
nicht: Dort steht *„unstrittig"* auf der Anlege-Achse — §1 nennt die Change-Request-Frage kein
einziges Mal, §3 sagt über sie *„hier nicht entschieden"*, **DoD (1)** knüpft das Wort ans
Anlegen, und `harness/conventions` ist eine der zwei *„unstrittigen"*, für die §6 die CR-Frage
gerade **offen** hält. Ein zweiter Satz derselben Sektion — *„drei Fundstellen … alle aus dem
Register-Konflikt"* — fällt mit und wird nicht erwähnt.

**Warum das vor der Annahme zählt und nicht danach.** Es ist ein Satz, keine Entscheidung. Ab
`Accepted` sperrt [`AGENTS.md`](../../AGENTS.md) §3.4 ihn, und der Preis steigt von einer Zeile auf
eine Folge-ADR mit `Supersedes` — dieselbe Kosten-Asymmetrie, mit der
[ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a) ihren
Accept-Übergang begründet. Hinzu kommt die Richtung des Fehlers: Er sagt dem Planner, **weniger**
sei betroffen, als betroffen ist, und die Gegenseite — der Plan — ist ein Artefakt, das nach
[`AGENTS.md`](../../AGENTS.md) §3.10 eine andere Rolle schreibt. Wer eine zu enge
Kollisions-Angabe einfriert, zwingt den Planner, gegen eine unveränderliche ADR nachzuziehen,
statt ein zutreffendes Übergabe-Artefakt zu bekommen.

**Der Baseline-Trigger feuert mit diesem Verdikt nicht.** *„ADR-Review-Runde abgeschlossen →
bindend"* (Baseline `v6.0.0`, `grundlagen-bootstrap.md` §Vier Trigger-Klassen, Zeile der
Acceptance-Trigger-Klasse,
`grep -c 'ADR-Review-Runde abgeschlossen → bindend' .harness/baseline/v6.0.0/regelwerk/grundlagen-bootstrap.md`
→ **1**, kein Erwartungswert) setzt eine abgeschlossene Runde voraus; diese Runde schließt mit
einem blockierenden Befund. **Der eine Posten, der ihn hält, ist M-1**, und er liegt **im Text der
ADR** — nicht in einem fremden Artefakt: Zu ändern ist die Reichweiten-Angabe des Absatzes, nicht
`slice-190`. **L-1, INFO-1 und INFO-2 halten ihn nicht**; sie sind hier ausdrücklich als nicht
blockierend ausgewiesen, damit ein Folgelauf sie nicht als Rest-Blockade liest. **`slice-190` kann
`open → next` damit weiterhin nicht** — nicht, weil die Change-Request-Frage aus §3 unbeantwortet
wäre (Festlegung 1 beantwortet sie und die Antwort ist geprüft), sondern weil sie noch nicht
bindend ist.

**Über den `Accepted`-Übergang entscheidet dieser Report nicht** — das ist Architect-Arbeit
([`AGENTS.md`](../../AGENTS.md) §3.8). Er stellt fest: **der Übergang ist heute nicht möglich, und
er ist es nach einem Satz.**

**Übergabe.** Die Findings gehen an den **Architect** — er hält die ADR
([`AGENTS.md`](../../AGENTS.md) §3.8), und dieser Report hat kein Artefakt außer sich selbst
angefasst. **M-1 trägt keine eigene Kante an den Planner:** Die Folgerung aus der Kollision für
Schnitt und Abnahmekriterien von `slice-190` ist bereits als Folgepflicht 4 verdrahtet und bleibt
Planner-Arbeit ([`AGENTS.md`](../../AGENTS.md) §3.10); dieser Report schreibt sie nicht und
schlägt sie nicht vor. Die Finding-Klassen gehen in die Slice-Closure §7 und von dort in den
Zähler; die Zuordnung zu einer `BEO-ALL/<slug>` fällt beim Schreiben der Closure, nicht hier
([`docs/plan/planning/observations/README.md`](../plan/planning/observations/README.md)).

Dieser Report ist ein **Lauf-Beleg** und ersetzt keine Verifikation — DoD-/Spec-Konformität prüft
der Verifier separat (Modul 11, anderes Prüf-Artefakt, anderer Eingabe-Kontext).
