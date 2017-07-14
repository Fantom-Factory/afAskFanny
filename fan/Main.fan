using util::Arg
using util::AbstractMain
using util::Opt
using wisp::WispService

@NoDoc
class Main : AbstractMain {

	@Arg { help="The 'thing' you want to know about!" }
	Str what	:= ""
	
	@Opt { help="Width (in characters) to wrap text at"; aliases=["w"] }
	Int width := 80
	
	@Opt { help="Set to launch a web sever to view \"Tell Me About\" in a browser" ; aliases=["web"] }
	Bool webServer	:= true
	
	@Opt { help="Port to run the web server on" }
	Int port := 8069
	
	override Int run() {
		
		if (webServer) {
			echo("Tell Me About website now available on http://localhost:${this.port}/")
			return runServices([WispService {
				it.httpPort = this.port
				it.root = TellMeAboutMod()
			}])			
		}
		
		index := IndexBuilder().indexAllPods.build
		index.tellMeAbout(what).join("\n\n" + "".padl(width, '-')) { it.toPlainText(width) } { echo(it) }
		return 0
	}
	
	override Bool parseArgs(Str[] toks) {
		valid := super.parseArgs(toks)
		if (!valid && webServer)
			return true
		return valid
	}
}
