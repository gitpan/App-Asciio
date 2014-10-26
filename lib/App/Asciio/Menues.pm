
package App::Asciio ;

$|++ ;

use strict;
use warnings;

use Data::TreeDumper ;
use Clone;
use List::Util qw(min max) ;
use List::MoreUtils qw(any minmax first_value) ;
use Eval::Context ;

use Glib ':constants';
use Gtk2 -init;
use Gtk2::Gdk::Keysyms ;
my %K = %Gtk2::Gdk::Keysyms ;
my %C = map{$K{$_} => $_} keys %K ;

#------------------------------------------------------------------------------------------------------

sub display_popup_menu
{
my ($self, $event) = @_;

my ($popup_x, $popup_y) = $event->coords() ;

my @menu_items ;

for my $element (@{$self->{ELEMENT_TYPES}})
	{
	(my $name_with_underscore = $element->{NAME}) =~ s/_/__/g ;
	
	push @menu_items, 
		[ "/$name_with_underscore", undef , insert_generator($self, $element, $popup_x, $popup_y), 0 , '<Item>', undef],
	}

for my $menu_entry (@{$self->get_context_menu_entries($popup_x, $popup_y)})
	{
	my($name, $sub, $data) = @{$menu_entry} ;
	(my $name_with_underscore = $name) =~ s/_/__/g ;
	
	push @menu_items, [ $name_with_underscore, undef , $self->menue_entry_wrapper($sub, $data), 0, '<Item>', undef],
	}

push @menu_items, 
	(
	['/File/open', undef , sub {$self->run_actions_by_name('Open') ;}, 0 , '<Item>', undef],
	['/File/save', undef , sub {$self->run_actions_by_name('Save') ;}, 0 , '<Item>', undef],
	[ '/File/save as', undef , sub {$self->run_actions_by_name(['Save', 1]) ;}, 0 , '<Item>', undef],
	) ;
	
if($self->get_selected_elements(1) == 1)
	{
	push @menu_items, [ '/File/save stencil', undef , $self->menue_entry_wrapper(\&save_stencil), 0 , '<Item>', undef ] ;
	}	

my $item_factory = Gtk2::ItemFactory->new("Gtk2::Menu" ,"<popup>") ;
$item_factory ->create_items($self->{widget}, @menu_items) ;

my $menu = $item_factory->get_widget("<popup>") ;

$menu->popup(undef, undef, undef, undef, $event->button, $event->time) ;
}

sub insert_generator 
{ 
my ($self, $element, $x, $y) = @_ ; 
my ($character_width, $character_height) = $self->get_character_size() ;

return sub
	{
	$self->add_new_element_of_type($element, $self->closest_character($x, $y)) ;
	$self->update_display();
	} ;
}

sub menue_entry_wrapper
{
my ($self, $sub, $data) = @_ ; 

return sub
	{
	$sub->($self, $data) ;
	} ;
}

#------------------------------------------------------------------------------------------------------

my Readonly $SHORTCUTS = 0 ;
my Readonly $CODE = 1 ;
my Readonly $ARGUMENTS = 2 ;
my Readonly $CONTEXT_MENUE_SUB = 3 ;
my Readonly $CONTEXT_MENUE_ARGUMENTS = 4 ;
my Readonly $NAME= 5 ;

sub get_context_menu_entries
{
my ($self, $popup_x, $popup_y) = @_ ;
my @context_menu_entries ;

for my $context_menu_handler
	(
	map {$self->{CURRENT_ACTIONS}{$_}}
		grep 
			{
			'ARRAY' eq ref $self->{CURRENT_ACTIONS}{$_} # not a sub actions definition
			&& defined $self->{CURRENT_ACTIONS}{$_}[$CONTEXT_MENUE_SUB]
			} sort keys %{$self->{CURRENT_ACTIONS}}
	)
	{
	#~ print "Adding context menue from action '$context_menu_handler->[$NAME]'.\n" ;
	
	if(defined $context_menu_handler->[$CONTEXT_MENUE_ARGUMENTS])
		{
		push @context_menu_entries, 
			$context_menu_handler->[$CONTEXT_MENUE_SUB]->
				(
				$self,
				$context_menu_handler->[$CONTEXT_MENUE_ARGUMENTS],
				$popup_x, $popup_y,
				) ;
		}
	else
		{
		push @context_menu_entries, $context_menu_handler->[$CONTEXT_MENUE_SUB]->($self, $popup_x, $popup_y) ;
		}
	}
	
return(\@context_menu_entries) ;
}

#------------------------------------------------------------------------------------------------------

1 ;
