# Review-Report: `slice-das-ziel-sagt-was-sein-vendored-baum-ist` — 2026-09-18

**Review-Art:** Code — geprüft gegen Slice-Plan, aktive ADRs und die Hard Rules
(`v6.9.0` · `regelwerk/modul-10-review-harness.md` §Drei Review-Arten). **Keine**
DoD-Abhakung: die prüft der Verifier (`v6.9.0` · `regelwerk/modul-11-verification.md`).

**Gegenstand:** Runde 1 über `git diff fd494fe7..872170f4` — die drei Implementer-Commits
`6db58a73`, `15cd2a82`, `872170f4`.

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5 · **Datum:** 2026-09-18

> **Zitier-Form.** Dieser Report friert ein; was er zitiert, bewegt sich weiter. Deshalb
> Kennung statt Adresse (`slice-<Kennung>` statt Lifecycle-Pfad, `make <target>` statt
> Link auf die Sensor-Datei), und eine Baseline-Stelle als Tag + Pfad in Inline-Code
> statt als Link. Die `pfad`-Felder zitieren den geprüften Stand und halten ihn fest.

**Eingangs-Kontext:**

- der Slice-Plan `slice-das-ziel-sagt-was-sein-vendored-baum-ist`, §1 bis §8, im Stand
  unter `in-progress/`;
- die aktiven ADRs aus dem Plan-Kopf: `ADR-0020` (Accepted), `ADR-0022` (Accepted); dazu
  `ADR-0054` (Accepted) für die skip-if-present-Klasse und `ADR-0037` für die
  Neutralisierungen im selben Emit-Pfad;
- die berührten IDs: `LH-FA-09`, `LH-FA-06`, `LH-QA-01`, `LH-QA-03`; `MR-007`, `MR-025`,
  `MR-033`;
- `AGENTS.md` §3.1, §3.6, §3.7, §3.9;
- vorherige Findings am selben Modul: die Reports vom 2026-09-13 und 2026-09-17 unter
  `docs/reviews/` (Emit-Pfad und `slice-mv`), deren wiederkehrende Klassen *Zusage reicht
  weiter als ihr Prüfumfang* und *Zahl ohne Kommando* sind — beide unten wieder getroffen.

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Der neue Kommentarblock ist ohne Leerzeile an den vorhandenen Block angesetzt: Die 20 Zeilen *„DIE ROLLEN-TYPEN LIEGEN IM ZIEL …"* stehen jetzt unmittelbar über `baum_aussagen_im_ziel()` und beschreiben `.claude/agents/`, sechs Rollen-Namen und die Quelle `internal/emit/templates/agents/*.md`; `rollen_typen_im_ziel()` folgt ab Zeile 238 ohne jeden Kommentar. Wer die Baum-Aussage ändert, liest einen Vertrag über Rollen-Typen, und wer die Rollen-Typen ändert, findet keinen. | `AGENTS.md` §3.7 (ein Kommentar beschreibt, was da ist) | `harness/tools/full-smoke.sh:141-160` (Block) gegen `:179` und `:238` (die zwei Funktionen) | nein — kein Modul des Doku-Gates und keine `make mutate`-Fehlschlag-Form liest Kommentar-Zugehörigkeit | Kommentarblock dokumentiert die nachbarstehende Funktion |
| F-2 | HIGH | Der emittierte Satz sagt über den mitgelieferten Baum: *„… und von **beiden** Doku-Gates ausgenommen."* Das Ziel bekommt genau **ein** Doku-Gate — `.d-check.yml` (geschrieben in `internal/emit/emit.go:183`) mit `scan.ignore: [… ".harness/**"]`. `.a-check.yml` ist ein Architektur-Gate, modul-gebunden und nur für schichten-tragende Layouts; ein flaches Ziel bekommt keines. Der Adopter liest eine Gate-Landschaft, die sein Repo nicht führt. | `LH-QA-01` (nichts behaupten, was nicht läuft) · `AGENTS.md` §3.1 | `internal/emit/baumaussage.go:202` | nein — die Marker-Prüfung in `full-smoke` misst Anwesenheit der Überschriften und `make`-Namen, keine Gate-Anzahl | Emittierte Aussage nennt eine Gate-Anzahl, die das Ziel nicht führt |
| F-3 | MEDIUM | Die Zelle zu `modul-15-observability.md §Erfassung und Token-Attribution` trägt *Träger kommt mit* und nennt `.claude/hooks/span-emit.sh`. Dieser Pfad steht in `captureFiles()`, das laut eigenem Kommentar „bewusst NICHT in `enforceFiles()`/`EnforcePaths()`" liegt: „jene Menge entsteht unbedingt, diese nur im Gelingens-Zweig". Scheitert die Träger-Ablage, schreibt `Enforce` keinen der drei Teile, gibt **keinen** Fehler zurück, und der Bootstrap endet erfolgreich — mit einer conventions.md, die den Wrapper behauptet. Die Gegenrichtung (behauptete Abwesenheit) ist getestet, diese nicht. | `ADR-0022` Festlegung 5 · `LH-QA-01` · Plan §1 (*„für einen Träger, der beschlossen und nicht abgelegt ist, wäre geht mit die Falschaussage"*) | `internal/emit/baumaussage.go:111-112` gegen `internal/emit/enforce.go:169-181` | ja — ein Go-Test über dem Fehlerzweig von `Enforce` würde die Differenz zeigen; heute prüft ihn keiner | Zellwert behauptet Anwesenheit eines bedingt emittierten Trägers |
| F-4 | MEDIUM | Der Freshness-Absatz verlangt ausdrücklich die **Release-Liste** und nicht das Asset und verweist für ihre Adresse auf den Abschnitt *Adoptierte Konventions-Quellen* darüber. Dieser Abschnitt trägt im emittierten Stand die Asset-URL **eines** Tags (`…/releases/download/v6.9.0/lab-regelwerk.zip`) und die Zeile `- **Extern (Lehrmaterial):** <Pfad oder URL>` — also genau das, was der Satz eine Zeile vorher als unzureichend bezeichnet, und einen unausgefüllten Platzhalter. | `LH-QA-01` · Plan §1 (der Audit als geschuldete Handlung braucht seine Quelle) | `internal/emit/baumaussage.go:213-217` gegen `v6.9.0` · `templates/harness/conventions.template.md` §Adoptierte Konventions-Quellen | ja — Lesen der emittierten `harness/conventions.md` in einem Sonden-Repo; kein Gate deckt es | Zeiger auf eine Adresse, die am genannten Ort nicht steht |
| F-5 | MEDIUM | Die Inventur ist eine Namensliste über den `regelwerk/`-Dateien und wird in ein **skip-if-present**-Dokument geschrieben (`harness/conventions.md`, Adopter-Boden), während der beschriebene Baum **konvergent** ist: `fetch.Baseline` ersetzt `<tag>/` bei jedem Lauf. Ein zweiter Bootstrap mit neuerem Pin tauscht den Baum und lässt die Tabelle stehen; der Block nennt auch nicht den Tag, gegen den er gemessen ist. Im Ziel kann das kein Lauf heilen und kein Sensor melden — die `full-smoke`-Prüfung läuft nur über frisch gebootstrappte Ziele. | `MR-033` (eine Aussage über die Baseline nennt ihren Mess-Tag) · `LH-QA-02` | `internal/emit/baumaussage.go:57-117` und `:223-227` gegen `internal/emit/templates.go:304-313` und `internal/fetch/baseline.go:124-129` | ja — zweiter Bootstrap mit geändertem `BASELINE_TAG` über demselben Ziel; keine Stufe fährt ihn heute | Eingefrorene Ableitung in einem skip-if-present-Dokument über konvergenter Quelle |
| F-6 | MEDIUM | Die reale Hälfte hängt an zwei Aufrufen derselben Funktion (`:363` und `:1784`); rot gesehen wurde laut Umsetzungs-Bericht nur der erste, weil `full-smoke` am ersten Fehler abbricht. Ein Aufruf mit falschem Ziel-Repo im zweiten Zweig liefe still grün — beide Ziele führen eine `harness/conventions.md`, und die Marker-Prüfung fände sie. Ein `# verify: full-smoke`-Fall, der genau diese Klasse listet, fehlt; der Modus ist im Repo etabliert (14 Fälle, darunter `332-zweiter-probe-aufruf-mit-falschem-ziel` für genau diese Klasse und `305-…-fullsmoke` für die Nachbarfunktion). | `AGENTS.md` §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel) | `harness/tools/full-smoke.sh:1784` | ja — `make mutate` mit einem `# verify: full-smoke`-Fall, der das zweite Argument vertauscht | Zweiter Varianten-Aufruf nie rot gesehen |
| F-7 | LOW | Die Plan-Tabelle §3 führt `test/baum-inventur.bats` und die erzeugte `docs/user/e2e-abdeckung.md` nicht, und die dort als *update* geführte Zeile `internal/emit/templates/` bleibt unberührt — der Block entsteht im Go-Code, nicht in der Vorlage. Wer §3 als Änderungsmenge liest, übersieht den Wächter, der die Nenner-Hälfte trägt. | Maintainability (Plan-Treue; §1-Abgrenzung bleibt gewahrt) | Slice-Plan §3 gegen `test/baum-inventur.bats` | nein | Plan-Tabelle führt die berührte Datei nicht |
| F-8 | INFO | `docs/user/e2e-abdeckung.md` ist regeneriert (nur verschobene Zeilennummern); die neue Prüfung bekommt keine Stufen-Zeile, ihre Bindungen `LH-FA-09`/`LH-QA-01`/`LH-QA-03` erscheinen dort also nicht. Das ist konsistent mit den zwei Nachbarfunktionen, bleibt aber eine undokumentierte Annahme über die Reichweite der erzeugten Sicht. | Maintainability | `docs/user/e2e-abdeckung.md` | nein | Erzeugte Abdeckungs-Sicht führt den neuen Zahn nicht |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Emittierter Datei-Satz (Plan §1, Ausschluss 3) | geprüft, ohne Befund — kein neuer Ziel-Pfad; `internal/emit/templates_test.go` ist allein um den Fixture-Anker `## Adaptions-Block` gewachsen, die Ziel-Pfad-Liste ist unverändert |
| Nenner-Deckung der Inventur | geprüft, ohne Befund — `diff <(ls .harness/baseline/*/regelwerk/*.md \| xargs -n1 basename \| sort) <(grep -oE '\{Modul: "[^"]+"' internal/emit/baumaussage.go \| sed 's/.*"\(.*\)"/\1/' \| sort -u)` ist leer; beide Richtungen hält `test/baum-inventur.bats` |
| skip-if-present-Urteil beim gepinnten Tag (Auftrags-Punkt 2) | geprüft, ohne Befund — das Urteil trägt: das emittierte `tools/harness/baseline-verify.sh` erzwingt genau ein `<tag>`-Verzeichnis und druckt `baseline-verify: <tag> OK — …`; eine eingetragene Ziffer wäre in einem nie überschriebenen Dokument die schlechtere Wahl |
| fail-closed im Emit (Auftrags-Punkt 6) | geprüft, ohne Befund — fehlender Anker und fremdes `make`-Ziel brechen beide, je mit eigenem Test; `NeutralizeMakeClaims` wird auf den fertigen Block angewandt und sein Ergebnis auf Gleichheit geprüft, nicht auf einen Platzhalter durchgereicht |
| `make`-Namen des Blocks gegen die init-invariante Menge | geprüft, ohne Befund — `help`, `gates`, `baseline-verify`, `docs-check`, `slice-mv`, `archive-welle`, `hooks-install` kommen alle aus `initFragments()` (Aggregator + `.mk`-Fragmente), und `full-smoke` prüft sie zusätzlich real per `make -n` im Ziel |
| Wächter-Verteilung und ihre Begründung (Auftrags-Punkt 3) | geprüft, ohne Befund — `.dockerignore:5` schließt `.harness` aus dem Build-Kontext aus, also sieht die `test`-Stage den Baum nicht; `test-bats` mountet `$(CURDIR)` read-only und fährt `bats test/`, der neue Fall läuft ohne Registrierung mit |
| Leerer Prüfbereich in der neuen `full-smoke`-Stufe | geprüft, ohne Befund — die `n -eq 0`-Schranke fängt den leeren Nenner, `grep -qxF` prüft die Marken zeilengenau, und die Block-Extraktion endet korrekt an der nächsten `## `-Überschrift (`### ` trifft das Muster nicht) |
| Abwesenheits-Zellen und ihre Adressen | geprüft, ohne Befund — beide (`tools/harness/`, `harness/mk/`) tragen einen gepinnten Bestand, und die Umkehrung (Pin ohne Zelle) fällt im selben Test |
| Die drei Mutationsfälle | geprüft, ohne Befund — `364`/`365` treffen die Go-Stufe, `366` die bats-Stufe; jeder `sed`-Operand trifft eine real vorhandene Zeile, und `366` löscht die zwei Zeilen eines vollständigen Eintrags |
| Gate-Lockerung | geprüft, ohne Befund — kein Modul abgeschaltet, keine Schwelle gesenkt, kein `scan.ignore`-Eintrag dazu; keine `//nolint`- oder `shellcheck disable`-Zeile im Diff |
| ADR-Bezüge | geprüft, ohne Befund — `ADR-0020`, `ADR-0022`, `ADR-0054` stehen auf `Accepted`; keine superseded ADR referenziert |
| §1-Abgrenzung (Auftrags-Punkt 8) | geprüft, ohne Befund — kein Freshness-Sensor emittiert, der vendored Baum unberührt, kein zusätzlicher Ziel-Pfad, kein automatischer Träger-Regel-Sensor, `doc-targets` im Ziel weiter nicht aktiviert (`modules:` der emittierten `.d-check.yml` führt `links, anchors, ids, matrix, spans`) |
| `MR-025` im neuen Text | geprüft, ohne Befund — keine eingefrorene Zahl; der Nenner wird zur Laufzeit gelesen (`ls .harness/baseline/*/regelwerk/*.md` im emittierten Text, `$n` in der Lauf-Meldung) |
| Übrige neue Kommentare (`AGENTS.md` §3.7) | geprüft, ohne Befund — außer F-1 kein Kommentar über einer verworfenen Alternative, keinem abwesenden Text und keinem Lauf-Protokoll; die Sensor-Nennung aus `872170f4` ist eine Zusage mit Sensor-Namen, keine Herkunft |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 2 |
| MEDIUM | 4 |
| LOW | 1 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Kommentarblock dokumentiert die nachbarstehende Funktion ·
Emittierte Aussage nennt eine Gate-Anzahl, die das Ziel nicht führt · Zellwert behauptet
Anwesenheit eines bedingt emittierten Trägers · Zeiger auf eine Adresse, die am genannten Ort
nicht steht · Eingefrorene Ableitung in einem skip-if-present-Dokument über konvergenter Quelle ·
Zweiter Varianten-Aufruf nie rot gesehen · Plan-Tabelle führt die berührte Datei nicht ·
Erzeugte Abdeckungs-Sicht führt den neuen Zahn nicht

## Verdikt

**Merge-blockierend:** ja — zwei HIGH und vier MEDIUM. F-1 und F-2 sind je für sich
blockierend: F-1 verletzt eine Hard Rule in dem Skript, das die Zusage des Slice real prüft,
F-2 stellt eine Falschaussage in genau die Schicht, die dieser Slice wahr machen soll.

F-3 bis F-6 sind die Frage, wie weit die drei Aussagen reichen dürfen: drei davon (F-3, F-4,
F-5) sind Aussagen über den Zustand des Ziels, die an einem benannten Zweig oder nach dem
nächsten Pin nicht mehr gelten, und F-6 ist die Hälfte des Rot-Belegs, die der Aufbau des
Sensors heute nicht hergibt. Die Einordnung *„halb geschlossen"* aus dem Umsetzungs-Bericht
wiegt aus Sicht dieses Laufs schwerer als dort: das Repo führt den Modus, der sie schließt,
und einen Fall genau dieser Klasse.

**Übergabe:** Findings an den Implementer; F-5 berührt zusätzlich eine Grenz-Entscheidung
(Zustand einer eingefrorenen Ableitung im Ziel) und gehört bei Widerspruch über den
Konflikt-Pfad an den Architect, nicht in eine Herabstufung. Die Finding-Klassen gehen in die
Slice-Closure §7 und von dort in den Zähler. Dieser Report ist Lauf-Beleg und ersetzt keine
Verifikation — die DoD-Konformität prüft der Verifier separat.
