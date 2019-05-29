classdef NumV < Value
   properties
      Value 
   end
   methods
      function obj = NumV(val)
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