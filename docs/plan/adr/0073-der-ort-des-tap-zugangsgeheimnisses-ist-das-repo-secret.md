# ADR-0073: Der Ort des Tap-Zugangsgeheimnisses am Regelweg ist das Repo-Secret — der Job `tap` liest `HOMEBREW_TAP_GITHUB_TOKEN` im Step-`env` auf `TAP_TOKEN` gemappt, und die Fadenkreuz-Bindung an den Tag tragen `needs: publish` und der Tag-Trigger

**Status:** Proposed

**Datum:** 2026-09-29

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
(**Accepted** — der Gegenstand: die Ort-Klausel ihrer Festlegung 4 und die
`environment:`-Erwartung in Folgepflicht 2 und der Fitness-Zeile *Job-Form*; alle übrigen
Festlegungen, ihre drei Klassen samt Schwellen, ihre Trigger und ihre Grenze binden
unverändert fort),
[ADR-0066](0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) (**Accepted** — der
Präzedenzfall der Form: Teil-`Supersedes` auf wörtlich genannte Stellen einer `Accepted`-ADR,
samt Zusatz im ADR-Index; dazu sein Re-Evaluierungs-Trigger 1, dessen Sachstand unten steht),
[ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) (**Accepted** — der erste
Präzedenz der Teil-`Supersedes`-Form),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (**Accepted** — der Beleg
des Accept-Übergangs),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Reproduzierbarkeit — der
Job fährt dasselbe Ziel wie der lokale Ausfallweg; der Ort des Tokens ist davon getrennt)

**Schärft:** — Prozess- und Werkzeug-Entscheidung ohne Spec-Stratum; keine Anforderung des
Lastenhefts und keine `ARC-*`-Zeile ändert sich.

**Supersedes (Teil):**
[ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md),
und dort **genau zwei Gegenstände**, wörtlich benannt:

1. Festlegung 4, der Satz **„Ort: ein Umgebungs-Secret, kein Repository-Secret."** samt seiner
   Begründung (*„Damit **erzwingt** die Plattform, dass nur ein Lauf an einem `v*`-Tag das Secret
   liest; ein Repository-Secret wäre dagegen von jedem Workflow jeder Branch-Fassung mit
   Schreibrecht lesbar, und *"nur in diesem Job"* bliebe Konvention."*) und des darin stehenden
   Anlage-Umfangs (*„Anlage der Umgebung, ihrer Regel und des Secrets"* — die Anlage des
   **Secrets** selbst bindet als Handlung des Auftraggebers außerhalb des Repos fort, Festlegung 4
   unten);
2. Folgepflicht 2 und die Fitness-Zeile **„Job-Form"**, soweit sie in der Aufzählung
   `environment:` führen, samt der Vorbedingung *„die Umgebung samt Tag-Regel und das Secret
   `TAP_TOKEN` existieren"* in der Hälfte, die die Umgebung nennt.

Der Rest der beiden Stellen bindet unverändert fort: die übrigen Sätze der Ort-Klausel (*„Das
Secret steht **nur im Step-`env` des Schritts, der `make tap-nachzug` ruft**, nicht auf Workflow-
oder Job-Ebene und nicht im `publish`-Job"*; `contents: read` für das eigene `github.token`,
`persist-credentials: false`), die Sätze zu Art und Scope, zum Umgang im Werkzeug und zum
Fehlt-Nachweis, und die übrigen Zeilen der Fitness-Zeile *Job-Form*. **Alles andere von
ADR-0064 bindet unverändert:** die übrigen Festlegungen (ein Skript, zwei Aufrufer, der Ablauf,
die Kontrolle, Idempotenz und Vorwärts-Schutz, Docker-only, Fehlschlag laut), die Wechselwirkung
mit den übrigen ADRs, ihre Alternativen als Abwägung, ihre Konsequenzen, Trigger und Grenze.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR) und §Hard Rule für Accepted-ADRs; Baseline-Regelwerk
`modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz (das Architect-Verdikt ist ein
Artefakt).

---

## Kontext

### Was die Entscheidung auslöst

Der Release-Job `tap` in [`.github/workflows/release.yml`](../../../.github/workflows/release.yml)
liest das Repo-Secret `HOMEBREW_TAP_GITHUB_TOKEN` — im Step-`env` des Schritts, der
`make tap-nachzug` ruft, auf `TAP_TOKEN` gemappt — und trägt kein `environment:`. Die ADR, die
die Job-Form als Constraint führt, trägt diese Form nicht: ihre Festlegung 4 legt den Ort als
**Umgebungs-Secret** fest, und Folgepflicht 2 wie die Fitness-Zeile *Job-Form* führen
`environment:` in der Aufzählung. Die `bats`-Fälle über die Job-Form
([`test/tap-nachzug.bats`](../../../test/tap-nachzug.bats)) halten die Form ohne `environment:`,
und Schritt 7 der Prozedur
([`docs/user/releasing.md`](../../../docs/user/releasing.md)) beschreibt die Form mit
Repo-Secret — beide lesen an dieser Frage gegen den Wortlaut der `Accepted`-ADR.

**Die Richtung ist gesetzt:** der Auftraggeber hat am 2026-09-29 das Repo-Secret
`HOMEBREW_TAP_GITHUB_TOKEN` angelegt und auf eine GitHub-Umgebung verzichtet; Vorbild ist die
Release-Job-Kette des Nachbar-Repos d-migrate (als Quelle gelesen, nicht als Kennung zitiert).
Diese Entscheidung formt die Abweichung aus — dieselbe Lage wie in
[ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
§Kontext (*„Die Richtung ist gesetzt …; diese Entscheidung formt sie aus"*). Der Plan des
Slices, der den Job trägt, benennt die Begründung; ein Plan ist aber kein Norm-Artefakt — der
Constraint, den Implementer und Reviewer lesen, ist die ADR, und deren Wortlaut widerspricht der
Form, die Job, Fälle und Prozedur tragen. Die Auflösung ist die Folge-ADR mit `Supersedes`
(Modul 8, Konflikt-Pfad, Verdikt 2); ein Zurückrollen des Jobs auf die Umgebung wäre Verdikt 1
und steht nicht zur Debatte, weil die Job-Form vom Auftraggeber gesetzt ist.

**Was die Änderung am Schutz ändert, und was sie nicht ändert.** Die Ort-Klausel band das
Secret an eine Umgebung mit Bereitstellungs-Regel auf `v*`-Tags; die Plattform erzwang damit,
dass nur ein Lauf an einem `v*`-Tag das Secret liest. Der Verzicht auf die Umgebung kostet
diese Erzwingung: *„nur in diesem Job"* ist am Regelweg Konvention, getragen von der
Job-Struktur (`needs: publish`, dieselbe `if`-Bedingung wie `publish` am Tag-Trigger), und ein
Repository-Secret ist von jedem Workflow jeder Branch-Fassung mit Schreibrecht lesbar, dessen
Datei es nennt. Die Sorge der Ort-Klausel wird damit nicht widerlegt — sie wird anders
gewichtet: die Umgebung samt Regel ist nicht angelegt, und die Rest-Bindung ist die
Job-Struktur. Art und Scope des Tokens (*fine-grained*, beschränkt auf das Tap-Repository,
*Contents: Read and write*, Ablaufdatum) und der Umgang im Werkzeug (nie in einer
Kommandozeile, nie in der Ausgabe) binden aus ADR-0064 Festlegung 4 unverändert fort.

### ADR-0066 Re-Evaluierungs-Trigger 1 — Sachstand

Der Job-Schritt verzweigt nicht auf die Klasse des Ziels: `run: make tap-nachzug` ohne `case`,
ohne `$?`-Vergleich, ohne `|| true` — jedes Nicht-Null des Ziels endet als roter Job. Der
Trigger fordert einen Aufrufer, der die Klasse am Prozess-Exit braucht; ein solcher Aufrufer ist
nicht entstanden, der Trigger ist **nicht eingetreten**. Einen Fall der Job-Form-Fälle hält die
Abwesenheit der Verzweigung, und ein Eintreten — eine eingebaute Verzweigung — färbt ihn rot.

## Entscheidung

**Wir legen den Ort des Tap-Zugangsgeheimnisses am Regelweg auf das Repo-Secret und stellen die
Umgebung als Träger der Tag-Bindung still.** Vier Festlegungen.

**1. Ort am Regelweg: das Repo-Secret, nur im Step-`env`.** Der Job `tap` in
[`.github/workflows/release.yml`](../../../.github/workflows/release.yml) liest das Repo-Secret
`HOMEBREW_TAP_GITHUB_TOKEN`, und zwar als Step-`env` des Schritts, der `make tap-nachzug` ruft:

```yaml
env:
  TAP_TOKEN: ${{ secrets.HOMEBREW_TAP_GITHUB_TOKEN }}
  TAG: ${{ github.ref_name }}
```

Der **Werkzeug-Vertragsname bleibt `TAP_TOKEN`**: das Skript liest diese Variable, seine
Fehlt-Meldung (Schritt b) nennt sie, und der lokale Aufruf reist unter demselben Namen — der Ort
wechselt, der Vertrag an den Aufrufern nicht. Eine Secret-Zuführung gibt es nur in diesem
Step-`env`: kein `env` auf Workflow- oder Job-Ebene, kein Secret-Zugriff im `publish`-Job, kein
weiterer Schritt mit Secret-Zugriff — dieser Teil der Ort-Klausel von ADR-0064 bindet fort und
trägt denselben Fall wie bisher.

**2. Keine GitHub-Umgebung am Job.** Der Job `tap` trägt kein `environment:`. Die Bindung, die
die Umgebung tragen sollte — dass nur ein Lauf an einem `v*`-Tag das Secret liest —, tragen
`needs: publish` und der Tag-Trigger des Workflows (dieselbe `if`-Bedingung wie `publish`). Der
Job ist damit ohne Vorbedingung außerhalb des Repos lieferbar; fehlt das Secret, endet der
Tag-Lauf laut (Schritt b des Skripts).

**3. Der lokale Ausfallweg behält die Form aus ADR-0064.**
`make tap-nachzug TAG=<tag>` mit `TAP_TOKEN` in der Umgebung des Aufrufers — wo der Auftraggeber
sie hält, ist seine Sache. Beide Aufrufer fahren dasselbe Skript mit derselben Variablen; der
Ort-Unterschied liegt ausschließlich in der Herkunft der Umgebung.

**4. Der Token-Wert steht in keinem Artefakt dieses Repos.** Die Workflow-Datei trägt nur den
Secret-Namen; Anlage, Wert und Rotation des Secrets sind Handlung des Auftraggebers außerhalb
des Repos — dieser Satz aus der Ort-Klausel bindet fort.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun; die Abweichung trägt der Plan des liefernden Slices | kein neues Artefakt | nach der Closure ist der Plan ein Zeitdokument; Implementer und Reviewer lesen ADR-0064 als Constraint, und deren Wortlaut bleibt der Form von Job, Fällen und Prozedur entgegen — dieselbe Konstellation wie in [ADR-0066](0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) §Kontext |
| B — den Job auf die Umgebung zurückbauen (Wortlaut von ADR-0064) | die `Accepted`-ADR bliebe im Wortlaut | die Job-Form ist Setzung des Auftraggebers (Repo-Secret angelegt, keine Umgebung); der Rückbau stellte die Anlage außerhalb des Repos zurück und machte den Regelweg von einer Voraussetzung abhängig, die nicht besteht |
| C — `Supersedes` der ganzen ADR-0064 | ein Text, ein Zeiger | nur die Ort-Klausel und die Umgebungserwartung fallen; Skript, Klassen, zwei Aufrufer, Vorwärts-Schutz, Docker-only und die übrigen Trigger bleiben — ein Voll-`Supersedes` läge über dem Gegenstand |
| **D — Teil-`Supersedes` auf die zwei Stellen; Ort am Regelweg: das Repo-Secret (gewählt)** | trifft genau die Abweichung; der Rest von ADR-0064 bleibt unberührt; die Form hat mit [ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) und [ADR-0066](0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) ihren Präzedenz | ein zweiter Text neben der Ort-Klausel, bis der Index-Zusatz steht (Folgepflicht 1); die Plattform-Erzwingung der Tag-Bindung ist entfallen und wird durch Job-Struktur ersetzt (§Kontext) |

## Konsequenzen

- **Positiv:** der Regelweg läuft mit der Anlage, die besteht (Repo-Secret), statt an einer
  fehlenden Umgebung zu scheitern; der Werkzeug-Vertragsname `TAP_TOKEN` bleibt an beiden
  Aufrufern derselbe; Job-Form, `bats`-Fälle und Prozedur haben einen Constraint, der ihre Form
  trägt.
- **Negativ:** die Plattform-Erzwingung der Tag-Bindung ist entfallen — *„nur in diesem Job"* ist
  am Regelweg Konvention, getragen von `needs: publish` und dem Tag-Trigger; ein
  Repository-Secret ist von jedem Workflow jeder Branch-Fassung mit Schreibrecht lesbar, dessen
  Datei es nennt; ein Leser von ADR-0064 findet die Ort-Klausel unverändert, bis der Index-Zusatz
  steht (Folgepflicht 1).
- **Folgepflicht 1 — der Zusatz an der Status-Zelle von ADR-0064 im ADR-Index** (*„revidiert
  durch ADR-0073"*, Umfang: die Ort-Klausel der Festlegung 4 samt ihrer Begründung und die
  `environment:`-Erwartung in Folgepflicht 2 und der Fitness-Zeile *Job-Form*). **Diese
  Entscheidung ordnet ihn an** — dieselbe Form wie [ADR-0066](0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md)
  Folgepflicht 3; er ist Folgepflicht des annehmenden Laufs, denn eine `Proposed`-ADR revidiert
  noch nichts.
- **Folgepflicht 2 — die lebenden Artefakte, die die Job-Form beschreiben, nennen die Quelle der
  Aufzählung in der Fassung dieser Entscheidung:** der `bats`-Kopf über die Job-Form verankert
  sich in ADR-0064 Folgepflicht 2 **in der Lesart von ADR-0073**, und Schritt 7 der Prozedur
  nennt an der Secret-Stelle neben der fortgeltenden Festlegung 4 diese Entscheidung. Die
  Anpassung des `bats`-Kopfs ist Teil dieser Entscheidung (nur Verweis-Zeilen, keine
  Verhaltensänderung der Fälle); die Zelle in der Prozedur zieht der Slice, der sie trägt.

## Fitness Function (falls maschinell prüfbar)

Die Fälle stehen in [`test/tap-nachzug.bats`](../../../test/tap-nachzug.bats) und lesen die
Workflow-Datei (Datei-Lektüre, kein Netz, kein Workflow-Lauf); jeder Fall wird einmal rot
gesehen ([`AGENTS.md`](../../../AGENTS.md) §3.6), die Ausgabe gelesen, nicht nur der Exit-Code.

| Zusage | Fall | Rot unter der Schwächung |
|---|---|---|
| Der Job `tap` trägt kein `environment:` — die Fadenkreuz-Bindung tragen `needs: publish` und der Tag-Trigger | `job-form: der Job tap tragt keine environment-Sperre` | `environment:` am Job `tap` → der Fall wird rot |
| `TAP_TOKEN` und `TAG` reisen als Step-`env` des Jobs `tap`; `TAP_TOKEN` ist das Mapping auf `secrets.HOMEBREW_TAP_GITHUB_TOKEN` | `job-form: TAP_TOKEN und TAG reisen als Step-env des Jobs tap` | Mapping oder Name geändert → der Fall wird rot |
| Eine Secret-Zuführung gibt es nur im Step-`env` des Jobs `tap` (kein `env` auf Workflow- oder Job-Ebene, kein Secret-Zugriff im `publish`-Job) | `job-form: eine Secret-Zufuehrung gibt es nur im Step-env des Jobs tap` | Secret-Zugriff an anderer Stelle → der Fall wird rot |
| Der `run:`-Text enthält keine Expansion; der Schritt verzweigt nicht auf die Klasse des Ziels | `uebergabe ohne text: der run-Text des Jobs tap enthaelt keine Expansion` · `job-form: der run-Text des Jobs tap verzweigt nicht auf die Klasse des Ziels` | `${{ }}` im `run:` bzw. `case`/`$?`/`|| true` → der jeweilige Fall wird rot |
| Der übrige Umfang der Job-Form (`needs: publish`, gleiche `if`-Bedingung, `persist-credentials: false`, `permissions: contents: read`, ein Schritt `make tap-nachzug`) | die übrigen `job-form`-Fälle | jede Zeile einzeln entfernt → der zugehörige Fall wird rot |

## Re-Evaluierungs-Trigger

- **Wenn ein Workflow-Lauf das Secret außerhalb des Tag-Schnitts liest** *(beobachtbar an einem
  `secrets.HOMEBREW_TAP_GITHUB_TOKEN`-Zugriff außerhalb des Step-`env` des Jobs `tap`)*: die
  Rest-Bindung „nur im Step-`env`" trägt nicht; neu zu wägen sind der Schutz der Workflow-Anlage
  und die Umgebung samt Tag-Regel.
- **Wenn der Auftraggeber eine GitHub-Umgebung samt Tag-Regel nachträglich anlegt** *(beobachtbar
  an der Umgebung in den Einstellungen des Repos — eine Einstellung außerhalb des Baums; ihr
  Beleg ist die Einstellung selbst)*: die ursprüngliche Ort-Klausel von ADR-0064 wird
  realisierbar; neu zu wägen ist der Rückzug auf sie.
- **Wenn das Token an einem Schnitt scheitert (abgelaufen, widerrufen), und das ein zweites
  Mal** *(beobachtbar am roten Job `tap` mit Exit 2 aus der Anmeldung)*:
  [ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  Re-Evaluierungs-Trigger 1 bindet fort und trifft beide Aufrufer ungeachtet des Orts.

**Wer diese Trigger beobachtet:** das Trigger-Audit der ADR-Klasse bei der Slice-Closure
(Baseline-Regelwerk `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 2; ohne
Wellen-Betrieb bei jeder Slice-Closure, Tabelle *Träger im Repo ohne Wellen*). Die Einstellungen
außerhalb des Baums liest kein Sensor des Repos; ihr Beleg bleibt die Einstellung selbst.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`; bis dahin ist sie ein Architect-Verdikt und als solches
das Übergabe-Artefakt, das der Implementer als Constraint liest. Sie wird `Accepted`, **wenn
eine Reviewer-Runde sie gegen
[ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) und
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) auf Konsistenz geprüft hat
und ihr Report ohne blockierenden Befund an der **Substanz** der vier Festlegungen in
`docs/reviews/` liegt.** Ein blockierender Befund an der **Darstellung** (Adressform, Zahl ohne
Kommando) wird behoben und hindert die Annahme nicht. Der Beleg ist eine Runde der prüfenden
Rolle; die Nachmessung durch den Kontext, der einen Befund aufgelöst hat, ist keine
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2); die
Accept-Zeile der §Geschichte nennt ihn als **Kennung**, nicht als Pfad-Link (ebenda,
Festlegung 1). **Die Annahme selbst ist die Entscheidung des Auftraggebers.**

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-29 | **Proposed** | Architect-Lauf: der Release-Job `tap` trägt das Repo-Secret `HOMEBREW_TAP_GITHUB_TOKEN` im Step-`env` und kein `environment:`; die Job-Form ist Setzung des Auftraggebers vom 2026-09-29. Teil-`Supersedes` auf die Ort-Klausel der Festlegung 4 und die `environment:`-Erwartung in Folgepflicht 2 und der Fitness-Zeile *Job-Form*; Sachstand zu [ADR-0066](0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) Re-Evaluierungs-Trigger 1 im Kontext. Der Acceptance-Trigger steht oben |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0073` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
