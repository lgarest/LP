-------------------------------------------------------------------------------
-- Exercise 1
-- Declaration of Point class
-----------------------------

class Point p where
  sel :: Int -> p -> Double
  dim :: p -> Int
  child :: p -> p -> [Int] -> Int
  dist :: p -> p -> Double
  listToPoint :: [Double] -> p
  ptrans :: [Double] -> p -> p
  pscale :: Double -> p -> p


-------------------------------------------------------------------------------
-- Exercise 2
-- Declaration of Point3d class and instantiation
-------------------------------------------------

data Point3d = Point3d [Double] deriving (Eq)
instance Point Point3d where
  sel x (Point3d p) = p !! x
  dim p = 3
  child e1 e2 l = binToDec (getChildNumber e1 e2 l)
  dist e1 e2 = sqrt ( (((sel 0 e2) - (sel 0 e1)) ** 2) + 
                      (((sel 1 e2) - (sel 1 e1)) ** 2) +
                      (((sel 2 e2) - (sel 2 e1)) ** 2)
                    )
  listToPoint l = (Point3d l)
  ptrans [x,y,z] p = (Point3d [
        ((sel 0 p) + x),
        ((sel 1 p) + y),
        ((sel 2 p) + z)
      ])
  pscale x p = (Point3d [
        ((sel 0 p) * x),
        ((sel 1 p) * x),
        ((sel 2 p) * x)
      ])

-- Show instance of a Point3d point
instance Show Point3d where
  show (Point3d [x,y,z]) = "("++(show x)++","++(show y)++","++(show z)++")" 

-------------------------------------------------------------------------------
-- Exercise 3
-- Declaration of Kd2nTree class and instantiation
--------------------------------------------------

-- Kd2nTree declaration
data Kd2nTree p = EmptyTree | Node p [Int] [Kd2nTree p]

-- Show instance of a Kd2nTree
instance Show p => Show (Kd2nTree p) where
  show EmptyTree = ""
  show (Node k coords children) = (show k)++" "++
                                  (show coords)++"\n"++
                                  (showChildren children 0 0)

-- Eq instance comparing two Kd2nTrees
-- The two trees must have the same size and include the same points to be equal
instance (Point p, Eq p) => Eq (Kd2nTree p) where
  EmptyTree == EmptyTree = True
  t1 == t2 = and [
      (size t1) == (size t2),
      (containsAllPoints (get_all t1) t2)
    ]

-------------------------------------------------------------------------------
-- Exercise 4
-------------

-- Inserts a point in its place inside of a Kd2ntree
insert :: Point p => Kd2nTree p -> p -> [Int] -> Kd2nTree p
insert EmptyTree point coords = Node point coords
  (take (2 ^ (length coords)) (cycle [EmptyTree]))
insert (Node a acoords children) b bcoords = Node a acoords (
    (take n children)++
    [(insert (head (drop n children)) b bcoords)]++
    (drop(n+1) children)
  )
  where n = child a b acoords

-- Generates a Kd2nTree from a list of (point, coordenates)
build :: (Eq p, Point p) => [(p, [Int])] -> Kd2nTree p
build [] = EmptyTree
build [(p, coords)] = Node p coords (take 
    (2 ^ (length coords))
    (cycle [EmptyTree])
  )
build (p:ps) = addPoints (build [p]) ps

-- Generates a Kd2nTree from a list of ([Double], coordenates)
buildIni :: (Eq p, Point p) => [([Double],[Int])] -> Kd2nTree p
buildIni [] = EmptyTree
buildIni l = build (convertToPoints l)

-------------------------------------------------------------------------------
-- Exercise 5
-------------

-- Returns a list containing all the points inside a Kd2nTree
get_all :: Point p => Kd2nTree p -> [(p, [Int])]
get_all EmptyTree = []
get_all (Node k coords []) = [(k, coords)]
get_all (Node k coords children) = (get_all (head children))++
    (get_all (Node k coords (tail children)))

-------------------------------------------------------------------------------
-- Exercise 6
-------------

-- Removes a point from a Kd2nTree and returns the result Kd2nTree
remove :: (Point p, Eq p) => Kd2nTree p -> p -> Kd2nTree p
remove EmptyTree _ = EmptyTree
remove k@(Node p coords children) a
  | p == a = if (not (hasChildren k)) then EmptyTree
             else
                build (getChildren k)
  | otherwise = (Node p coords (lbefore++[remove c a]++lafter))
  where 
    lbefore = take x children
    lafter = drop (x+1) children
    c = head (drop x children)
    x = child p a coords

-------------------------------------------------------------------------------
-- Exercise 7
-------------------

-- Returns if a Kd2nTree contains a point
contains :: (Point p, Eq p) => Kd2nTree p -> p -> Bool
contains EmptyTree k = False
contains (Node k coords children) x
  | (x == k) = True
  | otherwise = (contains 
      (children !! (child k x coords))
      x
    )

-------------------------------------------------------------------------------
-- Exercise 8
-------------

-- Returns the closest point
nearest :: (Point p, Eq p) => Kd2nTree p -> p -> p
nearest k@(Node point c f) a = nearestChild (get_all k) a point

-------------------------------------------------------------------------------
-- Exercise 9
-------------

-- Applies a function to a Kd2nTree and returns the result Kd2nTree
kdmap :: (Point p, Point q) => (p -> q)  -> Kd2nTree p -> Kd2nTree q
kdmap f EmptyTree = EmptyTree
kdmap f (Node a coords achildren) = (Node (f a) coords (map (kdmap f) achildren))

-- Applies a translation function to each of the nodes of a Kd2nTree and returns the result tree
translation :: (Point p) => [Double] -> Kd2nTree p -> Kd2nTree p
translation l k = kdmap (ptrans l) k

-- Applies a scale function to each of the nodes of a Kd2nTree and returns the result tree
scale :: (Point p) => Double -> Kd2nTree p -> Kd2nTree p
scale x k = kdmap (pscale x) k

-------------------------------------------------------------------------------
-- Aux functions 
-------------------

-- Returns a ^ b
power :: Int -> Int -> Int
power _ 0 = 1
power b 1 = b
power b e = b * (power b (e - 1))

-- Receives an Int list in binary and returns its representation in decimal
binToDec :: [Int] -> Int
binToDec [x] = x
binToDec l = (power 2 (length(tail l))) * (head l) + (binToDec (tail l))

-- Compares if a value of a coord of a point is bigger than another one
cmpCoord :: (Point p) => p -> p -> Int -> Int
cmpCoord e1 e2 x
  | (sel (x-1) e1) < (sel (x-1) e2) = 1
  | otherwise = 0


-- Returns the child number (binary) of a point depending on a coordenates vector
getChildNumber :: (Point p) => p -> p -> [Int] -> [Int]
getChildNumber _ _ [] = []
getChildNumber e1 e2 l = [(cmpCoord e1 e2 (head l))]++
  (getChildNumber e1 e2 (tail l))


-- Returns the number of nodes of the Kd2nTree
size :: (Point p) => Kd2nTree p -> Int
size k = length (get_all k)

-- Returns if the tree is empty or not
isEmpty :: (Point p) => Kd2nTree p -> Bool
isEmpty EmptyTree = True
isEmpty a = False

-- Returns if the tree doesntHaveChildren or not
hasChildren :: (Point p) => Kd2nTree p -> Bool
hasChildren EmptyTree = False
hasChildren (Node _ _ []) = False
hasChildren (Node _ _ _) = True

-- Returns the points of the tree w/o the root
-- solo la llama remove
getChildren :: Point p => Kd2nTree p -> [(p,[Int])]
getChildren EmptyTree = []
getChildren (Node _ coords []) = []
getChildren (Node k coords (x:xs)) = (get_all x)++
  (getChildren (Node k coords xs))

-- Shows the children of a tree recursively in the format:
-- <#ofchild> (coordenates comma separated) [list of coordenates comma separated]
showChildren :: Show k => [Kd2nTree k] -> Int -> Int -> String
showChildren [] _ _ = ""
showChildren (EmptyTree:xs) n spaces = (showChildren xs (n+1) spaces)
showChildren ((Node k coords children):xs) n spaces = 
  (take (spaces*4) (cycle " "))++
  " <"++(show n)++"> "++
  (show k)++" "++
  (show coords)++"\n"++
  (showChildren children 0 (spaces+1))++
  (showChildren xs (n+1) spaces)

-- Returns if a Kd2nTree contains all the points of a list
containsAllPoints :: (Point p, Eq p) => [(p,[Int])] -> Kd2nTree p -> Bool
containsAllPoints [] t = True
containsAllPoints ((c,_):xs) k
  | (contains k c) = containsAllPoints xs k
  | otherwise = False

-- Add points to a Kd2nTree and returns the result tree
addPoints :: Point p => Kd2nTree p -> [(p, [Int])] -> Kd2nTree p
addPoints k [] = k
addPoints k ((p, coords):xs) = addPoints (insert k p coords) xs

-- Convert a list of pairs (list of doubles, list of coords) into a list of pairs (point, list of coords) 
convertToPoints :: (Eq p, Point p) => [([Double],[Int])] -> [(p,[Int])]
convertToPoints [] = []
convertToPoints [(point, coords)] = [((listToPoint point), coords)]
convertToPoints ((point, coords) : ps) = [((listToPoint point), coords)]++
  (convertToPoints ps)

-- Tracks the current nearest point inside a list of points and returns it.
nearestChild :: (Point p, Eq p) => [(p,[Int])] -> p -> p -> p
nearestChild [] point best = best
nearestChild ((x,_):xs) point best
    | x == point = nearestChild [] x x
    | (dist x point) < (dist point best) = nearestChild xs point x
    | otherwise = nearestChild xs point best

-- An example list of pairs ([Double], [Int])
exampleList :: [([Double], [Int])]
exampleList = [
    ([3.0, -1.0, 2.1], [1, 3]),
    ([3.5, 2.8, 3.1], [1, 2]),
    ([3.5, 0.0, 2.1], [3]),
    ([3.0, -1.7, 3.1], [1, 2, 3]),
    ([3.0, 5.1, 0.0], [2]),
    ([1.5, 8.0, 1.5], [1]),
    ([3.3, 2.8, 2.5], [3]),
    ([4.0, 5.1, 3.8], [2]),
    ([3.1, 3.8, 4.8], [1, 3]),
    ([1.8, 1.1, -2.0], [1, 2])
  ]
-- An example Kd2nTree generated from the buildIni function
exampleList' = buildIni exampleList :: Kd2nTree Point3d

-- An example Kd2nTree
exampleTree :: Kd2nTree Point3d
exampleTree = build[
    (Point3d [3.0, -1.0, 2.1], [1, 3]),
    (Point3d [3.5, 2.8, 3.1], [1, 2]),
    (Point3d [3.5, 0.0, 2.1], [3]),
    (Point3d [3.0, -1.7, 3.1], [1, 2, 3]),
    (Point3d [3.0, 5.1, 0.0], [2]),
    (Point3d [1.5, 8.0, 1.5], [1]),
    (Point3d [3.3, 2.8, 2.5], [3]),
    (Point3d [4.0, 5.1, 3.8], [2]),
    (Point3d [3.1, 3.8, 4.8], [1, 3]),
    (Point3d [1.8, 1.1, -2.0], [1, 2])
  ]

test1 = do
  putStr "Check if a Tree contains a point -> "
  let check1 = (contains exampleList' (Point3d [3.5, 0.0, 2.1]))
  if check1 then putStr "OK "
  else putStr "FAILS1.1 "
  let check2 = (contains exampleList' (Point3d [3.7, 0.0, 2.1]))
  if not check2 then putStr "OK\n"
  else putStr "FAILS1.2\n"

test2 = do
  putStr "Check Tree Eq instance -> "
  let check1 = (exampleList' == exampleList')
  if check1 then putStr "OK "
  else putStr "FAILS2.1 "
  let check2 = (exampleList' == build[(Point3d [3.0, -1.0, 2.1], [1, 3])])
  if not check2 then putStr "OK\n"
  else putStr "FAILS2.2\n"

test3 = do
  putStr "Check translation and scale functions -> "
  let check1 = (translation [1.0,1.0,1.0] exampleList' == exampleList')
  if not check1 then putStr "OK "
  else putStr "FAILS3.1 "
  let check2 = (scale 1.0 exampleList' == exampleList')
  if  check2 then putStr "OK "
  else putStr "FAILS3.2 "
  let check3 = (scale 2.0 exampleList' == exampleList')
  if not check3 then putStr "OK "
  else putStr "FAILS3.3 "
  let check4 = (translation [1.0,1.0,1.0] (build[(Point3d [3.0, -1.0, 2.1], [1, 3])]) == (build[(Point3d [4.0, 0.0, 3.1], [1, 3])]))
  if check4 then putStr "OK "
  else putStr "FAILS3.4 "
  let check5 = (scale 2.0 (build[(Point3d [3.0, -1.0, 2.1], [1, 3])]) == (build[(Point3d [6.0, -2.0, 4.2], [1, 3])]))
  if check5 then putStr "OK\n"
  else putStr "FAILS3.5\n"

test4 = do
  putStr "Check insert and remove functions -> "
  let k = build[(Point3d [3.0, -1.0, 2.1], [1, 3])]
  let check1 = (insert k (Point3d [2.0, -1.0, 2.1]) [2] == k)
  if not check1 then putStr "OK "
  else putStr "FAILS4.1 "
  let check2 = (remove k (Point3d [3.0, -1.0, 2.1]) == EmptyTree)
  if check2 then putStr "OK\n"
  else putStr "FAILS4.2\n"


test = do
  test1
  test2
  test3
  test4
