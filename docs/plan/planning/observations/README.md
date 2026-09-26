# Beobachtungs-Register

Regeln dieser Ablage: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register — wer schreibt, wer liest, wann gestrichen wird,
welche Form ein Beleg hat, welchen der drei Ausgänge ein Eintrag ab 3× trägt,
und dass eine leere Ablage nur diese `README.md` trägt statt zu verschwinden.

**Form.** Je Beobachtung ein Verzeichnis `BEO-<KUERZEL>/<slug>/` mit drei Dateien, drei
Lebensdauern: `observation.md` (unveränderlich ab Anlage: Bezeichnung, Sub-Area, Kurzbeschreibung)
· `state.md` (veränderlich: `offen` oder einer der drei Ausgänge) ·
`evidence/<vorgangs-id>.md` (unveränderlich ab Merge, eine Datei je Auftreten). Es gibt **kein**
Zähler-Feld: der Zähler ist die Zahl der Dateien unter `evidence/`.

**Wer schreibt:** die **Slice-Closure** — ein neues Verzeichnis anlegen **oder** eine weitere Datei
in ein vorhandenes `evidence/` legen. Der Zähler läuft damit mit jedem geschlossenen Slice und
nicht mit der Welle. Das ist hier nicht bloß bequem: dieses Repo führt Wellen-Betrieb **und**
wellenlose Slices
([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)),
und ein wellen-getragener Zähler hätte für die zweite Hälfte keinen Träger.

**Wer liest:** die **Welle-Closure** liest, was **3×** erreicht hat; die **Slice-Planung** liest in
§8 ihres Plans, was darunter steht. Wer nur den ersten Schritt kennt, sieht alles unter 3× nie
wieder an.

**Belege sind formgebunden:** der Dateiname unter `evidence/` **ist** die Kennung eines
abgeschlossenen Vorgangs, kein Freitext-Feld. Regelfall ist der Slice (`slice-<Kennung>.md`); auch eine
Welle und ein Review-Report sind abgeschlossene Vorgänge und taugen als Beleg — die Lage ist dann
der Ort, an dem ihre Klasse abschließt.

**Ein Vorgang zählt einmal.** Zwei Funde im selben Slice sind eine Gelegenheit, kein zweites
Auftreten: Der Zähler misst Wiederholung über Vorgänge hinweg, nicht die Zahl der Funde — das
erzwingt hier das Dateisystem, nicht die Disziplin. Ein Vorkommen **ohne** abgeschlossenen Vorgang
bekommt keine Datei unter `evidence/` und bewegt den Zähler nicht; es gehört trotzdem in
`observation.md` unter „Benannt, nicht gezählt" — *benannt, nicht gezählt*.

**Ein Verzeichnis ohne Beleg ist ein Befund der Register-Paarung (c), keine Ausnahme**
([`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
Festlegungen 1 bis 3). „Benannt, nicht gezählt" ist ein **Abschnitt im belegten Eintrag** der
Klasse; eine zweite Sorte Verzeichnis mit eigener Form, eigenem Stand oder eigener Marke gibt es
nicht. Steht das einzige Vorkommen einer Klasse dort, ist der Eintrag einer, dem sein Beleg **noch
fehlt**. Der Befund endet, wenn ein abgeschlossener Vorgang das Vorkommen trifft und seine Kennung
als Datei unter `evidence/` liegt; ein Beleg wird nicht erfunden, und ein Vorgang, der die
Beobachtung nur verwaltet, ist kein Auftreten. Eine Klasse, deren Vorkommen eine Aussage über den
Bestand ist, ist keine Ausnahme (Festlegung 4): welche Vorgänge sie trafen, urteilt der Planner je
Vorgang.

**Die zweite Hälfte von (c) — jedes Verzeichnis trägt ein nicht leeres `evidence/` — gilt im
Closure-Schritt über das ganze Register**, nicht über die Verzeichnisse, die die Closure angelegt
oder berührt hat. Gezählt werden **Dateien** `evidence/*.md`, nicht das Verzeichnis, und die
Closure nennt jedes Verzeichnis ohne eine solche Datei namentlich; sie behauptet die Hälfte dann
nicht als getragen. Das Kommando liefert Zahl und Namen (keine Erwartungswerte, der Bestand wandert
mit jeder Closure —
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)):

```sh
for d in docs/plan/planning/observations/BEO-ALL/*/; do
  n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -eq 0 ] && echo "$d"; done
```

Ein Wächter dafür existiert nicht; das Kommando ist ein Lauf von Hand.

**Ab 3× trägt `state.md` genau einen von drei Ausgängen** — eine geschlossene Menge, kein
Freitext:

| Ausgang | Wann | Wohin |
|---|---|---|
| **verkörpert** | die Regel steht — **auch dann, wenn sie nicht bewacht ist** | der **Zielort**, an dem sie steht, und daneben der Herkunfts-Anker (`seit welle-<Kennung>` bzw. `seit slice-<Kennung>`), wo die Regel aus dem Steering Loop entstand; folgt sie aus Lastenheft, Spezifikation, Baseline oder ADR, trägt der Zielort an dieser Stelle seine eigene Kennung |
| **geplant** | die Regel ist beschlossen, aber noch nicht geschrieben | Kennung des Slice oder der Welle, die sie schreibt |
| **gestrichen** | die Beobachtung kann nicht mehr auftreten | die Begründung, warum sie nicht mehr auftreten kann |

**Der Zielort ist ein Norm-Artefakt — ein Lauf ist keiner.** Ist der Inhalt der Beobachtung eine
**benannte Lücke** (*die Klasse ist benannt, kein Wächter fängt sie*), trägt sie `verkörpert`,
sobald die Regel **und** die Aussage über ihre fehlende Bewachung an **einem** Zielort stehen; die
fehlende Bewachung steht als Abschnitt *Grenze der Verkörperung, benannt* in `state.md`. Ein Satz
der Form *„Träger ist der Lauf, der X schreibt"* nennt **keinen** Zielort: Er sagt, **wer** die
Regel wirksam hält, und gehört in dieselbe Grenze. **Hat die Klasse keinen Zielort** — steht sie
nirgends normiert —, trägt sie `geplant`: Der Lese-Schritt schneidet einen Träger und nennt seine
Kennung. **Ein vierter Ausgang entsteht nicht**
· seit slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke.

**Der Lese-Schritt liest alle Einträge über der Schwelle, zu seinem Zeitpunkt** — nicht nur die
seit dem letzten Lauf neu übergetretenen. `offen` über der Schwelle ist damit **zwischen zwei
Lese-Schritten** zulässig und vorübergehend; danach ist es eine **Vollzugs-Lücke des Schritts**,
kein Ausgang
· seit slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke.

Zugewiesen wird der Ausgang vom **Lese-Schritt**; zwischen dem Beleg, der den Zähler auf 3 hebt,
und diesem Schritt trägt `state.md` noch `offen` — das ist zulässig und vorübergehend. Unterhalb
der Schwelle ist `offen` der Normalzustand, kein Ausgang. **Gestrichen heißt nicht gelöscht:** Das
Verzeichnis bleibt liegen, `state.md` trägt `gestrichen` mit Begründung — wer still löscht, macht
die Beobachtung ununterscheidbar von einer, die es nie gab.

**Die Sub-Area** trägt in `observation.md` einen Namen, den die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
führt — **nicht** die, in deren Verzeichnis die Beobachtung aufgefallen ist, sondern die, deren
Konventions-Härte oder Inventur-Linie sie betrifft. Das `<KUERZEL>` im Verzeichnisnamen wird aus
derselben Tabelle **nachgeschlagen, nicht erfunden**: Steht in `observation.md` ein Name, den die
Modus-Deklaration nicht führt, ist entweder die Zuordnung falsch oder die Deklaration
unvollständig.

**Ist nichts offen**, steht in dieser Ablage nur diese `README.md` — ein leeres Verzeichnis führt
`git` nicht. Ohne sie wäre *nichts beobachtet* nicht von *nie geführt* zu unterscheiden.

**Zwei Verweis-Formen, ein Kriterium: was wird zitiert.** Ein Verweis auf das Register **als
Mechanismus** — *das Register sichten*, *der Zähler wird abgeleitet*, *wer schreibt/liest* —
zeigt auf diese `README.md`. Ein Verweis auf **eine konkrete Beobachtung** — ihre Bezeichnung,
ihr Stand, ihr Zähler — zeigt auf deren eigene `observation.md` (Kennung `BEO-<KUERZEL>/<slug>`).
Die erste Form überlebt jede Umbenennung eines Eintrags, die zweite bricht mit ihr — genau das
macht sie zur richtigen Wahl, wenn der Verweis wirklich diese eine Beobachtung meint und nicht
das Register als Ganzes.
