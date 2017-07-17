#Ask Fanny v0.0.0
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom-lang.org/)
[![pod: v0.0.0](http://img.shields.io/badge/pod-v0.0.0-yellow.svg)](http://www.fantomfactory.org/pods/afAskFanny)
![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)

## Overview

Ask Fanny is a mini search engine for the reference documentation of the Fantom Programming Language - see [http://fantom.org/](http://fantom.org/).

It's a library that indexes and ranks all the headings and titles of the core Fantom documentation and libraies for single words, and makes them available as:

- a programmable API
- a Command Line Program
- a Website

Every standard Fantom installation comes complete with examples and reference documentation. Tools such as [Explorer](http://eggbox.fantomfactory.org/pods/afExplorer/doc/#fandocViewer) let you view that documentation, which is great if you know what you're looking for or wish read it from start to finish like a novel.

But searching can be difficult if you don't know exactly where to look... it is hoped "Ask Fanny" fills that gap.

*The Fantom documentation is actually pretty good, but it's sometimes hard to find what you're looking for. I hope "Ask Fanny" changes that. - Steve Eynon*

## Install

Install `Ask Fanny` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afAskFanny

Or install `Ask Fanny` with [fanr](http://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afAskFanny

To use in a [Fantom](http://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afAskFanny 0.0"]

## Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afAskFanny/) - the Fantom Pod Repository.

## API

The API contains an [IndexBuilder](http://eggbox.fantomfactory.org/pods/afAskFanny/api/IndexBuilder) that creates an [Index](http://eggbox.fantomfactory.org/pods/afAskFanny/api/Index) which you query for [Section](http://eggbox.fantomfactory.org/pods/afAskFanny/api/Section) results.

    index   := IndexBuilder().indexAllPods.build
    results := index.askFanny("Fantom")
    
    results.each { echo(it.toPlainText) }

## Command Line Program

Ask Fanny may be run from a command line to give instant search results:

```
> fan afAskFanny Maps
```

Use the `-h` flag to list available options.

```
> fan afAskFanny -h
```

## Website

Ask Fanny is also distributed with a fully functioning web site. To launch it, use the `-webserver` option from the command line.

```
> fan afAskFanny -webserver
```

By default Ask Fanny runs on port 8069 so point your browser at `http://localhost:8069/` to view.

The Ask Fanny website is also availble online at [http://askfanny.fantomfactory.org](http://askfanny.fantomfactory.org/).

## Fanny

Fanny is the mascot of the Fantom programming language as named by Andy Frank (one of Fantom's creators) in this [forum post](http://fantom.org/forum/topic/2125#c1). The mascot cartoon itself was evolved for the [Fantom-Lang website](http://fantom-lang.org/).

