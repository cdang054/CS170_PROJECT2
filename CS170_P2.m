% CDANG054 CS170 Project 2 - Add finishing touches - FINAL

% ----- Feature Selection With Nearest Neighbor ----------------------------------------------------------------------------------------------
% Code up nearest neighbor classifier
% First Search: Forward Selection (given by Dr. Keogh)
% Second Search: Backward Elimination - Search tree from bottom to top, start with all features and eliminate one by one

% Dr. Keogh provided function feature_search_demo(data)
% Write it up and make sure it works!   

% My data sets:
% CS170_Small_Data__57.txt (6 features)
% CS170_Large_Data__95.txt (40 features)
% --------------------------------------------------------------------------------------------------------------------------------------------

function CS170_P2()

    disp('Welcome to the Feature Selection Algorithm.');

    % Prompting the user to enter which data file to use, the user input will be a string/text
    prompt1 = "Type in the name of the file to test ('CS170_Small_Data__57' or 'CS170_Large_Data__95'): ";
    file = {input(prompt1, "s")};
    file = strcat(file, ".txt");
    %disp(file);
    data = load(file);
    %disp(data);

    num_features = size(data, 2) - 1;
    num_instances = size(data, 1);
    
    %disp(num_features);
    %disp(num_instances);

    
    % Prompting the user to enter which alorithm to run
    disp("Type the number of the algorithm you want to run ");
    disp("     1) Forward Selection");
    disp("     2) Backward Elimination");
    prompt2 = newline;
    algorithm = input(prompt2, "s");

    %disp(["This dataset has ", num_features, " features (not including the class attribute), with ", num_instances, " instances."]);
    fprintf('This dataset has %d features (not including the class attribute), with %d instances.', num_features, num_instances);

    if algorithm == '1'
        feature_search_demo(file);
    elseif algorithm == '2'
        feature_search_backward_elimination(file);
    end
  

end





function feature_search_demo(data) % This is forward search
    
    % start time to record total execution time
    tic
    
    data = load(data);

    current_set_of_features = []; % INIT an empty set. As the tree is traversed, at each level each feature has its accuracy tested and the highest accuracy feature gets added to this set
    best_set_of_features = []; % INIT an empty set. Store the best subset in here while the search continues
    actual_best_accuracy = 0; % Stores the actual best accuracy of the best subset of the whole dataset

    %disp(['Running nearest neighbor with all ', size(data, 2) - 1, ' features, using "leaving-one-out" evaluation, i get an ']);
    fprintf('Running nearest neighbor with all %d features, using "leaving-one-out" evaluation, i get an \n', (size(data, 2) - 1));

    accuracy = leave_one_out_cross_validation(data, current_set_of_features, []); % Running nearest neighbor with all n features, using "leaving-one-out" evaluation

    %disp(['accuracy of ', accuracy * 100, '%']);
    fprintf('accuracy of %.1f%% \n', accuracy * 100);
    %disp('Beginning search.');
    fprintf('\nBeginning search.\n');

    for i = 1: size(data, 2) - 1 % Iterate thorugh each level of the tree
        %disp(['On the ', num2str(i), 'th level of the search tree'])
        feature_to_add_at_this_level = [];
        best_so_far_accuracy = 0;

        for k = 1: size(data, 2) - 1 % Iterate through each feature in this level
            if isempty(intersect(current_set_of_features, k)) % If the feature k has already been added, it shouldn't be added again
                accuracy = leave_one_out_cross_validation(data, current_set_of_features, k+1); % Calling the function that does the accuracy computation of the feature(s)
                %disp(['Using feature(s) {', num2str([current_set_of_features, k]), '} accuracy is ', accuracy * 100, '%']);
                fprintf('Using feature(s) {%s} accuracy is %.1f%% \n', num2str([current_set_of_features, k]), accuracy * 100);

                if accuracy > best_so_far_accuracy % Keep track of the highest accuracy feature in this level. The best accuracy will be added to the current set
                    best_so_far_accuracy = accuracy;
                    feature_to_add_at_this_level = k;
                end

            end


        end

        current_set_of_features(i) = feature_to_add_at_this_level; % Add the feature with the best accuracy to current set
        %disp(['Feature set {', num2str(current_set_of_features, '} was best, accuracy is ', best_so_far_accuracy * 100, '%%']);
        fprintf('Feature set {%s} was best, accuracy is %.1f%% \n', num2str(current_set_of_features), best_so_far_accuracy * 100);

        if best_so_far_accuracy > actual_best_accuracy % To get the subset with the best accuracy keep track of the best in the level and the best overall
            actual_best_accuracy = best_so_far_accuracy;
            best_set_of_features = current_set_of_features; % Updating the best accuracy means a new subset is the new best, so update best_set_of_features
        end


    end
    %disp(['Finished search!! The best feature subset is {', num2str(current_set_of_features), '}, which has an accuracy of ', best_so_far_accuracy * 100, '%']);
    fprintf('Finished search!! The best feature subset is {%s}, which has an accuracy of %.1f%% \n', num2str(best_set_of_features), actual_best_accuracy * 100);
    
    % stop timer
    toc

end






function feature_search_backward_elimination(data) % This is backward search

    % start time to record total execution time
    tic
    
    data = load(data);

    current_set_of_features = 2:size(data,2); % INIT the set to have all of the features. Features starts at column 2
    current_set_of_features = current_set_of_features - 1;
    %disp(current_set_of_features); % for testing
    best_set_of_features = current_set_of_features;
    actual_best_accuracy = 0;

    %disp(['Running nearest neighbor with all ', size(data, 2) - 1, ' features, using "leaving-one-out" evaluation, i get an ']);
    fprintf('Running nearest neighbor with all %d features, using "leaving-one-out" evaluation, i get an \n', (size(data, 2) - 1));

    accuracy = leave_one_out_cross_validation(data, current_set_of_features, []); % Running nearest neighbor with all n features, using "leaving-one-out" evaluation

    %disp(['accuracy of ', accuracy * 100, '%']);
    fprintf('accuracy of %.1f%% \n', accuracy * 100);
    %disp('Beginning search.');
    fprintf('\nBeginning search.\n');

    for i = 1: size(data, 2) - 1 % Iterate thorugh each level of the tree
        %disp(['On the ', num2str(i), 'th level of the search tree'])
        feature_to_remove_at_this_level = []; % With backward search, start with all features and eliminate 1 at each level instead of adding
        best_so_far_accuracy = 0;

        for k = 1: size(current_set_of_features, 2) % Iterate through each feature in this level
            %disp(['--Considering removing the ', num2str(current_set_of_features(k)), ' feature'])
            new_set = setdiff(current_set_of_features, current_set_of_features(k)); % Create a new set without the current feature to test accuracy without that feature
            accuracy = leave_one_out_cross_validation(data, new_set, []); % Calling the function that does the accuracy computation of the feature(s). Leaving the feature_to_add input blank since this function will not be adding
            %disp(['Using feature(s) {', num2str([new_set, k]), '} accuracy is ', accuracy * 100, '%']);
            fprintf('Using feature(s) {%s} accuracy is %.1f%% \n', num2str(new_set), accuracy * 100);

            if accuracy > best_so_far_accuracy % Keep track of the highest accuracy of the set without a feature. The best accuracy will be determine which one to remove
                best_so_far_accuracy = accuracy;
                feature_to_remove_at_this_level = current_set_of_features(k);
            end


        end

        
        current_set_of_features = setdiff(current_set_of_features, feature_to_remove_at_this_level); % Remove the feature from the current set 
        %disp(['Feature set {', num2str(current_set_of_features, '} was best, accuracy is ', best_so_far_accuracy * 100, '%']);
        fprintf('Feature set {%s} was best, accuracy is %.1f%% \n', num2str(current_set_of_features), best_so_far_accuracy * 100);

        if best_so_far_accuracy > actual_best_accuracy % To get the subset with the best accuracy keep track of the best in the level and the best overall
            actual_best_accuracy = best_so_far_accuracy;
            best_set_of_features = current_set_of_features; % Updating the best accuracy means a new subset is the new best, so update best_set_of_features
        end



    end
    %disp(['Finished search!! The best feature subset is {', num2str(current_set_of_features), '}, which has an accuracy of ', best_so_far_accuracy * 100, '%']);
    fprintf('Finished search!! The best feature subset is {%s}, which has an accuracy of %.1f%% \n', num2str(best_set_of_features), actual_best_accuracy * 100);

    % stop timer
    toc

end






function accuracy = leave_one_out_cross_validation(data, current_set_of_features, feature_to_add)

    % Edit data to exclude features not being looked at, set all to 0
    % All features in column 2-end
    all_features = 2:size(data, 2);
    all_features = all_features - 1; % The features start at column 2, but names start at 1
    % disp(all_features); % for testing
    % Add feature_to_add to current_set_of_features
    % disp(current_set_of_features); % for testing
    current_set_of_features = [current_set_of_features, feature_to_add-1]; % subtracted 1 from feature to add because the true index is different from the feature number
    % disp(current_set_of_features); % for testing
    % If the feature isn't in the current_set_of_features that feature needs to be excluded. get the difference between all of the features and the current set
    features_to_exclude = setdiff(all_features, current_set_of_features);
    % disp(features_to_exclude); % for testing
    % Set the exclued columns to 0
    data(:, features_to_exclude + 1) = 0;
    % disp(data); % for testing


    % Begin nearest neighbor
    number_correctly_classified = 0;


    for i = 1:size(data, 1) % Iterate through data
        object_to_classify = data(i, 2:end);
        label_object_to_classify = data(i, 1); % Retrieve the class of the data
        
        % Initializing distance and index variables. set to inf so they will be updated through comparison operation, anything is less than inf
        nearest_neighbor_distance = inf;
        nearest_neighbor_location = inf;

        for k = 1:size(data,1) % Nearest neighbor for the point, do not include the point itself
            if k~= i
                distance = sqrt(sum((object_to_classify - data(k, 2:end)).^2));
                if distance < nearest_neighbor_distance % Update nearest neighbor with closest distance
                    nearest_neighbor_distance = distance;
                    nearest_neighbor_location = k;
                    nearest_neighbor_label = data(nearest_neighbor_location, 1); % Get class of the nearest neighbor
                end
            end
        end

        %disp(['Object ', num2str(i), ' is class ', num2str(label_object_to_classify)]);
        %disp(['Its nearest_neighbor is ', num2str(nearest_neighbor_location), ' which is in class ', num2str(nearest_neighbor_label)]);

        if label_object_to_classify == nearest_neighbor_label % Check if the true class matches the class given by nearest neighbor
           number_correctly_classified = number_correctly_classified + 1;
        end


   
    end
    accuracy = number_correctly_classified / size(data, 1); % Accuracy of classification
    %disp(accuracy);
    

end    


% ---------------- done!!!!!! ---------------- %