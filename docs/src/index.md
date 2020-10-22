# index?
![CI](https://github.com/varnerlab/CFMG/workflows/CI/badge.svg?branch=master)

## Cell Free Model Generator in Julia (CFMG)

### Installation and Requirements
``CFMG.jl`` is organized as a [Julia](http://julialang.org) package which
can be installed in the ``package mode`` of Julia.

Start of the [Julia REPL](https://docs.julialang.org/en/v1/stdlib/REPL/index.html) and enter the ``package mode`` using the ``]`` key (to get back press the ``backspace`` or ``^C`` keys). Then, at the prompt enter:

    (v1.1) pkg> add https://github.com/varnerlab/CFMG.git

This will install the ``CFMG.jl`` package and the other required packages.
``CFMG.jl`` requires Julia 1.5.x and above.

``CFMG.jl`` is open source, available under a [MIT software license](https://github.com/varnerlab/JuCFMG/blob/master/LICENSE).
You can download this repository as a zip file, clone or pull it by using the command (from the command-line):

	$ git pull https://github.com/varnerlab/CFMG.git

or

	$ git clone https://github.com/varnerlab/CFMG.git

### How do I generate model code?
To generate cell free model code, first load the ``JuCFMG`` package, then generate a default project, add content to the ``Network.vff`` model file (and optionally update ``Default.toml`` with your values), and then generate code using the ``make_*_model`` family of commands.
To generate a default project structure, use the commands:

    julia> using CFMG
    julia> generate_default_project(<path to project dir>)

The ``generate_default_project`` command writes a blank  ``Network.vff`` model file, and a ``Defaults.toml`` file to the user specified path.
If a directory already exists at the user specified location, it is backed-up before new code is written. After you have generated a default project structure,
add content to the ``Network.vff`` model file. Lastly, issue the command ``make_*_model`` from the REPL:

    julia> using CFMG
    julia> make_julia_model(<path to model file>, <path where files will be written>)

In addition to [Julia](http://julialang.org), you can generate cell free model code for the [Octave](https://www.gnu.org/software/octave/), [Python 3.x](https://www.python.org) and [COBRA package in MATLAB](https://opencobra.github.io/cobratoolbox/stable/) environments. In these cases, issue the language specific commands, ``make_octave_model``, ``make_python_model`` or ``make_matlab_model``. The [MATLAB/COBRA](https://opencobra.github.io/cobratoolbox/stable/) command ``make_matlab_model`` generates a COBRA-compatible [MATLAB MAT-file](https://www.mathworks.com/help/matlab/import_export/mat-file-versions.html) while the other commands generate fully editable source code.

### Are there other packages required to run the model code?
There are several other packages that are required to run the model. However, these should be installed automagically the first time you run your code.
The linear programming problem is solved using the [GLPK solver](https://en.wikipedia.org/wiki/GNU_Linear_Programming_Kit), which is freely available for a
variety of platforms.


### How is the model file structured?
``CFMG.jl`` transforms a structured text file into cell free model code. ``CFMG.jl`` text files consist of delimited record types organized into
four sections ``TXTL-SEQUENCE``, ``METABOLISM``, ``GRN`` and ``PARAMETERS``.

#### METABOLISM records
``METABOLISM`` records are used to encode metabolic reactions. ``METABOLISM`` records consist of five fields.

	reaction_name (unique), [{; delimited set of ec numbers | []}],reactant_string,product_string, reversible

#### TXTL-SEQUENCE records
``TXTL-SEQUENCE`` records are used to generate sequence specific transcription and translation reactions which are appended to the end of the metabolic reactions
encoded in the ``METABOLISM`` section. ``TXTL-SEQUENCE`` records take the form:

    {X|L},{gene_symbol|protein_symbol},{RNAP_symbol|Ribosome_symbol}::sequence;

where:

* {X|L}: record type identifier takes on values of either X or L. X denotes a transcription record, while L denotes a translation record.
* {gene_symbol|protein_symbol}: species symbol used in the model. The species symbol is a user specified identifier that is used in the model. No spaces or special chars, ``_`` are acceptable, but ``+``,``-`` etc are not acceptable.
* {RNAP_symbol|Ribosome_symbol}: RNA polymerase or Ribosome symbol. User specified symbol for the RNA polymerase (``X`` record) or Ribosome (``L`` record).  No spaces or special chars, ``_`` are acceptable, but ``+``,``-`` etc are not acceptable.
* sequence: nucleotide (``X`` record) or protein (``L``) sequence in plain format.

``TXTL-SEQUENCE`` records are terminated by a ``;`` character.

#### GRN records
Record structure documented here.
