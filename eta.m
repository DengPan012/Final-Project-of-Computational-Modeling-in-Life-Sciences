function noise = eta(time,tup,NoiseBox)

yes_index=find(tup>=time);
noise=NoiseBox(yes_index(1));
end

