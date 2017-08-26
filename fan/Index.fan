
** Index of Fantom documentation.
const class Index {
	private  const Spelling			spelling	:= Spelling()
	internal const Str:Section[]	sections
	internal const Str:Int			counts
	
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
	
	Str[] didYouMean(Str? keyword) {
		if (keyword == null)
			return Str#.emptyList

		maybes := spelling.corrections(counts, keyword)		
		if (maybes.size == 1 && maybes.first == keyword)
			return maybes.clear

		stemmed := SectionBuilder.stem(keyword)
		maybes2 := spelling.corrections(counts, stemmed)
		if (maybes2.size == 1 && maybes.first == keyword)
			return maybes2.clear
		
		maybes = maybes.addAll(maybes2).unique
		
		if (maybes.size > 5)
			maybes.size = 5
		return maybes
	}
}
