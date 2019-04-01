function extrema = mt_getExtrema(varargin)
%gets all extreme values and then chooses the most prominent ones within a
%window of minimum period length
%% Metadata-----------------------------------------------------------
% Dagmar Krefting, 16.2.2015, dagmar.krefting@htw-berlin.de
% Version: 1.1
%-----------------------------------------------------------

% cwlVersion: v1.0-extended
% class: matlabfunction
% baseCommand: mt_getExtrema
%
% inputs:
%   data:
%     type: matlabfloatarray
%     inputBinding:
%       prefix: data
%     doc: "1-dimensional float array"
%   sf:
%     type: float?
%     inputBinding:
%       prefix: sf
%     doc: "sampling frequency in Hz. Default: 1 Hz"
%   mp:
%     type: float?
%     inputBinding:
%       prefix: mp
%     doc: "minimum period of signal in seconds. Default 1 sec"
%   debug:
%     type: boolean?
%     inputBinding:
%       prefix: debug
%     doc: "Debug mode - basically some output messages. Default: false"
%
% outputs:
%   extrema:
%     type: matlabfloatarray
%     outputBinding:
%       glob: "*_getTDS.mat"
%     doc: "nx4-matrix with extreme values,cols:,1: location maximum,2: value maximum,3: location minimum,4: value minimum "
%------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Code starts here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 0. Parse Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% required input
myinput.data = NaN;
% number of samples to be averaged
myinput.sf = 1;
% dimension to be averaged
myinput.mp = 1;
% dimension to be averaged
myinput.debug = 0;

try
    myinput = mt_parameterparser('myinputstruct',myinput,'varargins',varargin);
catch ME
    disp(ME)
    return
end

if (myinput.debug)
    myinput
end


%% find maxima

%windowlength in samples, where only one maximum should appear
d=myinput.mp*myinput.sf;

%get size of dataset
dim = size(myinput.data);

%get sign of gradients from time series
signal_grad_sign = sign(diff(myinput.data));

%allocate buffer, based on minimum period
nmax_extrema = ceil(length(myinput.data)/d);
%row:extrema, col: maxindex maxvalue minindex minvalue
%extrema = ones(nmax_extrema,,4);

extrema_temp = zeros(nmax_extrema,4);
%loopindex
l = 1;
    %loop over time
    for k = 1:dim(1)-2
        %detect maxima
        %change from positive to zero or negative gradient
        if ((signal_grad_sign(k) ==1) && (signal_grad_sign(k+1) < 1))
            %the maximum sample is one ahead the gradient, therefore k+1
            extrema_temp(l,1) = k+1;
            extrema_temp(l,2) = myinput.data(k+1,1);
            l = l+1;
        %detect minima
        %change from zero or negative gradient to positive gradient
        elseif ((signal_grad_sign(k) < 1) && (signal_grad_sign(k+1) == 1))
              extrema_temp(l,3) = k+1;
              extrema_temp(l,4) = myinput.data(k+1);
        end        
    end
    %clip extrema_temp
    %get maximum index for maxima :-)
    [~,I] = max(extrema_temp(:,1));
    extrema_temp = extrema_temp(1:I,:);
    %loop over all maxima
    m = 1;
    %m must be smaller than the length of extrema
    while (m < length(extrema_temp(:,1)))
        %look if distance is too short
        if (extrema_temp(m+1,1)-extrema_temp(m,1) < d)
            %find larger maximum
            %first maximum is larger
            if (extrema_temp(m,2) >= extrema_temp(m+1,2))
                %check for smaller minimum for following maximum
                if (m+2 <= length(extrema_temp(:,1)))
                    if (extrema_temp(m+1,4) < extrema_temp(m+2,4))
                    %copy smaller minimum
                    extrema_temp(m+2,3:4) = extrema_temp(m+1,3:4);
                    end
                end
                %delete smaller maximum value
                extrema_temp(m+1,:) = [];
            %second maximum is larger    
            else
                %both minima are possible, check for smaller minimum
                if (extrema_temp(m,4) < extrema_temp(m+1,4))
                    %copy smaller minimum
                    extrema_temp(m+1,3:4) = extrema_temp(m,3:4);
                end
                %delete smaller maximum
                extrema_temp(m,:) = [];
            end
        %if distance between maxima is okay, do nothing but increment    
        else    
            m = m+1;
        end
    end
    %get maximum index for maxima :-)
    [~,I] = max(extrema_temp(:,1));
    extrema = extrema_temp(1:I,:);    
end