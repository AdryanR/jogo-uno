# Jogo - UNO

Jogo de [UNO](https://pt.wikipedia.org/wiki/Uno_(jogo_de_cartas)) (jogo de cartas), *multiplayer* (2 jogadores) desenvolvido em Delphi 10 com uso de Sockets e Threads. 

<p align="center">
  <img
    width="80%"
    alt="Tela inicial jogo"
    src="https://user-images.githubusercontent.com/92650594/176304080-7b847d8f-0db1-4ecc-8765-3ed4d445bd6d.PNG"
  >
</p>

O único jogo de UNO desenvolvido em Delphi, jogo multiplayer atráves de cliente/servidor com o componente multithread Indy Sockets. Durante o desenvolvimento foram levantadas as cartas do jogo original e também as regras ao mais fiel possível, pois há muitas regras não oficiais criadas pelos jogadores.

## Funcionalidades

- Servidor em CLOUD (Amazon AWS)
- Banco de dados MySQL
- Ranking dos jogos
- Cliente e servidor
- Sockets/Threads

<p align="center">
  <img
    width="80%"
    alt="Lobby do jogo"
    src="https://user-images.githubusercontent.com/92650594/176306948-7148c3fb-1a0a-4381-bb60-1feaf9020e01.PNG"
  >
  <img
    width="80%"
    alt="Tela do jogo em execução"
    src="https://user-images.githubusercontent.com/92650594/176306945-ac675ed8-d974-4086-bb2a-a55256d8385e.PNG"
  >
</p>

## Stack utilizada

- Delphi 10.3.3, [Indy](https://www.indyproject.org/), MySQL

## Projeto
Esta aplicação faz parte de um projeto onde trabalhei com mais duas pessoas: [Anderson Bruns](https://github.com/AndersonBruns/) e [Ricardo Filho](https://github.com/ricardo-14).

Na pasta "Projeto Final" contém o projeto pronto, compilando o cliente e servidor juntos, assim o usuário escolhe se vai criar uma sala (ser o servidor) ou se vai entrar em uma sala (ser o cliente).
No diretório principal contém o executável final e a DLL necessária.
*Requer IPV6*

## Como usar
```
Delphi 10.3.3, requer IPV6 e DLL "libmysql.dll" para comunicação com o banco de dados.
```
