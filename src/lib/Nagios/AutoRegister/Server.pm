package Nagios::AutoRegister::Server;

use 5.012004;
use strict;
use warnings;

use Data::Dump 'pp';
use Net::Domain qw(hostname hostfqdn hostdomain domainname);

use ZMQ::Constants qw(ZMQ_REQ ZMQ_REP ZMQ_POLLIN);
use ZMQ::LibZMQ2;

use JSON::XS;

use Nagios::AutoRegister::Cmd '%dt';

our $VERSION = '0.01';

sub new {
    my ($class) = @_;

    my $o = {};
    $o->{ctx} = zmq_init
        or die $!;
    $o->{socket} = zmq_socket($o->{ctx}, ZMQ_REP)
        or die $!;
    zmq_bind($o->{socket}, 'tcp://0.0.0.0:5668')
        and die $!;

    return bless $o, $class;
}

my $LOOPTIMER=10000000; # not sure of unit, 1 million is approx 2 secs
sub loop {
    my $self = shift;

    while (1) {
        zmq_poll([
            {
                socket => $self->{socket},
                events => ZMQ_POLLIN,
                callback => sub { dispatch($self); }, # note closure to preserve $self
            },
        ], $LOOPTIMER);
        print '.';
        say scalar localtime(time);
        sleep 1;
    }
    die "WTF";
}

sub dispatch {
    my $self = shift;
    my $m = zmq_recv($self->{socket});
    my $data = zmq_msg_data($m);

    my $call;
    eval { $call = decode_json($data); }
        or do {
            zmq_send($self->{socket}, encode_json({error => "FATAL: Decode failed: $@"}));
            return;
        };

#    say pp($call);

    unless (exists $call->{id} and exists $call->{method} and exists $dt{$call->{method}}) {
        zmq_send($self->{socket}, encode_json({error => "FATAL: Invalid request: $data"}));
        return;
    }
    my $result = {id => $call->{id}};

    my $error = $dt{$call->{method}}->($call->{params});

    if ($error) {
        $result->{error} = "FATAL: $error";
    }
    else {
        if (my $error = $self->restart_icinga) {
            $result->{error} = "FATAL: $error";
        }
    }

    $result->{result} = 'Ok' unless $result->{error};
#    say pp($result);
    
    zmq_send($self->{socket}, encode_json($result));
    return;
}

sub restart_icinga {
    my $self = shift;

    # qx() forces a subshell so stdout stderr can be discarded
    qx(/etc/init.d/icinga checkconfig >/dev/null 2>&1);
    return "Icinga config invalid" if $?;

    qx(/etc/init.d/icinga restart >/dev/null 2>&1);
    return "Failed restarting Icinga" if $?;

    return;
}

1;
__END__

=head1 NAME

Nagios::AutoRegister - A remote API to register and delete hosts/services in Nagios/Icinga

=head1 SYNOPSIS

    nagios-register --hostname mta1 --hostgroup MTA --hostgroup hardware
    nagios-register --hostname mta1 --servicename check_mx --check_command 'check_nrpe!check_mx'
    nagios-register --hostname hudson1 --servicename builds --passive --silent

=head1 DESCRIPTION

Nagios Auto Register (NAR) allows scripting of registering, configuring and
deleting hosts from Nagios.  In environments where hosts and services are
in flux adding nagios-register commands to deployment tools keeps everything
up to date.

=head1 AUTHOR

David Sparks

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by David Sparks

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
