function [outputGraph,uniqueTriplet] = addLevelType2(Delta,inputGraph,uniqueTriplet)
    if ~exist('inputGraph','var')
        % If it is the first level then no inputGraph so make a digraph
        % with only the root
        outputGraph = graph(0);
        outputGraph.Nodes.Index = 1;
        outputGraph.Nodes.Level = 1;
        outputGraph.Nodes.Label = 0;
        outputGraph.Nodes.ParentIndex = nan;
        outputGraph.Nodes.ParentLabel = nan;
        outputGraph.Nodes.Major = true;
        uniqueTriplet = table([nan nan nan],nan,{nan},'VariableNames',{'Value','Level','RepeatLevel'});
    else
        % Otherwise we are atleast at level 2
        outputGraph = inputGraph;
        % All avaiable labels for type 1 are between 0 and Delta + 1
        availableLabels = (0:Delta+2)';
        % Get the current level
        newLevel = max(outputGraph.Nodes.Level) + 1;
        if newLevel < 3
            % If we are at level 2 then create the first setof children
            unavailableLabels = outputGraph.Nodes.Label + (-1:1)';
            newLabels = setdiff(availableLabels,unavailableLabels);
            newLabels = newLabels(1:min(numel(newLabels),Delta));
            outputGraph = subAddNodeAndEdges(outputGraph,newLevel,outputGraph.Nodes.Index,newLabels);
            uniqueTriplet.RepeatLevel = {[]};
        else
            if any(cellfun(@isempty,uniqueTriplet.RepeatLevel,'un',1))
                if isnan(uniqueTriplet.Level(1))
                    uniqueTriplet(1,:) = [];
                end
                % Get all the leaves index which will be the new parents
                allParentIndex = outputGraph.Nodes.Index(outputGraph.Nodes.Level==newLevel-1);
                % Loop through all the parents and add children
                for iIndex = 1:numel(allParentIndex)
                    % Get parent and grand parentlabels
                    parentLabel = outputGraph.Nodes.Label(allParentIndex(iIndex));
                    grandParentLabel = outputGraph.Nodes.ParentLabel(allParentIndex(iIndex));
                    % Can't use grand parent label and parent label +/- 1
                    unavailableLabels = [grandParentLabel;parentLabel + (-1:1)'];
                    newLabels = setdiff(availableLabels,unavailableLabels);
                    % Check in uniqueTriplet
                    newTriplets = [repmat(grandParentLabel,size(newLabels)) repmat(parentLabel,size(newLabels)) newLabels];
                    % Remove labels which already exist
                    [isEq,idxAdd] = ismember(newTriplets,uniqueTriplet.Value,'rows');
                    newLabels(isEq) = [];
                    newLabels = newLabels(1:min(numel(newLabels),Delta-1));
                    % Add where repeats
                    idxAdd = idxAdd(idxAdd>0);
                    for iIdx = 1:numel(idxAdd)
                        uniqueTriplet.RepeatLevel{idxAdd(iIdx)} = [uniqueTriplet.RepeatLevel{idxAdd(iIdx)} newLevel];
                    end
                    finalNewTriplets = [repmat(grandParentLabel,size(newLabels)) repmat(parentLabel,size(newLabels)) newLabels];
                    % Add new unique triplets
                    tempTable = table(finalNewTriplets,repmat(newLevel,[size(finalNewTriplets,1),1]),repmat({[]},[size(finalNewTriplets,1),1]));
                    tempTable.Properties.VariableNames = {'Value','Level','RepeatLevel'};
                    uniqueTriplet = [uniqueTriplet;tempTable];
                    % Check if parent is major
                    if numel(newLabels) == Delta - 1
                        outputGraph.Nodes.Major(allParentIndex(iIndex)) = true;
                    end
                    % Add all the children for the given parent in the graph
                    outputGraph = subAddNodeAndEdges(outputGraph,newLevel,allParentIndex(iIndex),newLabels);
                end
                
            else
                outputGraph = inputGraph;
                disp('No more unique nodes to add!');
            end
        end
    end
end

function outputGraph = subAddNodeAndEdges(inputGraph,newLevel,parentIndex,newLabels)
    % Set the output graph as input graph
    outputGraph = inputGraph;
    % Find the labels for all the new children
    Label = newLabels;
    % Get the indexes of the new children
    maxIndex = max(outputGraph.Nodes.Index);
    Index = (maxIndex+1:maxIndex+numel(Label))';
    % Set the levels
    Level = repmat(newLevel,size(Index));
    % Set the names to be labels but strings
    % Parent information
    ParentIndex = repmat(parentIndex,size(Index));
    ParentLabel = repmat(outputGraph.Nodes.Label(parentIndex),size(Index));
    Major = false(size(Index));
    % Add the new nodes
    outputGraph = outputGraph.addnode(table(Index,Level,Label,ParentIndex,ParentLabel,Major));
    % Add the new edges
    outputGraph = outputGraph.addedge(repmat(parentIndex,size(Index)),Index,ones(size(Index)));
end