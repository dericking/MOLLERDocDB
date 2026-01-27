#        Name: AuthorHTML.pm
# Description: Routines to create HTML elements for authors and institutions
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: Eric Vaandering (ewv@fnal.gov)

# Copyright 2001-2018 Eric Vaandering, Lynn Garren, Adam Bryant

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

require "HTMLUtilities.pm";

sub FirstAuthor ($;$) {
  my ($DocRevID,$ArgRef) = @_;
  my $Institution = exists $ArgRef->{-institution} ? $ArgRef->{-institution} : $FALSE;

  require "AuthorSQL.pm";
  require "AuthorUtilities.pm";
  require "Sorts.pm";

  FetchDocRevisionByID($DocRevID);

  my $FirstID = FirstAuthorID( {-docrevid => $DocRevID} );
  unless ($FirstID) {return "None";}
  my @AuthorRevIDs = GetRevisionAuthors($DocRevID);

  my $AuthorLink = AuthorLink($FirstID);
  if ($#AuthorRevIDs) {$AuthorLink .= " <i>et al.</i>";}
  if ($Institution) {
    FetchInstitution($Authors{$FirstID}{InstitutionID});
    $AuthorLink .= "<br/><em>".
                   SmartHTML({-text=>$Institutions{$Authors{$FirstID}{InstitutionID}}{SHORT}}).
                   "</em>";
  }
  return $AuthorLink;
}

sub AuthorListByAuthorRevID {
  my ($ArgRef) = @_;
  my @AuthorRevIDs = exists $ArgRef->{-authorrevids} ? @{$ArgRef->{-authorrevids}} : ();
  my $Format       = exists $ArgRef->{-format}       ?   $ArgRef->{-format}        : "long";
#  my $ListFormat  = exists $ArgRef->{-listformat}  ?   $ArgRef->{-listformat}  : "dl";
#  my $ListElement = exists $ArgRef->{-listelement} ?   $ArgRef->{-listelement} : "short";
#  my $LinkType    = exists $ArgRef->{-linktype}    ?   $ArgRef->{-linktype}    : "document";
#  my $SortBy      = exists $ArgRef->{-sortby}      ?   $ArgRef->{-sortby}      : "";

  require "AuthorUtilities.pm";
  require "Sorts.pm";

  @AuthorRevIDs = sort AuthorRevIDsByOrder @AuthorRevIDs;
  my @AuthorIDs = AuthorRevIDsToAuthorIDs({ -authorrevids => \@AuthorRevIDs, });

  my $HTML;
  if ($Format eq "long") {
    $HTML = AuthorListByID({ -listformat => "dl", -authorids => \@AuthorIDs });
  } elsif ($Format eq "short") {
    $HTML = AuthorListByID({ -listformat => "br", -authorids => \@AuthorIDs });
  }

  print $HTML;

}

sub AuthorListByID {
  my ($ArgRef) = @_;
  my @AuthorIDs   = exists $ArgRef->{-authorids}   ? @{$ArgRef->{-authorids}}  : ();
  my $ListFormat  = exists $ArgRef->{-listformat}  ?   $ArgRef->{-listformat}  : "dl";
#  my $ListElement = exists $ArgRef->{-listelement} ?   $ArgRef->{-listelement} : "short";
  my $LinkType    = exists $ArgRef->{-linktype}    ?   $ArgRef->{-linktype}    : "document";
  my $SortBy      = exists $ArgRef->{-sortby}      ?   $ArgRef->{-sortby}      : "";

  require "AuthorSQL.pm";
  require "Sorts.pm";

  foreach my $AuthorID (@AuthorIDs) {
    FetchAuthor($AuthorID);
  }

  if ($SortBy eq "name") {
    @AuthorIDs = sort byLastName     @AuthorIDs;
  }

  my ($HTML,$StartHTML,$EndHTML,$StartElement,$EndElement,$StartList,$EndList,$NoneText);

  if ($ListFormat eq "dl") {
    $StartHTML .= '<div id="Authors"><h4>Authors:</h4>';
    $EndHTML    = '</div>';
    $StartList  = '<ul>';
    $EndList    = '</ul>';
    $StartElement = '<li>';
    $EndElement   = '</li>';
    $NoneText     = '<div id="Authors"><h4>Authors:</h4>None';
  } else {  #$ListFormat eq "br"
    $StartHTML  = '<div>';
    $EndHTML    = '</div>';
    $EndElement = '<br/>';
    $NoneText   = 'None<br/>';
  }

  if (@AuthorIDs) {
    $HTML .= $StartHTML;
    $HTML .= $StartList;
    foreach my $AuthorID (@AuthorIDs) {
      $HTML .= $StartElement.AuthorLink($AuthorID,-type => $LinkType).$EndElement;
    }
    $HTML .= $EndList;
  } else {
    $HTML = $NoneText;
  }
  $HTML .= $EndHTML;

  return PrettyHTML($HTML);
}

sub RequesterByID {
  my ($RequesterID) = @_;

  my $AuthorLink   = &AuthorLink($RequesterID);
  print "<div><strong>Submitted by:</strong><span>&nbsp;&nbsp;&nbsp;$AuthorLink</span></div>\n";
}

sub SubmitterByID {
  my ($RequesterID) = @_;

  my $AuthorLink   = &AuthorLink($RequesterID);
  print "<div><strong>Updated by:</strong><span>&nbsp;&nbsp;&nbsp;$AuthorLink</span></div>\n";
}

sub AuthorLink ($;%) {
  require "AuthorSQL.pm";

  my ($AuthorID,%Params) = @_;
  my $Format = $Params{-format} || "full"; # full, formal
  my $Type   = $Params{-type}   || "document"; # document, event
  my $OldDocs = $Params{-olddocs} || "";

  FetchAuthor($AuthorID);
  FetchInstitution($Authors{$AuthorID}{InstitutionID});
  my $InstitutionName = $Institutions{$Authors{$AuthorID}{InstitutionID}}{LONG};
  $InstitutionName = SmartHTML( {-text => $InstitutionName,} );
  unless ($Authors{$AuthorID}{FULLNAME}) {
    return "Unknown";
  }
  my $Script;
  if ($Type eq "event") {
    $Script = $ListEventsBy;
  } else {
    $Script = $ListBy;
  }

  my $Link;
  if ($OldDocs) {
    $Link = "<a href=\"$Script?authorid=$AuthorID&amp;old=1\" title=\"$InstitutionName\" class=\"w3-text-teal\">";
  } else {
    $Link = "<a href=\"$Script?authorid=$AuthorID\" title=\"$InstitutionName\" class=\"w3-text-teal\">";
  }

  if ($Format eq "full") {
    $Link .= SmartHTML( {-text => $Authors{$AuthorID}{FULLNAME}, } );
  } elsif ($Format eq "formal") {
    $Link .= SmartHTML( {-text => $Authors{$AuthorID}{Formal}, } );
  }
  $Link .= "</a>";

  return $Link;
}

sub PrintAuthorInfo {
  require "AuthorSQL.pm";

  my ($AuthorID) = @_;

  &FetchAuthor($AuthorID);
  &FetchInstitution($Authors{$AuthorID}{InstitutionID});
  my $link = &AuthorLink($AuthorID);

  print "$link\n";
  print " of ";
  print SmartHTML( {-text => $Institutions{$Authors{$AuthorID}{InstitutionID}}{LONG}, } );
}

sub AuthorsByInstitution {
  my ($InstID) = @_;
  require "Sorts.pm";

  my @AuthorIDs = sort byLastName keys %Authors;

  print "<td><strong>$Institutions{$InstID}{SHORT}</strong>\n";
  print "<ul>\n";
  foreach my $AuthorID (@AuthorIDs) {
    if ($InstID == $Authors{$AuthorID}{InstitutionID}) {
      my $author_link = &AuthorLink($AuthorID);
      print "<li>$author_link</li>\n";
    }
  }
  print "</ul></td>";
}

sub AuthorsTable {
  require "Sorts.pm";
  require "MeetingSQL.pm";
  require "MeetingHTML.pm";

  my @AuthorIDs     = sort byLastName keys %Authors;
  my $NCols         = 4;
  my $NPerCol       = int (scalar(@AuthorIDs)/$NCols);
  my $UseAnchors    = (scalar(@AuthorIDs) >= 75);
  my $CheckEvent    = $TRUE;

  if (scalar(@AuthorIDs) % $NCols) {++$NPerCol;}

  if ($UseAnchors ) {
    print "<div class=\"w3-center w3-padding w3-margin-bottom\">\n";
    foreach my $Letter (A..Z) {
      print "<a href=\"#$Letter\" class=\"w3-text-teal w3-large\"><strong>$Letter</strong></a>\n";
    }
    print "</div><!-- Closing div w3-center w3-padding w3-margin-bottom -->\n";
  }
  print "<div class=\"w3-container w3-margin\">\n";
  print "<table class=\"w3-table w3-bordered no-row-lines\" style=\"margin-left: auto; margin-right: auto;\">\n";
  print "<tr>\n";

  my $NThisCol       = 0;
  my $PreviousLetter = "";
  my $FirstPass       = 1; # First sub-list of column
  my $StartNewColumn  = 1;
  my $CloseLastColumn = 0;
  foreach my $AuthorID (@AuthorIDs) {
    $FirstLetter = substr $Authors{$AuthorID}{LastName},0,1;
    $FirstLetter =~ tr/[a-z]/[A-Z]/;
    if ($NThisCol >= $NPerCol && $FirstLetter ne $PreviousLetter) {
      $StartNewColumn = 1;
    }

    if ($StartNewColumn) {
      if ($CloseLastColumn) {
        print "</ul></td>\n";
      }
      print "<td class=\"w3-padding\">\n";
      $StartNewColumn = 0;
      $NThisCol = 0;
      $FirstPass = 1;
    }

    ++$NThisCol;

    if ($FirstLetter ne $PreviousLetter) {
      $PreviousLetter = $FirstLetter;
      unless ($FirstPass) {
        print "</ul>\n";
      }
      $FirstPass = 0;
      print "<a id=\"$FirstLetter\"></a>\n";
      print "<div class=\"w3-large w3-teal w3-round w3-panel w3-leftbar w3-border w3-border-black\" style=\"font-weight:700;\">$FirstLetter</div>\n";
      print "<ul>\n";
    }
    my $AuthorLink = AuthorLink($AuthorID, -format => "formal");
    my $AuthorCount = "";
    if ($AuthorCounts{$AuthorID}{Exact}) {
      $AuthorCount = " ($AuthorCounts{$AuthorID}{Exact})";
    }
#    if ($CheckEvent) {
#      my %Hash = GetEventHashByModerator($AuthorID);
#      if (%Hash) {
#        $AuthorLink .= ListByEventLink({ -authorid => $AuthorID });
#      }
#    }

    print "<li>$AuthorLink$AuthorCount</li>\n";
    $CloseLastColumn = 1;
  }
  print "</ul></td></tr>";
  print "</table>\n";
  print "</div><!-- Closing div w3-container w3-margin -->\n";
}


sub RequesterActiveSearch {
  my ($ArgRef) = @_;
  my $DefaultID = exists $ArgRef->{-default}   ? $ArgRef->{-default}  : 0;
  my $Name   = exists $ArgRef->{-name}   ?   $ArgRef->{-name}   : "requester";
  my $HelpLink   = exists $ArgRef->{-helplink}   ?   $ArgRef->{-helplink}   : "authors";
  my $HelpText   = exists $ArgRef->{-helptext}   ?   $ArgRef->{-helptext}   : "Submitter";
  my $Required   = exists $ArgRef->{-required}   ?   $ArgRef->{-required}   : $TRUE;
  my $ExtraText =   $Params{-extratext} || "";

  my $HTML;
  if ($HelpLink) {
    $HTML .= FormElementTitle(-helplink => $HelpLink, -helptext  => $HelpText,
                              -required => $Required, -extratext => $ExtraText,
                              -name     => "requester",
                              -errormsg => 'You must choose a requester.');
    $HTML .= "\n";
  }

  my ($Default, $DefaultName);
  if ($DefaultID) {
    $Default = $DefaultID;
    $DefaultName = $Authors{$DefaultID}{Formal};
  }

  $HTML .= '<input class="required w3-input w3-border w3-round" name="requester_text" type="text" id="requester" value="'.$DefaultName.'">'.
           '<input name="requester" type="hidden" id="requester-id" value="'.$Default.'">'."\n";
  return $HTML;
}

sub AuthorActiveSearch {
  my ($ArgRef) = @_;
  my @DefaultAuthorIDs = exists $ArgRef->{-defaultauthorids} ? @{$ArgRef->{-defaultauthorids}} : ();
  my $HelpLink = exists $ArgRef->{-helplink} ? $ArgRef->{-helplink} : "authors";
  my $HelpText = exists $ArgRef->{-helptext} ? $ArgRef->{-helptext} : "Authors";
  my $Required = exists $ArgRef->{-required} ? $ArgRef->{-required} : $TRUE;
  my $ExtraText = exists $ArgRef->{-extratext} ? $ArgRef->{-extratext} : "";

  my @AuthorIDs = sort byLastName keys %Authors;

  my $HTML;

  if ($HelpLink) {
    $HTML .= FormElementTitle(-helplink => $HelpLink, -helptext  => $HelpText,
                              -required => $Required, -extratext => $ExtraText,
                              -errormsg => 'You must choose at least one author.');
    $HTML .= "\n";
  }
  $HTML .= '<div id="sel_authors_box">'."\n";
  $HTML .= '<ul id="authors_id_span"></ul>'."\n";
  $HTML .= '</div>'."\n";
  $HTML .= '<input id="author_dummy" class="required" type="hidden" value="dummy" name="authors" />'."\n";
  $HTML .= '<input name="authors_selection_text" type="text" id="authors_selector" class="w3-input w3-border w3-round"><br /> (type to search and<br/>click or press <i>Enter</i>)'."\n";

  $HTML .= '<script type="text/javascript">
            <!--
            jQuery().ready(function() {';
  foreach my $AuthorID (@DefaultAuthorIDs) {
    # /* call this function for each author, with authors_id and title [do not forget to escape it]  */
    $HTML .= 'addAuthorList(['.$AuthorID.', "'.$Authors{$AuthorID}{Formal}.'"]);'."\n";
  }
  $HTML .= '});
            // -->
            </script>';
  return $HTML;
}

sub AuthorScroll (%) {
  require "AuthorSQL.pm";
  require "Sorts.pm";

  my (%Params) = @_;

  my $All       =   $Params{-showall}   || 0;
  my $Multiple  =   $Params{-multiple}  || 0;
  my $HelpLink  =   $Params{-helplink}  || "";
  my $HelpText  =   $Params{-helptext}  || "Authors";
  my $ExtraText =   $Params{-extratext} || "";
  my $Required  =   $Params{-required}  || 0;
  my $Name      =   $Params{-name}      || "authors";
  my $Size      =   $Params{-size}      || 10;
  my $Disabled  =   $Params{-disabled}  || "";
  my @Defaults  = @{$Params{-default}};

  unless (keys %Author) {
    GetAuthors();
  }

  my @AuthorIDs = sort byLastName keys %Authors;
  my %AuthorLabels = ();
  my @ActiveIDs = ();
  foreach my $ID (@AuthorIDs) {
    if ($Authors{$ID}{ACTIVE} || $All) {
      $AuthorLabels{$ID} = SmartHTML({-text=>$Authors{$ID}{Formal}});
      push @ActiveIDs,$ID;
    }
  }
  if ($HelpLink) {
    my $ElementTitle = FormElementTitle(-helplink => $HelpLink, -helptext  => $HelpText,
                                        -required => $Required, -extratext => $ExtraText, );
    print $ElementTitle,"\n";
  }
  if ($Disabled) { # FIXME: Use Booleans
    print $query -> scrolling_list(-name => $Name, -values => \@ActiveIDs,
                                   -labels => \%AuthorLabels,
                                   -size => $Size, -multiple => $Multiple,
                                   -default => \@Defaults, -disabled,
                                   -class => "w3-select w3-border",
                                   -style => "width:100%;");
  } else {
    print $query -> scrolling_list(-name => $Name, -values => \@ActiveIDs,
                                   -labels => \%AuthorLabels,
                                   -size => $Size, -multiple => $Multiple,
                                   -default => \@Defaults,
                                   -class => "w3-select w3-border",
                                   -style => "width:100%;");
  }
}

sub AuthorTextEntry ($;@) {
  my ($ArgRef) = @_;

#  my $Disabled = exists $ArgRef->{-disabled} ?   $ArgRef->{-disabled} : "0";
  my $HelpLink  = exists $ArgRef->{-helplink}  ?   $ArgRef->{-helplink}  : "authormanual";
  my $HelpText  = exists $ArgRef->{-helptext}  ?   $ArgRef->{-helptext}  : "Authors";
  my $Name      = exists $ArgRef->{-name}      ?   $ArgRef->{-name}      : "authormanual";
  my $Required  = exists $ArgRef->{-required}  ?   $ArgRef->{-required}  : $FALSE;
  my $ExtraText = exists $ArgRef->{-extratext} ?   $ArgRef->{-extratext} : "";
  my @Defaults  = exists $ArgRef->{-default}   ? @{$ArgRef->{-default}}  : ();

  my $AuthorManDefault = "";

  foreach $AuthorID (@Defaults) {
    FetchAuthor($AuthorID);
    $AuthorManDefault .= SmartHTML({-text=>$Authors{$AuthorID}{FULLNAME}})."\n" ;
  }

  print FormElementTitle(-helplink => $HelpLink, -helptext  => $HelpText,
                         -required => $Required, -extratext => $ExtraText, );
  print $query -> textarea (-name    => $Name, -default => $AuthorManDefault,
                            -columns => 25,    -rows    => 8, -class => "w3-input w3-border");
};

sub InstitutionEntryBox (;%) {
  my (%Params) = @_;

  my $Disabled = $Params{-disabled}  || "0";

  my $Booleans = "";

  if ($Disabled) {
    $Booleans .= "-disabled";
  }

  print "<table cellpadding=5><tr valign=top>\n";
  print "<td>\n";
  print FormElementTitle(-helplink => "instentry", -helptext => "Short Name");
  print $query -> textfield (-name => 'shortdesc',
                             -size => 30, -maxlength => 40, -class => "w3-input w3-border w3-round", $Booleans);
  print "</td></tr>\n";

  print "<tr><td>\n";
  print FormElementTitle(-helplink => "instentry", -helptext => "Long Name");
  print $query -> textfield (-name => 'longdesc',
                             -size => 40, -maxlength => 80, -class => "w3-input w3-border w3-round", $Booleans);
  print "</td>\n";
  print "</tr></table>\n";
}

1;
