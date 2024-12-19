-module(erlang_v8_lib_bg_procs).

-include("erlang_v8_lib.hrl").

-export([start_link/0]).

-export([connect/0]).
-export([disconnect/1]).

-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

%% External API

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

connect() ->
    gen_server:call(?MODULE, {connect, self()}).

disconnect(MRef) ->
    gen_server:call(?MODULE, {disconnect, MRef}).

%% Callbacks

init([]) ->
    ?LOGINFO("Background process monitor started."),
    {ok, []}.

handle_call({connect, Pid}, _From, State) ->
    MRef = erlang:monitor(process, Pid),
    {reply, {ok,MRef}, State};

handle_call({disconnect, MRef}, _From, State) ->
    true = erlang:demonitor(MRef, [flush]),
    {reply, ok, State};

handle_call(_Message, _From, State) ->
    {reply, ok, State}.

handle_cast(_Message, State) ->
    {noreply, State}.

handle_info({'DOWN', _MRef, process, _Pid, _Reason}, State) ->
    {noreply, State};

handle_info(Msg, State) ->
    ?LOGINFO("Other: ~p", [Msg]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVersion, State, _Extra) ->
    {ok, State}.

