# Review-Report: `slice-commit-traeger-wird-skip-if-present` — 2026-09-16

**Review-Art:** **Code-Review gegen Plan, ADR und Hard Rules.** Kein DoD-Review (Verifier,
Modul 11), keine Validation gegen realen Bedarf, kein Accept-Schritt (Architect).

**Gegenstand:** Commit `d7fd8227` („Rolle Implementer: slice-commit-traeger-wird-skip-if-present —
der Commit-Traeger verlaesst die konvergente Menge"). Der **Slice-Diff** ist `77b927c7..d7fd8227` —
**19 Dateien, +530/−114**; `d7fd8227` selbst trägt gegen seinen Parent `2f82b466` nur die zwei
Dateien des Abgleichs zweier divergenter Läufe (`+5/−6`, beide in `internal/emit/templates/enforce/hooks-install.mk`
und `test/mutations/360-fragment-ohne-klassen-satz.sh`). Beide Fassungen sind gelesen; das Urteil zu
ihrer Differenz steht als Negativbefund unten. Arbeitsbaum sauber (`git status --porcelain` leer).

**Skill:** `.harness/skills/reviewer.md` @ `0565f274` (2.0.0) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** deepseek-v4.1-flash:cloud[1m] · **Datum:** 2026-09-16

**Kein Self-Review — als Negativ-Aussage:** Dieser Lauf hat an keiner Stelle des geprüften Diffs
geschrieben — kein Byte an `internal/emit/**`, `harness/**`, `test/mutations/**`, kein Byte an einer
ADR, einem Plan oder einer Norm-Datei. Die einzige von diesem Lauf geschriebene Datei ist dieser
Report. **Keine Einschätzung des Implementer-Berichts ist übernommen:** die Befunde zu den
Mutations-Fällen, die Fundmenge der gezogenen Sätze, die fünf Rot-Belege und die Gate-Zahlen der
Commit-Message sind in Kopien außerhalb des Repos nachgefahren (§Eigene Messungen) oder am
Zielartefakt gelesen.

**Eingangs-Kontext:** der Slice-Plan `slice-commit-traeger-wird-skip-if-present` (vollständig,
§1–§8) · [`ADR-0054`](../plan/adr/0054-emittierter-commit-traeger-skip-if-present.md) (`Accepted`) ·
[`ADR-0007`](../plan/adr/0007-bootstrap-phasen.md) Festlegung 3 · [`ADR-0022`](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
Festlegung 4 und 5 · [`ADR-0053`](../plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
· [`AGENTS.md`](../../AGENTS.md) §3.4/§3.6/§3.7/§3.9/§3.11 · [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 1 · [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) ·
[`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
Baseline `v6.8.0` · `regelwerk/modul-08-agentenrollen.md`, `regelwerk/modul-10-review-harness.md`.

---

## Eigene Messungen

```sh
# (1) greifen die Anker ALLER Fälle noch? — je Fall eine Kopie mit den deklarierten # files:,
#     Mutation fahren, Hash der Zielliste vorher/nachher
for path in test/mutations/*.sh; do m=$(basename "$path" .sh); spec=$(grep -m1 '^# files:' "$path" | sed 's/^# files: *//'); \
  mkdir -p w; cp --parents $spec w/; before=$(cd w && find . -type f -exec sha256sum {} + | sort -k2 | sha256sum); \
  (cd w && bash "$path") >/dev/null 2>&1; after=$(cd w && find . -type f -exec sha256sum {} + | sort -k2 | sha256sum); \
  [ "$before" = "$after" ] && echo "NO-OP $m"; rm -rf w; done
# -> changed=345  NO-OP=2  sonstige=0 ; die zwei: 157-hook-wrapper-nicht-emittiert (enforce.go),
#    164-rollentypen-konvergent (agents.go)
git show 77b927c7:internal/emit/enforce.go | grep -c '{"templates/enforce/span-emit.sh", ".claude/hooks/span-emit.sh", 0o755},'   # 1
git show 77b927c7:internal/emit/agents.go   | grep -c 'writeSkipIfPresent(targetDir, f.dst, content, f.mode)'                    # 1

# (2) alle 32 Fälle, deren deklariertes Ziel eine der 19 Diff-Dateien ist, durch die Go-Stufe
#     (Kopie je Fall, make test-go, '--- FAIL:'-Zeilen gegen '# expect:' gehalten)
while read -r m; do ...; (cd "$d" && make test-go) > "$m.stage.log"; grep -oE -- '--- FAIL: [A-Za-z_0-9]+' "$m.stage.log"; done
# -> 4 Befunde:  157 NO-OP · 164 NO-OP · 50 keine '--- FAIL:' · 354 keine '--- FAIL:'
#                50: internal/emit/enforce.go:518:3: break is not in a loop, switch, or select
#               354: internal/emit/enforce.go:135:105: too few values in struct literal of type enforceFile
# -> 26 weitere: angewandt, stage_rc=2, der jeweilige '# expect:'-Name steht in den FAIL-Zeilen
# ->  2 Ausnahmen mit ANDERER Stufe, nicht durch test-go gemessen: 160 (# verify: full-smoke,
#     Anker `const carrierMode fs.FileMode = 0o755` liegt in unberührtem Text), 190
#     (# verify: test-bats, Anker `einordnen "make -j gates im Ziel (--lang go)"` ebenso)
# die fünf behaupteten Rot-Belege einzeln, mit gelesener Ausgabe:
# -> 49: --- FAIL: TestEnforce_IdempotenzKlasseJePfad  (+ TestCommitMsgTraeger_BelegterPfadBleibtUndWirdGemeldet)
# -> 358: --- FAIL: TestCommitMsgTraeger_BelegterPfadBleibtUndWirdGemeldet
# -> 359: --- FAIL: TestCommitMsgTraeger_BelegterPfadBleibtUndWirdGemeldet
# -> 360: --- FAIL: TestHooksInstallFragment_TraegtDieKlasseSeinesPfades
# -> 361: --- FAIL: TestEnforce_IdempotenzKlasseJePfad  (+ 20 weitere, weil jeder Enforce-Lauf abbricht)

# (3) die Fundmenge der gezogenen Sätze — die entfernten Zeilen des Diffs, die eine Klasse behaupteten
git diff -U0 77b927c7 d7fd8227 | grep -E '^-[^-]' | grep -iE 'konvergent|kanonisch|unbedingt|tool-eigen|uebrigen|Bootstrap'

# (4) der Name, den die Umbenennung abschafft
grep -rn 'TestEnforce_Convergent' --include='*.go' .        # kein Treffer
grep -rn 'TestEnforce_Convergent' --exclude-dir=.git .      # ADR-0054:252 · done/slice-kennungs-waechter-geht-ins-ziel.md:261 · Reviews

# (5) Belege der Commit-Message, nachgefahren
make baseline-verify   # v6.8.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos), EXIT 0
make docs-check        # d-check: 1461 Datei(en) geprueft, 0 Befund(e), EXIT 0 (1461 mit diesem Report)
make test-bats         # 1..305, 0 not ok, EXIT 0
make comment-claims    # 63 Datei(en) geprueft, 0 Befund(e), EXIT 0
make shell-lint        # EXIT 0
make full-smoke        # EXIT 0 — Abschnitt „Klasse des Commit-Traegers" gefahren; die Meldung im Ziel GELESEN:
                       # „ai-harness-init: .githooks/commit-msg liegt bereits — die Datei bleibt unberuehrt
                       #  (skip-if-present). Die mitgelieferte Pruefung tools/harness/commit-msg-traceability.sh
                       #  liegt daneben bereit; ein eigener Traeger kann sie von dort aufrufen."
make gates             # EXIT 0 über diesem Stand (nach dem Report-Commit gefahren)
```

`make mutate` ist **nicht** gefahren (Post-integration, nächtlich — so auch die Commit-Message);
einzelne Fälle liefen in `/tmp`-Kopien, wie oben. Alle Mutationen liefen gegen Kopien außerhalb des
Repos; der Repo-Baum ist von keinem Lauf berührt worden.

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | **HIGH** | **Vier gelistete Mutations-Fälle sind von diesem Refactor entwaffnet.** `157` und `164` greifen **nicht mehr** (Zielliste unverändert — der Anker zitiert die ersetzte Quell-Form: das positions-gebundene `enforceFile`-Literal bzw. den `writeSkipIfPresent`-Aufruf in `Agents`); `50` und `354` wirken noch, aber ihr erwarteter Wächter fällt **nicht aus seinem Grund** — beide erzeugen einen Übersetzungsabbruch statt einer `--- FAIL:`-Zeile (`break is not in a loop, switch, or select`, weil der `return nil`-Zweig aus dem `switch` in ein `if` wanderte; `too few values in struct literal`, weil `354` ein positions-gebundenes Element in das jetzt keyed-Literal einfügt). Kein Gate des Push-Pfads liest das: `make mutate` meldete den ersten beiden „Mutation hat nicht gegriffen … Patch veraltet?" und den beiden anderen „rot, aber '<expect>' faellt nicht — falscher Grund". Gemessen über **alle 347** Fälle (Anker-Probe) und über **alle 32** Fälle mit Ziel in einer der 19 Diff-Dateien (Go-Stufe) — es sind genau diese vier. | [`AGENTS.md`](../../AGENTS.md) §3.6 · `make mutate`, Treiber-Bedingungen 2 und 4 | `test/mutations/157-hook-wrapper-nicht-emittiert.sh:12` · `test/mutations/164-rollentypen-konvergent.sh:19` · `test/mutations/50-skipifpresent-clobbert.sh:9` · `test/mutations/354-agenten-kanal-geht-ins-ziel.sh:20` | ja — `make mutate` (nächtlich), Bedingung 2 bzw. 4; im Push-Pfad fällt nichts | `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` — die Register-Kennung existiert (Stand `verkörpert`, 3×) und ihre `state.md` benennt **genau diese zweite Hälfte** als offene Grenze: *„ein Fall, der das alte Symbol einfügt, verändert die Datei, und der erwartete Test fällt erst über den Übersetzungslauf aus einem anderen Grund. Träger beider Hälften ist der Lauf, der einen Fall schreibt oder seinen Anker anfasst"* — dieser Lauf ist dieser Träger |
| F-2 | **MEDIUM** | **Die Umbenennung des Ganz-Mengen-Tests läßt in [`ADR-0054`](../plan/adr/0054-emittierter-commit-traeger-skip-if-present.md) eine abgeschaffte Kennung stehen.** Die ADR sagt im Präsens zu, `TestEnforce_Convergent` laufe über jeden Pfad der Aufzählung und verlange die konvergente Klasse; diesen Test gibt es nach diesem Diff nicht mehr, und ihre Aussage *„benannt, nicht bewacht"* ist damit nicht mehr nachvollziehbar. Die ADR ist ab `Accepted` nach §3.4 eingefroren — die Korrektur ist ein eigener Architect-Vorgang, und der Plan hat diese Stelle nicht als Risiko geführt (§6/Risiko 4 formuliert dieselbe Klasse nur für die **namensfreie** Zeile der `ADR-0007` §Fitness Function). Dieselbe abgeschaffte Kennung steht in einem `done/`-Zeitdokument. **Zweite Folge:** die Klasse steht mit diesem Vorgang bei **3×** und hat im §8-Sichtungs-Schritt des Plans keine Zeile (er nennt drei andere Beobachtungen). | [`AGENTS.md`](../../AGENTS.md) §3.11 mit ihrer Grenze (kein *vorgeschriebener* Ortswechsel) · §3.7 · `ADR-0054` §Fitness Function | `docs/plan/adr/0054-emittierter-commit-traeger-skip-if-present.md:252` · `docs/plan/planning/done/slice-kennungs-waechter-geht-ins-ziel.md:261` | ja — `grep -rn 'TestEnforce_Convergent' --include='*.go' .` → kein Treffer, gegen die zwei Fundstellen; kein Modul liest den Namen | `praesens-aussage-in-einzufrierendem-artefakt-ohne-form` (3. Vorkommen; Nachbarklasse `vorgeschriebener-ortswechsel-macht-adresse-tot` deckt es nicht — dort bewegt ein *vorgeschriebener* Move die Adresse) |
| F-3 | **MEDIUM** | **Die Zahl „vier Stellen" der Commit-Message ist nicht die Fundmenge.** Die Message sagt *„Dazu vier Stellen, die der Plan nicht nannte"*, die Rückgabe desselben Laufs nennt **sieben**; am Diff gezählt sind es **fünf** Stellen mit einer Klassen-Aussage, die der Plan an keiner Stelle nennt (`Enforce`-Doc, `writeFileMode`-Doc, `captureFiles`-Doc, `EnforcePaths`-Doc, `hooksInstallMkFile`-Doc), eine sechste nur in der Lesart ohne §3-Tabelle (`commitMsgHookFile`-Doc, dort als Datei zitiert) und eine siebte **ohne** Klassen-Aussage (`fieldlist_test.go`, Namens-Verweis auf den umbenannten Test). Bei keiner der beiden Zahlen steht ein Kommando oder die Ansage, daß keines sie liefert; die Sieben der Rückgabe enthält umgekehrt den Zusatz `writeSkipIfPresent`, der keine Klasse behauptet. Die Message ist nach dem Push unveränderlich — der Träger ist eingefroren, bevor die Zahl geprüft war. | [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) Setzung 1 · [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 1 | Commit-Message `d7fd8227`, Abschnitt „SAETZE AM PFAD GEZOGEN" | nein — kein Gate liest eine Commit-Message; die Nachzählung ist Handarbeit an `git diff -U0 77b927c7 d7fd8227` (§Eigene Messungen 3) | `extensionale-zahl-unterschreitet-die-eigene-fundmenge` (2. Vorkommen) |
| F-4 | **LOW** | **`harness/README.md` §Traceability trägt die Lieferung des Trägers unbedingt.** *„Er reist als `.githooks/commit-msg` mit dem Klon, seine Prüfung als `tools/harness/commit-msg-traceability.sh` daneben, und der Hook ruft die Prüfung über sein eigenes Verzeichnis auf"* steht ohne die Bedingung, die derselbe Absatz zwei Sätze später und `ADR-0054` §Konsequenzen setzen (*„in einem Ziel mit belegtem Pfad kommt der Träger nicht an"*). Gelesen als Zusage an den Überflieger sagt sie, der Werkzeug-Träger liege im Ziel und rufe die Prüfung — was im neu geschaffenen belegten Fall gerade nicht gilt. Der Diff faßt diesen Absatz an, und `ADR-0054` Folgepflicht 1 nennt ihn namentlich. | [`AGENTS.md`](../../AGENTS.md) §3.6 · §3.7 | `harness/README.md:156` | nein — kein Modul liest die Aussage | `zusage-neben-geaenderter-ableitung-bleibt-stehen` (26. Vorkommen; der Plan nennt die Klasse in §8 für die README-Hälfte ausdrücklich) |
| F-5 | **LOW** | **Vier neue oder geänderte Begründungen stehen im Irrealis über einen nicht gefahrenen Lauf** — *„Ein Lauf, der ihn konvergent schriebe, koennte am Pfad nicht erkennen, wessen Datei dort liegt"* (`commitMsgHookFile`), *„ein stiller Default waere genau die Setzung, die niemand ausgesprochen hat"* (`writeEnforceFile`), *„Ein stilles Uebergehen waere die zweite Haelfte desselben Fehlers"* (`writeSkipIfPresentTold`), *„ein Test, der die Klassen je Pfad selbst auflistet, haette eine zweite Fassung daneben"* (`PathClass`). Die Abwägung, die sie wiederholen, steht in `ADR-0054` §Verglichene Alternativen und ist an drei der vier Stellen ohnehin zitiert; beschrieben wird so nicht der Zustand, sondern die verworfene Alternative — die §3.7-Form, die `make gates` nicht fängt. | [`AGENTS.md`](../../AGENTS.md) §3.7 (*Falsch:* Konjunktiv über die verworfene Alternative) | `internal/emit/commitmsg.go:54` · `internal/emit/enforce.go:439` · `internal/emit/enforce.go:453` · `internal/emit/enforce.go:250` | nein — kein Gate liest diese Sätze | `Kommentar begruendet im Konjunktiv ueber die verworfene Alternative` (neu; die Klasse war im Repo schon einmal LOW: `slice-066`/N1) |
| F-6 | **INFO** | **Der Abbruch bei einem klassenlosen Eintrag stützt sich auf eine Festlegung, deren Zweifelsregel anders entscheidet.** Die Fehlermeldung begründet *„ein Pfad ohne Klasse faellt aus, statt konvergent zu gelten (ADR-0007 Festlegung 3)"*, während jene Festlegung für den unentschiedenen Fall `skip-if-present` als *„der sichere Default"* nennt. Die Annahme, daß ein Eintrag ohne Klasse ein Programmierfehler und keine unentschiedene Klasse ist, ist nirgends ausgesprochen; das Verhalten ist strenger als die zitierte Regel, nicht ihre Anwendung. Zuständige Rolle für die Auflösung: Architect. | [`AGENTS.md`](../../AGENTS.md) §3.7 (Rang-Zeiger) · [`ADR-0007`](../plan/adr/0007-bootstrap-phasen.md) Festlegung 3 | `internal/emit/enforce.go:448` | nein — `make test-go` färbt den Fall (`test/mutations/361`) rot, die Aussage selbst prüft kein Modul | `Rang-Zeiger nennt eine Festlegung, deren Zweifelsregel anders entscheidet` |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| §1-Ausschlüsse des Plans | **geprüft, ohne Befund.** Der Diff nimmt keinen ausgeschlossenen Punkt mit: `cmd/`, `internal/gen`, `internal/wire` sind unberührt; die Klassen der zwei Nachbar-Dateien sind **bestätigt, nicht geändert** (`commitMsgCheckFile`/`hooksInstallMkFile` bleiben konvergent); die Erkennungs-Seite (`patterns=` in `internal/emit/templates/enforce/commit-msg-traceability.sh`) ist unangetastet; die Feststellungs-Zeile des emittierten `close-welle.md` steht. Daß `Commands`/`Agents` ihre Klasse jetzt als Feld tragen, ist keine zweite Fassung der `.claude/`-Zeilen der `ADR-0007`-Tabelle, sondern Folge des fail-closed-Writers — die Klasse selbst ist unverändert. |
| Die fünf behaupteten Rot-Belege (`49`, `358`, `359`, `360`, `361`) | **geprüft, ohne Befund.** Jeder in einer eigenen `/tmp`-Kopie gefahren, die Fehlschlag-Ausgabe **gelesen**: jeder fällt mit dem in der Message genannten Wächter und mit der dort genannten Meldung (§Eigene Messungen 2). Keiner fällt aus einem anderen Grund. |
| Die übrigen 28 Mutations-Fälle mit Ziel in einer der 19 Diff-Dateien | **geprüft, ohne Befund** — mit zwei benannten Grenzen. 26 fahren angewandt durch die Go-Stufe und der jeweilige `# expect:`-Name steht in den `--- FAIL:`-Zeilen; `160` (`# verify: full-smoke`) und `190` (`# verify: test-bats`) fahren eine **andere** Stufe, die dieser Lauf nicht gefahren hat — bei beiden liegt der Anker in unberührtem Text (`const carrierMode …`, `einordnen "make -j gates im Ziel (--lang go)"`). Die Grenze: die Stufen dieser zwei Fälle sind **nicht** nachgemessen. |
| §3.6-Zusage des Ganz-Mengen-Tests (`TestEnforce_IdempotenzKlasseJePfad`) | **geprüft, ohne Befund.** Der Test fährt je Pfad die Richtung **seiner** Klasse und mißt beide Richtungen: der freie Pfad wird geschrieben (Lesen des kanonischen Stands im ersten Lauf), der belegte bleibt samt Modus unberührt; die Vorbedingung *beide Klassen besetzt* fällt, wenn eine Klasse leer läuft (`358` belegt das). Die Modus-/Inhalts-Hälfte des Trägers ist **nicht** verloren — sie liegt in `TestCommitMsgTraeger_BelegterPfadBleibtUndWirdGemeldet` (Teil 1 und 3) und in `TestEnforce_ScriptsExecutable`. Der Name mißt, was er behauptet. |
| „Ein Pfad, eine Klasse, an einer Stelle" | **geprüft, ohne Befund.** `PathClass` liest die Aufzählung, die `Enforce` fährt; im Diff entsteht **keine** zweite Klassen-Liste (weder im Test noch im Treiber noch in der Config), und `writeEnforceFile` fällt ohne Klasse aus statt still konvergent zu gelten. `EnforcePaths` bleibt die Pfad-Inventur (auch für den skip-if-present-Träger). |
| Der Abgleich der zwei divergenten Läufe (`d7fd8227` gegen `2f82b466`) | **geprüft, ohne Befund — die Begründung trägt.** Der verworfene Satz *„ein `test -f` weiter unten ist ueber ihn keine Aussage darueber, wer ihn geschrieben hat"* benennt eine Zeile des Fragments, die `slice-aktivierung-reist-nicht-mit-dem-klon` nach seinem §3 entfernt (sein Zahn `358-aktivierung-ohne-traeger-pruefung` tut genau das) — ein Kommentar über eine Zeile, die der serialisierte Nachfolger wegnimmt, wäre beim nächsten Slice ein toter Verweis. Die durchgesetzte Fassung beschreibt stattdessen, was die Aktivierung dann bewirkt (Indikativ, an der Stelle gültig), und der zugehörige Zahn `test/mutations/360` greift mit dem neuen Wortlaut weiterhin und fällt am benannten Test. |
| Mutations-Nummerierung (`358`) | **geprüft, ohne Befund.** Zwei Pläne beanspruchen `358` für verschiedene Dateien (`…-traeger-wieder-konvergent.sh` hier, `…-aktivierung-ohne-traeger-pruefung.sh` dort); die Nummer ist im Bestand bereits mehrfach doppelt (`47`, `48`, `49`, `50` je zweimal), die Dateinamen bleiben disjunkt, und kein Sensor hält die Nummer für eindeutig. |
| §3.4 / §3.8 / §3.10 | **geprüft, ohne Befund.** Keine ADR, kein `AGENTS.md`-Abschnitt, kein `harness/conventions*`-Eintrag, kein Closure- oder Register-Artefakt und kein `git mv` im Diff; der Slice liegt weiter in `in-progress/`. Die Befund-Klassen gehen als Übergabe an Closure/Register, nicht in diesen Diff. |
| §3.9 (Docker-only) | **geprüft, ohne Befund.** Alle Läufe dieses Reviews sind `make`-Targets; die Rot-Belege liefen in Kopien unter `/tmp`. Keine Host-Toolchain. |
| Belege der Commit-Message | **geprüft, ohne Befund.** Alle Zahlen (54 Dateien, `docs-check` 0 Befunde, 305 bats, 63/0 comment-claims, `shell-lint`, `full-smoke`) sind nachgefahren und stimmen; der Beleg des Kerns ist die **gelesene** Ausgabe im gebootstrappten Ziel, nicht eine Zeile im Test. |
| Der neue `full-smoke`-Abschnitt | **geprüft, ohne Befund.** Er liest den **Inhalt** der geprüften Datei (nicht den Exit-Code), vergleicht gegen den gepflanzten Adopter-Träger, prüft die Anwesenheit der Prüfung daneben und liest die Meldung aus der gefahrenen Ausgabe; die drei gesuchten Sätze stehen in ihr. Die Zusage *„der freie Pfad bekommt den Träger des Werkzeugs"* ist mit der Delegations-Prüfung in `kennungs_traeger_im_ziel` verbunden, nicht nur behauptet. |
| Der `EnforcePaths`-Doc-Wechsel | **geprüft, ohne Befund.** Kein Produktions-Code liest `EnforcePaths`/`PathClass` (nur Tests); die neue Beschreibung „Inventur, an der Tests den Bestand koppeln" trifft also zu, und die alte „Bootstrap-Pre-Flight (cmd, Phase 3)"-Begründung war Drift und ist zu Recht gezogen. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 2 |
| LOW | 2 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` ·
`praesens-aussage-in-einzufrierendem-artefakt-ohne-form` ·
`extensionale-zahl-unterschreitet-die-eigene-fundmenge` ·
`zusage-neben-geaenderter-ableitung-bleibt-stehen` ·
`Kommentar begruendet im Konjunktiv ueber die verworfene Alternative` ·
`Rang-Zeiger nennt eine Festlegung, deren Zweifelsregel anders entscheidet`

**Fundmenge der gezogenen Sätze (eigene Zählung, §Eigene Messungen 3):** **fünf** Stellen
behaupteten dieselbe Klasse und sind vom Plan an keiner Stelle genannt — `Enforce`-Doc,
`writeFileMode`-Doc, `captureFiles`-Doc, `EnforcePaths`-Doc, `hooksInstallMkFile`-Doc. Eine
**sechste** (`commitMsgHookFile`-Doc) zitiert die Datei-Tabelle in §3 als Satz und ist nur in der
Lesart *ohne* diese Tabelle unbenannt; eine **siebte** gezogene Stelle trägt **keine**
Klassen-Aussage (`fieldlist_test.go`, reiner Namens-Verweis auf den umbenannten Test — erzwungen,
weil `make comment-claims` existierende Testnamen verlangt). Weder die „vier" der Message noch die
„sieben" der Rückgabe treffen diese Menge (F-3).

## Verdikt

**Merge-blockierend:** **ja** — F-1 (HIGH) und F-2, F-3 (MEDIUM) blockieren nach dem Schema des
Reports. F-1 ist keine Stilfrage: vier gelistete Wächter stehen im Set, ohne noch zu beißen, und die
Messung, die das sagt, läuft nächtlich, nicht am Push. F-2 und F-3 haben die Eigenschaft, die ihren
Träger einfriert — die ADR ist `Accepted`, die Message ist gepusht; beide sind in diesem Lauf nicht
mehr an ihrer Stelle zu heilen, und die Entscheidung darüber gehört dem Architect bzw. dem Planner,
nicht dem Implementer. F-4 bis F-6 sind nicht blockierend.

**Kein Rollen-Konflikt:** kein Befund dieses Laufs ist vom Implementer bestritten; der Konflikt-Pfad
aus Modul 8 (Übergabe-Artefakte, Architect-Verdikt) ist nicht ausgelöst.

**Übergabe:** F-1 geht an den Implementer (Rückkante an den Plan nur, wenn §1/§3 die vier Fälle
ausgeschlossen hätten — tun sie nicht). F-2 geht an den Architect (eingefrorenes Artefakt, §3.4),
seine Planner-Hälfte (3×-Übertritt, §8-Sichtung) an die Closure. F-3 wirkt auf die Closure-Notiz:
sie ist die Stelle, die den Zahl-Beleg nach dem Push noch tragen kann. Die **Finding-Klassen** gehen
zusätzlich in die Slice-Closure §7 und von dort in den Zähler. Dieser Report ist ein **Lauf-Beleg** —
er wird über Läufe hinweg nicht gelesen. DoD- und Spec-Konformität prüft der Verifier getrennt
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
