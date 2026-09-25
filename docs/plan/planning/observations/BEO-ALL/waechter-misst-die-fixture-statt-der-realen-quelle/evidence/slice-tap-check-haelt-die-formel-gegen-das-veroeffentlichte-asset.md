**Vorgang:** slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset
**Fund:** `test/tap-nachzug.bats` fährt Stubs für `curl`, `docker`, Asset und Tap-Stand; ob die reale
Schnittstelle dieselbe Form liefert (Weiterleitung des Asset-Downloads, `Accept`-Kopf, 404-Form), hält
allein der reale Rot-Beleg, den der Verifier am 2026-09-25 gegen Tap `0.2.3` fuhr — dort stimmten die
Stubs mit der realen Antwort überein, **für den Tag der Messung**; der Beleg wandert mit jedem Schnitt.
Zwei weitere Eigenschaften der realen Quelle sind hermetisch nicht abgedeckt und **nie beobachtet**: das
Cache-Fenster der Schnittstelle (`max-age=60`, die Fälle spielen eine Stub-Folge alt → neu) und die
Reaktion auf ein erschöpftes anonymes Lese-Limit (der Fall *Tap unlesbar → 2* fährt einen Stub); ein
realer Fall beider liegt nicht vor. Ein Vorgang zählt einmal: die drei sind eine Gelegenheit
(`docs/reviews/2026-09-25-verify-slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset.md`
§3.1).
