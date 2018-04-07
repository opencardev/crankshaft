#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

// This program is a wrapper to suid scripts in /opt/crankshaft
// Because we can't suid the bash scripts

int safe (char * s) {
	for (int i=0; i < strlen(s); i++) {
		char c = s[i];
		if ( ! (
			(('0' <= c) && (c <= '9')) ||
			(('a' <= c) && (c <= 'z')) ||
			(('A' <= c) && (c <= 'Z')) ||
			(c == '.') || (c == '_') || (c == '-')
			) ) { 
			return 0;
		}
	}
	return 1;
}

int main(int argc, char **argv)
{
	if ( argc < 2 ) {
		fprintf( stderr, "Usage: %s program_to_run.sh (in /opt/crankshaft)\n", argv[0] );
		return 1;
	}

	if( setuid( 0 ) ) {
		fprintf( stderr, "Can't setuid! Aborting execution.\n" );
		return 1;
	}

	if ( safe (argv[1]) ) {

		char scriptname[50];
		strcpy (scriptname, "/opt/crankshaft/");
		strncat(scriptname, argv[1], 50);

		execvp( scriptname, &argv[1]  );
		
	} else {
		fprintf( stderr, "The script %s isn't safe! Aborting execution.\n" );
		return 1;
	}

	return 0;
}
