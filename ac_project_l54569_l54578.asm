.global main
.data 
imagem: .space 172800	#Array com os valores RGB
texto: .string "Escolha qual personagem quer ver:\n1-Yoda | 2-Darth Maul | 3-Mandalorian\n"
ficheiro_original: .string "starwars.rgb"
ficheiro_novo: .string "starwars_novo.rgb"
centromassa:	.space 2	


.text

#################################################################################
#Função: read_rgb_image							   	#
#Descrição: Lê o ficheiro starwars.rgb e coloca cada pixel dentro de 'imagem'.  #
#Argumentos: 								   	#
#	a0 - endereço do ficheiro starwars.rgb				   	#
#	a1 - array com os valores RGB					   	#
#	a2 - tamanho do array						   	#
#	a7 - comandos syscall para abertura, leitura e fecho		   	#
#Retorno:								   	#
#	a0 - endereço do ficheiro starwars.rgb				   	#
#################################################################################
read_rgb_image:		li a7, 1024		#Abre o ficheiro
			li a1, 0		#Define para leitura
			ecall
			mv t0, a0		#Guarda a descrição do ficheiro
			li a7, 63		#Lê o ficheiro descrito e coloca os valores para um buffer
			la a1, imagem		#Endereço do array o serão lidos os pixeis
			li a2, 172800		#Tamanho do array
			ecall			
			li a7, 57		#Fechar o ficheiro
			mv a0, t0		#Mover o endereço para a0 para retorno
			ecall
			ret

############################################################################
#Função: write_rgb_image						   #
#Descrição: Cria um ficheiro em formato .rgb com o resultado final.	   #
#Argumentos: 								   #
#	a0 - endereço do ficheiro starwars.rgb    			   #
#	a1 - array com os valores rgb alterados 			   #
#	a2 - tamanho do array						   #
#	a7 - comandos syscall para abertura, escrita e fecho		   #
#Retorno:								   #
#	a0 - endereço do ficheiro starwars_novo.rgb			   #
############################################################################	
write_rgb_image:	li a7, 1024
			li a1, 1		#Define para escrita
			ecall
			mv s6, a0
			li a7, 64		#Escreve os valores do array no ficheiro descrito
			la a1, imagem		
			li a2, 172800
			ecall
			li a7, 57
			mv a0, s6
			ecall
			ret
	
#################################################################################
# Funcao: hue									#
# Descricao: Esta função calcula o valor de matiz (hue) com base nos		#
#            valores de intensidade de vermelho (r), verde (g) e azul (b).	#
# Argumentos:									#
# a0 - r (red)									#
# a1 - g (green)								#
# a2 - b (blue)									#
# Retorno:									#
# a0 - h (hue)									#
#################################################################################
	
hue:		
		addi sp, sp, -4
		sw t1, 0(sp)
		li t0, 0             # Inicializa h com 0		
	   	# Comparação e cálculos
		bgeu a1, a0, verdeamarelado    # if (r <= g)
	  	bgtu a2, a1, verdeamarelado    # if (b > g) 
	  	sub t1, a1, a2      # t1 = g - b
	        sub t2, a0, a2      # t2 = r - b
	        li t3, 60           # t3 = 60
	        mul t4, t1, t3      # t4 = (g - b) * 60
		div t0, t4, t2      # h = (g - b) * 60 / (r - b)
		j end_hue
verdeamarelado: bltu a1, a0, verdeprimavera	# if (g < r)
	  	bleu a0, a2, verdeprimavera	# if (r <= b)
	        sub t1, a0, a2      # t1 = r - b
	  	sub t2, a1, a2      # t2 = g - b
	        li t3, 60           # t3 = 60
	        mul t4, t1, t3      # t4 = (r - b) * 60
		div t5, t4, t2      # t5 = (r - b) * 60 / (g - b)
		li t6, 120	    # t6 = 120
		sub t0, t6, t5      # h = 120 - (r - b) * 60 / (g - b)
		j end_hue
verdeprimavera:	bleu a1, a2, azure	# if (g <= b)
	  	bltu a2, a0, azure	# if (b < r)
	  	sub t1, a2, a0      # t1 = b - r
	  	sub t2, a1, a0      # t2 = g - r
	        li t3, 60           # t3 = 60
	        mul t4, t1, t3      # t4 = (b - r) * 60
		div t5, t4, t2      # t5 = (b - r) * 60 / (g - r)
		addi t0, t5, 120    # h = 120 + (r - b) * 60 / (g - b)
		j end_hue
azure:		bltu a2, a1, violeta	# if (b < g)
	  	bleu a1, a0, violeta	# if (g <= r)
	  	
	  	sub t1, a1, a0 		# t1 = g - r
	  	sub t2, a2, a0      	# t2 = b - r
	        li t3, 60           	# t3 = 60
	        mul t4, t1, t3      	# t4 = (g - r) * 60
		div t5, t4, t2      	# t5 = (g - r) * 60 / (b - r)
		li t6, 240		# t6 = 240
		sub t0, t6, t5		# h = 240 - (g - r) * 60 / (b - r)
		j end_hue
		
violeta:
		
		bleu a2, a0, rosa	# if (b <= r)
	  	bltu a0, a1, rosa	# if (r < g)
	  	
	  	sub t1, a2, a1 		# t1 = b - g
	  	sub t2, a0, a1   	# t2 = r - g
	        li t3, 60           	# t3 = 60
	        mul t4, t2, t3      	# t4 = (r - g) * 60
		div t5, t4, t1      	# t5 = (r - g) * 60 / (b - g)
		addi t0, t5, 240	# h = 240 + (r - g) * 60 / (b - g)
		j end_hue
		
rosa:
		
		bltu a0, a2, end_hue	# if (r < b)
	  	bleu a2, a1, end_hue	# if (b <= g)
	  	
	  	sub t1, a0, a1   	# t1 = r - g
	  	sub t2, a2, a1 		# t2 = b - g
	        li t3, 60           	# t3 = 60
	        mul t4, t2, t3      	# t4 = (b - g) * 60
		div t5, t4, t1      	# t5 = (b - g) * 60 / (r - g)
		li t6, 360		# t6 = 360
		sub t0, t6, t5 		# h = 360 - (b - g) * 60 / (r - g)
		
		end_hue:
	    	mv a0, t0
		lw t1, 0(sp)
	    	addi sp, sp, 4
	    	ret               # Retorna para o endereço de retorno
	    	
#################################################################################
# Funcao: indicator								#
# Descricao: Esta função verifica se os pixels pertencem ou não ao		#
#            personagem escolhido.						#
# Argumentos:									#
# a0 - hue									#
# a1 - personagem								#
# Retorno:									#
# a0 - 0 se não pertencer e 1 se pertencer					#
#################################################################################  
	
	
indicator:  	  
			addi sp, sp -4
			sw t1, 0(sp)
			
			li t0, 1
			li t1, 2
			li t2, 3
			bne a1, t0, darthmaul			# yoda
			li t0, 40
			li t1, 80
			blt a0, t0, fim_yoda
			bgt a0, t1, fim_yoda
			li a0, 1
			lw t1, 0(sp)
			addi sp, sp 4
			ret
	       fim_yoda:li a0, 0
	       		lw t1, 0(sp)
			addi sp, sp 4
		      	ret
			
	darthmaul:	bne a1, t1, mandalorian			# darthmaul
			li t0, 1
			li t1, 15
			blt a0, t0, fim_darthmaul
			bgt a0, t1, fim_darthmaul
			li a0, 1
			lw t1, 0(sp)
			addi sp, sp 4
			ret
	  fim_darthmaul:li a0, 0
	  		lw t1, 0(sp)
			addi sp, sp 4
		      	ret
	mandalorian:   	bne a1, t1, fim_mandalorian			# mandalorian
			li t0, 1
			li t1, 15
			blt a0, t0, fim_mandalorian
			bgt a0, t1, fim_mandalorian
			li a0, 1
			lw t1, 0(sp)
			addi sp, sp 4
			ret
	fim_mandalorian:li a0, 0
			lw t1, 0(sp)
			addi sp, sp 4
		      	ret			
		
#################################################################################
#Função: location						 	   	#
#Descrição: Calculo do centro de massa	 				   	#
#Argumentos: 								   	#
#	a0 - indicator							   	#
#Retorno:								   	#
#	Preenche o array 'centromassa' com as coordenadas x e y, respetivamente.#
#################################################################################
	
location:
		la a4, centromassa
		li t0, 320				# t0 = 320
		beqz a0, fim_location			# se a0 = 0, vai para fim_location
		add s3, s3, a6				# s3 = s3 + a6 - soma os pixels todos
		div t2, s3, s2				# t2 = s3 / s2 - Descobre o pixel do centro
   fim_location:div a2, t2, t0				# a2 = t2 / 320 - Descobre y
   		rem a3, t2, t0				# a3 = t2 % 320 - Descobre x
		sb a3, 0(a4)
		addi a4, a4, 1
		sb a2, 0(a4)
		ret

#################################################################################
#Função: cruz							 	   	#
#Descrição: Esta função desenha a cruz no centro de massa		   	#
#Argumentos: 								   	#
#	a4 - array com os valores RGB da imagem					#
#	a5 - array com o centro de massa 				   	#
#Retorno:								   	#
#	Desenha a cruz nas coordenadas do centro de massa			#
#################################################################################

cruz:
	li t0, 3		
	li t1, 960		
		
	lb t2, 0(a5)		#valor de X
	addi a5, a5, 1
	lb t3, 0(a5)		#valor de Y
	
	mul t4, t2, t0		#calculo do x
	mul t5, t3, t1		#calculo do Y
	sub t0, t1, t4
	sub t1, t5, t0
	add a4, a4, t1
	
	li t1, 255
	li t2, 0 
	li t3, 0
	
	sb t1, 0(a4)		#
	sb t2, 1(a4)		#o pixel referente ao centro de massa a preto
	sb t3, 2(a4)		#
	
	li t1, 5
	
	# Cruz horizontal (Verde Puro)
	li t2, 0			
	li t3, 255		
	li t4, 0
				
	li t5, 960
	
	# Desenhar a parte direita da cruz
      direita:addi a4, a4, 3
	sb t2, 0(a4)
	sb t3, 1(a4)
	sb t4, 2(a4)
	addi t1, t1, -1
	bnez t1, direita
	li t1, 5
	addi a4, a4, -15	#anda no buffer com os valores RGB da imagem
	
	#  Desenhar a parte esquerda da cruz
	esquerda:addi a4, a4, -3
	sb t2, 0(a4)
	sb t3, 1(a4)
	sb t4, 2(a4)
	addi t1, t1, -1
	bnez t1, esquerda
	li t1, 5
	addi a4, a4, 15
	
	# Cruz vertical (Vermelho Puro)
	li t2, 255
	li t3, 0
	li t4, 0
	
	li t5, 4800
	
	#  Desenhar a parte de cima da cruz
	cima:addi a4,a4,-960
	sb t2,0(a4)
	sb t3,1(a4)
	sb t4,2(a4)
	addi t1,t1,-1
	bnez t1,cima
	li t1,5
	add a4,a4,t5
	
	# Desenhar a parte de baixo da cruz
	baixo:addi a4, a4, 960
	sb t2, 0(a4)
	sb t3, 1(a4)
	sb t4, 2(a4)
	addi t1, t1, -1
	bnez t1, baixo
	sub a4, a4, t5
	ret
		
		
main:	
	# Guarda os registos na pilha
		addi sp, sp, -16
		sw s0, 0(sp)
		sw s1, 4(sp)
		sw s2, 8(sp)
		sw s3, 12(sp)
			
	# Dá valores aos registos importantes no loop
		li a5, 57600
		li a6, 0


	# Chama a função read_rgb_image
	    	la a0, ficheiro_original 
	   	jal ra, read_rgb_image   
	    	mv s1, a1
	
	# Escreva no terminal o texto para escolha do personagem
	    	la a0, texto           
	    	li a7, 4                 
	    	ecall                    	
	    
	# Lê o numero escolhido
	    	li a7, 5                 
	    	ecall                    
	    	mv t1, a0
       	
       	
       	# Loop que executa as funções hue, indicator e location em todos os pixels da imagem
       	loop:  
	    	lbu a0, 0(s1)
	    	lbu a1, 1(s1)
	    	lbu a2, 2(s1)
	    	jal hue
	    	mv a1, t1
	    	jal indicator
	    	add s2, s2, a0
	    	jal ra, location
	    	addi s1, s1, 3
	    	addi a5, a5, -1
	    	addi a6, a6, 1
	    	bnez a5, loop
	    	
	# Chama a função cruz
	    	la a4, imagem
	    	la a5, centromassa
	    	jal cruz
	
	# Chama a função write_rgb_image
	    	la a0, ficheiro_novo
	    	jal write_rgb_image
	
	# Recupera os registos da pilha	    
	    	lw s0, 0(sp)
	    	lw s1, 4(sp)
	    	lw s2, 8(sp)
	    	lw s3, 12(sp)
	    	addi sp, sp, 4
	                          
	# Fim do programa
	    	li a7, 10             
	    	ecall                 # Chama o sistema para encerrar o programa
