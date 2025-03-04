package Spellbook::Helper::Scope {
    use strict;
    use warnings;
    use YAML::Tiny; # https://metacpan.org/pod/YAML::Tiny
    use Spellbook::Core::Module;
    use Spellbook::Core::Orchestrator;

    sub new {
        my ($self, $parameters) = @_;
        my ($help, $scope, $information, $entrypoint, $save, @results, @response);

        my $threads = 10;
        
        Getopt::Long::GetOptionsFromArray (
            $parameters,
            "h|help"          => \$help,
            "S|scope=s"       => \$scope,
            "i|information=s" => \$information,
            "e|entrypoint=s"  => \$entrypoint,
            "t|threads=i"     => \$threads,
            "save:s"          => \$save
        );

        if ($scope && $information) {
            my $yamlfile = YAML::Tiny -> read($scope);

            if ($entrypoint) {
                my @response = Spellbook::Core::Orchestrator -> new (
                    [
                        "--entrypoint" => $entrypoint,
                        "--list"        => $yamlfile -> [0] -> {$information},
                        "--threads"     => $threads
                    ]
                );

                push @results, @response;
            }

            else {
                foreach my $info (@{$yamlfile -> [0] -> {$information}}) {
                    push @results, $info;
                }
            }
    
            if ($save) {
                for (keys @results) {
                    $yamlfile -> [0] -> {$save} = [@results];
                    $yamlfile -> write ($scope);              
                }
            }

            return @results;
        }

         if ($help) {
            return "
                \rHelper::Scope
                \r=====================
                \r-h, --help         See this menu
                \r-S, --scope        Define a YML file as a scope
                \r-i, --information  Set an information to extract from your scope
                \r-e, --entrypoint   Send informations to another entrypoint module
                \r--save             Save the output on some attribute\n\n";
        }
        
        return 0;
    }
}

1;