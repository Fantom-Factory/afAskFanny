using web

@NoDoc
const class TellMeAboutMod : WebMod {

	private const Str	windowTitle	:= "Tell Me About..."
	private const Str	windowDesc	:= "Tell Me About... Fantom - a mini search engine for the Fantom reference documentation; created by Alien-Factory"
	
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
		onIndexPage(res.out, req.absUri)
	}

	Void onIndexPage(WebOutStream out, Uri reqAbsUri) {
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
			out.tag("meta", "property='og:url'         content='http://fanny.fantomfactory.org/'").nl
			//out.tag("meta", "property='og:image'       content='http://fanny.fantomfactory.org/pod/afFannyTheFantom/doc/ogimage.png'").nl
			out.tag("meta", "property='og:description' content=\"${windowDesc}\"").nl
			out.tag("link", "href='http://fanny.fantomfactory.org/' rel='canonical'").nl
			out.tag("link", "href='/web/website.min.css' type='text/css' rel='stylesheet'").nl		
		out.headEnd		
		out.body
		
		out.h1.w("Tell Me About...").h1End

		
		


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

		out.bodyEnd
		out.htmlEnd
	}

   	** Serve up pod resources.
	Void onPodFile(Uri path) {
		echo(`fan://afTellMeAbout/res/${path}`)
    	file := (File?) `fan://afTellMeAbout/res/${path}`.get(null, false)
    	if (file == null || !file.exists) { res.sendErr(404); return }
    	FileWeblet(file).onService
   	}
}