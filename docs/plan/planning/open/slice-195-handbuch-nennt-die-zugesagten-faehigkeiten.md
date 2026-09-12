# Slice slice-195: Das Benutzerhandbuch nennt die drei Fähigkeiten, die der Vertrag zusagt und der Ist-Text verschweigt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Die Closure-Bedingung wäre die Abschrift der DoD unten
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).
Damit **nicht** in der Roadmap geführt.

**Ebene: Dogfood-Doku über die emittierte Ebene.** Gegenstand ist
[`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) — eine Datei
**dieses** Repos, die beschreibt, was ein **fremdes** Ziel bekommt. Der Generator ist nicht
berührt: alle drei Fähigkeiten liegen, nur der Text schweigt.

**Bezug:**
[`LH-FA-05`](../../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2),
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (nur die
Skill-Hälfte — die `CLAUDE.md`-Hälfte ist ausgeschlossen, §6),
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) — die
drei Anforderungen, deren Zusage im Ist-Text keine Entsprechung hat;
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Beschreibung, die vollständig aussieht und es nicht ist, sagt einen Umfang zu, den sie nicht hat);
[`ADR-0006`](../../adr/0006-durchsetzung-commands-tool-als-quelle.md) (**Accepted** — die
Klassen-Abgrenzung, aus der folgt, welche Artefakte der Durchsetzungsschicht real emittiert werden
und welches nicht).

**Berührte Spec-Stellen:** `—`. Der Slice ändert keine Spec-Aussage; die drei Anforderungen sind
**Prüfgegenstand**, nicht Änderungsziel. Der Verweis zeigt aufwärts (Baseline-Regelwerk
`grundlagen-referenz-richtung.md` §Referenz-Richtung (SDP)).

**Verantwortlich:** — (bis zur Priorisierung).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-09-07.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Wer im Handbuch nach einer zugesagten Fähigkeit sucht, findet sie beschrieben — oder erfährt,
dass es sie nicht gibt. Was er nicht bekommt, ist Schweigen.**

Drei Fähigkeiten sind emittiert und im Ist-Text nicht beschrieben. Je Zeile: die Zusage, das
Kommando, das die Emission zeigt, und das Kommando, das das Schweigen zeigt.

```sh
# LH-FA-08 — die drei Workflow-Commands
grep -c '".claude/commands/' internal/emit/commands.go                          # 3  emittiert
grep -nE 'implement-slice|plan-welle|close-welle' docs/user/benutzerhandbuch.md | cut -d: -f1
grep -n '^## 11\.' docs/user/benutzerhandbuch.md | cut -d: -f1                  # die Historie beginnt hier

# LH-FA-06 — Reviewer-/Closure-Skill
ls .harness/baseline/v6.0.0/templates/.harness/skills/ | wc -l                  # 2  Vorlagen im Kurs-Satz
sed -n '/^func inScope/,/^}$/p' internal/emit/templates.go | grep -c 'skills'   # 1  die Regel, die sie durchlaesst
grep -icE 'reviewer|skill' docs/user/benutzerhandbuch.md                        # 0

# LH-FA-05 — Pointer-/Trust-Abschnitt der Root-README
grep -c 'Was macht es vertrauenswürdig' \
  .harness/baseline/v6.0.0/templates/project-readme.template.md                 # 1  in der Vorlage
grep -icE 'pointer|trust|vertrauenswürdig|vorwärts' docs/user/benutzerhandbuch.md  # 0
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — jede Zahl wandert mit dem Emitter oder mit dem Handbuch. Tragend ist bei den zwei
Handbuch-Nullen, dass sie null sind, und bei den zwei Zeilennummern, dass die einzige Fundzeile
**hinter** der Überschrift der Änderungshistorie liegt. Was die genannten Muster nicht treffen, ist
ungemessen: die Null gilt für sie, nicht für jede denkbare Umschreibung.

**Der Command-Fall ist der schärfste, weil das Handbuch selbst über ihn urteilt.** Sein
Kasten in §11 setzt: *„Der Rumpf dieses Handbuchs beschreibt den **Ist-Stand**. Aussagen der Form
‚**ab** Version X gibt es Y' bleiben dort … Aussagen der Form ‚**in** Version X war es noch
anders' gehören **hierher**."* Die drei Kommando-Namen stehen ausschließlich in der Historie —
nach der eigenen Regel des Dokuments am falschen Ort. Im Rumpf trägt sie eine einzige Baum-Zeile
als *„+ Arbeitsabläufe"*, ohne Namen und ohne Aufgaben-Abschnitt, wie ihn `add-lang` hat.

**Warum das eine Fähigkeits-Frage ist und keine Baum-Frage.** Ein vollständiger Baum zeigt die
Pfade — das liefert
[slice-191](slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md) und hält es mit einem
Wächter. Ein Pfad ist aber keine Beschreibung: Wer `.harness/skills/reviewer.md` im Baum liest,
weiß nicht, dass sein Repo damit eine Review-Rolle mit fixierter Urteilsgrundlage bekommt, und wer
`.claude/commands/plan-welle.md` sieht, weiß nicht, dass er es als Slash-Command aufruft. Die zwei
Slices berühren dieselbe Datei an verschiedenen Stellen und in verschiedenen Formen; die Naht steht
in §4.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Die drei Workflow-Commands stehen im Rumpf, nicht nur in der Historie.**
  [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) nennt
  `implement-slice`, `plan-welle` und `close-welle` beim Namen, sagt, dass ein Agent sie als
  Slash-Command aufruft, und wofür jedes steht — die Klasse, die
  [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) als
  *Anleitung* gegen die *Durchsetzung* abgrenzt. **Rot:** die Fundzeilen aus §1 liegen weiterhin
  ausschließlich hinter der `## 11.`-Überschrift.
- [ ] **(2) Der emittierte Reviewer-/Closure-Skill ist beschrieben.** Das Handbuch nennt
  `.harness/skills/` und sagt, was ein Adopter damit bekommt: die fixierte Urteilsgrundlage der
  Review-Rolle, die als einzige Rolle eine Skill-Datei trägt. **Die Herkunfts-Aussage gehört
  dazu**, weil sie den Satz in §4 des Handbuchs bedient, nach dem werkzeug-eigene Infrastruktur
  bei jedem Lauf *aufgefrischt* wird und Adopter-Boden unangetastet bleibt: dieser Satz kommt aus
  dem Kurs-Satz und wird konvergent neu geschrieben, die Doc-Chain-Singletons daneben nicht
  ([`ADR-0006`](../../adr/0006-durchsetzung-commands-tool-als-quelle.md) §Abgrenzung Punkt 2).
  **Rot:** `grep -icE 'reviewer|skill' docs/user/benutzerhandbuch.md` bleibt `0`.
- [ ] **(3) Der Pointer-/Trust-Abschnitt der emittierten README ist beschrieben.** Das Handbuch
  sagt, dass die angelegte `README.md` einen Abschnitt mitbringt, der auf die kanonischen Quellen
  des neuen Repos **vorwärts** verweist, und warum diese Verweise gate-sicher sind — sie zeigen auf
  co-emittierte Ziele, keiner läuft ins Leere, sonst bräche `make docs-check` im frischen Repo
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
  **Rot:** `grep -icE 'pointer|trust|vertrauenswürdig|vorwärts' docs/user/benutzerhandbuch.md`
  bleibt `0`.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

**Kein Gate hält diese drei Punkte, und das ist der Befund, keine Vertagung.** Die *Rot*-Sätze
oben sind Anwesenheits-Messungen — zwei über einer Null, einer über einer Zeilennummer; sie sagen,
**dass** etwas dasteht und **wo**, nicht **was**. Ein Gate über der Sache gibt es nicht —
`make docs-check` prüft Links, Anker, Kennungen und Codepaths, keine Deckung zwischen einer
Anforderung und einem Nutzer-Text, und `make mutate` kennt für Fließtext keine Fehlschlag-Form.
Träger ist damit das Review ([`AGENTS.md`](../../../../AGENTS.md) §3.6, benannte Grenze statt
behaupteter Abdeckung); der Sensor selbst ist offen und steht in §6.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) §4 *Aufgaben* | update | DoD (1) — die Workflow-Commands sind Bedienwissen; §4 führt bereits einen Abschnitt je Aufgabe (`add-lang`, `--arch`) |
| [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) §6 *Was wird angelegt* | update, **soweit die Fähigkeits-Aussage dort hingehört** | DoD (2) und (3) beschreiben, was der Adopter bekommt; **welcher Abschnitt** sie trägt, entscheidet der Lauf am Text — die Pfad-Aufzählung selbst gehört [slice-191](slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md) |
| [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) §9 *Glossar* | update, **soweit betroffen** | „Slash-Command", „Skill" und „Pointer-Abschnitt" sind Begriffe, die der Rumpf sonst unerklärt einführt |
| [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) §11 *Änderungshistorie* | update | die Versions-Zeile des Handbuchs; nach dem Kasten in §11 wandert dabei **keine** Fähigkeits-Aussage aus dem Rumpf hierher |
| `internal/emit/`, `spec/`, `docs/plan/adr/` | **unverändert** | es wächst keine Anforderung, fällt keine Entscheidung und ändert sich kein emittiertes Byte — die drei Fähigkeiten liegen (§1) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**`open` → `next`:** keine Vorbedingung — die Kommandos aus §1 sind ohne Rückfrage nachfahrbar,
und keine der drei Fähigkeiten wartet auf eine Entscheidung.

**Zwei weitere offene Pläne stehen auf derselben Datei; die Naht ist eine Form-Grenze, keine
Reihenfolge.** [slice-191](slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md) schreibt
den **Pfad-Baum** in §6 und hält ihn mit einem Wächter;
[slice-111](slice-111-was-ein-bootstrap-anlegt-steht-in-der-nutzerdoku.md) beschreibt die
**Erfassungsschicht** als Fähigkeit und zieht §5 und §9 dazu nach. Dieser Slice beschreibt drei
**andere** Fähigkeiten und fasst den Baum nicht an. Läuft er als erster, findet der Nachbar seine
Prosa vor und ersetzt sie nicht; läuft er als letzter, schreibt er in einen bereits vollständigen
Baum. **Dieser Slice schreibt in keinen der beiden fremden Pläne.**

**Start** (`next` → `in-progress`): Implementer übernimmt, WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): falls sich zeigt, dass eine der drei
  Fähigkeiten keinen Absatz braucht, sondern einen eigenen Aufgaben-Abschnitt mit durchgespieltem
  Beispiel (wie `add-lang` einen hat). Drei Aufgaben-Kapitel sind kein Slice mehr; dann trennt ein
  Re-Schnitt sie, und jedes hat für sich Liefer-Wert.
- `in-progress` → `open` (blockiert — Carveout?): falls die Herkunfts-Aussage aus DoD (2) am Text
  nicht zu halten ist — [`ADR-0006`](../../adr/0006-durchsetzung-commands-tool-als-quelle.md)
  §Abgrenzung Punkt 2 ordnet dem Skill seine **Quelle** zu (Kurs-Satz statt Tool), nicht sein
  Verhalten beim Wiederholungs-Lauf. Zeigt der Bestand, dass §4 des Handbuchs ihn anders behandelt
  als der Satz sagt, steht eine Entscheidung aus, und dieser Slice ist nicht ihr Ort.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **(a)** die *Rot*-Sätze aus §2 sind mit den Kommandos aus §1 erneut
gemessen und die Ausgabe steht in der Closure-Notiz — die zwei Null-Zahlen sind positiv, und die
Fundzeilen der Command-Namen liegen nicht mehr allein hinter `## 11.`; **(b)** `make gates` grün.

Dazu: DoD vollständig; Review konform (Modul 10); Verifikation bestätigt (Modul 11); jedes Risiko
aus §6 mit Ausgang; Closure-Notiz mit Steering-Loop-Lerneintrag; `git mv` nach `done/` als eigener
Move-Commit. Den Abschluss schreibt der **Planner** in frischem Kontext
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Beschreibung altert ohne Wächter.** Genau so ist der heutige Zustand entstanden: die
  Emission wuchs, der Text stand still. Drei Absätze mehr sind drei Stellen mehr, die driften
  können, und §2 sagt selbst, dass kein Gate sie hält. Der naheliegende Sensor — jede `LH-*`-Zusage
  hat eine Entsprechung in [`docs/user/`](../../../../docs/user) — ist hier **nicht** gebaut: er
  bräuchte erst ein Kriterium, was als *beschrieben* zählt, und das ist ein Urteil, kein Muster.
  Die Klasse führt
  [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md).
  — **Ausgang:** <offen>
- **Die Beschreibung kann mehr zusagen als das Ziel liefert.** Wer
  [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) liest und
  daraus die Durchsetzungsschicht beschreibt, schreibt `CLAUDE.md` mit hinein — der Vertrag nennt
  sie, der Bestand kennt sie nicht (unten). Das Handbuch beschreibt den **Ist-Stand**; eine Zeile
  über eine nicht angelegte Datei wäre dieselbe Klasse Fehler wie das heutige Schweigen, nur mit
  umgekehrtem Vorzeichen. — **Ausgang:** <offen>
- **Drei offene Pläne auf einer Datei.** §4 zieht die Form-Grenze, aber sie ist eine Absprache im
  Text und kein Mechanismus; wer zwei davon nebeneinander fährt, löst Konflikte von Hand.
  Die Klasse führt
  [`BEO-ALL/ueberholter-offener-plan-ohne-genormten-ausgang`](../observations/BEO-ALL/ueberholter-offener-plan-ohne-genormten-ausgang/observation.md).
  — **Ausgang:** <offen>

**Nicht in diesem Slice — zwei Doku-Nachbarn.** Die Erklärung der **Erfassungsschicht**
([`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)) liegt bei
[slice-111](slice-111-was-ein-bootstrap-anlegt-steht-in-der-nutzerdoku.md), die **Pfad-Aufzählung**
des Baums bei
[slice-191](slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md). Beide sind bereits
geschnitten; dieser Slice fügt ihnen nichts hinzu und nimmt ihnen nichts weg.

**Nicht in diesem Slice — zwei Soll/Ist-Deltas, und beide sind der Normalfall.** Sie sind vom
selben Typ und vom Typ der drei DoD-Punkte **verschieden**: Dort **existiert** der Bestand und der
Ist-Text schweigt darüber — das ist der Defekt, den dieser Slice behebt. Hier nennt das Zielbild
etwas, das der Bestand nicht führt, und das ist keiner. Drei Dokumentklassen, drei Zeit-Domänen:
[`spec/`](../../../../spec) sagt, was gelten **soll**, [`docs/user/`](../../../../docs/user) sagt,
was **ist**, und `docs/plan/planning/` sagt, **wann** es kommt. Ein Abstand zwischen dem ersten
und dem zweiten ist die Aufgabe des Zielbilds, nicht sein Mangel; die Soll/Ist-Inventur macht ihn
**sichtbar**, sie beseitigt ihn nicht. **Für diesen Slice folgt daraus eine Regel und sonst
nichts:** Das Handbuch beschreibt beides **nicht** — weder als vorhanden noch als geplant. Ein
Handbuch bildet den Ist-Zustand ab und trägt keine Vorschau.

1. **Die Sprachenliste** in
   [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4). Das Zielbild
   nennt sechs Sprachen, der Generator führt zwei Profile:

   ```sh
   grep '^\*\*Unterstützte Sprachen:\*\*' spec/lastenheft.md | grep -oE '`[a-z]+`' | wc -l   # 6
   sed -n '/^func profiles/,/^}$/p' internal/gen/gen.go | grep -cE '^\t\t"'                  # 2
   ```

   **Keine Erwartungswerte**
   ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 2) — beide wandern, die erste mit dem Zielbild, die zweite mit dem Generator. Beide
   Seiten sind richtig: Die Liste sagt, welche Sprachen das Werkzeug tragen **soll**, und dass
   `cpp` darin steht **und** gebaut ist, ist kein Widerspruch — ein Zielbild wird nicht
   nachgeführt, wenn ein Teil davon existiert. Der Ist-Text des Handbuchs (*„Derzeit `go` und
   `cpp`"*) beschreibt die zwei Profile und bleibt, wie er ist; die vier übrigen Sprachen gehören
   dort in keiner Form hinein, auch nicht als Ausblick.
2. **`CLAUDE.md`** in
   [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren). Das
   Zielbild führt sie im Zielrepo; emittiert wird sie nicht, und keine Vorlage trägt sie:

   ```sh
   git grep -c 'CLAUDE\.md' -- 'internal/emit/*.go' 'cmd/**' | wc -l                    # 0 Dateien
   find .harness/baseline/v6.0.0/templates -iname '*CLAUDE*' | wc -l                     # 0
   grep -c '`CLAUDE\.md` (falls vorhanden)' internal/emit/templates/commands/plan-welle.md   # 1
   ```

   **Auch hier tragen beide Seiten**, und dieselbe Anforderung sagt, warum sie sich nicht
   widersprechen: `CLAUDE.md` ist dort ein **Briefing** wie `AGENTS.md` und damit *„**autort**,
   nicht tool-generiert"* (`grep -c 'autort\*\*, nicht tool-generiert' spec/lastenheft.md` → `1`).
   Ein Zielrepo **soll** eine haben; sie entsteht nicht aus dem Bootstrap. Das dritte Kommando
   zeigt dieselbe Linie im **emittierten** Command, das im Konditional über die Datei spricht,
   und [`ADR-0006`](../../adr/0006-durchsetzung-commands-tool-als-quelle.md) §Abgrenzung Punkt 3
   führt sie als **benannte Lücke**. **Für das Handbuch heißt das:** Es beschreibt den Bestand,
   und `CLAUDE.md` steht nicht darin.

**Ein Defekt steht daneben, und er ist von beiden verschieden.**
[`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) sagt
*„`cpp` … **folgt**"* — eine **Liefer-Aussage** in einem Soll-Dokument, also Plan am falschen Ort;
dass sie zusätzlich nicht mehr stimmt, ist die Folge und nicht der Grund. Sie ist gemessen und hat
keinen eigenen Träger: Der Plan, der sie trug, ist als eigener Vorgang verworfen — die Korrektur
ist ein Satz und fährt mit dem nächsten Lauf mit, der `spec/` anfasst. Dieser Slice fasst
`spec/` nicht an (§3).

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
[`docs/user/`](../../../../docs/user) liegt darunter und trägt die einzige geänderte Datei.
`harness/tools/`, `.codex/` und der Emitter sind **nicht** berührt: dieser Slice ändert kein
ausführbares Artefakt.

**Vorgelagert — offene Beobachtungen sichten:** Die Ablage
[`observations/`](../observations/README.md) ist durchgegangen; je Slug die Zahl der
`evidence/`-Dateien und die erste Zeile seiner `state.md`:

```sh
for s in zusage-neben-geaenderter-ableitung-bleibt-stehen \
         ueberholter-offener-plan-ohne-genormten-ausgang \
         zusage-nennt-sensor-der-form-nicht-sieht \
         out-of-scope-und-doku-dod-widersprechen-sich \
         slice-plan-umfang-waechst-ueber-umsetzung-hinaus \
         benannte-luecke-ohne-ausgang; do
  d="docs/plan/planning/observations/BEO-ALL/$s"
  echo "$s $(ls "$d/evidence" 2>/dev/null | wc -l)x $(head -1 "$d/state.md")"
done
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die sechs Einträge des Kommandos berühren diesen Slice; weitere Treffer: keine.

- [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  — **der Gegenstand.** Drei Emissionen sind entstanden, der Text daneben stand still. **Benannt,
  nicht gezählt:** der Beleg entsteht bei der Closure, nicht bei der Planung.
- [`ueberholter-offener-plan-ohne-genormten-ausgang`](../observations/BEO-ALL/ueberholter-offener-plan-ohne-genormten-ausgang/observation.md)
  — **berührt, Zuordnung offen.** Mit diesem Plan stehen drei offene Ansprüche auf einer Datei
  (§4). Der Anlass des Eintrags ist ein Versions-Sprung, hier ist es ein dritter Schnitt auf
  dieselbe Fläche; ob das dieselbe Beobachtung ist, entscheidet der Lauf, der den Beleg schreibt —
  eine unveränderliche `observation.md` wird dafür nicht gedehnt.
- [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  — berührt, **nicht getroffen**: dieser Slice sagt keinen Sensor zu. §2 nennt die Lücke
  ausdrücklich, statt einen Wächter zu behaupten, der Prosa nicht sieht.
- [`out-of-scope-und-doku-dod-widersprechen-sich`](../observations/BEO-ALL/out-of-scope-und-doku-dod-widersprechen-sich/observation.md)
  — berührt, weil §6 eine Out-of-Scope-Grenze neben drei Doku-DoD-Punkte stellt. **Nicht
  getroffen:** die Gegenstände sind disjunkt — die DoD beschreibt Artefakte, die im Bestand
  liegen, die Grenze schließt zwei aus, die nur im Zielbild stehen, und §6 sagt, welches welches
  ist. Beide Male entscheidet dieselbe Frage: Steht es im Bestand?
- [`slice-plan-umfang-waechst-ueber-umsetzung-hinaus`](../observations/BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus/observation.md)
  — berührt durch die Anlage eines weiteren Plans. **Nicht getroffen:** der Umfang ist geteilt
  statt gewachsen — die Fähigkeits-Hälfte steht hier, die Pfad-Hälfte bleibt in
  [slice-191](slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md), und die
  Beweisführung ist ein Kommando-Block statt einer Herleitung.
- [`benannte-luecke-ohne-ausgang`](../observations/BEO-ALL/benannte-luecke-ohne-ausgang/observation.md)
  — berührt, weil §2 eine Grenze benennt und §6 zwei. **Nicht getroffen:** der Eintrag misst
  Grenz-Beschreibungen in einem **lebenden** Artefakt im Pflicht-Lesepfad; diese hier stehen in
  einem Plan, den der Prozess nach `done/` legt. Die zwei aus §6 sind zudem keine Lücken, sondern
  ein Abstand zwischen zwei Dokumentklassen, den keine Seite schließen soll.

**Zwei Einträge nahe der Schwelle sind geprüft und nicht berührt:**
`re-baseline-ohne-inventur-slice` und `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`
binden ihre Identität je an einen Baseline-Sprung; dieser Slice bewegt keinen Baseline-Stand und
liest keine Fassung gegen eine andere.

**Alle berührten Sub-Areas GF.** Der Modus-Begründungsblock entfällt damit (§Umfang oben); `*`
steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) als
Greenfield, und dieser Slice führt keine neue Sub-Area ein.
