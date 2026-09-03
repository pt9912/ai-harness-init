# Slice slice-144: Der Lifecycle-Move zieht seine Verweise nach — und ob das Werkzeug übernommen wird, ist die Frage des Slice

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — der Schnitt-Test aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, alle drei Fragen beantwortet. **Bündel?** Nein — die Aussage *„der Lifecycle-Wechsel
zieht seine Verweise selbst nach"* ist mit diesem einen Slice wahr. **Gemeinsames
Closure-Kriterium?** Nein — eine Welle darum herum schriebe die DoD unten ab. **Auslöser reaktiv
oder gewollt?** **Reaktiv**: ein wiederholt bezahlter Handgriff, gezählt in §1 und als `BEO-003`
im Beobachtungs-Register geführt. Das Ergebnis ist ein Werkzeug, aber der **Auslöser** ist kein
Fähigkeits-Wunsch — und
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
fragt nach dem Auslöser, nicht nach dem Artefakt. Nach Setzung 2 erscheint wellenlose Arbeit
**nicht** in der Roadmap; ihr Zustand ist allein die Verzeichnis-Position.

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist der Planungs-Betrieb **dieses** Repos. Ob ein
frisch gebootstrapptes Zielrepo ein solches Werkzeug bekommt, ist ein anderer Vertrag mit eigenen
Trägern; dieser Slice entscheidet darüber nichts.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(das Ziel ist **kein** Gate und gehört nicht in `gates` — es bewegt, es prüft nicht),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(ein Shell-Skript neben `git` und GNU `make`, keine neue Abhängigkeit),
[`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)
(der Ort ausführbarer Harness-Tools),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(der Schnitt-Test oben),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl in diesem Plan steht neben dem Kommando, das genau sie ausgibt),
[`AGENTS.md`](../../../../AGENTS.md) §3.3 (der Move, dessen Folgen dieser Slice trägt),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel — für ein
Werkzeug heißt das: der **nicht** nachgezogene Move muss rot werden),
[`AGENTS.md`](../../../../AGENTS.md) §3.9 (Docker-only: das Ziel fährt `bash`, keine Host-Toolchain).

**Berührte Spec-Stellen:** — Dieser Slice berührt keine. Ein Planungs-Werkzeug steht in keinem der
drei Spec-Straten; was das Produkt kann, ändert sich nicht. Der Verweis zeigt ohnehin **aufwärts**:
die Spec nennt diesen Slice nie (Baseline-Regelwerk `grundlagen-referenz-richtung.md`
§Referenz-Richtung (SDP), `grundlagen-source-precedence.md` §ID-Schema als Klammer).

**Verantwortlich:** Implementer (pt9912). Die Rolle steht hier nicht, weil der Gegenstand nach ihr
aussieht, sondern weil das Feld sie nennt: Baseline-Regelwerk `modul-05-planning-harness.md`
§Lifecycle als State Machine setzt es beim Übergang `open → next` auf *„den Rolleninhaber der
Implementer-Rolle, der die Arbeit hält"* — es sagt *wer*, nicht *wo*, und trägt keinen Sensor. Dass
die Liefergegenstände (Skript, Make-Ziel, Selbsttest) in dieselbe Richtung zeigen, bestätigt die
Zuordnung; die Quelle ist sie nicht.

**Autor:** Planner. **Datum:** 2026-08-30.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Ein Lifecycle-Wechsel eines Slice bewegt die Datei und zieht die Verweise nach, die er bricht —
beide Richtungen, alle im Bestand vorkommenden Formen —, und ob das Werkzeug dafür übernommen oder
eigenständig gebaut wird, ist in diesem Slice entschieden statt vorausgesetzt.**

### Der Bedarf ist gemessen, nicht empfunden

Der Wechsel `open → next → in-progress → done` ist ein reiner `git mv`
([`AGENTS.md`](../../../../AGENTS.md) §3.3), und er bricht jeden Verweis auf die bewegte Datei.
Der Abgleich danach ist heute Handarbeit, und er hat einen eigenen Commit je Move:
`git log --format=%h --grep='Link-Abgleich nach dem Move' | wc -l` → **65**. Die Zahl wandert mit
dem Baum und ist kein Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Nicht die Menge ist das Problem, sondern die Formen — und die sind gemessen, nicht aufgezählt.**
Eine Adresse auf eine Slice-Datei tritt in den **lebenden** Artefakten dieses Repos in **13**
Präfix-Formen auf — vom nackten Verzeichnisnamen über ein bis zwei Aufstiege bis zum voll
qualifizierten Pfad ab Repo-Wurzel, jeweils mit und ohne die Zwischenstufe `plan`. Die Formen
stehen hier nicht als Liste, weil eine Liste von Adressen in diesem Plan selbst zu Adressen würde;
sie stehen als Ausgabe:

```sh
git grep -ohE '[^ ("]*(open|next|in-progress|done)/slice-[0-9]+' \
  -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
  | sed -E 's@(open|next|in-progress|done)/slice-[0-9]+@\1/@' \
  | grep -E '^(\.\./)*([a-z0-9.-]+/)*(open|next|in-progress|done)/$' | sort -u | wc -l
```

**Eine weitere Form hat gar kein Präfix und ist für dieses Kommando unsichtbar:** das Ziel **ohne
Verzeichnis-Segment**, der blanke Dateiname, den eine Datei trägt, solange ihr Ziel im selben
Verzeichnis liegt. Er steht **123**-mal in **33** Dateien der drei offenen Lifecycle-Verzeichnisse
— dasselbe Kommando einmal mit `-ohE`, einmal mit `-lE`:

```sh
git grep -ohE ']\((slice|welle)-[0-9][^)/]*\)' -- docs/plan/planning/open \
  docs/plan/planning/next docs/plan/planning/in-progress | wc -l
```

**Er bricht in beide Richtungen**, und das ist der Grund, warum eine Zählung der *eingehenden*
Verweise den Bedarf unterschätzt: er bricht, wenn sein Ziel wegzieht, **und** wenn die tragende
Datei selbst wegzieht. Die übrigen ausgehenden Adressen eines Slice überleben den Move dagegen:
`open/`, `next/`, `in-progress/` und `done/` liegen auf **derselben** Tiefe, ein `../../../../`
zeigt danach unverändert richtig. Für Welle-Plan-Dateien gilt das nicht — sie wechseln beim
Closure-Move die Tiefe (§6). Alle drei Zahlen wandern mit dem Baum und sind keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

### Der Ausgangspunkt ist fremd, die Entscheidung ist es nicht

Das Schwester-Repo **a-check** — demselben Auftraggeber gehörend, auf derselben Baseline `v5.12.0`
— führt das Werkzeug bereits: ein Skript slice-mv.sh und ein Make-Ziel gleichen Namens mit
`SLICE=` und `TO=`. Sein Kopf begründet, warum dort ein Werkzeug und kein Guide entstand, und
benennt zwei Grenzen ausdrücklich: es zieht **Pfade** nach und keine **Zustandssätze**, und
Welle-Plan-Dateien wechseln beim Closure-Move die Verzeichnis-**Tiefe** statt nur das Verzeichnis.

**Das ist ein Ausgangspunkt und keine Antwort.** Das fremde Skript ersetzt **zwei** Formen; dieses
Repo führt daneben mindestens zwei weitere (oben gemessen). Ein übernommenes Werkzeug, das nur die
zwei bekannten trifft, ist **schlechter als keines**: es meldet Erfolg und ersetzt die
Handprüfung, die den Rest heute noch fängt. Ob am Ende Übernahme, Übernahme-mit-Erweiterung oder
Eigenbau steht, entscheidet DoD (1) — gegen den gemessenen Bestand **dieses** Repos, nicht gegen
die Existenz des fremden Skripts.

### Warum ein Werkzeug und nicht eine schärfere Anweisung

Die Anweisung existiert bereits und wird befolgt: jeder Abgleich-Commit oben ist ein Fall, in dem
jemand daran gedacht hat. Was sie nicht leistet, ist **Vollständigkeit** — welche Formen es gibt,
steht in keinem dieser Commits gleich, und die Form ohne Verzeichnis-Segment taucht erst auf, wenn
man sie sucht. Eine Anweisung, die an derselben Familie schon mehrfach unvollständig geblieben
ist, wird durch Wiederholung nicht stärker.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **(1) Die Frage *übernehmen oder eigenständig bauen* ist entschieden, und die Entscheidung
      steht gegen den gemessenen Bedarf dieses Repos.** Ausgangspunkt ist das Werkzeug des
      Schwester-Repos a-check (ein Skript slice-mv.sh und ein Make-Ziel gleichen Namens, beide dem
      Auftraggeber gehörend, beide auf derselben Baseline). **Was übernommen wird, ist zu
      begründen, nicht vorauszusetzen:** das fremde Skript ersetzt **zwei** Adress-Formen; die
      Form-Menge dieses Repos liefert das Präfix-Kommando aus §1, und **eine** Form liegt
      grundsätzlich außerhalb von ihm (das Ziel ohne Verzeichnis-Segment, §1 zweites Kommando).
      Die Entscheidung nennt **je Form** der beiden Kommandos, ob das Ergebnis sie deckt — die
      Menge ist die Ausgabe dieser Kommandos zum Zeitpunkt der Ausführung, keine Liste in diesem
      Plan.
- [x] **(2) `make slice-mv SLICE=<slice-NNN> TO=<open|next|in-progress|done>` bewegt den Slice und
      zieht die Verweise nach — in beiden Richtungen.** **Eingehend:** die Verweise **auf** die
      Datei, in jeder Präfix-Form, die das erste Kommando aus §1 ausgibt. **Ausdrücklich außerhalb
      dieser Zusage bleibt die präfixlose Form von der eingehenden Seite:** ein Geschwister, das im
      Herkunftsverzeichnis bleibt und die bewegte Datei ohne jedes Verzeichnis-Segment referenziert,
      bricht durch den Move ebenso — die Ersetzungsregel der Eingehend-Richtung ankert an einem
      Verzeichnis-Literal, das diese Form nicht trägt, und sieht sie darum grundsätzlich nicht.
      Diese Grenze steht im Skriptkopf (`harness/tools/slice-mv.sh`, Grenze 3) und bleibt mit
      `BEO-003` im [Beobachtungs-Register](../observations.md) offen geführt — sie wird von diesem
      Slice nicht geschlossen. **Ausgehend:** die Ziele **in** der Datei, die kein
      Verzeichnis-Segment tragen und deshalb nach dem Wechsel ins falsche Verzeichnis zeigen — die
      Form, die das zweite Kommando aus §1 zählt und das erste per Konstruktion nicht sehen kann.
      Der Beleg ist **nicht** „es lief", sondern `make docs-check` **vor und nach** demselben Move,
      beide Ausgaben im Bericht — und dazu der Move einer Datei, die **beide** Richtungen trägt,
      weil ein Move ohne ausgehende Geschwister-Ziele die zweite Hälfte der Zusage nicht prüft. Ein
      Rückstand aus der ausgeschlossenen präfixlosen Eingehend-Form in der Nachher-Ausgabe ist kein
      Verstoß gegen diese Zusage; jeder andere Rückstand schon.
- [x] **(3) Der Skriptkopf nennt, was das Werkzeug *nicht* kann.** Zwei Grenzen sind schon bekannt
      und gehören hinein: es zieht **Pfade** nach und keine **Zustandssätze**, und
      Welle-Plan-Dateien wechseln beim Closure-Move die Verzeichnis-**Tiefe**. Jede weitere
      **gemessene** Grenze kommt dazu; eine vermutete nicht. Ein genannter Sensor muss existieren —
      `make comment-claims` prüft genau das.
- [x] `make gates` bringt **keinen Befund hervor, der diesem Slice zuzurechnen ist** —
      Vorher-Nachher-Vergleich derselben Ausgabe, nicht „grün". Dazu `make shell-lint` und
      `make comment-claims`, weil ein neues Skript beide sofort bindet.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist — hier keiner: ein
      Planungs-Werkzeug ändert nichts an dem, was das Produkt emittiert.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: das Repo hat keinen Brownfield-Bootstrap und führt keines; das Item
      entfällt mit diesem Grund, nicht still.
- [x] Beobachtungs-Register fortgeschrieben: `BEO-003` trägt den Stand dieses Slice — verkörpert,
      falls das Werkzeug steht; sonst mit dem Grund, warum nicht.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die nächste Welle-Closure — dieses
      Repo fährt Wellen-Betrieb, und die liest auch Slices ohne Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/slice-mv.sh` <!-- d-check:ignore (entsteht mit diesem Slice) --> | neu | ausführbares Harness-Tool; der Ort folgt [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption), nicht dem Baseline-Default |
| [`Makefile`](../../../../Makefile) | update | das Ziel `slice-mv` mit `SLICE=` und `TO=`; **kein** Gate und nicht in `gates` — es bewegt, es prüft nicht |
| [`harness/README.md`](../../../../harness/README.md) | update | dort stehen die Ziele außerhalb von `make gates`, samt dem, was jedes **nicht** prüft |
| [`.claude/commands/implement-slice.md`](../../../../.claude/commands/implement-slice.md) | update | Schritt 9 und Schritt 23 schicken heute zum blanken `git mv`; wenn das Werkzeug steht, ist der richtige Weg der kürzere |
| `test/slice-mv.bats` <!-- d-check:ignore (entsteht mit diesem Slice) --> | neu | der Selbsttest der Ersetzung, ohne ein Repo zu bewegen — sonst misst er sich selbst |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **das WIP-Limit ist frei**, also
`ls docs/plan/planning/in-progress/slice-*.md | wc -l` → **0**. Eine **fachliche** Vorbedingung hat
dieser Slice nicht: das Beobachtungs-Register, aus dem sein Auslöser stammt, steht bereits
([`observations.md`](../observations.md)).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Form-Menge aus DoD (2) erweist sich
  als größer als zwei Ersetzungs-Regeln, und der Selbsttest wächst zu einem eigenen Gegenstand.
  Geteilt wird dann entlang der **Richtungen** — eingehende Verweise hier, ausgehende in einem
  Folge-Slice —, nicht gedehnt.
- `in-progress` → `open` (blockiert — Carveout?): **zwei voneinander unabhängige Auslöser.**
  **Erstens:** die Entscheidung aus DoD (1) fällt auf *eigenständig bauen*, und der Eigenbau
  berührt eine Norm-Aussage, die nach [`AGENTS.md`](../../../../AGENTS.md) §3.8 der Architect
  schreibt. **Zweitens:** die offene Rollenfrage `BEO-007` — wer die Anweisungssätze unter
  [`.claude/commands/`](../../../../.claude/commands/) schreiben darf — fällt für die Zeile
  [`.claude/commands/implement-slice.md`](../../../../.claude/commands/implement-slice.md) aus §3
  gegen den Implementer als schreibende Rolle (§6 Risiko 2). In beiden Fällen geht der Slice zurück
  nach `open/`, und die Übergabe ist das Architect-Artefakt aus dem jeweiligen Konflikt-Pfad
  (Baseline-Regelwerk `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz) — nicht ein
  Norm-Text aus diesem Lauf.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig, `make gates` ohne einen Befund, der diesem Slice zuzurechnen ist (Vergleich gegen
den Lauf vor der Änderung), Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Übernahme bringt fremde Annahmen mit, und eine davon ist gemessen zu eng.** Das
  Vorbild-Skript ersetzt zwei Formen; die zwei Kommandos aus §1 geben für dieses Repo **13**
  Präfix-Formen plus die Form ohne Verzeichnis-Segment aus. Ein Werkzeug, das nur die zwei
  bekannten trifft, meldet Erfolg und lässt den Rest stehen — schlimmer als kein Werkzeug, weil es
  die Handprüfung ersetzt, die heute den Rest fängt. — **Ausgang: weiter offen** → `BEO-003` im
  [Beobachtungs-Register](../observations.md). Die ausgehende Hälfte der präfixlosen Form ist
  abgedeckt (DoD (2)); die eingehende Hälfte bleibt außerhalb der Zusage — dieselbe Grenze, die
  DoD (2) jetzt ausdrücklich benennt, nicht *vollständig abgedeckt*.
- **Ein Liefergegenstand liegt in einer Artefakt-Klasse ohne benannte schreibende Rolle.** §3
  führt [`.claude/commands/implement-slice.md`](../../../../.claude/commands/implement-slice.md);
  wer die Anweisungssätze unter [`.claude/commands/`](../../../../.claude/commands/) schreiben
  darf, sagt keine Quelle — das ist `BEO-007` im [Beobachtungs-Register](../observations.md), und
  der Verantwortliche dieses Slice ist der Implementer. Fällt die Antwort gegen ihn, greift die
  Rückführung `in-progress` → `open` aus §4 (zweiter Auslöser dort); die zwei übrigen Zeilen der
  Tabelle bleiben davon unberührt und tragen die Zusage aus DoD (2) allein.

  **Ausgang: entfallen.** [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  (Architect-Verdikt über den Konflikt-Pfad, `Proposed`, Annahme-Trigger
  [slice-145](../next/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md) in `next/`) löst
  genau diesen Fall in Folgepflicht 4 auf: die Prämisse der Rückführungs-Bedingung aus §4 trifft
  nicht zu, weil [`AGENTS.md`](../../../../AGENTS.md) §3.8 `.claude/commands/implement-slice.md`
  nie erfasst hat (Reviewer-Befund HIGH-1, bestätigt) — die Zeile ist ohne Rollen-Konflikt
  geschrieben. Der Verdikt selbst ist unabhängig vom `Accepted`-Status der ADR gefällt (Modul 8s
  Konflikt-Pfad schließt mit dem Architect-Artefakt, nicht mit dessen späterer Annahme); die
  Annahme selbst ist Sache von `slice-145`, nicht dieser Closure. **Die allgemeine Quellenfrage
  bleibt offen:** [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  deckt nur die Command-Form und lässt `.claude/agents/*.md` in
  Festlegung 3 ausdrücklich unentschieden — zweiter Beleg für `BEO-007` im
  [Beobachtungs-Register](../observations.md).
- **Eine Adresse ist ein Teilstring, und Slice-Nummern sind Präfixe voneinander.** `slice-13`
  steckt in `slice-130`; eine Ersetzung über den blanken Nummern-Teil trifft Nachbarn. Die
  Ersetzung muss auf dem **vollen Dateinamen** ankern, und das ist zu belegen, nicht zu behaupten.

  **Ausgang: entfallen.** Der Fall ist als Selbsttest rot gesehen: `test/slice-mv.bats` führt den
  Fall *„eingehend: Teilstring-Falle — Move von slice-13 aendert slice-130 NICHT"* (Zeile 68 ff.),
  der prüft, dass ein Move von `slice-13` `slice-130` unberührt lässt — ohne die
  Wortgrenzen-Verankerung wäre er rot. `docker run … bats test/slice-mv.bats` → 8/8 `ok`, dieser
  Fall darunter.
- **Ein Werkzeug, das Adressen ersetzt, ersetzt keine Zustandssätze.** Eine Zeile *„In Arbeit:
  <slice>"* bleibt nach dem Wechsel nach `done/` stehen; ihr Verweis ist dann richtig und ihre
  Aussage falsch. Das ist eine Grenze, keine Lücke — was ein Satz behauptet, ist Urteil und kein
  Match. Sie gehört in den Skriptkopf, nicht in die Commit-Message.

  **Ausgang: entfallen.** Die Grenze steht im Kopf — `harness/tools/slice-mv.sh` Abschnitt GRENZEN
  (1): *„Das Werkzeug zieht PFADE nach, keine ZUSTANDSSÄTZE … Welcher Satz einen Zustand
  behauptet, ist Urteil, kein Match."*
- **Welle-Plan-Dateien wechseln beim Closure-Move die Verzeichnis-Tiefe**, nicht nur das
  Verzeichnis: ein Ziel aus Tiefe *n* braucht aus *n+1* ein zusätzliches `../`. Ob der Slice diese
  Klasse mitnimmt oder sie ausdrücklich ausschließt, ist eine Entscheidung und keine Auslassung.

  **Ausgang: entfallen.** Ausdrücklich ausgeschlossen, im Kopf benannt — Abschnitt GRENZEN (2):
  das Werkzeug bewegt nur `SLICE=<slice-NNN>`-Dateien und ersetzt in der Ausgehend-Richtung darum
  nur `slice-`-Ziele; ein präfixloses `welle-`-Ziel bleibt unberührt (`test/slice-mv.bats`, Fall
  *„ausgehend: welle-Ziel bleibt unberuehrt (Grenze 2 — nur slice-Dateien)"*).
- **Ein neues Skript hat zwei Wächter, die es sofort binden.** `make shell-lint` deckt
  `harness/tools/*.sh` ohne Zutun; `make comment-claims` verlangt, dass ein im Kommentar genannter
  Sensor existiert. Ein Kopf, der einen Selbsttest nennt, den es nicht gibt, bricht das Gate — das
  ist gewollt und hier vorab benannt.

  **Ausgang: entfallen.** Beide grün, ohne Ausnahme — `make shell-lint` (clean), `make
  comment-claims` (47 Datei(en) geprueft, 0 Befund(e); Kommando: `make comment-claims`).
- **Der Nachweis ist nicht „es lief".** Nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.6 gehört zu jeder Zusage die Änderung, die sie rot färbt.
  Für dieses Werkzeug heißt das: ein Move, dessen Verweise **absichtlich** nicht nachgezogen
  werden, muss `make docs-check` rot machen — sonst misst der Beleg die Mechanik statt die Zusage.

  **Ausgang: entfallen.** Rot gesehen und dauerhaft im Bericht benannt — `harness/tools/slice-mv.sh`
  Abschnitt BELEG dokumentiert einen echten Move (`slice-069`, `open/` → `next/`) mit
  `make docs-check` vor (480 Datei(en), 0 Befund(e)) und danach (480 Datei(en), 8 Befund(e), alle
  `target-missing`, alle die ausgeschlossene präfixlose Eingehend-Form aus Grenze (3)) —
  reproduzierbar auf jedem sauberen Checkout.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Closure-Kriterien (beobachtet, nicht behauptet):**

1. **DoD vollständig.** Alle Punkte aus §2 sind gehakt —
   `grep -c '^- \[ \]' docs/plan/planning/done/slice-144-lifecycle-move-zieht-seine-verweise-nach.md` → **0**
   offene Punkte (Kommando läuft vor dem `git mv`, solange die Datei noch unter diesem Pfad
   liegt).
2. **`make gates` grün** nach dem Commit dieser Closure-Notiz — der Stop-Hook-Stempel deckt den
   Arbeitsbaum (`d-check: 480 Datei(en) geprüft, 0 Befund(e)`; `comment-claims: 47 Datei(en)
   geprueft, 0 Befund(e)`; bats-Gesamtlauf grün).

- **Was hat funktioniert:** Drei getrennte Rollen-Durchgänge nach dem ersten Grün (Reviewer,
  Delta-Reviewer, Verifier) fanden nacheinander **unterschiedliche** Lücken an demselben
  Liefergegenstand, statt denselben Fehler zu wiederholen — Rollen-Konflikt · Commit-Zuschnitt
  gegen Hard Rule 3.3 · Beleg-vs-Behauptung. Der Konflikt-Pfad aus Modul 8 trug real: das HIGH-1
  des Erstreviews löste über den Rollenwechsel zum Architect ein echtes Verdikt aus
  ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md), Verdikt 3 der
  Konflikt-Tabelle — „Lockerung legitim, aber undokumentiert"), statt dass eine spätere Runde das
  Finding einfach herabstufte.
- **Was ging anders als geplant:** Das Werkzeug brauchte vier statt einem Commit
  (`f9697d7` plus drei Nacharbeits-Runden), und seine dritte, bis heute offene Grenze (präfixlose
  Eingehend-Form) zeigte sich erst im echten Betrieb: Die zwei realen `slice-082`-Moves trafen
  beide denselben `docs/reviews`-Fehler, den zwei vorangegangene Reviews nicht gefangen hatten
  (`9b8d088`/`cfbcfcb`, von Hand nachgezogen, dann in `8737ca7` behoben) — der Plan selbst nennt
  das „den ehrlichsten Beleg, den dieser Slice hat".
- **Steering-Loop-Eintrag: benannte Spec-Lücke.** Kein Sensor prüft, ob eine Zusage — Skript-
  Ausgabe, Testname, Doku-Absatz — nach einem verhaltensändernden Fix weiter zutrifft; `make
  comment-claims` prüft nur, ob ein genannter Sensor **existiert**, nicht ob eine Aussage daneben
  **stimmt**. Dreifach in diesem Slice beobachtet: die `100 %`-Zusage der Skript-Ausgabe
  (Delta-Review MEDIUM-2, behoben `bc38f97`), der Testname „alle 14 gemessenen Praefix-Formen"
  (Erstreview LOW-1, behoben `fc1fc54`), und — nach `8737ca7` — der `harness/README.md`-Absatz
  plus die `test/slice-mv.bats`-Kopfzeile (Verifikation, behoben `b1ef306`). Jede der drei fand ein
  *anderer* Lauf; keine ein Gate. Neuer Register-Eintrag `BEO-009`.
- **Beobachtungs-Register (`../observations.md`):** `BEO-003` fortgeschrieben (2×: `slice-137`,
  `slice-144`; Beobachtung präzisiert auf den in §1 gemessenen Bestand statt „zwei Formen"; Stand
  *teilweise verkörpert* — 13 Präfix-Formen und die ausgehende Hälfte der präfixlosen Form sind
  gedeckt, die eingehende Hälfte bleibt Grenze 3 und damit offen). `BEO-007` fortgeschrieben (2×:
  `slice-137`, `slice-144`; die Command-Form ist über
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) beantwortet
  (`Proposed`), die allgemeine Quellenfrage — auch für `.claude/agents/*.md` — bleibt offen). Neu:
  `BEO-009` (Sub-Area `*`, 1×, Beleg `slice-144`).
- **Folge-Slices:** keine neuen — [`slice-145`](../next/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md)
  (Erinnerungs-Slice zu [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
  bereits in `next/`) ist das zweite Pflicht-Artefakt des Konflikt-Pfads, kein Ergebnis dieser
  Closure.
- **Risiken aus §6:** sieben benannt
  (`awk '/^## 6\. Risiken/,/^## 7\. Closure-Notiz/' docs/plan/planning/done/slice-144-lifecycle-move-zieht-seine-verweise-nach.md | grep -c '^- \*\*'`
  → **7**), sieben mit Ausgang — eines *weiter offen* (`BEO-003`), eines *entfallen* auf ein
  Architect-Verdikt mit offenem Rest
  ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)/`BEO-007`), fünf
  *entfallen* auf gemessene oder getestete Deckung, keines *eingetreten*.
- **Drei Paarungen:** entfällt hier — dieses Repo führt Wellen-Betrieb; die Paarungen (Anker ·
  Folge-Slice · Register) prüft die nächste Welle-Closure, auch für diesen wellenlosen Slice
  (`modul-06-roadmap.md`
  §Wellen-Closure-Prozedur, Schritt 3, *„Zum Schluss alle drei Paarungen prüfen"*).

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind [`harness/tools/`](../../../../harness/tools/)
(das Skript) und der Eintrag `*` (gesamtes Repo) für `Makefile`,
[`harness/README.md`](../../../../harness/README.md) und die Anweisungssätze. Beide führt die
Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
bereits als **Greenfield** — der Modus-Begründungsblock entfällt damit nach dem *Umfang*-Absatz
oben. Eine eigene Sub-Area für das Planning-Layout auszudifferenzieren, wäre hier ohne Gegenstand:
der Slice legt ein Skript und ein Make-Ziel an und baut keine Konventions-Dichte auf, die eine
eigene Zeile in der Deklaration trüge.

**Vorgelagert — offene Beobachtungen sichten:** **der Sub-Area-Test trifft jede offene Zeile, und
das ist selbst eine der Beobachtungen.** Der Schritt fragt *„steht eine der berührten Sub-Areas im
Register?"*; berührt sind [`harness/tools/`](../../../../harness/tools/) und `*` (gesamtes Repo),
und **jede** Zeile in [`observations.md`](../observations.md) trägt `*` — genau das ist `BEO-004`.
Der Test sortiert hier also nichts aus; was er liefert, ist die volle offene Liste, und die
Zuordnung zu diesem Slice muss aus dem Gegenstand kommen. **Zwei Zeilen berühren ihn:**

- `BEO-003` — *der Abgleich nach einem Lifecycle-Move läuft von Hand, und zwei Verweis-Formen
  brechen dabei regelmäßig* —, und dieser Slice **ist** ihr Träger. Zähler-Stand und Belege stehen
  in der Datei und nicht hier, damit nicht zwei Fassungen driften. Der Stand gehört ins Kriterium
  *Evidenz-/Diskrepanz-Risiko*: er ist der Grund, warum dieser Slice überhaupt geschnitten ist,
  und **nicht** die Existenz eines fremden Skripts. **Die Zeile nennt zwei Formen; §1 misst
  mehr** — der Träger schuldet ihr damit eine Präzisierung, keine zweite Kennung.
- `BEO-007` — die fehlende schreibende Rolle für [`.claude/commands/`](../../../../.claude/commands/);
  sie trifft **eine** Zeile der Plan-Tabelle in §3 und steht als Risiko in §6.

Der Rest der offenen Liste — wie lang sie ist, sagt
`grep -c '^| BEO-' docs/plan/planning/observations.md`, und sie wächst mit jeder Closure — berührt
den Gegenstand dieses Slice nicht. `BEO-004` ist darin selbst enthalten: es erklärt, warum der
Sub-Area-Test hier nichts aussortiert, und ist deshalb Werkzeug dieser Sichtung, nicht ihr Treffer.

