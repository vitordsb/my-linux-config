Lembrete de como instalar tudo

**Primeiro passo é instalar o git na maquina com:**

`sudo apt-get install git`
##

depois disso, baixe o repositório: `git clone https://github.com/vitordsb/linux-setup`
##

Ápos isso entre na pasta onde foi baixado o repositório.

`cd linux-setup`

transforme o arquivo ./install.sh em executável e faça a execução com:

`sudo chmod +x install.sh && sudo ./install.sh`

**O ./install.sh tem que ser executado como adm (sudo) para ocorrer sem erros de permissão**

## Novidades do instalador

- Detecta automaticamente a distro via `/etc/os-release` e só continua em sistemas baseados em APT (Debian/Ubuntu); suporte a outros gerenciadores pode ser adicionado no futuro.
- Executa pré-checks antes de instalar (rede, espaço em disco e presença do `sudo`) para evitar falhas na metade do processo.
- Ao final, gera um relatório `~/POST_INSTALL.md` com as etapas concluídas e próximos passos recomendados (Android Studio, MySQL, Flatpak, reboot etc.).
