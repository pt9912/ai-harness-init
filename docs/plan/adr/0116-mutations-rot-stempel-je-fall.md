# ADR-0116: Die Mutations-Rot-Stempel werden je Fall gestempelt — die je-Fall-Keys `.harness/state/mutate-rot-<fall>.key` reisen mit dem Klon, der Nacht-Vollsweep konsultiert sie

**Status:** Accepted

**Datum:** 2026-11-28

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Revidiert (Teil-Supersede):** die Festlegung 4 von
[ADR-0114](0114-mutations-gruen-vorlauf-je-driftfaecher.md) in zwei Sätzen —
*„Kein Stempel-Schreiber am Mutations-Zug"* und der Schlusssatz *„Der CI-Vollsweep
(mutate.yml, je Shard seine `MUTATE_CASES`) fährt unverändert die volle Fall-Menge"*. Die
übrigen Festlegungen von [ADR-0114](0114-mutations-gruen-vorlauf-je-driftfaecher.md)
(Vorlauf je Drift-Fächer, env-Auszug, Fall-Sensor-Wächter, die benannte Lücke und die
Konsum-Skizze) bleiben **Accepted** und unberührt. Unberührt bleiben ebenso: die
Schreiber-Kette von [ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
Festlegung 5 — **kein Mutations-Zug schreibt je-Check-Keys oder E2E-Keys**, die Mutations-Züge
rechnen sie weiter nur lesend; der Beleg-Slot von
[ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 5 — die
neue Klasse nimmt seine Vollauf/Teillauf-Form, sie erweitert sie nicht; die Ablage-,
Granularitäts- und Hash-Ausnahme-Formen von
[ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
(supersedes-Ablageort, `HASH_AUSNAHMEN` — hier am selben Ort **erweitert**, kein Widerruf)
und von [ADR-0107](0107-die-mutations-record-granularitaet-ist-je-fall.md) (Fall-Records als
Chronik — der Stempel ist daneben der Zustand, siehe Festlegung 1). §3.5 bindet die Revision:
der Nacht-Vollsweep fährt nach diesem ADR **weniger** — jede Grenz-Senkung ist diese ADR,
kein PR-Kommentar.

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein SKIP des Vollsweeps behauptet nur, was der Stempel und seine Bindungen decken — der
transportierte Satz behauptet nur, was ein Lauf trug, und entzieht die Aussage, wenn ein
frischer Lauf sie widerspricht),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (dieselbe Form am Host
und auf CI — Frisch-Rechnung gegen Transport über denselben Satzerzeuger, kein zweiter
Maßstab),
[ADR-0114](0114-mutations-gruen-vorlauf-je-driftfaecher.md) (die revidierte Festlegung 4;
Festlegung 3 trägt die Fall-Sensor-Form, aus der der `waechter`-Wert gelesen wird),
[ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) (die committed-Key-Klasse,
die gitignore- und Hash-Ausnahme-Form, die Lesart *ein Stempel deckt sich nicht selbst* und
die Nicht-Committierungs-Lesart des Schreibers),
[ADR-0113](0113-der-e2e-stempel-wird-je-variante-gestempelt.md) (die Feld-Form des
Satzerzeugers: Form- und Selbst-Bindung je Datei, `mengen-hash`-Zeile, je-Deckungs-Konsum),
[ADR-0107](0107-die-mutations-record-granularitaet-ist-je-fall.md) (die Fall-Kennungs-Erkennung
und die Treiber-Unterkommando-Form `--stamp-records`, hier als `--stamp-keys` parallel),
[ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md) (die
Namens-Kontrast-Form der Stempel-Klassen und die fail-closed-Ausnahme-Klausel),
[ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 5 (der
Beleg-Slot: der volle Lauf schreibt nach dem Bericht, der Teillauf nie),
[ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) (Abgrenzung: die
Keys blocken kein Turn-Ende),
[`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
(die CI ruft ausschließlich make-Targets — der Nacht-Konsum ist eine Selektion im
Nacht-Workflow, keine zweite Gate-Definition),
[`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(fail-closed je Zweifel),
[`MR-059`](../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang)
(die zugelassenen Fall-Kennungs-Formen),
[`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
/ [`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
(die Anlagen-Disziplin: `# files:`/`# verify:` der Fall-Datei ist die Träger-Tafel)

**Schärft:** — Prozess-ADR ohne Spec-Stratum, dieselbe Lesart wie
[ADR-0114](0114-mutations-gruen-vorlauf-je-driftfaecher.md): der Mutations-Treiber trägt
keinen Gate-Vertrag ([`harness/sensors/mutate.md`](../../../harness/sensors/mutate.md): kein
Gate); die Ordnungskante `record-gates: <checks>` bleibt unberührt. Die Senkungs-Bindung von
§3.5 steht im Kopf (Revidiert) — der Vollsweep-Satz und der Schreiber-Satz der Festlegung 4
von [ADR-0114](0114-mutations-gruen-vorlauf-je-driftfaecher.md) sind die Grenze, die dieser
ADR nachzieht.

---

## Kontext

Die Mutations-Fälle (`test/mutations/`, Bestand **824**, kein Erwartungswert — die Zahl wandert
mit `make mutate-greift`) sind die Rot-Belege der Zusage-Klassen von
[`AGENTS.md`](../../../AGENTS.md) §3.6: je Fall behauptet eine Zusage, dass ihr Wächter rot
färbt, wenn die Zeile kippt, und der Fall misst genau das — die Mutation färbt den
`# verify:`-Sensor rot am benannten Grund. Diese Rot-Fahrt wird heute dreifach transportiert,
und keiner trägt den Zustand *je Fall*: die `mutate-ergebnis.txt` am CI-Branch verfällt mit
dem Branch, der Beleg-Slot (`.harness/state/`, nicht committet,
[ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)) trägt nur den
letzten vollen Lauf, und die Fall-Records (`.harness/stamp/mutate/<fall-kennung>.txt`,
[ADR-0107](0107-die-mutations-record-granularitaet-ist-je-fall.md)) tragen die Chronik je
Sweep-Lauf — aber kein adressierbarer Zustand, *was dieser Fall über diesen Prüfgegenstand
bewiesen hat*. Der Nacht-Vollsweep (`mutate.yml`) wiederholt daher je Nacht alle Fälle, auch
die, deren Prüfgegenstand seit der letzten Rot-Fahrt unverändert ist. Das je-Check- und
je-Variante-Muster ([ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md),
[ADR-0113](0113-der-e2e-stempel-wird-je-variante-gestempelt.md)) trägt dieselbe Eigenschaft
schon auf der Kante und der E2E: der transportierte Satz, verglichen gegen die Frisch-Rechnung
eines Satzerzeugers, trennt den gedrifteten vom gedeckten Anteil. Für die Mutations-Fälle
fehlt diese Form — und [ADR-0114](0114-mutations-gruen-vorlauf-je-driftfaecher.md) Festlegung 4
hat den Stempel-Schreiber am Mutations-Zug ausdrücklich ausgeschlossen, weil kein
Stempel-Konzept bestand, nicht weil die Klasse unmöglich wäre.

## Entscheidung

Wir wählen: **Je Mutations-Fall eine committete Rot-Stempel-Datei `.harness/state/mutate-rot-<fall>.key`,
gebunden an einen Prüfgegenstand-Hash aus der Fall-Anlage selbst; ein Treiber-Unterkommando
schreibt und entzieht je Zeile des Result-Files; der Nacht-Vollsweep konsultiert die
transportierten Stempel je Fall, fail-closed; kein Rück-Stempel aus der CI.** Sechs Festlegungen:

**1. Die Stempel-Klasse — je Fall eine Datei, drei Zeilen, der Name trägt `rot`.**
Die Klasse ist `.harness/state/mutate-rot-<fall>.key`, `<fall>` ist der Stamm der Fall-Datei
unter `test/mutations/` (einzig im Verzeichnis; die Konsum-Kennungs-Erkennung trägt die
zugelassenen Formen je [`MR-059`](../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang)).
Je Datei drei Zeilen, je Form der [ADR-0113](0113-der-e2e-stempel-wird-je-variante-gestempelt.md)
Festlegung 1: `fall <stamm>` (Form- und Selbst-Bindung — der Datei-Name wird gegen diese Zeile
gelesen; ein fremdes Feld, eine falsche Zeile, ein Datei-Name ohne Zeile ist unformal), `waechter <modus>`
(der `# verify:`-Wert der Fall-Anlage, sonst `narrow_sensor` — dieselbe Lesart wie
[ADR-0114](0114-mutations-gruen-vorlauf-je-driftfaecher.md) Festlegung 3) und `pruefgegenstand <64-hex>`
(der Hash des Satzerzeugers, Festlegung 2). Kein Datums-Feld, keine Commit-SHA-Stelle (zirkulär,
[ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Festlegung 3); die Chronik
tragen `git` und die Fall-Records der
[ADR-0107](0107-die-mutations-record-granularitaet-ist-je-fall.md). **Namens-Kontrast-Zeile:** unter
`.harness/state/` liegen jetzt drei committete Key-Klassen je Stufen-Einheit — je Check
(`gates-passed-<check>.key`, der Nachweis der Kante), je Variante (`full-smoke-passed-<variante>.key`,
der E2E-Nachweis) und je Fall (`mutate-rot-<fall>.key`, die Rot-Aussage) — neben der
nicht-committeten Gesamt-Klasse (`.diffsha`/`.head`) und neben der Chronik-Klasse
`.harness/stamp/mutate/` ([ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
/ [ADR-0107](0107-die-mutations-record-granularitaet-ist-je-fall.md)). **Der Stempel behauptet
eine Rot-Fahrt, nie ein Grün** — der Präfix `mutate-rot-` trägt die Richtung: eine Mutation,
die ihren Wächter nicht rot färbt, ist ein Befund, und das Grün-Verdikt wäre ein
Erfolgs-Zustand, den kein Lauf trug. Ein Stempel ist der **Zustand** je Fall, die Fall-Records
sind die **Chronik** je Sweep-Lauf; beide driften erst, wo ein frischer Lauf den Stempel
widerspricht — das ist der Re-Evaluierungs-Trigger 3, kein stiller Zweifach-Bestand.

**2. Der Satzerzeuger `mutate-keys.sh` — die Fall-Anlage ist die Tafel.**
Ein Satzerzeuger neben [`gates-keys.sh`](../../../harness/tools/gates-keys.sh) und
`full-smoke-varianten.sh` (Form je [ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md)
/ [ADR-0113](0113-der-e2e-stempel-wird-je-variante-gestempelt.md) Festlegung 1: `menge <fall>`
(Die Dateien zeilenweise), `hash <fall>` (64 hex), `alle`, Hermetik-Form `--wurzel`) mit dem
unterscheidenden Zug: **es gibt keine zweite Tafel außer der Fall-Anlage.** Die `menge <fall>`
sind die Inhalte der `# files:`-Zeilen des Falls **samt der Fall-Datei selbst** — die
Anlage-Disziplin ([`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
/ [`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit))
läuft damit ohne Zusatzkonfiguration: ein Fall-Edit (Anlage, `# files:`, `# verify:`) dreht den
eigenen Prüfgegenstand-Hash und entwertet den eigenen Stempel — die Selbst-Bindung liegt in der
Menge, nicht in einer Tafel-Datei daneben. Eine Fall-Anlage ohne lesbares `# files:`/`# verify:`-Paar
bricht den Satzerzeuger fail-closed
([`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed),
[`MR-059`](../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang)-Werkzeug-Form).
**`MENGE_AUSSCHLUESS`-Form:** die Key-Klasse selbst steht in keiner ihrer eigenen Mengen —
*ein Stempel deckt sich nicht selbst*
([ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Festlegung 1, derselbe
Grund für die je-Check-Keys und die E2E-Keys).

**3. Die Schreiber-Kette — das Unterkommando schreibt und entzieht, `make` committiert nicht,
die CI stempelt nicht zurück.** Das Treiber-Unterkommando `--stamp-keys <result-file>` (Form je
`--stamp-records`,
[ADR-0107](0107-die-mutations-record-granularitaet-ist-je-fall.md) Festlegung 3: verb-Schalter
vor `main`, vollständige Prüfung **dann** Anhang, jede Grenze bricht mit Meldung ohne den
Bestand anzutasten) liest das Result-File eines **vollen** Laufs und trägt je Urteil-Zeile
einen Zug: aus einer `ok`-Zeile schreibt es den Key des Falls, aus einer `BEFUND`-Zeile
**entzieht** es einen bestehenden Key desselben Falls (Datei löschen). Das Entziehen ist die
fail-closed-Richtung: ohne ihn würde der transportierte Satz einen frischen Befund verdecken —
der Konsum des Stempels darf die Konsequenz seines Gegenstands nicht zum Schweigen bringen
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine
Ebene tiefer). **Nur der Vollauf (`MUTATE_FORCE=1`) schreibt und entzieht — der Teillauf
(`MUTATE_CASES`) schreibt nie** je Form des Beleg-Slots
([ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 5; die
Attributions-Grenze zwischen vollen und Teilläufen trägt dieselbe Unterscheidung hier weiter,
kein zweiter Maßstab). **Der Schreiber-Rest:** ein `BEFUND`, dessen Key nicht entzogen wird
(der Aufrufer vergisst den Zug), verdeckt am nächsten Vollsweep — kein Wächter hält den
entzogenen Zug; sein Träger ist der Re-Evaluierungs-Trigger 3 und der
Aufrufer-Reihenfolge-Zwang (lesen → stampen → entziehen → committen → räumen,
[ADR-0107](0107-die-mutations-record-granularitaet-ist-je-fall.md) Festlegung 3-Form). **Kein
make-Target committiert und die CI stempelt nicht zurück** — der Commit gehört dem aufrufenden
Zug, dieselbe Lesart wie [ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
Festlegung 5: der Vollauf ist ein Host-Aufruf mit Commit-Kontext, der Nacht-Workflow hat
keinen, und ein Rück-Stempel aus dem Nacht-Workflow wäre ein Push auf `main` ohne
Implementer-Kette — die fail-closed-Richtung trägt die Lücke: ein veralteter Satz bedeutet,
die nächste Nacht fährt die gedrifteten Fälle (Minuten), nicht dass ein Befund geschluckt
würde. Die Schreiber-Kette von
[ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Festlegung 5 bleibt
unverändert — kein Mutations-Zug schreibt je-Check-Keys oder E2E-Keys
([ADR-0114](0114-mutations-gruen-vorlauf-je-driftfaecher.md) Festlegung 4 in diesem Umfang).

**4. Der Konsum — der Nacht-Vollsweep konsultiert je Fall; der Fall-Sensor läuft weiter
unbedingt.** Die Fall-Selektion des Nacht-Workflows (`mutate.yml`) konsultiert die Stempel je
Form der [ADR-0113](0113-der-e2e-stempel-wird-je-variante-gestempelt.md) Festlegung 3-Form.
Ein Fall fährt **immer** (fail-closed,
[`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)),
wenn eine dieser Grenzen greift: der Stempel fehlt, ist unformal (Zeilen-Form, Selbst-Bindung),
fremd, oder der Satzerzeuger bricht; oder der Fall trägt `waechter narrow_sensor` — ein Fall
ohne eigenen `# verify:`-Modus hat keinen baum-abgeleiteten Schlüssel seiner Prüf-Klasse, und
über einer Klasse ohne Schlüssel wird nicht geskippt. Der deckende Skip braucht über der
Stempel-Form hinaus **die Prüf-Klasse-Bindung**: der je-Check-Key des `waechter`-Modus deckt den
Baum nach der Frisch-Rechnung
([ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Festlegung 2) — für die
`test`-Nähe gilt der `test`-Key (die überfahrende Richtung: ein Drift in einem Teil fährt die
Fälle, nie weniger), für `ci-lint`/`shell-lint` ihr Key, für `full-smoke` der je-Variante-Satz
je [ADR-0113](0113-der-e2e-stempel-wird-je-variante-gestempelt.md) Festlegung 3. **Der
Treiber-Vorlauf und der Fall-Sensor bleiben keine Konsumenten:**
[ADR-0114](0114-mutations-gruen-vorlauf-je-driftfaecher.md) Festlegung 3 läuft unverändert —
der Fall-Sensor trägt die Rot-Erwartung am Lauf selbst, seine Attributions-Leistung braucht die
Rot-Fahrt im Zug, kein Stempel ersetzt sie; `make mutate-greift` misst die Anlage, nicht die
Rot-Fahrt, und konsultiert nicht. Die Fall-Records
([ADR-0107](0107-die-mutations-record-granularitaet-ist-je-fall.md)) sind der Beleg der
gelaufenen Läufe weiter — der Stempel ist kein Konsum-Ersatz für sie. Der Beleg-Slot
([ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)) bleibt wie er ist.

**5. Die gitignore- und Hash-Ausnahme — derselbe Glob am selben Block.** Der
[`.gitignore`](../../../.gitignore)-Ausnahme-Block bekommt die Zeile
`!.harness/state/mutate-rot-*.key` (Form je
[ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Festlegung 1 /
[ADR-0113](0113-der-e2e-stempel-wird-je-variante-gestempelt.md) Festlegung 5), und die
`HASH_AUSNAHMEN` von [`working-tree-hash.sh`](../../../harness/tools/working-tree-hash.sh)
bekommt denselben Glob. Der Grund steht am Eintrag (ADR-0103 Festlegung 2-Fassung): *ein
Stempel-Commit rotiert keinen Baum-Hash und keinen Key — ein Stempel deckt sich nicht selbst*.
Die fail-closed-Klausel bleibt unberührt: Inhalt unter `.harness/state/` außerhalb der
deklarierten Klassen färbt den Baum-Hash-Wächter rot — der Glob deckt genau die Stempel-Klasse,
und ein falsches Namensmuster ist an derselben Klausel sichtbar. **Erstbestand: leer.** Keine
Key-Datei existiert vor dem ersten gelaufenen Vollauf, und keine wird retro-angelegt — ein Key
ohne gelaufene Rot-Fahrt wäre eine gefälschte Rot-Aussage
([`AGENTS.md`](../../../AGENTS.md) §3.6-Form); der Schreiber der Festlegung 3 ist der einzige
Zugang. Cutoff-Form: gebunden ist die Stempel-Klasse, die mit dieser ADR entsteht.

**6. Implementations-Slice-Skizze, Kennung `slice-mutate-rot-stempel-v1`.** Drei Liefer-Punkte,
je zwei Schichten (Harness-Mechanik + Stempel-Form): (a) der Satzerzeuger
`mutate-keys.sh` samt Wächter (hermetisch über `--wurzel`-Fixtures und Fall-Anlagen:
deterministischer Hash, ein Inhalt-Edit **innerhalb** der `# files:`-Menge dreht ihn, einer
außerhalb nicht; eine Anlage ohne `# files:`/`# verify:`-Paar bricht fail-closed) samt
Ausnahmen-Nachzug (gitignore, `HASH_AUSNAHMEN`, Festlegung 5); (b) der Schreiber-Zug am
Treiber: das Unterkommando `--stamp-keys` mit Schreiben, Entziehen und den Grenzen aus
Festlegung 3; (c) der Konsum-Zug: die Fall-Selektion des Nacht-Workflows konsultiert je Fall
(Stempel-Form + Prüf-Klasse-Bindung, Festlegung 4) samt hermetischem Wächter über der
Selektions-Eingabe. Dazu die Mutations-Fälle je
[`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
/ [`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit):
(c-1) der Konsum liest ein fremdes Feld oder eine falsche `fall`-Zeile und fährt statt
fail-closed → rot; (c-2) der `narrow_sensor`-Fall wird geskippt → rot; (c-3) die gitignore- oder
Hash-Ausnahme fällt still weg → rot; (b-1) das Unterkommando schreibt aus einer `BEFUND`-Zeile
einen Key (behauptet Rot ohne Rot-Fahrt) oder entzieht nicht → rot; (a-1) der Satzerzeuger
rechnet die Key-Klasse in die eigene Menge hinein → rot. Die README-Zelle
[`make mutate`](../../../harness/sensors/mutate.md) §CI-Branch nennt die Stempel-Klasse, das
Unterkommando und den Konsum (Form der Folgepflicht je
[ADR-0107](0107-die-mutations-record-granularitaet-ist-je-fall.md)).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun (der Nacht-Vollsweep fährt voll; die Chronik-Klassen tragen) | kein zweiter Stempel-Baum, kein Konsum-Griff | je Nacht laufen alle 824 Fälle über Prüfgegenständen, die seit der letzten Rot-Fahrt unverändert sind; der Zustand je Fall ist in keiner Klasse eine Adresse, und der Beleg der Zusage-Rot-Fahrt verfällt mit dem Branch der `mutate-ergebnis.txt` |
| B — Stempel je Shard oder je Sweep-Lauf | kleinster Bestand, ein Konsum-Profil | dieselbe Lehre wie [ADR-0107](0107-die-mutations-record-granularitaet-ist-je-fall.md) gegen die Lauf-Form: die Shard-Zuteilung ist Lauf-Eigenschaft und wandert; das Urteil *je Fall* ist nur ein Ausschnitt, und eine Klasse, die je Lauf sammelt, ist die Fall-Record-Chronik, die schon existiert — ein zweiter Träger derselben Aussage |
| C — Stempel je `# verify:`-Modus (Modus-Aggregat je Prüf-Klasse) | der Bestand misst im Bereich der Modus-Zahl statt 824 | ein Aggregat über einer Fall-Menge, die der Schlüssel je Modus nicht als Ganzes fuhr — ein Fall-Edit entwertete den Modus-Schlüssel für alle Fälle des Modus, und ein Modus-Stempel behauptet je Fall ein Verdikt, das der Lauf über die Fall-Ebene trug ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |
| D — Stempel je Prüfgegenstand-Satz (Fälle mit gleichem `# files:`-Satz teilen einen Key) | der Bestand misst die Menge der Datei-Mengen | die Rot-Aussage ist Fall × Wächter × Menge — derselbe Satz trägt Fall mit verschiedenen `waechter`-Werten, und ein Zusammen-Prüfgegenstand fasst, was kein Lauf in einem Zug fuhr; die Entzugs-Logik der Festlegung 3 verlöre ihre Fall-Adresse |
| **E — Stempel je Fall (gewählt)** | die kleinste Einheit, die eine ehrliche Aussage trägt: Fall × Wächter × Menge; das je-Check/je-Variante-Muster in seiner letzten Achse; der Entzug hat eine Adresse; die Tafel ist die Fall-Anlage selbst und kann neben ihr nicht driften | 824+ Dateien im Bestand; der Satzerzeuger trägt sie, kein Index daneben — git hält die Chronik |

## Konsequenzen

- Positiv: Der Nacht-Vollsweep fährt je Fall genau dann, wenn sein Stempel, sein
  Prüfgegenstand oder seine Prüf-Klasse driftet; der Beleg der Zusage-Rot-Fahrt je Fall ist
  eine Adresse auf `main` und reist mit jedem Klon. Eine Rot-Unterbrechung (ein Wächter
  verliert die Zähne, die ein Stempel deckte) entzieht sich nicht: der Entzug der Festlegung 3
  fährt die fail-closed-Richtung.
- Negativ: Der transportierte Satz kann veralten — ein Aufrufer, der den Vollauf ohne den
  `--stamp-keys`-Zug fährt, lässt den Satz stehen, und die nachfolgende Nacht fährt die Fälle
  wieder (Minuten, kein verdeckter Befund); einen Widerspruch, der nie entzogen wird, hält kein
  Wächter (Trigger 3). Die Bestands-Größe wächst mit der Fall-Menge — der Satzerzeuger hält
  sie, kein Index daneben.
- Negativ: Die Prüf-Klasse-Bindung der Festlegung 4 ist grob im `test`-Bereich (der `test`-Key
  deckt die `test-bats`/`test-go`-Klassen als Ganzes) — ein Drift in einem Teil fährt die
  verifizierten Fälle alle wieder; die fail-closed-Richtung fährt mehr, nie weniger.
- **Kein Eintrag im Adaptions-Block**, dieselbe Lesart wie
  [ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) und
  [ADR-0114](0114-mutations-gruen-vorlauf-je-driftfaecher.md) (die Baseline kennt keinen
  Mutations-Treiber — `grep -rl 'make mutate' .harness/baseline/v7.0.0/regelwerk/ | wc -l` → 0;
  [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage)).
- Folgepflicht (Implementations-Zug, `slice-mutate-rot-stempel-v1`): die README-Zelle
  [`make mutate`](../../../harness/sensors/mutate.md) §CI-Branch nennt die Klasse, das
  Unterkommando und den Konsum. **Die Grenze (ungenannt wäre die Zusage zu viel):** kein
  Wächter hält die Form-Zeile dort — dieselbe Grenze wie der ADR-0103-Festlegung-Zug
  ([`harness/sensors/mutate.md`](../../../harness/sensors/mutate.md) §CI-Branch,
  Grenze-Absatz); erzwingen kann sie nur der Vorgang, der sie schreibt.

## Fitness Function

| Tooling | Regel | Make-Target |
|---|---|---|
| bats, `test/mutate-keys.bats` (neu, hermetisch über `--wurzel`-Fixture und Fall-Anlagen) | **Happy:** `hash <fall>` liefert 64 hex, deterministisch über zwei Läufe; ein Inhalt-Edit innerhalb der `# files:`-Menge dreht ihn, einer außerhalb nicht; ein Fall-Edit dreht den eigenen Hash (Selbst-Bindung). **Negative:** Anlage ohne `# files:`/`# verify:`-Paar · unbekannte oder mehrdeutige Fall-Kennung → Satzerzeuger bricht fail-closed; Result-File fehlt · leer · doppelte Bestimmung → Unterkommando bricht ohne den Bestand anzutasten. **Boundary:** die Key-Klasse steht nie in einer eigenen Menge (`MENGE_AUSSCHLUESS`-Form); ein `BEFUND`-Zug entzieht keinen fremden Key | `make test` (in `make gates`) |
| Mutations-Fälle, `test/mutations/` (drei, Festlegung 6) | (c-1) der Konsum liest ein fremdes Feld oder eine falsche `fall`-Zeile und fährt statt fail-closed → rot; (c-2) der `narrow_sensor`-Fall wird geskippt → rot; (b-1) das Unterkommando schreibt aus einer `BEFUND`-Zeile oder entzieht nicht → rot; Anlage je [`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand) / [`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit) | `make mutate` (`MUTATE_CASES`) |

**Was hier nicht behauptet wird:** der Rot-Beleg steht **nicht** in dieser ADR — die Wächter
entstehen erst im Implementations-Zug, und das Einweihungs-Kriterium des Slices misst die drei
Klassen am realen Treiber und Satzerzeuger ([`AGENTS.md`](../../../AGENTS.md) §3.6); die
Nacht-Verdrahtung (die Fall-Selektion konsultiert) belegt der reale Nacht-Lauf, nicht ein
lokaler Wächter. **Was kein Wächter hält:** die Schreiber-Ketten-Integrität am Host-Aufruf
(Festlegung 3 — der verpasste Stempel, der verpasste Entzug) und die `narrow_sensor`-Klasse
ohne baum-abgeleiteten Schlüssel (Festlegung 4 — sie fährt deswegen immer, und diese
Fahr-Pflicht ist derselbe Rest wie
[ADR-0113](0113-der-e2e-stempel-wird-je-variante-gestempelt.md) Festlegung 4: was kein
Schlüssel trägt, skippt nichts) — Träger sind die Re-Evaluierungs-Trigger, geprüft im
Trigger-Audit der Closure.

## Re-Evaluierungs-Trigger

Nicht permanent. Vier beobachtbare Bedingungen, jede einzeln auslösend:

1. **Der skippende Vollsweep und die volle Fahrt liefern über demselben Stand verschiedene
   Verdikte** (beobachtbar an zwei Nacht-Läufen, einer mit konsultierendem Satz, einer mit
   `MUTATE_FORCE`) — dann konserviert der Stempel ein Verdikt, das keine seiner drei Bindungen
   deckt; die Bindungs-Breite ist neu zu schneiden, im Extremfall per Folge-ADR mit
   `Supersedes ADR-0116`.
2. **Die Fall-Anlagen-Form ändert sich** (`# files:` oder `# verify:` ändern ihre Lesung, der
   `narrow_sensor`-Baum wächst) — dann ist die Träger-Tafel vor dem ersten gestempelten
   Bestand neu zu zeigen; über einer ungefahren Menge wird kein Key gestempelt
   ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6);
   Form der [ADR-0113](0113-der-e2e-stempel-wird-je-variante-gestempelt.md) Trigger 2).
3. **Ein deckender Stempel wird von einem frischen Lauf widersprochen** — der Vollsweep fährt
   einen Fall trotz deckendem Prüfgegenstand und deckender Prüf-Klasse, oder der Entzug der
   Festlegung 3 verpasst einen `BEFUND` — dann ist das Befund-Urteil vor dem Stempel-Baum zu
   halten: die Bindung deckte eine Wächter-Drift außerhalb `# files:` und Prüf-Klasse; der Fall
   ist neu zu binden, im Extremfall per Folge-ADR mit `Supersedes ADR-0116`.
4. **Der emittierte Baum oder ein Adopter-Target bekommt die je-Fall-Rot-Stempel-Form** —
   eigene Entscheidung mit eigener Deckungs-Messung, einzeln entschieden je
   [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 5-Form (Form der
   [ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Trigger 4).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-28 | **Accepted** | Architektur-Übergabe-Artefakt auf die Auftraggeber-Entscheidung (*„feingranulare eingecheckte Stempel für die Mutationen“*); Annahme durch den Auftraggeber am 2026-11-28. Die Abweichung vom Auftragsentwurf steht in Festlegung 3: das Unterkommando entzieht wie es schreibt — der Auftragsentwurf nannte nur das Schreiben; der Entzug trägt die fail-closed-Richtung, die ohne ihn einen frischen Befund am transportierten Satz verdeckte |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0116` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
