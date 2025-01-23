filename = "tweets.xlsx";
tbl = readtable(filename, 'TextType', 'string');
head(tbl);
textData = tbl.Post;
documents = tokenizedDocument(textData);

documents = lower(documents);
documents = removeStopWords(documents);
bag = bagOfWords(documents);
counts = bag.Counts;
cooccurrence = counts.' * counts;
G = graph(cooccurrence, bag.Vocabulary, 'omitselfloops');

words = ["bull", "stable", "bear"]; % List of words to analyze
for i = 1:length(words)
    word = words(i);
    idx = find(bag.Vocabulary == word);
    nbrs = neighbors(G, idx);
    H = subgraph(G, [idx; nbrs]);

    figure; % Create a new figure for each word
    LWidths = 5 * H.Edges.Weight / max(H.Edges.Weight);
    plot(H, 'LineWidth', LWidths);
    title(sprintf("Co-occurrence Network - Word: '%s'", word));
end
