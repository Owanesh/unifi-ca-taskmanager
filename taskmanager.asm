#Mauro Matteo - matteo.mauro@stud.unifi.it
#Busiello Salvatore - salvatore.busiello@stud.unifi.it
#Milicia Lorenzo - lorenzo.milicia1@stud.unifi.it


.data

length: .word 0
head: .word 0
tail: .word 0
contatoreID: .word 1
flagScheduling: .word 0		#default==0 (scheduling per priorità)
jump_table: .space 28 # jump table a 7 word, corrispondenti alle 7 scelte del menù
item1: .asciiz "1) Inserire un nuovo task\n 2) Eseguire il task in testa alla coda"
item2: .asciiz ""
item3: .asciiz "3) Esegui uno specifico task"
item4: .asciiz "4) Elimina uno specifico task"
item5: .asciiz "5) Modifica priorita di uno specifico task"
item6: .asciiz "6) Cambia politica di scheduling"
item7: .asciiz "7) Esci dal programma"
spaceTab: .asciiz "   "
strErrore: .asciiz "Opzione errata! "
strErroreID: .asciiz "Opzione errata! L'ID deve essere maggiore di 0."
strTaskNotFound: .asciiz "Errore: Task inesistente."
strEmptyList: .asciiz "La lista è vuota."
strInserimento: .asciiz "Inserisci scelta: "
strInsID: .asciiz "Inserisci ID del task: "
strLinea: .asciiz "-------------------------------------------------------"
strInsPolitica: .asciiz "Scegliere politica di scheduling (1->Priorità, 2->Esecuzioni): "
strInsPriorita: .asciiz "Inserisci Priorità (0->minima, 9->massima): "
strInsNome: .asciiz "Inserisci Nome (Max 8 caratteri): "
strInsExec: .asciiz "Inserisci numero di esecuzioni (1->minimo, 99->massimo): "
strIsEmpty: .asciiz "Errore! La lista è vuota"
tableHead: .asciiz "|   ID   | PRIORITA'  | NOME TASK | ESECUZ. RIMANENTI |"



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
	addi $t2, $t2, -1 	# tolgo 1 da scelta perche' prima azione nella jump table (in posizione 0)
				# corrisponde alla prima scelta del case
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
	addi $sp,$sp, 8

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal printTasks	#stampo l'elenco dei task all'interno della lista
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	j loopMainMenu 		# ritorna alla richiesta di inserimento

case2:  # Esecuzione prossimo task (in base alla politica di scheduling adottata,
	# il prossimo task da eseguire è quello puntato da tail)
	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	jal isEmpty	# se la lista è vuota posso direttamente uscire
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, 8
	beqz $v0, lblExitCase2	# se $v0==0 allora la lista è vuota e termino la procedura

	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	lw $a0, tail		# prima carica in $a0 l'indirizzo dell'ultimo nodo
	lw $a0, 0($a0)		# dopo carica in $a0 l'ID dell'ultimo nodo (executeTask richiede l'ID del task da eseguire)
	jal executeTask		#esegue il prossimo task
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, 8

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal printTasks	#stampo l'elenco dei task all'interno della lista
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	lblExitCase2:
	j loopMainMenu 		# ritorna alla richiesta di inserimento

case3: # Esecuzione specifico task
	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	jal isEmpty	# se la lista è vuota posso direttamente uscire
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, 8
	beqz $v0, lblExitCase3	# se $v0==0 allora la lista è vuota e termino la procedura

	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	jal getID	#richiedo ID all'utente, che sarà salvato in $v0
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, 8

	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	move $a0, $v0	# $a0 = ID del task da eseguire (digitato da utente e ritornato con $v0)
	jal executeTask
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, 8

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal printTasks	#stampo l'elenco dei task all'interno della lista
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	lblExitCase3:
	j loopMainMenu 		# ritorna alla richiesta di inserimento

case4: # Eliminazione specifico task
	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	jal isEmpty	# se la lista è vuota posso direttamente uscire
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, 8
	beqz $v0, lblExitCase4	# se $v0==0 allora la lista è vuota e termino la procedura

	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	jal getID	#richiedo ID all'utente, che sarà salvato in $v0
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, 8

	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	move $a0, $v0
	jal removeTask	#rimuovo il task il cui ID è specificato in $a0
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, 8

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal printTasks	#stampo l'elenco dei task all'interno della lista
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	lblExitCase4:
	j loopMainMenu 		# ritorna alla richiesta di inserimento

case5: # Modifica priorità di uno specifico task
	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	jal isEmpty	# se la lista è vuota posso direttamente uscire
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, 8
	beqz $v0, lblExitCase5	# se $v0==0 allora la lista è vuota e termino la procedura


	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	jal getID	#richiedo ID all'utente, che sarà salvato in $v0
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, 8

	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	move $a0, $v0	# $a0 = ID digitato dall'utente
	jal changePriority
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, 8

	#richiamo politica di scheduling attuale
	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	lw $t2, flagScheduling
	bne $t2, $zero, lbl8	#se $t2!=0 allora salto ed eseguo sort per esecuzioni
	jal sortByPriority #altrimenti eseguo sort per priorità
	j lbl9

	lbl8:
	jal sortByExec

	lbl9:
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, 8

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal printTasks	#stampo l'elenco dei task all'interno della lista
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	lblExitCase5:
	j loopMainMenu 		# ritorna alla richiesta di inserimento

case6: # Cambia politica di scheduling

	# controllo se la lista è vuota
	addi $sp,$sp, -8	#salvo $t1 (indirizzo base JAT) e $ra
	sw $t1, 0($sp)
	sw $ra, 4($sp)
	jal isEmpty		#richiamo procedura isEmpty per verificare che la lista non sia vuota
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, 8
	beqz $v0, lblExitCase6	#se $v0==0 allora la lista è vuota, ritorno al menù principale

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

	addi $t2, $t2, -1
	bne $t2, $zero, L1Sched	 #se $t2!=0 allora salto
	jal sortByPriority #eseguo un'ordinamento per priorità

	move $t2,$zero
	sw $t2, flagScheduling	# variabile flag di scheduling = 0
	j L2Sched

	L1Sched:
	jal sortByExec #eseguo un'ordinamento per esecuzioni rimanenti
	li $t2, 1
	sw $t2, flagScheduling	# variabile flag di scheduling = 1

	L2Sched:
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, 8

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal printTasks	#stampo l'elenco dei task all'interno della lista
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	lblExitCase6:
	j loopMainMenu 		# ritorna alla richiesta di inserimento

case7: # Termina programma
	lw $ra, 4($sp)
	lw $t1, 0($sp)
	addi $sp,$sp, 8
	jr $ra
#-----------------------------------------------------------------------------
#etichette per la gestione degli errori di input da parte dell'utente
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
#++--++--++--++--++--++-- PROCEDURA GET_ID ==========================================
#====================================================================================
getID:
	loopGetID:
	#richiesta inserimento ID
	li $v0, 4
	la $a0, strInsID
	syscall
        li $v0, 5		# legge intero digitato
	syscall
	move $t2, $v0   	# $t2 = opzione digitata

	# controllo validità della scelta (deve essere scelta>0 )
	sle  $t0, $t2, $zero	# $t0=1 se scelta <= 0
	bne  $t0, $zero, choice_err_getID # errore se $t0==1

	#se arrivo qua la scelta è corretta
	move $v0, $t2
	jr $ra

	choice_err_getID:
	li $v0, 11		#ritorno a capo (\n)
	addi $a0, $zero, 10
	syscall
	li $v0, 4  		# stampa la stringa d'errore
     	la $a0, strErroreID
      	syscall
      	j loopGetID  # ritorna alla richiesta di inserimento ID



#====================================================================================
#++--++--++--++--++--++-- PROCEDURA IS_EMPTY ========================================
#====================================================================================
isEmpty:
	lw $t0, length		#carico dimensione della lista
	beq $t0, $zero, return0	#se $t0!=0 allora ritorno 1, cioè la lista non è vuota, altrimenti salto e ritorno 0
	li $v0, 1
	j exitIsEmpty

	return0:
	# stampa la stringa d'errore
	li $v0, 11	#ritorno a capo (\n)
	li $a0, 10
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
      	li $a1, 9	#MAX 8 caratteri
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
	jal sortByPriority #altrimenti eseguo sort per priorità
	j lbl2

	lbl1:
	jal sortByExec

	lbl2:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


#-----------------------------------------------------------------------------
#etichette per la gestione degli errori di input da parte dell'utente

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
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	jal isEmpty	# se la lista è vuota posso direttamente uscire
	lw $a0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	beqz $v0, exitExecute	# se $v0==0 allora la lista è vuota e termino la procedura

	addi $sp, $sp, -4	# $a0 possiede già l'argomento di searchTaskByID,
				# inoltre non mi interessa più preservarne il contenuto
	sw $ra, 0($sp)
	jal searchTaskByID	# cerca il task e ritorna in $v0 l'indirizzo del record
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	li $t2, -1
	beq $t2, $v0, exitExecute	#se $v0==-1 allora il task non è stato trovato, esco direttamente

	move $t0, $v0	#$t0 = indirizzo del task da eseguire

	lw $t1, 8($t0)	# $t1 = esecuzioni rimanenti
	addi $t1, $t1, -1 	#sottraggo 1 alle esecuzioni
	beqz $t1, remove	#se $t1==0 devo rimuovere il task
	sw $t1, 8($t0)	#altrimenti salvo il valore aggiornato
	j exitExecute

	remove:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	lw $a0, 0($t0)	# $a0 = ID del task da eliminare
	jal removeTask	# richiamo la removeTask per eliminare l'ultimo nodo che ha 
		        # terminato l'esecuzione, riceve come argomento l'ID
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	exitExecute:
	jr $ra





#====================================================================================
#++--++--++--++--++--++-- PROCEDURA SEARCH TASK BY ID ===============================
#====================================================================================
# input: a0-> ID da cercare
# output: v0-> indirizzo del task se trovato, altrimenti -1
#CASI PARTICOLARI: primo nodo -> v0=head, v1= head
#		   n° nodo -> v0= n° nodo, v1= (n-1)° nodo
#		   ultimo nodo -> v0=tail, v1= tail.prev
searchTaskByID:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	jal isEmpty	# se la lista è vuota posso direttamente uscire
	lw $a0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	beqz $v0, lblExit	# se $v0==0 allora la lista è vuota e termino la procedura

	move $t1, $a0	# $t1 = ID da cercare
	lw $t0, head	# $t0 = indirizzo del primo nodo, sarà usato come appoggio per scorrere la lista
	li $v0, -1	# $v0 = inizializzo variabile di ritorno a -1, se il task verrà
			# individuato allora sarà modificato nel corso della ricerca
	move $t3, $t0	# $t3 = conterrà l'indirizzo del nodo precedente

	loopSearch:
	beqz $t0, exitSearch	# se $t0==0 allora il puntatore è nullo, ho raggiunto la fine della lista ed esco
	lw $t2, 0($t0)	# $t2 = variabile d'appoggio per l'ID del nodo attuale
	beq $t2, $t1, returnRst	#se $t2==$t1 ho trovato il task, esco dal ciclo
	move $t3, $t0	#$t3 = nodo precedente
	lw $t0, 12($t0)	#altrimenti procedo al prossimo nodo e rieseguo il ciclo
	j loopSearch

	returnRst:
	move $v0, $t0	# $v0 = indirizzo del task trovato (salvato in $t0)
	move $v1, $t3	# $v1 = indirizzo del nodo precedente (utile nel caso di remove)
	jr $ra

	exitSearch:
	li $v0, 4
	la $a0, strTaskNotFound	# stampo messaggio d'errrore
	syscall
	li $v0, 11	#ritorno a capo (\n)
	li $a0, 10
	syscall
	li $v0, -1	# ritorno -1
	lblExit:
	jr $ra






#====================================================================================
#++--++--++--++--++--++-- PROCEDURA REMOVE TASK =====================================
#====================================================================================
#L'eliminazione prevede di modificare il puntatore "prossimo nodo" del task precedente a quello da eliminare

removeTask:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	jal isEmpty	# se la lista è vuota posso direttamente uscire
	lw $a0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	beqz $v0, exitRemove	# se $v0==0 allora la lista è vuota e termino la procedura

	addi $sp, $sp, -4	#non mi interessa preservare il contenuto di $a0, che verrà direttamente passato a searchTaskByID
	sw $ra, 0($sp)
	jal searchTaskByID	# cerca il task e ritorna: $v0 -> indirizzo del record, $v1 -> indirizzo del nodo precedente
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	li $t2, -1
	beq $t2, $v0, exitRemove	#se $v0==-1 allora il task non è stato trovato, esco direttamente

	move $t0, $v0	#$t0 = indirizzo del task da rimuovere
	move $t1, $v1	#$t1 = indirizzo del task precedente
	#gestisco i 3 casi possibili: eliminazione head, tail e generico nodo
	lw $t3, head	#carico indirizzo primo nodo
	lw $t3, 0($t3)	#carico ID del primo nodo
	lw $t4, 0($t0)	#carico ID del nodo da rimuovere
	beq $t4, $t3, removeHead	# se $t4==$t3 allora devo eliminare il primo nodo, salto a removeHead
	lw $t3, tail	#carico indirizzo ultimo nodo
	lw $t3, 0($t3)	#carico ID ultimo nodo
	beq $t4, $t3, removeTail	# altrimenti se $t4==$t3 allora devo eliminare l'ultimo nodo, salto a removeTail

	# per esclusione devo rimuovere un generico nodo
	lw $t4, 12($t0)	# $t4 = indirizzo del nodo successivo a quello da eliminare
	sw $t4, 12($t1) # sovrascrivo il campo "nodo successivo" del precedente
			# ho così eliminato logicamente il riferimento al nodo da eliminare
	lw $t4, length
	addi $t4, $t4, -1	#decremento la lunghezza della lista
	sw $t4, length
	j exitRemove

	removeHead:
	lw $t4, 12($t0)	# ottengo indirizzo del 2° nodo della lista
	sw $t4, head	# aggiorno l'indirizzo salvato in head
	lw $t4, length
	addi $t4, $t4, -1	#decremento la lunghezza della lista
	sw $t4, length
	j exitRemove

	removeTail:
	sw $zero, 12($t1)	# aggiorno a NULL (zero) il campo "nodo successivo" del penultimo task
	sw $t1, tail	# aggiorno l'indirizzo salvato in tail
	lw $t4, length
	addi $t4, $t4, -1	#decremento la lunghezza della lista
	sw $t4, length

	exitRemove:
	lw $t4, length
	bnez $t4, exitRemove2
	sw $zero, head
	sw $zero, tail
	exitRemove2:
	jr $ra

#====================================================================================
#++--++--++--++--++--++-- PROCEDURA CHANGE PRIORITY =================================
#====================================================================================
# riceve in $a0 l'ID inserito dall'utente
changePriority:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	jal isEmpty	# se la lista è vuota posso direttamente uscire
	lw $a0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	beqz $v0, exitChangePriority	# se $v0==0 allora la lista è vuota e termino la procedura

	addi $sp, $sp, -4	#non mi interessa preservare il contenuto di $a0, che verrà direttamente passato a searchTaskByID
	sw $ra, 0($sp)
	jal searchTaskByID	# cerca il task e ritorna: $v0 -> indirizzo del record
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	li $t2, -1
	beq $t2, $v0, exitChangePriority	#se $v0==-1 allora il task non è stato trovato, esco direttamente
	move $t1, $v0	# $t1 = indirizzo del task

	loopInsPriorita:
	li $v0, 11		#ritorno a capo (\n)
	addi $a0, $zero, 10
	syscall
	li $v0, 4
     	la $a0, strInsPriorita
      	syscall
      	 # l'utente digita un'opzione
        li $v0, 5		# legge intero digitato
	syscall
	move $t2, $v0   	# $t2 = opzione digitata

	# controllo validità della scelta
	slt  $t0, $t2, $zero	# $t0=1 se scelta < 0
	bne  $t0, $zero, choice_change_priorita # errore se $t0==1
	li   $t0, 9
	sle  $t0, $t2, $t0	#$t0=1 se scelta<=9
	beq  $t0, $zero, choice_change_priorita # errore se $t0==0

	#se arrivo qui il numero digitato è corretto
	sw $t2, 4($t1)	#salvo nel record il valore inserito
	
	exitChangePriority:
	jr $ra

	choice_change_priorita: 	#gestisce errore di inserimento priorità sbagliata
	li $v0, 11		#ritorno a capo (\n)
	addi $a0, $zero, 10
	syscall
	li $v0, 4  		# stampa la stringa d'errore
     	la $a0, strErrore
      	syscall
      	j loopInsPriorita  	# ritorna alla richiesta di inserimento priorità

#====================================================================================
#++--++--   PROCEDURA DI ORDINAMENTO PER PRIOIRTA' ===================
#====================================================================================
# $t0 = scorre la lista
# $t1 = contatore ciclo esterno
# $t2 = contatore ciclo interno
# $t3 = 10 (usato come confronto iniziale per la priorità)
# $t4 = indirizzo del task con priorità minore ad ogni iterazione (sarà il task che verrà spostato)
# $t5 = appoggio per priorità nodo da confrontare nel ciclo interno
# $t6 = appoggio generico
# $t7 = precedente di $t0 ad ogni iterazione
# $t8 = precedente di $t4 (necessario per eseguire lo scambio
# $t9 = flag per gestire primo scambio (necessario per aggiornare puntatore tail)
# $s0 = appoggio per ID del nodo da confrontare nel ciclo interno (necessario se le priorità sono uguali)
# $s1 = ID del task minimo trovato (ovvero $t4), necessario per verificare durante lo swap se stiamo spostando head
# $s2 = Indirizzo dell'ultimo task che è stato posizionato

sortByPriority:
	addi $sp, $sp, -12	# in seguito sono usati s0 e s1, li salvo nello stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	move $t9, $zero	# $t9 = flag per gestire primo scambio (necessario per aggiornare puntatore tail)
	lw $t1, length      # carico la lunghezza della lista

	loopSort:
		li $t3, 10	# $t3 = registro di appoggio per priorità più grande
		lw $t4, head	# $t4 = registro di appoggio per l'indirizzo del task con priorità più grande
		lw $t0, head	#$t0 = indirizzo del primo nodo, verrà usato per scorrere la lista
		lw $t7, head
		addi $t1, $t1, -1	#decremento il contatore del ciclo esterno
		blez $t1, exitSortByPriority	#se $t1<=0 allora ho terminato il sort
		move $t2, $t1	#$t2 = contatore ciclo find
		#prima trovo il minimo
		loopFind:
			lw $t5, 4($t0)     	# $t5 = priorità del task il cui indirizzo è in $t0,
						# salto 4 byte di offset (cfr. schema del record)
 			bgt $t5, $t3, jumpLoopFind1     # se $t5>$t3 allora proseguo al prossimo nodo
 							# (mantengo il task con la priorità minima per metterlo in fondo)
 			bne $t5, $t3, set
 			#qui devo controllare gli ID prima di decidere se settare il task corrente come minimo
 			lw $s0, 0($t0)	# $s0=ID task appena letto
 			lw $t6, 0($t4)	# $t6 = ID task minimo
 			bge $s0, $t6, jumpLoopFind1	# se il nuovo task ha un ID maggiore o 
 							# uguale del task in $t4 allora non cambio niente
 			set:
 			move $t3, $t5	# altrimenti ho trovato un nuovo minimo, salvo il valore della priorità
 			lw $s1, 0($t0)	# salvo in $s1 l'ID del task minimo,
 			move $t4, $t0	# l'indirizzo di tale task
 			move $t8, $t7	# e del suo precedente

 			jumpLoopFind1:
 			move $t7, $t0
 			blez $t2, exitLoopFind	#se $t2<=0 allora ho terminato la ricerca e posso uscire
 			lw $t0, 12($t0)	# procedo al prossimo nodo
 			addi $t2, $t2, -1	#decremento il contatore del ciclo interno di ricerca
 			j loopFind

		exitLoopFind:

	# arrivato qui ho in $t4 il task da posizionare in fondo
	# ma devo capire se sto cambiando di posto a head o tail
	bne $zero, $t9, jumpSwapHead	# $t9 (flag) != 0 posso saltare
	# altrimento sto inserendo il task in fondo quindi devo modificare il puntatore di tail
	sw $t4, tail
	li $t9, 1	#modifico valore di flag a 1, così non torna più qui

	jumpSwapHead:
	lw $t6, head
	lw $t6, 0($t6)	# ho caricato in $t6 l'ID del primo task
	bne $s1, $t6, jumpSwap	# se l'ID del task minimo e l'ID di head sono diversi allora salto
	# altrimento sto scambiando proprio head quindi devo modificare il puntatore di head
	lw $t6, head
	lw $t6, 12($t6)	# ho caricato in $t6 l'indirizzo del 2° nodo della lista
	sw $t6, head	# head diventa il 2° nodo della lista
	lw $t6, 12($t0)
	sw $t6, 12($t4)
	sw $t4, 12($t0)
	j loopSort

	jumpSwap:
	lw $t6, 12($t4)
	beqz $t6,jumpIgnore #Se è uguale a zero il successivo, vuol dire che il minimo trovato è il minimo assoluto,
	# e quindi corrisponde anche al tail, è già in posizione, non ho bisogno di fare swap
	beq $t6,$s2, jumpIgnore #Se il successivo, è l'ultimo elemento già posizionato, allora anche l'elemento corrente è nella
	#sua posizione ideale
	sw $t6, 12($t8)
	lw $t6, 12($t0)
	sw $t6, 12($t4)
	sw $t4, 12($t0)
	jumpIgnore:
	add $s2,$zero,$t4 #salvo in $s2 l'ultimo elemento che ha subito lo swap
	j loopSort




exitSortByPriority:
	sw $zero, flagScheduling	#aggiorno flagScheduling con politica attuale
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)

	addi $sp, $sp, 12

	jr $ra
#====================================================================================
#++--++--   PROCEDURA DI ORDINAMENTO PER ESECUZIONI ===================
#====================================================================================
sortByExec:
	addi $sp, $sp, -12	# in seguito sono usati s0 e s1, li salvo nello stack

	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	move $t9, $zero	# $t9 = flag per gestire primo scambio (necessario per aggiornare puntatore tail)
	lw $t1, length      # carico la lunghezza della lista

	loopSortExec:
		li $t3, 0	# $t3 = registro di appoggio per priorità più grande
		lw $t4, head	# $t4 = registro di appoggio per l'indirizzo del task con priorità più grande
		lw $t0, head	#$t0 = indirizzo del primo nodo, verrà usato per scorrere la lista
		lw $t7, head
		addi $t1, $t1, -1	#decremento il contatore del ciclo esterno
		blez $t1, exitSortByExec	#se $t1<=0 allora ho terminato il sort
		move $t2, $t1	#$t2 = contatore ciclo find
		#prima trovo il minimo
		loopFindExec:
			lw $t5, 8($t0)     	# $t5 = priorità del task il cui indirizzo è in $t0,
						# salto 4 byte di offset (cfr. schema del record)
 			blt $t5, $t3, jumpLoopFind1Exec  # se $t5>$t3 allora proseguo al prossimo nodo
 							 # (mantengo il task con la priorità minima per metterlo in fondo)
 			bne $t5, $t3, setExec
 			#qui devo controllare gli ID prima di decidere se settare il task corrente come minimo
 			lw $s0, 0($t0)	# $s0=ID task appena letto
 			lw $t6, 0($t4)	# $t6 = ID task minimo
 			bge $s0, $t6, jumpLoopFind1Exec	#se il nuovo task ha un ID maggiore 
 							# o uguale del task in $t4 allora non cambio niente
 			setExec:
 			move $t3, $t5	# altrimenti ho trovato un nuovo minimo, salvo il valore della priorità
 			lw $s1, 0($t0)	# salvo in $s1 l'ID del task minimo,
 			move $t4, $t0	# l'indirizzo di tale task
 			move $t8, $t7	# e del suo precedente
 			jumpLoopFind1Exec:
 			move $t7, $t0
 			blez $t2, exitLoopFindExec	#se $t2<=0 allora ho terminato la ricerca e posso uscire
 			lw $t0, 12($t0)	# procedo al prossimo nodo
 			addi $t2, $t2, -1	#decremento il contatore del ciclo interno di ricerca
 			j loopFindExec
		exitLoopFindExec:
	# arrivato qui ho in $t4 il task da posizionare in fondo
	# ma devo capire se sto cambiando di posto a head o tail
	bne $zero, $t9, jumpSwapHeadExec	# $t9 (flag) != 0 posso saltare
	# altrimento sto inserendo il task in fondo quindi devo modificare il puntatore di tail
	sw $t4, tail
	li $t9, 1	#modifico valore di flag a 1, così non torna più qui

	jumpSwapHeadExec:
	lw $t6, head
	lw $t6, 0($t6)	# ho caricato in $t6 l'ID del primo task
	bne $s1, $t6, jumpSwapExec	# se l'ID del task minimo e l'ID di head sono diversi allora salto
	# altrimento sto scambiando proprio head quindi devo modificare il puntatore di head
	lw $t6, head
	lw $t6, 12($t6)	# ho caricato in $t6 l'indirizzo del 2° nodo della lista
	sw $t6, head	# head diventa il 2° nodo della lista
	lw $t6, 12($t0)
	sw $t6, 12($t4)
	sw $t4, 12($t0)
	j loopSortExec

	jumpSwapExec:
	lw $t6, 12($t4)
	beqz $t6,jumpIgnoreExec
	beq $t6,$s2, jumpIgnoreExec
	sw $t6, 12($t8)
	lw $t6, 12($t0)
	sw $t6, 12($t4)
	sw $t4, 12($t0)
	jumpIgnoreExec:
	add $s2,$zero,$t4
	j loopSortExec


exitSortByExec:
	li $t6, 1
	sw $t6, flagScheduling	#aggiorno flagScheduling con politica attuale
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)

	addi $sp, $sp, 12

	jr $ra

#====================================================================================
#++--++--++--++--++--++--++ PROCEDURA PRINT TASKS     ===============================
#====================================================================================

printTasks:
	li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10
	syscall
	la $a0, tableHead   # stampo la tablehead
	li $v0,4
	syscall
	li $v0, 11	#ritorno a capo (\n)
	addi $a0, $zero, 10
	syscall

	lw $t0, head	# $t0 = indirizzo del primo nodo della lista
	lw $t1, length      # carico la lunghezza della lista
	bnez $t1, loopPrint
	la $a0, strEmptyList   # stampo messaggio "la lista è vuota"
	li $v0,4
	syscall

	loopPrint:
		beqz $t1, exitPrint	# se $t1==0 allora esco dal ciclo
 		addi $t1, $t1, -1   # inizializzo contatore $t1  a length-1

		li $v0, 11	#stampo '|'
		li $a0, 124
		syscall
	la $a0 spaceTab
  	li $v0,4
  	syscall
		lw $t2, 0($t0)	# carico l'ID (offset 0)
		li $v0, 1	# e stampo il valore
		move $a0, $t2
		syscall
		la $a0 spaceTab
  	li $v0,4
  	syscall
		li $v0, 11	#stampo '|'
		li $a0, 124
		syscall
la $a0 spaceTab
  	li $v0,4
  	syscall
		lw $t2, 4($t0)	# carico la priorità (offset 4)
		li $v0, 1	# e stampo il valore
		move $a0, $t2
		syscall
		la $a0 spaceTab
  	li $v0,4
  	syscall
		li $v0, 11	#stampo '|'
		li $a0, 124
		syscall
la $a0 spaceTab
  	li $v0,4
  	syscall

		la $t9, 16($t0)	#uso un registro di appoggio per scorrere byte per byte il nome da stampare
		li $t5, 10	#carattere '\n' (a capo)
		loopPrintNome:
		lb $t4, 0($t9)	# $t4 = carattere letto
		addi $t9, $t9, 1	# procedo al prossimo carattere
		beq $t4, $t5, exitLoopPrintNome # se $t4=='\n' allora esco
		beqz $t4, exitLoopPrintNome # se $t4==0 (fine stringa) allora esco
		li $v0, 11	#stampo il carattere
		move $a0, $t4
		syscall
 
		j loopPrintNome
 
		exitLoopPrintNome:
		la $a0 spaceTab
  	li $v0,4
  	syscall
		li $v0, 11	#stampo '|'
		li $a0, 124
		syscall
la $a0 spaceTab
  	li $v0,4
  	syscall
		lw $t2, 8($t0)	# carico le esecuzoni rimanenti (offset 8)
		li $v0, 1	# e stampo il valore
		move $a0, $t2
		syscall
		la $a0 spaceTab
  	li $v0,4
  	syscall
		li $v0, 11	#stampo '|'
		li $a0, 124
		syscall
 
		li $v0, 11	#ritorno a capo (\n)
		addi $a0, $zero, 10
		syscall
 
		lw $t0, 12($t0)	# procedo al prossimo nodo
		j loopPrint	#rieseguo il ciclo

	exitPrint:
	jr $ra




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
