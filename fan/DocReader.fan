using fandoc
using concurrent::AtomicInt

class DocReader {

	Section[] readDocPod(Str podName) {
		sections := Section[,]
		podSec	:= SectionBuilder(podName)
		sections.add(podSec.toSection)
		podFile := Env.cur.findPodFile(podName)
		Zip.open(podFile).contents.findAll |file, uri| { uri.ext == "fandoc" && uri.path[0] == "doc" }.each |File fandocFile| {
			typeSec  := SectionBuilder(podName, fandocFile.basename) { it.parents.push(podSec) }
			sections.add(typeSec.toSection)

			secs := doReadFandoc(podName, fandocFile.basename, fandocFile.in)
			secs.each { it.parents.push(typeSec).push(podSec) }
			sections.addAll(secs.map { it.toSection })
		}
		return sections
	}

	Section[] readFandoc(Str pod, Str type, InStream in) {
		doReadFandoc(pod, type, in).map { it.toSection }
	}	

	private SectionBuilder[] doReadFandoc(Str pod, Str type, InStream in) {
		doc := FandocParser().parse("${pod}::${type}", in, true)
		
		bobs := SectionBuilder[,]
		// for now, ignore headings that are buried in lists
		doc.children.each |elem| {
			if (elem is Heading)
				bobs.add(SectionBuilder(pod, type, elem, bobs))
			else
				bobs.last?.addContent(elem)	// ? 'cos not all fandocs start with a heading!
		}
		return bobs
	}	
}

class SectionBuilder {
	static const Uri	webBaseUrl	:= `http://fantom.org/doc/`
	Str					fanUrl
	Uri					webUrl
	Str					pod
	Str?				type
	Version?			chapter
	Heading? 			heading
	DocNode[]			content		:= DocNode[,]	
	SectionBuilder[]	parents		:= SectionBuilder[,]
	Section?			section
	
	new makePod(Str pod) {
		this.pod		= pod
		this.fanUrl		= "${pod}::index"
		this.webUrl		= webBaseUrl + `${pod}/index`
	}
	
	new makeType(Str pod, Str type) {
		this.pod		= pod
		this.type		= type
		this.fanUrl		= "${pod}::${type}"
		this.webUrl		= webBaseUrl + `${pod}/${type}`
	}

	new makeDoc(Str pod, Str type, Heading heading, SectionBuilder[] bobs) {
		this.pod		= pod
		this.type		= type
		this.heading 	= heading
		this.fanUrl		= "${pod}::${type}#${heading.anchorId}"
		this.webUrl		= webBaseUrl + `${pod}/${type}#${heading.anchorId}`

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
	
	Section toSection() {
		buf := Buf()
		out := FandocDocWriter(buf.out)
		content.each { it.write(out) }
		fandoc := buf.flip.readAllStr

		return section = Section {
			it.pod		= this.pod
			it.type		= this.type
			it.chapter	= this.chapter
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
	
	override Str toStr() {
		"${pod}::${type}#${this.heading?.anchorId}"
	}
}
