function returnValues = tcpIR(arduinoUrl)   

    if nargin > 1
        error('Too much arguments')
    end

    httpCommand = strcat('IR');

    if nargin == 0
      rawResult = tcpIpClient(httpCommand);
    else
      rawResult = tcpIpClient(httpCommand, arduinoUrl);
    end

    rawNumbers = rawResult(1:end);
    
    try
        resultArray = strsplit(rawNumbers, ',');
    catch
        returnValues = [];
        return;
    end
    
    returnValues = inf(4, 2);  
    
    
    nElements = numel(resultArray);
    if nElements <= 1 
        return;       
    end
    
    for i = 1:nElements/2
        for j = 1:2
            tmp = str2double(resultArray((i-1) * 2 + j));            
            returnValues(i,j) = tmp;            
        end        
    end       
    
end
 