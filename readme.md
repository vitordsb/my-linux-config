Lembrete de como instalar tudo

**Primeiro passo é atualizar o sistema e instalar o git na maquina com:**

`sudo apt-get update && sudo apt-get upgrade -y`

`sudo apt-get install git`
##

depois disso, baixe o repositório: `git clone https://github.com/vitordsb/linux-setup`
##

Ápos isso entre na pasta onde foi baixado o repositório.

`cd linux-setup`

transforme o arquivo ./install.sh em executável e faça a execução com:

`sudo chmod +x install.sh && sudo ./install.sh`

**O ./install.sh tem que ser executado como adm (sudo) para ocorrer sem erros de permissão**

Durante a execução será exibido um menu para escolher quais módulos instalar:

- `1` Base do sistema
- `2` Ferramentas de desenvolvimento
- `3` Shell/terminal (Fish + plugins)
- `4` Neovim (build custom + dotfiles)
- `5` Aplicativos via APT (ex.: Windsurf)
- `6` Aplicativos via Flatpak
- `7` Bancos de dados (MySQL/Postgres)
- `8` Limpeza final / reboot opcional
- `all` instala tudo na ordem acima (opção padrão)

## Novidades do instalador

- Detecta automaticamente a distro via `/etc/os-release` e só continua em sistemas baseados em APT (Debian/Ubuntu); suporte a outros gerenciadores pode ser adicionado no futuro.
- Executa pré-checks antes de instalar (rede, espaço em disco e presença do `sudo`) para evitar falhas na metade do processo.
- Ao final, gera um relatório `~/POST_INSTALL.md` com as etapas concluídas e próximos passos recomendados (Android Studio, MySQL, Flatpak, reboot etc.).
