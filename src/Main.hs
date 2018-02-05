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

import qualified Text.Blaze.Html5 as H
import Text.Blaze.Html.Renderer.Text (renderHtml)

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
            hits <- liftIO $ show <$> getAndIncreaseHits
            html $ renderHtml
                $ H.docTypeHtml $ do
                    H.head $ do
                        H.title $ mapM_ H.toHtml ["Hello Visitor #", hits, "!"]
                    H.body $ do
                        H.h1 "Hi there"
                        H.p $ mapM_ H.toHtml ["You are visitor number: ", hits, "!"]
                        H.p $ mapM_ H.toHtml ["My name is: ", hostName]



getServicePortFromEnv :: IO Int
getServicePortFromEnv = fromMaybe 8080 . (readMaybe =<<) <$> lookupEnv "SERVICE_PORTS"
