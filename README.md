# Erlangのトレースツールttbを使ってみる
Erlangは19.1で動作確認しました。  
ttbはErlangのバージョン19から使え、18にはないので注意が必要です。

## トレース対象

トレースするプログラムを用意します。

```erlang:calc.erl
-module(calc).

-export([inc/1]).
-export([add/2]).

inc(A) -> add(A, 1).
add(A, B) -> A + B.
```

トレース処理はやや煩雑ですので便利関数を用意します。
また出力を見やすく整形します。

```erlang:util.erl
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
```

## 動作デモ
```shell
# make run
echo 'c(calc), c(util), util:start([calc]), calc:inc(1), calc:add(1, 2), util:stop().' | erl
Eshell V8.1  (abort with ^G)
1> Stored logs in /home/tadokoro/git/erlang_ttb/ttb_upload_ttb-20161109-183549
time:2016/11/9 9:35:49:750.623  from:erl_eval:do_apply/6    to:calc:inc/1
time:2016/11/9 9:35:49:750.643  from:erl_eval:do_apply/6    to:calc:add/2
unknown end_of_trace
ok
```

## トレースの流れ
1. 最初に ttb:tracer() します
2. ttb:p(all, call) 等としてトレース対象を決めます。callの他にはsend, receive, messageなど色々。詳細は[dbg](http://erlang.org/doc/man/dbg.html)のp(Items, Flags)
3. ttb:tp(Mod, caller) 等としてトレースを有効化するモジュール、トレース位置(呼び出し時か、戻り時か)を決めます。詳細は[ttb](http://erlang.org/doc/man/ttb.html)
4. トレースしたい処理を実行します
5. {stopped, Dir} = ttb:stop(return_fetch_dir) 等としてトレースを止めて、ログ保存先を取得
6. ttb:format(Dir) とするとトレース結果が表示されます。出力フォーマットを変えたい場合は ttb:format(Dir, {handler, {fun show/4, []}}) 等としてフォーマット関数(この例ではshow)を指定します。詳細は[ttb](http://erlang.org/doc/man/ttb.htm)

## 備考
トレース実行後は以下のようなファイルが自動で作成されます

```txt
ttb_last_config
ttb_upload_ttb-20161109-184359/
├── nonode@nohost-ttb
└── nonode@nohost-ttb.ti
```

ttbが使えるはずなのに、rebar3でビルド後に「exception error: undefined function ttb:tracer/0」などと表示される場合は、rebar.configのrelxのdepへobserverを追加すると良です  
エラーが消えてttbが使えるようになります
