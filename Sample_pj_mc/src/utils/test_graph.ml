module V = struct
    type t = int
    let compare = compare 
    let equal = (=)
    let hash = Hashtbl.hash
end

module E = struct
    type t = int
    let compare = compare
    let default = 0
end


module G = struct
  include Graph.Imperative.Digraph.ConcreteLabeled(V)(E)

  let of_int_list ls =  
    let t = create () in
    List.iter (fun (i,j) -> 
                     add_vertex t i;
		     add_vertex t j;
		     add_edge t i j) ls;
    t
end

module Viz = Agraphviz.Make(G)

let output visualizer fundef filename =
  let file = File_handler.open_file filename in
  Viz.output file visualizer (G.of_int_list fundef)

let dump_graph ?name fundef ?filename () = 
    let visualizer = 
      object inherit Viz.defaultVisualizer as super
        method graph = 
  	   match name with
	   | None -> super#graph
	   | Some s -> (`Label s) :: super#graph
	method vertex_name i = (string_of_int i)^"abc"
	method vertex block = [`Comment "hello world!";`Shape(`Circle)] 
        method edge _ = []
      end
    in
    let outfile = 
       match filename with
       | None -> "default.dot"
       | Some name -> name
    in
    output visualizer fundef outfile
 
let test_dumper () = 
   let ls = [(2,3);(1,5);(5,6); (1,2); (1,5); (2,6); (3,5)]
   in
   dump_graph ~filename:"graph.dot" ls ()

module MyDfs = Graph.Traverse.Dfs(G)
module MyBfs = Graph.Traverse.Bfs(G)

let visit i = print_string ((string_of_int i) ^ "\n")

let test_graph_traversal () = 
   let ls = [(2,3);(1,5);(5,6); (1,2); (1,5); (2,6); (3,5)] in
   let g = G.of_int_list ls in
   print_string "depth-first search: \n";
   MyDfs.iter ~pre:visit g;
   print_string "breadth-first search: \n";
   MyBfs.iter visit g;
   print_string "iter vertex \n";
   G.iter_vertex visit g
