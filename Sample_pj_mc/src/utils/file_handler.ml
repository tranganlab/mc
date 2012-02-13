(* input-output file handling *)

type file = { name : string; mutable created : bool }

let open_file name = { name= name; created= false }

let open_file = 
  let files = Hashtbl.create 17 in
  fun name -> 
    try
      Hashtbl.find files name 
    with
    | Not_found ->
	let file = open_file name in
	Hashtbl.replace files name file;
	file

let reopen file = 
  let oc = 
    open_out_gen 
      (match file.created with
       | false -> [Open_wronly; Open_trunc; Open_creat] (* first open *) 
       | true  -> [Open_wronly; Open_append; Open_creat] (* append *))     
      0o666
      file.name
  in
  file.created <- true;
  oc


