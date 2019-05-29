assert(ZHRL.top_interp('4') == "4");
assert(ZHRL.top_interp('{if true 1 2}') == "1");
assert(ZHRL.top_interp('{+ 1 2}') == "3");
assert(ZHRL.top_interp('{* {+ 1 2} {- 15 5}}') == "30");
assert(ZHRL.top_interp('{equal? 1 1}') == "true");
assert(ZHRL.top_interp('{{lam {+} {* + +}} 14}') == "196");
%assert(ZHRL.top_interp('"hello"') == '"hello"');
%assert(ZHRL.top_interp('{if false 1 "hello"}') == '"hello"');

% testing variables
keys = {'+', '-', '*', '/', '<=', 'equal?', 'true', 'false'};
values = {PrimV('+'), PrimV('-'), PrimV('*'), ...
          PrimV('/'), PrimV('<='), PrimV('equal?'), ...
          BoolV(true), BoolV(false)};
env = Environment(keys, values);

% basic interp testing
assert(isequal(ZHRL.interp(NumC(5), env), NumV(5)));
assert(isequal(ZHRL.interp(IdC('true'), env), BoolV(true)));
assert(isequal(ZHRL.interp(IdC('false'), env), BoolV(false)));
assert(isequal(ZHRL.interp(StringC('hello'), env), StringV('hello')));

% interp lamC testing
assert(isequal(ZHRL.interp(LamC({'x' 'y'}, AppC(IdC('+'), {IdC('x') IdC('y')})), env), ...
                    ClosV({'x' 'y'}, AppC(IdC('+'), {IdC('x') IdC('y')}), env)));
assert(isequal(ZHRL.interp(AppC(LamC({'x', 'y'}, AppC(IdC('+'), {IdC('x'), IdC('y')})), {NumC(3), NumC(4)}), env), NumV(7)));

% interp primV testing
assert(isequal(ZHRL.interp(AppC(IdC('+'), {NumC(4), NumC(5)}), env), NumV(9)));
assert(isequal(ZHRL.interp(AppC(IdC('-'), {NumC(4), NumC(5)}), env), NumV(-1)));
assert(isequal(ZHRL.interp(AppC(IdC('*'), {NumC(4), NumC(5)}), env), NumV(20)));
assert(isequal(ZHRL.interp(AppC(IdC('<='), {NumC(4), NumC(5)}), env), BoolV(true)));
assert(isequal(ZHRL.interp(AppC(IdC('<='), {NumC(10), NumC(5)}), env), BoolV(false)));
assert(isequal(ZHRL.interp(AppC(IdC('/'), {NumC(20), NumC(5)}), env), NumV(4)));
assert(isequal(ZHRL.interp(AppC(IdC('equal?'), {StringC('test'), StringC('test')}), env), BoolV(true)));
assert(isequal(ZHRL.interp(AppC(IdC('equal?'), {StringC('test'), StringC('test1')}), env), BoolV(false)));
assert(isequal(ZHRL.interp(AppC(IdC('equal?'), {AppC(IdC('<='), {NumC(4) NumC(5)}) AppC(IdC('<='), {NumC(1) NumC(8)})}), env), ...
               BoolV(true)));

% interp appC tests
assert(isequal(ZHRL.interp(AppC(LamC({'x', 'y'}, AppC(IdC('+'), {IdC('x'), IdC('y')})), {NumC(4), NumC(5)}), env), NumV(9)));

% errors should be thrown here
%assert(isequal(ZHRL.interp(AppC(IdC('/'), [NumC(20) NumC(0)]), env), NumV()));

% interp ifC testing
assert(isequal(ZHRL.interp(IfC(IdC('false'), NumC(3), NumC(2)), env),NumV(2)));
assert(isequal(ZHRL.interp(IfC(IdC('true'), NumC(3), NumC(2)), env),NumV(3)));

% parse testing
assert(isequal(ZHRL.parse('4'), NumC(4)));
assert(isequal(ZHRL.parse('a'), IdC('a')));
assert(isequal(ZHRL.parse('"ilovepl"'), StringC('ilovepl')));
assert(isequal(ZHRL.parse({'if', 'true', '2', '1'}), IfC(IdC('true'), NumC(2), NumC(1))));
assert(isequal(ZHRL.parse({'+', '4', '5'}), AppC(IdC('+'), {NumC(4), NumC(5)})));
assert(isequal(ZHRL.parse({'lam', {'x', 'y'},  {'+', 'x', 'y'}}), LamC({'x', 'y'}, AppC(IdC('+'), {IdC('x'), IdC('y')}))));

% pre_parse testing
assert(isequal(ZHRL.pre_parse(ZHRL.chop_str("{4}")), {'4'}));
assert(isequal(ZHRL.pre_parse(ZHRL.chop_str("{var {z = 14} {+ z z}}")), {'var', {'z', '=', '14'} {'+', 'z', 'z'}}));
assert(isequal(ZHRL.pre_parse(ZHRL.chop_str("4")), '4'));
assert(isequal(ZHRL.pre_parse(ZHRL.chop_str("{if {equal? {+ {- 1 2} 3} 3} {var {x = 2} x} {f {* 3 2}}}")), {'if', {'equal?', {'+', {'-', '1', '2'}, '3'}, '3'}, {'var', {'x', '=', '2'}, 'x'}, {'f', {'*', '3', '2'}}}));

assert(isequal(errorCheck(ZHRL.interp(IfC(IdC('true'), NumC(1), NumC(2)), env), "ZHRL: Bad IfC Condition"), true));

primArgTest = true;
try
    ZHRL.interp(AppC(IdC('+'), {NumC(1) NumC(2) NumC(3)}), env);
    primArgTest = false;
catch e
    if strcmp(e.message, "ZHRL: Wrong number of arguments for primitive operation.") == 0
        error("Primitive argument error test failed");
    end
end
if primArgTest == false
    error("Primitive argument error test failed");
end

invalidAppTest = true;
try
    ZHRL.interp (AppC (NumC (3), {NumC(1), NumC(3)}), env)
    invalidAppTest = false;
catch e
    if strcmp(e.message, "ZHRL: invalid application call") == 0
        error("Primitive argument error test failed");
    end
end
if invalidAppTest == false
    error("Invalid AppC error test failed");
end

argsParamMatchTest = true;
try
    ZHRL.interp(AppC(LamC({}, NumC(9)), {NumC(17), NumC(3)}), env);
    argsParamMatchTest = false;
catch e
    if strcmp(e.message, "ZHRL: arguments don't match parameters") == 0
        argsParamMatchTest = false;
    end
end
if argsParamMatchTest == false
    error("Arguments don't match parameters test failed");
end

symbolNotInEnvTest = true;
try 
    ZHRL.interp(AppC(LamC({'x', 'y'}, AppC(IdC('o'), {IdC('x'), IdC('y')})), {NumC(3), NumC(4)}), env);
    symbolNotInEnvTest = false;
catch e
    if strcmp(e.message, "ZHRL: Symbol not in environment") == 0
        symbolNotInEnvTest = false;
    end
end
if symbolNotInEnvTest == false
    error ("Symbol not in env test failed");
end

invalidPrimTest = true;
try
    ZHRL.interp(AppC(IdC('+'), {StringC('test'), NumC(1)}), env);
    invalidPrimTest = false;
catch e
    if strcmp(e.message, "ZHRL: Invalid primitive operation.") == 0
        invalidPrimTest = false;
    end
end
if invalidPrimTest == false
    error("Invalid primitive operation test failed");
end

function ret_val = errorCheck(fun, msg)
    ret_val = false;

    try
        fun;
        ret_val = true;
    catch e
        if strcmp(e.message, msg) == 0
            ret_val = false;
        end
    end
end