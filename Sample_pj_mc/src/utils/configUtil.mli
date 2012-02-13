(*module Log : 
  sig
    (*val log_level : Logging.facility ref
    val set_new_log_level : Logging.facility -> unit
    val log : Logging.facility -> string -> unit*)
    val debug : string -> unit
    val info : string -> unit
    val notice : string -> unit
    val warn : string -> unit
    val error : string -> unit
    val crit : string -> unit
    val alert : string -> unit
    val emerg : string -> unit
    val init : unit -> unit
    val close : unit -> unit
  end
*)
module Graph_dot : sig
  type function_info_t = {
       name: string;
       path_to_dot: string option;
  }     

  type source_info_t = {
       path_to_source: string;
       dot_file: string option;
       mutable functions: function_info_t list;
  }

  type dot_info_t = {
       path: string;
       relevant_source_files: string list; (* file names *)
  }

  type graph_info_t = 
       | Graph_per_function of string * source_info_t list
       | Graph_per_project of string * dot_info_t list
end       

type config_t = {
   log_file : string;
   graphs : (Graph_dot.graph_info_t list) ref;
}

val config : config_t 
(*
type message_t = (*Logging.facility **) string
exception Message of message_t

val export_configuration : ?config_file_name:string -> unit -> unit 
*)