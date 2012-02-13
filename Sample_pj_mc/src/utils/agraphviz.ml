open File_handler

module type Viz = sig
  type graph
  type vertex
  type edge

  open Graph.Graphviz

  class type visualizer = object
    method edge :  edge -> DotAttributes.edge list
    method graph : DotAttributes.graph list
    method subgraph : vertex -> DotAttributes.subgraph option
    method vertex : vertex -> DotAttributes.vertex list
    method vertex_name : vertex -> string
  end

  class defaultVisualizer : visualizer
      (** template *)

  val output : File_handler.file -> visualizer -> graph -> unit
      (** output a graph to a graphviz log file using a visualizer *)
end

module Make (G : Graph.Sig.I) = struct 

  type graph = G.t
  type vertex = G.V.t
  type edge = G.E.t

  (* edges *)
  module E = struct
    type t = G.E.t
    let src : t -> G.V.t = G.E.src
    let dst : t -> G.V.t = G.E.dst
    (* FIXME: commented out by DzungDK 
    let hash (v1, v2) = Hashtbl.hash (G.V.hash v1, G.V.hash v2)

    (* edges between the same vertex pairs are considered equal *)
    let equal (v1,v2) (v1',v2') = G.V.equal v1 v1' && G.V.equal v2 v2'
    *)
  end

  (* duh, I use objects. Incredible. *)
  class type visualizer = object
    method vertex_name : G.V.t -> string
    method graph : Graph.Graphviz.DotAttributes.graph list
    method vertex : G.V.t -> Graph.Graphviz.DotAttributes.vertex list
    method edge : E.t -> Graph.Graphviz.DotAttributes.edge list
    method subgraph : G.V.t -> Graph.Graphviz.DotAttributes.subgraph option
  end

  class defaultVisualizer = (object
    method vertex_name _ = "uninitizlized"
    method graph = [`Center true; `Pagedir `TopToBottom]
    method vertex _ = []
    method edge _ = []
    method subgraph _ = None
  end : visualizer)

  let output file visualizer graph =
    (* oh!, modules within let. *)
    let module GViz = struct
      (* FIXME: commented out by DzungDK 
      include G *)
      type t = G.t
      module V = G.V
      module E = E
      let iter_vertex = G.iter_vertex
      let iter_succ = G.iter_succ

      let iter_edges_e f t = 
	iter_vertex (fun src -> iter_succ (fun dst -> 
	                                      begin
					      try let e = G.find_edge t src dst
					      in f e
					      with
					      | Not_found -> assert false
					      end
					  ) t src) t

      let graph_attributes _ = visualizer#graph 

      let default_vertex_attributes _ = []
      let vertex_name v = Printf.sprintf "\"%s\"" (visualizer#vertex_name v)
      let vertex_attributes v = visualizer#vertex v

      let default_edge_attributes _ = [] 

      let edge_attributes e = visualizer#edge e

      let get_subgraph = visualizer#subgraph
    end in
    let module GVizDot = Graph.Graphviz.Dot(GViz) in
    let oc = reopen file in
    GVizDot.output_graph oc graph;
    output_string oc "\n\n";
    close_out oc
end
