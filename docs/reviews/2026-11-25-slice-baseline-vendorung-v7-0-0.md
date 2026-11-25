# Review-Report: slice-baseline-vendorung-v7-0-0 — 2026-11-25

**Review-Art:** Code-Review gegen Plan + Konventionen (Modul 10 §Drei Review-Arten).
**Gegenstand:** `slice-baseline-vendorung-v7-0-0`, Range `883e38e7`/`3fc82452` (Claim) … `e2eed75c` (HEAD).
Commits geprüft: `51649824` (Pins), `7afa252c` (Baum-Abtritt + Vendorung), `1477e06c` (§Baseline Stand), `a1cc90ce`/`060e7e87`/`6a80cf3d`/`e2eed75c` (Plan §7), `e8b7e822` (Retargeting), `88f85db3` (Re-Anker).
**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 ·
**Modell:** GLM 5.3 · **Datum:** 2026-11-25

**Eingangs-Kontext:**

- Plan `in-progress/slice-baseline-vendorung-v7-0-0.md` (§1–§8) — Diff geprüft gegen Plan §3-Zeilen und §7-Befundlage
- `AGENTS.md` §3.6/§3.7/§3.9/§3.11
- [`MR-007`] · [`MR-025`] · [`MR-033`] · [`MR-051`] · [`MR-057`] · [`MR-071`] · [`MR-090`] · [`MR-091`] — gelesen über `harness/conventions.md` und die Eintrags-Dateien
- ADR-0059 (SHA256SUMS als Release-Asset, Pin trägt den ZIP-Hash)
- Slice-Plan, CI-Beleg-Fähigkeit: Run-Nummern `45661467791` (2. Lauf), `45666751330` (3. Lauf), beide 2026-11-25

**Beleg-Methode zu F-1/F-2:** Die Shard-Artefakte des 3. CI-Laufs wurden
über `gh run download 45666751330 -n shard-<i>` geholt (Alle 10 Shards 0–9
erhalten; Artifacts retention 3 Tage, Lauf liegt am Prüftag). Die
Release-`SHA256SUMS` wurde über `gh release download v7.0.0` auf den
gleichen Klon gezogen und byte-gegen die vendored Fassung geprüft.

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Der dritte CI-Lauf (Run `45666751330`, geprüfter Commit `6a80cf3d`) wird in §7 mit Fakten beschrieben, die seine Shard-Belege **nicht** tragen: „alle 11 Shards grün mit echten Fall-Läufen (200–300 s je Shard, kein Vorlauf-Tod mehr)" und „die Ergebnis-Aggregation liest die Shard-Belege erneut leer". Die Artifacts zeigen das Gegenteil: **zehn** Shard-Jobs (0–9), je `rc=2`, **0** `mutate: ok`-Zeilen; jeder der 4 Worker pro Shard bricht fail-closed im Grün-Vorlauf ab („der Gruen-Vorlauf 'make test-bats' ist in SEINER Kopie ohne Mutation rot") an den sieben geplant-roten C2-Fixtures (`not ok 17/19/20/105–108`); „0 von 6–7 Fall-Dateien haben ein Ergebnis". **Kein Fall lief, kein Fall urteilt.** Der Ergebnis-Schritt („kein Ergebnis im Log") las die Logs damit **richtig** — eine Aggregations-Lese-Lücke existiert in diesem Beleg nicht. | [`AGENTS.md`](../../AGENTS.md) §3.6 · `LH-QA-02` | Plan §7, Absatz „CI-Probe dritter Lauf"; Belege Shard-Logs `log` / `rc` von Run `45666751330` | ja — Shard-Artefakte des Laufs (retention 3 Tage) oder ein lokaler Probe-Lauf nach Heilung von `test-bats` | `Übergabe-Artefakt behauptet Lauf-Ergebnisse, die der Beleg nicht trägt` |
| F-2 | MEDIUM | Der in §7 genannte Heilungs-Träger — „der Treiber-/Workflow-Zug" gegen „die Aggregations-Lücke" — hat nach F-1 keinen Gegenstand: es gibt keinen belegten Treiber-/Workflow-Defekt (der Ergebnis-Schritt urteilte korrekt BEFUND). Ein Folge-Zug auf dieser Basis würde ein Slice ohne Gegenstand anlegen; der reale Träger ist der strukturelle Zustand (Probe unurteilbar, solange `test-bats` die geplante rote C2-Fläche trägt) und damit C2, nicht der Treiber. Baseline-Form: ein Folge-Zeiger, der die Sendung nicht führt, zeigt ins Leere. | `v7.0.0` · `regelwerk/modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer übernimmt (Bedingung 1) | Plan §7, Satz „Träger der Heilung ist der Treiber-/Workflow-Zug" | ja — der Ergebnis-Schritt von Run `45666751330` gegen die Shard-Logs | `Folge-Adresse ohne Gegenstand` |
| F-3 | MEDIUM | Der rot-Beleg für die Zusage der drei re-angekerten Fälle **224/244/248** existiert nicht: alle drei CI-Läufe produzierten **null** Fall-Urteile (Vorlauf-Tode bzw. Vorlauf-Abbruch an der geplanten roten Fläche). `make mutate-greift` (775/775) hält nach [`MR-090`] §Grenze nur, dass der Anker **trifft** — nicht, dass der Wächter rot wird. Bis `test-bats` grün ist (C2), ist der rot-Beleg für **jeden** der 65 Fälle unmeßbar; §7 benennt die Grenze in der F-1-Fassung als „beobachtet und nur Lesedefekt". Bevor die Welle den Mutations-Schritt als getragen liest, braucht es die Nennung „unurteilbar bis C2 heilt" am selben Ort (§3.6: die Lücke benennen statt sie verdecken). | [`AGENTS.md`](../../AGENTS.md) §3.6 · [`MR-090`] §Grenze | Plan §7, „Nachlieferung 2"; `make mutate-greift` 775/775 · Run-Logs ohne Fall-Urteil | ja — ein Fall-Lauf nach C2-Heilung (lokal oder CI) | `Zusage trägt Anker-Treffer statt Wächter-Rot als Beleg` |
| F-4 | LOW | Die Nachlieferung 2 (Commit `6a80cf3d`, Anker-Nachlieferung in §7) hat eine `id-unlinked`-Befundzeile **neu** erzeugt: `docs/plan/planning/in-progress/slice-baseline-vendorung-v7-0-0.md:212` nennt `MR-071` ohne Link auf ihre Definition. Gemessen am Stand vor dem Report: `make docs-check` → „2986 Datei(en) geprüft, **147** Befund(e)" gegen die in §7 dokumentierten **146** (145 × `target-missing` + 1 × `planning-drift`). Die geplante rote Fläche ist um genau diese Zeile offene Zahl. | [`MR-001`] (Link-Pflicht des Doc-Gate) | Plan:212 | ja — `make docs-check` | `Neue Gate-Befundzeile außerhalb der geplanten roten Fläche` |
| F-5 | LOW | Die §3-Zeile `test/sources-pin.bats | update` schreibt eine Änderung vor, die nicht stattfand (Commit `51649824` ändert die Fälle nicht — begründet in der Commit-Message, aber die Plan-Zeile bleibt unkorrigiert); beim Closure-Lesen liest der nächste Lauf eine Plan-Zeile ohne Entsprechung im Code. | [`MR-025`] (Zahl/Kommando-Disziplin, auf Plan-Zeilen angewandt) | Plan §3, Zeile `test/sources-pin.bats` | ja — `git show 51649824 --stat` | `Plan-Zeile ohne Code-Entsprechung, unkorrigiert` |
| F-6 | INFO | Die §3-Nachlieferungs-Zeile (`.claude/rules/*.md`) begründet die Sendung mit der CI-Probe über [`MR-090`], dessen Gegenstand der Anker-Sensor ist; die Pflicht, die den Beleg urteilbar macht, ist die Probe-vor-Verifikation in [`MR-091`] Setzung 1. Die Sendung trägt, aber sie hängt am Nachbar-Eintrag. | [`MR-091`] Setzung 1 | Plan §3, Zeile `.claude/rules/*.md` | nein — Formlektüre | `Sendung am Nachbar-Eintrag begründet` |

## Geprüft, ohne Befund

| Bereich | Ergebnis |
|---|---|
| Pin-Kopplung (`51649824`): `Makefile` (`BASELINE_TAG`/`BASELINE_ZIP_SHA256`), `.d-check.yml` `sources`-Paar, `internal/fetch/baseline.go` (`DefaultTag`/`DefaultBaselineSHA256`) | geprüft, ohne Befund — vier Stellen tragen identisch `v7.0.0` / `34a7866d2b8f…0e`, fail-closed gekoppelt (§2/§3-Plan-Erfüllung, ein Zug wie gefordert) |
| Pin-Beleg gegen Publikation (ADR-0059) | geprüft, ohne Befund — Release-Asset `SHA256SUMS` von Tag `v7.0.0` geholt; es trägt genau eine Zeile (`34a7866d…  lab-regelwerk.zip`), gepaart je Asset-Name mit dem `Makefile`-Pin |
| Vendored Baum (`7afa252c`): `.harness/baseline/v7.0.0/` | geprüft, ohne Befund — `make baseline-verify` → `v7.0.0 OK — 55 Dateien`; die vendored `SHA256SUMS` ist die frisch erzeugte Baum-Form (55 Zeilen, „frisch" wie in Plan §3 deklariert), die Release-`SHA256SUMS` die Asset-Form — beide Klassen liegen getrennt (ADR-0059) |
| Abtritt des alten Baums | geprüft, ohne Befund — `.harness/baseline/v6.18.1/` im selben Commit entfernt; „ein Tag zur Zeit" gehalten (`internal/emit/templates/baseline-verify.sh` `<tag>`-Politik unangetastet, tag-agnostisch wie vermutet) |
| Emissions-Kanten | geprüft, ohne Befund — `internal/emit/templates/d-check.yml` führt keine Baseline-Pin-Zeile (`grep` leer); `InventurMessTag = "v7.0.0"` in `internal/emit/baumaussage.go`, Kopplungs-Test in der Datei benannt |
| Retargeting der 7 Baseline-Zeiger (`e8b7e822`) | geprüft, ohne Befund — alle 10 `.claude/rules/`-Dateien `test -f`-grün gegen `../../.harness/baseline/v7.0.0/…`; je Zielpfad vorher einzeln geprüft, wie §7 sagt |
| Re-Anker der Fälle 224/244/248 (`88f85db3`) | geprüft, ohne Befund am **Anker** — nur Namens-Anteile geändert (Diff gelesen), `# expect:`-Regeltext unangetastet; Sed-Stichprobe Fall 244 (`done/<wave-id>/archive\.zip` → `abgelegt/…`) trifft die `v7.0.0`-Vorlage und erzeugt die beabsichtigte Änderung; Reste-2-Stelle (`internal/emit/templates.go` Kommentar-/Rezept-Zeilen) unverändert, wie §7 sagt |
| Nachlieferungs-Form (Urteil 2) | geprüft ohne Befund **in der Form**: §3-Nachzug als Zeile „nachgetragen — Nachlieferung" mit Übergang in §7, Commit vorher (`e8b7e822`) — in-progress-Plan, nicht eingefroren, kein Verstoß gegen §3.11. Für die Anker-Nachlieferung fehlt die §3-Zeile; sie lebt nur in §7 (F-6-Umfeld, keine eigene Kategorie) |
| `harness/conventions.md` §Baseline (`1477e06c`) | geprüft, ohne Befund — `Stand:` als Version mit Datum-Zeile daneben, Zustandsform (kein Chronik-Verstoß §3.7); die verbleibenden `v6.18.1`-Pfadzeilen sind Bestands-Drift der C7-Fläche, kein Arbeitsauftrag dieser Sektion |
| Kommentar-Klassen §3.7 in den geänderten Code-Dateien | geprüft, ohne Befund — `baumaussage.go`-Kommentar beschreibt Zustand/Beleg, kein Herkunfts-/Konjunktiv-Verstoß |
| Host-Disziplin §3.9 über alle Commits | geprüft, ohne Befund — kein Host-Toolchain-Aufruf in den implementer Commits; CI-Läufe über `make mutate-auswahl`/`mutate-branch` (MR-014/MR-091-Konform) |

## Die drei angefragten Urteile

**1. MR-091-Verhältnis (Probe lief, aber kein Urteil).** Nach der in F-1
gezeigten Beleglage lautet das Urteil anders als vorgetragen: die dritte Probe
hat **nicht** „ohne Urteil" geschlossen, weil eine Aggregation leer las —
sie hat **keinen Fall laufen lassen** (alle 40 Worker brachen fail-closed im
Grün-Vorlauf an der geplanten roten `test-bats`-Fläche) und durfte deshalb
nach der Fail-Closed-Regel des Treibers gar kein Urteil fällen.
MR-091 Setzung 1 bleibt Pflicht und ist **nicht erfüllt** — aber sie ist im
geplanten roten Zwischenstand **strukturiert unerfüllbar**, solange C2 die
`test-bats`-Fläche nicht heilt; die zwei Normen (Probe vor Verifikation ·
geplante rote Fläche) kollidieren, und diese Kollision muss die Welle
entscheiden, nicht dieser Slice. Blocker für Closure: **ja** — nicht wegen
der fehlenden Probe, sondern wegen F-1: die Closure würde eine falsche
Beleglage in die Welle-Träger übergeben, aus deren Lerneintrag eine
Defekt-Klasse („Aggregation liest leer") entstünde, die es so nicht gibt.
Vorstellungen: §7 korrigieren (echter Zustand: 10 Shards, alle Worker
Vorlauf-Abbruch an C2-Fixtures, 0 Fall-Urteile, Ergebnis-Schritt korrekt) —
dann ist der dokumentierte Zustand schließbar.

**2. Nachlieferungen am Slice.** Legitim in der Übergabe-Form, mit zwei
Formresten. Beide Züge (Retargeting `e8b7e822`, Re-Anker `88f85db3`) sind
Enabling-Arbeit für eine Pflicht dieses Slices (MR-091-Probe vor der
Verifikation), nicht stiller Umfang: §1 schließt den Re-Anker nach C2 aus,
und der Pull-Forward ist mit dem konkreten Blocker begründet (Vorlauf-Tod,
Run-Nummern genannt). Die Vorlage ist der §3-Nachzug als „nachgetragen —
Nachlieferung" mit §7-Übergang — für den Retargeting-Zug sauber vollzogen.
Die zwei Formreste: (a) die Anker-Nachlieferung hat **keine** §3-Zeile (nur
§7); (b) die §3-Zeile `test/sources-pin.bats` schreibt eine Änderung vor,
die nicht stattfand, ohne korrigiert zu werden — beides schließbar vor dem
Commit (`git mv` ist noch nicht gelaufen), kein Blocker. Die Aussage, die
der Plan-Defekt-Form (§3.6-Nachzug) gälte, greift hier nicht: der Slices
Umfang, der den Pull-Forward legitimiert, stand zur Arbeit-Zeit als Pflicht
(MR-091) im Briefing.

**3. Beobachtungs-Register / Folge-Zeiger.** Für den vermuteten
Defekt („Aggregation liest leer") gibt es nach F-1 **keine** Eintragung —
die Voraussetzung fällt weg, und mit ihr der „Treiber-/Workflow-Zug" als
Heilungs-Träger (F-2). Was **sich** ins Register gehört, ist das, was der
dritte Lauf stattdessen belegt hat: die Grüner-Vorlauf-Schicht bricht an
der geplanten roten `test-bats`-Fläche und macht in dieser Phase **jede**
Mutations-Probe — über alle 65 Fälle — unurteilbar. Ob dafür ein
Eigen-Eintrag nötig ist oder der bestehende Eintrag
`BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last` (sein Gegenstand:
„die Vorlauf-Schicht verliert, nicht der Fall") erweitert wird, ist
Zuordnungs-Urteil im Lese-Schritt; seine **Beleglage** liegt in den
Shard-Artefakten dieses Laufs und — solange sie existieren (retention
3 Tage) — vor Ort. DoD-Konkordaten: die Register-Fortsetzung ist eine
Pflicht der DoD („Keine Beobachtung angefallen ist ebenfalls eine Antwort"
— hier: angefallen, und bislang **kein** `evidence/`-Eintrags-File für
diesen Slice, der letzte trägt `slice-d-check-sprung-v0930`); bis
Closure vollzogen.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 2 |
| LOW | 2 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** `Übergabe-Artefakt behauptet Lauf-Ergebnisse, die der Beleg nicht trägt` · `Folge-Adresse ohne Gegenstand` · `Zusage trägt Anker-Treffer statt Wächter-Rot als Beleg` · `Neue Gate-Befundzeile außerhalb der geplanten roten Fläche` · `Plan-Zeile ohne Code-Entsprechung, unkorrigiert` · `Sendung am Nachbar-Eintrag begründet`

## Verdikt

**Merge-blockierend:** ja — F-1 (HIGH) ist vor dem `git mv` nach `done/` zu
heilen: §7 trägt die dritte CI-Runde in der Fassung ein, die die
Shard-Artefakte belegen (Vorlauf-Abbruch an den C2-Fixtures, null
Fall-Urteile, kein belegter Treiber-Defekt); der Heilungs-Träger der Mutations-Schicht
wird auf den realen Zustand umgestellt (C2-Heilung als Vorbedingung jedes
Fall-Urteils) oder mit benannter Lücke offengehalten (F-3). Nach der
Korrektur sind die Reste (F-4 bis F-6) an der Slice-Closure zu räumen, nicht
Blocker.

**Übergabe:** Findings an den Implementer; die Finding-Klassen in die
Slice-Closure §7 und von dort in den Zähler. Dieser Report ist ein
Lauf-Beleg — die DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11).
