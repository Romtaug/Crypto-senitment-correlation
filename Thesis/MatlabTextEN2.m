% Set the character encoding to UTF-8 for proper handling of text data
slCharacterEncoding('UTF-8');

% Define the filename of the Excel file containing the tweet data
file = "tweets.xlsx";

% Attempt to read the Excel file into a MATLAB table
try
    T = readtable(file, 'ReadVariableNames', true);
catch
    % If there's an error reading the file, display a custom error message
    error('Error reading the file %s. Ensure the file name is correct and the file exists.', file);
end

% Check if the 'Post' column exists in the table
if ismember('Post', T.Properties.VariableNames)
    PostData = T.Post; % Extract data from the 'Post' column
else
    % If the 'Post' column is not found, throw an error
    error('Column "Post" not found in the table.');
end

% Display the first 5 rows of PostData for a quick inspection
disp(PostData(1:5));

% Preprocess the Post data using a custom function
documents = preprocessPost(PostData);

% Display the first 5 preprocessed documents for verification
disp(documents(1:5));

% Create a bag of n-grams model using the preprocessed text, focusing on bigrams
bagBigrams = bagOfNgrams(documents, 'NGramLengths', [1,2]);

% Generate and display a word cloud for the bigrams
figure;
wordcloud(bagBigrams);
title("Text Data: Preprocessed Bigrams");

% Perform Latent Dirichlet Allocation (LDA) to discover 10 topics within the text data
mdl = fitlda(bagBigrams, 10, 'Verbose', 0);

% Display word clouds for the first 4 topics identified by LDA
figure;
for i = 1:4
    subplot(2,2,i);
    wordcloud(mdl, i);
    title(sprintf("LDA Topic %d", i));
end

% For trigrams, preprocess the text by removing punctuation and converting to lowercase
cleanPostData = lower(erasePunctuation(PostData));
documentsTrigrams = tokenizedDocument(cleanPostData);

% Create a bag of n-grams model for trigrams
bagTrigrams = bagOfNgrams(documentsTrigrams, 'NGramLengths', 3);

% Generate and display a word cloud for the trigrams
figure;
wordcloud(bagTrigrams);
title("Post Data: Trigrams");

% Display the 10 most frequent n-grams from the trigram analysis
tbl = topkngrams(bagTrigrams, 10);
disp(tbl);

% Define the function used for preprocessing the Post data
function documents = preprocessPost(PostData)
    % Convert to lowercase
    cleanPostData = lower(PostData);
    % Tokenize the text
    documents = tokenizedDocument(cleanPostData);
    % Remove punctuation
    documents = erasePunctuation(documents);
    % Remove stop words
    documents = removeStopWords(documents);
    % Remove short words (less than 3 characters)
    documents = removeShortWords(documents, 2);
    % Remove long words (more than 15 characters)
    documents = removeLongWords(documents, 15);
    % Add parts of speech details
    documents = addPartOfSpeechDetails(documents);
    % Lemmatize the words
    documents = normalizeWords(documents, 'Style', 'lemma');
end
