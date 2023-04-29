#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>


// Define a struct RGBPixel para representar um pixel RGB
// Função que lê um arquivo com uma imagem RGB e armazena seus pixels em um array
// Retorna um ponteiro para o array de pixels
// Parâmetros:
// - filename: nome do arquivo a ser lido
// - width: endereço onde a largura da imagem deverá ser armazenada
// - height: endereço onde a altura da imagem deverá ser armazenada

typedef struct RGBPixel{
    unsigned char r;
    unsigned char g;
    unsigned char b;
} RGBPixel;

RGBPixel* read_rgb_image(const char* filename, int* width, int* height) {
    // Abre o arquivo em modo de leitura binária
    FILE* fp = fopen(filename, "rb");
    if (fp == NULL) {
        fprintf(stderr, "Erro ao abrir o arquivo %s\n", filename);
        exit(EXIT_FAILURE);
    }

    // Lê o cabeçalho do arquivo para obter a largura e a altura da imagem
    int header_size = 54;
    unsigned char header[header_size];
    if (fread(header, 1, header_size, fp) != header_size) {
        fprintf(stderr, "Erro ao ler o cabeçalho do arquivo %s\n", filename);
        exit(EXIT_FAILURE);
    }
    *width = (int)(header[18] | header[19] << 8 | header[20] << 16 | header[21] << 24);
    *height = (int)(header[22] | header[23] << 8 | header[24] << 16 | header[25] << 24);

    // Aloca um array de pixels para armazenar a imagem
    RGBPixel* image = (RGBPixel*)malloc(*width * *height * sizeof(RGBPixel));
    if (image == NULL) {
        fprintf(stderr, "Erro ao alocar memória para a imagem\n");
        exit(EXIT_FAILURE);
    }

    // Lê os pixels da imagem e os armazena no array
    int row_size = (*width * 3 + 3) & ~3;  // largura de uma linha da imagem (múltiplo de 4 bytes)
    for (int y = *height - 1; y >= 0; y--) {
        for (int x = 0; x < *width; x++) {
            int index = y * *width + x;
            RGBPixel pixel;
            if (fread(&pixel, sizeof(RGBPixel), 1, fp) != 1) {
                fprintf(stderr, "Erro ao ler o pixel (%d, %d) do arquivo %s\n", x, y, filename);
                exit(EXIT_FAILURE);
            }
            image[index] = pixel;
        }
        // Lê e descarta bytes de preenchimento adicionais, se necessário
        for (int i = 0; i < row_size - *width * 3; i++) {
            unsigned char dummy;
            if (fread(&dummy, 1, 1, fp) != 1) {
                fprintf(stderr, "Erro ao ler bytes de preenchimento da linha %d do arquivo %s\n", y, filename);
                exit(EXIT_FAILURE);
            }
        }
    }

    // Fecha o arquivo e retorna o array de pixels
    fclose(fp);
    return image;
}


void write_rgb_image(const char* filename, unsigned char* image, int width, int height) {
    FILE* fp = fopen(filename, "wb"); // abre o arquivo para escrita em modo binário
    if (!fp) {
        printf("Erro ao abrir o arquivo para escrita.\n");
        return;
    }
    
    // Escreve o cabeçalho do arquivo
    fprintf(fp, "P6\n%d %d\n255\n", width, height);
    
    // Escreve os pixels da imagem
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            int index = (y * width + x) * 3;
            fputc(image[index], fp);
            fputc(image[index + 1], fp);
            fputc(image[index + 2], fp);
        }
    }
    
    fclose(fp);
}


float hue(int r, int g, int b) {
    float max_val = (float) ((r > g) ? ((r > b) ? r : b) : ((g > b) ? g : b));
    float min_val = (float) ((r < g) ? ((r < b) ? r : b) : ((g < b) ? g : b));
    float delta = max_val - min_val;
    float hue_val = 0.0;

    if (delta != 0) {
        if (max_val == r) {
            hue_val = fmod(((g - b) / delta), 6.0);
        } else if (max_val == g) {
            hue_val = ((b - r) / delta) + 2.0;
        } else if (max_val == b) {
            hue_val = ((r - g) / delta) + 4.0;
        }
        hue_val *= 60.0;
        if (hue_val < 0) {
            hue_val += 360.0;
        }
    }

    return hue_val;
}


int indicator(int character, unsigned char R, unsigned char G, unsigned char B) {
    // definir as gamas de valores de R, G e B para cada personagem
    struct Character {
        int R_low, R_high, G_low, G_high, B_low, B_high;
    };

    struct Character yoda = {50, 120, 100, 170, 10, 70};
    struct Character maul = {120, 220, 20, 70, 20, 70};
    struct Character mando = {20, 60, 100, 170, 150, 230};

    // verificar se as componentes do pixel estão dentro das gamas da personagem escolhida
    switch (character) {
        case 1:  // Yoda
            if (R >= yoda.R_low && R <= yoda.R_high && G >= yoda.G_low && G <= yoda.G_high && B >= yoda.B_low && B <= yoda.B_high) {
                return 1;  // pixel pertence a Yoda
            }
            break;
        case 2:  // Darth Maul
            if (R >= maul.R_low && R <= maul.R_high && G >= maul.G_low && G <= maul.G_high && B >= maul.B_low && B <= maul.B_high) {
                return 1;  // pixel pertence a Darth Maul
            }
            break;
        case 3:  // Mandalorian
            if (R >= mando.R_low && R <= mando.R_high && G >= mando.G_low && G <= mando.G_high && B >= mando.B_low && B <= mando.B_high) {
                return 1;  // pixel pertence a Mandalorian
            }
            break;
        default:
            break;
    }

    // se as componentes não estiverem dentro das gamas da personagem, o pixel não pertence a essa personagem
    return 0;
}


void location(int p, int width, int height, unsigned char *image, int *x, int *y) {
    int count = 0;
    int sum_x = 0, sum_y = 0;

    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            int index = 3 * (i * width + j);
            int r = image[index];
            int g = image[index + 1];
            int b = image[index + 2];
            float h = hue(r, g, b);

            if (indicator(p, r, g, b)) {
                count++;
                sum_x += j;
                sum_y += i;
            }
        }
    }

    if (count > 0) {
        *x = sum_x / count;
        *y = sum_y / count;
    } else {
        *x = -1;
        *y = -1;
    }
}



int main(int argc, char * argv[]) 
{
    
    int width = 320;
    int height = 180;


    RGBPixel* image = read_rgb_image("starwars.png", &width, &height);
    char character[10];

    printf("Digite o nome de uma personagem (yoda, maul ou mando): ");
    scanf("%s", character);

    if (strcmp(character, "yoda") == 0) {

        // Chame a função para identificar Yoda na imagem
        RGBPixel* new_image = identify_character(image, width, height, 60, 90);
        write_rgb_image("yoda.png", (unsigned char*)new_image, width, height);
        free(new_image);
    } 
    
    else if (strcmp(character, "maul") == 0) {

        // Chame a função para identificar Maul na imagem
        RGBPixel* new_image = identify_character(image, width, height, 330, 30);
        write_rgb_image("maul.png", (unsigned char*)new_image, width, height);
        free(new_image);
    } 
    
    else if (strcmp(character, "mando") == 0) {

        // Chame a função para identificar Mando na imagem
        RGBPixel* new_image = identify_character(image, width, height, 30, 60);
        write_rgb_image("mando.png", (unsigned char*)new_image, width, height);
        free(new_image);
    } 
    
    else {
        printf("Personagem inválida.\n");
    }

    free(image);
    return 0;
}


