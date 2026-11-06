# Triptych

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21908151.svg)](https://doi.org/10.5281/zenodo.21908151)

<img width="4570" height="6898" alt="sun-triptychs-for-solar-eclipses-kasper-bergholt" src="https://github.com/user-attachments/assets/d5f51300-d8fd-4a69-b945-eee171bda986" />

A Prolog (or *pro-logos*) realisation of a system poem. The generator produces 72 variants of the poem: 3 nouns × 3 verbs × 4 adverbs × 2 syntactic orders = 72. One variant for each solar eclipse in Saros 126 (1179–2459).

* **`saros.pl`** is a minimal version of the work consisting of a 72-line Prolog program that generates all 72 variants of the poem-structure.
* **`sun.pl`** is the expanded, self-verifying glossematic and acoustic implementation. It encodes the four Hjelmslevian strata, derives all category strides and Saros year-displacements from the inventory, models the 110 Hz (A2) overtone field, and verifies its own structural invariants (`self_check/0`) before printing any of five editions.

## About

*Sun* is inspired by glossematics, the theory of language the Danish linguist Louis Hjelmslev worked out in the 1930s. For Hjelmslev a language is form first of all, a web of relations laid across unshaped substance, and it runs on two planes at once: expression on the side of the signifier, content on the side of the signified. Underneath the signs he places *figurae*, a small closed stock of sub-elements that recombine to make everything a language can say.

*Sun* consists of three nouns, three verbs, four adverbs, the last of which is the deictic *now*. The grid combines them and seventy-two variants fall out, one per eclipse of Saros 126.

## Why Prolog

Prolog suits this better than a procedural language would. You don't give it steps to run; you state the constraints and let it find whatever satisfies them. Its one building block is the relation, the predicate, which is also where Hjelmslev begins: his primitive unit is the function, the dependency between two terms, and the terms are only ever what the relation needs them to be. Relation first, contents second, in both systems. So the poems aren't composed one at a time. The program goes through the grid, turns up every combination the constraints permit, and the seventy-two that survive are the program's output.

Prolog has the right ancestry for it, too, as it came out of Alain Colmerauer's group in Marseille around 1972, from work on parsing natural language, which is why it handles word order exactly as it does.

## Architecture of `sun.pl`

Unlike a one-way string generator, `sun.pl` is bidirectional and relational. Everything numerical about the work—category strides, characteristic intervals across Saros 126, marked cell counts, and harmonic spectra—is derived from the inventory and verified at runtime by `self_check/0`:

1. **Glossematic Strata:** Formalises `expression/form` (the $3 \times 3 \times 4 \times 2$ grid), `expression/substance` (the overtone field above A2 = 110 Hz), `content/form` (the 72 ordinal positions of Saros 126), and `content/substance` (the solar eclipse ephemeris from 1179 J to 2459).
2. **Hjelmslevian Mutation (Commutation & Permutation):** Categories are distinguished not by part of speech, but by how far a mutation carries the reader through Saros 126:
   * `adverb` — stride **1** (18 years)
   * `verb` — stride **4** (72 years)
   * `noun` — stride **12** (216 years)
   * `order` (permutation) — stride **36** (649 years)
3. **Etymological & Acoustic Solidarity (`fundamental_free = germanic`):** Under the work's sounding rule (each letter selects a partial of the 110 Hz A2 drone by alphabet position modulo 12), `recursively` touches partial 1 once (its final *y*, $25 \bmod 12 = 1$), while `thicken` never touches partial 1 at all (`t h i c k e n` = `8 8 9 3 11 5 2`). Consequently, the words that leave the fundamental drone ungrounded are **exclusively the two Germanic cells of the body** (`thicken` and `now`). Meanwhile, the letter `l` ($12 \bmod 12 = 0$) introduces an acoustic aperture (`silence`) exclusively inside the Latinate lexicon (`align`, `rhythmically`, `vertically`).

## Usage

### Minimal version (`saros.pl`)

```bash
swipl saros.pl
```

Output:
```text
1. apertures align rhythmically
2. apertures align vertically
3. apertures align recursively
4. apertures align now
...
72. now, apparitions emerge
```

### Expanded version (`sun.pl`)

Run the default Saros edition (runs `self_check` automatically first):

```bash
swipl -q -s sun.pl -t halt
```

Or print any of the five editions directly:

```bash
swipl -q -f sun.pl -g "self_check, print_manifestations" -t halt
swipl -q -f sun.pl -g "self_check, print_saros_edition" -t halt
swipl -q -f sun.pl -g "self_check, print_glossematic_edition" -t halt
swipl -q -f sun.pl -g "self_check, print_mutation_edition" -t halt
swipl -q -f sun.pl -g "self_check, print_sounding_edition" -t halt
```

### Interactive Queries

Load `sun.pl` interactively (`swipl -f sun.pl`) or in [SWISH](https://swish.swi-prolog.org/) (removing the final `:- initialization(main).` line):

```prolog
?- poem(48, Text).
Text = 'now, apertures emerge'.

?- poem(N, 'now, apertures emerge').
N = 48.

?- commutation(noun, 48, N2, Old, New), saros_year(N2, Year).
N2 = 60, Old = apertures, New = auguries,    Year = 2242 ;
N2 = 72, Old = apertures, New = apparitions, Year = 2459.

?- characteristic_interval(Category, Stride, Years).
Category = noun,   Stride = 12, Years = 216 ;
Category = verb,   Stride = 4,  Years = 72 ;
Category = adverb, Stride = 1,  Years = 18 ;
Category = order,  Stride = 36, Years = 649.

?- fundamental_free(Word).
Word = thicken ;
Word = now.
```

## Why 72

* 72 eclipses in Saros 126 (1179–2459)
* 72 variants of the poem
* 72 lines of code in `saros.pl`
* 72 outputs when run
* '72, the year Prolog appeared
* The Danish original, *Omkring sprogteoriens grundlæggelse*, uses the word *sproget* 172 times

## Further reading

For the full essay on glossematics, heteroglossia, and the system poetry genealogy, see [bergholt.net/sun](https://bergholt.net/sun).
