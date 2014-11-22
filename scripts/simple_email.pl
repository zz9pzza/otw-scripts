use MIME::Lite;
use URI::Escape;
use Template;
use Template::Config;
use Getopt::Long;

my ($template_dir,$email,$username,$html,$text,$subject);

GetOptions ( 'templatedir|T=s'=>\$template_dir,'email|E=s'=>\$email,'username|U=s'=>\$username,'subject|S=s'=>\$subject) ;
my $username_url = uri_escape($username) ;
if (!defined $subject) {
  $subject='Please support the Archive!'
}

my $vars   = {
       email        => $email ,
       username     => $username ,
       username_url => $username_url,
     } ;




my $msg = MIME::Lite->new
(
  Subject => "$subject",
  From    => 'Archive of Our Own <do-not-reply@archiveofourown.org>',
  To      => "$email",
  Type    => 'multipart/alternative',
);

my $tt = Template->new( EVAL_PERL => 1,INCLUDE_PATH =>$template_dir );
if (!$tt->process('email.html', $vars,\$html) ) {
   print "Skiping $username\n" ;
   exit 1;
  }
if (!$tt->process('email.text', $vars,\$text) ) {
   print "Skiping $username\n" ;
   exit 1;
  }

$msg->attach(
        Type     => 'TEXT',
        Data     => $text );


$msg->attach(
  Type => 'text/html',
  Data    => $html);

$msg->send();
