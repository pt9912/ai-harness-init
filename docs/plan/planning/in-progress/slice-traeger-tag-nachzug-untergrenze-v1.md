# Slice slice-traeger-tag-nachzug-untergrenze-v1: Release-Schnitt — der Pin-Nachzug trägt die Untergrenze-Fassung am gepinnten Traeger

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — keine Closure-Bedingung, die von der DoD dieses Slices
verschieden ist ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird));
die Folgepflicht 3 von [`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
Festlegung 2 (der Release-Schnitt als Folge-Posten) trägt je Slice.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md),
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md),
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md),
[`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)
(die `done/*/archive.zip`-Abgabe, deren Untergrenze der Konsum misst).

**Berührte Spec-Stellen:** — (keine: der Slice berührt nur Pin-Stellen der
Werkzeug-Ebene; der Verweis zeigt **aufwärts**, die Spec nennt diesen Slice nie).

**Verantwortlich:** pt9912 (Zweig slice-traeger-tag-nachzug-untergrenze-v1)

**Autor:** pt9912 (Rolle Planner). **Datum:** 2026-11-28.

---

## 1. Ziel und Abgrenzung

**Ziel:** der Release-Schnitt aus dem heutigen Quell-Stand — der Release-Tag
wird neu geschnitten und die Pin-Kette zieht nach: `TRAEGER_TAG` im
Dogfood-`Makefile` (gemessen: `grep -n 'TRAEGER_TAG ?=' Makefile` → Zeile 53,
`grep -cE '^TRAEGER_SHA256' Makefile` → 6) und der Tag-Pin des emittierten
Fragmentes des Traeger-Fetch (Zielort des Ziels je
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
Festlegung 3; Quellpfad `internal/emit/templates/enforce/traeger.mk`,
gemessen: `grep -n 'TRAEGER_TAG ?=' internal/emit/templates/enforce/traeger.mk`
→ Zeile 25) je
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
(der emit-Pin trägt nur den Tag). Danach trägt der gepinnte Traeger die
Untergrenze-Fassung der
`done/*/archive.zip`-Abgabe ([`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)),
die v0.10.0 nicht führt — je der Nehmer-Diagnose am Konsum-Bruch
`[untergrenze]` (Frisch-Rechnung: der Quell-Stand meldet „Sperren: keine",
v0.10.0 sperrt an derselben Saat) — und die CI-[untergrenze]-Naht trägt je
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
Festlegung 2 (Folgepflicht 3) künftig den laut-Bruch statt eines
Exit-2-Mismatches, sobald ein Werkzeug-Fortschritt am Unterkommando dem Pin
zuvorkommt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Untergrenze-Fassung selbst** — es wäre ein anderer Vorgang: der
  Quell-Stand trägt sie (gepinnt heute: nicht), je der Kette
  `slice-altbestand-stubs-voll-v1` → `slice-full-smoke-gates-echt-gruen` →
  `slice-ci-stempel-eingecheckt-v1`. Dieser Slice zieht nur den Pin der
  fertigen Fassung; ein Werkzeug-Fortschritt am Unterkommando gehört nicht
  hierher.
- **Die CI-Verbrauchsstempel-Kette** (`slice-ci-stempel-eingecheckt-v1`) —
  Bestand bleibt bewusst stehen: die je-Check-Keys sind committet und ändern
  sich durch den Pin-Nachzug nicht.
- **Der Warte-Schritt der mutate-branch-Worker-Hälfte hinter der Publikation** —
  es wäre ein anderer Vorgang: die Grenze trägt der Register-Eintrag
  [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/state.md)
  am Ort benannt; ein Geplanter nimmt sie dort an, nicht hier.

## 2. Definition of Done

- [ ] **Liefer-Punkt 1 — Release-Schnitt vollzogen:** aus dem heutigen
      Quell-Stand sind die Release-Artefakte gebaut und der neue Tag gepublisht
      — `make release-artifacts DEST=<dir>` (Plattform-Matrix
      [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix))
      mit `SHA256SUMS`; Beleg lesend aus der Publikation: `make
      traeger-pins-check TAG=<neu>`; die Tap-Formel ist nachgezogen, `make
      tap-nachzug TAG=<neu>` je
      [`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)-Form.
- [ ] **Liefer-Punkt 2 — Pin-Nachzug:** die Pin-Kette trägt `<neu>` —
      `TRAEGER_TAG` und die sechs `TRAEGER_SHA256_*`-Pins im Dogfood-`Makefile`,
      der Tag-Pin des emit-Fragmentes `internal/emit/templates/enforce/traeger.mk`;
      `make traeger-pins-check` (Default `TRAEGER_TAG`) und `make tap-check`
      sind grün je
      [`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)-Form;
      die Pin-Kopplungs-Fälle `test/mutations/554-traeger-tag-im-fragment-umbenannt-full-smoke.sh`
      und `test/mutations/555-traeger-tag-im-fragment-umbenannt-pin-kopplung.sh`
      bleiben grün.
- [ ] **Liefer-Punkt 3 — CI-Naht:** der von CI am frischen Klon gefetchte
      Traeger trägt die Untergrenze-Fassung — der Konsum misst die
      `done/*/archive.zip`-Untergrenze ohne `[untergrenze]`-Bruch; die
      laut-Bruch-Zusage der Sperren-Form ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
      Festlegung 2) bleibt unangetastet.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist — die
      Release-Prozedur (`docs/user/releasing.md`) trägt die Schritte des
      Schnitts.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — eine
      weitere Datei in ein vorhandenes `evidence/` oder ein neues Verzeichnis;
      keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind von der nächsten
      Welle-Closure geprüft.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` (Pin-Block, Zeilen 53–61) | update | `TRAEGER_TAG` + die sechs `TRAEGER_SHA256_*`-Pins je `SHA256SUMS` der neu gebauten Assets |
| `internal/emit/templates/enforce/traeger.mk` (Zeile 25) | update | der emit-Pin trägt je [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) nur den Tag — Nachzug auf `<neu>` |
| `test/traeger-fetch.bats` (Zeilen 133–134, Umsetzungs-Fund) | update | der pin-kopplung-Fall hält das Tag-Literal an beiden Pin-Stellen — der Wert wandert je Release-Schnitt mit dem Pin, sonst fällt `make test` an der Fassung ohne Zugs-Grund |

**Ansatz:** der Bump folgt der Publikation, nie umgekehrt — die
Prüfsummen-Pins übernehmen die `SHA256SUMS`-Einträge des neu geschnittenen
Tags; die Verifizierung bleibt fail-closed vor der Ablage. Die Netz-Züge je
Besorgung-Fassung ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
Festlegung 4,
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)):

- `make traeger-pins-check TAG=<neu>` — lesend, Prüfsummen gegen die Publikation.
- `make tap-nachzug TAG=<neu>` — schreibend, braucht `TAP_TOKEN` und Netz.
- `make traeger-fetch` — legt den Traeger je neuem Pin ab, fail-closed.

Jeder braucht Netz an **genau** seinem Aufruf; nichts davon ist Gate („NICHT
in gates").

## 4. Trigger

**Start** (`next` → `in-progress`): der Konsum-Bruch `[untergrenze]` an der
gepinnten Fassung ist gemessen (Nehmer-Diagnose, Commit `f6dd26c9`); die
Folgepflicht 3 je
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
Festlegung 2 führt den Release-Schnitt als Folge-Posten — der ist mit dem
Untergrenze-Fortschritt am Unterkommando eingetreten.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): mehr als drei
  Liefer-Punkte — etwa, wenn der Schnitt neben dem Tag zusätzlich
  Werkzeug-Fortschritt am Unterkommando (eine Fassung über die Untergrenze
  hinaus) tragen muss → re-slicen je Pin-Kette.
- `in-progress` → `open` (blockiert — Carveout?): die Publikation ist am
  Registry-/Tap-Besorgungs-Weg nicht kontrollierbar (Netz- oder Token-Ausfall)
  — dann Carveout-Klärung je
  [`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 2; der Pin bleibt je Bestand, keine Senkung (`AGENTS.md` §3.5).

## 5. Closure-Trigger

§2 vollständig; Belege: `make traeger-pins-check` grün gegen den neuen Tag,
`make traeger-fetch` und der Konsum-Lauf am gefetchten Traeger ohne
`[untergrenze]`-Bruch, `make gates` grün; Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- **Der Netz-Zug je Besorgung-Fassung:** die `SHA256SUMS` des Tags ist die
  Quelle der Prüfsummen; bricht der Registry-Zug oder weicht die Publikation
  ab, bricht `traeger-pins-check` fail-closed vor der Ablage
  ([`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md))
  — **Ausgang:** bei Closure entscheiden — eingetreten: Carveout am Netz-Zug
  (mit Trigger; die Pin-Schwelle bleibt, `AGENTS.md` §3.5);
  entfallen: Publikation deckt Pins und Tap-Formel.
- **Die mutate-branch-Worker-Grenze hinter der Publikation:** folgt der Tag
  dem Push von `main` später, fällt der Worker-Konsum an `traeger-fetch`
  (Register
  [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/state.md),
  5 Belege) — **Ausgang:** weiter offen: der Register-Eintrag trägt die Grenze
  am Ort; sie ist nicht Gegenstand dieses Pin-Nachzugs.
- **Die Tap-Fassung:** der schreibende Nachzug braucht `TAP_TOKEN` und Netz;
  Formel-Drift gegen das Asset zeigt `make tap-check` erst nach dem Zug
  ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md))
  — **Ausgang:** bei Closure je `tap-check` gemessen; Drift → eingetreten mit
  Folge-Slice-Kennung.

## 7. Closure-Notiz

- *(wird bei dessen Closure gefüllt)*

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind die Pin-Blöcke im
Dogfood-`Makefile` und das emit-Fragment `internal/emit/templates/enforce/traeger.mk`
(Kürzel `ALL`); beide erfüllen die Schwelle ≥ 2 von 3 Achsen.

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen.
Treffer im Kürzel `ALL`:

- [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/state.md)
  — 5 Belege, Stand verkörpert (`make release-warten`); dieser Slice fährt die
  Release-Schnitt-Klasse erneut und ergänzt bei Closure einen Beleg — kein
  neuer Übertritt.
- [`BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/state.md)
  — 6 Belege, Stand geplant (Kennung
  `slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle`, liegt in
  `open/`); die Diagnose dieses Slices ist je dieser Messklasse am Quell-Stand
  geführt — kein weiterer Übertritt.
- [`BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut`](../observations/BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut/state.md)
  — 2 Belege (< 3×), Stand offen.
- [`BEO-ALL/aufruf-ohne-wirkung-am-pin-traegt-nur-eine-fixture`](../observations/BEO-ALL/aufruf-ohne-wirkung-am-pin-traegt-nur-eine-fixture/state.md)
  — 1 Beleg (< 3×), Stand offen.

Kürzel `TOOLS`: keine Treffer (die Ablage trägt zwei Einträge, keiner berührt
die Pin-Kette).

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF — der
Modus-Begründungsblock entfällt.
