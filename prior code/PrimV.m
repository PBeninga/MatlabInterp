classdef PrimV < Value
   properties
      Value
   end
   methods
      function obj = PrimV(val)
         if nargin == 1
            if ischar(val)
               obj.Value = val;
            else
               error('Value must be char')
            end
         end
      end
   end
end