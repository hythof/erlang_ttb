-module(calc).

-export([inc/1]).
-export([add/2]).

inc(A) -> add(A, 1).
add(A, B) -> A + B.
