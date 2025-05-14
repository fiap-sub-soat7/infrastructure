# FIAP - SOAT7 - Main
## VehicleAPI

## | 🖥️ • Architecture
### Technologies
Typescript, NodeJS, Mongo (Document DB)
###  Project structure - Clean Architecture
```
vehicle.postech.app
  ├── domain/                            # Camada I - Entities
  │   ├── models/                        # Definição de entidades
  │   │   ├── ...                        # Modelo para cada entidade
  │   │   └── vehicle.model.ts
  │   ├── entity/                        # Definição de interfaces para entidades
  │   │   ├── ...                        # Dependemos apenas de interfaces, nao de implementações
  │   │   └── vehicle.entity.ts
  │   ├── repository/                    # Definição de interfaces para repositories
  │   │   ├── ...                        # Dependemos apenas de interfaces, nao de implementações
  │   │   └── vehicle.repository.ts
  ├── usecases/                          # Camada II - Casos de uso
  │   ├── vehicle/                       # Separação por contextos 
  │   │   ├── ...                        # Use cases atomicos para cada fluxo, reutilizaveis
  │   │   └── vehicle.usecase.ts
  ├── application/                       # Camada III - Controllers, Presenters
  │   ├── controllers/                   # Orquestradores
  │   │   └── vehicle/                      # Separação por contextos 
  │   │       ├── ...
  │   │       └── vehicle.controller.ts
  │   └── presenters/                    # Mapeadores
  │       └── vehicle.presenter.ts          
  ├── adapter/                           # Camada IV - Drivers, frameworks
  │   ├── repositories/                  # Adaptador para persistencia em banco de dados
  │   │   └── orm.bootstrap.ts           
  │   │   └── product.repository.ts      
  │   ├── external/                      # Adaptadores para integrações externas e outros serviços
  │   │   └── client/
  │   │       └── xpto.ts      
  │   ├── cli/                           # Adaptador para execução da aplicação via CLI
  │   │   └── ...
  │   ├── http/                          # Adaptador para execução da aplicação HTTP
  │   │   └── ...
  │   └── ...
```
### Diagrama Clean Architecture - VehicleAPP
![Diagrama Clean Architecture - VehicleAPP](docs/app.drawio.png)

### Diagrama - Event Storming e Domain Storytelling
https://miro.com/app/board/uXjVI26d5po=/

### Services
- [Vehicle] - Serviço dedicado aos veículos e venda

### DOCKER (local env, development)
1 - Run bash `docker compose up` inside infrastrure repo

Versão docker para desenvolvimento local:
Vehicle MS, databases e nginx proxy.
```sh
# all repositories must be in an up enclosing folder
docker compose up
```
2 - Done :)
```
http://localhost:3000/[microservice]/[endpoint] #proxy [ingress]
http://localhost:3001/docs # vehicle [ms]
```


