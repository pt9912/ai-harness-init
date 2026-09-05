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
abgeschlossenen Vorgangs, kein Freitext-Feld. Regelfall ist der Slice (`slice-<NNN>.md`); auch eine
Welle und ein Review-Report sind abgeschlossene Vorgänge und taugen als Beleg — die Lage ist dann
der Ort, an dem ihre Klasse abschließt.

**Ein Vorgang zählt einmal.** Zwei Funde im selben Slice sind eine Gelegenheit, kein zweites
Auftreten: Der Zähler misst Wiederholung über Vorgänge hinweg, nicht die Zahl der Funde — das
erzwingt hier das Dateisystem, nicht die Disziplin. Ein Vorkommen **ohne** abgeschlossenen Vorgang
bekommt keine Datei unter `evidence/` und bewegt den Zähler nicht; es gehört trotzdem in
`observation.md` unter „Benannt, nicht gezählt" — *benannt, nicht gezählt*.

**Ab 3× trägt `state.md` genau einen von drei Ausgängen** — eine geschlossene Menge, kein
Freitext:

| Ausgang | Wann | Wohin |
|---|---|---|
| **verkörpert** | die Regel steht | Zielort **und** Herkunfts-Anker (`seit welle-<NN>` bzw. `seit slice-<NNN>`) |
| **geplant** | die Regel ist beschlossen, aber noch nicht geschrieben | Kennung des Slice oder der Welle, die sie schreibt |
| **gestrichen** | die Beobachtung kann nicht mehr auftreten | die Begründung, warum sie nicht mehr auftreten kann |

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
