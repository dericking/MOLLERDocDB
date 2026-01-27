#        Name: FileHTML.pm
#
# Description: Subroutines to provide links for files, groups of
#              files and archives.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: Eric Vaandering (ewv@fnal.gov)

# Copyright 2001-2017 Eric Vaandering, Lynn Garren, Adam Bryant

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

sub FileListByRevID {
  require "MiscSQL.pm";
  my ($DocRevID) = @_;

  my @FileIDs  = &FetchDocFiles($DocRevID);
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  my $Version    = $DocRevisions{$DocRevID}{VERSION};

  print "<div id=\"Files\">\n";
  print "<h4>Files in Document:</h4>\n";

  if (@FileIDs) {
    @RootFiles  = ();
    @OtherFiles = ();
    foreach my $FileID (@FileIDs) {
      if ($DocFiles{$FileID}{ROOT}) {
        push @RootFiles,$FileID;
      } else {
        push @OtherFiles,$FileID;
      }
    }
    if (@RootFiles) {
      print "<div class=\"FileList\">\n";
      &FileListByFileID(@RootFiles);
      print "</div>\n";
    }
    if (@OtherFiles) {
      print "<div class=\"FileList\"><em>Other Files:</em>\n";
      &FileListByFileID(@OtherFiles);
      print "</div>\n";
    }
    unless ($Public) {
      my $ArchiveLink = &ArchiveLink($DocumentID,$Version);
      print "<ul>\n";
      print "<li style=\"list-style-type:circle;\">$ArchiveLink</li>\n";
      print "</ul>\n";
    }
  } else {
    print "None\n";
  }
  print "</div>\n";
}

sub ShortFileListByRevID {
  require "MiscSQL.pm";
  my ($DocRevID, $SkipVersions) = @_;

  my @FileIDs  = &FetchDocFiles($DocRevID);
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  my $Version    = $DocRevisions{$DocRevID}{VERSION};

  @RootFiles  = ();
  foreach $File (@FileIDs) {
    if ($DocFiles{$File}{ROOT}) {
      push @RootFiles,$File
    }
  }
  if (@RootFiles) {
    ShortFileListByFileID({-files => \@RootFiles, -skipversions => $SkipVersions, });
  } else {
    print "None<br/>\n";
  }
}

sub FileListByFileID {
  require "Sorts.pm";

  my (@Files) = @_;
  unless (@Files) {
    return;
  }

  @Files = sort FilesByDescription @Files;

  print "<ul>\n";
  foreach my $FileID (@Files) {
    my $DocRevID   = $DocFiles{$FileID}{DOCREVID};
    my $Version    = $DocRevisions{$DocRevID}{VERSION};
    my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
    my $Link = FileLink( {-docid => $DocumentID, -version => $Version,
                          -shortname   => $DocFiles{$FileID}{NAME},
                          -description => $DocFiles{$FileID}{DESCRIPTION}} );
    print "<li>$Link</li>\n";
  }
  print "</ul>\n";
}

sub ShortFileListByFileID { # FIXME: Make special case of FileListByFileID
  require "Sorts.pm";

  my ($ArgRef) = @_;
  my @Files        = exists $ArgRef->{-files}        ? @{$ArgRef->{-files}}       : ();
  my $SkipVersions = exists $ArgRef->{-skipversions} ?   $ArgRef->{-skipversions} : $FALSE;

  @Files = sort FilesByDescription @Files;

  foreach my $FileID (@Files) {
    my $DocRevID   = $DocFiles{$FileID}{DOCREVID};
    my $Version    = $DocRevisions{$DocRevID}{VERSION};
    my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
    my $Link = FileLink( {-maxlength => 20, -format => "short", -docid => $DocumentID, -version => $Version,
                          -shortname   => $DocFiles{$FileID}{NAME}, -skipversions => $SkipVersions,
                          -description => $DocFiles{$FileID}{DESCRIPTION}} );
    print "$Link<br/>\n";
  }
}

sub FileLink ($) {
  my ($ArgRef) = @_;

  my $DocumentID   = exists $ArgRef->{-docid}        ? $ArgRef->{-docid}        : 0;
  my $Version      = exists $ArgRef->{-version}      ? $ArgRef->{-version}      : 0;
  my $ShortName    = exists $ArgRef->{-shortname}    ? $ArgRef->{-shortname}    : "";
  my $Description  = exists $ArgRef->{-description}  ? $ArgRef->{-description}  : "";
  my $MaxLength    = exists $ArgRef->{-maxlength}    ? $ArgRef->{-maxlength}    : 60;
  my $MaxExt       = exists $ArgRef->{-maxext}       ? $ArgRef->{-maxext}       : 4;
  my $Format       = exists $ArgRef->{-format}       ? $ArgRef->{-format}       : "long";
  my $SkipVersions = exists $ArgRef->{-skipversions} ? $ArgRef->{-skipversions} : $FALSE;

  require "FSUtilities.pm";
  require "FileUtilities.pm";

  my $ShortFile = CGI::escape($ShortName);
  my $BaseURL   = GetURLDir($DocumentID,$Version);
  my $FileSize  = FileSize(FullFile($DocumentID,$Version,$ShortName));

  $FileSize =~ s/^\s+//; # Chop off leading spaces

  my $PrintedName = $ShortName;
  if ($MaxLength) {
    $PrintedName = AbbreviateFileName(-filename  => $ShortName,
                                      -maxlength => $MaxLength, -maxext => $MaxExt);
  }

  my $URL = $BaseURL.$ShortFile;
  if ($UserValidation eq "certificate" || $UserValidation eq "shibboleth" || 
      $UserValidation eq "FNALSSO" || $Preferences{Options}{AlwaysRetrieveFile}) {
    $URL = $RetrieveFile."?docid=".$DocumentID.'&amp;filename='.$ShortFile;
    unless ($SkipVersions) {
        $URL .= '&amp;version='.$Version;
    }
  }

  my $Link = "";

  # Sanitize output
  $ShortName = SmartHTML( {-text => $ShortName, } );
  $Description = SmartHTML( {-text => $Description, } );
  $PrintedName = SmartHTML( {-text => $PrintedName, } );

  if ($Format eq "short") {
    if ($Description) {
      return "<a href=\"$URL\" title=\"$ShortName\" class=\"w3-text-docdb-color\">$Description</a>";
    } else {
      return "<a href=\"$URL\" title=\"$ShortName\" class=\"w3-text-docdb-color\">$PrintedName</a>";
    }
  } else {
    if ($Description) {
      return "<a href=\"$URL\" title=\"$ShortName\" class=\"w3-text-docdb-color\">$Description</a> ($PrintedName, $FileSize)";
    } else {
      return "<a href=\"$URL\" title=\"$ShortName\" class=\"w3-text-docdb-color\">$PrintedName</a> ($FileSize)";
    }
  }
}

sub ArchiveLink {
  my ($DocumentID,$Version) = @_;

  my @Types = ("tar.gz");
  if ($Zip) {push @Types,"zip";}

  @Types = sort @Types;

  my $link  = "Get all files as \n";
  @LinkParts = ();
  foreach my $Type (@Types) {
    push @LinkParts,"<a href=\"$RetrieveArchive?docid=$DocumentID\&amp;version=$Version\&amp;type=$Type\" class=\"w3-text-docdb-color\">$Type</a>";
  }
  $link .= join ', ',@LinkParts;
  $link .= ".";

  return $link;
}

sub FileUploadBox (%) {
  my (%Params) = @_;

  my $Type        = $Params{-type}        || "file";
  my $DescOnly    = $Params{-desconly}    || 0;
  my $AllowCopy   = $Params{-allowcopy}   || 0;
  my $MaxFiles    = $Params{-maxfiles}    || 0;
  my $AddFiles    = $Params{-addfiles}    || 0;
  my $DocRevID    = $Params{-docrevid}    || 0;
  my $Required    = $Params{-required}    || 0;
  my $FileSize    = $Params{-filesize}    || 60;
  my $FileMaxSize = $Params{-filemaxsize} || 250;

  my @FileIDs = @{$Params{-fileids}};

  require "Sorts.pm";

  if ($DocRevID) {
    require "MiscSQL.pm";
    @FileIDs = &FetchDocFiles($DocRevID);
  }

  my @RootFiles  = ();
  my @OtherFiles = ();

  foreach my $FileID (@FileIDs) {
    if ($DocFiles{$FileID}{ROOT}) {
      push @RootFiles,$FileID;
    } else {
      push @OtherFiles,$FileID;
    }
  }

  @RootFiles  = sort FilesByDescription @RootFiles;
  @OtherFiles = sort FilesByDescription @OtherFiles;
  @FileIDs    = (@RootFiles,@OtherFiles);
  my $NOrigFiles = scalar(@FileIDs);
  unless ($MaxFiles) {
    if (@FileIDs) {
      if ($NumberUploads > $NOrigFiles+$AddFiles) {
        $MaxFiles = $NumberUploads;
      } else {
        $MaxFiles = $NOrigFiles+$AddFiles;
      }
    } elsif ($NumberUploads) {
      $MaxFiles = $NumberUploads;
    } elsif ($UserPreferences{NumFiles}) {
      $MaxFiles = $UserPreferences{NumFiles};
    } else {
      $MaxFiles = 1;
    }
  }
  if ($DescOnly) {
    $MaxFiles = $NOrigFiles;
  }

  print "<div>\n";
  print $query -> hidden(-name => 'maxfiles', -default => $MaxFiles);
  print "</div>\n";

  print "<table class=\"Alternating LeftHeader FileEntry\">\n";

  my ($HelpLink,$HelpText,$FileHelpLink,$FileHelpText,$DescHelpLink,$DescHelpText,$ReqName);
  if ($Type eq "file") {
    $HelpLink = "fileupload";
    $HelpText = "Local file upload";
    $FileHelpLink = "localfile";
    $FileHelpText = "File";
    $ReqName      = "upload1";
  } elsif ($Type eq "http") {
    $HelpLink = "httpupload";
    $HelpText = "Upload by HTTP";
    $FileHelpLink = "remoteurl";
    $FileHelpText = "URL";
    $ReqName      = "url1";
  }

  if ($DescOnly) {
    $HelpLink = "filechar";
    $HelpText = "Update File Characteristics";
  }

  $DescHelpLink = "description";
  $DescHelpText = "Description";

  my %Options = ();
  if ($Required && !$AllowCopy && !$DescOnly) { # Only require on add
    $Options{'-name'} = $ReqName;
    $Options{'-errormsg'} = 'You must upload at least one file.'
  }

  my $BoxTitle = FormElementTitle(-helplink => $HelpLink, -helptext => $HelpText,
                                  -required => $Required, %Options);
  
  if ($Type eq "file" && !$DescOnly) {
    # Print title before file upload divs
    print '<div>';
    print $BoxTitle;
    print "</div>\n";
    
    if ($AllowCopy) {
      print '<div>';
      print '&nbsp;<label><input type="checkbox" name="checkall" class="w3-check" style="accent-color: #004080;" onclick="checkUncheckAll(this,\'copyfile\');" /> ';
      print 'Copy all files from previous version (at least one file must be added or updated)</label>';
      print "</div>\n";
    }
  } else {
    # Keep table structure for HTTP uploads and DescOnly
    print '<tr><td colspan="2">';
    print $BoxTitle;
    print "</td></tr>\n";

    if ($AllowCopy && !$DescOnly) {
      print '<tr><td>&nbsp;</td><td colspan="2">';
      print '&nbsp;<label><input type="checkbox" name="checkall" class="w3-check" style="accent-color: #004080;" onclick="checkUncheckAll(this,\'copyfile\');" /> ';
      print 'Copy all files from previous version (at least one file must be added or updated)</label></td></tr>'."\n";
    }
  }

  for (my $i = 1; $i <= $MaxFiles; ++$i) {
    my $FileID = shift @FileIDs;
    my $ElementName = "upload$i";
    my $DivName     = "upload_div$i";
    my $DescName    = "filedesc$i";
    my $MainName    = "main$i";
    my $FileIDName  = "fileid$i";
    my $CopyName    = "copyfile$i";
    my $URLName     = "url$i";
    my $NewName     = "newname$i";
    my $RowClass = ("Odd","Even")[$i % 2];

    my $FileHelp        = FormElementTitle(-helplink => $FileHelpLink, -helptext => $FileHelpText);
    my $DescriptionHelp = FormElementTitle(-helplink => $DescHelpLink, -helptext => $DescHelpText);
    my $NewNameHelp     = FormElementTitle(-helplink => "newfilename", -helptext => "New Filename");
    my $MainHelp        = FormElementTitle(-helplink => "main", -helptext => "Main?", -nocolon => $TRUE, -nobold => $TRUE);
    my $DefaultDesc = $DocFiles{$FileID}{DESCRIPTION};

    print "<tbody class=\"$RowClass\">\n";
    if ($DescOnly) {
      print "<tr>\n";
      print "<th>Filename:</th>";
      print "<td>\n";
      print $DocFiles{$FileID}{NAME};
      print $query -> hidden(-name => $FileIDName, -value => $FileID);
      print "</td>\n";
      print "</tr>\n";
    } else {
      if ($Type eq "file") {
        print '<div id="fileUploadOption" class="w3-panel w3-border w3-round w3-paper w3-padding w3-margin-bottom">'."\n";
        print '  <div class=""><b>File selection: </b></div>'."\n";
        print '  <div class="w3-cell-row">'."\n";
        print '    <div class="w3-cell w3-rest w3-cell-middle">'."\n";
        print "      <span id=\"$DivName\">\n";
        my %Options = ();
        if ($ElementName eq $ReqName && !$AllowCopy && !$DescOnly) {
          $Options{-class} = "required";
        }
        print $query -> filefield(-name => $ElementName, -size => $FileSize,
                                  -maxlength => $FileMaxSize, -class => "w3-input", 
                                  -style => "border:0!important; margin:0!important; padding:0!important;", %Options);
        print "      </span>\n";
        print '    </div>'."\n";
        print '    <div class="w3-cell w3-right">'."\n";
        print "      <input class=\"w3-button w3-border w3-docdb-color w3-round\" type=\"button\" value=\"Clear\" onclick=\"clearFileInputField('$DivName')\" />\n";
        print '    </div>'."\n";
        print '  </div>'."\n";
        print "\n";
        print '  <div class="w3-margin-bottom" style="margin-top:4px!important; margin-bottom:8px!important;"><b>File Description:</b></div>'."\n";
        print '  <div class="w3-cell-row">'."\n";
        print '    <div class="w3-cell w3-rest w3-cell-middle">'."\n";
        print $query -> textfield(-name => $DescName, -size => 60,
                                  -maxlength => 128, -default => $DefaultDesc,
                                  -class => "w3-input w3-round w3-border", -placeholder => "Description");
        print "\n";
        print '    </div>'."\n";
        print '    <div class="w3-cell w3-right">'."\n";
        print '      <label>'."\n";
        if ($i == 1) {
          print "        <input type=\"checkbox\" name=\"$MainName\" class=\"w3-check\" style=\"accent-color: #004080;\" checked=\"checked\" value=\"1\">&nbsp;&nbsp;Is Main File\n";
        } else {
          print "        <input type=\"checkbox\" name=\"$MainName\" class=\"w3-check\" style=\"accent-color: #004080;\" value=\"1\">&nbsp;&nbsp;Is Main File\n";
        }
        print '      </label>'."\n";
        print '    </div>'."\n";
        print '  </div>'."\n";
        print '</div>'."\n";
      } else {
        print "<tr><th>\n";
        print $FileHelp;
        print "</th>\n";

        print "<td>\n";
        my %Options = ();
        if ($ElementName eq $ReqName && !$AllowCopy && !$DescOnly) {
          $Options{-class} = "required";
        }
        if ($Type eq "http") {
          my %HTTPOptions = %Options;
          $HTTPOptions{'-class'} = ($HTTPOptions{'-class'} ? $HTTPOptions{'-class'}." " : "")."w3-input w3-border w3-round";
          print $query -> textfield(-name      => $URLName,     -size => $FileSize,
                                    -maxlength => $FileMaxSize, %HTTPOptions);
        }
        print "</td>\n";
        print "</tr>\n";

        if ($Type eq "http") {
          print "<tr><th>\n";
          print $NewNameHelp;
          print "</th>\n";

          print "<td>\n";
          print $query -> textfield(-name      => $NewName, -size => $FileSize,
                                    -maxlength => $FileMaxSize, -class => "w3-input w3-border w3-round");
          print "</td>\n";
          print "</tr>\n";
        }
        print "<tr><th>\n";
        print $DescriptionHelp;
        print "</th>\n";
        print "<td>\n";
        print $query -> textfield (-name      => $DescName, -size    => 60,
                                   -maxlength => 128,       -default => $DefaultDesc, -class => "w3-input w3-border w3-round");

        if ($i == 1) {
          print '&nbsp;<label><input type="checkbox" name="'.$MainName.'" class="w3-check" style="accent-color: #004080;" checked="checked" value="1"></label>';
        } else {
          print '&nbsp;<label><input type="checkbox" name="'.$MainName.'" class="w3-check" style="accent-color: #004080;" value="1"></label>';
        }

        print $MainHelp;
        print "</td></tr>\n";
      }
    }
    if ($FileID && $AllowCopy && !$DescOnly) {
      print "<tr><td>&nbsp;</td><td colspan=\"2\" class=\"FileCopyRow\">\n";
      print $query -> hidden(-name => $FileIDName, -value => $FileID);
      print '&nbsp;<label><input type="checkbox" name="'.$CopyName.'" class="w3-check" style="accent-color: #004080;" value="1"></label>';
      print "Copy <tt>$DocFiles{$FileID}{NAME}</tt> from previous version:";
      print "</td></tr>\n";
    }
    print "</tbody>\n";
  }
  if ($AllowCopy && $NOrigFiles) {
    print '<tr><td colspan="2">';
    print '<label><input type="checkbox" name="LessFiles" class="w3-check" style="accent-color: #004080;" value="1"></label>';
    print FormElementTitle(-helplink => "LessFiles", -helptext => "New version has fewer files",
                           -nocolon  => $TRUE,       -nobold   => $TRUE);;
    print "</td></tr>\n";
  }
  if ($Type eq "http") {
    print "<tr><th>User:</th>\n";
    print "<td>\n";
    print $query -> textfield (-name => 'http_user', -size => 20, -maxlength => 40, -class => "w3-input w3-border w3-round");
    print "<b>&nbsp;&nbsp;&nbsp;&nbsp;Password:</b>\n";
    print $query -> password_field (-name => 'http_pass', -size => 20, -maxlength => 40);
    print "</td></tr>\n";
  }

  print "</table>\n";
}

sub ArchiveUploadBox (%)  {
  my (%Params) = @_;

  my $Required   = $Params{-required}   || 0;        # short, long, full
  my %Options = ();
  if ($Required) {
     $Options{-class} = "required";
  }

  print "<table class=\"LowPaddedTable LeftHeader\">\n";
  print "<tr><td colspan=\"2\">";
  print FormElementTitle(-helplink => "filearchive", -helptext => "Archive file upload",
                         -required => $Required, -name => single_upload,
                         -errormsg => 'You must upload a archive file and specify main file.');
  print "</td></tr> \n";
  print "<tr><th>Archive File:</th><td>\n";
  print $query -> filefield(-name      => "single_upload", -size => 60,
                            -maxlength => 250, %Options);

  print "<tr><th>Main file in archive:</th><td>\n";
  print $query -> textfield (-name => 'mainfile', -size => 70, -maxlength => 128, -class => "w3-input w3-border w3-round");

  print "<tr><th>Description of file:</th><td>\n";
  print $query -> textfield (-name => 'filedesc', -size => 70, -maxlength => 128, -class => "w3-input w3-border w3-round");
  print "</td></tr></table>\n";
};

1;
