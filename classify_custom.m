function [outclass, posterior] = classify(sample, training, group)
%CLASSIFY Discriminant analysis.
%   CLASS = CLASSIFY(SAMPLE,TRAINING,GROUP) classifies each row of the data
%   in SAMPLE into one of the groups in TRAINING.  SAMPLE and TRAINING must
%   be matrices with the same number of columns.  GROUP is a grouping
%   variable for TRAINING.  Its unique values define groups, and each
%   element defines which group the corresponding row of TRAINING belongs
%   to.  GROUP can be a categorical variable, numeric vector, a string
%   array, or a cell array of strings.  TRAINING and GROUP must have the
%   same number of rows.  CLASSIFY treats NaNs or empty strings in GROUP as
%   missing values, and ignores the corresponding rows of TRAINING. CLASS
%   indicates which group each row of SAMPLE has been assigned to, and is
%   of the same type as GROUP.
%
%   CLASS = CLASSIFY(SAMPLE,TRAINING,GROUP,TYPE) allows you to specify the
%   type of discriminant function, one of 'linear', 'quadratic',
%   'diagLinear', 'diagQuadratic', or 'mahalanobis'.  Linear discrimination
%   fits a multivariate normal density to each group, with a pooled
%   estimate of covariance.  Quadratic discrimination fits MVN densities
%   with covariance estimates stratified by group.  Both methods use
%   likelihood ratios to assign observations to groups.  'diagLinear' and
%   'diagQuadratic' are similar to 'linear' and 'quadratic', but with
%   diagonal covariance matrix estimates.  These diagonal choices are
%   examples of naive Bayes classifiers.  Mahalanobis discrimination uses
%   Mahalanobis distances with stratified covariance estimates.  TYPE
%   defaults to 'linear'.
%
%   CLASS = CLASSIFY(SAMPLE,TRAINING,GROUP,TYPE,PRIOR) allows you to
%   specify prior probabilities for the groups in one of three ways.  PRIOR
%   can be a numeric vector of the same length as the number of unique
%   values in GROUP (or the number of levels defined for GROUP, if GROUP is
%   categorical).  If GROUP is numeric or categorical, the order of PRIOR
%   must correspond to the ordered values in GROUP, or, if GROUP contains
%   strings, to the order of first occurrence of the values in GROUP. PRIOR
%   can also be a 1-by-1 structure with fields 'prob', a numeric vector,
%   and 'group', of the same type as GROUP, and containing unique values
%   indicating which groups the elements of 'prob' correspond to. As a
%   structure, PRIOR may contain groups that do not appear in GROUP. This
%   can be useful if TRAINING is a subset of a larger training set.
%   CLASSIFY ignores any groups that appear in the structure but not in the
%   GROUPS array.  Finally, PRIOR can also be the string value 'empirical',
%   indicating that the group prior probabilities should be estimated from
%   the group relative frequencies in TRAINING.  PRIOR defaults to a
%   numeric vector of equal probabilities, i.e., a uniform distribution.
%   PRIOR is not used for discrimination by Mahalanobis distance, except
%   for error rate calculation.
%
%   [CLASS,ERR] = CLASSIFY(...) returns ERR, an estimate of the
%   misclassification error rate that is based on the training data.
%   CLASSIFY returns the apparent error rate, i.e., the percentage of
%   observations in the TRAINING that are misclassified, weighted by the
%   prior probabilities for the groups.
%
%   [CLASS,ERR,POSTERIOR] = CLASSIFY(...) returns POSTERIOR, a matrix
%   containing estimates of the posterior probabilities that the j'th
%   training group was the source of the i'th sample observation, i.e.
%   Pr{group j | obs i}.  POSTERIOR is not computed for Mahalanobis
%   discrimination.
%
%   [CLASS,ERR,POSTERIOR,LOGP] = CLASSIFY(...) returns LOGP, a vector
%   containing estimates of the logs of the unconditional predictive
%   probability density of the sample observations, p(obs i) is the sum of
%   p(obs i | group j)*Pr{group j} taken over all groups.  LOGP is not
%   computed for Mahalanobis discrimination.
%
%   [CLASS,ERR,POSTERIOR,LOGP,COEF] = CLASSIFY(...) returns COEF, a
%   structure array containing coefficients describing the boundary between
%   the regions separating each pair of groups.  Each element COEF(I,J)
%   contains information for comparing group I to group J, defined using
%   the following fields:
%       'type'      type of discriminant function, from TYPE input
%       'name1'     name of first group of pair (group I)
%       'name2'     name of second group of pair (group J)
%       'const'     constant term of boundary equation (K)
%       'linear'    coefficients of linear term of boundary equation (L)
%       'quadratic' coefficient matrix of quadratic terms (Q)
%
%   For the 'linear' and 'diaglinear' types, the 'quadratic' field is
%   absent, and a row x from the SAMPLE array is classified into group I
%   rather than group J if
%         0 < K + x*L
%   For the other types, x is classified into group I if
%         0 < K + x*L + x*Q*x'
%
%   Example:
%      % Classify Fisher iris data using quadratic discriminant function
%      load fisheriris
%      x = meas(51:end,1:2);  % for illustrations use 2 species, 2 columns
%      y = species(51:end);
%      [c,err,post,logl,str] = classify(x,x,y,'quadratic');
%      gscatter(x(:,1),x(:,2),y,'rb','v^')
%
%      % Classify a grid of values
%      [X,Y] = meshgrid(linspace(4.3,7.9), linspace(2,4.4));
%      X = X(:); Y = Y(:);
%      C = classify([X Y],x,y,'quadratic');
%      hold on; gscatter(X,Y,C,'rb','.',1,'off'); hold off
%
%      % Draw boundary between two regions
%      hold on
%      K = str(1,2).const;
%      L = str(1,2).linear;
%      Q = str(1,2).quadratic;
%      % Plot the curve K + [x,y]*L + [x,y]*Q*[x,y]' = 0:
%      f = @(x,y) K + L(1)*x + L(2)*y ...
%                   + Q(1,1)*x.^2 + (Q(1,2)+Q(2,1))*x.*y + Q(2,2)*y.^2;
%      ezplot(f,[4 8 2 4.5]);
%      hold off
%      title('Classification of Fisher iris data')
%

% grp2idx sorts a numeric grouping var ascending, and a string grouping
% var by order of first occurrence
[gindex,groups,glevels] = grp2idx(group);
nans = find(isnan(gindex));
if ~isempty(nans)
    training(nans,:) = [];
    gindex(nans) = [];
end
ngroups = length(groups);
gsize = hist(gindex,1:ngroups);
nonemptygroups = find(gsize>0);
nusedgroups = length(nonemptygroups);



[n,d] = size(training);

m = size(sample,1);

prior = gsize(:)' / sum(gsize);
    
mm = m;

gmeans = NaN(ngroups, d);
for k = nonemptygroups
    gmeans(k,:) = mean(training(gindex==k,:),1); %mean firing rate for each pixle
end

D = NaN(mm, ngroups);


% Pooled estimate of variance: SigmaHat = diag(S.^2)
S = std(training - gmeans(gindex,:)) * sqrt((n-1)./(n-nusedgroups)); %how much firing rates vary at locations (in training)

logDetSigma = 2*sum(log(S)); % avoid over/underflow


% MVN relative log posterior density, by group, for each sample
for k = nonemptygroups
    A=bsxfun(@times, bsxfun(@minus,sample,gmeans(k,:)),1./S); %how far is each sample rate from mean of training at each location
    D(:,k) = log(prior(k)) - .5*(sum(A .* A, 2) + logDetSigma); 
end


% find nearest group to each observation in sample data
[maxD,outclass] = max(D, [], 2);


% POSTERIOR   
% Bayes' rule: first compute p{x,G_j} = p{x|G_j}Pr{G_j} ...
% (scaled by max(p{x,G_j}) to avoid over/underflow)
P = exp(bsxfun(@minus,D(1:m,:),maxD(1:m)));

sumP = nansum(P,2);

% ... then Pr{G_j|x) = p(x,G_j} / sum(p(x,G_j}) ...
% (numer and denom are both scaled, so it cancels out)

posterior = bsxfun(@times,P,1./(sumP));


%Convert outclass back to original grouping variable type
 outclass = glevels(outclass,:);



