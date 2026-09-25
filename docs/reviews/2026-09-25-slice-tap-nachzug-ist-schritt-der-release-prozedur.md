# Review-Report: slice-tap-nachzug-ist-schritt-der-release-prozedur — 2026-09-25

**Review-Art:** Doku-Diff gegen Plan, ADR und Hard Rules (Modul 10). Nicht gegen die DoD (das ist der Verifier).

**Gegenstand:** `git diff 57287b64..HEAD` (HEAD `8441a755`, Baum sauber) — vier Commits: `b8357d3f` (`make slice-mv`,
reiner Move `next/` → `in-progress/`), `42eefe53` (`make slice-mv`, ein Verweis nachgezogen), `dce20611` (Rolle Implementer:
Ruhe-Marker der Roadmap entfernt, drei Zeilen), `8441a755` (Rolle Implementer: `docs/user/releasing.md`, +58/−6). Der
Produktiv-Diff ist allein `docs/user/releasing.md`: Schritt 7 neu, Schritt 8 (Meldung) übernimmt den alten Schritt 7, die
Nennung in Schritt 5 wird `(Schritt 8)`.

**Plan-Bezug:** Slice `slice-tap-nachzug-ist-schritt-der-release-prozedur` (Ziel, §1 Abgrenzung, §3 Umsetzung, §6) —
Kennung, nicht Pfad: der Plan wandert mit dem Lifecycle (`AGENTS.md` §3.11). **Constraint:** `ADR-0064` (`Accepted`,
Festlegungen 1 bis 3 und 6, Folgepflicht 3), `ADR-0066` (`Accepted`, Festlegung 1), `LH-QA-02`, `AGENTS.md` §3.6, §3.7,
§3.10, §3.11, Setzung des Auftraggebers *„die Nutzerdoku trägt nur den Ist-Zustand"*.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-25

**Eingangs-Kontext:** Diff · Slice-Plan · `ADR-0064` · `ADR-0066` · `LH-QA-02` · `AGENTS.md` §3 · die Skripte
`harness/tools/tap-nachzug.sh` und `harness/tools/tap-nachzug-nutzlast.sh` · Makefile-Ziel `tap-check` ·
`harness/README.md` (Zeile `make tap-check`) · `test/tap-nachzug.bats` · Handbuch Weg C. Der Implementer-Bericht war
Behauptung; Text, Code und Läufe sind selbst gelesen und gefahren.

**Eigene Sensor-Läufe dieses Laufs** (lesend; kein Schreibzugriff auf das Tap, kein Nachzug, kein `make mutate`, keine
Host-Toolchain):

| Aufruf | Ergebnis |
|---|---|
| `make tap-check TAG=v0.2.4` | Exit 0, Zeile `tap-check: gleich — Tag v0.2.4, Tap-Kopf Formula/ai-harness-init.rb, sha256 ccc0a3db…536c`, 1,2 s (kein Warten) |
| `make tap-check TAG=v0.2.3` (Rot-Beleg, Tap-Kopf `0.2.4`) | 1 m 6,4 s; Zeile `tap-check: Formel-Unterschied — Tag v0.2.3, Asset sha256 a5a1c165…a1f2, Tap-Kopf sha256 ccc0a3db…536c; erste abweichende Zeile (zweites Lesen) Zeile 11: Asset [  version "0.2.3"] \| Tap [  version "0.2.4"]`, danach `tap-check: Exit 1` (genau einmal), danach `make: *** [Makefile:493: tap-check] Fehler 1`; Prozess-Exit von `make` **2** |
| `make tap-check TAG=v0.3.0-rc.1` und `TAG=v1.0.0-rc.1+x` | Exit 0, `tap-check: Vorab-Tag, Tap bleibt (…)`, ohne docker-Aufruf |
| `make tap-check TAG=v1.0.0+build-1` | Exit 2, `Asset nicht auffindbar … (HTTP 404)` — **kein** Vorab-Tag (Metadatum wird zuerst abgeschnitten) |
| `make tap-check TAG=v0.2` und ohne `TAG` | Exit 2, `Tag-Form falsch` bzw. `die Umgebungsvariable TAG ist nicht gesetzt`, je `tap-check: Exit 2` |
| `DOCKER_HOST=tcp://127.0.0.1:1 make tap-check TAG=v0.2.4` | Exit 2, `der Transport im Bild endete ohne Ergebnis der Nutzlast (docker Exit 1) …`, `tap-check: Exit 2` |
| `grep -nE '^[a-z-]*tap[a-z-]*:' Makefile` | genau eine Zeile: `492:tap-check:`; kein Bezug von `tap-check` in `gates`/`record-gates` (`grep -n 'tap-check' Makefile` → `.PHONY`, Rezept, Kommentar) |
| `grep -nE '^  [a-z0-9-]+:$' .github/workflows/release.yml` | `artifacts`, `start-smoke`, `publish` — kein Job schreibt ins Tap |
| `gh release list --json tagName,isPrerelease` | sieben Releases `v0.1.0` … `v0.2.4`, alle `isPrerelease: false` |

---

## Findings

Kein HIGH, kein MEDIUM.

### LOW

**R1-1** — `kategorie`: LOW · `quelle`: `ADR-0064` Festlegung 2 (Klasse 2 „nicht ausführbar") · `pfad`:
`docs/user/releasing.md:124` · `befund`: Die Aufzählung der Klasse 2 lautet *„Aufruf, Tag-Form, Asset oder Tap nicht
lesbar"* und liest sich als abschließend. Die Ursache, die ein Mensch am wahrscheinlichsten trifft — der Docker-Daemon ist
nicht erreichbar (`docker Exit 1`, Meldung *„der Transport im Bild endete ohne Ergebnis der Nutzlast"*) — endet ebenfalls
mit Exit 2 und steht nicht da; ebenso Feldform, Pin und der Modus `sync`. · `verifizierbar`: ja — `DOCKER_HOST=tcp://127.0.0.1:1
make tap-check TAG=v0.2.4` → Exit 2, Zeile `tap-check: Exit 2` (oben). Kein Gate hält die Aufzählung gegen das Skript. ·
`klasse`: *Aufzählung einer Fehlerklasse in der Doku nennt die wahrscheinlichste Ursache nicht und liest sich als
abschließend*

**R1-2** — `kategorie`: LOW · `quelle`: `ADR-0064` Festlegung 3 c (Vorab-Regel, Metadatum zuerst abgeschnitten) · `pfad`:
`docs/user/releasing.md:109` (und `:120`) · `befund`: *„Vorab-Tag (SemVer-Präfix `-`)"* ist die Kurzform der Regel des Skripts
(`case "${tag%%+*}" in *-*)`). Ein Tag mit Bindestrich nur im Build-Metadatum (`v1.0.0+build-1`) ist stabil und braucht den
Nachzug; wer die Kurzform wörtlich liest, lässt ihn aus, und `tap-check` sagt dann `Asset nicht auffindbar`/Exit 2 statt
`Vorab-Tag`. Die Tag-Form des Skripts lässt `+<Build>` ausdrücklich zu. · `verifizierbar`: ja — `make tap-check
TAG='v1.0.0+build-1'` → Exit 2 (nicht Vorab); der bats-Fall *„die Regel des Skripts entscheidet dieselben Tags wie die
Regel des publish-Jobs"* führt `v1.0.0+build-1` als stabil, bindet aber die Doku nicht. · `klasse`: *Kurzform einer
Regel in der Prozedur weicht in einer zugelassenen Eingabe-Form von der Regel des Werkzeugs ab*

**R1-3** — `kategorie`: LOW · `quelle`: Setzung *„Ist-Zustand"* · `AGENTS.md` §3.7 (Zustandsform; MR-025-Nähe) · `pfad`:
`docs/user/releasing.md:96-98` und `:141-143` · `befund`: Vier Aussagen sind wahr, solange das Werkzeug nur `check` führt:
*„der Release-Workflow … schreibt sie nicht ins Tap"*, *„der Nachzug ist Handarbeit"*, *„ein Ziel dafür besteht nicht"*
und *„den Vorwärts-Schutz hält sie nicht"*. Sie beschreiben den Ist-Zustand (keine Prognose, kein Konjunktiv, kein „noch
nicht"), altern aber mit dem Schnitt für `sync` und dem Job `tap`; kein Sensor liest die Prosa gegen das Makefile oder den
Workflow. Nur die dritte Aussage trägt ihr Kommando daneben (Ausgabe gemessen: allein `tap-check`); die erste und zweite
tragen keines (`grep -nE '^  [a-z0-9-]+:$' .github/workflows/release.yml` → `artifacts`, `start-smoke`, `publish`). Der
Träger des Nachzugs beim Schnitt ist der Slice für `sync`, dessen Kennung noch nicht vergeben ist (Plan §1). ·
`verifizierbar`: nein (nur durch das Kommando von Hand). · `klasse`: *Prozedur-Aussage über die Abwesenheit eines
Werkzeugs altert ohne Träger*

**R1-4** — `kategorie`: LOW · `quelle`: Maintainability (Verständlichkeit, Prüfpunkt 6 des Auftrags) · `pfad`:
`docs/user/releasing.md:101-110` · `befund`: Handlung und Vorbedingung nennen weder, wie der Tap-Stand gelesen wird (die
`version`-Zeile steht in der Datei, die der Schritt ersetzt), noch dass vor dem Commit eine aktuelle Arbeitskopie des Tap
vorliegen muss. Der Vorwärts-Schutz ist die einzige Sicherung der Handarbeit (*„der Satz trägt ihn"*); ein Mensch mit
Push-Recht setzt ihn nur um, wenn er die Zeile am Tap-Kopf aufschlägt, bevor er die Datei überschreibt. Commit-Message
(nennt den Tag), Datei-Pfad `Formula/ai-harness-init.rb`, Repo und Default-Branch stehen da — das genügt für die Handlung;
die Vorbedingung ist ohne diese Angabe eine Lese-Aufgabe ohne Ort. · `verifizierbar`: nein · `klasse`: *einzige Sicherung
einer Handarbeit nennt den Ort ihrer Prüfung nicht*

**R1-5** — `kategorie`: LOW · `quelle`: Maintainability / Stand-Form (`AGENTS.md` §3.7, Zustandsfelder) · `pfad`:
`docs/user/releasing.md:147-149` · `befund`: Die Klammer *„(Tag, Asset-Menge, Prüfsummen, Läufe, die Zeile von
`tap-check`)"* gilt für *„die Meldung — und der Release-Text aus Schritt 5 samt jeder Ergänzung"*. Der Release-Text wird in
Schritt 5 gesetzt; die Zeile von `tap-check` entsteht erst in Schritt 7. Ob der Release-Text sie nach Schritt 7 nachtragen
muss oder nur die Meldung, sagt der Satz nicht; beide Lesarten sind mit dem Wortlaut vereinbar. Derselbe Absatz führt
außerdem zwei Sätze *„Die Meldung geht erst, wenn …"* (`:145` und `:150`) neben dem Satz aus Schritt 6. · `verifizierbar`:
nein · `klasse`: *Stand-Form-Klammer erfasst zwei Artefakte mit verschiedenem Entstehungs-Zeitpunkt*

### INFO

**R1-6** — `quelle`: Setzung *„Ist-Zustand"* · `pfad`: `docs/user/benutzerhandbuch.md:155` (Weg C, nicht im Diff) ·
Der Satz *„sie wird je Release-Schnitt aus dem Formel-Asset desselben Schnitts nachgezogen"* stimmt am Ist-Zustand: alle
sieben veröffentlichten Releases sind stabil (`gh release list --json tagName,isPrerelease`), und Schritt 7 nimmt nur
Vorab-Tags aus, die es nicht gibt. Nachzuziehen ist er erst mit dem ersten veröffentlichten Vorab-Tag; das Handbuch-Update
gehört zum Release-Schnitt (Plan §1). Verweis: Planner/Auftraggeber; kein Merge-Punkt.

**R1-7** — `quelle`: `ADR-0064` Festlegung 6 · `pfad`: `docs/user/releasing.md:95-152` · `ADR-0064` Folgepflicht 3 sieht
im Schritt außerdem das *„Nachzug-Ergebnis des Jobs"* und den lokalen Ausfallweg vor; beide setzen Modus `sync` und den Job
`tap` voraus, die nicht bestehen. Der Plan schließt sie in §1 ausdrücklich aus (Folge-Schnitt); der Schritt beschreibt allein
die bestehende Handarbeit samt Kontrolle. Keine Abweichung, benannt, damit der Folge-Schnitt den Schritt umbaut.

---

## Prüfung der einzelnen Aussagen (Auftrag 1)

| Aussage in Schritt 7/8 | Gegen | Ergebnis |
|---|---|---|
| Exit 0 gleich: Wort `gleich`, Tag, Digest | Nutzlast `printf 'tap-%s: gleich — Tag %s, Tap-Kopf …, sha256 %s'`; Lauf `v0.2.4` | stimmt |
| Exit 0 Vorab: `Vorab-Tag, Tap bleibt` | `tap-nachzug.sh` Schritt c; Läufe `v0.3.0-rc.1`, `v1.0.0-rc.1+x` | stimmt (Kurzform siehe R1-2) |
| Exit 1: beide Digests, erste abweichende Zeile, nach zweitem Lesen | Nutzlast `erste_abweichung`; Lauf `v0.2.3` | stimmt |
| Exit 2: Aufruf, Tag-Form, Asset, Tap nicht lesbar | Läufe `v0.2`, ohne `TAG`, Nutzlast `hole_asset`/`lese_tap` | stimmt, unvollständig (R1-1) |
| `make` endet jeder Fehlschlag mit Exit 2 | Lauf `v0.2.3`: `Fehler 1`, Prozess-Exit 2 | stimmt |
| Zeile `tap-check: Exit <N>` genau einmal bei 1 und 2, fehlt bei 0 | `beende()`; drei Läufe oben | stimmt |
| 65 s Wartezeit, einmal, nur bei Ungleichheit | `TAP_WAIT="${TAP_WAIT:-65}"`, `vergleiche()`; Lauf `v0.2.3` 66,4 s; Lauf `v0.2.4` 1,2 s; bats *„die Wartezeit ohne Vorgabe sind 65 Sekunden"* | stimmt |
| Schnittstelle liefert einen bis zu 60 s alten Stand | `ADR-0064` Festlegung 2 (Fenster 60 s + 5 s) | stimmt (Zitat der ADR, hier nicht messbar) |
| liest nur, schreibt nichts, Netz, keine Gate-Kette | Skript (nur `curl` GET), Makefile (`tap-check` nicht in `gates`) | stimmt |
| Vorwärts-Schutz: der Vergleich liest keine `version`-Zeile | `grep -n version` über beide Skripte, nur Kommentare; bats-Fall *„version-zeile: in check kein Gegenstand — gleiche Bytes mit einer version-Zeile ausserhalb der Feldform enden mit Exit 0"* (:251) | stimmt |
| Nach dem Nachzug eines älteren Tags endet die Kontrolle gegen genau diesen Tag mit Exit 0 | `cmp` Asset gegen Tap-Kopf, Ergebnis 0 bei gleichen Bytes; kein Vergleich von Tag und Tap-Stand | stimmt aus dem Code, **nicht über das Ziel hinaus**: bei gleichen Bytes trägt der Tap-Kopf ohnehin die `version`-Zeile des Asset, der Vorwärts-Schutz gehört nach `ADR-0064` Festlegung 3 d und *„Die `version`-Zeile ist nur in `sync` Gegenstand"* allein zu `sync` |
| Vorbedingung Kern `major.minor.patch`, numerisch je Feld, gleich oder größer geht durch | `ADR-0064` Festlegung 3 d | stimmt (Maßstab der ADR; im Skript nicht implementiert, und der Text sagt das: *„Ein Nachzug von Hand hat diesen Schutz nicht"*) |
| Schritt 8 hängt an `tap-check` Exit 0 und trägt die Ausgabezeile | Plan Liefer-Punkt 1 · `ADR-0064` Festlegung 6 | stimmt (R1-5 zur Klammer) |

**Rot-Beleg (`AGENTS.md` §3.6) für die zitierten Wortlaute:** der Lauf gegen einen Tag, dessen Formel nicht die des Tap
ist (`v0.2.3`, Tap-Kopf `0.2.4`), endet mit der Meldung des Unterschieds, der Zeile `tap-check: Exit 1` und Prozess-Exit 2;
der Lauf gegen den Tag des Tap-Standes (`v0.2.4`) endet mit Exit 0 (oben). Gelesen ist die Ausgabe, nicht der Exit-Code.
**Deckung, benannt:** kein Test und kein Gate hält `docs/user/releasing.md` gegen die Ausgabe des Skripts; ein geänderter
Wortlaut lässt die Prozedur grün und falsch. Träger ist dieser Review (Plan Liefer-Punkt 2). Die Prozedur zitiert das Wort
`gleich` und die Klasse, nicht die Digest-Zeile als Vertrag — das entspricht dem, was der bats-Fall bindet
(`*"gleich"*`).

## Nummerierung (Auftrag 3)

Gemessen mit `grep -nE 'Schritte? [0-9]' docs/user/releasing.md` gegen die Überschriften 1 bis 8:

| Fundort | Nennung | Meint | Stimmt |
|---|---|---|---|
| `releasing.md:42` | `(Schritt 1)` | Tag in der Vorlage | ja |
| `releasing.md:80` | `(Schritt 8)` (vorher `(Schritt 7)`) | Stand-Form der Meldung | ja — die Nennung war die einzige, die der Einschub verschob |
| `releasing.md:87` | `Schritt 3` | `verify`-Modus | ja |
| `releasing.md:146` | `(Schritt 7)` | `tap-check` | ja |
| `releasing.md:148` | `Schritt 5` | Release-Text | ja |
| `releasing.md:161` | `Schritte 4 und 6` | Gates am Tag-Baum, CI am Tag | ja (beide unverändert) |
| `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/state.md` (Zustandsfeld) | `Schritt 6` | CI am Tag | ja |
| `BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor/observation.md` (eingefroren) | `Schritte 4 und 6` | dieselben zwei | stimmt weiter; nicht angefasst |
| ältere Zeitdokumente (`docs/reviews/2026-09-19-…-verifikation.md`: *„Schritte 1–7"*; erledigter Slice: *„sieben Schritte"*) | sieben Schritte | Stand des Tages | Chronik, nicht zu ändern |
| `[…]releasing.md#`-Anker | — | — | keiner in lebenden Artefakten |

Weitere Nennungen im Repo (`grep -rnI` über `docs harness .claude spec README.md`, ohne `docs/reviews`, `done/`, Baseline):
`.claude/commands/plan-welle.md` (*„Schritt 7/8/9"*) und `AGENTS.md`-Bezüge meinen andere Prozeduren. Es besteht keine
Nennung einer `releasing.md`-Schritt-Nummer, die durch den Einschub falsch würde; die Gegenprobe des Plans (Nennung in
Schritt 5 unverändert lassen → sie zeigte auf den Nachzug statt auf die Meldung) ist am Diff ablesbar: die Nennung ist auf
`(Schritt 8)` gezogen.

## Handbuch Weg C (Auftrag 7)

Siehe R1-6: stimmt am Ist-Zustand, kein Nachzug im Diff nötig.

---

## Geprüft, ohne Befund

| Bereich | Ergebnis |
|---|---|
| HIGH — Verstoß gegen aktive ADR/Hard Rule: `ADR-0064` Festlegungen 1, 2, 3 c, 3 d, 6 · `ADR-0066` Festlegung 1 (Klasse des **Skripts**, `make` = Prozess-Exit 2, Zeile `tap-check: Exit <N>`, gelesen wird die Zeile) · `AGENTS.md` §3.1 (jedes genannte Ziel besteht: `make tap-check`; der Text behauptet kein Ziel für den Nachzug), §3.3 (Move-Commit rein, Inhalt getrennt), §3.4 (keine ADR berührt), §3.5, §3.8 (keine Hard-Rule-/MR-Änderung), §3.9 (Docker-only: der Text fährt nur `make`/`gh`/`git` als Handlung eines Menschen; die Verifikation lief über `make`) | geprüft, ohne Befund |
| HIGH — Gate-Lockerung ohne ADR; Stilles-Grün-Pfad; halluziniertes Gate: `harness/README.md` führt `make tap-check` mit Klassen und Bindung; Makefile-Ziel besteht; Prosa und README-Zeile nennen dieselben Klassen; `docs-check`-Anker `benutzerhandbuch.md#weg-c--über-ein-homebrew-tap-macos-linux` löst auf (Stempel gedeckt) | geprüft, ohne Befund |
| HIGH — superseded ADR: `ADR-0064` und `ADR-0066` stehen im Index auf `Accepted`; der Text zitiert `ADR-0064` Festlegung 3 d als Maßstab und `ADR-0066` Festlegung 1 für die Ebene; keine superseded ADR wird zitiert | geprüft, ohne Befund |
| HIGH — Norm nur im Template-Kommentar: kein Template berührt | geprüft, ohne Befund |
| HIGH — Kommentar trägt keine Klasse: kein Code-, Konfigurations- oder Skript-Kommentar im Diff | geprüft, ohne Befund |
| HIGH — Zustandsfeld trägt Chronik: der Diff enthält keine `Stand`-/`Status`-Zelle; die Roadmap verliert allein den Ruhe-Marker (`dce20611`), der bei beanspruchtem `in-progress/` nach `modul-06-roadmap.md` §Roadmap-Struktur entfällt; der Marker steht nicht mehr, die Liste der offenen Wellen ist unberührt | geprüft, ohne Befund |
| `AGENTS.md` §3.7 / Setzung im Prozedur-Text (`docs/user/releasing.md:95-152`): kein Konjunktiv über verworfene Fassungen, kein „früher"/„noch nicht"/„künftig", keine Chronik, keine Prognose; `grep -niE 'würde|wäre|hätte|könnte|noch nicht|früher|künftig|bald'` über die Zeilen 95–152 → kein Treffer; der Satz *„Ein Nachzug von Hand hat diesen Schutz nicht; der Satz trägt ihn"* ist Indikativ über den Zustand. Nichts Unimplementiertes wird als vorhanden beschrieben; der Job `tap`, der Modus `sync` und das Secret erscheinen nicht (R1-3 zur Alterung der Abwesenheits-Sätze) | geprüft, ohne Befund |
| `AGENTS.md` §3.10 (Rollen): der Schritt nennt keine Rolle als Ausführende und keinen Pfad eines Nachbar-Klons (`grep -nE 'homebrew-ai-harness-init\|\.\./\|Rolle\|Architect\|Planner\|Implementer\|Reviewer'` über 95–152 → allein der Repo-Name `pt9912/homebrew-ai-harness-init` als Ziel); der Plan (§7, DoD-Häkchen, Closure) ist im Diff nicht berührt; die zwei `make slice-mv`-Commits sind reine Verweis-/Move-Commits, der Implementer-Commit berührt nur `releasing.md`/Roadmap-Marker | geprüft, ohne Befund |
| `AGENTS.md` §3.11 (Adressen): der Text nennt bewegliche Artefakte (Slice, Welle) nicht als Pfad; Pfade auf `docs/plan/adr/…`, `benutzerhandbuch.md` sind ortsfest; dieser Report nennt den Slice bei der Kennung; Move-Entscheidung des Plans (§4) vor dem `git mv`: `grep`-Beleg der Kennung nur als Text in zwei eingefrorenen Dateien, `42eefe53` zog den einen verbliebenen Verweis nach | geprüft, ohne Befund |
| MR-025 (Zahl neben Kommando): die einzigen Zahlen im Text sind `65` (`TAP_WAIT`-Vorgabe im Skript, bats-Fall bindet sie), `60` (Zitat der ADR), `8` (Asset-Menge, Kommando daneben, Bestand) — kein neuer Erwartungswert ohne Kommando | geprüft, ohne Befund |
| §3.6 Zusagen: *„läuft in keiner Gate-Kette"* — Gegenprobe `grep -n 'tap-check' Makefile`; *„Vergleich liest keine `version`-Zeile"* — bats-Fall :251 färbt sich rot, sobald `check` eine Feldform-Prüfung der `version`-Zeile bekäme (Fixture trägt `0.08.3`, außerhalb der Feldform); *„wartet nicht bei Gleichheit"* — bats-Fall *„sofort gleich liest einmal und wartet nicht"* (`STUB_LOG_SLEEP` leer) und Lauf 1,2 s | geprüft, ohne Befund |
| Reproduzierbarkeit (`LH-QA-02`): Quelle ist das veröffentlichte Asset desselben Tags, keine lokal gefüllte Kopie; die Kontrolle liest im gepinnten Bild | geprüft, ohne Befund |
| Rollen-/Eigentumsfrage: der Schritt setzt *„Push-Recht auf das Tap und Netz"* voraus und beantwortet die offene Frage des Plans (§6 Frage 1) nicht | geprüft, ohne Befund |

**Nicht gefahren:** `make mutate` (verboten; keine Zähne im Diff), ein Nachzug oder ein Schreibzugriff auf das Tap,
`make tap-check` gegen `v0.2.2` (der Rot-Beleg an `v0.2.3` trägt dieselbe Klasse), der Test-Lauf der bats-Datei (Diff
berührt sie nicht). `make gates` und `make record-gates` — siehe Ende.

---

**Summary:** 0 HIGH · 0 MEDIUM · 5 LOW · 2 INFO

**Finding-Klassen dieses Laufs:** Aufzählung einer Fehlerklasse in der Doku nennt die wahrscheinlichste Ursache nicht und
liest sich als abschließend · Kurzform einer Regel in der Prozedur weicht in einer zugelassenen Eingabe-Form von der Regel
des Werkzeugs ab · Prozedur-Aussage über die Abwesenheit eines Werkzeugs altert ohne Träger · einzige Sicherung einer
Handarbeit nennt den Ort ihrer Prüfung nicht · Stand-Form-Klammer erfasst zwei Artefakte mit verschiedenem
Entstehungs-Zeitpunkt

## Verdikt

**Kein Merge-Blocker.** Kein HIGH, kein MEDIUM: jede zitierte Klasse, jeder Wortlaut und die 65 s stimmen mit Skript,
Nutzlast und Makefile überein; die Vorwärts-Schutz-Aussage der Grenze trägt aus dem Code und geht nicht über `check`
hinaus; die Nummerierung ist in allen lebenden Nennungen richtig (ein Anker auf eine Schritt-Zeile besteht nirgends); der
Text nennt weder Rolle noch Klon-Pfad und hält die Setzung *Ist-Zustand*. Die fünf LOW sind vor dem Merge mitzunehmen, wenn
der Implementer sie für berechtigt hält (R1-1, R1-2 und R1-5 sind Wortlaut-Korrekturen im Schritt); sie blockieren nicht.

**Übergabe:**

- **R1-1 bis R1-5 → Implementer** (Wortlaut in `docs/user/releasing.md`; Korrekturen dort, nicht in diesem Lauf).
- **R1-3 → Planner** zusätzlich: der Slice für `sync` (Kennung offen) trägt den Umbau von Schritt 7 — der Plan nennt ihn
  als Folge-Schnitt; ob sein DoD-Punkt die Abwesenheits-Sätze ausdrücklich nennt, ist Planner-Entscheidung.
- **R1-6 → Planner/Auftraggeber** (Handbuch Weg C erst mit dem ersten Vorab-Tag).
- Die **Finding-Klassen** gehen in die Slice-Closure §7 und von dort in den Zähler. Dieser Report ist ein Lauf-Beleg und
  ersetzt keine Verifikation: DoD-Konformität und die Closure-Schritte prüft der Verifier bzw. schreibt der Planner
  (`AGENTS.md` §3.10).
