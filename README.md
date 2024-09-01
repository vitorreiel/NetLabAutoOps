# ⌨️ NetLabAutoOps 💻
<br>

O objetivo deste projeto é propor, de forma automatizada, a criação de topologias de rede SDN utilizando containers Docker e a ferramentar Containernet com implementação na nuvem AWS.

<br>

---
<br>
<br>

<div align="center"><img width="150" height="150" src="https://cdn-icons-png.flaticon.com/512/564/564619.png"></img></div>

<br>
<br>

> #### 🎯 Nota: É importante destacar que siga todas as instruções abaixo, para que não ocorra nenhum tipo de problema.

<br>

---

<br>

## 🔎 Pré-requisitos:
<br>

```sh
✏️ 1° Requisito - Tenha acesso a uma conta AWS Academy;

✏️ 2° Requisito - Tenha acesso a um terminal Linux com permissão de super usuário.
```

---

<br>

## 🔎 Execução:
<br>

**✏️ 1° Passo** - Clone este repositório em sua máquina local utilizando o comando abaixo no seu terminal:
```sh
git clone https://github.com/vitorreiel/NetLabAutoOps.git
```
<br>
<br>

**✏️ 2° Passo** - Acesse sua AWS Academy e inicie seu Lab. Para iniciar seu Lab, basta clicar na opção:
```sh
Start Lab
```

<br>
<br>

**✏️ 3° Passo** - Acesse sua AWS Academy e clique na opção "AWS Details". Feito isso, procure a informação "AWS CLI" e em seguida, clique na opção "Show". Com isso, copie toda sua AWS CLI, pois ela será usada posteriormente. Abaixo um exemplo de como seria uma AWS CLI:
```sh
[default] 
aws_access_key_id=xxxxxxxxxxxxxxxxxx 
aws_secret_access_key=xxxxxxxxxxxxxxxxxxxxxxxxx 
aws_session_token=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

<br>
<br>

**✏️ 4° Passo** - Retorne para o terminal de sua máquina local e entre no repositório "NetLabAutoOps". Feito isso, utilize o editor de texto de sua preferência para editar o arquivo "aws_access". Com isso, cole sua AWS CLI copiada no passo anterior. Abaixo um exemplo de como entrar no repositório e editar o arquivo "aws_access":
```sh
cd NetLabAutoOps
nano aws_access
```

>  🎯 **Nota:** Você pode apagar, se desejar, todo o conteúdo comentado no arquivo aws_access e depois colar sua AWS CLI. Como também, pode apenas colar na útlima linha do arquivo. Fica a sua escolha.
<br>
<br>

**✏️ 5° Passo** - Por fim, execute o script. Abaixo o comando de execução do script:
```sh
./start.sh
```

<br>
<br>

---

<br>

#### 🎯 Nota: Os dados de capturados usado para análise comparativa das ferramentas de IaC, podem ser encontradas aqui:
[🗂 NetLabAutoOps-Dataset 📈](https://github.com/vitorreiel/NetLabAutoOps-Dataset.git)

<br>

---

<div style="display: inline_block;">

   ![Badge em Desenvolvimento](http://img.shields.io/static/v1?label=STATUS&message=EM%20DESENVOLVIMENTO&color=GREEN&style=for-the-badge)

</div>
<div style="display: inline_block;">
   <img height="34" width="34" hspace="7" src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/docker/docker-original.svg" />
   <img height="34" width="30" hspace="7" src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/terraform/terraform-original.svg" />
   <img height="34" width="30" hspace="7" src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/amazonwebservices/amazonwebservices-plain-wordmark.svg" />
</div>
