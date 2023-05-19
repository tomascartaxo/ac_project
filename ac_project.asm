.global main
.data

fout: .asciz "/home/tmpcartaxo/Desktop/Universidade Tomás/AC1/ac_project"



.text

read_rgb_image:
	
	li   a7, 1024     # system call for open file
  	la   a0, fout     # output file name
  	li   a1, 1        # Open for writing (flags are 0: read, 1: write)
  	ecall             # open a file (file descriptor returned in a0)
  	mv   s6, a0       # save the file descriptor
  	
  	li   a7, 57       # system call for close file
  	mv   a0, s6       # file descriptor to close
  	ecall             # close file
  	
  	ret
  	

rgbtohsv:

	li t0, 0      	#t0: int h = 0
			#t1 = r ; t2 = g ; t3 = b
	
	bgt t1 , t2 , LA
	LA: bge t2 , t3 , laranja
	laranja:
		sub t4 , t2 , t3
		sub t5 , t1 , t3
		div t0 , t4 , t5      # h=60*(g-b)/(r-b)
		li t6 , 60
		mul t0 , t0 , t6
		ret
	
	bge t2 , t1 , VA
	VA: bgt t1 , t3 , verde-amarelado
	verde-amarelado:
		sub t4 , t1 , t3
		sub t5 , t2 , t3
		div t0 , t4 , t5		# h=120-60*(r-b)/(g-b)
		li t6 , 60
		mul t0 , t0 , t6
		li s0, 120
		sub t0 , s0 , t0
		ret
	
	bgt t2 , t3 , VP
	VP: bge t3 , t1 , verde-primavera
	verde-primavera:
		sub t4 , t3 , t1
		sub t5 , t2 , t1
		div t0 , t4 , t5      # h=120+60*(b-r)/(g-r)
		li t6 , 60
		mul t0 , t0 , t6
		addi t0, t0 , 120
		ret
	
	bge t3 , t2 , AZ
	AZ: bgt t2 , t1 , azure
	azure:
		sub t4 , t2 , t1
		sub t5 , t3 , t1
		div t0 , t4 , t5		# h=240-60*(g-r)/(b-r)
		li t6 , 60
		mul t0 , t0 , t6
		li s0, 240
		sub t0 , s0 , t0
		ret
	
	bgt t3 , t1 , VI
	VI: bge t1 , t2 , violeta
	violeta:
		sub t4 , t1 , t2
		sub t5 , t3 , t2
		div t0 , t4 , t5      # h=240+60*(r-g)/(b-g)
		li t6 , 60
		mul t0 , t0 , t6
		addi t0, t0 , 240
		ret
	
	bge t1 , t3 , RO
	RO: bgt t3 , t2 , rosa
	rosa:
		sub t4 , t3 , t2
		sub t5 , t1 , t2
		div t0 , t4 , t5		# h=360-60*(b-g)/(r-g)
		li t6 , 60
		mul t0 , t0 , t6
		li s0, 360
		sub t0 , s0 , t0
		ret	
	
		
	
		
	
		
	
		
		
	
	
	
