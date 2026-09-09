# Slice slice-207: Die MR-Paraphrase der Anweisungssätze bemerkt den Drift ihrer Quelle

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Baseline-Test ist das *Mehr*
(`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht): eine beobachtbare
Closure-Bedingung, die mehr beobachtet als die DoD dieses Slice. Es gibt keine —
der neue Sensor läuft in `make gates`, und `make gates` grün steht in der DoD.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(der Sensor nennt seinen Prüfbereich, statt ihn zu behaupten),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(hermetisch, kein Host-Paketmanager, kein Netz),
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)
(rank-1-Grund für die Abgrenzung gegen die emittierte Ebene: dort ist der
MR-Block ein *adaptierbarer* Marker),
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
(wem die drei Dateien gehören — die Vorbedingung des Zuschnitts),
[ADR-0023](../../adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md)
(Festlegung 2 trägt die Tag-Normalisierung, Festlegung 4 bindet jeden Sensor,
der einen `<tag>`-tragenden Bestand liest),
[`MR-045`](../../../../harness/conventions.md#mr-045)
(der Adaptions-Block läuft in der Verzeichnis-Form — eine gepinnte Quelle ist
eine Datei, die per `git mv` wandern kann),
[`MR-025`](../../../../harness/conventions.md#mr-025)
(jede Zahl unten steht neben dem Kommando, das sie liefert),
[`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
(die Klasse; dieser Slice trägt eine ihrer Unterklassen).

**Berührte Spec-Stellen:** `—`. Der Slice legt einen repo-internen Wächter an;
die emittierte Ebene bleibt unberührt (§1 Abgrenzung), und damit ändert sich
keine Zusage des Technik- oder Sicht-Stratums.

**Verantwortlich:** `—` bis zur Priorisierung (Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine). Die Arbeit liegt
vollständig in `harness/tools/`, im `Makefile` und in `test/` — nach
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
Festlegung 1 kein Anweisungssatz-Artefakt, also **Implementer**.

**Autor:** Planner. **Datum:** 2026-09-09.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein hermetischer Sensor bemerkt, wenn sich die Quelle einer
MR-Paraphrase in den drei Anweisungssätzen unter `.claude/commands/` ändert,
ohne dass die Paraphrase nachgezogen wurde — **Erkennung, keine Korrektur**.
Der Erfolg ist ein rotes Gate, nicht ein automatisch umgeschriebener Text.

**Der Anlass, gemessen.** Die drei Dateien tragen einen Abschnitt, dessen
Überschrift auf `harness/conventions.md` — den MR-Block — zeigt und dessen
Aufzählungspunkte dessen Substanz zusammenfassen. Nach
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
Festlegung 2 ist diese Destillation erlaubt: sie setzt keine neue Norm, sie
fasst bestehende zusammen. Nur zieht sie niemand nach, und **die Quelle bewegt
sich rund achtmal so oft wie die Zusammenfassung** — beide Zahlen wandern mit
dem Bestand, sie sind keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025)):

```sh
git log --format=%H -- harness/conventions.md harness/conventions/ | wc -l   # 127
git log --format=%H -- .claude/commands/implement-slice.md | wc -l           #  15
LETZT=$(git log -1 --format=%H -- .claude/commands/implement-slice.md)
git log --format=%H "$LETZT"..HEAD -- harness/conventions.md harness/conventions/ | wc -l   # 3
```

Der Prüfbereich ist **kein Namensliste, sondern eine beobachtbare Eigenschaft**:
die Überschrift, die den MR-Block als Quelle nennt. Sie trifft heute genau drei
Dateien, je einmal, und keine davon liegt in einem Zeitdokument oder im
vendored Baum:

```sh
git grep -lF -- '(harness/conventions.md — MR-Block)' -- '*.md' ':!.harness/baseline'
# .claude/commands/close-welle.md · implement-slice.md · plan-welle.md   (3 Dateien, 13 Aufzählungspunkte)
```

**Zwei naheliegende Wege sind gemessen und scheiden aus.** Das Modul
`citations` des Doku-Gates prüft ein **Verbatim-Zitat** gegen seine
Quell-Spanne; eine Paraphrase ist keines, und der Bestand trägt null
funktionale Direktiven (`git grep -c '<!-- d-check:cite' -- '*.md'
':!.harness/baseline'` findet drei Treffer, alle drei Prosa **über** die
Direktive, keiner eine). `check-lines` — über `codepaths` bereits aktiv —
prüft, dass eine Zeilen-Spanne existiert und in Bounds liegt, nicht, dass ihr
Inhalt derselbe geblieben ist.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Wort der drei Anweisungssätze wird umgeschrieben, und keine Datei
  unter `.claude/commands/` wird angefasst.** Der Sensor führt seine Paarungen
  in einer eigenen Datei neben sich; die Anweisungssätze bleiben Byte für Byte,
  wie sie sind. Das ist die tragende Selbstbindung dieses Slice: zwei der drei
  Dateien gehören nach
  [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  Festlegung 1 dem **Planner**, nicht der Rolle, die diesen Slice ausführt —
  und sie ist beim Review in einem `git diff --stat` sofort prüfbar
  (Schicht-Abgrenzung).
- **Findet der Lauf beim Pinnen, dass eine Paraphrase ihre heutige Quelle schon
  nicht mehr trifft, repariert er sie nicht — er berichtet sie.** Der Pin friert
  *die Quelle* ein, nicht die Richtigkeit der Zusammenfassung; wer beides
  vermengt, schreibt beim Anlegen eines Wächters fremden Text um. Der Befund
  geht als Übergabe-Artefakt an die besitzende Rolle (anderer Vorgang).
- **Die emittierte Ebene bleibt außen vor** — `internal/emit/templates/commands/`
  trägt denselben Abschnitt mit der Überschrift *„(ANPASSEN an dein Repo)"*.
  [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)
  führt den MR-Block dort ausdrücklich als **adaptierbaren** Marker; ein Pin
  gegen unser `harness/conventions/` wäre im Zielrepo eine tote Adresse. Die
  Trennung ist mechanisch, nicht nach Pfadliste: die zwei Überschriften sind
  verschieden (Schicht-Abgrenzung).
- **Jede weitere Datei, die MR-Substanz paraphrasiert, ohne diese Überschrift zu
  tragen, bleibt bewusst ungeprüft.** Ob ein beliebiger Absatz „MR-Substanz
  zusammenfasst", ist ein Urteil und kein Muster — kein `grep` entscheidet es.
  Ein Sensor darüber wäre eine Zusage, die weiter reicht als ihre Abdeckung
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Bestand bleibt stehen, benannt.
- **Kein Produkt-Code, keine ADR, kein `harness/conventions.md` und kein
  Eintrag darunter.** Der Adaptions-Block und die Hard Rules gehören dem
  Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8); der Slice **liest** sie
  und schreibt sie nicht (Schicht-Abgrenzung).

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

**Liefer-Punkt (1) — der Sensor.**

- [ ] Ein neues `make`-Ziel fährt den Prüfer **hermetisch** (bash + coreutils,
      kein Docker, kein Netz, kein Host-Paketmanager —
      [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
      [`AGENTS.md`](../../../../AGENTS.md) §3.9) und hängt in `record-gates`.
      Seine letzte Zeile **nennt** den eigenen Prüfbereich als Zahlen —
      geprüfte Dateien · geprüfte Paarungen · Befunde —, statt Vollständigkeit
      zu behaupten
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6);
      dieselbe Form wie die „N Datei(en) geprueft"-Zeile von
      `harness/tools/comment-claims.sh`).
- [ ] Der Prüfbereich entsteht aus der **Eigenschaft**, nicht aus einer
      Pfadliste: jede getrackte `.md` außerhalb von `.harness/baseline/`, deren
      Abschnitts-Überschrift `(harness/conventions.md — MR-Block)` enthält. Der
      Lauf belegt, dass die Menge heute die drei Dateien aus §1 ist.

**Liefer-Punkt (2) — die Deklaration, fail-closed in beide Richtungen.**

- [ ] Eine Datei neben dem Prüfer führt je Aufzählungspunkt der drei Abschnitte
      eine Zeile: paraphrasierende Datei · die fett gesetzte Punkt-Anrede ·
      Quell-Pfad · gepinnter, tag-normalisierter sha256. **Alle 13 Punkte sind
      erfasst.** Ein Punkt, dessen Substanz keinen MR-Eintrag als Quelle hat,
      trägt statt eines Pfades ein `—` **und den Träger, der ihn stattdessen
      hält** — gemessen betrifft das den Docker-only-Punkt, dessen Quelle
      [`AGENTS.md`](../../../../AGENTS.md) §3.9 ist und kein Eintrag des
      Adaptions-Blocks.
- [ ] Drei Befund-Klassen, jede fail-closed: eine Datei mit der Überschrift ohne
      Deklaration · ein Aufzählungspunkt ohne Zeile (auch nach Umformulierung
      seiner Anrede) · ein Quell-Pfad, der nicht existiert — Letzteres ist der
      `git mv` eines Eintrags nach `harness/conventions/done/`
      ([`MR-045`](../../../../harness/conventions.md#mr-045)) und darf nicht
      still grün bleiben.
- [ ] Vor dem Setzen jedes Pins ist die zugehörige Quelle **gelesen** und im
      Bericht steht je Paarung, ob die Paraphrase sie heute noch trifft. Ein
      Nein wird **berichtet, nicht repariert** (§1 Abgrenzung).

**Liefer-Punkt (3) — die Zähne, in drei Richtungen.**

- [ ] **Rot bei Substanz:** eine inhaltliche Änderung an einer gepinnten Quelle
      ohne Pin-Nachzug färbt das Ziel rot. Der Beleg ist real und
      reproduzierbar, nicht konstruiert — über den Substanz-Commit `e9343013`
      ([`MR-010`](../../../../harness/conventions.md#mr-010) bekommt eine
      Setzung) unterscheidet sich der **normalisierte** Digest, gemessen mit dem
      Kommando aus §3.
- [ ] **Grün beim legitimen Nachzug:** Quelle und Pin gemeinsam aktualisiert →
      grün. Der Sensor bestraft die Reparatur nicht, die er verlangt.
- [ ] **Grün beim Adress-Nachzug einer Re-Baseline** — die teure Gegenprobe:
      über den zwei gemessenen Sweep-Commits `faa8178d` und `7e05dca8`
      (45 bzw. 48 berührte Eintrags-Dateien) bleibt **jeder** normalisierte
      Digest gleich, während der rohe sich bei allen ändert. Ohne diese
      Eigenschaft erzeugte jeder Baseline-Sprung acht falsche Rote.
- [ ] Je Richtung ein Fall unter `test/mutations/` (Nummern im Anschluss an die
      höchste vergebene — `ls -1 test/mutations/*.sh | sed -n
      's#.*/\([0-9]*\)-.*#\1#p' | sort -n | tail -1` → **284**, beim Anlegen neu
      auszuzählen), dazu ein bats-Fall über der Normalisierungs- und der
      Vergleichs-Funktion.
- [ ] `make mutate` meldet für die **in diesem Slice angelegten** Fälle keinen
      `BEFUND`. Ein Befund an einem Fall, den dieser Slice nicht angelegt hat,
      ist ein eigener Vorgang und blockiert diese DoD nicht — er wird berichtet.

**Konstant je Slice — zählt nicht in die drei Liefer-Punkte.**

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: das neue Ziel steht in der Sensor-Tabelle von
      [`harness/README.md`](../../../../harness/README.md) §Sensors **mit seinen
      benannten Grenzen** und in der Gate-Tabelle von
      [`AGENTS.md`](../../../../AGENTS.md) §4. Beides ist Beschreibung eines
      vorhandenen Ziels, keine Hard-Rule- und keine Adaptions-Änderung
      ([`AGENTS.md`](../../../../AGENTS.md) §3.8 bindet §3 und den
      Adaptions-Block, nicht §4).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register fortgeschrieben, **falls dieser Slice einen
      Inventur-Fund auflöst** — Zeile mit Datum und auflösendem Artefakt nach
      *Aufgelöste Einträge* verschoben. **Entfällt hier:** Repos ohne
      Brownfield-Bootstrap haben die Datei nicht, und dieses führt sie nicht
      (`ls docs/plan/planning/reconciliation.md` → nicht vorhanden). Der Pfad
      steht als Kommando-Operand, weil die vendored Vorlage ihn als blanken
      Inline-Code führt und `codepaths` ihn dann als fehlendes Ziel meldet.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

**Die Bauform, entschieden statt offengelassen: Deklaration neben dem Prüfer,
Pin über dem tag-normalisierten Quell-Inhalt.** Vorbild ist die Pin-Mechanik,
die dieses Repo für fremde Inhalte schon fährt (`BASELINE_ZIP_SHA256`,
`DCHECK_DIGEST`): ein Hash wird eingefroren, ein Sensor hält den aktuellen
dagegen und bricht, bis jemand bewusst nachzieht.

**Warum normalisiert und nicht roh — gemessen, nicht vermutet.** Ein
Baseline-Sprung zieht die Navigations-Zeiger in **allen** Eintrags-Dateien nach
(`git show --pretty=format: --name-only 7e05dca8 | grep -c '^harness/conventions/'`
→ **48**), ohne eine einzige Aussage zu ändern; genau das verlangt
[ADR-0023](../../adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md)
Festlegung 2 (*„In änderbaren Artefakten bleibt der lokale Pfad ein
Navigations-Zeiger, und der Bump zieht ihn nach"*). Ein roher Hash läse das als
Drift. Die Normalisierung — jedes `baseline/v<X.Y.Z>` wird vor dem Hashen zu
`baseline/<tag>` — trennt beides, und beide Richtungen sind am Bestand geprüft:

```sh
norm() { sed -E 's|baseline/v[0-9]+\.[0-9]+\.[0-9]+|baseline/<tag>|g'; }
p=harness/conventions/MR-002-gate-nachweis-mechanik-und-claude-hooks.md
git show "7e05dca8^:$p" | norm | sha256sum        # Adress-Sweep: gleich
git show "7e05dca8:$p"  | norm | sha256sum        #   (roh: verschieden)
q=harness/conventions/MR-010-d-check-gate-fragment-tool-generiert.md
git show "e9343013^:$q" | norm | sha256sum        # Substanz-Aenderung: verschieden
git show "e9343013:$q"  | norm | sha256sum
```

Über beide Sweep-Commits blieb der normalisierte Digest bei **jeder** geprüften
Quelle gleich (acht Kandidaten über `7e05dca8`, zehn Stichproben über
`faa8178d`) — **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025)), die Zahlen wandern mit
dem Bestand.

**Was der Sensor nicht ist:** kein Sensor über dem `<tag>`-tragenden Bestand im
Sinne von
[ADR-0023](../../adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md)
Festlegung 4. Er urteilt über keine Tag-Nennung und verlangt an keiner eine
Änderung; die Normalisierung ist eine **Blindheit** gegenüber allen drei Klassen
gleichermaßen, nicht eine Trennung zwischen ihnen. Der Preis dieser Blindheit
steht als benannte Grenze in §6.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/` — der Prüfer <!-- d-check:ignore (geplante Datei) --> | neu | Träger von Liefer-Punkt (1); hermetisch wie `harness/tools/comment-claims.sh`, dessen `sha256sum`-Nutzung `harness/tools/working-tree-hash.sh` präzedenziert |
| `harness/tools/` — die Deklaration der Paarungen <!-- d-check:ignore (geplante Datei) --> | neu | Liefer-Punkt (2). Sie liegt **hier** und nicht in den Anweisungssätzen: so bleibt der Slice in einer Eigentums-Zone ([ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1), und kein `MR-`-Token gerät in eine gescannte `.md`, wo die Link-Pflicht griffe |
| `Makefile` | update | neues Ziel + Aufnahme in `record-gates` |
| `test/mutations/` — drei Fälle <!-- d-check:ignore (geplante Dateien) --> | neu | Liefer-Punkt (3); wer keinen Fall hat, gilt als unbewacht ([`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| `test/` — bats über Normalisierung und Vergleich <!-- d-check:ignore (geplante Datei) --> | neu | die Urteils-Funktionen ohne Repo-Lauf prüfbar halten |
| [`harness/README.md`](../../../../harness/README.md), [`AGENTS.md`](../../../../AGENTS.md) §4 | update | Sensor- und Gate-Tabelle; die Grenzen aus §6 stehen dort, nicht nur hier |
| `.claude/commands/*.md` | **unberührt** | §1 Abgrenzung: kein Byte. Beim Review an `git diff --stat` ablesbar |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): `in-progress/` trägt keinen `slice-*.md`
(WIP-Limit 1) und ein Implementer übernimmt. Keine Abhängigkeit auf einen
anderen Slice: der Prüfbereich, die Bauform und die zwei Gegenproben sind hier
gemessen, nichts davon wartet auf eine fremde Entscheidung.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Deklaration der 13
  Paarungen erzwingt eine Änderung an einer der drei Anweisungssätze — dann
  fällt eine Eigentums-Grenze in den Slice
  ([ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  Festlegung 1), und der Schnitt trennt in einen Implementer-Teil (Sensor +
  Deklaration) und einen Planner-Teil (die zwei wellen-eigenen Dateien).
- `in-progress` → `open` (blockiert — Carveout?): die Normalisierung trennt
  Adress-Nachzug und Substanz **nicht** sauber — etwa weil ein Sweep neben den
  Tags noch etwas anderes anfasst. Dann ist die Bauform widerlegt, und die Wahl
  zwischen einer feineren Pin-Einheit (ein benanntes Pflichtfeld statt der
  ganzen Datei) und dem Verzicht gehört vor die Umsetzung, nicht in sie.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien:

1. `make gates` ist grün **und** enthält das neue Ziel — nachweisbar daran, dass
   `record-gates` es als Vorbedingung führt und die Ausgabe des Laufs die
   Prüfbereichs-Zeile des Sensors trägt.
2. Der rot färbende Fall ist **einmal rot gesehen**
   ([`AGENTS.md`](../../../../AGENTS.md) §3.6) und liegt als Fall unter
   `test/mutations/`; `make mutate` zieht ihn und meldet für die in diesem Slice
   angelegten Fälle keinen `BEFUND`.

Dazu der Lerneintrag in §7 — eine der drei Formen (geschärfte Regel · neuer
Sensor · benannte Spec-Lücke). Der Ausgang jedes Risikos aus §6 steht dabei
fest, bevor die Datei nach `done/` wandert; den Abschluss schreibt der
**Planner** in frischem Kontext
([`AGENTS.md`](../../../../AGENTS.md) §3.10), nicht der Lauf, der gebaut hat.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

**Betriebskosten im Gate — bewusst entschieden, nicht nebenbei.** Das Ziel läuft
**in** `make gates`. Der Grund ist die Messung: die zwei Adress-Sweeps der
letzten Baseline-Sprünge röten es nicht, und eine *inhaltliche* Änderung an
einer gepinnten Quelle ist im Adaptions-Block ohnehin selten und abnorm — ein
Eintrag ist nach Annahme append-only, inhaltliche Bewegung heißt Kopf-Marke,
nachgetragenes Pflichtfeld oder `git mv` nach `done/`. Genau bei diesen drei
gehört die Paraphrase neu gelesen. Ein Ziel *neben* `make gates` — wie
`make mutate` — hätte keinen mechanischen Auslöser und liefe nie.

- **Die Normalisierung ist blind für einen Tag-Tausch innerhalb einer
  *datierten Aussage*** ([ADR-0023](../../adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md)
  §Kontext, Klasse 2). Wer eine Mess-Aussage von `v6.0.0` auf `v6.5.0` schreibt,
  ohne neu zu messen, bleibt grün. Das ist der Preis dafür, dass Klasse 1 nicht
  rötet — die Alternative wäre acht falsche Rote je Sprung.
  **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → Beobachtungs-Register>
- **Der Sensor sieht geänderte Quellen, nicht fehlende.** Ein *neuer*
  MR-Eintrag, dessen Substanz in die Paraphrase gehörte, erzeugt keinen Pin und
  damit kein Rot. Die Umkehrung bleibt Review-Arbeit — dieselbe Grenze, die
  `harness/tools/comment-claims.sh` in seinem Kopf für „trägt der genannte
  Sensor die Behauptung inhaltlich?" benennt.
  **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → Beobachtungs-Register>
- **Der Pin friert Übereinstimmung zum Pin-Zeitpunkt ein, und die behauptet der
  Lauf, statt sie zu beweisen.** Ist eine Paraphrase heute schon falsch, pinnt
  der Sensor sie falsch fest und bleibt grün. Gegenmittel ist das dritte
  DoD-Item von Liefer-Punkt (2) — je Paarung eine gelesene Aussage —, und das
  ist ein Urteil, kein Muster.
  **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → Beobachtungs-Register>
- **Ein vierter Anweisungssatz ohne diese Überschrift bleibt unsichtbar.** Der
  Prüfbereich hängt an der Überschriften-Zeichenkette; wer einen neuen Command
  mit einem anders betitelten Adaptions-Abschnitt schreibt, bekommt keinen
  Wächter und keine Meldung darüber.
  **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → Beobachtungs-Register>
- **Die Deklarations-Datei könnte in den Prüfbereich des Doku-Gates geraten.**
  Sie trägt `MR-`-Token in Quell-Pfaden; läge sie als Markdown, griffe die
  Link-Pflicht ([`MR-001`](../../../../harness/conventions.md#mr-001)). Der Plan
  legt sie deshalb als Nicht-Markdown neben den Prüfer; ob `docs-check` sie
  dennoch anfasst, ist vor dem ersten Commit zu messen, nicht anzunehmen.
  **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → Beobachtungs-Register>

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
  Auslöser: `BEO-<KUERZEL>/<slug>` (<slice-NNN>, <slice-MMM>, <slice-KKK> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
  **Erwartet ist die Form *neuer Sensor*** — der Slice legt einen an; ob daneben
  eine Regel geschärft gehört, entscheidet der Abschluss.
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-NNN.md` | `evidence/slice-NNN.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
  **Kandidat, beim Abschluss zu prüfen statt jetzt zu setzen:**
  [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  — dieser Slice schließt eine ihrer Unterklassen. Ob das ein *Beleg* ist (eine
  weitere Datei unter `evidence/`) oder ein *Ausgang*, entscheidet der
  Abschluss-Lauf: der Eintrag steht auf `geplant` mit der Kennung `slice-153`,
  und ein zweiter Träger für dieselbe Zeile ist eine Zustands-Frage, keine
  Zähler-Frage.
- **Folge-Slices:** <slice-NNN (<Titel>) — ist eine Datei in `open/`>
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind zwei deklarierte
Sub-Areas. `harness/tools/` (Kürzel `TOOLS`) trägt Prüfer und Deklaration; die
Schwelle ≥ 2 von 3 Achsen ist erfüllt (eigenes Verzeichnis · eigene
Werkzeug-Klasse mit eigener Konventions-Verankerung · eigener Modus in der
Deklaration). `*` (Kürzel `ALL`) trägt `Makefile`,
[`harness/README.md`](../../../../harness/README.md) und
[`AGENTS.md`](../../../../AGENTS.md) §4. **Nicht** als eigene Sub-Area geführt
werden `.claude/commands/` — der Slice fasst sie nicht an (§1) — und
`.codex/` (`CODEX`), das er nicht berührt. Eine gröbere Fassung („die Harness")
wäre die Vermischung, vor der Modul 5 warnt.

**Vorgelagert — offene Beobachtungen sichten:** Das Register
(`docs/plan/planning/observations/`) ist vollständig durchgegangen; der
Zähler-Stand ist die Zahl der Dateien unter dem jeweiligen `evidence/`, gemessen
mit `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l` —
**keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025)). Alle Einträge tragen
die Sub-Area `*`; für `harness/tools/` führt das Register keinen eigenen. Vier
Treffer berühren den Gegenstand dieses Slice:

- [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  — **18×**, Stand `geplant` (Kennung `slice-153`). Der Stand nennt die Lücke,
  die dieser Slice füllt: *„Offen bleibt jede Unterklasse, in der die Zusage
  kein Anker ist"*. Eine Paraphrase ist keiner.
- [`BEO-ALL/zusammenfassung-staerker-als-ihre-quelle`](../observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md)
  — **3×**, Stand `offen`. Benachbart, aber **nicht** dasselbe: dort ist die
  Fehlerrichtung *die Zusammenfassung sagt mehr zu als die Quelle* zum
  Schreib-Zeitpunkt; hier ist es *die Quelle bewegt sich, die Zusammenfassung
  nicht*. Der Sensor dieses Slice deckt jene Richtung ausdrücklich **nicht**
  (§6) — die Zeile bleibt davon unberührt.
- [`BEO-ALL/anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md)
  — **5×**, Stand `geplant`. Sie ist der Grund, warum §1 die drei
  Anweisungssätze unangetastet lässt; der Slice fügt ihr keinen Beleg zu,
  sondern richtet sich nach ihrem Ausgang
  ([ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
- [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  — **1×**, Stand `offen`. Direkt einschlägig, weil dieser Slice einen Wächter
  anlegt; Liefer-Punkt (3) ist die Antwort darauf.

**Kein Eintrag erreicht mit diesem Slice 3×** — er legt keinen Beleg an, das tut
erst die Closure. Ein Folge-Slice aus der Sichtung entsteht daher nicht.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** — `harness/tools/` (`TOOLS`) und `*` (`ALL`)
sind in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md) als Greenfield
geführt. Ein Begründungsblock je Sub-Area ist damit nicht Pflicht; die vier
Kriterien wären hier ohne Gegenstand, weil kein Bestand zu inventarisieren ist:
Prüfer und Deklaration entstehen neu, und die Quellen, gegen die sie pinnen,
sind das laufende, gemergte `harness/conventions/`.
