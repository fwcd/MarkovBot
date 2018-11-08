{-# LANGUAGE OverloadedStrings #-}

-- Source: https://github.com/aquarial/discord-haskell/blob/master/examples/ping-pong.hs

import Control.Exception (finally)
import Control.Monad (when)
import Data.Char (toLower)
import Data.Monoid ((<>))
import qualified Data.Text as T
import qualified Data.Text.IO as TIO

import Discord

-- | Replies "pong" to every message that starts with "ping"
main :: IO ()
main = do
  tok <- T.strip <$> TIO.readFile "./authtoken.secret"

  dis <- loginRestGateway (Auth tok)

  finally (let loop = do
                  e <- nextEvent dis
                  case e of
                      Left er -> putStrLn ("Event error: " <> show er)
                      Right (MessageCreate m) -> do
                        when (isPing (messageText m)) $ do
                          resp <- restCall dis (CreateMessage (messageChannel m) "Pong!" Nothing)
                          putStrLn (show resp)
                          putStrLn ""
                        loop
                      _ -> do loop
           in loop)
          (stopDiscord dis)

isPing :: T.Text -> Bool
isPing = T.isPrefixOf "ping" . T.map toLower
