
internal class TestIndexing : Test {
	
	Index? index
	
	Void testStuff() {
		
		index = IndexBuilder()
			.indexPod("docLang")
			.indexPod("sys")
			.buildIndex
		
		
		
		tellMeAbout("pod")
//		tellMeAbout("comment")
//		tellMeAbout("map")
		tellMeAbout("safe") //-> 2.6
		
		
		pods := index.tellMeAbout("pod")
		sec  := pods[0]
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Pods")
		verifyEq(sec.title, "Pods")
		// check that Overview content is merged with parent
		verifyEq(sec.content.startsWith("Pods are the top of Fantom's namespace as well as the unit of deployment."), true)

		sec  = pods[1]
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Structure")
		verifyEq(sec.title, "1. Pods")
		verifyEq(sec.webUrl.frag, "pods")

		
		
		safe := index.tellMeAbout("safe")
		sec  = safe.first
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Expressions")
		verifyEq(sec.title, "6.2. Safe Invoke")
		verifyEq(sec.webUrl.frag, "safeInvoke")
		verifyEq(sec.parents[0].title, "6. Null Convenience Operators")
		verifyEq(sec.parents[1].title, "Expressions")
		verifyEq(sec.parents[2].title, "docLang")
		
		sec  = safe.first.parents[0]
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Expressions")
		verifyEq(sec.title, "6. Null Convenience Operators")
		verifyEq(sec.webUrl.frag, "nullConvenience")
		verifyEq(sec.parents[0].title, "Expressions")
		verifyEq(sec.parents[1].title, "docLang")
		
		sec  = safe.first.parents[1]
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Expressions")
		verifyEq(sec.title, "Expressions")
		verifyEq(sec.parents[0].title, "docLang")
	}
	
	Void tellMeAbout(Str keyword) {
		secs := index.tellMeAbout(keyword)
		
		out := secs.join("\n\n" + ("-" * 120) + "\n\n") { it.toPlainText(120) }
		echo(out)
	}
	
}
