
const class Index {
	static const Uri	webBaseUrl	:= `http://fantom.org/doc/`

	internal const Str:Section[]	sections
	
	internal new make(|This| f) { f(this) }

	Section[] tellMeAbout(Str keyword) {
		if (keyword.contains(" "))
			throw ArgErr("Keywords can not contain whitespace! $keyword")
		
		secs	:= (Section[]) (sections[keyword] ?: Section[,]).rw		
		stemmed := SectionBuilder.stem(keyword)
		if (stemmed != keyword)
			secs.addAll(sections[stemmed] ?: Section#.emptyList)

		sortScore := |Section s->Int| { (s.parents.size * 2) + s.keywords.size + (s.isApi ? 10 : 0) }
		secs = secs.rw.sort |s1, s2| { sortScore(s1) <=> sortScore(s2) }
		return secs
	}
}
