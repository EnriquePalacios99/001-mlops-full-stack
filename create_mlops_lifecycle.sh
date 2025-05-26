# 1️⃣  Genera el archivo con el código
cat > create_mlops_lifecycle.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# --- Definición de los bloques/herramientas ---------------------------
TOOLS="
01-Experiment_Tracking/01-MLflow
01-Experiment_Tracking/02-Weights_and_Biases
02-Pipelines_Orchestration/01-Prefect
02-Pipelines_Orchestration/02-Airflow
03-Feature_Store/01-Feast
04-Model_Registry/01-MLflow_Registry
05-Deployment/01-BentoML
05-Deployment/02-Seldon_Core
06-Monitoring_Observability/01-Evidently_AI
06-Monitoring_Observability/02-Prometheus_Grafana
07-Data_Validation/01-Great_Expectations
08-Testing_CI_CD/01-GitHub_Actions
09-Infrastructure_as_Code/01-Terraform
09-Infrastructure_as_Code/02-Helm
10-Data_Versioning/01-DVC
"

CLOUDS=("aws" "gcp" "azure")

# --- Carpetas globales -------------------------------------------------
mkdir -p docs infra .github/workflows
[[ -f README.md ]] || echo "# MLOPS Lifecycle" > README.md

cat > .github/workflows/lint-test.yml <<'YAML'
name: Lint & Unit Tests
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install -r requirements.txt
      - run: pytest -q
YAML

# --- Generar la jerarquía ---------------------------------------------
while IFS= read -r line; do
  [[ -z "$line" ]] && continue                     # salta líneas vacías
  base="$line"                                     # p.ej. 01-Experiment_Tracking/01-MLflow
  name="${base##*/}"; name="${name:3}"             # MLflow (sin prefijo numérico)

  for d in 01-Theory 02-Implementation 03-Evaluation 04-Deployment 05-MLOps; do
    mkdir -p "$base/$d"
  done

  touch "$base/01-Theory/$name.md" \
        "$base/02-Implementation/$name.ipynb" \
        "$base/03-Evaluation/Checklist.md" \
        "$base/04-Deployment/README.md" \
        "$base/05-MLOps/Best_Practices.md"

  for cloud in "${CLOUDS[@]}"; do
    ia_dir=$([[ $cloud == "azure" ]] && echo bicep || echo terraform)
    mkdir -p "infra/$cloud/$base/$ia_dir"
    mkdir -p "infra/$cloud/$base/ci"
  done
done <<< "$TOOLS"

echo "✅  Estructura MLOPS Lifecycle creada en $(pwd)"
EOF

# 2️⃣  Hazlo ejecutable
chmod +x create_mlops_lifecycle.sh

# 3️⃣  Ejecútalo
./create_mlops_lifecycle.sh
