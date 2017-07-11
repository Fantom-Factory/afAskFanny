
const class Index {
	
	internal const Str:Section[]	sections
	
	new make(|This| f) { f(this) }

	Section[] tellMeAbout(Str keyword) {
		if (keyword.contains(" "))
			throw ArgErr("Keywords can not contain whitespace! $keyword")
		// TODO stem keyword
		secs := (Section[]) (sections[keyword] ?: Section#.emptyList)
		
		secs = secs.rw.sort |p1, p2| { p1.keywords.size <=> p2.keywords.size }
		return secs
	}	
}

class IndexBuilder {
	
	Section[]	sections	:= Section[,]
	
	This indexDocPod(Str podName) {
		sections.addAll(DocReader().readDocPod(podName))
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
}
