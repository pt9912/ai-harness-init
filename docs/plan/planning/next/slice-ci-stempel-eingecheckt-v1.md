# Slice slice-ci-stempel-eingecheckt-v1: Die CI trägt die eingecheckten Stempel (Implementation [`ADR-0111`](../../adr/0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Festlegung 6)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle ([`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst):
der Baseline-Test ist das *Mehr* — eine beobachtbare Closure-Bedingung, die
mehr beobachtet als die DoD dieses Slice; es gibt keine, der Closure-Trigger
unten wäre die Abschrift der eigenen DoD). Wellenlose Arbeit erscheint nicht
in der Roadmap (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine
Welle braucht).

**Bezug:**
[`ADR-0111`](../../adr/0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
(`Accepted`, `a23e4a06` — die bindende Fassung, deren Festlegung 6 diese
Implementations-Skizze bestellt: gitignore-Umstellung — Festlegung 1,
Frisch-Rechnung gegen Transport, Skip nur auf main — Festlegung 2,
Gesamt-Dateien gitignored — Festlegung 3, E2E-Stempel-Feld — Festlegung 4,
`make` committiert nicht — Festlegung 5, dieses Slice — Festlegung 6),
[`ADR-0108`](../../adr/0108-stempel-synthese-je-check-pruefgegenstand.md)
(deren Festlegung 3 — der CI-Satz — durch ADR-0111 revidiert ist; ihre
übrigen Festlegungen und Zusagen bleiben unberührt),
[`ADR-0103`](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
(die Hash-Ausnahme-Form, die
[`harness/tools/working-tree-hash.sh`](../../../../harness/tools/working-tree-hash.sh)
um die zwei committeten Ablage-Klassen wächst),
[`ADR-0083`](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
(der Stop-Hook deckt das Turn-Ende am Host; die CI braucht keinen Schreiber),
[`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
(eine Definition, derselbe Satzerzeuger auf dem Runner — kein zweiter Maßstab),
[`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
(die CI ist dort das Netz — die Workflows werden am CI-Lauf selbst belegt),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed),
[`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/
[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
(Anlage-Disziplin der drei neuen Mutations-Fälle).

**Berührte Spec-Stellen:** `—` — die Entscheidung trägt die Prozess-ADR;
[`ADR-0108`](../../adr/0108-stempel-synthese-je-check-pruefgegenstand.md) §5
(beobachtbar an der ADR-Index-Zelle: „revidiert durch ADR-0111"). Der Verweis
zeigt **aufwärts**: Die Spec nennt diesen Slice nie.

**Verantwortlich:** pt9912

**Autor:** pt9912 (Rolle Planner, je [`ADR-0111`](../../adr/0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
Festlegung 6, Architektur-Zug `a23e4a06`). **Datum:** 2026-11-28.

---

## 1. Ziel und Abgrenzung

**Ziel:** die Implementation von [`ADR-0111`](../../adr/0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
Festlegung 6 — die CI trägt die eingecheckten Stempel: je-Check-Keys und der
E2E-Stempel reisen mit dem Klon, der push-`main`-Job fährt je Push die
Drift-Menge über unverändertes `make gates` statt voll, die
`pull_request`-Jobs fahren erzwungen voll. Drei Liefer-Punkte, je zwei
Schichten (Harness-Mechanik + CI-Form), je der Festlegung-6-Skizze.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- *(Bestand bleibt bewusst stehen.)* Die zwei Gesamt-Dateien
  `.harness/state/gates-passed.diffsha` und `.harness/state/gates-passed.head`
  bleiben gitignored — kein Nachzug in die committed Welt
  ([`ADR-0111`](../../adr/0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
  Festlegung 3); der Stop-Hook deckt das Turn-Ende am Host unverändert.
- *(Es wäre ein anderer Vorgang.)* `make` committet nicht — das Rezept läuft
  auch in CI- und E2E-tmp-Kontexten mit Read-only-Annahmen; ein
  self-committendes make-Target bricht den Turn-Ende-Fluss des Stop-Hooks
  ([`ADR-0111`](../../adr/0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
  Festlegung 5 und Kontext zur verworfenen Alternative).
- *(Schicht-Abgrenzung.)* Die [`ADR-0108`](../../adr/0108-stempel-synthese-je-check-pruefgegenstand.md)-Fitness-Wächter
  (gates-fastpfad, Kante) bleiben unverändert und greifen weiter
  (Festlegung 6, letzter Satz); die Tafel-Mengen selbst werden hier nicht
  umgeschnitten.

## 2. Definition of Done

- [ ] **Liefer-Punkt 1:** die **gitignore-Umstellung** — der
      `.harness/state/`-Eintrag in der Pflicht-Form mit zwei Ausnahme-Blöcken
      (`/.harness/state/*` plus `!.harness/state/gates-passed-*.key` und
      `!.harness/state/full-smoke-passed.key`,
      [`ADR-0111`](../../adr/0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
      Festlegung 1/4); der Kopfkommentar der alten Form (*„Harness-Laufzustand
      (lokal — NUR state/)"*) ist an die committete Form angepasst; die
      committeten Ablage-Klassen tragen die deklarierte Hash-Ausnahme in
      [`harness/tools/working-tree-hash.sh`](../../../../harness/tools/working-tree-hash.sh)
      (ADR-0103 Festlegung 2-Form, sichtbarer Ort im Skriptkopf, fail-closed
      für nicht deklarierten committeten Inhalt unter `.harness/state/`); der
      Wächter (bats) hält die check-ignore-Formen je Klasse und die
      fail-closed-Form. Dazu der Mutations-Fall: die gitignore-Ausnahme fällt
      still weg → Wächter rot
      ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)).
- [ ] **Liefer-Punkt 2:** die **CI-Fassung der gates-Kante** — der
      push-`main`-Job konsultiert die transportierten Keys über unverändertes
      `make gates` (der Fast-Pfad greift am frischen Klon durch die
      committeten Keys von selbst), die `pull_request`-Jobs fahren
      `GATES_FORCE=1` voll; der Wächter einer frischen-Klon-Konsultation
      (SKIP und Teildrift über dem committeten Satz); die Workflows werden
      am CI-Lauf selbst belegt (die CI ist dort das Netz,
      [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Form).
      Dazu der Mutations-Fall: der Transport-Key wird in der Klassifikation
      still nicht mehr konsultiert → Wächter rot am benannten Grund.
- [ ] **Liefer-Punkt 3:** der **E2E-Stempel** — der Schreiber-Zug am
      [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh)
      (die zwei Zeilen nach grünem Ende), der CI-Skip-Griff am E2E-Job (liest
      das eine Festlegung-4-Feld, vergleicht gegen den frischen Baum-Hash,
      fail-closed) und sein hermetischer Wächter. Dazu der Mutations-Fall:
      der E2E-Skip liest ein fremdes Feld oder einen falschen Baum-Hash →
      Wächter rot.

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; Gate-Läufe und die Closure-Pflichten
zählen nicht mit.

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      `evidence/`-Datei ergänzen, wo eine Beobachtung anfiel; keine
      Beobachtung anfallen ist ebenfalls eine Antwort und wird in §7
      notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind hier geprüft
      — Repo ohne Wellen-Betrieb, nach dem `git mv`.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.gitignore`](../../../../.gitignore) | update | der `state`-Eintrag in der Pflicht-Form mit zwei Ausnahme-Blöcken, Kopfkommentar an die committete Form angepasst — LP 1 |
| [`harness/tools/working-tree-hash.sh`](../../../../harness/tools/working-tree-hash.sh) | update | die zwei committeten Ablage-Klassen als deklarierte Hash-Ausnahme, fail-closed je nicht deklariertem committetem state-Inhalt — LP 1 |
| `test/` (bats-Wächter, Name beim Implementer) | update/neu | check-ignore-Formen je Klasse und fail-closed-Form; SKIP- und Teildrift-Wächter der frischen-Klon-Konsultation; der hermetische E2E-Skip-Wächter — je LP |
| [`.github/workflows/ci.yml`](../../../../.github/workflows/ci.yml) | update | push-`main`-Job konsultiert die transportierten Keys, `pull_request`-Jobs `GATES_FORCE=1`, der E2E-Skip-Griff am E2E-Job — LP 2/LP 3 |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | der E2E-Stempel-Schreiber-Zug: die zwei Zeilen nach grünem Ende — LP 3 |
| `test/mutations/<drei neue Fälle>` | neu | je LP einer: Transport-Key still nicht konsultiert · E2E-Skip fremdes Feld/falscher Baum-Hash · gitignore-Ausnahme fällt still weg — Anlage je [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit) |

## 4. Trigger

**Start** (`next` → `in-progress`): [`ADR-0111`](../../adr/0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
ist `Accepted` (beobachtbar an der Status-Zeile und der ADR-Index-Zelle von
[`ADR-0108`](../../adr/0108-stempel-synthese-je-check-pruefgegenstand.md) —
„revidiert durch ADR-0111"). Ein weiterer Architektur-Zug braucht es davor
nicht: die Fassung trägt die ADR selbst (Festlegungen 1–6).

**Rückführungen — vorab benennen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): gerät der
  Stop-Hook-Edit, die Gesamt-Dateien als committete Klasse oder ein
  Tafel-Mengen-Schnitt in den Umfang — alle drei sind in §1 ausdrücklich
  ausgeschlossen.
- `in-progress` → `open` (blockiert — Carveout?): der Fast-Pfad greift am
  frischen Klon trotz committeter Keys nicht, oder der
  `working-tree-hash.sh`-Edit braucht eine zweite Ausnahme-Klasse neben der
  Festlegung-1-Form — dann geht die Frage an den Architect, bevor CI
  umgestellt wird.

## 5. Closure-Trigger

DoD (§2) vollständig, und die Fitness-Zeilen von
[`ADR-0111`](../../adr/0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
§Fitness Function sind gezeigt: der CI-Push-Lauf am frischen Klon SKIPpt/
fährt die Drift-Menge über die transportierten Keys, der E2E-Skip liest das
Festlegung-4-Feld und vergleicht gegen den frischen Baum-Hash, die drei
Mutations-Fälle färben an ihren benannten Gründen rot, und die committete
Klasse rotiert keinen Baum-Hash und keinen Key. Zusätzlich: Closure-Notiz mit
Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- **Ein Push mit vergessenen Keys fährt mehr als nötig** — die
  fail-closed-Richtung, bezahlt in Minuten, nicht in Behauptungen
  ([`ADR-0111`](../../adr/0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
  §Verglichene Alternativen F). — **Ausgang (vorgesehen):** entfallen mit
  Grund — der Preis ist der gewählte, der rot färbt statt still zu Skippen.
- **Die Schreiber-Ketten-Integrität am main-Push bleibt benannt** (Runner-
  und Netz-Fassung) — Rest aus Festlegungen 2 und 4 der ADR. — **Ausgang
  (vorgesehen):** weiter offen · benannt, nicht geschlossen
  ([`ADR-0111`](../../adr/0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
  Konsequenzen/Rest); greift der Fall real, Re-Evaluierung der ADR, nicht
  ein stiller Edit.
- **Die Deckung der Tafel-Mengen auf CI-Runner-Fassungen** — die Runner- und
  Netz-Varianten der Werkzeuge können von der Host-Fassung abweichen; der
  Transport-Key rechnet gegen denselben Satzerzeuger am Runner
  ([`ADR-0108`](../../adr/0108-stempel-synthese-je-check-pruefgegenstand.md)
  Festlegungen 2/3). — **Ausgang (vorgesehen):** weiter offen; der Träger
  steht im Rest-Abschnitt der ADR, nicht in diesem Slice.

## 7. Closure-Notiz

<!-- BEDIENHINWEIS — keine Norm; faellt beim Kopieren weg (README.md
§Verwendung, Schritt 5) und darf deshalb nichts Tragendes halten. Reihenfolge:
diese Sektion vor dem `git mv` nach done/ fuellen — einzige Ausnahme ist das
letzte DoD-Item in §2 (die Paarungen suchen in `done/`, also nach dem `git mv`).
Im Repo ohne Wellen-Betrieb braucht die Closure dadurch drei Commits: Inhalt,
`git mv`, Haekchen — das folgt aus der Hard Rule, es widerspricht ihr nicht. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln. Ging
der Gegenstand an einen anderen Slice oder entfiel er, trägt diese Sektion die
Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko aus §6 seinen
Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die zwei vorgelagerten
Schritte und die vier Pflichtkriterien (Konventionen-Dichte · Phase-Reife ·
Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und nicht mehr.
Der Abschnitt selbst entfällt nie; bedingt ist allein der
Modus-Begründungsblock am Ende.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `*` (gesamtes Repo,
Kürzel `ALL`, Modus-Deklaration
[`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area — CI-Workflows liegen in keinem Kürzel-Baum)
und `harness/tools/` (`TOOLS`) über
[`working-tree-hash.sh`](../../../../harness/tools/working-tree-hash.sh) und
[`full-smoke.sh`](../../../../harness/tools/full-smoke.sh) — die Schwelle
≥ 2 von 3 Achsen ist je erfüllt (Strukturregeln über den Adaptions-Block,
Phase-Reife Phase 5).

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen
(`docs/plan/planning/observations/BEO-ALL/`). Der Treffer der berührten
Ebene ist [`BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf`](../observations/BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf/state.md)
— Treiber-Umgebungs-Ebene, nicht die CI-Stempel-Klasse; falls im Zug eine
Beobachtung anfällt, trägt sie die Closure
(`evidence/slice-ci-stempel-eingecheckt-v1.md`). Keine Treffer unter der
Schwelle an der berührten Ebene.

**Modus:** alle berührten Sub-Areas GF — der Modus-Begründungsblock entfällt.
