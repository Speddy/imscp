#!/usr/bin/perl

# i-MSCP - internet Multi Server Control Panel
# Copyright (C) 2010-2013 by internet Multi Server Control Panel
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# @category		i-MSCP
# @copyright	2010-2013 by i-MSCP | http://i-mscp.net
# @author		Daniel Andreca <sci2tech@gmail.com>
# @author		Laurent Declercq <l.declercq@nuxwin.com>
# @link			http://i-mscp.net i-MSCP Home Site
# @license		http://www.gnu.org/licenses/gpl-2.0.html GPL v2

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/..";
use lib "$FindBin::Bin/../PerlLib";
use lib "$FindBin::Bin/../PerlVendor";

use iMSCP::Debug;
use iMSCP::Boot;
use iMSCP::Rights;
use iMSCP::Servers;
use iMSCP::Addons;

# Turn off localisation features to force any command output to be in english
$ENV{'LC_MESSAGES'} = 'C';

# Mode in which the script is triggered
# For now, this variable is only used by i-MSCP installer/setup scripts
$main::execmode = shift || '';

umask(027);

newDebug('imscp-set-engine-permissions.log');

silent(1);

sub startUp
{
	iMSCP::Boot->getInstance()->boot({ 'nolock' => 'yes', 'nodatabase' => 'yes', 'nokeys' => 'yes' });

	my $rs = 0;

	unless($main::execmode eq 'setup') {
		require iMSCP::HooksManager;
		$rs = iMSCP::HooksManager->getInstance()->register(
			'beforeExit', sub { shift; my $clearScreen = shift; $$clearScreen = 0; 0; }
		)
	}

	$rs;
}

sub process
{
	my $rootUName = $main::imscpConfig{'ROOT_USER'};
	my $rootGName = $main::imscpConfig{'ROOT_GROUP'};
	my $masterGName = $main::imscpConfig{'MASTER_GROUP'};
	my $confDir = $main::imscpConfig{'CONF_DIR'};
	my $rootDir = $main::imscpConfig{'ROOT_DIR'};
	my $logDir = $main::imscpConfig{'LOG_DIR'};

	my ($instance, $file, $class);
	my @servers = iMSCP::Servers->getInstance()->get();
	my @addons = iMSCP::Addons->getInstance()->get();
	my $totalItems = @servers + @addons + 1;
	my $counter = 1;

	# Set base permissions - begin
	debug('Setting backend base permissions');
	print "Setting backend base permissions\t$totalItems\t$counter\n" if $main::execmode eq 'setup';

	# eg. /etc/imscp/*
	my $rs = setRights(
		$confDir,
		{ 'user' => $rootUName, 'group' => $rootGName, 'dirmode' => '0750', 'filemode' => '0640', 'recursive' => 1 }
	);
	return $rs if $rs;

	# eg. /etc/imscp
	$rs = setRights($confDir, { 'user' => $rootUName, 'group' => $masterGName } );
    return $rs if $rs;

	# eg. /etc/imscp/imscp*
	$rs = setRights("$confDir/imscp*", { 'user' => $rootUName, 'group' => $masterGName, 'mode' => '0640'} );
	return $rs if $rs;

	# eg. /var/www/imscp/engine
	$rs = setRights(
		"$rootDir/engine", { 'user' => $rootUName, 'group' => $masterGName, 'mode' => '0750', 'recursive' => 1 }
	);
	return $rs if $rs;

	# eg. /var/log/imscp
	$rs = setRights($logDir, { 'user' => $rootUName, 'group' => $masterGName, 'mode' => '0750'} );
	return $rs if $rs;

	$counter++;

	# Set base permissions - ending

	# Trigger the setEnginePermissions() method on all i-MSCP server packages implementing it

	for(@servers) {
		s/\.pm//;

		$file = "Servers/$_.pm";
		$class = "Servers::$_";

		require $file;
		$instance = $class->factory();

		if($instance->can('setEnginePermissions')) {
			debug("Setting $_ server backend permissions");
			print "Setting backend permissions for the $_ server\t$totalItems\t$counter\n" if $main::execmode eq 'setup';
			$rs = $instance->setEnginePermissions();
			return $rs if $rs;
		}

		$counter++;
	}

	# Trigger the setEnginePermissions() method on all i-MSCP addon packages implementing it
	for(@addons) {
		s/\.pm//;

		$file = "Addons/$_.pm";
		$class = "Addons::$_";

		require $file;
		$instance = $class->getInstance();

		if($instance->can('setEnginePermissions')) {
			debug("Setting $_ addon backend permissions");
			print "Setting backend permissions for the $_ addon\t$totalItems\t$counter\n" if $main::execmode eq 'setup';
			$rs = $instance->setEnginePermissions();
			return $rs if $rs;
		}

		$counter++;
	}

	0;
}

sub shutDown
{
	unless($main::execmode eq 'setup') {
		my @warnings = getMessageByType('warn');
		my @errors = getMessageByType('error');
		my $rs = 0;

		my $msg = "\nWARNINGS:\n" . join("\n", @warnings) . "\n" if @warnings > 0;
		$msg .= "\nERRORS:\n" . join("\n", @errors) . "\n" if @errors > 0;

		if($msg) {
			require iMSCP::Mail;

			$rs = iMSCP::Mail->new()->errmsg($msg);
			return $rs if $rs;
		}
	}
}

my $rs = startUp();
$rs ||= process();

shutDown();

exit $rs;
