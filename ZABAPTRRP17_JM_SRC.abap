*&---------------------------------------------------------------------*
*&  Include           ZABAPTRRP17_JM_SRC
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.

SELECT-OPTIONS so_cpf   FOR zabaptrt09_jm-cpf NO INTERVALS.
SELECT-OPTIONS so_codfm FOR zabaptrt09_jm-codfilme NO INTERVALS.
SELECT-OPTIONS so_dtloc FOR zabaptrt09_jm-dtloc NO INTERVALS.

PARAMETER p_alv   RADIOBUTTON GROUP alv DEFAULT 'X'.
PARAMETER p_smart RADIOBUTTON GROUP alv.

SELECTION-SCREEN END OF BLOCK b1.