# Verifier-Report slice-056 — Ein Mutations-Fall fährt nur seinen Sensor

Rolle: **Verifier (Modul 11)**, getrennt von Implementation und Review. Prüfgegenstand ist die
**DoD-Behauptung**. Bei diesem Slice ist die Verifier-Frage besonders scharf: der Umbau macht den
Sensor **schneller** — die einzige Art, das falsch zu machen, ist ihn **blinder** zu machen.

**Datum:** 2026-07-27. **Slice:** `docs/plan/planning/in-progress/slice-056-mutate-laufzeit.md`.

**Grenze:** kein frischer Kontext (Modul 8); kompensiert durch Kommandos. Beide Messungen liefen
**allein** auf dem Docker-Daemon — eine parallel laufende Gate-Ausführung hätte die Vorher-Zahl
künstlich erhöht und den Gewinn geschönt.

## Was ich selbst erhoben habe

| DoD-Punkt | Kommando / Beleg | Ergebnis |
|---|---|---|
| (1) Zuordnung mechanisch | `narrow_sensor` gegen alle vier Formen | Go-Name → `test-go` · bats-Titel → `test-bats` · **leer → `test`** · **mehrzeilig → `test`** |
| (1) Zuordnung über die realen Fälle | Schleife über `test/mutations/*.sh` | **60** `test-go`, **31** `test-bats`, **2** eigener `verify`-Modus (`smoke`, `ci-lint`) |
| (1) fail-closed bewacht | Mutation **97** (leere Erwartung → `test-bats` statt `test`) | **rot gesehen** — der Driver-Test „fällt auf den vollen Satz zurück" fällt |
| (2) Aussage unverändert | fallweiser Vergleich beider Läufe (`ok`-Zeilen, Fall → erwarteter Wächter) | **genau ein Unterschied**: der neu hinzugekommene Fall 97. Alle 92 alten Fälle färben denselben Wächter rot wie vorher |
| (2) Summe | `make mutate` | **93 ok, 0 Befunde** |
| (3) Vorher | `time make mutate` (92 Fälle, alte Fassung) | **19m01s** |
| (3) Nachher | `time make mutate` (93 Fälle, neue Fassung) | **10m54s** — **−43 %**, über **einen Fall mehr** |
| Gates | `make gates` | Exit 0 — d-check 212/0, `comment-claims` 31/0, 0 `not ok` |

## DoD-Stand

**Bestätigt:** (1) vollständig · (2) **in der Substanz** vollständig · (3) vollständig ·
`make gates` grün. **Offen:** Doku-Update (`AGENTS.md` §4 / `harness/README.md`) und die
Closure-Notiz — beides Teil des Abschlusses.

**Die eine Abweichung, die der Verifier festhalten muss:** DoD (2) fordert wörtlich „weiterhin
**92 ok / 0**" **und** einen Wächter auf die neue Auswahl. Beides zusammen ist **nicht erfüllbar** —
der Wächter *ist* ein zusätzlicher Fall. Der Lauf steht folgerichtig auf **93 ok / 0**. Abgenommen
wird gegen die **Substanz** der Forderung („kein Fall verliert seinen Wächter"), und die ist
fallweise belegt, nicht summarisch: der Vergleich der beiden Lauf-Logs zeigt genau einen
Unterschied. Dieselbe Klasse wie die „byte-identisch"-Formulierung in slice-053 — ein DoD-Text, der
älter ist als das, was er selbst verlangt. Gehört in die Closure-Notiz, nicht in eine stille
Anpassung.

## Zur Messung selbst

Die Zahl ist **konservativ**: der Nachher-Lauf trägt einen Fall mehr, und beide Läufe liefen unter
denselben Bedingungen. Ein früherer Nachher-Lauf wurde **verworfen**, weil `make gates` zu diesem
Zeitpunkt rot war (Review-F-1) und der Fix in einer während des Laufs gesperrten Datei lag — die
Zeit wurde nicht ermittelt, es ging also keine Zahl verloren. Auch die **erste** Baseline wurde
abgebrochen: dort hätte ein parallel nötiger Gate-Lauf denselben Docker-Tag gebaut und die
Vorher-Zahl künstlich erhöht — was den Gewinn geschönt hätte.

Der Gewinn liegt über der vorab notierten Erwartung (~ein Drittel). Das ist ein **Befund**, keine
Bestätigung: der bats-Container wiegt mehr, als die reine Go-Build-Rechnung hergab. Was übrig
bleibt, benennt der Slice selbst — 60 Fälle × Go-Build, davon 94 % Übersetzung (Hebel B).

## Verdikt

**DoD bestätigt (alle prüfbaren Punkte).** Keine Rückkante zur Implementation. Der Sensor ist
schneller geworden, ohne blinder zu werden — und genau das, nicht die Zeit, ist die Aussage, die
hier abgenommen wird.
