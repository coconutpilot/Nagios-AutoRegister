use 5.012004;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Nagios::AutoRegister',
    VERSION           => '0.08',
    PREREQ_PM         => {},
    ABSTRACT_FROM     => 'lib/Nagios/AutoRegister/Server.pm',
    AUTHOR            => 'David Sparks <noemail@example.com>',
    EXE_FILES         => ['bin/nagios-register', 'bin/nagios-autoregisterd'],
);

