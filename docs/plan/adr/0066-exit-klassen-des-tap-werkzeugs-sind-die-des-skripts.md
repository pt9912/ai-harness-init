# ADR-0066: Die Exit-Klassen des Tap-Werkzeugs sind die des Skripts — `make` endet jeden Fehlschlag mit 2, und die Klasse trägt die letzte stderr-Zeile des Skripts

**Status:** Proposed

**Datum:** 2026-09-24

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
(**Accepted** — der Gegenstand: ihre Exit-Klassen 0, 1 und 2, ihre Festlegung 6 und drei weitere
Stellen, die unten wörtlich genannt sind; alle übrigen Festlegungen binden unverändert fort),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Kontrolle, deren Klassen
diese Datei auf ihre Ebene stellt, hält das Tap gegen das **veröffentlichte** Asset),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (**Accepted** — der Beleg des
Accept-Übergangs),
[ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) (**Accepted** — der Präzedenzfall der
Form: Teil-`Supersedes` auf wörtlich genannte Stellen einer `Accepted`-ADR, samt Zusatz im
ADR-Index),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert; keine ist ein Erwartungswert)

**Schärft:** — Prozess- und Werkzeug-Entscheidung ohne Spec-Stratum; keine Anforderung des
Lastenhefts und keine `ARC-*`-Zeile ändert sich.

**Supersedes (Teil):** [ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md),
und dort **genau einen Gegenstand** — die Lesart eines `Exit 1` oder `Exit 2` als **Prozess-Exit
eines `make`-Ziels** an vier wörtlich genannten Stellen:

1. §Fitness Function, Zeile *„Rot-Beleg am realen Zustand"*: `make tap-check` gegen das Asset von
   `v0.2.2` → *„Exit 1"*;
2. Festlegung 6: *„ein Exit 1 der Prozedur ist erst nach dieser Wiederholung ein
   Formel-Unterschied"*;
3. §Konsequenzen, Negativ: *„ein echter Unterschied endet danach mit Exit 1"*;
4. Re-Evaluierungs-Trigger 1: *„am roten Job `tap` mit Exit 2 aus der Anmeldung"*.

Der Wortlaut dieser vier Stellen bindet nicht mehr, soweit er das Exit-Ergebnis eines
`make`-Aufrufs nennt; es gilt Festlegung 1 unten. **Alles andere bindet unverändert fort:** die
sieben Festlegungen von ADR-0064, ihre drei Klassen samt Schwellen (Wiederholung nach 65 s, Vorab-Regel,
Vorwärts-Schutz, Feldform, Token-Umgang), der Regel-Gehalt aller Zeilen ihrer Fitness-Tabelle, ihr
Rot-Beleg als **Beleg** (gegen `v0.2.2` ein Formel-Unterschied, gegen `v0.2.3` Gleichheit), ihre
übrigen Trigger und ihre Grenze. Diese Entscheidung ändert keine Klasse; sie nennt die Ebene, auf der
die Klassen gelten, und den Träger, über den sie durch `make` hindurch lesbar sind.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR) und §Hard Rule für Accepted-ADRs (*„Spätere Korrekturen oder Schärfungen
entstehen als neue ADR mit explizitem Verweis auf die abgelöste oder geschärfte Vorgängerin."*),
gelesen gegen `v6.9.0`; Baseline-Regelwerk `modul-08-agentenrollen.md` §Konflikt-Pfad als
Rollen-Sequenz (das Architect-Verdikt ist ein Artefakt).

---

## Kontext

### Der Gegenstand: eine Ebene, die die ADR nicht nannte

[ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) führt **ein
Skript**, das zwei `make`-Ziele fahren (Festlegung 1), und ordnet dessen Ausgang drei Klassen zu
(Festlegung 2). Vier Stellen nennen die Klasse an einem Aufruf **über `make`**, die Prozedur oder
den Job — als Prozess-Exit. Das trägt `make` nicht: GNU Make bildet **jeden** gescheiterten
Rezept-Schritt auf den Prozess-Exit 2 ab, unabhängig vom Status des Kommandos.

```sh
make --version | head -1                                        # GNU Make 4.3
printf 't:\n\t@sh -c "exit 1"\n' > "$T/Makefile"; make -C "$T" t; echo "exit=$?"
# make: *** [Makefile:2: t] Fehler 1   ·   exit=2
make tap-check TAG=v01.0.0 2>&1 >/dev/null | tail -n 3; echo "exit=${PIPESTATUS[0]}"
# tap-check: Feldform falsch: v01.0.0 — …   ·   tap-check: Exit 2   ·   make: *** [Makefile:<Zeile>: tap-check] Fehler 2   ·   exit=2
```

Ein `make tap-check` mit Prozess-Exit 1 ist damit nicht herstellbar; die vier Stellen lassen sich
**wörtlich nicht halten**, gemeint ist an allen vieren die Klasse des Skripts. Die Skript-Ebene ist
die, auf der die Zusagen der ADR gebunden sind: die hermetischen Fälle der Fitness Function fahren das
Skript mit Stubs und lesen seinen Exit.

**Was ohne Träger verloren ginge.** Über `make` enden ein Formel-Unterschied (Klasse 1) und ein
nicht ausführbarer Lauf (Klasse 2) beide mit Prozess-Exit 2; die Trennung, die Festlegung 2 als
tragend führt (*„Ein Lesefehler ist damit nie 1 und nie 0"*), bliebe im Skript wahr und wäre für den
Prozedur-Schritt (Festlegung 6) und für den, der einen roten Job liest, nicht mehr ablesbar. Die
Klasse braucht einen Träger, der durch `make` hindurch reicht.

**Die letzte Zeile des Skripts ist nicht die letzte des Aufrufs.** Über `make` folgt der Zeile des
Skripts die Meldung von `make` (`make: *** […] Fehler 2`, in anderer Locale `Error 2`); die
Skript-Zeile ist dort die **vorletzte** Zeile der Ausgabe (Messung oben). Wer die Klasse liest, liest
darum die letzte Zeile **des Skripts**, nicht die Meldung von `make` — sie ist locale-abhängig und
nennt den Status des Kommandos, nicht die Klasse.

### Warum eine ADR und nicht der Wortlaut des Plans

Der Plan, der das Werkzeug liefert, hat die Abnahme auf das Objekt *Skript* gestellt und die Klasse
über `make` an die Zeile gebunden. Das ist die Plan-Korrektur, die der Konflikt-Pfad der Baseline für
den Fall vorsieht, dass ein Plan behauptet, was die Entscheidung nicht trägt — hier steht jedoch der
Wortlaut der **Entscheidung** selbst an vier Stellen gegen `make`, und ein Constraint, den der
Implementer und der Reviewer lesen, darf dem Plan nicht widersprechen. Die Zeile als Träger der
Klasse ist eine **Festlegung** des Vertrags (Festlegung 2), keine Eigenschaft der Implementierung:
Prozedur und Job lesen sie.

## Entscheidung

**Wir stellen die Exit-Klassen von ADR-0064 auf die Ebene des Skripts und geben der Klasse über `make`
einen Träger: die letzte stderr-Zeile des Skripts.** Zwei Festlegungen.

**1. Die Klassen 0, 1 und 2 sind der Exit des Skripts.** Wo ADR-0064 an den vier oben genannten
Stellen einen Exit eines `make`-Aufrufs nennt, ist die Klasse des Skripts gemeint. Für einen Aufruf
**über `make`** gilt: Skript-Exit 0 → Prozess-Exit 0; Skript-Exit 1 oder 2 → Prozess-Exit 2 (Eigenschaft
von GNU Make, gemessen in §Kontext, keine Zusage des Werkzeugs). Ein
Aufruf des Skripts **ohne `make`** (`bash harness/tools/tap-nachzug.sh check` mit `TAG=<tag>` in der
Umgebung) trägt die Klasse als Prozess-Exit. Der Rot-Beleg der Fitness Function liest dort den
Prozess-Exit des Skripts; über `make` liest er die Zeile aus Festlegung 2.

**2. Die Klasse über `make` trägt die letzte stderr-Zeile des Skripts.** Bei Skript-Exit 1 und 2
schreibt das Skript als **letzte Zeile seiner stderr** `tap-<modus>: Exit <N>`; `<modus>` ist `check`
oder `sync`, `<N>` der Exit des Skripts. Bei Exit 0 schreibt es die Zeile **nicht**. Sie steht genau
einmal. **Der Prozedur-Schritt und ein Leser des roten Jobs unterscheiden die Klassen an dieser
Zeile**, nicht am Prozess-Exit von `make` und nicht an dessen Meldung. Der Wortlaut der Zeile ist
Teil des Vertrags; ein anderer Text ist eine Änderung dieser Entscheidung.

**Nicht zugesagt** — benannt, nicht geschlossen: die Zeile bei einem Ende, das das Skript nicht selbst
herbeiführt (ein Signal an den Host-Prozess während des `docker`-Aufrufs) und bei einer stderr, die nicht
beschreibbar ist. Ein Skript, das sie dort hält, bricht diese Entscheidung nicht; ein Skript, das sie
dort nicht hält, auch nicht. Der Prozess-Exit von `make` trennt nur `0` von `≠ 0`.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun; der Wortlaut des Plans trägt die Ebene | kein Text an einer `Accepted`-ADR | die ADR liest sich an vier Stellen weiter als Prozess-Exit von `make`, der nicht herstellbar ist; der Constraint des Implementers widerspricht seinem Plan; kein Architect-Artefakt, das den Konflikt-Pfad der Baseline verlangt |
| B — eine Zeile in der §Geschichte von ADR-0064 | mechanisch zulässig: `exclude-sections: [Geschichte]` nimmt den Abschnitt aus dem Kern ([`harness/sensors/adr-immutable.md`](../../../harness/sensors/adr-immutable.md)) | der Sensor nimmt den Abschnitt aus, damit die Fortschreibung nicht rot färbt — nicht als Ort für eine Festlegung: die Datei sagt selbst, ein Absatz dort statt in einer Folge-ADR bleibe **unbewacht**; und der Schlusssatz von ADR-0064 verweist Schärfungen auf eine neue ADR |
| C — ein Eintrag im Glossar von `harness/conventions.md` | die ADR bleibt unberührt | die Datei hat in der Source Precedence ([`AGENTS.md`](../../../AGENTS.md) §2) keinen Rang; der Leser der ADR als Constraint liest den Glossar nicht; ein Träger der Klasse ist eine Festlegung des Vertrags, keine Lesehilfe |
| D — das Rezept so ändern, dass der Prozess-Exit von `make` die Klasse trägt | keine Zeile nötig | nicht herstellbar: GNU Make bildet den Fehlschlag auf 2 ab (Messung in §Kontext); ein Rezept, das den Fehlschlag verschluckt, machte das Ziel für den Job grün |
| **E — Teil-`Supersedes` auf die vier Stellen, Klasse des Skripts, Träger `tap-<modus>: Exit <N>` (gewählt)** | trifft genau den unhaltbaren Wortlaut; der Rest von ADR-0064 bleibt unberührt; der Träger ist ein Text, den Skript und Prozedur teilen | eine Folge-ADR für eine Ebenen-Frage; der Zusatz an der Status-Zelle von ADR-0064 kommt erst mit dem Accept |

## Konsequenzen

- **Positiv:** die vier Stellen sind gelesen, statt zu bleiben und den Leser über `make` zu täuschen;
  die Trennung von Formel-Unterschied und Nicht-Ausführbarkeit bleibt über `make` ablesbar; der
  Prozedur-Schritt hat ein Objekt, an dem er die Klasse liest.
- **Negativ:** ein Leser von ADR-0064 findet den Wortlaut der vier Stellen unverändert, bis der Zusatz
  im ADR-Index steht (Folgepflicht 3); die Klasse steht in einem Text, den nur ein Fall hält, kein
  Typ; die Zeile ist bei einem Signal nicht zugesagt.
- **Folgepflicht 1 — die lebenden Artefakte, die das Werkzeug beschreiben** (Skript-Kopf,
  Makefile-Kommentar, README-Zeile, Plan des liefernden Slice), nennen den Exit des **Skripts** und die
  Zeile als Träger der Klasse über `make`; wo sie einen Exit nennen, nennen sie die Ebene.
- **Folgepflicht 2 — die Prozedur** ([`docs/user/releasing.md`](../../user/releasing.md), Folgepflicht 3
  von ADR-0064) liest die Klasse an der Zeile: *„`tap-check` rot mit der Zeile `tap-check: Exit 1`"* ist
  ein Formel-Unterschied, `tap-check: Exit 2` nicht ausführbar.
- **Folgepflicht 3 — der Zusatz an der Status-Zelle von ADR-0064 im ADR-Index** (*„revidiert durch
  ADR-0066"*, Umfang: die Lesart des Exit-Ergebnisses an den vier Stellen). **Diese Entscheidung ordnet
  ihn an**, dieselbe Form wie [ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md); er
  ist Folgepflicht des annehmenden Laufs, denn eine `Proposed`-ADR revidiert noch nichts.

## Fitness Function (falls maschinell prüfbar)

Jeder Fall wird vor dem Accept einmal rot gesehen ([`AGENTS.md`](../../../AGENTS.md) §3.6), die Ausgabe
gelesen, nicht nur der Exit. **Schwächung** heißt: die Zusicherung wird testweise so verändert, dass
sie nicht mehr hält.

| Zusage | Fall (`bats`, hermetisch; das Skript mit Stubs) | Rot unter der Schwächung |
|---|---|---|
| Bei Skript-Exit 1 und Exit 2 ist die letzte stderr-Zeile `tap-<modus>: Exit <N>` mit der Klasse des Exits; bei Exit 0 fehlt sie; sie steht genau einmal | Formel-Unterschied → Exit 1 und letzte Zeile `tap-check: Exit 1`; falsche Tag-Form → Exit 2 und `tap-check: Exit 2`; gleich → Exit 0, keine Zeile; Modus `sync` → `tap-sync: Exit 2`; die Zeile zählt genau einmal | Zeile entfernt · falsche Klasse in der Zeile · Zeile auch bei Exit 0 · Zeile doppelt (der Fall zählt) → der Fall wird rot |
| **Rot-Beleg am realen Zustand, kein Gate:** der Formel-Unterschied ist über beide Aufrufe lesbar | `TAG=<älterer Tag als der des Tap> bash harness/tools/tap-nachzug.sh check` → Prozess-Exit 1 und letzte Zeile `tap-check: Exit 1`; `make tap-check TAG=<älterer Tag>` → Prozess-Exit 2, die Zeile `tap-check: Exit 1` steht vor der Meldung von `make`; ein Tag, den das Tap trägt → beide Exit 0. **Datiert:** der Beleg gilt für den Tap-Stand am Tag der Messung und wandert mit jedem Schnitt | — |

## Re-Evaluierungs-Trigger

- **Wenn ein Aufrufer die Klasse am Prozess-Exit braucht** *(beobachtbar an einem Workflow-Schritt oder
  einem Skript, das auf `1` gegen `2` verzweigt)*: der Träger trägt nicht; neu zu wägen ist ein
  Aufruf des Skripts ohne `make` für diesen Aufrufer.
- **Wenn ein Ende ohne die Zeile zweimal eine Klasse falsch gelesen hat** *(beobachtbar an einem roten
  Lauf, dessen Klasse der Leser aus einer fehlenden Zeile falsch schloss)*: die Nicht-Zusage bei Signal
  und nicht beschreibbarer stderr trägt nicht.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`; bis dahin ist sie ein Architect-Verdikt und als solches das
Übergabe-Artefakt, das der Implementer als Constraint liest. Sie wird `Accepted`, **wenn eine
Reviewer-Runde sie gegen
[ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) und
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) auf Konsistenz geprüft hat und ihr
Report ohne blockierenden Befund an der **Substanz** der zwei Festlegungen in `docs/reviews/`
liegt.** Ein blockierender Befund an der **Darstellung** wird behoben und hindert die Annahme nicht.
Der Beleg ist eine Runde der prüfenden Rolle; die Accept-Zeile der §Geschichte nennt ihn als
**Kennung**, nicht als Pfad-Link (ADR-0040 Festlegung 1). **Die Annahme selbst ist die Entscheidung des
Auftraggebers.**

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-24 | **Proposed** | Architect-Lauf: die vier Stellen von ADR-0064, die einen `make`-Exit 1 nennen, sind mit GNU Make nicht herstellbar (Messung in §Kontext); die Klasse des Skripts und ihr Träger über `make` sind die Festlegungen. Der Acceptance-Trigger steht oben |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0066` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
