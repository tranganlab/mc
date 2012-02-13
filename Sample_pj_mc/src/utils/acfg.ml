open ConfigUtil
open ConfigUtil.Graph_dot

module V = struct
    type t = Slicingstructure.node
    let compare = compare 
    let equal = (=)
    let hash = Hashtbl.hash
end

module E = struct
    type t = Slicingstructure.edge
    let compare edge1 edge2 = match edge1, edge2 with 
                                | Slicingstructure.Edge (_,_,_,num1), Slicingstructure.Edge(_,_,_,num2) -> compare num1 num2
				| _ -> -1
    let default = Slicingstructure.Edge(Slicingstructure.NodeV("","",Slicingstructure.NODE_OTHER),Slicingstructure.NodeV("","",Slicingstructure.NODE_OTHER),Slicingstructure.OTHER,0)
end


module G = struct
  include Graph.Imperative.Digraph.ConcreteLabeled(V)(E)

  let of_int_list (couple: (Slicingstructure.node list) * (Slicingstructure.edge list )) =  
    let t = create () in
    let vers, edges = couple in
    List.iter (fun v -> add_vertex t v) vers;
    List.iter (fun e -> match e with 
                        | Slicingstructure.Edge(source,dest,ty,num) -> add_edge_e t (source, e, dest)
                        | _ -> ()
              ) edges;
    t
end

module Viz = Agraphviz.Make(G)

let output visualizer couple filename =
  let file = File_handler.open_file filename in
  Viz.output file visualizer (G.of_int_list couple)

let dump_graph_one ?name couple ?filename () = 
    let visualizer = 
      object inherit Viz.defaultVisualizer as super
        method graph = 
  	   match name with
	   | None -> super#graph
	   | Some s -> (`Label s) :: super#graph
	method vertex_name v = (
                           match v with 
                               | Slicingstructure.NodeV(node_name,comment,t) -> node_name 
                               | _ -> assert false
                              )
	(*method vertex block = [] (*[`Comment "hello world!";`Shape(`Circle)] *)
        method edge _ = []*)
        method vertex v = 
	   let new_attributes = 
  	      match v with 
	      | Slicingstructure.NodeV(_,cm,t) -> 
                     match t with 
                       | Slicingstructure.NODE_ASGN -> [`Shape(`Record);`Comment(cm)]
		       | Slicingstructure.NODE_ASGN_V -> [`Shape(`Record);`Comment(cm);`Style(`Dashed)]  
                       | Slicingstructure.NODE_IF -> [`Shape(`Diamond);`Comment(cm)] 
                       | Slicingstructure.NODE_STMT -> [`Shape(`Box);`Comment(cm)] 
                       | Slicingstructure.NODE_GOTO -> [`Shape(`Ellipse);`Comment(cm)] 
                       | Slicingstructure.NODE_LABEL -> [`Shape(`Box);`Comment(cm)] 
                       | Slicingstructure.NODE_OTHER -> [`Shape(`Box);`Comment(cm)] 
                       | _ -> assert false
	      | _ -> assert false
	   in
	   new_attributes @ (super#vertex v)
        method edge ((_,e,_) as ed) = 
           let Slicingstructure.Edge(source,dest,ty,num) = e in
           let label,color = 
	       match ty with
       	       | Slicingstructure.ACFG_TRUE -> "True",0xF00000
       	       | Slicingstructure.ACFG_FALSE -> "False",0xFF0000
       	       | Slicingstructure.CDG -> "CDG",0xFEAB01
       	       | Slicingstructure.DDG -> "DDG",0xF00000
       	       | Slicingstructure.PDT -> "PDT",0xFFFFF0
       	       | Slicingstructure.SDG -> "SDG",0x000000
       	       | Slicingstructure.KOBO -> "",0xF10000
       	       | Slicingstructure.BO -> "bo",0xFB00AA
       	       | Slicingstructure.OTHER -> "Other",0xFFFFFF
       	       | _ -> assert false
           in
           [`Label label;`Color color] @ (super#edge ed) 
            
      end
    in
    let outfile = 
       match filename with
       | None -> "default.dot"
       | Some name -> name
    in
    output visualizer couple outfile

let getlastnode (ls : Slicingstructure.node list) = 
   List.nth ls ((List.length ls) - 1)


let dump_graph listcouple ?source type_graph () =
  let list_func = ref [] in
  let (source_info : Graph_dot.source_info_t) = 
      let name = Sys.getcwd () ^ "/" ^
                 (match source with
                 | Some name -> name
		 | None -> "")
      in
      {
        Graph_dot.path_to_source = name;
        Graph_dot.dot_file = None;
        Graph_dot.functions = [];
      }
   in
   List.iter (fun couple -> let vers , edges = couple in
                            let fver = getlastnode vers in
                            let Slicingstructure.NodeV(fun_name,comment,typ) = fver in
			    if (List.mem fun_name !list_func) = false then
                                begin
				    list_func := (fun_name)::(!list_func);
		                    let filename = Filename.temp_file ("mc_"^fun_name^"_"^type_graph^"_") ".dot"  in
		                    dump_graph_one couple ~filename:filename ();
				    source_info.functions <- 
						source_info.functions @ 
						[{name = fun_name; 
						  path_to_dot = Some filename}];
                                 end
                            
              ) listcouple;
  config.graphs := !(config.graphs) @ [Graph_dot.Graph_per_function (type_graph, [source_info])]

(*   Cac thuoc tinh cua Graphviz 

Graph.Graphviz.DotAttributes.vertex =
    [ `Color of Graph.Graphviz.color
    | `Comment of string
    | `Distortion of float
    | `Fillcolor of Graph.Graphviz.color
    | `Fixedsize of bool
    | `Fontcolor of Graph.Graphviz.color
    | `Fontname of string
    | `Fontsize of int
    | `Height of float
    | `Label of string
    | `Layer of string
    | `Orientation of float
    | `Peripheries of int
    | `Regular of bool
    | `Shape of
        [ `Box
        | `Circle
        | `Diamond
        | `Doublecircle
        | `Ellipse
        | `Plaintext
        | `Polygon of int * float
        | `Record ]
    | `Style of [ `Bold | `Dashed | `Dotted | `Filled | `Invis | `Solid ]
    | `Url of string
    | `Width of float
    | `Z of float ]

*)



