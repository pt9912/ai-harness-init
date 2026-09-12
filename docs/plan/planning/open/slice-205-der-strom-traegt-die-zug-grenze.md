# Slice slice-205: `SubagentStop` wird verdrahtet — und seine Bedeutung gemessen, bevor sie zugesagt wird

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Slice verdrahtet **ein** Ereignis und schreibt seine Bedeutung fest;
sein Beleg ist eine Messung an einem realen Strom, und die steht in seiner eigenen DoD
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Ebene: Dogfood *und* emittiert, hier mit zwei Dateien statt einer.** Anders als bei
[slice-204](slice-204-das-programm-feld-nennt-das-programm.md), wo die Änderung über den Träger
reist: Die Hook-Verdrahtung steht **zweimal** im Repo — in `.claude/settings.json` (dieses Repo)
und in `internal/emit/templates/enforce/settings-capture-hooks.json` (was ein Zielrepo bekommt).

**Die zwei Dateien führen nicht dieselbe Ereignis-Menge, wohl aber dieselbe
Erfassungs-Menge** — und nur die ist hier der Gegenstand. Maßgeblich ist nicht, welche Ereignisse
eine Datei nennt, sondern welche `span-emit` rufen (**keine Erwartungswerte**):

```sh
for f in .claude/settings.json internal/emit/templates/enforce/settings-capture-hooks.json; do
  echo "$f"
  echo "  alle:      $(grep -oE '"(PreToolUse|PostToolUse|PostToolUseFailure|SubagentStart|SubagentStop|Stop)"' "$f" | sort -u | tr '\n' ' ')"
  echo "  span-emit: $(grep -B8 'span-emit' "$f" | grep -oE '"(PreToolUse|PostToolUse|PostToolUseFailure|SubagentStart|SubagentStop|Stop)"' | sort -u | tr '\n' ' ')"
done
```

`.claude/settings.json` führt **fünf** Ereignisse, die Vorlage **drei**. Die **Erfassungs-Hälfte
ist in beiden dieselbe und dreielementig** — `PostToolUse`, `PostToolUseFailure`,
`SubagentStart`; die zwei zusätzlichen in diesem Repo sind `PreToolUse` (der Command-Guard) und
`Stop` (der Gate-Wächter), beide rufen `span-emit` **nicht** und sind hier nicht berührt. Wer nur
eine der zwei Dateien anfasst, lässt die zwei Ebenen auseinanderlaufen.

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (die
Erfassungsschicht, deren Ereignis-Menge dieser Slice erweitert),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (die Erfassungs-Policy: *„Ein Attribut
ohne Incident-Frage fliegt raus"* — die Incident-Frage dieses Ereignisses steht in §1 und ist
**nicht** die, für die es auf den ersten Blick taugt),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (der Träger und
die Bedingung, unter der der Erfassungs-Block überhaupt entsteht),
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
(führt `.claude/` als Geltungsbereich — ein Adaptions-Eintrag, **keine** Rollen-Zuweisung; siehe
§6),
[`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
(die Spec-Zeile ist Rang 2 und ohne Vertragsänderung fortschreibbar)

**Berührte Spec-Stellen:** [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
§5, Absatz *„Die erfasste MENGE, ausgesprochen statt suggeriert"* — er nennt heute wörtlich
**drei** Ereignisse und wird mit diesem Slice falsch. Dazu `SPEC-005` (`event`), dessen
Incident-Frage um das Ende-Ereignis wächst.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-08.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** `SubagentStop` wird als **viertes** Erfassungs-Ereignis verdrahtet — auf beiden Ebenen —
und seine Bedeutung wird **gemessen, bevor sie zugesagt wird**: ob es einmal je Lauf oder je Zug
feuert, entscheidet der Lauf und nicht dieser Plan.

Heute beginnt ein Subagenten-Strom beobachtbar und endet stumm. Verdrahtet sind drei Ereignisse,
und keines davon markiert ein Ende (**keine Erwartungswerte** — der Bestand ist gitignored,
maschinenlokal und seit dem 2026-09-08 auf drei Tage beschnitten):

```sh
cat .harness/state/spans/*.jsonl | grep -oE '"event":"[^"]*"' | cut -d'"' -f4 | sort | uniq -c | sort -rn
#    9746 PostToolUse
#     119 SubagentStart
#      72 PostToolUseFailure
grep -oE '"(PreToolUse|PostToolUse|PostToolUseFailure|SubagentStart|SubagentStop|Stop)"' .claude/settings.json | sort | uniq -c
#    PostToolUse, PostToolUseFailure, PreToolUse, Stop, SubagentStart — je 1; SubagentStop: keines
```

**Die Incident-Frage ist nicht die naheliegende, und der Grund dafür ist eine fehlende Messung —
kein Beleg.** Naheliegend wäre *„Läuft der Agent noch oder hängt er?"*. Ob das Ereignis sie
beantwortet, hängt daran, ob es **einmal pro Lauf** oder **je Zug** feuert, und **die vendored
Referenz entscheidet das nicht**. Sie sagt an mehreren Stellen etwas darüber, und die Stellen
lassen beide Lesarten zu
([`docs/user/claude-hooks-referenz.md`](../../../../docs/user/claude-hooks-referenz.md),
**keine Erwartungswerte** — die Zeilennummern wandern mit der Datei):

```sh
grep -n 'SubagentStop' docs/user/claude-hooks-referenz.md
```

- **Z. 47** (Ereignis-Tabelle): *„When a subagent **finishes**"*.
- **Z. 574:** *„…in `SubagentStop` konvertiert, da dies das Ereignis ist, das ausgelöst wird,
  **wenn ein Subagent fertig ist**"*.
- **Z. 2146** (der eigene Abschnitt): *„Wird ausgeführt, wenn ein Claude Code-Subagent **fertig
  mit der Antwort** ist."*
- **Z. 856:** *„`Stop` und `SubagentStop`: am Ende des **Zugs**. Das Gespräch wird fortgesetzt"* —
  **aber** dieser Satz steht im Abschnitt *„Wo die Erinnerung angezeigt wird"* und beschreibt, wo
  der `additionalContext` eines Hooks ankommt; dieselbe Aufzählung verortet `PreToolUse`/
  `PostToolUse` *„neben dem Tool-Ergebnis"*. Aus ihrem Abschnitt gelöst trägt die Zeile die
  Aussage nicht.

**Die Waage kippt nicht:** *„fertig mit der Antwort"* ist genau die Formulierung, mit der die
Referenz auch `Stop` beschreibt (*„When Claude finishes responding"*), und `Stop` führt sie
ausdrücklich im Rhythmus *„einmal pro Runde"*. Dieselben Worte tragen also an anderer Stelle die
Zug-Lesart. Dazu erhält ein `SubagentStop`-Hook laut Z. 2157 die Arrays `background_tasks` und
`session_crons` — ein Hinweis darauf, dass beim Feuern noch etwas laufen **kann**, aber kein
Beleg, wie oft es feuert.

**Also gilt: hier ist es nicht gemessen.** Der Fall, an dem sich die Frage entscheidet — ein
Subagent beendet seinen Zug, während sein Hintergrund-Lauf weiterläuft, und wird später per
Nachricht fortgesetzt — ist am 2026-09-08 zweimal aufgetreten und **von niemandem beobachtet
worden, weil das Ereignis nicht verdrahtet ist**. Das ist der Grund für die Zurückhaltung dieses
Slice: **Nicht-Verfügbarkeit einer Messung**, nicht ein widersprechender Beleg — dieselbe
Unterscheidung, die [ADR-0040](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
für den Accept-Übergang führt. Deshalb entscheidet **der Lauf** die Frage (Liefer-Punkt 2) und
nicht dieser Plan.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Zusage, dass „beendet" von „hängend" unterscheidbar wird.** Sie hängt an der Frage, die
  §1 offen lässt, und ist deshalb **vor** der Messung nicht zu geben: Feuert das Ereignis je Zug,
  ist ein Lauf ohne es nur pausiert, nicht hängend. Der Slice liefert das Ereignis und seine
  gemessene Bedeutung; was ein Beobachter daraus schließen darf, folgt erst daraus —
  **Bestand bleibt bewusst stehen**, und die Grenze gehört benannt statt überschrieben.
- **Keine Auswertung und keine Sicht.** Wer das neue Ereignis liest und was er daraus schließt,
  ist **ein anderer Vorgang** auf einer anderen Schicht und in diesem Repo nicht geschnitten.
  Dieser Slice schreibt nur, was im Strom steht.
- **Kein zweiter Hook und kein `Stop`/`SessionEnd`.** Der Haupt-Kontext hat sein eigenes
  Ende-Ereignis, und `Stop` ist in diesem Repo bereits mit dem Gate-Wächter belegt. Es
  daneben auch noch erfassen zu lassen, ist eine eigene Abwägung — **ein anderer Vorgang**.
- **Keine Änderung an `internal/span/`.** Der Emitter nimmt das Ereignis **roh**
  (`Event: rawString(raw, "hook_event_name")`, `internal/span/span.go`); er kennt keine
  Ereignis-Liste, die zu erweitern wäre. Ist das gemessen falsch, ist **das** der Befund und der
  Slice geht nach §4 zurück — **Schicht-Abgrenzung**, beim Review sofort prüfbar.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

**Liefer-Punkt 1 — das Ereignis ist verdrahtet, auf beiden Ebenen.**

- [ ] `SubagentStop` ruft `span-emit` in `.claude/settings.json` **und** in
      `internal/emit/templates/enforce/settings-capture-hooks.json`, je mit leerem Matcher wie
      die drei bestehenden. Beide Dateien führen danach dieselbe **Erfassungs**-Menge — vier statt drei; ein Diff, der
      nur eine anfasst, ist der Befund.
- [ ] Ein realer Lauf erzeugt einen `SubagentStop`-Span **im Strom des beendeten Subagenten**
      (dieselbe Ablage-Regel, die `SubagentStart` für den Start hat) — gemessen, nicht
      angenommen.

**Liefer-Punkt 2 — die Bedeutung ist gemessen, bevor sie zugesagt wird** ([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **Das Gegenbeispiel ist benannt und hergestellt:** Ein Subagent beendet seinen Zug, während
      ein Hintergrund-Kommando weiterläuft, und wird danach per Nachricht fortgesetzt. **Was
      passieren müsste, damit ein Ende-Ereignis lügt:** genau dieser Ablauf erzeugt
      `SubagentStop`, und danach folgen **weitere** `PostToolUse`-Spans **im selben Strom**. Die
      Fall-Beschreibung ist keine Vermutung — der Ablauf ist am 2026-09-08 zweimal aufgetreten.
- [ ] Die gemessene Span-Folge ist protokolliert: `SubagentStop` gefolgt von weiteren Spans
      desselben `(session, agent)`. Tritt sie **nicht** auf — feuert das Ereignis erst beim
      wirklichen Ende —, ist **das** die Messung, und die Spec-Zeile sagt dann das.
      **Beide Ausgänge sind zulässig; keiner ist vorweggenommen.**
- [ ] Der Absatz *„Die erfasste MENGE"* in
      [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
      §5 nennt **vier** Ereignisse statt drei und schreibt die **gemessene** Bedeutung fest —
      je Lauf oder je Zug, was der Lauf ergeben hat, samt der Grenze, die daraus folgt. Steht
      dort eine Lesart, die der Lauf nicht belegt hat, ist **das** der Befund. Das Technik-Stratum ist
      ohne Vertragsänderung fortschreibbar
      ([`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence));
      das Lastenheft wird **nicht** angefasst.
- [ ] Ein Fall in `test/mutations/` nimmt der Verdrahtung die Zähne — ohne ihn ist sie
      unbewacht ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Vorbild ist die bestehende
      Kopplungs-Prüfung der Hook-Aufrufer.

**Pro Slice konstant — zählt nicht in die zwei:**

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register ([`../observations/`](../observations/)) fortgeschrieben — **kein
      Zähler wird gesetzt**, er folgt aus den Dateien.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieser Slice läuft
      **ohne Welle**, sie werden also hier geprüft, nach dem `git mv`.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.claude/settings.json` | update | der vierte Hook-Eintrag, Dogfood-Ebene |
| `internal/emit/templates/enforce/settings-capture-hooks.json` | update | derselbe Eintrag, emittierte Ebene — sonst laufen die zwei auseinander |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) §5 | update | „drei Ereignisse" → vier, plus die gemessene Bedeutung und ihre Grenze |
| `test/mutations/<N>-subagent-stop-*.sh` | neu | ohne Fall ist die Verdrahtung unbewacht |

**Zwei Schichten:** Konfiguration (beide Hook-Dateien) und Spec-Stratum 2. Kein `internal/span/`,
kein `cmd/`, kein `Makefile`.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Der Slice ist priorisiert, `Verantwortlich:` ist gesetzt, das
WIP-Limit des Rolleninhabers ist frei. **Keine Abhängigkeit von slice-203** — siehe §5.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Emitter nimmt das Ereignis doch
  nicht roh an, und die Erfassung verlangt eine Änderung in `internal/span/` — dann ist die
  Schicht-Abgrenzung aus §1 verletzt und der Slice neu zu schneiden.
- `in-progress` → `open` (blockiert — Carveout?): Das Gegenbeispiel aus Liefer-Punkt 2 lässt sich
  nicht herstellen, weil der Ablauf nicht willentlich auslösbar ist. Dann fehlt der Zusage ihr
  Rot, und sie darf nach [`AGENTS.md`](../../../../AGENTS.md) §3.6 nicht geschrieben werden.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **(1)** Ein realer Strom trägt einen `SubagentStop`-Span, und beide
Hook-Dateien führen dieselbe Erfassungs-Menge; `make gates` ist grün. **(2)** Die Bedeutung des
Ereignisses ist an einem realen Ablauf gemessen und in der Spec-Zeile festgeschrieben — samt der
Grenze, die die Messung ergibt. Dazu der Lerneintrag in einer der drei Formen (geschärfte Regel ·
neuer Sensor · benannte Spec-Lücke).

**Kein Leser wartet auf dieses Ereignis.** Dieser Slice schreibt; wer den Strom liest, ist in
diesem Repo nicht geschnitten. Ein Strom, der sein Ende-Ereignis führt, ist auch ohne benannten
Leser auswertbar — der Slice ist damit einzeln lieferbar und kein Zombie-Slice
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Das Ereignis wird als „Lauf beendet" gelesen, bevor gemessen ist, ob es das heißt.** Feuert
  es je Zug, übersieht ein Beobachter, der es glaubt, genau den Fall, für den er gebaut wurde:
  den Lauf, der pausiert und weitergeht. Der Referenz-Wortlaut trägt **beide** Lesarten (§1), also
  entscheidet nur der Lauf. Liefer-Punkt 2 schreibt das Ergebnis in die Spec, damit es nicht nur
  im Kopf des schreibenden Laufs steht. — **Ausgang:** <offen>
- **Für `.claude/settings.json` benennt keine Quelle eine schreibende Rolle.**
  [`AGENTS.md`](../../../../AGENTS.md) §3.8 deckt nur Hard Rules und Adaptions-Block;
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) nimmt
  `.claude/agents/*.md` ausdrücklich aus und *„lässt die Frage für alle übrigen ausdrücklich
  offen"*.
  [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
  führt `.claude/` als **Geltungsbereich** einer Adaption — das ist keine Rollen-Zuweisung. Die Datei ist zudem **kein Anweisungssatz**, sondern Konfiguration; der
  Register-Eintrag `anweisungssatz-eigentum-ohne-quelle` (5×, `geplant`) ist auf Anweisungssätze
  zugeschnitten, und ob dies dieselbe Beobachtung ist oder eine eigene, ist ein **Urteil** und
  fällt bei der Closure — nicht hier, und nicht durch stille Einordnung.
  — **Ausgang:** <offen>
- **Die zwei Ebenen können auseinanderlaufen.** Die Ereignis-Menge steht in zwei Dateien, und
  kein Sensor hält sie gegeneinander. Liefer-Punkt 1 verlangt beide; ob ein Wächter das dauerhaft
  hält, entscheidet dieser Slice nicht. — **Ausgang:** <offen>
- **Ein blockierender Hook an diesem Ereignis hält den Subagenten an.** Die Referenz führt
  `SubagentStop` als blockierfähig (*„Verhindert, dass der Subagent stoppt"*). `span-emit` ist ein
  schreibender Hook und darf hier nichts blockieren; die Klemme aus
  [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 6 muss auch auf diesem
  Kanal greifen. — **Ausgang:** <offen>

## 7. Closure-Notiz

<!-- Wird bei der Closure gefüllt — Planner, nicht der Lauf, der die Arbeit tat
(AGENTS.md §3.10). -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area, `*` (`ALL`). Die
Hook-Verdrahtung liegt in `.claude/` und in `internal/emit/templates/`, die zweite Schicht ist
`spec/` — `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`) sind als Pfade nicht berührt. `.codex/`
führt allein den SessionStart-Injektor und keine Erfassung; die Ereignis-Menge dieses Slice
erreicht ihn nicht.

**Vorgelagert — offene Beobachtungen sichten:** Das Register unter
[`../observations/`](../observations/) ist durchgegangen; die Zähler sind als Dateizahl unter
`evidence/` abgelesen
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, **keine
Erwartungswerte** —
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2, gelesen am gemergten Stand vom 2026-09-08). Diesen Vorgang betreffen:

| Eintrag | Zähler | Stand | Bezug zu diesem Slice |
|---|---|---|---|
| `hintergrund-lauf-wird-gepollt-statt-abgewartet` | 1× | offen | der Anlass der ganzen Linie; dieser Slice liefert das Ereignis, an dem eine Lücke im Strom erklärbar wird |
| `zusage-ohne-herstellbares-gegenbeispiel` | 2× | offen | **der Kern von Liefer-Punkt 2** — die Rückführung in §4 nennt den Fall, in dem das Gegenbeispiel *nicht* herstellbar ist, statt ihn wegzudefinieren |
| `anweisungssatz-eigentum-ohne-quelle` | 5× | geplant | benachbart, **nicht** zitiert als Beleg: `.claude/settings.json` ist Konfiguration, kein Anweisungssatz; die Zuordnung ist ein Urteil und steht als Risiko in §6 |
| `neuer-waechter-ohne-mutations-fall` | 1× | offen | die neue Verdrahtung braucht ihren Fall in `test/mutations/` |
| `vollstaendigkeits-zusage-misst-falsche-ebene` | 2× | offen | die Ereignis-Menge steht in **zwei** Dateien; eine Zusage über „die verdrahteten Ereignisse" trifft sonst nur eine Ebene |
| `zusage-nennt-sensor-der-form-nicht-sieht` | 9× | geplant | die Spec-Zeile nennt eine Menge, die kein Sensor gegen die zwei Dateien hält — Adresse `slice-181` |
| `zahl-ohne-kommando-trifft-ihren-gegenstand-nicht` | 3× | offen | über der Schwelle: „drei Ereignisse" ist genau so eine Zahl, und sie wird mit diesem Slice falsch |

**Zwei Einträge tragen bereits einen Ausgang** (`anweisungssatz-eigentum-ohne-quelle`,
`zusage-nennt-sensor-der-form-nicht-sieht` — beide `geplant` mit Kennung); dieser Slice ändert ihn
nicht. **Ein Eintrag steht über der Schwelle** (`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`)
und wartet auf den Lese-Schritt; dieser Slice weist ihm keinen Ausgang zu und erhöht ihn nicht
vorab. Alle Bezeichnungen sind **zitiert**, nicht neu formuliert.

**Modus:** alle berührten Sub-Areas **GF** — der Begründungsblock entfällt damit nach der
Umfangs-Regel dieser Sektion.
