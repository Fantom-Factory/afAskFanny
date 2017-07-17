using web
using fandoc::FandocParser
using fandoc::HtmlDocWriter

@NoDoc
internal const class TellMeAboutMod : WebMod {
	private const Str	windowTitle	:= "Ask Fanny"
	private const Str	windowDesc	:= "Ask Fanny - a mini search engine for the Fantom reference documentation; created by Alien-Factory"
	private const Uri	baseUrl
	private const Str?	gaAccountNo
	private const Index	index
	private const Pod	pod
	
	new make(Bool indexAllPods := false) {
		// note there's a config.props on the prod server
		props		:= |->Str:Str| { try return `config.props`.toFile.readProps; catch return [:] }()
		pod			= typeof.pod
		baseUrl		= props.get("baseUrl", 		"http://localhost/").toUri
		gaAccountNo	= props.get("gaAccountNo",	null)
		index 		= IndexBuilder() { if (indexAllPods) it.indexAllPods; else it.indexCorePods }.build
	}
	
	override Void onGet() {
		name := req.modRel.path.first

		if (name == null)
			onIndex
		else if (name == "about")
			onAbout
		else if (name == "doc")
			onPodFile(req.modRel.relTo(`/`))
		else if (name == "web")
			// manually add 'res' to prevent *any* pod resource from being served
			onPodFile(`res/` + req.modRel.relTo(`/`))
		else if (name == "favicon.ico")
			onPodFile(`res/web/${name}`)
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
			out.tag("meta", "property='og:image'       content='${baseUrl}doc/ogimage.png'").nl
			out.tag("meta", "property='og:image:width' content='1200'").nl
			out.tag("meta", "property='og:image:height' content='800'").nl
			out.tag("meta", "property='og:description' content=\"${windowDesc}\"").nl
			out.tag("link", "href='${baseUrl}' rel='canonical'").nl
			out.tag("link", "href='/web/website.min.css' type='text/css' rel='stylesheet'").nl		
			out.tag("link", "href='/favicon.ico' rel='shortcut icon'").nl
		out.headEnd		
		out.body.nl
		renderHeader(out)
		out.div("class='container'")
		
		out.div("class='text-center text-muted blurb'")
			out.i.w("A mini search engine for the Fantom reference documentation").iEnd
		out.divEnd
		
		query	:= req.modRel.query.get("q", "").split.first
		results	:= index.askFanny(query)
		
		renderForm(out, query, results.size)
		
		if (query.size > 0)
			renderResults(out, results)

		renderFooter(out)

		if (query.size > 0) {
			out.script("src='web/jquery-3.2.1.slim.min.js'").scriptEnd
			out.script("src='web/util.js'").scriptEnd
			out.script("src='web/tab.js'").scriptEnd
		}
		
		renderGoogleAnal(out)
		out.divEnd.nl
		out.bodyEnd.nl
		out.htmlEnd.nl
	}

	
	
	Void onAbout() {
		res.headers["Content-Type"] = "text/html; charset=utf-8"

		out := res.out
		out.docType5
		out.tag("html", "lang='en'").nl
		out.head
			out.title.w(windowTitle).titleEnd
			out.tag("meta", "charset='utf-8'").nl
			out.tag("meta", "http-equiv='X-UA-Compatible' content='IE=edge'").nl
			out.tag("meta", "name='viewport'           content='width=device-width, initial-scale=1' id='myViewport'")
			out.tag("link", "href='/web/website.min.css' type='text/css' rel='stylesheet'").nl		
		out.headEnd		
		out.body
		renderHeader(out)
		out.div("class='container'")

		out.h1.w("About").h1End
		out.p.i.w("\"The Fantom documentation is actually pretty good, but it's sometimes hard to find what you're looking for. I hope 'Ask Fanny' changes that.\" - Steve Eynon").iEnd.pEnd

		url := `fan://${typeof.pod}/doc/pod.fandoc`
		str := ((File) url.get).readAllStr
		doc := FandocParser().parse(url.toStr, str.in)
		doc.writeChildren(HtmlDocWriter(out))

		renderFooter(out)
		renderGoogleAnal(out)
		out.divEnd.nl
		out.bodyEnd.nl
		out.htmlEnd.nl
	}



	private Void renderHeader(WebOutStream out) {
		out.nav("class='navbar navbar-expand navbar-dark bg-dark'").nl
			out.div("class='container px-sm-3'").nl
				out.a(`/`, "class='navbar-brand'").img(`web/askFanny-logo.png`, "class='logo' alt='Ask Fanny'").nl.aEnd.nl
				out.div("class='navbar-nav'").nl
					out.a(`/about`, "class='nav-item nav-link'").w("About").aEnd.nl
				out.divEnd.nl
			out.divEnd.nl
		out.navEnd.nl
	}

	private Void renderForm(WebOutStream out, Str q, Int size) {
		out.div("class='row justify-content-md-center'").nl
			out.div("class='col col-sm-12 col-md-9 col-lg-7 col-xl-6'").nl
				out.div("class='d-none d-sm-block float-left m-3'").nl
					out.img(`web/fanny-reading.png`, "alt='Fanny the Fantom reading a book'").nl
				out.divEnd.nl
				out.form("class='my-4 my-sm-6 float-sm-left' method='GET' action='/'").nl
					out.label("for='q'").w("Ask Fanny About:").labelEnd.nl
					out.div("class='input-group'").nl
						out.input("id='q' class='form-control' name='q' type='text' autocomplete='off' value='${q}'").nl
						out.span("class='input-group-btn'").nl
							out.input("class='btn btn-outline-success' type='submit' value='Go!'").nl
						out.spanEnd.nl
					out.divEnd.nl
					if (q.size > 0)
						out.print("<small class='form-text'>").span("class='text-muted'").w("${size} result") { if (size != 1) w("s") }.w(" found for: ").spanEnd.w(q.capitalize).print("</small>")
				out.formEnd.nl
			out.divEnd.nl
		out.divEnd.nl
	}
	
	private Void renderFooter(WebOutStream out) {
		out.nl
		out.hr("class='mb-1'").nl
		out.footer("class='mb-2'").nl
			out.a(`http://fantom-lang.org/`, "class='mr-1' title='Fantom :: The JVM Programming Language'")
				out.w("""<svg xmlns="http://www.w3.org/2000/svg" width="114" height="20"><linearGradient id="shield-b" x2="0" y2="100%"><stop offset="0" stop-color="#bbb" stop-opacity=".1"/><stop offset="1" stop-opacity=".1"/></linearGradient><mask id="shield-a"><rect width="114" height="20" rx="3" fill="#fff"/></mask><g mask="url(#shield-a)"><path fill="#555" d="M0 0h63v20H0z"/><path fill="#9f9f9f" d="M63 0h51v20H63z"/><path fill="url(#shield-b)" d="M0 0h114v20H0z"/></g><g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11"><text x="31.5" y="15" fill="#010101" fill-opacity=".3">written in</text><text x="31.5" y="14">written in</text><text x="87.5" y="15" fill="#010101" fill-opacity=".3">Fantom</text><text x="87.5" y="14">Fantom</text></g></svg>""")
			out.aEnd.nl
			out.a(`http://eggbox.fantomfactory.org/pods/${pod.name}/`, "title='Ask Fanny'")
				out.w("""<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="202" height="20"><linearGradient id="b" x2="0" y2="100%"><stop offset="0" stop-color="#bbb" stop-opacity=".1"/><stop offset="1" stop-opacity=".1"/></linearGradient><clipPath id="a"><rect width="202" height="20" rx="3" fill="#fff"/></clipPath><g clip-path="url(#a)"><path fill="#555" d="M0 0h77v20H0z"/><path fill="#4c1" d="M77 0h125v20H77z"/><path fill="url(#b)" d="M0 0h202v20H0z"/></g><g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11"><text x="38.5" y="15" fill="#010101" fill-opacity=".3">powered by</text><text x="38.5" y="14">powered by</text><text x="138.5" y="15" fill="#010101" fill-opacity=".3">Ask Fanny v${pod.version}</text><text x="138.5" y="14">Ask Fanny v${pod.version}</text></g></svg>""")
			out.aEnd.nl
			out.div("class='float-right text-muted small'").w("Written by ")
				out.a(`http://www.alienfactory.co.uk/`).w("Steve Eynon").aEnd
				out.w(", 2017")
			out.divEnd.nl
		out.footerEnd
	}

	private Void renderResults(WebOutStream out, Section[] sections) {
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
		
		pill := |Int size| {
			clazz := size == 0 ? "badge-secondary" : "badge-success"
			out.span("class='badge badge-pill ${clazz}'").w(size.toStr).spanEnd
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
				docs.each { renderResult(out, it) }
			out.divEnd
			out.div("id='types' class='tab-pane fade' role='tabpanel'")
				types.each { renderResult(out, it) }
			out.divEnd
			out.div("id='slots' class='tab-pane fade' role='tabpanel'")
				slots.each { renderResult(out, it) }
			out.divEnd
		out.divEnd
	}
	
	private Void renderResult(WebOutStream out, Section section) {
		out.nl
		out.div("class='card mt-3 mb-6'")
			out.div("class='card-header text-muted'")
				out.w(section.what + " &rarr; ")
				out.a(section.webUrl).w(section.webUrl).aEnd
			out.divEnd
			out.div("class='card-body'")
		
				mono := |Section s->Str| { s.what != "Documentation" && s.what != "Chapter" ? "monofont " : "" }
				lev  := 0
				section.parents.eachr |parent| {
					out.div("class='card-subtitle ${mono(parent)}ml-${lev}'")
						out.a(parent.webUrl).w(parent.title).aEnd
					out.divEnd
					lev += 2
				}
				out.h4("class='card-title ${mono(section)}ml-${lev++}'")
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
	
	private Void renderGoogleAnal(WebOutStream out) {
		if (gaAccountNo == null) return
		out.script.w(
			"(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
			 (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
			 m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
			 })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
			 ga('create', 'UA-33997125-11', 'auto');
			 ga('send', 'pageview');"
		)
		out.scriptEnd
	}
	
   	** Serve up pod resources.
	private Void onPodFile(Uri path) {
    	file := (File?) `fan://${pod.name}/${path}`.get(null, false)
    	if (file == null || !file.exists) { res.sendErr(404); return }
    	FileWeblet(file).onService
   	}
}