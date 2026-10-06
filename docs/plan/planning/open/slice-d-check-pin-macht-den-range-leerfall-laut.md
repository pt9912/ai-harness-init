# Slice slice-d-check-pin-macht-den-range-leerfall-laut: Der d-check-Pin springt `v0.79.0` → `v0.81.0`, und `vcs` bricht über einer leeren Range selbst ab

**Welle:** ohne Welle.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Digest-Pin), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (Grenze des Gates), [`MR-073`](../../../../harness/conventions.md#mr-073) (Vorgänger der Pin-Linie, Eintragsform), [`MR-063`](../../../../harness/conventions.md#mr-063) (Gegenmessung je aktivem Modul), [`MR-065`](../../../../harness/conventions.md#mr-065) (history-lesender Lauf), [`MR-066`](../../../../harness/conventions.md#mr-066) (Messung 4: leere Range blind grün), [`MR-054`](../../../../harness/conventions.md#mr-054).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-06.

---

## 1. Ziel und Abgrenzung

**Ziel:** Der gepinnte d-check steht an beiden gekoppelten Stellen (`d-check.mk`, `internal/emit/emit.go`) auf `v0.81.0` mit nachgemessenem Digest; was der Sprung am Bestand ändert, ist vorher/nachher gemessen, und jede lebende Aussage, die eine leere Range „blind und grün“ nennt, ist auf den neuen Stand gezogen.

**Schnitt: ein Slice, nicht zwei.** Dogfood-Pin und emittierter Default-Pin sind fail-closed gekoppelt (`TestDefaultImage_MatchesCanonical`, `TestDefaultDigest_MatchesCanonical` in `make test`); getrennt stünde zwischen den zwei Slices ein rotes Gate. Mit drei Liefer-Punkten (§2) passt beides in einen Lauf.

**Werkzeug-Stand** (`gh api -H 'Accept: application/vnd.github.raw' 'repos/pt9912/d-check/contents/CHANGELOG.md?ref=v0.81.0'`, Abschnitte 0.80.0 und 0.81.0; fremde Kennungen nicht zitiert). Digest `docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.81.0` → `sha256:c6e613428d994acf416077024b0e47e8319af5738cbddab7c609fa2a005c92e5` (2026-10-06, gleich dem Release-Text). `--print-mk` unterscheidet sich zwischen den Digests nur in der Zeile `DCHECK_IMAGE` (`diff` der zwei Ausgaben → ein Hunk).

**Strenge-Bilanz, gemessen am Bestand 2026-10-06** (`v0.79.0` → `v0.81.0`, je über `DCHECK_DIGEST=<digest>` als make-Override):

- **Schärfer — `hostpaths` (Home-relative Pfade):** Opt-in und in keiner `modules:`-Liste (`grep -n '^modules:' .d-check.yml internal/emit/templates/d-check.yml`); Gate unberührt. Unter `--enable hostpaths` (die übrigen Module `--disable`): 33 → 36 Befunde, die drei neuen sind Tilde-Funde in `done/` und `docs/reviews/`. Das neue Ventil `hostpaths.exempt-targets` ist ohne Schlüssel byte-identisch.
- **Bricht ab — `vcs` über leerer Range:** `make doc-immutable RANGE=HEAD..HEAD` → `v0.79.0` Exit 0, `0 Befund(e)`; `v0.81.0` Exit 2, `Range-Leerfall … es wurde nichts geprüft`. `RANGE=HEAD~5..HEAD` unter beiden Exit 0. Laut CHANGELOG bricht `vcs` im flachen Klon auch bei nicht-leerer Range ab; `commits` ist unverändert. Damit wird falsch: die `full-smoke`-Stufe, die „ohne den Wächter grün“ über der leeren Range erwartet (`grep -n 'leeren Range' harness/tools/full-smoke.sh`), und die Prosa „blind und grün“ für `vcs` (`git grep -nE 'leere[nr]? (Commit-)?Range|blind und gr' -- ':!docs/reviews' ':!docs/plan/planning/done' ':!.harness/baseline'`).
- **Verfügbar — `targets.makefiles` nimmt Globs:** im Dogfood nicht genutzt (`makefiles: [Makefile, d-check.mk]`, wörtlich); `make docs-check` unter beiden Digests `2267 Datei(en) geprüft, 0 Befund(e)`.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Der Glob in `targets.makefiles` im emittierten Ziel — Folge-Slice `slice-targets-modul-im-emittierten-doc-gate`, dessen Start an diesem Slice in `done/` hängt.
- `hostpaths` aktivieren oder sein Ventil setzen — anderer Vorgang: eine Modul-Aktivierung folgt [`MR-054`](../../../../harness/conventions.md#mr-054), kein Pin-Sprung.
- Rückbau von `make history-range-guard` — anderer Vorgang (Retirement-Check): `commits` bleibt über leerer Range still, der Wächter behält dort seinen Gegenstand; ob er für `vcs` entfällt, ist die Architect-Frage in §4.
- Die Dogfood-Liste `targets.makefiles` auf Glob umstellen — Bestand bleibt: die wörtliche Liste ist unter beiden Pins befundfrei.
- Keine ADR — der Sprung schärft (`hostpaths`, `vcs`), er senkt nichts ([`AGENTS.md`](../../../../AGENTS.md) §3.5).

## 2. Definition of Done

- [ ] **L1 — Pin `v0.81.0` an beiden Stellen, Digest nachgemessen, Fragment re-adaptiert.** Rot: `make test` fällt (`TestDefaultImage_MatchesCanonical`/`TestDefaultDigest_MatchesCanonical`), solange `d-check.mk` und `internal/emit/emit.go` auseinanderlaufen — einmal mit nur einer gezogenen Stelle gesehen.
- [ ] **L2 — Der Range-Leerfall ist nachgezogen:** die `full-smoke`-Stufe zur leeren Range erwartet für `vcs` ohne Wächter Exit 2 mit der Leerfall-Meldung (nicht mehr `0 Befund(e)`), die lebende Prosa (Kommando in §1) nennt den neuen Stand. Rot: die Stufe mit dem alten Erwartungswert gegen den neuen Pin gefahren meldet „der Anlass ist hier nicht reproduziert“; ihr neuer Erwartungswert wird mit dem alten Digest rot gesehen.
- [ ] **L3 — Gegenmessung je aktivem Modul** ([`MR-063`](../../../../harness/conventions.md#mr-063)) im Dogfood (9 Module) und am frisch emittierten `--lang go`-Ziel (6 Module), vorher/nachher, auf Nicht-Null-Basis; der history-lesende Lauf nennt, woher der Klon die Objekte liest ([`MR-065`](../../../../harness/conventions.md#mr-065)). Ergebnis steht als Übergabe-Artefakt für den Architect im Implementer-Bericht. Rot: je Modul ein eingesetzter Verstoß, der unter beiden Digests fällt.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Der Adaptions-Eintrag des Architect für diesen Sprung liegt vor (§4).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `d-check.mk`, `internal/emit/emit.go` (+ `internal/emit/testdata/raw-print-mk.txt`, falls es den Tag führt) | update | Pin und Digest, gekoppelt — [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` (per `make e2e-abdeckung`) | update | Stufe zur leeren Range auf Exit 2 des Moduls — [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| `harness/sensors/history-range-guard.md`, Kommentare in `harness/tools/history-range-guard.sh`, `internal/emit/templates/enforce/history-range-guard.sh`, `Makefile`, `.github/workflows/ci.yml` | update | „blind und grün“ gilt nur noch für `commits`; die Kommentar-Regel [`AGENTS.md`](../../../../AGENTS.md) §3.7 gilt für die angefassten Zeilen |

## 4. Trigger

**Start** (`next` → `in-progress`): Auftrag des Auftraggebers **und** die Architect-Frage ist gestellt. Wie bei [`MR-073`](../../../../harness/conventions.md#mr-073) schreibt der Architect den Adaptions-Eintrag ([`AGENTS.md`](../../../../AGENTS.md) §3.8, eigener Commit) nach dem Pin-Commit des Implementers und vor dem Review, aus der Messung von L3. **Frage an den Architect:** (1) Eintrag für den Sprung `v0.79.0` → `v0.81.0` mit der Strenge-Bilanz aus §1 und L3, Fortsetzung von [`MR-073`](../../../../harness/conventions.md#mr-073); (2) [`MR-066`](../../../../harness/conventions.md#mr-066) Messung 4 und die Grenzen-Sätze zur leeren Range in [`MR-068`](../../../../harness/conventions.md#mr-068)/[`MR-073`](../../../../harness/conventions.md#mr-073) sind für `vcs` überholt — Kopf-Marke nach [`MR-032`](../../../../harness/conventions.md#mr-032)? (3) Behält `make history-range-guard` seinen Gegenstand allein über `commits` und das flache Klonen, oder ist ein Retirement-Check fällig?

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: `make docs-check` meldet unter dem neuen Pin am Dogfood Befunde, die über einen Nachzug von wenigen Zeilen hinausgehen — dann eigener Bereinigungs-Slice vor dem Sprung.
- `in-progress` → `open`: der Digest des Tags weicht bei Arbeitsbeginn von dem in §1 ab (Re-Publikation) — dann zuerst klären, nicht pinnen.

## 5. Closure-Trigger

DoD vollständig, `make gates` und `make full-smoke` grün unter dem neuen Pin, Adaptions-Eintrag liegt vor, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Ein emittiertes Ziel, das `doc-immutable` im flachen Klon fährt, bricht unter dem neuen Pin auch bei nicht-leerer Range ab (CHANGELOG) — **Ausgang:** bei Closure zuweisen, nach der Messung in L3.
- Der Digest ist nur über die Werkzeug-Ausgabe belegt, kein Sensor hält ihn gegen den Tag — **Ausgang:** bei Closure zuweisen (Register-Klasse `pin-digest-ohne-waechter`).

## 7. Closure-Notiz

Wird bei der Closure vom Planner geschrieben (AGENTS.md §3.10), nicht im Plan.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** eine Sub-Area, `*` (`ALL`), Schwelle erfüllt; alle berührten Sub-Areas GF.

**Vorgelagert — offene Beobachtungen sichten:** gelesen am gemergten Stand 2026-10-06, Zähler je `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`: `strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit` → 1 (die Bilanz steht hier vorab, L3 misst sie nach), `pin-digest-ohne-waechter` → 1 (Risiko in §6), `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` → 4, Stand `geplant`, und `werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten` → 4, Stand `geplant` (die Prosa „blind und grün“ ist genau so eine Aussage; L2 zieht sie), `ci-rennt-gegen-die-publikation-des-gepinnten-releases` → 1.
