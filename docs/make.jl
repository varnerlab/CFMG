using Documenter
using CFMG

makedocs(
    sitename = "CFMG",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true"
    ),
    modules = [CFMG],
    pages = [
    "Home" => "index.md",
    "Introduction" => "introduction.md",
    "Installation" => "installation.md",
    "VFF format" => "vffformat.md",
    "Examples" => "example.md",
    ],
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/varnerlab/CFMG.git",
    devurl = "stable",
)
