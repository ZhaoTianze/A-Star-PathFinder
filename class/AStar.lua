--
-- Author: zen.zhao88@gmail.com
-- Date: 2015-08-10 20:38:24
--
-- A*算法
local astar = {}

local INF = 1/0
astar.cachedPaths = nil

local function dist_betweenSqrt ( nodeA, nodeB )
	local subPos = { x = nodeA.pos.x - nodeB.pos.x, y = nodeA.pos.y - nodeB.pos.y}
	return math.pow(subPos.x,2) + math.pow(subPos.y,2)
end

local function heuristic_cost_estimate ( nodeA, nodeB )
	return dist_betweenSqrt(nodeA, nodeB)
end

--查找开启列表中，F值最低的节点
local function lowest_f_score ( set, f_score )
	local lowest, bestNode = INF, nil
	for _, node in pairs ( set ) do
		local score = f_score [ node ]
		if score < lowest then
			lowest, bestNode = score, node
		end
	end
	return bestNode
end

local function not_in ( set, theNode )
	if set[theNode] then
		return false
	end
	return true
end
--从set中删除一个节点
local function remove_node ( set, theNode )
	set[theNode] = nil
end
--反向查找得到路径
local function unwind_path ( flat_path, map, current_node )
	if map [ current_node ] then
		table.insert ( flat_path, 1, map [ current_node ] ) 
		return unwind_path ( flat_path, map, map [ current_node ] )
	else
		return flat_path
	end
end

local function table_num(set)
	local count = 0
    for k, v in pairs(set) do
        count = count + 1
    end
    return count
end

----------------------------------------------------------------
-- pathfinding functions
-- 参数：star  开始点
--		goal  目标点
--		nodes 所有节点
--		valid_node_func 判断临近节点是否可用的函数
----------------------------------------------------------------

local function a_star ( start, goal, find_Neighbors)
	local closedset = {} --关闭列表
	local openset = {} --开启列表
	openset[start] = start
	local came_from = {}--记录节点的上一个节点


	local g_score, f_score = {}, {}
	g_score [ start ] = 0
	f_score [ start ] = g_score [ start ] + heuristic_cost_estimate ( start, goal ) -- F = G + H

	while table_num(openset) > 0 do
	
		local current = lowest_f_score ( openset, f_score ) -- 找到F最小值
		if current == goal then --找到了目标点
			local path = unwind_path ( {}, came_from, goal )
			table.insert ( path, goal )
			return path
		end
		--继续查找
		remove_node ( openset, current )	--从开启列表中删除选中节点	
		-- table.insert ( closedset, current ) --把选中节点放入到关闭列表中
		closedset[current] = current
		
		local neighbors = find_Neighbors (current) --获得当前节点的附近节点
		for _, neighbor in ipairs ( neighbors ) do 
			if not_in ( closedset, neighbor ) then --附近节点没有在关闭列表里面，说明该节点还没有被选中
			
				local tentative_g_score = g_score [ current ] + dist_betweenSqrt ( current, neighbor )
				 
				if not_in ( openset, neighbor ) or tentative_g_score < g_score [ neighbor ] then 
					came_from 	[ neighbor ] = current --记录父方格
					g_score 	[ neighbor ] = tentative_g_score
					f_score 	[ neighbor ] = g_score [ neighbor ] + heuristic_cost_estimate ( neighbor, goal )
					if not_in ( openset, neighbor ) then
						-- table.insert ( openset, neighbor )
						openset[neighbor] = neighbor
					end
				end
			end
		end
	end
	return nil -- no valid path
end

----------------------------------------------------------------
-- exposed functions
----------------------------------------------------------------

function astar.clear_cached_paths ()
	astar.cachedPaths = nil
end

function astar.path ( start, goal, ignore_cache, find_Neighbors )
	if not start then
		return nil
	end
	if not astar.cachedPaths then astar.cachedPaths = {} end
	if not astar.cachedPaths [ start ] then
		astar.cachedPaths [ start ] = {}
	elseif astar.cachedPaths [ start ] [ goal ] and not ignore_cache then
		return astar.cachedPaths [ start ] [ goal ]
	end
	local newPath = a_star ( start, goal, find_Neighbors )
	astar.cachedPaths [ start ] [ goal ] = newPath --存储缓存数据
	return newPath
end

return astar