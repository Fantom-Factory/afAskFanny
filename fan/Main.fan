using util::Arg
using util::AbstractMain
using util::Opt
using wisp::WispService

@NoDoc
class Main : AbstractMain {

	@Arg { help="Want to know about!" }
	Str what := ""
	
	@Opt { help="Indexes ALL pods in current Fantom installation, not just the core pods" }
	Bool all := false
	
	@Opt { help="Width (in characters) to wrap text at" }
	Int width := 80
	
	@Opt { help="Set to launch a web sever to view \"Ask Fanny\" in a browser" }
	Bool webserver
	
	@Opt { help="Port to run the web server on" }
	Int port := 8069
	
	override Int run() {
		if (webserver) {
			echo("Tell Me About website now available on: http://localhost:${this.port}/")
			return runServices([WispService {
				it.httpPort = this.port
				it.root = AskFannyWebMod(all)
			}])			
		}
		
		index   := IndexBuilder() { if (all) it.indexAllPods; else it.indexCorePods }.build
		results := index.askFanny(what)
		dashes  := "".padl(width, '-')

		echo("${results.size} results found for: ${what.capitalize}\n")
		if (results.size > 0) {
			output := results.join("\n\n" + dashes) { it.toPlainText(width) }
			echo(dashes + output)
		}
		
		didYouMean := index.didYouMean(what)
		if (didYouMean.size > 0) {
			if (results.size > 0) {
				echo(dashes)
				echo
			}
			echo("Did you mean: " + didYouMean.join(", ") + "?")
		}
		
		return 0
	}
	
	override Bool parseArgs(Str[] toks) {
		valid := super.parseArgs(toks)
		if (!valid && webserver)
			return true
		return valid
	}
}
