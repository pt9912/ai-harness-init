# Slice slice-c6-agents-vorlage-v7-0-0: AGENTS-Vorlagen-Formen — Docker-Block und Parallele Läufe am Stand v7.0.0

**Lifecycle:** Der Zustand dieser Datei ist das Verzeichnis, in dem sie liegt
(`open/`, `next/`, `in-progress/`, `done/`); er wechselt nur durch `git mv`
(Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine).

**Welle:** [`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md) —
deren Closure-Trigger trägt das Mehr über die DoD dieses Slice: die Gesamt-Gates
am neuen Stand, der Replay-Lauf `make full-smoke` und der Bestands-Lese-Schritt.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (adoptierter Stand `v7.0.0`) · Form-Bezüge: [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) · [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) · Tafel-Bezug: Delta-Tafel C6 in [`welle-baseline-sprung-v7-0-0.md`](../welle-baseline-sprung-v7-0-0.md) §4, gelesen von [`slice-baseline-delta-lesung-v7-0-0`](../done/slice-baseline-delta-lesung-v7-0-0.md).

**Berührte Spec-Stellen:** `—` — die AGENTS-Kern-Formen tragen ihr Stratum aus
dem Baseline-Regelwerk, Modul-14 §Umgebungs-Zusage (Pfad: `.harness/baseline/v7.0.0/regelwerk/modul-14-docker-harness.md`)
und die Vorlage selbst (Pfad: `.harness/baseline/v7.0.0/templates/AGENTS.template.md`);
keine Festlegung der [`spec/lastenheft.md`](../../../../spec/lastenheft.md)/[`spec/architecture.md`](../../../../spec/architecture.md)
dieses Repos; die Anforderungs-Seite steht in der `LH-QA`-ID des Felds Bezug.

**Verantwortlich:** pt9912

**Autor:** pt9912 (Planner-Lauf). **Datum:** 2026-11-26.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die AGENTS-Kern-Formen der v7-Vorlage in die eigene [`AGENTS.md`](../../../../AGENTS.md)
ziehen — (a) die **Docker-Block-Neufassung** von §3.9: der Tool-/Versions-Check-Verweis
auf `harness/sensors/environment-check.md` <!-- d-check:ignore (Platzhalter-Pfad: legt LP1 dieses Zugs an) --> und der Umgebungs-Mechanik-Satz
(Docker ist Träger der Umgebungs-Zusage, Modul-14-Termini), Form-Quelle die
v7-Vorlage §3.1 `### 3.1 Docker-only` (Pfad: `.harness/baseline/v7.0.0/templates/AGENTS.template.md`,
Zeilen 97–109); (b) der **„Parallele Läufe"-Absatz** je der Vorlage (Zeilen
250–261: je Lauf ein `git worktree` bzw. ein weiterer Klon, `Verantwortlich:`
nennt Person und Zweig) — der Worktree-Pfad des Absatzes bekommt je v7-Regel
die Fundstellen-Form (`d-check:ignore`-Kommentar am Fundort, [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)-Platzhalter-Ausschluss);
(c) das **Emitter-Form-Verdikt**: die AGENTS-Vorlage ist Walk-Quelle des
Emitters (Beleg-Vorlauf: `internal/emit/templates.go` führt `AGENTS.template.md`
in der Vorlagen-Liste des Walks, Zeile 206; ein `agents.go` mit Form-Konstanten
existiert nicht) — der Code-Zug entfällt je Form, belegt in §7.

**Sub-Zug-Kennzeichnung:** die AGENTS.md-Änderung berührt den Hard-Rule-Block
— ihr Commit trägt die Rolle selbst (`Rolle Architect: …`, [`AGENTS.md`](../../../../AGENTS.md)
§3.8-Form); der Implementer-Zug fährt die übrigen Artefakte der DoD.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **C7** — übernimmt seine Tafel-Kennung `slice-c7-adaptions-nachzuege-v7-0-0`
  (Terminologie/Stanze und CI-Nachheilung). Klasse 1 (Folge-Slice der Tafel; die
  Cluster-Zeile nennt den Gegenstand).
- **Die Verbreiterung eines `ignore-refs`-Eintrags der [`.d-check.yml`](../../../../.d-check.yml)** —
  Klasse 3: ein neues Paar verbreitert die Deckung einer Deklaration und verlangt
  eine eigene ADR (Form der C5-Bestands-Korrektur: [`ADR-0026`](../../../../docs/plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md)/[`ADR-0039`](../../../../docs/plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md));
  je Fundstelle greift stattdessen der `d-check:ignore`-Kommentar am Fundort.
- **Die Terminologie-Nachzüge am Konventionsspeicher** ([`MR-048`](../../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag),
  [`MR-047`](../../../../harness/conventions.md#mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr),
  Inventur-Texte) — Klasse 1: Adresse `slice-c7-adaptions-nachzuege-v7-0-0`; hier
  nur die §3.9-Docker-Form als Terminologie-Anknüpfpunkt, kein Eintrags-Rumpf.
- **Der Emitter-Code-Zug** — entfällt als Alternative mit Beleg (Klasse 3, Form
  des C5-Verdikts): die AGENTS-Vorlage ist Quelldatei des Walk-Forms über den
  vendored `templates/`-Baum; `internal/emit/templates/agents/` führt die
  Rollen-Commande (architect/implementer/planner/reviewer/validator/verifier),
  nicht den AGENTS-Kern. Kein Konstante-Griff.

## 2. Definition of Done

Liefer-Punkte (drei; gezählt nach [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)):

- [x] **LP1 — Docker-Block-Neufassung §3.9:** §3.9 der [`AGENTS.md`](../../../../AGENTS.md)
  trägt den Tool-/Versions-Check-Verweis (`harness/sensors/environment-check.md`) <!-- d-check:ignore (Platzhalter-Pfad: legt LP1 dieses Zugs an) -->

  und den Umgebungs-Mechanik-Satz (Träger-Form der Umgebungs-Zusage), Form-Quelle
  v7-Vorlage §3.1 (Pfad-Angabe im Plan oben). Messung: je git-Diff des Zugs die
  zwei Formen; `make docs-check` grün am Zug-Stand. ✓ Sub-Zug `a45df66b` —
  `git show --stat` → allein [`AGENTS.md`](../../../../AGENTS.md) (+22 Zeilen), die zwei Formen im
  Diff (Report Prüffeld 1/2; Byte-Stichprobe in §7 am Closure-Stand wiederholt).
- [x] **LP2 — „Parallele Läufe"-Absatz:** der Absatz steht je der Vorlage
  (Zeilen 250–261, Pfad-Angabe im Plan oben); der Worktree-Pfad ist Fundstellen-Form
  (`d-check:ignore` am Fundort, Begründung in Klammern); `make docs-check` grün. ✓
  `diff <(sed -n '250,261p' .harness/baseline/v7.0.0/templates/AGENTS.template.md) <(sed -n '552,563p' AGENTS.md)`
  → leer (Report Prüffeld 2; am Closure-Stand 2026-11-26 in §7 wiederholt).
- [x] **LP3 — Emitter-Form-Verdikt:** der Verdikt-Zug belegt Walk-Form —
  `grep -n 'AGENTS.template.md' internal/emit/templates.go` (Vorlagen-Liste des
  Walks) und `ls internal/emit/` (kein `agents.go`-Form-Konstanten-Träger) —
  §7 trägt die Ausgaben; Änderung an `internal/emit/`-Dateien: keine
  (Negativ-Aussage je git-Diff des Zugs). ✓ Kommando-Ausgaben je in §7;
  `git show --stat a45df66b f4a94a75` führt keinen `internal/emit/`-Pfad
  (Report Negativbefunde-Zeile 5).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`AGENTS.md`](../../../../AGENTS.md) (§3.9 Docker-Block, „Parallele Läufe"-Absatz) | update | LP1/LP2 — die zwei Formen der Vorlage ins Hard-Rule-Briefing ziehen; der Commit trägt die Rolle selbst (Sub-Zug-Kennzeichnung §1, [`AGENTS.md`](../../../../AGENTS.md) §3.8) |
| `internal/emit/` | inspect — keine Änderung | LP3 — das Walk-Verdikt ist eine Lesung: die Quelle der AGENTS-Kern-Formen ist der Walk über den vendored `/templates/`-Baum, nicht der Code (Ausschluss §1) |
| `.d-check.yml` (`ignore-refs`) | entfällt | Ausschluss §1 Punkt 2 — die Fundstellen-Form (`d-check:ignore` am Fundort) trägt R2; eine Verbreiterung eines Eintrags verlangt eine eigene ADR |
| `harness/conventions/` (Rümpfe [`MR-047`](../../../../harness/conventions.md#mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr), [`MR-048`](../../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag)) | entfällt | Ausschluss §1 Punkt 3 — die Terminologie-Nachzüge sind der C7-Zug ([`slice-c7-adaptions-nachzuege-v7-0-0`](../in-progress/slice-c7-adaptions-nachzuege-v7-0-0.md)) |

**Ansatz als Liste** — die zwei Formen reisen byte-genau aus dem vendored `v7.0.0`-Baum:

- Vorlage §3.1 Docker-Block (Zeilen 97–109) — nur die zwei Formen (Check-Verweis,
  Umgebungs-Mechanik-Satz); die Dogfood-Abwägung zur byte-differenzierten
  Träger-Satz-Fassung trägt §7.
- Vorlage „Parallele Läufe"-Absatz (Zeilen 250–261) — byte-genau; der
  Worktree-Pfad ist Fundstellen-Form (`d-check:ignore` am Fundort).

## 4. Trigger

**Start (`open` → `next`, `next` → `in-progress`):**
[`slice-c5-vertrauensgrenzen-v7-0-0`](../done/slice-c5-vertrauensgrenzen-v7-0-0.md)
liegt in `done/` — beobachtbar am Verzeichnis; die Delta-Tafel §4 der [`welle-baseline-sprung-v7-0-0.md`](../welle-baseline-sprung-v7-0-0.md)
trägt C6 als geordneten Vorschlag. `open→next` setzt den Verantwortlichen.
Der Implementer übernimmt.

**Rückführungen — vorab benennen:**
- **`in-progress` → `next` (zu groß / Schnitt falsch):** die Kern-Lesung findet
  AGENTS-Vorlagen-Formen über der M-Schätzung (mehr als die zwei Formen + Verdikt
  oder eine Form verlangt eine Umsetzung, die §1 ausgeschlossen hat) — dann
  zurück; die Fundliste bleibt, die Formen zerlegen sich in eigene Slices.
- **`in-progress` → `open` (Blocker):** die v7-Vorlage trägt die Formen nicht am
  C1-Stand (`make baseline-verify` rot oder Form-Abweichung gegen das
  Release-Asset) — Blocker mit Carveout-Frage (Modul 7), kein stiller Carveout.

## 5. Closure-Trigger

LP1 und LP2 je geleistet (git-Diff + `make docs-check` grün), LP3 Verdikt
belegt in §7; jeder §6-Risiko mit Ausgang, Lern-Eintrag in §7.

## 6. Risiken und offene Punkte

- **R1 — die Docker-Block-Neufassung zieht Terminologie-Nachzüge nach:** der
  Umgebungs-Zusage-Satz berührt [`MR-048`](../../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag)/[`MR-047`](../../../../harness/conventions.md#mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr)-Begriffe, deren Eintrags-Rümpfe
  §1 Punkt 3 ausschließt. Ausgang: *eingetreten* → die Formen stehen der
  C7-Kennung in dessen §8-Sichtung frei (Adresse: `slice-c7-adaptions-nachzuege-v7-0-0`);
  *entfallen* → keine Berührung (Fundliste trägt die 0). **Ausgang (Closure
  2026-11-26):** *entfallen* — kein Konventions-Rumpf berührt: `git show --stat` je
  Zugs-Commit führt `AGENTS.md` bzw. Plan + `roadmap.md`, kein `harness/conventions*`
  (Report Prüffeld 1, Negativbefunde-Zeile 1). Die C7-Kennung bleibt Adresse
  ([`slice-c7-adaptions-nachzuege-v7-0-0`](../in-progress/slice-c7-adaptions-nachzuege-v7-0-0.md),
  Stand vor dieser Closure).
- **R2 — der Worktree-Inline-Code-Pfad färbt `codepaths` (`repo-escape`):** die
  Vorlagen-Form `../<repo>-<lauf>` löst von AGENTS.md nach draußen auf. Ausgang:
  *entfallen* → Fundstellen-Form (`d-check:ignore`, LP2); *eingetreten* → falls
  nur ein `ignore-refs`-Eintrag die Zeile still hält, Rückführung `next` (die
  Verbreiterung braucht eine ADR, §1 Punkt 2). **Ausgang (Closure 2026-11-26):**
  *entfallen* — die beobachtete Form steht in §7: `codepaths` misst auch
  `AGENTS.md` (Befund an `AGENTS.md:404` am ersten Lauf), die Fundstellen-Form
  trägt die Zeile; [`.d-check.yml`](../../../../.d-check.yml) bleibt in beiden
  Zugs-Commits unberührt, keine Verbreiterung, keine Rückführung.
- **R3 — der Architect-Sub-Zug scheitert an der Rollen-Grenze:** ein Zug, der
  AGENTS.md und die übrigen Artefakte in **einem** Commit trägt, verstößt gegen
  §3.8. Ausgang: *entfallen* → zwei Commits, Kennung je Message (Form der
  Tafel-Bindung); das ist keine Umplanung, sondern die LP-Vorgabe. **Ausgang
  (Closure 2026-11-26):** *entfallen* — zwei Commits gezogen, beide Messages
  tragen die Kennung (`Rolle Architect:` für `a45df66b`, `Rolle Implementer:` für
  `f4a94a75`; Report Prüffeld 5, Negativbefunde-Zeile 1).

## 7. Closure-Notiz

<!-- Bei der Closure füllen (Implementer/Planner): Fundlisten je Kommando,
Walk-Verdikt, Lern-Eintrag, Risiko-Ausgänge, Register-Paarung. -->

### Übergabe-Artefakte des Implementer-Zugs (2026-11-26, AGENTS-Commit `a45df66b`; Formal-Closure je [`AGENTS.md`](../../../../AGENTS.md) §3.10 beim Planner)

- **LP3 — Walk-Verdikt:** `git grep -n 'AGENTS.template.md' internal/emit/templates.go` → eine Fundstelle im Walk-Eintrag:
  `internal/emit/templates.go:206: "AGENTS.template.md",` (Kommentar am Rename-Schutz, Zeile 165);
  `ls internal/emit/` → **Korrektur zur Formel §1**: `agents.go`
  existiert und trägt die Rollen-Typen (embed `templates/agents`, die `.claude/agents/*`-Quellen
  — kein AGENTS-Kern); `grep -c 'Docker\|Parallele' internal/emit/agents.go` → `0`.
  Verdikt je Form: Walk-Quelle, der Emitter-Code-Zug entfällt — ein AGENTS-Kern-Konstanten-Griff
  gibt es nicht.
- **Dogfood-Abwägung (LP1), 2 Zeilen:** der v7-Träger-Satz (*„Toolchain-Reproduzierbarkeit —
  Docker ist hier der Träger der Umgebungs-Zusage"*) und der Dogfood-Begründungs-Satz
  (*„Reproduzierbar ist ein Lauf über das gepinnte Image"*) sind byte-differenziert — die
  Dogfood-Fassung behält ihre Begründung und trägt den v7-Satz als eigenen
  **Umgebungs-Zusage**-Absatz; der Tool-/Versions-Check-Verweis nennt statt der Vorlagen-Datei
  <!-- Platzhalter-Pfad je LP1 (d-check:ignore am Fundort in AGENTS.md) -->
  die Träger-Form (Docker-only-Deckel, gepinnte Digests, `make traeger-pins-check` /
  `make traeger-fetch`), die Verweis-Form der Vorlage bleibt am Fundort mit `d-check:ignore`
  markiert.
- **R2 — beobachtete Form:** `codepaths` misst auch `AGENTS.md` (Befund `codepath-missing` an
  AGENTS.md:404 am ersten Lauf) — die Fundstellen-Form (`d-check:ignore` am Fundort) trägt die
  Zeile; **keine** Verbreiterung eines `ignore`-Eintrags nötig. Der
  Ruhe-Pfad `.claude/worktrees/` des Parallel-Läufe-Absatzes färbt nicht (`.gitignore`
  führt die Zeile, `grep -n worktrees .d-check.yml` → 0 — die v7-Ignore-Form trägt die
  emittierte Vorlage, `scan.ignore` des Dogfoods bleibt unverändert je
  [`slice-c3-d-check-faecher-v7-0-0`](../done/slice-c3-d-check-faecher-v7-0-0.md) §1).

**Was hat funktioniert:** der Zug blieb in zwei Commits je Rolle getrennt
(§3.8-Form — `Rolle Architect:` für [`AGENTS.md`](../../../../AGENTS.md) allein), die zwei Formen
reisten byte-genau aus dem vendored `v7.0.0`-Baum, und der Walk-Verdikt-Griff
blieb eine Lesung ohne Emitter-Änderung. Review: Report
[`../../../../docs/reviews/2026-11-25-slice-c6-agents-vorlage-v7-0-0.md`](../../../../docs/reviews/2026-11-25-slice-c6-agents-vorlage-v7-0-0.md)
— HIGH 0 · MEDIUM 0 · LOW 1 · INFO 2.

**Fundlisten je Kommando** ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)-Form, jede Zahl am Kommando):

- **Byte-Genau-Stichprobe (LP2)** — `diff <(sed -n '250,261p' .harness/baseline/v7.0.0/templates/AGENTS.template.md) <(sed -n '552,563p' AGENTS.md)` → **leer** (byte-gleich; Report Negativbefunde-Zeile 2, am Closure-Stand 2026-11-26 wiederholt).
- **Rollen-Commit-Zuschnitte (LP1/LP3)** — `git show --stat --format=short a45df66b f4a94a75` → `a45df66b`: allein [`AGENTS.md`](../../../../AGENTS.md) (+22), Message `Rolle Architect:`; `f4a94a75`: Plan (+26) + `roadmap.md` (−2), Message `Rolle Implementer:` (Report Negativbefunde-Zeile 1).

**F-Bearbeitung je Review:**

- **F-1 (LOW, „Vorlagen-Abschnitt fehlt am Slice-Plan")** — der Abschnitt
  `## 3. Plan (vor Code)` mit der Tabelle der Züge ist im Inhalt-Commit dieser
  Closure nachgezogen (Bestands-Korrektur an der Plan-Datei; der
  Abschnitts-Verstoß lag vor dem Review-Range und wird vom Zugs-Diff nicht
  getragen).
- **F-2 (INFO, „Zitat-Spanne enger als der Ist-Bereich")** — beide Zitat-Stellen
  (§1 (b) und LP2) berichtigt: „Zeilen 250–251" → „Zeilen 250–261" (Ist-Bereich
  byte-verifiziert, Report Prüffeld 2).
- **F-3 (INFO, „Marker-Ziehung folgt dem Claim mit Versatz")** — getragen: die
  Korrektur zog der Zugs-Diff selbst nach (`f4a94a75`, −2 Zeilen `roadmap.md`);
  die Versatz-Frage zählt im Register
  ([`BEO-ALL/marker-ziehung-folgt-dem-claim-mit-versatz`](../observations/BEO-ALL/marker-ziehung-folgt-dem-claim-mit-versatz/observation.md)).

**Lern-Eintrag (geschärfte Regel, `· seit slice-c6-agents-vorlage-v7-0-0`):** eine
Zitat-Spanne der Form-Quelle in §1/LP trägt den **Ist-Bereich** des Absatzes in der
Vorlage, nicht die zwei Zeilen der Zitier-Stelle — der Griff ist die
Spannen-Stichprobe (`sed -n` je genannter Spanne, `diff` der Blöcke) **vor** dem
Zitat im Plan. Die Klasse zählt im Register unter
[`BEO-ALL/zitat-spanne-enger-als-der-ist-bereich`](../observations/BEO-ALL/zitat-spanne-enger-als-der-ist-bereich/observation.md)
— 2× (C5-INFO-1, C6-INFO-2), Stand `offen` unter der 3×-Schwelle; sie trägt kein
`liegt in`-Feld und ist damit gezählt, nicht verkörpert (Paarung (a)).

**Beobachtungen:** die drei Finding-Klassen des Reports gehen wie oben —
„Zitat-Spanne …" (2×, Verzeichnis angelegt, 2 Belege) · „Marker-Ziehung …" (2×,
Verzeichnis angelegt, 2 Belege) · „Vorlagen-Abschnitt fehlt am Slice-Plan"
(Erstauftreten, benannt ohne Verzeichnis: die Klasse ist am Planungs-Bestand vor
dem Review-Range getragen, der Zugs-Diff erbt sie nicht, und die Berichtigung
steht in diesem Inhalt-Commit). Die §8-Sichtung hielt — keine Register-Zeile
trifft die AGENTS-Vorlagen-Formen.

**Drei Paarungen (geprüft am 2026-11-26, nach dem `git mv` — Form der C5-Closure):**

- *(a) Anker:* §7 trägt kein `liegt in`-Feld — der Lern-Eintrag ist gezählt, nicht
  verkörpert (Beleg: Register, 2 Belege je neuer Klasse). Grün.
- *(b) Folge-Slice:* §6 R1 nennt
  [`slice-c7-adaptions-nachzuege-v7-0-0`](../in-progress/slice-c7-adaptions-nachzuege-v7-0-0.md)
  als Adresse — die Datei liegt im Planning-Lifecycle (`next/`) und nimmt den
  Terminologie-Posten an. Grün.
- *(c) Register:* die in §7 genannten Beobachtungen existieren als Verzeichnisse
  mit nicht leeren Belegen —
  [`BEO-ALL/zitat-spanne-enger-als-der-ist-bereich`](../observations/BEO-ALL/zitat-spanne-enger-als-der-ist-bereich/observation.md)
  und
  [`BEO-ALL/marker-ziehung-folgt-dem-claim-mit-versatz`](../observations/BEO-ALL/marker-ziehung-folgt-dem-claim-mit-versatz/observation.md)
  (je 2 Belege). Grün.

**Ruhe-Marker:** [`roadmap.md`](../in-progress/roadmap.md) §Offene Wellen — `in-progress/`
trägt nach dem `git mv` nur ihr `roadmap.md`; der Marker „Nichts in Arbeit." steht und trifft
den Zustand (Paarungs-Commit, Form der Zug-Korrektur `f4a94a75`; die Versatz-Frage zählt im
Register, F-3 oben).

**Paarungen geprüft am 2026-11-26:** `make docs-check` → 3023 Datei(en) geprüft, 0 Befund(e)
(frische Messung am Paarungs-Commit; der Move-Stand trug die zwei Befunde der hier getragenen
Hälften — der [`MR-047`](../../../../harness/conventions.md#mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr)-Anker-Ausschnitt und der Ruhe-Marker). `make gates` zum Zug-Ende — grün,
Stempel deckt HEAD.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Beide vorgelagerten Prüfungen vor dem Block:

1. **Sub-Area-Wahl prüfen:** die berührte Sub-Area ist `*` (gesamtes Repo) —
   der Zug ist eine AGENTS-Kern-Form, kein Pfad-Ensemble; Kürzel `ALL` (Modus-Deklaration
   [`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area). Schwelle erfüllt.
2. **Offene Beobachtungen sichten:** das
   [Register](../observations/) trägt **keine** Beobachtung, die die
   AGENTS-Vorlagen-Formen, den Docker-Block oder den Parallel-Läufe-Absatz
   berührt (Sichtung: `grep -rl -i -e docker -e umgebung -e vorlag
   docs/plan/planning/observations/` — die Treffer betreffen Nachbar-Klassen:
   Image-Pin-Guard, Handbuch-Doc-Kommentar der `slice-191`-Basis; gelesen auf
   dem Hauptzweig, 2026-11-26). **Keine Treffer sind ebenfalls eine Antwort** —
   Zähler-Stand `—`.

**Modus-Begründung:** alle berührten Sub-Areas GF — der Zug übernimmt
Norm-Formen der Vorlage, kein Bestands-Rückbau; Phase-Reife Phase 3 (Pfad:
`.harness/baseline/v7.0.0/regelwerk/modul-02-harness-bootstrap.md`); Evidenz-/
Diskrepanz-Risiko niedrig (die Form-Quelle ist der vendored Baum, Integrität am
C1-Pin); Reconciliation-Aufwand kein — keine Carveout-Anlage, Graduation-Trigger
entfällt (GF).
