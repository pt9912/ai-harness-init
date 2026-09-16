**Vorgang:** slice-commit-traeger-wird-skip-if-present
**Fund:** Die Commit-Message von `d7fd8227` sagt *„Dazu vier Stellen, die der Plan nicht nannte"*;
die Rückgabe desselben Laufs nennt **sieben**; am Diff gezählt sind es **fünf** Stellen mit einer
Klassen-Aussage, die der Plan an keiner Stelle nennt — `Enforce`-Doc, `writeFileMode`-Doc,
`captureFiles`-Doc, `EnforcePaths`-Doc, `hooksInstallMkFile`-Doc. Eine **sechste**
(`commitMsgHookFile`-Doc) ist nur in der Lesart *ohne* die §3-Tabelle unbenannt, eine **siebte**
(`fieldlist_test.go`, Namens-Verweis auf den umbenannten Test) trägt gar keine Klassen-Aussage.

```sh
git diff -U0 77b927c7 d7fd8227 | grep -E '^-[^-]' | grep -icE 'konvergent|kanonisch|unbedingt'   # 22 Fundorte
```

Die 22 Fundorte sind **Zeilen**, nicht Stellen — die fünf sind an ihnen gelesen, und keine der zwei
Zahlen steht neben diesem Kommando. Der Träger ist damit eingefroren, bevor die Zahl geprüft war: die
Message `d7fd8227` ist gepusht und unveränderlich, ein Gate liest keine Commit-Message, und die
Closure-Notiz ist die einzige Stelle, die den Beleg nach dem Push noch tragen kann
([`MR-051`](../../../../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 1). Sie trägt ihn: die „vier" bleibt stehen, die Fundmenge steht daneben benannt.
