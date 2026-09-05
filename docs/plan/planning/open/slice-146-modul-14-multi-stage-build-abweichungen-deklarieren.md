# Slice slice-146: Modul 14 „Multi-Stage-Build" — zwei Regeln bekommen ihren Ausgang

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — die Closure-Bedingung ist von dieser DoD nicht verschieden; der Fund kam
aus [welle-10](../done/welle-10-re-baseline.md)s Durchgang 3
([slice-084](../done/slice-084-stichprobe-gegen-bestand.md)), gehört aber selbst nicht zu deren
Slice-Menge (§4 dort: „Ein Delta, das eigene Arbeit verlangt, wird als Slice in `open/` notiert" —
nicht Fracht der Welle).

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (die
Blankett-Klausel, deren „wo kein Eintrag sie ausnimmt, gilt die Klausel fort" hier zwei
Ausnahmen fehlt), [`ADR-0003`](../../adr/0003-go-native-binaries.md) (Native-Binary-Distribution
— der wahrscheinliche Grund für die erste der zwei Ausnahmen),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Bezugspunkt der
zweiten Regel — Image-Hash als Reproduzierbarkeits-Anker).

**Berührte Spec-Stellen:** `—`. Die Norm-Änderung landet im Adaptions-Block, nicht in der Spec.

**Verantwortlich:** Architect (pt9912) — der gesamte Liefergegenstand ist der Ausgang je Regel im
Adaptions-Block von [`harness/conventions.md`](../../../../harness/conventions.md), ein
Architect-Artefakt ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Präzedenzfall
[slice-082](../done/slice-082-adaptions-durchgang.md) trägt dieselbe Besetzung. Das Feld weicht
damit von der Default-Besetzung ab, die Baseline-Regelwerk `modul-05-planning-harness.md`
§Lifecycle als State Machine nennt (*„den Rolleninhaber der Implementer-Rolle"*).

**Autor:** Planner. **Datum:** 2026-08-31.

---

## 1. Ziel

Zwei Regeln aus `modul-14-docker-harness.md` §Multi-Stage-Build: die operativen Disziplinen sind
im `Dockerfile` dieses Repos weder umgesetzt noch im Adaptions-Block als Abweichung geführt —
gefunden von [slice-084](../done/slice-084-stichprobe-gegen-bestand.md) §9 (Durchgang 3 von
welle-10, Stichprobe gegen den Bestand). Jede der zwei bekommt einen verbuchten Ausgang:
**Adoption** (der Dockerfile-Mechanismus wird ergänzt) oder **deklarierte Abweichung** (neuer
`MR-<NNN>`-Eintrag mit Begründung).
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)s Blankett-Klausel trägt
danach wieder — für diesen Abschnitt korrekt statt stillschweigend falsch.

## 2. Definition of Done

- [ ] **Runtime-Stage-Regel** (*„Stages trennen: deps → build → runtime, Distroless/nonroot, keine
      Build-Toolchain im Ergebnis"*) hat einen Ausgang: Adoption (Dockerfile bekommt eine
      `runtime`-Stage) oder deklarierte Abweichung — Beleg-Kandidat
      [`ADR-0003`](../../adr/0003-go-native-binaries.md) („kein OCI-Image als Vertriebsmittel"),
      geprüft und nicht nur unterstellt: Trägt die ADR die **Runtime-Stage**-Frage überhaupt, oder
      nur die Frage nach dem *Vertriebskanal* — zwei verschiedene Dinge, die ein Kurzschluss
      gleichsetzen könnte (dieselbe Falle wie `BEO-ALL/adaptions-achse-1-kurzschluss`).
- [ ] **Image-Hash-Regel** (*„Image-Hash im Build-Output festhalten … harness/image-hash.txt"*) hat
      einen Ausgang: Adoption (ein Mechanismus, der den Digest des Build-Outputs festhält, analog
      `harness/tools/working-tree-hash.sh` für den Arbeitsbaum) oder deklarierte Abweichung — mit
      Begründung, was diese Regel für ein Repo ohne aktives Modul 12 (Replay-Evaluierung; `grep -ci
      replay harness/README.md harness/conventions.md spec/lastenheft.md` → **0** an allen drei
      Stellen) noch trägt, wenn überhaupt.
- [ ] `make gates` grün.
- [ ] Doku-Update: `harness/conventions.md` trägt die zwei Ausgänge als neue Adaptions-Block-
      Einträge (oder Verweis auf einen bestehenden, falls einer der beiden sich als Sonderfall
      eines schon geführten Eintrags erweist).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/conventions.md`](../../../../harness/conventions.md) | update (neue Einträge) | die zwei Ausgänge; Architect-Artefakt ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |
| `Dockerfile` | update, **nur falls Adoption gewählt wird** | Runtime-Stage bzw. Image-Hash-Capture, je nach Ausgang |
| `harness/README.md` | update, **nur falls Image-Hash adoptiert wird** | Referenz auf eine Datei „harness/image-hash.txt", wie die Baseline-Regel es verlangt |

## 4. Trigger

**Start** (`next` → `in-progress`): [slice-084](../done/slice-084-stichprobe-gegen-bestand.md)
liegt in `done/` — dort steht der Fund mit seinem Beleg (§9). Zum Zeitpunkt, an dem dieser
Folge-Slice angelegt wird, liegt slice-084 noch in `in-progress/`; der Link zeigt auf den
aktuellen Ort und wandert mit dem nächsten `git mv`.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn eine der beiden Regeln eine
  eigene Review-Sitzung braucht (z. B. weil die Runtime-Stage-Frage eine echte Re-Evaluierung von
  [`ADR-0003`](../../adr/0003-go-native-binaries.md) verlangt statt nur einer Abweichungs-Notiz).
- `in-progress` → `open` (blockiert): wenn die Image-Hash-Frage eine Architektur-Entscheidung
  über Modul 12 (Replay-Evaluierung) hinaus verlangt, die noch nicht getroffen ist.

## 5. Closure-Trigger

DoD vollständig, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- **Die Runtime-Stage-Frage kippt in eine Folge-ADR statt eines `MR`-Eintrags.** Trifft
  [`ADR-0003`](../../adr/0003-go-native-binaries.md) die Frage nicht direkt (§2 DoD-Punkt 1), ist
  die richtige Form eine Folge-ADR (Modul 8 §Konflikt-Pfad, Verdikt 2), kein Adaptions-Eintrag über
  eine ADR-Lücke hinweg. — **Ausgang:** offen, wird bei Closure verbucht.
- **Die Image-Hash-Regel könnte für dieses Repo strukturell gegenstandslos sein**, wenn Modul 12
  hier nie zur Anwendung kommt (kein Golden Set, kein Replay-Lauf in Scope). Das wäre dann selbst
  ein Ausgang (Achse-1-artig: „Bezug entfallen"), keine Lücke, die geschlossen werden muss. —
  **Ausgang:** offen, wird bei Closure verbucht.

## 7. Closure-Notiz

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — `harness/conventions.md`
und `Dockerfile` sind beide in der bestehenden Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
über `*` geführt; keine zu grobe, neu auszudifferenzierende Sub-Area.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-ALL/adaptions-achse-1-kurzschluss` (1×, `*`, Beleg slice-082) — *„Achse 1
… ist nicht mit ‚die Baseline behandelt jetzt dasselbe Thema' beantwortet"*. Gilt für DoD-Punkt 1
dieses Slice unmittelbar: Dass [`ADR-0003`](../../adr/0003-go-native-binaries.md) „OCI-Image"
erwähnt, beantwortet nicht automatisch, ob sie die **Runtime-Stage**-Pflicht trägt — das ist als
Prüf-Auftrag im DoD-Punkt selbst vermerkt, nicht vorweg entschieden.

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/` gehört zum
Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
