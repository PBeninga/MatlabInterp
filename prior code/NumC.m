classdef NumC < ExprC
   properties
      Value 
   end
   methods
      function obj = NumC(val)
         if nargin == 1
            if isnumeric(val)
               obj.Value = val;
            else
               error('Value must be numeric')
            end
         end
      end
   end
end