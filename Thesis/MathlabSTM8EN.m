% Read the data from an Excel file
filename = 'tweets.xlsx';
data = readtable(filename, 'TextType', 'string');

% Calculate the difference from a reference value (e.g., 5) for sentiment analysis
data.differenceFrom5 = data.a - 5;

% Initialize the sentiment column based on the differenceFrom5
data.sentiment = repmat("positive", height(data), 1);
data.sentiment(data.differenceFrom5 > 0) = "negative";

% Rename column 'v' to 'virality' for clarity
data.virality = data.v;

% Calculate weighted sentiment by multiplying the difference with virality
data.weightedSentiment = data.differenceFrom5 .* data.virality;

% Determine sentiment strength based on weighted sentiment
data.sentimentStrength = repmat("neutral", height(data), 1);
data.sentimentStrength(data.weightedSentiment > 0) = "positive";
data.sentimentStrength(data.weightedSentiment < 0) = "negative";

% Ensure 'sentiment' column is treated as categorical for analysis
data.sentiment = categorical(data.sentiment);

% Preprocess the text data from the 'Post' column
documents = preprocessText(data.Post); % Note: Function is defined at the end

% Split data into training and testing sets
cvp = cvpartition(data.sentiment, 'Holdout', 0.2);
dataTrain = data(cvp.training,:);
dataTest = data(cvp.test,:);

% Generate a word cloud from the training data text
figure;
wordcloud(dataTrain.Post); % Assuming 'Post' column contains text data
title("Word Cloud of Training Data Tweets");

% Create a figure for the histogram of sentiment distribution
f = figure;
f.Position(3) = 1.5*f.Position(3);

% Draw the histogram for the sentiment distribution
h = histogram(data.sentiment);
xlabel("Sentiment");
ylabel("Frequency");
title("Sentiment Distribution");

% Adjust the colors of the histogram, if desired
h.FaceColor = [0 0.5 0.5];

% Calculate the length of posts in number of characters
data.postLength = strlength(data.Post); % Replace 'Text' with the actual name of your text column

% Group data by sentiment and calculate the average length of posts
summaryTable = groupsummary(data, 'sentiment', 'mean', 'postLength');

% Display the summary table
disp(summaryTable);

% Calculate the length of each tweet
data.TweetLength = strlength(data.Post); % or use your custom function to count words

% Create a figure to visualize the distributions
figure;
f.Position = [100, 100, 1049, 895]; % Adjust as needed

% Find unique sentiment categories
uniqueSentiments = categories(data.sentiment);

% Loop through each sentiment category to plot distributions
for i = 1:length(uniqueSentiments)
    % Select tweet lengths for the current sentiment category
    currentSentimentLengths = data.TweetLength(data.sentiment == uniqueSentiments(i));
    
    % Subplot for each sentiment category
    subplot(length(uniqueSentiments), 1, i);
    histogram(currentSentimentLengths);
    title(['Tweet Length Distribution - ', char(uniqueSentiments(i))]);
    xlabel('Tweet Length');
    ylabel('Frequency');
end

% Encode words into numeric tokens
enc = wordEncoding(documents(cvp.training));
documentsTrain = documents(cvp.training);
documentsTest = documents(cvp.test);

XTrain = doc2sequence(enc, documentsTrain, 'Length', 30);
XTest = doc2sequence(enc, documentsTest, 'Length', 30);

% Prepare the labels for training and testing
YTrain = dataTrain.sentiment;
YTest = dataTest.sentiment;

% Define the LSTM model structure
layers = [
    sequenceInputLayer(1)
    wordEmbeddingLayer(100, enc.NumWords)
    lstmLayer(100, 'OutputMode', 'last')
    fullyConnectedLayer(numel(categories(YTrain)))
    softmaxLayer
    classificationLayer];

% Training options
options = trainingOptions('adam', ...
    'MaxEpochs', 100, ...
    'MiniBatchSize', 128, ...
    'InitialLearnRate', 0.01, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', {XTest, YTest}, ...
    'Plots', 'training-progress', ...
    'Verbose', false);

% Train the model
net = trainNetwork(XTrain, YTrain, layers, options);

% Evaluate the model on the test set
YPred = classify(net, XTest);
accuracy = sum(YPred == YTest) / numel(YTest);
fprintf('Test Accuracy: %.4f\n', accuracy);

% Preprocess new sentences for sentiment prediction
newSentences = [
    "Cryptocurrencies are a total scam, leading countless investors to ruin with their volatile markets.",
    "Cryptocurrencies represent the future of finance, offering unprecedented growth and opportunities.",
    "I can say with almost certainty that cryptocurrencies will come to a bad ending.",
    "Bitcoin is on the verge of being widely accepted by conventional financiers."
];
newDocuments = preprocessText(newSentences);

% Predict sentiments of new sentences
newX = doc2sequence(enc, newDocuments, 'Length', 30);
[labelsNew, scores] = classify(net, newX);

% Display the prediction results
for i = 1:length(newSentences)
    fprintf('"%s" - %s\n', newSentences(i), string(labelsNew(i)));
end

% Define the function to preprocess text data
function documents = preprocessText(textData)
    documents = tokenizedDocument(textData);
    documents = lower(documents);
    documents = erasePunctuation(documents);
end
