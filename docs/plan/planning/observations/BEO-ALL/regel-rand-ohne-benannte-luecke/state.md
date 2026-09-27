**Stand:** verkörpert

Zielort: [`.harness/skills/reviewer.md`](../../../../../../.harness/skills/reviewer.md) — die Zeile
*„Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe"*, mit dem Herkunfts-Anker
`seit slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt`
(`grep -c 'seit slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt' .harness/skills/reviewer.md`
→ 1, kein Erwartungswert). Der Anweisungssatz gehört der Rolle, die ihn ausführt: die Zeile schreibt der
Reviewer ([`ADR-0028`](../../../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)); den Ausgang
setzt der Planner. Der Anker nennt den Slice, in dessen Closure die Klasse ihren dritten Beleg trug; dessen
Kennung löst über `done/` auf.

**Grenze der Verkörperung, benannt.** Ein Wächter existiert nicht: kein Sensor hält die Aufzählung einer Regel
gegen die Formen der Sprache, über die sie spricht — die Menge der Formen ist offen —, und
`make comment-claims` prüft, ob ein genannter Sensor existiert, nicht, ob eine Aufzählung vollständig ist.
Träger ist der Review, der die Formen fährt; die Zeile deckt Aufzählungen, die ein Diff anlegt oder ändert,
nicht den Bestand. Die Autor-Seite bleibt offen: solange der Lauf, der die Aufzählung schreibt, keine
Formen-Probe fährt, findet erst der Review die Lücke. Das Vorkommen an `harness/sensors/commit-msg-check.md`
steht in `observation.md` unter *Benannt, nicht gezählt* und bewegt den Zähler nicht.

**Vierter Beleg, Eskalation fällig.** Ein abgeschlossener Vorgang nach der Zeile hat einen vierten Beleg angelegt
(`ls docs/plan/planning/observations/BEO-ALL/regel-rand-ohne-benannte-luecke/evidence/*.md | wc -l` → 4, gelesen 2026-09-27,
keine Erwartung): `slice-204-das-programm-feld-nennt-das-programm`. Die Zeile hat an diesem Diff gegriffen — der Review fand die
Lücken der Aufzählung —, und die Autor-Seite blieb offen: der Lauf, der die Aufzählung schrieb, fuhr die Formen nicht. Der
nächste Schritt ist eine Falsch/Richtig-Zeile in [`AGENTS.md`](../../../../../../AGENTS.md) §3.6 (Architect, §3.8); geschrieben
ist sie nicht.
