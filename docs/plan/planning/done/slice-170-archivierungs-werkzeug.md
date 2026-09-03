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

**Die drei offenen Haken hängen nicht an Arbeit, sondern an der Rolle.** Closure-Notiz,
Register-Fortschreibung und die drei Paarungen sind Closure-Schritte und laufen beim **Planner**,
nach Review und Verifikation und in einem eigenen Kontext (Baseline-Regelwerk
`modul-08-agentenrollen.md` §Die neun Übergaben; [`.claude/commands/implement-slice.md`](../../../../.claude/commands/implement-slice.md)
Schritte 23 und 24). Die Implementation setzt sie nicht selbst — täte sie es, fielen die drei
Rollen in einen Kontext, gegen den die Trennung gebaut ist.

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
  der Commit-Zeit, nicht aus der Uhr des Laufs. Gemessen an zwei Läufen über demselben
  Tree-Operanden, zwei Sekunden auseinander — `sha256sum` liefert beide Male denselben Wert. Der
  Wert **steht hier nicht**, und das ist die Anwendung von
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2 und nicht ihre Umgehung: Er hängt am Commit des jeweiligen Repos, und ein Leser, der
  das Kommando daneben fährt, bekäme einen anderen — eine Zahl, die ihr eigenes Kommando nicht
  reproduziert, belegt nichts. Belegt ist die **Eigenschaft** (zwei Läufe, gleiche Bytes), und das
  Nachmess-Kommando dafür steht im Skriptkopf (`harness/tools/archive-welle.sh`, Abschnitt BELEG).
  Die opake Hälfte des Risikos bleibt wahr — kein Gate liest ins Zip hinein; das ist die Aussage
  der Quelle selbst (Vollständigkeit bezeugt der Archivierungs-Commit) und kein Rest dieses
  Risikos. Was ein zweiter Lauf **zusätzlich** belegt: der `unzip -p`-Zeiger, den der Stub
  abdruckt, gibt den archivierten Volltext wortwörtlich zurück — als genau dieses Kommando
  gefahren, nicht als Variante davon.
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

**Closure-Kriterien (beobachtet, nicht behauptet):**

1. **Probelauf über eine geschlossene Welle dieses Repos** — `make archive-welle WELLE=welle-10`
   über einem Klon des Hauptzweigs endet an Ausgang 3 („42 wellenlose Slice(s) liegen flach …,
   aber kein `done/*/archiv.zip` setzt eine Untergrenze"), `git log` und `git status --porcelain`
   des Klons danach unverändert. Das Werkzeug steht und ist auf **keine** Welle dieses Repos
   anwendbar, solange der Altbestand nicht als eigener Vorgang archiviert ist — die Aussage hat
   einen Ort, [`harness/README.md`](../../../../harness/README.md).
2. **`make gates` grün** nach dem Commit dieser Notiz; der Stop-Hook-Stempel deckt den
   Arbeitsbaum.

- **Was hat funktioniert:** Der Schnitt lieh sich seine Form: Kopf-Aufbau, Zwei-Commit-Disziplin
  und die Wortgrenzen-Regel kommen aus `harness/tools/slice-mv.sh`, statt neu entworfen zu werden.
  Beide Review-Runden maßen an eigenen Scratch-Repos — alle drei HIGH der Runde 1 waren rot
  gesehen, nicht abgeleitet, und jede Behebung trägt einen bats-Fall, der gegen den alten Stand
  rot ist.
- **Was ging anders als geplant:** Der Plan rechnete mit dem Werkzeug, nicht mit seinem Kopf. Von
  elf Findings der Runde 1 lagen drei in derselben Klasse — die Zusage im Skriptkopf ging weiter
  als der Code darunter —, die Verifikation fand die vierte, und die Behebung brachte die
  Zähler-Label-Klasse an neuer Stelle zurück.
- **Steering-Loop-Eintrag: eine benannte Lücke** — *`make comment-claims` prüft, dass ein
  Kommentar seinen Sensor nennt und dass der genannte Test existiert; dass der genannte Sensor den
  zugesagten Fall **deckt**, prüft nichts.* Der Ernstfall steht in Grenze 3 des Skriptkopfs: sie
  nennt `make docs-check` als Auffang für eine Verweis-Form, die dessen Module nicht sehen
  (Sonde und Bestands-Zahl in der Registerzeile). Kein Zielort — die Lücke ist **benannt**, nicht
  verkörpert, und liegt als `BEO-025` im [Register](../observations.md).
- **Beobachtungs-Register (`../observations.md`):** zwei neue Kennungen, je 1×, Beleg `slice-170`
  — `BEO-025` (Zusage weiter als Code oder genannter Sensor) und `BEO-026` (Zähler-Label nennt
  eine andere Einheit als der Zähler zählt). `BEO-003` ist in §1 und §6 zitiert und **nicht**
  erhöht: der Risiko-Ausgang dort ist *entfallen*, also kein neues Auftreten.
- **Folge-Slices:** [slice-172](../done/slice-172-adr-archivierung-als-unterkommando.md),
  [slice-173](../open/slice-173-archive-welle-als-unterkommando.md) und
  [slice-174](../open/slice-174-archivierung-emittieren.md) — alle drei Dateien in `open/`. Sie
  sind nicht aus diesem Lauf geschnitten, sondern liegen vor ihm; sie wechseln den Träger vom
  Shell-Helfer zum Unterkommando des Produkt-Binärs.
- **Risiken aus §6:** zwei benannt, beide **entfallen** — siehe §6.
- **Zwei offene LOW der Runde 2 sind nicht behoben:** `titel_von` lässt bei der H1-Form
  `# Slice <NNN>: T` die Nummer im Titel stehen, `unsauber_grund` zählt Porcelain-Zeilen und nennt
  sie „Datei(en)". Ein Planner-Lauf ändert den Code nicht — dieselbe Trennung, aus der die drei
  Haken in §2 überhaupt hier landen. Beide bleiben latent, solange Ausgang 3 jeden Lauf über
  diesem Repo sperrt (Kriterium 1); die Klasse liegt als `BEO-025`/`BEO-026` im Register, der
  Einzelfall als Risiko in §6 von
  [slice-173](../open/slice-173-archive-welle-als-unterkommando.md).
- **Drei Paarungen** (dieser Slice ist wellenlos, also hier geprüft — **nach** dem `git mv`):
  (a) **Anker** — kein Eintrag trägt das Feld `liegt in`, also kein Gegenstand; (b)
  **Folge-Slice** — slice-172, slice-173 und slice-174 sind Dateien im Planning-Lifecycle
  (`ls docs/plan/planning/*/slice-17[234]-*.md` → je `open/`); (c) **Register** — die drei hier
  zitierten Kennungen haben je eine Zeile, und jede Zeile des Registers trägt mindestens einen
  Beleg (`awk -F'|' 'NR>1 && /^\| BEO-/ {if ($6 !~ /slice-/) print $2}' docs/plan/planning/observations.md`
  → leer).

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
