using Documenter, CFMG

makedocs(
	doctest = false,
  modules = [CFMG],
	sitename = "CFMG.jl",
	format =:html,
	pages = [
		"Home" => "index.md",
		"installation.md",
		"Examples" => Any[
			"Example 1" => "examples/example1.md",
		]
	],
	# format = Documenter.HTML(prettyurls = get(ENV, "JULIA_NO_LOCAL_PRETTY_URLS", nothing) === nothing)
)

deploydocs(
    repo = "https://github.com/varnerlab/CFMG.git",
)
