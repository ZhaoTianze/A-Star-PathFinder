--
-- Author: zen.zhao88@gmail.com
-- Date: 2015-08-10 20:38:24
--
-- A*寻路器
local PathFinder = {}

function PathFinder.findBeginBlock(pos,blocks,beforPath,isFly)
	if beforPath then
		local point = beforPath:currentWayPoint()
		if point then
			return PathFinder.findClosetBlock(point,blocks,isFly)
		end
	end
	return PathFinder.findClosetBlock(pos,blocks,isFly)
end
--找到离坐标最近的地块
function PathFinder.findClosetBlock(pos,blocks,isFly)
	local actorWNum,actorHNum = pos.x/BattleCommonDefine.Room_Block_Width, pos.y/BattleCommonDefine.Room_Block_Width
	local wNum = math.floor(actorWNum)
	local hNum = math.floor(actorHNum)
	if wNum ~= actorWNum or hNum ~= actorHNum  then
		local distanceSqrt = 99999999999
		local resultBlock
		for addW=1,2 do
			for addH=1,2 do
				local w,h = wNum+(addW-1),hNum+(addH-1)
				local blockName = string.format("%d_%d",w,h)
				local block = blocks[blockName]
				if block and (block.couldCross or isFly) then
					local newDisSqrt = cc.pGetLengthSq(cc.pSub(block.pos,pos))
					if distanceSqrt > newDisSqrt then
						resultBlock = block
						distanceSqrt = newDisSqrt
					end
				end
			end
		end
		return resultBlock
	else
		return blocks[string.format("%d_%d",wNum,hNum)] 
	end
end
--判断地块的可通过性
function PathFinder.jugeNeighbor (w,h,nodes,neighbors,isFly)
	local nodeName = string.format("%d_%d",w,h)
	local neighborNode = nodes[nodeName]
	if neighborNode and (isFly or neighborNode.couldCross) then
		table.insert( neighbors,neighborNode )
		return true
	end
	return false
end
--查找地块附近可用的地块
--[[
	theBlock - 需要判定的地块
	blocks - 所有地块
	isFly - 飞行，是否无视障碍物]]
function PathFinder.neighbors(theBlock,blocks,isFly)
	local neighbors = {}
	--首先取出附近的8个节点。
	local left_top = true
	local left_down = true
	local right_top = true
	local right_down = true
	--left
	if not PathFinder.jugeNeighbor(theBlock.w-1,theBlock.h,blocks,neighbors,isFly) then
		left_top = false
		left_down = false
	end
	--right
	if not PathFinder.jugeNeighbor(theBlock.w+1,theBlock.h,blocks,neighbors,isFly) then
		right_top = false
		right_down = false
	end
	--top
	if not PathFinder.jugeNeighbor(theBlock.w,theBlock.h+1,blocks,neighbors,isFly) then
		left_top = false
		right_top = false
	end
	--down
	if not PathFinder.jugeNeighbor(theBlock.w,theBlock.h-1,blocks,neighbors,isFly) then
		left_down = false
		right_down = false
	end
	--top-left
	if left_top then
		PathFinder.jugeNeighbor(theBlock.w-1,theBlock.h+1,blocks,neighbors,isFly)
	end
	--down-left
	if left_down then
		PathFinder.jugeNeighbor(theBlock.w-1,theBlock.h-1,blocks,neighbors,isFly)
	end
	--top-right
	if right_top then
		PathFinder.jugeNeighbor(theBlock.w+1,theBlock.h+1,blocks,neighbors,isFly)
	end
	--down-right
	if right_down then
		PathFinder.jugeNeighbor(theBlock.w-1,theBlock.h+1,blocks,neighbors,isFly)
	end
	return neighbors
end

function PathFinder.calculate(beginPos,targetPos,blocks,isFly,beforePath)
	--1.找到开始节点，以actor所在位置，寻找附近最近的节点block
	local beginBlock = PathFinder.findBeginBlock(beginPos,blocks,beforePath,isFly)
	--2.找到结束节点
	local endBlock = PathFinder.findClosetBlock(targetPos,blocks,isFly)
	--3.使用A*查找路线
	local blockPaths = AStar.path(beginBlock,endBlock,blocks,false,function(theBlock)
		return PathFinder.neighbors(theBlock,blocks,isFly)
	end)
	--4.构建Path结构数据
	if not blockPaths or table.nums(blockPaths) == 0 then
		return nil -- A*寻路没有找到可用的路线
	end
	local path = Path.new()
	
	for i=1,#blockPaths do
		local block = blockPaths[i]
		path:addWayPoint(block.pos)
	end
	--7.将最终的终点加入到Path里面
	path:addWayPoint(targetPos)
	return path
end

return PathFinder