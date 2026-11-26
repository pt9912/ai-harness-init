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
250–251: je Lauf ein `git worktree` bzw. ein weiterer Klon, `Verantwortlich:`
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

- [ ] **LP1 — Docker-Block-Neufassung §3.9:** §3.9 der [`AGENTS.md`](../../../../AGENTS.md)
  trägt den Tool-/Versions-Check-Verweis (`harness/sensors/environment-check.md`) <!-- d-check:ignore (Platzhalter-Pfad: legt LP1 dieses Zugs an) -->

  und den Umgebungs-Mechanik-Satz (Träger-Form der Umgebungs-Zusage), Form-Quelle
  v7-Vorlage §3.1 (Pfad-Angabe im Plan oben). Messung: je git-Diff des Zugs die
  zwei Formen; `make docs-check` grün am Zug-Stand.
- [ ] **LP2 — „Parallele Läufe"-Absatz:** der Absatz steht je der Vorlage
  (Zeilen 250–251, Pfad-Angabe im Plan oben); der Worktree-Pfad ist Fundstellen-Form
  (`d-check:ignore` am Fundort, Begründung in Klammern); `make docs-check` grün.
- [ ] **LP3 — Emitter-Form-Verdikt:** der Verdikt-Zug belegt Walk-Form —
  `grep -n 'AGENTS.template.md' internal/emit/templates.go` (Vorlagen-Liste des
  Walks) und `ls internal/emit/` (kein `agents.go`-Form-Konstanten-Träger) —
  §7 trägt die Ausgaben; Änderung an `internal/emit/`-Dateien: keine
  (Negativ-Aussage je git-Diff des Zugs).

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
  *entfallen* → keine Berührung (Fundliste trägt die 0).
- **R2 — der Worktree-Inline-Code-Pfad färbt `codepaths` (`repo-escape`):** die
  Vorlagen-Form `../<repo>-<lauf>` löst von AGENTS.md nach draußen auf. Ausgang:
  *entfallen* → Fundstellen-Form (`d-check:ignore`, LP2); *eingetreten* → falls
  nur ein `ignore-refs`-Eintrag die Zeile still hält, Rückführung `next` (die
  Verbreiterung braucht eine ADR, §1 Punkt 2).
- **R3 — der Architect-Sub-Zug scheitert an der Rollen-Grenze:** ein Zug, der
  AGENTS.md und die übrigen Artefakte in **einem** Commit trägt, verstößt gegen
  §3.8. Ausgang: *entfallen* → zwei Commits, Kennung je Message (Form der
  Tafel-Bindung); das ist keine Umplanung, sondern die LP-Vorgabe.

## 7. Closure-Notiz

<!-- Bei der Closure füllen (Implementer/Planner): Fundlisten je Kommando,
Walk-Verdikt, Lern-Eintrag, Risiko-Ausgänge, Register-Paarung. -->

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
