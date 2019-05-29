classdef Environment
    properties
      Map
   end
   methods
       
      function obj = Environment(keys, values)
         obj.Map = containers.Map(keys, values);
      end
      
      function retval = lookup(obj, lookfor)
         retvalcell = values(obj.Map, {lookfor});
         retval = retvalcell{1,1};          
      end
      
      function newenv = extend(obj, newkeys, newvals)
          newenv = Environment([obj.Map.keys newkeys], [obj.Map.values newvals]);
      end
   end
end