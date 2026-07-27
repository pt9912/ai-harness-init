# Verifier-Report slice-052 — `v0.1.1`, die Nutzer-Doku sagt, was das Werkzeug tut

Rolle: **Verifier (Modul 11)**, getrennt von Implementation und Review. Prüfgegenstand ist **nicht**
die Code-Qualität (Modul 10), sondern die **DoD-Behauptung** und die Plan-vs-Artefakt-Übereinstimmung.
Kanonische Rollen-Definition: `.harness/baseline/v3.5.2/regelwerk/modul-11-verification.md` —
*„Behauptung ohne Bestätigung ist die häufigste Verifier-Lücke"*; eine DoD-Verletzung ist eine
**Verifier-only-Klasse**.

**Datum:** 2026-07-27. **Slice:** `docs/plan/planning/in-progress/slice-052-release-v0-1-1.md`.

**Range:** `8170a78..5b596b0`. Slice-eigen: `1fe2496` (Plan) → `8170a78` (Move `open`→`in-progress`)
→ `3c7ad4e` (Link-Reconciliation) → `eeead0b` (Impl) → `5b596b0` (Review-Report).

**Mandat:** `make`-Targets selbst gefahren. `git status` war vor und nach allen Läufen leer; der
einzige Schreibvorgang außerhalb dieser Datei war eine **rot-Gegenprobe** an einer Kopie des
Handbuchs, die im selben Schritt zurückgespielt wurde (Beleg unten: leerer `git status`).

## Was ich selbst erhoben habe

| DoD-Punkt | Kommando | Ergebnis |
|---|---|---|
| (1) getaggter Stand | `git show v0.1.0:docs/user/benutzerhandbuch.md \| grep -c "Derzeit nicht\|keine Release-Versionsnummer"` | **2** — die Falschaussage steckt im Tag |
| (1) heutiger Stand | dasselbe Muster auf `HEAD` | **0**; die FAQ sagt heute „Ja, ab `v0.1.0`" (Zeile 499) |
| (2) Bedienkonzept | `grep -n 'arbeitet in \*\*einem\*\* Schritt' docs/user/benutzerhandbuch.md \| grep -v '^[0-9]*:\| '` | **0** — im Rumpf weg; Zeile 181 sagt „arbeitet in **getrennten Schritten**" |
| (2) Gegenprobe **rot gesehen** | alten Wortlaut per `sed` in Zeile 181 zurückgespielt, dasselbe Kommando | **1** — der Sensor greift; danach zurückgespielt, `git status` leer |
| (3) alle Fundstellen | `grep -n "neueres Regelwerk nach\|neueren Kurs-Stand" docs/user/benutzerhandbuch.md README.md` | nur korrigierte Treffer (183/305/493) + das §11-Zitat; alt 179/301/309/489 + README 37 sind alle angefasst (309→313 trägt die Aussage gar nicht mehr) |
| (3) Deckung im Code | `cmd/ai-harness-init/main.go:277`, `internal/fetch/baseline.go:48` | `envOr("COURSE_TAG", fetch.DefaultTag)`, `DefaultTag = "v3.5.2"` — die Prosa sagt genau das |
| (4) Windows-Hinweis | `grep -c "Hinweis für Windows"` · `grep -ciE "sign\|codesign\|signtool\|authenticode"` über **alle drei** Workflows | **1** · **0/0/0** — der Hinweis bleibt im Belegten |
| `spec/` unberührt | `git diff --name-only 8170a78~1..HEAD` | `README.md`, `docs/user/benutzerhandbuch.md`, zwei Plan-/Report-Dateien — **kein `spec/`-Pfad** ([`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)) |
| Gates | `make gates` | **Exit 0**, `baseline-verify` v3.5.2 OK (42 Dateien), `d-check` 198 Datei(en) / 0 Befund(e) |
| `make mutate` | `grep -rn "README.md" test/mutations/*.sh`; `grep -rn benutzerhandbuch test/ Makefile harness/tools/` | kein Wächter auf den zwei geänderten Dateien — der Verzicht ist **begründet**, nicht stillschweigend |

## DoD-Stand

**Bestätigt (5):** (2) · (3) · (4) · `spec/` unberührt · `make gates` grün samt begründetem
`mutate`-Verzicht.

**Offen (4) — alle hinter dem Tag, keiner davon durch den Diff auflösbar:**

1. **(1) „Der getaggte Stand verneint seinen eigenen Release nicht mehr."** Auf `main` erfüllt, im
   Tag noch nicht: `git tag --list` kennt nur `v0.1.0`. Der Punkt ist **per Konstruktion** erst
   nach Schritt (4) der Plan-Reihenfolge einlösbar.
2. **Tag `v0.1.1`, `release`-Lauf grün über acht Jobs, sechs Assets gezählt.**
3. **Assets gegen die CI-Artefakte gehalten** (sha256-Mengenvergleich).
4. **Closure-Notiz mit Steering-Loop-Eintrag.**

**Keine DoD-Verletzung gefunden:** kein bestätigter Punkt ist behauptet-aber-nicht-erfüllt, und
kein offener Punkt ist als erfüllt ausgegeben.

## Zum Review-Finding F-1 (Modul-11-Sicht)

Der Reviewer meldet MEDIUM auf den **Beleg**, nicht auf den Text. Aus Verifier-Sicht bestätigt:
`grep -c 'arbeitet in **einem** Schritt'` liefert auf dem Commit-Stand **1**, nicht die
protokollierten **0**. Der geschärfte Sensor —
`grep -n … | grep -v '^[0-9]*:| '` (Tabellenzeilen der Änderungshistorie ausgenommen) — liefert
**0** und wurde **rot gesehen** (alten Wortlaut zurückgespielt → **1**). Damit ist die Eigenschaft
belegt, die der ursprüngliche Beleg nur behauptet hat. Der Commit `eeead0b` wird nicht
umgeschrieben; der korrigierte Beleg gehört in die Closure-Notiz — dort schlägt ihn der nächste
Leser nach.

## Verdikt

**DoD bestätigt, soweit ohne Tag entscheidbar: 5 von 9.** Die vier offenen Punkte hängen
ausnahmslos am Release-Schritt und sind im Plan (§3 Reihenfolge, §5 Closure-Trigger) genau so
vorgesehen. **Keine Rückkante zur Implementation.** Der Tag ist nach außen wirkend — die Freigabe
holt der Implementer beim Nutzer ein (Plan §6), nicht der Verifier.
