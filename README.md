# Erlangのトレースツールttbを使ってみる
Erlangは19.1で動作確認  
ttbはErlangのバージョン19から使え、18にはないので注意

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
1. 最初に ttb:tracer() しておく
2. ttb:p(all, call) 等として対象を決める。callの他にsend, receive, messageなど色々ある。詳細は(dbg)[http://erlang.org/doc/man/dbg.html]のp(Items, Flags)にある
3. ttb:tp(Mod, caller) 等としてトレースするモジュールと、トレース位置(呼び出し時か、戻り時か)を決める。詳細は(ttb)[http://erlang.org/doc/man/ttb.html]にある
4. ここでトレースしたい処理を実行
5. {stopped, Dir} = ttb:stop(return_fetch_dir) 等としてトレースを止め、ログ保存先を取得
6. ttb:format(Dir) とするとトレース結果が表示される。出力フォーマットを変えたい場合は ttb:format(Dir, {handler, {fun show/4, []}}) 等としてフォーマット関数(この例ではshow)を指定する。詳細は(ttb)[http://erlang.org/doc/man/ttb.html]にある

## 備考
トレース実行後は以下のようなファイルができる

```txt
ttb_last_config
ttb_upload_ttb-20161109-184359/
├── nonode@nohost-ttb
└── nonode@nohost-ttb.ti
```

ttbが使えるはずなのに、rebar3でビルド後に「exception error: undefined function ttb:tracer/0」などと表示する場合は、rebar.configのrelxのdepへobserverを追加すると良い  
エラーが消えてttbが使えるようになる
