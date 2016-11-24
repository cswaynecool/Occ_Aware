function part=decide_pos_in_training_process(parentnode,child,part)
for childi=1:length(child)
    childnode=child(childi);
    if childnode<5
    [ignore,part{childnode}.sel]=max(sum(part{childnode}.msg,2));
    end
end
