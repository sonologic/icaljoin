#!/usr/bin/perl -w
#
#    Copyright (c) 2011, Koen Martens <gmc@hackerspaces.org>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

use strict;

use iCal::Parser;

use Data::ICal;
use Data::ICal::Entry::Event;
use DateTime::Format::ICal;

my @files = glob("cache/*.ics");

my $parser=iCal::Parser->new();

my $hash=$parser->parse(@files);

my $cal=Data::ICal->new();

$cal->add_property('PRODID'=>'Hxx calendar aggregator v1.0');
$cal->add_property('X-WR-CALNAME'=>'Dutch hackerspaces');
$cal->add_property('METHOD'=>'PUBLISH');

for my $year (sort {$a < $b} keys %{$hash->{events}}) {
  for my $month (sort {$a < $b} keys %{$hash->{events}->{$year}}) {
    for my $day (sort {$a < $b} keys %{$hash->{events}->{$year}->{$month}}) {
      for my $event (keys %{$hash->{events}->{$year}->{$month}->{$day}}) {
        my $calevent=Data::ICal::Entry::Event->new();
print "hop\n";
        for my $tag (keys %{$hash->{events}->{$year}->{$month}->{$day}->{$event}}) {
 	  unless( ($tag eq 'idref') or ($tag eq 'allday') or ($tag eq 'hours') or ($tag eq 'ATTENDEE') ) {
	    if(UNIVERSAL::isa($hash->{events}->{$year}->{$month}->{$day}->{$event}->{$tag},'DateTime')) {
              #$calevent->add_property($tag => $hash->{events}->{$year}->{$month}->{$day}->{$event}->{$tag});
              $calevent->add_property($tag => DateTime::Format::ICal->format_datetime($hash->{events}->{$year}->{$month}->{$day}->{$event}->{$tag}));
	    } else {
              $calevent->add_property($tag => $hash->{events}->{$year}->{$month}->{$day}->{$event}->{$tag});
	    }
	  }
	}
	$cal->add_entry($calevent);
      }
    }
  }
}

print $cal->as_string;
