
DBCC AUTOPILOT (5, 5, 0, 0, 0)

DBCC AUTOPILOT(6, 1, 359672329,6)
   GO 
SET AUTOPILOT ON 
GO 
SELECT 
     l_orderkey,
     SUM(l_extendedprice * (1 - l_discount)) AS revenue,
     o_orderdate,
     o_shippriority
 FROM  customer, orders, lineitem
WHERE c_mktsegment = 'BUILDING'
  AND c_custkey = o_custkey
  AND l_orderkey = o_orderkey
  AND o_orderdate < (DATEADD(DAY, 5, '1995-12-01'))
  AND l_shipdate < (DATEADD(DAY, 3, '1995-12-01'))
GROUP BY l_orderkey, o_orderdate, o_shippriority
ORDER BY revenue DESC,  o_orderdate
	
GO                                                                                                                           
SET AUTOPILOT OFF 

GO