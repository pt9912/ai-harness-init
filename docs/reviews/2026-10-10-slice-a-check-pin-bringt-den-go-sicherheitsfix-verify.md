# Verifikation slice-a-check-pin-bringt-den-go-sicherheitsfix

Stand HEAD 278d9eca. Rolle Verifier. Gegenstand: 57f1fa9a (Pin), d3868345 und 278d9eca (MR-093), Review a0120715.

**Verdikt gesamt: bestaetigt, 0 Findings.** Offen bleiben nur Planner-Punkte (Closure).

## DoD-Punkte

- **1 a-check v0.23.2 (Pin):** bestaetigt. `git show 57f1fa9a -- internal/emit/archgate.go`: genau eine Stelle, Tag, Digest `sha256:2368f7b3...f422` und Kopfkommentar. Der Commit nennt das `imagetools`-Kommando. Rot-Beleg selbst nachgetragen am realen Pin: `DefaultArchDigest` auf `...f423` verfaelscht, `make full-smoke` Exit 2 (make "Fehler 1"), Meldung: `docker run ghcr.io/pt9912/a-check@sha256:2368...f423 --print-mk: exit status 125 ... manifest unknown`, dann `FEHLER -- add-lang go apps/hex --arch hexslice ist NICHT Exit 0`. Das ist die genannte Referenz, aus dem richtigen Grund. `git checkout` der Datei, Baum sauber. Die Luecke "Tag passt nicht zum Digest geht durch" steht in der Commit-Message und in MR-093.
- **2 Gegenmessung (MR-063):** bestaetigt als Stichprobe, nur go selbst wiederholt. Frisches Ziel `--lang go --arch hexslice`: beide Digests liefern gruen `gesamt: 0 Befund(e)` (neu, Exit 0). Domain-Datei mit Import `app/internal/adapters/driven/notify` liefert an NEU und ALT je `core-impurity: 1`, `gesamt: 1 Befund(e)`, Exit 1, `greeting.go:7: core-impurity: Kern importiert app/internal/adapters/driven/notify`. Byte-Diff alt/neu, cpp und kotlin stehen nur in der Commit-Message (von mir nicht wiederholt, vom Review gelesen). `make full-smoke` fuehrt die Arch-Zaehne go/cpp/kotlin mit `core-impurity` (im Log 10 Treffer) am neuen Pin.
- **3 Go-Fassung:** bedingt bestaetigt. Nicht wiederholt; das Review hat amd64 wiederholt (go1.27.2). arm64 und die alte Fassung gelten nur nach Commit-Message und MR-093. Messbild `golang:1.27.2` ist per Tag gewaehlt. MR-093 nennt das als Grenze.
- **make gates gruen:** uebernommen. Der Auftraggeber nennt gruen und Stempel auf HEAD, ich habe nicht neu gefahren. **make full-smoke EXIT 0:** bestaetigt, auf sauberem Baum eigener Lauf, EXIT=0, "TRAEGER-FETCH"-Stufe bis "ZEILENENDEN IM KLON" OK.
- **Review:** bestaetigt. Der Report liegt vor, 0 HIGH und 0 MEDIUM. LOW-1 (MR-093 nannte MR-084 als Vorgaenger) ist in 278d9eca behoben: `sed -n 5,12p` von MR-093 nennt MR-084 jetzt als Form-Vorlage, der Ausschluss ist benannt.
- **Doku-Update (Architect-Commit):** bestaetigt. MR-093 und Index-Zeile liegen in eigenen Architect-Commits (d3868345, 278d9eca) vor, ohne Adresse in `.harness/baseline/`. Die Werte (Digest, Go-Fassung, Tabelle der Gegenmessung) stimmen mit der Commit-Message 57f1fa9a ueberein.
- **Closure-Notiz, Register, Risiko-Ausgaenge, Paarungen:** nicht Gegenstand dieser Verifikation, Planner (AGENTS.md 3.10). Noch offen, §7 ist Platzhalter.

## Plan gegen Code

- Plan §3 nennt nur `archgate.go`. `git show --stat 57f1fa9a` bestaetigt keine weiteren Produktdateien. Gebautes ohne Plan: nichts gefunden.
- Rueckfuehrungs-Bedingungen (abweichende Ausgabe alt/neu, fehlende Plattform, Go < 1.27.2) sind nach den Belegen nicht eingetreten.

## Mutationsfaelle

- `make mutate-auswahl` (SLICE=slice-a-check-pin-bringt-den-go-sicherheitsfix): 5 Faelle ueber f4e7410f..HEAD, Schwelle 8, Urteil lokal, kein CI-Branch noetig.
- `make mutate MUTATE_CASES=<5 Faelle>` (639, 641, 66, 69, 70): `5 ok, 0 Befund(e)`, Ausgabe selbst: "TEILLAUF 5 von 654 -- kein Beleg".
- **Grenze:** Die Faelle pruefen Wiring und Adaption (`adaptArchMK` pinnt auf die erzeugende Referenz, Mount-Scope, Nutzervariable), nicht den Wert. Fall 66 verfaelscht den Pin in der Verdrahtung, nicht Tag-gegen-Digest. Dass der Wert der richtige Digest zum Tag ist, belegen nur `imagetools` (Review-Stichprobe), `full-smoke` (Digest loest auf und liefert den Befund `core-impurity`) und MR-093. `BEO-ALL/pin-digest-ohne-waechter` ist weiter offen.

## Offen fuer den Planner

- Closure §7 samt Lerneintrag und die drei Risiko-Ausgaenge aus §6 (3x-Uebertritt von `gepinntes-bild-ohne-schwachstellen-scan` mit diesem Beleg, Lese-Schritt nach ADR-0085).
- Von mir nicht wiederholt: cpp und kotlin der Gegenmessung, arm64-Go-Fassung. Keine Findings daraus.
