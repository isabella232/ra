-module(ra_machine).

-compile({no_auto_import, [apply/3]}).

-include("ra.hrl").


-export([init/2,
         apply/4
        ]).

-type state() :: term().
-type command() :: term().

-type apply_fun() :: fun((command(), state()) -> state()).

-type machine() :: {simple, apply_fun(), Initial :: state()} |
                   {module, module()}.

-type builtin_command() :: {down, pid()}.

-type effect() ::
    {send_msg, pid() | atom() | {atom(), atom()}, term()} |
    {monitor, process, pid()} |
    {demonitor, pid()} |
    % indicates that none of the preceeding entries contribute to the
    % current machine state
    {release_cursor, ra_index(), term()}.

-type effects() :: [effect()].

-export_type([machine/0,
              effect/0,
              effects/0,
              builtin_command/0]).


-callback init(Name :: atom()) -> {state(), ra_node:ra_effects()}.

-callback 'apply'(Index :: ra_index(), command(), state()) ->
    {state(), ra_node:ra_effects()}.



-spec init(machine(), atom()) -> {state(), effects()}.
init({module, Mod}, Name) ->
    Mod:init(Name);
init({simple, _Fun, InitialState}, _Name) ->
    {InitialState, []}.

-spec apply(machine(), ra_index(), command(), state()) ->
    {state(), effects()}.
apply({module, Mod}, Idx, Cmd, State) ->
    Mod:apply(Idx, Cmd, State);
apply({simple, Fun, _InitialState}, _Idx, Cmd, State) ->
    {Fun(Cmd, State), []}.
