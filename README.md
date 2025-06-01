# README

```mermaid
---
title: Artifacts Refactor
---
flowchart LR
    ArtifactStencils
    Users
    Artifacts
    FavoriteArtifacts
    Conversations
    Messages
    Projects
    WeeklyConsumptions

    ArtifactStencils --> FavoriteArtifacts
    Users --> FavoriteArtifacts
    FavoriteArtifacts --> Artifacts
    Artifacts --> Conversations
    Artifacts --> Messages
    Artifacts --> Projects
    Users --> WeeklyConsumptions

```
