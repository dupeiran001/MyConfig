function table_merge(into, from)
	local stack = {}
	local node1 = into
	local node2 = from
	while true do
		for k, v in pairs(node2) do
			if type(v) == "table" and type(node1[k]) == "table" then
				table.insert(stack, { node1[k], node2[k] })
			else
				node1[k] = v
			end
		end
		if #stack > 0 then
			local t = stack[#stack]
			node1, node2 = t[1], t[2]
			stack[#stack] = nil
		else
			break
		end
	end
	return into
end
