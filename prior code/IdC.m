classdef IdC < ExprC
   properties
      Value 
   end
   methods
      function obj = IdC(val)
         if nargin == 1
            if ischar(val)
               obj.Value = val;
            else
                display(val);
               error('Value must be char')
            end
         end
      end
   end
end