#        Name: $RCSfile$
# Description: Snippets of HTML producing various things for SearchForm.
#              Some of these can probably be moved to more generic functions.
#              Functions in this file:
#
#        TitleSearchBox
#          A box to type words/strings and a mode selecter for text searches
#          on DocumentTitle
#
#        AbstractSearchBox
#          A box to type words/strings and a mode selecter for text searches
#          on Abstract
#
#        KeywordSearchBox
#          A box to type words/strings and a mode selecter for text searches
#          on Keywords
#
#        RevisionNoteSearchBox
#          A box to type words/strings and a mode selecter for text searches
#          on Keywords
#
#        PubInfoSearchBox
#          A box to type words/strings and a mode selecter for text searches
#          on PublicationInfo
#
#        DocTypeMulti
#          A select box for searches on document type. Unlike entry buttons,
#          this has to be multi-selectable for ANDS/ORS
#
#        DateRangePullDown
#          Two sets of pulldowns for defining a date range. Blanks are default
#          for tagging no search on date.
#
#        LogicTypeButtons
#          Two buttons allow the user to control whether the inner logic (multiple
#          members of field) and the outer logic (between fields) are done with ANDs
#          or ORs.
#
#        ModeSelect
#          A pulldown to select the display mode for searches

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

require "SearchModes.pm";
require "FormElements.pm";

sub TitleSearchBox { # Box and mode selecter for searches on DocumentTitle
  print "<tr><th class=\"w3-padding\" style=\"vertical-align: middle;\">";
  print FormElementTitle(-helplink => "wordsearch", -helptext => "Titles", -nobreak => $TRUE);
  print "</th>\n";
  print "<td class=\"w3-padding\">\n";
  print $query -> textfield (-name      => 'titlesearch',
                             -size      => 40,
                             -maxlength => 240,
                             -class     => "w3-input w3-border w3-round");
  print "</td>\n";
  print "<td class=\"w3-padding\">\n";
  print $query -> popup_menu (-name    => 'titlesearchmode',
                              -values  => \%SearchModes,
                              -class   => "w3-select w3-border");
  print "</td></tr>\n";
};

sub AbstractSearchBox { # Field and mode selecter for searches on Abstract
  print "<tr><th class=\"w3-padding\" style=\"vertical-align: middle;\">";
  print FormElementTitle(-helplink => "wordsearch", -helptext => "Abstract", -nobreak => $TRUE);
  print "</th>\n";
  print "<td class=\"w3-padding\">\n";
  print $query -> textfield (-name      => 'abstractsearch',
                             -size      => 40,
                             -maxlength => 240,
                             -class     => "w3-input w3-border w3-round");
  print "</td>\n";
  print "<td class=\"w3-padding\">\n";
  print $query -> popup_menu (-name    => 'abstractsearchmode',
                              -values  => \%SearchModes,
                              -class   => "w3-select w3-border");
  print "</td></tr>\n";
};

sub KeywordsSearchBox { # Field and mode selecter for searches on Keywords
  print "<tr><th class=\"w3-padding\" style=\"vertical-align: middle;\">";
  print FormElementTitle(-helplink => "wordsearch", -helptext => "Keywords", -nobreak => $TRUE);
  print "</th>\n";
  print "<td class=\"w3-padding\">\n";
  print $query -> textfield (-name      => 'keywordsearch',
                             -size      => 40,
                             -maxlength => 240,
                             -class     => "w3-input w3-border w3-round");
  print "</td>\n";
  print "<td class=\"w3-padding\">\n";
  print $query -> popup_menu (-name    => 'keywordsearchmode',
                              -values  => \%SearchModes,
                              -class   => "w3-select w3-border");
  print "</td></tr>\n";
};

sub RevisionNoteSearchBox { # Field and mode selecter for searches on Note
  print "<tr><th class=\"w3-padding\" style=\"vertical-align: middle;\">";
  print FormElementTitle(-helplink => "wordsearch", -helptext => "Notes and Changes", -nobreak => $TRUE);
  print "</th>\n";
  print "<td class=\"w3-padding\">\n";
  print $query -> textfield (-name      => 'revisionnotesearch',
                             -size      => 40,
                             -maxlength => 240,
                             -class     => "w3-input w3-border w3-round");
  print "</td>\n";
  print "<td class=\"w3-padding\">\n";
  print $query -> popup_menu (-name    => 'revisionnotesearchmode',
                              -values  => \%SearchModes,
                              -class   => "w3-select w3-border");
  print "</td></tr>\n";
};

sub PubInfoSearchBox { # Field and mode selecter for searches on PublicationInfo
  print "<tr><th class=\"w3-padding\" style=\"vertical-align: middle;\">";
  print FormElementTitle(-helplink => "wordsearch", -helptext => "Publication Info", -nobreak => $TRUE);
  print "</th>\n";
  print "<td class=\"w3-padding\">\n";
  print $query -> textfield (-name      => 'pubinfosearch',
                             -size      => 40,
                             -maxlength => 240,
                             -class     => "w3-input w3-border w3-round");
  print "</td>\n";
  print "<td class=\"w3-padding\">\n";
  print $query -> popup_menu (-name    => 'pubinfosearchmode',
                              -values  => \%SearchModes,
                              -class   => "w3-select w3-border");
  print "</td></tr>\n";
};

sub FileNameSearchBox { # Field and mode selecter for searches on Files
  print "<tr><th class=\"w3-padding\" style=\"vertical-align: middle;\">";
  print FormElementTitle(-helplink => "wordsearch", -helptext => "File names", -nobreak => $TRUE);
  print "</th>\n";
  print "<td class=\"w3-padding\">\n";
  print $query -> textfield (-name      => 'filesearch',
                             -size      => 40,
                             -maxlength => 240,
                             -class     => "w3-input w3-border w3-round");
  print "</td>\n";
  print "<td class=\"w3-padding\">\n";
  print $query -> popup_menu (-name    => 'filesearchmode',
                              -values  => \%SearchModes,
                              -class   => "w3-select w3-border");
  print "</td></tr>\n";
};

sub DescriptionSearchBox { # Field and mode selecter for searches on Files
  print "<tr><th class=\"w3-padding\" style=\"vertical-align: middle;\">";
  print FormElementTitle(-helplink => "wordsearch", -helptext => "File descriptions", -nobreak => $TRUE);
  print "</th>\n";
  print "<td class=\"w3-padding\">\n";
  print $query -> textfield (-name      => 'filedescsearch',
                             -size      => 40,
                             -maxlength => 240,
                             -class     => "w3-input w3-border w3-round");
  print "</td>\n";
  print "<td class=\"w3-padding\">\n";
  print $query -> popup_menu (-name    => 'filedescsearchmode',
                              -values  => \%SearchModes,
                              -class   => "w3-select w3-border");
  print "</td></tr>\n";
};

sub ContentSearchBox { # Field and mode selecter for searches on Files
  print "<tr><th class=\"w3-padding\" style=\"vertical-align: middle;\">";
  print FormElementTitle(-helplink => "contentsearch", -helptext => "File contents", -nobreak => $TRUE);
  print "</th>\n";
  print "<td class=\"w3-padding\">\n";
  print $query -> textfield (-name      => 'filecontsearch',
                             -size      => 40,
                             -maxlength => 240,
                             -class     => "w3-input w3-border w3-round");
  print "</td>\n";
  print "<td class=\"w3-padding\">\n";
  print $query -> popup_menu (-name    => 'filecontsearchmode',
                              -values  => \%SearchModes,
                              -class   => "w3-select w3-border");
  print "</td></tr>\n";
};

sub DocTypeMulti { # Scrolling selectable list for doc type search
  my %DocTypeLabels = ();
  foreach my $DocTypeID (keys %DocumentTypes) {
    $DocTypeLabels{$DocTypeID} = $DocumentTypes{$DocTypeID}{SHORT};
  }
  print FormElementTitle(-helplink => "doctypemulti", -helptext => "Document type");
  print $query -> scrolling_list(-size => 10, -name => "doctypemulti",
                              -values => \%DocTypeLabels, -multiple => 'true');
};

sub DateRangePullDown { # Two sets of pulldowns for defining a date range
  my ($sec,$min,$hour,$day,$mon,$year) = localtime(time);
  $year += 1900;

  my @days = ("--");
  for ($i = 1; $i<=31; ++$i) {
    push @days,$i;
  }

  my @months = ("---","Jan","Feb","Mar","Apr","May","Jun",
                      "Jul","Aug","Sep","Oct","Nov","Dec");

  my @years = ("----");
  for ($i = $FirstYear; $i<=$year; ++$i) { # $FirstYear - current year
    push @years,$i;
  }

  # Start Date section - first cell with label
  print "<td class=\"w3-padding\" style=\"vertical-align: middle;\">\n";
  print "<strong>Start Date:</strong>\n";
  print "</td>\n";
  
  # Start Date section - second cell with dropdowns
  print "<td class=\"w3-padding\" style=\"vertical-align: middle;\">\n";
  print "<div class=\"w3-cell-row w3-margin-top\" style=\"margin-top:4px!important;\">\n";
  print "<div class=\"w3-cell\" style=\"width:80px;\">\n";
  print "<label class=\"w3-small\">Month</label><br/>\n";
  print $query -> popup_menu (-name => 'aftermonth',-values => \@months, -class => "w3-select w3-border w3-round");
  print "</div>\n";
  print "<div class=\"w3-cell\" style=\"width:70px; padding-left:4px;\">\n";
  print "<label class=\"w3-small\">Day</label><br/>\n";
  print $query -> popup_menu (-name => 'afterday',  -values => \@days, -class => "w3-select w3-border w3-round");
  print "</div>\n";
  print "<div class=\"w3-cell\" style=\"width:90px; padding-left:4px;\">\n";
  print "<label class=\"w3-small\">Year</label><br/>\n";
  print $query -> popup_menu (-name => 'afteryear', -values => \@years, -class => "w3-select w3-border w3-round");
  print "</div>\n";
  print "</div><!-- Closing div w3-cell-row -->\n";
  print "</td>\n";

  # End Date section - third cell with label
  print "<td class=\"w3-padding\" style=\"vertical-align: middle;\">\n";
  print "<strong>End Date:</strong>\n";
  print "</td>\n";
  
  # End Date section - fourth cell with dropdowns
  print "<td class=\"w3-padding\" style=\"vertical-align: middle;\">\n";
  print "<div class=\"w3-cell-row w3-margin-top\" style=\"margin-top:4px!important;\">\n";
  print "<div class=\"w3-cell\" style=\"width:80px;\">\n";
  print "<label class=\"w3-small\">Month</label><br/>\n";
  print $query -> popup_menu (-name => 'beforemonth',-values => \@months, -class => "w3-select w3-border w3-round");
  print "</div>\n";
  print "<div class=\"w3-cell\" style=\"width:70px; padding-left:4px;\">\n";
  print "<label class=\"w3-small\">Day</label><br/>\n";
  print $query -> popup_menu (-name => 'beforeday',  -values => \@days, -class => "w3-select w3-border w3-round");
  print "</div>\n";
  print "<div class=\"w3-cell\" style=\"width:90px; padding-left:4px;\">\n";
  print "<label class=\"w3-small\">Year</label><br/>\n";
  print $query -> popup_menu (-name => 'beforeyear', -values => \@years, -class => "w3-select w3-border w3-round");
  print "</div>\n";
  print "</div><!-- Closing div w3-cell-row -->\n";
  print "</td>\n";
}

sub LogicTypeButtons { # Two buttons allow control whether inner and outer
                       # logic are done with ANDs or ORs
  my @Values = ["AND","OR"];

  print "<table class=\"w3-table\">\n";
  print "<tr>\n";
  print "<td class=\"w3-padding w3-right-align\" style=\"vertical-align: middle;\">\n";
  print FormElementTitle(-helplink => "logictype", -helptext => "Between Fields", -nobreak => $TRUE);
  print "</td>\n";
  print "<td class=\"w3-padding w3-left-align\" style=\"vertical-align: middle;\">\n";
  my $outerRadio = $query -> radio_group(-name => "outerlogic",
                              -values => @Values, -default => "AND");
  $outerRadio =~ s/(<\/label>)(<input)/$1&nbsp;&nbsp;$2/g;
  print $outerRadio;
  print "</td>\n";
  print "<td class=\"w3-padding w3-right-align\" style=\"vertical-align: middle;\">\n";
  print FormElementTitle(-helplink => "logictype", -helptext => "Within Fields", -nobreak => $TRUE);
  print "</td>\n";
  print "<td class=\"w3-padding w3-left-align\" style=\"vertical-align: middle;\">\n";
  my $innerRadio = $query -> radio_group(-name => "innerlogic",
                              -values => @Values, -default => "OR");
  $innerRadio =~ s/(<\/label>)(<input)/$1&nbsp;&nbsp;$2/g;
  print $innerRadio;
  print "</td>\n";
  print "</tr>\n";
  print "</table>\n";
}

sub ModeSelect { # Display Mode selecter for searches
  my %Modes = ();
  $Modes{date}    = "Date with document #";
  $Modes{meeting} = "Author with topics and files";
  $Modes{title}   = "Document title";
  print "<table class=\"w3-table\">\n";
  print "<tr>\n";
  print "<td class=\"w3-padding\" style=\"vertical-align: middle;\">\n";
  print FormElementTitle(-helptext => "Sort by", -helplink => "displaymode", -nobreak => $TRUE),"\n";
  print "</td>\n";
  print "<td class=\"w3-padding\" style=\"vertical-align: middle;\">\n";
  print $query -> popup_menu (-name    => 'mode',
                              -values  => \%Modes,
                              -default => 'date',
                              -class   => "w3-select w3-border");
  print "</td>\n";
  print "</tr>\n";
  print "</table>\n";
}

1;
