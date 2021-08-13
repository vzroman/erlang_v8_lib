-module(erlang_v8_lib_run).

-export([run/2, pre_run/1, post_run/1, run/3]).

system_code() ->
    SourcePath = code:priv_dir(fp) ++ "/UI/dev/backend_api/fp_backend_api.js",
    {ok, Api} = file:read_file(SourcePath),
    Api.
%%    <<"
%%        let handlers = {
%%            api : 'fp_js_backend',
%%            db  : 'fp_js_backend'
%%        };
%%        let fp_api = {
%%            api:{
%%                get_value:async ( Tag, Field, Default )=>{
%%                    if (Default === undefined) {
%%                        Args = [Tag, Field];
%%                    } else {
%%                        Args = [Tag, Field, Default]
%%                    }
%%                    Params = {path:['fp', 'api', 'get_value'], args: Args};
%%                  let value = await external.run(handlers.api, Params);
%%                  return value;
%%                },
%%                set_value:async (Tag, Field, Value) => {
%%                    Params = {path:['fp', 'api', 'set_value'], args: [Tag, Field, Value]};
%%                    let exec_code = await external.run(handlers.api, Params);
%%                    return exec_code;
%%              },
%%                archives_get:async (Points, Archives) => {
%%                    Params = {path:['fp', 'api', 'archives_get'], args: [Points, Archives]};
%%                    let exec_code = await external.run(handlers.api, Params);
%%                    return exec_code;
%%                },
%%                archives_get_periods:async (ParamS, Archives) =>  {
%%                    Params = {path:['fp', 'api', 'archives_get_periods'], args: [ParamS, Archives]};
%%                    let exec_code = await external.run(handlers.api, Params);
%%                    return exec_code;
%%                },
%%                catalog_find_node: async (Catalog, NodeID) => {
%%                    Params = {path:['fp', 'api', 'catalog_find_node'], args: [Catalog, NodeID]};
%%                    let exec_code = await external.run(handlers.api, Params);
%%                    return exec_code;
%%                },
%%                log: async (Level, Text, Arguments) => {
%%                    if (Arguments === undefined) {
%%                        Args = [Level, Text];
%%                    } else {
%%                        Args = [Level, Text, Arguments];
%%                    }
%%                    Params = {path : ['fp', 'api', 'log'], args: Args};
%%                    let exec_code = await external.run(handlers.api, Params);
%%                    return exec_code;
%%                }
%%            },
%%            db:{
%%                create_object:async (Fields) => {
%%                    Params = {path:['fp', 'db', 'create_object'], args:[Fields]};
%%                    let exec_code = await external.run(handlers.db, Params);
%%                    return exec_code;
%%                },
%%                edit_or_create:async (Fields) => {
%%                    Params = {path:['fp', 'db', 'edit_or_create'], args:[Fields]};
%%                    let exec_code = await external.run(handlers.db, Params);
%%                    return exec_code;
%%                },
%%
%%                read_field:async (Object, Field) => {
%%                    Args = [Object, Field];
%%                    Params = {path:['fp', 'db', 'read_field'], args: Args};
%%                    let exec_code = await external.run(handlers.db, Params);
%%                    return exec_code;
%%                },
%%                read_fields:async (Object, Fields) => {
%%                    Args = [Object, Fields];
%%                    Params = {path:['fp', 'db', 'read_fields'], args: Args};
%%                    let exec_code = await external.run(handlers.db, Params);
%%                    return exec_code;
%%                },
%%                edit_object:async (Object, Fields) => {
%%                    Args = [Object, Fields];
%%                    Params = {path:['fp', 'db', 'edit_object'], args: Args};
%%                    let exec_code = await external.run(handlers.db, Params);
%%                    return exec_code;
%%                },
%%                dirty_edit_object:async (Object, Fields) => {
%%                    Args = [Object, Fields];
%%                    Params = {path:['fp', 'db', 'dirty_edit_object'], args: Args};
%%                    let exec_code = await external.run(handlers.db, Params);
%%                    return(exec_code);
%%                },
%%                copy_object:async (ID, Overwrite) => {
%%                    Params = {path:['fp', 'db', 'copy_object'], args: [ID, Overwrite]};
%%                    let exec_code = await external.run(handlers.db, Params);
%%                    return(exec_code);
%%                },
%%                query: async(QueryString) => {
%%                    Params = {path:['fp', 'db', 'query'], args: [QueryString]};
%%                    let result = await external.run(handlers.db, Params);
%%                    return result;
%%                },
%%                transaction:async (Fun) => {
%%                    return 1;
%%                },
%%                start_transaction:async () => {
%%                    Params = {path:['fp', 'db', 'start_transaction'], args:[]};
%%                    let exec_code = await external.run(handlers.db, Params);
%%                    return(exec_code);
%%                },
%%                commit_transaction:async () => {
%%                    Params = {path:['fp', 'db', 'commit_transaction'], args:[]};
%%                    let exec_code = await external.run(handlers.db, Params);
%%                    return exec_code;
%%                },
%%                rollback_transaction:async () => {
%%                    Params = {path:['fp', 'db', 'rollback_transaction'], args:[]};
%%                    let exec_code = await external.run(handlers.db, Params);
%%                    return exec_code;
%%                },
%%                to_oid:async (Object) => {
%%                    Params = {path:['fp', 'db', 'to_oid'], args: [Object]};
%%                    let value = await external.run(handlers.db, Params);
%%                    return value;
%%                },
%%                path2oid:async (Path) => {
%%                    Params = {path:['fp', 'db', 'path2oid'], args: [Path]};
%%                    let value = await external.run(handlers.db, Params);
%%                    return value;
%%                },
%%                to_path: async (Object) => {
%%                    Params = {path:['fp', 'db', 'to_path'], args: [Object]};
%%                    let value = await external.run(handlers.db, Params);
%%                    return value;
%%                }
%%
%%            }
%%        };
%%        let x =  100;
%%    ">>.

pre_run(Opts) ->
    HandlerContext = maps:get(handler_context, Opts, #{}),
    {ok, Worker} = erlang_v8_lib_pool:claim(),
    ok = erlang_v8_lib_bg_procs:connect(),
    SystemCode = system_code(),
    run(Worker, [{eval,SystemCode}], HandlerContext),
    {Worker, HandlerContext}.

post_run({Worker, _HandlerContext}) ->
    erlang_v8_lib_pool:release(Worker),
    ok.

run(Instructions, Opts) ->
    HandlerContext = maps:get(handler_context, Opts, #{}),
    {ok, Worker} = erlang_v8_lib_pool:claim(),
    ok = erlang_v8_lib_bg_procs:connect(),
    R = run(Worker, Instructions, HandlerContext),
    %% ok = erlang_v8_lib_bg_procs:disconnect(),
    _ = erlang_v8_lib_pool:release(Worker),
    R.

run(Worker, [Instruction|Instructions], HandlerContext) ->
    case unwind(Worker, [Instruction], HandlerContext) of
        {error, Reason} ->
            {error, Reason};
        Other when length(Instructions) =:= 0 ->
            Other;
        _Other ->
            run(Worker, Instructions, HandlerContext)
    end.

unwind(_Worker, [], _HandlerContext) ->
    ok;

unwind(Worker, [{context, Context}], _HandlerContext) ->
    case erlang_v8_lib_pool:call(Worker,
                                 <<"__internal.setContext">>, [Context]) of
        {error, Reason} ->
            {error, Reason};
        {ok, undefined} ->
            ok
    end;

unwind(Worker, [{call, Fun, Args}], HandlerContext) ->
    {ok, []} = erlang_v8_lib_pool:eval(Worker, <<"__internal.actions = [];">>),
    case erlang_v8_lib_pool:call(Worker, Fun, Args) of
        {error, Reason} ->
            {error, Reason};
        {ok, undefined} ->
            case erlang_v8_lib_pool:eval(Worker, <<"__internal.actions;">>) of
                {ok, Actions} ->
                    unwind(Worker, Actions, HandlerContext);
                {error, Reason} ->
                    {error, Reason}
            end;
        {ok, Value} ->
            %% TODO: What about returned values? Treat as a regular return?
            {ok, jsx:decode(jsx:encode(Value), [return_maps])}
    end;

unwind(Worker, [{eval, Source}], HandlerContext) ->
    case erlang_v8_lib_pool:eval(Worker, <<"
        __internal.actions = [];
        ", Source/binary, "
        __internal.actions;
    ">>) of
        {ok, Actions} ->
            unwind(Worker, Actions, HandlerContext);
        {error, Reason} ->
            {error, Reason}
    end;

unwind(_Worker, [[<<"return">>, Value]|_], _HandlerContext) ->
    {ok, jsx:decode(jsx:encode(Value), [return_maps])};

unwind(Worker, [[<<"external">>, HandlerIdentifier, Ref, Args]|T],
       HandlerContext) ->
    Actions = dispatch_external(Worker, Ref, Args, HandlerIdentifier,
                                HandlerContext),
    unwind(Worker, Actions ++ T, HandlerContext);

unwind(Worker, [[resolve_in_js, Status, Ref, Fun, Args]|T], HandlerContext) ->
    {ok, Actions} = erlang_v8_lib_pool:call(Worker, Fun, [Status, Ref, Args]),
    unwind(Worker, Actions ++ T, HandlerContext);

unwind(Worker, [[callback, Status, Ref, Args]|T], HandlerContext) ->
    Fun = <<"__internal.handleExternal">>,
    {ok, Actions} = erlang_v8_lib_pool:call(Worker, Fun, [Status, Ref, Args]),
    unwind(Worker, Actions ++ T, HandlerContext);

unwind(Worker, [Action|T], HandlerContext) ->
    lager:error("Unknown instruction: ~p", [Action]),
    unwind(Worker, T, HandlerContext).

dispatch_external({_, _, Handlers}, Ref, Args, HandlerIdentifier,
                  HandlerContext) ->
    case maps:get(HandlerIdentifier, Handlers, undefined) of
        undefined ->
            [[callback, <<"error">>, Ref, <<"Invalid external handler.">>]];
        HandlerMod ->
            case HandlerMod:run(Args, HandlerContext) of
                {resolve_in_js, Fun, Response} ->
                    [[resolve_in_js, <<"success">>, Ref, Fun, Response]];
                {ok, Response} ->
                    [[callback, <<"success">>, Ref, Response]];
                ok ->
                    [[callback, <<"success">>, Ref, <<>>]];
                {error, Reason} when is_binary(Reason); is_atom(Reason) ->
                    [[callback, <<"error">>, Ref, Reason]];
                {error, Reason} ->
                    lager:error("Unknown dispatch error: ~p", [Reason]),
                    [[callback, <<"error">>, Ref, <<"Unknown error.">>]]
            end
    end.
