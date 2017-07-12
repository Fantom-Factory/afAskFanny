using fandoc
using compilerDoc

const class Index {
	
	internal const Str:Section[]	sections
	
	new make(|This| f) { f(this) }

	Section[] tellMeAbout(Str keyword) {
		if (keyword.contains(" "))
			throw ArgErr("Keywords can not contain whitespace! $keyword")
		
		secs	:= (Section[]) (sections[keyword] ?: Section[,])		
		stemmed := SectionBuilder.stem(keyword)
		if (stemmed != keyword)
			secs.addAll(sections[stemmed] ?: Section#.emptyList)

		sortScore := |Section s->Int| { (s.parents.size * 2) + s.keywords.size + (s.isApi ? 10 : 0) }
		secs = secs.rw.sort |s1, s2| { sortScore(s1) <=> sortScore(s2) }
		return secs
	}	
}

class IndexBuilder {
	private DocEnv docEnv	:= DefaultDocEnv()
	Section[]	sections	:= Section[,]
	
	Index buildIndex() {
		keywords := sections.map { it.keywords }.flatten.unique.sort
				
		sections := Str:Section[][:]
		keywords.each |keyword| {
			sections[keyword] = this.sections.findAll { it.containsKeyword(keyword) }
		}
		echo(keywords)
		return Index {
			it.sections = sections 
		}
	}

	This indexPod(Str podName) {
		podFile := Env.cur.findPodFile(podName)
		docPod	:= DocPod.load(docEnv, podFile)
		podSec	:= SectionBuilder(docPod)
		sections.add(podSec.toSection)

		indexDocs(podName, podSec)
		indexTypes(docPod, podSec)
		return this
	}

	private Void indexTypes(DocPod docPod, SectionBuilder podSec) {
		docPod.types.each |DocType type| {
			typeSec  := SectionBuilder.makeType(type) { it.parents.push(podSec) }

			secs := (SectionBuilder[]) type.slots.map {
				SectionBuilder.makeSlot(it)
			}
			secs.each { it.parents.push(typeSec).push(podSec) }

			sections.add(typeSec.toSection)
			sections.addAll(secs.map { it.toSection })
		}
	}

	
	private Void indexDocs(Str podName, SectionBuilder podSec) {
		podFile := Env.cur.findPodFile(podName)
		Zip.open(podFile).contents.findAll |file, uri| { uri.ext == "fandoc" && uri.path[0] == "doc" }.each |File fandocFile| {
			typeSec  := SectionBuilder.makeChapter(podName, fandocFile.basename) { it.parents.push(podSec) }

			secs := doReadFandoc(podName, fandocFile.basename, fandocFile.in, typeSec)
			secs.each { it.parents.push(typeSec).push(podSec) }

			sections.add(typeSec.toSection)
			sections.addAll(secs.map { it.toSection })
		}
	}

	Section[] readFandoc(Str pod, Str type, InStream in) {
		doReadFandoc(pod, type, in, null).map { it.toSection }
	}	

	private SectionBuilder[] doReadFandoc(Str pod, Str type, InStream in, SectionBuilder? parent) {
		doc := FandocParser().parse("${pod}::${type}", in, true)
		
		bobs := SectionBuilder[,]
		// for now, ignore headings that are buried in lists
		doc.children.each |elem| {
			if (elem is Heading) {
				if (parent == null || bobs.size > 0 || (elem as Heading).title != "Overview")
					bobs.add(SectionBuilder.makeDoc(pod, type, elem, bobs))
				
			} else {
				// ? 'cos not all fandocs start with a heading!
				if (bobs.isEmpty)
					parent?.addContent(elem)
				else
					bobs.last.addContent(elem)
			}
		}
		return bobs
	}	
}
