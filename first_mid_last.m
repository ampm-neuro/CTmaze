function sesh_rng = first_mid_last(number_of_sessions, learning_stage, discrete)
%outputs the sessions corresponding to each learning stage

if discrete == 1

    switch number_of_sessions
        case 0
            sesh_rng = nan;
        case 1
            switch learning_stage
                case 2.1
                    sesh_rng = 1;
                case 2.2
                    sesh_rng = nan;
                case 2.3
                    sesh_rng = nan;
            end
        case 2
            switch learning_stage
                case 2.1
                    sesh_rng = 1;
                case 2.2
                    sesh_rng = nan;
                case 2.3
                    sesh_rng = 2;
            end
        case 3
            switch learning_stage
                case 2.1
                    sesh_rng = 1;
                case 2.2
                    sesh_rng = 2;
                case 2.3
                    sesh_rng = 3;
            end
        case 4
            switch learning_stage
                case 2.1
                    sesh_rng = 1;
                case 2.2
                    sesh_rng = 2;
                case 2.3
                    sesh_rng = 4;
            end
        case 5
            switch learning_stage
                case 2.1
                    sesh_rng = 1;
                case 2.2
                    sesh_rng = 3;
                case 2.3
                    sesh_rng = 5;
            end
        case 6
            switch learning_stage
                case 2.1
                    sesh_rng = 1;
                case 2.2
                    sesh_rng = 3;
                case 2.3
                    sesh_rng = 6;
            end
        case 7
            switch learning_stage
                case 2.1
                    sesh_rng = 1;
                case 2.2
                    sesh_rng = 4;
                case 2.3
                    sesh_rng = 7;
            end
        case 8
            switch learning_stage
                case 2.1
                    sesh_rng = 1;
                case 2.2
                    sesh_rng = 4;
                case 2.3
                    sesh_rng = 8;
            end
        case 9
            switch learning_stage
                case 2.1
                    sesh_rng = 1;
                case 2.2
                    sesh_rng = 5;
                case 2.3
                    sesh_rng = 9;
        end
        case 10
            switch learning_stage
                case 2.1
                    sesh_rng = 1;
                case 2.2
                    sesh_rng = 6;
                case 2.3
                    sesh_rng = 10;
        end 
    end
   
elseif discrete == 0
    
    switch number_of_sessions
        case 0
            sesh_rng = nan;
        case 1
            switch learning_stage
                case 2.1
                    sesh_rng = 1;
                case 2.2
                    sesh_rng = nan;
                case 2.3
                    sesh_rng = nan;
            end
        case 2
            switch learning_stage
                case 2.1
                    sesh_rng = 1;
                case 2.2
                    sesh_rng = nan;
                case 2.3
                    sesh_rng = 2;
            end
        case 3
            switch learning_stage
                case 2.1
                    sesh_rng = 1;
                case 2.2
                    sesh_rng = 2;
                case 2.3
                    sesh_rng = 3;
            end
        case 4
            switch learning_stage
                case 2.1
                    sesh_rng = [1 2];
                case 2.2
                    sesh_rng = [ 3];
                case 2.3
                    sesh_rng = 4;
            end
        case 5
            switch learning_stage
                case 2.1
                    sesh_rng = [1 2];
                case 2.2
                    sesh_rng = [3];
                case 2.3
                    sesh_rng = [4 5];
            end
        case 6
            switch learning_stage
                case 2.1
                    sesh_rng = [1 2];
                case 2.2
                    sesh_rng = [3 4];
                case 2.3
                    sesh_rng = [5 6];
            end
        case 7
            switch learning_stage
                case 2.1
                    sesh_rng = [1 2 3];
                case 2.2
                    sesh_rng = [4 5];
                case 2.3
                    sesh_rng = [6 7];
            end
        case 8
            switch learning_stage
                case 2.1
                    sesh_rng = [1 2 3];
                case 2.2
                    sesh_rng = [4 5 6];
                case 2.3
                    sesh_rng = [7 8];
            end
        case 9
            switch learning_stage
                case 2.1
                    sesh_rng = [1 2 3];
                case 2.2
                    sesh_rng = [4 5 6];
                case 2.3
                    sesh_rng = [7 8 9];
            end
        case 10
            switch learning_stage
                case 2.1
                    sesh_rng = [1 2 3];
                case 2.2
                    sesh_rng = [4 5 6 7];
                case 2.3
                    sesh_rng = [8 9 10];
        end
    end
else
    error('enter discrete or no')
end

end