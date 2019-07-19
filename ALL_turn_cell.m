function [fstats_all, pvals_all, spec_all] = ALL_turn_cell
% computes relationship between firing rate and angular velocity for ever
% cell

% get all files
session_paths = get_file_paths('C:\Users\ampm1\Desktop\oldmatlab\neurodata');
session_paths = session_paths(contains(session_paths, '\1'));

% constrain by type of session
%session_paths = session_paths(contains(session_paths, 'overtraining'));
session_paths = session_paths(contains(session_paths, 'continuous') | contains(session_paths, 'overtraining'));
%session_paths = session_paths(contains(session_paths, 'acclimation'));

% set figure
%figure; hold on

% preallocate output
fstats_all = [];
pvals_all = [];
spec_all = [];

% iterate through sessions
for isesh = 1:length(session_paths)
    
   % load session 
   load(session_paths{isesh}, 'eptrials', 'clusters')
    
   % compute statistics
   [fstats_sesh, pvals_sesh] = session_turn_cell(eptrials, clusters(:,1));
   [spec_sesh] = session_turn_cell_specificity(eptrials, clusters(:,1));
   
   % load output
   fstats_all = [fstats_all; fstats_sesh];
   pvals_all = [pvals_all; pvals_sesh];
   spec_all = [spec_all; spec_sesh(:)];
   
end

%{
figure; 
histogram(fstats_all, 0:2:60, 'normalization', 'probability')
ylabel('Proportion of neurons')
xlabel('Relationship btwn AngVeloc and FireRate (F-stat)')
set(gca,'TickLength',[0, 0]); box off; axis square

sig_prop = sum(pvals_all<0.05)/length(pvals_all);
title([num2str(sig_prop*100) '% pvals < 0.05'])
%}