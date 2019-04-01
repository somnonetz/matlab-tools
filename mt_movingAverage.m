function [result,delay,movStd] = mt_movingAverage(varargin)
%moving average over time data, pads data on both ends to fit original length
%% Metadata-----------------------------------------------------------
% cwlVersion: v1.0-extended
% class: matlabfunction
% baseCommand: mt_movingAverage
%
% inputs:
%   data:
%     type: File
%     inputBinding:
%       prefix: data
%     doc: "1- or 2-dimensional float array"
%   ns:
%     type: integer?
%     inputBinding:
%       prefix: ns
%     doc: "number of samples to be averaged. Default: 3"
%   dim:
%     type: integer?
%     inputBinding:
%       prefix: dim
%     doc: "dimension of the array, that should be averaged. Default: 1(rows)"
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
%       glob: "*_getTDS.mat"
%     doc: "Matlab data file (.mat) containing results of a Time-Delay-Stability (TDS) analysis performed on a Polysomnography in EDF format. File can be loaded in Matlab and Octave environments."
%   tds_all:
%     type: File?
%     outputBinding:
%       glob: "*_getTDS_all.mat"
%     doc: "Matlab data file (.mat) containing results of a Time-Delay-Stability (TDS) analysis performed on a Polysomnography in EDF format. File can be loaded in Matlab and Octave environments. The tds_all file contains more Matlab objects than the tds file."
%
%   s:author:
%     - class: s:Person
%       s:identifier:  https://orcid.org/0000-0002-7238-5339
%       s:email: mailto:dagmar.krefting@htw-berlin.de
%       s:name: Dagmar Krefting
% 
%   s:dateCreated: "2019-01-12"
%   s:license: https://spdx.org/licenses/Apache-2.0 
% 
%   s:keywords: edam:topic_3063, edam:topic_2082
%     doc: 3063: medical informatics, 2082: matrix
%   s:programmingLanguage: matlab
% 
%   $namespaces:
%     s: https://schema.org/
%     edam: http://edamontology.org/
% 
%   $schemas:
%     - https://schema.org/docs/schema_org_rdfa.html
%     - http://edamontology.org/EDAM_1.18.owl


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
myinput.ns = 3;
% dimension to be averaged
myinput.dim = 1;
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

%% calculate moving average
%number of samples excluding actual sample
ns = myinput.ns-1;

%dimensions of datarecord
% transpose to have the signals in first dimension
if (myinput.dim == 2); myinput.data = myinput.data'; end

dim = size(myinput.data);
%length of datarecord (number of rows)
l = dim(1);
%allocate buffer
result = zeros(l-ns,dim(2));

%length of datarecord is supposed to be on dim 1
for i = 1:l-ns
    result(i,:) = mean(myinput.data(i:i+ns,:));
    movStd(i,:) = std(myinput.data(i:i+ns,:));
end

%delay
delay = floor(ns/2);

%pad result with constant values (first and last averaged value
result = [repmat(result(1,:),delay,1); result; repmat(result(end,:),delay,1)];

%check for dimensions
if (myinput.dim == 2); result = result'; end
end
