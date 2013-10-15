NAME

Nagios::AutoRegister - A remote API to register and delete hosts/services in Nagios/Icinga

SYNOPSIS

Register the host mta1 and put it in the MTA and hardware hostgroups:
>     nagios-register --hostname mta1 --hostgroup MTA --hostgroup hardware

Register the NRPE service check check_mx:
>     nagios-register --hostname mta1 --servicename check_mx --check_command 'check_nrpe!check_mx'

Register a passive service check for builds:
>     nagios-register --hostname hudson1 --servicename builds --passive --silent

Delete the www1 host from Nagios:
>     nagios-register --deletehost www1

DESCRIPTION

Nagios Auto Register (NAR) allows scripting of registering, configuring and
deleting hosts from Nagios.  In environments where hosts and services are
in flux adding nagios-register commands to deployment tools keeps everything
up to date.

AUTHOR

David Sparks

COPYRIGHT AND LICENSE

Copyright (C) 2013 by David Sparks

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.4 or,
at your option, any later version of Perl 5 you may have available.
