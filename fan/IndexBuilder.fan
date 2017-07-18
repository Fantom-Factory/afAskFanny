using fandoc
using compilerDoc

** Indexes documents and pods to create an 'Index' instrance.
class IndexBuilder {
//	private static const Str[] corePodNames := "docIntro docLang docFanr docTools docDomkit build compiler compilerDoc compilerJava compilerJs concurrent dom domkit email fandoc fanr fansh flux fluxText fwt gfx icons inet obix sql syntax sys testCompiler testJava testNative testSys util web webfwt webmod wisp xml".split
	private static const Str[] corePodNames := "docIntro docLang docTools docDomkit concurrent dom domkit email fandoc fwt gfx inet sys util web webfwt webmod wisp xml".split

	private DocEnv docEnv	:= DefaultDocEnv()
	Section[]	sections	:= Section[,]
	
	** Builds an 'Index' instance from the indexed documents.
	Index build() {
		keywords := sections.map { it.keywords }.flatten.unique.sort
				
		sections := Str:Section[][:]
		keywords.each |keyword| {
			sections[keyword] = this.sections.findAll { it.containsKeyword(keyword) }
		}
		return Index {
			it.sections = sections 
		}
	}

	** Indexes all pods in the current Fantom installation.
	This indexAllPods() {
		Env.cur.findAllPodNames.each { indexPod(it) }
		return this
	}

	** Indexes a subset of core pods from the standard Fantom installation;
	** including 'sys' and all reference documentation. 
	This indexCorePods() {
		corePodNames.each { indexPod(it) }
		return this
	}
	
	** Indexes the contents of a pod, including:
	**  - all documented types - '<pod>/doc/*.apidoc'
	**  - all fandocs - '<pod>/doc/*.fandoc'
	This indexPod(Str podName) {
		podFile := Env.cur.findPodFile(podName)
		if (podFile == null) return this	// todo make this checked??

		docPod	:= DocPod.load(docEnv, podFile)
		podSec	:= SectionBuilder(docPod)

		indexDocs(podName, podSec)
		indexTypes(docPod, podSec)
		
		// wait until any Overview sections have been added
		sections.add(podSec.toSection)
		return this
	}

	** Indexes a single fandoc file. Useful for adhoc documents.
	This indexFandoc(Str pod, Str type, InStream in) {
		doIndexFandoc(pod, type, in, null, null).map { it.toSection }
		return this
	}

	private Void indexTypes(DocPod docPod, SectionBuilder podSec) {
		docPod.types.each |DocType type| {
			typeSec  := SectionBuilder.makeType(type) { it.parents.push(podSec) }

			secs := (SectionBuilder[]) type.slots.map {
				SectionBuilder.makeSlot(it)
			}
			secs.each { it.parents.push(typeSec).push(podSec) }

			sections.add(typeSec.toSection)
			sections.addAll(secs.map { it.toSection })
		}
	}
	
	private Void indexDocs(Str podName, SectionBuilder podSec) {
		podFile := Env.cur.findPodFile(podName)
		zip 	:= Zip.open(podFile)
		index	:= zip.contents[`/doc/index.fog`]
		files	:= null as File[] 
		if (index != null) {
			fog := index.readObj as Obj[]
			names := fog.map { it is List ? (it as List).first : null }.exclude { it == null }
			files = names.map |con| { zip.contents.find |v, k| { k ==`/doc/${con}.fandoc` } }.exclude { it == null }	// exclude null incase we have a dodgy index.fog with unkown file names
		} else
			files = zip.contents.findAll |file, uri| { uri.ext == "fandoc" && uri.path[0] == "doc" }.vals
		
		files.each |File fandocFile, i| {
			idx := index != null ? i+1 : null

			typeSec  := fandocFile.name == "pod.fandoc"
				? podSec
				: SectionBuilder.makeChapter(podName, fandocFile.basename, idx) { it.parents.push(podSec) }

			secs := doIndexFandoc(podName, fandocFile.basename, fandocFile.in, typeSec, idx)
			secs.each {
				it.parents.push(typeSec)
				if (typeSec !== podSec)
					it.parents.push(podSec)
			}

			if (typeSec != podSec)
				sections.add(typeSec.toSection)
			sections.addAll(secs.map { it.toSection })
		}
		zip.close
	}	

	private SectionBuilder[] doIndexFandoc(Str pod, Str type, InStream in, SectionBuilder? parent, Int? idx) {
		doc := FandocParser().parse("${pod}::${type}", in, true)
		
		overview := false
		bobs := SectionBuilder[,]
		// for now, ignore headings that are buried in lists
		doc.children.each |elem| {
			if (elem is Heading) {
				if (parent != null && bobs.isEmpty && (elem as Heading).title == "Overview")
					overview = true
				else
					bobs.add(SectionBuilder.makeDoc(pod, type, elem, bobs, overview, idx))
				
			} else {
				// ? 'cos not all fandocs start with a heading!
				if (bobs.isEmpty)
					parent?.addContent(elem)
				else
					bobs.last.addContent(elem)
			}
		}
		return bobs
	}	
}

