
{-Joan 76 1.80-}

main = do
    linea <- getLine
    let x = words linea
    --h = (x !! 1) :: Integer
    print (x !! 0)
    print (x !! 1)
    print (x !! 2)
