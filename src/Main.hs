{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Monad.IO.Class
import Database.Redis hiding (get)
import Data.Text.Lazy
import Web.Scotty

redisConnectInfo :: ConnectInfo
redisConnectInfo = defaultConnectInfo { connectHost = "redis" }

getAndIncreaseHits :: IO Integer
getAndIncreaseHits = do
    conn <- checkedConnect redisConnectInfo
    runRedis conn $ do
        hitCount <- incr "hitCount"
        return $ either (\_ -> 0) id hitCount

main :: IO ()
main = scotty 8888 $
    get "/" $ do
        hits <- liftIO $ getAndIncreaseHits
        html $ mconcat ["<h1>Hi there\nYou are visitor number: ", pack $ show hits, "!</h1>\n"]
