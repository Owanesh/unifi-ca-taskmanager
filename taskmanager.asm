# Utility
# ------------------
# |LB -- Load byte | A byte is loaded into a register from the specified address.
# |
# | lb $t, offset($s)



			# Prendo memoria per memorizzare un task
li $v0, 9		# codice syscall SBRK
li $a0, 20		# numero di byte da allocare
syscall                 # chiamata sbrk: restituisce un blocco di 4 byte, puntato da v0: il nuovo record
			

#------------
# STRUTTURA DI UN TASK (in byte) TOT 20byte
# 4 byte = Id
# 1 byte = Priorita
# 1 byte = Esecuzioni rimanenti
# 4 byte = Indirizzo memoria del task successivo
# 8 byte = Nome del task
#-----------------------------------------------


#-------------------- PROCEDURA DI ORDINAMENTO UNICA ----------------------

ordinamentounico:   # definita il nome della procedura
 lw $t1,lenght      # carico la lunghezza della lista
 lw $t3,head        # load a pointer to array into $a1
 addi $t1,$t1,-1    #inizializzazione dei due contatori
 addi $t2,$t1,$zero 
 lw $t7, head        #inizializzo la sentinella al primo elmento della lista 


loop1:
 beqz $t2,here     #if $t2 is zero, goto here
 addi $t2,$t2,-1   #subtract 1 from $t2, save to $t2
 lw $t5,4($t3)     #carico il byte 4, quindi la priorita del task
 lw $t3,6($t3)     #t3 attualmente prende l'indirizzo nella cella successiva della lista
 lw $t6,4($t3)     #carico il byte 4, quindi la priorita del task (successivo)
 blt $t5,$t6,loop1 #if $t5 < $t6, goto loop1
 lw $t7,4($t7)     #sposto la sentinella di un elemento 
 beq $t5,$t6,swapbyid   #IPOTESI non ci va messo 4($t5),4($t6) ???? io voglio controllare
		    #ipotizziamo di partire con 1-2-3-4
 sw 4($t7),4($t5)   # il successivo di 1 e'3
 sw 4($t5),4($t6)   # il successivo di 2 e' 4
 sw 4($t6),$t5      # il successivo di 3 e' 2
                    #arriviamo alla fine con 1-3-2-4
 bnez $t2,loop1     #if $t2 is not zero, to go loop1

# La swapbyid viene chiamata nel caso due elementi abbiano stessa priorità
# o stesse esecuzioni rimanenti, insomma, arrivati qui, si ordina in maniera
# decrescente rispetto all'id
swapbyid:


 
here:
 la $a1,array      #load array into $a1
 addi $t1,$t1,-1   #subtract 1 from $t1, save to $t1
 add $t2,$t2,$t1   #add $t2 to $t1, save to $t2
 bnez $t1,loop1    #if $t1 isn't zero, goto loop1
 li $v0,4          #load 4 into $v0 (print string)
 la $a0,output     #load 'the numbers are' into $a0
 syscall           #display message to screen
 la $a1,array      #load array pointer into $a1
 li $t1,10         #load 10 into $t1



escidalprogramma:
 li $v0,10         #exit
 syscall