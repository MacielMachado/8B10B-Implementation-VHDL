# 8B10B-Implementation-VHDL

O Pacote "8B10B Implementation VHDL" consiste da implementações em linguagem de desrição de hardware, no caso, VHDL, do protocolo de comunicação 8B10B.

O protocolo 8B10B consiste de uma codificação que transforma um pacote de 8 bits em um 10 bits visando alcançar o balanço DC e disparidade controlada. Portanto, a quantidade de 0s e 1s em uma transmissão devem ser iguais, a disparidade máxima (diferença entre a quantidade de 0s e 1s) em uma string de 20 bits não deve passar de dois e, finalmente, não deve haver mais de 5 bits de nível lógico igual consecutivos.

Um pacote de 8 bits do tipo "HGFEDCBA", ao passar pela codificação 8B10B, se transforma em uma mensagem do tipo "abcdeifghj".

A implementação consiste das seguintes etapas:

1) TX:

1.1) Gerar os bits "abcdei";

1.2) Gerar os bits "fghj";

1.3) Juntar ambos os pacotes e fazer as complementações necessárias para manter o balanço DC;

1.4) Serializar gerando as vírgulas adequadas;

2) RX:

2.1) Receber os dados e salvá-los em um registrador de deslocamento;

2.2) Encontrar os dados de informação entre os pacotes vírgula;

2.3) Descomplementar os dados;

2.4) Encontrar os bits "EDCBA";

2.5) Encontrar os bits "HGF";

A implementação é dotada de diversas funções de debugação também.

