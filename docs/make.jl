using Documenter
using CFMG

makedocs(
    sitename = "CFMG",
    format = Documenter.HTML(),
    modules = [CFMG]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/varnerlab/CFMG.git"
)
