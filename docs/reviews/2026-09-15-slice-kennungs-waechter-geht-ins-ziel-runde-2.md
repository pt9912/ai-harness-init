# Review-Report: slice-kennungs-waechter-geht-ins-ziel — Runde 2, 2026-09-15

**Review-Art:** Nachlauf-Review gegen **die eigenen vier blockierenden Befunde** (Modul 10
§Drei Review-Arten). Kein voller Diff-Review, **kein DoD-Review** — DoD-/Spec-Konformität prüft der
Verifier (Modul 11, anderer Eingabe-Kontext).

**Gegenstand:** `a1059000` (F-1, F-3, F-4-Kopplung) und `0b6a9f06` (die Kopf-Aufzählung gekoppelt)
gegen Runde 1 (`docs/reviews/2026-09-15-slice-kennungs-waechter-geht-ins-ziel.md`), gemessen am
Stand `0b6a9f06`; dazu der Planner-Zug `d9a429d4` (§1, §4 — **nicht** Gegenstand, aber Voraussetzung
von F-2). Spitze dieses Laufs vor dem Report: `git log --oneline -1` → `0b6a9f06`,
`git status --porcelain` → leer.

**Kein Self-Review:** Dieser Lauf hat an keinem der beiden Commits geschrieben. Jede der vier
Behauptungen ist **nachgefahren**, nicht übernommen: die vier Rot-Belege sind einzeln in einer Kopie
außerhalb des Repos gefahren und ihre Fehlschlag-Ausgaben **gelesen** (§1); die zwei neuen
bats-Gruppen sind am Baum gelesen (§2); die Adress-Frage aus F-4 ist mit drei Sonden gemessen (§3).

**Skill:** `.harness/skills/reviewer.md` @ `0565f274` (2.0.0) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** deepseek-v4.1-flash:cloud[1m] · **Datum:** 2026-09-15

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis)*. Dieser Report friert ein; was er zitiert, bewegt sich weiter. Deshalb:
> **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines Lifecycle-Pfads, `make <target>` statt
> eines Links auf die Sensor-Datei, eine Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als
> Link (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Ein `pfad`-Feld auf den **geprüften
> Gegenstand** ist davon nicht betroffen — es zitiert den Stand des Laufs.

**Eingangs-Kontext:**

- Runde 1 dieses Laufs (`docs/reviews/2026-09-15-slice-kennungs-waechter-geht-ins-ziel.md`) — die
  vier blockierenden Befunde F-1 bis F-4, F-5, F-6
- Slice-Plan `slice-kennungs-waechter-geht-ins-ziel` — §1, §3, §4, §6 (Stand nach `d9a429d4`)
- [`ADR-0007`](../../docs/plan/adr/0007-bootstrap-phasen.md) (Idempotenz-Klassifikation, `Accepted`)
  · [`ADR-0053`](../../docs/plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
  (`Proposed`) ·
  [`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- `AGENTS.md` §3.6, §3.10, §3.11 · Baseline `v6.8.0` ·
  `regelwerk/modul-05-planning-harness.md` §Offene Risiken werden bei Closure aufgelöst ·
  `regelwerk/modul-08-agentenrollen.md` §Die neun Übergaben und ihre Artefakte

---

## Eigene Messungen

### 1. Die vier Rot-Belege, einzeln in einer Kopie außerhalb des Repos gefahren

Je Fall in `/tmp`, mit dem Sensor, den der Fall selbst nennt (`# verify:` bzw. die Ableitung aus
`# expect:`); gelesen wird die Fehlschlag-Ausgabe, nicht der Exit-Code allein:

| Fall | Sensor | erwarteter Wächter | Ergebnis (gelesen) |
|---|---|---|---|
| `test/mutations/354` | `test-go` (Ableitung) | `TestCommitMsgTraeger_ZielTraegtNurDenGitKanal` | FAIL mit `das Ziel bekommt [.claude/hooks/pretooluse-commit-msg-guard.sh] als zweiten Commit-Message-Kanal — harness/README.md §Traceability sagt zu, …` |
| `test/mutations/355` | `test-bats` | `rot: der Grund nennt den Ort der Menge und zaehlt sie nicht selbst auf` | `not ok 49` |
| `test/mutations/356` | `test-bats` | `kopplung: die Klassen-Aufzaehlung im Kopf ist die der Zeile patterns=` | `not ok 48` |
| `test/mutations/49-enforce-konvergent` | `test-go` (Ableitung) | `TestEnforce_Convergent` | FAIL mit 18 Pfaden, darunter `.githooks/commit-msg wurde nicht kanonisch neu geschrieben (konvergent verletzt): 19 Bytes gegen 1082 des ersten Laufs` und die zwei übrigen neuen Pfade |

```sh
# je Fall: Mutation anwenden, Datei-Änderung belegen, Sensor fahren, Erwartung im Fehlschlag lesen
make test-go      # 354: FAIL TestCommitMsgTraeger_ZielTraegtNurDenGitKanal (Meldung oben)
make test-bats    # 355: not ok 49   ·  356: not ok 48
make test-go      # 49:  FAIL TestEnforce_Convergent, grep -c 'wurde nicht kanonisch neu geschrieben' → 18
```

Alle vier treffen die Stelle, die der **Aufrufer** fährt: `354` und `49` die eingebetteten Quellen,
die die Go-Tests über `emit.EnforcePaths()` / `emit.Enforce()` lesen; `355`/`356` die emittierte
Prüfung bzw. ihren Kopf, die die bats-Gruppe über `Enforce`-nahe Pfade liest. Kein Zahn baut seine
Verdrahtung selbst nach.

### 2. Der Ist-Stand der drei gezogenen Aussagen

```sh
sed -n '155,157p' harness/README.md
#  "Im gebootstrappten Ziel trägt der git-eigene Hook die Kennungs-Zusage; den PreToolUse-Zusatz für
#   Commit-Messages bekommt es nicht."
sed -n '70,72p' internal/emit/templates/enforce/commit-msg-traceability.sh
#  "Erwartet wird eine Kennung aus der Menge in der Zeile `patterns=` dieser Pruefung."
grep -n '^@test' test/commit-msg-emission.bats | wc -l        # 10
```

Die Aussagen decken sich mit dem emittierten Bestand: die Träger-Menge des Ziels ist eine
(`grep -rln 'pretooluse-commit-msg' internal/ cmd/` → EXIT 1), die Meldung führt keine Klasse mehr,
und der Kopf-Absatz nennt sie in Worten — gebunden an `patterns=` durch die Gruppe
`kopplung: die Klassen-Aufzaehlung im Kopf ist die der Zeile patterns=` über **beide** Fassungen
(emittiert und Dogfood), mit `fail-closed` bei leerer Ableitung.

### 3. F-4 — die abgegebene Seite und die Frage nach ihrer Adresse

```sh
grep -c 'githooks' docs/plan/adr/0007-bootstrap-phasen.md                       # 0 (ADR unberührt)
git log --oneline -1 -- docs/plan/adr/0007-bootstrap-phasen.md                  # 3491b7a6 (Accepted-Zug)
git grep -ln 'githooks' -- docs/plan/planning/open docs/plan/planning/next      # keine Ausgabe
sed -n '/^## 6\. Risiken/,/^## 7/p' <Slice-Plan> | grep -c -i 'idempotenz\|githooks\|ADR-0007'   # 0
```

Drei Sonden, eine Antwort: **kein** Artefakt führt die abgegebene Entscheidung. Die ADR ist
unberührt, in `open/` und `next/` nennt kein Slice die Frage, und §6 des Slice führt kein Risiko zu
ihr. Die abgegebene Seite steht allein in der Commit-Message von `a1059000` — und eine
Commit-Message ist kein Artefakt, das ein späterer Lauf wieder liest (dieselbe Grenze, die
`AGENTS.md` §3.7 für den Kommentar zieht).

### 4. F-5 und F-6

```sh
grep -c 'ADR-0053' <Slice-Plan>                       # 0 — der Plan trägt die ADR weiterhin nicht
git show d9a429d4 --stat --format="" | tail -1        # 1 file changed, 19 insertions(+), 11 deletions(-)
git diff --name-only 8c1b87b8 0b6a9f06 -- internal/   # 7 Dateien, alle unter internal/emit/
```

F-5s Adresse ist weiter leer; F-6s Grund steht in §1 („Die Träger-Wahl des Dogfoods für sich"),
und die Lieferung bleibt innerhalb der dort gezogenen Grenze (`internal/emit/`).

### 5. Der Gate-Lauf über dem neuen Stand

```sh
make gates        # EXIT 0
#  baseline-verify: v6.8.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)
#  d-check: 1446 Datei(en) geprüft, 0 Befund(e)
#  test-bats: 305 ok, 0 not ok
#  comment-claims: 63 Datei(en) geprueft, 0 Befund(e)
```

`make full-smoke` und `make mutate` sind **nicht** gefahren (siehe Grenzen).

---

## Verdikt je Befund

| Befund (Runde 1) | Verdikt | Beleg |
|---|---|---|
| **F-1** (HIGH) — „zwei Träger im Ziel" | **behoben.** Der Satz nennt jetzt genau die Reichweite des Ziels: den git-eigenen Hook als Träger, den PreToolUse-Zusatz als **nicht** vorhanden; die Zeile daneben benennt, dass die Aktivierungs-Grenze dort schwerer wiegt, weil der aktivierungsfreie Kanal fehlt. Kein „mehr" bleibt stehen (keine zweite Fassung der Menge im Ziel, kein zweiter Kanal) und kein „weniger" (die zwei Grenzen, die Reichweiten-Zusage und der `HOOKS_DIR`-Hinweis stehen weiter). Der Satz hat jetzt den Sensor, den er vorher nicht hatte, und der Rot-Beleg trifft ihn (`354`, §1). | `harness/README.md:155` · `internal/emit/commitmsg_test.go` (`TestCommitMsgTraeger_ZielTraegtNurDenGitKanal`) |
| **F-2** (MEDIUM) — §1 gegen den Vollzug | **behoben, durch die zuständige Rolle.** `d9a429d4` zieht die Grenze auf das, was sie meint (die emittierte Ebene, `internal/emit/`, gegen den Laufzeitpfad), und §4 nennt denselben Zustand. Nicht mein Gegenstand in dieser Runde; geprüft ist nur, dass der Vollzug **innerhalb** der gezogenen Grenze bleibt — alle sieben `internal/`-Dateien liegen unter `internal/emit/` (§4). | `slice-kennungs-waechter-geht-ins-ziel` §1 und §4 |
| **F-3** (MEDIUM) — zweite Aufzählung ohne Bindung | **anders behoben als in meiner ersten Lesart — und tragend.** Gewählt ist: die Aufzählung aus der **Meldung** nehmen und den **Kopf** an `patterns=` koppeln. Das trägt, weil die verbleibende Prosa-Aufzählung nicht mehr ungebunden ist: die neue bats-Gruppe leitet die Klassen aus `patterns=` ab (je Alternative der Teil bis zum ersten Bindestrich) und hält sie gegen die Klassen im Kopf-Zusatz — für beide Fassungen der Prüfung, fail-closed bei leerer Ableitung. Beide Richtungen sind gemessen (`355` entfernt die Meldung, `356` lässt den Kopf um eine Klasse fallen; beide rot, §1). Die Zusage in `harness/README.md` ist mitgezogen („Ihre Fehlermeldung wiederholt die Menge nicht, sondern nennt die Zeile"). | `internal/emit/templates/enforce/commit-msg-traceability.sh:70` · `test/commit-msg-emission.bats:80` · `harness/README.md:171` |
| **F-4** (MEDIUM) — Idempotenz-Klasse ohne Zeile | **teilweise behoben, in der Sache offen.** Die **Implementer-Seite** ist erledigt und nachgemessen: `TestEnforce_Convergent` fährt jetzt über die **ganze** Enforce-Menge (kanonischer Stand, Löschen + verstellt Neuanlegen, zweiter Lauf, Inhalt **und** Modus), die drei neuen Pfade stehen einzeln in der Aussage, und der Rot-Beleg meldet `.githooks/commit-msg` mit (§1). Die **ADR-Seite** ist zu Recht abgegeben — eine Idempotenz-Klasse ist eine Architektur-Entscheidung, und die Accepted-ADR fasst sie nicht an —, aber sie hat **keine Adresse**: die ADR ist unberührt, `open/`/`next/` führen kein Slice dazu, §6 des Slice führt kein Risiko dazu (§3). Damit ist der Befund nicht beantwortet, sondern nur benannt: das Ziel schreibt `.githooks/commit-msg` weiter konvergent, und das benannte Versagen — ein Adopter-Re-Lauf ersetzt einen dort liegenden eigenen Träger lautlos — ist unverändert. | `internal/emit/enforce_test.go` (`TestEnforce_Convergent`) · `docs/plan/adr/0007-bootstrap-phasen.md` (kein `githooks`) · `slice-kennungs-waechter-geht-ins-ziel` §6 |
| **F-5** (LOW) — Beleg-Kette der Commit-Message | **nachrichtlich angenommen, nicht repariert.** Eine Commit-Message ist eingefroren; sie umzuschreiben wäre ein `git`-Eingriff in die Vergangenheit, kein Nachzug. Die Adresse bleibt offen: der Plan trägt `ADR-0053` weiter nicht (§4), und der Satz, den die Message als Träger benennt, ist §3. | Commit `446cc05d` (Message) · `slice-kennungs-waechter-geht-ins-ziel` §3 |
| **F-6** (INFO) — Dogfood-Fassung des Anweisungssatzes | **angenommen.** Der Implementer entscheidet und nimmt nicht mit; §1 schließt die Träger-Wahl des Dogfoods aus. Der genannte Grund greift etwas weiter als §1 (ausgeschlossen ist die **Wahl**, nicht ein Satz über den bestehenden Hook), die Entscheidung trägt aber auf dem stärkeren Grund: der lokale Träger ist in diesem Klon nicht aktiv und müßte es nach [`ADR-0053`](../../docs/plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 4 auch nicht sein, weil die Werkzeug-Commits keine Kennung tragen — ein Satz, der zur Aktivierung anwiese, wiese in die falsche Richtung. | `.claude/commands/implement-slice.md:37` · `slice-kennungs-waechter-geht-ins-ziel` §1 |

## Findings dieser Runde

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| N-1 | INFO | Der neue Wächter des Träger-Bestands misst die Abwesenheit über einen **Namens**-Filter: er sucht in `emit.EnforcePaths()` nach Pfaden mit dem Teilstring `commit-msg` und in der emittierten `settings.json` nach derselben Zeichenkette. Ein Agenten-Kanal unter einem Namen ohne diesen Teilstring (etwa `.claude/hooks/pretooluse-kennung.sh`, in der `settings.json` verdrahtet) bliebe für ihn unsichtbar, während der README-Satz fällt. Der realistische Fall — genau dieser Repo-Kanal unter seinem Namen — ist getroffen (`354`). | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) | `internal/emit/commitmsg_test.go` (`TestCommitMsgTraeger_ZielTraegtNurDenGitKanal`) | ja — eine zweite Quelle mit anderem Namen und Verdrahtung in der `settings.json` lässt `make test-go` grün (nicht gefahren, weil die Aussage am Baum ablesbar ist) | `abwesenheits-waechter-mit-namens-filter-statt-mengen-pruefung` |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Die vier Rot-Belege (354, 355, 356, 49)** | **geprüft, ohne Befund.** Jeder einzeln gefahren und gelesen (§1); jeder fällt rot am erwarteten Wächter, jeder trifft die Stelle, die der Aufrufer fährt. `355`/`356` fallen an den Nummern, die `0b6a9f06` nennt (`not ok 49` bzw. `not ok 48`). |
| **Die zwei Fassungen des Prüfers** | **geprüft, ohne Befund.** Die Kopplungs-Gruppen aus Runde 1 stehen unverändert; die neue Kopf-Kopplung läuft über **beide** Fassungen und ist fail-closed bei leerer Ableitung. |
| **Die dritte Stelle mit einer Kennungs-Aufzählung im emittierten Baum** (der Bullet der Command-Vorlage `.claude/commands/implement-slice.md`) | **geprüft, ohne Befund.** Sie steht in einer **skip-if-present**-Anleitung mit `ANPASSEN`-Marker, die der Adopter adaptiert — eine Prosa-Nennung, keine Fassung der Menge; mein Befund sprach von der Prüfung. Ein Finding wäre hier eine Forderung ohne Quelle. |
| **`make gates` über dem neuen Stand** | **geprüft, ohne Befund.** Exit 0, `305 ok / 0 not ok`, `1446 Datei(en) geprüft, 0 Befund(e)`, `comment-claims 63/0` (§5) — die Zahlen der beiden Commit-Messages reproduzieren. |
| **Der Planner-Zug `d9a429d4`** | **geprüft, ohne Befund** — soweit er Voraussetzung dieses Laufs ist: die gezogene §1-Grenze deckt den Vollzug (alle sieben `internal/`-Dateien unter `internal/emit/`), §4 nennt denselben Zustand. Sein Text ist nicht Gegenstand dieser Runde. |
| **§3 des Plans** | **geprüft, ohne Befund.** Unverändert; deckt sich weiter mit dem gelieferten Stand. |
| **`harness/conventions/**`, Welle-Closure, benachbarte Wellen** | **nicht Gegenstand** (Auftrags-Grenze). |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 0 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** `abwesenheits-waechter-mit-namens-filter-statt-mengen-pruefung`
(neu vergeben). Aus Runde 1 sind `doku-behauptet-traeger-den-das-emittierte-ziel-nicht-hat`,
`zweite-ungebundene-aufzaehlung-der-kennungs-menge` und
`out-of-scope-grenze-des-plans-bleibt-stehend-ueber-ihrem-vollzug` **erledigt**;
`emittierter-pfad-ohne-zeile-in-der-idempotenz-klassifikation` bleibt **offen** und ist um ein
Auftreten derselben Sache gewachsen (die Abgabe ohne Adresse ist die zweite Gestalt derselben
Klasse); `beleg-beruft-sich-auf-eine-stelle-die-ihn-nicht-fuehrt` und
`convention-des-commit-traegers-nicht-in-der-dogfood-fassung-des-anweisungssatzes` bleiben ohne
neues Auftreten. Die Zuordnung zu `BEO-<KUERZEL>/<slug>` ist Sache der Slice-Closure (§7).

## Verdikt

**Merge-blockierend: ja — allein wegen F-4, und dort allein wegen der fehlenden Adresse.**

F-1 und F-3 sind behoben und so behoben, wie der Befund sie gestellt hat; F-3 auf einem anderen Weg
als dem, den ich zuerst genannt hatte, und der andere Weg trägt (§Verdikt je Befund). F-2 hat der
Planner gezogen. F-5 trägt nachrichtlich, F-6 ist entschieden.

F-4 bleibt offen, aber **nicht** als Forderung an den Implementer: seine Seite ist getan und
nachgemessen, und dass die ADR-Seite nicht in seinen Kontext gehört, ist die richtige Einordnung
(`AGENTS.md` §3.8/Modul 8). Was fehlt, ist der **Träger der Abgabe** — ein Risiko-Ausgang, eine
Datei in `open/` oder eine ADR, also eines der Artefakte, die dieses Repo für einen Rollenwechsel
ohnehin verlangt (Modul 8: kein Rollenwechsel ohne Artefakt). Ohne eines davon ist die Entscheidung
nach der Closure nicht wieder lesbar, und genau dieser Zustand ist die Klasse, die der Report
benennt. Der Slice kann bei rotem Sensor nicht schließen (Modul 5 §Offene Risiken …), aber er kann
die fehlende Adresse in §6 benennen — der Planner hält den Abschluss (`AGENTS.md` §3.10).

**Was dieser Report nicht entscheidet:** welches der drei Träger-Artefakte die Abgabe aufnimmt ·
welche Idempotenz-Klasse `.githooks/commit-msg` bekommt (Architect) · ob der Namens-Filter aus N-1
verengt wird.

**Was dieser Report nicht geprüft hat:** `make full-smoke` (nicht gefahren — der Wellen-Closure-
Trigger fährt ihn) · `make mutate` (Post-integration, nicht gefahren; die vier berührten Fälle
einzeln gefahren, §1) · die DoD-Konformität als solche (Modul 11, anderer Eingabe-Kontext) · die
übrige Lieferung aus `446cc05d` (nicht erneut geprüft — Runde 1 steht) · `harness/conventions/**`
und die Welle-Closure.
