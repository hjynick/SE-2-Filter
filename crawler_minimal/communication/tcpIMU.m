function resultArray = tcpIMU()

    if nargin > 0
        error('Too much arguments')
    end
    
    httpCommand = 'IMU';
    
    try
        rawResult = tcpIpClient(httpCommand);
        [z,y,x] = extractAngles(rawResult);
        resultArray = rad2deg([z,y,x]);                      
    catch
        resultArray = [0,0,0];
        return;
    end        
end

function [z,y,x] = extractAngles(str)
    values = split(str,',');    
    z = str2double(values(1)); 
    y = str2double(values(2));
    x = str2double(values(3));
end
