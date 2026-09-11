# Gepinnter Werkzeug-Weg umgangen, ohne dass der Guard trifft

**Sub-Area:** `*` (gesamtes Repo)

Ein Lauf fährt eine Toolchain an den `make`-Zielen vorbei, indem er sie in einem selbst gewählten
Container startet. Der PreToolUse-Guard greift dabei nicht, und zwar nach Bauart: Er prüft die
**Befehlsposition** jedes Kommando-Segments, und dort steht ein erlaubtes `docker` — die verbotene
Toolchain steht als Argument dahinter. Der Zweck von
[`AGENTS.md`](../../../../../../AGENTS.md) §3.9 ist damit unterlaufen, ohne dass eine Sperre
anschlägt: Das Bild ist per Tag statt per Digest bezogen, die Stufen des `Dockerfile` laufen nicht
mit, und das Ergebnis ist keines, das CI wiederholt
([`LH-QA-02`](../../../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).

Der Guard benennt diese Grenze selbst — *„Bewusst NICHT geprueft: andere Interpreter … der Guard
ist ein Stolperdraht …, KEINE Sandbox"*. Gezählt wird hier nicht die Grenze, sondern wie oft sie
getroffen wird.
