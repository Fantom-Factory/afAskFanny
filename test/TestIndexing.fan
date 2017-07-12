
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
		
		
		pods := index.tellMeAbout("pod")
		sec  := pods.first
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Structure")
		verifyEq(sec.heading, "Pods")
		verifyEq(sec.anchorId, "pods")
		verifyEq(sec.chapter, Version([2]))

		safe := index.tellMeAbout("safe")
		sec  = safe.first
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Expressions")
		verifyEq(sec.heading, "Safe Invoke")
		verifyEq(sec.anchorId, "safeInvoke")
		verifyEq(sec.chapter, Version("6.2"))
		verifyEq(sec.parents[0].title, "6. Null Convenience Operators")
		verifyEq(sec.parents[1].title, "Expressions")
		verifyEq(sec.parents[2].title, "docLang")
		
		sec  = safe.first.parents[0]
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Expressions")
		verifyEq(sec.heading, "Null Convenience Operators")
		verifyEq(sec.anchorId, "nullConvenience")
		verifyEq(sec.chapter, Version("6"))
		verifyEq(sec.parents[0].title, "Expressions")
		verifyEq(sec.parents[1].title, "docLang")
		
		sec  = safe.first.parents[1]
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Expressions")
		verifyEq(sec.heading, null)
		verifyEq(sec.anchorId, null)
		verifyEq(sec.chapter, null)
		verifyEq(sec.parents[0].title, "docLang")
		
	}
	
	Void tellMeAbout(Str keyword) {
		secs := index.tellMeAbout(keyword)
		
		out := secs.join("\n\n" + ("-" * 120) + "\n\n") { it.toPlainText(120) }
		echo(out)
	}
	
}
