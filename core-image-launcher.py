from core.emulator.coreemu import CoreEmu
from core.emulator.data import IpPrefixes, NodeOptions, LinkOptions
from core.emulator.enumerations import EventTypes
from core.nodes.network import SwitchNode
from core.nodes.docker import DockerNode
from os.path import exists
from time import sleep


nodeTargetNum=50 #for loopback runs
#nodeTargetNum=10 #For delay runs

ippre_Control = IpPrefixes(ip4_prefix="10.83.0.0/16")
ippre_Internal = IpPrefixes(ip4_prefix="10.90.0.0/16")

useDualNetwork=False

print("Initializing CoreEmu...")
coreemu = CoreEmu()
session = coreemu.create_session()

session.set_state(EventTypes.CONFIGURATION_STATE) #Enables adding of nodes, otherwise locked

print("Creating virtual switches...")
switchNodesToController = session.add_node(SwitchNode)
switchNodesInternal = None

if useDualNetwork:
    print("Using Dual Network Setup.")
    switchNodesInternal = session.add_node(SwitchNode)

#go at the end of the add_link command / with options=LO_XXXXXXXXXXXXXXX
linkSlow1Min = LinkOptions(
    bandwidth=2000000, #bps
    delay=60000000, #microseconds (us) 15000000
    dup=0, #duplication
    loss=0, #loss
    jitter=5000000, #jitter microseconds (us) 50000
)

linkSlow15Sec = LinkOptions(
    bandwidth=2000000, #bps
    delay=15000000, #microseconds (us) 15000000
    dup=0, #duplication
    loss=0, #loss
    jitter=1000000, #jitter microseconds (us) 50000
)

linkSlow5Sec = LinkOptions(
    bandwidth=2000000, #bps
    delay=5000000, #microseconds (us) 15000000
    dup=0, #duplication
    loss=0, #loss
    jitter=1000000, #jitter microseconds (us) 50000
)

linkSlow1Sec = LinkOptions(
    bandwidth=2000000, #bps
    delay=1000000, #microseconds (us) 15000000
    dup=0, #duplication
    loss=0, #loss
    jitter=1000000, #jitter microseconds (us) 50000
)


link3G = LinkOptions(
    bandwidth=1500000, #bps
    delay=50000, #microseconds (us)
    dup=0, #duplication
    loss=5, #loss
    jitter=10000, #jitter microseconds (us)
)


linkFaster = LinkOptions(
    bandwidth=1500000, #bps
    delay=10000, #microseconds (us)
    dup=0, #duplication
    loss=30, #loss
    jitter=5000, #jitter microseconds (us)
)

linkFasterLossy = LinkOptions(
    bandwidth=1500000, #bps
    delay=10000, #microseconds (us)
    dup=0, #duplication   
    loss=80, #loss #50,75,80,90
    jitter=5000, #jitter microseconds (us)
)


print("Creating {theNum} Nodes".format(theNum=nodeTargetNum),end="", flush=True)
for nodeNum in range(1,(nodeTargetNum+1)):

    aName = "Node{n}".format(n=nodeNum)
    theOptions = NodeOptions(x=(100+nodeNum), y=(100+nodeNum), name=aName, image="pokirun:scenario", model=None)
    aNode = session.add_node(DockerNode, options=theOptions)
    mainIF = ippre_Control.create_iface(aNode)
    
    # if useDualNetwork:
        # if (nodeNum % 10) == 0:
            # session.add_link(aNode.id, switchNodesToController.id, mainIF, options=linkFaster)
            # print("F",end="",flush=True)

        # else:
            # session.add_link(aNode.id, switchNodesToController.id, mainIF, options=linkSlow)
            #print("S",end="",flush=True)
        
        #peerIF = ippre_Internal.create_iface(aNode)
        #session.add_link(aNode.id, switchNodesInternal.id, peerIF, options=linkFaster)
    #else:
    
    #if (nodeNum % 2) == 0:
    # if True:
        # session.add_link(aNode.id, switchNodesToController.id, mainIF, options=linkSlow15Sec)
    # else:
        # session.add_link(aNode.id, switchNodesToController.id, mainIF, options=linkFasterLossy)
    session.add_link(aNode.id, switchNodesToController.id, mainIF )
        
    print(".",end="",flush=True)    
    
print("Done.",flush=True)

# print("Creating Hopper Node...",flush=True)
# theOptions = NodeOptions(x=(1), y=(1), name="Hopper", image="pokirun:scenario", model=None)
# hNode = session.add_node(DockerNode, options=theOptions)
# hIF  = ippre_Control.create_iface(hNode)
# session.add_link(hNode.id, switchNodesToController.id, hIF) #has perfect networking


print("Creating Controller Node...",flush=True)
theOptions = NodeOptions(x=(1), y=(1), name="Controller", image="pokirun:scenario", model=None)
cNode = session.add_node(DockerNode, options=theOptions)
controllerIF  = ippre_Control.create_iface(cNode)
#session.add_link(cNode.id, switchNodesToController.id, controllerIF, options=linkFaster)
session.add_link(cNode.id, switchNodesToController.id, controllerIF)

print("Instantiating session...",flush=True)
session.instantiate()

signalF = open("session.ready", "w")
signalF.write("READY")
signalF.close()

print("Session active. Waiting for session.stop signal file...",flush=True)

while True:

    if (exists("session.stop")):
        break
    
    sleep(1)


print("Shutting down session. This will take a while...",flush=True)
session.shutdown()

print("Shutdown complete.",flush=True)



# if __name__ == "__main__":
    # logging.basicConfig(level=logging.DEBUG)
    # parser = argparse.ArgumentParser(description="Run distributed_switch example")
    # parser.add_argument(
        # "-a",
        # "--address",
        # required=True,
        # help="local address that distributed servers will use for gre tunneling",
    # )
    # parser.add_argument(
        # "-s",
        # "--server",
        # required=True,
        # help="distributed server to use for creating nodes",
    # )
    # args = parser.parse_args()
    # main(args)
