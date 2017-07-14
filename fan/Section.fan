
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
	const Uri		webUrl
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
		text := "\n\n(${what})\n${webUrl}\n\n"
		parents.dup.insert(0, this).eachr {
			text += "".justl(lev * 2)
			text += "${it.title}\n"; lev++
		}
		text += "\n" + content
		return "\n\n" + TextWrapper { normaliseWhitespace = false }.wrap(text, maxWidth)
	}
	
	@NoDoc
	override Str toStr() { fanUrl }
}
