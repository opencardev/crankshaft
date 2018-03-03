#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>

// HACK: Will fix later
//
// This program is a wrapper to suid scripts in /opt/crankshaft
// Because we can't suid the bash scripts
//
// This is probably a dumb and dangerous idea but it works for now

int main( int argc, char **argv )
{
   setuid( 0 );
   char scriptname[50];
   strcpy (scriptname, "/opt/crankshaft/");
   strncat(scriptname, argv[1], 50);
   printf("Executing '%s' with suid 0!\n", scriptname);
   system( scriptname );

   return 0;
}
