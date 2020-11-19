var documenterSearchIndex = {"docs":
[{"location":"vffformat/#VFF-format","page":"VFF format","title":"VFF format","text":"","category":"section"},{"location":"vffformat/","page":"VFF format","title":"VFF format","text":"VFF format is designed to be the standard input format of CFMG.jl. Aside from comments marked by preceding two slashes '//', each VFF file contains three parts: TXTL-SEQUENCE, metabolism, and gene regulatory network. Each part has its start and end marks, and specific syntactic format for describing biological information.","category":"page"},{"location":"vffformat/#TXTL-SEQUENCE","page":"VFF format","title":"TXTL-SEQUENCE","text":"","category":"section"},{"location":"vffformat/","page":"VFF format","title":"VFF format","text":"Item Description\nStart #TXTL-SEQUENCE::START\nEnd #TXTL-SEQUENCE::STOP\nFormat {X|L},{symbol1},{symbol2}::sequence;\n{X|L} 'X' denotes transcription, while 'L' denoting translation\n{symbol1} gene or protein symbol\n{symbol2} 'RX' or 'RL' denoting RNAP_symbol or Ribosome_symbol, respectively\n{sequence} gene or protein sequence\nExample {X,cI_ssrA,RX::atgagcacaaaaaagaaaccattaacacaagagcagcttgaggacgcacgtcgccttaaagc;} {L,cI_ssrA,RL::MSTKKKPLTQEQLEDARRLKAIYEKKKNELGLSQESVADKMGMGQS;}","category":"page"},{"location":"vffformat/#METABOLISM","page":"VFF format","title":"METABOLISM","text":"","category":"section"},{"location":"vffformat/","page":"VFF format","title":"VFF format","text":"Item Description\nStart #METABOLISM::START\nEnd #METABOLISM::STOP\nFormat {name, [ECs],reactant,product,is_reversible}\nname unique string denoting reaction name\nECs ';' delimited set of ec numbers, use '[]' if no EC\nreactant reactant symbols connected by '+', metabolite symbols can not have special chars or spaces, stochiometric coefficients are pre-pended to metabolite symbol\nproduct product symbols connected by '+', metabolite symbols can not have special chars or spaces, stochiometric coefficients are pre-pended to metabolite symbol\nis_reversible true|false\nExample {R_A_syn_2,[6.3.4.13],M_atp_c+M_5pbdra+M_gly_L_c,M_adp_c+M_pi_c+M_gar_c,false}<br /> {R_adhE,[1.2.1.10;1.1.1.1],M_accoa_c+2M_h_c+2M_nadh_c,M_etoh_c+2*M_nad_c,true}<br /> {M_h2s_c_exchange,[],[],M_h2s_c,true}","category":"page"},{"location":"vffformat/#Gene-regulatory-network","page":"VFF format","title":"Gene regulatory network","text":"","category":"section"},{"location":"vffformat/","page":"VFF format","title":"VFF format","text":"Item Description\nStart #GRN::START\nEnd #GRN::STOP\nFormat actors action target\nactors comma ',' delimited list of actors\naction activate, activates, activated, induce, induces, induced, inhibit, inhibits, inhibited, repress, represses, represses\ntarget the target\nExample {cI_ssrA inhibits deGFP_ssrA}<br /> {s70 activates deGFP_ssrA}","category":"page"},{"location":"examples/example1/#example-1","page":"Example 1","title":"example 1","text":"","category":"section"},{"location":"installation/#Installation-and-Requirements","page":"Installation","title":"Installation and Requirements","text":"","category":"section"},{"location":"installation/","page":"Installation","title":"Installation","text":"CFMGjl is organized as a Julia package which  can be installed in the package mode of Julia.","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"Start of the Julia REPL and enter the package mode using the  key (to get back press the backspace or ^C keys). Then, at the prompt enter:","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"(v1.1) pkg> add https://github.com/varnerlab/CFMG.git","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"This will install the CFMGjl package and the other required packages. CFMGjl requires Julia 1.5.x and above.","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"CFMGjl is open source, available under a MIT software license. You can download this repository as a zip file, clone or pull it by using the command (from the command-line):","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"$ git pull https://github.com/varnerlab/CFMG.git","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"or","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"$ git clone https://github.com/varnerlab/CFMG.git","category":"page"},{"location":"#CFMG.jl-Documentation","page":"Home","title":"CFMG.jl Documentation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"#Index","page":"Home","title":"Index","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"}]
}
