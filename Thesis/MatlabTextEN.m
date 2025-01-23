% File name and corresponding title
file = 'tweets.xlsx';
titleStr = 'Twitter Data';
print("gehzd")
% Read the table from the file
T = readtable(file, 'ReadVariableNames', true);

% Check if 'Post' is the column name and rename it to 'text'.
if ismember('Post', T.Properties.VariableNames)
    T.Properties.VariableNames{strcmp(T.Properties.VariableNames, 'Post')} = 'text';
    textData = T.text;
else
    warning('Column "Post" not found in the file %s.', file);
    return; % Stop execution if 'Post' column is not found.
end

% Display the first 10 items of textData
disp(textData(1:10));

% Preprocess textData
textData = lower(textData);
textData = eraseURLs(textData);
textData = erasePunctuation(textData);

% Create a word cloud
figure;
wordcloud(textData);
title(titleStr);
