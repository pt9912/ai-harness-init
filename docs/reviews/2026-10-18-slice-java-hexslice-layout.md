# Review — slice-java-hexslice-layout

**Gegenstand:** Range `eed91448..a6a54283` (eb4c450c, 7142a817, a6a54283) zu
`slice-java-hexslice-layout`. **Geprüft gegen:** Slice-Plan §1/§3/§6, ADR-0094 (Accepted), ADR-0060, ADR-0088,
`AGENTS.md` §3. **Nicht geprüft:** DoD-Konformität (Verifier). **Rolle:** Reviewer, frischer Kontext.

## Findings

### HIGH

**H-1 — Move und Rewrite eines Mutations-Falls in einem Commit (Hard Rule `AGENTS.md` §3.3)**
- `kategorie`: HIGH · `quelle`: AGENTS.md §3.3 · `pfad`: `test/mutations/678-java-hexagonal-ohne-renderer.sh`
  (Commit 7142a817)
- `befund`: Der Fall `678-java-hexslice-ohne-renderer.sh` wurde zu `678-java-hexagonal-ohne-renderer.sh`
  umbenannt **und** inhaltlich umgeschrieben (Test-Name, sed-Anker, Kopf) im selben Commit. Git zeigt keine Umbenennung,
  sondern `A` + `D`: `git log --name-status -M30% eed91448..a6a54283 -- test/mutations/678-*` →
  `A 678-java-hexagonal-ohne-renderer.sh`, `D 678-java-hexslice-ohne-renderer.sh`; `git diff -M --stat 7142a817~1 7142a817`
  führt beide Zeilen getrennt. Die Regel verlangt zwei Commits, damit die Rename-Detection greift; die Wirkung
  (Historie des Falls nicht verfolgbar) ist eingetreten.
- `verifizierbar`: ja (Kommando oben; kein Gate liest die Commit-Form, vgl. AGENTS.md §3.8 „Ein Wächter existiert nicht").
- `klasse`: „Move und Rewrite in einem Commit bei Umbenennung eines Falls"
- Blockiert nach Skill-Liste („Verstoß gegen eine Hard Rule"); die Sachwirkung ist klein (eine 9-Zeilen-Datei) —
  ob die Entscheidung am Hard-Rule-Rang hängt oder die Rolle Planner/Architect eine Ausnahme setzt, ist nicht Sache dieses Reviews.

### MEDIUM

Keine.

### LOW

**L-1 — Benutzerhandbuch nennt die Bauform-Matrix falsch**
- `quelle`: AGENTS.md §6 Schritt 7 (Doku bei berührtem öffentlichem Vertrag) · `pfad`: `docs/user/benutzerhandbuch.md:328`
- `befund`: „`--arch hexslice` liefern alle drei Zielsprachen (`go`, `cpp`, `kotlin`) … (`cpp` oder `kotlin` mit `hexagonal`)
  endet mit Exit 2": nach dem Diff liefert auch `java` hexslice; die Liste nennt `java` weder als Sprache noch beim Exit-2-Fall.
  `git grep -n java -- docs/user/benutzerhandbuch.md` → keine Treffer, die Lücke besteht seit `slice-java-skelett`; der Diff
  zieht sie nicht nach, obwohl er den Vertrag ändert (README ist nachgezogen).
- `verifizierbar`: nein · `klasse`: „Nutzer-Handbuch zählt Sprachen mit Layout nicht nach"

**L-2 — Abdeckungs-Zeile nennt „Paket gleich Verzeichnis" als Gemessenes, die Stufe misst es nicht**
- `quelle`: AGENTS.md §3.6 (emittierte Abdeckungs-Aussage) · `pfad`: `harness/tools/full-smoke.sh:3538`,
  `docs/user/e2e-abdeckung.md` (Java-hexslice-Zeile)
- `befund`: Die Kurzbeschreibung führt unter Gemessenem „(Pakete, Paket gleich Verzeichnis)" und unter NICHT Gemessenem „ein Paket
  ausserhalb seines Verzeichnisses". Die Stufe prüft nur, dass Imports auflösen (kein „Import-Symbolen"-Hinweis); Paket == Verzeichnis
  hält der Go-Test, nicht die Stufe. Eine Lesart „E2E deckt Paket == Verzeichnis" ist möglich.
- `verifizierbar`: nein · `klasse`: „Abdeckungs-Zeile nennt Teilmessung widersprüchlich"

### INFO

**I-1 — Fall 727 pinnt die Ursache nicht.** `# expect:` ist „make gates … NICHT Exit 0"; der Fall-Kopf behauptet `wrong-direction`.
Die Mutation ändert nur die Kante (726 belegt im Text-Test, dass genau sie fehlt), ein anderer Rot-Grund ist nicht erkennbar; die
Ausgabe der Meldung liest `make mutate` nicht mit. Beleg: rot gesehen (siehe unten), Ursache nicht gelesen.

**I-2 — Parallel-Lauf von `make mutate` kollidiert auf dem Image-Cache.** Ein Teillauf mit 14 Fällen im Default-Worker-Modus brach mit
`docker: Error response from daemon: No such image: sha256:…` ab (Befunde „falscher Grund" und „vollstaendigkeit" bei 723 u. a.);
mit `MUTATE_JOBS=1` alle 12 Go-Fälle ok. Gehört nicht zu diesem Diff; Umgebungsbeobachtung (Colima).

**I-3 — Laufzeit-Zuwachs: Vermutung bestätigt, Zahl nicht gemessen.** Gelesen an `harness/tools/full-smoke.sh`:
(1) `kennungs_form_im_ziel` (Z. 4020) leitet Sprache × Architektur aus dem Träger ab und fährt `java hexslice` als neue Kombination
(Bootstrap + docs-check); (2) die zwei späteren `make gates` über das gemeinsame Mono-Repo `tmprepo_doc` (Z. 3815 `two_out`,
Z. 3885 `hexagonal_out`) fahren das ab Z. 3534 eingerichtete Modul `apps/javahexslice` jedes Mal mit (Test, Lint, Build, a-check).
Das erklärt die nicht zugeordneten 40–68 s der Commit-Message plausibel; ich habe die Teile nicht einzeln gemessen.

**I-4 — Rollenfrage `spec/architecture.md`: zulässig, kein Befund.** AGENTS.md §3.8 bindet nur Hard Rules und Adaptions-Block an den
Architect und sagt über andere Norm-Artefakte nichts; ADR-0094 (Folgepflicht, Z. 138) benennt den Slice als Träger, Plan DoD 3
verlangt es, ADR-0062 beantwortet die Eigentumsfrage nicht im laufenden Vorgang (`slice-151` bleibt offen). Inhalt: sachlich
richtig gegen den Code, keine Zeit-/Liefersätze.

**I-5 — `java_hexslice.go` als eigene Datei.** Kein Defekt gefunden: `dupl` (threshold 150) prüft Go-Quelltext; die doppelten
Rollen-Funktionen sind durch `jvmLayout` entfallen. Ob die Datei-Trennung selbst von `dupl` verlangt ist, habe ich nicht
nachgestellt; die Beobachtung (Vorschlag des Implementers) ist Planner-Sache.

## Negativbefund — geprüft, ohne Befund

- **Kotlin byte-gleich:** `jvmLayout.role` liefert für Kotlin dieselben Pfade/Inhalte wie die gelöschte `kotlinRole` (Diff gelesen,
  Rollen, Pfade, `Main.kt` für `roleEntrypoint` flat vs. `roleCompositionRoot` hex, `hexagonal` → nil). Kotlin-Fälle einzeln
  gefahren (`make mutate`, `MUTATE_JOBS=1`): 623, 624, 626, 618 ok. Gegenprobe `t.Skip` im benannten Test: 623 und 719 grün
  (binden allein); 624 bleibt rot durch `TestRun_BootstrapKotlinRoot` (bestehender, ungeänderter Test, struktureller Nebeneffekt);
  kein Wächter verlor Zähne durch die Helfer-Auslagerung. 625/621/628 (full-smoke) berühren nur die Config-Konstante, nicht gefahren.
- **Fall 678 Endform:** sed-Anker greift, `TestGenerateArch_JavaOhneHexagonal` rot (ok); die Java-flat-Stufe prüft `--arch hexagonal` mit
  Exit 2 und ohne Artefakt (full-smoke Z. 2886 ff.), `TestRun_AddLangJavaHexagonalIstExit2` hält Meldung `verfuegbar: flat, hexslice`.
- **Fälle 719–723, 726, 728–730** (`make mutate`, einzeln, sequentiell): alle ok, `mutate-greift` über alle 716 Fälle `0 Befund(e)`.
  Gegenprobe `t.Skip`: 720, 723, 726 bleiben grün (binden allein); 721, 722, 729, 730, 678, 728 bleiben durch andere Tests rot
  (721: `JavaResolution` prüft den Root ebenfalls; 722: `EdgesMatchSkeleton` über die Import-Regex; 729/730/678/728: cmd-Tests über
  dieselbe Quell-Stelle) — struktureller Nebeneffekt, der benannte Test bindet jeweils Eigenes (Literal je Schlüssel); keine
  Exklusivitäts-Behauptung im Kopf.
- **Lauf-Fälle 724, 725, 727** (`SMOKE_ARTIFACT_TARGET=artifact-host`, je einzeln): rot aus dem benannten Grund (724: Meldung
  „rot, aber nicht mit core-impurity an der Domain-Datei"; 725: „Arch-Gate grün, löst aber keinen Import auf"; 727: „make gates … NICHT Exit 0").
- **a-check-Config/Skelett (ADR-0094 Festl. 4/5):** `languages: java ["**/*.java"]`, `fixed-root`, `roots ["src/main/java/app"]`,
  `package_base "app"`, Pfade, Paket == Verzeichnis, sieben Kanten inkl. `driven_adapters → ports_outbound`; `EdgesMatchSkeleton` beide
  Richtungen (726 fällt, 721 fällt); `hexagonal` → Exit 2. **Realquelle gefahren** (frischer Bootstrap `--lang java --arch hexslice`,
  echtes a-check): Basis `0 Befund(e)`; Import Domain → Adapter: `core-impurity` (Datei:Zeile); Wildcard-Import und `import static`
  werden ebenfalls als `core-impurity` gemeldet; ein voll qualifizierter Name ohne `import` bleibt grün — deckt sich mit der
  NICHT-gemessen-Zeile und der Spec-Aussage.
- **full-smoke-Stufe / `e2e-abdeckung.md`:** Stufe prüft Dateien, `make gates`, Marker, Abwesenheit „Import-Symbolen", roten Fall
  (`Greeting.java:4: core-impurity`) und Gegenprobe; Sicht neu erzeugt (46 Stufen), Java-flat-Zeile nennt Exit-2-Fall; Befund nur L-2.
- **`spec/architecture.md` / README:** sachlich richtig gegen Code und Config; keine Zeit- oder Liefersätze; README-Zeile stimmt.
- **§3.2 / §3.5 / §3.9:** keine Suppression, keine Gate-Lockerung, keine Host-Toolchain im Diff.
- **§3.7-Kommentare:** neue Kommentare tragen Zusage/Kopplung/Grenze; kein Befund.

## Sensor-Läufe

- `make gates`: alle Stufen vor `mutate-greift` grün (baseline-verify OK, docs-check 0 Befund(e), Go-Tests, lint, build, bats,
  comment-claims 0, register-ausgang 0). `mutate-greift` meldete im ersten Lauf 709 Befunde — Ursache: BSD-`sed` im Shell-PATH
  des Laufs, nicht der Diff; mit `PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH make mutate-greift` →
  `716 Fall/Faelle, 716 greifen, 0 Befund(e)`, Exit 0. Ein voller `make gates` mit GNU-sed-PATH wurde nicht wiederholt.
- Budget: ~46 Tool-Calls (Überschreitung, wegen Gegenproben und der drei full-smoke-Fälle).
