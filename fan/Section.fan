using fandoc::Link
using fandoc::HtmlDocWriter
using fandoc::FandocParser

** A search result.
const class Section {
	
	** What the Section is. 
	const SectionType	what
	
	** Name of the (containing) pod.
	const Str		pod
	
	** Name of the (containing) chapter / type.
	const Str?		type
	
	** Display name.
	const Str		title
	
	** Fandoc content.
	const Str		content
	
	** List of keywords this Section is indexed under.
	const Str[]		keywords
	
	** The fantom qname of this Section.
	const Str		qname
	
	** A hierarchy of parents.
	const Section[]	parents

	** Standard it-block ctor.
	new make(|This| f) {
		f(this)
		
		// TODO add acronyms
		keywords = keywords.map { it.lower }
	}

	internal Bool containsKeyword(Str keyword) {
		keywords.contains(keyword)
	}

	** Renders the section to pretty plain text, wrapping at the given 'maxWidth'.
	Str toPlainText(Int maxWidth := 80) {
		lev := 0
		text := "\n\n(${what})\n${resolve(qname)}\n\n"
		parents.dup.insert(0, this).eachr {
			text += "".justl(lev * 2)
			text += "${it.title}\n"; lev++
		}
		text += "\n" + content
		return "\n\n" + TextWrapper { normaliseWhitespace = false }.wrap(text, maxWidth)
	}
	
	** Returns the fandoc content as HTML, resolving links to the given 'baseUrl'. 
	Str contentAsHtml(Uri baseUrl := `http://fantom.org/doc/`) {
		buf := Buf()
		out := HtmlDocWriter(buf.out)
		out.onLink = |Link link| {
			link.uri = resolve(link.uri, baseUrl).encode
		}

		doc := FandocParser().parse(qname, content.in)
		doc.writeChildren(out)
		
		return buf.flip.readAllStr
	}
	
	** Resolves this Section's 'qname' to a web URL.
	Uri webUrl() {
		resolve(qname)
	}
	
	** Resolves the given 'qname' to a web URL. Returns 'qname.toUri' if it doesn't look like a qname.
	Uri resolve(Str qname, Uri baseUrl := `http://fantom.org/doc/`) {
		cols := qname.split(':').exclude { it.isEmpty }.map { it.split('.') }.flatten.map { it.toStr.split('#') }.flatten
		
		if (!qname.contains("::"))
			cols.insert(0, pod)
		
		if (cols.size == 1)
			return `${baseUrl}${cols[0]}/index`
		if (cols.size == 2)
			return `${baseUrl}${cols[0]}/${cols[1]}` 
		if (cols.size == 3)
			return `${baseUrl}${cols[0]}/${cols[1]}#${cols[2]}` 
		return qname.toUri
	}
	
	@NoDoc
	override Str toStr() { qname }
}

** The type of Section.
enum class SectionType {
	pod, type, field, method, chapter, documentation;
	
	** Convenience for 'name.toDisplayName'.
	Str dis() {
		name.toDisplayName
	}
	
	** Returns 'true' if 'type', 'field', or 'method'.
	Bool isApi() {
		this == type || this == field || this == method 
	}
	
	** Returns 'true' if 'field' or 'method'.
	Bool isSlot() {
		this == field || this == method
	}
	
	** Returns 'true' if 'pod', 'chapter' or 'documentation'.
	Bool isDoc() {
		this == pod || this == chapter || this == documentation
	}
}