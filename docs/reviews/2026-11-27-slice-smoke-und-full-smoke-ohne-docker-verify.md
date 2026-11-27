# Verifikation — slice-smoke-und-full-smoke-ohne-docker (welle-ohne-docker)

**Verifier-Lauf:** frisch, frischer Kontext (Review-Report gelesen, Run- und Rot-Belege eigenhändig)
**Code-Stand:** HEAD `1e3ffbdc` (main); Kette seit Claim `f63b57aa`: `ac8487eb` · `f8039566` ·
`eb00a571` · `07520af0` · Review `0d760fc4` (F-1..F-7) · Behebung `95988195` / `2108567e` /
`5ee7d555` / `1e3ffbdc`
**Review:** `docs/reviews/2026-11-27-slice-smoke-und-full-smoke-ohne-docker.md` (`0d760fc4`,
3 MEDIUM / 2 LOW / 2 INFO)
**Betriebsform:** docker-los am Host (Linux), `make environment-check` grün (12/12);
d-check-Carrier an der fetched Ablage `.harness/state/bin/d-check`; kein Commit, kein push.
Alle Läufe über make-Ziele; Beleg-Logs zwischenzeitlich unter /tmp, nach Lauf geräumt.

---

## Urteile je DoD-Punkt (§2)

- **LP1 — `make smoke` docker-los grün: BESTÄTIGT.** `make smoke` → **Exit 0**; die fünf
  Stufen echoen die Host-Form: „1/5 Produkt-Binary fuer den HOST bauen (make host-bin)“ …
  „4/5 emittiertes docs-check laeuft + meldet 0 Befunde out-of-the-box“ (`d-check: 22
  Datei(en) geprüft, 0 Befund(e)`) … „5/5 … Go-Gates gruen“, Abschluss „smoke: OK“.
  Kein Docker-Aufruf im Lauf. Stufen-Deklarationen unverändert (`docs/user/e2e-abdeckung.md`
  nicht im Diff, `git diff f63b57aa..HEAD --stat`).
- **LP1-Wächter (Paarungs-Proben): BESTÄTIGT.** `make test-bats
  BATS_TARGET=test/smoke-ohne-docker.bats` → **5/5 ok** (Happy + Verdrahtung + Target-Skript
  + Anspruch + Singleton). Die Datei liest `umgebung_paarung_pruefen` per sed **aus der realen
  Quelle** `harness/tools/smoke.sh` (kein Fixture-Doppel des Funktionskörpers) und dreht je
  Form die emittierte Seite. Eigener Rot-Zug am Quell-Bestand: das 817-sed
  (`s/GATE_CHECKS := environment-check .(GATE_CHECKS)/GATE_CHECKS += environment-check/`) von
  Hand auf `internal/emit/environment.go` (Zeile 41 — die einzige Stelle der Form) →
  `make smoke` fällt an der Paarungs-Probe mit der benannten Meldung:
  „smoke: FEHLER — das Target hinter dem make-Anspruch fehlt (… die GATE_CHECKS-Verdrahtung
  in harness/mk/environment.mk)“, make-Exit 2. Restauriert (`cp` der Sicherung;
  `git diff --stat` leer).
- **LP2 — `make full-smoke` docker-los grün: BEDINGT (Restmenge beim Nehmer, Teil-Lauf
  bestätigt).** `make full-smoke` → Exit 1 (make: „Error 1“). Beleg-Reihenfolge genau wie
  geplant: „1/3 Produkt-Binary fuer den HOST bauen (make host-bin)“ → „2/3 Bootstrap (--lang
  go …) in ein leeres tmp-Repo“ → „3/3 im Ziel: make -j gates“ — und der 3/3-Lauf im Ziel
  kommt **grün durch die host-nativen emittierten Gates** (Log: „environment-check: grün —
  7/7 Pflicht-Werkzeuge“, golangci „0 issues“), bricht dann an der **ersten**
  Daemon-gebundenen Stufe: `make -f d-check.mk doc-commits` im vollständigen Klon — dessen
  Ketten-Wächter probe greift, der Modul-Lauf fährt `docker run … ghcr.io/pt9912/d-check@…`,
  „Cannot connect to the Docker daemon“ → `d-check.mk:45: doc-commits` Error 1 → „
  full-smoke: FEHLER — AUSGANG BAUM“, „make: *** [Makefile:322: full-smoke] Error 1“.
  Das ist die (a)-Klasse — die Reihenfolge des F-4-korrigierten Kopfkommentars von
  `full-smoke.sh` (a Vorlauf-Wächter-/Doku-Zahn-Stufen, b Archiv-Leseprobe, c
  hexslice-/hexagonal-Bootstraps; getrennt die carrier-gebundenen `make gates`-Läufe) ist
  durch den realen Lauf **an der Stelle bestätigt**: der erste Abbruch ist `doc-commits`,
  vor Archiv und hexslice. F-5-Echo korrigiert: „full-smoke: 1/3 Produkt-Binary fuer den
  HOST bauen (make host-bin)“ (Line 544; kein „natives Release-Binary … extrahieren“ mehr).
  Die LP2-LP3-Restmenge trägt der Nehmer `slice-full-smoke-gates-echt-gruen` (§1/§6 des
  Plans, Form stimmt — siehe unten); die Stufen-Deklarationen sind **nicht** still geändert.
- **LP3 — Mutations-Nachweis docker-los: BEDINGT (smoke entlassen, full-smoke fällt an der
  Vorbedingung).** Treiber-Lauf docker-los mit dem Carrier in der Umgebung —
  `DCHECK_CARRIER="$PWD/.harness/state/bin/d-check" make mutate
  MUTATE_CASES='08-smoke-out-of-scope 817-smoke-environment-paarung-ohne-verdrahtung'` →
  **„2 ok, 0 Befund(e)“**, Exit 0, TEILLAUF 2 von 801. Fall 817 färbt `make smoke` rot am
  Paarungs-Zahn mit der oben benannten Meldung. Die `# verify: full-smoke`-Fälle fallen
  weiter an der Umgebungs-/Daemon-Vorbedingung — realer Fall-Aufruf (`MUTATE_CASES=
  '739-python-arch-zahn-im-ziel'`): „mutate: ABBRUCH — Umgebungs-Befund: docker · Soll:
  erreichbarer Docker-Daemon · Ist: nicht erreichbar (docker info schlug fehl)“, Exit-Klasse
  4 (unter `make`: Exit 2), vor der ersten Isolationskopie; die Grenze trägt am Ort
  (`mutate.sh` Kommentar „bis ein Folgeslice diese Restmenge traegt, gilt der Abbruch") und
  ist im Register-Ausgang bei der Nehmer-Kennung benannt.
- **`make gates` grün: NICHT ERFÜLLT am Stand — und mehr als die bekannte docs-check-Zeile
  ist rot.** `make gates` (TEILDRIFT: fährt die gedrifteten Checks) → rot, make: Exit 2. Zwei
  Klassen: (i) **docs-check-host: 117 Befund(e)** — die Differenz zum Claim ist **genau +1**
  und die eine Zeile ist die benannte Platzhalter-Verlinkung von F-3:
  `docs/plan/planning/in-progress/slice-smoke-und-full-smoke-ohne-docker.md:60 …
  ../next/slice-full-smoke-gates-echt-gruen.md  target-missing  Linkziel existiert nicht`
  (Klaim: 116 Befunde, 3086 Dateien; HEAD: 117, 3088; beide Läufe rot an
  docs-check-host). (ii) **mutate-greift: 1 NEUER Befund** — siehe V-1 unten; der
  TEILDRIFT-Gates-Lauf bricht an docs-check-host, die Klassen liegen aber am selben Stand
  einzeln vor (beide von mir einzeln gefahren).
- **Review durchgeführt, Report unter docs/reviews/: ERFÜLLT** — `0d760fc4`, vom Reviewer in
  frischem Kontext; die fünf Behebungen F-1..F-5 stecken in den Folge-Commits und sind oben
  je Stelle belegt.
- **Doku-Update (smoke.md / full-smoke.md): ÜBERNOMMEN.** Keine der Sensoren-Zellen ist im
  Diff; der Plan-DoD nennt als Träger den Nehmer `slice-doku-nachzug-ohne-docker` (liegt in
  `next/`). Form stimmt: die DoD-Zeile trägt die Kennung; die Zellen selbst sind ein
  Nehmer-Posten, kein Stand-Befund.
- **Closure-Notiz / Lerneintrag / §7 / Risiko-Ausgänge / drei Paarungen: PLANNER-POSTEN.**
  Am Verifikationsstand: §6 Risiko 3 trägt seinen Ausgang (eingetreten — reale Lauf brach an
  der Vorlauf-Wächter-Stufe, Register-Anker), die DoD-Häkchen stehen offen (Bedingung für
  `done/`). Die drei Paarungen prüft die nächste Welle-Closure.

## Sensoren und Register (F-1)

- `make register-ausgang` → **grün**: „292 Eintraege, 83 ueber der Schwelle, 0 Befund(e)“.
- `docs/plan/planning/observations/BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet/state.md`
  trägt den Zustand in der Richtlinien-Form: **Stand: verkörper** und Belegzahl über
  `ls evidence | wc -l` (3), **Ausgang: verkörper** mit der Treiber-Vorbedingung als
  Verkörperung, `liegt in harness/tools/mutate.sh` + Herkunfts-Anker
  `Seit slice-mutate-treiber-host-modi`, und die smoke-Entlassung / das full-smoke-Rest bei
  der Nehmer-Kennung benannt. Drei evidence-Dateien liegen. Formen stimmen
  (`grundlagen-traceability.md` §Sensor 1: Feld `liegt in`, Zielort auflöst).

## Nehmer-Adresse (Plan §1/§6, LP2/LP3-Restmenge)

- Die Plan-Zeile (§1, Abschnitt „Die LP2/LP3-Restmenge“) trägt
  `Übernimmt: slice-full-smoke-gates-echt-gruen` mit Platzhalter-Vermerk (d-check:ignore,
  Form der ADR-0109-Zeile). Die Form ist modul-5-konstant: Kennung benannt, **Grund**
  benannt (LP2/LP3 an der Restmenge nicht erreichbar; Treiber-Vorbedingung bleibt für
  full-smoke in Kraft; reale Bruchstelle belegt am Register-Eintrag), **Grenze** benannt
  (genaue Aufzählung der Rest-Stufen: doc-commits/doc-immutable, Archiv-Leseprobe,
  hexslice-/hexagonal-Bootstraps, carrier-gebundene gates-Läufe).
- **Offen bei der Closure (Planner):** die Slice-Datei unter `next/` anlegen
  (`ls docs/plan/planning/next/slice-full-smoke-gates-echt-gruen.md` → nicht vorhanden;
  Form des Bestands, wie die Planzeile sie verheißt). Bis dahin bleibt die eine
  docs-check-Befundzeile am Stand (dokumentiert, Klasse des Bestands).

## Plan-vs-Code (§3)

- Die vier Plan-Zeilen stehen alle im Diff: `harness/tools/smoke.sh` (+85/−), `full-smoke.sh`
  (+96/−), `Makefile` (+51/−), `test/smoke-ohne-docker.bats` (neu, 96 Zeilen). Darüber
  hinaus im Diff — jede mit Grund im Plan/Behebung: `harness/tools/mutate.sh` (Treiber,
  smoke-Entlassung aus der Vorbedingung; §6/§1 Restmenge), `.github/workflows/mutate.yml`
  (Carrier-Preposition des Nacht-Jobs), `docs/user/benutzerhandbuch.md` (§6 vier
  Environment-Dateien der Emission), Mutations-Anlage 817 (F-2-Behebung), Register-Evidenz
  (07520af0) und Plan-Bericht-Berichtigungen (F-1/F-3). Kein Gebautes ohne Plan-Bezug
  gefunden; die Stichproben (Register-Formen, Wächter-Extraktion, Treiber-Kommentar,
  environment.go-Anker) stimmten alle.

## Vorbestand vs. Slice (Differenzmessung, Vorgänger-Form)

- **docs-check-host:** Klaim `f63b57aa` → **116 Befund(e)** / 3086 Dateien; HEAD →
  **117 / 3088**; `make docs-check-host` je Lauf rot (Exit 1). Byte-identisch abzüglich der
  **einen dokumentierten** F-3-Befundzeile (oben zitiert) — der Rest ist der Bestand der
  Vorgänger-Verifikationen (102 am Stand von
  `slice-waechter-umgebungs-robustheit`, gewachsen mit dem Planungs-Baum).
- **shell-lint:** rot, **byte-identisch** zwischen Klaim und HEAD (nur die make-Echo-Zeile
  wandert, `Makefile:379` → `:391`): `SC2254 ×4` in `harness/tools/gates-keys.sh` plus
  `SC2016`-Infos in `test/mutations/{797,798,799,800,801}` — vorbestehende Klasse aus dem
  Vorgänger-Bericht, unbeeinträchtigt.
- **test-go:** rot, **FAIL-Menge byte-identisch** zwischen Klaim und HEAD — zwei
  vorbestehende Klassen aus dem Vorgänger-Bericht: `TestGoProfile_PinsMatchRepo` („ARG
  GO_VERSION: generiert "1.27.3" != Repo-Dockerfile "1.27.4"“) und
  `TestStopHook_CommitBindung/dogfood` („record-gates.sh Exit 1: unbekannter Check:
  docs-check“). Kein neuer Fehlschlag aus dem Diff.
- **`make gates`** (ein TEILDRIFT-Lauf am HEAD): Bricht an docs-check-host (117) als erstem
  roten Prüfpunkt; weitere rote Klassen des selben Stands einzeln belegt (mutate-greift
  unten, shell-lint/test-go oben). Der Vorbestand ist unverändert — **neu rot ist nur
  mutate-greift (V-1)**; docs-check hat exakt die eine dokumentierte Zeile zusätzlich.

## Neue Befunde der Verifikation

- **V-1 — `make mutate-greift` NEU rot: Fall 816 hat einen verateten Anker, veralt von
  einem Commit dieses Slice.** `make mutate-greift` (801 Fälle am HEAD) → **„801
  Fall/Faelle, 800 greifen, 1 Befund(e)“**, make-Exit 1:
  `BEFUND 816-mutate-daemon-vorbedingung-verliert-die-modi — Mutation hat nicht gegriffen
  bei: harness/tools/mutate.sh — Anker veraltet?`. Ursache: das sed des Falls —
  `s@smoke | full-smoke) daemons=@…/@` — trifft die Fall-Arm-Form der
  Daemon-Vorbedingung; **`eb00a571`** hat smoke aus dem Arm entlassen, der Arm heißt seit
  `full-smoke) daemons="$daemons…"` (`mutate.sh:1939`) und das Muster steht nicht mehr.
  Der Fall (`test/mutations/816…`, Anker-Kommentar nennt die genau-einmal-Aform
  `smoke | full-smoke) daemons=`) misst damit seinen Gegenstand nicht mehr — MR-071 (Anker
  am Quell-Bestand) ist an dieser Stelle verletzt. Der Review-Lauf (F-1..F-7) hat die
  Stelle nicht geführt. **Träger:** Implementer-Nachzug — Fall 816 auf die neue Form
  re-anchoren und dabei benennen, was sein Gegenstand an der neuen Vorbedingung misst (der
  Fall „räumt die Modi aus der Vorbedingung“; der Arm trägt nur noch full-smoke; der
  Fall-Wille — Daemon-Modi fliegen aus der Vorbedingung — braucht an der neuen Form einen
  neuen Zug). Da `mutate-greift` ein gates-Check ist, rotiert dieser Befund in jeden
  künftigen gates-Lauf, bis er bezogen ist.

## Offene Posten für die Closure (Planner)

1. **Nehmer-Slice-Datei** `next/slice-full-smoke-gates-echt-gruen.md` anlegen (Form des
   Bestands); bis dahin die dokumentierte docs-check-Befundzeile am Stand.
2. **Fall 816** — Implementer-Nachzug (V-1); danach `make mutate-greift` wieder 0 Befund(e).
3. **CI-Branch** (`make mutate-auswahl`, MR-090): am `1e3ffbdc`-Tip → Exit 10 → Push nach
   `mutate/slice-smoke-und-full-smoke-ohne-docker-<sha8>`; gelesen einmal per
   `git fetch origin … && git show FETCH_HEAD:mutate-ergebnis.txt`; danach Branch-Räumung.
   Am Verifikationsstand liegt kein Ergebnis-Branch vor (kein push in diesem Lauf). Der
   Treiber-TEILLAUF (2 von 801) ist kein Vollauf-Beleg.
4. **F-7** (Pin-Derivation SKEL_GO_VERSION, Tool-Ebene) — ohne Folge-Slice im Plan-Baum
   benannt (Review INFO); vor der Closure entscheiden: Folge-Slice-Kennung oder
   dokumentierter Won't-Fix mit Grund.
5. **`make gates`** bleibt rot an den vorbestehenden Klassen (docs-check 117, shell-lint,
   test-go ×2) plus V-1; die trägerseitig zuständigen Rollen stehen im Vorgänger-Bericht
   (unverändert); **neuverantwortlich ist nur V-1 (Implementer)**.
6. DoD-„Doku-Update“-Posten liegt beim Nehmer `slice-doku-nachzug-ohne-docker` (`next/`) —
   in der Closure bei den Paarungen gegenprufen.

## Läufe dieses Verifikations-Berichts

- `make environment-check` — grün (12/12).
- `make smoke` — Exit 0 (LP1, 5/5 Stufen).
- `make test-bats BATS_TARGET=test/smoke-ohne-docker.bats` — 5/5 ok.
- Rot-Zug: 817-sed an `internal/emit/environment.go` → `make smoke` rot an der
  Paarungs-Probe (Meldung oben) → restauriert.
- `make full-smoke` — Exit 1, Abbruch an `doc-commits` (LP2, Grenze/Form bestätigt).
- `DCHECK_CARRIER=… make mutate MUTATE_CASES=‘08… 817…’` — 2 ok, 0 Befund(e) (LP3,
  smoke-Spur).
- `make mutate MUTATE_CASES='739-python-arch-zahn-im-ziel'` — ABBRUCH Umgebungs-Befund,
  Exit 4 vor der Isolationskopie (full-smoke-Spur).
- `make register-ausgang` — grün (292 Einträge, 0 Befunde).
- `make docs-check-host` am HEAD (117) und im getrennten Klaim-Checkout (`git worktree`,
  zwischenzeitlich /tmp, entfernt) — 116; Differenz +1, benannte Zeile.
- `make shell-lint` / `make test-go` am HEAD und am Klaim — je rot, byte-identische Befund-
  bzw. FAIL-Menge.
- `make mutate-greift` — 800 greifen, 1 NEUER Befund (V-1).
- `make gates` — TEILDRIFT-Lauf, rot an docs-check-host (Exit 2); die übrigen roten
  Klassen einzeln belegt.

/tmp geräumt (Worktree `verify-claim` entfernt, Logs und tmp-Repos gelöscht), Arbeitsbaum
clean.
