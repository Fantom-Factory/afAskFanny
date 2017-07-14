using build

class Build : BuildPod {
	new make() {
		podName = "afTellMeAbout"
		summary = "Documentation Index for Fantom"
		version = Version("0.0.1")

		depends = [
			"sys          1.0.69 - 1.0",
			"fandoc       1.0.69 - 1.0",
			"compilerDoc  1.0.69 - 1.0",

			"docLang      1.0.69 - 1.0",
		]

		srcDirs = [`fan/`, `fan/internal/`, `test/`]
		resDirs = [,]

		docApi = true
		docSrc = true
	}
}
