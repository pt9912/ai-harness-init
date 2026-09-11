# Slice slice-124: Die Gate-Tabellen werden gegen das Makefile gehalten — von einem Modul, das seit Monaten mitläuft und nichts prüft

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) — Achse (1) des Roadmap-Kandidaten
*Regeln ohne Feedback-Quadrant schließen*. Hermetisch, hängt an keinem anderen Slice der Welle.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind die Gate-Tabellen **dieses** Repos. Die
emittierte Starter-Config bleibt `modules: [links, anchors]`
([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed));
ob ein Ziel-Repo `targets` bekommt, entscheidet
[slice-073](../done/slice-073-emittierte-doc-gate-module.md) — dort ist die Frage gestellt, und sie ist
dort eine andere, weil ein frisch gebootstrapptes Ziel andere Utility-Targets hat als wir.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Regel, die hier einen Sensor bekommt — *„jeder genannte Gate muss auf frischem Checkout laufen"* —
**und** zugleich die Gegenkraft: ein Modul über leerem Prüfbereich ist selbst der Verstoß),
[`AGENTS.md`](../../../../AGENTS.md) §3.1 (dieselbe Regel als Hard Rule; §4 trägt die Tabelle, die
geprüft wird),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-*Anheben* → Steering-Loop, kein ADR — die Auflage, unter der dieser Slice steht),
[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
(*„Kein Rückfall auf stilles Grün: jede Ventil-Zeile nennt, was sie ausnimmt und warum"* — der
Maßstab für die 19 Ausnahmen, die dieser Slice setzen muss),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
(Setzung 2 zieht heute die Grenze *behauptet* gegen *advisory*; dieser Slice macht aus einem
advisory-Ziel einen behaupteten Gate und muss die Aufzählung nachziehen),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-08-28.

---

## 1. Ziel

**Ein Gate, das in [`AGENTS.md`](../../../../AGENTS.md) §4 oder
[`harness/README.md`](../../../../harness/README.md) steht und im
[`Makefile`](../../../../Makefile) fehlt, färbt `make gates` rot — und umgekehrt fällt ein
undokumentiertes Target auf, statt still zu bleiben.**

### Der Anlass: die Regel hat keinen Träger, und das Werkzeug dafür liegt seit Monaten im Image

[`AGENTS.md`](../../../../AGENTS.md) §3.1 verlangt, dass jeder genannte Gate auf frischem Checkout
läuft. Geprüft wird das von nichts: [`.d-check.yml`](../../../../.d-check.yml) führt sieben Module
(`grep -m1 '^modules:' .d-check.yml`), und keines vergleicht Doku gegen Build-Targets. Das Modul
`targets` (`DC-FA-TGT-001`) tut genau das und ist als `doc-targets` in
[`d-check.mk`](../../../../d-check.mk) erzeugt — verdrahtet ist es nirgends
(`grep -rn 'doc-targets' Makefile .github/workflows/*.yml` → kein Treffer, Exit 1).

### Und `make doc-targets` ist heute ein stilles Grün — gemessen, nicht vermutet

Gegen eine Kopie außerhalb des Repos (Stand `1f5741f`, netzlos, `:ro`, Image `v0.65.0` per Digest),
mit einer erfundenen Gate-Zeile ``| `make phantom-gate` | … |`` an
[`AGENTS.md`](../../../../AGENTS.md) angehängt:

| Lauf | Config | Ergebnis |
|---|---|---|
| Flags aus `doc-targets`, Baum **mit** Phantom-Gate | **ohne** `targets:`-Block (heutiger Stand) | `425 Datei(en) geprüft, 0 Befund(e)`, **Exit 0** |
| dieselben Flags, derselbe Baum | **mit** `targets:`-Block | Befunde, Exit 1 |

**Das Ziel läuft, meldet grün und prüft nichts.** Ohne Config-Block ist das Modul inert — die
`targets:`-Sektion ist in `--print-config` auskommentiert und hat keinen Default, der auf dieses
Repo zeigt. `make doc-targets` ist damit heute keine *„verfügbare, nur nicht behauptete"*
Fähigkeit, sondern eine Zusicherung ohne Gegenstand.

### Die Adoptions-Schuld, und sie ist die eigentliche Arbeit

Derselbe Lauf mit `targets:`-Block über den **unveränderten** Baum
(`makefiles: [Makefile]`, `doc-tables: [AGENTS.md, harness/README.md]`, `authority: AGENTS.md`):
**21 Befunde** — **19** × `gate-undocumented`, **2** × `gate-phantom`.

- Die **19** sind Targets im [`Makefile`](../../../../Makefile), die
  [`AGENTS.md`](../../../../AGENTS.md) nicht führt: `help`, `test-bats`, `test-go`, `artifact`,
  `release-artifacts`, `compile`, `smoke`, `full-smoke`, `mutate`, `regelwerk-check`,
  `baseline-freshness`, die vier `freshness-*`, `span-clean`, `span-report`, `hook-overhead`,
  `record-gates`. **Die meisten davon sind zu Recht nicht dort** —
  [`AGENTS.md`](../../../../AGENTS.md) §4 führt die Gates, und `harness/README.md` beschreibt
  ausdrücklich die, die **außerhalb** von `make gates` stehen. Sie brauchen also `exempt-targets`,
  und zwar kuratiert: jede Zeile nennt, was sie ausnimmt und warum
  ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)).
  Eine pauschale Liste wäre die Suppression, deren Grund als Nächstes veraltet.
- Die **2** `gate-phantom` (`AGENTS.md:258` und `harness/README.md:43`, beide auf `docs-check`) sind
  **kein Doku-Defekt, sondern ein Config-Defekt meiner Probe**: `docs-check` lebt in
  [`d-check.mk`](../../../../d-check.mk), nicht im [`Makefile`](../../../../Makefile). Die richtige
  Antwort ist `makefiles: [Makefile, d-check.mk]` — und dass die Probe das falsch hatte, ist der
  beste vorhandene Beleg, dass der Config-Block eine **Entscheidung** ist und keine Formsache.

### Der Prüfbereich ist die **Tabellenzeile**, und das gilt in beide Richtungen

Der Modul-Vertrag grenzt seinen Gegenstand enger ab, als sein Name nahelegt: geprüft wird *„jedes
in einer Doku-**Tabellenzeile** behauptete `make X`"*, und *„Tabellenzeilen zählen nur außerhalb
von Code-Blöcken"*. Was das für dieses Repo heißt, ist gemessen — Kopie außerhalb des Repos,
netzlos, Mount `:ro`, Image `v0.65.0` per Digest, Stand `fccc627`
(`git archive HEAD | tar -x -C <kopie>`), Config `makefiles: [Makefile, d-check.mk]`,
`doc-tables: [AGENTS.md, harness/README.md]`, `authority: AGENTS.md`, je Lauf
`docker run --rm --network none -v <kopie>:/repo:ro ghcr.io/pt9912/d-check@<digest> --config <profil> --enable targets`:

| An [`harness/README.md`](../../../../harness/README.md) angehängt | `gate-phantom`? |
|---|---|
| ein Prosa-Satz mit `` `make phantom-prosa` `` | **nein** — 30 Befunde, unverändert |
| eine Aufzählungs-Zeile mit `` `make phantom-liste` `` | **nein** — 30 Befunde, unverändert |
| eine **Tabellenzeile** mit `` `make phantom-tabelle` `` | **ja** — 31 Befunde, gemeldet auf der angehängten Zeile |
| dieselbe Tabellenzeile in einem Code-Block | **nein** — 30 Befunde, unverändert |

**Und die Autoritäts-Richtung liest denselben Ausschnitt.** Mit
`authority: harness/README.md` — der Datei, in der die Nicht-Gate-Verifies **stehen** — melden
`smoke`, `full-smoke`, `mutate`, `span-clean`, `span-report` und `hook-overhead` weiterhin
`gate-undocumented`. Ihre Beschreibung dort ist Prosa; für das Modul sind sie undokumentiert.
Genau **diese sechs** sind die Ziele, die
`grep -oE 'make [a-z][a-z0-9-]*' harness/README.md | sort -u` (**17** genannte) und
`grep -E '^\| \`make ' harness/README.md | grep -oE 'make [a-z][a-z0-9-]*' | sort -u` (**11** in
Tabellenzeilen) unterscheidet.

**Das ist die eigentliche Entscheidung dieses Slice, und sie ist unangenehm.**
[`AGENTS.md`](../../../../AGENTS.md) §4 verweist für *„was jedes Ziel prüft und was es nicht
prüft"* ausdrücklich auf [`harness/README.md`](../../../../harness/README.md), und dort steht die
Antwort für die Nicht-Gate-Verifies in Prosa. Die sechs in `exempt-targets` zu legen hieße, sie als
*„ohne Doku-Pflicht"* zu führen, obwohl sie dokumentiert sind — eine Ausnahme, die das Gegenteil
dessen behauptet, was der Fall ist. Sie in Tabellenzeilen zu heben, macht sie in **beiden**
Richtungen sichtbar, kostet aber eine Umformung der Doku, die niemand wegen des Sensors verlangt
hat.

**Drei Randbedingungen, die die Wahl einschränken — jede gemessen, keine geraten:**

- `authority` ist **eine** Datei, keine Liste: `authority: [AGENTS.md, harness/README.md]` bricht
  mit `cannot unmarshal !!seq into string`. Die Vollständigkeits-Quelle ist also **ein** Dokument;
  jedes weitere `doc-tables`-Dokument prüft nur die Phantom-Richtung.
- `exempt-targets` ist **exakt, kein Glob**: `exempt-targets: ["freshness-*"]` ändert die Befundzahl
  nicht (30 vor wie nach). Die vier `freshness-*`-Ziele stehen einzeln in der Liste oder gar nicht.
- Die Zahl der Ausnahmen ist **größer** als die Probe von `1f5741f` sagt. Mit der oben als richtig
  benannten Quelle `makefiles: [Makefile, d-check.mk]` meldet der unveränderte Baum **30**
  `gate-undocumented` und **0** `gate-phantom` — die zwei Phantome sind weg, dafür kommen die
  **elf** `doc-*`-Ziele aus [`d-check.mk`](../../../../d-check.mk) dazu
  (`grep -c '^doc-' d-check.mk` → **11**). Die Korrektur der einen Config-Zeile verschiebt die
  Arbeit von 19 auf 30 Entscheidungen.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3).

- [x] **(1) `targets` ist in [`.d-check.yml`](../../../../.d-check.yml) aktiviert und läuft in
      `make gates`.** Aufnahme in `modules:` — nicht als zweites Ziel daneben, sonst entsteht ein
      Gate-Name, den [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
      erst wieder einlösen müsste.
      **Rot:** eine erfundene Zeile ``| `make phantom-gate` | … |`` in
      [`AGENTS.md`](../../../../AGENTS.md) → `make docs-check` fällt und nennt Datei, Zeile und
      `gate-phantom`. Der Lauf **ohne** die Zeile bleibt grün. Beide gehören in den
      Umsetzungs-Commit.
- [x] **(2) Jeder Befund des gewählten Config-Blocks ist aufgelöst — als Doku-Nachzug oder als
      begründete Ausnahme, keiner als stille Liste; und die sechs in Prosa dokumentierten Ziele
      sind ausdrücklich entschieden.** Für jede `exempt-targets`-Zeile steht neben ihr, **warum**
      das Target keine Doku-Pflicht hat; für `docs-check` ist die `makefiles`-Quelle korrigiert
      statt das Target ausgenommen. Die Befundzahl folgt aus dieser Korrektur und ist **kein**
      Erwartungswert: mit `makefiles: [Makefile]` waren es 21, mit
      `makefiles: [Makefile, d-check.mk]` sind es 30
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2).
      **Rot:** ein `exempt-targets`-Eintrag ohne Begründung; eine Liste, die statt der benannten
      Targets ein Muster führt (es wirkt ohnehin nicht — die Liste ist exakt, §1); **oder** eine
      Ausnahme für eines der sechs Ziele, die
      [`harness/README.md`](../../../../harness/README.md) in Prosa beschreibt, ohne dass daneben
      steht, dass sie dokumentiert **sind** und nur außerhalb des Prüfbereichs liegen. Alle drei
      machen den Gate über der Ausnahme-Menge blind, und
      genau davor steht
      [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
      §Kein Rückfall auf stilles Grün. Mechanisch rot wird der Punkt, wenn nach der Kuratierung ein
      **neues** undokumentiertes Target hinzukommt und `make docs-check` es **nicht** meldet.
- [x] **(3) Die Grenzziehung in
      [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
      Setzung 2 ist nachgezogen — als Übergabe, nicht als Eigenmacht.** Sie zählt heute `docs-check`
      als **einziges** behauptetes Ziel und die übrigen elf als advisory; nach diesem Slice stimmt
      das nicht mehr.
      **Kein Kommando färbt diesen Punkt rot**, und das ist der Befund, keine Vertagung: der
      Adaptions-Block ist Architect-Eigentum ([`AGENTS.md`](../../../../AGENTS.md) §3.8), und kein
      Modul des Doku-Gates liest den Wahrheitsgehalt einer MR-Aufzählung. Der Slice liefert die
      Messung; der Norm-Text entsteht im Architect-Lauf.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.d-check.yml`](../../../../.d-check.yml) | update | `targets` in `modules:` **und** der `targets:`-Block mit `makefiles`/`doc-tables`/`authority`/`exempt-targets` — der Kern des Slice |
| [`AGENTS.md`](../../../../AGENTS.md) §4 | update | Doku-Nachzug für die Targets, die dort **hingehören**; die Gate-Tabelle ist die `authority` und wird durch den Slice erstmals mechanisch gehalten. **§3 bleibt unberührt** (Hard Rules sind Architect-Eigentum, §3.8) |
| [`harness/README.md`](../../../../harness/README.md) | update | zweite `doc-tables`-Quelle; hier steht, was **außerhalb** von `make gates` läuft — genau die Unterscheidung, die `exempt-targets` mechanisch macht |
| `test/` | neu | der Fall, der die Zusage aus DoD (1) rot färbt, plus sein `test/mutations/`-Zahn |
| [`harness/conventions.md`](../../../../harness/conventions.md) | **nicht durch diesen Slice** | [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) (Modul-Liste) und [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 2 (Grenzziehung) sind nachzuziehen — **Übergabe** an den Architect, DoD (3) |
| [`internal/emit/`](../../../../internal/emit) | **unverändert** | Ebene Dogfood (Kopfzeile); die emittierte Modul-Liste entscheidet [slice-073](../done/slice-073-emittierte-doc-gate-module.md) |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md)
ist gestartet und das WIP-Limit ist frei.** Der Slice ist hermetisch und wartet auf keinen anderen —
insbesondere **nicht** auf [slice-123](../done/slice-123-ci-sieht-die-historie.md): `targets` liest keine
Historie und ist auf einem Klon der Tiefe 1 genauso scharf wie auf einem vollen.

**Rückführungen, vorab benannt:**

- `in-progress` → `next`: die Kuratierung der 19 zeigt, dass die Gate-Tabellen selbst uneinheitlich
  sind — dann ist die Doku-Bereinigung ein eigener Schnitt und die Modul-Aktivierung ein zweiter.
  Ein vierter DoD-Punkt wäre die falsche Antwort.
- `in-progress` → `open`: das Modul verlangt eine Ausnahme-Form, die dieses Repo nicht vertreten
  kann (z. B. nur Muster statt exakter Namen — `exempt-targets` ist laut `--print-config`
  ausdrücklich **exakt, kein Glob**, was hier hilft, aber bei den vier `freshness-*` eine
  Aufzählung erzwingt). Dann ist die Lage ein Carveout nach Modul 7, kein stiller Kompromiss.

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt mit gefahrenen Kommandos, `make gates` grün (**mit** `targets` in der
Modul-Liste), `make mutate` ohne Befund, Review nach Modul 10 und Verifikation nach Modul 11 ohne
blockierenden Befund, Closure-Notiz in §7 mit Steering-Loop-Eintrag und der ausgewiesenen Übergabe
aus DoD (3).

## 6. Risiken und offene Punkte

Jedes Risiko trägt bei Closure genau einen der drei Ausgänge (Modul 5 §Offene Risiken werden bei
Closure aufgelöst): *eingetreten* → Carveout oder Folge-Slice mit Kennung · *entfallen* →
gestrichen mit Begründung · *weiter offen* → Beobachtungs-Register.

- **Die 19 Ausnahmen sind die Stelle, an der dieser Slice scheitern kann.** Ein Gate, dessen
  Ausnahme-Liste die Hälfte des [`Makefile`](../../../../Makefile) umfasst, prüft die andere Hälfte
  — das ist zulässig, aber es ist **nicht**, was die Zusage sagt. Die Meldung und
  [`harness/README.md`](../../../../harness/README.md) müssen den Ausschnitt benennen, so wie
  `make comment-claims` seine „N Datei(en) geprueft"-Zeile führt.

  **Ausgang: entfallen.** Die Bedingung trat ein — die Liste deckt mehr als die Hälfte —, die
  Benennung auch. Gemessen, ohne Erwartungswerte
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2):

  ```sh
  sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml | grep -c '^    - '                 # 36 ausgenommen
  grep -h '^\.PHONY:' Makefile d-check.mk | sed -E 's/^\.PHONY:[[:space:]]*//' \
    | tr ' ' '\n' | grep -v '^$' | sort -u | wc -l                                       # 47 Rezepte
  grep -E '^\|.*`make [a-z][a-z0-9-]*`.*\|$' AGENTS.md \
    | grep -oE '`make [a-z][a-z0-9-]*`' | tr -d '`' | sed 's/^make //' | sort -u | wc -l  # 11 in der Autoritäts-Tabelle
  ```

  36 und 11 ergeben 47: Der Prüfbereich ist lückenlos in zwei Teile zerlegt, und beide Teile stehen
  namentlich in [`harness/README.md`](../../../../harness/README.md) — die Zahl neben dem Kommando,
  das sie liefert, beide Ausnahme-Gruppen mit ihrem Grund und alle 36 Namen.
  **Die zweite Hälfte der Forderung ist nicht eingelöst und das bleibt benannt statt zugesagt:** Die
  *Meldung* stammt aus dem vendored d-check und nennt nur Datei- und Befundzahl; anders als bei
  `make comment-claims`, dessen Zeile ein repo-eigenes Skript druckt, ist sie hier nicht
  erreichbar. Den Ausschnitt trägt allein [`harness/README.md`](../../../../harness/README.md).
- **`authority: AGENTS.md` macht eine Datei zur Vollständigkeits-Quelle, die zwei Rollen gehört.**
  §3 schreibt der Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8), §4 wächst mit den
  Artefakten. Dieser Slice fasst nur §4 an — und das ist eine Grenze, die niemand mechanisch prüft
  (kein Modul des Doku-Gates liest Commits oder Abschnitts-Eigentum). Sie hängt am Rollen-Wechsel,
  nicht an einem Sensor.

  **Ausgang: entfallen.** Der Slice fasst auch §4 nicht an — die Datei ist über die ganze
  Umsetzungs-Kette unverändert (`git diff 6f454e15^..94635d8d --stat -- AGENTS.md` → leer). Die
  Grenze, um die es geht, ist als Regel bereits verkörpert
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8), und ihr Register-Eintrag
  [`fremdes-rollen-artefakt-im-implementations-kontext`](../observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md)
  trägt den Stand `verkörpert`. Ein Träger fehlt der Grenze also nicht; was fehlte, wäre ein Sensor,
  und dass es keinen gibt, sagt jene Hard Rule selbst.
- **Ein zweiter, stiller Prüfbereich entsteht mit `doc-tables` — und er ist nicht wählbar, sondern
  erzwungen.** `authority` nimmt genau **eine** Datei (§1: die Listenform bricht mit Exit 2). Die
  zweite `doc-tables`-Datei wird damit in **eine** Richtung geprüft (Phantom), nicht in beide. Was
  das bedeutet, gehört aufgeschrieben, sonst liest die nächste Runde „die Tabellen sind bewacht"
  und meint beide.

  **Ausgang: entfallen.** Die Asymmetrie steht in
  [`harness/README.md`](../../../../harness/README.md) ausgeschrieben: *Vollständigkeit* prüft gegen
  genau eine `authority`-Datei, weil das Schema des Moduls keine Liste zulässt, *Phantom* prüft
  beide `doc-tables`-Dateien in die Gegenrichtung. Damit ist die Richtung je Datei benannt, und die
  Formulierung „die Tabellen sind bewacht" hat dort keinen Ort mehr.
- **Die größere Blindstelle ist die Prosa, und sie bleibt nach diesem Slice bestehen.** Ein
  halluziniertes Ziel in einem Fließtext-Satz oder in einer Aufzählung ist für das Modul unsichtbar
  (§1, vier Sonden). Der Slice kann sie nicht schließen — er kann sie nur **benennen**, so wie
  `make comment-claims` seine „N Datei(en) geprueft"-Zeile führt. Eine Formulierung wie „die
  Gate-Nennungen sind bewacht" wäre nach diesem Slice falsch; richtig ist „die Gate-Nennungen **in
  Tabellenzeilen** sind bewacht". Ohne diesen Zusatz schließt der Slice die halluzinierten Gates in
  der Tabelle und lässt sie in der Prosa offen — dieselbe Klasse, gegen die er antritt
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

  **Ausgang: entfallen.** Die Einschränkung, die das Risiko verlangt, steht im selben Absatz wie die
  Zusage: *„Beide Richtungen greifen nur an **Tabellenzeilen** — eine Erwähnung in Fließtext,
  Aufzählung oder Code-Block bleibt für das Modul unsichtbar"*, samt dem Satz, dass ein
  halluziniertes Ziel in Prosa außerhalb dieses Prüfbereichs bleibt. Die Blindstelle besteht fort;
  sie ist damit deklariert statt zugesagt, und genau das war die Bedingung.
- **Der Befund `gate-phantom` auf `docs-check` ist ein Warnschuss für die ganze Welle.** Er kam aus
  einer Config, die eine plausible Annahme traf (`makefiles: [Makefile]`) und damit an einem
  **richtigen** Doku-Eintrag rot wurde. Eine Adoption, die solche Befunde durch Ausnahmen statt
  durch Config-Korrektur beseitigt, baut sich ein stilles Grün ein — dieselbe Klasse, die der Slice
  schließen soll.

  **Ausgang: entfallen.** Der Befund ist durch die Config-Korrektur verschwunden, nicht durch eine
  Ausnahme: `makefiles` führt beide Rezept-Dateien, und `docs-check` steht in keiner Ausnahme-Zeile
  (`sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml | grep -c '^    - docs-check$'` → **0**).
  Keiner der 36 Namen ist zugleich eine Tabellenzeile der Autoritäts-Datei — die zwei bats-Fälle in
  `test/targets-modul-wiring.bats` halten beide Richtungen dieser Trennung laufend, nicht nur zum
  Zeitpunkt der Kuratierung.

## 7. Closure-Notiz (nach `done/`)

**Rolle:** Planner (frischer Kontext, [`AGENTS.md`](../../../../AGENTS.md) §3.10) · **Datum:** 2026-09-11

### Geliefert

Das Modul `targets` steht in der Modul-Liste der [`.d-check.yml`](../../../../.d-check.yml) und
läuft damit in jedem `make docs-check` und `make gates` — kein zweites Gate-Ziel daneben, das
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) erst
wieder einlösen müsste. Der Config-Block trennt den Prüfbereich lückenlos in 36 kuratierte
Ausnahmen und 11 Zeilen der Autoritäts-Tabelle, und `test/targets-modul-wiring.bats` hält beide
Richtungen dieser Trennung laufend statt nur zum Zeitpunkt der Kuratierung.

### Was funktionierte

**Die Probe, die sich selbst widerlegte, war der wertvollste Beleg des Slice.** Die zwei
`gate-phantom`-Befunde auf `docs-check` kamen aus einer plausiblen Annahme (`makefiles: [Makefile]`)
und zeigten an einem *richtigen* Doku-Eintrag rot. Die Antwort war die Config-Korrektur, nicht die
Ausnahme — und sie verschob die Arbeit von 19 auf 30 Entscheidungen, bevor irgendetwas geschrieben
war. Hätte der Slice statt dessen zwei Ausnahmen gesetzt, wäre der Gate grün gewesen und hätte elf
Rezepte aus [`d-check.mk`](../../../../d-check.mk) nie gesehen.

**Das stille Grün ist unabhängig reproduziert worden**, am Elternstand vor dem ersten
Umsetzungs-Commit: dieselben Flags, die das advisory-Ziel fährt, gegen einen Baum ohne
`targets:`-Block — `1098 Datei(en) geprüft, 0 Befund(e)`, Exit 0. Ein Ziel, das läuft, grün meldet
und nichts prüft, ist keine *verfügbare, nur nicht behauptete* Fähigkeit.

### Was anders lief

**Die Ausnahme-Begründung hat drei Anläufe gebraucht, und die dritte Fassung entstand durch
Streichen.** Zwei frühere Formulierungen behaupteten je ein Konjunkt, das ein Teil der 16 Namen
nicht trug; erst die Fassung, die gegen den **vollständigen** Bestand der Gruppe falsifizierbar ist,
hält. Das ist [`AGENTS.md`](../../../../AGENTS.md) §3.6 in der Ausnahme-Liste statt im Test: Eine
Begründung, die nur für die Mehrheit ihrer Zeilen gilt, ist ein stilles Grün über dem Rest.

**Zwei Mutations-Fälle sind stumpf geworden, ohne dass an ihnen etwas falsch war.** Die Aufnahme von
`targets` in die `modules:`-Zeile verschob den Wortlaut, auf den `test/mutations/269` und
`test/mutations/279` mit dem vollen Listen-Literal ankerten; beide Patches wurden zu No-Ops. Hier
fiel es im Review als Vorhersage auf, vor dem Lauf, der es gemeldet hätte.

### Steering-Loop-Einträge

1. **Neuer Sensor — geliefert.** Die Gate-Tabellen dieses Repos werden gegen die Rezepte gehalten.
   Beide Grund-Codes sind rot gesehen: eine erfundene Tabellenzeile in
   [`AGENTS.md`](../../../../AGENTS.md) färbt `gate-phantom`, ein `.PHONY`-Rezept ohne Tabellenzeile
   färbt `gate-undocumented`, und der unveränderte Baum bleibt grün.
2. **Benannte Spec-Lücke.**
   [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
   verlangt, dass *jeder* genannte Gate läuft. Bewacht ist nach diesem Slice die **Tabellenzeile**;
   ein halluziniertes Ziel in Fließtext, Aufzählung oder Code-Block bleibt unsichtbar. Die Lücke
   steht in [`harness/README.md`](../../../../harness/README.md) deklariert — die Zusage lautet dort
   *„die Gate-Nennungen in Tabellenzeilen sind bewacht"*, nicht *„die Gate-Nennungen sind bewacht"*.
3. **Geschärfte Regel, noch unter der Schwelle.** Ein `sed`-Anker in `test/mutations/` zitiert das
   **Token**, nicht die volle Zeile. Die drei in diesem Slice angefassten Fälle tragen die Form, und
   `test/mutations/301` nennt sie in seinem eigenen Kopf. Repo-weit gilt sie nicht: Sie ist als
   Beobachtung gebucht und wartet auf ihren dritten Beleg.

### Beobachtungs-Register

- **Neu angelegt:**
  [`mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md)
  — zwei Belege, Stand `offen`. Der eine ist dieser Slice (zwei Fälle in einem Vorgang zählen
  einmal), der andere der Vorgang, dessen Closure die Form als Unterklasse benannte, die ihr
  damaliger Ausgang nicht erreicht. Zwei Nachbarklassen decken sie nicht: die eine bricht an der
  `# files:`-Zeile, die andere an der `# expect:`-Zeile, diese am `sed`-Muster dazwischen. Der
  Bestandsfall `test/mutations/278` trägt dieselbe Anker-Form und gehört zu keinem abgeschlossenen
  Vorgang — er steht dort als *benannt, nicht gezählt* und bewegt den Zähler nicht.
- **Beleg ergänzt:**
  [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  — `test/targets-modul-wiring.bats` ist ein neuer Wächter, den kein Fall in `test/mutations/` in
  seiner `# files:`-Zeile nennt. Der Eintrag stand vor diesem Slice bereits über der Schwelle; sein
  Ausgang gehört damit dem Lese-Schritt, nicht dieser Closure.
- **Kein Beleg für**
  [`ausnahmeliste-nur-auf-form-geprueft`](../observations/BEO-ALL/ausnahmeliste-nur-auf-form-geprueft/observation.md):
  Die Klasse beschreibt einen *unbegründeten* Eintrag, der unsichtbar bliebe. Hier trägt jede der 36
  Zeilen ihren Grund, und beide Hälften der Begründung sind gegen den vollständigen Bestand der
  Gruppe nachgemessen. Die Klasse bleibt wahr — geprüft wird die Bijektion, nicht die Berechtigung —,
  aber sie ist in diesem Vorgang nicht aufgetreten.

### Der Lese-Schritt, und warum er hier nicht liegt

Dieses Repo führt Wellen-Betrieb (`ls docs/plan/planning/welle-*.md | wc -l`, kein
Erwartungswert), und dieser Slice ist Mitglied von
[welle-13](../welle-13-regeln-bekommen-ihren-sensor.md). Der Lese-Schritt — welcher Eintrag **3×**
erreicht hat und welchen Ausgang er bekommt — gehört damit der Welle-Closure, und der
Herkunfts-Anker einer daraus verkörperten Regel lautet `seit welle-13`, nicht `seit slice-124`.
Die eine Ausnahme greift hier nicht: Kein Eintrag wird von **dieser** Closure über die Schwelle
gehoben. Der neu angelegte steht bei zwei, der ergänzte stand bereits bei drei.

**Der stehende Rückstand ist damit nicht aufgelöst und gehört benannt.** Einträge bei ≥ 3× mit
Stand `offen`:

```sh
for d in docs/plan/planning/observations/BEO-ALL/*/; do
  n=$(ls "$d/evidence"/*.md 2>/dev/null | wc -l); s=$(head -1 "$d/state.md")
  [ "$n" -ge 3 ] && [ "$s" = "**Stand:** offen" ] && echo "$(basename $d) $n"
done | sort -k2 -rn
```

**Kein Erwartungswert.** Einen davon berührt dieser Slice — den ergänzten oben; seine Zahl steigt,
sein Zustand nicht. Ihre Ausgänge sind fast durchweg Norm-Text und damit Architect-Arbeit im
Rahmen der Welle-Closure ([`AGENTS.md`](../../../../AGENTS.md) §3.8).

### Übergabe an den Architect

Der Adaptions-Block trägt keinen Ort, an dem steht, dass dieses Repo `planning` und `targets` im
Doc-Gate fährt. Die Übergabe hat einen Träger bekommen statt nur einen Satz in dieser Notiz:
[slice-212](../open/slice-212-modul-aktivierung-hat-keinen-adaptions-eintrag.md) in `open/`. Der
zuerst gemeldete Posten an
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
Setzung 2 ist entkräftet und wird **nicht** weitergereicht: Aktiviert wurde ein Modul *innerhalb*
von `docs-check`, kein zweites Gate-Ziel — `make doc-targets` bleibt advisory und steht in keiner
Prerequisite-Kette.

### Zwei Übergaben aus dem Review, je mit Ausgang

- **Die zwei gehärteten Extraktionen ohne eigenen Wächter** gehen ins Register (Beleg oben). Ein
  Rückbau bliebe heute unsichtbar, weil beide Fassungen über dem heutigen Baum dieselben Mengen
  liefern; das ist die Eigenschaft, die der Eintrag zählt, und kein Defekt dieses Slice.
- **Die Anker-Form in `test/mutations/278`** ist Bestand und wurde von diesem Diff nicht erzeugt.
  Sie steht im neuen Eintrag unter *benannt, nicht gezählt*. Ein eigener Schnitt dafür wäre heute
  verfrüht: Der Fall ist nicht gefallen, und die Klasse hat ihren dritten Beleg noch nicht.

### Verifikation

- **`make gates`** deckt den Abschlussstand des Slice: `.harness/state/gates-passed.diffsha` und
  `bash harness/tools/working-tree-hash.sh` liefern denselben Wert über dem sauberen Baum.
- **`make mutate`** ist über **288** Fällen vollständig grün gelaufen
  (`ls test/mutations/*.sh | wc -l`, kein Erwartungswert). Der Beleg ist nicht nur berichtet,
  sondern am Mechanismus nachgeprüft: `.harness/state/mutate-passed.key` entsteht ausschließlich
  bei `fail_count == 0` (`finalize_belief` in `harness/tools/mutate.sh`), und der gespeicherte
  Schlüssel ist reproduziert worden — er trifft den heutigen Baum **ohne** die Report-Datei des
  Verifiers, also genau den Stand, über dem der Lauf startete. Diese eine Datei liegt unter
  `docs/reviews/`, und kein Mutations-Fall nennt einen Pfad dort
  (`sed -n 's/^# files: //p' test/mutations/*.sh | tr ' ' '\n' | sort -u | grep -c 'docs/reviews'` →
  **0**). Der Prüfgegenstand des Laufs und der Abschlussstand unterscheiden sich damit um nichts,
  worüber der Sensor urteilt.
- **Review** nach Modul 10 in zwei abgelegten Runden, beide aufgelöst; **Verifikation** nach
  Modul 11 mit eigenständiger Nachmessung beider Grund-Codes und des stillen Grüns am Elternstand.
## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Die
Gate-Konfiguration ist konventionell dicht bis zur Vorschrift: [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
begründet jede aktive Modul-Zeile, und [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
setzt den Maßstab für jede Ausnahme.
