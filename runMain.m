clear all;
close all;
%% Initialise parameters

% Delta is the maximum of all degrees of vertices
Delta = 6;
% Number of levels we want to go down the tree
nLevels = 7;

fromScratch = true;
addRepeats = true;

%% Prediction
predictedNumTriplets = 2*(1*(Delta-1)+(Delta-1)*(Delta-2)) + ...
    2*(1*(Delta-1)+(Delta-2)*(Delta-2)) + ...
    (Delta-2)*(2*(Delta-1)+(Delta-3)*(Delta-2));

%% Create a maximal type 1 tree

if fromScratch
    [fullTree,uniqueTriplet] = addLevel(Delta);
    for iLevel = 2:nLevels
        [fullTree,uniqueTriplet] = addLevel(Delta,fullTree,uniqueTriplet,addRepeats);
        save('allData.mat','fullTree','uniqueTriplet','Delta','nLevels')
    end
else
    load('allData.mat');
    currLevel = max(fullTree.Nodes.Level);
    for iLevel = currLevel+1:nLevels
        [fullTree,uniqueTriplet] = addLevel(Delta,fullTree,uniqueTriplet,addRepeats);
        save('allData.mat','fullTree','uniqueTriplet','Delta','nLevels')
    end
end

%% Sort out uniqueTriple

% disp(unique(uniqueTriplet.Level));
[~,idxSort] = sort(uniqueTriplet.Value(:,1)*100+uniqueTriplet.Value(:,2)*10+uniqueTriplet.Value(:,3));
uniqueTriplet = uniqueTriplet(idxSort,:);
numTop = arrayfun(@(x) sum(uniqueTriplet.Value(:,1)==x),0:Delta+1,'un',1);

% %% Find the distance between major vertices
% fullTree.Nodes.DistanceFromMajor = fullTree.distances('all',fullTree.Nodes.Index(fullTree.Nodes.Major),'method','unweighted');
% 
% %% Find number of major vertices in neighbourhood
% maxDistance = max(max(fullTree.Nodes.DistanceFromMajor));
% majorInNeighbourhood = nan(fullTree.numnodes,maxDistance);
% for iNode = 1:fullTree.numnodes
%     for iDistance = 1:maxDistance
%         nodesInNeighbourhood = fullTree.nearest(iNode,iDistance);
%         
%         majorInNeighbourhood(iNode,iDistance) = sum(fullTree.Nodes.Major(nodesInNeighbourhood)) + fullTree.Nodes.Major(iNode);
%     end
% end

%% Plot
% figure;
% plotHandle = plot(fullTree,'Layout','layered','NodeLabel',fullTree.Nodes.Label);
% highlight(plotHandle,fullTree.Nodes.Index(fullTree.Nodes.Major),'NodeColor','r');
% 
% figure;
% plotHandle = plot(fullTree,'layout','force','nodelabel',{});
% highlight(plotHandle,fullTree.Nodes.Index(fullTree.Nodes.Major),'NodeColor','r');

% %% Reorder and plot
% figure;
% newOrder = 1:fullTree.numnodes;
% newOrder(1) = 3;
% newOrder(3) = 1;
% reorderTree = fullTree.reordernodes(newOrder);
% plotHandle = plot(reorderTree,'Layout','layered','NodeLabel',reorderTree.Nodes.Label);
% highlight(plotHandle,reorderTree.Nodes.Index(reorderTree.Nodes.Major),'NodeColor','r');
