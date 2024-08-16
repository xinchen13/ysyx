#include "monitor.h"
#include "common.h"
#include "paddr.h"
#include "host.h"

static char *img_file = NULL;   // image file

static long load_img() {
    if (img_file == NULL) {
        printf("No image is given. Use the default build-in image.\n");
        return 0;
    }

    FILE *fp = fopen(img_file, "rb");
    assert(fp);

    fseek(fp, 0, SEEK_END);
    long size = ftell(fp);

    printf("load_img(): The image is %s, size = %ld\n", img_file, size);

    fseek(fp, 0, SEEK_SET);
    int ret = fread(guest_to_host(RESET_VECTOR), size, 1, fp);
    assert(ret == 1);

    fclose(fp);
    return size;
}

static int parse_args(int argc, char *argv[]) {
    const struct option table[] = {
        {"img"      , required_argument, NULL, 'i'},
        {"help"     , no_argument      , NULL, 'h'},
        {0          , 0                , NULL,  0 },
    };
    int o;
    while ((o = getopt_long(argc, argv, "-hi:", table, NULL)) != -1) {
        switch (o) {
            case 'i': img_file = optarg; break;
            default:
                printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
                printf("\t-i,--img=FILE read img file\n");
                printf("\n");
                exit(0);
        }
    }
    return 0;
}


void init_monitor(int argc, char *argv[]) {
    /* Perform some global initialization. */

    /* Parse arguments. */
    parse_args(argc, argv);

    /* Initialize memory. */
    init_mem();

    /* Load the image to memory. This will overwrite the built-in image. */
    long img_size = load_img();

    /* Display welcome message. */
    // welcome();
}
