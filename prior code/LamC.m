classdef LamC < ExprC
   properties
      Args
      Body
   end
   methods
      function obj = LamC(arg, bod)
         if nargin == 2
            if iscellstr(arg) && isa(bod, "ExprC")
               obj.Args = arg;
               obj.Body = bod;
            else
               error('Bad LamC Args')
            end
         end
      end
   end
end