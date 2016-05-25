.data 

length: .word 0
head: .word 0
tail: .word 0
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
strErrore: .asciiz "Opzione errata! "
strInserimento: .asciiz "Inserisci scelta: "
strLinea: .asciiz "-------------------------------------------------------"
strInsPolitica: .asciiz "Scegliere politica di scheduling (1->Priorità, 2->Esecuzioni): "
strInsPriorita: .asciiz "Inserisci Priorità (0->minima, 9->massima): "
strInsNome: .asciiz "Inserisci Nome (Max 8 caratteri): "
strInsExec: .asciiz "Inserisci numero di esecuzioni (1->minimo, 99->massimo): "
strIsEmpty: .asciiz "Errore! La lista è vuota"
tableHead: .asciiz "|  ID  |  PRIORITA'  |  NOME TASK  |  ESECUZ. RIMANENTI |"

 
 
#-----------------------------------------------
# STRUTTURA DI UN TASK (in byte)
# 4 byte = ID
# 4 byte = Priorita
# 4 byte = Esecuzioni rimanenti
# 4 byte = Indirizzo memoria del task successivo
# 8 byte = Nome del task
# TOTALE: 24 byte
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
        li $v0, 5		# legge intero digitato
	syscall
	move $t2, $v0   	# $t2 = opzione digitata
	
	# controllo validità della scelta 
	sle  $t0, $t2, $zero	# $t0=1 se scelta <= 0
	bne  $t0, $zero, choice_err # errore se $t0==1
	li   $t0, 7
	sle  $t0, $t2, $t0	#$t0=1 se scelta<=7
	beq  $t0, $zero, choice_err # errore se $t0==0

branch_case:
	# se arrivo qui l'opzione digitata era corretta
	addi $t2, $t2, -1 	# tolgo 1 da scelta perche' prima azione nella jump table (in posizione 0) corrisponde alla prima scelta del case
	add $t0, $t2, $t2
	add $t0, $t0, $t0 	# ho calcolato (scelta-1) * 4
	add $t0, $t0, $s0 	# sommo all'indirizzo base della JAT l'offset appena calcolato
	lw $t0, 0($t0)    	# $t0 = indirizzo a cui devo saltare

	jr $t0 		  	# salto all'indirizzo calcolato

case1: # Inserimento nuovo task
	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	jal insertTask		#richiama procedura per l'inserimento di un nuovo task
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, -8
	
	j loopMainMenu 		# ritorna alla richiesta di inserimento

case2: # Esecuzione prossimo task (in base alla politica di scheduling adottata, il prossimo task da eseguire è quello puntato da tail)
	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	lw $a0, tail		# prima carica in $a0 l'indirizzo dell'ultimo nodo	
	lw $a0, 0($a0)		# dopo carica in $a0 l'ID dell'ultimo nodo (executeTask richiede l'ID del task da eseguire)
	jal executeTask		#esegue il prossimo task
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, -8
	
	j loopMainMenu 		# ritorna alla richiesta di inserimento

case3: # Esecuzione specifico task"
	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	
	
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, -8 
	j loopMainMenu 		# ritorna alla richiesta di inserimento
	
case4: # Eliminazione specifico task
	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	
	
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, -8
	   
	j loopMainMenu 		# ritorna alla richiesta di inserimento
	
case5: # Modifica priorità di uno specifico task
	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	
	
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, -8
	j loopMainMenu 		# ritorna alla richiesta di inserimento
	
case6: # Cambia politica di scheduling

	# controllo se la lista è vuota
	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	jal isEmpty		#richiamo procedura isEmpty per verificare che la lista non sia vuota
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, -8
	
	beq $v0, $zero, return6	#se $v0==0 allora la lista è vuota, ritorno al menù principale
	
	loopSchedulingChoice:
	li $v0, 11		#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	li $v0, 4  
     	la $a0, strInsPolitica
      	syscall 
	# l'utente digita un'opzione	  
        li $v0, 5		# legge intero digitato
	syscall
	move $t2, $v0   	# $t2 = opzione digitata
	
	# controllo validità della scelta 
	sle  $t0, $t2, $zero	# $t0=1 se scelta <= 0
	bne  $t0, $zero, choice_err2 # errore se $t0==1
	li   $t0, 2
	sle  $t0, $t2, $t0	#$t0=1 se scelta<=2
	beq  $t0, $zero, choice_err2 # errore se $t0==0
	
	#se arrivo qui l'opzione digitata è corretta
	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	
	bne $t2, $zero, L1Sched	 #se $t2!=0 allora salto
	jal bubbleSortByPriority #eseguo un'ordinamento per priorità
	
	move $t2,$zero		
	sw $t2, flagScheduling	# variabile flag di scheduling = 0
	j L2Sched
	
	L1Sched:
	jal bubbleSortByExecutions #eseguo un'ordinamento per esecuzioni rimanenti
	addi $t2, $zero, 1	
	sw $t2, flagScheduling	# variabile flag di scheduling = 1
	
	L2Sched:
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, -8
	
	return6:
	j loopMainMenu 		# ritorna alla richiesta di inserimento
	  	  
case7: # Termina programma
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, -8
	jr $ra
	
choice_err: 
	li $v0, 11		#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	li $v0, 4		# stampa la stringa d'errore  
     	la $a0, strErrore 
      	syscall 
      	li $v0, 4  
     	la $a0, strInserimento
      	syscall 						  		  		  	  
      	j choice 		# ritorna alla richiesta di inserimento
	
choice_err2: 
	li $v0, 11		#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	li $v0, 4  		# stampa la stringa d'errore
     	la $a0, strErrore 
      	syscall 						  		  		  	  
      	j loopSchedulingChoice  # ritorna alla richiesta di inserimento	
	



#====================================================================================
#++--++--++--++--++--++-- PROCEDURA IS_EMPTY ========================================
#====================================================================================
isEmpty:
	lw $t0, length		#carico dimensione della lista
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
	li $v0, 9	# codice syscall SBRK
	li $a0, 24	# numero di byte da allocare
	syscall         # chiamata sbrk: restituisce un blocco di 24 byte, puntato da v0
	move $t1, $v0	#$t1 = $v0 = puntatore al record allocato
	#inserisco nodo alla coda
	lw $t8, head	#carico indirizzo del nodo iniziale
	lw $t9, tail	#carico indirizzo del nodo finale
	bne $t9, $zero, link_last #se tail!=0 allora non è il primo inserimento, salto per aggiungere in coda
	sw $t1, head	#aggiorno puntatore head e tail a $t1
	sw $t1, tail
	j jumpInsID

	link_last:      # se la coda e' non vuota, collega l'ultimo elemento della lista,
			# puntato da tail (t9) al nuovo record; dopodiche' modifica tail 
			# per farlo puntare al nuovo record
	sw $t1, 12($t9)  # il campo elemento successivo dell'ultimo record prende $t1
	sw $t1, tail    #aggiorno puntatore tail a $t1	
	
	jumpInsID:
	#inserisco campo ID autoincrementante
	lw $t2, contatoreID	#carico dalla memoria l'ID da assegnare
	sw $t2, 0($t1)	#salvo nel record il valore inserito
	addi $t1, $t1, 4	#incremento di 4 byte per puntare al prossimo "campo" del record
	addi $t2, $t2, 1	#incremento ID e salvo
	sw $t2, contatoreID
	
	jumpInput:	
	li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	lblInsPriorita:
	li $v0, 4  
     	la $a0, strInsPriorita
      	syscall 
      	 # l'utente digita un'opzione	  
        li $v0, 5		# legge intero digitato
	syscall
	move $t2, $v0   	# $t2 = opzione digitata
	
	# controllo validità della scelta 
	slt  $t0, $t2, $zero	# $t0=1 se scelta < 0
	bne  $t0, $zero, choice_err_priorita # errore se $t0==1
	li   $t0, 9
	sle  $t0, $t2, $t0	#$t0=1 se scelta<=9
	beq  $t0, $zero, choice_err_priorita # errore se $t0==0

	#se arrivo qui il numero digitato è corretto
	sw $t2, 0($t1)	#salvo nel record il valore inserito
	addi $t1, $t1, 4	#incremento di 4 byte per puntare al prossimo "campo" del record
	#--------------------------------------------------------------------------------
	li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	lblInsExec:
	li $v0, 4  
     	la $a0, strInsExec
      	syscall 
      	 # l'utente digita un'opzione	  
        li $v0, 5		# legge intero digitato
	syscall
	move $t2, $v0   	# $t2 = opzione digitata
	
	# controllo validità della scelta 
	sle  $t0, $t2, $zero	# $t0=1 se scelta <= 0
	bne  $t0, $zero, choice_err_exec # errore se $t0==1
	li   $t0, 99
	sle  $t0, $t2, $t0	#$t0=1 se scelta<=99
	beq  $t0, $zero, choice_err_exec # errore se $t0==0

	#se arrivo qui il numero digitato è corretto
	sw $t2, 0($t1)	#salvo nel record il valore inserito
	addi $t1, $t1, 4	#incremento di 4 byte per puntare al prossimo "campo" del record
	#------------------------------------------------------------------
	sw $zero, 0($t1)	#puntatore al campo successivo = 0 (non esiste ancora)
	addi $t1, $t1, 4	#incremento di 4 byte per puntare al prossimo "campo" del record
	
	#------------------------------------------------------------------
	li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	lblInsNome:
	li $v0, 4  
     	la $a0, strInsNome
      	syscall 
      	# l'utente digita una stringa
      	move $a0, $t1	#scrivo direttamente nel campo "nome" del record
      	li $a1, 8	#MAX 8 caratteri 
        li $v0, 8	# legge stringa digitata
	syscall
	#------------------------------------------------------------------
	
	#aggiorno length
	lw $t2, length
	addi $t2, $t2, 1
	sw $t2, length
	
	#richiamo politica di scheduling attuale
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	lw $t2, flagScheduling
	bne $t2, $zero, lbl1	#se $t2!=0 allora salto ed eseguo sort per esecuzioni
	jal bubbleSortByPriority #altrimenti eseguo sort per priorità
	j lbl2
	
	lbl1:
	jal bubbleSortByExecutions
	
	lbl2:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	


	choice_err_priorita: 	#gestisce errore di inserimento priorità sbagliata
	li $v0, 11		#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	li $v0, 4  		# stampa la stringa d'errore
     	la $a0, strErrore 
      	syscall 						  		  		  	  
      	j lblInsPriorita  	# ritorna alla richiesta di inserimento priorità	

	choice_err_exec: 	#gestisce errore di inserimento esecuzioni sbagliate
	li $v0, 11		#ritorno a capo (\n)
	addi $a0, $zero, 10		
	syscall
	li $v0, 4  		# stampa la stringa d'errore
     	la $a0, strErrore 
      	syscall 						  		  		  	  
      	j lblInsExec	# ritorna alla richiesta di inserimento esecuzioni rimanenti




#====================================================================================
#++--++--++--++--++--++-- PROCEDURA EXECUTE TASK =====================================
#====================================================================================
executeTask:
	addi $sp, $sp, -4	#non mi interessa preservare il contenuto di $a0, che verrà direttamente passato a searchTaskByID
	sw $ra, 0($sp)
	jal searchTaskByID	# cerca il task e ritorna in $v0 l'indirizzo del record
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	move $t0, $v0	#$t2 = indirizzo del task da eseguire
	
	lw $t1, 8($t0)	# $t1 = esecuzioni rimanenti
	addi $t1, $t1, -1 	#sottraggo 1 alle esecuzioni
	beqz $t1, remove	#se $t1==0 devo rimuovere il task
	sw $t1, 8($t0)	#altrimenti salvo il valore aggiornato
	j exitExecute
	
	remove:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	lw $a0, 0($t0)	# $a0 = ID del task da eliminare
	jal removeTask	#richiamo la removeTask per eliminare l'ultimo nodo che ha terminato l'esecuzione, riceve come argomento l'ID
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	exitExecute:
	jr $ra
	
	
	
	
	
#====================================================================================
#++--++--++--++--++--++-- PROCEDURA SERACH TASK BY ID================================
#====================================================================================	
searchTaskByID:
	move $t1, $a0	# $t1 = ID da cercare
	lw $t0, head	# $t0 = indirizzo del primo nodo, sarà usato per scorrere la lista
	
	loopSearch:
	lw $t2, 0($t0)	# $t2 = variabile d'appoggio per l'ID del nodo attuale
	beq $t2, $t1, exitSearch	#se $t2==$t1 ho trovato il task, esco dal ciclo
	lw $t0, 12($t0)	#altrimenti procedo al prossimo nodo









#====================================================================================
#++--++--++--++--++--++-- PROCEDURA REMOVE TASK =====================================
#====================================================================================










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
 			lw $t5, 4($t0)     	# $t5 = priorità del task il cui indirizzo è in $t0, salto 4 byte di offset (cfr. schema del record) 
 			move $t8, $t0		# $t8 = indirizzo del primo nodo (relativo a questa iterazione)
			lw $t0, 12($t0)         # $t0 = indirizzo del nodo successivo della lista, salto 12 byte di offset  
 			lw $t6, 4($t0)     	# $t6 = priorità del task il cui indirizzo è in $t0, salto 4 byte di offset
 			move $t9, $t0		# $t9 = indirizzo del secondo nodo (relativo a questa iterazione)
 		
			bgt $t5, $t6, loopInterno 	# se $t5>$t6 i due nodi sono ordinati in modo decrescente, rieseguo il ciclo
 			beq $t5, $t6, swapByID  # se le priorità sono uguali allora ordino per ID
 			
 			# i due nodi non sono ordinati
 			#gestisco caso tailSwap (ovvero modifico puntatore alla coda)
 			bnez $t2, ignoreTailSwap1  # se $t2==0 allora è l'ultima iterazione e sto modificando l'ultimo elemento, devo cambiare puntatore alla coda
 			sw $t8, tail
 			
 			ignoreTailSwap1:
 			beqz $t4, headSwap	  # se $t4==0 allora salta per gestire caso particolare
 			lw $t3, 12($t9)    # $t3 = D (ovvero C.next)
 			sw $t3, 12($t8)    # B.next = D (C.next)
 			sw $t8, 12($t9)    # C.next = B
 			sw $t9, 12($t7)    # A.next = C
 			lw $t7, 12($t7)  # aggiorno indirizzo sentinella $t7 al nodo successivo
 			move $t0, $t8	  # aggiorno indirizzo di $t0 dato che ho effettuato uno scambio
 			bnez $t2, loopInterno     # se $t2!=0, rieseguo il ciclo
 			j exitLoopInterno	#altrimenti esci dal ciclo
 			
 			headSwap:
 			lw $t3, 12($t9)    # $t3 = C (ovvero B.next)
 			sw $t3, 12($t8)    # A.next = C (ovvero B.next)
 			sw $t8, 12($t9)    # B.next = A
 			sw $t9, head      # head = B , ovvero B diventa la nuova head della lista
			lw $t7, head	  # aggiorno indirizzo sentinella $t7 al primo nodo della lista
			move $t0, $t8	  # aggiorno indirizzo di $t0 dato che ho effettuato uno scambio
			addi $t4, $zero, 1		  #modifico flag $t4
 			bnez $t2, loopInterno     # se $t2!=0, rieseguo il ciclo
 			j exitLoopInterno	#altrimenti esci dal ciclo

			
			swapByID:	#è necessario accedere ai campi ID dei due nodi e confrontarli tra loro
			lw $t5, 0($t0)     	# $t5 = ID del task il cui indirizzo è in $t0, salto 0 byte di offset (cfr. schema del record task in cima alla pagina) 
 			move $t8, $t0		# $t8 = indirizzo del primo nodo (relativo a questa iterazione)
			lw $t0, 12($t0)          # $t0 = indirizzo del nodo successivo della lista, salto 12 byte di offset  
 			lw $t6, 0($t0)     	# $t6 = ID del task il cui indirizzo è in $t0, salto 0 byte di offset
 			move $t9, $t0		# $t9 = indirizzo del secondo nodo (relativo a questa iterazione)
 			
			bge $t5, $t6, loopInterno 	# se $t5>=$t6 i due nodi sono ordinati in modo decrescente per ID, rieseguo il ciclo

			#i due nodi non sono ordinati
			beqz $t4, headSwap	  # se $t4==0 allora salta per gestire caso particolare
 			lw $t3, 12($t9)    # $t3 = D (ovvero C.next)
 			sw $t3, 12($t8)    # B.next = D (C.next)
 			sw $t8, 12($t9)    # C.next = B
 			sw $t9, 12($t7)    # A.next = C
 			lw $t7, 12($t7)  # aggiorno indirizzo sentinella $t7 al nodo successivo
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

bubbleSortByExecutions:
	lw $t1, length      # carico la lunghezza della lista
 	loopEsternoExec:
 		addi $t1, $t1, -1   # inizializzo contatore $t1 (ciclo esterno) a length-1
 		beqz $t1, exitLoopEsternoExec  #se $t1==0 allora esco dal ciclo esterno, ho terminato bubbleSort
 		move $t2,$t1	    # inizializzo contatore $t2 (ciclo interno) al valore di $t1
 		move $t4, $zero	    # $t4 = flag per primo caso 
		loopInternoExec:
			beqz $t2, exitLoopInternoExec     # se $t2==0 allora ho esaminato tutti gli elementi, quindi esco dal ciclo
			addi $t2,$t2,-1   	# decremento contatore $t2 (ciclo interno)
 			lw $t5, 8($t0)     	# $t5 = esecuzioni del task il cui indirizzo è in $t0, salto 8 byte di offset (cfr. schema del record task in cima alla pagina) 
 			move $t8, $t0		# $t8 = indirizzo del primo nodo (relativo a questa iterazione)
			lw $t0, 12($t0)         # $t0 = indirizzo del nodo successivo della lista, salto 12 byte di offset  
 			lw $t6, 8($t0)     	# $t6 = esecuzioni del task il cui indirizzo è in $t0, salto 8 byte di offset
 			move $t9, $t0		# $t9 = indirizzo del secondo nodo (relativo a questa iterazione)
 		
			blt $t5, $t6, loopInternoExec 	# se $t5<$t6 i due nodi sono ordinati in modo crescente, rieseguo il ciclo
 			beq $t5, $t6, swapByIDExec  # se le priorità sono uguali allora ordino per ID
 			
 			# i due nodi non sono ordinati
 			#gestisco caso tailSwap (ovvero modifico puntatore alla coda)
 			bnez $t2, ignoreTailSwap2  # se $t2==0 allora è l'ultima iterazione e sto modificando l'ultimo elemento, devo cambiare puntatore alla coda
 			sw $t8, tail
 			
 			ignoreTailSwap2:
 			beqz $t4, headSwapExec	  # se $t4==0 allora salta per gestire caso particolare
 			lw $t3, 12($t9)    # $t3 = D (ovvero C.next)
 			sw $t3, 12($t8)    # B.next = D (C.next)
 			sw $t8, 12($t9)    # C.next = B
 			sw $t9, 12($t7)    # A.next = C
 			lw $t7, 12($t7)  # aggiorno indirizzo sentinella $t7 al nodo successivo
 			move $t0, $t8	  # aggiorno indirizzo di $t0 dato che ho effettuato uno scambio
 			bnez $t2, loopInternoExec     # se $t2!=0, rieseguo il ciclo
 			j exitLoopInternoExec	#altrimenti esci dal ciclo
 			
 			headSwapExec:
 			lw $t3, 12($t9)    # $t3 = C (ovvero B.next)
 			sw $t3, 12($t8)    # A.next = C (ovvero B.next)
 			sw $t8, 12($t9)    # B.next = A
 			sw $t9, head      # head = B , ovvero B diventa la nuova head della lista
			lw $t7, head	  # aggiorno indirizzo sentinella $t7 al primo nodo della lista
			move $t0, $t8	  # aggiorno indirizzo di $t0 dato che ho effettuato uno scambio
			addi $t4, $zero, 1		  #modifico flag $t4
 			bnez $t2, loopInternoExec     # se $t2!=0, rieseguo il ciclo
 			j exitLoopInternoExec	#altrimenti esci dal ciclo

			
			swapByIDExec:	#è necessario accedere ai campi ID dei due nodi e confrontarli tra loro
			lw $t5, 0($t0)     	# $t5 = ID del task il cui indirizzo è in $t0, salto 0 byte di offset (cfr. schema del record task in cima alla pagina) 
 			move $t8, $t0		# $t8 = indirizzo del primo nodo (relativo a questa iterazione)
			lw $t0, 12($t0)          # $t0 = indirizzo del nodo successivo della lista, salto 12 byte di offset  
 			lw $t6, 0($t0)     	# $t6 = ID del task il cui indirizzo è in $t0, salto 0 byte di offset
 			move $t9, $t0		# $t9 = indirizzo del secondo nodo (relativo a questa iterazione)
 			
			bge $t5, $t6, loopInternoExec 	# se $t5>=$t6 i due nodi sono ordinati in modo decrescente per ID, rieseguo il ciclo

			#i due nodi non sono ordinati
			beqz $t4, headSwapExec	  # se $t4==0 allora salta per gestire caso particolare
 			lw $t3, 12($t9)    # $t3 = D (ovvero C.next)
 			sw $t3, 12($t8)    # B.next = D (C.next)
 			sw $t8, 12($t9)    # C.next = B
 			sw $t9, 12($t7)    # A.next = C
 			lw $t7, 12($t7)  # aggiorno indirizzo sentinella $t7 al nodo successivo
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
	#REGISTRI USATI
	# $t2 : indica il numero di elementi rimanenti
	# $t3 : indica il numero di byte da leggere per ogni task
	# $t1 : indica il task corrente
	
	la $a0, tableHead   # stampo la tablehead
	li $v0,4
	syscall 
	lw $t2, length      # carico la lunghezza della lista
	lw $t1,head         # metto in t1 la testa della coda
	lw $t3,24
	loopScorriLista:
                blez  $t3, caricasuccessivo  #se $t1<=0 allora carico il successivo
 		la $a0, $t1     # stampo l'elemento # del record
		li $v0,4	# chiamo la syscall con il 4 per fare una printf
		syscall  
		addi $t1, $t1, 4	#incremento di 4 byte per puntare al prossimo "campo" del record		
		addi $t3, $t3, -4   #decremento il contatore di 4 byte
		bgtz $t3, loopScorriLista #se è maggiore, vuol dire che ho ancora roba da stampare, e torno su
	caricasuccessivo:
		lw $t1, 12($t1)
		addi $t2,$t2, -1 #decremento gli elementi rimanenti
		lw $t3,24        #ri-inizializzo il numero di byte da leggere
		#if t1!=null loopscorrilista else go out
	


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
