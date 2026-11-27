# Verifikation — slice-binraire-ziehen-ohne-docker

**Lauf:** Verifier, 2026-11-27 · **Gegen:** DoD (§2) des Slice-Plans
(`docs/plan/planning/in-progress/slice-binraire-ziehen-ohne-docker.md`), die dort genannten
LH-QA-02/03, ADR-0058/0059, ADR-0109, SPEC-099 — **nicht** gegen Plan/ADR (Reviewer).
**Umgebung:** Docker-Daemon aus (Auftraggeber) — `make gates`/`make test`/`make lint`/
`make build`/`make docs-check` nicht gefahren (ungenehmigt); docker-lose Läufer und
Host-bats gefahren. **Geprüfter Stand:** HEAD `c6b4d798`; Kern `15cb3586`, Fixes
`edf99b05`, Nachzug `5f0c0598`.

## Verdikte je DoD-Punkt (§2)

### Liefer-Punkt 1 — Beschaffungsmessung + Weg je Binär — **bestätigt**

- Messung steht in `harness/sensors/dcheck-fetch.md` §Weg (Zustands-Doku, nicht
  Skriptkopf — F-1-Lösung `edf99b05`; der Skriptkopf trägt den Rang-Zeiger
  „VERTRAG: harness/sensors/dcheck-fetch.md", keine zweite Fassung).
- **Keine zweite Pin-Stelle:** `git show --stat 15cb3586 edf99b05 5f0c0598` —
  `d-check.mk`, `.d-check.yml`, `internal/emit/` unberührt; das Rezept exportiert den
  bestehenden Pin an den Zug (`Makefile:627`:
  `@DCHECK_IMAGE="$(DCHECK_IMAGE)" DCHECK_DIGEST="$(DCHECK_DIGEST)" bash …`). Die
  pinsync-Paarung ist unberührt.
- **Reale Beschaffung d-check (ohne Daemon):** `make dcheck-fetch` →
  `exit 0`, „13 Layer geprueft (anonymer OCI-Zug, docker-los)", Ablage
  `.harness/state/bin/d-check` (ELF 64-bit x86-64, statisch, BuildID gelesen).
- **Reale Beschaffung Träger (ohne Daemon):** `make traeger-fetch` →
  `exit 0`, „ai-harness-init-linux-amd64 aus Release v0.10.0, Digest verifiziert gegen
  Pin (docker-los am Host)", Ablage `.harness/state/bin/ai-harness-init`.

### Liefer-Punkt 2 — Pin-Form je Binär fail-closed, ADR-0059-Form — **bestätigt**

- d-check: Prüfform exakt `sha256:<64-hex>` (`dcheck-fetch.sh:50`), Byte-Kette
  Index↔Manifest↔Layer je Blob-Digest (`verifiziere`, Exit 1 bei Abweichung), Registry
  hart gegen ghcr.io (Exit 2), Medienform gzip/plain je Manifest-Eintrag (sonst Exit 2).
- Eigene Bruchproben am FETCH-Weg, Temp-Baum `/tmp/verify-bruch-*`:
  - 63-hex-Digest am Aufruf → `exit 2`, Meldung „…trägt nicht die Pruefform
    sha256:<64-hex>…" — **kein Ablagepfad angelegt**.
  - gültige 64-hex-Form mit verfälschtem Wert am Aufruf → Registry 404, `exit 22`,
    laut — **kein Ablagepfad angelegt**.
  - Der Halb-Ablage-Zahn (Abweichung nach geladenen Bytes → Exit 1 vor `mkdir`),
    färbt als Case: `bats test/dcheck-fetch.bats` Negativ-Fälle ok (s. LP 3), Träger
    `Digest-Abweichung vom Pin bricht fail-closed, ohne den Traeger zu legen` ok im Lauf.
- Träger: ADR-0059-Paarung Tag + SHA256SUMS je Asset unberührt
  (`traeger-fetch-host.sh`, bats-Pin-/Manifest-Modus grün).

### Liefer-Punkt 3 — bats-Wächter + Mutations-Fälle — **bestätigt (1 Vorbefund)**

- Host-Lauf `bats test/dcheck-fetch.bats test/traeger-fetch-host.bats
  test/environment-check.bats` → **24/25 ok**: d-check 8 Tests, Träger-Host 7 Tests,
  env-check 10 Tests. Fällt: env-check-Test „fehlendes optionales Werkzeug warnt, kein
  Rot" — `env: 'bash': No such file or directory`, Exit 127. **Deutung bestätigt am
  Code:** `test/environment-check.bats:83` streift den Test-eigenen PATH auf
  `PATH="$S:/nonexistent"` — `$S` trägt nur den sha256sum-Stub, `bash` liegt darin
  nicht, `env` findet den interpreter nicht, bevor das Skript läuft. Hermeticity-Bruch
  des Tests selbst (F-9, korrigierte Deutung), kein Regression des Slice; ob der Test in
  der Docker-Test-Stage messen kann, sagt der CI-Lauf.

- **Rot-Beleg nachgetragen (Am-Real-File, danach restore, Tree clean):**
  - Fall 800 (`sed 's|\[ -n "$DCHECK_DIGEST" \]|[ "" = "" ]|'`) → genau
    `not ok 1 fail-closed vor dem Registry-Zug: fehlende Pruefsumme und falsche
    Pruefform brechen, ohne abzulegen` — wortgenau wie der Anker.
  - Fall 803 (`sed 's/\*v1\.tar) zflag=""/\*v1.tar) zflag="z"/'`) → genau
    `not ok 7 mediaform plain: ein v1.tar-Layer (ohne gzip) zieht und legt ab`, Suite
    sonst grün (`grep -c '^not ok'` → 1) — wortgenau wie der Anker; die Grenze
    (sonst-Zweig ohne Mutations-Anlage, bats-Deckung Test 8) steht im Anker von 803.
- `make mutate-greift` → **789 Fälle, 786 greifen, 3 Befunde:** 784/785/794,
  Anker „veraltet" bei `harness/tools/gates-fast.sh`/`gates-keys.sh` — Vorbefunde des
  Schwesterslices, nicht der Fall-Satz 799–803. (Make meldet `Error 1` am Ende — der
  Befund-Status ist das Signal, kein Lauf-Fehler.)

### `make gates` grün — **nicht bestätigt (Umwelt; Träger ist CI)**

- Auf dem Auftraggeber-Host ungenehmigt und docker-gebunden; nicht gefahren. Der Träger
  ist CI ([`MR-014`](../spec/lastenheft.md)) auf dem frischen Klon.
- **CI-Stand:** Lauf `45961494310` (HEAD `c6b4d798`) **in progress**. Der Vorläufer
  `45960465554` (Push `a6c70467`, nur der Review-Report) ist **rot**: Job
  `full-smoke` — die E2E-Ausgangs-Zusammenfassung läuft an
  `make archive-welle` in `Error 3` („untergrenze: wellenlose Slices liegen flach in
  `done/`, kein `done/*/archiv.zip` setzt eine Untergrenze"). `a6c70467` berührt allein
  den Report — die Attribution liegt in der Altbestand-Archivierung der Welle (der
  Vorbefund-Klasse wie die Anker 784/785/794), nicht im Code dieses Slices; der
  Gates-Job des Laufs hat kein Log (vermutlich run-abhängig abgebrochen). Open Punkt an
  die Planner-Closure: der Altbestands-Schnitt der Welle räumt genau das, was die
  Untergrenze-Sperre benennt.

### Review — **bestätigt** · Doku-Update — **bestätigt**

- Report liegt: `docs/reviews/2026-11-27-slice-binraire-ziehen-ohne-docker.md`
  (`a6c70467` + Addendum `c6b4d798`), kein Self-Review; F-1..F-6 gelöst
  (`edf99b05`), N-1/N-3 gelöst (`5f0c0598`), F-7/F-8 INFO offen.
- `harness/README.md:91-93` trägt beide Wege als Index-Zeilen (Vertrag + Bindung je
  Zeile); keine Zeile der Doku sagt einen Exit-Satz zu — §3.6-Form nicht berührt.

### Closure-Notiz / Beobachtungs-Register / Risiko-Ausgänge §6 / Paarungen — **nicht verifiziert (Planner)**

- §7 der Plan-Datei ist leer → Planner-Arbeit nach diesem Bericht. §6-Ausgänge
  ausstehend: (1) kein pinierbares Release → Ausgang ist die Messung
  (Sensor §Weg, Registry-Weg), das Risiko trägt die ADR-0109-Form — Urteil an Planner;
  (2) Netz-Ausbreitung → Ausgang: README-Zeilen + Inventar-Zeilen tragen den
  Aufruf-Vertrag je Ziel.

## Kernfragen des Auftrags

1. **Messung→Entscheidung (LP 1):** bestätigt — die Wahl ist Zustands-Doku im
   Sensor §Weg („assets": [] am Release der Quelle v0.93.0; Klon+Build an zweiter
   Pin-Stelle + Host-go), der Skriptkopf ist Rang-Zeiger; der OCI-Weg liest
   `DCHECK_DIGEST` aus `d-check.mk` (`Makefile:627`), pinsync unberührt.
2. **Fail-closed-Kette:** bestätigt (Bruchproben oben, je ohne Ablage; Halb-Ablage
   über bats Negative gedeckt).
3. **Einheitliche Ablage + Inventar-Anschluss:** bestätigt — `make dcheck-fetch`
   real grün, danach `make environment-check` → „grün — 11/11 Pflicht-Werkzeuge tragen
   ihr Soll" (exit 0). Die Erweiterung ist normativ in SPEC-099 getragen
   (`spec/spezifikation.md:245` — benannte Ausnahme an der `d-check`-Zeile,
   `DCHECK_CARRIER`, Grenze „ohne Ablage bleibt der Befund"; Historie `:266`); die
   `· seit slice-binraire-ziehen-ohne-docker`-Anker stehen am Inventar
   (`environment-inventory.txt:28,30`) und an der README-Zeile `:93` — die Spec-Zeile
   selbst führt keinen `seit`-Anker (Spec-Stratum trägt LH-Bezug; Bestand-Form).
4. **Opt-in-Verdrahtung:** bestätigt — `make traeger-fetch` (Host-Rezept,
   real grün), `make traeger-fetch-image` existiert (`make -n` ok, Rezept
   `Makefile:615` → `traeger-fetch.sh`), ADR-0059-Paarung unverändert; README-Zeilen
   91–92 decken beide Wege.
5. **bats-Zähne docker-los:** bestätigt — 24/25 am Host (oben); der eine Fall ist der
   Vorbefund Test 5, F-9-Deutung am Code bestätigt.
6. **Mutations-Deckung:** bestätigt — Anker 799–803 tragen die vollständigen
   gemessenen Rot-Mengen (Stichprobe 800/803 selbst am Real-File rot gesehen);
   `make mutate-greift` 789/786/3 wie erwartet.
7. **Mutations-CI-Ergebnis:** **noch offen — Sammlung geht an die Planner-Closure.**
   Run `45959944410` (Branch `mutate/slice-binraire-ziehen-ohne-docker-15cb3586`,
   Tip `15cb3586`, 789 Fälle) ist in progress: plan + shard(0) + shard(1) ✓,
   shard(2) ✗ und shard(5) ✗ (Ursachenzuordnung erst am Run-Ende lesbar — Logs sind
   bis dahin geschlossen), shards 3/4/6/7/8/9 laufen.
   - **Lesekommando nach Run-Ende:**
     `git fetch origin mutate/slice-binraire-ziehen-ohne-docker-15cb3586 && git show FETCH_HEAD:mutate-ergebnis.txt`
     (je Fall ok/BEFUND); Logs: `gh run view 45959944410 --log`.
   - **Branch nicht löschen**, solange der Lauf und der `SCHRITT=ergebnis`-Push offen
     sind; die Löschung (dieser und ggf. älterer Refs desselben Präfix —
     `git ls-remote origin 'refs/heads/mutate/slice-binraire-ziehen-ohne-docker*'`
     nennt heute nur diesen) gehört nach dem Konsum.
   - **Deckungsumfang:** der Branch trägt `15cb3586` — der Lauf misst die
     Fassung **vor den Fixes**: die Anker-Korrekturen (`edf99b05`) und der Fall 803 +
     die `|| true`-Kette (`5f0c0598`) sind nicht in seinem Umfang. Deren Rot-Belege
     tragen die rot gesehene Hand-Mutation (Implementer, Reviewer r2, und die
     Nachprobe dieses Laufs) und `make mutate-greift` am Stand HEAD.
   - **Beleg-Einbuchung (Entscheidung dieses Laufs):** die Rot-Belege für 800/803
     sind hier am Real-File eingebracht (Kommandos + Ausgaben oben); der CI-Ausgang
     ist Konsumobjekt der Closure — die erwartbare BEFUND-Meldung eines Shards wird
     dort der Fall-Logik zugerechnet (Infra- vs Fall-Ursache) und — bei Fall-Ursache —
     als Beleg-Datei nach `.harness/stamp/mutate/…` gebucht.
8. **Kontrakt:** bestätigt — kein `spec/lastenheft.md`-Touch im Diff; SPEC-099
   normativ geschärft; `.viper.sh` unberührt (Letzter Touch `7cb85890`,
   Schwesterslice).

## Plan-vs-Code-Delta

- Kern `15cb3586` folgt der Plan-Tabelle: `Makefile`, zwei Fetch-Skripte, zwei
  bats-Suiten, README. Übertrifft den Plan: env-check-Fälle + Inventar-Schärfung +
  SPEC-099 (Inventar-Anschluss war Start-Trigger, im Code als Lieferung gelandet),
  Medienform-Verzweigung und Registry-Hardiagnose (Fix-Läufe).
- Fix-Commits im Range: `edf99b05` (F-1..F-6), `5f0c0598` (N-1/N-3 + `|| true`-
  Korrektur der drei grep-Ketten). Offen aus dem Review: F-7 (JSON-Feldreihenfolge-/
  Layer-Media-Typ-Annahmen, brechen laut), F-8 (CWD-relativer Fetch-Default vs
  REPO_ROOT-verankerte Probe, Deckung nur über `make`) — je INFO, benannt nicht
  geschlossen.
- §3.7-Form: Skriptkopf trägt Zustand + Rang-Zeiger, die Abwägung nur im
  Sensor §Weg; die Mutations-Anker tragen Zustands-Zeilen („rot gesehene
  Hand-Mutation … gemessen") und der 803-Anker nennt die ungedeckte Grenze
  (MR-090-Form) — konform.

## Offene Punkte an die Planner-Closure

1. **Mutations-CI-Konsum:** Run `45959944410` — Ergebnis lesen, je Fall ok/BEFUND,
   Ursachenzuordnung, Beleg-Buchung; danach den Branch (und ältere desselben Präfix) löschen.
2. **CI auf main:** Lauf `45961494310` (HEAD) abwarten; der Vorgänger `45960465554`
   ist rot an `full-smoke` (archive-welle Untergrenze im E2E-Baum) — Attributions-Urteil
   und die Altbestand-Archivierung gehören in die Welle-Closure, nicht in den
   Slice-Code.
3. **docker-gebundene Rest-Zähne:** `make gates`/`make test`/`make lint`/
   `make build`/`make docs-check` ungenau an keinen Stand des Slices gefahren — das
   DoD-Häkchen „make gates grün" trägt CI.
4. **Test-5-Hermeticity:** der Vorbefund ist als Hermeticity-Bruch des Tests
   (`PATH-Streifung entfernt `bash``) zu tragen, nicht als Umwelt-Befund; die
   Befundung in der Test-Fixtur-Deckung der Docker-Stage (CI grün?) klären —
   ggf. Folge-Fix (PATH des Stubs um bash erweitern).
5. **Befund-Rückstand 784/785/794** (Anker „veraltet" am Schwesterslice gates-fast/
   gates-keys) — nicht Gegenstand dieses Slices; steht offen.
