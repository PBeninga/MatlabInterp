classdef ZHRL
    methods(Static)
        
        % top_interp
        % given an ExprC, return result as char
        function ret_str = top_interp(exp)
            keys = {'+', '-', '*', '/', '<=', 'equal?', 'true', 'false'};
            values = {PrimV('+'), PrimV('-'), PrimV('*'), PrimV('/'), PrimV('<='), PrimV('equal?'), BoolV(true), BoolV(false)};
            env = Environment(keys, values);
            % todo: very big chain of calls here, maybe we should move it all to parse
            ret_str = ZHRL.serialize(ZHRL.interp(ZHRL.parse(ZHRL.pre_parse(ZHRL.chop_str(exp))), env));
        end
        
        % interp
        % given an expression, return the Value
        function ret_val = interp(exp, env)
            switch class(exp)
                case 'NumC'
                    ret_val = NumV(exp.Value);
                case 'StringC'
                    ret_val = StringV(exp.Value);
                case 'IdC'
                    try
                        ret_val = env.lookup(exp.Value);
                    catch e
                        error("ZHRL: Symbol not in environment");
                    end
                case 'IfC'
                    res = ZHRL.interp(exp.Condition, env);
                    if isa(res, 'BoolV') && res.Value
                        ret_val = ZHRL.interp(exp.Left, env);
                    elseif isa(res, 'BoolV') && res.Value == false
                        ret_val = ZHRL.interp(exp.Right, env);
                    else
                        error('ZHRL: Bad IfC Condition');
                    end
                case 'LamC'
                    ret_val = ClosV(exp.Args, exp.Body, env);
                case 'AppC'
                    fun = ZHRL.interp(exp.Func, env);
                    switch class(fun)
                        case 'PrimV'
                            if 2 == numel(exp.Args)
                                l = ZHRL.interp(exp.Args{1}, env);
                                r = ZHRL.interp(exp.Args{2}, env);
                                ret_val = ZHRL.computePrim(l, r, fun.Value);
                            else
                                error("ZHRL: Wrong number of arguments for primitive operation.");
                            end
                        case 'ClosV'
                            if length(exp.Args) ~= length(fun.Args)
                               error("ZHRL: arguments don't match parameters");
                            else
                               arg_vals = num2cell(arrayfun(@(x) ZHRL.interp(x{1}, env), exp.Args));
                               new_env = fun.Env.extend(fun.Args, arg_vals);
                               ret_val = ZHRL.interp(fun.Body, new_env); 
                            end
                        otherwise
                            error("ZHRL: invalid application call");
                    end 
            end
        end
        
        % todo: add ZHRL error checking
        function ret_val = computePrim(l, r, op)
           if strcmp(op,'equal?')
               if (isa(l, 'NumV') && isa(r, 'NumV')) || (isa(l, 'BoolV') && isa(r, 'BoolV'))
                   ret_val = BoolV(l.Value == r.Value);
               elseif isa(l, 'StringV') && isa(r, 'StringV')
                   ret_val = BoolV(strcmp(l.Value, r.Value));
               else
                   ret_val = BoolV(false);
               end
           elseif isa(l, 'NumV') && isa(r, 'NumV')
               switch op
                   case '+'
                       ret_val = NumV(l.Value + r.Value);
                   case '-'
                       ret_val = NumV(l.Value - r.Value);
                   case '*'
                       ret_val = NumV(l.Value * r.Value);
                   case '/'
                       ret_val = NumV(l.Value / r.Value);
                   case '<='
                       ret_val = BoolV(l.Value <= r.Value);
                   otherwise
                       error('ZHRL: Unknown primitive operation.')
               end
           else
               error('ZHRL: Invalid primitive operation.')
           end
        end
        
        % serialize
        % given a Value, return char representation
        function ret_str = serialize(val)
            switch class(val)
                case 'NumV'
                    ret_str = int2str(val.Value);
                case 'StringV'
                    ret_str = ['"' val.Value '"'];
                case 'ClosV'
                    ret_str = '#<procedure>';
                case 'PrimV'
                    ret_str = '#<primop>';
                case 'BoolV'
                    if val.Value
                        ret_str = "true";
                    else
                        ret_str = "false";
                    end
            end
        end
        
        % parse
        % given a list of strings return an ExprC
        function ret_exp = parse(exprS)
            switch class(exprS)
                case 'cell'
                    if strcmp(exprS{1}, 'if')
                        ret_exp = IfC(ZHRL.parse(exprS{2}), ZHRL.parse(exprS{3}), ZHRL.parse(exprS{4}));
                    elseif strcmp(exprS{1}, 'lam')
                        ret_exp = LamC(exprS{2}, ZHRL.parse(exprS{3}));
                    else
                        arguments = num2cell(ones(1,length(exprS) - 1));
                        for k=2:length(exprS)
                            arguments{k-1} = ZHRL.parse(exprS{k});
                        end
                        ret_exp = AppC(ZHRL.parse(exprS{1}), arguments);
                    end
                case 'char'
                    if regexp(exprS, '\".*\"')
                        
                        ret_exp = StringC(exprS(2:length(exprS)-1));
                    elseif regexp(exprS, '[0-9.]+')
                        ret_exp = NumC(str2num(exprS));
                    else
                        ret_exp = IdC(exprS);
                    end
                case 'string'
                    ret_exp = StringC(exprS);
            end
        end
        
        % turn a string into an array of strings
        function ret_arr = chop_str(valstr)
           valstr = strrep(strrep(valstr, '{', ' { '), '}', ' } ');
           arr = strsplit(valstr);
           arr = arr(arr ~= "");
           ret_arr = arr;
        end
        
        % turn an array of strings into cell hierarchy ready to parse 
        function ret_arr = pre_parse(arr)
            els = {}; 
            n = 1;

            while n <= length(arr)               
               if strcmp(arr(n), "{")
                   res = ZHRL.pre_parse(arr(n+1:length(arr)));
                   els{end+1} = res{1};
                   n = n + res{2};
               elseif strcmp(arr(n), "}")                   
                   ret_arr = {els, n};
                   return;
               else
                   els{end+1} = char(arr(n));
               end
               
               n = n + 1;
            end
            
            ret_arr = els{1};
        end
    end
end
