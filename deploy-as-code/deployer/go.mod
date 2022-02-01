module deployer

go 1.13

require (
	github.com/TechMindsDev/DevOps/tree/master/deploy-as-code/deployer/pkg/cmd/deployer v1.0.0
	github.com/manifoldco/promptui v0.8.0
	github.com/mitchellh/go-homedir v1.1.0
	github.com/spf13/cobra v0.0.5
	github.com/spf13/viper v1.6.1
	gopkg.in/yaml.v2 v2.2.4

)

replace github.com/TechMindsDev/DevOps/tree/master/deploy-as-code/deployer/pkg/cmd/deployer => ../deployer
