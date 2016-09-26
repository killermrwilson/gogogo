#!/usr/bin/perl
use strict;
use warnings;

# Required to load custom libraries before compile
use Cwd qw(abs_path);
my $currentFile;
my $mainDirectory;
BEGIN {
	$currentFile = abs_path($0);
	if ($currentFile =~ m/^(\S+)\/go\.pl/){
	    $mainDirectory = $1;
	};
}
use lib "$mainDirectory/lib";

use Go::Menu;
use Go::File;
use Go::Term;
use Go::Device;
use Go::Update;
use Go::Config;
my %config = Go::Config::getConfig();

# check if the config directories exist, create them if they don't
Go::File::ensureDataDirectoriesExist();

if (! Go::File::checkForPrivateKey()) {
	Go::Menu::printCertificateWizard();
	Go::Menu::getUpdatePreferences();
	%config = Go::Config::getConfig();
}

my $numberOfSearchTerms = scalar @ARGV;
my @initiallyMatchedDevices = Go::File::getDevices(\@ARGV);
my $numberOfMatchedDevices = scalar @initiallyMatchedDevices;

# just type 'go'
if ($numberOfSearchTerms == 0) {
	if ($config{'checkForUpdates'} eq "yes"){
		print `clear`;
		printWithColor("Checking for updates...\n", "yellow");
		Go::Update::checkForUpdates();
	}
	Go::Menu::printMainMenu();

# search terms match *ONE* device
} elsif ($numberOfMatchedDevices == 1) {
	my %device = Go::Device::getDeviceInfo($initiallyMatchedDevices[0]);
	Go::Device::connectToDevice(\%device);

# search terms match *MULTIPLE* devices
} elsif ($numberOfMatchedDevices > 1) {
	Go::Menu::printDeviceSelectionMenu(\@initiallyMatchedDevices);
	my $deviceSelection = Go::Menu::getSelectionInput() - 1;
	my %device = Go::Device::getDeviceInfo($initiallyMatchedDevices[$deviceSelection]);
	Go::Device::connectToDevice(\%device);

# search terms match *ZERO* devices
} elsif ($numberOfMatchedDevices == 0) {
	error("No match. Use 'go' to add devices.\n");
} 

exit;
