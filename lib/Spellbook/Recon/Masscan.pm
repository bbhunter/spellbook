package Spellbook::Recon::Masscan {
    use strict;
    use warnings;
    use Masscan::Scanner;
    use List::MoreUtils qw(uniq);
    use Spellbook::Recon::Get_IP;
    use Spellbook::Helper::CDN_Checker;
    
    sub new {
        my ($self, $parameters) = @_;
        my ($help, @target, @result);
        
        my @arguments = qw(--banners);
        my @ports     = "1-65535";

        Getopt::Long::GetOptionsFromArray (
            $parameters,
            "h|help"      => \$help,
            "t|target=s"  => \@target,
            "p|port=s"    => \@ports,
            "a|arguments" => \@arguments
        );

        if (@target) {
            my $CDN_Checker = Spellbook::Helper::CDN_Checker -> new (["--target" => $target[0]]);

            if (!$CDN_Checker) {
                my @ip = Spellbook::Recon::Get_IP -> new(["--target" => $target[0]]);

                my $masscan = Masscan::Scanner -> new(
                    hosts     => \@ip,
                    ports     => \@ports,
                    arguments => \@arguments
                );

                my $scan = $masscan -> scan();

                if ($scan) {
                    my $result = $masscan -> scan_results();

                    foreach my $value (@{$result -> {"scan_results"}}) {                    
                        push @result, $target[0] . ":" . $value -> {"ports"} -> [0] -> {"port"};
                    }
                    
                    return uniq @result;
                }
            }
        } 

        if ($help) {
            return "
                \rRecon::Masscan
                \r=====================
                \r-h, --help       See this menu
                \r-t, --target     Set an Domain/IP to make a port scanning using masscan
                \r-p, --ports      Define ports to scan
                \r-a, --arguments  Parameters to masscanner\n\n";
        }

        return 0;
    }
}

1;