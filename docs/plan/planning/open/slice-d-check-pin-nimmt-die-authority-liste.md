# Slice slice-d-check-pin-nimmt-die-authority-liste: Der d-check-Pin springt `v0.81.0` → `v0.82.0`, und `targets.authority` nimmt eine Liste

**Welle:** ohne Welle.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Digest-Pin), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (Grenze des Gates), [`MR-079`](../../../../harness/conventions.md#mr-079) (Vorgänger der Pin-Linie, Eintragsform), [`MR-063`](../../../../harness/conventions.md#mr-063) (Gegenmessung je aktivem Modul), [`MR-065`](../../../../harness/conventions.md#mr-065) (history-lesender Lauf), [`MR-054`](../../../../harness/conventions.md#mr-054).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-06.

---

## 1. Ziel und Abgrenzung

**Ziel:** Der gepinnte d-check steht an beiden gekoppelten Stellen (`d-check.mk`, `internal/emit/emit.go`) auf `v0.82.0` mit nachgemessenem Digest; was der Sprung am Bestand ändert, ist vorher/nachher gemessen, im Dogfood und am frisch emittierten Ziel.

**Schnitt: ein Slice.** Dogfood-Pin und emittierter Default-Pin sind fail-closed gekoppelt (`TestDefaultImage_MatchesCanonical`, `TestDefaultDigest_MatchesCanonical` in `make test`); getrennt stünde zwischen zwei Slices ein rotes Gate.

**Werkzeug-Stand** (`gh api -H 'Accept: application/vnd.github.raw' 'repos/pt9912/d-check/contents/CHANGELOG.md?ref=v0.82.0'`, Abschnitt 0.82.0; fremde Kennungen nicht zitiert): ein Eintrag unter *Added* — `targets.authority` nimmt neben einem Pfad eine Liste wörtlicher Pfade; `gate-undocumented` misst gegen die Vereinigung; Doppelnennung kein Befund; fehlende Datei, leerer, Null- oder Nicht-Skalar-Eintrag Exit 2; leere Liste lässt die Prüfung entfallen; mit einer Datei (String oder einelementige Liste) byte-identische Ausgabe, auch `--json` und `--doctor`. Digest `docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.82.0` → `sha256:d28e9437888554a262ad9a2e8a63fdb1717e5b5860824fdef263a877d532e0c8` (2026-10-06).

**Strenge-Bilanz, Vorab-Messung am Bestand 2026-10-06** (`v0.81.0` → `v0.82.0`): `--print-mk` unterscheidet sich zwischen den Digests nur in der Zeile `DCHECK_IMAGE` (`diff` der zwei Ausgaben → ein Hunk); `make docs-check` unter beiden Digests (`DCHECK_DIGEST=<digest>` als make-Override) `2277 Datei(en) geprüft, 0 Befund(e)`. Erwartet ist damit nur *verfügbar* (`targets.authority` als Liste), nichts schärfer — das emittierte Ziel und die Gegenmessung je Modul misst L2, nicht diese Zeile.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Das Modul `targets` im emittierten Ziel und der werkzeug-eigene Index-Teil — Folge-Slice `slice-targets-modul-im-emittierten-doc-gate`, dessen Start an diesem Pin hängt.
- Eine Listen-`authority` im Dogfood — Bestand bleibt: `.d-check.yml` führt eine Autoritäts-Datei, und die ist mit einer Datei byte-identisch; eine zweite gibt es hier nicht.
- Keine ADR — der Sprung macht etwas verfügbar und senkt nichts ([`AGENTS.md`](../../../../AGENTS.md) §3.5).

## 2. Definition of Done

- [ ] **L1 — Pin `v0.82.0` an beiden Stellen, Digest nachgemessen, Fragment re-adaptiert.** Rot: `make test` fällt (`TestDefaultImage_MatchesCanonical`/`TestDefaultDigest_MatchesCanonical`), solange `d-check.mk` und `internal/emit/emit.go` auseinanderlaufen — einmal mit nur einer gezogenen Stelle gesehen ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [ ] **L2 — Strenge-Bilanz und Gegenmessung je aktivem Modul** ([`MR-063`](../../../../harness/conventions.md#mr-063)): `--print-mk`-Diff, `make docs-check` vorher/nachher im Dogfood und am frisch emittierten `--lang go`-Ziel, je aktivem Modul auf Nicht-Null-Basis; der history-lesende Lauf nennt, woher der Klon die Objekte liest ([`MR-065`](../../../../harness/conventions.md#mr-065)). Rot: je Modul ein eingesetzter Verstoß, der unter beiden Digests fällt. Ergebnis als Übergabe-Artefakt für den Architect im Implementer-Bericht.
- [ ] **L3 — Die Byte-Identität mit einer Datei ist gesehen:** `targets` im Dogfood unter `authority: harness/README.md` und unter `authority: [harness/README.md]` liefert dieselbe Ausgabe, und ein eingesetztes undokumentiertes Target färbt beide gleich rot (`gate-undocumented`); die Probe ändert `.d-check.yml` nicht dauerhaft.
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
| Kopfkommentar `d-check.mk` (Zustandssatz) | update | nennt den neuen Stand; die Kommentar-Regel [`AGENTS.md`](../../../../AGENTS.md) §3.7 gilt für die angefassten Zeilen |

## 4. Trigger

**Start** (`next` → `in-progress`): Auftrag des Auftraggebers. Wie bei [`MR-079`](../../../../harness/conventions.md#mr-079) schreibt der Architect den Adaptions-Eintrag ([`AGENTS.md`](../../../../AGENTS.md) §3.8, eigener Commit) nach dem Pin-Commit des Implementers und vor dem Review, aus der Messung von L2/L3. **Frage an den Architect:** Eintrag für den Sprung `v0.81.0` → `v0.82.0` mit der Strenge-Bilanz aus §1 und L2, Fortsetzung von [`MR-079`](../../../../harness/conventions.md#mr-079).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: die Gegenmessung zeigt eine Verschärfung, die der CHANGELOG nicht nennt und die über einen Nachzug von wenigen Zeilen hinausgeht — dann eigener Bereinigungs-Slice vor dem Sprung.
- `in-progress` → `open`: der Digest des Tags weicht bei Arbeitsbeginn von dem in §1 ab (Re-Publikation) — dann zuerst klären, nicht pinnen.

## 5. Closure-Trigger

DoD vollständig, `make gates` und `make full-smoke` grün unter dem neuen Pin, Adaptions-Eintrag liegt vor, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Der Digest ist nur über die Werkzeug-Ausgabe belegt, kein Sensor hält ihn gegen den Tag — **Ausgang:** <…>
- Die Byte-Identität mit einer Datei ist eine Werkzeug-Zusage; L3 sieht sie nur an der Dogfood-Konfiguration, nicht an `--json`/`--doctor` — **Ausgang:** <…>

## 7. Closure-Notiz

Wird bei der Closure vom Planner geschrieben ([`AGENTS.md`](../../../../AGENTS.md) §3.10), nicht im Plan.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** eine Sub-Area, `*` (`ALL`), Schwelle erfüllt; alle berührten Sub-Areas GF.

**Vorgelagert — offene Beobachtungen sichten:** gelesen am gemergten Stand 2026-10-06, Zähler je `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l` (keine Erwartungswerte): `strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit` → 1, offen (die Bilanz steht hier vorab, L2 misst sie nach), `pin-digest-ohne-waechter` → 2, offen (Risiko in §6), `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` → 4, `geplant`, `werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten` → 5, `geplant` (der Werkzeug-Stand in §1 nennt Quelle, Stand und Messstelle), `ci-rennt-gegen-die-publikation-des-gepinnten-releases` → 1, offen.
