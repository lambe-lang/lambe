open Lambe_checker.Context
open Lambe_checker.Gamma
open Lambe_checker.Type.Checker.Operator
open Dsl
open Dsl.Types

let test_case_000 () =
  let expected = true
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star ] + empty)
    |- (v "a" <? v "a") Variables.create
  in
  Alcotest.(check bool) "should accept a <? a" expected computed

let test_case_001 () =
  let expected = false
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star; "b", star ] + empty)
    |- (v "a" <? v "b") Variables.create
  in
  Alcotest.(check bool) "should accept a <? b" expected computed

let test_case_002 () =
  let expected = true
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star; "b", star ] + empty)
    |- (v "a" <? (v "a" <|> v "b")) Variables.create
  in
  Alcotest.(check bool) "should accept a <? b | a" expected computed

let test_case_003 () =
  let expected = true
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star; "b", star ] + empty)
    |- (v "a" <? (v "b" <|> v "a")) Variables.create
  in
  Alcotest.(check bool) "should accept a <? b | a" expected computed

let test_case_004 () =
  let expected = true
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star; "b", star ] + empty)
    |- (v "b" <|> v "a" |-> v "a" <? (v "a" |-> v "a")) Variables.create
  in
  Alcotest.(check bool) "should accept a | b -> a <? a -> a" expected computed

let test_case_005 () =
  let expected = true
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star; "b", star ] + empty)
    |- (v "b" <|> v "a" |@> v "a" <? (v "a" |@> v "a")) Variables.create
  in
  Alcotest.(check bool) "should accept a | b @-> a <? a @-> a" expected computed

let test_case_006 () =
  let expected = true
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star; "b", star ] + empty)
    |- (v "b" <|> v "a" <? (v "a" <|> v "b")) Variables.create
  in
  Alcotest.(check bool) "should accept a | b <? b | a" expected computed

let test_case_007 () =
  let expected = true
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star; "b", star ] + empty)
    |- ( data "C" [ "h", v "a"; "t", v "b" ]
       <? data "C" [ "t", v "b"; "h", v "a" ] )
         Variables.create
  in
  Alcotest.(check bool)
    "should accept data C (h:a) (t:b) <? data C (t:b) (h:a)" expected computed

let test_case_008 () =
  let expected = true
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star; "b", star ] + empty)
    |- (data "C" [ "h", v "a"; "t", v "b" ] <? data "C" [ "t", v "b" ])
         Variables.create
  in
  Alcotest.(check bool)
    "should accept data C (h:a) (t:b) <? data C (t:b)" expected computed

let test_case_009 () =
  let expected = false
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star; "b", star ] + empty)
    |- (data "C" [ "t", v "b" ] <? data "C" [ "h", v "a"; "t", v "b" ])
         Variables.create
  in
  Alcotest.(check bool)
    "should reject data C (t:b) <? data C (h:a) (t:b)" expected computed

let test_case_010 () =
  let expected = true
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star ] + empty)
    |- (mu "x" (v "a" |-> v "x") <? (v "a" |-> mu "x" (v "a" |-> v "x")))
         Variables.create
  in
  Alcotest.(check bool)
    "should accept mu(x).a -> x <? a -> (mu(x).a -> x)" expected computed

let test_case_011 () =
  let expected = true
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star ] + empty)
    |- (v "a" |-> mu "x" (v "a" |-> v "x") <? mu "x" (v "a" |-> v "x"))
         Variables.create
  in
  Alcotest.(check bool)
    "should accept a -> (mu(x).a -> x) <? mu(x).a -> x" expected computed

let test_case_012 () =
  let expected = true
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star ] + empty)
    |- (mu "y" (v "a" |-> v "y") <? mu "x" (v "a" |-> v "x")) Variables.create
  in
  Alcotest.(check bool)
    "should accept mu(y).a -> x <? mu(x).a -> x" expected computed

let test_case_013 () =
  let expected = true
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star ] + empty)
    |- ( forall ("x", Gamma.star) (v "x" |-> v "a")
       <? forall ("y", Gamma.star) (v "y" |-> v "a") )
         Variables.create
  in
  Alcotest.(check bool)
    "should accept forall(x:*).x -> a <? forall(y:*).y -> a" expected computed

let test_case_014 () =
  let expected = true
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star ] + empty)
    |- ( forall ("x", Gamma.(star |-> star)) (v "x" |-> v "a")
       <? forall ("y", Gamma.star) (v "y" |-> v "a") )
         Variables.create
  in
  Alcotest.(check bool)
    "should accept forall(x:*->*).x -> a <? forall(y:*).y -> a" expected
    computed

let test_case_015 () =
  let expected = false
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star ] + empty)
    |- ( forall ("x", Gamma.star) (v "x" |-> v "a")
       <? forall ("y", Gamma.(star |-> star)) (v "y" |-> v "a") )
         Variables.create
  in
  Alcotest.(check bool)
    "should reject forall(x:*).x -> a <? forall(y:*->*).y -> a" expected
    computed

let test_case_016 () =
  let expected = true
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star ] + empty)
    |- ( exists ("x", Gamma.star) (v "x" |-> v "a")
       <? exists ("y", Gamma.star) (v "y" |-> v "a") )
         Variables.create
  in
  Alcotest.(check bool)
    "should accept exists(x:*).x -> a <? exists(y:*).y -> a" expected computed

let test_case_017 () =
  let expected = true
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star ] + empty)
    |- ( exists ("x", Gamma.(star |-> star)) (v "x" |-> v "a")
       <? exists ("y", Gamma.star) (v "y" |-> v "a") )
         Variables.create
  in
  Alcotest.(check bool)
    "should accept exists(x:*->*).x -> a <? exists(y:*).y -> a" expected
    computed

let test_case_018 () =
  let expected = false
  and computed, _ =
    Gamma.(Helpers.k_set [ "a", star ] + empty)
    |- ( exists ("x", Gamma.star) (v "x" |-> v "a")
       <? exists ("y", Gamma.(star |-> star)) (v "y" |-> v "a") )
         Variables.create
  in
  Alcotest.(check bool)
    "should reject exists(x:*).x -> a <? exists(y:*->*).y -> a" expected
    computed

let test_cases =
  let open Alcotest in
  ( "Type subsume"
  , [
      test_case "Accept a <? a" `Quick test_case_000
    ; test_case "Reject a <? b" `Quick test_case_001
    ; test_case "Accept a <? a | b" `Quick test_case_002
    ; test_case "Accept a <? b | a" `Quick test_case_003
    ; test_case "Accept b | a -> a <? a -> a" `Quick test_case_004
    ; test_case "Accept b | a @> a <? a @> a" `Quick test_case_005
    ; test_case "Accept a | b <? b | a" `Quick test_case_006
    ; test_case "Accept data C (h:a) (t:b) <? data C (t:b) (h:a)" `Quick
        test_case_007
    ; test_case "Accept data C (h:a) (t:b) <? data C (t:b)" `Quick test_case_008
    ; test_case "Reject data C (t:b) <? data C (h:a) (t:b)" `Quick test_case_009
    ; test_case "Accept mu(x).a -> x <? a -> (mu(x).a -> x)" `Quick
        test_case_010
    ; test_case "Accept a -> (mu(x).a -> x) <? mu(x).a -> x" `Quick
        test_case_011
    ; test_case "Accept mu(y).a -> y <? mu(x).a -> x" `Quick test_case_012
    ; test_case "Accept forall(x:*).x -> a <? forall(y:*).y -> a" `Quick
        test_case_013
    ; test_case "Accept forall(x:*->*).x -> a <? forall(y:*).y -> a" `Quick
        test_case_014
    ; test_case "Reject forall(x:*).x -> a <? forall(y:*->*).y -> a" `Quick
        test_case_015
    ; test_case "Accept exists(x:*).x -> a <? exists(y:*).y -> a" `Quick
        test_case_016
    ; test_case "Accept exists(x:*->*).x -> a <? exists(y:*).y -> a" `Quick
        test_case_017
    ; test_case "Reject exists(x:*).x -> a <? exists(y:*->*).y -> a" `Quick
        test_case_018
    ] )
