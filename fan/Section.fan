
const class Section {
	const Str[]		keywords
	const Str		pod
	const Str?		type
	const Version?	chapter
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
		
		if (type == null)
			title = pod
		else if (heading == null)
			title = type
		else {
			if (chapter == null)
				title = heading
			else
				title = "${chapter}. ${heading}"
		}
	}
	
	// TODO proper stemming!
	private Str stem(Str word) {
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
