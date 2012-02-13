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

module Make(G : Graph.Sig.I) : Viz
with type graph = G.t 
with type vertex = G.V.t
with type edge = G.E.t

