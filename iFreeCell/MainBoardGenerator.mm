////////////////////////////////////////////////
///\file MainBoardGenerator.cpp
///\brief This is a program to generate Freecell (and similar solitare games) boards
///\author Michael Mann
///\version 1.0
///\date September 2002
////////////////////////////////////////////////

#include <time.h>
#include <iostream>
#include <fstream>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "AFreecellGameBoard.h"

using namespace std;

char *getNewBoardString(int);

int main2(int argc, char **argv)
{
	time_t Seed = time(NULL);
	char GameName[GAME_NAME_LENGTH];
	char* GameBoardString;
	GameName[0] = NULL;
	ofstream Write;
	bool Display10AsT = false;

	int arg;

	//parse the command line
	for (arg = 1;arg<argc;arg++)
	{
		if (!strcmp(argv[arg], "-n"))
		{
			arg++;
			if (arg != argc)
				Seed = atoi(argv[arg]);
		}
		else if (!strcmp(argv[arg], "-t"))
		{
			Display10AsT = true;
		}
		else if (!strcmp(argv[arg], "-g"))
		{
			arg++;
			if (arg != argc)
				strcpy(GameName, argv[arg]);
		}
		else
		{
			break;
		}
	}

	AFreecellGameBoard* GameBoard = CreateAFreecellGameBoard(GameName, Display10AsT);
	if (GameBoard == NULL)
	{
		cerr << "Invalid game name!" << endl;
		exit(-1);
	}

	GameBoardString = new char[GameBoard->GetGameBoardSize()+1];
	GameBoardString[0] = NULL;
	GameBoard->Shuffle((int)Seed);
	GameBoard->Deal(GameBoardString);

	if (arg == argc)
	{
		//use cout
		cout << GameBoardString << endl;
	}
	else
	{
		//use ofstream
		Write.open(argv[arg]);
		Write << GameBoardString << endl;
		Write.close();
	}

	return 0;
}


int main_test(void)
{
	cout << getNewBoardString(1) << endl;

	return 0;
}

char *getNewBoardString(int board)
{
	char *ret = NULL;

	if( board < 1 || board > 65535 )
	{
		board = 1;
	}

	AFreecellGameBoard *gameBoard = CreateAFreecellGameBoard( (char *)"microsoft_freecell", false );

	if( gameBoard != NULL )
	{
		ret = new char[gameBoard->GetGameBoardSize() + 1];
		*ret = '\0';

		gameBoard->Shuffle(board);
		gameBoard->Deal(ret);
	}

	return ret;
}