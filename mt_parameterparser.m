function [ myinputstruct ] = mt_parameterparser(varargin)
%reads varargins of a function and gives back the parsed parameters Compumedics dpsg files and converts in matlab struct
%
% cli:
%   cwlVersion: v1.0-extended
%   class: matlabfunction
%   baseCommand: [mandatoryStruct,optionlStruct] = mt_parameterparser(varargin)
%
%   inputs:
%     varargins:
%       type: matlabCellArray
%       inputBinding:
%         prefix: varargins
%       doc: "A matlab cell array containing the varargin of the calling function."
%     myinputstruct:
%       type: matlabStruct
%       inputBinding:
%         prefix: myinputstruct
%       doc: "The struct holding all input parameters. It must be named myinput!"
%     debug:
%       type: int?
%       inputBinding:
%         prefix: debug
%       doc: "if set to 1 debug information is provided. Default 0"
%
%   outputs:
%     myinputstruct:
%       type: matlabStruct
%       outputBinding:
%         glob: "*_getTDS.mat"
%       doc: "The struct holding all input parameters."

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 0. Input evaluation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Defaults
debug = 0;

% this is the last time I have to do it explicitely :-)

%size of varargin
m = size(varargin,2);

%if varargin present, check for keywords and get parameter
if m > 0
    %disp(varargin);
    for i = 1:2:m-1
        %varargins
        if strcmp(varargin{i},'varargins')
            varargins = varargin{i+1};
            %labels
        elseif strcmp(varargin{i},'myinputstruct')
            myinputstruct = varargin{i+1};
        elseif strcmp(varargin{i},'debug')
            debug = varargin{i+1};
        end
    end
end

%debug
if debug; disp('Starting mt_parameterparser.m'); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the struct fields
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%size of varargin*s*!
nv2 = size(varargins,2);
if debug, disp(nv2); end

%loop over variables
for i = 1:2:nv2-1
    if debug; disp(varargins{i}); end
    myinputstruct.(varargins{i}) = varargins{i+1};
end

% check for NaNs, indicating that required variables are not set
names = fieldnames(myinputstruct);
if debug; disp(names);end
for k = 1:length(names)
    %check if cell, because cells cannot be isnan
    if ~iscell(myinputstruct.(names{k}))
        if ~isstruct(myinputstruct.(names{k}))
            if isnan(myinputstruct.(names{k}))
                error('Required variable(s) missing, refer to documentation please!')
                return
            end
        end
    end
end







