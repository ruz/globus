# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
use inc::Module::Install;

name 'Globus';
all_from 'lib/Globus.pm';

requires 'Catalyst::Runtime' => '5.7015';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::StackTrace';
requires 'Catalyst::Plugin::Unicode';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::View::TT';
requires 'DBIx::Class';
requires 'DBD::SQLite';
requires 'Catalyst::Model::DBIC::Schema';
requires 'SQL::Translator';
requires 'parent';
requires 'ex::lib';
requires 'Class::Date';

# converts unicode into readable ASCII
requires 'Text::Unidecode';

requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
