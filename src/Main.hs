{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Monad.IO.Class
import Database.Redis hiding (get)
import Data.Maybe
import Data.Text.Lazy
import Network.HostName
import System.Environment
import Text.Read hiding (get)
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
main = do
    port <- getServicePortFromEnv
    hostName <- getHostName
    scotty port $
        get "/" $ do
            hits <- liftIO $ getAndIncreaseHits
            html $ mconcat [ "<h1>Hi there</h1>"
                           , "<p>You are visitor number: ", pack $ show hits, "!</p>"
                           , "<p>My name is: ", pack hostName, "</p>"
                           ]

getServicePortFromEnv :: IO Int
getServicePortFromEnv = fromMaybe 8080 . (readMaybe =<<) <$> lookupEnv "SERVICE_PORT"
