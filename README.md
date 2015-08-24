# A-Star-PathFinder
A星寻路算法 for cocos2dx-lua

寻路的时候需要传入开始坐标，目标坐标以及存放所有地块格子的table。

1.关于地块格子(block)的划分方式
	每个block为一个table
	local block = {}
		  block.w = w --在整个地图划分中所处的行
		  block.h = h --在整个地图划分中所处的列
		  block.pos = pos --格子的中心点在地图中的坐标		
		  block.couldCross = true --表示该格子是否是可以通过的
	然后将block以键值string.format("%d_%d",block.w,block.h) 存入blocks中

2.关于路径的缓存
	为了提高效率,完成一次寻路后会把相关路径信息缓存到aster.cachedPaths中，在地图变化时需要手动调用astar.clear_cached_paths清除缓存信息
	