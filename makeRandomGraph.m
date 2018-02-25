function graphObj = makeRandomGraph(Delta,nLevels)

    probVec = ones(1,Delta)/(Delta-1);
    probVec(1) = 0;
    parentIndex = branch(nLevels,probVec)';
    edgeTable = table([(2:numel(parentIndex))' parentIndex(2:end)],'VariableNames',{'EndNodes'});
    graphObj = graph(edgeTable);
end