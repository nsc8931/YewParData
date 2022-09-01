#!/usr/bin/env stack
{- stack runghc --package HSLauncher
-}
import Core
import MPIJobs

workDir = "/users/pgt/2637692c/Workspace/MSc/experiment"
yewParAppDir = "/users/pgt/2637692c/Workspace/MSc/YewPar/build/install/bin"
dataDir = "/users/pgt/2637692c/Workspace/MSc/instances"

hosts = [ "gpgnode-04" , "gpgnode-05" , "gpgnode-06" , "gpgnode-07" , "gpgnode-08"
        , "gpgnode-09" , "gpgnode-10" , "gpgnode-11" , "gpgnode-12" , "gpgnode-13"
        , "gpgnode-14" , "gpgnode-15" , "gpgnode-16" , "gpgnode-17" , "gpgnode-18"
        , "gpgnode-19" , "gpgnode-20" ]


samples = 3
timeout = "2h"
globalMPIArgs = "-disable-hostname-propagation"

counters = mconcat $ map (\s -> " --hpx:print-counter " ++ s ++ " ") [
    "/workstealing/depthpool/spawns"
  , "/workstealing/depthpool/distributedFailedSteals"
  , "/workstealing/depthpool/distributedSteals"
  , "/workstealing/depthpool/localFailedSteals"
  , "/workstealing/depthpool/localSteals"
  ]
-- Nodes/Thread pairs
distCfgs = [ (1, 1) ]
probabilities = [ 0 ]

cliques = [ "brock400_1.clq", "brock400_2.clq", "brock400_3.clq", "brock800_3.clq", "brock800_4.clq"]

-- NS
max_genus = 47

jobUpdatePreCmds preCmds hosts threads benchmark probability baseCmd =
  let cmd' = "timeout " ++ timeout ++ " " ++ yewParAppDir ++ baseCmd ++ " --skeleton basicrandom --spawn-probability " ++ show probability ++ " --hpx:threads " ++ show threads ++ " --hpx:ini=hpx.stacks.large_size=0x2000000" ++ counters
  in
  Job hosts $ MPIJob {
      preCommands = ["cd " ++ workDir,
                     "echo CMD: " ++ cmd',
                     "echo PROBABILITY: " ++ show probability,
                     "echo HOSTS: " ++ show hosts
                    ] ++ preCmds
    , postCommands = []
    , createOutputFile = \uid -> "output/" ++ benchmark ++ "/" ++ show uid
    , mpiArgs = globalMPIArgs
    , cmd = cmd'
  }

job = jobUpdatePreCmds []

createMCJobs = map createMCJob [ (c, cfg, probability) | c <- cliques, cfg <- distCfgs, probability <- probabilities ]
  where
  createMCJob (i, (n,ts), p)  = job n ts "maxclique" p $ "/maxclique-14" ++ " -f " ++ dataDir ++ "/maxclique/" ++ i

createNSJobs = map createNSJob [ (cfg, probability) | cfg <- distCfgs, probability <- probabilities ]
  where
  createNSJob ((n,ts), p) = job n ts "NS" p $ "/NS-hivert -g " ++ show max_genus

main :: IO ()
main = do
--  let jobs = createMCJobs ++ createNSJobs
  let jobs = createNSJobs
  runJobs modMPI hosts $ concat $ replicate samples $ jobs
