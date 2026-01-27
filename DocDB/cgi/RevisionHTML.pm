#        Name: RevisionHTML.pm
# Description: Produce HTML related to information on document revisions
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

sub TitleBox (%) {
  push @DebugStack,"tb TitleDefault $TitleDefault";
  my (%Params) = @_;
  #FIXME: Get rid of global default

  my $Required   = $Params{-required}   || 0;

  my $HTML = FormElementTitle(-helplink  => "title" ,
                              -helptext  => "Title" ,
                              -required  => $Required
                              );
  $HTML .= $ElementTitle."\n";
  my $SafeDefault = SmartHTML({-text => $TitleDefault},);

  my %FieldParams = (-name => 'title', -default => $SafeDefault, -size => 70, -maxlength => 240, -class => "w3-input w3-border w3-round");
  if ($Required) {
    $FieldParams{'-class'} = "w3-input w3-border w3-round required";
  }
  $HTML .=  $query -> textfield(%FieldParams);
  print $HTML;
};

sub AbstractBox (%) {
  my (%Params) = @_;
  #FIXME: Get rid of global default

  my $Required = $Params{-required} || 0;
  my $HelpLink = $Params{-helplink} || "abstract";
  my $HelpText = $Params{-helptext} || "Abstract";
  my $Name     = $Params{-name}     || "abstract";
  my $Columns  = $Params{-columns}  || 60;
  my $Rows     = $Params{-rows}     || 4;

  my $ElementTitle = &FormElementTitle(-helplink  => $HelpLink ,
                                       -helptext  => $HelpText ,
                                       -required  => $Required);
  print $ElementTitle,"\n";
  my $SafeDefault = SmartHTML({-text => $AbstractDefault},);
  my %FieldParams = (-name    => $Name, -default => $SafeDefault,
                     -rows    => $Rows, -columns => $Columns, -class => "w3-input w3-border");
  if ($Required) {
    $FieldParams{'-class'} = "w3-input w3-border required";
  }
  print $query -> textarea(%FieldParams);
};

sub RevisionNoteBox {
  # FIXME: Make Javascript OK with SmartHTML
  my (%Params) = @_;
  my $Default  = $Params{-default}  || "";
  my $JSInsert = $Params{-jsinsert} || "";
  my $Required = $Params{-required} || 0;
  print "<a name=\"RevisionNote\" />";

  my $ExtraText = "";

  # Convert text string w/ control characters to JS literal

  if ($JSInsert) {
    $JSInsert =~ s/\n/\\n/g;
    $JSInsert =~ s/\r//g;
    $JSInsert =~ s/\'/\\\'/g;
    $JSInsert =~ s/\&#x27;/\\\&#x27;/g;
    $JSInsert =~ s/\&#x22;/\\\&#x27;/g;  # Double quote with single quote
    $JSInsert =~ s/\"/\\\'/g; # FIXME: See if there is a way to insert double quotes
                              #        Bad HTML/JS interaction, I think. Try breaking string at $JSInsert
    $ExtraText = "<a href=\"#RevisionNote\" onclick=\"InsertRevisionNote('$JSInsert');\" class=\"w3-text-docdb-color\">(Insert notes from previous version)</a>";
  }

  my $ElementTitle = &FormElementTitle(-helplink  => "revisionnote",
                                       -helptext  => "Notes and Changes",
                                       -extratext => $ExtraText,
                                       -required  => $Required );
  print $ElementTitle,"\n";
  my $SafeDefault = SmartHTML({-text => $Default},);
  my %FieldParams = (-name    => 'revisionnote', -default => $SafeDefault,
                     -rows    => 2, -columns => 60, -class => "w3-input w3-border");
  if ($Required) {
    $FieldParams{'-class'} = "w3-input w3-border required";
  }
  print $query -> textarea(%FieldParams);
#   print $query -> textarea (-name => 'revisionnote', -default => $Default,
#                             -columns => 60, -rows => 2);
};

sub DocTypeButtons (%) {
  my (%Params) = @_;

  my $Required = $Params{-required} || 0;
  my $Default  = $Params{-default}  || 0;

  &GetDocTypes();
  my @DocTypeIDs = keys %DocumentTypes;
  my %ShortTypes = ();

  foreach my $DocTypeID (@DocTypeIDs) {
    $ShortTypes{$DocTypeID} = SmartHTML({-text=>$DocumentTypes{$DocTypeID}{SHORT}});
  }

  my $ElementTitle = &FormElementTitle(-helplink  => "doctype" ,
                                       -helptext  => "Document type" ,
                                       -required  => $Required,
                                       -errormsg  => 'You must choose a document type.');

  print $ElementTitle,"\n";
  my %FieldParams = (-columns => 3,            -name    => "doctype",
                     -values  => \%ShortTypes, -default => $Default);
  if ($Required) {
    $FieldParams{'-class'} = "required";
  }
  print $query -> radio_group(%FieldParams);
};

sub PrintRevisionInfo {
  require "FormElements.pm";
  require "Security.pm";

  require "AuthorSQL.pm";
  require "SecuritySQL.pm";
  require "TopicSQL.pm";

  require "AuthorHTML.pm";
  require "DocumentHTML.pm";
  require "FileHTML.pm";
  require "SecurityHTML.pm";
  require "TopicHTML.pm";
  require "XRefHTML.pm";

  my ($DocRevID,%Params) = @_;

  my $HideButtons  = $Params{-hidebuttons}  || 0;
  my $HideVersions = $Params{-hideversions} || 0;

  FetchDocRevisionByID($DocRevID);

  my $DocumentID   = $DocRevisions{$DocRevID}{DOCID};
  my $Version      = $DocRevisions{$DocRevID}{VERSION};
  my @RevAuthorIDs = GetRevisionAuthors($DocRevID);
  my @TopicIDs     = GetRevisionTopics( {-docrevid => $DocRevID} );
  my @GroupIDs     = GetRevisionSecurityGroups($DocRevID);
  my @ModifyIDs;
  if ($EnhancedSecurity) {
    @ModifyIDs     = GetRevisionModifyGroups($DocRevID);
  }

  print "<div id=\"RevisionInfo\" class=\"w3-container w3-row\">\n";

  ### Column Layout

  ### Left Column

  print "<div id=\"LeftColumn3ColWrapper\" class=\"w3-quarter\">\n";

  ### BasicDocInfo module
  print "<div id=\"BasicDocInfo\" class=\"w3-card w3-paper w3-border w3-border-gray w3-round w3-margin-top\">\n";
  print "<div class=\"w3-center\" style=\"font-weight:700;margin-top:4px;\"><span style=\"text-decoration:underline;\">Document Information</span></div>\n";
  print "<div class=\"w3-bar-block\">\n";
  print "<div class=\"w3-bar-item\">\n";
   &PrintDocNumber($DocRevID);
   &RequesterByID($Documents{$DocumentID}{Requester});
   &SubmitterByID($DocRevisions{$DocRevID}{Submitter});
   &PrintModTimes;
  print "</div><!-- Closing div w3-bar-item -->\n";
  print "</div><!-- Closing div w3-bar-block -->\n";
  print "</div><!-- Closing div id BasicDocInfo -->\n";

  ### AccessInformation module
  print "<div id=\"AccessInformation\" class=\"w3-card w3-paper w3-border w3-border-gray w3-round w3-margin-top\">\n";
  print "<div class=\"w3-center\" style=\"font-weight:700;margin-top:4px;\"><span style=\"text-decoration:underline;\">Document Access</span></div>\n";
  print "<div class=\"w3-bar-block\">\n";
  &SecurityListByID(@GroupIDs);
  &ModifyListByID(@ModifyIDs);
  print "</div><!-- Closing div w3-bar-block -->\n";
  print "</div><!-- Closing div id AccessInformation -->\n";

  ### PreviousVersions module
  unless ($HideVersions) {
    require "RevisionSQL.pm";
    require "Sorts.pm";
    my @RevIDs = reverse sort RevisionByVersion &FetchRevisionsByDocument($DocumentID);
    if ($#RevIDs > 0) {  # Only show module if there's more than one version
      print "<div id=\"PreviousVersions\" class=\"w3-card w3-paper w3-border w3-border-gray w3-round w3-margin-top\">\n";
      print "<div class=\"w3-center\" style=\"font-weight:700;margin-top:4px;\"><span style=\"text-decoration:underline;\">Document Versions</span></div>\n";
      print "<div class=\"w3-margin-top\"></div>\n";
      print "<div class=\"w3-bar-block\">\n";
      &OtherVersionLinks($DocumentID,$Version);
      print "</div><!-- Closing div w3-bar-block -->\n";
      print "</div><!-- Closing div id PreviousVersions -->\n";
    }
  }

  ### UpdateButtons module
  if (CanModify($DocumentID) && !$HideButtons) {
    print "<div id=\"UpdateButtons\" class=\"w3-card w3-paper w3-border w3-border-gray w3-round w3-margin-top\">\n";
    print "<div class=\"w3-center\" style=\"font-weight:700;margin-top:4px;\"><span style=\"text-decoration:underline;\">Document Actions</span></div>\n";
    print "<div class=\"w3-bar-block w3-padding-small\">\n";
    UpdateButton($DocumentID);
    UpdateDBButton($DocumentID,$Version);
    if ($Version) {
      AddFilesButton($DocumentID,$Version);
    }
    # COMMENTED OUT: Create Similar Button - no longer needed
    # CloneButton($DocumentID);
    print "</div><!-- Closing div w3-bar-block -->\n";
    print "</div><!-- Closing div id UpdateButtons -->\n";
  }

  ### DocNotifySignup module
  unless ($Public || $HideButtons) {
    print "<div id=\"DocNotifySignup\" class=\"w3-card w3-paper w3-border w3-border-gray w3-round w3-margin-top\">\n";
    print "<div class=\"w3-center\" style=\"font-weight:700;margin-top:4px;\"><span style=\"text-decoration:underline;\">Document Notifications</span></div>\n";
    print "<div class=\"w3-bar-block\">\n";
    require "NotificationHTML.pm";
    &DocNotifySignup(-docid => $DocumentID);
    print "</div><!-- Closing div w3-bar-block -->\n";
    print "</div><!-- Closing div id DocNotifySignup -->\n";
  }

  print "<div class=\"w3-margin-bottom\"></div>\n";

  print "</div><!-- Closing div id LeftColumn3ColWrapper -->\n";

  ### Main Column

  print "<div id=\"MainColumn3Col\" class=\"w3-threequarter w3-padding\">\n";

  ### Document Title
  print "<div id=\"DocTitle\">\n";
   &PrintTitle($DocRevisions{$DocRevID}{Title});
   if ($UseSignoffs) {
     require "SignoffUtilities.pm";
     my ($ApprovalStatus,$LastApproved) = &RevisionStatus($DocRevID);
     unless ($ApprovalStatus eq "Unmanaged") {
       print "<h5>(Document Status: $ApprovalStatus)</h5>\n";
     }
   }
  print "</div><!-- Closing div id DocTitle -->\n";

  PrintAbstract($DocRevisions{$DocRevID}{Abstract}); # All are called only here, so changes are OK
  FileListByRevID($DocRevID); # All are called only here, so changes are OK
  print TopicListByID( {-topicids => \@TopicIDs, -listelement => "withparents", -sortby => "provenance",} );
  AuthorListByAuthorRevID({ -authorrevids => \@RevAuthorIDs });
  PrintKeywords($DocRevisions{$DocRevID}{Keywords});
  PrintRevisionNote($DocRevisions{$DocRevID}{Note});
  PrintXRefInfo($DocRevID);
  PrintReferenceInfo($DocRevID);
  PrintEventInfo(-docrevid => $DocRevID, -format => "normal");
  PrintPubInfo($DocRevisions{$DocRevID}{PUBINFO});

  if ($UseSignoffs) {
    require "SignoffHTML.pm";
    PrintRevisionSignoffInfo($DocRevID);
  }

  print "</div><!-- Closing div id MainColumn3Col -->\n";

  print "</div><!-- Closing div id RevisionInfo -->\n";
}

sub PrintAbstract ($;$) {
  my ($Abstract,$ArgRef) = @_;

  my $Format = exists $ArgRef->{-format} ? $ArgRef->{-format} : "div";

  if ($Abstract) {
    $Abstract = SmartHTML( {-text => $Abstract, -makeURLs => $TRUE, -addLineBreaks => $TRUE} );
  } else {
    $Abstract = "None";
  }

  if ($Format eq "div") {
    print "<div id=\"Abstract\" class=\"w3-panel w3-light-gray w3-round-large\">\n";
    print "<h4>Abstract:</h4>\n";
    print "<em>$Abstract</em>\n";
    print "</div>\n";
  } elsif ($Format eq "bare") {
    print  $Abstract;
  }
}

sub PrintKeywords {
  my ($Keywords) = @_;

  require "KeywordHTML.pm";

  $Keywords =~ s/^\s+//;
  $Keywords =~ s/\s+$//;

  if ($Keywords) {
    print "<div id=\"Keywords\">\n";
    print "<h4>Keywords:</h4>\n";
    print "<ul>\n";
    my @Keywords = split /\,*\s+/,$Keywords;
    my $Link;
    foreach my $Keyword (@Keywords) {
      $Link = &KeywordLink($Keyword);
      print "<li>$Link</li>\n";
    }
    print "</ul>\n";
    print "</div>\n";
  }
}

sub PrintRevisionNote {
  require "Utilities.pm";

  my ($RevisionNote) = @_;
  if ($RevisionNote) {
    print "<div id=\"RevisionNote\" class=\"w3-panel w3-light-gray w3-round-large w3-border\" style=\"border-style:dashed!important;border-width:1px;\">\n";
    $RevisionNote = SmartHTML( {-text => $RevisionNote, -makeURLs => $TRUE, -addLineBreaks => $TRUE} );
    print "<h4>Notes and Changes:</h4>\n";
    print "<em>$RevisionNote</em>\n";
    print "</div>\n";
  }
}

sub PrintReferenceInfo ($;$) {
  require "MiscSQL.pm";
  require "ReferenceLinks.pm";

  my ($DocRevID,$Mode) = @_;
  unless ($Mode) {$Mode = "long";}
  my @ReferenceIDs = &FetchReferencesByRevision($DocRevID);

  if (@ReferenceIDs) {
    &GetJournals;
    if ($Mode eq "long") {
      print "<div id=\"ReferenceInfo\">\n";
      print "<dl>\n";
      print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Journal References:</span></dt>\n";
    }
    foreach my $ReferenceID (@ReferenceIDs) {
      $JournalID = $RevisionReferences{$ReferenceID}{JournalID};
      if ($Mode eq "long") {
        print "<dd>Published in ";
      }
      my ($ReferenceLink,$ReferenceText) = &ReferenceLink($ReferenceID);
      if ($ReferenceLink) {
        print "<a href=\"$ReferenceLink\" class=\"w3-text-docdb-color\">";
      }
      if ($ReferenceText) {
        print "$ReferenceText";
      } else {
        print "$Journals{$JournalID}{Abbreviation} ";
        if ($RevisionReferences{$ReferenceID}{Volume}) {
          print " vol. $RevisionReferences{$ReferenceID}{Volume}";
        }
        if ($RevisionReferences{$ReferenceID}{Page}) {
          print " pg. $RevisionReferences{$ReferenceID}{Page}";
        }
      }
      if ($ReferenceLink) {
        print "</a>";
      }
      if ($Mode eq "long") {
        print ".</dd>\n";
      } elsif ($Mode eq "short") {
        print "<br/>\n";
      }
    }
    if ($Mode eq "long") {
      print "</dl>\n";
      print "</div>\n";
    }
  }
}

sub PrintEventInfo (%) {
  require "MeetingSQL.pm";
  require "MeetingHTML.pm";

  my %Params = @_;
  my $DocRevID = $Params{-docrevid};
  my $Format   = $Params{-format}   || "normal";
  my $EventGroupID = $Params{-eventgroupid} || 0;

  my @EventIDs = GetRevisionEvents($DocRevID);

  if (@EventIDs) {
    unless ($Format eq "short" || $Format eq "description") {
      print "<div id=\"EventInfo\">\n";
      print "<dl>\n";
      print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Associated with Events:</span></dt> \n";
    }
    foreach my $EventID (@EventIDs) {
      my $EventLink;
      if ($Format eq "description") {
        $EventLink = EventLink(-eventid => $EventID, -format => "long");
      } else {
        $EventLink = EventLink(-eventid => $EventID);
      }
      my $Start = EuroDate($Conferences{$EventID}{StartDate});
      my $End   = EuroDate($Conferences{$EventID}{EndDate});
      unless ($Format eq "short" || $Format eq "description") {
        print "<dd>";
      }
      print "$EventLink ";
      if ($Format eq "short" || $Format eq "description") {
        if ($EventGroupID) {
          # Comment out the date when eventgroupid is specified
          # print "($Start)<br/>";
          print "<br/>";
        } else {
          print "($Start)<br/>";
        }
      } else {
        if ($Start && $End && ($Start ne $End)) {
          print " held from $Start to $End ";
        }
        if ($Start && $End && ($Start eq $End)) {
          print " held on $Start ";
        }
        if ($Conferences{$EventID}{Location}) {
          print " in $Conferences{$EventID}{Location}";
        }
        print "</dd>\n";
      }
     }
    unless ($Format eq "short" || $Format eq "description") {
      print "</dl></div>\n";
    }
  }
}

sub PrintPubInfo ($) {
  require "Utilities.pm";

  my ($pubinfo) = @_;
  if ($pubinfo) {
    print "<div id=\"PubInfo\">\n";
    $pubinfo = SmartHTML( {-text => $pubinfo, -makeURLs => $TRUE, -addLineBreaks => $TRUE} );
    print "<dl>\n";
    print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Publication Information:</span></dt>\n";
    print "<dd>$pubinfo</dd>\n";
    print "</dl>\n";
    print "</div>\n";
  }
}

sub PrintModTimes {
  require "SQLUtilities.pm";
  require "SignoffUtilities.pm";

  my ($DocRevID) = @_;
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  $DocTime     = &EuroDateHM($Documents{$DocumentID}{Date});
  $RevTime     = &EuroDateHM($DocRevisions{$DocRevID}{DATE});
  $VersionTime = &EuroDateHM($DocRevisions{$DocRevID}{VersionDate});

  my $ActualDateTime = ConvertToDateTime({-MySQLTimeStamp => $DocRevisions{$DocRevID}{TimeStamp}, });
  my $ActualTime  = DateTimeString({ -DateTime => $ActualDateTime });

  print "<div><strong>Document Created:</strong><span>&nbsp;&nbsp;&nbsp;$DocTime</span></div>\n";
  print "<div><strong>Contents Revised:</strong><span>&nbsp;&nbsp;&nbsp;$VersionTime</span></div>\n";
  print "<div><strong>Metadata Revised:</strong><span>&nbsp;&nbsp;&nbsp;$RevTime</span></div>\n";
  if ($ActualTime ne $RevTime) {
    print "<div><strong>Actually Revised:</strong><span>&nbsp;&nbsp;&nbsp;$ActualTime</span></div>\n";
  }

  my $LastApproved = RevisionSignoffDate($DocRevID);
  if ($LastApproved) {
    my $ApprovalDateTime = ConvertToDateTime({-MySQLTimeStamp => $LastApproved, });
    my $ApprovalTime  = DateTimeString({ -DateTime => $ApprovalDateTime });
    print "<div><strong>Last Signed:</strong><span>&nbsp;&nbsp;&nbsp;$ApprovalTime</span></div>\n";
  }
}

sub OtherVersionLinks {
  require "Sorts.pm";

  my ($DocumentID,$CurrentVersion) = @_;
  my @RevIDs = reverse sort RevisionByVersion &FetchRevisionsByDocument($DocumentID);
  my $DocRevID = $RevIDs[0];

  my $HTML = "";
  $HTML .= "<div id=\"OtherVersions\" style=\"padding-top:8px!important;\">\n";
  # COMMENTED OUT: Quick Links section
  # $HTML .= "<p><b>Quick Links:</b>\n";
  # $HTML .= "<br/>";
  # $HTML .= DocumentLink(-docid => $DocumentID, -noversion => $TRUE, -linktext => "Latest Version");
  # 
  # if (!$Public && $Preferences{Security}{Instances}{Public}) {
  #   my @GroupIDs     = GetRevisionSecurityGroups($DocRevID);
  #   unless (@GroupIDs) {
  #     my $PublicURL = $Preferences{Security}{Instances}{Public}.'/ShowDocument?docid='.$DocumentID;
  #     $HTML .= '<br/><a href="'.$PublicURL.'" class="w3-text-docdb-color">Public Version</a>'."\n";
  #   }
  # }
  # 
  # $HTML .= "</p>\n";
  print $HTML;

  unless ($#RevIDs > 0) {
    print "</div>\n";
    return;
  }
  print "<span class=\"w3-padding\" style=\"font-weight:700;\">Other Versions:</span>\n";

  print "<table id=\"OtherVersionTable\" class=\"w3-table w3-bordered no-row-lines\">\n";

  foreach $RevID (@RevIDs) {
    my $Version = $DocRevisions{$RevID}{VERSION};
    if ($Version == $CurrentVersion) {next;}
    unless (&CanAccess($DocumentID,$Version)) {next;}
    $link = DocumentLink(-docid => $DocumentID, -version => $Version);
    $date = &EuroDateHM($DocRevisions{$RevID}{DATE});
    print "<tr><td>$link\n";
    print "<br/>$date\n";
    if ($UseSignoffs) {
      require "SignoffUtilities.pm";
      my ($ApprovalStatus,$LastApproved) = &RevisionStatus($RevID);
      unless ($ApprovalStatus eq "Unmanaged") {
        print "<br/>$ApprovalStatus";
      }
    }
    print "</td></tr>\n";
  }

  print "</table>\n";
  print "</div>\n";
}

1;
