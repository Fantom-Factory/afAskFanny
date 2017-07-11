using fandoc
using concurrent::AtomicInt

class DocReader {

	Section[] readDocPod(Str podName) {
		sections := Section[,]
		podFile := Env.cur.findPodFile(podName)
		Zip.open(podFile).contents.findAll |file, uri| { uri.ext == "fandoc" && uri.path[0] == "doc" }.each |File fandocFile| {
			
			sections.addAll(readFandoc(podName, fandocFile.basename, fandocFile.in))
		}
		return sections
	}

	Section[] readFandoc(Str pod, Str type, InStream in) {
		doc := FandocParser().parse("${pod}::${type}", in, true)
		
		// for now, ignore headings that are buried in lists
		bobs := SectionBuilder[,]
		doc.children.each |elem| {
			if (elem is Heading)
				bobs.add(SectionBuilder(pod, type, elem, bobs))
			else
				bobs.last?.addContent(elem)	// ? 'cos not all fandocs start with a heading!
		}
		return bobs.map { it.toSection }
	}	
}

class SectionBuilder {
	Heading 	heading
	DocNode[]	content		:= DocNode[,]
	
	Str			id
	Str			pod
	Str			type
	Str			fandocUrl
	Version		chapter
	SectionBuilder[]	parents
	Section?	section
	
	new make(Str pod, Str type, Heading heading, SectionBuilder[] bobs) {
		this.id			= genShortId
		this.pod		= pod
		this.type		= type
		this.fandocUrl	= "${pod}::${type}"
		this.heading 	= heading
		this.parents	= SectionBuilder[,]
		
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
		chapter = Version(levs.reverse)
	}
	
	Void addContent(DocNode node) {
		content.add(node)
	}
	
	private static const AtomicInt lastTimeRef := AtomicInt(0)
	static Str genShortId() {
		time := DateTime.nowTicks / 1sec.ticks
		
		// try to keep spurts of activities in order
		if (time <= lastTimeRef.val)
			time = lastTimeRef.incrementAndGet
		lastTimeRef.val = time
		
		// 2.pow(32) / 60 sec / 60 min / 24 hour / 365 day == 136 years --> and no one will over need more than 48K of RAM
		time = time.and(0xffff_ffff)

		rand := Int.random.and(0xffff_ffff)
		return StrBuf(20).add(time.toHex(8)).addChar('-').add(rand.toHex(8)).toStr
	}
	
	Section? toSection() {
		buf := Buf()
		out := FandocDocWriter(buf.out)
		content.each { it.write(out) }
		fandoc := buf.flip.readAllStr
		
		return section = Section {
			it.id		= this.id
			it.pod		= this.fandocUrl[0..<this.fandocUrl.index(":")]
			it.type		= this.fandocUrl[this.fandocUrl.index(":")+2..-1]
			it.chapter	= this.chapter
			it.heading	= this.heading.title
			it.anchorId	= this.heading.anchorId
			it.content	= fandoc
			it.fandocUrl = this.fandocUrl
			it.fantomUrl = `http://fantom.org/doc/${it.pod}/${it.type}#${it.anchorId}`
			it.parents	= this.parents.isEmpty ? Str#.emptyList : this.parents.map { it.section }
		}
	}
}


