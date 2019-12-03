function returnValues = tcpUS( sideID, numberScans, arduinoUrl )
%tcpUS Calls the US-Sensor with sideID and does numberScans scans
%   This method calls httpClient for scanning. If there are only two parameters
%   given, the stadard url calling the arduino will be used. If you want to use
%   a specific url to call the crawler, you have to pass all three arguments.
%   Normally, the function-call is done in less than five seconds.
%   Trying to do more than 40 (estimation) scans can result in an empty
%   result. This is caused by the arduino.
%   sideID:         number from 0 to 3 encoding the direction of the US-Sensor
%   numberScans:    number of performed scans
%   arduinoUrl:     (optimal) url used to call the arduino.

    if nargin < 2
        error('Too few arguments')
    end

    if nargin > 3
        error('Too much arguments')
    end

    httpCommand = strcat('US', ',', int2str(sideID), ',', int2str(numberScans));

    if nargin == 2
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
    returnValues = [];
    
    nulls = 0;
    
    for index = 1 : numel(resultArray)
        tmp = str2double(resultArray(index));
        if tmp < 0.0001
            nulls = nulls +1;
        else
            returnValues(index) = tmp;
        end
    end
    
    
    %0.00 durch inf ändern inf
%    resultArray(resultArray == '0.00') = inf;
    if nulls > 0
        disp(nulls);
    end
    
end
 