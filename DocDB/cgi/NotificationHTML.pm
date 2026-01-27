#        Name: NotificationHTML.pm
# Description: HTML for document notifications
#
#      Author: Eric Vaandering (ewv@fnal.gov)

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

sub DocNotifySignup (%) {
  my %Params     = @_;
  my $DocumentID = $Params{-docid};

  my $NeedUserFields = ($UserValidation ne "certificate" && $UserValidation ne "shibboleth" && $UserValidation ne "FNALSSO");

  print "<div id=\"DocNotifySignup\" class=\"w3-padding-small\">\n";
  print $query -> start_multipart_form('POST',$WatchDocument);
  print "<div class=\"InputWrapper\">\n";
  # COMMENTED OUT: Removed <hr> per user request
  # if ($NeedUserFields) {
  #   print "<hr/>\n";
  # }
  print $query -> hidden(-name => 'docid', -default => $DocumentID, -override => 1);

  if ($NeedUserFields) {
    print "<div class=\"w3-padding-small\">\n";
    print "<label><strong>Username:</strong><br/>\n";
    print $query -> textfield(-name => 'username', -size => 12, -maxlength => 32, -class => "w3-input w3-border w3-round w3-padding-small");
    print "</label>\n";
    print "</div>\n";
    print "<div class=\"w3-padding-small\">\n";
    print "<label><strong>Password:</strong><br/>\n";
    print $query -> password_field(-name => 'password', -size => 12, -maxlength => 32, -class => "w3-input w3-border w3-round w3-padding-small");
    print "</label>\n";
    print "</div>\n";
  }
  print "<div id=\"DocActionSubmitCell\" class=\"w3-padding w3-center\">\n";
  print $query -> submit (-value => "Watch Document", -class => "w3-button w3-docdb-color w3-round w3-border w3-border-black w3-padding-small");
  print "</div>\n";
  print "</div>\n";
  print $query -> end_multipart_form;
  print "</div>\n";
}



1;
