{-# LANGUAGE DeriveGeneric #-}
-- | Parameter types for LightGBM.
--
-- Parameter details are documented in the
-- <http://lightgbm.readthedocs.io/en/latest/Parameters.html LightGBM documentation>.
--
-- Note that some of the parameters listed in the documentation are
-- not exposed here since they're set implicitly through other parts
-- of the API.  For instance, the 'task' param is set in the
-- "LightGBM.Model" API, and the 'header' param is set in the
-- "LightGBM.DataSet" API.

module LightGBM.Parameters
  ( -- * Parameters
    Param(..)
  , PredictionParam(..)
  , Application(..)
  , BinaryClassParam(..)
  , Booster(..)
  , DARTParam(..)
  , Device(..)
  , Direction(..)
  , FairRegressionParam(..)
  , GOSSParam(..)
  , GPUParam(..)
  , LambdaRankParam(..)
  , LocalListenPort
  , MachineListFile
  , Metric(..)
  , Minutes
  , MultiClassStyle(..)
  , NDCGEvalPositions
  , NumClasses
  , NumMachines
  , ParallelismParams(..)
  , ParallelismStyle(..)
  , PoissonRegressionParam(..)
  , RegressionApp(..)
  , TweedieRegressionParam(..)
  , VerbosityLevel(..)
  , XEApp(..)
  -- * Utilities
  , ColumnSelector(..)
  , colSelArgument
  ) where

import Data.Hashable (Hashable)
import Data.Int (Int32)
import GHC.Generics (Generic)
import Numeric.Natural (Natural)

import LightGBM.Utils.Types
  ( IntGreaterThanOne
  , LeftOpenProperFraction
  , NonNegativeDouble
  , OneToTwoLeftSemiClosed
  , OpenProperFraction
  , PositiveDouble
  , PositiveInt
  , ProperFraction
  )

-- | Parameters control the behavior of lightGBM.
data Param
  = Objective Application -- ^ Regression, binary classification, etc.
  | BoostingType Booster -- ^ Booster to apply - by default is 'GBDT'
  | TrainingData FilePath -- ^ Path to training data
  | ValidationData [FilePath] -- ^ Paths to validation data files (supports multi-validation)
  | PredictionData FilePath -- ^ Path to data to use for a prediction
  | Iterations Natural -- ^ Number of boosting iterations - default is 100
  | LearningRate PositiveDouble -- ^ Scale how quickly parameters change in training
  | NumLeaves PositiveInt       -- ^ Maximum number of leaves in one tree
  | Parallelism ParallelismStyle -- ^ Called 'tree_learner' in the LightGBM docs
  | NumThreads Natural -- ^ Number of threads for LightGBM to use
  | Device Device -- ^ GPU or CPU
  | RandomSeed Int -- ^ A random seed used to generate other random seeds
  | MaxDepth Natural            -- ^ Limit the depth of the tree model
  | MinDataInLeaf Natural       -- ^ Minimum data count in a leaf
  | MinSumHessianInLeaf NonNegativeDouble -- ^ Minimal sum of the Hessian in one leaf
  | BaggingFraction LeftOpenProperFraction
  | BaggingFreq PositiveInt
  | BaggingFractionSeed Int
  | FeatureFraction LeftOpenProperFraction
  | FeatureFractionSeed Int
  | EarlyStoppingRounds PositiveInt -- ^ Stop training if a validation metric doesn't improve in the last n rounds
  | Regularization_L1 NonNegativeDouble
  | Regularization_L2 NonNegativeDouble
  | MaxDeltaStep PositiveDouble
  | MinSplitGain NonNegativeDouble
  | MinDataPerGroup PositiveInt -- ^ Minimum number of data points per categorial group
  | MaxCatThreshold PositiveInt
  | CatSmooth NonNegativeDouble
  | CatL2 NonNegativeDouble -- ^ L2 regularization in categorical split
  | MaxCatToOneHot PositiveInt
  | TopK PositiveInt -- ^ VotingPar only
  | MonotoneConstraint [Direction] -- ^ Length of directions = number of features
  | MaxBin IntGreaterThanOne
  | MinDataInBin PositiveInt
  | DataRandomSeed Int
  | OutputModel FilePath -- ^ Where to persist the model after training
  | InputModel FilePath -- ^ Filepath to a persisted model to use for prediction or additional training
  | OutputResult FilePath -- ^ Where to persist the output of a prediction task
  | PrePartition Bool
  | IsSparse Bool
  | TwoRoundLoading Bool
  | SaveBinary Bool
  | Verbosity VerbosityLevel
  | LabelColumn (ColumnSelector Natural) -- ^ Which column has the labels
  | WeightColumn (ColumnSelector Natural) -- ^ Which column has the weights
  | QueryColumn (ColumnSelector Natural)
  | IgnoreColumns [(ColumnSelector Natural)] -- ^ Select columns to ignore in training
  | CategoricalFeatures [(ColumnSelector Int32)] -- ^ Select columns to use as features
  | BinConstructSampleCount PositiveInt
  | UseMissing Bool
  | ZeroAsMissing Bool
  | InitScoreFile FilePath
  | ValidInitScoreFile [FilePath]
  | ForcedSplits FilePath
  | Sigmoid PositiveDouble -- ^ Used in Binary classification and LambdaRank
  | Alpha OpenProperFraction -- ^ Used in Huber loss and Quantile regression
  | BoostFromAverage Bool -- ^ Used only in RegressionL2 task
  | RegSqrt Bool -- ^ Only used in RegressionL2
  | Metric [Metric] -- ^ Loss Metric
  | MetricFreq PositiveInt
  | TrainingMetric Bool
  deriving (Eq, Show)

data PredictionParam
  = PredictRawScore Bool -- ^ True = raw scores only, False = transformed scores
  | PredictLeafIndex Bool -- ^ True = predict with leaf index
  | PredictContrib Bool -- ^ True = estimate how each feature contributes to the prediction
  | NumIterationsPredict Natural -- ^ how many trained iterations are used in prediction
  | PredEarlyStop Bool -- ^ True = use early stopping on the prediction (may degrade accuracy)
  | PredEarlyStopFreq Natural
  | PredEarlyStopMargin Double  -- ??? Should this be a Positive Double?
  deriving (Eq, Show)

data LambdaRankParam
  = MaxPosition PositiveInt
  | LabelGain [Double] -- ^ Used in LambdaRank
  deriving (Eq, Show, Generic)
instance Hashable LambdaRankParam

data BinaryClassParam
  = IsUnbalance Bool -- ^ Set to true if training data are unbalanced
  | ScalePosWeight PositiveDouble
  deriving (Eq, Show, Generic)
instance Hashable BinaryClassParam

--- | Parameters for Fair loss regression
data FairRegressionParam =
  FairC PositiveDouble
   deriving (Eq, Show, Generic)
instance Hashable FairRegressionParam

-- | Parameters for Poisson regression
data PoissonRegressionParam =
  PoissonMaxDeltaStep PositiveDouble
  deriving (Eq, Show, Generic)
instance Hashable PoissonRegressionParam

-- | Different types of Boosting approaches
data Booster
  = GBDT -- ^ Gradient Boosting Decision Tree
  | RandomForest
  | DART [DARTParam] -- ^ Dropouts meet Multiple Additive Regression Trees
  | GOSS [GOSSParam] -- ^ Gradient-based One-Sided Sampling
  deriving (Eq, Show, Generic)
instance Hashable Booster

data TweedieRegressionParam =
  TweedieVariancePower OneToTwoLeftSemiClosed -- ^ Control Tweedie variance in range [1, 2) - 1 is like Poisson, 2 is like Gamma
  deriving (Eq, Show, Generic)
instance Hashable TweedieRegressionParam

-- | Different types of regression metrics
data RegressionApp
  = L1 -- ^ Absolute error metric
  | L2 -- ^ RMS errror metric
  | Huber
  | Fair [FairRegressionParam]
  | Poisson [PoissonRegressionParam]
  | Quantile
  | MAPE
  | Gamma
  | Tweedie [TweedieRegressionParam]
  deriving (Eq, Show, Generic)
instance Hashable RegressionApp

-- | Multi-classification styles
data MultiClassStyle
  = MultiClassSimple
  | MultiClassOneVsAll
  deriving (Eq, Show, Generic)
instance Hashable MultiClassStyle

data XEApp
  = XEntropy
  | XEntropyLambda
  deriving (Eq, Show, Generic)
instance Hashable XEApp

type NumMachines = PositiveInt

type MachineListFile = FilePath

type LocalListenPort = Natural

type Minutes = Natural

data ParallelismParams
  = SocketVer { nMachines :: NumMachines
              , machineList :: MachineListFile
              , port :: LocalListenPort
              , timeOut :: Minutes }
  | MPIVer { nMachines :: NumMachines }
  deriving (Eq, Show, Generic)
instance Hashable ParallelismParams

data ParallelismStyle
  = Serial
  | FeaturePar ParallelismParams
  | DataPar ParallelismParams
  | VotingPar ParallelismParams
  deriving (Eq, Show, Generic)
instance Hashable ParallelismStyle

data GPUParam
  = GpuPlatformId Natural
  | GpuDeviceId Natural
  | GpuUseDP Bool
  deriving (Eq, Show, Generic)
instance Hashable GPUParam

data Device
  = CPU
  | GPU [GPUParam]
  deriving (Eq, Show, Generic)
instance Hashable Device

data Direction
  = Increasing
  | Decreasing
  | NoConstraint
  deriving (Eq, Show, Generic)
instance Hashable Direction

data VerbosityLevel
  = Fatal
  | Warn
  | Info
  deriving (Eq, Show, Generic)
instance Hashable VerbosityLevel

type NDCGEvalPositions = [Natural]

data Metric
  = MeanAbsoluteError -- L1
  | MeanSquareError -- L2
  | L2_root
  | QuantileRegression
  | MAPELoss
  | HuberLoss
  | FairLoss
  | PoissonNegLogLikelihood
  | GammaNegLogLikelihood
  | GammaDeviance
  | TweedieNegLogLiklihood
  | NDCG (Maybe NDCGEvalPositions)
  | MAP
  | AUC
  | BinaryLogloss
  | BinaryError
  | MultiLogloss
  | MultiError
  | Xentropy
  | XentLambda
  | KullbackLeibler
  deriving (Eq, Show, Generic)
instance Hashable Metric

type NumClasses = Natural

-- | LightGBM can be used for a variety of applications
data Application
  = Regression RegressionApp
  | BinaryClassification [BinaryClassParam]
  | MultiClass MultiClassStyle NumClasses
  | CrossEntropy XEApp
  | LambdaRank [LambdaRankParam] -- ^ A ranking algorithm
  deriving (Eq, Show, Generic)
instance Hashable Application

-- | Parameters exclusively for the DART booster
data DARTParam
  = DropRate ProperFraction     -- ^ Dropout rate
  | SkipDrop ProperFraction     -- ^ Probablility of skipping a drop
  | MaxDrop PositiveInt         -- ^ Max number of dropped trees on one iteration
  | UniformDrop Bool
  | XGBoostDARTMode Bool
  | DropSeed Int
  deriving (Eq, Show, Generic)
instance Hashable DARTParam

data GOSSParam
  = TopRate ProperFraction
  | OtherRate ProperFraction
  deriving (Eq, Show, Generic)
instance Hashable GOSSParam

-- | Some parameters are based on column selection either by index or
-- by name.  A 'ColumnSelector' encapsulates this flexibility.
data ColumnSelector a
  = Index a
  | ColName String
  deriving (Eq, Show)

colSelArgument :: Show a => ColumnSelector a -> String
colSelArgument (Index i) = show i
colSelArgument (ColName s) = s
