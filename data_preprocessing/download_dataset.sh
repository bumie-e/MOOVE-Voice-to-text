#!/usr/bin/env bash
set -euo pipefail

LOCAL_DIR="${1:-./datasets}"
AMHARIC_DIR="${LOCAL_DIR}/amharic"
TIGRIGNA_DIR="${LOCAL_DIR}/tigrigna"
AFAN_OROMO_DIR="${LOCAL_DIR}/afan_oromo"

mkdir -p "$LOCAL_DIR"
mkdir -p "$AMHARIC_DIR"
mkdir -p "$TIGRIGNA_DIR"
mkdir -p "$AFAN_OROMO_DIR"

echo "Downloading datasets to: $LOCAL_DIR"

hf download shunyalabs/amharic-speech-dataset \
    --repo-type dataset \
    --local-dir "$AMHARIC_DIR"

hf download silencioNetwork/amharic-speech \
    --repo-type dataset \
    --local-dir "$AMHARIC_DIR"

hf download leyu-amharic/leyu-amharic-gojjam-dialect \
    --repo-type dataset \
    --local-dir "$AMHARIC_DIR"

hf download leyu-amharic/leyu-amharic-gonder-dialect \
    --repo-type dataset \
    --local-dir "$AMHARIC_DIR"

hf download leyu-amharic/leyu-amharic-wello-dialect \
    --repo-type dataset \
    --local-dir "$AMHARIC_DIR"

hf download leyu-amharic/leyu-amharic-shewa-dialect \
    --repo-type dataset \
    --local-dir "$AMHARIC_DIR"

hf download badrex/amharic-speech \
    --repo-type dataset \
    --local-dir "$AMHARIC_DIR"

hf download badrex/tigrinya-speech \
    --repo-type dataset \
    --local-dir "$TIGRIGNA_DIR"

hf download phoneticoai/phonetico-speech \
    --repo-type dataset \
    --local-dir "$TIGRIGNA_DIR"

hf download turiabu/Sagalee \
    --repo-type dataset \
    --local-dir "$AFAN_OROMO_DIR"

kaggle datasets download -d ashenafifasilkebede/amharic-speech-corpus -p "$AMHARIC_DIR"
# Other files were downloaded from the website directly as zip files

echo "Download complete."
