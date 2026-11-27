# CO-007: CI auf main rot vorgefunden — `gates` (Runner-Erschöpfung) und `full-smoke` (Träger ohne `archive-welle`)

**Status:** Aktiv.

**Datum angelegt:** 2026-11-27. **Letzte Prüfung:** 2026-11-27.

**Betroffenes Gate:** `make gates` auf CI — die GitHub-Actions-Jobs `gates` und
`full-smoke` ([`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)).
Lokal ist der Nachweis seit dem Auftraggeber-Beschluss 2026-11-27 nicht
herstellbar (Docker-Daemon bleibt aus, [`AGENTS.md`](../../../AGENTS.md) §3.9 in
der Übergangs-Fassung; Stempel-Marker `.harness/state/stop-gate-ausgesetzt`).
Das Gate trägt keine Schwelle — kein ADR-Verweis nach dieser Zeile.

**Geltungsbereich:** die zwei CI-Jobs auf main und den DoD-Punkt, der an sie
verweist; nicht andere Gates und nicht die lokalen Targets einzeln.

**Folge-Slice:** der Träger-Teil (a) trägt an
[`slice-binraire-ziehen-ohne-docker`](../planning/done/slice-binraire-ziehen-ohne-docker.md);
die Fork-Erschöpfung (b) ist im Beobachtungs-Register geführt
(`BEO-ALL/gates-keys-fork-erschoepfung-bricht-den-ci-gates-lauf`) und hat von
der anlegenden Closure keinen eigenen Slice in `open/` bekommen — ob die
Heilung einen eigenen trägt, schneidet die Welle-Closure nach dem Trigger.

Regeln: Baseline-Regelwerk `modul-07-carveouts.md` §Ziel-Form: Carveout — ein
Carveout braucht immer einen Auflösungs-Trigger **und** einen Folge-Slice.

---

## Begründung

Beide Ursachen sind **vorgefunden** — Lauf 45939443193 (2026-11-27T04:21,
vorgängig zu allen Commits des Slices `slice-cr-lh-qa-02-03-ohne-docker`):

- **(a) Job `full-smoke`:** der per `TRAEGER_TAG` gepinnte Release-Träger
  `v0.10.0` führt das `archive-welle`-Unterkommando nicht; der
  Konsumenten-Aufruf endet mit Exit 2 — die Klasse der Festlegung 2 von
  [ADR-0058](../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md): der
  gefetchte Träger hinkt dem Dogfood-Vorauslauf des Haupt-Branch hinterher.
- **(b) Job `gates`:** `harness/tools/gates-keys.sh: fork: retry: Resource
  temporarily unavailable`, sechs Meldungen, dann `make: *** [Makefile:743:
  gates] Terminated` — Runner-Ressourcenerschöpfung in der Tier-2-Maschinerie
  aus `slice-gates-pruefgegenstand-stempel-v1` (wellenlos, geschlossen); der
  Job stirbt, bevor `docs-check` fährt.

Am HEAD-Stand des Slices wiederholt sich Signatur (b) messbar (Lauf
45944570095, gates-Job `140326215480`): `gh run view --job 140326215480 --log
| grep -c 'fork: retry'` → **6**, danach `make: *** Terminated`. Kein
Befund in beiden Logs trägt auf den Slice-Umbau — ein CR über
`spec/lastenheft.md` erzeugt keine der beiden Meldungen.

Die zwei Befunde liegen während der Welle unter diesem dokumentierten
Carveout, nicht unter stiller Duldung.

## Auflösungs-Trigger

**Abschluss von [welle-ohne-docker](../planning/welle-ohne-docker.md)** — ihr
Übergangs-DoD (voller Mutations-Vollauf docker-los und `make gates` grün auf
einem Runner ohne Docker-Daemon) ist das nächste Ereignis, an dem beide
Störstellen angetroffen werden; der Zustand ist an der Roadmap prüfbar (Welle
steht unter *Abgeschlossene Wellen*). **Danach** die CI-Heilung als eigener
Zug, zwei Befund-Klassen:

- **(a) Träger-Vertrag** — die Unterkommando-Fassung des `archive-welle`-Teils
  zieht [`slice-binraire-ziehen-ohne-docker`](../planning/done/slice-binraire-ziehen-ohne-docker.md).
- **(b) Fork-Erschöpfung in `harness/tools/gates-keys.sh`** — Befund gegen
  `slice-gates-pruefgegenstand-stempel-v1`, Register-Zeile oben; ob sie einen
  eigenen Folge-Slice trägt, schneidet die Welle-Closure.

Kein Zeit-Trigger ("sobald Zeit"), ein Ereignis-Trigger.

## Geltungs-Konfiguration

Kein Gate-Tool ist konfiguriert — die Ausnahme ist dokumentiert, nicht
maschinell gesetzt:

| Datei | Zeile/Section | Wert |
|---|---|---|
| [`slice-cr-lh-qa-02-03-ohne-docker.md`](../planning/done/slice-cr-lh-qa-02-03-ohne-docker.md) | §2, Zeile `make gates` grün | bedingt — Verweis auf CO-007 |

## Verifikation (nach Auflösung)

- [ ] `make full-smoke` auf main grün — Störstelle (a) geheilt.
- [ ] `make gates` auf einem CI-Runner ohne Docker-Daemon grün — Störstelle
      (b) geheilt; `docs-check` fährt im Job.
- [ ] Die Register-Zeile `BEO-ALL/gates-keys-fork-erschoepfung-bricht-den-ci-gates-lauf`
      trägt nach dem Lese-Schritt einen Ausgang (oder die Begründung, dass die
      Klasse nicht mehr auftreten kann).
- [ ] Datei wird nach `docs/plan/carveouts/done/` bewegt (reiner `git mv`). <!-- d-check:ignore (done/ entsteht erst bei erster Carveout-Auflösung) -->
- [ ] Folge-Slice-Arbeit geschlossen oder explizit dokumentiert.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-27 | Angelegt — beide Ursachen vorgefunden (Lauf 45939443193), Closure von `slice-cr-lh-qa-02-03-ohne-docker` | [`slice-cr-lh-qa-02-03-ohne-docker.md`](../planning/done/slice-cr-lh-qa-02-03-ohne-docker.md) |
