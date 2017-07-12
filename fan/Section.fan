using fandoc
using compilerDoc

const class Section {
	const Str[]		keywords
	const Str		pod
	const Str?		type
	const Str?		heading
	const Str?		anchorId
	const Str		content
	const Str		fanUrl
	const Uri		webUrl
	const Section[]	parents
	const Str		title

	new make(|This| f) {
		f(this)
		
		// TODO add acronyms
		keys := null as Str[]
		if (type == null)
			keys = [pod]
		else if (heading == null)
			keys = [type]
		else
			keys = heading.toDisplayName.split
		
		keywords = keys.map { stem(it.lower) }
				.exclude |Str key->Bool| { key.size < 2 || key.endsWith("-") }	// remove nonsense
				.exclude |Str key->Bool| { ["and", "or", "the"].contains(key) }	// remove stopwords
	}
	
	// TODO proper stemming!
	static Str stem(Str word) {
		// classes -> class, closures -> closure!!!??
		if (word.endsWith("ses"))
			word = word[0..<-2]
		// pods -> pod, this -> this, class -> class
		if (word.endsWith("s") && !word.endsWith("is") && !word.endsWith("ss"))
			word = word[0..<-1]
		return word		
	}

	internal Bool containsKeyword(Str keyword) {
		keywords.contains(keyword)
	}

	Str toPlainText(Int maxWidth := 80) {
		lev := 0
		text := "\n\n${webUrl}\n\n"
		parents.dup.insert(0, this).eachr {
			text += "  " * lev
			text += "${it.title}\n"; lev++
		}
		text += "\n" + content
		return "\n\n" + TextWrapper { normaliseWhitespace = false }.wrap(text, maxWidth)
	}
	
	Str toFandocText(Int maxWidth := 80) {
		text := "`${fanUrl}` --> `${webUrl}`\n"
		text += heading + "\n\n"
		text += content
		return TextWrapper { normaliseWhitespace = false }.wrap(text, maxWidth)
	}
	
	@NoDoc
	override Str toStr() {
		fanUrl
	}
}

class SectionBuilder {
	static const Uri	webBaseUrl	:= `http://fantom.org/doc/`
	Str					fanUrl
	Uri					webUrl
	Str					pod
	Str?				type
	Str					title
	Str?				fandoc
	Heading? 			heading
	DocNode[]?			content
	SectionBuilder[]	parents		:= SectionBuilder[,]
	Section?			section
	
	new makePod(DocPod pod) {
		this.pod		= pod.name
		this.title		= pod.name
		this.fandoc		= pod.summary
		this.fanUrl		= "${pod.name}::index"
		this.webUrl		= webBaseUrl + `${pod.name}/index`
	}
	
	new makeChapter(Str pod, Str type) {
		this.pod		= pod
		this.type		= type
		this.title		= type
		this.fanUrl		= "${pod}::${type}"
		this.webUrl		= webBaseUrl + `${pod}/${type}`
		this.content	= DocNode[,]
	}

	new makeDoc(Str pod, Str type, Heading heading, SectionBuilder[] bobs) {
		this.pod		= pod
		this.type		= type
		this.heading 	= heading
		this.fanUrl		= "${pod}::${type}#${heading.anchorId}"
		this.webUrl		= webBaseUrl + `${pod}/${type}#${heading.anchorId}`
		this.content	= DocNode[,]

		levs := Int[1]
		lev  := heading.level
		bobs.eachr |sec| {
			if (sec.heading.level == lev)
				levs.push(levs.pop.increment)
			if (sec.heading.level < lev) {
				levs.push(1)
				lev = sec.heading.level
				parents.push(sec)
			}
		}
		chapter := Version(levs.reverse)
		
		this.title = "${chapter}. ${heading.title}"
	}
	
	Void addContent(DocNode node) {
		content.add(node)
	}
	
	Section toSection() {
		if (fandoc == null) {
			buf := Buf()
			out := FandocDocWriter(buf.out)
			content.each { it.write(out) }
			fandoc = buf.flip.readAllStr
		}

		return section = Section {
			it.pod		= this.pod
			it.type		= this.type
			it.title	= this.title
			it.heading	= this.heading?.title
			it.anchorId	= this.heading?.anchorId
			it.content	= fandoc
			it.fanUrl	= this.fanUrl
			it.webUrl	= this.webUrl
			it.parents	= this.parents.map { it.section }.exclude { it == null }
			
			if (it.parents.isEmpty)
				it.parents = Section#.emptyList
		}
	}
	
	override Str toStr() { fanUrl }
}

