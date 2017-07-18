
** Index of Fantom documentation.
const class Index {
	internal const Str:Section[]	sections
	
	internal new make(|This| f) { f(this) }

	** Seek the wisdom of the floating fantasm.
	Section[] askFanny(Str? keyword) {
		if (keyword?.trimToNull == null)
			return Section#.emptyList
		if (keyword.contains(" "))
			throw ArgErr("Keyword may not contain whitespace! $keyword")
		
		keyword	= keyword.lower
		secs	:= (Section[]) (sections[keyword] ?: Section[,]).rw		
		stemmed := SectionBuilder.stem(keyword)
		if (stemmed != keyword)
			secs.addAll(sections[stemmed] ?: Section#.emptyList)

		sortScore := |Section s->Int| { (s.parents.size * 2) + s.keywords.size + (s.what.isApi ? 10 : 0) }
		secs = secs.rw.sort |s1, s2| { sortScore(s1) <=> sortScore(s2) }
		return secs
	}
}
