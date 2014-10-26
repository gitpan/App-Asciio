
use strict;
use warnings;

use lib qw(lib lib/stripes documentation/scripting/lib) ;

use App::Asciio ;
use scripting_lib ;

#-----------------------------------------------------------------------------

my $asciio = new App::Asciio() ;
$asciio->setup('setup/setup.ini') ;

#-----------------------------------------------------------------------------

my $box1 = new_box(TEXT_ONLY =>'box1') ;
$asciio->add_element_at($box1, 0, 2) ;

my $box2 = new_box(TEXT_ONLY =>'box2') ;
$asciio->add_element_at($box2, 20, 10) ;

my $box3 = new_box(TEXT_ONLY =>'box3') ;
$asciio->add_element_at($box3, 40, 5) ;

add_connection($asciio, $box1, $box2, 'down') ;
add_connection($asciio, $box2, $box3, ) ;
add_connection($asciio, $box3, $box1, 'up') ;
optimize_connections($asciio) ;

print $asciio->transform_elements_to_ascii_buffer() ;



