# language-detect

This repository defines a set of rules and statistics to identify written variants of the [Norwegian language](https://en.wikipedia.org/wiki/Norwegian_language). Some of these language variants are very similar to the base variant, so special measures must be taken to identify the correct variant. A plain [naïve Bayes classifier](https://en.wikipedia.org/wiki/Naive_Bayes_classifier) with N-grams is not enough to get a high quality detection on short text fragments.

## Norwegian written forms

The core purpose of this exercise is to create statistics for detection of Norwegian language variants. There are several quite unique problems with detection of the correct variant. In particular; [Høgnorsk](https://en.wikipedia.org/wiki/Høgnorsk) is very similar to [Nynorsk](https://en.wikipedia.org/wiki/Nynorsk), and [Riksmål](https://en.wikipedia.org/wiki/Riksmål) is very similar to [Bokmål](https://en.wikipedia.org/wiki/Bokmål). The variant [Moderat Bokmål](https://no.wikipedia.org/wiki/Moderat_bokmål) is in between Bokmål and Riksmål, and is even harder to identify correctly.

By creating a first approximation to the language variants by using coarse classification, and then creating a refined set with only the acceptable documents, sources using alternate variants can be used for training the classifier.

As a very short list of Norwegian newspapers and their use of language variants

- [Aftenposten](https://en.wikipedia.org/wiki/Aftenposten) used *Riksmål* according to *Riksmålsordlisten* from 1952 up to 1989, from 1990 *Riksmål* according to definitions by [Det norske akademi](https://en.wikipedia.org/wiki/Det_norske_akademi) as of 1986, and late 90s it started moving towards *Moderat Bokmål* which became official in 2006
- [Dagbladet](https://en.wikipedia.org/wiki/Dagbladet) uses *Radikalt Bokmål*
- [VG](https://en.wikipedia.org/wiki/Verdens_Gang) uses *Moderat Bokmål*

For an alternate list, see [Wikipedia: Liste over norske aviser etter målform](https://no.wikipedia.org/wiki/Liste_over_norske_aviser_etter_m%C3%A5lform)

## Overview

The language files are split into three sets for each language variant; one N-gram set, one affix set, and one term set.

The N-gram statistics is a bit unusual by using a space replacement character. This set will catch some of the affixes, but not the long ones, and the statistics will be somewhat diffuse compared with the affix rules and the keywords. The N-grams might catch infix rules that are otherwise lost.

As some affixes can be quite long in Norwegian, and also stacked, like "bilistene" (the motorists, definite plural), separate statistics is built for the affix rules to avoid very long N-grams.

The keywords are a list of known words where the written language forms diverge. This is quite interesting as some of the words are quite good markers, especially for older texts. The keywords have rules to control inflection

## Usage

Each statistics gives a count of the number of occurrences after cleanup in the export script. The capitalized words are removed from the text, literal quotes are removed, and the terms that don't pass spellchecking are removed. Spellcheckers for Bokmål and Nynorsk are pretty forgiving, so most of the language variants should pass as acceptable.

Capitalized words are removed on an assumption that it is highly likely that such words are names, and thus are very noisy as they often comes from other cultural areas.

Literal quotes are removed on an assumption that it is highly likely they contain snippets of text in other languages, or spoken text which might have other properties than written text.

Whatever don't pass the spellchecker is removed too, on the assumption that the term seems so strange that it is unlikely they are a good source for language detection. This step is rather dangerous, as it can easily remove what is indicative for a specific language variant.

The *prior probability of the language variant* is given in the marginals section of the statistics, while the prior probability of the predictor must be calculated over all actual variants. If the purpose is only to compare the posterior probability, ie. identification of the language variant, then the prior probability of the predictor can be dropped.

### N-gram statistics

These statistics describe the differences in use of N-grams, that is the *conditional probability for observing the N-gram given the language specific form*.

These statistics are completely built by the script, with N-grams extracted from the text sources.

### Affix statistics

These statistics describe the differences in use of affixes, that is the *conditional probability for observing the affix given the language specific form*.

These statistics are built with the affix files as patterns, with terms extracted from the text sources.

### Keyword statistics

These statistics describe the differences in use of keywords, that is the *conditional probability for observing the keywords given the language specific form*.

These statistics are built with the affix files and keywords as patterns, with terms extracted from the text sources.

## Sources

- Gundersen, Dag; Engh, Jan; Fjeld, Ruth Vatvedt; [Håndbok i norsk – Skriveregler, grammatikk og språklige råd fra a til å](https://bibsys-almaprimo.hosted.exlibrisgroup.com/primo-explore/fulldisplay?docid=BIBSYS_ILS71482075340002201&context=L&vid=BIBSYS&search_scope=default_scope&tab=default_tab&lang=no_NO) Kunnskapsforlaget (1995) ISBN 978-82-573-0562-8
- Bleken, Brynjulv; [Riksmål og liberalisert bokmål – en sammenlignende oversikt](http://urn.nb.no/URN:NBN:no-nb_digibok_2014020606085) Oslo (1980), ISBN 8299062802
- Lie, Svein; [Innføring i norsk syntaks](http://urn.nb.no/URN:NBN:no-nb_digibok_2009021804107) Universitetsforlaget Oslo (2003) ISBN 978-82-15-00454-9 ([4. edition](http://urn.nb.no/URN:NBN:no-nb_digibok_2007092000090))
- Kuldbrandstad, Lars Andreas; [Språkets mønstre](http://urn.nb.no/URN:NBN:no-nb_digibok_2011082605006) Universitetsforlaget Oslo (2015) ISBN 978-82-15-00771-7 ([2. edition](http://urn.nb.no/URN:NBN:no-nb_digibok_2008082100028))
- Saeed, John I.; *Semantics* Wiley-Blackwell (2009) ISBN 978-1-4051-5639-4
- Johnson, Keith; *Quantitative Methods in Linguistics* Blackwell Publishing (2008) ISBN 978-1-4051-4425-4
- Jurafsky, Daniel; Martin, James H.; *Speech and Language Processing* Pearson Education (2009) ISBN 978-0-13-504196-3
- Hastie, Trevor; Tibshirani, Robert; Friedman, Jerome; [The Elements of Statistical Learning](https://bibsys-almaprimo.hosted.exlibrisgroup.com/primo-explore/fulldisplay?docid=BIBSYS_ILS71505101120002201&context=L&vid=BIBSYS&search_scope=default_scope&isFrbr=true&tab=default_tab&lang=no_NO) Springer Science + Business Media (2009) ISBN 9780387848570

## Other libraries

- [Google Code: languagedetection](https://code.google.com/archive/p/language-detection/#!) (also [GitHub: shuyo/language-detection](https://github.com/shuyo/language-detection))
- [GitHub: optimaize/language-detector](https://github.com/optimaize/language-detector)
- [GitHub: CLD2Owners/cld2](https://github.com/CLD2Owners/cld2)
