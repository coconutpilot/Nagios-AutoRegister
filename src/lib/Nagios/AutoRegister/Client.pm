package Nagios::AutoRegister::Client;

use 5.012004;
use strict;
use warnings;

use Data::Dump 'pp';

use ZMQ::Constants qw(ZMQ_REQ ZMQ_REP ZMQ_POLLIN);
use ZMQ::LibZMQ2;

use JSON::XS;

sub new {
    my ($class) = @_;

    my $o = {};
    $o->{ctx} = zmq_init
        or die $!;
    $o->{socket} = zmq_socket($o->{ctx}, ZMQ_REQ)
        or die $!;
    zmq_connect($o->{socket}, 'tcp://monitor1.labs.sophos:5668')
        and die $!;

    return bless $o, $class;
}

sub newhost {
    my $self = shift;
    my $arg = shift;

    my $send = encode_json({method => 'newhost', params => $arg, id => undef});
            
    zmq_send($self->{socket}, $send)
        and die $!;

    my $resp = zmq_recv($self->{socket})
        or die $!;

    my $data = decode_json(zmq_msg_data($resp));

    return $data;
}

sub newservice {
    my $self = shift;
    my $arg = shift;
   
    my $send = encode_json({method => 'newservice', params => $arg, id => undef});
            
    zmq_send($self->{socket}, $send)
        and die $!;

    my $resp = zmq_recv($self->{socket})
        or die $!;

    my $data = decode_json(zmq_msg_data($resp));

    return $data;
}

sub rmhost {
    my $self = shift;
    my $arg = shift;
   
    my $send = encode_json({method => 'rmhost', params => $arg, id => undef});
            
    zmq_send($self->{socket}, $send)
        and die $!;

    my $resp = zmq_recv($self->{socket})
        or die $!;

    my $data = decode_json(zmq_msg_data($resp));

    return $data;
}

1;
