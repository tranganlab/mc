module Logic :
  sig
    (* included in Csisat.Ast *)
    (*type theory = EUF | LA | EUF_LA
    type symbol = string
    type expression =
        Constant of float
      | Variable of symbol
      | Application of symbol * expression list
      | Sum of expression list
      | Coeff of float * expression
    type predicate =
        True
      | False
      | And of predicate list
      | Or of predicate list
      | Not of predicate
      | Eq of expression * expression
      | Lt of expression * expression
      | Leq of expression * expression
      | Atom of int*)
    type theory = EUF | LA | EUF_LA
    type symbol = string
    type expression = 
        Constant of float
      | Variable of symbol
      | Application of symbol * expression list
      | Sum of expression list
      | Coeff of float * expression
    type atom_type =
        External of string
      | Internal of int
    type predicate =
        True
      | False
      | And of predicate list
      | Or of predicate list
      | Not of predicate
      | Eq of expression * expression
      | Lt of expression * expression
      | Leq of expression * expression
      | Atom of atom_type

    exception SAT
    exception SAT_FORMULA of predicate

    (* new features *)
    val predicate_of_form: Form.form_t -> predicate 
    val expr_of_term: Form.term_t -> expression
    val form_of_predicate: predicate -> Form.form_t 
 
    val string_of_predicate: predicate -> string 
    val string_of_expression : expression -> string

    val get_interpolant : predicate -> predicate -> predicate 
    val get_interpolants : predicate list -> predicate list

    val is_sat: predicate -> bool 
    val is_valid: predicate -> bool

    val cnf: predicate -> predicate
    val dnf: predicate -> predicate 

    val normalize: predicate -> predicate
    val replace_var_in_expression : expression -> expression -> expression -> expression
    val replace_var_in_predicate: predicate -> expression -> expression -> predicate
    val get_weakest_precondition: predicate -> predicate -> predicate 
    val simplify: predicate -> predicate
    val simplify_expr : expression -> expression
    val remove_lit_clash: predicate -> predicate
  end



