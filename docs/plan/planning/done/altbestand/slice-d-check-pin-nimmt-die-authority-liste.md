# Slice slice-d-check-pin-nimmt-die-authority-liste: Der d-check-Pin springt `v0.81.0` → `v0.82.0`, und `targets.authority` nimmt eine Liste

**Welle:** ohne Welle.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Digest-Pin), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (Grenze des Gates), [`MR-079`](../../../../harness/conventions.md#mr-079) (Vorgänger der Pin-Linie, Eintragsform), [`MR-063`](../../../../harness/conventions.md#mr-063) (Gegenmessung je aktivem Modul), [`MR-065`](../../../../harness/conventions.md#mr-065) (history-lesender Lauf), [`MR-054`](../../../../harness/conventions.md#mr-054).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

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

- [x] **L1 — Pin `v0.82.0` an beiden Stellen, Digest nachgemessen, Fragment re-adaptiert.** Rot: `make test` fällt (`TestDefaultImage_MatchesCanonical`/`TestDefaultDigest_MatchesCanonical`), solange `d-check.mk` und `internal/emit/emit.go` auseinanderlaufen — einmal mit nur einer gezogenen Stelle gesehen ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [x] **L2 — Strenge-Bilanz und Gegenmessung je aktivem Modul** ([`MR-063`](../../../../harness/conventions.md#mr-063)): `--print-mk`-Diff, `make docs-check` vorher/nachher im Dogfood und am frisch emittierten `--lang go`-Ziel, je aktivem Modul auf Nicht-Null-Basis; der history-lesende Lauf nennt, woher der Klon die Objekte liest ([`MR-065`](../../../../harness/conventions.md#mr-065)). Rot: je Modul ein eingesetzter Verstoß, der unter beiden Digests fällt. Ergebnis als Übergabe-Artefakt für den Architect im Implementer-Bericht.
- [x] **L3 — Die Byte-Identität mit einer Datei ist gesehen:** `targets` im Dogfood unter `authority: harness/README.md` und unter `authority: [harness/README.md]` liefert dieselbe Ausgabe, und ein eingesetztes undokumentiertes Target färbt beide gleich rot (`gate-undocumented`); die Probe ändert `.d-check.yml` nicht dauerhaft.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Der Adaptions-Eintrag des Architect für diesen Sprung liegt vor (§4).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

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

- **(1)** Der Digest ist nur über die Werkzeug-Ausgabe belegt, kein Sensor hält ihn gegen den Tag — **Ausgang:** *weiter offen* — der Pin `v0.82.0` trägt dieselbe Lücke; Beleg in [`BEO-ALL/pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/observation.md).
- **(2)** Die Byte-Identität mit einer Datei ist eine Werkzeug-Zusage; L3 sieht sie nur an der Dogfood-Konfiguration, nicht an `--json`/`--doctor` — **Ausgang:** *entfallen* — die Verifikation misst `--json` und `--doctor` unter String- und Listen-Form byte-gleich je Strom, grün und mit drei roten Sonden; bei zusammengeführten Strömen ist die Reihenfolge nicht festgelegt, unabhängig von der Form ([`MR-080`](../../../../harness/conventions.md#mr-080)).

## 7. Closure-Notiz

- **Was hat funktioniert:** Die Vorab-Strenge-Bilanz in §1 hielt unter L2 (Dogfood und emittiertes Ziel, je Modul mit Basis); L1 an der realen Pin-Stelle rot gesehen.
- **Was ging anders als geplant:** Der Sprung feuert den Re-Evaluierungs-Trigger von [`ADR-0045`](../../adr/0045-authority-wechsel-senkt-eine-richtung.md); das Trigger-Audit bestätigt die ADR ([`MR-080`](../../../../harness/conventions.md#mr-080)). Der Kommentar zum `targets`-Block der `.d-check.yml` nannte eine Schema-Grenze, die `v0.82.0` nicht mehr hat; er beschreibt jetzt die Konfiguration.
- **Steering-Loop-Eintrag:** benannte Lücke — d-check legt die Reihenfolge zusammengeführter Ströme (`2>&1`) nicht fest; eine Byte-Gleichheits-Aussage über seine Ausgabe misst je Strom. Die Grenze steht in [`MR-080`](../../../../harness/conventions.md#mr-080). Dazu: die Kommandos einer Aufbau-Anleitung, auf die ein späterer Eintrag verweist, sind wörtlich nachfahrbar zu halten. Beides gezählt, nicht verkörpert.
- **Beobachtungs-Register (`../observations/`):** Belege in [`BEO-ALL/pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/observation.md) (Risiko 1), [`BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`](../observations/BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten/observation.md) (Review-Klasse *Werkzeug-Aussage im Bestand vom Pin-Sprung falsifiziert*), [`BEO-ALL/aufbau-anleitung-stellt-die-gemessene-lage-nicht-her`](../observations/BEO-ALL/aufbau-anleitung-stellt-die-gemessene-lage-nicht-her/observation.md) (Review INFO) und neu [`BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung`](../observations/BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung/observation.md) (Review-Klasse *Pin-Sprung feuert Trigger einer Accepted-ADR ohne Nennung*). `pin-digest-ohne-waechter` erreicht damit 3× (`ls ../observations/BEO-ALL/pin-digest-ohne-waechter/evidence/*.md | wc -l`); den Ausgang weist der Lese-Schritt der nächsten Welle-Closure zu.
- **Folge-Slices:** keine.
- **Risiken aus §6:** (1) *weiter offen*, (2) *entfallen* — Gründe in §6.
- **Drei Paarungen:** Paarungen geprüft am 2026-10-06 nach dem `git mv`: (a) kein `liegt in` in §7 — kein Gegenstand; (b) keine Folge-Slices; (c) die vier genannten `BEO-ALL/…` existieren, `ls …/evidence/*.md | wc -l` → 2 · 3 · 1 · 6 (`sed -n "/^## 7/,/^## 8/p"` über §7, `grep -oE "BEO-ALL/[a-z0-9-]+"`).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** eine Sub-Area, `*` (`ALL`), Schwelle erfüllt; alle berührten Sub-Areas GF.

**Vorgelagert — offene Beobachtungen sichten:** gelesen am gemergten Stand 2026-10-06, Zähler je `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l` (keine Erwartungswerte): `strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit` → 1, offen (die Bilanz steht hier vorab, L2 misst sie nach), `pin-digest-ohne-waechter` → 2, offen (Risiko in §6), `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` → 4, `geplant`, `werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten` → 5, `geplant` (der Werkzeug-Stand in §1 nennt Quelle, Stand und Messstelle), `ci-rennt-gegen-die-publikation-des-gepinnten-releases` → 1, offen.
