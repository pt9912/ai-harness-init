# Slice slice-170: Das Archivierungs-Werkzeug der Wellen-Closure

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD unten, ein repo-weiter Beleg darüber
hinaus steht in keinem Kriterium (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein benanntes Target läuft auf frischem Checkout),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(das Packen läuft im gepinnten Image, nicht auf dem Host).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Schritt 4 der Wellen-Closure — Zeitdokumente nach `done/<welle-id>/archiv.zip`, Stubs an ihrer
Stelle — läuft als Kommando statt von Hand.**

Der Schritt gilt in diesem Repo ab dieser Datei in `done/`; die Start-Bedingung steht in
[`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md) Schritt 4
([slice-158](../done/slice-158-archivierungs-schritt.md)). Von Hand archiviert niemand: Die
Vollständigkeit des Archivs bezeugt allein der Archivierungs-Commit, und der Move bricht dieselben
Verweis-Formen, für die `make slice-mv` gebaut wurde — er zieht sie nur zwischen den vier
Lifecycle-Verzeichnissen nach, nicht eine Ebene tiefer (`BEO-003` im [Register](../observations.md)).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **`make archive-welle WELLE=<welle-id>` legt das Archiv an** (`done/<welle-id>/archiv.zip`,
      gepacktes Image statt Host-Werkzeug), schreibt je archiviertem Slice und für den Welle-Plan
      einen Stub per `cp` aus den zwei vendored Vorlagen und zieht die Verweise auf die bewegten
      Dateien nach — Move und Inhalt in getrennten Commits
      ([`AGENTS.md`](../../../../AGENTS.md) §3.3).
- [x] **Die Einsammel-Regel liegt im Werkzeug, nicht im Aufrufer:** Slices, deren `Welle:` diese
      Welle nennt, **und** die wellenlosen seit der letzten Closure; Slices einer noch offenen Welle
      bleiben liegen. Rot gesehen ([`AGENTS.md`](../../../../AGENTS.md) §3.6) an einem Slice jeder
      der drei Klassen.
- [x] **Ein Wächter hält die Stub-Form** — Archiv-Zeiger vorhanden **und** keine
      Abschnittsüberschrift mehr; die zweite Hälfte ist die tragende, denn ein Stub mit Zeiger und
      vollem Text wäre die Archivierung, die es nicht gab. Rot gesehen an genau diesem Fall.
- [x] `make gates` grün.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/` | neu | die Operation als Shell-Helfer, damit `shell-lint` und bats sie decken — Ablage und Zuschnitt folgen dem Nachbarn, der denselben Move fährt (`slice-mv.sh`) |
| `Makefile` | update | `archive-welle` als benanntes Target, nicht in `gates` |
| `test/archive-welle.bats` | neu | Einsammel-Regel und Stub-Form über einem synthetischen Baum |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-158](../done/slice-158-archivierungs-schritt.md)
liegt in `done/` — dort steht, was das Werkzeug ausführt und ab wann der Schritt läuft.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn das Nachziehen der Verweise eine
  zweite Ersetzungs-Regel verlangt — die Grenze von `BEO-003` im [Register](../observations.md) ist
  ein eigener Gegenstand und kein Anhang dieses Werkzeugs.
- `in-progress` → `open` (blockiert — Carveout?): wenn ein deterministisches Archiv im gepinnten
  Image nicht herstellbar ist und damit unklar bleibt, was ein zweiter Lauf belegt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; ein Probelauf über eine geschlossene Welle ist gefahren und sein Ergebnis genannt;
Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Ein Zip ist opak und trägt Zeitstempel:** zwei Läufe über denselben Bestand liefern verschiedene
  Bytes, und kein Gate liest hinein. Was ein zweiter Lauf dann belegt, ist zu benennen. —
  **Ausgang:** **entfallen** — die Zeitstempel-Hälfte tritt nicht ein, weil nicht `zip` packt,
  sondern `git archive --format=zip` über einem Tree-Operanden: die Eintrags-Zeitstempel kommen aus
  der Commit-Zeit, nicht aus der Uhr des Laufs. Gemessen an zwei Läufen über denselben Commit,
  `sha256sum` beide Male `0d4ef4178295a1544376b0cbe4853531657a3b25358a8ad87c5ae19d67ab494d`
  (Scratch-Repo, Skriptkopf §BELEG; keine Erwartungswerte,
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Ein zweiter Lauf belegt damit Byte-Gleichheit. Dass kein Gate ins Zip hineinliest,
  bleibt wahr — das ist die Aussage der Quelle selbst (Vollständigkeit bezeugt der
  Archivierungs-Commit) und kein Rest dieses Risikos.
- **Die eingehende Hälfte der präfixlosen Verweis-Form hat keinen Träger** (`BEO-003` im
  [Register](../observations.md), Grenze 3): ein Verweis ohne Verzeichnis-Segment bricht beim Move
  und wird nicht nachgezogen. — **Ausgang:** **entfallen** für diese Operation:
  `rewrite_bare_sibling_in_file` ankert an der Link-Klammer statt am Verzeichnis-Literal und hängt
  jedes präfixlose Ziel in den flach gebliebenen `done/`-Dateien auf `<welle-id>/` um. Zwei
  bats-Fälle führen beide Richtungen, der Lauf über das Scratch-Repo zieht zwei solche Ziele nach.
  Für `make slice-mv` bleibt die Grenze unberührt — dort wechselt die Datei das Geschwister-
  Verzeichnis statt die Ebene, und die Registerzeile führt sie weiter.

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
- **Beobachtungs-Register (`../observations.md`):** <neue `BEO-<NNN>` angelegt (Sub-Area, 1×, Beleg slice-NNN) | `BEO-<NNN>` auf <N>× erhöht, Beleg slice-NNN ergänzt | keine Beobachtung angefallen>
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — Planning-Lifecycle und
Harness-Tools liegen in keiner engeren Sub-Area der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area).

**Vorgelagert — offene Beobachtungen sichten:** `BEO-003` (Verweise brechen beim vorgeschriebenen
Move; verkörpert in `make slice-mv`, mit benannter Grenze) steht als Risiko in §6. Weitere Treffer:
keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
