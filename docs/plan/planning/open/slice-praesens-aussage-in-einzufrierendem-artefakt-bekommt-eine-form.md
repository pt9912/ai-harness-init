# Slice slice-praesens-aussage-in-einzufrierendem-artefakt-bekommt-eine-form: Die Präsens-Aussage über ein lebendes Artefakt bekommt eine Form, bevor sie einfriert

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case. Die Kennung selbst nennt keine einfrierende
Datei: sie steht hier als **Träger** der Beobachtung
[`BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form`](../observations/BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form/observation.md),
deren Ausgang `geplant` sie ist.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Schnitt-Test aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, alle drei Fragen beantwortet: **Bündel?** Nein — ein Norm-Text und die Frage nach dem
Sensor, kein zweiter Slice, auf den er wartet. **Gemeinsames Closure-Kriterium?** Nein — jedes wäre
die Abschrift seiner eigenen DoD. **Auslöser reaktiv oder gewollt?** Reaktiv: die dritte Beobachtung
hat die Schwelle mit einem fremden Vorgang erreicht und ihren Ausgang erhalten. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Bezug:**
[`ADR-0055`](../../adr/0055-abgeschaffte-kennung-verlaesst-die-fitness-function-als-teil-abloesung.md)
(**Accepted** — ihr §Konsequenzen nennt die Klasse mit **3×** erreicht und übergibt den Ausgang dem
Lese-Schritt; ihr Re-Evaluierungs-Trigger 3 — *„Wenn die Klasse *„Präsens-Aussage in einem
einfrierenden Artefakt"* eine Form bekommt, ist zu prüfen, ob diese Datei sie trägt oder von ihr
abgelöst wird"* — fällt mit diesem Vorgang an),
[`ADR-0049`](../../adr/0049-ausgang-traegt-die-benannte-luecke.md) (**Accepted** — Festlegung 2: wo
kein Zielort steht, schneidet der Lese-Schritt einen Träger und nennt seine Kennung),
[`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(**Accepted** — die Kennung einer Beobachtung **ist** der Pfad `BEO-<KUERZEL>/<slug>`),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl dieses Plans steht neben dem Kommando, das sie liefert),
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(eine Baseline-Aussage nennt ihren Tag),
[`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
(die nächste Nachbarklasse: die Präsens-Aussage über den vendored Baum — sie nimmt `docs/plan/adr/`
ausdrücklich aus, und genau dort fällt diese Klasse an),
[`AGENTS.md`](../../../../AGENTS.md) §3.4 (die einfrierende Grenze), §3.7 (was ein Satz trägt),
§3.8 (der Norm-Text gehört dem Architect), §3.11 (die eingefrorene Adresse),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Artefakt, das eine Geltung behauptet, die niemand mehr halten darf, sagt mehr zu als es hält).

**Berührte Spec-Stellen:** `—`. Der Slice schreibt eine Schreib-Regel für Norm-Artefakte; kein
Zielelement der Spec-Straten wird angefasst.

**Verantwortlich:** `—` bis zur Priorisierung. Die zwei Liefer-Punkte liegen nach
[`AGENTS.md`](../../../../AGENTS.md) §3.8 beim **Architect**: der Norm-Text einer Hard Rule oder eines
Adaptions-Eintrags gehört der Rolle, die diese Datei schreibt.

**Autor:** Planner. **Datum:** 2026-09-16.

---

## 1. Ziel und Abgrenzung

<!-- BEDIENHINWEIS: Ziel = ein Satz, Liefer-Fokus, kein "wir machen
aufraeumen". Abgrenzung = je Punkt eine Begruendung, nicht nur eine Nennung:
ein Ausschluss ohne Grund ist eine Behauptung. Keine Mindestzahl — ein echter
Ausschluss ist besser als vier erfundene. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Für die Präsens-Aussage über ein repo-eigenes **lebendes** Artefakt in einem Text, der nach
[`AGENTS.md`](../../../../AGENTS.md) §3.4 einfriert, steht **eine Form**: was der Satz nennen darf —
den Zustand und einen auflösbaren Anker — und was nicht — eine Aussage, die sich mit dem nächsten
Lauf ändert und danach niemand mehr berichtigen darf. Die Form hält den drei gemessenen Fällen
stand, die sie verlangen.

**Der Gegenstand ist die Form, nicht ihre drei Fälle.** Die Belege stehen im Register
([`BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form`](../observations/BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form/observation.md),
3×); sie sind drei **Varianten** derselben Sache und werden hier nicht wiederholt — der Plan nennt
die Belege, nicht ihren Text.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die drei bestehenden Stellen.** Sie stehen in `Accepted`-ADRs und sind nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefroren; eine Form wirkt **ab ihrer Einführung** und
  zieht keinen Bestand nach. Wie groß dieser Bestand ist, sagt ein Kommando, keine Schätzung:

  ```sh
  for f in docs/plan/adr/0*.md; do grep -q '^\*\*Status:\*\* Accepted' "$f" || continue; \
    n=$(grep -c 'steht auf `Proposed`' "$f"); [ "$n" -gt 0 ] && echo "$f"; done | wc -l   # 14
  ```
- **Die Erkennungs-Seite.** Welche Formen ein Werkzeug als Zitat erkennt und wie es lebt von
  eingefroren als Fundliste führt, ist ein eigener Gegenstand und liegt nach
  [`MR-059`](../../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang)
  Setzung 2 in dem Vorgang, der die Fundliste führt — dieser Slice schreibt keine Erkennung.
- **Die Ausdehnung auf die emittierte Ebene.** Ob ein **Ziel**-Repo dieselbe Form braucht, hängt an
  seiner eigenen Baseline-Fassung; die Form für dieses Repo zu setzen ist der kleinere Vorgang, und
  wer beides in einen Satz nimmt, entscheidet für zwei Verträge gleichzeitig.

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

<!-- BEDIENHINWEIS: je Zeile ein pruefbares Kriterium. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **Die Form steht an einem Zielort, und sie hält den drei gemessenen Fällen stand.** Ein
      Norm-Artefakt sagt, was eine Präsens-Aussage über ein lebendes Artefakt in einem einfrierenden
      Text nennen darf — den **Zustand** und einen **auflösbaren Anker** — und was nicht; die drei
      Belege des Registers sind gegen sie gehalten, und jeder ist einer der drei Varianten
      (Zustand · Ablauf · Zeitform) zugeordnet. Der Beleg ist der gelesene Zielort, nicht der Satz,
      der ihn ankündigt.
- [ ] **Der Zielort nennt seine Grenze.** Ob ein Sensor die Form halten kann, ist an **einem**
      gemessenen Fall entschieden und steht dort: entweder der Sensor samt seinem gelisteten Zahn in
      `test/mutations/` ([`AGENTS.md`](../../../../AGENTS.md) §3.6), oder die benannte Lücke in der
      Form des Absatzes *„Ein Wächter existiert nicht"*. Beide Ausgänge sind zulässig — die
      Auslassung nicht.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: der Zielort aus Liefer-Punkt 1 **ist** das Doku-Artefakt — eine Hard Rule in
      [`AGENTS.md`](../../../../AGENTS.md) §3 oder ein Adaptions-Eintrag unter
      [`harness/conventions/`](../../../../harness/conventions/) —; der Punkt ist mit ihm erfüllt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

<!-- BEDIENHINWEIS: Datei- oder Komponenten-Ebene reicht; der
Implementer-Agent erweitert die Liste in seinem ersten Lauf, inklusive
einer Testdatei-Zeile mit der Akzeptanzkriterien-ID in `Begründung`
(Modul 9 §Minimal Agent Workflow). -->

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`AGENTS.md`](../../../../AGENTS.md) | update | **Erster Zielort-Kandidat:** die Hard Rule, die sagt, was ein Satz trägt — die Form für eine Präsens-Aussage über ein lebendes Artefakt gehört neben `§3.7`/`§3.11`. Der Norm-Text gehört nach §3.8 dem Architect |
| [`harness/conventions/`](../../../../harness/conventions/) | neu **oder** — | **Zweiter Kandidat:** ein Adaptions-Eintrag, wenn die Form eine Abweichung von der Baseline ist statt eine Ergänzung; die Wahl zwischen den zwei Orten ist Teil der Entscheidung, nicht dieses Plans |
| [`docs/plan/adr/`](../../adr/) | neu | **Nur falls die Form Alternativen hat, die eine Entscheidung brauchen** — dann trägt die ADR sie; sonst entfällt die Zeile |
| [`.d-check.yml`](../../../../.d-check.yml) und `test/mutations/*` | update / neu | **Nur Liefer-Punkt 2, obere Verzweigung:** trägt ein Modul die Form, kommt sein gelisteter Zahn dazu; fällt die Verzweigung, steht die Grenze als Prosa am Zielort |
| `docs/plan/planning/observations/BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form/` | update | `state.md` wechselt mit dem Abschluss von `geplant` auf `verkörpert` (Zielort + Herkunfts-Anker `seit slice-praesens-aussage-in-einzufrierendem-artefakt-bekommt-eine-form`) |

**Der Unterschied ist der des Gegenstands.** Der Plan nennt **Kandidaten**, nicht eine Festlegung:
welcher der zwei Norm-Orte trägt, entscheidet der Lauf, der die Form schreibt — die ADR-Praxis
dieses Repos trennt *Regel* von *Abwägung*, und eine Form für einen Satz ist eine Regel (Präzedenz:
`§3.7` und `§3.11` stehen als Hard Rules, ihre Abwägungen in den ADRs).

## 4. Trigger

<!-- BEDIENHINWEIS: Beispiele — "Wenn Welle X done." / "Wenn Carveout CO-NN
aufgeloest." -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **der Vorgang ist priorisiert** (`Verantwortlich:` gesetzt — die
Rolle, die den Norm-Text schreibt) **und das WIP-Limit ihres Rolleninhabers ist frei**. Eine
Vorbedingung aus dem Gegenstand gibt es nicht: die drei Belege liegen im Register, ihre Träger sind
eingefroren, und die Form steht ausdrücklich **neben** ihnen statt an ihrer Stelle.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Form, die Prüfung der drei
  Varianten **und** die Sensor-Frage zusammen nicht in einer Review-Sitzung prüfbar sind — dann ist
  an der Sensor-Frage zu schneiden, sie ist der Teil, der Umfang mitbringt.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Form eine **Änderung an einer
  einfrierenden Entscheidung** verlangt (etwa an der Sektion *Der Acceptance-Trigger* der
  ADR-Vorlage) — dann gehört erst diese Entscheidung, und sie ist eine ADR, kein Satz in einer Hard
  Rule.

## 5. Closure-Trigger

<!-- BEDIENHINWEIS: z.B. "DoD vollstaendig + PR gemerged + Closure-Notiz
geschrieben." -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig, `make gates` grün, Closure-Notiz mit Steering-Loop-Lerneintrag.

**Dazu eine Pflicht, die an einer fremden Entscheidung hängt:**
[`ADR-0055`](../../adr/0055-abgeschaffte-kennung-verlaesst-die-fitness-function-als-teil-abloesung.md)
Re-Evaluierungs-Trigger 3 ist mit diesem Vorgang fällig — *„Wenn die Klasse *„Präsens-Aussage in
einem einfrierenden Artefakt"* eine Form bekommt, ist zu prüfen, ob diese Datei sie trägt oder von
ihr abgelöst wird."* Der Abschluss nennt das Ergebnis: **bestätigt** oder **Folge-ADR**. Ohne diese
Zeile schließt der Vorgang mit einem Trigger, dessen Bedingung er selbst erfüllt.

## 6. Risiken und offene Punkte

<!-- BEDIENHINWEIS: Was koennte schief gehen? Welche Carveouts entstehen
ggf.? Die drei Ausgaenge stehen als Form in der Zeile darunter. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Form wird aus den drei Fällen hergeleitet statt entschieden.** Die Belege sind drei
  **Varianten** — Zustand · Ablauf · Zeitform —, und eine Form, die nur der ersten folgt, läßt die
  zwei anderen weiter zu. Die drei sind dann je einzeln benannt und keiner ist getragen. —
  **Ausgang:** <…>
- **Die Form friert selbst ein und nennt ihre Grenze nicht.** Ob ein Sensor sie halten kann, ist die
  zweite Hälfte; bleibt sie unausgesprochen, wiederholt der neue Norm-Text die Klasse eine Ebene
  höher — eine Aussage über eine Deckung, die niemand hält
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). —
  **Ausgang:** <…>
- **Der Zielort wächst über den Gegenstand.** Eine Fassung des ganzen `§3.7`-Bereichs wäre ein
  anderer Vorgang; die Form gilt **einer** Satz-Klasse, und ein Eintrag, der den Bestand daneben
  räumt, hat die §1-Ausschlüsse verlassen. — **Ausgang:** <…>

## 7. Closure-Notiz

<!-- BEDIENHINWEIS — keine Norm; faellt beim Kopieren weg (README.md
§Verwendung, Schritt 5) und darf deshalb nichts Tragendes halten. Reihenfolge:
diese Sektion vor dem `git mv` nach done/ fuellen — einzige Ausnahme ist das
letzte DoD-Item in §2 (die Paarungen suchen in `done/`, also nach dem `git mv`).
Im Repo ohne Wellen-Betrieb braucht die Closure dadurch drei Commits: Inhalt,
`git mv`, Haekchen — das folgt aus der Hard Rule, es widerspricht ihr nicht. -->

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
  Auslöser: `BEO-<NNN>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist **eine** Sub-Area: `*` (gesamtes Repo). Ihr
Gegenstand sind die Norm-Artefakte dieses Repos — `AGENTS.md` §3, der Adaptions-Block, die ADRs —,
und keine der beiden anderen deklarierten Sub-Areas trägt ihn: `harness/tools/` ist die Pfad-Familie
der ausführbaren Helfer, `.codex/` eine Hook-Familie. `*` steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) und
erfüllt das Inklusionskriterium.

**Vorgelagert — offene Beobachtungen sichten:** das Register ist durchgegangen; die Stände sind
gemessen, nicht abgelesen ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2):

```sh
for s in praesens-aussage-in-einzufrierendem-artefakt-ohne-form \
         abgeschaffte-kennung-in-unveraenderlichem-artefakt zitat-grep-uebersieht-zeilenumbruch-und-markup; do
  printf '%-64s %s\n' "$s" "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)"
done
```

**Keine Erwartungswerte** — jeder Stand wandert mit der nächsten Closure. Drei berühren diesen Slice;
**einer** trägt ihn:

- **`praesens-aussage-in-einzufrierendem-artefakt-ohne-form` (3×, `geplant`)** — **der Gegenstand
  dieses Slice**: die Kennung in seiner `state.md` ist die dieses Plans. Der Eintrag ist damit der
  erste, der bei seinem Übertritt einen Träger bekommt, statt eine Closure zu überleben.
- **`abgeschaffte-kennung-in-unveraenderlichem-artefakt` (1×, unter der Schwelle)** — die
  Nachbarklasse, und die Grenze ist gemessen: sie handelt von einer **Adresse**, die nicht mehr
  auflöst; hier löst die Adresse auf und die **Aussage** ist die, die altert. Die Abgrenzung steht in
  beiden `observation.md`.
- **`zitat-grep-uebersieht-zeilenumbruch-und-markup` (3×, `geplant`)** — berührt nur die Frage, mit
  welchem Werkzeug die drei Belege gefunden wurden; dieser Slice führt keine Fundliste, er schreibt
  eine Form.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.
