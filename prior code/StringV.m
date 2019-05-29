classdef StringV < Value
   properties
      Value 
   end
   methods
      function obj = StringV(val)
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