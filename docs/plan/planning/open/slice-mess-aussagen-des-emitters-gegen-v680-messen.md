# Slice slice-mess-aussagen-des-emitters-gegen-v680-messen: Die drei Vorlagen-Proben des Emitters werden gegen den neuen Satz gefahren

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Welle:** ohne Welle. Sein Closure-Trigger würde die eigene DoD abschreiben (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht); nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap.

**Herkunft:** Übergabe aus
[slice-mutations-fall-entdeckt-den-vendored-tag](../done/slice-mutations-fall-entdeckt-den-vendored-tag.md)
§1, Out-of-Scope Punkt 1 — dort ausdrücklich als Adresse benannt, die die Sendung annimmt.

**Bezug:**
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(eine Aussage über die Baseline nennt den Tag, gegen den sie gemessen ist — hier ist der genannte
Tag der abgelöste),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(die Probe steht neben dem Kommando, das sie liefert),
[`MR-053`](../../../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
(eine Werkzeug-Aussage wird datiert, statt den lebenden Stand zu führen),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Proben müssen
nachfahrbar sein — heute nennen sie einen Pfad, den es nicht gibt),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (eine Zusage ohne gefahrene Gegenprobe).

**Berührte Spec-Stellen:** — (Gegenstand sind Doc-Kommentare in `internal/emit/templates.go`).

**Verantwortlich:** — (bis zur Priorisierung).

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Die drei Proben, mit denen `internal/emit/templates.go` seine Maskierungs- und
Kommentar-Regeln gegen den Vorlagensatz belegt, werden gegen `v6.8.0` gefahren, und der genannte
Mess-Stand wird auf das Ergebnis dieses Laufs gesetzt.

**Der Befund.** Drei Stellen nennen den abgelösten Tag:

```sh
git grep -n 'v6\.7\.2' -- internal/emit/templates.go   # 3 Zeilen: :903, :904, :982
```

**Kein Erwartungswert** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Zwei davon sind **Kommandos**, die ihren eigenen Beleg liefern sollen — die
NUL-Byte-Probe (`grep -rlP '\x00' .harness/baseline/v6.7.2/templates …`) und der `T=`-Block mit
drei Backtick-Proben. Ihr Operand existiert nicht mehr; ein Nachfahren liefert heute einen Fehler
statt der zugesagten leeren Ausgabe, und die Zusage *„die Grenze ist heute nicht auslösbar"* ruht
damit auf einer Messung gegen einen Satz, der nicht mehr da ist.

**Der Block verlangt es selbst.** Wörtlich: *„Diese drei Proben gelten für den Satz, gegen den sie
gefahren wurden, und für keinen anderen: JEDER Re-Baseline … muss sie gegen den NEUEN Satz erneut
fahren — sie sind eine NOTWENDIGE, keine hinreichende Bedingung"*. Der Sprung auf `v6.8.0` hat das
nicht getan.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Tag wird nicht entdeckt, sondern neu genannt.** Die Gegenrichtung — eine tag-freie
  Adresse, wie sie
  [slice-mutations-fall-entdeckt-den-vendored-tag](../done/slice-mutations-fall-entdeckt-den-vendored-tag.md)
  für die Mutations-Fälle durchgesetzt hat — wäre hier der Fehler:
  [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  verlangt den Tag, wo er eine **Messung** datiert. Was fehlt, ist der Lauf, nicht die Adressform.
- **Kein Verhaltens-Änderung am Emitter.** Fällt eine Probe gegen `v6.8.0` **nicht** leer aus, ist
  das ein Befund und kein Auftrag: Dann trägt die Grenze *„heute nicht auslösbar"* nicht mehr, und
  was daraus folgt — ein Fix, ein Carveout oder eine umgeschriebene Grenze — ist ein eigener
  Vorgang mit eigener Abwägung. Dieser Slice misst und schreibt das Ergebnis auf.
- **Kein Nachzug anderer Tag-Nennungen im Repo.** Die übrigen Vorkommen sind entweder Historie in
  eingefrorenen Artefakten oder bewusst stehengelassener Bestand; beides ist in der Herkunft
  §1 bereits entschieden. Ein zweiter Durchgang darüber meldete gegen Altbestand, den niemand
  entschieden hat.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

**Zwei Liefer-Punkte** (die ersten zwei); alles darunter ist pro Slice konstant.

- [ ] **(1) Die drei Proben sind gegen `v6.8.0` gefahren, und ihr Ergebnis steht da.** Jede der
      drei nennt den Stand, gegen den sie lief, und die Ausgabe, die sie lieferte — leer oder
      nicht. `git grep -c 'v6\.7\.2' -- internal/emit/templates.go` ist **0**, und jeder Operand
      in den Kommentar-Kommandos löst auf (`[ -e ]` über den genannten Pfaden).
- [ ] **(2) Die Zusage daneben trägt genau das, was der Lauf gezeigt hat.** Fielen alle drei
      leer aus, bleibt die Grenze *„heute nicht auslösbar"* stehen, jetzt mit `v6.8.0` als
      Mess-Stand. Fiel eine nicht leer aus, steht das dort — als Befund mit Fundstelle, und die
      Grenz-Aussage wird auf das eingeschränkt, was der Code hält
      ([`AGENTS.md`](../../../../AGENTS.md) §3.7); der Ausgang ist dann ein Folge-Slice, nicht
      eine stillschweigend weichere Formulierung.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: entfällt — kein öffentlicher Vertrag berührt. Gegenstand sind Doc-Kommentare an
      unexportierten Funktionen; weder ein `make`-Ziel noch ein Sensor-Vertrag noch eine emittierte
      Vorlage ändert sich.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates.go` §`unmaskQuotedCommentSyntax` (Kopf) | update | Die NUL-Byte-Probe gegen den `v6.8.0`-Satz fahren; Tag und Ergebnis im Kommentar auf den Lauf setzen. |
| `internal/emit/templates.go` §`StripCommentHints` (Kopf, `T=`-Block) | update | Die drei Backtick-Proben gegen den `v6.8.0`-Satz fahren; `T=` und die drei Ausgaben auf den Lauf setzen. Die vierte Form (*Fence-Blindheit*) hat auch danach keine Probe — das steht dort schon und bleibt so. |

**Kein Test-Eintrag, und das ist die Eigenart dieses Slice.** Der Liefergegenstand ist eine
**Messung**, kein Verhalten: Es gibt nichts zu testen, was nicht schon getestet wäre, und ein
neuer Test hier behauptete eine Eigenschaft, die der Slice gar nicht ändert. Der Beleg ist die
Ausgabe der drei Kommandos, und sie steht im Kommentar neben ihnen
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

**Die Proben laufen Docker-only** ([`AGENTS.md`](../../../../AGENTS.md) §3.9). `grep`, `find` und
`awk` sind keine Host-Toolchain im Sinne der Regel; sie laufen über den Baum, nicht über eine
Sprach-Umgebung. Wo ein Kommando doch eine braucht, ist **das** der Befund und nicht der Ausweg.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Priorisiert, `Verantwortlich:` gesetzt, WIP-Limit frei. Eine
Abhängigkeit hat der Slice nicht — der `v6.8.0`-Baum steht, und der Gegenstand liegt vollständig
in einer Datei. Er ist **nicht dringend**: Der Defekt ist eine unbelegte Zusage, kein roter Lauf.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Eine der drei Proben fällt gegen
  `v6.8.0` **nicht** leer aus, und die Reparatur am Emitter wäre Teil desselben Laufs. Dann sind
  es zwei Vorgänge — messen und ändern —, und der zweite gehört geschnitten, nicht mitgenommen
  (§1, Ausschluss 2).
- `in-progress` → `open` (blockiert — Carveout?): Eine Probe ist gegen den neuen Satz nicht
  fahrbar, weil die Vorlage, die sie adressiert, im `v6.8.0`-Satz nicht mehr existiert. Dann ist
  die Frage, was die Probe überhaupt noch belegen soll, und das ist eine Entscheidung über die
  Grenz-Aussage, keine Messung.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. `git grep -c 'v6\.7\.2' -- internal/emit/templates.go` ist **0**, und jeder Pfad-Operand in
   den drei Kommentar-Kommandos löst auf — geprüft mit `[ -e ]` über den genannten Pfaden, nicht
   durch Hinsehen.
2. Die Ausgabe jeder der drei Proben steht im Kommentar neben ihrem Kommando, und der Review hat
   mindestens eine davon **nachgefahren** statt sie zu übernehmen. `make gates` grün.

**Lerneintrag** (eine der drei Formen): *benannte Spec-Lücke* oder *geschärfte Regel*, je nach
Ergebnis. Die Frage, die der Slice offenlegt, ist größer als er: Ein Kommentar-Block, der seine
eigene Nachfahr-Pflicht bei jeder Re-Baseline ausspricht, hat dafür keinen Träger — weder ein Gate
noch einen Schritt in der Sprung-Prozedur. Ob daraus eine Regel wird, entscheidet der Zähler-Stand
der Beobachtung aus §8; die Verkörperung wäre Architect-Arbeit
([`AGENTS.md`](../../../../AGENTS.md) §3.8).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Eine Probe fällt nicht leer aus.** Dann trägt die Grenz-Aussage *„heute nicht auslösbar"* nicht
  mehr, und der Slice liefert einen Befund statt einer Bestätigung. Das ist kein Fehlschlag des
  Slice — es ist das, wofür die Probe da ist —, aber es verschiebt seinen Ausgang. — **Ausgang:** <bei Closure>
- **Die Probe ist nachfahrbar, aber nicht mehr aussagekräftig.** Der `v6.8.0`-Satz kann Vorlagen
  enthalten, die die geprüfte Form gar nicht mehr tragen; dann ist die Probe über der leeren Menge
  wahr und belegt nichts — die Klasse
  [`zusicherung-ueber-der-leeren-menge-wahr`](../observations/BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr/observation.md).
  Ein leeres Ergebnis ist darum gegen die **Kandidaten-Menge** zu halten, nicht nur zu notieren. — **Ausgang:** <bei Closure>
- **Der Lauf schreibt eine neue Zahl neben ein Kommando, das er nicht gefahren hat.** Genau die
  Klasse [`zahl-neben-nie-gefahrenem-kommando`](../observations/BEO-ALL/zahl-neben-nie-gefahrenem-kommando/observation.md)
  (verkörpert), und sie liegt hier besonders nah: Der Slice besteht aus nichts anderem als aus
  Kommandos und ihren Ausgaben. — **Ausgang:** <bei Closure>

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
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <Repo **mit** Wellen-Betrieb — geprüft von der nächsten Welle-Closure, auch
  für diesen Slice ohne Wellen-Zugehörigkeit>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Eine berührte Sub-Area: **`*` (gesamtes Repo)** (`ALL`),
so in der Modus-Deklaration ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area) geführt. `internal/emit/` ist dort **nicht** als eigene Sub-Area
deklariert und wird hier auch keine: Eine Neu-Deklaration ist eine Konventions-Entscheidung und
gehört nicht in einen Slice, der drei Kommandos nachfährt.

**Vorgelagert — offene Beobachtungen sichten:** Das Register
([`../observations/`](../observations/README.md)) ist durchgegangen; alle Einträge tragen die
Sub-Area `*`, gesichtet ist also nach **Aussagen**-Berührung. Vier Treffer, Zähler-Stand ist je
die Zahl der Dateien unter `evidence/`
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`), **keine
Erwartungswerte**:

| Beobachtung | Stand | Berührung |
|---|---|---|
| [`tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht`](../observations/BEO-ALL/tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht/observation.md) | 1× offen | **Direkt, als Gegenstück** — der Eintrag trennt Adresse von Messung; dieser Slice ist die **Messungs**-Hälfte. Er erreicht **kein** zweites Auftreten: Die drei Stellen sind der bereits gezählte Fund desselben Vorgangs, nicht ein neuer. |
| [`zahl-neben-nie-gefahrenem-kommando`](../observations/BEO-ALL/zahl-neben-nie-gefahrenem-kommando/observation.md) | 4× verkörpert | **Direkt** — Risiko 3 in §6. Der Slice besteht aus Kommandos und ihren Ausgaben; die Regel ist verkörpert und wirkt, der Lauf muss sie nur halten. |
| [`zusicherung-ueber-der-leeren-menge-wahr`](../observations/BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr/observation.md) | 2× offen | **Direkt** — Risiko 2 in §6: Eine leere Probe über einer leeren Kandidaten-Menge belegt nichts. Ob der Slice ein drittes Auftreten liefert, entscheidet der Lauf, nicht dieser Plan. |
| [`baseline-aussage-ohne-mess-tag`](../observations/BEO-ALL/baseline-aussage-ohne-mess-tag/observation.md) | 4× offen | **Nachbar, deckt nicht** — dort fehlt der Tag ganz; hier steht er und ist der falsche. Genannt, weil die Abhilfe entgegengesetzt aussieht: dort ergänzen, hier ersetzen. |

**Keiner der vier erreicht mit diesem Slice 3×** — zwei stehen darüber und tragen bereits einen
Ausgang, zwei bewegt er nicht.

**Modus-Begründungsblock — Umfang.** Die berührte Sub-Area ist **GF**; ein Begründungsblock
entfällt damit.
