#!/bin/bash

aws_access_key=$(awk -F= '/aws_access_key_id/ && !/^#/ {print $2}' aws_access)
aws_secret_key=$(awk -F= '/aws_secret_access_key/ && !/^#/ {print $2}' aws_access)
aws_session_token=$(awk -F= '/aws_session_token/ && !/^#/ {print $2}' aws_access)

arquivo_destino="automated-networks/ansible-playbook/vars/main.yaml"
arquivo_destino_terraform="automated-networks/terraform/variables.tf"
script_destino="automated-networks/utils/network-components/start.sh"
key_destino="utils/credentials/keypair.pem"

echo -e "\n\033[1;33m- [ Atenção: É necessário que sua conta AWS Academy esteja iniciada! ] \033[0m"
sleep 1
echo -e '\n\033[1;33m- [ Atenção: É necessário que tenha colocado sua AWS CLI no arquivo "aws_access". ] \033[0m\n'
sleep 0.5
echo -e "\n\033[1;36m- [ Digite: 1 - Para iniciar o processo criação automatizada de rede emulada. ] \033[0m"
sleep 0.5
echo -e "\n\033[1;31m- [ Digite: 2 - Para deletar um cenário de rede emulada já existente. ] \033[0m\n"
echo -e '\n\033[1;35m- [ Por favor, digite o valor correspondente: ] \033[0m'
read confirmacao

if [[ "$confirmacao" =~ ^(1|01)$ ]]; then

    echo -e "\n\n\033[1;32m- [ Qual ferramenta deseja utilizar para criação do cenário? Digite apenas o número! ] \033[0m\n"
    sleep 0.5
    echo -e "\n\033[1;34m- [ 1 ] : Ansible \033[0m"
    sleep 0.5
    echo -e "\n\033[1;34m- [ 2 ] : Terraform \033[0m\n"
    sleep 0.5
    echo -e '\n\033[1;35m- [ Por favor, digite o valor correspondente: ] \033[0m'
    read iac

    echo -e "\n\n\033[1;32m- [ Digite apenas o número correspondente a topologia desejada! ] \033[0m\n"
    sleep 0.5
    echo -e "\n\033[1;34m- [ 1 ] : Topologia de Rede Single \033[0m"
    sleep 0.5
    echo -e "\n\033[1;34m- [ 2 ] : Topologia de Rede Linear \033[0m"
    sleep 0.5
    echo -e "\n\033[1;34m- [ 3 ] : Topologia de Rede Tree \033[0m\n"
    sleep 0.5
    echo -e '\n\033[1;35m- [ Por favor, digite o valor correspondente: ] \033[0m'
    read topologia

    generate_python_code() {
        local topology=$1
        local num_switches_lvl1=$2
        local num_switches_lvl2=$3
        local num_hosts_per_switch_lvl2=$4
        local num_switches=$2
        local num_hosts=$3
        local python_file="./utils/network-components/topology/topology.py"

    # Cria um arquivo temporário para o código Python
    temp_file=$(mktemp)

    cat <<EOF > $temp_file
#!/usr/bin/python

from mininet.net import Containernet
from mininet.node import Controller, RemoteController
from mininet.cli import CLI
from mininet.log import info, setLogLevel
import sys

def topology(args):
    "Create a network."
    net = Containernet(controller=Controller)

    info("*** Creating nodes\\n")
    C1 = net.addController(name='C1', controller=RemoteController, ip='localhost', protocol='tcp', port=6633)
EOF

    if [ "$topologia" == "1" ] || [ "$topologia" == "01" ]; then
        echo "    S1 = net.addSwitch('S1')" >> $temp_file
        for ((i=1; i<=$num_hosts; i++)); do
            echo "    H$i = net.addDocker('H$i', mac='00:00:00:00:00:$(printf '%02x' $i)', ip='10.0.10.1$i/24', dimage=\"alpine-user:latest\")" >> $temp_file
            echo "    net.addLink(S1, H$i)" >> $temp_file
        done

    elif [ "$topologia" == "2" ] || [ "$topologia" == "02" ]; then
        # Adicionando switches
        for ((i=1; i<=$num_switches; i++)); do
            echo "    S$i = net.addSwitch('S$i')" >> $temp_file
        done

        # Adicionando hosts e conectando cada um ao seu switch correspondente
        for ((i=1; i<=$num_hosts; i++)); do
            echo "    H$i = net.addDocker('H$i', mac='00:00:00:00:00:$(printf '%02x' $i)', ip='10.0.10.1$i/24', dimage=\"alpine-user:latest\")" >> $temp_file
            echo "    net.addLink(S$i, H$i)" >> $temp_file
        done

        # Conectando os switches em série
        for ((i=1; i<$num_switches; i++)); do
            echo "    net.addLink(S$i, S$((i + 1)))" >> $temp_file
        done

    elif [ "$topology" == "3" ] || [ "$topology" == "03" ]; then
        # Adicionando switches de nível 1
        echo "    # Nível 1: Switches conectando aos switches de nível 2" >> $temp_file
        for ((i=1; i<=$num_switches_lvl1; i++)); do
            echo "    S1$i = net.addSwitch('S1$i')" >> $temp_file
        done

        # Adicionando switches de nível 2 e conectando-os aos switches de nível 1
        echo "    # Nível 2: Switches conectados aos switches de nível 1" >> $temp_file
        for ((i=1; i<=$num_switches_lvl1; i++)); do
            for ((j=1; j<=$num_switches_lvl2; j++)); do
                echo "    S2${i}_$j = net.addSwitch('S2${i}_$j')" >> $temp_file
                echo "    net.addLink(S1$i, S2${i}_$j)" >> $temp_file

                # Conectando hosts aos switches de nível 2
                for ((k=1; k<=$num_hosts_per_switch_lvl2; k++)); do
                    echo "    H${i}_$j$k = net.addDocker('H${i}_$j$k', mac='00:00:00:00:0$i:$((j * 10 + k))', ip='10.0.$i.$((j * 10 + k))/24', dimage=\"alpine-user:latest\")" >> $temp_file
                    echo "    net.addLink(S2${i}_$j, H${i}_$j$k)" >> $temp_file
                done
            done
        done
    fi

    cat <<EOF >> $temp_file
    info("*** Starting network\\n")
    net.start()
    net.pingAll()

    info("*** Running CLI\\n")
    CLI(net)

    info("*** Stopping network\\n")
    net.stop()

if __name__ == '__main__':
    setLogLevel('info')
    topology(sys.argv)
EOF

    # Move o arquivo temporário para o arquivo final
    mv $temp_file $python_file
}

    case $topologia in
        1|01)
            echo -e '\n\033[1;35m- [ Quantos hosts serão conectados ao switch central? ] \033[0m'
            read num_hosts
            num_switches=1
    esac

    case $topologia in
    2|02)
        while true; do
            echo -e "\n\033[1;35m- [ Quantos switches devem ser criados? ] \033[0m"
            read num_switches
            echo -e "\n\033[1;35m- [ Quantos hosts devem ser criados? ] \033[0m"
            read num_hosts

            # Verifica se a quantidade de switches e hosts é a mesma
            if [ "$num_switches" -eq "$num_hosts" ]; then
                break
            else
                echo -e "\n\033[1;33m- [ A quantidade de switches e hosts devem ser a mesma na topologia Linear. Por favor, tente novamente. ] \033[0m"
            fi
        done
    esac

    case $topologia in
        3|03)
        echo -e "\n\033[1;35m- [ Quantos switches você deseja no nível 1? ] \033[0m"
        read num_switches_lvl1
        echo -e "\n\033[1;35m- [ Quantos switches você deseja no nível 2? ] \033[0m"
        read num_switches_lvl2
        echo -e "\n\033[1;35m- [ Quantos hosts serão conectados a cada switch de nível 2? ] \033[0m"
        read num_hosts_per_switch_lvl2
    esac

    if [ "$topologia" == "3" ] || [ "$topologia" == "03" ]; then
        generate_python_code "$topologia" "$num_switches_lvl1" "$num_switches_lvl2" "$num_hosts_per_switch_lvl2"
    else
        generate_python_code "$topologia" "$num_switches" "$num_hosts"
    fi

    case $iac in
    1|01)
        echo -e "\n\033[1;33m- [ Iniciando configurações da Infraestrutura. Aguarde! ] \033[0m\n"
        sudo apt update -y > /dev/null 2>&1
        sudo apt install git python3 python3-pip ansible -y > /dev/null 2>&1
        pip install boto3 ansible-core==2.16.0 Jinja2==3.1.3 urllib3==1.26.5 > /dev/null 2>&1
        ansible-galaxy collection install community.aws --force > /dev/null 2>&1
        awk -v new_value_1="$aws_access_key" 'NR == 2 {print "aws_access_key: " new_value_1} NR != 2' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
        awk -v new_value_2="$aws_secret_key" 'NR == 3 {print "aws_secret_key: " new_value_2} NR != 3' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
        awk -v new_value_3="$aws_session_token" 'NR == 4 {print "aws_session_token: " new_value_3} NR != 4' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
        echo -e "\033[1;32m- [ Dependências instaladas com Sucesso! ] \033[0m\n"
        ansible-playbook -i automated-networks/ansible-playbook/hosts automated-networks/ansible-playbook/playbook.yaml
        #ip=$(awk '/ansible_host/ {match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/); print substr($0, RSTART, RLENGTH)}' automated-networks/ansible-playbook/hosts)
        #ssh -i "$key_destino" ubuntu@"$ip"
    esac

    case $iac in
    2|02)
        if [ ! -f "$key_destino" ]; then
            touch "$key_destino"
        fi
        sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl > /dev/null 2>&1
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - > /dev/null 2>&1
        echo "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null 2>&1
        sudo apt-get install terraform -y  > /dev/null 2>&1
        sed -i -e "4s|.*|  default = \"$aws_access_key\"|" -e "10s|.*|  default = \"$aws_secret_key\"|" -e "16s|.*|  default = \"$aws_session_token\"|" "$arquivo_destino_terraform"
        terraform -chdir=automated-networks/terraform init
        terraform -chdir=automated-networks/terraform apply -auto-approve
    esac

elif [[ "$confirmacao" =~ ^(2|02)$ ]]; then
    echo -e "\n\n\033[1;32m- [ Qual ferramenta será usada para destruir o cenário? ] \033[0m\n"
    sleep 0.5
    echo -e "\n\033[1;34m- [ 1 ] : Ansible \033[0m"
    sleep 0.5
    echo -e "\n\033[1;34m- [ 2 ] : Terraform \033[0m\n"
    sleep 0.5
    echo -e '\n\033[1;35m- [ Por favor, digite o valor correspondente: ] \033[0m'
    read destroy

    case $destroy in
    1|01)
    esac
	ansible-playbook -i automated-networks/ansible-playbook/hosts automated-networks/ansible-playbook/playbook-destroy.yaml
    case $destroy in
    2|02)
        terraform -chdir=automated-networks/terraform destroy -auto-approve
    esac
else
    echo -e "\n\033[1;33m- [ Desculpe, valor não encontrado, encerrando terminal... ] \033[0m"
fi
