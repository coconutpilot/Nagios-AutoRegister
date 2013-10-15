package Nagios::AutoRegister::Cmd;

use 5.012004;
use strict;
use warnings;

use Data::Dump 'pp';

use JSON::XS;

use base 'Exporter';
our @EXPORT_OK = qw(%dt);

# XXX: move to config or cmdline
my $ARD = '/etc/icinga/autoregister.d';

our %dt = (
    newhost                 => \&newhost,
    rmhost                  => \&rmhost,
    newservice              => \&newservice,
);

sub newhost {
    my $arg = shift;

    my $hostname = $arg->{hostname};
    my $hostgroup = $arg->{hostgroup} ?
        "    hostgroups     $arg->{hostgroup}" : '';

    open my $f, '>', "$ARD/$hostname.cfg" or die $!;
    print $f <<YOHOHO;
define host {
    use            generic-host
    host_name      $hostname
$hostgroup  
    icon_image     icon-gentoo.png
    check_command  check-host-alive
}

YOHOHO
    close $f or die $!;
    
    return;
}

sub rmhost {
    my $arg = shift;

    my $fn = "$ARD/$arg->{hostname}.cfg";
    return unless -f $fn;
    unlink $fn or die $!;

    return;
}

sub newservice {
    my $arg = shift;

    my $fn = "$ARD/$arg->{hostname}.cfg";
    newhost($arg) unless -f $fn;

    return "Not enough args"
        unless $arg->{hostname}
            and $arg->{servicename}
            and ($arg->{check_command} or $arg->{passive});

    $arg->{check_command} ||= 'check_dummy'; # passive still need a check_command

    my $extra = '';
    $extra = <<EOT if $arg->{passive};
    active_checks_enabled   0
    passive_checks_enabled  1
    max_check_attempts      1
EOT

    $extra .= "    notifications_enabled   0\n"
        if $arg->{silent};

    open my $f, '>>', $fn or die $!;
    print $f <<YOHOHO;
define service {
    use                  generic-service

    host_name            $arg->{hostname}
    service_description  $arg->{servicename}
    check_command        $arg->{check_command}
$extra
}

YOHOHO
    close $f or die $!;
    
    return;
}

1;
