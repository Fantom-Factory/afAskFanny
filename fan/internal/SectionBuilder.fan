using fandoc
using compilerDoc

internal class SectionBuilder {
	static const Uri	webBaseUrl	:= `http://fantom.org/doc/`
	Str					fanUrl
	Str					what
	Str					pod
	Str?				type
	Str					title
	Str?				fandoc
	Bool				isApi
	Str[]				keywords
	Heading? 			heading
	DocNode[]?			content
	SectionBuilder[]	parents		:= SectionBuilder[,]
	
	new makePod(DocPod pod) {
		this.what		= "Pod"
		this.pod		= pod.name
		this.title		= pod.name
		this.fandoc		= pod.summary
		this.fanUrl		= "${pod.name}::index"
		this.keywords	= [pod.name]
	}
	
	new makeType(DocType type) {
		this.what		= "Type"
		this.pod		= type.pod.name
		this.type		= type.name
		this.title		= type.qname
		this.fanUrl		= "${this.pod}::${this.type}"
		this.fandoc		= type.doc.text
		this.keywords	= [type.name]
		this.isApi		= true
	}
	
	new makeSlot(DocSlot slot) {
		this.what		= "Slot"
		this.pod		= slot.parent.pod
		this.type		= slot.parent.name
		this.title		= slot.qname
		this.fanUrl		= "${this.pod}::${this.type}.${slot.name}"
		this.fandoc		= slot.doc.text
		this.keywords	= [slot.name]
		this.isApi		= true
		
		field := slot as DocField
		if (field != null) {
			this.what = "Field"
			if (field.init != null)
				title += " := ${field.init}"
		}

		method := slot as DocMethod
		if (method != null) {
			this.what = "Method"
			title += "(" + method.params.join(", ") { it.toStr } + ")"
		}
	}
	
	new makeChapter(Str pod, Str fileBaseName, Int? idx) {
		this.what 		= "Documentation"
		this.pod		= pod
		this.type		= fileBaseName
		this.title		= fileBaseName
		this.fanUrl		= "${pod}::${fileBaseName}"
		this.content	= DocNode[,]
		this.keywords	= type.toDisplayName.split.map { stem(it) }
		
		if (idx != null)
			title = idx.toStr + ". " + title
	}

	new makeDoc(Str pod, Str type, Heading heading, SectionBuilder[] bobs, Bool overview, Int? idx) {
		if (type == "pod") type = "index"
		this.what 		= "Documentation"
		this.pod		= pod
		this.type		= type
		this.heading 	= heading
		this.fanUrl		= "${pod}::${type}#${heading.anchorId}"
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
		// cater for missing out 'Overview' sections
		if (overview)
			levs.push(levs.pop.increment)
		if (idx != null)
			levs.push(idx)
		
		chapter := Version(levs.reverse)		
		this.title = "${chapter}. ${heading.title}"

		this.keywords = heading.title.toDisplayName.split.map { stem(it) }
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

	Void addContent(DocNode node) {
		// this happens when writing pod.fandoc overviews to pod sections
		if (content == null) {
			content = DocNode[,]
			fanUrl += "#overview"
			if (fandoc != null) {
				content = DocNode[ Para().add(DocText(fandoc)) ]
				fandoc  = null
			}
		}
		content.add(node)
	}
	
	once Section toSection() {
		if (fandoc == null) {
			buf := Buf()
			out := FandocDocWriter(buf.out)
			content.each { it.write(out) }
			fandoc = buf.flip.readAllStr
		}

		return Section {
			it.what		= this.what
			it.pod		= this.pod
			it.type		= this.type
			it.title	= this.title
			it.isApi	= this.isApi
			it.isDoc	= this.isApi.not
			it.keywords	= this.keywords
			it.content	= fandoc
			it.fanUrl	= this.fanUrl
			it.parents	= this.parents.map { it.toSection }
		}
	}
	
	override Str toStr() { fanUrl }
}

