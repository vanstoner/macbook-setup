function createDemo {
  if [ $# -lt 2 ]; then
    echo "Usage: createDemo <name> <memSizeInMB>"
    return
  fi

  if $(docker-machine ls|grep $1 > /dev/null); then
    echo "Machine exists, skipping creation."
  else
    docker-machine create $1 --driver virtualbox --virtualbox-memory $2 --virtualbox-cpu-count 4 --engine-insecure-registry  registry.xebialabs.com
  fi

  eval "$(docker-machine env $1)"
  replaceHost $1 $(docker-machine ip $1)
  docker login -u rvanstone@xebialabs.com -p St4b1li$ registry.xebialabs.com
  /Users/vanstoner/github/xebialabs-external/demo-self-service/petportal/start-demo.sh
} 

function rmDemo {
  if [ $# -ne 1 ]; then
    echo "Usage: rmDemo <name>"
    return
  fi
  docker-machine rm $1
}

function removeHost() {
    if [ $# -ne 1 ]; then
     echo "Usage: removeHost <hostname>"
     return
    fi
    if [ -n "$(grep $1 /etc/hosts)" ]
    then
        echo "$1 Found in your /etc/hosts file, Removing now...";
        sudo sed -i".bak" "/$1/d" /etc/hosts
    else
        echo "$1 was not found in your /etc/hosts file";
    fi
}

function addHost() {
    if [ $# -ne 2 ]; then
     echo "Usage: addHost <hostname> <ip address>"
     return
    fi
    HOSTNAME=$1
    IP=$2

    HOSTS_LINE="$IP\t$HOSTNAME"
    if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
        then
            echo "$HOSTNAME already exists : $(grep $HOSTNAME /etc/hosts)"
        else
            echo "Adding $HOSTNAME to your /etc/hosts";
            sudo -- sh -c -e "echo '$HOSTS_LINE' >> /etc/hosts";

            if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
                then
                    echo "$HOSTNAME was added succesfully \n $(grep $HOSTNAME /etc/hosts)";
                else
                    echo "Failed to Add $HOSTNAME, Try again!";
            fi
    fi
}

function replaceHost {
  if [ $# -ne 2 ]; then
     echo "Usage: replaceHost <hostname> <ip>"
     return
  fi
  if [ -n "$(grep $1 /etc/hosts)" ]; then
    removeHost $1
    addHost $1 $2
  else
    addHost $1 $2
  fi
}

function getXlSoftware {
  APPS_DIR=~/apps/xebialabs
  TRIAL_URL=$1
  LICENSE_PREFIX=$2

  echo "Downloading ${TRIAL_URL}" 
  http --download ${TRIAL_URL} --output /tmp/xl.zip
  
  if [ -d ${APPS_DIR} ]; then
    echo "${APPS_DIR} directory already exists..."
  else
    mkdir -p ${APPS_DIR}
  fi

  version=$(unzip -v /tmp/xl.zip|grep xl-|awk '{print $8}'|awk -F"/" '{print $1}'|uniq)

  if [ -d ${APPS_DIR}/${version} ]; then
    echo "Latest version already installed - skipping..."
  else
    echo "Unzipping version to ${APPS_DIR}"
    unzip /tmp/xl.zip -d ${APPS_DIR}
  
    echo "Creating license symlink"
    ln -fs ~/xl-licenses/${LICENSE_PREFIX}-license.lic ${APPS_DIR}/${version}/conf/${LICENSE_PREFIX}-license.lic
  fi
  


}

function getXlr {
   getXlSoftware "https://dist.xebialabs.com/xl-release-trial.zip" "xl-release" 
}

function getXld {
  getXlSoftware "https://dist.xebialabs.com/xl-deploy-trial-server.zip" "deployit"
}
