using web

@NoDoc
internal const class TellMeAboutMod : WebMod {

	private const Str	windowTitle	:= "Tell Me About..."
	private const Str	windowDesc	:= "Tell Me About... Fantom - a mini search engine for the Fantom reference documentation; created by Alien-Factory"
	private const Uri	baseUrl
	private const Index	index
	private const Pod	pod
	
	new make(Bool indexAllPods := false) {
		pod		= typeof.pod
		baseUrl	= Env.cur.vars.get("${pod.name}.baseUrl", "http://tellMeAbout.fantom-lang.org/").toUri
		index 	= IndexBuilder() { if (indexAllPods) it.indexAllPods; else it.indexCorePods }.build
	}
	
	override Void onGet() {
		name := req.modRel.path.first
		if (name == null)
			onIndex
		else if (name == "web")
			onPodFile(req.modRel.relTo(`/`))
		else if (name == "favicon.ico")
			onPodFile(`web/${name}`)
		else
			res.sendErr(404)
	}

	Void onIndex() {
		res.headers["Content-Type"] = "text/html; charset=utf-8"

		out := res.out
		out.docType5
		out.tag("html", "lang='en' prefix='og: http://ogp.me/ns#'").nl
		out.head
			out.title.w(windowTitle).titleEnd
			out.tag("meta", "charset='utf-8'").nl
			out.tag("meta", "http-equiv='X-UA-Compatible' content='IE=edge'").nl
			out.tag("meta", "name='viewport'           content='width=device-width, initial-scale=1' id='myViewport'")
			out.tag("meta", "name='description'        content=\"${windowDesc}\"").nl
			out.tag("meta", "property='og:type'        content='website'").nl
			out.tag("meta", "property='og:title'       content='${windowTitle}'").nl
			out.tag("meta", "property='og:url'         content='${baseUrl}'").nl
			//out.tag("meta", "property='og:image'       content='${baseUrl}/pod/${pod.name}/doc/ogimage.png'").nl
			out.tag("meta", "property='og:description' content=\"${windowDesc}\"").nl
			out.tag("link", "href='${baseUrl}' rel='canonical'").nl
			out.tag("link", "href='/web/website.min.css' type='text/css' rel='stylesheet'").nl		
		out.headEnd		
		out.body
				
		out.nav("class='navbar navbar-expand navbar-dark bg-dark'")
			out.div("class='container px-sm-3'")
				out.a(`#`, "class='navbar-brand'").w("Tell Me About...").aEnd
				out.div("class='navbar-nav'")
					out.a(`#`, "class='nav-item nav-link'").w("Tell Me").aEnd
					out.a(`#`, "class='nav-item nav-link'").w("About").aEnd
				out.divEnd
			out.divEnd
		out.navEnd

		out.div("class='container'")
		
		out.div("class='text-center text-muted blurb'")
			out.i.w("A mini search engine for the Fantom reference documentation").iEnd
		out.divEnd
		
		q := req.modRel.query["q"] ?: ""
		out.form("class='form-inline my-6' method='GET' action='/'")
			out.label("for='q' class='mr-2'").w("Tell Me About:").labelEnd
			out.input("id='q' class='form-control mr-2' name='q' type='text' autocomplete='off' value='${q}'")
			out.input("class='btn btn-outline-success' type='submit' value='Go!'")
		out.formEnd
		
		if (req.modRel.query.containsKey("q"))
			writeResults(out)


//			out.script.w("(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
//			              (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
//			              m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
//			              })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
//			              ga('create', 'UA-33997125-11', 'auto');
//			              ga('send', 'pageview');")
//			out.scriptEnd

//			out.script.w("window.twttr = (function(d, s, id) {
//			                var js, fjs = d.getElementsByTagName(s)[0], t = window.twttr || {};
//			                if (d.getElementById(id)) return t;
//			                js = d.createElement(s);
//			                js.id = id;
//			                js.src = 'https://platform.twitter.com/widgets.js';
//			                fjs.parentNode.insertBefore(js, fjs);
//			                t._e = [];
//			                t.ready = function(f) { t._e.push(f); };
//			                return t;
//			              }(document, 'script', 'twitter-wjs'));")
//			out.scriptEnd

		out.hr("class='mb-1'")
		out.footer("class='mb-2'")
			out.a(`http://fantom-lang.org/`, "class='mr-1' title='Fantom :: The JVM Programming Language'")
				out.w("""<svg xmlns="http://www.w3.org/2000/svg" width="114" height="20"><linearGradient id="shield-b" x2="0" y2="100%"><stop offset="0" stop-color="#bbb" stop-opacity=".1"/><stop offset="1" stop-opacity=".1"/></linearGradient><mask id="shield-a"><rect width="114" height="20" rx="3" fill="#fff"/></mask><g mask="url(#shield-a)"><path fill="#555" d="M0 0h63v20H0z"/><path fill="#9f9f9f" d="M63 0h51v20H63z"/><path fill="url(#shield-b)" d="M0 0h114v20H0z"/></g><g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11"><text x="31.5" y="15" fill="#010101" fill-opacity=".3">written in</text><text x="31.5" y="14">written in</text><text x="87.5" y="15" fill="#010101" fill-opacity=".3">Fantom</text><text x="87.5" y="14">Fantom</text></g></svg>""")
			out.aEnd
			out.a(`http://eggbox.fantomfactory.org/pods/${pod.name}/`, "title='Tell Me More'")
				out.w("""<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="202" height="20"><linearGradient id="b" x2="0" y2="100%"><stop offset="0" stop-color="#bbb" stop-opacity=".1"/><stop offset="1" stop-opacity=".1"/></linearGradient><clipPath id="a"><rect width="202" height="20" rx="3" fill="#fff"/></clipPath><g clip-path="url(#a)"><path fill="#555" d="M0 0h77v20H0z"/><path fill="#4c1" d="M77 0h125v20H77z"/><path fill="url(#b)" d="M0 0h202v20H0z"/></g><g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11"><text x="38.5" y="15" fill="#010101" fill-opacity=".3">powered by</text><text x="38.5" y="14">powered by</text><text x="138.5" y="15" fill="#010101" fill-opacity=".3">Tell Me About v${pod.version}</text><text x="138.5" y="14">Tell Me About v${pod.version}</text></g></svg>""")
			out.aEnd
			out.div("class='float-right text-muted small'").w("Written by ")
				out.a(`http://www.alienfactory.co.uk/`).w("Steve Eynon").aEnd
				out.w(", 2017")
			out.divEnd
			
			out.script.w(`fan://${typeof.pod}/res/web/jquery-3.2.1.min.js`.get->readAllStr).scriptEnd
			out.script.w(`fan://${typeof.pod}/res/web/tab.js`.get->readAllStr).scriptEnd
			out.script.w(`fan://${typeof.pod}/res/web/util.js`.get->readAllStr).scriptEnd
		out.footerEnd
		
		out.divEnd
		out.bodyEnd
		out.htmlEnd
	}

	private Void writeResults(WebOutStream out) {
		q		 := req.modRel.query["q"].split.first
		sections := index.askFanny(q)
	
		docs	:= Section[,]
		types	:= Section[,]
		slots	:= Section[,]
		
		sections.each |section| {
			switch (section.what) {
				case "Field":
				case "Method":
					slots.add(section)
				case "Type":
					types.add(section)
				default:
					docs.add(section)
			}
		}
		
		if (sections.size == 1)
			out.p.span("class='text-muted'").w("${sections.size} result found for: ").spanEnd.w(q.capitalize).pEnd
		else
			out.p.span("class='text-muted'").w("${sections.size} results found for: ").spanEnd.w(q.capitalize).pEnd
		
		pill := |Int size| {
			if (size == 0)
				out.span("class='badge badge-pill badge-secondary'").w(size.toStr).spanEnd
			else
				out.span("class='badge badge-pill badge-success'").w(size.toStr).spanEnd
		}
		out.ul("class='nav nav-tabs' role='tablist'")
			out.li("class='nav-item'")
				out.a(`#docs`, "class='nav-link active' data-toggle='tab' role='tab'").w("Documentation ") { pill(docs.size) }.aEnd
			out.liEnd
			out.li("class='nav-item'")
				out.a(`#types`, "class='nav-link' data-toggle='tab' role='tab'").w("Types ") { pill(types.size) }.aEnd
			out.liEnd
			out.li("class='nav-item'")
				out.a(`#slots`, "class='nav-link' data-toggle='tab' role='tab'").w("Slots ") { pill(slots.size) }.aEnd
			out.liEnd
		out.ulEnd
		
		out.div("class='tab-content'")
			out.div("id='docs' class='tab-pane fade active show' role='tabpanel'")
				docs.each { writeCard(out, it) }
			out.divEnd
			out.div("id='types' class='tab-pane fade' role='tabpanel'")
				types.each { writeCard(out, it) }
			out.divEnd
			out.div("id='slots' class='tab-pane fade' role='tabpanel'")
				slots.each { writeCard(out, it) }
			out.divEnd
		out.divEnd
	}
	
	private Void writeCard(WebOutStream out, Section section) {
		out.nl
		out.div("class='card mt-3 mb-6'")
			out.div("class='card-header text-muted'")
				out.w(section.what + " &rarr; ")
				out.a(section.webUrl).w(section.webUrl).aEnd
			out.divEnd
			out.div("class='card-body'")
		
				lev := 0
				section.parents.eachr |parent| {
					out.div("class='card-subtitle ml-${lev}'")
						out.a(parent.webUrl).w(parent.title).aEnd
					out.divEnd
					lev += 2
				}
				out.h4("class='card-title ml-${lev++}'")
					out.a(section.webUrl).w(section.title).aEnd
				out.h4End
		
				out.div("class='result'")
					out.print(section.contentAsHtml)
				out.divEnd
			out.divEnd
//			out.div("class='card-footer'")
//				out.a(section.webUrl).w(section.webUrl).aEnd
//			out.divEnd
		out.divEnd.nl		
	}
	
   	** Serve up pod resources.
	private Void onPodFile(Uri path) {
    	file := (File?) `fan://${pod.name}/res/${path}`.get(null, false)
    	if (file == null || !file.exists) { res.sendErr(404); return }
    	FileWeblet(file).onService
   	}
}