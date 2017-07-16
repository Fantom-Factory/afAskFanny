using fandoc::Link
using fandoc::HtmlDocWriter
using fandoc::FandocParser

const class Section {
	const Str		what
	const Str		pod
	const Str?		type
	const Str		title
	const Str		content
	const Bool		isApi
	const Bool		isDoc
	const Str[]		keywords
	const Str		fanUrl
	const Section[]	parents

	new make(|This| f) {
		f(this)
		
		// TODO add acronyms
		keywords = keywords.map { it.lower }
	}

	internal Bool containsKeyword(Str keyword) {
		keywords.contains(keyword)
	}

	Str toPlainText(Int maxWidth := 80) {
		lev := 0
		text := "\n\n(${what})\n${resolve(fanUrl)}\n\n"
		parents.dup.insert(0, this).eachr {
			text += "".justl(lev * 2)
			text += "${it.title}\n"; lev++
		}
		text += "\n" + content
		return "\n\n" + TextWrapper { normaliseWhitespace = false }.wrap(text, maxWidth)
	}
	
	Str toHtml(Uri baseUrl := `http://fantom.org/doc/`) {
		buf := Buf()
		out := HtmlDocWriter(buf.out)
		out.onLink = |Link link| {
			link.uri = resolve(link.uri, baseUrl).encode
		}

		doc := FandocParser().parse(fanUrl, content.in)
		doc.writeChildren(out)
		
		return buf.flip.readAllStr
	}
	
	Uri webUrl() {
		resolve(fanUrl)
	}
	
	Uri resolve(Str url, Uri baseUrl := `http://fantom.org/doc/`) {
		cols := url.split(':').exclude { it.isEmpty }.map { it.split('.') }.flatten.map { it.toStr.split('#') }.flatten
		
		if (!url.contains("::"))
			cols.insert(0, pod)
		
		if (cols.size == 1)
			return `${baseUrl}${cols[0]}/index`
		if (cols.size == 2)
			return `${baseUrl}${cols[0]}/${cols[1]}` 
		if (cols.size == 3)
			return `${baseUrl}${cols[0]}/${cols[1]}#${cols[2]}` 
		return url.toUri
	}
	
	@NoDoc
	override Str toStr() { fanUrl }
}
