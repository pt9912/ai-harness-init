# Slice slice-075: Der Adaptions-Block zeigt auf das Regelwerk, von dem er abweicht

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle. Begründet gegen die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird):
(1) **Bündel?** Nein — eine Kennungs-Klasse, ihr Bestand und ihr Zahn landen zusammen oder gar
nicht. (2) **Gemeinsames Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift der DoD.
(3) **Reaktiv oder gewollt?** **Reaktiv:** Auslöser ist eine Messung am vorhandenen
Adaptions-Block, nicht der Wunsch nach einer Fähigkeit. Damit **nicht** in der Roadmap geführt
([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2) — der Zustand ist das Verzeichnis.

**Nicht welle-09.** Deren Closure-Kriterium ist die 4 × 2-Matrix über die vier Regelblöcke des
Observability-Moduls; die Verweisbarkeit auf ein Regelwerks-Modul ist keiner davon. Sie kommt aus
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Kennung → klickbarer Anker) und trifft alle Module gleich. Der Slice teilt mit welle-09 den
**Anlass-Ort**, nicht die Regel-Familie.

**Bezug:**
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(die Doc-Gate-Schärfung, die die Linkpflicht für Kennungen gesetzt hat, und die Linie
„Gate-*Anheben* → Steering-Loop"),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(die committet-vendored Baseline — sie macht den Link überhaupt netzlos auflösbar, und ihre Zusage
„eine Zeile + der Baum" ist die Kostenschranke dieses Slice),
[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
(§Tag im Referenzpfad — die schon getroffene Entscheidung gegen einen tag-stabilen Zeiger, auf der
dieser Slice aufbaut),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (minimale
Abhängigkeiten — das Argument, mit dem der Zeiger damals unterblieb),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (das Regelwerk geht
auch ins Ziel — die zweite Ebene, die hier entschieden und **nicht** mitgenommen wird),
[`AGENTS.md`](../../../../AGENTS.md) §3.4 (ADRs sind nach Accepted immutabel — die Grenze, an der
der Bestand endet), §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-08-01.

---

## 1. Ziel

**Der Doc-Gate soll rot werden, wenn der Adaptions-Block ein Regelwerks-Modul nennt, ohne auf es
zu zeigen.**

[`harness/conventions.md`](../../../../harness/conventions.md) ist das Register der Abweichungen
vom Regelwerk. Es nennt acht Module — und zeigt auf keines. Für das Werkzeug ist eine
Modul-Kennung Prosa: `.d-check.yml` führt in `ids.patterns` genau `ADR-`, `LH-` und `MR-`.

**Ist-Messung** (Arbeitsbaum-Stand 2026-08-01; jede Zahl mit ihrem Kommando, weil zwei Nennformen
existieren und ein Muster über nur eine davon zu eng ist):

| Größe | Kommando | Wert |
|---|---|---|
| Nennungen `Modul NN` (Leerzeichen) | `grep -oE 'Modul [0-9]{1,2}' harness/conventions.md \| wc -l` | 24 |
| Nennungen `Modul-NN` (Bindestrich) | `grep -oE 'Modul-[0-9]{1,2}' harness/conventions.md \| wc -l` | 4 |
| beide Formen zusammen — der Bestand dieses Slice | `grep -oE 'Modul[- ][0-9]{1,2}' harness/conventions.md \| wc -l` | **28** |
| davon auf ein Modul zeigend | `grep -cE '\]\([^)]*regelwerk/' harness/conventions.md` | **0** |
| verschiedene Module in den 28 | `grep -oE 'Modul[- ][0-9]{1,2}' harness/conventions.md \| sort -u \| wc -l` | 6 (2 · 5 · 6 · 7 · 8 · 15) |
| Links nach `spec/` | `grep -cE '\]\(\.\./spec/' harness/conventions.md` | 36 |
| Links nach `docs/plan/` | `grep -cE '\]\([^)]*docs/plan/' harness/conventions.md` | 23 |
| Links in ein Regelwerks-Modul, **repo-weit** | `git ls-files '*.md' \| xargs grep -lE '\]\([^)]*regelwerk/'` | **2 Dateien**, beide `docs/reviews/` |

**Die dritte Nennform ist gemessen und gehört nicht zum Bestand:** `modul-00`, `modul-13`,
`modul-16` (kleingeschrieben, Datei-/Bereichsform) stehen dreimal in Inline-Code und benennen den
Baum, nicht das Modul — ein Muster, das sie mitnimmt, wäre weiter als die Frage. Ebenso außen vor:
`Regelwerk-Modul` · `Rollen-Modul` · `Gate-Modul` (5 · 3 · 1 repo-weit, keine Kennung).

**Die Folge ist nicht kosmetisch: weil der Text nicht zeigen kann, muss er nacherzählen.** Der
Block *„Sechs erklärte Abweichungen vom Modul-15-Pflicht-Minimum"* trägt das Pflicht-Minimum in
eigenen Worten mit, damit er sagen kann, wovon er abweicht — **295 Zeilen** im letzten committeten
Stand, gemessen vom Bullet-Anfang bis zum nächsten Top-Level-Bullet. Vier seiner Nennungen führen
ein wörtliches Zitat aus dem Modul mit, ohne Stelle, an der es steht. Das Delta ist unprüfbar,
ohne das Modul selbst zu suchen.

**Der Link ist bewacht — gemessen, nicht angenommen.** Die Sorge war, `.d-check.yml` nehme
`.harness/baseline/**` aus (`scan.ignore`) und ein Link dorthin sei damit eine unbewachte
Behauptung. Gegenprobe über das gepinnte Image, vier Fälle in einer Sonde: eine **fehlende Datei**
im ausgenommenen Baum meldet `target-missing`, eine **fehlende Überschrift** dort meldet
`anchor-missing`, die existierenden Gegenstücke bleiben still. `scan.ignore` prunt, **was
gescannt wird**, nicht, **was aufgelöst wird** — Datei- **und** Anker-Achse tragen also in den
Baum hinein.

## 2. Definition of Done

- [ ] **(1) Eine Modul-Kennung ohne Link bricht `docs-check`, und der Bestand fällt im selben
  Schnitt.** `.d-check.yml` bekommt in `ids.patterns` die Klasse `Modul[- ]\d{1,2}` mit
  `link-policy: always` (Kennungen auch in Inline-Code, wie die drei bestehenden Klassen) und
  `target` auf das vendored Modul-Verzeichnis. Die **28** Stellen in
  [`harness/conventions.md`](../../../../harness/conventions.md) werden zu Links auf
  `.harness/baseline/<tag>/regelwerk/modul-NN-*.md`; wo der Text eine bestimmte Aussage des Moduls
  meint, auf deren **Überschrift** (die Anker-Achse trägt, s. §1). `make docs-check` grün.
  **Der Prüfbereich ist der Adaptions-Block und die repo-weiten Briefings** — dort behauptet der
  Text ein Delta gegen ein Modul und muss es zeigen können. Alles andere trägt die Kennung als
  Quellenangabe und steht mit **benanntem Auflösungs-Trigger** in DoD (3), nicht als stille
  Ausnahme.
- [ ] **(2) Der Zahn ist dauerhaft, und beide Richtungen sind zu zeigen.** Ein Fall in
  `test/mutations/` nimmt genau **einen** Link aus dem Adaptions-Block und muss `make docs-check`
  mit der Befund-Art `id-unlinked` rot färben. Die Gegenrichtung gehört in denselben Beleg
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6): dieselbe bare Nennung bleibt **ohne** die neue
  Klasse grün — sonst behauptet der Fall, der Gate habe die Verletzung gefunden, statt: **erst**
  die Klasse findet sie. Der Fall setzt den `failure_form`-Modus `docs-check` in
  `harness/tools/mutate.sh` voraus; er entsteht in
  [slice-072](slice-072-adr-verweist-nicht-auf-lifecycle.md) und wird hier **nicht** zweitgebaut
  (Trigger in §4).
- [ ] **(3) Was der Link kostet und was die Regel nicht fängt, steht im Adaptions-Block.** Ein
  Eintrag hält fest: der **Tag im Referenzpfad** (der tag-stabile Zeiger bleibt ungebaut, jetzt
  mit gemessener Begründung statt YAGNI — s. §6); die Bump-Rechnung; dass `ids` „ist verlinkt"
  prüft und **nicht** „zeigt auf das genannte Modul" (gemessen: ein Link auf ein fremdes Ziel
  passiert); dass Überschriften und Code-Fences außerhalb liegen, Tabellenzellen aber innerhalb
  (beides gemessen); und die **nicht** einbezogenen Pfad-Klassen je mit Auflösungs-Trigger.
- [ ] `make gates` grün; `make mutate` grün über die CI (`.github/workflows/ci.yml`, frischer
  Runner).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.d-check.yml` | update | die vierte `ids`-Klasse samt `exempt-paths` der nicht einbezogenen Pfad-Klassen |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | die 28 Stellen werden Links; dazu der Eintrag aus DoD (3) |
| `test/mutations/` | neu | der Zahn aus DoD (2) |
| [`harness/README.md`](../../../../harness/README.md) | update | die `docs-check`-Zeile nennt die geprüften Kennungs-Klassen — der Vertrag wächst hier, also wächst die Zeile mit |

**Der Prüfbereich, entschieden statt offengelassen.** Der Bestand hängt daran, wie weit die Klasse
greift; die Zahlen sind je Pfad-Klasse gemessen
(`git ls-files '*.md' | xargs grep -ohE 'Modul[- ][0-9]{1,2}' | wc -l` → **1997** repo-weit, je
Klasse aufgeschlüsselt):

| Pfad-Klasse | Nennungen | Verdikt | Grund |
|---|---|---|---|
| Adaptions-Block + Briefings (`harness/conventions.md`, [`AGENTS.md`](../../../../AGENTS.md), `CLAUDE.md`, [`harness/README.md`](../../../../harness/README.md)) | **28** (alle in `conventions.md`) | **einbezogen** | hier behauptet der Text ein Delta gegen ein Modul; drei der vier Dateien nennen heute keines und sind ab Tag eins gebunden |
| `.harness/baseline/**` | 252 | außerhalb | schon heute aus `scan.ignore`; vendored, wir schreiben es nicht |
| `docs/reviews/**` | 571 | ausgenommen | Zeitdokumente; **alle drei** bestehenden `ids`-Klassen nehmen sie aus — hier gilt kein anderer Grund |
| `docs/plan/planning/done/**` | 250 | ausgenommen | geschlossene Slices sind Audit-Material; ein Link nachzutragen schriebe Geschichte um |
| `docs/plan/planning/` (offen, `next/`, `in-progress/`, flach) | 97 | ausgenommen | Auflösungs-Trigger: die erste **gemessene** veraltete Modul-Nennung in einem lebenden Plan |
| `docs/plan/adr/**` | 21 | ausgenommen | **11 davon in drei Accepted-ADRs** ([`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md) · [`ADR-0010`](../../adr/0010-hexagonal-arch-realisierung.md) · [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md)) — nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 nicht nachträglich verlinkbar; die Regel wäre dort dauerhaft rot oder erzwänge einen Regelbruch |
| `.claude/commands/**`, `.claude/agents/**`, `.harness/skills/**` | 48 · 19 · 4 | ausgenommen | Auflösungs-Trigger derselbe wie bei den lebenden Plänen; sie zitieren Module als Quelle, sie erklären keine Abweichung |
| `internal/emit/templates/**` | 48 | ausgenommen | **gemessene Gefahr**, s. u. |

**Warum die Emissions-Vorlagen nicht bloß „später" sind.** Ein Link mit literalem Tag in einer
emittierten Datei zeigt im Zielrepo auf den Tag, den **wir** hatten — nicht auf den, den der
Adopter gebootstrappt hat. Das emittierte Repo bekommt das Regelwerk unter
`.harness/baseline/<seine-version>/regelwerk/`
([`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)), fährt `links` in
seinem eigenen Doc-Gate und meldete den Verweis dann als `target-missing` — die
Out-of-the-box-Grünheit aus
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) fiele. Das
ist dieselbe Klasse, die `test/mutations/37-commands-interner-leak.sh` heute schon bewacht: eine
repo-interne Referenz, die im Ziel tot ist.

**Was die Umsetzung zuerst nachmisst** (Modul 9 §4): die 28 Stellen und die Klassen-Tabelle neu
zählen, bevor die `exempt-paths` geschrieben werden — die Zahlen altern mit jedem Commit an einem
Plan oder Review. Insbesondere ist zu prüfen, ob zwischenzeitlich eine **vierte** Nennform
entstanden ist; das Muster ist gegen die Frage zu halten, nicht gegen den heutigen Bestand.

## 4. Trigger

**`open` → `next`:** [slice-072](slice-072-adr-verweist-nicht-auf-lifecycle.md) liegt in `done/`.
Das ist eine **echte Abhängigkeit**, keine Reihung nach Konfliktfläche: heute kann kein Fall in
`test/mutations/` einen `docs-check`-Wächter binden — `failure_form` in
`harness/tools/mutate.sh` kennt nur `test`/`test-go`/`test-bats`/`smoke`/`ci-lint`. Ohne den dort
entstehenden Modus `docs-check` wäre der Zahn aus DoD (2) nicht dauerhaft, und der Slice landete
mit einer Zusage ohne Sensor.

**`next` → `in-progress`:** WIP-Limit.

Rückführungen:

- `in-progress` → `next`: falls die Nachmessung zeigt, dass die 28 Stellen und der Eintrag aus
  DoD (3) zwei Arbeiten sind — dann trennt ein Re-Schnitt die Regel samt Zahn von der
  Bestands-Umschreibung. Die Naht liegt sichtbar dort, wo eine Stelle nicht nur einen Link,
  sondern eine **Umformulierung** braucht, weil sie das Modul nacherzählt statt es zu zitieren.
- `in-progress` → `open`: falls sich zeigt, dass der Prüfbereich aus §3 eine Pfad-Klasse trifft,
  die hier nicht gemessen ist — etwa eine vierte Nennform oder eine neue Briefing-Datei. Dann ist
  erst zu klären, was die Klasse umfasst, bevor die Regel scharf gestellt wird.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates` grün
und ein CI-Vollauf `make mutate` mit `0 Befund(e)`; `git mv` nach `done/` (eigener Move-Commit);
Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Tag im Referenzpfad ist der Preis, und der tag-stabile Zeiger scheidet gemessen aus.**
  `.harness/baseline/<tag>/regelwerk/…` trägt den Tag; vier Re-Baselines liegen in neun Tagen
  hinter uns.
  [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
  §Tag im Referenzpfad hat den Symlink schon einmal verworfen — damals mit YAGNI, weil nichts
  dauerhaft in den Baum zeigte. Dieser Slice hebt die Voraussetzung auf, also ist die Frage neu zu
  beantworten, und die Antwort ist jetzt **gemessen**: d-check meldet für **jeden** Link, dessen
  Pfad über einen Symlink läuft, die Befund-Art `symlink` — auch wenn Datei und Anker auflösen.
  Ein `current`-Zeiger machte damit aus 28 stillen Links 28 dauerhafte Befunde. Der Tag bleibt
  literal.
- **Die Bump-Rechnung, ehrlich gerechnet.**
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  verspricht „eine Zeile + der Baum"; der letzte Re-Vendor (`ce4b611`, v3.5.1 → v3.5.2) berührte
  außerhalb des Baums **sieben** Dateien und rund **14** tag-tragende Zeilen — die Zusage ist also
  schon heute eine Näherung. Mit diesem Slice werden daraus rund **42**. Das ist der eigentliche
  Grund für den engen Prüfbereich aus §3: über alle Pfad-Klassen wären es über 1000, und dann wäre
  die Zusage nicht mehr ungenau, sondern falsch. **Der Bump wird dafür prüfbar:** jeder übersehene
  Link ist nach dem Umzug ein `target-missing`, kein stiller Alt-Verweis — das ist die
  Gegenleistung für die 42 Zeilen und der Grund, warum die Kosten hier akzeptiert und nicht bloß
  hingenommen werden.
- **Die Regel prüft „ist verlinkt", nicht „zeigt aufs richtige Modul" — gemessen.** In der Sonde
  passiert eine Nennung `Modul 15`, die auf eine beliebige andere Datei verlinkt, den Gate
  unbeanstandet; `target` in `ids.patterns` bindet das Ziel nicht. Damit fängt die Regel das
  **Fehlen** des Zeigers, nicht seine **Richtigkeit**. Ein Sensor dafür müsste die Kennung gegen
  den Zielpfad halten; dieser Slice liefert ihn nicht, DoD (3) schreibt die Grenze hin.
- **Zwei Fundstellen-Arten liegen außerhalb der Klasse, und beides ist gemessen:** Überschriften
  und Code-Fences werden von `ids` nicht gegriffen, Tabellenzellen dagegen schon. Eine
  Modul-Nennung in einer Überschrift bleibt also unverlinkt und unbemerkt. Das ist im Bestand
  unschädlich (keine der 28 steht in einer Überschrift), aber es ist eine Fail-open-Kante und
  gehört benannt.
- **Der Prüfbereich ist eine Positivliste, geschrieben als Ausnahmeliste — das ist fail-open nach
  innen.** `ids.patterns[].exempt-paths` ist die einzige verfügbare Schraube: `ids.scope.roots`
  wirkt **modulweit** und würde die Linkpflicht für `ADR-`/`LH-`/`MR-` gleich mit umscopen, ist
  hier also unbrauchbar (aus `--print-config` gelesen). Folge: eine **neue Datei innerhalb** einer
  ausgenommenen Klasse ist ungebunden, eine neue Pfad-Klasse dagegen gebunden. Die Kante ist
  benannt, nicht geschlossen.
- **Abgrenzung zu [slice-072](slice-072-adr-verweist-nicht-auf-lifecycle.md) und
  [slice-073](slice-073-emittierte-doc-gate-module.md).** Alle drei fassen dieselbe Datei an, und
  das allein wäre ein schlechter Grund für drei Schnitte. Die Trennung ist inhaltlich: slice-072
  setzt eine **`matrix`**-Regel (Verweis **verboten**, Richtung ADR → Lifecycle) und baut den
  `docs-check`-Modus des Mutations-Treibers; dieser Slice setzt eine **`ids`**-Klasse (Verweis
  **gefordert**, Richtung Repo → Regelwerk) — anderes Modul, andere Richtung, anderer Bestand
  (27 gegen 28 Stellen, disjunkt). Eingefaltet werden könnte er nicht: slice-072 trägt bereits
  drei slice-eigene DoD-Punkte, und Modul 5 lässt keinen vierten zu. slice-073 entscheidet, welche
  Doc-Gate-**Module** ins Ziel gehen; die hier gesetzte Klasse ist ein `ids`-**Muster** innerhalb
  eines Moduls, das slice-073 ohnehin emittiert. Sie geht dort **nicht** mit — slice-073s eigenes
  Kriterium 1 („der Dogfood fährt es selbst") ist bis zum Abschluss dieses Slice nicht erfüllt.
  Dieser Slice schafft die Voraussetzung; die Ziel-Entscheidung bleibt bei slice-073.
- **Nicht in diesem Slice:** die Zerlegung von
  [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) —
  **839 Zeilen, 50 % der Datei, ohne eine einzige Unterüberschrift** (gemessen am letzten
  committeten Stand) — und die Kürzung der 295 Zeilen Nacherzählung darin. Beides folgt aus
  diesem Befund und ist eigene Arbeit: der Link muss stehen, **bevor** die Nacherzählung durch
  einen Zeiger ersetzt werden kann, sonst verliert der Leser die Aussage, statt sie zu gewinnen.
  Ebenfalls nicht hier: die emittierte Ebene (s. o.) und jede Erweiterung des Prüfbereichs auf
  Pläne, ADRs oder Briefings-Kopien — jede trägt ihren Auflösungs-Trigger in §3.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `.d-check.yml`, `harness/`
und `test/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
