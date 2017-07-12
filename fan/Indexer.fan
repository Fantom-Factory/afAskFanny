using fandoc

const class Index {
	
	internal const Str:Section[]	sections
	
	new make(|This| f) { f(this) }

	Section[] tellMeAbout(Str keyword) {
		if (keyword.contains(" "))
			throw ArgErr("Keywords can not contain whitespace! $keyword")
		
		stemmed := Section.stem(keyword)
		secs	:= (Section[]) (sections[stemmed] ?: Section#.emptyList)
		
		sortScore := |Section s->Int| { (s.parents.size * 2) + s.keywords.size }
		secs = secs.rw.sort |s1, s2| { sortScore(s1) <=> sortScore(s2) }
		return secs
	}	
}

class IndexBuilder {
	
	Section[]	sections	:= Section[,]
	
	This indexDocPod(Str podName) {
		sections.addAll(readDocPod(podName))
		return this
	}

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
	
	Section[] readDocPod(Str podName) {
		sections := Section[,]
		podSec	:= SectionBuilder(podName)
		sections.add(podSec.toSection)
		podFile := Env.cur.findPodFile(podName)
		Zip.open(podFile).contents.findAll |file, uri| { uri.ext == "fandoc" && uri.path[0] == "doc" }.each |File fandocFile| {
			typeSec  := SectionBuilder(podName, fandocFile.basename) { it.parents.push(podSec) }

			secs := doReadFandoc(podName, fandocFile.basename, fandocFile.in, typeSec)
			secs.each { it.parents.push(typeSec).push(podSec) }

			sections.add(typeSec.toSection)
			sections.addAll(secs.map { it.toSection })
		}
		return sections
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
					bobs.add(SectionBuilder(pod, type, elem, bobs))
				
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
