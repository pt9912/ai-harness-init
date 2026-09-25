# ADR-0066: Die Exit-Klassen des Tap-Werkzeugs sind die des Skripts — `make` endet jeden Fehlschlag mit 2, und die Klasse trägt die letzte stderr-Zeile des Skripts

**Status:** Accepted

**Datum:** 2026-09-24

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0064](0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
(**Accepted** — der Gegenstand: ihre Exit-Klassen 0, 1 und 2, ihre Festlegung 6 und zwei weitere
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
und dort **genau einen Gegenstand** — die Lesart eines `Exit 1` als **Prozess-Exit eines
`make`-Ziels** an drei wörtlich genannten Stellen:

1. §Fitness Function, Zeile *„Rot-Beleg am realen Zustand"*, **beide Zellen**, soweit sie den Exit
   eines `make`-Aufrufs nennen: die Zusage-Zelle (*„fängt einen Formel-Unterschied als Exit 1 mit der
   Meldung des Unterschieds (nicht 2)"*) und die Fall-Zelle (`make tap-check` gegen das Asset von
   `v0.2.2` → *„Exit 1 (nach der Wiederholung des Lesens)"*). Über `make` ist die Zusage-Zelle die
   schärfere Falschheit, denn der Prozess-Exit ist dort 2; ihr *„Gleichheit als 0"* und das
   *„Exit 0"* der Fall-Zelle gegen `v0.2.3` sind über `make` wahr und bleiben;
2. Festlegung 6: *„ein Exit 1 der Prozedur ist erst nach dieser Wiederholung ein
   Formel-Unterschied"*;
3. §Konsequenzen, Negativ: *„ein echter Unterschied endet danach mit Exit 1"*.

Der Wortlaut dieser drei Stellen bindet nicht mehr, soweit er das Exit-Ergebnis eines
`make`-Aufrufs nennt; es gilt Festlegung 1 unten. **Alles andere bindet unverändert fort:** die
sieben Festlegungen von ADR-0064, ihre drei Klassen samt Schwellen (Wiederholung nach 65 s, Vorab-Regel,
Vorwärts-Schutz, Feldform, Token-Umgang), der Regel-Gehalt aller Zeilen ihrer Fitness-Tabelle, ihr
Rot-Beleg als **Beleg** (gegen `v0.2.2` ein Formel-Unterschied, gegen `v0.2.3` Gleichheit), ihre
Trigger und ihre Grenze. **Auch Re-Evaluierungs-Trigger 1** (*„am roten Job `tap` mit Exit 2 aus der
Anmeldung"*) bindet fort und ist nicht Teil der Ablösung: er setzt einen Job-Schritt voraus, der ein
`make`-Ziel fährt, und für diesen Schritt ist er wörtlich wahr, denn ein `make`-Rezept endet bei jedem
Fehlschlag mit 2 (Messung in §Kontext). Dass dieser Exit die Anmeldung als Ursache nennt,
liest der Job nie am Exit, sondern an der Meldung des Skripts — auch ohne `make` tragen alle
Ursachen der Klasse 2 denselben Exit. Diese Entscheidung ändert keine Klasse; sie nennt die Ebene, auf
der die Klassen gelten, und den Träger, über den sie durch `make` hindurch als Vertrag lesbar sind.

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
(Festlegung 2). Drei Stellen nennen `Exit 1` an einem Aufruf **über `make`** — dem Ziel, der
Prozedur oder der Nachkontrolle — als Prozess-Exit. Das trägt `make` nicht: GNU Make bildet **jeden**
gescheiterten Rezept-Schritt auf den Prozess-Exit 2 ab, unabhängig vom Status des Kommandos.

```sh
make --version | head -1                                        # GNU Make 4.3
T=$(mktemp -d); printf 't:\n\t@sh -c "exit 3"\n' > "$T/Makefile"; make -C "$T" t; echo "exit=$?"
# make: Verzeichnis „…“ wird betreten · make: *** [Makefile:2: t] Fehler 3 · make: Verzeichnis „…“ wird verlassen · exit=2
make tap-check TAG=v01.0.0 2>&1 >/dev/null | tail -n 3; echo "exit=${PIPESTATUS[0]}"
# tap-check: Feldform falsch: v01.0.0 — …   ·   tap-check: Exit 2   ·   make: *** [Makefile:<Zeile>: tap-check] Fehler 2   ·   exit=2
```

Ein `make tap-check` mit Prozess-Exit 1 ist damit nicht herstellbar; die drei Stellen sind **über
`make` wörtlich falsch**, gemeint ist an allen dreien die Klasse des Skripts. Die Skript-Ebene ist
die, auf der die Zusagen der ADR gebunden sind: die hermetischen Fälle der Fitness Function fahren das
Skript mit Stubs und lesen seinen Exit. (Die vierte Stelle, die ein Exit nennt — Trigger 1, oben —, ist
über `make` wörtlich wahr und bleibt.)

**Was der Prozess-Exit nicht trägt, und was `make` daneben meldet.** Über `make` enden ein
Formel-Unterschied (Klasse 1) und ein nicht ausführbarer Lauf (Klasse 2) beide mit Prozess-Exit 2; der
Prozess-Exit trennt dort nur `0` von `≠ 0`. Die Trennung, die Festlegung 2 als tragend führt (*„Ein
Lesefehler ist damit nie 1 und nie 0"*), bleibt im Skript wahr. **`make` meldet den Status des
Kommandos daneben selbst:** die Ziffer hinter `Fehler`/`Error` ist der Exit des Skripts (`Fehler 3` bei
Exit 3, im realen Ziel `Fehler 2` bei Exit 2) — die Klasse ist damit über `make` **ablesbar**, nicht
verloren. Die Frage ist, ob ein Vertrag sich auf diese Meldung stützen darf; Alternative F wägt sie.

**Die letzte Zeile des Skripts ist nicht die letzte des Aufrufs.** Über `make` folgt der Zeile des
Skripts die Meldung von `make` (`make: *** […] Fehler 2`, in anderer Locale `Error 2`). Bei
`make <ziel>` aus dem Wurzelverzeichnis ist die Skript-Zeile die **vorletzte** Zeile der Ausgabe
(Messung oben); unter `make -C <dir>` (und `-w`) folgt ihr zusätzlich die Zeile `Verzeichnis … wird
verlassen`, und unter einem umschließenden `make` steht als **letzte** Meldung die des äußeren
(`make: *** [Outer.mk:2: o] Fehler 2`, während die des inneren `make[1]: *** [Makefile:2: t] Fehler 3`
lautet):

```sh
T=$(mktemp -d); printf 't:\n\t@sh -c "exit 3"\n' > "$T/Makefile"; printf 'o:\n\t@$(MAKE) t\n' > "$T/Outer.mk"
make -C "$T" -f Outer.mk o 2>&1 | grep '\*\*\*'; LC_ALL=C LANGUAGE=C make -C "$T" t 2>&1 | grep '\*\*\*'
# make[1]: *** [Makefile:2: t] Fehler 3   ·   make: *** [Outer.mk:2: o] Fehler 2   ·   make: *** [Makefile:2: t] Error 3
```

Die Position der Skript-Zeile hängt damit am Aufruf; die Leseregel dieser Entscheidung tut es nicht:
gelesen wird **die Zeile `tap-<modus>: Exit <N>`** (die letzte stderr-Zeile des Skripts), nicht eine Zeile
an einer Stelle der Ausgabe.

### Warum eine ADR und nicht der Wortlaut des Plans

Der Plan, der das Werkzeug liefert, hat die Abnahme auf das Objekt *Skript* gestellt und die Klasse
über `make` an die Zeile gebunden. Das ist die Plan-Korrektur, die der Konflikt-Pfad der Baseline für
den Fall vorsieht, dass ein Plan behauptet, was die Entscheidung nicht trägt — hier steht jedoch der
Wortlaut der **Entscheidung** selbst an drei Stellen gegen `make`, und ein Constraint, den der
Implementer und der Reviewer lesen, darf dem Plan nicht widersprechen. Die Zeile als Träger der
Klasse ist eine **Festlegung** des Vertrags (Festlegung 2), keine Eigenschaft der Implementierung:
Prozedur und Job lesen sie.

## Entscheidung

**Wir stellen die Exit-Klassen von ADR-0064 auf die Ebene des Skripts und geben der Klasse über `make`
einen Träger: die letzte stderr-Zeile des Skripts.** Zwei Festlegungen.

**1. Die Klassen 0, 1 und 2 sind der Exit des Skripts.** Wo ADR-0064 an den drei oben genannten
Stellen einen Exit eines `make`-Aufrufs nennt, ist die Klasse des Skripts gemeint. Für einen Aufruf
**über `make`** gilt: Skript-Exit 0 → Prozess-Exit 0; Skript-Exit 1 oder 2 → Prozess-Exit 2 (Eigenschaft
von GNU Make, gemessen in §Kontext, keine Zusage des Werkzeugs). Ein
Aufruf des Skripts **ohne `make`** (`bash harness/tools/tap-nachzug.sh check` mit `TAG=<tag>` in der
Umgebung) trägt die Klasse als Prozess-Exit. Der Rot-Beleg der Fitness Function liest dort den
Prozess-Exit des Skripts; über `make` liest er die Zeile aus Festlegung 2. Ein Ende durch ein Signal
ist keine der drei Klassen (§Nicht zugesagt).

**2. Die Klasse über `make` trägt die letzte stderr-Zeile des Skripts.** Bei Skript-Exit 1 und 2
schreibt das Skript als **letzte Zeile seiner stderr** `tap-<modus>: Exit <N>`; `<modus>` ist der
Modus, mit dem es aufgerufen wurde (`check` über das Ziel, `sync`), `<N>` der Exit des Skripts. Bei
Exit 0 schreibt es die Zeile **nicht**. Sie steht genau einmal. **Der Prozedur-Schritt und ein Leser
des roten Jobs unterscheiden die Klassen an dieser Zeile**, nicht am Prozess-Exit von `make` und nicht
an dessen Meldung. Der Wortlaut der Zeile ist Teil des Vertrags; ein anderer Text ist eine Änderung
dieser Entscheidung. **Warum die Zeile und nicht die Ziffer der Meldung:** die Zeile ist ein Text, den
das Skript schreibt und den ein Fall des Repos hält, ohne Wortlaut einer Locale und ohne Position;
die Ziffer ist heute dieselbe Klasse, aber Meldung eines Fremdwerkzeugs, deren Wortlaut die Locale
und deren Zeile Aufruf und Umgebung bestimmen (Alternative F). Ein Mensch, der die Ziffer liest,
liest nichts Falsches; der Vertrag stützt sich nicht auf sie.

**Nicht zugesagt** — benannt, nicht geschlossen: die Zeile bei einem Ende, das das Skript nicht selbst
herbeiführt (ein Signal an den Host-Prozess während des `docker`-Aufrufs), bei einer stderr, die nicht
beschreibbar ist, und bei einem Aufruf ohne Modus oder mit einem unbekannten Modus (`tap-nachzug: Exit 2`
bzw. `tap-<Argument>: Exit 2`; erreichbar nur im Direktaufruf, die Ziele setzen den Modus fest). Ein
Skript, das sie dort hält, bricht diese Entscheidung nicht; ein Skript, das sie dort nicht hält, auch
nicht. **Bei einem Signal fehlt neben der Zeile auch die Klasse:** der Prozess endet mit 128 plus der
Signalnummer und ohne jede Ausgabe, keine der drei Klassen ist gemeint (`docker` als Stub, der `sleep 4`
ausführt, im `PATH`; `TAG=v0.2.2 bash harness/tools/tap-nachzug.sh check 2>err.txt & kill -TERM $!;
wait $!; echo "exit=$?"; wc -c < err.txt` → `exit=143`, `0` Bytes). **Bei nicht beschreibbarer stderr
ist auch die Klasse nicht zugesagt:** schreibt der Container
auf die stderr des `docker`-Clients, die sich nicht beschreiben lässt, endet dieser mit 1 statt mit dem Status
der Nutzlast (`docker run --rm <Bild> sh -c 'echo x >&2; exit 10' 2>/dev/full; echo "status=$?"` →
`status=1`, mit `2>/dev/null` `status=10`); ein Formel-Unterschied endet dort als Klasse 2 — die
sichere Richtung, nie ein Unterschied, der keiner ist. Der Prozess-Exit von `make` trennt nur `0` von
`≠ 0`.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun; der Wortlaut des Plans trägt die Ebene | kein Text an einer `Accepted`-ADR | die ADR liest sich an drei Stellen weiter als Prozess-Exit von `make`, der nicht herstellbar ist; der Constraint des Implementers widerspricht seinem Plan; kein Architect-Artefakt, das den Konflikt-Pfad der Baseline verlangt |
| B — eine Zeile in der §Geschichte von ADR-0064 | mechanisch zulässig: `exclude-sections: [Geschichte]` nimmt den Abschnitt aus dem Kern ([`harness/sensors/adr-immutable.md`](../../../harness/sensors/adr-immutable.md)) | der Sensor nimmt den Abschnitt aus, damit die Fortschreibung nicht rot färbt — nicht als Ort für eine Festlegung: die Datei sagt selbst, ein Absatz dort statt in einer Folge-ADR bleibe **unbewacht**; und der Schlusssatz von ADR-0064 verweist Schärfungen auf eine neue ADR |
| C — ein Eintrag im Glossar von `harness/conventions.md` | die ADR bleibt unberührt | die Datei hat in der Source Precedence ([`AGENTS.md`](../../../AGENTS.md) §2) keinen Rang; der Leser der ADR als Constraint liest den Glossar nicht; ein Träger der Klasse ist eine Festlegung des Vertrags, keine Lesehilfe |
| D — das Rezept so ändern, dass der Prozess-Exit von `make` die Klasse trägt | keine Zeile nötig | nicht herstellbar: GNU Make bildet den Fehlschlag auf 2 ab (Messung in §Kontext); ein Rezept, das den Fehlschlag verschluckt, machte das Ziel für den Job grün |
| **E — Teil-`Supersedes` auf die drei Stellen, Klasse des Skripts, Träger `tap-<modus>: Exit <N>` (gewählt)** | trifft genau den unhaltbaren Wortlaut; der Rest von ADR-0064 bleibt unberührt; der Träger ist ein Text, den Skript und Prozedur teilen, locale-frei, positionsfrei und von einem Fall gehalten, der im bats-Image läuft | eine Folge-ADR für eine Ebenen-Frage; ein zweiter Text neben der Meldung von `make`, die dieselbe Klasse als Ziffer nennt; der Zusatz an der Status-Zelle von ADR-0064 kommt erst mit dem Accept |
| F — die Ziffer der `make`-Meldung (`Fehler N`/`Error N`) als Träger lesen; die Klasse des Skripts wie in E | kein Text im Skript, keine Zeile; die Ziffer ist heute der Exit des Skripts (Messung in §Kontext) und für einen Menschen lesbar; die Ebenen-Festlegung 1 bliebe dieselbe | die Meldung eines Fremdwerkzeugs wäre Vertrag: ihr Wortlaut hängt an der Locale (`Fehler`/`Error`, gemessen) und das Format ist keine Zusage von `make`; das bats-Image, in dem `make test` die Fälle fährt, trägt kein `make` — ein Fall, der die Ziffer liest, ist dort nicht haltbar (Messung unten); die Zeile mit der Klasse steht nicht an fester Stelle — unter `-C` folgt ihr eine Zeile, unter einem umschließenden `make` ist die letzte Meldung die des äußeren mit `Fehler 2` und die Klasse steht nur in der des inneren (gemessen); die Ziffer ist der Status des Rezept-Kommandos und trägt die Klasse nur, solange das Kommando das Skript allein ist; ein Direktaufruf ohne `make` hat keine Meldung, er trägt die Klasse im Prozess-Exit |

**Warum E trotz F trägt.** F ist billiger und für einen lesenden Menschen ausreichend; gegen F spricht
nicht, dass die Ziffer falsch wäre, sondern dass der Prozedur-Schritt und der Job **einen Text lesen,
den das Repo hält**. Ein Fall, der die Ziffer läse, wäre dort baubar, wo `make` verfügbar ist; die
Fälle des Werkzeugs laufen im gepinnten bats-Image (`BATS_IMAGE`, `grep -n '^BATS_IMAGE' Makefile`), und
das trägt kein `make`: `docker run --rm --pull=never --entrypoint sh <BATS_IMAGE> -c 'command -v make;
echo "exit=$?"; make --version'` → `exit=127` und `sh: make: not found`. Die Zeile ist dort mit Stubs
hermetisch haltbar, die Meldung von `make` nicht — und ein Vertrag ohne haltenden Fall bricht ungesehen
([`AGENTS.md`](../../../AGENTS.md) §3.6). Dazu bestimmen Locale, `make`-Version und Umgebung des Aufrufers
Wortlaut und Stelle der Meldung. E kostet eine Zeile im Skript und ihre Zähne, die im Werkzeug schon
stehen; die Begründung der Festlegung ist damit die **Festigkeit des Vertrags**, nicht eine
Unlesbarkeit der Klasse über `make`.

## Konsequenzen

- **Positiv:** die drei Stellen sind gelesen, statt zu bleiben und den Leser über `make` zu täuschen;
  die Trennung von Formel-Unterschied und Nicht-Ausführbarkeit steht über `make` in einem Text, den
  das Repo hält; der Prozedur-Schritt hat ein Objekt, an dem er die Klasse liest.
- **Negativ:** ein Leser von ADR-0064 findet den Wortlaut der drei Stellen unverändert, bis der Zusatz
  im ADR-Index steht (Folgepflicht 3); die Klasse steht in einem Text, den nur ein Fall hält, kein
  Typ; die Zeile ist bei einem Signal, bei nicht beschreibbarer stderr und bei fehlendem Modus nicht
  zugesagt; die Klasse steht über `make` zweimal (Zeile und Ziffer der Meldung), und nur die Zeile
  ist Vertrag.
- **Folgepflicht 1 — die lebenden Artefakte, die das Werkzeug beschreiben** (Skript-Kopf,
  Makefile-Kommentar, README-Zeile, Plan des liefernden Slice), nennen den Exit des **Skripts** und die
  Zeile als Träger der Klasse über `make`; wo sie einen Exit nennen, nennen sie die Ebene; wo sie die
  Position der Zeile nennen, nennen sie die Bedingung (*über `make <ziel>` aus dem Wurzelverzeichnis die
  vorletzte Zeile der Ausgabe*); wo sie die Nicht-Zusage bei einem Signal nennen, nennen sie neben der
  Zeile die Klasse (*ein Ende durch ein Signal ist keine der drei Klassen*).
- **Folgepflicht 2 — die Prozedur** ([`docs/user/releasing.md`](../../user/releasing.md), Folgepflicht 3
  von ADR-0064) liest die Klasse an der Zeile: *„`tap-check` rot mit der Zeile `tap-check: Exit 1`"* ist
  ein Formel-Unterschied, `tap-check: Exit 2` nicht ausführbar.
- **Folgepflicht 3 — der Zusatz an der Status-Zelle von ADR-0064 im ADR-Index** (*„revidiert durch
  ADR-0066"*, Umfang: die Lesart des Exit-Ergebnisses an den drei Stellen). **Diese Entscheidung ordnet
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
- **Wenn ein Ergebnis der Nutzlast außerhalb von „gleich", „Unterschied" und „nicht ausführbar" entsteht
  oder ein zweiter Aufrufer der Nutzlast die Klasse aus ihr statt aus dem Skript liest** *(beobachtbar am
  Schnitt, der den Modus `sync` implementiert)*: die Klasse des Skripts ist dort nicht mehr der Exit, den
  es aus dem Vergleich herleitet; neu zu wägen sind Festlegung 1 und der Träger für diese Klasse.

**Wer diese Trigger beobachtet — und wer nicht.** Ein Sensor, der eine dieser Bedingungen liest, besteht
nicht: die Module des Doku-Gates halten keinen Trigger gegen den Zustand, den er beschreibt
(`grep -n '^modules:' .d-check.yml`). Der Träger ist das
**Trigger-Audit der ADR-Klasse** bei der Closure (Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur Schritt 2; ohne Wellen-Betrieb bei jeder Slice-Closure, Tabelle *Träger im
Repo ohne Wellen*). **Trigger 3** hat damit einen Anlass: die Closure des Slice, der den Modus `sync`
implementiert, trägt die Frage in ihrem Audit; ein Sensor darüber besteht nicht, und eine Closure, die
das Audit auslässt, wird nicht erwischt. **Trigger 1 und Trigger 2 haben keinen Anlass:** sie hängen an
einem neuen Aufrufer und an einem roten Lauf, den keine Closure zwingend berührt — **benannt, nicht
geschlossen**. Wer sie bemerkt, trägt sie als Beobachtung ins Register; diese Route hat nur eine
Closure, ein Lauf außerhalb einer Closure hat keine. Für Trigger 2 ist die Lücke begrenzt: ein Schritt,
der `tap-check` fährt, bleibt bei einem Signal, bei nicht beschreibbarer stderr und bei fehlendem Modus
rot; der Fehlgriff ist ein Lesen als Klasse 2, nie ein Grün.

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
| 2026-09-24 | **Proposed** | Architect-Lauf: die drei Stellen von ADR-0064, die einen `make`-Exit 1 nennen, sind mit GNU Make nicht herstellbar (Messung in §Kontext); die Klasse des Skripts und ihr Träger über `make` sind die Festlegungen. Der Acceptance-Trigger steht oben |
| 2026-09-25 | **Accepted** | Beleg nach [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 ist die Reviewer-Runde `2026-09-25-adr-0066-exit-klassen-des-tap-werkzeugs-runde-2` — sie meldet annahmefähig an der Substanz, kein HIGH und kein MEDIUM; die Annahme selbst hat der Auftraggeber am 2026-09-25 erteilt. **Ab hier bindet [`AGENTS.md`](../../../AGENTS.md) §3.4:** Korrekturen entstehen als Folge-ADR mit `Supersedes ADR-0066`. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0066` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
