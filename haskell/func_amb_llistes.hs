--myLength
myLength :: [Int] -> Int
myLength [] = 0
myLength (h:t) = 1 + myLength t
{-
myLength (h:t)
    | t == [] = 1
    | otherwise = 1 + myLength(t)
-}

--myMaximum
myMaximum :: [Int] -> Int
myMaximum [] = 0
myMaximum (h:t)
    | t == [] = h
    | head t > h = myMaximum (head t:t )
    | otherwise = myMaximum (h:tail t)

--average
addAll :: [Int] -> Int
addAll [] = 0
addAll (h:t) = h + addAll t

average :: [Int] -> Float
average [] = 0
average a = (fromIntegral (addAll a)) / (fromIntegral(myLength a))

--buildPalindrome
reverseList :: [Int] -> [Int]
reverseList [] = []
reverseList a = last a:(reverseList(init a))

buildPalindrome :: [Int] -> [Int]
buildPalindrome [] = []
buildPalindrome a = (reverseList a)++a

--remove
pop :: [Int] -> Int -> [Int]
pop [] a = []
pop x a = [y | y <- x, y /= a]

remove :: [Int] -> [Int] -> [Int]
remove [] [] = []
remove x [] = x
remove [] x = []
remove x (h:t) = remove (pop x h) t

--flatten
flatten :: [[Int]] -> [Int]
flatten [] = []
flatten (h:t) = [] ++ h ++ flatten t

--oddsNevens
evens :: [Int] -> [Int]
evens [] = []
evens a = [y | y <- a, y `mod` 2 == 0]

odds :: [Int] -> [Int]
odds [] = []
odds a = [y | y <- a, y `mod` 2 /= 0]

oddsNevens :: [Int] -> ([Int],[Int])
oddsNevens [] = ([],[])
oddsNevens a = (odds a, evens a)

--primeDivisors
isPrime :: Int -> Bool
isPrime 0 = False
isPrime 1 = False
isPrime n = not (hasFactor n (n-1))

hasFactor :: Int -> Int -> Bool
hasFactor n c
    | c == 1 = False
    | n `mod` c == 0 = True
    | otherwise = hasFactor n (c-1)

searchDivisor :: Int -> Int -> [Int]
searchDivisor a b
    | b > (div a 2) = []
    | isPrime b && a `mod` b == 0 = [b] ++ (searchDivisor a (b+1))
    | otherwise = (searchDivisor a (b+1))

primeDivisors :: Int -> [Int]
primeDivisors a
    | isPrime a = [a]
    | otherwise = searchDivisor a 2
