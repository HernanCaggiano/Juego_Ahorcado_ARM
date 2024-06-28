.data
mapa:   .ascii  "__________________________________ |\n"
        .ascii  "                                   |\n"
        .ascii  "   *** El ahorcado - Orga 1 ***    |\n"
        .ascii  "__________________________________ |\n"
        .ascii  "                                   |\n"
        .ascii  "                                   |\n"
        .ascii  "          +-------+                |\n"
        .ascii  "          |       |                |\n"
        .ascii  "          |                        |\n"
        .ascii  "          |                        |\n"
        .ascii  "          |                        |\n"
        .ascii  "          |                        |\n"
        .ascii  "          |                        |\n"
        .ascii  "          |                        |\n"
        .ascii  "          |                        |\n"
        .ascii  "  +-----------------------------+  |\n"
        .ascii  "                                   |\n"
        .ascii  "                                     |\n"
        .ascii  "                                   |\n"
        .ascii  "  +-----------------------------+  |\n"
finMapa = . - mapa

        //Etiquetas para las cadenas de texto
        stringQuedanLetras: .ascii "Quedan letras por adivinar!\n"
        stringQuedanLetrasLen = . - stringQuedanLetras  @manera simple de contar cuantas letras tiene un arreglo

        stringCantVidas: .ascii "Vidas:  \n"
        stringCantVidasLen = . - stringCantVidas

        stringIngreseLetra: .asciz "Ingrese una letra: \n"
        stringIngreseLetraLen = . - stringIngreseLetra

        stringGano: .ascii "¡Felicidades Ganaste!\n"
        stringGanoLen = . - stringGano

        stringPerdio: .ascii "¡Perdiste!\n"
        stringPerdioLen = . - stringPerdio

        mensajeBienvenida: .asciz "Bienvenido al juego del Ahorcado\n"
        stringBienvenidaLen = . - mensajeBienvenida

        pideNombre: .asciz "Ingrese su nombre: \n"
        stringPideNombreLen = . - pideNombre

        stringPalabraCorrecta: .asciz "La palabra correcta era: "
        stringPalabraCorrectaLen = .- stringPalabraCorrecta

        stringOportunidadPunteria: .ascii "¡Te quedaste sin vidas! Te damos una oportunidad de salvar al ahorcado con tu buena puntería!\n"
        stringOportunidadPunteriaLen = . - stringOportunidadPunteria

        pideCoordenadaX: .asciz "Ingrese la coordenada X (ayuda: es un numero de un digito): "
        stringpideCoordenadaXLen = . - pideCoordenadaX

        pideCoordenadaY: .asciz "Ingrese la coordenada Y (ayuda: es un numero de dos digitos): "
        stringpideCoordenadaYLen = . - pideCoordenadaY

        saltoLinea: .asciz "\n"
        saltoLineaLen = . - saltoLinea

        //Etiquetas para las posiciones del ahorcado
        cabeza: .word 314

        cuerpoPri: .word 351

        brazoIzq: .word 350

        brazoDer: .word 352

        cuerpoSeg: .word 388

        piernaIzq: .word 424

        piernaDer: .word 426

        palabraAuxPosicion: .word 638

        //Etiquetas varias
        cantidadLetrasPalabra: .word 7          //reservo espacio para guardar la cantidad de letras de palabra

        //palabra: .asciz "sistema"             //espacio para la palabra a adivinar

        auxPalabra: .asciz "@@@@@@@"            //reemplaza con "@@@@@@@" en panatalla

        vidas: .word 7                          //cantidad de vidas

        contador: .word 0x00000

        letraIngresada: .asciz ""               //se guarda la letra que ingreso por teclado

        nombre: .asciz ""                       //donde se guarda el nombre del jugador


        //Etiquetas para la segunda parte del TP
        coordenadaX: .asciz "  "                //se guarda la coordenada x

        coordenadaY: .asciz "  "                //se guarda la coordenada y

        coordenadaXInt: .byte 0                 //guarda la coordenada x convertida en un entero

        coordenadaYInt: .byte 0                 //guarda la coordenada y convertida en un entero

        filaSoga: .byte 8                       //el valor acertado de la fila

        columnaSoga: .byte 19                   //el valor acertado de la columna

        cantidadCaracteres: .byte 0             //almacena la cantidad de caracteres que tiene el numero

        //Etiquetas para los arcivos
        archivoPalabras: .asciz "palabras.txt"

        buffer: .space 170

        listaPalabras: .space 170

        aleatorio: .word 0

        palabra: .asciz "       "
        palabraLen = . - palabra



.text

@ Imprime el mapa en pantalla
@ No recibe parametros
@ Interrupcion
imprimirMapa:
        .fnstart
        push {lr}

        bl remplazaPalabraAux


        mov r7, #4
        mov r0, #1
        mov r2, $finMapa
        ldr r1, =mapa
        swi 0

        pop {lr}
        bx lr
        .fnend

//------------------------------------------------------------------------


@Realiza un salto de linea
@No recibe nada
@
saltoDeLinea:
        .fnstart
        push {r1, r2, lr}

        ldr r1, =saltoLinea
        mov r2, $saltoLineaLen

        bl imprimeCadena

        pop {r1, r2, lr}
        bx lr
        .fnend

//-------------------------------------------------------------------------


@Lee palabras del archivo y las guarda en una lista
@
@
leer_palabras:
        .fnstart
        push {lr}

        mov r7, #5
        ldr r0, =archivoPalabras
        mov r1, #0                      //lectura archivo
        mov r2, #0
        swi 0

        //proceso de lectura
        mov r7, #3
        ldr r1, =buffer
        mov r2, #170                    //tamaño del buffer
        swi 0

        //cerrar archivo
        mov r7, #6
        mov r0, r6
        swi 0

        //Copiar buffer a ListaPalabras
        ldr r1, =buffer
        ldr r2, =listaPalabras
        mov r3, #0

copiarBuffer:
        ldrb r0, [r1, r3] //lee un byte de la memoria apuntada por r1 + r3
        strb r0, [r2, r3]  // lo escribe a la dirección apuntada por r2 + r3

        cmp r0, #0  //compara si llegó al fin del buffer
        beq finCopiaBuffer

        add r3, r3, #1  //aumenta contador

        bal copiarBuffer

finCopiaBuffer:

        pop {lr}
        bx lr
        .fnend

//----------------------------------------------------------------------------


@Elige una palabra al azar de una lista
@
@
sortear_palabra:
        .fnstart
        push {lr}

        ldr r1, =listaPalabras
        mov r2, #0              //indicializar para recorrer la lista
        mov r3, #0              //contador de palabras encontradas (indice)

        bl random
        mov r5, r0

encontrarPalabra:
        ldrb r0, [r1, r2]

        cmp r0, #0
        beq termino

        cmp r0, #'\n'
        beq avanzarPalabra

        add r2, r2, #1

        bal encontrarPalabra

avanzarPalabra:
        add r2, r2, #1
        add r3, r3, #1

        cmp r3, r5              //compara el contador con el indice deseado
        beq copiarPalabra

        bal encontrarPalabra

copiarPalabra:
        mov r3, #0
        ldr r6, =palabra

bucleCopiarPalabra:
        ldrb r0, [r1, r2]

        cmp r0, #'\n'  //compara si termino la palabra
        beq copiadoTerminado

        strb r0, [r6], #1  //almacena e incrementa al siguiente byte

        add r2, r2, #1

        bal bucleCopiarPalabra

copiadoTerminado:
        mov r0, #0
        strb r0, [r6, r3]

termino:
        pop {lr}
        bx lr
        .fnend


//----------------------------------------------------------------



@Genera un número aleatorio
@Sin entradas
@Salida: r0: num aleatorio
random:
        .fnstart
        push {r1, r3, r6, r9, lr}

        ldr r9, =aleatorio
        mov r7, #78  //setear codigo de syscall fn getrandom devuelve num aleato
        ldr r0, =aleatorio
        mov r1, #0
        swi 0

        ldr r0, [r9, #1]  //carga en r0 el contenido de r9 más un desplazamiento

        ror r3, r0, #28 //rotacion a la derecha de 28bits
        mov r0, #0
        mov r6, #0
        and r0, r3, #0x000000f //extrae los 4 bits menos significativos

        pop {r1, r3, r6, r9, lr}
        bx lr
        .fnend




//-----------------------------------------------------------------------


@ Lee una letra por teclado para guardadla en el puntero de letraSeleccionada
@ No recibe parametros
@ Interrupcion
leerLetraPorTeclado:
        .fnstart
        push {lr}

        mov r7, #3 //lectura por teclado
        mov r0, #0 //ingreso de cadena
        mov r2, #3 //lee la cantidad de caracteres
        ldr r1, = letraIngresada  //donde se va a guardar la letra
        swi 0

        pop {lr}
        bx lr
        .fnend


//----------------------------------------------------------------------


@ Imprime por pantalla una cadena de texto
@ Entradas (r1: cadena y r2: tamaño de cadena)
@ Interrupcion
imprimeCadena:
        .fnstart
        push {r0, r1, r2, lr}

        mov r0, #1
        mov r7, #4
        swi 0

        pop {r0, r1, r2, lr}
        bx lr
        .fnend



//-----------------------------------------------------------------------



@ Lee el nombre del usuario y lo asigna a la variable nombre
@ No recibe parametros
@ Interrupcion
leerNombre:
        .fnstart
        push {lr}

        mov r7, #3
        mov r0, #0
        mov r2, #10  //tamaño maximo de la cadena
        ldr r1, =nombre  //donde se va a guardar el nombre
        swi 0

        pop {lr}
        bx lr
        .fnend



//----------------------------------------------------------------------



@ Valida si la letra ingresada pertenece a la palabra
@ Entrada r0 (letra a validar)
@ Retorna r1 | r1 = 0 --> no esta la letra | r1 = 1 --> se encontro la letra
comprobarLetra:
        .fnstart
        push {lr}

        mov r1, #0
        ldr r4, =contador
        ldr r4, [r4]
        ldr r5, =palabra      // puntero a la palabra que tiene que adivinar

cicloAdivinaLetra:
        mov r2, #0
        ldrb r2, [r5]                           //caracter de la palabra

        cmp r2, #00                             //compara si es el final de la palabra
        beq terminoComprobacionLetra

        cmp r2, r0                              //el caracter de r2 es igual al que ingreso por teclado
        beq reemplazarCaracter

sigoAdivinandoLetra:

        add r4, r4, #1                          //contador++
        add r5, r5, #1                          //a la siguiente posicion
        bal cicloAdivinaLetra

reemplazarCaracter:

        ldr r3, =auxPalabra
        add r3, r3, r4          //a la dirección de memoria de aux le sumo el contador para posicionarlo
        strb r0, [r3]           //le asigno el caracter

        ldr r3, =cantidadLetrasPalabra
        ldr r2, [r3]
        sub r2, #1
        str r2, [r3]

        mov r1, #1                              //devuelvo r1 = 1 (true) porque se encontro una letra

        bal sigoAdivinandoLetra

        terminoComprobacionLetra:
        pop {lr}
        bx lr
        .fnend




//----------------------------------------------------------------------------


@ Resta una vida, actualiza la etiqueta 'vidas'
@ No recibe parametros
@ No retorna
restarVida:
        .fnstart
        push {lr}

        ldr r2, =vidas
        ldr r3, [r2]

        sub r3, #1                      //le resta una vida
        str r3, [r2]                    //actualiza la etiqueta

        pop {lr}
        bx lr
        .fnend




//--------------------------------------------------------------------------


@ Se encarga de imprimir el string de las vidas restantes
@ Entrada r3 (cantidad de vidas)
@ No retorna
imprimirVidas:
        .fnstart

        ldr r0, =stringCantVidas                //string que tiene que imprimir

        add r3, #0x30                           //convierto de numero a ascii

        ldr r0, =stringCantVidas
        add r0, $stringCantVidasLen - 3         //apunta el puntero al final del string -3

        strb r3, [r0]

        push {lr}

        ldr r1, =stringCantVidas
        ldr r2, =stringCantVidasLen
        bl imprimeCadena

        pop {lr}
        bx lr
        .fnend



//--------------------------------------------------------------------------



@ Dibuja parte del ahorcado o escribe la letra adivinada
@ Entradas (r10 y r2)
@ No retorna
resultadoIntento:
        .fnstart
        push {r10, lr}


        ldr r10, =mapa
        ldr r2, =vidas
        ldr r3, [r2]

        cmp r3, #7
        beq dibujarCabeza

        cmp r3, #6
        beq dibujarCuerpo1

        cmp r3, #5
        beq dibujarBrazoIzq

        cmp r3, #4
        beq dibujarBrazoDer

        cmp r3, #3
        beq dibujarCuerpo2

        cmp r3, #2
        beq dibujarPiernaIzq

        cmp r3, #1
        beq dibujarPiernaDer

        bal finFuncion          // Salta al final si ninguna condición se cumple

dibujarCabeza:
        ldr r6, =cabeza
        ldr r6, [r6]

        add r10, r6

        mov r0, #111            // el valor ASCII de o
        strb r0, [r10]

        bal finFuncion

dibujarCuerpo1:
        ldr r6, =cuerpoPri
        ldr r6, [r6]

        add r10, r6
        mov r0, #124            // el valor ASCII de |
        strb r0, [r10]

        bal finFuncion

dibujarBrazoIzq:
        ldr r6, =brazoIzq
        ldr r6, [r6]

        add r10, r6
        mov r0, #47             // el valor ASCII de /
        strb r0, [r10]

        bal finFuncion

dibujarBrazoDer:
        ldr r6, =brazoDer
        ldr r6, [r6]

        add r10, r6
        mov r0, #92             //el valor ASCII de \
        strb r0, [r10]

        bal finFuncion

dibujarCuerpo2:
        ldr r6, =cuerpoSeg
        ldr r6, [r6]

        add r10, r6
        mov r0, #124            // el valor ASCII de |
        strb r0, [r10]

        bal finFuncion

dibujarPiernaIzq:
        ldr r6, =piernaIzq
        ldr r6, [r6]

        add r10, r6
        mov r0, #47             // el valor ASCII de /
        strb r0, [r10]

        bal finFuncion

dibujarPiernaDer:
        ldr r6, =piernaDer
        ldr r6, [r6]

        add r10, r6
        mov r0, #92             //el valor ASCII de \
        strb r0, [r10]

        bal finFuncion

finFuncion:
        pop {r10, lr}
        bx lr
        .fnend


//------------------------------------------------------------------------


@ Remplaza en el mapa la palabra aux
@ Entradas (r10 y r2)
@ No retorna
remplazaPalabraAux:
        .fnstart
        push {r1, r2, r3, lr}

        ldr r10, =mapa

        ldr r11, =palabraAuxPosicion
        ldr r11, [r11]

        ldr r9, =auxPalabra
        ldrb r8, [r9]

        ldr r5, =palabra              // puntero a la palabra que tiene que adivinar
        ldrb r6, [r5]

        add r10, r11

cicloPalabra:
        cmp r6, #00
        beq finFuncion2

        strb r8, [r10]

        add r10, r10, #1              // a la dirección de memoria de aux le sumo el contador para posicionarlo

        add r5, r5, #1                // a la siguiente posicion
        ldrb r6, [r5]

        add r9, r9, #1                          //a la siguiente posicion
        ldrb r8, [r9]

        bal cicloPalabra

 finFuncion2:
        pop {r1, r2, r3, lr}
        bx lr
        .fnend



//----------------------------------------------------------------------------


@ Lee la coordenada X por teclado para guardarla en el puntero coordenadaX
@ No recibe parametros
@ Interrupcion
leerCoordenadaX:
        .fnstart
        push {r3, r4, r6, r8, lr}

        mov r7, #3              //lectura por teclado
        mov r0, #0              //ingreso de cadena
        mov r2, #2              //lee la cantidad de caracteres
        ldr r1, =coordenadaX    //donde se va a guardar la letra
        swi 0

        pop {r3, r4, r6, r8, lr}
        bx lr
        .fnend


//------------------------------------------------------------------------------


@ Lee la coordenada Y por teclado para guardarla en el puntero coordenadaX
@ No recibe parametros
@ Interrupcion
leerCoordenadaY:
        .fnstart
        push {r3, r4, r6, r8, lr}

        mov r7, #3              //lectura por teclado
        mov r0, #0              //ingreso de cadena
        mov r2, #2              //lee la cantidad de caracteres
        ldr r1, = coordenadaY   //donde se va a guardar la letra
        swi 0

        pop {r3, r4, r6, r8, lr}
        bx lr
        .fnend


//-------------------------------------------------------------------------


@ Transforma un cadena en enteros
@ Entradas (r6: numero, r8: direccion de memoria, r10: num en int)
@ Interrupcion
convierteCadenaEnEntero:
        .fnstart
        push {r3, r4, r6, r8, r10, lr}

        mov r1, #0              //contador para la posicion
        mov r2, #10             //acumulador de la suma
        mov r5, #0              //almaceno el int
        mov r12, #0             //acumulador de la suma

        ldr r9, =cantidadCaracteres
        ldrb r9, [r9]

        cmp r9, #0x1           //si es el segundo digito lo sumo y salgo
        beq numeroDeUnCaracter

        cmp r9, #0x2
        beq numeroDeDosCaracteres


numeroDeUnCaracter:

        sub r5, r6, #0x30                        //resto 30 a cada caracter

        bal finCadena

numeroDeDosCaracteres:

        cmp r6, #00
        beq finCadena

        sub r11, r6, #0x30

        mul r12, r11, r2

        add r5, r12

        sub r2, #9

        add r8, #1
        ldrb r6, [r8]
        bal numeroDeDosCaracteres


finCadena:
        strb r5, [r10]

        pop {r3, r4, r6, r8, r10, lr}
        bx lr
        .fnend



//------------------------------------------------------------------------

@ Cuenta los caracteres de las coordenadas
@ Entradas (r6: num ingresado y r8: memoria donde guardar el entero)
@ Interrupcion
contarCaracteres:
        .fnstart
        push {r3, r4, r6, r8, lr}

        ldr r9, =cantidadCaracteres

        mov r1, #0

cicloContarCaracteres:

        cmp r6, #00  //cuando ingresa dos caracteres
        beq finContarCaracteres

        cmp r6, #0xa  //cuando ingresa un caracter
        beq finContarCaracteres

        add r1, #1

        add r8, #1
        ldrb r6, [r8]

        bal cicloContarCaracteres

finContarCaracteres:

        strb r1, [r9]

        pop {r3, r4, r6, r8, lr}
        bx lr
        .fnend



.global main
main:

        //imprime el mensaje de bienvenida
        ldr r1, =mensajeBienvenida
        mov r2, $stringBienvenidaLen
        bl imprimeCadena


        //imprime mensaje pidiendo nombre
        ldr r1, =pideNombre
        mov r2, $stringPideNombreLen
        bl imprimeCadena


        bl leerNombre  //guarda en memoria el nombre del jugador


        bl leer_palabras
        bl sortear_palabra


        bl saltoDeLinea

ciclo:

        bl imprimirMapa

        //imprime las vidas
        ldr r3, =vidas
        ldr r3, [r3]
        bl imprimirVidas


        //imprime la cantidas de letras
        ldr r1, =stringQuedanLetras
        mov r2, $stringQuedanLetrasLen
        bl imprimeCadena

        bl saltoDeLinea

        //imprime ingrese una letra
        ldr r1, =stringIngreseLetra
        mov r2, $stringIngreseLetraLen
        bl imprimeCadena

        bl leerLetraPorTeclado


        ldr r0, =letraIngresada
        ldrb r0, [r0]


        bl comprobarLetra
        cmp r1, #0  //no encontro letra
        beq noEncontroLetra


        ldr r0, =cantidadLetrasPalabra
        ldr r0, [r0]

        cmp r0, #0  //compara si el contador de las letras acertadas
        beq gano

        bal ciclo

noEncontroLetra:
        bl resultadoIntento
        bl restarVida

        ldr r0, =vidas
        ldr r0, [r0]

        cmp r0, #0  //si tiene o no más vidas
        beq perdio
        bal ciclo  //vuelve al ciclo principal


perdio:
        bl imprimirMapa


        //imprime cual era la palabra correcta
        ldr r1, =stringPalabraCorrecta
        mov r2, $stringPalabraCorrectaLen
        bl imprimeCadena

        ldr r1, =palabra
        mov r2, $palabraLen -1
        bl imprimeCadena

        bl saltoDeLinea
        bl saltoDeLinea

//-------------------------------------------------------
//Segunda parte del tp
//-------------------------------------------------------

        ldr r3, =filaSoga
        ldrb r3, [r3]  //coordenada x

        ldr r4, =columnaSoga
        ldrb r4, [r4]  //coordenada y


        //imprime el mensaje de la oportunidad de punteria
        ldr r1, =stringOportunidadPunteria
        mov r2, $stringOportunidadPunteriaLen
        bl imprimeCadena


        //imprime el mensaje pidiendo la coordenada X
        ldr r1, =pideCoordenadaX
        mov r2, $stringpideCoordenadaXLen
        bl imprimeCadena

        bl leerCoordenadaX

        ldr r10, =coordenadaXInt          //donde guardo el entero en memoria
        ldr r8, =coordenadaX
        ldrb r6, [r8]

        bl contarCaracteres

        bl convierteCadenaEnEntero




        //imprime el mensaje pidiendo la coordenada Y
        ldr r1, =pideCoordenadaY
        mov r2, $stringpideCoordenadaYLen
        bl imprimeCadena

        bl leerCoordenadaY

        ldr r10, =coordenadaYInt         //donde guardo el entero en memoria
        ldr r8, =coordenadaY
        ldrb r6, [r8]

        bl contarCaracteres

        bl convierteCadenaEnEntero




        ldr r1, =coordenadaXInt
        ldrb r1, [r1]

        ldr r2, =coordenadaYInt
        ldrb r2, [r2]

        //compara si las coordenadas son correctas
        cmp r1, r3
        bne perdioDefinitivamente  //si no es igual

        cmp r2, r4
        bne perdioDefinitivamente  //si no es igual

        bal gano

gano:

        bl saltoDeLinea

        ldr r1, =stringGano
        mov r2, $stringGanoLen

        bl imprimeCadena

        b fin

perdioDefinitivamente:
        bl saltoDeLinea

        bl imprimirMapa

        bl saltoDeLinea

        ldr r1, =stringPerdio
        mov r2, $stringPerdioLen
        bl imprimeCadena



fin:
        //Finalizar sistema

        mov r7, #1
        swi 0
