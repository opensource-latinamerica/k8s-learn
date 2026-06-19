#!/bin/bash
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2026
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

set -o pipefail
set -o errexit
set -o nounset
if [[ ${DEBUG:-false} == "true" ]]; then
    set -o xtrace
fi

# Ensure qmd model cache directory exists with correct permissions
mkdir -p "${HOME}/.cache/qmd/models"

# Initialize qmd local index if not already present
qmd init

# Global context orients LLMs to the overall workspace purpose
qmd context add / \
    "Kubernetes study group knowledge base: weekly sessions covering controller internals, control loops, reconciliation patterns, and core API machinery"

to_title() {
    local value="$1"
    value="${value//-/ }"
    value="${value//_/ }"
    echo "$value" | sed -E 's/\<./\U&/g'
}

build_week_topics() {
    local week_dir="$1"
    local topics=()
    local lesson
    local lesson_name

    for lesson in "$week_dir"/[0-9][0-9]-*.md; do
        [[ -f "$lesson" ]] || continue
        lesson_name=$(basename "$lesson" .md)
        lesson_name="${lesson_name#*-}"
        topics+=("$(to_title "$lesson_name")")
    done

    if [[ ${#topics[@]} -eq 0 ]]; then
        echo "Kubernetes internals and controller behavior"
        return
    fi

    local joined=""
    local topic
    for topic in "${topics[@]}"; do
        if [[ -n "$joined" ]]; then
            joined+=", "
        fi
        joined+="$topic"
    done

    echo "$joined"
}

root_dir=$(git rev-parse --show-toplevel)

for session_dir in "$root_dir"/docs/session*/; do
    [[ -d "$session_dir" ]] || continue

    session_name=$(basename "$session_dir")
    session_num="${session_name#session}"

    for week_dir in "$session_dir"/week*/; do
        [[ -d "$week_dir" ]] || continue

        week_name=$(basename "$week_dir")
        week_num="${week_name#WW}"
        week_num="${week_num#week}"

        collection_name="${session_name}-${week_name}"
        week_topics=$(build_week_topics "$week_dir")

        # Register collection only if not already present
        if ! qmd collection list 2>/dev/null | grep -qE "^${collection_name}[[:space:]]"; then
            qmd collection add "$week_dir" --name "$collection_name"
        fi

        # Collection root context: describe the exact session/week content
        qmd context add "qmd://${collection_name}" \
            "Kubernetes study group session ${session_num}, week ${week_num}: ${week_topics}"

        # Per document context for finer-grained retrieval
        for lesson in "$week_dir"/*.md; do
            [[ -f "$lesson" ]] || continue
            lesson_file=$(basename "$lesson")
            lesson_name=$(basename "$lesson" .md)

            if [[ "$lesson_name" == "README" ]]; then
                qmd context add "qmd://${collection_name}/${lesson_file}" \
                    "Overview and study guide for Kubernetes session ${session_num} week ${week_num}"
                continue
            fi

            lesson_slug="${lesson_name#*-}"
            lesson_title=$(to_title "$lesson_slug")

            qmd context add "qmd://${collection_name}/${lesson_file}" \
                "Kubernetes session ${session_num} week ${week_num} lesson: ${lesson_title}"
        done
    done
done

# Pull latest content for all registered collections then rebuild the index
qmd update
qmd embed
