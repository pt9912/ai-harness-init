# Slice slice-215: Der Commit-Message-Wächter bekommt den Träger, der auch die Commits sieht, die kein Agent tippt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Baseline-Test ist das *Mehr*
(`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht): eine beobachtbare
Closure-Bedingung, die mehr beobachtet als die DoD dieses Slice. Es gibt keine —
der Träger hängt an keinem repo-weiten Beleg, den die DoD nicht selbst führt.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §5 (*„Requirement- und ADR-IDs in PRs/Commits referenzieren"* —
die Zusage, deren Abdeckung hier wächst),
[`harness/README.md`](../../../../harness/README.md) §Traceability (dieselbe Zusage, zweiter Ort),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Wächter, dessen Reichweite nicht neben seiner Zusage steht, behauptet mehr als er misst),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (der Host bekommt
keine neue Abhängigkeit, auch keinen ungeprüften `.git/hooks`-Pfad),
[`ADR-0004`](../../adr/0004-durchsetzungs-emission.md) (der Stolperdraht-Charakter eines Guards,
gegen den jede Träger-Wahl gehalten wird),
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (warum die
konventions-schreibende Behebung hier **nicht** stattfindet),
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) (die
Hook- und Nachweis-Mechanik dieses Repos — sie entscheidet, wo ein Vor-Commit-Sensor hängen darf).

**Berührte Spec-Stellen:** `—`. Der Slice verschiebt den Träger einer bestehenden Zusage; er
schreibt keine neue Anforderung und keine technische Festlegung.

**Verantwortlich:** `—` bis zur Priorisierung (Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine).

**Autor:** Planner. **Datum:** 2026-09-12.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** **Eine Commit-Message ohne Traceability-Kennung wird auch dann rot, wenn kein Agent den
`git commit`-Aufruf getippt hat — und was der Träger danach nicht erreicht, steht neben dem, was er
erreicht.**

### Der Anlass: eine gemessene Reichweiten-Grenze, zweimal dieselbe Ursache

[slice-126](../done/slice-126-commit-message-traegt-eine-kennung.md) hat den Vor-Commit-Sensor
gebaut und ihn an den PreToolUse-Kanal des Agenten gehängt. Der Kanal sieht nur, was als
Bash-Kommando **wörtlich** `git commit …` enthält. Daraus folgen zwei Lücken mit **einer** Ursache
— der Träger sitzt am Agenten, nicht am Commit:

1. **Werkzeug-Commits sind strukturell unerreichbar.** `harness/tools/slice-mv.sh` und
   `cmd/ai-harness-init/archive_welle.go` committen **innerhalb** von Skript bzw. Binär; dem Hook
   erscheint der Aufruf als `make slice-mv …`. Gemessen am Bestand, **keine Erwartungswerte** — sie
   wandern mit jedem Commit:

   ```sh
   git log --format='%s' | grep -c '^slice-mv:'      # 304
   git log --format='%s' | grep -c '^archive-welle'  #   0
   git log --format='%s' | wc -l                     # 2117
   ```

2. **Die Abdeckung hängt an einer Konvention ohne durchgängigen Träger.** Der Hook greift nur bei
   `git commit -F <datei>`; vier von sechs `.claude/agents/*.md` und
   [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) nennen die Konvention
   nicht:

   ```sh
   ls .claude/agents/*.md | wc -l                                     # 6
   git grep -lc 'Commit via Message-Datei' -- .claude/ .harness/      # nur .claude/commands/*
   ```

   Geführt als
   [`BEO-ALL/waechter-abdeckung-haengt-an-uninstruierter-konvention`](../observations/BEO-ALL/waechter-abdeckung-haengt-an-uninstruierter-konvention/observation.md).

Ein Träger, der am **Commit** hängt statt am Agenten, beantwortet beide Lücken in einem Zug — er
braucht die auslösende Aufrufform nicht mehr. Ob er der richtige ist, entscheidet dieser Slice
gemessen, statt ihn vorauszusetzen.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Konvention in `.claude/agents/*.md` und `.harness/skills/reviewer.md` schreiben.** Diese
  Dateien gehören nach [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  der jeweils ausführenden Rolle, und für `.claude/agents/*.md` ist das Eigentum selbst noch offen
  ([`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md), `slice-152`).
  Ein Lauf dieses Slice dürfte sie nicht anfassen; die Behebung hier ist die
  konventions-**unabhängige**.
- **Die Wahrheit einer Aussage in der Message prüfen** — ob ein genannter Hash oder eine genannte
  Kennung auflöst. Das ist die Eigenschaft von
  [slice-121](../open/slice-121-commit-message-nennt-was-es-gibt.md), gemessen verschieden von
  *Anwesenheit einer Kennung*; sie hängt sich an den Träger, den dieser Slice liefert, statt einen
  zweiten zu erfinden.
- **Einen Range-Lauf in CI aufnehmen.** Am gepinnten d-check ist `--range` des Moduls `commits`
  unbedienbar, sobald `commits.id-patterns` irgendeine nicht-leere Liste trägt
  ([`harness/README.md`](../../../../harness/README.md) §Sensors, gemessen); der Nachzug wäre eine
  Werkzeug-Anforderung an ein Nachbar-Repo und damit ein anderer Vorgang.
- **Die emittierte Ebene.** Was ein gebootstrapptes Zielrepo an Commit-Wächtern bekommt, entscheidet
  der Slice, der die Tool-Ebene entscheidet; der Gegenstand kommt im Emissions-Baum heute nicht vor
  (`git grep -lni 'commit-msg\|COMMIT_EDITMSG' -- internal/emit/templates/ | wc -l` → **0**).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt.

- [ ] **(1) Der Träger ist entschieden, und die Entscheidung ordnet jeder gemessenen Commit-Klasse
      einen Träger zu.** Mindestens drei Klassen sind zu bedienen: direkt getippter Aufruf · Commit
      aus einem Repo-Werkzeug heraus · Aufruf ohne die Konventions-Form. Zu entscheiden ist
      zugleich, wie der Träger auf einem **frischen Klon** entsteht — ein `.git/hooks/`-Pfad reist
      nicht mit und wäre sonst ein Wächter, den nur der lokale Baum kennt.
      **Rot:** eine Klasse ohne benannten Träger, oder eine Trägerschaft, die der frische Klon nicht
      herstellt.
- [ ] **(2) Der gewählte Träger ist verdrahtet und einmal rot gesehen — an einer Commit-Klasse, die
      der heutige PreToolUse-Hook strukturell nicht erreicht.** Beide Läufe (rot ohne Kennung, grün
      mit) gehören in den Umsetzungs-Commit.
      **Rot:** `make mutate` meldet **BEFUND** auf den `test/mutations/`-Fall, der die
      Kennungs-Prüfung des neuen Trägers entwaffnet — der Zahn muss die Stelle treffen, die der
      Aufrufer benutzt.
- [ ] **(3) Die neue Reichweite steht neben der alten, und was draußen bleibt, ist benannt.** In
      [`harness/README.md`](../../../../harness/README.md) steht, welche Commit-Klassen der Träger
      erreicht, welche nicht, und ob die Konventions-Abhängigkeit aus §1 damit entfällt oder als
      Lücke weiterläuft.
      **Rot:** eine Zusage im Text, für die der Lauf kein Gegenbeispiel herstellen kann
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6).

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Review nach Modul 10 mit Report unter `docs/reviews/` · Doku-Update, falls ein öffentlicher Vertrag
berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag · Beobachtungs-Register fortgeschrieben ·
jedes Risiko aus §6 mit Ausgang · die drei Paarungen von der nächsten Welle-Closure getragen.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`docs/plan/adr/`](../../adr/) | **offen** | Die Träger-Wahl unterscheidet sich in der **Reichweite** der Alternativen und ist damit eine Architektur-Entscheidung; ob sie eine eigene ADR trägt oder in die Zeile dieses Abschnitts passt, entscheidet der Architect vor `next` → `in-progress` (§4) |
| `harness/tools/` oder `.githooks/` | neu | der Träger selbst, falls die Wahl auf einen `git`-eigenen `commit-msg`-Hook fällt — versioniert, mit `core.hooksPath` statt `.git/hooks/` ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) |
| [`Makefile`](../../../../Makefile) | update | das Ziel, das den Träger auf einem frischen Klon herstellt; ein neues behauptetes Ziel zieht [`AGENTS.md`](../../../../AGENTS.md) §4 und das Modul `targets` mit |
| [`.claude/hooks/pretooluse-commit-msg-guard.sh`](../../../../.claude/hooks/pretooluse-commit-msg-guard.sh) | update / entfällt | zwei Wächter über demselben Gegenstand sind zwei Orte, an denen dieselbe Config driftet — die Entscheidung aus DoD (1) sagt, ob der Zusatz-Hook bleibt |
| `test/` | neu | der hermetische Fall zum neuen Träger; das gepinnte `BATS_IMAGE` führt kein `git` — der reale Beleg gehört wie bei `slice-mv` in den Skriptkopf |
| `test/mutations/` | neu | der Zahn aus DoD (2) |
| [`harness/README.md`](../../../../harness/README.md) | update | Reichweite und Grenze (DoD (3)) |
| `.claude/agents/*.md`, [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) | **nicht durch diesen Slice** | fremdes Rollen-Eigentum ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)), §1 |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit ist frei, **und** der Architect hat die
Träger-Wahl aus DoD (1) beantwortet — als ADR oder als Zeile in §3. Solange sie offen steht, ist
die Architect-Antwort auf diesen Plan unvollständig, und der Lauf entschiede eine
Architektur-Frage im Implementations-Kontext (Baseline-Regelwerk `modul-08-agentenrollen.md`
§Rollen-Regeln).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Träger-Wahl endet bei **zwei**
  Trägern, die nebeneinander laufen sollen — dann brauchen Verdrahtung, Doku und Zähne je eigene
  Läufe, und es sind zwei Slices statt eines vierten DoD-Punkts.
- `in-progress` → `open` (blockiert — Carveout?): Der gewählte Träger lässt sich auf einem frischen
  Klon nicht ohne Host-Schritt herstellen, den
  [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) ausschließt. Dann
  ist die Lage ein Carveout nach Modul 7 und keine stille Teil-Verdrahtung.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD (1) bis (3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make mutate` ohne Befund,
Review nach Modul 10 und Verifikation nach Modul 11 ohne blockierenden Befund, Closure-Notiz in §7
mit Steering-Loop-Eintrag **und** der ausdrücklichen Feststellung, ob
[`BEO-ALL/waechter-abdeckung-haengt-an-uninstruierter-konvention`](../observations/BEO-ALL/waechter-abdeckung-haengt-an-uninstruierter-konvention/observation.md)
mit diesem Slice seinen Ausgang bekommt oder als Lücke weiterläuft.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Ein `git`-eigener Hook ist im Klon nicht da.** `.git/hooks/` wird von `git clone` nicht
  übertragen; ein Träger dort wäre ein Wächter, den nur der Baum kennt, auf dem ihn jemand
  installiert hat — dieselbe Klasse, die
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) für
  behauptete Gates verbietet. Die Antwort (`core.hooksPath`, ein `make`-Ziel, ein Bootstrap-Schritt)
  gehört in DoD (1) entschieden, nicht hier weggewunken. — **Ausgang:** <eingetreten: CO-NNN /
  slice-NNN | entfallen: Grund | weiter offen: → Beobachtungs-Register>
- **Ein `commit-msg`-Hook liegt außerhalb von `make`.** `git` startet ihn selbst; er darf darum
  nicht Docker voraussetzen, sonst bricht jeder Commit ohne laufenden Daemon. Ein hermetischer
  bash+awk-Prüfer wäre ein **zweiter** Prüfer neben dem `commits:`-Block der
  [`.d-check.yml`](../../../../.d-check.yml) — zwei Fassungen derselben Kennungs-Liste, die driften.
  — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: →
  Beobachtungs-Register>
- **Zwei Wächter über demselben Gegenstand.** Bleibt der PreToolUse-Zusatz neben dem neuen Träger
  stehen, blockt derselbe Commit zweimal mit zwei Begründungen, und ein Lauf weiß nicht, welche
  gilt. — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: →
  Beobachtungs-Register>
- **Der Cutoff bleibt prospektiv, und das muss er.** Ein Maßstab über die ganze Historie wäre an
  einem Bestand rot, den niemand mehr ändern kann; gemessen liegt der kennungslose Anteil im
  jüngsten Bestand bereits niedrig
  (`RE='ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+|^(Merge |Revert )';
  git log --format='%s' -50 | grep -vcE "$RE"` → **2**, kein Erwartungswert). Ein Träger, der die
  Historie liest, kippt diese Lage. — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen:
  Grund | weiter offen: → Beobachtungs-Register>

## 7. Closure-Notiz

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Vorgelagert — Sub-Area-Wahl prüfen:** Der Slice berührt `*` (gesamtes Repo) und `TOOLS`
(`harness/tools/`), beide in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md) geführt. Eine feinere Sub-Area für
„Commit-Wächter" wird **nicht** aufgemacht: Sie erfüllt die Schwelle ≥ 2 von 3 Achsen nicht — es
gibt weder eigene Konventionen noch eine eigene Reife-Linie, nur eine Datei.

**Vorgelagert — offene Beobachtungen sichten:** Drei Einträge des Registers treffen diesen Slice,
Zähler als Dateizahl abgelesen
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, **keine
Erwartungswerte**):
[`waechter-abdeckung-haengt-an-uninstruierter-konvention`](../observations/BEO-ALL/waechter-abdeckung-haengt-an-uninstruierter-konvention/observation.md)
**1×** — der Anlass dieses Slice, unter der Schwelle;
[`commit-message-ohne-traceability-kennung`](../observations/BEO-ALL/commit-message-ohne-traceability-kennung/observation.md)
**2×** — der Gegenstand, ebenfalls unter der Schwelle;
[`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
**12×**, Stand `geplant` (`slice-181`) — das ist das Evidenz-Risiko von DoD (3): Die Reichweiten-Zusage
dieses Slice ist genau die Form, die dort zwölfmal gebrochen ist, und sie gehört darum gemessen
statt formuliert.

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas GF; ein Begründungsblock entfällt.
Der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Präzedenzfall für einen
hermetischen Wächter mit `make`-Ziel, bats-Fall und `test/mutations/`-Zahn ist
[slice-126](../done/slice-126-commit-message-traegt-eine-kennung.md); für den Hook-Ort ist es
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks).
