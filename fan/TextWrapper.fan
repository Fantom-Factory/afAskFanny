
** Utility class for pretty-printing text. 
** 
** Example:
** 
** pre>
** text := TextWrapper().wrap("Chuck Norris once ordered a Big Mac at Burger King, and got one.", 25)
** 
** // --> Chuck Norris once ordered
**        a Big Mac at Burger King,
**        and got one.
** 
** <pre 
const class TextWrapper {

	** If 'true', then the text is trimmed.
	const Bool trim					:= true

	** If 'true', then each run of whitespace (including tabs and new lines) is replaced with a single space character.
	const Bool normaliseWhitespace	:= true
	
    ** If 'true', then words longer than 'maxWidth' will be broken in order to ensure that no line 
    ** is longer than 'maxWidth'. 
    ** 
    ** If 'false', then long words will not be broken and some lines may be longer than 'maxWidth'. 
    ** (Long words will be put on a line by themselves, in order to minimise the amount by which 
    ** 'maxWidth' is exceeded.)
	const Bool breakLongWords		:= true

    ** If 'true', wrapping will occur on whitespace and after hyphens in compound words.
	const Bool breakOnHyphens		:= true
	
	** Standard it-block ctor for setting field values.
	** 
	**   syntax: fantom
	**   iceT := TextWrapper {
	**       it.breakLongWords = false
	**   }
	new make(|This|? f := null) { f?.call(this) }

	** Formats and word wraps the given text. 
	Str wrap(Str text, Int maxWidth) {
		if (trim)
			text = text.trim

		if (normaliseWhitespace) {
			chrs := Int[,]
			spce := false
			text.each |ch| {
				if (ch.isSpace) {
					if (!spce)
						chrs.add(' ')
					spce = true
				} else {
					spce = false
					chrs.add(ch)
				}
			}
			text = Str.fromChars(chrs)
		}
		
		buff := StrBuf()
		line := StrBuf()
		word := StrBuf()

		flushLine := |->| {
			if (!normaliseWhitespace || line.toStr.trimEnd.size > 0) {
				buff.join(line.toStr.trimEnd, "\n")
				line.clear
			}
		}

		flushWord := |Str char| {
			if (word.size + char.size > 0) {
				if (line.size + (word.toStr + char).trim.size > maxWidth)
					flushLine()
	
				if (word.size > maxWidth && breakLongWords) {
					flushLine()
					while (word.size > maxWidth) {
						part := word.getRange(0..<maxWidth)
						buff.join(part, "\n")
						word.removeRange(0..<maxWidth)
					}
				}

				line.add(word.toStr)
				word.clear

				if (char == "\n")
					flushLine()
				else
					line.add(char)
			}
		}

		text.each |char| {
			if (char.isSpace || (breakOnHyphens && char == '-'))
				flushWord(char.toChar)
			else
				word.addChar(char)
		}

		flushWord("")
		flushLine()

		return buff.toStr
	}
}