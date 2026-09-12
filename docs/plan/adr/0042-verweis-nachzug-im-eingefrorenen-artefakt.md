# ADR-0042: Der Verweis-Nachzug ersetzt im Zeitdokument die Adresse und in der `Accepted`-ADR nichts

**Status:** Accepted

**Datum:** 2026-09-12

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Gate
dieses Repos hält den Status eines Artefakts gegen die Form seiner Adressen — die Lücke wird
benannt, nicht geschlossen),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Regel, gegen die hier
entschieden wird, stammt aus dem auf einen Tag gepinnten vendored Baum; welcher Tag gemessen ist,
steht an jeder Zitatstelle),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (**Accepted** — Festlegung 1
ist der Kern, den diese Entscheidung von einer Datei auf ihre Klasse weitet; Festlegung 3 bindet
den Schreiber, Festlegung 4 den Beweger),
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) (**Accepted** — die erste Fassung der
Adress-Form-Regel, für Carveouts geschnitten),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (**Accepted** — die Form, in der hier aus dem
Regelwerk zitiert wird; zugleich die Datei, deren §Kontext die hier tragende Unterscheidung schon
gemessen hat und die Festlegung 2 als einzige betrifft),
[ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md) (**Accepted** — die Apparatur der
Referenz-Ventile und ihr Breiten-Wächter, an den Festlegung 3 anschließt),
[ADR-0041](0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) (**Accepted** — Festlegung 4
bindet den Vollzug der Archivierung an den Ausgang dieser Frage),
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) (**Accepted** — der Träger, dessen
Verweis-Nachzug hier geregelt wird; keine seiner Festlegungen wird berührt),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (**Accepted** — woran der
Lauf sich hält, der diese Datei auf `Accepted` setzt),
[`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(der vendored Baum, aus dem die zitierte Regel stammt),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Aussage über die Baseline nennt ihren Tag).

**Schärft:** `—` — Prozess-Entscheidung ohne Spec-Stratum. Sie ordnet das Schreiben in die
Zeitdokumente des Planning-Lifecycle, nicht eine Eigenschaft des Produkts.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

### Was die Entscheidung auslöst

Jeder vom Prozess vorgeschriebene Ortswechsel — der `git mv` des Planning-Lifecycle, der
Archiv-Move der Wellen-Closure — bricht die Verweise auf die bewegte Datei. Beide Träger dieses
Repos ziehen sie darum nach: `make slice-mv` und das Unterkommando `archive-welle`. Ihre
Ausnahmeliste kennt heute **einen** Baum, den vendored (`.harness/baseline/**`); jeder andere wird
geschrieben, auch die Zeitdokumente, die nach Abschluss niemand mehr anfassen soll.

Das ist **13-mal** aufgefallen und jedes Mal notiert statt entschieden —

```sh
ls docs/plan/planning/observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/evidence/*.md | wc -l   # 13
```

**kein Erwartungswert**, der Zähler wandert mit dem Register. Die `state.md` jenes Eintrags weist
die Auflösung ausdrücklich dem Architect zu und benennt bis dahin den bewegenden Lauf als Träger;
dreizehn Läufe haben gemessen, den Preis aufgeschrieben und den Move trotzdem gefahren, weil die
Alternative — dreizehn Mal eine tote Adresse zu hinterlassen — schlechter war. Ein Träger, der
dreizehnmal *„entschieden ist es nicht"* protokolliert, ist kein Träger, sondern eine
Warteschlange.

### Warum jetzt

[ADR-0041](0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Festlegung 4 bindet den
Vollzug der ersten Archivierung an den Ausgang genau dieser Frage. Der Träger ist gebaut, die
Betriebsart steht: Die Vorschau des Sammel-Archivs meldet über sauberem Arbeitsbaum **eine**
Sperre, und sie ist **nicht** diese Frage —

```sh
.harness/state/bin/ai-harness-init archive-welle --vorschau altbestand | sed -n '/^  Sperren:/,$p' | grep -c '^    \['   # 1
```

`[haenger]`, die eigenständige Frage, die `slice-216` entscheidet. **Kein Erwartungswert** — die
Zahl wandert mit dem Baum, und ein unsauberer Baum trägt `[unsauber]` daneben.

### Was die adoptierte Baseline sagt

`grundlagen-harness-dateien.md` §harness/README.md als Einstiegspunkt, adoptierte Baseline
`v6.5.0`:

> „**Ein einfrierendes Artefakt nennt ein prozess-bewegtes bei seiner Kennung, nicht unter seiner
> Adresse.** Einfrierend sind die **Zeitdokumente** — Review-Report, Closure-Notiz, Archiv-Stub,
> `Accepted`-ADR, geschlossener Slice: Sie halten eine Messung oder Entscheidung zu ihrem Datum
> fest und werden nicht nachgezogen."

Und, für den Fall, dass die Adresse schon dasteht, dieselbe Stelle:

> „Steht die Adresse erst im eingefrorenen Artefakt, bleiben zwei Wege: es doch anfassen — dann ist
> es kein Zeitdokument mehr — oder ein Ausnahme-Ventil im Prüfbereich, also eine Gate-Senkung mit
> eigener Begründungslast."

**Die Quelle verbietet das Anfassen nicht, sie beziffert es.** Sie nennt zwei Wege und hängt an
jeden einen Preis; welchen dieses Repo zahlt, sagt sie nicht. Der Satz *„werden nicht
nachgezogen"* steht in der **Begründung** der Adress-Form-Regel — er sagt, warum eine Adresse dort
nichts zu suchen hat, nicht, was mit einer bereits geschriebenen zu geschehen hat. Genau diese
Lücke schließt diese Entscheidung.

### Was heute gemessen ist

**1. Die Adress-Form-Regel trägt; der Rest ist Bestand.** In den drei Bäumen, die den größten
Bestand halten, stehen Kennungen und Pfad-Adressen im Verhältnis 1227 zu 220:

```sh
export LC_ALL=C
git grep -ohE '`slice-[0-9]+`' \
  -- 'docs/plan/planning/done/*.md' 'docs/reviews/*.md' 'docs/plan/adr/*.md' | wc -l              # 1227
git grep -ohE '\]\([^)]*planning/(done|open|next|in-progress)/slice-[0-9]' \
  -- 'docs/plan/planning/done/*.md' 'docs/reviews/*.md' 'docs/plan/adr/*.md' | wc -l              #  220
```

**Keine Erwartungswerte** — beide wandern mit dem Bestand. Tragend ist das Verhältnis: Was
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md)/[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
Festlegung 3 und [`AGENTS.md`](../../../AGENTS.md) §3.11 dem Schreiber auferlegen, wird
überwiegend eingehalten. Der Nachzug ist damit kein Dauerzustand, sondern die Abwicklung eines
Bestands, den §3.11 ausdrücklich nicht als Arbeitsauftrag führt.

**2. Der erste Archivierungs-Lauf schreibt zu vier Fünfteln in eingefrorene Artefakte.** Die
Vorschau nennt die betroffenen Dateien mit ihrer Fundstellen-Zahl; nach Baum aufgeteilt:

```sh
.harness/state/bin/ai-harness-init archive-welle --vorschau altbestand |
  awk '/^  Verweise:/{b=1;next} /^  Sperren:/{b=0} b' |
  sed -n 's/^    \(.*\) (\([0-9]*\))$/\1\t\2/p' |
  awk -F'\t' '$1 ~ /^docs\/(plan\/planning\/done|reviews|plan\/adr|plan\/planning\/observations|plan\/carveouts\/done)\//{n++;s+=$2}
              END{print n" Datei(en), "s" Fundstelle(n) eingefroren"}'     # 146 Datei(en), 402 Fundstelle(n)
```

Gegen **32** lebende Dateien mit **114** Fundstellen (dieselbe Kette mit negiertem Muster); die
Vorschau-Kopfzeile nennt die Gesamtsumme selbst (*„178 Datei(en) betroffen"*). **Keine
Erwartungswerte.** Aufgeteilt: `docs/reviews/` 79 Dateien / 150 Fundstellen ·
`docs/plan/planning/done/` 62 / 216 · `docs/plan/carveouts/done/` 2 / 31 ·
`docs/plan/planning/observations/` 2 / 3 · `docs/plan/adr/` **1 / 2**.

**3. Die ADR-Hälfte ist winzig und liegt in einer einzigen Datei.** Die zwei Fundstellen unter
`docs/plan/adr/` stehen beide in [ADR-0016](0016-verweis-traegt-tag-und-zitat.md), beide als
**Inline-Code**, keine als Markdown-Link:

```sh
grep -c 'slice-076-mr-018-umzug-technik-stratum\|slice-015-zitat-sensor' \
  docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md                      # 2
git grep -cE '\]\([^)]*(open|next|in-progress|done)/slice-[0-9]+[^)]*\.md[^)]*\)' \
  -- 'docs/plan/adr/*.md' | grep -v ':0$' | wc -l                         # 2 Dateien, beide Treffer in einem Code-Block
```

Die zweite Zeile findet zwei Dateien; in beiden steht die Link-Form **innerhalb** eines
Code-Blocks bzw. einer Code-Span und ist damit Zitat, nicht Zeiger — die Vorschau führt sie
folgerichtig nicht. **Keine Erwartungswerte.**

**4. Der gefürchtete Anker-Fall ist heute leer.** Ein eingefrorener Satz, der einen Abschnitt des
bewegten Slice nennt, zeigt nach der Archivierung auf einen Stub, der keine Abschnitte trägt. Die
**maschinell sichtbare** Hälfte davon — ein Link mit Anker-Fragment — kommt im ganzen
einfrierenden Bestand nicht vor:

```sh
export LC_ALL=C
git grep -ohE '\]\([^)]*slice-[0-9]+[^)]*\.md#[^)]*\)' \
  -- 'docs/plan/planning/done/*.md' 'docs/reviews/*.md' 'docs/plan/adr/*.md' \
     'docs/plan/carveouts/done/*.md' 'docs/plan/planning/observations/**' | wc -l   # 1
```

Der eine Treffer zeigt auf einen **Review-Report**, nicht auf eine Slice-Datei unter `done/`
(`docs/reviews/2026-07-26-…`-Klasse, Ziel ist eine andere Report-Datei); auf eine flach unter
`done/` liegende Slice- oder Welle-Datei zeigt **kein** Anker-Link. **Kein Erwartungswert** — die
Zahl wandert. Was bleibt, ist die Prosa-Hälfte (*„gemessen in `slice-183` §6"* neben einem
ankerlosen Link): kein Muster, ein Urteil, und darum unten in Festlegung 4 benannt statt beziffert.

**5. Die Fundstelle im Code-Block ist die einzige mechanisch trennbare Gegenform, und sie zählt
fünf.** Steht die Adresse als Operand eines Mess-Kommandos, beantwortet dasselbe Kommando nach der
Ersetzung eine andere Frage, ohne zu scheitern — die Nachbar-Beobachtung
[`BEO-ALL/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse`](../planning/observations/BEO-ALL/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse/observation.md)
führt genau das. Über allen einfrierenden Bäumen, Ziel eine flach in `done/` liegende Slice- oder
Welle-Datei:

```sh
export LC_ALL=C
git ls-files -- 'docs/plan/planning/done/*.md' 'docs/reviews/*.md' 'docs/plan/adr/*.md' \
    'docs/plan/carveouts/done/*.md' 'docs/plan/planning/observations/**' |
while IFS= read -r f; do
  awk -v D="$(dirname "$f")" '
    /^[[:space:]]*```/ { z = !z; next }
    { r = $0
      while (match(r, /\]\([^)]*\)/)) {
        t = substr(r, RSTART+2, RLENGTH-3); r = substr(r, RSTART+RLENGTH)
        sub(/#.*$/, "", t); if (t == "" || t ~ /^[a-zA-Z]+:/) continue
        print (z ? "code" : "prosa") "\t" D "/" t } }' "$f"
done | while IFS="$(printf '\t')" read -r k p; do
  q="$(realpath -m --relative-to=. "$p")"
  case "$q" in docs/plan/planning/done/slice-*.md|docs/plan/planning/done/welle-*.md) echo "$k";; esac
done | sort | uniq -c        # 5 code · 1635 prosa
```

**Keine Erwartungswerte.** Fünf von 1640 — die Klasse ist real und klein, und sie hat ihren
eigenen Registereintrag mit eigenem Träger; diese Entscheidung nimmt ihn ihr nicht ab.

**6. Der Nachbar hat dieselbe Frage beantwortet, mit demselben Kriterium und ohne unsere
Gegenfälle.** Das Nachbar-Repo `d-check` desselben Nutzers fährt denselben Kurs — dort am Tag
`v6.6.0`, hier `v6.5.0` — und hat seinen Altbestand archiviert; sein Verweis-Nachzug läuft repo-weit
und nimmt die einfrierenden Bäume **nicht** aus. Sein Adaptions-Eintrag *„Wer mechanisch über den
Baum ersetzt, listet die Frozen-Klassen vorher auf"* (`Accepted`, 2026-09-07) formuliert das Kriterium
ausdrücklich — *„Die Unterscheidung ist nicht **ob** geschrieben wird, sondern **ob die Aussage
danach noch dieselbe ist**"* — und nimmt den Pfad-Nachzug eines Lifecycle-Moves aus seiner
Ausschluss-Menge heraus, weil *„es nannte einen Slice, und es nennt ihn weiter — nur an seinem
neuen Ort"*. Das ist **Praxis eines anderen Repos und keine Norm dieses** (die Aussage steht in
keinem Rang der Source Precedence dieses Repos); übernommen wird hier die **Form der
Unterscheidung**, nicht ihr Ergebnis — die Gegenfälle aus Punkt 4 und 5 sind dort nicht gemessen
und werden unten einzeln beantwortet.

### Annahmen, auf denen diese Entscheidung steht

- **`AGENTS.md` §3.4 spricht über ADRs, nicht über Zeitdokumente.** Wortlaut:
  *„ADRs sind nach Accepted immutable — Korrekturen entstehen als neue ADR mit Supersedes, nicht
  durch Überschreiben."* Die Ausdehnung auf *„jedes Artefakt, das nach Abschluss nicht mehr
  angefasst wird"* steht in [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) Festlegung 3 und
  §3.11 — und beide binden dort die **Form des geschriebenen Zeigers**, nicht den späteren
  Beweger. Kippt diese Lesart, kippt Festlegung 1.
- **Das Zeitdokument schützt seinen datierten Inhalt.** [ADR-0016](0016-verweis-traegt-tag-und-zitat.md)
  §Kontext hat diese Unterscheidung bereits gemessen und in ihrer Tabelle festgehalten: die ADR ist
  *„nein — §3.4"*, die Datei unter `done/` und der Review-Report sind *„Zeitdokument: von §3.4
  **nicht** geschützt, inhaltlich aber datiert"*. Das ist eine Kontext-Feststellung jener Datei und
  keine ihrer Festlegungen — sie belegt, dass diese Linie im Rang-4-Stratum dieses Repos schon
  einmal gezogen wurde, und trägt hier als Beleg, nicht als Norm.
- **Der Nachzug ersetzt Pfade, keine Zustandssätze.** Das ist die selbstdeklarierte Grenze 1 von
  `make slice-mv` und gilt für den Archiv-Nachzug gleichermaßen. Bekäme ein Träger diese zweite
  Fähigkeit, wäre Festlegung 4 neu zu bewerten.

## Entscheidung

**Wir wählen Alternative D: der Nachzug ersetzt eine Adresse und ändert keine Aussage — im
Zeitdokument darf er das, in einer `Accepted`-ADR nichts. Fünf Festlegungen.**

**1. Der Verweis-Nachzug eines vom Prozess vorgeschriebenen Ortswechsels ersetzt die Pfad-Adresse
in einem Zeitdokument. Das ist entschieden, nicht geduldet.** Gebunden sind die vier Bäume, die
Messung 2 neben `docs/plan/adr/` als eingefroren ausweist:
[`docs/plan/planning/done/`](../planning/done), [`docs/reviews/`](../../reviews),
[`docs/plan/carveouts/done/`](../carveouts/done) und, vom Beobachtungs-Register
[`docs/plan/planning/observations/`](../planning/observations), dessen eingefrorenes Glied
`evidence/<vorgangs-id>.md` — die `state.md` daneben nennt die adoptierte Baseline `v6.5.0`
(`modul-06-roadmap.md` §Das Beobachtungs-Register) *„der veränderliche Stand"*, und in einem
lebenden Artefakt bleibt der Pfad der richtige Zeiger. Beide Träger behalten ihre heutige
Ausnahmeliste; **keiner bekommt einen weiteren ausgenommenen Baum.**

Der Grund ist das Kriterium und nicht die Bequemlichkeit: Ein Zeitdokument hält eine **Messung
oder Entscheidung zu seinem Datum** fest, und das ist sein datierter **Inhalt**. Der Nachzug nennt
denselben Vorgang an seinem neuen Ort — *„Report X prüfte `slice-N`"* gilt vor und nach der
Ersetzung, Wort für Wort. Was §3.4 mit *immutable* meint, ist an dieser Stelle die Aussage und
nicht das Byte; für ADRs fällt beides zusammen (Festlegung 2), für Zeitdokumente nicht.

**Die Alternative wäre nicht „weniger schreiben", sondern „weniger prüfen".** Unterbliebe der
Nachzug, stünden nach der ersten Archivierung 402 tote Adressen in 146 Artefakten, die niemand
reparieren darf; stumm zu schalten wären sie nur baum-weit — `in: docs/reviews/**` gegen
`refs: docs/plan/planning/done/**` und drei Geschwister —, und das nähme die gesamte
Lifecycle-Achse dieser vier Bäume dauerhaft aus der Prüfung. Das ist um Größenordnungen mehr
Blindheit als die vier namentlich geschnittenen Ventile, die dieses Repo heute führt
([ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)) plus der
drei Glob-Einträge aus [ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md).

**2. Eine `Accepted`-ADR ist ausgenommen — kein Byte, auch nicht an der Adresse.** Beide Träger
nehmen `docs/plan/adr/` zusätzlich zum vendored Baum aus ihrer Ersetzung aus.

Das ist [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 1, von
**einer** Datei auf ihre **Klasse** geweitet: Dort steht *„§3.4 bindet das Artefakt, nicht nur
seine Aussage"*, und §3.4 ist eine Hard Rule, die ADRs beim Namen nennt. Kein `Supersedes` — jene
Festlegung gilt unverändert weiter und ist im Umfang dieser hier enthalten.

**Der Schnitt läuft über den Pfad, der Norm-Gegenstand über den Status, und die Differenz ist
benannt.** Ein Träger, der `docs/plan/adr/` als Pfad ausschneidet, überspringt auch die
`Proposed`-ADRs, die **lebend** sind und nachgezogen gehörten. Heute ist diese Differenz leer:

```sh
grep -l '^\*\*Status:\*\* Proposed' docs/plan/adr/0*.md | wc -l   # 5 Proposed-Dateien (diese hier eingeschlossen),
# davon in der Vorschau des Sammel-Archivs als betroffen genannt: keine
```

**Kein Erwartungswert.** Entsteht sie, zieht der bewegende Lauf die betroffene `Proposed`-ADR **von
Hand** nach und hält das in seinem Beleg fest; ein status-lesender Schnitt im Träger ist eine
Fähigkeit, die diese Entscheidung nicht verlangt und nicht verbietet (Re-Evaluierungs-Trigger 3).

**3. Die zwei Adressen, die dadurch sterben, bekommen zwei namentlich geschnittene
`ignore-refs`-Paare — eingetragen von dem Lauf, der den Move vollzieht, nicht vorher.**
Quelle beider Paare ist [ADR-0016](0016-verweis-traegt-tag-und-zitat.md); Ziel je einer der beiden
Pfade, die sie heute als Inline-Code trägt — der Plan von `slice-076` und der von `slice-015`, je
in der Form `refs: ["<ihr flacher done/-Pfad vor dem Move>"]`. **Und keinen weiteren.**

Das ist eine Aufnahme-**Grenze**, keine Aufnahme-**Regel**: Die Grenzen aus
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) und
[ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 3 gelten unverändert
weiter; diese Entscheidung erhöht die Zahl der Paare um zwei und **nicht** die Zahl der
Entscheidungen, die ein weiteres braucht. Jeder zusätzliche Eintrag, jedes Glob in `in` oder `refs`
und jede Verbreiterung auf ein Verzeichnis bleibt eine neue Senkung nach
[`AGENTS.md`](../../../AGENTS.md) §3.5 mit eigener ADR.

**Nicht vorher**, und der Grund steht schon in
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 2: Beide Adressen
lösen heute auf. Sie jetzt stumm zu schalten hieße, eine **lebende, richtige** Referenz aus der
Prüfung zu nehmen, und zwar für die unbestimmte Zeit bis zum Move. Der eintragende Lauf misst die
Deckung neu und deklariert sie je Eintrag, wie
[ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 2 es verlangt — auf der
Markdown-Link-Achse, die deren Breiten-Wächter liest, ist sie für beide `0`, denn beide Adressen
sind Code-Spans (Messung 3 oben). Findet er mehr als diese zwei, ist das eine neue Senkung und
nicht die Ausführung dieser hier.

**4. Der Nachzug bleibt eine reine Pfad-Ersetzung und bekommt keine zweite Fähigkeit. Wo die
Adresse die Aussage trägt, bleibt der Widerspruch stehen und wird nicht repariert.** Drei Formen
sind gemessen, alle drei bleiben:

- **Der Zustandssatz neben der Adresse.** Ein Report, dessen Prosa den Plan *„in `open/`"* verortet,
  trägt nach dem Nachzug daneben einen Link nach `next/`. Der Träger deklariert diese Grenze selbst
  (*„zieht Pfade nach, keine Zustandssätze"*), und welcher Satz einen Zustand behauptet, ist ein
  Urteil und kein Match.
- **Der Operand im Mess-Kommando.** Fünf Fundstellen (Messung 5); eigener Registereintrag, eigener
  Träger — der Lauf, der die Mess-Aussage **schreibt**, wählt eine Form ohne Pfad-Literal.
- **Der Abschnitts-Verweis auf einen künftigen Stub.** Nach der Archivierung zeigt *„gemessen in
  `slice-183` §6"* auf einen Stub ohne §6: der Link grün, die Aussage falsch. Die maschinell
  sichtbare Hälfte — der Anker-Link — ist heute leer (Messung 4); die Prosa-Hälfte ist ein Urteil.

**Warum nicht repariert wird — und warum der Preis-Satz der Quelle das nicht entscheidet:** Er steht
unter *„die Reparatur ist teurer als die Vermeidung"* und stellt **beide** Wege nebeneinander; auch
der hier gewählte geht Weg 1. Getrennt werden sie vom Kriterium dieser Entscheidung: Der Nachzug
lässt die Aussage stehen, die Reparatur schreibt sie um — aus einem Zeiger wird Text — und setzt
dafür ein **Urteil je Fundstelle** über 402 Stellen in 146 Artefakten, das kein Match liefert.

**Träger der Vermeidung ist der Schreiber vor dem Einfrieren, nicht der Beweger danach.** Das ist
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md)/[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
Festlegung 3 und [`AGENTS.md`](../../../AGENTS.md) §3.11, und Messung 1 zeigt, dass diese Linie
trägt: 1227 Kennungen gegen 220 Adressen. Der Rest ist Bestand vor dem Cutoff und nach §3.11
ausdrücklich kein Arbeitsauftrag.

**5. Die Vorab-Messung aus [`AGENTS.md`](../../../AGENTS.md) §3.11 behält ihren Zweck, und der ist
nicht mehr die Erlaubnis.** Sie hält den Move **nicht** an, wo sie ein Zeitdokument findet — dort
ist der Nachzug ab hier beschlossen, und der bewegende Lauf nennt in seinem Beleg, was er anfasst.
Sie hält ihn an, wo sie eine `Accepted`-ADR findet, und dort an **zwei** Bedingungen: Der Move läuft
erst, wenn **beide Träger** die Ausnahme aus Festlegung 2 führen (Folgepflicht 1) **und** jede
gefundene Adresse ihr Ventil hat. Die zweite ist mit Festlegung 3 erfüllt, die erste **nicht** — bis
dahin ist der erste Archiv-Move gesperrt, gleich was die Vorschau sonst meldet. Ohne sie erlaubte
diese Entscheidung ihren eigenen Bruch: Beide Träger nehmen heute allein den vendored Baum aus, und
die Vorschau führt [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) mit zwei Fundstellen als zu
schreibende Datei. Eine dritte Adresse wäre eine neue Senkung nach §3.5 mit eigener Entscheidung.

Damit bekommt der Absatz, an dem dreizehn Läufe gemessen und dann doch entschieden haben, eine
Antwort statt einer Warteschlange — und behält seine Sperrwirkung genau dort, wo sie
unauflösbar ist.

**Was diese Entscheidung nicht tut.**

- **Sie entscheidet nicht, was mit einem eingehenden Verweis auf einen Review-Report geschieht.**
  Das ist die `[haenger]`-Sperre und der Gegenstand von
  `slice-216`,
  der sie in seinem §1 ausdrücklich von dieser Frage trennt: Dort **bricht** ein Verweis, weil sein
  Ziel ersatzlos verschwindet; hier wird ein Artefakt **geschrieben**, weil sein Ziel umzieht. Was
  jene Entscheidung wählt, ändert an dieser nichts — fällt sie auf einen Report-Stub, gilt für den
  Nachzug in dessen Quellen Festlegung 1 und 2 unverändert.
- **Sie superseded nichts.** Weder [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
  (Festlegung 1 ist in Festlegung 2 enthalten, Festlegung 3 und 4 bleiben in Kraft, Festlegung 4
  bekommt in Festlegung 5 ihre Anwendung) noch
  [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (deren §Kontext hier als **Beleg** zitiert wird,
  nicht als Festlegung) noch [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) (keine ihrer
  fünf Festlegungen wird berührt, keiner ihrer Re-Evaluierungs-Trigger ist gefeuert).
- **Sie sagt nichts über [`harness/conventions/`](../../../harness/conventions).** Der
  Adaptions-Block ist ein **lebendes** Register — [`harness/README.md`](../../../harness/README.md)
  führt ihn als lebendes Artefakt —, und in lebenden Artefakten bleibt der Pfad der richtige Zeiger
  ([ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 3, Absatz *„Was
  Festlegung 3 nicht verlangt"*). Eine eigene Aussage bräuchte einen Fall, und der erste
  Archivierungs-Lauf hat keinen: `git grep -lE '\]\([^)]*(open|next|in-progress|done)/slice-[0-9]'
  -- 'harness/conventions/**' | wc -l` → **2** Dateien, beide zeigen auf Slices, die dieser Lauf
  nicht bewegt (**kein Erwartungswert**).
- **Sie sagt nichts über ein emittiertes Repo.** Der Geltungsbereich ist dieses Repo; was ein
  Zielrepo an Nachzugs-Regeln bekommt, entscheidet der Vorgang, der die Tool-Ebene entscheidet.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
[ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md),
[ADR-0041](0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) und die zitierten Stellen der
adoptierten Baseline `v6.5.0` auf Konsistenz geprüft hat und ihr Report gegen den Gegenstand
dieser Entscheidung selbst keinen blockierenden Befund führt.** Die Accept-Zeile der §Geschichte
nennt den Beleg als Kennung
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1).

**Was diese Bedingung nicht verlangt — und der Verzicht ist entschieden, nicht übersehen.** Sie
verlangt keine Runde ohne blockierendes Verdikt und damit auch nicht die **erneute** Runde
derselben prüfenden Rolle, die
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 nach einem
blockierenden Befund zum Beleg macht. Der Anlass ist die dritte Reviewer-Runde vom 2026-09-12 zu
dieser Entscheidung: Sie prüft die fünf Festlegungen, die Nicht-Regression und die Gate-Wirkung je
ohne Befund und verdiktiert dennoch blockierend, weil ihr einziger Befund **außerhalb** dieser
Datei liegt — in [`harness/sensors/archive-welle.md`](../../../harness/sensors/archive-welle.md),
einem lebenden Artefakt, das die Sperre des ersten Archiv-Moves allein an die Norm-Frage hängte.
Er ist in `5a3cdc05` behoben; **die behobene Fassung hat keine Runde bestätigt.** Die Bedingung
bindet den Trigger darum an den Gegenstand der Entscheidung und überlässt die Wirkung auf fremde
Artefakte deren eigenen Trägern.

**Der Weg dahin ist [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 3, und er ist der einzige.** Soll ein anderer Beleg genügen als der, den der Trigger
nennt, wird der Trigger geändert — **solange die Datei `Proposed` ist**; danach frieren
Statuszeile und Trigger-Abschnitt gemeinsam ein. Die Setzung ist die des Auftraggebers vom
2026-09-12. **Was offen bleibt, bleibt benannt:** Jene Festlegung 2 spricht über jede prüfende
Runde, die blockierend gemeldet hat, nicht allein über den Wortlaut des Triggers; ob die engere
Fassung sie erfüllt oder verdrängt, entscheidet diese Datei nicht. Sie sagt, was zählt, und sagt
daneben, was fehlt.

## Verglichene Alternativen

Regeln dieser Sektion: **mindestens drei Optionen mit Pro/Contra** — „nichts tun" ist eine davon.
Eine ADR ohne Alternativen ist ein Postulat, kein Entscheidungsprotokoll, und im Review nicht
verteidigbar (Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR)).

| Option | Pro | Contra |
|---|---|---|
| A — Nichts tun: der Nachzug läuft weiter wie heute, unentschieden | Kostet keine Zeile. Der Bestand bleibt, wie er ist, und die Träger bleiben unverändert | **Entscheidet nichts und blockiert zwei Vorgänge.** [ADR-0041](0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Festlegung 4 wartet ausdrücklich auf diesen Ausgang, und der Registereintrag steht bei 13 Belegen ohne Träger. Jeder weitere Lauf misst erneut, schreibt dieselbe Notiz und fährt trotzdem — der Zähler wüchse ohne Erkenntnisgewinn. Und die Ungleichbehandlung bliebe: Was ein Nachzug anfasst, entschiede weiter die **Sichtbarkeit für das Gate** statt die Eigenschaft des Artefakts |
| B — Die einfrierenden Bäume aus dem Nachzug herausnehmen | Nimmt den Wortlaut der Quelle beim Wort (*„werden nicht nachgezogen"*). Kein Byte in einem Zeitdokument | **Tauscht Schreiben gegen Blindheit, und zwar baum-weit.** Nach der ersten Archivierung stünden **402** tote Adressen in **146** Artefakten, die niemand reparieren darf. Sie stumm zu schalten ginge nur über vier Glob-Paare der Form `in: <einfrierender Baum>/**` gegen `refs: docs/plan/planning/done/**` — das nähme die **gesamte** Lifecycle-Achse dieser Bäume dauerhaft aus der Prüfung und träfe damit auch jeden künftigen, richtigen Verweis. Der Breiten-Wächter aus [ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 2 müsste dafür eine Zahl deklarieren, die jeder Archiv-Lauf verschiebt. Und sie löste die Frage nicht, sondern verschöbe sie: Eine tote Adresse in einem Zeitdokument ist genau der Befund, den [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) und [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) je einmal mit einer eigenen Entscheidung auffangen mussten |
| C — Die Adresse im eingefrorenen Artefakt auf eine pfadlose Kennung ziehen | Erfüllt die Adress-Form-Regel der Quelle auch im Bestand, nicht nur vorwärts. Danach gibt es nichts mehr nachzuziehen | **Ändert nicht nur dieselben Bytes stärker als der Nachzug, sondern die Aussage** — aus einem Zeiger wird Text. Beide Optionen gehen Weg 1 der Quelle und zahlen denselben Preis; getrennt werden sie vom Kriterium, nicht vom Preis-Satz. Und es ist ein **Urteil je Fundstelle** über 402 Stellen in 146 Artefakten: Ob ein Link entbehrlich ist, sieht kein Match. §3.11 führt den Bestand ausdrücklich als *kein Arbeitsauftrag*; diese Option macht ihn zu einem |
| **D — Der Nachzug ersetzt die Adresse im Zeitdokument und nichts in der `Accepted`-ADR (gewählt)** | Zieht die Linie dort, wo die Quellen dieses Repos sie schon ziehen: §3.4 nennt ADRs beim Namen, [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 1 sagt für eine ADR *„kein Byte"*, [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) §Kontext hat das Zeitdokument als *„von §3.4 nicht geschützt"* gemessen. Das Kriterium ist die **Aussage**, nicht die Gate-Sichtbarkeit — genau der Punkt, an dem die bisherige Praxis auffiel. Der Preis ist beziffert und klein: **1** Datei, **2** Adressen, **2** namentlich geschnittene Ventile. Beide Träger bleiben unverändert bis auf **einen** zusätzlich ausgenommenen Pfad, und der erste Archivierungs-Lauf wird ausführbar | Schreibt weiterhin in **402** Fundstellen eingefrorener Artefakte, und drei gemessene Gegenformen bleiben ungelöst (Festlegung 4) — sie sind benannt, nicht geschlossen. Der Pfad-Schnitt in Festlegung 2 ist gröber als der Norm-Gegenstand: eine `Proposed`-ADR wird mit ausgenommen, obwohl sie lebt (heute leer, künftig Handarbeit). Und die zwei Ventile sind eine Senkung, die vorher keine war |
| E — Der Nachzug unterscheidet selbst: Adresse ja, aussagetragende Adresse nein | Träfe genau das Kriterium und löste alle drei Gegenformen aus Festlegung 4 an der Wurzel | **Verlangt ein Urteil vom Werkzeug, das ein Urteil ist.** Ein Zustandssatz neben einer Adresse ist kein Muster; die einzige mechanisch trennbare Form ist der Code-Block, und die zählt **5** von **1640** (Messung 5). Für diese fünf gibt es bereits einen Registereintrag mit eigenem Träger beim **Schreiber** der Mess-Aussage — dort ist sie billig und sicher, im Werkzeug teuer und unvollständig. Eine Fähigkeit, die 5 Fälle trifft und 402 unberührt lässt, beantwortet die Frage nicht, sondern verdeckt sie |

## Konsequenzen

- **Positiv:** Die Frage, die dreizehn Läufe gemessen und keiner entschieden hat, ist entschieden.
  Der bewegende Lauf misst weiterhin nach §3.11, aber er misst jetzt gegen ein Kriterium statt
  gegen eine offene Frage — und sein Beleg im Register wird zur Notiz statt zur Wiedervorlage.
- **Positiv:** [ADR-0041](0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Festlegung 4
  hat ihren Ausgang. Der Move bleibt danach gesperrt — normativ durch Festlegung 5, bis
  Folgepflicht 1 steht, und im Träger durch `[haenger]`, eine Frage mit eigenem Slice.
- **Positiv:** Das Kriterium ist übertragbar. Es hängt an *ändert sich die Aussage?* und nicht an
  einer Liste von Bäumen — ein fünfter einfrierender Baum kostet damit keine eigene Runde, solange
  er ein Zeitdokument ist.
- **Negativ:** Es wird weiter in eingefrorene Artefakte geschrieben, beim ersten Archivierungs-Lauf
  in **146** Dateien an **402** Stellen. Diese Entscheidung macht das nicht kleiner, sie macht es
  verantwortet.
- **Negativ:** Drei Gegenformen bleiben offen (Festlegung 4). Zwei davon sind Urteile ohne Sensor;
  die dritte hat einen eigenen Registereintrag, dessen Zähler weiterläuft.
- **Negativ:** Zwei neue `ignore-refs`-Paare sind zwei neue blinde Referenzen — namentlich
  geschnitten und trotzdem eine Senkung. Beide sind Code-Spans; ihre **Restbreite** misst kein
  Sensor (§Fitness Function).
- **Folgepflicht 1 — die zwei Träger bekommen ihren zusätzlich ausgenommenen Pfad.** `slice-mv`
  nimmt heute allein den vendored Baum aus, der Archiv-Nachzug ebenso; beide brauchen
  `docs/plan/adr/` daneben, samt Test. Das ist Implementer-Arbeit und ein eigener Slice; ohne sie
  ist Festlegung 2 eine Zusage ohne Träger und der erste Archiv-Move nach Festlegung 5 gesperrt.
- **Folgepflicht 2 — der Lauf, der den ersten Archiv-Move vollzieht, trägt die zwei
  `ignore-refs`-Paare ein**, im selben Commit wie den Move, mit je neu gemessener
  `# Deckung:`-Deklaration.
- **Folgepflicht 3 — der Registereintrag bekommt seinen Ausgang.**
  [`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../planning/observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
  steht bei 13 Belegen auf `offen`; mit der Annahme dieser Datei ist er *verkörpert*, Zielort diese
  ADR. Den Stand schreibt die Closure, die das Beleg-Register fortschreibt, nicht dieser Lauf.
- **Folgepflicht 4 — keine Hard Rule.** [`AGENTS.md`](../../../AGENTS.md) §3 bindet **jeden** Lauf;
  dies bindet den, der einen vorgeschriebenen Ortswechsel vollzieht, und der liest den
  Lifecycle-Abschnitt ohnehin. Eine zweite Fassung derselben Aussage in §3 driftete gegen diese
  hier — dieselbe Begründung, mit der
  [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) auf eine Hard Rule
  verzichtet.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| bats (`test/ignore-refs-restbreite.bats`) | Jedes `ignore-refs`-Paar wird in bekannter Form gelesen und deckt genau so viele **Markdown-Links**, wie es deklariert — die zwei Paare aus Festlegung 3 fallen vom ersten Lauf an unter beide Prüfungen | `make test` |
| d-check (`links`, `codepaths`) | Nach dem Move löst jede nachgezogene Adresse auf; eine unterbliebene Ersetzung färbt rot | `make docs-check` |
| — | **Festlegung 1, 2, 4 und 5 haben keinen Sensor — und die *Restbreite* der zwei Paare aus Festlegung 3 ebenso wenig** | — |

**Die erste Zeile deckt weniger, als ihr Name nahelegt.** Beide Adressen aus Festlegung 3 stehen in
ihrer Quelldatei als **Code-Span** (Messung 3), und der Wächter liest die Inline-Markdown-Form
`](ziel)`: Er hält für diese zwei Paare **Form** und **Deklaration**, nicht die **Restbreite** — ein
zweiter Code-Span derselben Quelldatei ließe ihn grün. Das ist wörtlich die Lage des dritten Paares,
die [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Folgepflicht 2 und
[ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md) §Fitness Function als **benannte
Lücke** führen; diese Entscheidung behauptet den Wächter dafür **nicht**
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Sie hebt
die Zahl der Paare, deren Deklaration `0` lautet, weil ihre reale Referenz ein Code-Span ist, von
**1** auf **3**:

```sh
grep -c '^  # Deckung: 0$' .d-check.yml   # 1 — kein Erwartungswert; die zwei Paare aus Festlegung 3 treten hinzu
```

**Die dritte Zeile trägt den Rest.** Kein Modul der [`.d-check.yml`](../../../.d-check.yml) hält
den Status eines Artefakts gegen die Form seiner Adressen, und keines liest Commits — dieselbe
Lücke, die [`AGENTS.md`](../../../AGENTS.md) §3.11 und
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) §Fitness Function für sich
selbst feststellen. Dass der Nachzug `docs/plan/adr/` ausnimmt, wird nach Folgepflicht 1 von einem
Test am Träger gehalten; dass er ein Zeitdokument schreiben **darf**, ist eine Erlaubnis und kein
prüfbarer Zustand. Träger bleiben der Accept-Übergang und der Lauf, der den Move plant.

## Re-Evaluierungs-Trigger

1. **Wenn die adoptierte Baseline den *Vorgang* regelt statt nur die Verweis-Form** — also den
   Nachzug einer Move- oder Massen-Operation in ein Zeitdokument —, gilt ihre Fassung, und diese
   Entscheidung wird gegen sie gehalten. Heute regelt `v6.5.0` allein die Form des geschriebenen
   Zeigers und beziffert den Reparatur-Fall, ohne ihn zu entscheiden (§Kontext).
2. **Wenn ein Modul des Doku-Gates Status und Adress-Form zusammenhält.** Dann ist die
   Nicht-Reparatur aus Festlegung 4 erstmals messbar, und die drei Gegenformen bekommen eine Zahl
   statt eines Urteils.
3. **Wenn ein Träger den Nachzug status-abhängig schneiden kann** (`Accepted` gegen `Proposed`).
   Dann entfällt der Preis aus Festlegung 2, und der Pfad-Schnitt gehört durch den Status-Schnitt
   ersetzt.
4. **Wenn eine vierte Gegenform auftritt** — eine Aussage, die der Nachzug nachweislich falsch
   macht und die keine der drei in Festlegung 4 benannten ist. Dann ist die Klasse größer als
   gemessen, und das Kriterium *„die Aussage bleibt dieselbe"* trägt nicht mehr allein.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-12 | **Proposed** | Architect-Lauf zur offenen Norm-Frage aus `BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt` (13 Belege, Stand `offen`). Fällig geworden mit [ADR-0041](0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Festlegung 4, die den Vollzug der ersten Archivierung an den Ausgang dieser Frage bindet; der Acceptance-Trigger steht in §Der Acceptance-Trigger |
| 2026-09-12 | **Accepted** | **Entscheidung des Auftraggebers vom 2026-09-12, vollzogen in der Architect-Rolle.** Beleg sind die drei Reviewer-Runden vom 2026-09-12 zu dieser Entscheidung; die dritte prüft die fünf Festlegungen, die Nicht-Regression und die Gate-Wirkung je ohne Befund. Sie verdiktiert dennoch **blockierend**, wegen eines Befundes **außerhalb** dieser Datei — in `harness/sensors/archive-welle.md`, behoben in `5a3cdc05`; **die behobene Fassung hat keine Runde bestätigt.** Der Acceptance-Trigger ist darum vor diesem Umschlag enger gefasst worden, solange die Datei `Proposed` war ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 3); die Bestätigungsrunde, die dessen Festlegung 2 nach einem blockierenden Befund verlangt, ist **nicht gefahren**. **Ab hier bindet [`AGENTS.md`](../../../AGENTS.md) §3.4:** Korrekturen entstehen als Folge-ADR mit `Supersedes`. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0042` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
