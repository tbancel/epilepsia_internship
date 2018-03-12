clc; clear;

predicted_labels = [0 0 0 0 0 1 1 1 1 0 0 0 0 0];
labeled_epochs = [0 0 0 0 0 0 1 1 1 1 1 0 0 0];

% expected_results = {'TN', 'TN', 'TN', 'TN', 'TN', 'FP', 'TP', 'TP', 'TP', 'FN', 'FN', 'TN', 'TN', 'TN'};

[accuracy, sensitivity, specificity] = compute_performance(predicted_labels, labeled_epochs)