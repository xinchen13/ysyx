#include <stdio.h>

int main(int argc, char *argv[])
{
    // if(argc != 2) {
    //     printf("ERROR: You need one argument.\n");
    //     // this is how you abort a program
    //     return 1;
    // }

    int j = 0;
    int i = 0;
    char letter;

    for(j = 1; j < argc; j++){
        for(i = 0; letter = argv[j][i], argv[j][i] != '\0'; i++) {
            // char letter = argv[1][i];
                
            if (letter < 91 && letter > 64){
                switch(letter) {
                    case 'A':
                        printf("%c", 'A'+32);
                        break;
                    case 'E':
                        printf("%c", 'E'+32);
                        break;
                    case 'I':
                        printf("%c", 'I'+32);
                        break;
                    case 'O':
                        printf("%c", 'O'+32);
                        break;
                    case 'U':
                        printf("%c", 'U'+32);
                        break;
                    default:
                        ;
                }
            }
            else {
                printf("%c",letter);
            }
        }
        printf("\n");
    }
    return 0;
}