# ADR-0111: Die CI trägt die eingecheckten Stempel — je-Check-Keys und der E2E-Stempel reisen mit dem Klon, CI fährt je Push die Drift-Menge statt voll

**Status:** Accepted

**Datum:** 2026-11-28

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Revidiert (Teil-Supersede):** den CI-Satz von
[ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md) Festlegung 3
(*„CI läuft unverändert voll — die Keys reisen nicht mit dem Klon (gitignored), der frische
Klon fährt fail-closed voll"*) und den CI-Satz der Konsequenzen von
[ADR-0099](0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md)
(*„CI bleibt unverändert (frischer Klon: kein Stempel, fail-closed voller Lauf)"*). Die übrigen
Festlegungen und Zusagen beider bleiben **Accepted** und unberührt: Schreiber, Ordnungskante,
Stop-Hook-Konsum, fail-closed-Richtung, `GATES_FORCE` und der benannte Rest tragen weiter wie
bisher ([AGENTS.md](../../../AGENTS.md) §3.4 kennt den Voll-Supersede; die Teil-Revision wird im
ADR-Index an [ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md) annotiert — so kann
kein Slice den revidierten CI-Satz als aktiv zitieren). §3.5 bindet diese Revision: die CI-voll-Form
ist eine Gate-Grenze, ihre Aufweichung ist diese ADR, nicht ein PR-Kommentar.

**Bezug:**
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(derselbe Stempel-Bestand, dieselbe SKIP-Entscheidung auf CI wie am Host — deterministisch,
ohne neuen Schlüssel),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(Ein SKIP behauptet kein Verdikt, das der Schlüssel nicht deckt — der transportierte Satz
behauptet nur, was ein Lauf trug),
[ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md)
(die Tier-2-Form: Satzerzeuger, je-Check-Keys, Drift-Klassifikation — hier transportiert, nicht
geändert),
[ADR-0099](0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md)
(Fail-closed-Form, Ausschalter, benannter Rest),
[ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
(Festlegung 3: die zwei Gesamt-Dateien und ihre weiteren Leser — unverändert),
[ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
(Festlegung 4: der benannte Rest — hier je auf die CI-Kante gestellt),
[ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
(Festlegung 2-Form: die deklarierte Hash-Ausnahme als sichtbarer Ort),
[ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 5 (der nächste Fall wird
einzeln entschieden — die CI-Aufweichung ist dieser Fall, ein künftiger Adopter-Fall braucht eine
eigene Entscheidung, siehe Trigger 4),
[`MR-003`](../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
(die CI als Netz über dem Stop-Hook-Stempel — ihr Konsum ändert sich hier),
[`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed),
[`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
/ [`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
(Anlage-Disziplin der Mutations-Fälle)

**Schärft:** — Prozess-ADR ohne Spec-Stratum. Der Fast-Pfad und der E2E-Stempel sind keine
Spec-Stellen; die Ordnungskante `record-gates: <checks>`
([`spec/architecture.md §5`](../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume))
bleibt unberührt, und der CI-Werkzeug-Weg bleibt Weg, keine Pflicht
([`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).

---

## Kontext

Die CI fährt heute je Push beide Läufer voll (Push-Lauf ca. 7 min `make gates`,
ca. 45–60 min `make full-smoke`; [`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)).
Der frische Klon trägt keinen Stempel, weil die Stempel-Klasse gitignored ist —
[ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md) Festlegung 3 hat das als
Satz, nicht als Schluss gesetzt. Der Auftraggeber hat entschieden, die feingranularen Stempel
einzuchecken und auf CI wirksam zu machen, damit CI nicht je Push neu testet, was ein grüner
Lauf über unverändertem Prüfgegenstand bereits trug. Der Prüfgegenstand der je-Check-Keys
kommt aus getrackten Dateien
([`harness/tools/gates-keys.sh`](../../../harness/tools/gates-keys.sh), Tafel-Mengen) — ein
Key deckt exakt dasselbe am CI-Klon wie am Host-Lauf, wenn er mit dem Klon reist.

## Entscheidung

Wir wählen: **Die Key-Klasse wird committet; CI konsultiert den transportierten Satz gegen die
Frisch-Rechnung desselben Satzerzeugers — genau die Tier-2-Drift-Klassifikation, am selben
Skript; der E2E-Stempel reist als eine committete Datei; die Schreiber-Kette bleibt, `make`
committiert nicht.** Sechs Festlegungen:

**1. Committed je-Check-Keys — die gitignore-Umstellung trägt die Festlegung.**
Die Klasse `.harness/state/gates-passed-<check>.key` wechselt in die committed Welt; die zwei
Gesamt-Dateien `.harness/state/gates-passed.diffsha` und `.harness/state/gates-passed.head`
bleiben gitignored (Festlegung 3). Die Form: der Verzeichnis-Eintrag `.harness/state/` im
[`.gitignore`](../../../.gitignore) wird zu einer Pflicht-Form mit zwei
Ausnahme-Blöcken (`/.harness/state/*` plus `!.harness/state/gates-passed-*.key` und
`!.harness/state/full-smoke-passed.key`, Festlegung 4); der Kopfkommentar *„Harness-Laufzustand
(lokal — NUR state/)"* trägt die alte Form und wird im Implementer-Zug an die neue angepasst —
dieser ADR bestellt die Form, der Edit trägt sie. Die committete Klasse liegt außerhalb des
Baum-Hash und außerhalb jedes je-Check-Keys: [`harness/tools/working-tree-hash.sh`](../../../harness/tools/working-tree-hash.sh)
bekommt die zwei committeten Ablage-Klassen als deklarierte Hash-Ausnahme
([ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
Festlegung 2-Form, sichtbarer Ort im Skriptkopf, fail-closed für nicht deklarierten committeten
Inhalt unter `.harness/state/`), mit demselben Grund wie `MENGE_AUSSCHLUESS` im Satzerzeuger
(*„ein Key deckt sich nicht selbst"*) — ein Stempel-Commit rotiert damit keinen Baum-Hash und
keinen Key, und [ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md) Festlegung 2
(*„gitignored — nie in der ls-files-Menge"*) gilt für die Keys als Ausschluss-Klasse unverändert
weiter.

**2. Das Vertrauens-Modell: Frisch-Rechnung gegen Transport, Skip nur auf main.**
CI vergleicht den transportierten Key je Check gegen den frisch gerechneten Wert desselben
Satzerzeugers (`gates-keys.sh key <check>`); Ungleichheit, Fehlen, Unformalität oder
Satzerzeuger-Fehler fahren den vollen bzw. den Drift-Anteil — exakt die Klassifikation von
[`harness/tools/gates-fast.sh`](../../../harness/tools/gates-fast.sh), kein zweiter Maße-
stab ([ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md) Festlegungen 1/3). Der
transportierte Stempel behauptet zusätzlich „dieses Baum-Grün wurde einmal verifiziert"; diese
Behauptung ist gebunden an `main` mit Push-Schutz: die Skip-Konsultation läuft nur im
push-auf-`main`-Job, die `pull_request`-Jobs fahren voll (die erzwungene Form: `GATES_FORCE=1`
je PR-Job — derselbe Schalter, dieselbe Werte-Welt aus
[ADR-0099](0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md) Festlegung 3). Der Forger kann
den frischen Key selbst rechnen und am eigenen Branch committen — sein PR läuft trotzdem voll
(das drückt sein Ergebnis nicht in den Hauptzweig), und ein main-Push mit falsch passenden
Keys skippt Checks, deren Prüfgegenstand er nie fahren ließ: dieser Rest liegt außerhalb jedes
baum-abgeleiteten Schlüssels ([ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegung 4); sein Träger ist der main-Push-Schutz zusammen mit der Schreiber-Kette der
Festlegung 5 — kein Sensor hält die Integrität der Kette, und die SKIP-Meldung behauptet kein
heutiges Check-Ergebnis, sondern das des Stempel-Laufs.

**3. Die zwei Gesamt-Dateien bleiben untransportiert — die HEAD-Kante auf CI ist der
Commit selbst.** `gates-passed.diffsha` und `gates-passed.head` bleiben gitignored und
host-Klasse ([ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
Festlegung 3 unverändert). Eine vom Auftragsentwurf abweichende Entscheidung liegt hier: der
`head`-Wert lässt sich nicht transportieren — die Datei kann nicht die Commit-SHA des Commits
tragen, der sie selbst trägt (jede Nach-Kopplung schafft einen neuen HEAD statt den gemessenen;
Alternativen B unten). Die der gedachten HEAD-Kante entsprechende Bindung ist auf CI die
Frisch-Rechnung selbst: die Keys reisen in dem Commit, dessen Baum der Klon trägt, und der
Vergleich gegen die Frisch-Rechnung misst jeden Tafel-Ausschnitt gegen exakt diesen Baum —
nichts kommt zwischen Transport und Prüfgegenstand. Die Rest-Klassen (Dateien, über die kein
Check der Kante urteilt, `MENGE_REST`) brauchen keine Kante: kein SKIP behauptet über sie ein
Urteil ([ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md) Festlegung 4). Bei Drift
fährt CI genau die gedriftete Check-Menge (dieselbe Tier-2-Form) und schreibt **keinen**
Stempel zurück — der Read-only-Kontext der CI bleibt, der Rück-Stempel ist Host-Pflicht des
Implementer-Zugs (Festlegung 5).

**4. Der full-smoke-E2E-Stempel — eine Datei, ein Feld, kein Netz-Versprechen.**
Der E2E-Stempel ist eine committete Datei
`.harness/state/full-smoke-passed.key`, maschinengeschrieben vom grünen
[`make full-smoke`](../../../harness/sensors/full-smoke.md)-Lauf am Ende; zwei Zeilen:
`baum-hash <64-hex>` (der Wert von
[`harness/tools/working-tree-hash.sh`](../../../harness/tools/working-tree-hash.sh) am
Lauf-Start — die tmp-Repos der E2E liegen außerhalb des Baums) und `varianten <n>` (die
Anzahl der E2E-Varianten; die Matrix lebt im Skript-Inhalt und ist damit transitiv im
Baum-Hash — eine Datei je Variante wäre 13 alternierende Dateien, Alternativen D). Keine
Commit-SHA-Stelle (Festlegung 3: zirkulär), kein Datumsfeld (die Chronik trägt `git`). CI
skippt die E2E nur, wenn `baum-hash` dem frisch gerechneten Baum-Hash des Klons gleicht; fehlend,
unformal, fremd oder Parser-Zweifel → voll (fail-closed, [`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)).
**Der benannte Rest bleibt:** die externen Zugänge — die Verfügbarkeit des
Traeger-Releases (`SHA256SUMS`, Asset des gepinnten Tags) und die Registry-/Netz-Zustände —
liegen je [ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 4
außerhalb jedes baum-abgeleiteten Schlüssels, ebenso die Runner-Fassung des CI-Läufers; der
Stempel deckt nur den Baum-abgeleiteten Teil, und ein E2E-Skip konserviert das Netz-Runner-
Verdikt des Stempel-Laufs. Die Skip-Meldung der CI nennt diesen Rest.

**5. Die Schreiber-Kette: Schreiber bleiben, der Commit gehört dem Implementer-Zug.**
`record-gates` bleibt der alleinige Schreiber der je-Check-Keys und der zwei Gesamt-Dateien,
`gates-fast` stempelt nach grünem Drift-Exit wie bisher
([ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md) Festlegungen 2/3), `full-smoke`
schreibt den E2E-Stempel nach grünem Ende. **Kein make-Target committiert:** das Committing
der Stempel-Dateien ist Teil des Implementer-Zugs in demselben Commit wie der betroffene
Inhalt — die Key-Werte hängen nur an Tafel-Inhalten, nicht am HEAD, und sind darum an dem
Commit gültig, der Inhalt und Stempel zusammen transportiert, ohne dass der Lauf den Commit
kennt. Ein Push, der Inhalt mitführt und die aktualisierten Keys vergisst, fährt auf CI genau
die gedrifteten Checks (fail-closed-Richtung, kein Rot, kein stiller Skip). Der
Auftragsentwurf bot die Alternative „`record-gates` committiert die state-Dateien selbst am
selben HEAD" — verworfen: das Rezept läuft auch in CI- und E2E-tmp-Kontexten mit Read-only-
Annahmen, und ein self-committendes make-Target bricht den Turn-Ende-Fluss des Stop-Hooks
([ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) Festlegung 1);
der Stop-Hook deckt das Turn-Ende am Host, und die CI braucht keinen Schreiber am Skript.

**6. Implementations-Slice-Skizze, Kennung `slice-ci-stempel-eingecheckt-v1`.**
Drei Liefer-Punkte, je zwei Schichten betroffen (Harness-Mechanik + CI-Form): (a) die
gitignore-Umstellung samt Kopfkommentar, die Hash-Ausnahme-Erweiterung in
[`working-tree-hash.sh`](../../../harness/tools/working-tree-hash.sh) und ihre Wächter
(bats: die check-ignore-Formen je Klasse, die fail-closed-Form für nicht deklarierten
committeten state-Inhalt); (b) die CI-Fassung der gates-Kante — push-`main`-Job konsultiert
die transportierten Keys über unverändertes `make gates` (der Fast-Pfad greift durch die
committeten Keys am frischen Klon von selbst), `pull_request`-Jobs fahren erzwungen voll, plus
der Wächter einer frischen-Klon-Konsultation (SKIP und Teildrift über dem committeten Satz)
und die CI-Workflows werden am CI-Lauf selbst belegt (die CI ist dort das Netz, [`MR-003`](../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Form);
(c) der E2E-Stempel — der Schreiber-Zug am full-smoke-Skript (die zwei Zeilen nach grünem
Ende), der CI-Skip-Griff am E2E-Job (liest das eine Feld, vergleicht gegen den frischen
Baum-Hash, fail-closed) und sein hermetischer Wächter. Dazu die Mutations-Fälle je
[`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit):
der Transport-Key wird still nicht mehr konsultiert → Wächter rot; der E2E-Skip liest ein
fremdes Feld oder einen falschen Wert → Wächter rot; die gitignore-Ausnahme fällt still weg
→ Wächter rot. Die [ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md)-Fitness-Wächter
(gates-fastpfad, Kante) bleiben unverändert und greifen weiter.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun (CI voll je Push) | keine Transport-Oberfläche, keine Vertrauensfrage je Stempel | je Push werden je 7 und 45–60 Minuten wiederholt, die identische Inhalte fahren — der Beleg steht bereits, wird aber nicht konsumiert ([ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 2-Form) |
| B — CI liest zusätzlich `gates-passed.head`/`.diffsha` (Auftragsentwurf Festlegung 3) | eine Gesamt-Kante über dem Baum | `head == HEAD` ist zirkulär — die Datei kann die SHA des Commits nicht tragen, der sie trägt; jede Nach-Kopplung (Amend, Stempel-Commit) bewegt HEAD über den gemessenen Wert. `.diffsha` wäre mit den Hash-Ausnahmen konsistent, aber redundant: die je-Check-Frisch-Rechnung misst dieselben Ausschnitte enger und die Rest-Klassen brauchen kein Urteil (Festlegung 3) |
| C — `record-gates` committiert die Stempel selbst (Auftragsoption Festlegung 5) | der Stempel-Commit kann vergessen werden | ein self-committendes Rezept läuft auch in CI- und E2E-Read-only-Kontexten und bricht den Stop-Hook-Fluss am Turn-Ende; der Commit gehört dem Implementer-Zug, den der Stop-Hook deckt |
| D — eine Stempel-Datei je E2E-Variante | je Variante unabhängiger Skip | 13 Dateien altern je Lauf; die Varianten-Matrix lebt im Skript-Inhalt und ist transitiv im Baum-Hash — der Satz ohne eigene Dateien ist kleiner und nicht weniger deckend |
| E — Skip auch im `pull_request`-Job | dieselbe Verkürzung auf einem Klon mehr | der Forger spart die eigentliche Prüfung seines eigenen PR; gewählt: PR fährt voll, die Behauptung „verifiziert" bleibt an die main-Push-Kette gebunden (Festlegung 2) |
| **F — transportierter Satz gegen Frisch-Rechnung desselben Satzerzeugers, Skip nur auf main, E2E-Stempel als eine Datei, `make` committiert nicht (gewählt)** | ein Mechanismus, keine zweite Definition des Drift-Urteils; der frische Klon trägt den Nachweis je Push | der Rest aus Festlegungen 2 und 4 bleibt bestehen (Schreiber-Ketten-Integrität am main-Push; Runner- und Netz-Fassung); ein Push mit vergessenen Keys fährt mehr als nötig — die fail-closed-Richtung, bezahlt in Minuten, nicht in Behauptungen |

## Konsequenzen

- Positiv: CI fährt je Push die Drift-Menge der Kante und die E2E nur bei Baum-Drift; der
  frische Klon trägt den Nachweis — auf CI und in jedem lokalen Klon. Schreiber, Ordnungskante
  und Stop-Hook bleiben unverändert ([ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md)
  Festlegungen 2/3/5, [ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)).
- Negativ: Der benannte Rest ist auf CI härter als am Host — die SKIP-Meldung der CI konserviert
  das Verdikt eines Host-Laufs über Runner-Fassung, CI-Cache-Zustand (Festlegung 2) und
  Netz-/Registry-Zustand der E2E (Festlegung 4), die niemand adressiert. `GATES_FORCE=1` am
  main-Job und der erzwungene PR-Voll-Lauf machen es behebbar, nicht abwesend.
- Negativ: Ein falsch passender Satz auf `main` (Festlegung 5, Rest) skippt Checks ohne Lauf;
  kein Sensor hält die Schreiber-Ketten-Integrität. Träger: main-Push-Schutz plus die
  Schreiber-Form; `GATES_FORCE=1` am main-Job ist der Behebungs-Griff auch hier.
- **Kein Eintrag im Adaptions-Block**, nach der Lesart von
  [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage): der transportierte
  Stempel-Konsum hat in der adoptierten Baseline kein Gegenstück (die Baseline kennt keinen
  CI-Stempel-Transport), von dem abgewichen werden könnte; der Fast-Pfad-Konsum selbst ist
  dieselbe Design-Eigenschaft, die
  [ADR-0099](0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md) §Konsequenzen bereits gelesen
  hat, hier am neuen Ort transportiert und nicht ersetzt.
- Folgepflicht (Implementer-Zug, `slice-ci-stempel-eingecheckt-v1`): die
  `make gates`- und `make full-smoke`-Zellen in
  [`harness/README.md`](../../../harness/README.md) §Sensors nennen den transportierten
  Konsum und tragen diese ADR als Bindung; die SKIP-Meldungen nennen den Rest je Kante.

## Fitness Function

| Tooling | Regel | Make-Target |
|---|---|---|
| bats, `test/ci-stempel-committed.bats` (neu, hermetisch über Fixture-Baum) | **Happy:** frischer Klon mit committetem, deckendem je-Check-Satz → SKIP-Meldung mit benanntem Rest, kein Check fährt; Teildrift → genau die gedrifteten Checks. **Negative:** transportierter Key fehlt · fremd · unformal · Satzerzeuger-Fehler → voller Lauf; E2E-Stempel fehlt · unformal · `baum-hash` fremd → volle E2E. **Boundary:** `GATES_FORCE=1` → voller Lauf malgré committeten Satz; die zwei Gesamt-Dateien fehlen am Klon, ohne dass ein SKIP greift | `make test` (in `make gates`) |
| bats, `test/ci-stempel-committed.bats` (gitignore-Formen) | `git check-ignore`: `.harness/state/gates-passed-lint.key` und `.harness/state/full-smoke-passed.key` nicht ignoriert, `.harness/state/gates-passed.diffsha` und `.head` ignoriert; nicht deklarierter committeter Inhalt unter `.harness/state/` färbt den Baum-Hash-Wächter rot (fail-closed, [ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md) Festlegung 2-Form) | `make test` (in `make gates`) |
| Mutations-Fälle, `test/mutations/` (drei neu, Festlegung 6) | (a) der Transport-Key wird in der Klassifikation still nicht konsultiert → Wächter rot am benannten Grund; (b) der E2E-Skip liest ein fremdes Feld oder einen gefälschten Baum-Hash → Wächter rot; (c) die gitignore-Ausnahme fällt still weg → Wächter rot. Anlage je [`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand) / [`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit) | `make mutate` (bevorzugt lokal, `MUTATE_CASES`) |

**Was hier nicht behauptet wird:** der Rot-Beleg steht **nicht** in dieser ADR — die Wächter
entstehen erst im Implementer-Zug, und das Einweihungs-Kriterium des Slices misst die drei
Klassen am realen Wächter ([AGENTS.md](../../../AGENTS.md) §3.6); die Verdrahtung der
Workflows (push-`main`-Skip, PR-Voll-Lauf, E2E-Skip-Griff) belegt der reale CI-Lauf, nicht ein
lokaler Wächter. **Was kein Wächter hält:** die Integrität der Schreiber-Kette am `main`-Push
(Festlegungen 2 und 5) und die Deckung der Tafel-Mengen auf CI-Runner-Fassungen — Träger sind
die Re-Evaluierungs-Trigger, geprüft im Trigger-Audit der Closure.

## Re-Evaluierungs-Trigger

Nicht permanent. Vier beobachtbare Bedingungen, jede einzeln auslösend:

1. **SKIP/Teildrift auf CI und erzwungener voller Lauf liefern über demselben Stand
   verschiedene Verdikte** (beobachtbar an zwei Läufen am selben Push) — dann konserviert der
   Transport ein Runner- oder Cache-Verdikt, das kein Schlüssel deckt; die Skip-Form ist neu
   zu wägen, im Extremfall per Folge-ADR mit `Supersedes ADR-0111`.
2. **Ein Check tritt in die Kante ein oder aus, oder die Tafel-Lesung ändert sich** — dann
   ist die Deckung je Check neu zu zeigen, **bevor** CI den transportierten Satz weiter
   konsultiert (Form der [ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md)
   Trigger 1); ein Push vor dem re-gestempelten Satz fährt voll — die fail-closed-Richtung
   trägt die Lücke nicht zu.
3. **Eine zweite Schreibstelle der Stempel-Klasse entsteht** (ein Werkzeug schreibt
   `.harness/state/` außerhalb der drei Schreiber) oder die Schreiber-Kette driftet von der
   Form der Festlegung 5 — dann ist die Vertrauens-Form neu zu halten, bevor der Transport
   weiter behauptet, was die Kette nicht schrieb.
4. **Der emittierte Baum oder ein Adopter-Target bekommt die committed-Keys-Form** — eigene
   Entscheidung mit eigener Deckungs-Messung, einzeln entschieden
   ([ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 5-Form; Form der
   [ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md) Trigger 4).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-28 | **Accepted** | Architektur-Übergabe-Artefakt auf die Auftraggeber-Entscheidung
(*„die feingranularen Stempel werden eingecheckt und auf CI wirksam"*); Annahme durch den
Auftraggeber am 2026-11-28. Die zwei Abweichungen vom Auftragsentwurf stehen als gewählte
Alternativen im Kopf von Festlegung 3 (`head`/`diffsha` untransportiert, Begründung: Zirkularität)
und Festlegung 5 (`make` committiert nicht, Begründung: Read-only-Kontexte); beide sind
Architektur-Form-Entscheidungen innerhalb des Auftrags |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0111` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
