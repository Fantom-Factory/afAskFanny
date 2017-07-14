
@NoDoc
class Main {
	Void main(Str[] args) {
		tellMeAbout := args.first
		
		index := IndexBuilder().indexAllPods.build
		index.tellMeAbout(tellMeAbout).join("\n\n" + "".padl(120, '-')) { it.toPlainText(120) } { echo(it) }
	}
}
