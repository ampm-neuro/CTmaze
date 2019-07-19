function [clusters, eptrials] = loaddata(rat, session_type, session_number)
% loads data already processed by trials. This data is stored by rat
% number, session type, and session number within the nuerodata folder in
% the MATLAB folder.
%
%
% rat should be the rat number e.g., 1789
%
% session_type should be a number 1 2 or 3
%   1 = continuous
%   2 = overtraining
%   3 = delay
%
% session_number should be a number corresponding the session within that
%   session type for that rat. (For example, 5 would be the fifth session of
%   the session_type indicated by session_type. This is not necessarily the
%   fifth session over all, but may be the fifth overtraining session or the
%   fifth delay session.)

switch logical(true)
        
        case session_type == 1, session_type = 'continuous';
        case isequal(session_type, 'one'), session_type = 'continuous';
        case isequal(session_type, 'cont'), session_type = 'continuous';
            
        case session_type == 2, session_type = 'overtraining';
        case isequal(session_type, 'two'), session_type = 'overtraining';
        case isequal(session_type, 'ot'), session_type = 'overtraining';
        case isequal(session_type, 'overtrain'), session_type = 'overtraining';
        case isequal(session_type, 'asymptotic'), session_type = 'overtraining';
        case isequal(session_type, 'asymptote'), session_type = 'overtraining';
            
        case session_type == 3, session_type = 'delay';
        case isequal(session_type, 'three'), session_type = 'delay';
        case isequal(session_type, 'del'), session_type = 'delay';
            
        otherwise
            error ('Session_type not recognized')
end;

load(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(session_type),'/' ,num2str(session_number),'.mat'));

end