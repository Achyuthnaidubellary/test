# Terraform Variable Case Sensitivity Test

This prototype tests whether Terraform handles case-sensitive variables correctly when values are provided through GitHub environment variables using the `TF_VAR_` prefix.

## 🎯 Test Scenario

**THE PROBLEM:** GitHub environment variables are typically UPPERCASE, but Terraform best practice uses lowercase snake_case for variable names.

This project tests:
- ❌ Whether UPPERCASE GitHub env vars (`ENVIRONMENT_NAME`) can map to lowercase Terraform variables (`environment_name`)
- ✅ The workaround to transform between them in the GitHub Actions workflow
- 🔍 Proof that Terraform variable names are **case-sensitive** and require exact matching

## 📁 Project Structure

```
.
├── main.tf                      # Terraform config with case-sensitive variables
├── terraform.tfvars.example     # Example variable values
├── .github/
│   └── workflows/
│       └── terraform-case-test.yml  # GitHub Actions workflow
└── README.md
```

## 🔬 Test Variables

The following variables test the real-world scenario:

| Terraform Variable (lowercase) | GitHub Env Var (UPPERCASE) | Mapping Result |
|-------------------------------|---------------------------|----------------|
| `environment_name` | `ENVIRONMENT_NAME` | ❌ **NO MATCH** (case mismatch) |
| `project_id` | `PROJECT_ID` | ❌ **NO MATCH** (case mismatch) |
| `region` | `REGION` | ❌ **NO MATCH** (case mismatch) |
| `cluster_name` | `CLUSTER_NAME` | ❌ **NO MATCH** (case mismatch) |

**Plus comparison variables:**
| Terraform Variable (UPPERCASE) | GitHub Env Var (UPPERCASE) | Mapping Result |
|-------------------------------|---------------------------|----------------|
| `ENVIRONMENT_NAME` | `ENVIRONMENT_NAME` | ✅ **MATCH** (exact case) |
| `PROJECT_ID` | `PROJECT_ID` | ✅ **MATCH** (exact case) |

## 🚀 How to Run

### Local Testing

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Test with environment variables:**
   ```bash
   export TF_VAR_environment_name="local-test-lower"
   export TF_VAR_EnvironmentName="local-test-pascal"
   export TF_VAR_ENVIRONMENT_NAME="local-test-upper"
   export TF_VAR_environmentName="local-test-camel"
   
   terraform plan
   terraform apply
   ```

3. **Check outputs:**
   ```bash
   terraform output
   cat terraform-output.txt
   ```

4. **Cleanup:**
   ```bash
   terraform destroy
   ```

### GitHub Actions Testing

1. **Push to GitHub:**
   ```bash
   git add .
   git commit -m "Add Terraform case sensitivity test"
   git push origin main
   ```

2. **Run the workflows:**
   
   **Workflow 1: Terraform Case Sensitivity Test** (Shows the problem)
   - Go to Actions tab → "Terraform Case Sensitivity Test"
   - Click "Run workflow"
   - Result: Will show that UPPERCASE env vars DON'T map to lowercase Terraform vars
   
   **Workflow 2: Terraform Case Sensitivity - With Workaround** (Shows the solution)
   - Go to Actions tab → "Terraform Case Sensitivity - With Workaround"
   - Click "Run workflow"
   - Result: Will show successful transformation and mapping

3. **View results:**
   - Check the workflow logs for variable values
   - See the case mapping test output
   - Download artifacts to see the generated output file

### Using GitHub Environment Variables

You can also configure repository/environment-level variables:

1. Go to Settings → Environments → Create environment (e.g., "test")
2. Add environment variables:
   - `TF_VAR_environment_name` = "prod-env"
   - `TF_VAR_EnvironmentName` = "ProdEnv"
   - `TF_VAR_ENVIRONMENT_NAME` = "PROD-ENV"
   - etc.

3. Update workflow to use environment:
   ```yaml
   jobs:
     terraform-case-test:
       environment: test
   ```

## 📊 Expected Results

**Key Finding:** Terraform variable names are **case-sensitive** and require **EXACT matching**.

### Without Workaround (First Workflow):
- ❌ `TF_VAR_ENVIRONMENT_NAME` → does NOT set `environment_name` (lowercase)
- ❌ `TF_VAR_PROJECT_ID` → does NOT set `project_id` (lowercase)
- ✅ `TF_VAR_ENVIRONMENT_NAME` → DOES set `ENVIRONMENT_NAME` (uppercase)

### With Workaround (Second Workflow):
- ✅ Transform `ENVIRONMENT_NAME` → `TF_VAR_environment_name` in workflow
- ✅ Successfully sets lowercase Terraform variables
- ✅ Maintains UPPERCASE convention in GitHub while using lowercase in Terraform

## ⚠️ Important Notes

1. **Case Sensitivity:** Variable names must match exactly (case-sensitive)
2. **TF_VAR_ Prefix:** GitHub env vars must use exact case after the prefix
3. **Best Practice:** Use consistent naming (typically `snake_case`) for all Terraform variables
4. **Avoid Confusion:** Don't create variables that differ only in case

## 🧪 Testing Different Scenarios

### Scenario 1: GitHub UPPERCASE → Terraform lowercase (FAILS)
```bash
export TF_VAR_ENVIRONMENT_NAME="production"
terraform apply
# Result: Only 'ENVIRONMENT_NAME' variable set, NOT 'environment_name'
```

### Scenario 2: Exact case match (WORKS)
```bash
export TF_VAR_environment_name="production"
terraform apply
# Result: 'environment_name' variable is set correctly
```

### Scenario 3: Workaround - Transform in workflow (WORKS)
```bash
# In GitHub Actions workflow
ENVIRONMENT_NAME="PRODUCTION"
export TF_VAR_environment_name="${ENVIRONMENT_NAME,,}"  # Convert to lowercase
terraform apply
# Result: 'environment_name' set to "production"
```

## 🔧 Workaround Solutions

### Solution 1: Transform in Workflow (Recommended)
```yaml
- name: Transform Variables
  run: |
    # Convert UPPERCASE GitHub vars to lowercase TF_VAR_
    echo "TF_VAR_environment_name=${ENVIRONMENT_NAME,,}" >> $GITHUB_ENV
    echo "TF_VAR_project_id=${PROJECT_ID,,}" >> $GITHUB_ENV
```

### Solution 2: Use Lowercase in GitHub Environment Variables
- Set GitHub env vars as: `environment_name`, `project_id` (not typical but works)

### Solution 3: Use UPPERCASE in Terraform (Not Recommended)
```hcl
variable "ENVIRONMENT_NAME" {  # Not best practice
  type = string
}
```

### Solution 4: Script-based transformation
```bash
# Create a transformation script
for var in ENVIRONMENT_NAME PROJECT_ID REGION; do
  lower_var=$(echo "$var" | tr '[:upper:]' '[:lower:]')
  export "TF_VAR_${lower_var}=${!var}"
done
```

## 📚 References

- [Terraform Environment Variables](https://developer.hashicorp.com/terraform/cli/config/environment-variables)
- [Terraform Input Variables](https://developer.hashicorp.com/terraform/language/values/variables)
- [GitHub Actions Environment Variables](https://docs.github.com/en/actions/learn-github-actions/variables)

## ✅ Conclusion

### Key Findings:
1. ❌ **UPPERCASE GitHub env vars do NOT automatically map to lowercase Terraform variables**
2. ✅ **Terraform variable names are strictly case-sensitive** - exact match required
3. ✅ **Workaround exists**: Transform case in the GitHub Actions workflow
4. 📝 **Best practice**: Use bash parameter expansion `${VAR,,}` to convert to lowercase

### Recommendation:
Use the **workaround workflow** (`terraform-workaround.yml`) which:
- Keeps UPPERCASE convention in GitHub environment variables
- Uses lowercase (best practice) in Terraform variable definitions  
- Transforms between them automatically in the workflow

This allows you to follow both GitHub's UPPERCASE convention and Terraform's lowercase best practices!
