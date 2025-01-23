% Load the dataset
filename = 'tweets.xlsx';
data = readtable(filename, 'TextType', 'string');

% Creating a numeric feature based on text length
data.TextLength = strlength(data.Post);

% Preparing sentiment data
data.sentiment = repmat("negative", height(data), 1);
data.differenceFrom5 = data.a - 5; % Assuming 'a' contains sentiment scores
data.sentiment(data.differenceFrom5 > 0) = "positive";
data.sentiment = categorical(data.sentiment);
head(data)


% Split data into training and testing sets
cvp = cvpartition(data.sentiment, 'Holdout', 0.2);
dataTrain = data(cvp.training,:);
dataTest = data.Post(cvp.test);

% Splitting data into training and testing sets
cvp = cvpartition(data.sentiment, 'Holdout', 0.2);
XTrain = data.TextLength(cvp.training);
YTrain = data.sentiment(cvp.training);
XTest = data.TextLength(cvp.test);
YTest = data.sentiment(cvp.test);

% Initialize arrays to store accuracies and model names
modelNames = {'Decision Tree', 'SVM', 'Logistic Regression', 'KNN', 'Naive Bayes', 'LDA', 'QDA', 'Random Forest', 'GBM', 'AdaBoost'};
accuracies = zeros(length(modelNames), 1);

% Loop through each model, fit it, and predict test labels
for i = 1:length(modelNames)
    switch modelNames{i}
        case 'Decision Tree'
            model = fitctree(XTrain, YTrain);
            
        case 'SVM'
            model = fitcsvm(XTrain, YTrain, 'KernelFunction', 'linear');
            
        case 'Logistic Regression'
            YTrainNumeric = grp2idx(YTrain);
            [B,~] = mnrfit(XTrain, YTrainNumeric);
            prob = mnrval(B, XTest);
            [~,predNumeric] = max(prob, [], 2);
            pred = categorical(predNumeric, 1:2, {'negative', 'positive'});
            accuracies(i) = sum(pred == YTest) / numel(YTest);
            continue; % To skip the common prediction code below for this model
            
        case 'KNN'
            model = fitcknn(XTrain, YTrain);
            
        case 'Naive Bayes'
            model = fitcnb(XTrain, YTrain);
            
        case 'LDA'
            model = fitcdiscr(XTrain, YTrain);
            
        case 'QDA'
            model = fitcdiscr(XTrain, YTrain, 'DiscrimType', 'quadratic');
            
        case 'Random Forest'
            model = TreeBagger(50, XTrain, YTrain, 'Method', 'classification');
            
        case 'GBM'
            model = fitcensemble(XTrain, YTrain, 'Method', 'LogitBoost');
            
        case 'AdaBoost'
            model = fitcensemble(XTrain, YTrain, 'Method', 'AdaBoostM1');
    end
    
    % Predict and calculate accuracy for the common models
    if ~strcmp(modelNames{i}, 'Random Forest') % Random Forest uses different prediction syntax
        pred = predict(model, XTest);
    else
        pred = predict(model, XTest);
        pred = categorical(pred);
    end
    
    accuracies(i) = sum(pred == YTest) / numel(YTest);
end

% Sort and rank models by accuracy
[sortedAcc, sortIdx] = sort(accuracies, 'descend');
sortedNames = modelNames(sortIdx);

% Handle tied ranks
[uniqueAcc, ~, rank] = unique(sortedAcc);
rank = max(rank) - rank + 1;

% Display models ranked by accuracy
fprintf('Model Ranking by Accuracy:\n');
for i = 1:length(sortedNames)
    fprintf('%d. %s - Accuracy: %.4f\n', rank(i), sortedNames{i}, sortedAcc(i));
end

% Visualizing the decision tree
model = fitctree(XTrain, YTrain);
view(model, 'Mode', 'graph');

% To create a plot similar to the first image, you would calculate the cross-validation error
% for various numbers of terminal nodes (pruned trees)
leafs = logspace(1, 2, 10); % Choose a range for the number of leaf nodes
N = numel(leafs);
err = zeros(N,1);
for n=1:N
    t = fitctree(XTrain, YTrain, 'CrossVal', 'On', 'MinLeafSize', leafs(n));
    err(n) = kfoldLoss(t);
end

% Train the decision tree model on training data
treeModel = fitctree(XTrain, YTrain);

% View the decision tree
view(treeModel, 'Mode', 'graph');
