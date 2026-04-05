# portfolio_project
graph TD

    %% USER
    U[User / Client<br/>Requests]:::user

    %% SERVICE
    S[Kubernetes Service<br/>tdl-api-service<br/>Selector: version=blue/green]:::service

    %% BLUE DEPLOYMENT
    subgraph BLUE[BLUE Deployment<br/>Stable Release v1.1.0]
        direction TB
        B1[Pod: tdl-api-blue-1]:::healthy
        B2[Pod: tdl-api-blue-2]:::healthy
        B3[Pod: tdl-api-blue-3]:::healthy
    end

    %% GREEN DEPLOYMENT
    subgraph GREEN[GREEN Deployment<br/>Broken Release v1.1.1]
        direction TB
        G1[Pod: tdl-api-green-1<br/>CrashLoopBackOff]:::broken
        G2[Pod: tdl-api-green-2<br/>CrashLoopBackOff]:::broken
        G3[Pod: tdl-api-green-3<br/>CrashLoopBackOff]:::broken
    end

    %% TRAFFIC FLOW
    U --> S

    S -->|If selector = blue| B1
    S -->|If selector = blue| B2
    S -->|If selector = blue| B3

    S -.->|If selector = green| G1
    S -.->|If selector = green| G2
    S -.->|If selector = green| G3

    %% STYLES
    classDef healthy fill:#b6f2b6,stroke:#2d7a2d,stroke-width:2px;
    classDef broken fill:#ffb3b3,stroke:#b30000,stroke-width:2px,stroke-dasharray: 5 5;
    classDef service fill:#cce0ff,stroke:#0047b3,stroke-width:2px;
    classDef user fill:#fff2cc,stroke:#b38f00,stroke-width:2px;
