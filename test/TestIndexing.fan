
internal class TestIndexing : Test {
	
	Index? index
	
	Void testStuff() {
		
		index = IndexBuilder()
			.indexDocPod("docLang")
			.buildIndex
		
		
		
		tellMeAbout("pod")
//		tellMeAbout("comment")
//		tellMeAbout("map")
		tellMeAbout("safe") //-> 2.6
		
		
		secs := index.tellMeAbout("pod")
		sec := secs.first
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Structure")
		verifyEq(sec.heading, "Pods")
		verifyEq(sec.anchorId, "pods")
		verifyEq(sec.chapter, Version([2]))

		secs = index.tellMeAbout("safe")
		sec  = secs.first.parents.first
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Expressions")
		verifyEq(sec.heading, "Null Convenience Operators")
		verifyEq(sec.anchorId, "nullConvenience")
		verifyEq(sec.chapter, Version("6"))
		sec  = secs.first
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Expressions")
		verifyEq(sec.heading, "Safe Invoke")
		verifyEq(sec.anchorId, "safeInvoke")
		verifyEq(sec.chapter, Version("6.2"))
		
		
		
	}
	
	Void tellMeAbout(Str keyword) {
		secs := index.tellMeAbout(keyword)
		
		out := secs.join("\n\n" + ("-" * 120) + "\n\n") { it.toPlainText(120) }
		echo(out)
	}
	
}
