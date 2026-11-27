# Review — slice-smoke-und-full-smoke-ohne-docker

**Datum:** 2026-11-27
**Diff:** `f63b57aa..07520af0` (4 Implementer-Commits: `ac8487eb`, `f8039566`,
`eb00a571`, `07520af0`)
**Plan:** `docs/plan/planning/in-progress/slice-smoke-und-full-smoke-ohne-docker.md`
**ADRs im Geltung:** ADR-0109 (Gates docker-los, Pflicht-Weg), MR-071, MR-090,
MR-098; hard rules §3.1, §3.6, §3.7.
**Grenze:** Review prüft gegen Plan und ADRs (Modul 10); die DoD-Abhakung
(Liefer-Punkte 1–3, `make gates` grün) prüft die Verifikation.

## Findings

### F-1 — Beleg hebt den Register-Eintrag über die 3×-Schwelle; die Stand-Zelle hält nicht, und der register-ausgang-Sensor steht rot

* **kategorie:** MEDIUM
* **quelle:** ADR-0069 (Zählung), ADR-0049 (Ausgang trägt die benannte Lücke), ADR-0085
  (Lese-Schritt); AGENTS.md §3.7 (Zustandsfeld)
* **pfad:**
  `docs/plan/planning/observations/BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet/state.md:3`
  · `make register-ausgang`
* **befund:** Commit `07520af0` legt die dritte `evidence/*.md`-Datei an
  (`slice-smoke-und-full-smoke-ohne-docker.md`) — damit ist der Eintrag bei
  **3** Belegen, genau der Schwelle. Die Stand-Zelle steht bei
  `Zähler 2 … unter der Schwelle`, und die Zelle nennt ihre eigene Messung
  (`ls evidence | wc -l`), die nun 3 liest — das Zustandsfeld hält an der
  Dateizahl nicht. `make register-ausgang` ist am Handoff rot:
  `…: 3 Belege (evidence/*.md), Stand 'offen' — ueber der 3x-Schwelle ohne
  Ausgang … make: *** [Makefile:410: register-ausgang] Error 1`. Die
  Commit-Message sagt „kein Zaehler gesetzt“ — aber der Zähler des Registers
  **ist** die Zahl der Dateien (Beobachtungs-Register-README: „Es gibt kein
  Zähler-Feld“); ein Beleg ist darum zugleich ein Zähler-Treffer. Der Lese-Schritt
  (Ausgang · verkörperte Regel · benannte Lücke) und der Folge-Slice — die
  Trägerfrage: die LP2-Restmenge `a-check --print-mk` / `unzip` /
  nicht-Go-Gates / Vorlauf-Wächter liegt an — sind nicht geschrieben.
* **verifizierbar:** ja — `make register-ausgang` (Exit 2, roter Lauf oben).
* **klasse:** schwelle-uebertritt-ohne-ausgang

### F-2 — Die drei neuen Paarungs-Proben des Smokes sind ungebunden: kein Mutations-Fall, kein bats (Plan §3 verspricht `test/smoke-ohne-docker.bats` — fehlt)

* **kategorie:** MEDIUM
* **quelle:** AGENTS.md §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel);
  Plan §3 (Test-Tabelle), MR-071/MR-090
* **pfad:** `harness/tools/smoke.sh:115-131` (Paarungs-Proben) · Plan §3
  (`test/smoke-ohne-docker.bats (je Implementer) | neu`)
* **befund:** Die Prüfung misst jetzt die Paarung beider Seiten — der
  make-Anspruch im Singleton (`grep -q 'make environment-check'`, positives
  Urteil) und das Target dahinter (`tools/harness/environment-check.sh` +
  `^GATE_CHECKS := environment-check` in `harness/mk/environment.mk`). Die
  Proben themselves sind sauber formuliert (beide Seiten, lauter Abbruch).
  Aber: die vom Plan versprochene Test-Datei ist nicht geliefert
  (`ls test/smoke-ohne-docker.bats` → nicht vorhanden; der Diff fügt keine
  Test-Datei hinzu), und kein Fall unter `test/mutations/` bindet eine der
  drei neuen Proben — eine Mutation an der Emission der Anspruchs-Zeile oder
  der `GATE_CHECKS`-Verdrahtung färbt keine kurierte Suite rot. Die Proben
  laufen nur, wenn jemand `make smoke` fährt; ihre Zusage ist damit
  ungezähnt (§3.6).
* **verifizierbar:** ja — `ls test/smoke-ohne-docker.bats`;
  `grep -rl 'environment.mk' test/mutations/ | wc -l` → 0.
* **klasse:** neue-zusage-ohne-rot-faerbenden-fall

### F-3 — LP2/LP3 des Plans sind im gelieferten Zustand nicht erreichbar; die Restmenge trägt nur Kommentar und Commit-Messages, der Plan-Text bleibt unverändert

* **kategorie:** MEDIUM
* **quelle:** Plan §1/§2/§4/§5; ADR-0109
* **pfad:**
  `docs/plan/planning/in-progress/slice-smoke-und-full-smoke-ohne-docker.md:62-75`
  (Liefer-Punkte 2–3) vs. `harness/tools/full-smoke.sh:18-21,526-530` und
  `harness/tools/mutate.sh:1924-1937`
* **befund:** Der Plan §2 verspricht: `make full-smoke` ohne Docker-Daemon
  **grün** (LP2) und der Mutations-Nachweis über einem `# verify:
  full-smoke`-Fall **docker-los** (LP3). Geliefert ist: full-smoke läuft
  docker-los **bis zur ersten Daemon-gebundenen Stufe** — der probe-Lauf brach
  am `make -f d-check.mk doc-commits` der Vorlauf-Wächter-Stufe (Beleg-Evidenz
  `07520af0`); full-smoke bleibt in der Daemon-Vorbedingung des Treibers, und
  die 63 `# verify: full-smoke`-Fälle laufen darin Exit 4 weiter — benannt
  (`mutate.sh:1930-1937`, Kommentar „bis ein Folgeslice diese Restmenge
  trägt, gilt der Abbruch“), aber getragen nur von Kommentar und Commit-Message.
  §4 des Plans sagt für eine Stufe ohne Host-Prüfen-Weg: „die Stufen-Deklaration
  wird neu formuliert — nicht still geändert“ und §5 setzt den realen grünen
  `full-smoke`-Lauf als Closure-Trigger. Weder der Abschnitt im Plan noch die
  Stufen-Deklarationen trägen die Form; der Slice kann über §5 so nicht
  schließen. Die Restmenge braucht einen benannten Folge-Slice im Plan-Baum.
* **verifizierbar:** ja — der Läufer am daemon-losen Host bricht an der
  Vorlauf-Wächter-Stufe (Beleg 07520af0); `git diff f63b57aa..07520af0 --
  docs/plan/planning/in-progress/` → nur die Evidenz-Datei, der Plan-Text
  unverändert.
* **klasse:** plan-code-abweichung-nur-im-kommentar-getragen

### F-4 — Die Grenze-Aufzählung der Daemon-Rest-Stufen ist unvollständig: ihr fehlen die Vorlauf-Wächter- und Dok-Zahn-Stufen, die auf daemon-losem Host die *ersten* Abbruch-Stufen sind

* **kategorie:** LOW
* **quelle:** Maintainability; AGENTS.md §3.6-Form (Aufzählung, die der Diff
  anlegt); Reviewer-Skill *Grenzen-Aufzählung ohne Formen-Probe*
* **pfad:** `harness/tools/full-smoke.sh:18-21` (Kopfkommentar);
  `Makefile:317-321` (full-smoke-Rezeptkommentar)
* **befund:** Der Kommentar nennt als Daemon-Rest: Archiv-Leseprobe
  (`archiv_gueltig`, BATS_IMAGE), hexslice-/hexagonal-Bootstraps
  (`a-check --print-mk`), nicht-Go-Code-Gates. Nicht genannt: die
  Vorlauf-Wächter-Stufen (`make -f d-check.mk doc-commits` am volständigen
  Klon, `full-smoke.sh:991` und Vorbindungs-Proben um 975) und die
  Dok-Zahn-Stufen (`make -C "$tmprepo" docs-check`, Docker-Form,
  `full-smoke.sh:1067` ff.) — obwohl die Beleg-Evidenz zeigt, dass genau eine
  davon (`doc-commits`) die erste Daemon-gebundene Stufe des Laufs ist, vor
  Archiv-Leseprobe und vor den hexslice-Bootstraps. Der Leser auf
  daemon-losem Host wird zur Archiv-Leseprobe als erster Grenze geschickt,
  wo der Lauf schon an der Vorlauf-Wächter-Stufe bricht. Dazu die zweite
  Lücke derselben Aufzählung: die un-carried `make -j gates`-Läufe der
  cpp/kotlin/java/python/csharp- und repo.mk-Stufen
  (`full-smoke.sh:2827,2828,2876,2966,3080,3161,3293,3538,3640,4904,4953`)
  brauchen für den emittierten `docs-check-host` (fail-closed,
  `internal/emit/emit.go:136`) den **Carrier**, nicht den Daemon — der Rest
  ist also zum Teil carrier-gebunden und docker-ösbar, was die
  Rest-Beschreibung („alles Daemon-weg“) verdeckt.
* **verifizierbar:** ja — `grep -n 'd-check.mk' harness/tools/full-smoke.sh`
  (Stufen um 769/795/991) gegen die Kopf-Aufzählung; kein DCHECK_CARRIER am
  `make -j -C "$repo" gates` der repo.mk-Stufe.
* **klasse:** grenz-aufzaehlung-unvollstaendig

### F-5 — Stufen-Echo von full-smoke sagt den alten Träger: „natives Release-Binary … extrahieren“ beim Default `host-bin` (Bau am Host)

* **kategorie:** LOW
* **quelle:** Maintainability (Doku-Drift im Lauf-Log)
* **pfad:** `harness/tools/full-smoke.sh:531`
* **befund:** Der Default von `ARTIFACT_TARGET` ist seit diesem Slice
  `host-bin` — das Rezept **baut** das Binary am Host; das Echo der Stufe 1/3
  sagt weiter „natives Release-Binary auf den Host extrahieren“. `smoke.sh`
  wurde am selben Punkt angepasst („Produkt-Binary fuer den HOST bauen“),
  full-smoke nicht. Ein Leser des Lauf-Logs liest eine Stufen-Beschreibung,
  die die Stufe nicht ausführt.
* **verifizierbar:** ja — `grep -n 'natives Release-Binary'
  harness/tools/full-smoke.sh` → 531; Rezept `host-bin` baut
  (`Makefile:614-622`).
* **klasse:** stufen-echo-traegt-den-alten-traeger

### F-6 — Smoke-Fälle im Mutations-Treiber brauchen jetzt einen Carrier vor dem Gruen-Vorlauf; ohne `DCHECK_CARRIER` bricht der Treiber im Vorlauf ab — benannt nur am Nacht-Job

* **kategorie:** INFO
* **quelle:** dokumentationswürdige, aber (am `make mutate`-Vertrag)
  undokumentierte Annahme
* **pfad:** `harness/tools/mutate.sh:343-350` (ISOLATION_EXCLUDES =
  `./.harness/state`) · `harness/tools/smoke.sh:44-56` ·
  `.github/workflows/mutate.yml:67-69`
* **befund:** Nach der Entlassung des smoke-Modus aus der Daemon-Vorbedingung
  hängt jeder `# verify: smoke`-Fall am Carrier. Die Isolationskopie
  schließt `.harness/state` aus, die fetched Ablage liegt in der Kopie also
  nicht — ohne `DCHECK_CARRIER` in der Umgebung scheitert der Gruen-Vorlauf
  (`make smoke` bricht laut am Carrier-Befund ab, Exit 1, und der Treiber
  meldet „ohne Mutation rot“). Der Nacht-Job übergibt den Carrier
  (`dcheck-fetch` dann `DCHECK_CARRIER`); lokalen Läufen sagt das kein
  Träger-Ort des Treibers oder des Make-Rezepts. Fail-closed, nicht still —
  aber die Voraussetzung trägt nur die YAML.
* **verifizierbar:** nein (ein Lauf über `make mutate` mit einem smoke-Fall
  ohne env bestätigt es; nicht gefahren — Docker aus, budgetiert).
* **klasse:** smoke-fall-bedarf-carrier-vor-dem-vorlauf

### F-7 — SKEL_GO_VERSION: Ebene-Trennung sauber am E2E-Ort; die Pin-Derivation am Tool-Ort bleibt offen (Rest-Posten)

* **kategorie:** INFO
* **quelle:** bewusste Won't-Fix-Designnotiz dieses Slices; LH-QA-02; ADR-0109
* **pfad:** `harness/tools/full-smoke.sh:574-580,599-606,2763-2767`
  (SKEL_GO_VERSION-Zug) · `internal/gen/golang.go:11` (`DefaultGoVersion =
  "1.27.3"`) · `internal/gen/golang.go:1087-1100` (`InventoryRows` aus
  derselben `skelVersion`) · `cmd/ai-harness-init/main.go:665-674`
* **befund:** Am E2E-Ort ist der Zug konsistent: `skelVersion` löst
  `SKEL_GO_VERSION` (env) oder `gen.DefaultVersion` auf, und die Emission
  leitet Fragment-Pin **und** Inventar-Soll aus derselben aufgelösten
  version ab — mit `SKEL_GO_VERSION="$GO_VERSION"` (Labor-Pin 1.27.4) stimmen
  Fragment, Inventar und Host-Tool, ohne dass die Tool-Ebene angefasst würde.
  Offen bleibt die Tool-Schicht: der Skeleton-Default `1.27.3` vs. Labor-Pin
  `1.27.4` — ein Bootstrap ohne env auf einem Host mit abweichendem
  `go` emittiert Soll und Pin in 1.27.3, und der emittierte
  Tool-/Versions-Check hält das Soll gegen die Host-Version: gates des
  frisch gebootstrappten Ziels sind auf einem solchen Host erst nach
  `SKEL_GO_VERSION` grün (out-of-the-box-Grenze, die der Kommentar am
  3/3-Stufe nennt, aber der Tool-Schicht-Posten trägt kein Folge-Slice im
  Plan-Baum). Kein stiller Drift — aber ein benannt-behobener Symptom-Ort
  ohne benannten Tool-Schicht-Nachzug.
* **verifizierbar:** nein (Urteil über Code-Lage; der echte Wächter wäre ein
  Bootstrap-Lauf ohne env auf einem Host mit abweichendem go).
* **klasse:** skelett-default-drift-am-tool-ort-unter-folgefrei

## REFUTED

*(kein verworfener Befund-Kandidat in diesem Lauf)*

## Negativbefunde — geprüft, ohne Befund

* **e2e-abdeckung-Deklarationen:** nicht umgedeklappt — `docs/user/e2e-abdeckung.md`
  ist nicht im Diff, alle `e2e_abdeckung`-Zeilen des Diffs stehen als unveraenderter
  Kontext; die Daemon-gebundenen Stufen (Archiv, hexslice, nicht-Go) messen
  unverändert, keine Deklaration trägt eine Teilmessung, die die Stufe nicht fährt.
* **smoke-Release im Mutations-Treiber:** die Form ist benannt, kein stiller
  Bestand — Abbruch-Liste auf `full-smoke` reduziert,
  `mutate.sh:1930-1937` nennt die Grenze samt Rest-Behandlung, und die 63
  `# verify: full-smoke`-Fälle (Exit 4 weiter) sind an der Stelle benannt.
* **mutate.yml (Nacht-Job):** Carrier-Preposition je Shard vor `make mutate`, Netz
  an genau diesem `dcheck-fetch`-Aufruf, Übergabe als `DCHECK_CARRIER` — passend
  zur Ablage des Targets; Syntax-Deckung über `make ci-lint` in gates.
* **SKEL_GO_VERSION-Verdrathung am E2E-Ort:** Fragment-Pin und Inventar-Soll
  stammen aus derselben `skelVersion`-Auflösung (kein Auseinanderfall zwischen
  Fragment und Inventar — F-7 gilt nur am Tool-Default, nicht innerhalb der Emission).
* **Paarungs-Ziel der neuen Proben:** die emittierte Seite existiert und stimmt
  zur Probe (`internal/emit/environment.go:41` `GATE_CHECKS := environment-check
  $(GATE_CHECKS)`; `tools/harness/environment-check.sh` in der Emission,
  `internal/emit/environment_test.go:96`) — der Befund F-2 gilt der Bindung der
  Proben, nicht ihrer Form.
* **host-bin-DEST-Form:** ein Bau-Rezept, kein zweiter daneben; mit `DEST` baut
  dieselbe Form dorthin, je Lauf frisch aus dem Baum-Stand; ohne DEST in den
  gitignorierten Zustands-Bereich (span-check/span-report unberührt).
* **docs/user/benutzerhandbuch.md §6:** die vier genannten Emissions-Dateien
  existieren in der Emission-Menge (`internal/emit/environment_test.go:96`,
  `internal/emit/enforce.go:100`); keine halluzinierte Datei.
* **Carrier-Resolver beider Smokes:** fail-closed und laut („ABB RUCH —
  Umgebungs-Befund“), Quelle außen (env › fetched Ablage), Pfad-Auflösung
  absolut in smoke (`cd dirname basename`), HIER-basiert in full-smoke
  (vor der Nutzung definiert, Zeile 24); Exit-Klasse 1 (nicht 4) — konsistent
  mit den übrigen fehlenden-Sensor-Aborten der Smokes.
* **Ketten-Wächter-Marker:** `docker run` → `state/bin/d-check` an den drei
  Ketten-Proben (1755, 2437, 5518) — der emittierte Carrier-Ablagepfad ist
  `docs-check-host`-Form und stimmt zum Rezept-Echo der emittierten Kette;
  die Gates-Beleg-Marker (633-Stufe) tragen die host-native Rezept-Echos.

## Sensoren dieses Laufs

* `make register-ausgang` — **rot** (Exit 2), Befund F-1, am Handoff.
* Diff/Commit-Range gelesen: `f63b57aa..07520af0`, Bestandsvergleiche
  (`git log -S 'GATE_CHECKS += docs-check-host'`, `git show f63b57aa:…`).
* Restlauf: `make gates` am committeten Stand (wird nach dem Commit gefahren;
  Ergebnis steht im Bericht des Läufs an den Aufrufer).
