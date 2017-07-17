
internal class TestIndexing : Test {
	
	Index? index
	
	Void testStuff() {
		
		index = IndexBuilder()
			.indexPod("docLang")
			.indexPod("sys")
			.indexPod("fandoc")
			.build
		
		
		
		tellMeAbout("pod")
//		tellMeAbout("comment")
//		tellMeAbout("map")
		tellMeAbout("safe") //-> 2.6
		
		
		pods := index.askFanny("pod")
		sec  := pods[0]
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Pods")
		verifyEq(sec.title, "8. Pods")
		// check that Overview content is merged with parent
		verifyEq(sec.content.startsWith("Pods are the top of Fantom's namespace as well as the unit of deployment."), true)

		sec  = pods[1]
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Structure")
		verifyEq(sec.title, "1.2. Pods")
		verifyEq(sec.fanUrl, "docLang::Structure#pods")

		sec  = pods[2]
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Pods")
		verifyEq(sec.title, "8.2. Pod Meta")
		verifyEq(sec.fanUrl, "docLang::Pods#meta")

		sec  = pods[3]
		verifyEq(sec.pod, "sys")
		verifyEq(sec.type, "Pod")
		verifyEq(sec.title, "sys::Pod")

		sec  = pods[4]
		verifyEq(sec.pod, "sys")
		verifyEq(sec.type, "Type")
		verifyEq(sec.title, "sys::Type.pod()")

		
		
		safe := index.askFanny("safe")
		sec  = safe.first
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Expressions")
		verifyEq(sec.title, "3.6.2. Safe Invoke")
		verifyEq(sec.fanUrl, "docLang::Expressions#safeInvoke")
		verifyEq(sec.parents[0].title, "3.6. Null Convenience Operators")
		verifyEq(sec.parents[1].title, "3. Expressions")
		verifyEq(sec.parents[2].title, "docLang")
		
		sec  = safe.first.parents[0]
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Expressions")
		verifyEq(sec.title, "3.6. Null Convenience Operators")
		verifyEq(sec.fanUrl, "docLang::Expressions#nullConvenience")
		verifyEq(sec.parents[0].title, "3. Expressions")
		verifyEq(sec.parents[1].title, "docLang")
		
		sec  = safe.first.parents[1]
		verifyEq(sec.pod, "docLang")
		verifyEq(sec.type, "Expressions")
		verifyEq(sec.title, "3. Expressions")
		verifyEq(sec.parents[0].title, "docLang")
		
		
		
		fandoc := index.askFanny("fandoc")
		sec  = fandoc[0]
		verifyEq(sec.pod, "fandoc")
		verifyEq(sec.type, null)
		verifyEq(sec.title, "fandoc")
		verifyEq(sec.fanUrl, "fandoc::index#overview")
		verifyEq(sec.parents.size, 0)
		// check summary AND overview are picked up
		verifyEq(sec.content.startsWith("Fandoc parser and DOM\n\nFandoc is documentation format"), true)

		sec  = fandoc[1]
		verifyEq(sec.pod, "fandoc")
		verifyEq(sec.type, "index")
		verifyEq(sec.title, "2.3. Fandoc API")
		verifyEq(sec.fanUrl, "fandoc::index#api")
		verifyEq(sec.parents[0].title, "2. Ex Heading 1")
		verifyEq(sec.parents[1].title, "fandoc")
	}
	
	Void tellMeAbout(Str keyword) {
		secs := index.askFanny(keyword)
	}
}
