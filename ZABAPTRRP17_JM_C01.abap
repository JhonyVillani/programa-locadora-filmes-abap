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
        cpf       TYPE zabaptrde15_jm,
        nome      TYPE zabaptrde10_jm,
        datanasc  TYPE zabaptrde11_jm,
        sexo      TYPE zabaptrde16_jm,
        codfilme  TYPE zabaptrde24_jm,
        titulo    TYPE zabaptrde25_jm,
        categoria TYPE zabaptrde28_jm,
        dtloc     TYPE zabaptrde27_jm,
        datadev   TYPE zabaptrde29_jm,
        atraso    TYPE zabaptrde30_jm,
      END OF ty_s_saida.

*   Tabela que receberá dados da tabela transparente após um select condicional
    DATA:
          gt_zabaptrt07 TYPE TABLE OF zabaptrt07_jm, "Clientes
          gt_zabaptrt08 TYPE TABLE OF zabaptrt08_jm, "Filmes
          gt_zabaptrt09 TYPE TABLE OF zabaptrt09_jm. "Locação Cliente X Filme

*   Modelo de saída do ALV
    DATA:
          mt_saida TYPE TABLE OF ty_s_saida,
          ms_saida TYPE ty_s_saida.

*   Variáveis necessárias para chamar a função Domain Value Get
    DATA:
          mv_texto TYPE dd07v-ddtext, "Tipo do campo na função domain_value_get
          mv_trim  TYPE dd07v-domvalue_l.

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

    SELECT *
      FROM zabaptrt07_jm
      INTO TABLE gt_zabaptrt07
     WHERE cpf IN so_cpf.

    SELECT *
      FROM zabaptrt08_jm
      INTO TABLE gt_zabaptrt08
     WHERE codfilme IN so_codfm.

    SELECT *
          FROM zabaptrt09_jm
          INTO TABLE gt_zabaptrt09
          WHERE cpf      IN so_cpf
            AND codfilme IN so_codfm
            AND dtloc    IN so_dtloc.

  ENDMETHOD.                    "constructor

  METHOD processar.
*   Work-areas auxiliares no READ TABLE
    DATA:
          gs_zabaptrt07 TYPE zabaptrt07_jm,
          gs_zabaptrt08 TYPE zabaptrt08_jm,
          gs_zabaptrt09 TYPE zabaptrt09_jm.

    SORT gt_zabaptrt09 BY codfilme.

*   Loop na tabela principal (que contém a maioria dos dados)
    LOOP AT gt_zabaptrt09 INTO gs_zabaptrt09.

*     Boa prática limpar a estrutura antes de dar READ TABLE
      CLEAR gs_zabaptrt07.
      READ TABLE gt_zabaptrt07 INTO gs_zabaptrt07 WITH KEY cpf = gs_zabaptrt09-cpf.
      ms_saida-cpf      = gs_zabaptrt09-cpf(3)   && '.' &&
                          gs_zabaptrt09-cpf+3(3) && '.' &&
                          gs_zabaptrt09-cpf+6(3) && '-' &&
                          gs_zabaptrt09-cpf+9(2).

      ms_saida-nome     = gs_zabaptrt07-nome.
      ms_saida-datanasc = gs_zabaptrt07-dtnasc.

*     Variável deve receber o valor a ser validado
      CLEAR: mv_trim, mv_texto.
      mv_trim = gs_zabaptrt07-sexo.

      CALL FUNCTION 'DOMAIN_VALUE_GET'
        EXPORTING
          i_domname  = 'ZABAPTRD13_JM'
          i_domvalue = mv_trim
        IMPORTING
          e_ddtext   = mv_texto
        EXCEPTIONS
          not_exist  = 1
          OTHERS     = 2.

      ms_saida-sexo    = mv_texto.

*     Boa prática limpar a estrutura antes de dar READ TABLE
      CLEAR gs_zabaptrt08.
      READ TABLE gt_zabaptrt08 INTO gs_zabaptrt08 WITH KEY codfilme = gs_zabaptrt09-codfilme.
      ms_saida-titulo    = gs_zabaptrt08-titulo.

*     Variável deve receber o valor a ser validado novamente
      CLEAR: mv_trim, mv_texto.
      mv_trim = gs_zabaptrt08-categoria.

      CALL FUNCTION 'DOMAIN_VALUE_GET'
        EXPORTING
          i_domname  = 'ZABAPTRD16_JM'
          i_domvalue = mv_trim
        IMPORTING
          e_ddtext   = mv_texto
        EXCEPTIONS
          not_exist  = 1
          OTHERS     = 2.
      ms_saida-categoria = mv_texto.

      ms_saida-codfilme  = gs_zabaptrt09-codfilme.
      ms_saida-dtloc     = gs_zabaptrt09-dtloc.
      ms_saida-datadev   = gs_zabaptrt09-dtloc + 2.

*     Verifica se a data de devolução antecede a data de hoje (expirou)
      IF ms_saida-datadev < sy-datum.
        ms_saida-atraso = 'Em atraso'.
      ENDIF.

      APPEND ms_saida TO mt_saida.
      CLEAR ms_saida.
    ENDLOOP.

  ENDMETHOD.                    "processar

  METHOD exibir.

*   Verifica se o RADIO Smart foi selecionado
    IF p_smart IS INITIAL. "Caso NÃO

*     Criando o relatório ALV, declarando na classe a variáveis mo_alv referenciando cl_salv_table
*     Chama o método que constrói a saída ALV
      CALL METHOD cl_salv_table=>factory
        IMPORTING
          r_salv_table = mo_alv
        CHANGING
          t_table      = mt_saida.

*     Mostra o ALV
      mo_alv->display( ). "Imprime na tela do relatório ALV

*   Otimiza tamanho das colunas
      go_columns = mo_alv->get_columns( ). "Retorna o objeto tipo coluna INSTANCIADO
      go_columns->set_optimize( ).

    ELSE. "Caso SIM

*     Declarações do Smartform
      DATA:
            lv_fm_name            TYPE rs38l_fnam,
            ls_control_parameters TYPE ssfctrlop,
            ls_output_options     TYPE ssfcompop,
            ls_job_output_info    TYPE ssfcrescl,
            ls_saida              TYPE zabaptrs04_jm. "Do tipo da estrutura SE11 criada para exibição

      LOOP AT mt_saida INTO ls_saida.

*       Declarações de variáveis a serem utilizadas no Case que verifica a quantidade de páginas via LOOP
        DATA: lv_lines TYPE i,
              lv_tabix TYPE sy-tabix.
        lv_tabix = sy-tabix.

*       Função que passa uma estrutura para o Smartform e exibe-o (Necessário método de importação FM_NAME)
        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZABAPTRSF01_JM'
          IMPORTING
            fm_name            = lv_fm_name "Função definida abaixo
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.

*       Definições de saída do Smartform
        ls_output_options-tddest        = 'LP01'.
        ls_output_options-tdimmed       = abap_true.
        ls_control_parameters-no_dialog = abap_true.
        ls_control_parameters-preview   = abap_true.

*       Case para verificar quantidade de páginas a serem exibidas pelo LOOP
        DESCRIBE TABLE mt_saida LINES lv_lines.

        CASE lv_tabix.
          WHEN 1.
            ls_control_parameters-no_open = abap_false.
            ls_control_parameters-no_close = abap_true.
          WHEN OTHERS.
            ls_control_parameters-no_open = abap_true.
            ls_control_parameters-no_close = abap_true.
        ENDCASE.

        IF lv_lines EQ 1.
          ls_control_parameters-no_open = abap_false.
          ls_control_parameters-no_close = abap_false.
        ELSEIF sy-tabix EQ lv_lines.
          ls_control_parameters-no_open = abap_true.
          ls_control_parameters-no_close = abap_false.
        ENDIF.

*       Função que importa a estrutura do programa para dentro do Smartform (Necessária para o primeiro método funcionar
        CALL FUNCTION lv_fm_name
          EXPORTING
            control_parameters = ls_control_parameters
            output_options     = ls_output_options
            user_settings      = space
            is_saida           = ls_saida "No Smartform é necessário ter a variável job declarada com o mesmo tipo da estrutura global
          IMPORTING
            job_output_info    = ls_job_output_info
          EXCEPTIONS
            formatting_error   = 1
            internal_error     = 2
            send_error         = 3
            user_canceled      = 4
            OTHERS             = 5.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.                    "exibir

ENDCLASS.                    "lcl_controle IMPLEMENTATION