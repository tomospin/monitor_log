# Goal: Monitor log messages. If it meet the condition, send an email. (NOT SUCCEED YET)
# What I've done:   Read messages_sample.txt
# 				  	Extract IP and Datetime if the message contains 'Failed password for invalid user root from'
#					Check whether this IP is already sent or not by reading sent_ip.txt file
#					Count the number of occurences (if = 5 and within 10 minutes then print 'outlaw IP at Datetime' and append this IP to sent_ip.txt file) 
# My current output: 
# outlaw 125.133.120.52 at Jan 30 04:38:13
# outlaw 213.168.31.174 at Jan 30 10:04:06
# outlaw 66.212.21.223 at Jan 30 11:44:14
# outlaw 222.186.29.69 at Jan 30 13:36:00
# outlaw 219.232.244.45 at Jan 30 14:31:41
# outlaw 75.112.151.18 at Jan 30 15:54:59
# outlaw 60.8.63.104 at Jan 30 16:12:38
# outlaw 178.18.17.106 at Jan 30 19:25:59
# outlaw 221.128.105.94 at Jan 30 19:33:25
# outlaw 66.154.45.220 at Jan 31 14:37:36

# Written by Sirapat Na Ranong 57070503438
# 29 April 2018 #

use strict;
use warnings;


my $file = '/var/logs/messages_sample.txt';

open(DATA, $file) or die "ERROR while opening $file\n";
my @lines = <DATA>;
close(DATA);

my $count = 1;
my $prev_ip = '';
my $sent = 0;

my $tmp_hour;
my $tmp_minute;
my $tmp_second;

foreach my $line (@lines) {

	my ($month, $day, $hour, $minute, $second, $message, $ip) = $line =~ m/([A-Z][a-z]{2}) ([0-9]{1,2}) ([0-9]{2}):([0-9]{2}):([0-9]{2}).*(Failed password for invalid user root from) ([0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3})/;

	if(defined $ip) {
		# Open sent_ip.txt to check whether this IP is already sent or not
		open(DATA, './sent_ip.txt') or die "Could not open sent_ip.txt\n";
		my @sent_ips = <DATA>;
		close(DATA);

		foreach my $sent_ip (@sent_ips) {
			$sent_ip =~ s/\n//;
			if($ip eq $sent_ip) {
				$sent = 1;
				last;
			} else {
				$sent = 0;
			}
		}

		if($ip eq $prev_ip && $sent != 1) {
			if($count == 1) {
				($tmp_hour, $tmp_minute, $tmp_second) = ($hour, $minute, $second);
			}
			# Count for dupicate IP. If count reach 5 then send email
			$count = $count + 1;
			# If count reaches 5 and it's within 10 minutes then send email
			if ($count == 5) {
				$count = 1;
				if ((60*60*$hour + 60*$minute + $second) - (60*60*$tmp_hour + 60*$tmp_minute + $tmp_second) < 600) {
					# It's supposed to send an email here, but I just print it first.
					print("outlaw $ip at $month $day $hour:$minute:$second\n");
					# Append IP that is sent to a file name sent_ip.txt
					open(DATA, '>>' , './sent_ip.txt') or die "Could not open sent_ip.txt\n";
					print DATA "$ip\n";
					close(DATA);
				}
			}
		}
		$prev_ip = $ip;
	}
}