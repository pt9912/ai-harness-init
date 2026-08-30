# Slice slice-137: Das Beobachtungs-Register entsteht — leer, und mit einem Träger für jeden seiner drei Schritte

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — **gemessen an zwei Instrumenten, und das erste legt zunächst das Gegenteil
nahe.**

**(1) Die Probe aus [slice-134](slice-134-adr-index-traegt-die-ziel-form.md) hat zwei Konjunkte,
und hier zeigen sie in verschiedene Richtungen.** Das erste — *stammt der Befund aus dem
Re-Baseline-Delta?* — lautet **ja**: die abgelöste Fassung kennt den Gegenstand nicht
(`git grep -l 'observations\|Beobachtungs-Register' b902b60^ -- '.harness/baseline/v3.5.2/' | wc -l`
→ **0**), die gepinnte führt ihn breit
(`git grep -l 'observations\|Beobachtungs-Register' -- '.harness/baseline/v5.12.0/' | wc -l` →
**20**; beide Beträge wandern mit dem Kurs-Stand und sind keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Das zweite — *belegt der Slice ein Closure-Kriterium von
[welle-10](../welle-10-re-baseline.md) §3, und braucht die Welle ihn?* — lautet **nein**, und es
entscheidet. Keiner der drei Durchgänge fängt ihn: Durchgang 1 zählt Einträge des
Adaptions-Blocks, und die Übernahme eines Baseline-**Defaults** erzeugt keinen
([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage), §1); Durchgang 2 hält
die Pflichtfelder der neuen Gliederung an **vorhandene** Singleton-Artefakte, und
[slice-083](slice-083-form-vergleich-pflichtfelder.md) §6 sagt über genau diesen Gegenstand
wörtlich, eine neue Artefakt-Klasse mit eigener Lese-Pflicht falle *„zwischen"* seine drei
DoD-Punkte; Durchgang 3 ist die Stichprobe **ohne** Delta. **welle-10 §6 nennt den Fall beim Namen
und führt ihn hinaus:** *„Ein Delta, das eigene Arbeit verlangt, wird als Slice in `open/` notiert
— sonst wächst die Welle auf die Größe des Deltas und verliert ihr Closure-Kriterium."* Bei
[slice-136](slice-136-roadmap-traegt-die-ziel-form.md) zeigten beide Konjunkte gemeinsam nach
welle-10 und waren dort nicht zu unterscheiden; hier fallen sie auseinander, und tragend ist das
zweite: **Herkunft aus dem Delta allein begründet keine Zugehörigkeit.**

**(2) Der Schnitt-Test aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, alle drei Fragen beantwortet.** **Bündel?** Nein — die Aussage *„das Repo führt das
Beobachtungs-Register, und kein lebender Plan behauptet das Gegenteil"* ist mit diesem einen
Slice wahr. **Gemeinsames
Closure-Kriterium?** Nein — eine Welle darum herum schriebe die DoD unten ab. **Auslöser reaktiv
oder gewollt?** **Reaktiv**: ein fremder Kurs-Stand hat die Ziel-Form geändert, und sieben lebende
Pläne widersprechen sich seither selbst (§1). Die **Fähigkeit** — dass der 3×-Übertritt maschinell
gedeckt feuert — entsteht hier gerade **nicht**; ihre maschinelle Hälfte ist benannt, begründet
und ausgelagert (§6), und genau das hält Frage 3 auf der reaktiven Seite.

Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 erscheint wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist allein die
Verzeichnis-Position. Die drei Paarungen (Anker · Folge-Slice · Register) prüft gleichwohl die
nächste Welle-Closure — dieses Repo fährt Wellen-Betrieb, und die liest auch Slices ohne
Wellen-Zugehörigkeit.

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist das Planning-Layout **dieses** Repos. Was ein
frisch gebootstrapptes Zielrepo an Registern und Anweisungssätzen bekommt, ist ein anderer Vertrag
mit eigenen Trägern: [slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md) entscheidet
über jede neue Vorlage des getauschten Baums,
[slice-085](slice-085-emittierte-ebene-zieht-nach.md) zieht die emittierten Commands nach. Heute
trägt die emittierte Ebene zum Register **nichts**
(`grep -rc 'observations\|Beobachtungs-Register\|BEO-' internal/emit/ | grep -cv ':0$'` → **0**),
und dieser Slice ändert daran nichts.

**Bezug:**
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) — die Blankett-Klausel
*„keine inhaltlichen Adaptionen ggü. Baseline-Default"* ist die Achse, um die sich die
Entscheidung dreht: Übernahme braucht keinen Eintrag, Ablehnung einen.
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(der Schnitt-Test oben und der Ort wellenloser Arbeit),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl in diesem Plan steht neben dem Kommando, das genau sie ausgibt),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(die Wächter-Frage in §1: ein Sensor über einem leeren Prüfbereich ist genau der Fall, den dieses
Requirement verbietet),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel — der
Grund, warum hier kein Gate entsteht, statt eines zu behaupten),
[`AGENTS.md`](../../../../AGENTS.md) §3.8 (der abgelehnte Zweig ist Architect-Arbeit; dieser Slice
schreibt kein Norm-Artefakt),
[ADR-0015](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) und
[ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (die offen
gelassene Eigentums-Frage und das Muster, in dem dieses Repo sie schließt — §6 nennt den einen
Posten, der hier daran hängt).

**Berührte Spec-Stellen:** — Dieser Slice berührt keine. Das Beobachtungs-Register ist ein
Artefakt des Planungs-Harness und steht in keinem der drei Spec-Straten; was das Werkzeug kann,
ändert sich nicht. Der Verweis zeigt ohnehin **aufwärts**: die Spec nennt diesen Slice nie
(Baseline-Regelwerk `grundlagen-referenz-richtung.md`
§Referenz-Richtung (SDP), `grundlagen-source-precedence.md` §ID-Schema als Klammer).

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-08-29.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Dieses Repo führt das Beobachtungs-Register — leer, wie die Ziel-Form es für den Anfang
vorsieht —, jeder seiner drei Schritte hat einen Träger in einem Anweisungssatz dieses Repos, und
kein lebender Plan behauptet mehr das Gegenteil.**

### Die Frage, und warum sie nicht länger offen bleiben kann

Die Ziel-Form führt den Zähler des Steering Loops als **stehende Datei** flach im Planning-Layout
(`v5.12.0`, `modul-06-roadmap.md` §Das Beobachtungs-Register: *„Der Zähler des Steering Loops liegt
als **stehende Datei** flach im Planning-Layout, neben den offenen Wellen"*), und die Vorlage dazu
liegt im vendored Baum
(`ls .harness/baseline/v5.12.0/templates/docs/plan/planning/observations.template.md`). Dieses
Repo führt sie nicht (`find docs/plan -iname '*observation*' | wc -l` → **0**).

**Entschieden hat das niemand.** Keine ADR, kein Adaptions-Eintrag und kein Abschnitt der
Briefing-Dateien nennt das Register
(`git grep -lEi 'observations\.md|Beobachtungs-Register' -- AGENTS.md CLAUDE.md README.md 'harness/*.md' 'docs/plan/adr/*.md' 'spec/*.md' | wc -l` → **0**).
Vertagt ist es an **sieben** Stellen: so viele lebende Plandateien zitieren in ihrer Closure-Notiz
bereits die Regeln des Registers und erklären zwei Abschnitte weiter oben, dass es das Register
nicht gibt
(`grep -rl '§Das Beobachtungs-Register (vorhandene' docs/plan/planning/ | wc -l` → **7**; die
Zahl **wächst mit jedem neuen Slice**, denn beide Stellen stammen aus derselben `cp`-Vorlage und
sind keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die Vorlage hängt zudem einen **DoD-Punkt je Slice** an das Register
(`grep -c 'Beobachtungs-Register' .harness/baseline/v5.12.0/templates/docs/plan/planning/slice.template.md`
→ **3** Zeilen: der DoD-Punkt in §2, die Regel-Zeile in §7 und die Ergebnis-Zeile darunter). Jeder
Slice, der ab heute per `cp` entsteht, erbt alle drei.

### Woraus die Entscheidung fällt — vier Messungen, und eine Asymmetrie

1. **Ohne Register hat die 3×-Schwelle keine Quelle.** `v5.12.0`, `modul-08-agentenrollen.md` §3a
   verdrahtet sie namentlich: *„**Planner** erkennt den 3×-Übertritt | Zähler-Stand aus dem
   Beobachtungs-Register"*. Ohne Register kann die Regel nicht feuern — die Achse, auf der sie
   zählt, existiert nicht.
2. **Der Bestand, den nichts zusammenführt.** `ls docs/plan/planning/done/slice-*.md | wc -l` →
   **88** geschlossene Slices, davon
   `grep -rl 'Steering-Loop' docs/plan/planning/done/slice-*.md | wc -l` → **88** mit einem
   Lerneintrag. Achtundachtzig Einträge, kein Ort, an dem zwei davon als **dieselbe** Beobachtung
   sichtbar würden.
3. **Kein einziger Beleg ist heute vergeben.** `git grep -c 'BEO-[0-9]' -- '*.md' ':!.harness/baseline' | wc -l`
   → **0**: was im Repo als `BEO-` steht, ist ausnahmslos der Platzhalter aus der zitierten
   Vorlage. Das ist zugleich die Antwort auf die Wächter-Frage weiter unten.
4. **Die Asymmetrie entscheidet, nicht die Vorliebe.** Übernahme ist der Baseline-**Default** und
   erzeugt nach
   [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) **keinen**
   Adaptions-Eintrag; Ablehnung ist eine Abweichung und **braucht** einen — und ein
   Adaptions-Eintrag wird nach [`AGENTS.md`](../../../../AGENTS.md) §3.8 vom **Architect**
   geschrieben, in einem eigenen Commit. Der ablehnende Zweig ist damit von einem Planner-Slice
   nicht lieferbar, sondern nur übergebbar. Er bleibt als Ausgang benannt (§6), aber er ist nicht
   der Weg dieses Slice.

### Die Bestands-Frage: kein Übertrag, und der Grund steht in der Ziel-Form selbst

Die **88** Lerneinträge wandern **nicht** ins Register. Das ist keine Bequemlichkeit, sondern die
Regel der Vorlage: *„Die Tabelle unten startet leer — das ist der richtige Anfangszustand, nicht
eine Lücke … Erfinde keine Belege: Eine Kennung entsteht beim **ERST**auftreten einer echten
Beobachtung, nicht beim Adoptieren dieser Vorlage."* Modul 6 sagt dasselbe von der anderen Seite:
*„Ist nichts offen, trägt die Tabelle `— keine —` und bleibt stehen. Die leere Liste **ist** die
Aussage — und sie ist die, mit der jedes Repo anfängt."*

**Und die Grenze ist keine Mauer.** Der Beleg ist formgebunden auf `slice-<NNN>` in `done/` — und
genau diese Form tragen die 88 Einträge bereits. Tritt eine Klasse wieder auf, darf ihre neue
`BEO-<NNN>` die historischen Belege mitführen; was ausgeschlossen ist, ist die **Vollinventur**
über 88 Dateien, die für jede Zeile das Urteil *ist das dieselbe Beobachtung?* verlangte. Der
Preis ist benannt statt versteckt: der Zähler startet bei null, eine Klasse mit drei
zurückliegenden Instanzen feuert nicht von selbst (§6).

### Die Wächter-Frage, gestellt und beantwortet: kein Gate, mit Grund und Träger

Modul 6 nennt die maschinell entscheidbare Hälfte selbst — *„ob eine in `done/` zitierte
`BEO-<NNN>` eine Registerzeile hat **und ob jede Registerzeile mindestens einen Beleg trägt**"* —
und lässt das Werkzeug offen (*„Welches Werkzeug, ist Repo-Entscheidung"*). **Dieser Slice baut
sie nicht**, aus drei gemessenen Gründen:

1. **Es gibt heute nichts zu prüfen.** Messung 3 oben: null vergebene Kennungen, und das Register
   startet leer. Ein Gate darüber wäre grün über einem leeren Prüfbereich — der Fall, den
   [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
   verbietet und den dieses Repo beim Meilenstein M4 schon einmal ausdrücklich abgewartet hat
   (der Trigger dort verlangt den gefüllten Prüfbereich **vor** der Aktivierung,
   [`roadmap.md`](../in-progress/roadmap.md) §Meilensteine).
2. **Die adoptierbare Hälfte kostet ein fremdes Norm-Artefakt.** Sie wäre ein viertes
   `ids`-Pattern (`BEO-\d{3}` auf die Registerdatei, `link-policy: always`) — und der `ids`-Block
   ist in
   [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
   ausgeschrieben. Ihn zu erweitern, ohne den Eintrag nachzuziehen, erzeugt genau die Drift, die
   [slice-131](slice-131-praesens-aussage-gegen-den-gepinnten-stand.md) und
   [slice-132](../next/slice-132-adaptions-block-ohne-totes-ziel.md) abräumen; ihn nachzuziehen ist
   Architect-Arbeit ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Beides gehört nicht in einen
   Planner-Slice, dessen Gegenstand ein Planungs-Artefakt ist.
3. **Die zweite Hälfte hat in keinem der beiden d-check-Stände ein Modul.** Über beide Digests
   gemessen, netzlos:
   `docker run --rm --network none ghcr.io/pt9912/d-check@sha256:5ea03abe7918381c68203d8ac078a78d0d4ab91b5478e87c66b5a7b4fda41288 --print-config | grep -ci 'observation'`
   → **0** (gepinnt, `v0.65.0`) und dasselbe Kommando mit
   `sha256:117a3503b2e721aee35dad85b477b6e29b497721f67b7d042b16daef4410a7f1` → **0**
   (`v0.66.1`, das Ziel von [slice-135](slice-135-d-check-pin-v0661.md)). Das Modul `planning`
   führt dort drei Fähigkeiten — Lifecycle, `closure`, `waves` —, keine über ein Register. Das ist
   eine **fehlende Fähigkeit eines Fremd-Werkzeugs**, keine Grenze dieses Repos: d-check hängt an
   einem eigenen Pin, und ob die Fähigkeit entsteht, wird dort entschieden. Der Eigenbau, den es
   sonst bräuchte, wiegt schwerer als der Nutzen über einem Register mit null Zeilen.

**Was stattdessen trägt, ist Feedforward, und der Plan sagt es so:** die drei Schritte des
Registers stehen danach in den Anweisungssätzen, die dieses Repo bei Planung und Closure liest
(DoD (3)). Heute steht dort nichts —
`grep -rl 'Beobachtung\|observations\|BEO-' .claude/commands/ | wc -l` → **0** bei
`ls .claude/commands/ | wc -l` → **3** Dateien. Ohne diesen Schritt entstünde eine leere Datei,
die niemand anfasst: dieselbe Trägerlosigkeit, die die 88 Lerneinträge aus Messung 2 unverbunden
gelassen hat.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Die Frage ist entschieden, und die Entscheidung liegt als Artefakt vor, nicht als
      Prosa.** Eine `observations.md` liegt flach unter `docs/plan/planning/`, entstanden per `cp`
      aus `.harness/baseline/v5.12.0/templates/docs/plan/planning/observations.template.md` mit
      `diff -q` als Provenienz-Beleg **vor** dem Füllen; Template-Hinweis und Bedienhinweise sind
      gestrippt, beide Tabellen tragen `— keine —`, und keine Kennung ist erfunden
      (`grep -c 'BEO-[0-9]'` über die neue Datei → **0**). **Der Bestand ist nicht übertragen** —
      der Grund steht in §1 und stammt aus der Ziel-Form, nicht aus dem Aufwand.
- [ ] **(2) Kein lebender Plan widerspricht der Entscheidung mehr.** Die Menge ist ein Kommando,
      keine Liste, weil sie zwischen Schnitt und Ausführung wächst:
      `grep -rl '§Das Beobachtungs-Register (vorhandene' docs/plan/planning/{open,next,in-progress}/`
      — jede Treffer-Datei trägt danach in §2, §7 und §8 den entschiedenen Stand statt der
      Vertagung. **`docs/plan/planning/done/` und `docs/reviews/` bleiben unangetastet**: sie sind
      Zeitdokumente und beschreiben ihren Stand richtig.
- [ ] **(3) Jeder der drei Schritte des Registers hat einen Träger in einem Anweisungssatz dieses
      Repos.** Schreib-Schritt (Slice-Closure), Lese-Schritt (Welle-Closure, 3×-Übertritt) und
      Sichtungs-Schritt (Slice-Planung, §8 des Plans) stehen in den Abschnitten von
      [`.claude/commands/`](../../../../.claude/commands/), die die **Planner**-Rolle bereits
      führen — heute nennt keine der drei Dateien das Register (Messung in §1). Zu jedem Schritt
      gehört, was er bei **null** Beobachtungen tut; die leere Antwort ist die häufigste.
- [ ] `make gates` bringt **keinen Befund hervor, der diesem Slice zuzurechnen ist**. Die Zusage
      ist bewusst so und nicht „grün" formuliert: der Lauf trägt zum Schnitt-Zeitpunkt zwei offene
      Carveouts ([`CO-004`](../../carveouts/done/CO-004-emitter-klassifikation-offen.md) auf `test`,
      [`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md) auf `docs-check`), und
      beide sind fremde Posten mit eigenen Folge-Slices. Verlangt ist der **Vorher-Nachher-Vergleich
      derselben Ausgabe** — dieselben Befunde, dieselbe Zurechnung, bei `docs-check` eine geprüfte
      Datei mehr.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist — hier keiner: die emittierte Ebene
      hat eigene Träger (Kopf, §6).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: das Repo hat keinen Brownfield-Bootstrap und führt keines; das Item
      entfällt.
- [ ] Beobachtungs-Register fortgeschrieben — **ab diesem Slice ist das Item echt**: neue
      `BEO-<NNN>` oder Zähler +1 mit Beleg, und *keine Beobachtung angefallen* ist ebenfalls eine
      Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die nächste Welle-Closure — dieses
      Repo fährt Wellen-Betrieb, und die liest auch Slices ohne Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| eine `observations.md` flach unter `docs/plan/planning/` | neu (per `cp`) | die Entscheidung **ist** die Datei; leer, beide Tabellen `— keine —` |
| die Treffermenge aus DoD (2), heute in `docs/plan/planning/open/` und `docs/plan/planning/in-progress/` | update | §2, §7 und §8 tragen den entschiedenen Stand statt der Vertagung |
| [`.claude/commands/implement-slice.md`](../../../../.claude/commands/implement-slice.md) §Closure | update | der **Schreib**-Schritt; der Abschnitt führt die Planner-Rolle bereits im Titel |
| [`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md) | update | der **Lese**-Schritt: was 3× erreicht hat, wandert in die Steering-Loop-Einträge der Welle-Closure |
| [`.claude/commands/plan-welle.md`](../../../../.claude/commands/plan-welle.md) | update | der **Sichtungs**-Schritt: das Register vor dem Schnitt durchgehen, Treffer mit Zähler-Stand nach §8 des Plans |
| [`docs/plan/planning/README.md`](../README.md) | prüfen, ggf. update | beschreibt das Planning-Layout; eine stehende Datei mehr darin ist eine Aussage über den Bestand, keine über den Prozess |

**Nicht in dieser Liste, und beides mit Absicht:** [`.d-check.yml`](../../../../.d-check.yml) und
[`harness/conventions.md`](../../../../harness/conventions.md) — der eine, weil kein Gate entsteht
(§1), der andere, weil die Übernahme eines Defaults keinen Adaptions-Eintrag erzeugt und ein
solcher Eintrag ohnehin nicht von diesem Slice geschrieben würde
([`AGENTS.md`](../../../../AGENTS.md) §3.8).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **das WIP-Limit ist frei**, also
`ls docs/plan/planning/in-progress/slice-*.md | wc -l` → **0**. Am 2026-08-29 liefert dasselbe
Kommando **1**:
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) hält es. Eine
**fachliche** Vorbedingung hat dieser Slice **nicht**. Insbesondere wartet er **nicht** auf
[slice-083](slice-083-form-vergleich-pflichtfelder.md): dessen §6 hat die Entscheidung benannt,
seine drei DoD-Punkte tragen sie nicht, und Modul 5 lässt keinen vierten zu — die Vertagung hat
dort keinen Haken, an dem sie hängen könnte (§6).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die drei Anweisungssätze aus DoD (3) und
  die Treffermenge aus DoD (2) sprengen zusammen eine Sitzung. Geteilt wird dann entlang der
  Schichten — Register plus Plan-Bereinigung hier, Träger in einem Folge-Slice —, **nicht**
  gedehnt.
- `in-progress` → `open` (blockiert — Carveout?): ein Architect-Lauf widerspricht der Übernahme.
  Dann ist die Frage nicht offen, sondern **anders** entschieden, und der Weg ist ein
  Adaptions-Eintrag statt einer Datei (§6, erster Punkt). Der Slice geht zurück nach `open/` und
  wird auf den ablehnenden Zweig umgeschrieben.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig, `make gates` ohne einen Befund, der diesem Slice zuzurechnen ist (Vergleich
gegen den Lauf vor der Änderung), Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der ablehnende Zweig ist nicht lieferbar, nur übergebbar.** Fällt die Entscheidung gegen das
  Register, ist sie eine Abweichung vom Baseline-Default und braucht einen Adaptions-Eintrag, den
  nach [`AGENTS.md`](../../../../AGENTS.md) §3.8 der **Architect** in einem eigenen Commit
  schreibt. Dieser Slice schriebe ihn nicht; er ginge zurück nach `open/` (§4). —
  **Ausgang:** eingetreten (Übergabe an den Architect, Slice zurück nach `open/`) | entfallen: die
  Übernahme steht.
- **Der Zähler startet bei null, und das kostet etwas Benennbares.** Eine Klasse, die in den
  **88** geschlossenen Slices bereits dreimal aufgetreten ist, erreicht die Schwelle nicht von
  selbst; sichtbar wird sie erst beim vierten Mal. Der Preis ist gewollt (§1), aber er ist keiner,
  den man verschweigt. — **Ausgang:** weiter offen → als `BEO-<NNN>` im Register notieren, sobald
  die erste solche Klasse wieder auftritt, mit ihren historischen Belegen aus `done/`.
- **Die maschinelle Hälfte der Register-Paarung bleibt unbewacht, und das ist benannt statt
  verschwiegen.** Kein Modul der beiden gemessenen d-check-Stände deckt sie (§1, Messung 3); die
  adoptierbare Hälfte kostet einen Eintrag im Adaptions-Block. — **Ausgang:** weiter offen →
  Folge-Slice in `open/`, geschnitten bei der Closure dieses Slice, mit dem beobachtbaren Trigger
  *die erste `BEO-<NNN>` ist vergeben* (davor liefe er über einem leeren Prüfbereich,
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
  Die zweite Hälfte ist eine **Anforderung an d-check**, nicht an dieses Repo, und gehört dorthin
  gemeldet.
- **Wer die Anweisungssätze unter `.claude/commands/` schreiben darf, sagt keine Quelle.**
  [ADR-0015](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) besetzt zwei Norm-Artefakte und
  lässt die Frage für alle übrigen ausdrücklich offen;
  [ADR-0024](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) zeigt, wie
  dieses Repo eine solche Lücke schließt — mit einer ADR, also Architect-Arbeit. DoD (3) bindet
  sich deshalb auf die Abschnitte, die die **Planner**-Rolle bereits im Titel führen; die
  allgemeine Eigentums-Frage bleibt daneben stehen. — **Ausgang:** weiter offen → an den Architect
  gemeldet; die Bearbeitung dieses Slice hängt nicht an ihr.
- **Die Treffermenge aus DoD (2) bewegt sich zwischen Schnitt und Ausführung.** Jeder neue `cp`
  vergrößert sie; [slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md)
  liegt heute in `in-progress/` und ist bis dahin womöglich ein Zeitdokument in `done/`. Genau
  darum steht in der DoD ein Kommando und keine Dateiliste. — **Ausgang:** entfallen, wenn die
  Menge zum Ausführungszeitpunkt gemessen und vollständig abgearbeitet ist.
- **Die Registerdatei vergrößert den Doku-Prüfbereich, und ihr Inhalt ist erst nach dem Strippen
  bekannt.** Die Vorlage trägt **0** Markdown-Links
  (`grep -oE '\]\([^)]+\)' .harness/baseline/v5.12.0/templates/docs/plan/planning/observations.template.md | wc -l`)
  und **0** Kennungen der drei linkpflichtigen Muster
  (`grep -coE 'LH-[A-Z]{2}-[0-9]{2}|ADR-[0-9]{4}|MR-[0-9]{3}' .harness/baseline/v5.12.0/templates/docs/plan/planning/observations.template.md`),
  womit nach dem
  Strippen nichts übrig bleibt, worüber die Module `links`, `anchors` und `ids` urteilen könnten.
  Das ist eine Aussage über die **Vorlage**, nicht über die gefüllte Datei. — **Ausgang:**
  entfallen, wenn `make docs-check` nach dem Anlegen genau den vorbestehenden Befund meldet und
  eine Datei mehr zählt | eingetreten: der neue Befund wird behoben, nicht ausgenommen.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

<!-- Erst nach Abschluss füllen. Vor dem `git mv` nach done/; das letzte
DoD-Item in §2 prüft die nächste Welle-Closure. -->

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `docs/plan/planning/` und
`.claude/commands/`. Beide fallen unter den Eintrag `*` (gesamtes Repo) der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) —
**alle berührten Sub-Areas GF**, der Modus-Begründungsblock entfällt damit. Eine eigene Sub-Area
für das Planning-Layout auszudifferenzieren wäre hier ohne Gegenstand: der Slice legt eine leere
Datei an und schreibt drei Anweisungssätze fort, er baut keine Konventions-Dichte auf, die eine
eigene Zeile in der Deklaration trüge.

**Vorgelagert — offene Beobachtungen sichten:** **keine Treffer, und der Grund ist der Gegenstand
dieses Slice** — ein Register, das gesichtet werden könnte, existiert nicht
(`find docs/plan -iname '*observation*' | wc -l` → **0**). Dies ist der letzte Slice dieses Repos,
der diese Antwort mit dieser Begründung geben kann; ab seiner Closure ist die leere Tabelle die
Antwort, nicht die fehlende Datei.
