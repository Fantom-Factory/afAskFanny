
const class Section {
	const Str		id
	const Str[]		keywords
	const Str		pod
	const Str		type
	const Version	chapter
	const Str		heading
	const Str		anchorId
	const Str		content
	const Str		fandocUrl
	const Uri		fantomUrl
	const Section[]	parents

	new make(|This| f) {
		f(this)
		
		// TODO add acronyms
		keywords = heading.toDisplayName.lower.split.map { stem(it) }
		.exclude |Str key->Bool| { key.size < 2 || key.endsWith("-") }	// remove nonsense
		.exclude |Str key->Bool| { ["and", "the"].contains(key) }		// remove stopwords
	}
	
	// TODO proper stemming!
	private Str stem(Str word) {
		// classes -> class, closures -> closur!!!??
		if (word.endsWith("es"))
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
		text := "\n\n"
		text += "  " * lev
		text += pod + "\n"; lev++
		text += "  " * lev
		text += type + "\n"; lev++
		parents.each {
			text += "  " * lev
			text += "${it.chapter}. ${it.heading}\n"; lev++
		}
		text += "  " * lev
		text += "${chapter}. ${heading}\n"
		text += "  " * lev		
		text += "${fantomUrl}\n\n"

		text += content
		return TextWrapper { normaliseWhitespace = false }.wrap(text, maxWidth)
	}
	
	Str toFandocText(Int maxWidth := 80) {
		text := "`${fandocUrl}` --> `${fantomUrl}`\n"
		text += heading + "\n\n"
		text += content
		return TextWrapper { normaliseWhitespace = false }.wrap(text, maxWidth)
	}
}
