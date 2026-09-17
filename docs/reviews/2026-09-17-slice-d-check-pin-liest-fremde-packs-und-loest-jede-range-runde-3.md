# Review `slice-d-check-pin-liest-fremde-packs-und-loest-jede-range` (Runde 3) — 0 HIGH · 0 MEDIUM · 1 LOW · 1 INFO

**Rolle:** Reviewer · **Datum:** 2026-09-17 · **Geprüfter Stand:** `825107e1` (HEAD), **lokal**,
Basis `705b2bfc` · **Gegenstand:** allein der Norm-Commit `825107e1` — `MR-067`, die Kopf-Marke an
`MR-066`, die Index-Zeile und die Zeile in §Baseline · **Review-Art:** Review gegen
Adaptions-Block, `AGENTS.md` §3 und den Anlass V-1 aus der Verifikation · **Nicht Gegenstand:**
die DoD-Abhakung und die Befunde der Runden 1 und 2.

**Skill:** `.harness/skills/reviewer.md` @ `2.0.0` · **Modell:** `claude-opus-5[1m]`

**Eingangs-Kontext:** V-1 aus
`docs/reviews/2026-09-17-slice-d-check-pin-liest-fremde-packs-und-loest-jede-range-verify.md` ·
`harness/conventions.md` §Adaptions-Block · `MR-025`, `MR-032`, `MR-033`, `MR-039`, `MR-046`,
`MR-053`, `MR-055`, `MR-060`, `MR-063`, `MR-065`, `MR-066` · `AGENTS.md` §3.5, §3.6, §3.7, §3.8,
§3.11 · `LH-QA-01`, `LH-QA-03`.

---

## Eigene Messung

Die Folge aus `MR-067` ist **unabhängig nachgebaut** — nicht an der Kopie des Architects, sondern
an einem eigens angelegten Wegwerf-Repo im Scratchpad (zwei Commits, `git repack -a -d`, dann
`git clone --no-local`). Der Arbeitsbaum ist nicht berührt.

| Gegenstand | Ergebnis |
|---|---|
| git-Fassung | `git version 2.43.0` — deckt die Angabe im Eintrag |
| Schritt 2 übersprungen (Pack bleibt am Ort) | `git unpack-objects < …/pack-*.pack` endet mit **rc 0** und ohne Ausgabe, `count:` bleibt **0** — der stille Fehlschlag, den Setzung 3 behauptet, ist reproduziert |
| `-f` in der gemessenen Fassung | `git unpack-objects -f` → `usage: git unpack-objects [-n] [-q] [-r] [--strict]` — wörtlich die Zeile, die der Eintrag zitiert |
| Schritt 2 (Pack heraus) | `count: 0`, `in-pack: 0`, Pack-Verzeichnis leer |
| Schritt 3 (`git unpack-objects`) | `count: 5`, `in-pack: 0` |
| Schritt 4 (`git maintenance run --task=loose-objects`) | `count: 5` **und** `in-pack: 5` **gleichzeitig**, dazu `loose-<hash>.{idx,pack,rev}` — die „übersehene Hälfte" aus Setzung 3 ist reproduziert |
| Schritt 5 (`git prune-packed`) | `count: 0`, `in-pack: 5` |
| Setzung 2, beide Hälften | `ls .git/objects/pack/ \| grep -c '^pack-'` → **0** und `count:` → **0**; `git cat-file -t HEAD` → `commit`, der Klon ist intakt |
| Baseline-Zitat | `grep -c 'Und das Rot muss von \*dieser\* Regel kommen' .harness/baseline/v6.9.0/regelwerk/modul-13-quality-gates.md` → **1**, am adoptierten Tag (`MR-033`) |
| Prämisse der Entscheidung | `git cat-file -e origin/main:harness/conventions/MR-066-…md` → vorhanden; `origin/main` steht auf `93a0d10f`, `825107e1` und `705b2bfc` sind lokal. `MR-066` ist also **angenommen**, `MR-067` ist nicht vermeidbare Zeremonie |

Jeder Schritt der Tabelle in `MR-067` reproduziert an einem fremden Repo mit derselben
git-Fassung. Die Stellen-Grenze, die der Eintrag selbst zieht (`MR-055`), bleibt davon unberührt —
gemessen ist jetzt eine zweite Stelle, nicht die Klasse.

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| H-1 | LOW | Setzung 1 ist allgemein formuliert („eine Aufbau-Anleitung … nennt zuerst die Prüf-Bedingung"), und der Eintrag nennt **keinen Cutoff**. Die angenommenen Einträge des Blocks tragen Aufbau-Anleitungen ohne vorangestellte Bedingung und können sie nicht nachtragen, weil an einem angenommenen Eintrag nichts inhaltlich geändert wird. Ein späterer Lauf, der Setzung 1 am Bestand misst, findet ihn rot und hat zwei verbotene Auswege. `MR-060` hat genau diese Frage für das Pflichtfeld schon einmal gekostet — dort brauchte es einen eigenen Eintrag, um „gilt für neue, nicht rückwirkend" zu sagen. | `harness/conventions.md` §Adaptions-Block (Disziplin) · `MR-060` als Präzedenz · `AGENTS.md` §3.7/§3.8/§3.10, die ihren Cutoff je ausschreiben | `harness/conventions/MR-067-aufbau-anleitung-nennt-ihre-pruef-bedingung-vor-ihren-kommandos.md`, Feld `Adaption — Setzung 1` | nein: kein Modul misst Setzungen am Bestand | Setzung ohne Cutoff über einem append-only-Bestand |
| H-2 | INFO | Setzung 2 nennt zwei Bedingungen, die beide **Abwesenheit** prüfen. Dass das Pack unter fremdem Präfix **vorliegt** und die Objekte der Range trägt, setzt sie voraus, ohne es zu fordern; ein leerer Objektspeicher erfüllt beide Zeilen. Der Satz „Erst beide zusammen machen das Pack … zum einzigen Weg" trägt diese Voraussetzung mit, prüfbar wird sie nicht. Folgenlos ist die Lücke, weil ein solcher Aufbau unter **beiden** Ständen laut abbricht statt still grün zu melden — anders als die Lage, gegen die Setzung 3 steht. Zuständig: Architect, als Won't-Fix vertretbar. | `LH-QA-01` (eine Bedingung reicht so weit wie das, was sie prüft) | `MR-067`, Feld `Setzung 2` | ja: ein Klon nach Schritt 2 erfüllt beide Zeilen und trägt keine Objekte | Prüf-Bedingung prüft nur Abwesenheit, nicht Anwesenheit ihres Gegenstands |

Kein HIGH, kein MEDIUM. Kein Rollen-Konflikt.

## Antworten auf die fünf Prüffragen

1. **Die Entscheidung trägt.** `MR-066` liegt auf `origin/main` und ist damit angenommen — die
   Korrektur im Eintrag selbst wäre der Weg, den §Adaptions-Block ausschließt; Kopf-Marke plus
   Folge-Eintrag ist der vorgesehene. Die Begründung „was ein Pin-Sprung liest, steht im
   Adaptions-Block" ist nachprüfbar: Der `Auflösungs-Trigger` von `MR-066` nennt als seine drei
   Anlaufstellen `MR-061`, `MR-063` und `MR-065` — alle drei im Block, keine im Planungsbaum.
   `AGENTS.md` §3.7 führt `docs/plan/planning/done/**` ausdrücklich als Zeitdokument; eine Lücke
   dort abzulegen hieße, sie an einen Ort zu legen, den der nächste Sprung nicht aufschlägt, und
   §3.11 spricht gegen die Adresse dorthin. Ein Slice-Plan des nächsten Sprungs existiert zudem
   noch nicht — die Lücke hätte bis dahin keinen Träger.
2. **Formgerecht.** Alle Pflichtfelder stehen (`Datum`, `Wirksamkeits-Anlass` blank nach `MR-028`,
   `Geltungsbereich`, `Ersetzt-Baseline-Regel` mit Fork-Verdikt im Feld nach `MR-039` Setzung 3,
   `Adaption`, `Begründung`, `Auflösungs-Trigger`), `Löst auf` und `Ausgelöst durch
   Baseline-Stand` paarweise. `MR-025`: jede Zahl steht neben ihrem Kommando, `2.43.0` und die
   Tabellenwerte sind als Nicht-Erwartungswerte deklariert. `MR-033`: die eine Baseline-Aussage
   nennt `v6.9.0` und ist nachgemessen. `MR-053`: die Werkzeug-Aussage nennt die git-Fassung als
   Mess-Operanden und führt keinen lebenden Pin. §3.7: kein Absatz erzählt die Entstehung, und —
   bemerkenswert, weil naheliegend — **keine** Befund-Kennung und kein Verweis auf den
   Verifikations-Report stehen im Eintrag. **Setzung 2 trägt**, beide Hälften eigenständig
   nachgemessen; die Einschränkung steht als H-2.
3. **Die Kopf-Marke ist richtig geschnitten.** Abgelöst ist der Aufbau-**Satz** „als Anleitung",
   wörtlich zitiert; die Fortgeltung nennt Messwerte, Gegenprobe und die Angabe daneben
   ausdrücklich. Form nach `MR-032` Setzung 1 (Blockquote direkt unter der Überschrift,
   `ÜBERHOLT: <Reichweite> → <Ziel>.` mit Fortgeltungssatz) und Setzung 3 (im selben Commit wie
   der ablösende Eintrag); die Ausnahme aus Setzung 4 greift nicht, weil kein Messwert abgelöst
   wird. `MR-066` ist die erste Marke an dieser Datei, keine ältere ist überschrieben; die Datei
   bleibt nach `MR-046` in `conventions/`.
4. **Die Abgrenzung schneidet sauber.** Gegen `MR-065` Setzung 1: Die Angabe ist eine Pflicht
   **nach** dem Lauf (was zu berichten ist), `MR-067` setzt die Bedingung **davor** (was
   herzustellen ist) — komplementär, nicht überlappend, und der Eintrag belegt die Differenz an
   Zeile 4 seiner Tabelle, wo die Angabe den Defekt erst hinterher ausgewiesen hätte. Gegen
   `MR-063`: Die Gegenmessung läuft über einer `git archive`-Kopie ohne `.git` und hat keinen
   Objektspeicher; sie hat damit kein Objekt für Setzung 2. Beide Ausschlüsse stehen im Feld
   `Geltungsbereich`, nicht nur im Rumpf.
5. **Neue Befunde:** H-1 (LOW) und H-2 (INFO), beide oben.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| V-1 der Verifikation | geprüft, ohne Rest: beide Halbsätze des Befunds sind im Eintrag aufgelöst — der übersprungene Schritt 2 (stiller `rc 0`), das fehlende `-f` und der fehlende `git prune-packed` stehen als Schritte **und** als Grund; eigene Reproduktion deckt alle drei |
| Index- und §Baseline-Zeile | geprüft, ohne Befund: eine Zeile in *Aktive Adaptionen* mit beiden Ankern (`mr-067` und Überschriften-Slug), Geltungsbereich und Fork-Verdikt als Feldanfang; die Kettenzeile in §Baseline ergänzt den Satz zur Aufbau-Anleitung, ohne eine der bestehenden Zuschreibungen zu verändern |
| `AGENTS.md` §3.8 | geprüft, ohne Befund: `825107e1` berührt ausschließlich `harness/conventions.md` und zwei Dateien unter `harness/conventions/`, und die Message nennt die Rolle |
| `AGENTS.md` §3.5 | geprüft, ohne Befund: der Commit schaltet nichts ab und senkt nichts; Setzung 1 ist eine **Verschärfung** und braucht darum kein ADR |
| `AGENTS.md` §3.11 | geprüft, ohne Befund: der Eintrag nennt Slices bei der Kennung, verweist auf ortsfeste Ablagen und auf keinen Report |
| `AGENTS.md` §3.6 (Zusage mit Gegenbeispiel) | geprüft, ohne Befund: der Eintrag behauptet keinen Wächter, sondern benennt ausdrücklich, dass keiner existiert und der herstellende Lauf der Träger ist |
| `LH-QA-03` | geprüft, ohne Befund: die Folge braucht nur `git` auf dem Host — auf dem Review-Host verifiziert |
| Abgrenzung zur Werkzeug-Wirkung | geprüft, ohne Befund: der Eintrag misst die Wirkung auf d-check ausdrücklich **nicht** und lässt sie in `MR-066` Messung 1 — die Trennung Lage/Wirkung ist konsequent durchgehalten |
| Restliche Artefakte des Slice | nicht berührt: `d-check.mk`, `internal/emit/`, `.d-check.yml`, `harness/tools/` und `harness/sensors/` stehen im Commit nicht |

## Summary

**0 HIGH · 0 MEDIUM · 1 LOW · 1 INFO.** V-1 ist ohne Rest aufgelöst, und zwar auf dem Weg, den
der append-only-Block vorsieht. Die Folge in `MR-067` ist an einer **zweiten, unabhängigen
Stelle** reproduziert, einschließlich der zwei stillen Fehlschläge, um derentwillen der Eintrag
existiert. Wiederkehrende Klasse für die Closure §7: keine neue; H-1 ist die dritte Berührung der
Frage *gilt eine neue Setzung rückwirkend?* nach `MR-039`/`MR-060` — ob die Closure dafür einen
Register-Eintrag zitiert oder anlegt, entscheidet sie.

## Verdikt

**Push frei.** Kein Befund dieser Runde hält den Commit auf: H-1 betrifft die Reichweite einer
Setzung und ist im nächsten Architect-Lauf oder im Folge-Eintrag zu klären, H-2 ist
Won't-Fix-fähig. Der Eintrag friert mit einer Anleitung ein, die trägt — das war der Zweck.

**Closure:** unverändert offen; sie setzt die Verifikation gegen die DoD voraus und liegt beim
Planner (`AGENTS.md` §3.10).
