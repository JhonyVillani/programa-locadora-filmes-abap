*&---------------------------------------------------------------------*
*&  Include           ZABAPTRRP17_JM_C01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       CLASS lcl_controle DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_controle DEFINITION.
  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_saida,
        cpf       TYPE zabaptrde15,
        nome      TYPE zabaptrde10_jm,
        datanasc  TYPE zabaptrde11_jm,
        sexo      TYPE zabaptrde16_jm,
        codfilme  TYPE zabaptrde24_jm,
        titulo    TYPE zabaptrde25_jm,
        categoria TYPE zabaptrde26_jm,
        dataloc   TYPE zabaptrde27_jm,
        datadev   TYPE sy-datum,
        atraso    TYPE char10,
      END OF ty_s_saida.

*   Modelo de saída do ALV
    DATA:
          mt_saida TYPE TABLE OF ty_s_saida,
          ms_saida TYPE ty_s_saida.

*   Variáveis necessárias na formatação e montagem do ALV
    DATA:
          mo_alv     TYPE REF TO cl_salv_table,
          go_columns TYPE REF TO cl_salv_columns_table.

    METHODS:
   constructor,
   processar,
   exibir.

ENDCLASS.                    "lcl_controle DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_controle IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_controle IMPLEMENTATION.
  METHOD constructor.

  ENDMETHOD.                    "constructor

  METHOD processar.

  ENDMETHOD.                    "processar

  METHOD exibir.


*       Criando o relatório ALV, declarando na classe a variáveis mo_alv referenciando cl_salv_table
*       Chama o método que constrói a saída ALV
    CALL METHOD cl_salv_table=>factory
      IMPORTING
        r_salv_table = mo_alv
      CHANGING
        t_table      = mt_saida.

*       Mostra o ALV
    mo_alv->display( ). "Imprime na tela do relatório ALV

*   Otimiza tamanho das colunas
    go_columns = mo_alv->get_columns( ). "Retorna o objeto tipo coluna INSTANCIADO
    go_columns->set_optimize( ).

  ENDMETHOD.                    "exibir

ENDCLASS.                    "lcl_controle IMPLEMENTATION