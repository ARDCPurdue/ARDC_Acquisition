classdef Tube < handle
    properties(Access = private)
        response_mat;
    end
    
    %% public methods
    methods
        function SetResponse(self, response )
            self.response_mat(:,end+1) = response;
        end
        
        function output = GetResponseMat(self)
            output = self.response_mat;
        end
        
        function SetResponseMat(self, data )
            self.response_mat = data;
        end
        
        function output = GetAverage(self)
            output = mean(self.response_mat,2);
        end
    end
end


