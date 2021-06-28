-module(erlang_v8_lib).

-export([
    run/1, run/2, run/3,
    pre_run/1, post_run/1
]).

run(Source) ->
    run(Source, #{}).

run(Source, Opts) when is_binary(Source) ->
    run([{eval, Source}], Opts);

run(Instructions, Opts) when is_map(Opts) ->
    erlang_v8_lib_run:run(Instructions, Opts).

pre_run(Opts) ->
    erlang_v8_lib_run:pre_run(Opts).

post_run(Worker) ->
    erlang_v8_lib_run:post_run(Worker).

run(Worker, Source, HandlerContext) ->
    erlang_v8_lib_run:run(Worker, [{eval, Source}], HandlerContext).