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

**Verantwortlich:** Implementer (pt9912).

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

- [x] **(1) Der Träger ist entschieden, und die Entscheidung ordnet jeder gemessenen Commit-Klasse
      einen Träger zu.** Mindestens drei Klassen sind zu bedienen: direkt getippter Aufruf · Commit
      aus einem Repo-Werkzeug heraus · Aufruf ohne die Konventions-Form. Zu entscheiden ist
      zugleich, wie der Träger auf einem **frischen Klon** entsteht — ein `.git/hooks/`-Pfad reist
      nicht mit und wäre sonst ein Wächter, den nur der lokale Baum kennt.
      **Rot:** eine Klasse ohne benannten Träger, oder eine Trägerschaft, die der frische Klon nicht
      herstellt.
- [x] **(2) Der gewählte Träger ist verdrahtet und einmal rot gesehen — an einer Commit-Klasse, die
      der heutige PreToolUse-Hook strukturell nicht erreicht.** Beide Läufe (rot ohne Kennung, grün
      mit) gehören in den Umsetzungs-Commit.
      **Rot:** `make mutate` meldet **BEFUND** auf den `test/mutations/`-Fall, der die
      Kennungs-Prüfung des neuen Trägers entwaffnet — der Zahn muss die Stelle treffen, die der
      Aufrufer benutzt.
- [x] **(3) Die neue Reichweite steht neben der alten, und was draußen bleibt, ist benannt.** In
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
| [`docs/plan/adr/`](../../adr/) | **neu** — [ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) (Proposed) | **beantwortet:** der Träger der Werkzeug-Klasse ist der git-eigene `commit-msg`-Hook, und der PreToolUse-Kanal bleibt daneben die reisende Hälfte (Festlegungen 1 und 2). Die Wahl unterscheidet sich in der **Reichweite** der Alternativen und bindet damit über diesen Slice hinaus — sie steht darum als ADR und nicht als Zeile dieses Abschnitts |
| `harness/tools/` oder `.githooks/` | neu | der Träger selbst, falls die Wahl auf einen `git`-eigenen `commit-msg`-Hook fällt — versioniert, mit `core.hooksPath` statt `.git/hooks/` ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) |
| [`Makefile`](../../../../Makefile) | update | das Ziel, das den Träger auf einem frischen Klon herstellt; ein neues behauptetes Ziel zieht [`AGENTS.md`](../../../../AGENTS.md) §4 und das Modul `targets` mit |
| [`.claude/hooks/pretooluse-commit-msg-guard.sh`](../../../../.claude/hooks/pretooluse-commit-msg-guard.sh) | bleibt | der Agenten-Kanal trägt die Klasse *getippter Aufruf* ohne Aktivierungsschritt und ist mit dem Commit-Kanal nicht austauschbar ([ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 2) — zwei Träger, zwei Reichweiten, kein zweiter Satz über denselben Gegenstand |
| `test/` | neu | der hermetische Fall zum neuen Träger; das gepinnte `BATS_IMAGE` führt kein `git` — der reale Beleg gehört wie bei `slice-mv` in den Skriptkopf |
| `test/mutations/` | neu | der Zahn aus DoD (2) |
| [`harness/README.md`](../../../../harness/README.md) | update | Reichweite und Grenze (DoD (3)) |
| `.claude/agents/*.md`, [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) | **nicht durch diesen Slice** | fremdes Rollen-Eigentum ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)), §1 |
| [`harness/tools/slice-mv.sh`](../../../../harness/tools/slice-mv.sh), `internal/archive/anwenden.go` | **nicht durch diesen Slice** | die vier Commit-Message-Formen der Werkzeuge tragen keine Kennung und brechen den scharf gestellten Träger **nach** dem `git mv`; ein Folge-Slice übernimmt es — Kennung **`slice-werkzeug-commits-tragen-eine-kennung`** ([ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 4) |

**Die Form ist an einem Nachbar-Repo erprobt, und ihr Urteil ist gemessen — beschrieben, nicht
verlinkt.** Ein Nachbar-Repo desselben Nutzers führt einen `commit-msg`-Hook, der die zwei Hälften
seines Standing-Gates als Regex auf `$1` spiegelt — **inklusive** der Merge-/Revert-Ausnahme, damit
er keinen Commit zurückweist, den das Gate zulässt — und **bash-only** läuft, ohne Docker. Er ist
dort ausdrücklich **optional und nicht-durchsetzend**: `core.hooksPath` ist lokale Konfiguration,
die nicht mit dem Klon reist, und `--no-verify` umgeht ihn. **Die Form abschreiben, das Ergebnis
nicht übernehmen** — die Entscheidung fällt an diesem Baum; einen **maschinen-lokalen Pfad** auf
jenes Checkout trägt dieses Dokument nicht, er löst für niemanden sonst auf
(`hostpaths` ist der Wächter dieser Klasse und in diesem Repo nicht adoptiert, s. [`AGENTS.md`](../../../../AGENTS.md) §3.1).

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
  gehört in DoD (1) entschieden, nicht hier weggewunken. — **Ausgang: entfallen** — die Antwort ist
  eine andere als die im Risiko genannte. Der Träger liegt **versioniert** unter `.githooks/`, nicht
  in `.git/hooks/`; er reist mit dem Klon (`git ls-files -s .githooks/commit-msg` → `100755`). Was
  der Klon allein **nicht** herstellt, ist die Aktivierung (`core.hooksPath` ist lokale
  Konfiguration) — das ist die bewusst gewählte Eigenschaft, nicht der Rest des Risikos: sie steht
  als Zeile in der Reichweiten-Tabelle und als Annahme in der
  [`ADR-0053`](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 3,
  und ihr Zustand ist gemessen — kennungsloser `-m`-Commit im frischen Klon **EXIT 0**, nach
  `make hooks-install` **EXIT 1** (Verifikation §3). Die Lücke ist damit deklariert und terminiert:
  ihr Hochschalt-Trigger ist der Re-Evaluierungs-Trigger 1 derselben ADR (`core.hooksPath` wird zum
  Automatismus). Kein unentschiedener Rest.
- **Ein `commit-msg`-Hook liegt außerhalb von `make`.** `git` startet ihn selbst; er darf darum
  nicht Docker voraussetzen, sonst bricht jeder Commit ohne laufenden Daemon. Ein hermetischer
  bash+awk-Prüfer wäre ein **zweiter** Prüfer neben dem `commits:`-Block der
  [`.d-check.yml`](../../../../.d-check.yml) — zwei Fassungen derselben Kennungs-Liste, die driften.
  — **Ausgang: entfallen** — beide Hälften sind beantwortet. Der Träger ist `bash` + coreutils ohne
  Docker und ohne Netz ([`ADR-0053`](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
  Festlegung 1, [`ADR-0004`](../../adr/0004-durchsetzungs-emission.md)); ein Commit ohne laufenden
  Daemon bricht nicht. Und die zwei Fassungen derselben Kennungs-Menge stehen nicht mehr
  unvergleichen da: `test/commit-msg-hook.bats` Fall 10 hält ihre **Mengen-Gleichheit**, nachdem der
  Review gemessen hatte, dass nur **eine** Richtung hielt (F-2, MEDIUM) — der Nachzug `8a0538d3`
  stellt jeder Richtung einen eigenen Zahn daneben, beide einzeln gefahren (Verifikation §4.4). Die
  Kopplung ist benannt **und** bewacht; ihr Träger ist `make test`.
- **Zwei Wächter über demselben Gegenstand.** Bleibt der PreToolUse-Zusatz neben dem neuen Träger
  stehen, blockt derselbe Commit zweimal mit zwei Begründungen, und ein Lauf weiß nicht, welche
  gilt. — **Ausgang: entfallen** — die Entscheidung ist getroffen und lautet: **beide bleiben**, und
  sie sind nicht austauschbar
  ([`ADR-0053`](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
  Festlegung 2). *Zweimal derselbe Commit mit zwei Begründungen* kann nicht entstehen, weil die zwei
  an zwei Punkten **desselben Pfades** sitzen und in einer Reihenfolge liegen: der Agenten-Kanal
  **vor** der Ausführung, der Hook **an** ihr. Blockt der erste, entsteht kein Commit, den der
  zweite sehen könnte; im Normalpfad urteilt genau einer, und die Reichweiten-Tabelle sagt, welcher
  welche Klasse trägt. Die Zusage, die das Risiko berührt, ist damit an einer Stelle deklariert statt
  zweimal.
- **Der Cutoff bleibt prospektiv, und das muss er.** Ein Maßstab über die ganze Historie wäre an
  einem Bestand rot, den niemand mehr ändern kann; gemessen liegt der kennungslose Anteil im
  jüngsten Bestand bereits niedrig
  (`RE='ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+|^(Merge |Revert )';
  git log --format='%s' -50 | grep -vcE "$RE"` → **2**, kein Erwartungswert). Ein Träger, der die
  Historie liest, kippt diese Lage. — **Ausgang: entfallen** — der gewählte Träger liest die
  **Message**, nicht die Historie: `git` übergibt ihm die Datei des Commits, der gerade entsteht
  ([`ADR-0053`](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
  Festlegung 1). Der Satz *„der Cutoff bleibt prospektiv"* gilt also unverändert weiter — er ist
  nicht durch die Träger-Wahl in Frage gestellt worden, weil keine der beiden Fassungen die
  Historie liest. Was der Bestand daneben trägt, ist eine andere Achse und bleibt benannt: die
  Werkzeug-Messages (Register-Beleg zu
  [`commit-message-ohne-traceability-kennung`](../observations/BEO-ALL/commit-message-ohne-traceability-kennung/observation.md)).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** **Die Bauart des Trägers war keine Abwägung, sondern Bedingung — und sie
  ist eingehalten.** `bash` + coreutils, kein Docker, kein Netz: ein Commit, der ohne laufenden
  Daemon bricht, wäre kein Wächter, sondern ein Ausfall
  ([`ADR-0004`](../../adr/0004-durchsetzungs-emission.md)). Zweitens war die **Reichweite am Bestand
  entscheidbar**, weil die zwei Hälften an zwei verschiedenen Punkten desselben Pfades sitzen — der
  Agenten-Kanal *vor* der Ausführung, der Hook *an* ihr; die Tabelle ist damit eine Messung und
  keine Absichtserklärung. Drittens hat der Review die Kopplung der zwei Kennungs-Listen **gemessen**
  statt sie zu glauben (F-2), und daraus wurde eine Mengen-Gleichheit mit je einem Zahn pro
  Richtung.
- **Was ging anders als geplant:** **Drei Dinge, und das erste ist ein Ablauf-Befund.** (1) **Der
  Start-Trigger aus §4 war beim Vollzug nicht erfüllt.** Die §3-Zelle stand auf *„offen"*, und die
  Architecture-Antwort kam **nach** den drei Umsetzungs-Commits
  (`7ee36939` · `2557901e` · `9ab67fa0` → `0f2409cc`). Getragen hat den Vollzug die **Form** — die
  Vorlage führt `core.hooksPath` + ein `make`-Ziel ausdrücklich als mögliche Antwort —, nicht die
  **Entscheidung**; der Reviewer führt es als Vorbemerkung, und dass es gutging, heilt den Ablauf
  nicht. (2) **Die Träger-Wahl brachte einen zweiten Arm mit**, den der Plan nicht als Liefer-Punkt
  hatte: die vier Message-Formen der eigenen Werkzeuge
  ([`ADR-0053`](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 4;
  die Kennung des Kandidaten steht am Ende dieser Notiz). Er ist der Grund, warum der Träger in
  diesem Klon **nicht aktiv** ist: scharf gestellt bricht `make slice-mv` **nach** dem `git mv`. Ein vierter
  Liefer-Punkt hieße *zurück zur Zerlegung*, also steht er als benannter Kandidat. (3) **Ein
  Zellen-Überclaim der neuen Reichweiten-Tabelle** ist erst von der Verifikation widerlegt worden
  (V-1) und in `dc392dd9` gezogen — die Zelle sagte über die Werkzeug-Klasse *„heute trägt keine
  eine"*, und die Mehrheit trägt eine
  (`git log --format='%s' | grep '^slice-mv:' | grep -cE 'ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+'`
  → **367** von `git log --format='%s' | grep -c '^slice-mv:'` → **411**; **keine Erwartungswerte**).
  (4) **Die Vorab-Messung, die [`AGENTS.md`](../../../../AGENTS.md) §3.11 Absatz 2 vor jedem
  vorgeschriebenen Ortswechsel verlangt, ist hier nicht über die zwei eingefrorenen Bäume
  gefahren.** Die Messung dieses Laufs hat `docs/reviews/` und `docs/plan/planning/done/` mit ihren
  beiden Ausschlüssen ausgeblendet — und genau dort hat der Nachzug dann geschrieben: zwei
  Zeitdokumente, eine fremde Verifikation und die Closure-Notiz von `slice-126`. Der Nachzug selbst
  ist die von [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2
  entschiedene Antwort; unterblieben ist der Schritt **vor** dem Move. Der Fund steht im
  Register-Beleg.
- **Steering-Loop-Eintrag:** *Neuer Sensor* — [`.githooks/commit-msg`](../../../../.githooks/commit-msg)
  samt [`harness/tools/commit-msg-traceability.sh`](../../../../harness/tools/commit-msg-traceability.sh)
  (die Prüfung), `make hooks-install` (die Aktivierung), `test/commit-msg-hook.bats`
  (`grep -c '^@test' test/commit-msg-hook.bats` → **13** Fälle, darunter die Mengen-Gleichheit der
  zwei Kennungs-Listen) und `test/mutations/340`–`342` (`ls test/mutations/34[0-2]*.sh | wc -l` →
  **3** Zähne; `340` färbt den bats-Fall, und der fährt den Aufruf **über** den Hook). **Kein
  `liegt in`-Feld:** Mit diesem Slice ist keine Regel verkörpert worden — der Sensor ist der
  Liefergegenstand, nicht die Antwort auf einen 3×-Schwellen-Übertritt. Der Eintrag ist gezählt,
  nicht verkörpert.
- **Beobachtungs-Register (`../observations/`):** **Vier Belege an vorhandenen Einträgen, kein neues
  Verzeichnis**; je Eintrag eine Datei `evidence/slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md`,
  und **kein Zähler wird gesetzt** — er folgt aus den Dateien. Die Zuordnung ist am Bestand
  gemessen, nicht aus den Reports übernommen:
  - [`commit-message-ohne-traceability-kennung`](../observations/BEO-ALL/commit-message-ohne-traceability-kennung/observation.md)
    — der Zähler steht damit bei **3×**
    (`ls docs/plan/planning/observations/BEO-ALL/commit-message-ohne-traceability-kennung/evidence/*.md | wc -l`).
    Der Eintrag ist über der Schwelle und trägt noch `offen`: Den **Ausgang** weist der Lese-Schritt
    zu, und in diesem Repo mit Wellen-Betrieb ist das die **nächste Welle-Closure** — nicht diese
    Slice-Closure. Die Commits dieses Vorgangs selbst fallen **nicht** in die Klasse (gemessen über
    die ganze Kette, Kommando im Beleg); die Klasse steht an der Werkzeug-Hälfte, die der Vorgang
    benennt und liegen lässt.
  - [`waechter-abdeckung-haengt-an-uninstruierter-konvention`](../observations/BEO-ALL/waechter-abdeckung-haengt-an-uninstruierter-konvention/observation.md)
    — **2×**, unter der Schwelle. Die **Feststellung, die §5 verlangt:** der Eintrag bekommt mit
    diesem Slice **keinen Ausgang**; er läuft als Lücke weiter. Geschlossen ist die Hälfte, die ohne
    Konvention auskommt — der Hook braucht die Aufrufform nicht —, offen die rollen-gebundene, und
    die ist fremdes Eigentum
    ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)). Der Vorgang hat
    sie nicht geschrieben (gemessen: `git diff --name-only 7ee36939^..dc392dd9 | grep -c '\.claude/agents/\|\.harness/skills/'`
    → **0**); sie steht jetzt aber als Zeile neben der Tabelle, mit diesem Eintrag als Adresse.
  - [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
    — **16×** (`ls docs/plan/planning/observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/evidence/*.md | wc -l`),
    Stand `geplant` (`slice-181`): **V-1**, die Zelle, die eine Klasse absolut behauptete, wo der
    Bestand sie teilt. Es ist genau der Fall, den §8 als Evidenz-Risiko dieser DoD angekündigt hatte
    — die eigene Ankündigung ist eingetreten.
  - [`verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
    — **14×** (`ls docs/plan/planning/observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/evidence/*.md | wc -l`),
    Stand `verkörpert`
    ([`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)): der Nachzug des
    Closure-Move hat in **zwei** Zeitdokumente geschrieben — die Closure-Notiz von `slice-126` und
    den Verifikations-Report von `slice-174`. Das ist die entschiedene Antwort und kein Befund; der
    Fund dieses Belegs ist die **Reihenfolge**, siehe (4) oben.
  - **Kein Beleg** ging an
    [`adaptions-marker-nennt-eine-stelle-die-emissions-klasse-nicht-haelt`](../observations/BEO-ALL/adaptions-marker-nennt-eine-stelle-die-emissions-klasse-nicht-haelt/observation.md):
    gemessen hat dieser Vorgang **keinen** `ANPASSEN`-Marker geschrieben oder angefasst
    (`git diff 7ee36939^..dc392dd9 | grep -c 'ANPASSEN'` → **0**), und `internal/emit/` kommt im Diff
    nicht vor. Die Klasse ist nicht eingetreten.
- **Folge-Slices:** **keiner geschnitten.** Der benannte Kandidat steht unten und ist nicht
  Gegenstand dieses Laufs.
- **Risiken aus §6:** vier Risiken, vier Ausgänge — **alle vier *entfallen***, jeder mit der
  Entscheidung oder Messung, die ihn beendet; die Ausgänge stehen in §6 neben ihren Risiken. **Kein
  Risiko wandert ins Register**, und das ist keine Weglassung: die zwei verbleibenden Lagen sind
  **deklariert** statt offen — die eine als Grenze der Trägerschaft mit Re-Evaluierungs-Trigger
  ([`ADR-0053`](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 3
  und Trigger 1), die andere als Kandidat mit Kennung.
- **Drei Paarungen:** Dieses Repo führt **Wellen** — geprüft von der nächsten Welle-Closure, auch
  für diesen Slice ohne Wellen-Zugehörigkeit. Was sie vorfindet, steht im letzten DoD-Punkt in §2.

**Der Zwilling — und der Kandidat, der noch nicht geschnitten ist.** Dieser Slice ist der
**Zwilling** von
[`slice-kennungs-waechter-geht-ins-ziel`](../done/slice-kennungs-waechter-geht-ins-ziel.md) in
[welle-emittierte-werkzeuge](welle-emittierte-werkzeuge.md) — dem Mitglied, das diesen Träger in
ein gebootstrapptes Ziel bringt. Das Mitglied **erbt die Träger-Wahl** aus
[`ADR-0053`](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) und nimmt sie
nicht vorweg; die Richtung *„erst die ausgeführte Fassung, dann die emittierte"* ist die Ordnung der
Welle und keine Sperre für dieses Mitglied. Die ADR steht auf `Proposed` — ihr Accept-Übergang ist
eine eigene Frage mit eigenem Beleg
([`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)) und kein Punkt
dieses Slice.

Benannt und **nicht** geschnitten: **`slice-werkzeug-commits-tragen-eine-kennung`**
([`ADR-0053`](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 4).
Sein Gegenstand sind die vier Message-Formen der eigenen Werkzeuge, die ihre Message ohne Kennung
bilden — scharf gestellt bricht der Träger damit `make slice-mv` **nach** dem `git mv` und
hinterlässt einen gestagten Rename ohne Commit. Seine Arbeit ist die Bedingung dafür, dass die
Aktivierung des Trägers in einem Baum, den mehrere Rollen zugleich benutzen, gefahrlos wird. Die
Kennung ist vergeben, seine Datei existiert nicht
(`ls docs/plan/planning/*/slice-werkzeug-commits-tragen-eine-kennung.md` → kein Treffer); ihn zu
schneiden ist Planner-Arbeit und lag nicht in diesem Auftrag.

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
