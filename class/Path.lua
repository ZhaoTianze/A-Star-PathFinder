--
-- Author: zen.zhao88@gmail.com
-- Date: 2015-08-06 18:36:37
--
local Path = class("Path")
Path.WayPointSeekDistSq = math.pow(30,2)
function Path:ctor()
	self.wayPoints_ = {}
	self.curWayPointIndex_ = 1
	self.isLoop_ = false
end
--随机生成路径
function Path:randomWayPoints(numberOfPoints,minX,minY,maxX,maxY)
	self:clear()

	local midX = (minX+maxX)/2.0
	local midY = (minY+maxY)/2.0

	local smaller = math.min(midX,midY)

	local spacing = common.TwoPI / numberOfPoints

	for i=1,numberOfPoints do
		local radialDist = common.RandomInRange(smaller*0.2,smaller)

		local temp = {x = radialDist, y = 0}

		temp = Transformations.Vec2DRotateAroundOrigin(temp,i*spacing)

		temp.x, temp.y = temp.x+midX, temp.y+midY

		self.wayPoints_[#self.wayPoints_+1] = temp

	end

	self.curWayPointIndex_ = 1

	return self.wayPoints_
end

function Path:currentWayPoint()
	assert(self.curWayPointIndex_ ~= nil)
	return self.wayPoints_[self.curWayPointIndex_]
end
--当前目标点是否是组后一个路径点
function Path:isLastPoint()
	return (self.curWayPointIndex_ == #self.wayPoints_) and (not self.isLoop_) 
end
--是否完成所有路径
function Path:finished()
	return self.isFinished_
end

function Path:addWayPoint(newPoint)
	self.wayPoints_[#self.wayPoints_+1] = newPoint
end

function Path:setWayPoints(points)
	self.wayPoints_ = points
end

function Path:setIsLoop(b)
	self.isLoop_ = b
end

function Path:clear()
	self.wayPoints_ = {}
end

function Path:getWayPoints()
	return self.wayPoints_
end

function Path:goToNextWayPoint()
	local num = #self.wayPoints_
	assert ( num > 0, "没有路径点可用～")
	self.curWayPointIndex_  = self.curWayPointIndex_  + 1
	if self.curWayPointIndex_  > num then
		if self.isLoop_ then
			self.curWayPointIndex_  = 1
		else
			self.isFinished_ = true
		end
	else
		self.isFinished_ = false
	end
end

function Path:isArrivedCurrentPoint(pos)
	local distanceSqrt = cc.pGetLengthSq(cc.pSub(self:currentWayPoint(),pos))
	return distanceSqrt < Path.WayPointSeekDistSq 
end

return Path