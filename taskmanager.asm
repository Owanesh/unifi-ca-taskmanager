.data 

length: .word 0
head: .word 0
contatoreID: .word 1
flagScheduling: .word 0		#default==0 (scheduling per priorità)
jump_table: .space 28 # jump table a 7 word, corrispondenti alle 7 scelte del menù
item1: .asciiz "1) Inserire un nuovo task"
item2: .asciiz "2) Eseguire il task in testa alla coda"
item3: .asciiz "3) Esegui uno specifico task"
item4: .asciiz "4) Elimina uno specifico task"
item5: .asciiz "5) Modifica priorita di uno specifico task"
item6: .asciiz "6) Cambia politica di scheduling"
item7: .asciiz "7) Esci dal programma"
strErrore: .ascii "Scelta errata! "
strInserimento: .asciiz "Inserisci scelta: "
strLinea: .asciiz "-------------------------------------------------------"
strInsPriorita: .asciiz "Inserisci Priorità: "
strInsNome: .asciiz "Inserisci Nome: "
strInsExec: .asciiz "Inserisci numero di esecuzioni: "
strIsEmpty: .asciiz "Errore! La lista è vuota"
tableHead: .asciiz "|  ID  |  PRIORITA'  |  NOME TASK  |  ESECUZ. RIMANENTI |"

 
 
#-----------------------------------------------
# STRUTTURA DI UN TASK (in byte) TOT 20byte
# 4 byte = Id
# 1 byte = Priorita
# 1 byte = Esecuzioni rimanenti
# 4 byte = Indirizzo memoria del task successivo
# 8 byte = Nome del task
# 2 byte = rimanenti per allocare un multiplo di 4
#-----------------------------------------------


.text
.globl main
#====================================================================================
#++--++--++--++--++--++--++ PROCEDURA MAIN   ========================================
#====================================================================================

main:  
# prepara la jump_table con gli indirizzi delle case actions
	la $s0, jump_table
	la $t0, case1  
	sw $t0, 0($s0)
 	la $t0, case2  
	sw $t0, 4($s0)
	la $t0, case3	  
	sw $t0, 8($s0)	  
	la $t0, case4	  
	sw $t0, 12($s0)
	la $t0, case5	  
	sw $t0, 16($s0)
	la $t0, case6	  
	sw $t0, 20($s0)
	la $t0, case7	  
	sw $t0, 24($s0)

loopMainMenu:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal printMainMenu	#stampo il menù principale
	lw $ra, 0($sp)
	addi $sp, $sp, 4
choice:
        # l'utente digita un'opzione	  
        li $v0, 12		# legge carattere digitato
	syscall
	move $t2, $v0   	# $t2 = opzione digitata
	addi $t2, $t2, -48	#decremento di 48 il valore ASCII del carattere digitato
	
	# controllo validità della scelta 
	sle  $t0, $t2, $zero	# $t0=1 se scelta <= 0
	bne  $t0, $zero, choice_err # errore se $t0==1
	li   $t0, 7
	sle  $t0, $t2, $t0	#$t0=1 se scelta<=7
	beq  $t0, $zero, choice_err # errore se $t0==0

branch_case:
	# se arrivo qui l'opzione digitata era corretta
	addi $t2, $t2, -1 # tolgo 1 da scelta perche' prima azione nella jump table (in posizione 0) corrisponde alla prima scelta del case
	add $t0, $t2, $t2
	add $t0, $t0, $t0 # ho calcolato (scelta-1) * 4
	add $t0, $t0, $s0 # sommo all'indirizzo base della JAT l'offset appena calcolato
	lw $t0, 0($t0)    # $t0 = indirizzo a cui devo saltare

	jr $t0 		  # salto all'indirizzo calcolato

case1: # Inserimento nuovo task
	#salva sempre $t1 (base JAT)
	j loopMainMenu # ritorna alla richiesta di inserimento

case2: # Esecuzione task in testa alla coda
	#salva sempre $t1 (base JAT)
	j loopMainMenu # ritorna alla richiesta di inserimento

case3: # Esecuzione specifico task"
	#salva sempre $t1 (base JAT)  
	j loopMainMenu # ritorna alla richiesta di inserimento
	
case4: # Eliminazione specifico task

	   
	j loopMainMenu # ritorna alla richiesta di inserimento
	
case5: # Modifica priorità di uno specifico task

	j loopMainMenu # ritorna alla richiesta di inserimento
	
case6: # Cambia politica di scheduling

	# controllo se la lista è vuota
	addi $sp,$sp, -4
	sw $ra, 0($sp)
	jal isEmpty
	lw $ra, 0($sp)
	addi $sp,$sp, 4
	beq $v0, $zero, return6	#se $v0==0 allora la lista è vuota, ritorno al menù principale
	
	
	loopSchedulingChoice:
	# l'utente digita un'opzione	  
        li $v0, 12		# legge carattere digitato
	syscall
	move $t2, $v0   	# $t2 = opzione digitata
	addi $t2, $t2, -49	#decremento di 49 il valore ASCII del carattere digitato (così digitando 1 diventa 0)
	
	# controllo validità della scelta 
	sle  $t0, $t2, $zero	# $t0=1 se scelta <= 0
	bne  $t0, $zero, choice_err2 # errore se $t0==1
	li   $t0, 2
	sle  $t0, $t2, $t0	#$t0=1 se scelta<=2
	beq  $t0, $zero, choice_err2 # errore se $t0==0
	
	#se arrivo qui l'opzione digitata è corretta
	addi $sp,$sp, -4
	sw $ra, 0($sp)
	
	bne $t2, $zero, L1Sched	#se $t2!=0 allora salto
	jal bubbleSortByPriority
	j L2Sched
	
	L1Sched:
	jal bubbleSortByRemainingExecution
	
	L2Sched:
	lw $ra, 0($sp)
	addi $sp,$sp, 4
	
	return6:
	j loopMainMenu # ritorna alla richiesta di inserimento
	  	  
case7: # Termina programma
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
choice_err: 
	li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	# stampa la stringa d'errore
	li $v0, 4  
     	la $a0, strErrore 
      	syscall 						  		  		  	  
      	j choice # ritorna alla richiesta di inserimento
	
choice_err2: 
	li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	# stampa la stringa d'errore
	li $v0, 4  
     	la $a0, strErrore 
      	syscall 						  		  		  	  
      	j loopSchedulingChoice # ritorna alla richiesta di inserimento	
	



#====================================================================================
#++--++--++--++--++--++-- PROCEDURA IS_EMPTY ========================================
#====================================================================================
isEmpty:
	lw $t0, length	#carico dimensione della lista
	beq $t0, $zero, return0	#se $t0!=0 allora ritorno 1, cioè la lista non è vuota, altrimenti salto e ritorno 0
	addiu $v0, $v0, 1 
	j exitIsEmpty
	
	return0:
	# stampa la stringa d'errore
	li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	li $v0, 4  
     	la $a0, strIsEmpty
      	syscall 
	move $v0, $zero
	
	exitIsEmpty:
	jr $ra
	
	
#====================================================================================
#++--++--++--++--++--++-- PROCEDURA INSERT TASK =====================================
#====================================================================================
insertTask:
	li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	li $v0, 4  
     	la $a0, strInsPriorita
      	syscall 
      	 # l'utente digita un'opzione	  
        li $v0, 12		# legge carattere digitato
	syscall
	move $t2, $v0   	# $t2 = opzione digitata
	addi $t2, $t2, -48	#decremento di 48 il valore ASCII del carattere digitato
	
	# controllo validità della scelta 
	sle  $t0, $t2, $zero	# $t0=1 se scelta <= 0
	bne  $t0, $zero, choice_err # errore se $t0==1
	li   $t0, 7
	sle  $t0, $t2, $t0	#$t0=1 se scelta<=7
	beq  $t0, $zero, choice_err # errore se $t0==0

#====================================================================================
#++--++--   PROCEDURA DI ORDINAMENTO BUBBLESORT PER PRIOIRTA' =======================
#====================================================================================

# $t0 = puntatore di appoggio per scorrere la lista
# $t1 = contatore ciclo esterno (loop2)
# $t2 = contatore ciclo interno (loop1)
# $t3 = puntatore del precedente
# $t4 = flag per gestire il caso in cui i primi due elementi della lista sono fuori posto
# $t5 = priorità del primo nodo incontrato durante una singola iterazione
# $t6 = priorità del secondo nodo incontrato durante una singola iterazione
# $t7 = indirzzo del secondo nodo della precedente iterazione
# $t8 = registro di appoggio per salvare l'indirizzo del primo nodo incontrato durante una singola iterazione
# $t9 = registro di appoggio per salvare l'indirizzo del secondo nodo incontrato durante una singola iterazione

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
 			beqz $t4, L1Prior	  # se $t4==0 allora salta per gestire caso particolare
 			lw $t3, 6($t9)    # $t3 = D (ovvero C.next)
 			sw $t3, 6($t8)    # B.next = D (C.next)
 			sw $t8, 6($t9)    # C.next = B
 			sw $t9, 6($t7)    # A.next = C
 			lw $t7, 6($t7)  # aggiorno indirizzo sentinella $t7 al nodo successivo
 			move $t0, $t8	  # aggiorno indirizzo di $t0 dato che ho effettuato uno scambio
 			bnez $t2, loopInterno     # se $t2!=0, rieseguo il ciclo
 			j exitLoopInterno	#altrimenti esci dal ciclo
 			
 			L1Prior:
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
			beqz $t4, L1Prior	  # se $t4==0 allora salta per gestire caso particolare
 			lw $t3, 6($t9)    # $t3 = D (ovvero C.next)
 			sw $t3, 6($t8)    # B.next = D (C.next)
 			sw $t8, 6($t9)    # C.next = B
 			sw $t9, 6($t7)    # A.next = C
 			lw $t7, 6($t7)  # aggiorno indirizzo sentinella $t7 al nodo successivo
 			move $t0, $t8	  # aggiorno indirizzo di $t0 dato che ho effettuato uno scambio
 			bnez $t2, loopInterno     # se $t2!=0, rieseguo il ciclo
 			j exitLoopInterno	#altrimenti esci dal ciclo
 			

		exitLoopInterno:
		bnez $t1, loopEsterno    # se $t1!=0 allora rieseguo il ciclo interno (loop1)
	exitLoopEsterno:
	sw $zero, flagScheduling #flagScheduling=0 perchè la politica di scheduling adottata è per priorità 
	jr $ra

#====================================================================================
#++--++--   PROCEDURA DI ORDINAMENTO BUBBLESORT PER ESECUZIONI RIMANENTI ===========
#====================================================================================

bubbleSortByRemainingExecution:
	lw $t1, length      # carico la lunghezza della lista
 	loopEsternoExec:
 		addi $t1, $t1, -1   # inizializzo contatore $t1 (ciclo esterno) a length-1
 		beqz $t1, exitLoopEsternoExec  #se $t1==0 allora esco dal ciclo esterno, ho terminato bubbleSort
 		move $t2,$t1	    # inizializzo contatore $t2 (ciclo interno) al valore di $t1
 		move $t4, $zero	    # $t4 = flag per primo caso 
		loopInternoExec:
			beqz $t2, exitLoopInternoExec     # se $t2==0 allora ho esaminato tutti gli elementi, quindi esco dal ciclo
			addi $t2,$t2,-1   	# decremento contatore $t2 (ciclo interno)
 			lbu $t5, 5($t0)     	# $t5 = priorità del task il cui indirizzo è in $t0, salto 4 byte di offset (cfr. schema del record task in cima alla pagina) 
 			move $t8, $t0		# $t8 = indirizzo del primo nodo (relativo a questa iterazione)
			lw $t0, 6($t0)          # $t0 = indirizzo del nodo successivo della lista, salto 6 byte di offset  
 			lbu $t6, 5($t0)     	# $t6 = priorità del task il cui indirizzo è in $t0, salto 4 byte di offset
 			move $t9, $t0		# $t9 = indirizzo del secondo nodo (relativo a questa iterazione)
 		
			bgt $t5, $t6, loopInternoExec 	# se $t5<$t6 i due nodi sono ordinati in modo crescente, rieseguo il ciclo
 			beq $t5, $t6, swapByIDExec  # se le priorità sono uguali allora ordino per ID
 			
 			# i due nodi non sono ordinati
 			beqz $t4, L1Exec	  # se $t4==0 allora salta per gestire caso particolare
 			lw $t3, 6($t9)    # $t3 = D (ovvero C.next)
 			sw $t3, 6($t8)    # B.next = D (C.next)
 			sw $t8, 6($t9)    # C.next = B
 			sw $t9, 6($t7)    # A.next = C
 			lw $t7, 6($t7)  # aggiorno indirizzo sentinella $t7 al nodo successivo
 			move $t0, $t8	  # aggiorno indirizzo di $t0 dato che ho effettuato uno scambio
 			bnez $t2, loopInternoExec     # se $t2!=0, rieseguo il ciclo
 			j exitLoopInternoExec	#altrimenti esci dal ciclo
 			
 			L1Exec:
 			lw $t3, 6($t9)    # $t3 = C (ovvero B.next)
 			sw $t3, 6($t8)    # A.next = C (ovvero B.next)
 			sw $t8, 6($t9)    # B.next = A
 			sw $t9, head      # head = B , ovvero B diventa la nuova head della lista
			lw $t7, head	  # aggiorno indirizzo sentinella $t7 al primo nodo della lista
			move $t0, $t8	  # aggiorno indirizzo di $t0 dato che ho effettuato uno scambio
			li $t4, 1		  #modifico flag $t4
 			bnez $t2, loopInternoExec     # se $t2!=0, rieseguo il ciclo
 			j exitLoopInternoExec	#altrimenti esci dal ciclo

			
			swapByIDExec:	#è necessario accedere ai campi ID dei due nodi e confrontarli tra loro
			lw $t5, 0($t0)     	# $t5 = ID del task il cui indirizzo è in $t0, salto 0 byte di offset (cfr. schema del record task in cima alla pagina) 
 			move $t8, $t0		# $t8 = indirizzo del primo nodo (relativo a questa iterazione)
			lw $t0, 6($t0)          # $t0 = indirizzo del nodo successivo della lista, salto 6 byte di offset  
 			lw $t6, 5($t0)     	# $t6 = ID del task il cui indirizzo è in $t0, salto 0 byte di offset
 			move $t9, $t0		# $t9 = indirizzo del secondo nodo (relativo a questa iterazione)
 			
			bge $t5, $t6, loopInternoExec 	# se $t5>=$t6 i due nodi sono ordinati in modo decrescente, rieseguo il ciclo

			#i due nodi non sono ordinati
			beqz $t4, L1Exec	  # se $t4==0 allora salta per gestire caso particolare
 			lw $t3, 6($t9)    # $t3 = D (ovvero C.next)
 			sw $t3, 6($t8)    # B.next = D (C.next)
 			sw $t8, 6($t9)    # C.next = B
 			sw $t9, 6($t7)    # A.next = C
 			lw $t7, 6($t7)  # aggiorno indirizzo sentinella $t7 al nodo successivo
 			move $t0, $t8	  # aggiorno indirizzo di $t0 dato che ho effettuato uno scambio
 			bnez $t2, loopInternoExec     # se $t2!=0, rieseguo il ciclo
 			j exitLoopInternoExec	#altrimenti esci dal ciclo
 
		exitLoopInternoExec:
		bnez $t1, loopEsternoExec    # se $t1!=0 allora rieseguo il ciclo interno (loop1)
	exitLoopEsternoExec:
	addi $t0, $zero, 1
	sw $t0, flagScheduling #flagScheduling=1 perchè la politica di scheduling adottata è per esecuzioni 
	jr $ra






#====================================================================================
#++--++--++--++--++--++--++ PROCEDURA PRINT TASK     ===============================
#====================================================================================

# PRINTALL
#  \_stampo la tablehead
#   \__ faccio un for da length a 0
#     \__ stampo i 20byte

 
 


printSingleTask: 
	la $a0, tableHead   # stampo la tablehead
	li $v0,4
	syscall 
	lw $t1, length      # carico la lunghezza della lista
	loopScorriLista:
 		addi $t1, $t1, -1   # inizializzo contatore $t1  a length-1
 		beqz $t1, noop  #se $t1==0 allora esco dal ciclo esterno, ho terminato la stampa

noop: #aspè, devo rivedere sui pdf delle cose..

	


#====================================================================================
#++--++--++--++--++--++--++  PROCEDURA PRINT MAIN MENU     ==========================
#====================================================================================
printMainMenu:

  	li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	
	la $a0 strLinea    
  	li $v0,4        
  	syscall 
  	li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	la $a0 item1    
  	li $v0,4        
  	syscall 
        li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	
	la $a0 item2    
  	li $v0,4        
  	syscall 
        li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall

        la $a0 item3   
  	li $v0,4        
  	syscall 
        li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall

	la $a0 item4  
  	li $v0,4       
  	syscall 
        li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	
	la $a0 item5    
  	li $v0,4        
  	syscall 
        li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall

	la $a0 item6    
  	li $v0,4        
  	syscall 
        li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall

	la $a0 item7   
  	li $v0,4        
  	syscall 
        li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	
	la $a0 strInserimento    
  	li $v0,4       
  	syscall 
	
	jr $ra
