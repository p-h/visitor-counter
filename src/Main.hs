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

import qualified Data.ByteString.Char8 as BS

redisConnectInfo :: ConnectInfo
redisConnectInfo = defaultConnectInfo { connectHost = "redis" }

getAndIncreaseHits :: String -> IO (Integer, Integer)
getAndIncreaseHits hostName = do
    conn <- checkedConnect redisConnectInfo
    runRedis conn $ do
        result <- multiExec $ do
            hitCount' <- incr "hitCount"
            hostHitCount' <- incr $ mconcat [BS.pack hostName, "_hitCount"]
            return $ (,) <$> hitCount' <*> hostHitCount'
        return $ case result of
            TxSuccess tuple -> tuple
            _ -> (0, 0)

main :: IO ()
main = do
    port <- getServicePortFromEnv
    hostName <- getHostName
    scotty port $
        get "/" $ do
            (hits, hostHits) <- liftIO $ getAndIncreaseHits hostName
            html $ renderHtml
                $ H.docTypeHtml $ do
                    H.head $ do
                        H.title $ mapM_ H.toHtml ["Hello Visitor #", show hits, "!"]
                    H.body $ do
                        H.h1 "Hi there"
                        H.p $ mapM_ H.toHtml ["My name is: ", hostName]
                        H.p $ mapM_ H.toHtml ["You are total visitor number: ", show hits, "!"]
                        H.p $ mapM_ H.toHtml ["You are ", hostName, "'s visitor number: ", show hostHits, "!"]



getServicePortFromEnv :: IO Int
getServicePortFromEnv = fromMaybe 8080 . (readMaybe =<<) <$> lookupEnv "SERVICE_PORTS"
