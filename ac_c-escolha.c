#include <stdio.h>
#include <stdlib.h>
#define altura 180
#define tamanho 320

int rgbtohsv(unsigned char r, unsigned char g, unsigned char b)
{
    int h=0;
    if(r>g && g>=b)//laranja
        h=60*(g-b)/(r-b);
    else if(g>=r && r>b)//verde-amarelado
        h=120-60*(r-b)/(g-b);
    else if(g>b && b>=r)//verde-primavera
        h=120+60*(b-r)/(g-r);
    else if(b>=g && g>r)//azure
        h=240-60*(g-r)/(b-r);
    else if(b>r && r>=g)//violeta
        h=240+60*(r-g)/(b-g);
    else if(r>=b && b>g)//rosa
        h=360-60*(b-g)/(r-g);
    return h;
}

int abrir_imagem(const char *file,char *imagem)
{
    FILE *f=fopen(file, "rb");
    fread(imagem, 3, 3*tamanho*altura, f);
    fclose(f);
    return 0;
}

int save_image(const char *file,const char *imagem)
{
    FILE *f=fopen(file, "wb");
    fwrite(imagem,3,tamanho*altura,f);
    fclose(f);
    return 0;
}

int main(int argc, char const *argv[])
{
   int n;
   unsigned char im[3*tamanho*altura];

   abrir_imagem("starwars.rgb", im);
   printf("Escolha qual personagem quer ver:\n");
   printf("1-Yoda | 2-Darth Maul | 3-Mandalorian\n");
   scanf("%d", &n);

   for(int i=0; i<tamanho*altura; i++)
   {
        int r=im[i*3];
        int g=im[3*i+1];
        int b=im[3*i+2];
        int h=rgbtohsv(r,g,b);
        if(n==1){
            if(!(h>=40 && h<=80))
            {
                im[i*3]=0;
                im[i*3+1]=0;
                im[i*3+2]=0;
            }
        }else if(n==2){
            if(!(h>=1 && h<=15))
            {
                im[i*3]=0;
                im[i*3+1]=0;
                im[i*3+2]=0;
            }
        }else if(n==3){
            if(!(h>=160 && h<=180))
            {
                im[i*3]=0;
                im[i*3+1]=0;
                im[i*3+2]=0;
            }
        }
   }
    if(n==1)
        save_image("yoda.rgb",im);
    else if(n==2)
        save_image("DarthMaul.rgb",im);
    else if(n==3)
        save_image("Mandalorian.rgb",im);
    else if(n<1 || n>3){
        printf("Opção indisponivel!\n");
        exit(1);
    }    
}

    



