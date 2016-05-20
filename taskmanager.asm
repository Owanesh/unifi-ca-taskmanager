.data 

length: .word 0
head: .word 0
flagScheduling: .byte 0
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
#++--++--++--++--++--++--++   MAIN PROCEDURE ========================================
#====================================================================================

main:  
# prepara la jump_table con gli indirizzi delle case actions
	la $t1, jump_table
	la $t0, case1  
	sw $t0, 0($t1)
 	la $t0, case2  
	sw $t0, 4($t1)
	la $t0, case3	  
	sw $t0, 8($t1)	  
	la $t0, case4	  
	sw $t0, 12($t1)
	la $t0, case5	  
	sw $t0, 16($t1)
	la $t0, case6	  
	sw $t0, 20($t1)
	la $t0, case7	  
	sw $t0, 24($t1)

loopMainMenu:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal printMainMenu	#stampo il menù principale
	lw $ra, 0($sp)
	addi $sp, $sp, 4
choice:
        # l'utente digita un'opzione	  
        li $v0, 5		# legge intero digitato
	syscall
	move $t2, $v0   	# $t1 = opzione digitata
	
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
	add $t0, $t0, $t1 # sommo all'indirizzo base della JAT l'offset appena calcolato
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
	lw $t0, flagScheduling   #carico variabile flag, indica quale scehl	
	beq 
	j loopMainMenu # ritorna alla richiesta di inserimento
	  	  
case7: # Termina programma
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
choice_err: 
	# stampa la stringa d'errore
	li $v0, 4  
     	la $a0, strErrore 
      	syscall 						  		  		  	  
      	j choice # ritorna alla richiesta di inserimento
		
	





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
 			

		exitLoopInterno:
		bnez $t1, loopEsterno    # se $t1!=0 allora rieseguo il ciclo interno (loop1)
	exitLoopEsterno:


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
 			beqz $t4, L1	  # se $t4==0 allora salta per gestire caso particolare
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







#====================================================================================
#++--++--++--++--++--++--++   PRINT TASK PROCEDURE    ===============================
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
#++--++--++--++--++--++--++   PRINT MAIN MENU PROCEDURE    ==========================
#====================================================================================
printMainMenu:

  	li $v0, 11	#stampo un ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	
	la $a0 item1    # Nell'indirizzo a0 ci carico la stringa "Inserisci un nuovo task"
  	li $v0,4        # Caricare in un registro, un valore costante, lo stesso valore che corrisponde ad una funzione che verrà poi eseguita con la chiamata successiva
  	syscall 
        li $v0, 11	#stampo un ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	
	la $a0 item2    # Nell'indirizzo a0 ci carico la stringa "Eseguire il task in testa alla coda"
  	li $v0,4        # Caricare in un registro, un valore costante, lo stesso valore che corrisponde ad una funzione che verrà poi eseguita con la chiamata successiva
  	syscall 
        li $v0, 11	#stampo un ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall

        la $a0 item3    # Nell'indirizzo a0 ci carico la stringa "Esegui uno specifico task"
  	li $v0,4        # Caricare in un registro, un valore costante, lo stesso valore che corrisponde ad una funzione che verrà poi eseguita con la chiamata successiva
  	syscall 
        li $v0, 11	#stampo un ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall

	la $a0 item4    # Nell'indirizzo a0 ci carico la stringa "Elimina uno specifico task"
  	li $v0,4        # Caricare in un registro, un valore costante, lo stesso valore che corrisponde ad una funzione che verrà poi eseguita con la chiamata successiva
  	syscall 
        li $v0, 11	#stampo un ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	
	la $a0 item5    # Nell'indirizzo a0 ci carico la stringa "Modifica priorita di uno specifico task"
  	li $v0,4        # Caricare in un registro, un valore costante, lo stesso valore che corrisponde ad una funzione che verrà poi eseguita con la chiamata successiva
  	syscall 
        li $v0, 11	#stampo un ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall

	la $a0 item6    # Nell'indirizzo a0 ci carico la stringa "Cambia politica di scheduling"
  	li $v0,4        # Caricare in un registro, un valore costante, lo stesso valore che corrisponde ad una funzione che verrà poi eseguita con la chiamata successiva
  	syscall 
        li $v0, 11	#stampo un ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall

	la $a0 item7    # Nell'indirizzo a0 ci carico la stringa "Esci dal programma"
  	li $v0,4        # Caricare in un registro, un valore costante, lo stesso valore che corrisponde ad una funzione che verrà poi eseguita con la chiamata successiva
  	syscall 
        li $v0, 11	#stampo un ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	
	la $a0 strInserimento    # Nell'indirizzo a0 ci carico la stringa "Esci dal programma"
  	li $v0,4        # Caricare in un registro, un valore costante, lo stesso valore che corrisponde ad una funzione che verrà poi eseguita con la chiamata successiva
  	syscall 
	jr $ra