open LogicUtil;;
open LogicUtil.Logic;;

let test () = 
       print_string "Predicate discovery!\n";
       let pval1 = Variable "x"
       and malloc0 = Variable "malloc0"
       and malloc1 = Variable "malloc1"
       and pvalStar1 = Variable "pvalStar1"
       and size1 = Variable "size1"
       and pval11 = Variable "pval11"
       and pval21 = Variable "pval21"
       and a1 = Variable "a1"
       and i1 = Variable "i1"
       and ptr1 = Variable "ptr1"
       and zero = Constant 0.0
       in
       let p1 = Eq(pval1, malloc0)
       and p2 = Not(Eq(pval1, zero))
       and p3 = Eq(pvalStar1, zero)
       and p4 = Lt(zero, pvalStar1)
       and p5 = Eq(size1, pvalStar1)
       and p6 = Eq(pval11, pval1)
       and p7 = Eq(pval21, pval1)
       and p8 = Eq(a1, malloc1)
       and p9 = Not(Eq(a1, zero))
       and p10 = Eq(i1, zero)
       and p11 = Leq(size1, i1)
       and p12 = Eq(ptr1, zero)
       in
       let preds = [p1;p2;p3;p4;p5; p6; p7; p8; p9; p10; p11; p12] in
       let interpolants = Logic.get_interpolants preds in
       List.iter (fun p -> 
                    let s = 
                        Logic.string_of_predicate p in
                    print_string ("\n --> " ^ s))
                 interpolants

let test1 () =
    let x31 = Variable "x31" 
    and y31 = Variable "y31"
    and y32 = Variable "y32"
    and ctr20 = Variable "ctr20"
    and i20 = Variable "i20"
    in
    let p1 = Eq (x31, ctr20)
    and p2 = Eq (y31, x31)
    and p3 = Eq (y32, (Sum [x31; Constant 1.]))
    in 
    let p11 = And [p1; p3]
    and p4 = Eq (ctr20, i20)
    and p5 = True
    and p6 = Eq (y32, (Sum [i20; Constant 1.]))
    in let p21 = And [p4; p5;Not p6]
    in 
    let preds = [p11; p21] in
    let interpolants = 
          Logic.get_interpolants preds in
    List.iter (fun p -> 
                    let s = 
                        Logic.string_of_predicate p in
                    print_string ("\n --> " ^ s))
                 interpolants

let _ = test1 ()
