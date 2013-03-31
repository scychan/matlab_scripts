function r = dirchrnd(alpha,N)
% take a sample from a dirichlet distribution
%   alpha - parameter vector
%   N     - number of samples

alpha = horz(alpha);
p = length(alpha); % length of param vec
scale = 1; % arbitrary?
r = gamrnd(repmat(alpha,N,1), scale, N, p);
r = r ./ repmat(sum(r,2),1,p);

% 
% % SAMPLE_DIRICHLET Sample N vectors from Dir(alpha(1), ..., alpha(k))
% % theta = sample_dirichlet(alpha, N)
% % theta(i,j) = i'th sample of theta_j, where theta ~ Dir
%  
% % We use the method from p. 482 of "Bayesian Data Analysis", Gelman et al.
% % Author: Kevin Murphy (murphyk@cs.berkeley.edu)
%  
% k = length(alpha);
% theta = zeros(N, k);
% scale = 1; % arbitrary?
% for i=1:k
%   theta(:,i) = gamrnd(alpha(i), scale, N, 1);  
% end
% S = sum(theta,2); 
% theta = theta ./ repmat(S, 1, k);
