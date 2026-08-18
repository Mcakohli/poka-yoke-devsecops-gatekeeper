# Poka-Yoke DevSecOps CI/CD Gatekeeper

[![Poka-Yoke CI/CD Gatekeeper](https://github.com/Mcakohli/poka-yoke-devsecops-gatekeeper/actions/workflows/poka_yoke_gatekeeper.yml/badge.svg)](https://github.com/Mcakohli/poka-yoke-devsecops-gatekeeper/actions/workflows/poka_yoke_gatekeeper.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.11](https://img.shields.io/badge/python-3.11-blue.svg)](https://www.python.org/downloads/release/python-3110/)
[![Terraform 1.7.0](https://img.shields.io/badge/terraform-1.7.0-purple.svg)](https://www.terraform.io/)

A fail-closed DevSecOps continuous integration and deployment gatekeeper enforcing deterministic data ingestion, static AST/secret scanning, and compliant Infrastructure-as-Code (IaC) provisioning for Google Cloud BigQuery.

---

## Architecture & Engineering Principles
```mermaid
graph TD
    A[Client / Ingestion Payload] -->|HTTP POST| B[DRF Serializer: DCYN Converter]
    B -->|Ambiguous Inputs Blocked| C[400 Validation Error]
    B -->|Deterministic 0 or 1| D[Validated Sink / BigQuery Ingestion]
    
    subgraph CI_CD_Gatekeeper [GitHub Actions Fail-Closed CI/CD Pipeline]
        E[Git Push / PR] --> F[Backend Suite: Black, Flake8, Pytest]
        E --> G[DevSecOps Gate: Bandit AST, TruffleHog, Trivy]
        E --> H[IaC Gate: Terraform fmt, validate]
        F --> I{All Pass?}
        G --> I
        H --> I
        I -->|Yes| J[Merge to Main Allowed]
        I -->|No| K[Pipeline Blocked]
    end
```

1. **Poka-Yoke Ingestion (Mistake-Proofing)**:
   * Employs Django REST Framework (DRF) serializers with custom deterministic converters (`DCYN` logic).
   * Transforms ambiguous/freeform survey inputs into strict binary integer flags (`1` or `0`) before payloads hit downstream data lakes.
2. **Shift-Left DevSecOps Gatekeepers**:
   * **Bandit**: Static AST analysis to block Python security flaws.
   * **TruffleHog**: High-entropy verified credential and secret leak detection.
   * **Trivy**: Comprehensive filesystem vulnerability and misconfiguration scanning.
3. **Infrastructure-as-Code Compliance**:
   * Automated modular Terraform linting (`fmt`) and semantic validation (`validate`) for BigQuery dataset provisioning and IAM role bindings.

---

## CI/CD Pipeline Matrix

| Gatekeeper Job | Tools Used | Enforcement Objective |
| :--- | :--- | :--- |
| **Backend Quality & Tests** | `black`, `flake8`, `pytest` | Code standard formatting, syntax linting, and 100% unit test coverage. |
| **DevSecOps Security** | `bandit`, `trufflehog`, `trivy` | Zero AST security vulnerabilities, zero committed secrets, and CVE scanning. |
| **Terraform IaC** | `terraform fmt`, `terraform validate` | Strict HCL canonical formatting and valid resource dependency graphs. |

---

## Local Development & Testing

```bash
# 1. Install dependencies
pip install -r backend/requirements.txt

# 2. Run Python formatting & linting
black --check backend/
flake8 backend/ --max-line-length=88

# 3. Run Unit Test Suite
pytest backend/tests/ -v

# 4. Validate Terraform
cd infrastructure/terraform
terraform init -backend=false
terraform validate
