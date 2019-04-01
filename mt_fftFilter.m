function [result,f,fftdata] = mt_fftFilter(varargin)
% removes frequencycomponents from signal
%% Metadata-----------------------------------------------------------
% cwlVersion: v1.0-extended
% class: matlabfunction
% baseCommand: mt_fftFilter
%
% inputs:
%   data:
%     type: numerical array
%     inputBinding:
%       prefix: data
%     doc: "1-dimensional float array"
%   sf:
%     type: double?
%     inputBinding:
%       prefix: sf
%     doc: "sampling frequency in Hertz. Default: 1 Hz"
%   filterfreqs:
%     type: double array mx2
%     inputBinding: 
%       prefix: filterfreqs
%     doc: "Array containing the frequency components to be removed. First column: startfreq, second column stopfreq, low pass filter goes until end. Example: [0,0.032;50,50;70,end]"
%   debug:
%     type: boolean?
%     inputBinding:
%       prefix: debug
%     doc: "Debug mode - basically some output messages. Default: false"
%
% outputs:
%   result:
%     type: float?
%     outputBinding:
%       glob: 
%     doc: "filtered signal"
%   tds_all:
%     type: File?
%     outputBinding:
%       glob: "*_getTDS_all.mat"
%     doc: "Matlab data file (.mat) containing results of a Time-Delay-Stability (TDS) analysis performed on a Polysomnography in EDF format. File can be loaded in Matlab and Octave environments. The tds_all file contains more Matlab objects than the tds file."
%------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Code starts here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 0. Parse Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% required input
%signal
myinput.data = NaN;
% Frequency components to be removed
myinput.filterfreqs = NaN;
% number of samples to be averaged
myinput.sf = 1;
% Debug
myinput.debug = 0;

varargin

try
    myinput = mt_parameterparser('myinputstruct',myinput,'varargins',varargin,'debug',1);
catch ME
    disp(ME)
    return
end

if (myinput.debug)
    myinput
end

%% create fft, results in a complex array with
fftdata = fft(myinput.data);

%% get number of samples
sl = fix(length(fftdata)/2);
%frequency axis
f = (0:sl-1)*myinput.sf/(2*sl);

%find the components
%number of components = number of rows
ncomps = size(myinput.filterfreqs,1);
%loop over components and remove them 
for i = 1:ncomps
    %find start
    [minval,startindex] = min(abs(f-myinput.filterfreqs(i,1)));
    %find end
    % check for keyword inf
    if isinf(myinput.filterfreqs(i,2))
        stopindex = sl;
    else
    [minval,stopindex] = min(abs(f-myinput.filterfreqs(i,2)));
    end
    %remove the components
    fftdata(startindex:stopindex) = complex(0,0);
    %remove components in complex conjugates
    fftdata(sl+sl-stopindex+1:sl+sl-startindex+1) = complex(0,0);
end

result = real(ifft(fftdata));
