**Lauf:** `make full-smoke`, Stand `7c750972`, 2026-11-26 — die Traeger-Fetch-Stufe (Stufe (d), *Der Gelingens-Fall des Konsumenten-Aufrufs*), gemessen im Ziel-Klon mit dem aus `TRAEGER_TAG` `v0.10.0` gefetchten Träger:

```text
  Review-Reports (ohne Stub):           0
  Verweise: 0 Datei(en) betroffen (0 Praefix-, 0 geschwister-relative, 0 aufsteigende Fundstelle(n))
  Sperren: 1 — der schreibende Lauf braeche ab.
    [untergrenze] 1 wellenlose(r) Slice(s) liegen flach in docs/plan/planning/done/, aber kein docs/plan/planning/done/*/archiv.zip setzt eine Untergrenze
      'wellenlos seit der letzten Closure' umfasste damit den gesamten Altbestand
      die Archivierung des Altbestands ist ein eigener Vorgang — danach ist die Grenze beobachtbar
make[1]: *** [harness/mk/archivierung.mk:41: archive-welle] Error 3
full-smoke: FEHLER — AUSGANG BAUM: make archive-welle mit dem gefetchten Traeger (golang). ...
```

Der Ziel-Klon führt in `docs/plan/planning/done/` allein die synthetische Welle (`welle-fetch.md`, `welle-fetch-results.md`, `slice-997-fetch-smoke.md` mit `Welle: welle-fetch`) und sonst nichts; der Vorschau-Zähler liest Mitglieder 1 und wellenlos 1 — der gefetchte Träger zählt anders als die Quelle, deren Meldung `archive.zip` trägt. Make-Meldung `Error 3` (Sperren-Bruch im Fragment-Rezept), `make` meldet über die Kette `Error 1`.

Nachmessung der Gegenprobe je Fundlisten-Form: dieselbe Stufe über dem gerade gebauten Träger (Stufe (b), Abschnitt Archivierung im Ziel) führt Vollzug und die zwei Sperren — die Differenz trägt der gefetchte Träger, nicht der Fragment-Text.
