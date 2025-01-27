terraform {
  cloud {
    organization = "SHProptech"

    workspaces {
      name = "azure"
    }
  }
}
