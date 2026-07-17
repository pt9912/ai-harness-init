# Slice slice-015: Zitat-Sensor (`make cite-check`)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem die Datei liegt
(`open/` · `next/` · `in-progress/` · `done/`), Wechsel nur per `git mv` —
v3.1.0-Konvention (`modul-05`).

**Welle:** ohne Welle (Harness-Wartung). Einordnung *(Kontext, nicht normativ)*:
[roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-17.

---

## 1. Ziel

Ein repo-lokaler, netzloser Sensor `make cite-check`, der Zeilenreferenzen der Form
`<pfad>:<zeile>` bzw. `<pfad>:<von>-<bis>` gegen den in-tree Baum prüft: Zeigt eine
Referenz auf eine nicht existierende Datei oder über deren Ende hinaus, färbt das Gate
**rot**. Er schließt den **mechanisierbaren** Teil der Lücke, die der
[Review-Report vom 2026-07-17](../../../reviews/2026-07-17-slices-011-014-plan-review.md)
§Verdikt als Steering-Loop-Signal benennt: *behauptete statt gemessene Zahlen*, sechsmal
in einem Zug aufgetreten, von keinem Gate gefangen.

Fortsetzung der [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)-Philosophie: dort wurde „Kennungen verlinken zur
Quelle" von einer Konvention zu einem **gemessenen Property**. Hier dasselbe für Zitate
— aus „das Zitat stimmt" wird „das Zitat stimmt, sonst rot".

> **Dieser Slice ist bewusst blockiert.** Seine Prämisse ist am 2026-07-17 **widerlegt**
> worden (§6, erster Punkt). Der Trigger in §4 ist die *beobachtbare Bedingung*, unter
> der er wieder sinnvoll wird. Tritt sie nie ein, startet der Slice nie — das ist das
> gewünschte Verhalten, kein Versäumnis.

**Abgrenzung.** **Nicht** hier: Prosa-Quantoren („fast alle", „zwei von drei") und freie
Zahlen mit externer Grundwahrheit („42 Dateien im ZIP") — beides ist mechanisch nicht
entscheidbar und bleibt Review-Territorium. **Nicht** hier: die Provenienz-Pflicht für
Zahlen (Analogie zu `ids.link-policy: always`); eigener Slice mit eigenem
False-Positive-Risiko, der auf Betriebserfahrung *mit* diesem Sensor aufsetzen sollte,
statt darauf zu wetten. **Nicht** hier: der CR an d-check — anderes Repo, andere Uhr
(s. §6).

## 2. Definition of Done

- [ ] `harness/tools/cite-check.sh` <!-- d-check:ignore (geplante Datei — existiert erst nach Umsetzung dieses Slice; Doc führt, Code folgt) --> (bash+awk, **kein** node/jq/python —
      [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten); Docker-only gilt dem Build, nicht Gate-Skripten,
      [`ADR-0003`](../../adr/0003-go-native-binaries.md)) prüft je erkannter Referenz: Zieldatei existiert · `von ≤ bis` ·
      `bis ≤ Zeilenzahl`. Die erkannte Zitat-Syntax ist in `harness/README.md`
      dokumentiert — eine Referenz, die das Tool **nicht** erkennt, ist eine
      ungeprüfte Referenz und muss als solche benannt sein.
- [ ] `make cite-check` netzlos, Prerequisite von `gates`; **nicht-leerer Prüfbereich
      nachgewiesen** (Anzahl geprüfter Referenzen > 0, im Lauf ausgegeben) und beide
      Richtungen real vorgeführt: eine kaputte Referenz färbt rot, eine korrekte grün
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [ ] `test/cite-check.bats` deckt: existierende Referenz · fehlende Datei · Zeile über
      EOF · invertierter Bereich · nicht erkannte Syntax (kein stilles Durchwinken).
- [ ] `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/cite-check.sh` <!-- d-check:ignore (geplante Datei, s. DoD 1) --> | neu | Sensor (bash+awk, zero-dep) |
| `Makefile` | update | `cite-check` als `gates`-Prerequisite (netzlos) |
| `test/cite-check.bats` | neu | Negativ- und Positivpfad, inkl. „Syntax nicht erkannt" |
| `harness/README.md` (§Sensors) | update | Gate führen + erkannte Zitat-Syntax dokumentieren |
| `AGENTS.md` (§4) | update | Gate in der kanonischen Aufzählung |

## 4. Trigger

**Zwei Bedingungen, beide beobachtbar (Modul 6: Trigger ist eine Bedingung, kein Datum):**

1. **slice-011 liegt in `done/`.** Vorher zeigen Regelwerks-Zitate auf einen
   gitignorierten Cache, der auf einem frischen Checkout gar nicht existiert — der
   Sensor wäre dort nicht netzlos-grün zu bekommen.
2. **Dauerhafte Dokumente führen überhaupt Zeilenreferenzen:**
   ```
   grep -rhoE '[A-Za-z0-9._/-]+\.(md|yml|sh|awk):[0-9]+(-[0-9]+)?' \
     AGENTS.md CLAUDE.md harness/ spec/ docs/plan/adr/ | wc -l
   ```
   → **> 0**. Am 2026-07-17 ist das Ergebnis **0** (s. §6). Solange es 0 bleibt, hätte
   der Sensor nichts zu prüfen und wäre selbst ein stilles Grün.

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Prämisse widerlegt (gemessen 2026-07-17) — der Hauptgrund, warum dieser Slice in
  `open/` liegt und nicht in `next/`.** Der Sensor wurde mit dem Argument
  vorgeschlagen, die vendored Baseline erzeuge einen Korpus von Zeilenzitaten auf einen
  Fremdbaum, der bei jedem Tag-Bump still verrottet. Nachgemessen trägt dieses Repo
  **null** Zeilenreferenzen in `AGENTS.md`, `CLAUDE.md`, `harness/`, `spec/` und
  `docs/plan/adr/`. Sämtliche Referenzen liegen in `docs/plan/planning/` und
  `docs/reviews/` — **Zeitdokumente**, die den Stand ihres Entstehens festhalten
  *sollen* und deshalb einzufrieren, nicht mitzuwandern sind (dieselbe Logik, aus der
  `.d-check.yml` schon heute `docs/reviews/**` von der `ids`-Pflicht ausnimmt, und aus
  der `done/` Archiv bleibt). Ein Gate über einem leeren oder ausschließlich exempten
  Prüfbereich meldet grün, ohne etwas zu prüfen — nach der Definition dieses Repos
  ein **halluziniertes Gate** ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Der Sensor gegen die Lücke wäre
  dann selbst ein Fall der Lücke.
- **Herkunft der Fehleinschätzung — als Beleg aufbewahrt, nicht als Fußnote.** Das
  Rot-Verrotten-Argument wurde am 2026-07-17 als „das stärkste Argument" für den
  d-check-CR bezeichnet, **bevor** der Korpus gezählt wurde. Es war ein plausibler
  Mechanismus ohne Messung — dieselbe Klasse, die der Review-Report als
  Steering-Loop-Signal führt, zum dritten Mal in derselben Sitzung, diesmal im
  *Vorschlag für den Sensor gegen diese Klasse*. Das entkräftet den Befund nicht, es
  schärft ihn: Die Klasse überlebt jede Menge Sorgfalt. Sie braucht einen Sensor —
  aber offenbar einen anderen als diesen, denn dieser hätte sie hier nicht gefangen.
- **Was der Sensor auch bei erfüllter Prämisse NICHT fängt.** Von den sechs belegten
  Fehlern des 2026-07-17-Zuges fängt er **zwei** (die Off-by-one-Zeilenbereiche) — und
  auch die nur mit Stufe „verbatim" (Zitattext gegen die Spanne), nicht mit
  Existenz-/Bereichsprüfung allein: `modul-02:173-176` zeigt auf eine existierende
  Zeile 176, nur eben auf die falsche. Gehört vor dem Bau entschieden: reicht
  Existenz + Bereich (billig, keine Konvention nötig, fängt Fäule), oder braucht es
  ausgezeichnete Zitatblöcke (`<!-- cite: pfad:von-bis -->` + Blockquote, fängt
  zusätzlich Off-by-one, verlangt aber Markup-Disziplin)?
- **Verhältnis zum d-check-CR.** d-check ist ein eigenes Repo mit eigener Release-Uhr;
  der Pin hier steht auf v0.10.0 (`harness/conventions.md` §Baseline). Diesen Slice an
  einen dortigen CR zu hängen, erzeugt den abhängigen Zombie-Slice, vor dem Modul 5
  warnt. Umgekehrt ist wertvoll: Ein lokal laufender Sensor wäre **Betriebserfahrung**
  für den CR („läuft seit N Wochen, hat X gefangen") statt eines spekulativen Antrags.
  Aber erst, wenn die Prämisse trägt — sonst wäre die Betriebserfahrung „hat nichts
  gefangen, weil es nichts zu fangen gab".
- **Nebenbefund beim Anlegen dieses Slice: der d-check-Pin ist die Ursache, nicht
  d-check.** `make docs-check` färbte rot, weil der Plan
  `harness/tools/cite-check.sh` <!-- d-check:ignore (geplante Datei; diese Erwähnung im Befundtext loeste den Befund selbst aus) --> nennt — eine Datei, die per Definition erst nach der
  Umsetzung existiert. `codepaths` prüft Pfade in **Inline-Code-Spans**, deren Präfix
  auf `codepaths.roots` passt (hier `harness`); `test/cite-check.bats` blieb still,
  weil `test` kein Root ist. Bisher fiel das nie auf: **alle zehn bisherigen Slices
  fassten ausschließlich bestehende Dateien an** (rewrite/update); dies ist der erste,
  der ein neues Harness-Tool ankündigt.
- **Korrektur (2026-07-17, gegen den d-check-Quelltext geprüft): „`codepaths` verbietet
  Doc-führt-Code-folgt" war falsch.** Die erste Fassung dieses Slice behauptete das und
  leitete daraus einen d-check-CR-Bedarf ab („Unterscheidung referenzierter vs.
  geplanter Pfad fehlt im Gate"). Beides trifft nicht zu. `codepaths` kennt **drei
  Ventil-Achsen**: `d-check:ignore` (zeilen-weit), `exempt-paths` (datei-weit) und
  `codepaths.ignore-refs` (**referenz-weit** — eine Glob-Liste aufgelöster Ziel-Pfade,
  die von der Existenz-/Escape-/Anker-Prüfung ausgenommen sind). Die dritte ist exakt
  die angeblich fehlende Unterscheidung; sie existiert seit d-check **0.34.0**
  (dort `ADR-0025`) <!-- d-check:ignore (fremde ADR-Kennung: d-check-eigene, nicht die dieses Repos — vgl. slice-011 §6 zum vendored Baum) --> und ist im dortigen CHANGELOG als „dritte Ventil-Achse neben
  `d-check:ignore` (Zeile) und `exempt-paths` (Datei)" eingeführt. Ein CR dafür wäre
  ein Antrag auf ein ausgeliefertes Feature.
  **Die eigentliche Ursache ist Pin-Lag:** Dieses Repo pinnt d-check **v0.10.0**
  (`harness/conventions.md` §Baseline); upstream steht am 2026-07-17 bei **0.45.1**.
  Bei v0.10.0 ist nachweislich nur `d-check:ignore` verfügbar (hier real benutzt, Gate
  wurde grün) — `ignore-refs` liegt 24 Minors jenseits des Pins. Was sich wie eine
  Werkzeug-Lücke anfühlte, ist ein 35 Minors alter Pin. **Folge:** Der Bedarf gehört
  **nicht** in einen d-check-CR, sondern in den ohnehin geplanten d-check-Pin-Sprung
  (eigener Slice, eigenes Risiko — slice-013 §Abgrenzung). **Die dort ursprünglich
  genannte Ziel-Version war doppelt falsch** und ist inzwischen aus allen
  Abgrenzungen entfernt: „v0.10.0 → 0.43.1, 33 Minors" war (a) überholt — 0.43.1
  stammt vom 2026-07-15, allein am 2026-07-17 erschienen vier weitere Releases bis
  0.45.1 — und (b) von Anfang an keine *Zählung*, sondern Arithmetik auf
  Versionsnummern: tatsächlich veröffentlicht sind zwischen 0.10 und 0.45 nur **29**
  Minors (0.13–0.16 und 0.20/0.21 gab es nie). **Lehre, allgemeiner als dieser Slice:**
  Eine Fremd-Version in einer Abgrenzung ist eine Wartungsfalle — sie steht an einer
  Stelle, die niemand pflegt, und beschreibt etwas, das sich viermal am Tag bewegt.
  Maßgeblich ist die Quelle (`git tag`), nicht ihre Kopie im Plan.
  **Vor der Nutzung zu klären:** `ignore-refs` ist im CHANGELOG als *Tombstone-Register*
  für bewusst **entfernte** Artefakte eingeführt („Frozen-Doc-Refactoring-Falle"), nicht
  für **geplante**. Ob geplante Pfade eine legitime Anwendung sind oder ein
  Zweckentfremden — und ob dafür `d-check:ignore` pro Zeile die ehrlichere Form bleibt
  (sichtbar am Ort, mit Begründung) — ist eine Entscheidung, kein Automatismus.
- **Der Steering Loop ist ohne diesen Slice geschlossen.** `.harness/skills/reviewer.md`
  nennt drei gültige Lerneintrag-Formen: geschärfte Regel · neuer Sensor · **benannte
  Spec-Lücke**. Der Review-Report liefert die dritte mit Beleg. Dieser Slice wäre die
  stärkere Form, ist aber **nicht** die geforderte — er ist Kür, kein offener Prozess-Rest.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-05-planning-harness.md)):
`harness/tools/`, `Makefile`/Gate-Config und die Doku teilen die adoptierte
Harness-Mechanik ([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids), [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)); GF (Doc führt).
