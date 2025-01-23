filename = "output_weekly.xlsx";

% Define the names of the sheets
weekSheets = {'Week1', 'Week2', 'Week3', 'Week4'};

% Loop through each sheet
for i = 1:length(weekSheets)
    % Read the data from the current week's sheet
    tbl = readtable(filename, 'Sheet', weekSheets{i}, 'TextType', 'string');
    
    % Extract the posts
    str = tbl.Post;
    documents = tokenizedDocument(str);
    
    % Calculate sentiment scores
    compoundScores = vaderSentimentScores(documents);
    
    % Calculate the mean sentiment score for the current week
    M = mean(compoundScores);
    disp(['Mean sentiment for ', weekSheets{i}, ': ', num2str(M)]);
    
    % Find positive and negative posts
    idxPositive = compoundScores > 0.1;
    idxNegative = compoundScores < -0.1;
    strPositive = str(idxPositive);
    strNegative = str(idxNegative);
    
    % Create a figure for the current week
    figure
    subplot(1,2,1)
    wordcloud(strPositive);
    title(['Positive Sentiment ', weekSheets{i}])
    
    subplot(1,2,2)
    wordcloud(strNegative);
    title(['Negative Sentiment ', weekSheets{i}])
end
