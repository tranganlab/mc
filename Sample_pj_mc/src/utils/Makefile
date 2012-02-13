OCAMLMAKEFILE := ../OCamlMakefile

SOURCES := file_handler.ml \
            logicUtil.mli logicUtil.ml \
            configUtil.mli configUtil.ml agraphviz.mli agraphviz.ml \
                         
RESULT := packed_lib

INCDIRS := ../parser ../la ../../csisat-1.2/obj 

PACKS := ocamlgraph xml-light

all: byte-code-library

-include $(OCAMLMAKEFILE)
