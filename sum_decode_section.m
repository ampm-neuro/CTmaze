function [summed] = sum_decode_section(inpt_mtx, scheme)
%sums ouput from decoder by unfolded section (combined stem) based on the
%trial type and the input scheme, which indicate what to sum
%
%THIS ALWAYS SUBTRACTS RIGHT FROM LEFT, indicating how left-like the dec is
%
%scheme =
%1 for approach only
%2 for reward only
%3 for return only
%4 for approach and reward
%5 for approach, reward, and return
%
%ouputs the total decode to the sections associated with the CORRECT
%respond MINUS the total decode to the sections associated with the ERROR
%response

switch scheme
        
        %approach only
        case 1

            summed = inpt_mtx(:,4) - inpt_mtx(:,5);

        %reward only
        case 2

            summed = inpt_mtx(:,6) - inpt_mtx(:,7);

        %return only
        case 3

            summed = inpt_mtx(:,8) - inpt_mtx(:,9);
        
        %approach and reward
        case 4

            summed = (inpt_mtx(:,4) + inpt_mtx(:,6)) - (inpt_mtx(:,5) + inpt_mtx(:,7));

        %approach, reward, and return
        case 5
            
            summed = (inpt_mtx(:,4) + inpt_mtx(:,6) + inpt_mtx(:,8)) - (inpt_mtx(:,5) + inpt_mtx(:,7) + inpt_mtx(:,9));

        otherwise
            error('incorrect summation scheme input')

end


 
end