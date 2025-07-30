{ config, ... }: {
  imports = [
    ./sops.nix
  ];

  terraform = {
    required_providers = {
      github = {
        source = "integrations/github";
      };
    };
  };

  provider = {
    github = {
      token = config.data.sops_file.secrets "data[\"github.token\"]";
    };
  };

  resource = {
    github_repository.mwr = {
      name = "mwr.el";
      description = "Emacs package to manually resize Emacs windows, with hydra & golden-ratio integration.";
      visibility = "public";
    };
  };
}
