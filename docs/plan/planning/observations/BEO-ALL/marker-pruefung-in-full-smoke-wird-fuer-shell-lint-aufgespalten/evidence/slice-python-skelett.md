**Vorgang:** slice-python-skelett
**Fund:** Die F401-Prüfung der Python-Stufe besteht nach der SC2016-Behebung aus drei unabhängigen `grep -qF` (`F401 [*]`, `imported but unused`, `src/app/main.py:3:8`); Review INFO-2 und Verifier V-4 nennen die gelockerte Ko-Okkurrenz, Fall 695 färbt rot, die Probe (ein Import) ist eindeutig.
