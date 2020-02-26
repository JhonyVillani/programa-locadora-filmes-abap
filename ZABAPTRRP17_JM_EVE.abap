*&---------------------------------------------------------------------*
*&  Include           ZABAPTRRP17_JM_EVE
*&---------------------------------------------------------------------*

* Declara uma variável do tipo da classe
  DATA:
        go_controle TYPE REF TO lcl_controle. "Classe local

  START-OF-SELECTION.

    CREATE OBJECT go_controle.

    go_controle->processar( ).

  END-OF-SELECTION.

    go_controle->exibir( ).