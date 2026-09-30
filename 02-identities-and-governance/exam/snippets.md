# Path 02 — Snippet drills (CLI / PowerShell / ARM / Bicep)

Recognize the **triple** and the **wrong plane**. You will not type these from a blank terminal on the exam.

## Azure RBAC — which line is the assignment?

```bash
az role assignment create \
  --assignee maria@contoso.com \
  --role "Virtual Machine Contributor" \
  --scope "/subscriptions/<subId>/resourceGroups/rg-app"
```

```powershell
New-AzRoleAssignment -SignInName maria@contoso.com `
  -RoleDefinitionName 'Virtual Machine Contributor' `
  -ResourceGroupName rg-app
```

Who / what / where: `--assignee` + `--role` + `--scope`.

PowerShell can take `-ResourceGroupName` instead of a full `-Scope` when the scope is an RG.

**Wrong on purpose (do not pick these):**

```bash
# Contributor cannot grant access
az role assignment create --assignee maria@contoso.com --role Contributor --scope /subscriptions/<subId>

# Entra role name is the wrong plane
az role assignment create --assignee maria@contoso.com --role "User Administrator" --scope /subscriptions/<subId>

# Inherited assignment is not deleted at the child
az role assignment delete --ids <id-that-lists-scope-as-a-management-group>
```

See list of inherited assignments:

```bash
az role assignment list --scope /subscriptions/<subId> --include-inherited
```

## Policy vs RBAC (do not mix the cmdlets)

| Job | Command family |
| --- | --- |
| Stamp a tag / deny a SKU | `az policy assignment create` |
| Let a person restart a VM | `az role assignment create` |
