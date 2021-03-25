let () =
  let open Alcotest in
  run "checker"
    [
      Kind_subsume.test_cases
    ; Type_check.test_cases
    ; Type_reduce.test_cases
    ; Type_subsume.test_cases
    ; Expr_check.test_cases
    ]
