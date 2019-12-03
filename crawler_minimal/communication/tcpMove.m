function result = tcpMove( primitive, percent, steps, arduinoURL)

  if nargin < 1
     error('Too few arguments'); 
  end
  if nargin == 1
      percent = 1.0;      
  end
  if nargin <= 2
      steps = 1; 
  end
  if nargin > 4
      error('Too much arguments')
  end  

  command = strcat('MOVE', ',', int2str(primitive), ',', ...
      int2str(percent), ',' , int2str(steps));

  try
      
      resultString = tcpIpClient(command);
  
      [z,y,x] = extractAngles(resultString);
      result = [z,y,x];
  catch       
    result = [0,0,0];    
  end
end

function [z,y,x] = extractAngles(str)
    values = split(str,',');    
    z = str2double(values(1)); 
    y = str2double(values(2));
    x = str2double(values(3));
end
