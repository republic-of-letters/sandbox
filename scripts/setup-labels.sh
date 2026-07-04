#!/usr/bin/env bash
# Create the standard protocol labels on a fresh repo (SETUP.md step 5).
# Idempotent: --force updates colour/description if the label already exists.
set -euo pipefail

gh label create "round:running"  --color FBCA04 --description "Round open, awaiting the Runner"            --force
gh label create "round:answered" --color 0E8A16 --description "Runner pushed RESULT.md; awaiting merge"    --force
gh label create "blocked"        --color B60205 --description "Emergency stop — agents halt (AGENTS.md §13)" --force
gh label create "priority:high"  --color D93F0B --description "Jumps the FIFO queue; use sparingly (§5.0)" --force
gh label create "question"       --color C5DEF5 --description "Not a round — scoping, blockers, data questions" --force
gh label create "topic-proposal" --color BFD4F2 --description "An idea that could become a topic (§12)"    --force
gh label create "topic:T01"      --color 1D76DB --description "Rounds belonging to topic T01"              --force

echo "labels ready — add topic:T<NN> labels as topics open (gh label create \"topic:T02\" --color 1D76DB)"
