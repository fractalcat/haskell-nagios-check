{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE RecordWildCards            #-}
{-# LANGUAGE TupleSections              #-}

module System.Nagios.Plugin.PerfData
(
    UOM(..),
    PerfValue(..),
    PerfDatum(..),
    ToPerfData,
    toPerfData,
    barePerfDatum
) where

import           Data.Int
import           Data.Nagios.Perfdata.Metric (UOM (..))
import           Data.Text                   (Text)
import           Numeric

-- | Value of a performance metric.
data PerfValue = RealValue Double | IntegralValue Int64
  deriving (Eq, Ord)

instance Show PerfValue where
    show (RealValue x) = showFFloat Nothing x ""
    show (IntegralValue x) = show x

-- | One performance metric. A plugin will output zero or more of these,
--   whereupon Nagios generally passes them off to an external system such
--   as <http://oss.oetiker.ch/rrdtool/ RRDTool> or
--   <https://github.com/anchor/vaultaire Vaultaire>.
--   The thresholds are purely informative (designed to be graphed), and
--   do not affect alerting; likewise with `_min` and `_max`.
data PerfDatum = PerfDatum
    { _label :: Text             -- ^ Name of quantity being measured.
    , _value :: PerfValue        -- ^ Measured value, integral or real.
    , _uom   :: UOM              -- ^ Unit of measure; 'NullUOM' is fine here.
    , _min   :: Maybe PerfValue  -- ^ Measured quantity cannot be lower than this.
    , _max   :: Maybe PerfValue  -- ^ Measured quantity cannot be higher than this.
    , _warn  :: Maybe PerfValue  -- ^ Warning threshold for graphing.
    , _crit  :: Maybe PerfValue  -- ^ Critical threshold for graphing.
    }
  deriving (Eq, Show)

class ToPerfData a where
    { toPerfData :: a -> [PerfDatum] }

-- | Create a PerfDatum from only the required values, using Nothing
--   for all the others.
barePerfDatum ::
       Text
    -> PerfValue
    -> UOM
    -> PerfDatum
barePerfDatum info val uom = PerfDatum info val uom Nothing Nothing Nothing Nothing
