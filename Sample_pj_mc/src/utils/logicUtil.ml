(* Written by DzungDK@ANLAB Vietnam
   Copyright (C) 2008 Yonezawa Lab, The University of Tokyo
*)

(* MEMO: 
     (1) these serve as translators. 
     (2) There are some cases which are not handled yet
*)
open CsisatAst

module Ast = CsisatAst
module Interpolate = CsisatInterpolate
module AstUtil = CsisatAstUtil
module SatPL = CsisatSatPL

let rec print_expr expr = match expr with
  | Constant cst -> CsisatUtils.my_string_of_float cst
  | Variable v -> v
  | Application (sym, lst) -> sym ^ "(" ^ (CsisatUtils.string_list_cat ", " (List.map print_expr lst)) ^")"
  | Sum lst ->  "(" ^ (CsisatUtils.string_list_cat " $PLUS " (List.map print_expr lst)) ^")"
  | Coeff (co, expr) -> (CsisatUtils.my_string_of_float co) ^ " $MUL " ^ (print_expr expr)

let rec print_pred p =
  match p with
  | False -> "false"
  | True -> "true"
  | And lst -> "(" ^ (CsisatUtils.string_list_cat " $AND " (List.map print_pred lst)) ^")"
  | Or lst -> "(" ^ (CsisatUtils.string_list_cat " $OR " (List.map print_pred lst)) ^")"
  | Not p -> "not " ^ print_pred p
  | Eq (e1,e2) -> (print_expr e1) ^ " $EQ " ^ (print_expr e2)
  | Lt (e1,e2) -> (print_expr e1) ^ " $LT " ^ (print_expr e2)
  | Leq (e1,e2) -> (print_expr e1) ^ " $LEQ " ^ (print_expr e2)
  | Atom (External str) -> str
  | Atom (Internal i) -> "atom"^(string_of_int i)

let print p = print_pred p

let get_function_name (term : Form.term_t) : string =
    match term with
    | Form.FUN fun_name -> fun_name
    | _ -> assert false

let rec expr_of_term (term : Form.term_t) : Ast.expression =
    match term with
    | Form.VAR var_name -> 
         Ast.Variable var_name
    | Form.UIFUN terms ->
         begin
            match terms with
            | [] -> assert false
            | h::terms -> 
                let fun_name = get_function_name h in 
                let exprs = List.map expr_of_term terms in
                Ast.Application (fun_name, exprs)  
         end
    | Form.ARITH arith_term -> 
         expr_of_arith_term arith_term
    | Form.FUN _ (* not allowed to appear here *)
    | Form.LTERM _ -> assert false (* LTERM appears improperly *)

and expr_of_arith_term (arith_term : Form.arith_term_t) : Ast.expression =
    match arith_term with
    | Form.NUM n 
        -> Ast.Constant (Num.float_of_num n)
    | Form.MUL (term1, term2) 
        -> begin
             let expr1 = expr_of_term term1 
             and expr2 = expr_of_term term2 in
             match expr1, expr2 with
             | Ast.Constant f, _ -> Ast.Coeff (f, expr2)
             | _, Ast.Constant f -> Ast.Coeff (f, expr1)
             | _ -> assert false (* temporarily skipped *)          
           end
    | Form.ADD (term1, term2) 
        -> let expr1 = expr_of_term term1 
           and expr2 = expr_of_term term2 in
           Ast.Sum [expr1; expr2]
    | Form.NEG term 
        -> Ast.Coeff(-1.0, expr_of_term term)
    | Form.ZERO 
    | Form.CVT _ -> assert false (* ZERO & CVT appear improperly *)

let rec predicate_of_form (input : Form.form_t) :  Ast.predicate = 
    match input with
    | Form.TT 
        -> Ast.True
    | Form.FF 
        -> Ast.False
    | Form.PROP var 
        -> assert false (* temporarily not considered *)
    | Form.PRED (op, term1, term2) 
        -> begin
           let expr1 = expr_of_term term1 
           and expr2 = expr_of_term term2 in
           match op with
           | Form.EQ -> Ast.Eq (expr1, expr2)
           | Form.NE -> Ast.Not (Ast.Eq(expr1,expr2))
           | Form.GE -> Ast.Not (Ast.Lt(expr1,expr2))
           | Form.GT -> Ast.Not (Ast.Leq(expr1,expr2))
           | Form.LE -> Ast.Leq(expr1, expr2)
           | Form.LT -> Ast.Lt(expr1, expr2)
           | Form.DIVS -> assert false (* temporarily not considered *)
        end
    | Form.NOT form 
        -> Ast.Not (predicate_of_form form)
    | Form.AND forms
        -> let predicates = List.map predicate_of_form forms in
           Ast.And predicates
    | Form.OR forms
        -> let predicates = List.map predicate_of_form forms in
           Ast.Or predicates
    | Form.IMP (form1, form2)
        -> let pred1 = predicate_of_form form1
           and pred2 = predicate_of_form form2 in
           Ast.Or [Ast.Not pred1; pred2]
    | Form.IFF (form1, form2)
        (* stupid way to handle *)
        -> let pred1 = predicate_of_form (Form.IMP(form1, form2))
           and pred2 = predicate_of_form (Form.IMP(form1, form2)) in
           Ast.And [pred1; pred2]
    | Form.FORALL _
    | Form.EXISTS _ 
        -> assert false  (* temporarily not considered *)


let rec term_of_expression (expr: Ast.expression) : Form.term_t =
    match expr with
    | Ast.Constant f -> Form.ARITH (Form.NUM (Num.num_of_int (int_of_float f)))
    | Ast.Variable name -> Form.VAR name
    | Ast.Application (fun_name, exprs) ->
          let forms = List.map term_of_expression exprs in
    Form.UIFUN ((Form.FUN fun_name)::forms)
    | Ast.Sum exprs ->
          let f a (b: Ast.expression) =
        let temp = term_of_expression b in
        Form.ARITH (Form.ADD (a, temp))
    in
    List.fold_left f (Form.ARITH (Form.NUM (Num.num_of_int 0))) exprs
    | Ast.Coeff (f, expr) ->
          let term1 = Form.ARITH (Form.NUM (Num.num_of_int (int_of_float f))) in
    let term2 = term_of_expression expr in
    Form.ARITH (Form.MUL (term1, term2))

let rec form_of_predicate (pred: Ast.predicate) : Form.form_t = 
    match pred with
    | Ast.True -> Form.TT
    | Ast.False -> Form.FF
    | Ast.And preds 
       -> let forms = List.map form_of_predicate preds in
          Form.AND forms
    | Ast.Or preds 
       -> let forms = List.map form_of_predicate preds in
          Form.OR forms
    | Ast.Not pred1 
       -> let form = form_of_predicate pred1 in
          Form.NOT form
    | Ast.Eq (expr1, expr2) 
       -> let term1 = term_of_expression expr1 
          and term2 = term_of_expression expr2 in
          Form.PRED(Form.EQ, term1, term2)
    | Ast.Lt (expr1, expr2) 
       -> let term1 = term_of_expression expr1 
          and term2 = term_of_expression expr2 in
          Form.PRED(Form.LT, term1, term2)
    | Ast.Leq (expr1, expr2) 
       -> let term1 = term_of_expression expr1 
          and term2 = term_of_expression expr2 in
          Form.PRED(Form.LE, term1, term2)
    | Ast.Atom i (*lit for the satsolver*)
       -> assert false

let get_interpolants (inputs: Ast.predicate list) : Ast.predicate list =
    let conjunction_of (preds : Ast.predicate list) : Ast.predicate =
        Ast.And preds
    in
    let rec get_interpolants1 (inputs1:Ast.predicate list)
                              (inputs2:Ast.predicate list) 
               (to_return: Ast.predicate list) =
    begin
        match inputs2 with
        | [] -> to_return
        | h::tail -> 
                let a = conjunction_of inputs1
                and b = conjunction_of inputs2
                in
                let interpolant = 
                        Interpolate.interpolate_with_proof a b in 
                get_interpolants1 (inputs1 @ [h]) 
                                  tail 
                                  (interpolant::to_return)
    end
    in 
    match inputs with 
    | [] -> []
    | h::t -> get_interpolants1 [h] t []

(* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CHECK VALID ~~~~~~~~~~~~~~~~~~~~~~~~~~~ *)
let is_valid (pred_to_check : predicate) = 
begin
    let new_pred = AstUtil.simplify (Not pred_to_check) in
    if SatPL.is_sat (new_pred) = false then true
    else false
end

(* ~~~~~~~~~~~~~~~~~~~~~~~ COMPUTE WEAKEST PRECONDITION ~~~~~~~~~~~~~~~~~~~~~ *)
(* replace var in an expression by an other expression (the other expression  *)
(* is right_expr of an assignment)                                            *)
let rec replace_var_in_expression (expr_in_post_condition : expression) 
    (replacing_var : expression) (expr_to_replace : expression) 
: expression =
begin
	  match expr_in_post_condition with
    | Constant f -> Constant f
	  | Variable _ -> 
        if expr_in_post_condition = replacing_var then expr_to_replace 
        else expr_in_post_condition
    (* 20090626 *)
	  (*| Application ("addrof", _)
	  | Application ("pref", _)
	  | Application ("sref", _)
	  | Application ("srefp", _) ->
	      if expr_in_post_condition = replacing_var then expr_to_replace 
		    else expr_in_post_condition*)
	  (* temporally  process "array" *)
	  | Application ("array", expr_list) -> (*assert false*)
        if expr_in_post_condition = replacing_var then expr_to_replace 
        else begin
            let new_expr_list = ref [] in
            (* replace var in each expr in expr_list *)
            List.iter 
                (fun a_expr -> 
                    let new_expr = 
                        replace_var_in_expression (a_expr) (replacing_var) 
                          (expr_to_replace) 
                    in
                    new_expr_list := !new_expr_list @ [new_expr]
                )
                expr_list;
            (* return *)
            Application ("array", !new_expr_list)
        end
	  | Application (name_of_function_call, expr_list) -> begin
		    let new_expr_list = ref [] in
	      (* replace var in each expr in expr_list *)
		    List.iter 
		        (fun a_expr -> 
		            let new_expr = 
		                replace_var_in_expression (a_expr) (replacing_var) 
	                    (expr_to_replace) 
	              in
		            new_expr_list := !new_expr_list @ [new_expr]
            )
		        expr_list;
	      (* return *)
		    Application (name_of_function_call, !new_expr_list)
	    end
	  | Sum expr_list -> begin
		    let new_expr_list = ref [] in
	      (* replace var in each expr in expr_list *)
		    List.iter 
		        (fun a_expr -> 
		            let new_expr = 
		                replace_var_in_expression (a_expr) (replacing_var) 
	                    (expr_to_replace) 
	              in
		            new_expr_list := !new_expr_list @ [new_expr]
            )
		        expr_list;
	      (* return *)
		    Sum !new_expr_list
	    end
	  | Coeff (c, expr) -> begin
	      let new_expr = 
	          replace_var_in_expression (expr) (replacing_var) (expr_to_replace)
	      in
	      Coeff (c, new_expr)
	    end
end

(* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *)
(* replace expression in an predicatee by an other expression (the other      *)
(* expression is right_expr of an assignment)                                 *)
and replace_var_in_predicate (pred_in_post_condition : predicate) 
    (replacing_var : expression) (expr_to_replace : expression) 
: predicate = 
begin
	  match pred_in_post_condition with
	  | True -> True
	  | False -> False
	  | And pred_list -> begin
		    let new_pred_list = ref [] in
		    List.iter 
		        (fun a_pred -> 
			          let new_pred = 
	                  replace_var_in_predicate (a_pred) (replacing_var) 
	                    (expr_to_replace) 
	              in
			          new_pred_list := !new_pred_list @ [new_pred]
            )
		        pred_list;
		      And !new_pred_list
        end
    | Or pred_list -> begin
        let new_pred_list = ref [] in
        List.iter 
            (fun a_pred -> 
                let new_pred : predicate = 
                    replace_var_in_predicate (a_pred) (replacing_var) 
                      (expr_to_replace) 
                in
                new_pred_list := !new_pred_list @ [new_pred]
            )
            pred_list;
        Or !new_pred_list
      end
	  | Not pred -> begin
        let new_pred = 
            replace_var_in_predicate (pred) (replacing_var) (expr_to_replace)
        in
        Not new_pred
      end
	  | Eq (expr1, expr2) -> begin 
		    let new_expr1 : expression = 
            replace_var_in_expression (expr1) (replacing_var) (expr_to_replace) 
		    in
        let new_expr2 : expression = 
            replace_var_in_expression (expr2) (replacing_var) (expr_to_replace) 
        in
		    Eq (new_expr1, new_expr2)
      end
	  | Lt (expr1, expr2) -> begin 
        let new_expr1 : expression = 
            replace_var_in_expression (expr1) (replacing_var) (expr_to_replace) 
        in
        let new_expr2 : expression = 
            replace_var_in_expression (expr2) (replacing_var) (expr_to_replace) 
        in
        Lt (new_expr1, new_expr2)
      end
	  | Leq (expr1, expr2) -> begin 
        let new_expr1 : expression = 
            replace_var_in_expression (expr1) (replacing_var) (expr_to_replace) 
        in
        let new_expr2 : expression = 
            replace_var_in_expression (expr2) (replacing_var) (expr_to_replace) 
        in
        Leq (new_expr1, new_expr2)
      end
	  | Atom i -> Atom i
end

(* ~~~~~~~~~~~~~~~~ compute weakest_precondition ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *)
let rec get_weakest_precondition (post_condition : predicate)
    (edge : predicate) 
: predicate =
begin
	  (* check type of edge, if edge isn't an assignment or a list of *)
    (* assignments is assert false                                  *)
	  let wp_to_return = 
	      match edge with
		    | Eq (left_expr, right_expr) -> 
		       replace_var_in_predicate (post_condition) (left_expr) (right_expr)
		    | And pred_list ->
          begin 
			      let rev_pred_list = List.rev pred_list in 
			      let weakest_precondition = ref post_condition in
			      List.iter 
		  	        (fun a_pred -> 
			              weakest_precondition :=  
                      get_weakest_precondition (!weakest_precondition) (a_pred)
                )
			          rev_pred_list;
            (* return *)
			      !weakest_precondition
          end
		    | _ -> post_condition;
	  in
	  wp_to_return
end

(* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *)
module Logic = struct
  include Ast
  let predicate_of_form: Form.form_t -> predicate = predicate_of_form
  let expr_of_term: Form.term_t -> Ast.expression = expr_of_term
  let form_of_predicate: predicate -> Form.form_t = form_of_predicate
  
  let string_of_predicate: predicate -> string = 
      fun (p: predicate) -> print_pred p
  let string_of_expression : expression -> string = 
      fun (e : expression) -> print_expr e
  
  let get_interpolant (a : predicate) (b : predicate) : predicate =
      Interpolate.interpolate_with_proof a b
  let get_interpolants (preds : predicate list) : predicate list =
      Interpolate.interpolate_with_one_proof preds

  let is_sat: predicate -> bool = SatPL.is_sat
  let is_valid: predicate -> bool = is_valid

  let cnf: predicate -> predicate = AstUtil.cnf
  let dnf: predicate -> predicate = AstUtil.dnf

  let normalize: predicate -> predicate = AstUtil.normalize
  
  let replace_var_in_expression : expression -> expression -> expression -> expression =
      replace_var_in_expression
  let replace_var_in_predicate: predicate -> expression -> expression -> predicate =
      replace_var_in_predicate
  let get_weakest_precondition: predicate -> predicate -> predicate = 
      get_weakest_precondition
  let simplify : predicate -> predicate = AstUtil.simplify 
  let simplify_expr : expression -> expression = AstUtil.simplify_expr
  let remove_lit_clash : predicate -> predicate = AstUtil.remove_lit_clash
end
   
