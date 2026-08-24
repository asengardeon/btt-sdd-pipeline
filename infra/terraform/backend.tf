# Estado remoto — nunca use state local em produção.
# Preencha bucket/key/region/dynamodb_table (ou o backend equivalente do seu provedor) antes de
# rodar terraform init. Deixado como comentário porque os valores reais dependem do ambiente e
# não devem ser hardcoded no template.

# terraform {
#   backend "s3" {
#     bucket         = "SUBSTITUA-pelo-bucket-de-state"
#     key            = "projeto-base-ia/terraform.tfstate"
#     region         = "SUBSTITUA-pela-regiao"
#     dynamodb_table = "SUBSTITUA-pela-tabela-de-lock"
#     encrypt        = true
#   }
# }
