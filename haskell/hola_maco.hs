
main = do
    linea <- getLine
    if (last linea) == 'a' || (last linea) == 'A' then 
        putStr "Hola maca!\n"
    else
        putStr "Hola maco!\n"
