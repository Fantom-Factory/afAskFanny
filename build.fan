using build

class Build : BuildPod {
	new make() {
		podName = "afAskFanny"
		summary = "Documentation Index for Fantom"
		version = Version("0.0.1")

		depends = [
			"sys          1.0.69 - 1.0",
			"fandoc       1.0.69 - 1.0",
			"compilerDoc  1.0.69 - 1.0",
			
			// ---- web ----
			"web          1.0.69 - 1.0",
			"wisp         1.0.69 - 1.0",
			"util         1.0.69 - 1.0",
		]

		srcDirs = [`fan/`, `fan/internal/`, `test/`]
		resDirs = [`doc/`, `res/web/`]

		docApi = true
		docSrc = true
	}
}
