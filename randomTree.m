%% Close and clear everything
clear all;
close all;

%% Make the test graph
% Delta = 5;
% nLevels = 5;
% testTree = makeRandomGraph(Delta,nLevels);
% figure;plot(testTree,'layout','force');
% save('testTree','testTree','Delta','nLevels')
load('testTree')
% load('testTreeFailed1.mat')
% load('testTreeWorkedWithoutZ1.mat')
% load('allData.mat')
% testTree = fullTree;

%% Get information
testTree.Nodes.Index = (1:testTree.numnodes)';
testTree.Nodes.Degree = degree(testTree);
testTree.Nodes.Major = testTree.Nodes.Degree == Delta;

testTree.Nodes.Nearest1 = cellfun(@(x) testTree.nearest(x,1),num2cell(testTree.Nodes.Index),'un',0);
testTree.Nodes.Nearest2 = cellfun(@(x) testTree.nearest(x,2),num2cell(testTree.Nodes.Index),'un',0);
testTree.Nodes.Nearest3 = cellfun(@(x) testTree.nearest(x,3),num2cell(testTree.Nodes.Index),'un',0);

testTree.Nodes.Distance3 = cellfun(@(x,y) setdiff(x,y),testTree.Nodes.Nearest3,testTree.Nodes.Nearest2,'un',0);
testTree.Nodes.Distance2 = cellfun(@(x,y) setdiff(x,y),testTree.Nodes.Nearest2,testTree.Nodes.Nearest1,'un',0);
testTree.Nodes.Distance1 = cellfun(@sort,testTree.Nodes.Nearest1,'un',0);

testTree.Nodes.Majors1 = cellfun(@(x) x(testTree.Nodes.Major(x)),testTree.Nodes.Distance1,'un',0);
testTree.Nodes.Majors2 = cellfun(@(x) x(testTree.Nodes.Major(x)),testTree.Nodes.Distance2,'un',0);
testTree.Nodes.Majors3 = cellfun(@(x) x(testTree.Nodes.Major(x)),testTree.Nodes.Distance3,'un',0);

testTree.Nodes.NumMajors1 = cellfun(@numel,testTree.Nodes.Majors1,'un',1);
testTree.Nodes.NumMajors2 = cellfun(@numel,testTree.Nodes.Majors2,'un',1);
testTree.Nodes.NumMajors3 = cellfun(@numel,testTree.Nodes.Majors3,'un',1);

testTree.Nodes.TypeB = testTree.Nodes.NumMajors2==2*Delta-4 & ~testTree.Nodes.Major;
testTree.Nodes.TypeD = testTree.Nodes.NumMajors2==2*Delta-5 & ~testTree.Nodes.Major;
testTree.Nodes.TypeE = testTree.Nodes.NumMajors2==2*Delta-6 & ~testTree.Nodes.Major;

testTree.Nodes.TypeB1 = cellfun(@(x) x(testTree.Nodes.TypeB(x)),testTree.Nodes.Distance1,'un',0);
testTree.Nodes.TypeD1 = cellfun(@(x) x(testTree.Nodes.TypeD(x)),testTree.Nodes.Distance1,'un',0);
testTree.Nodes.TypeE1 = cellfun(@(x) x(testTree.Nodes.TypeE(x)),testTree.Nodes.Distance1,'un',0);

testTree.Nodes.TypeB2 = cellfun(@(x) x(testTree.Nodes.TypeB(x)),testTree.Nodes.Distance2,'un',0);
testTree.Nodes.TypeD2 = cellfun(@(x) x(testTree.Nodes.TypeD(x)),testTree.Nodes.Distance2,'un',0);
testTree.Nodes.TypeE2 = cellfun(@(x) x(testTree.Nodes.TypeE(x)),testTree.Nodes.Distance2,'un',0);

%% Start labeling
type2 = false;
if any(testTree.Nodes.NumMajors1+testTree.Nodes.Major>2)
    type2 = true;
    disp('- Type 2 because more than two majors in a closed neighbourhood');
elseif any(testTree.Nodes.NumMajors2(testTree.Nodes.Major)>Delta-2)
    type2 = true;
    disp('- Type 2 because more than \Delta-2 majors at distance from a major');
elseif any(testTree.Nodes.NumMajors2(~testTree.Nodes.Major)>2*Delta-4)
    type2 = true;
    disp('- Type 2 because more than 2*\Delta-4 majors at distance from a minor');
end
    
typeBIdx = testTree.Nodes.NumMajors2==2*Delta-4 & ~testTree.Nodes.Major;
typeDIdx = testTree.Nodes.NumMajors2==2*Delta-5 & ~testTree.Nodes.Major;
typeEIdx = testTree.Nodes.NumMajors2==2*Delta-6 & ~testTree.Nodes.Major;

% typeBIdx 
if any(cellfun(@(x) numel(x)>1,testTree.Nodes.TypeB1,'un',1) & testTree.Nodes.Major)
    type2 = true;
    disp('- Type 2 because more than 1 Type B next for a major');
elseif any(cellfun(@(x) numel(x)>2,testTree.Nodes.TypeD1,'un',1) & testTree.Nodes.Major)
    type2 = true;
    disp('- Type 2 because more than 2 Type D next for a major');
end
save('allData.mat','testTree','Delta','-append')


if ~type2
    load('allData.mat')
    %% Label
    if ismember('Label',testTree.Nodes.Properties.VariableNames)
        testTree.Nodes.OldLabel = testTree.Nodes.Label;
    end
    testTree.Nodes.Label = repmat(-1,size(testTree.Nodes.Index));
    firstMajorIdx = testTree.Nodes.Index(find(testTree.Nodes.Major,1));
    testTree.Nodes.Label(firstMajorIdx) = 0;
    majorNodesDistance12 = union(testTree.Nodes.Majors1{firstMajorIdx},testTree.Nodes.Majors2{firstMajorIdx});
    testTree.Nodes.Label(majorNodesDistance12) = Delta+1;
    testTree = subLabel(testTree,firstMajorIdx,Delta);
    leftToLabel = testTree.Nodes.Index(testTree.Nodes.Label==-1);
    leftToLabelAdjacent = testTree.Nodes.Distance1(leftToLabel);
    leftToLabelAdjacent = unique(vertcat(leftToLabelAdjacent{:}));
    for iNode = 1:numel(leftToLabelAdjacent)
        testTree = subLabel(testTree,leftToLabelAdjacent(iNode),Delta);
    end
    
    %% Check
    for iNode = 1:testTree.numnodes
        currLabel = testTree.Nodes.Label(iNode);
        distance1Labels = testTree.Nodes.Label(testTree.Nodes.Distance1{iNode});
        distance2Labels = testTree.Nodes.Label(testTree.Nodes.Distance2{iNode});

        distance1LabelsPMOne = [distance1Labels-1; distance1Labels; distance1Labels+1];
        if any(currLabel==distance2Labels) || any(currLabel==distance1LabelsPMOne)
            keyboard;
        end

    end
    
    figure;
    plotHandle = plot(testTree,'layout','force','nodelabel',testTree.Nodes.Label);
    highlight(plotHandle,testTree.Nodes.Index(testTree.Nodes.Major),'NodeColor','r');
    highlight(plotHandle,testTree.Nodes.Index(testTree.Nodes.Label==-2),'NodeColor','g');
    highlight(plotHandle,testTree.Nodes.Index(testTree.Nodes.Label==-1),'NodeColor','g');

end



%% Function
function outputTree = subLabel(inputTree,inputNodeIdx,Delta)
    outputTree = inputTree;
    distance1Nodes = outputTree.Nodes.Distance1{inputNodeIdx};
    
    availableLabels = 0:Delta+1;
    distance1Labels = outputTree.Nodes.Label(distance1Nodes);
    
    allNodesToLabel = distance1Nodes(distance1Labels==-1);
    nodesToLabel = allNodesToLabel;
    majorNodes = nodesToLabel(outputTree.Nodes.Major(nodesToLabel));
    for iNode = 1:numel(majorNodes)
        nodeIdx = majorNodes(iNode);
        distance1Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance1{nodeIdx});
        distance2Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance2{nodeIdx});
        distance1Labels(distance1Labels==-1) = [];
        distance2Labels(distance2Labels==-1) = [];
        currLabel = setdiff([0,Delta+1],distance2Labels);
        distance1LabelsPMOne = [distance1Labels-1 distance1Labels distance1Labels+1];
        currLabel = setdiff(currLabel,distance1LabelsPMOne(:));
        currLabel = currLabel(1);
        outputTree.Nodes.Label(nodeIdx) = currLabel;
        majorNodesDistance12 = union(outputTree.Nodes.Majors1{nodeIdx},outputTree.Nodes.Majors2{nodeIdx});
        outputTree.Nodes.Label(majorNodesDistance12) = setdiff([0,Delta+1],currLabel);
    end
    nodesToLabel = setdiff(nodesToLabel,majorNodes);
    
    typeBNodes = nodesToLabel(outputTree.Nodes.TypeB(nodesToLabel));
    for iNode = 1:numel(typeBNodes)
        nodeIdx = typeBNodes(iNode);
        distance1Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance1{nodeIdx});
        distance2Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance2{nodeIdx});
        distance1Labels(distance1Labels==-1) = [];
        distance2Labels(distance2Labels==-1) = [];
        currLabel = setdiff([1,Delta],distance2Labels);
        distance1LabelsPMOne = [distance1Labels-1 distance1Labels distance1Labels+1];
        currLabel = setdiff(currLabel,distance1LabelsPMOne(:));
        currLabel = currLabel(1);
        outputTree.Nodes.Label(nodeIdx) = currLabel;
    end
    nodesToLabel = setdiff(nodesToLabel,typeBNodes);
    
    typeDNodes = nodesToLabel(outputTree.Nodes.TypeD(nodesToLabel));
    for iNode = 1:numel(typeDNodes)
        nodeIdx = typeDNodes(iNode);
        distance1Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance1{nodeIdx});
        distance2Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance2{nodeIdx});
        distance1Labels(distance1Labels==-1) = [];
        distance2Labels(distance2Labels==-1) = [];
        currLabel = setdiff([2,Delta-1],distance2Labels);
        distance1LabelsPMOne = [distance1Labels-1 distance1Labels distance1Labels+1];
        currLabel = setdiff(currLabel,distance1LabelsPMOne(:));
        currLabel = currLabel(1);
        outputTree.Nodes.Label(nodeIdx) = currLabel;
    end
    nodesToLabel = setdiff(nodesToLabel,typeDNodes);
    
    if Delta > 4
        typeENodes = nodesToLabel(outputTree.Nodes.TypeD(nodesToLabel));
        for iNode = 1:numel(typeENodes)
            nodeIdx = typeENodes(iNode);
            distance1Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance1{nodeIdx});
            distance2Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance2{nodeIdx});
            distance1Labels(distance1Labels==-1) = [];
            distance2Labels(distance2Labels==-1) = [];
            currLabel = setdiff(3:Delta-2,distance2Labels);
            distance1LabelsPMOne = [distance1Labels-1 distance1Labels distance1Labels+1];
            currLabel = setdiff(currLabel,distance1LabelsPMOne(:));
            currLabel = currLabel(1);
            outputTree.Nodes.Label(nodeIdx) = currLabel;
        end
        nodesToLabel = setdiff(nodesToLabel,typeENodes);
    end
    
    typeYIdx = cellfun(@(x) numel(x)==2,outputTree.Nodes.Majors1(nodesToLabel),'un',1);
    typeYNodes = nodesToLabel(typeYIdx);
    for iNode = 1:numel(typeYNodes)
        nodeIdx = typeYNodes(iNode);
        distance1Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance1{nodeIdx});
        distance2Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance2{nodeIdx});
        distance1Labels(distance1Labels==-1) = [];
        distance2Labels(distance2Labels==-1) = [];
        currLabel = setdiff(2:Delta-1,distance2Labels);
        distance1LabelsPMOne = [distance1Labels-1 distance1Labels distance1Labels+1];
        currLabel = setdiff(currLabel,distance1LabelsPMOne(:));
        if isempty(currLabel)
            currLabel = -2;
        else
            currLabel = currLabel(1);
        end
        outputTree.Nodes.Label(nodeIdx) = currLabel;
    end
    nodesToLabel = setdiff(nodesToLabel,typeYNodes);

    majors2Dist1 = outputTree.Nodes.Index(cellfun(@(x) numel(x)==2,outputTree.Nodes.Majors1,'un',1));
%     typeZIdx = cellfun(@(x) numel(x)>0,outputTree.Nodes.TypeD1(nodesToLabel),'un',1);
    distance1 = outputTree.Nodes.Distance1(nodesToLabel);
    typeZIdx = cellfun(@(x) any(ismember(x,majors2Dist1)),distance1,'un',1);
    typeZNodes = nodesToLabel(typeZIdx);
    for iNode = 1:numel(typeZNodes)
        nodeIdx = typeZNodes(iNode);
        distance1Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance1{nodeIdx});
        distance2Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance2{nodeIdx});
        distance1Labels(distance1Labels==-1) = [];
        distance2Labels(distance2Labels==-1) = [];
        currLabel = setdiff(1:Delta,distance2Labels);
        distance1LabelsPMOne = [distance1Labels-1 distance1Labels distance1Labels+1];
        currLabel = setdiff(currLabel,distance1LabelsPMOne(:));
        if isempty(currLabel)
            currLabel = -2;
        else
            currLabel = currLabel(1);
        end
        outputTree.Nodes.Label(nodeIdx) = currLabel;
    end
    nodesToLabel = setdiff(nodesToLabel,typeZNodes);
    
    typeXIdx = cellfun(@(x) numel(setdiff(x,inputNodeIdx))==1,outputTree.Nodes.Majors1(nodesToLabel),'un',1);
    typeXNodes = nodesToLabel(typeXIdx);
    for iNode = 1:numel(typeXNodes)
        nodeIdx = typeXNodes(iNode);
        distance1Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance1{nodeIdx});
        distance2Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance2{nodeIdx});
        distance1Labels(distance1Labels==-1) = [];
        distance2Labels(distance2Labels==-1) = [];
        currLabel = setdiff(availableLabels,distance2Labels);
        distance1LabelsPMOne = [distance1Labels-1 distance1Labels distance1Labels+1];
        currLabel = setdiff(currLabel,distance1LabelsPMOne(:));
        if ~isempty(intersect(currLabel,2:Delta-1))
            currLabel = intersect(currLabel,2:Delta-1);
        elseif ~isempty(intersect(currLabel,[1,Delta]))
            currLabel = intersect(currLabel,[1,Delta]);
        elseif ~isempty(intersect(currLabel,[0,Delta+1]))
            currLabel = intersect(currLabel,[0,Delta+1]);
        end
        currLabel = currLabel(1);
        outputTree.Nodes.Label(nodeIdx) = currLabel;
    end
    nodesToLabel = setdiff(nodesToLabel,typeXNodes);
    
    for iNode = 1:numel(nodesToLabel)
        nodeIdx = nodesToLabel(iNode);
        distance1Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance1{nodeIdx});
        distance2Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance2{nodeIdx});
        distance1Labels(distance1Labels==-1) = [];
        distance2Labels(distance2Labels==-1) = [];
        currLabel = setdiff(availableLabels,distance2Labels);
        distance1LabelsPMOne = [distance1Labels-1 distance1Labels distance1Labels+1];
        currLabel = setdiff(currLabel,distance1LabelsPMOne(:));
        currLabel = currLabel(1);
        outputTree.Nodes.Label(nodeIdx) = currLabel;
    end
    
%     for iNode = 1:numel(nodesToLabel)
%         nodeIdx = nodesToLabel(iNode);
%         distance1Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance1{nodeIdx});
%         distance2Labels = outputTree.Nodes.Label(outputTree.Nodes.Distance2{nodeIdx});
%         distance1Labels(distance1Labels==-1) = [];
%         distance2Labels(distance2Labels==-1) = [];
%         possibleLabels = setdiff(availableLabels,distance2Labels);
%         distance1LabelsPMOne = [distance1Labels-1 distance1Labels distance1Labels+1];
%         possibleLabels = setdiff(possibleLabels,distance1LabelsPMOne(:));
%         
%         if outputTree.Nodes.Major(nodeIdx)
%             currLabel = intersect([0,Delta+1],possibleLabels);
%         elseif outputTree.Nodes.TypeB(nodeIdx)
%             currLabel = intersect([1,Delta],possibleLabels);
%         elseif outputTree.Nodes.NumMajors1(nodeIdx) == 2
%             currLabel = intersect(2:Delta-1,possibleLabels);
%             if outputTree.Nodes.TypeD(nodeIdx)
%                 currLabel = intersect([2,Delta-1],currLabel);
%             elseif outputTree.Nodes.TypeE(nodeIdx)
%                 currLabel = intersect(3:Delta-2,currLabel);
%             else
%                 currLabel = [setdiff(currLabel,[2,Delta-1]),intersect([2,Delta-1],currLabel)];
%             end
%         else
% %             currLabel = possibleLabels;
%             currLabel = [setdiff(possibleLabels,[2,Delta-1]),intersect([2,Delta-1],possibleLabels)];
% %             keyboard;
%         end
%         if numel(currLabel) > 1
%             currLabel = currLabel(1);
%         end
%         outputTree.Nodes.Label(nodeIdx) = currLabel;
%     end
    
    nextNodesToLabelIdx = cellfun(@(x) any(outputTree.Nodes.Label(x)==-1),outputTree.Nodes.Distance1(distance1Nodes),'un',1);
    nextNodesToLabel = distance1Nodes(nextNodesToLabelIdx);
    for iNode = 1:numel(nextNodesToLabel)
        nodeIdx = nextNodesToLabel(iNode);
        if ~isempty(nodeIdx)
            outputTree = subLabel(outputTree,nodeIdx,Delta);
        end
    end
    
end