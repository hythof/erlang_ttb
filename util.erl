-module(util).

-export([start/1]).
-export([stop/0]).

%% see http://erlang.org/doc/apps/observer/ttb_ug.html
%% see http://erlang.org/doc/man/dbg.html

start(Mods) ->
    ttb:tracer(),
    ttb:p(all, call),
    lists:foreach(fun(Mod) -> ttb:tp(Mod, caller) end, Mods).

stop() ->
    {stopped, Dir} = ttb:stop(return_fetch_dir),
    ttb:format(Dir, {handler, {fun show/4, []}}).

%% private
show(_Fd, Trace, _TraceInfo, State) ->
    case Trace of
    {_, _, _, {M1, F1, A1}, {M2, F2, A2Length}, TimeStamp} ->
        {_, _, MicroSec} = TimeStamp,
        {{Y, M, D}, {HH, MM, SS}} = calendar:now_to_universal_time(TimeStamp),
        io:format("time:~p/~p/~p ~p:~p:~p:~p\tfrom:~p:~p/~p\tto:~p:~p/~p~n", [Y, M, D, HH, MM, SS, MicroSec / 1000.0, M2, F2, A2Length, M1, F1, length(A1)]);
    _ ->
        io:format("unknown ~p~n", [Trace])
    end,
    State.
