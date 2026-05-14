# triptych

A Prolog (or read *pro-logos*) realisation of the system poem from [bergholt.net/sun](https://bergholt.net/sun).

The generator produces 72 variants of the poem:

> 3 nouns × 3 verbs × 4 adverbs × 2 syntactic orders = 72

One variant for each eclipse in Saros 126 (1179–2459).

## About

*Sun: A Triptych for the Solar Eclipse* treats language as a combinatory machine in the Hjelmslevian sense of glossematics: meaning emerges from finite elements permuted through fixed constraints. A ten-word grid of nouns, verbs, adverbs, and the deictic *now* generates seventy-two variants, structurally mapped onto the seventy-two eclipses of Saros 126.

## Why Prolog

Prolog was chosen because its architecture mirrors the structuralist logic of the combinatory machine. Unlike procedural languages, Prolog is declarative: it defines the linguistic system's constraints rather than the steps to execute them. This serves Hjelmslev's glossematics directly, where meaning emerges from the formal relations between elements.

The project requires 72 permutations mapped onto the Saros 126 cycle. Prolog's built-in backtracking engine handles this natively, exhaustively exploring the ten-word grid to realize every variant. Its roots in computational linguistics allow for precise control over syntactic order and deictic anchoring.

## Usage

Requires [SWI-Prolog](https://www.swi-prolog.org/).

```bash
swipl sun.pl
```

Output:

```
1. apertures align rhythmically
2. apertures align vertically
3. apertures align recursively
4. apertures align now
...
72. now, apparitions emerge
```

## Why 72

- 72 eclipses in Saros 126 (1179–2459)
- 72 variants of the poem
- 72 lines of code
- 72 outputs when run

The number is not chosen. It is the cycle.

## Further reading

For the full essay on heteroglossia, chronotopes, and glossematics, see [bergholt.net/glossary](https://bergholt.net/glossary).

## License

MIT License. Feel free to use for your own projects.

---

Copenhagen, 2026
