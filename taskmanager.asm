.data 

length: .word 0


		

#------------
# STRUTTURA DI UN TASK (in byte) TOT 20byte
# 4 byte = Id
# 1 byte = Priorita
# 1 byte = Esecuzioni rimanenti
# 4 byte = Indirizzo memoria del task successivo
# 8 byte = Nome del task
# 2 byte = rimanenti per allocare un multiplo di 4
#-----------------------------------------------


#-------------------- PROCEDURA DI ORDINAMENTO BUBBLESORT ----------------------

# $t0 = puntatore di appoggio per scorrere la lista
# $t1 = contatore ciclo esterno (loop2)
# $t2 = contatore ciclo interno (loop1)
# $t3 = puntatore del precedente
# $t4 = 

bubbleSortByPriority:
	lw $t1, length      # carico la lunghezza della lista
 	loopEsterno:
 		addi $t1, $t1, -1   # inizializzo contatore $t1 (ciclo esterno) a length-1
 		beqz $t1, exitLoopEsterno  #se $t1==0 allora esco dal ciclo esterno, ho terminato bubbleSort
 		move $t2,$t1	    # inizializzo contatore $t2 (ciclo interno) al valore di $t1
 		move $t4, $zero	    # $t4 = flag per primo caso 
		loopInterno:
			beqz $t2, exitLoopInterno     # se $t2==0 allora ho esaminato tutti gli elementi, quindi esco dal ciclo
			addi $t2,$t2,-1   	# decremento contatore $t2 (ciclo interno)
 			lbu $t5, 4($t0)     	# $t5 = priorità del task il cui indirizzo è in $t0, salto 4 byte di offset (cfr. schema del record task in cima alla pagina) 
 			move $t8, $t0		# $t8 = indirizzo del primo nodo (relativo a questa iterazione)
			lw $t0, 6($t0)          # $t0 = indirizzo del nodo successivo della lista, salto 6 byte di offset  
 			lbu $t6, 4($t0)     	# $t6 = priorità del task il cui indirizzo è in $t0, salto 4 byte di offset
 			move $t9, $t0		# $t9 = indirizzo del secondo nodo (relativo a questa iterazione)
 		
			blt $t5, $t6, loopInterno 	# se $t5<$t6 i due nodi sono ordinati in modo crescente, rieseguo il ciclo
 			beq $t5, $t6, swapByID  # se le priorità sono uguali allora ordino per ID
 			
 			# i due nodi non sono ordinati
 			beqz $t4, L1	  # se $t4==0 allora salta per gestire caso particolare
 			lw $t3, 6($t9)    # $t3 = D (ovvero C.next)
 			sw $t3, 6($t8)    # B.next = D (C.next)
 			sw $t8, 6($t9)    # C.next = B
 			sw $t9, 6($t7)    # A.next = C
 			lw $t7, 6($t7)  # aggiorno indirizzo sentinella $t7 al nodo successivo
 			move $t0, $t8	  # aggiorno indirizzo di $t0 dato che ho effettuato uno scambio
 			bnez $t2, loopInterno     # se $t2!=0, rieseguo il ciclo
 			j exitLoopInterno	#altrimenti esci dal ciclo
 			
 			L1:
 			lw $t3, 6($t9)    # $t3 = C (ovvero B.next)
 			sw $t3, 6($t8)    # A.next = C (ovvero B.next)
 			sw $t8, 6($t9)    # B.next = A
 			sw $t9, head      # head = B , ovvero B diventa la nuova head della lista
			lw $t7, head	  # aggiorno indirizzo sentinella $t7 al primo nodo della lista
			move $t0, $t8	  # aggiorno indirizzo di $t0 dato che ho effettuato uno scambio
			li $t4, 1		  #modifico flag $t4
 			bnez $t2, loopInterno     # se $t2!=0, rieseguo il ciclo
 			j exitLoopInterno	#altrimenti esci dal ciclo

			
			swapByID:	#è necessario accedere ai campi ID dei due nodi e confrontarli tra loro
			lw $t5, 0($t0)     	# $t5 = ID del task il cui indirizzo è in $t0, salto 0 byte di offset (cfr. schema del record task in cima alla pagina) 
 			move $t8, $t0		# $t8 = indirizzo del primo nodo (relativo a questa iterazione)
			lw $t0, 6($t0)          # $t0 = indirizzo del nodo successivo della lista, salto 6 byte di offset  
 			lw $t6, 4($t0)     	# $t6 = ID del task il cui indirizzo è in $t0, salto 0 byte di offset
 			move $t9, $t0		# $t9 = indirizzo del secondo nodo (relativo a questa iterazione)
 			
			bge $t5, $t6, loopInterno 	# se $t5>=$t6 i due nodi sono ordinati in modo decrescente, rieseguo il ciclo

			#i due nodi non sono ordinati
			beqz $t4, L1	  # se $t4==0 allora salta per gestire caso particolare
 			lw $t3, 6($t9)    # $t3 = D (ovvero C.next)
 			sw $t3, 6($t8)    # B.next = D (C.next)
 			sw $t8, 6($t9)    # C.next = B
 			sw $t9, 6($t7)    # A.next = C
 			lw $t7, 6($t7)  # aggiorno indirizzo sentinella $t7 al nodo successivo
 			move $t0, $t8	  # aggiorno indirizzo di $t0 dato che ho effettuato uno scambio
 			bnez $t2, loopInterno     # se $t2!=0, rieseguo il ciclo
 			j exitLoopInterno	#altrimenti esci dal ciclo
 			
 			L1:
 			lw $t3, 6($t9)    # $t3 = C (ovvero B.next)
 			sw $t3, 6($t8)    # A.next = C (ovvero B.next)
 			sw $t8, 6($t9)    # B.next = A
 			sw $t9, head      # head = B , ovvero B diventa la nuova head della lista
			lw $t7, head	  # aggiorno indirizzo sentinella $t7 al primo nodo della lista
			move $t0, $t8	  # aggiorno indirizzo di $t0 dato che ho effettuato uno scambio
			li $t4, 1		  #modifico flag $t4
 			bnez $t2, loopInterno     # se $t2!=0, rieseguo il ciclo
 			j exitLoopInterno	#altrimenti esci dal ciclo
 
		exitLoopInterno:
		bnez $t1, loopEsterno    # se $t1!=0 allora rieseguo il ciclo interno (loop1)
	exitLoopEsterno:
