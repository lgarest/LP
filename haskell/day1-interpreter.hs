Prelude> 2+2+2
6
Prelude> div 10 2
5
Prelude> mod 10 2
0
Prelude> 
Prelude> mod 10 3
1
Prelude> 10 `div` 2
5
Prelude> 5 == 5
True
Prelude> 4 == 5
False
Prelude> 4 /= 5
True
Prelude> 3 == 4 || 5==5
True
Prelude> 3 == 4 && 5==5
False
Prelude> not (4 == 4)
False
Prelude> odd 5
True
Prelude> even 10
True
Prelude> :t
:trace  :type
Prelude> :type 7
7 :: Num a => a
Prelude> :type False
False :: Bool
Prelude> :type 7+2
7+2 :: Num a => a
Prelude> :type 7==2
7==2 :: Bool
Prelude> 2**3
8.0
Prelude> 2^3
8
Prelude> 24684566^23
106117352506343928431362358046960765107707222727500129227349146564488594057642645553351789771209014012547227113760601606173318564833238188171661296208023028505750112567296
Prelude> 24684566^23
106117352506343928431362358046960765107707222727500129227349146564488594057642645553351789771209014012547227113760601606173318564833238188171661296208023028505750112567296
Prelude> 24684567856^23
106117536019446423050199826433815145533621545826730864577246993611048436470176920196865413505934696671897744283727597159355500335608285451202476129847772262004304084683959974932858409012249582627972384647246009764298046406852192827254767616
Prelude> 24684567856**23
1.0611753601944643e239
Prelude> ''

<interactive>:30:3:
    parse error (possibly incorrect indentation or mismatched brackets)
Prelude> ' '
' '
Prelude> 'a'
'a'
Prelude> "Bernat"
"Bernat"
Prelude> :T "Bernat"
unknown command ':T'
use :? for help.
Prelude> :t "Bernat"
"Bernat" :: [Char]
Prelude> [1,2,3]
[1,2,3]
Prelude> [1,2,"a"]

<interactive>:37:2:
    No instance for (Num [Char]) arising from the literal `1'
    Possible fix: add an instance declaration for (Num [Char])
    In the expression: 1
    In the expression: [1, 2, "a"]
    In an equation for `it': it = [1, 2, "a"]
Prelude> [1,2,'a']

<interactive>:38:2:
    No instance for (Num Char) arising from the literal `1'
    Possible fix: add an instance declaration for (Num Char)
    In the expression: 1
    In the expression: [1, 2, 'a']
    In an equation for `it': it = [1, 2, 'a']
Prelude> :T [1,2,3]
unknown command ':T'
use :? for help.
Prelude> :t [1,2,3]
[1,2,3] :: Num t => [t]
Prelude> :t [True,False]
[True,False] :: [Bool]
Prelude> :t [1..5]
[1..5] :: (Enum t, Num t) => [t]
Prelude> [1..5]
[1,2,3,4,5]
Prelude> [1..0]
[]
Prelude> [3..2]
[]
Prelude> head [1..5]
1
Prelude> tail [1..5]
[2,3,4,5]
Prelude> :t tail
tail :: [a] -> [a]
Prelude> :t head
head :: [a] -> a
Prelude> :t length
length :: [a] -> Int
Prelude> :t +

<interactive>:1:1: parse error on input `+'
Prelude> :t (+)
(+) :: Num a => a -> a -> a
Prelude> (+) 3 4
7
Prelude> let f = (+) 3
Prelude> :t f
f :: Integer -> Integer
Prelude> f 4
7
Prelude> let doble = (*) 2
Prelude> :t doble
doble :: Integer -> Integer
Prelude> doble 3
6
Prelude> doble 4
8
Prelude> let g x = 3*x + 1
Prelude> :t g
g :: Num a => a -> a
Prelude> g 6
19
Prelude> g 5
16
Prelude> let h x y = x+y
Prelude> :t h
h :: Num a => a -> a -> a
Prelude> (h 2) 3
5
Prelude> let m = h 2
Prelude> :t m
m :: Integer -> Integer
Prelude> m 3
5
Prelude> :r
