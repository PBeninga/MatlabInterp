classdef BoolV < Value
   properties
      Value 
   end
   methods
      function obj = BoolV(val)
         if nargin == 1
            if islogical(val)
               obj.Value = val;
            else
               error('Value must be boolean')
            end
         end
      end
   end
end