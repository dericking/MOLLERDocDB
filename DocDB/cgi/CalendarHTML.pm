#
#        Name: CalendarHTML.pm
# Description: Functions to print out various types of calendar (monthly/yearly/daily)
#              and the events on that day (or an indication that there are events)
#
#    Revision: $Revision$
#    Modified: $Author$ on $Date$
#
#      Author: Eric Vaandering (ewv@fnal.gov)

# Copyright 2001-2013 Eric Vaandering, Lynn Garren, Adam Bryant

#    This file is part of DocDB.

#    DocDB is free software; you can redistribute it and/or modify
#    it under the terms of version 2 of the GNU General Public License
#    as published by the Free Software Foundation.

#    DocDB is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with DocDB; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

sub CalendarLink (%) {
  my %Params = @_;

  my $Month    = $Params{-month}    || 0;
  my $Year     = $Params{-year}     || 0;
  my $Day      = $Params{-day}      || 0;
  my $SQL      = $Params{-SQL}      || "";
  my $Text     = $Params{-text}     || "Calendar";
  my $Class    = $Params{-class}    || "";

  my $Link = "<a ";
  if ($Class) {
    $Link .= "class=\"w3-text-docdb-color\" ";
  } else {
    $Link .= "class=\"w3-text-docdb-color\" ";
  }
  $Link .= "href=\"".$ShowCalendar;

  if ($SQL) {
    ($Year,$Month,$Day) = split /-/,$SQL;
    push @DebugStack,"Y $Year M $Month D $Day T $Text";
  }

  if ($Day && $Month && $Year) {
    $Link .= "?year=$Year&amp;month=$Month&amp;day=$Day\">";
  } elsif ($Month && $Year) {
    $Link .= "?year=$Year&amp;month=$Month\">";
  } elsif ($Year) {
    $Link .= "?year=$Year\">";
  }
  $Link .= $Text."</a>";
}

sub PrintCalendar {
  use DateTime;
  require "Sorts.pm";
  require "MeetingSecurityUtilities.pm";

  my %Params = @_;

  my $Month = $Params{-month};
  my $Year  = $Params{-year};
  my $Type  = $Params{-type} || "month";

  my $DaysInMonth = DateTime -> last_day_of_month(year => $Year, month => $Month) -> day();
  my $FirstDay    = DateTime -> new(year => $Year, month => $Month, day => 1);
  my $MonthName   = $FirstDay -> month_name();
  my $Today       = DateTime ->today(time_zone => 'local');

  if ($Type eq "month") {
    print "<div class=\"w3-container w3-margin-bottom\">\n";
    print "<div id=\"CalNavWrap\" class=\"w3-panel\">\n";
    print "<div id=\"CalendarNavigator\" class=\"w3-cell-row w3-center w3-margin-bottom w3-paper w3-round-large w3-border w3-border-light-gray w3-padding\">\n";
    my $PrevMonth = $FirstDay -> clone();
       $PrevMonth -> add(months => -1);
    my $PrevMNum  = $PrevMonth -> month();
    my $PrevName  = $PrevMonth -> month_name();
    my $PrevYear  = $PrevMonth -> year();
    my $NextMonth = $FirstDay -> clone();
       $NextMonth -> add(months => 1);
    my $NextMNum  = $NextMonth -> month();
    my $NextName  = $NextMonth -> month_name();
    my $NextYear  = $NextMonth -> year();

    my $YearLink = CalendarLink(-year => $Year, -text => $Year);
    my $CurrLink = "$MonthName $YearLink";
    print "<div class=\"w3-cell w3-cell-middle\">\n";
    print "<i class=\"fa-solid fa-chevron-left w3-text-docdb-color\"></i>&nbsp;";
    print "<a href=\"".$ShowCalendar."?year=$PrevYear&amp;month=$PrevMNum\" class=\"w3-large w3-text-docdb-color\"><span class=\"\">$PrevName $PrevYear</span></a>\n";
    print "</div><!-- Closing div w3-cell -->\n";
    print "<div class=\"w3-cell w3-cell-middle\" style=\"padding-left:2em; padding-right:2em;\">\n";
    print "<span class=\"w3-large\">$CurrLink</span>\n";
    print "</div><!-- Closing div w3-cell -->\n";
    print "<div class=\"w3-cell w3-cell-middle\">\n";
    print "<a href=\"".$ShowCalendar."?year=$NextYear&amp;month=$NextMNum\" class=\"w3-large w3-text-docdb-color\"><span class=\"\">$NextName $NextYear</span></a>&nbsp;";
    print "<i class=\"fa-solid fa-chevron-right w3-text-docdb-color\"></i>\n";
    print "</div><!-- Closing div w3-cell -->\n";
    print "</div><!-- Closing div id CalendarNavigator -->\n";
    print "</div><!-- Closing div id CalNavWrap -->\n";
    print "<div id=\"CalTabWrap\" class=\"w3-card w3-border w3-border-gray w3-margin-left w3-margin-right\">\n";
  }

  print "<table class=\"w3-table w3-bordered\" id=\"CalendarTable\">\n";
  if ($Type eq "month") {
    print "<colgroup>\n";
    print "<col span=\"7\" style=\"width:14.2857%;\">\n";
    print "</colgroup>\n";
  } elsif ($Type eq "year") {
    print "<colgroup>\n";
    print "<col span=\"7\" style=\"width:14.2857%;\">\n";
    print "</colgroup>\n";
  }

  if ($Type eq "year") {
    my $MonthLink = CalendarLink(-year => $Year, -month => $Month, -text => $MonthName);
    print "<tr><th colspan=\"7\" class=\"w3-center w3-paper\">$MonthLink</th></tr>\n";
  }
  
  print "<tr>\n";
  foreach my $DayName ("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday") {
    if ($Type eq "year") {
      print "<th class=\"w3-center w3-paper\">",substr($DayName,0,1),"</th>\n";
    } else {
      print "<th class=\"w3-center w3-docdb-color\">$DayName</th>\n";
    }
  }
  print "</tr>\n";

  my $RowOpen;

# Add blank cells for days in previous month

  my $DOW = $FirstDay -> day_of_week() + 1; if ($DOW ==8) {$DOW = 1;}
  if ($DOW > 1) {
    my $NSkip = $DOW - 1;
    print "<tr><td colspan=\"$NSkip\"></td>\n";
    $RowOpen = $TRUE;
  }
  my $DaysLeft;

  for (my $Day = 1; $Day <= $DaysInMonth; ++$Day) {
    my $DateTime = DateTime -> new(year => $Year, month => $Month, day => $Day);
    my $SQLDate = $DateTime -> ymd();
    my $DOW = $DateTime -> day_of_week() + 1; # Convert from Monday week start
    if ($DOW ==8) {$DOW = 1;}
       $DaysLeft = 7 - $DOW;
    my $DayName = $DateTime -> day_name();

# Start a new row on Sundays

    if ($DOW == 1) {
      if ($RowOpen) {
        print "</tr>\n";
        $RowOpen = $FALSE;
      }
      print "<tr>\n";
      $RowOpen = $TRUE;
    }

    my $CellClass = "";
    if ($DateTime == $Today) {
      $CellClass = "CalendarToday";
    } elsif ($DOW == 1 || $DOW == 7) {  # Sunday or Saturday
      $CellClass = "w3-light-gray";
    }
    
    # Format IDs: CalCellDay{year}{month}{day}, etc.
    my $CellID = sprintf("%04d%02d%02d", $Year, $Month, $Day);
    
    print "<td class=\"CalendarCell w3-padding-small $CellClass\" style=\"vertical-align: top;\">\n";
    
    if ($Type eq "year") {
      my @EventIDs   = GetEventsByDate({-on => $SQLDate});
      my @SessionIDs = FetchSessionsByDate($SQLDate);
      if (@EventIDs || @SessionIDs) {
        my $DayLink = "<a class=\"w3-text-docdb-color\" href=\"".$ShowCalendar."?year=$Year&amp;month=$Month&amp;day=$Day\">".
                      "<span class=\"u-fw700\">".$DateTime -> day()."</span></a>";
        print "$DayLink\n";
      } else {
        print "<span class=\"u-fw700\">".$Day."</span>\n";
      }
    }
    
    if ($Type eq "month") {
      print "<div id=\"CalCellWrap$CellID\" style=\"min-height:10em; width:100%;\">\n";
      
      print "<div id=\"CalCellHead$CellID\" class=\"w3-bar\">\n";
      print "<a id=\"CalCellDay$CellID\" class=\"w3-bar-item w3-text-docdb-color w3-medium\" style=\"padding:0;\" href=\"".$ShowCalendar."?year=$Year&amp;month=$Month&amp;day=$Day\">";
      print "<span class=\"u-fw700\">".$DateTime -> day()."</span></a>\n";
      
      if (CanCreateMeeting()) {
        print "<a id=\"CalCellAdd$CellID\" class=\"w3-bar-item w3-right w3-tag w3-tiny w3-docdb-color w3-round u-pad4\" style=\"margin-top:1px;\" href=\"".$SessionModify."?mode=new&amp;singlesession=1&amp;sessionyear=$Year&amp;sessionmonth=$Month&amp;sessionday=$Day\" title=\"Add event\">";
        print "<i class=\"fa-solid fa-plus\"></i></a>\n";
      }
      print "</div><!-- Closing div id CalCellHead$CellID -->\n";
      
      print "<div id=\"CalCellContent$CellID\" class=\"w3-small\" style=\"margin-top:4px; text-align:left;\">\n";
      PrintDayEvents(-day => $Day, -month => $Month, -year => $Year, -format => "summary");
      print "</div><!-- Closing div id CalCellContent$CellID -->\n";
      
      print "</div><!-- Closing div id CalCellWrap$CellID -->\n";
    }
    print "</td>\n";
  }

  if ($DaysLeft) {
    print "<td colspan=\"$DaysLeft\">&nbsp;</td>\n";
  }

  print "</tr></table>\n";
  if ($Type eq "month") {
    print "</div><!-- Closing div w3-card -->\n";
    print "</div><!-- Closing div w3-container -->\n";
  }
}

sub PrintDayEvents (%) {
  use DateTime;
  require "Sorts.pm";
  require "MeetingSQL.pm";
  require "MeetingSecurityUtilities.pm";
  require "Utilities.pm";
  require "EventUtilities.pm";

  my %Params = @_;

  my $Month    = $Params{-month};
  my $Year     = $Params{-year};
  my $Day      = $Params{-day};
  my $Format   = $Params{-format}   || "full"; # full || summary || multiday
  my $RowClass = $Params{-rowclass} || "Normal";

  my $DateTime = DateTime -> new(year => $Year, month => $Month, day => $Day);
  my $SQLDate  = $DateTime -> ymd();

  my @EventIDs = sort numerically GetEventsByDate({-on => $SQLDate});
  if ($Format eq "full") {
    print "<div class=\"w3-container w3-margin-top w3-margin-bottom\">\n";
    print "<div class=\"w3-container w3-margin-top\">\n";
    print "<div id=\"EventsDetails\" class=\"w3-card w3-border w3-border-gray\">\n";
    print "<table class=\"w3-table w3-bordered w3-striped\">\n";
  }
  my $DayPrinted = $FALSE;
  my $Count      = 0;

### Separate into ones with and without sessions, save sessions for this day

  my @AllDayEventIDs = ();
  my @AllSessionIDs  = ();
  my $EventID;
  foreach $EventID (@EventIDs) {
    unless (CanAccessMeeting($EventID)) {next;} # Ignore meetings they can't see
    my @SessionIDs = sort &FetchSessionsByConferenceID($EventID);
    if (@SessionIDs) {
      foreach my $SessionID (@SessionIDs) {
        my ($Sec,$Min,$Hour,$SessDay,$SessMonth,$SessYear) = &SQLDateTime($Sessions{$SessionID}{StartTime});
        if ($SessYear == $Year && $SessMonth == $Month && $SessDay == $Day) {
          push @AllSessionIDs,$SessionID;
        }
      }
    } else {
      push @AllDayEventIDs,$EventID;
    }
  }

  my @DateSessionIDs = FetchSessionsByDate($SQLDate);
  push @AllSessionIDs,@DateSessionIDs;
  @AllSessionIDs = Unique(@AllSessionIDs);

### Print Header if we are going to print something

  if ((@AllDayEventIDs || @AllSessionIDs) && $Format eq "full") {
    print "<tr>\n";
    print "<th>Time</th>\n";
    print "<th>Event</th>\n";
    print "<th>Location</th>\n";
    print "<th>&nbsp;</th>\n";
    print "</tr>\n";
  } elsif ($Format eq "full") {
    print "<tr><td>No events for this day</td></tr>\n";
  }

### Loop over all day/no time events

  foreach $EventID (@AllDayEventIDs) {
    unless (CanAccessMeeting($EventID)) {next;} # Ignore meetings they can't see
    my $EventLink = &EventLink(-eventid => $EventID, -format => "full");
    if ($EventLink) {
      ++$Count;
      if ($Format eq "full" || $Format eq "multiday" ) {
        print "<tr>\n";
        if ($Format eq "multiday" && !$DayPrinted) {
          $DayPrinted = $TRUE;
          print "<th class=\"w3-left-align\">$Day ",@AbrvMonths[$Month-1]," $Year</th>\n";
        } elsif ($Format eq "multiday") {
          print "<td>&nbsp;</td>\n";
        }
        print "<td>All day/no time</td>\n";
        print "<td>$EventLink</td>\n";
        print "<td>$Conferences{$EventID}{Location}</td>\n";
        print "<td>$Conferences{$EventID}{URL}</td>\n";
        print "</tr>\n";
      } elsif ($Format eq "summary") {
        print "<div class=\"w3-small\" style=\"margin-top:2px;\">$EventLink</div>\n";
      }
    }
  }

### Loop over sessions by time

  @AllSessionIDs = sort SessionsByDateTime @AllSessionIDs;
  foreach my $SessionID (@AllSessionIDs) {
    unless (CanAccessMeeting($Sessions{$SessionID}{ConferenceID})) {next;} # Ignore meetings they can't see
    my $StartTime = &EuroTimeHM($Sessions{$SessionID}{StartTime});
    my $EndTime   = &TruncateSeconds(&SessionEndTime($SessionID));
    if ($EndTime eq $StartTime) {
      $EndTime = "";
    }
    if ($Format eq "full" || $Format eq "multiday" ) {
      ++$Count;
      my $SessionLink = &SessionLink(-sessionid => $SessionID, -format => "full");
      print "<tr>\n";
      if ($Format eq "multiday" && !$DayPrinted) {
        $DayPrinted = $TRUE;
        print "<th class=\"w3-left-align\">$Day ",@AbrvMonths[$Month-1]," $Year</th>\n";
      } elsif ($Format eq "multiday") {
        print "<td>&nbsp;</td>\n";
      }
      print "<td>$StartTime &ndash; $EndTime</td>\n";
      print "<td>$SessionLink</td>\n";
      print "<td>$Sessions{$SessionID}{Location}</td>\n";
      print "<td>$Conferences{$EventID}{URL}</td>\n";
      print "</tr>\n";
    } elsif ($Format eq "summary") {
      my $SessionLink = &SessionLink(-sessionid => $SessionID);
      print "<div class=\"w3-small\" style=\"margin-top:2px;\">$StartTime $SessionLink</div>\n";
    }
  }
  if ($Format eq "full") {
    print "</table>\n";
    print "</div><!-- Closing div id EventsDetails -->\n";
    print "</div><!-- Closing div w3-container -->\n";
    print "</div><!-- Closing div w3-container -->\n";
  }
  return $Count;
}

1;
