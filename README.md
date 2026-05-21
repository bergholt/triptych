*apertures align recursively / now, apparitions emerge*

# Triptych

A Prolog — or *pro-logos* — realisation of a system poem.

The generator produces 72 variants of the poem:

> 3 nouns × 3 verbs × 4 adverbs × 2 syntactic orders = 72

One variant for each solar eclipse in Saros 126, from 1179 to 2459.

## About

*Sun* is built on glossematics, the theory of language Louis Hjelmslev worked out in the 1940s. For Hjelmslev, a language is *form* first of all: a web of relations laid across unshaped *substance*. It runs on two planes at once: *expression*, on the side of the signifier, and *content*, on the side of the signified.

Underneath the signs he places *figurae*: a small closed stock of sub-elements that recombine to make everything a language can say.

In *Sun*, the figurae are ten words: three nouns, three verbs, and four adverbs, the last of them the deictic *now*. The grid combines them, and seventy-two variants fall out, one per eclipse of Saros 126.

Seventy-two is the entire vocabulary of the thing. There is no seventy-third.

## Why Prolog

Prolog suits this better than a procedural language would. You do not give it steps to run; you state the constraints and let it find whatever satisfies them.

Its basic building block is the relation, the *predicate*, which is also where Hjelmslev begins. His primitive unit is the *function*: the dependency between two terms. The terms are only ever what the relation needs them to be.

Relation first, contents second, in both systems.

So the poems are not composed one at a time. The program goes through the grid, turns up every combination the constraints permit, and the seventy-two that survive are what the system proves.

They are closer to theorems than to anything a person sat down and wrote.

Prolog has the right ancestry for it, too. It came out of Alain Colmerauer’s group in Marseille around 1972, from work on parsing natural language, which is why it handles word order and the placing of *now* as exactly as it does.

## Usage

Requires SWI-Prolog.

```bash
swipl saros.pl
