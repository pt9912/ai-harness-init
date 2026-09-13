# MR-056 — Die Auswahl im Auto-Kontext hängt an der Lauf-Berührung, nicht am Prozess-Modul-Begriff

- **Datum:** 2026-09-13
- **Wirksamkeits-Anlass:** kein Slice — eine Auftraggeber-Entscheidung, ausgeführt außerhalb des
  Slice-Betriebs, wie schon bei
  [`MR-035`](../conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
  selbst. Wirksam wird sie mit dem Commit, der die zwei Zeiger in den Index nimmt.
  [`MR-028`](../conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt)
  verlangt den Anlass als Arbeitseinheit; hier ist keine geschnitten, und eine zu nennen hieße,
  eine Adresse anzugeben, die nicht auflöst.
- **Geltungsbereich:** der **Auswahl-Maßstab** für `.claude/rules/` und die zwei Zahlen im
  Zugriffs-Absatz [`AGENTS.md`](../../AGENTS.md) §1. **Nicht** der Rumpf von
  [`MR-035`](../conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl):
  kein Wort daran wird geändert, und seine fünf Setzungen binden fort. **Dieses Repo, nicht das
  emittierte** — dort ist die Lage unverändert die, die jener Eintrag beschreibt.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  aus demselben Grund wie bei
  [`MR-035`](../conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl):
  Die Baseline kennt den Mechanismus nicht. Am heute adoptierten Stand nachgemessen
  (`grep -rl 'claude/rules' .harness/baseline/v6.7.2/ | wc -l` → **0**), weil
  [`MR-033`](../conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  zu einer Baseline-Aussage den Tag verlangt, gegen den sie gemessen ist.
- **Löst auf:** [`MR-035`](../conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
  — allein den Auswahl-Maßstab in seiner Begründung, keine seiner Setzungen. Das Feld
  `Ausgelöst durch Baseline-Stand` bleibt aus, weil die Ablösung repo-intern getrieben ist
  ([`MR-038`](../conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte):
  dann *„gäbe es nichts zu nennen"*).
- **Setzung 1 — der Maßstab ist die Lauf-Berührung, und er trägt über drei Achsen.** Aufgenommen
  wird ein Modul, dessen Gegenstand **jeder** Lauf berührt, nicht nur eine Einzelentscheidung. Das
  war schon der Maßstab von
  [`MR-035`](../conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl);
  benannt war dort aber die **Aufzählung** — *die vier Prozess-Module* — statt der **Eigenschaft**,
  und eine Aufzählung trägt kein fünftes Mitglied. Die drei Achsen, über die die Eigenschaft heute
  trägt:

  1. **Ablauf** — Entwicklungszyklus, Planning Harness, Roadmap Engineering, Agentenrollen: der
     Slice-Lifecycle, die Wellen-Prozedur und die Rollen-Übergaben.
  2. **Bindung** — `grundlagen-traceability`: der Traceability-Constraint bindet **jede** Änderung
     an eine Kennung ([`AGENTS.md`](../../AGENTS.md) §5), der Herkunfts-Anker jede verkörperte
     Regel.
  3. **Abnahme** — Verification und Quality Gates: §3.1 und §3.5 sind Gate-Regeln, §4 führt den
     Gate-Index, und §6 verlangt in Schritt 5 den engsten Sensor und in Schritt 6 den repo-weiten
     Gate-Lauf vor Handoff. §3.6 nennt die Pre-completion-Checkliste
     (`grep -c 'Pre-completion' AGENTS.md` → **1**); eine eigene Begriffs-Sektion dafür führt
     `modul-11`
     (`grep -c '^### Begriffe: Pre-completion Checklist Middleware und DoD-Verletzung$' .harness/baseline/v6.7.2/regelwerk/modul-11-verification.md`
     → **1**), genannt wird der Begriff im Regelwerk daneben in einem zweiten Modul
     (`grep -rl 'Pre-completion' .harness/baseline/v6.7.2/regelwerk/ | wc -l` → **2**).

  Dieselbe Bewegung — von der Aufzählung zur Eigenschaft — vollzieht
  [`AGENTS.md`](../../AGENTS.md) §3.11 für die eingefrorenen Adressen, und aus demselben Grund:
  Eine Aufzählung braucht für jedes weitere Mitglied eine eigene Runde.
- **Setzung 2 — die Grenze kommt aus Modul 8, und sie trennt Review von Verification.**
  [`MR-035`](../conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
  schließt das Review-Modul ausdrücklich aus, und der Grund trägt weiter: Das Urteil des Reviewers
  führt nach Modul 8 §Welche Rolle braucht welche Artefaktklasse eine **Skill-Datei**, und die
  liegt im Repo (`ls .harness/skills/*.md | wc -l` → **1**). Modul 10 bleibt damit draußen
  (`readlink .claude/rules/*.md | grep -c 'modul-10'` → **0**, Exit **1**).

  **Dieselbe Tabelle nimmt Modul 11 herein.** Der Verifier steht dort in der Klasse **keins**
  (`grep -c '| \*\*keins\*\* |.*Verifier · Validator |' .harness/baseline/v6.7.2/regelwerk/modul-08-agentenrollen.md`
  → **1**) — *„Die Prüfgrundlage steht bereits im Slice"*. Eine Skill-Datei wäre für ihn nach
  demselben Kriterium eine **Attrappe**; es gibt für sein Modul also keinen Träger außer dem
  On-demand-Lesevorgang. Ausschluss von Modul 10 und Aufnahme von Modul 11 folgen damit aus
  **einer** Regel, nicht aus zwei Vorlieben. Modul 13 hängt an keiner Rolle: Gates sind repo-weit,
  und ihre Disziplin steht als Hard Rule (§3.1, §3.5), nicht als Rollen-Urteil.
- **Setzung 3 — gebucht sind drei Zeiger, einer davon nachträglich.** Seit
  [`MR-035`](../conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
  ist die Menge um drei gewachsen: `grundlagen-traceability.md` sowie mit diesem Eintrag
  `modul-11-verification.md` und `modul-13-quality-gates.md`. Der erste kam durch einen Commit
  hinzu, der den Register-Nachzug ausdrücklich dieser Rolle überließ
  (`git log --diff-filter=A --format=%s -- .claude/rules/grundlagen-traceability.md`); dieser
  Eintrag ist der Nachzug. Setzung 2 jenes Eintrags verlangt für *einen Eintrag mehr oder weniger*
  einen neuen Eintrag dieses Blocks — für die drei zusammen ist dieser es. Stand:
  `readlink .claude/rules/*.md | grep -c '\.harness/baseline/'` → **7** von **26**
  (`ls .harness/baseline/v6.7.2/regelwerk/*.md | wc -l`). **Keine Erwartungswerte**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — beide wandern mit dem Verzeichnis und mit dem Tag.
- **Setzung 4 — der Preis ist beziffert und bezahlt.** Die sieben Baseline-Zeiger messen
  **110410** Zeichen
  (`(cd .claude/rules && cat $(readlink *.md | grep '\.harness/baseline/')) | wc -c`); davon
  entfallen **23331** auf die zwei neuen
  (`cat .harness/baseline/v6.7.2/regelwerk/modul-1[13]-*.md | wc -c`), also ein Aufschlag von
  **26,8 %** auf die vorige Modul-Menge:

  ```sh
  awk -v ganz="$( (cd .claude/rules && cat $(readlink *.md | grep '\.harness/baseline/')) | wc -c )" \
      -v neu="$(cat .harness/baseline/v6.7.2/regelwerk/modul-1[13]-*.md | wc -c)" \
      'BEGIN{printf "%.1f\n", neu/(ganz-neu)*100}'
  ```

  **Keine Erwartungswerte** — alle drei wandern mit dem Verzeichnis und mit dem Tag. Der
  Auftraggeber hat diesen Aufschlag genannt bekommen und angenommen; er fällt in **jedem**
  Claude-Lauf an, nicht nur in denen, die verifizieren oder ein Gate anfassen. Das ist der Preis
  des unbedingten Ladens, den
  [`MR-035`](../conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
  Setzung 5 für die Symlink-Form ausgeschrieben hat.
- **Setzung 5 — der Zweck ist Verfügbarkeit, nicht Wirkung.**
  [`MR-035`](../conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
  Setzung 3 — *Präsenz ist keine Durchsetzung* — bleibt unberührt und gilt für die zwei neuen
  genauso: Ein Modul im Auto-Kontext informiert, erzwingt nichts, färbt nichts rot und ersetzt
  keinen Sensor. Gewonnen ist allein, dass sein Text **ohne On-demand-Lesevorgang** dasteht — die
  Presence-Garantie aus
  [`MR-006`](../conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) §Tradeoff für
  zwei weitere Module. Was bindet, sind §3.1 und §3.5, weil sie Hard Rules sind; dass Modul 13
  daneben im Kontext steht, fügt dem nichts hinzu. Wer aus der Aufnahme eine Bindung liest, liest
  gegen den Wortlaut.
- **Begründung.** Der Lesepfad aus [`AGENTS.md`](../../AGENTS.md) §1 — Index plus relevantes Modul
  on-demand — setzt voraus, dass ein Lauf **weiß**, dass er nachschlagen muss. Auf der
  Abnahme-Achse stand bisher die Hard Rule im Auto-Kontext, ihr Baseline-Grund aber nicht:
  `AGENTS.md` ist selbst ein Zeiger unter `.claude/rules/`
  (`readlink .claude/rules/*.md | grep -c '^\.\./\.\./AGENTS\.md$'` → **1**), die zwei Module
  waren es bis zu diesem Eintrag nicht (Setzung 3). Diese Asymmetrie schließt die Aufnahme. **Ob
  sie ein Verhalten ändert, ist nicht gemessen und wird hier nicht behauptet** — Setzung 5 und
  [`AGENTS.md`](../../AGENTS.md) §3.6.
- **Grenze — der Gesamt-Zähler misst zwei Populationen.** `cat .claude/rules/*.md | wc -c` zählt
  beide Bestände des Verzeichnisses: die sieben Zeiger in den vendored Baum, die sich nur mit dem
  Tag bewegen, und drei Zeiger auf **lebende** repo-eigene Dateien — `AGENTS.md`,
  `harness/conventions.md` und [`harness/README.md`](../README.md), die jeder Lauf ändern darf
  (`readlink .claude/rules/*.md | grep -vc '\.harness/baseline/'` → **3**). Der Gesamt-Zähler
  wandert damit, **ohne** dass sich die Modul-Auswahl bewegt; eine Änderung an einer dieser drei
  genügt. Tragend für die Auswahl ist darum der Zähler über die Baseline-Zeiger allein
  (Setzung 4), und der Gesamt-Zähler ist eine Kosten-Aussage über den Lauf, keine über die Menge.
  Dasselbe erklärt, warum der Betrag in Setzung 1 von
  [`MR-035`](../conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
  veralten kann, ohne dass ein Tag-Bump oder ein Zeiger-Zuwachs stattgefunden hat.
- **Kein Wächter, und die Lage ist die von
  [`MR-035`](../conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl).**
  Kein Modul des Doku-Gates liest eine Ladeform, und `make comment-claims` hat keine
  Markdown-Datei in seinem Prüfbereich; beides steht dort ausgeschrieben und ist durch diesen
  Eintrag nicht bewegt. Neu ist allein die **Zahl der Zeiger**, die ein Tag-Bump nachziehen muss:
  sieben statt vier. `make baseline-verify` sieht sie nicht — es prüft den Baum, nicht wer auf ihn
  zeigt. Träger dieser Setzungen bleibt der Rollen-Wechsel vor der Änderung.
- **Auflösungs-Trigger:** permanent für den Maßstab (Setzung 1) und die Grenze (Setzung 2) — beide
  hängen an keinem Tag und an keinem Pin. Die **Beträge** in Setzung 4 wandern mit dem Verzeichnis
  und mit `BASELINE_TAG`: Die Symlink-Ziele tragen den Tag im Pfad, ein Re-Baseline bricht sie, und
  der Bump zieht die sieben Zeiger nach oder entfernt sie — welches von beidem, ist nach Setzung 2
  von [`MR-035`](../conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
  ein neuer Eintrag. **Neu fällig wird dieser Eintrag**, sobald ein Modul aufgenommen werden soll,
  das keine der drei Achsen trägt: Dann ist nicht die Menge zu erweitern, sondern der Maßstab zu
  prüfen.
