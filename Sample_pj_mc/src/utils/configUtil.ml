open Xml

(*
    Module Graph_dot
*) 
module Graph_dot = struct
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
       
   let xml_of_function_info (func: function_info_t) =
       let attrs = [("name", func.name)] in
       let attrs = match func.path_to_dot with
                   | None -> attrs
   	  	   | Some path -> attrs @ [("pathToDot", path)]
       in Element ("function", attrs, [])

   let xml_of_source_info (source: source_info_t) =
       let attrs = [("pathToSource", source.path_to_source)] in
       let attrs = match source.dot_file with
                   | None -> attrs
  	  	   | Some path -> attrs @ [("pathToDot", path)]
       in 
       let children = 
           List.map xml_of_function_info source.functions 
       in Element ("source", attrs, children)

   let xml_of_dot_info (dot_info: dot_info_t) = 
       let attrs = [("pathToDot", dot_info.path)] in
       let children = 
           List.map (fun source -> 
     	              Element ("source", [("pathToSource", source)], []))
	 	    dot_info.relevant_source_files 
       in Element ("dot", attrs, children)
   
   let xml_of_graph_info (graph: graph_info_t) =
       match graph with
       | Graph_per_function (name, sources) ->
           let attrs = [("name", name); ("type", "1")] in
  	   (* assuring there is at least one source *)
  	   assert ((List.length sources) > 0); 
           let children = List.map xml_of_source_info sources in
           Element ("graph", attrs, children)
       | Graph_per_project (name, dots) ->
           let attrs = [("name", name); ("type", "2")] in
  	   (* assuring there is at least one dot file *)
   	   assert ((List.length dots) > 0); 
           let children = List.map xml_of_dot_info dots in
           Element ("graph", attrs, children)
       | _ -> assert false
end       

(*
 *  config
 *)

type config_t = {
   log_file : string;
   graphs : (Graph_dot.graph_info_t list) ref;
}

let config = {
   log_file =  Filename.temp_file "mc_debug_" ".dat";
   graphs = ref [];
}


(* 
 * Module MyLogger: for logging
 *)

(*open Logging*)

(*module DefaultLogger : LOGGER = struct
    let debug_file = Unix.openfile config.log_file 
	               [Unix.O_CREAT; Unix.O_APPEND; Unix.O_WRONLY] 0o644
    external write_log_message: 
         Unix.file_descr -> string -> facility -> string -> unit 
	 = "write_log_message"
    let outputs = [
      (Error,(write_log_message Unix.stderr "%m/%d/%Y %H:%M:%S %z"));
      (Warn,(write_log_message Unix.stdout "%m/%d/%Y %H:%M:%S %z"));
      (Info,(write_log_message Unix.stdout "%m/%d/%Y %H:%M:%S %z"));
      (Debug,(write_log_message debug_file "%m/%d/%Y %H:%M:%S %z"));
    ]
    let default_log_level = Info
    let init () = ()
    let shutdown () = try
      Unix.close debug_file
    with (Unix.Unix_error (Unix.EBADF,"close","")) -> ()
  end;;

module Log = Make(DefaultLogger);;*)

(*
 * Exception
 *)

(*type message_t = Logging.facility * string*)
(*exception Message of message_t;;*)

(* 
 *  export_configuration
 *)

(*let export_configuration ?config_file_name () = 
    let filename = match config_file_name with
                   | Some name -> name
		   | None -> "result.xml"
    in
    let file = File_handler.open_file filename in
    let oc = File_handler.reopen file in
    let xml_graphs = Element ("graphs", [], 
                              (List.map Graph_dot.xml_of_graph_info 
			                !(config.graphs))) 
    in
    let xml_logfile = Element ("log", 
                               [("pathToLog",config.log_file)], 
			       []) in
    let xml_result = Element ("project", [], [xml_logfile;xml_graphs]) in
    let str = to_string_fmt xml_result in
    output_string oc str;
    output_string oc "\n\n";
    close_out oc
*)