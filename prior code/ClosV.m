classdef ClosV < Value
   properties
      Args
      Body
      Env 
   end
   methods
      function obj = ClosV(arg, bod, env)
         if nargin == 3
            if iscellstr(arg) && isa(bod, "ExprC") && isa(env, "Environment")
               obj.Args = arg;
               obj.Body = bod;
               obj.Env = env;
            else
               error('Bad ClosV Args')
            end
         end
      end
   end
end