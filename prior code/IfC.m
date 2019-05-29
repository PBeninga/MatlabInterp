classdef IfC < ExprC
   properties
      Condition
      Left
      Right
   end
   methods
      function obj = IfC(con, lef, rig)
         if nargin == 3
            if isa(con, "ExprC") && isa(lef, "ExprC") && isa(rig, "ExprC")
               obj.Condition = con;
               obj.Left = lef;
               obj.Right = rig;
            else
               error('Bad IfC Args')
            end
         end
      end
   end
end