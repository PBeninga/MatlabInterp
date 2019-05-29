classdef AppC < ExprC
   properties
      Func
      Args
   end
   methods
      function obj = AppC(fun, arg)
         if nargin == 2
            if isa(fun, "ExprC") %&& iscellstr(arg)
               obj.Func = fun;
               obj.Args = arg;
            else
               error('Bad AppC Args')
            end
         end
      end
   end
end