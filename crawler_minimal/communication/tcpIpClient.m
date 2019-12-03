function result = tcpIpClient(commandString, ip)
%TCPIP Executes a tcpip communication with the arduino
%   This method is used to communicate with the arduino.
%   
%   Paramters:
%   params:     URL-Params, see documentation of the crawler-api for more
%               informations
%   ip:        (optimal parameter) url used to call the arduino. If not
%               given, a default-value will be used

  TimeOut  = 10; %sek
  if nargin < 1
     error('No parameters given');
  end

  %Some default-values
  if nargin == 1
      ip = '192.168.240.1';
  end

  if nargin > 2
      error('Too much parameters');
  end
  
  t = tcpip(ip,5005);
  fopen(t);
  fwrite(t, commandString);
  start = clock;
  timeOutErr = 0;
  
  while t.BytesAvailable == 0
    if(etime(clock,start)>TimeOut)
        timeOutErr = 1;
        break;
    end
  end  
  
  if(timeOutErr == 0)
      retval = fread(t,t.BytesAvailable);
      result = string(native2unicode(retval).');
  end
  fclose(t);   
end