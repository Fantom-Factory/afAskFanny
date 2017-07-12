
class Main {
	Void main() {
		tellMeAbout := "pods"
		
		index := IndexBuilder().indexAll.buildIndex
		index.tellMeAbout(tellMeAbout).join("\n\n" + "".padl(120, '-')) { it.toPlainText(120) } { echo(it) }
	}
}
