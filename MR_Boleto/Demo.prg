#include "inkey.ch"
#include "hbgtinfo.ch"

Procedure Main
   Local oBoleto
   Local cFilePdf := 'MR_boleto.PDF'

   F_Set_Desktop()

   oBoleto := MR_Boleto():New( cFilePdf )

      // *---------------------------------------------------------------------*
      // BANCO DO BRASIL
      // *---------------------------------------------------------------------*
      oBoleto:Banco________ := '001'
      oBoleto:Banco_Agencia := '3482'
      oBoleto:Banco_Ag_Dv__ := '7'
      oBoleto:Banco_Ag_Un_A := ''
      oBoleto:Conta________ := '29022'
      oBoleto:Conta_DV_____ := 'X'
      oBoleto:Conta_OP_____ := ''
      oBoleto:Carteira_____ := '17'
      oBoleto:Carteira_Tipo := ''
      oBoleto:NossoNumero__ := '28694640006980101'
      oBoleto:Doc_Origem___ := 'NFe'
      oBoleto:Prefixo______ := '2869464'
      oBoleto:Prefixo_DV___ := '6'
      oBoleto:Doc_Numero___ := '0006980101'
      oBoleto:Doc_Aceite___ := 'N'
      oBoleto:Doc_Especie__ := 'R$'
      oBoleto:Doc_Data_____ := STOD( '20160301' )
      oBoleto:Vencimento___ := oBoleto:Doc_Data_____ + 30
      oBoleto:Valor________ := ( 100 * 1 )
      oBoleto:Protesto_Dias := 0
      oBoleto:Multa_Auto___ := 2
      oBoleto:Juros_Mes____ := 2
      oBoleto:Numero_Vias__ := 3
      oBoleto:Local_Pagamen := { "Pague em qualquer banco até o limite da data de vencimento" }
      oBoleto:Instrucoes___ := { "Desconto de 5% se pago até o dia " + Tran( Date()+10, '@E' ), "Não receber após 30 dias da data de vencimento" }
      oBoleto:Demonstrativo := { "Vetor: pode a exemplo ser utilizado para se demonstrar o rateio de despesas para condominios", '', 'Utiliza Fonte com espaçamento de tamanho fixo ( Courier ), o que permite geração de demostrativos financeiros flexiveis.', '', 'O limite é sua criatividade :)', '', "Exiba detalhes importantes para o usuario", '', 'Valores em cobrança', '', 'Contratos', '', 'Informações úteis', '', 'Etc...' }
      oBoleto:Beneficiario_ := { "00912141000180", "HIPERTELAS INDUSTRIA E COMERCIO DE TELAS", "Beneficiario: Endereço ( Opcional )" }
      oBoleto:Pagador______ := { "28242092168", "PAULO LUIZ SOARES", "AV. CASTELO BRANCO, NR 2033", "SETOR COIMBRA", "GOIANIA", "GO", "74530010" }
      oBoleto:Avalista_____ := { "28242092168", "PAULO LUIZ SOARES", "Avalista: Endereço ( Opcional )" }

      oBoleto:AddPage()

      oBoleto:Cnab_Path____ := 'C:\TEMP\Remessa\'
      oBoleto:Cnab_Save()

      // *---------------------------------------------------------------------*
      // BANCO SANTANDER
      // *---------------------------------------------------------------------*
      oBoleto:Banco________ := '033'
      oBoleto:Banco_Agencia := '0123'
      oBoleto:Banco_Ag_Dv__ := '7'
      oBoleto:Banco_Ag_Un_A := ''
      oBoleto:Conta________ := ''
      oBoleto:Conta_DV_____ := ''
      oBoleto:Conta_OP_____ := ''
      oBoleto:Carteira_____ := '00'
      oBoleto:Carteira_Tipo := ''
      oBoleto:NossoNumero__ := '12345'
      oBoleto:Doc_Origem___ := 'NFe'
      oBoleto:Prefixo______ := '12345'
      oBoleto:Prefixo_DV___ := '9'
      oBoleto:Doc_Numero___ := '00012345'
      oBoleto:Doc_Aceite___ := 'N'
      oBoleto:Doc_Especie__ := 'R$'
      oBoleto:Doc_Data_____ := Date()
      oBoleto:Vencimento___ := Date()+29
      oBoleto:Valor________ := ( 13.37 * 2 )
      oBoleto:Protesto_Dias := 0
      oBoleto:Multa_Auto___ := 2
      oBoleto:Juros_Mes____ := 2
      oBoleto:Numero_Vias__ := 3
      oBoleto:Local_Pagamen := { "Pague em qualquer banco até o limite da data de vencimento" }
      oBoleto:Instrucoes___ := { "Desconto de 5% se pago até o dia " + Tran( Date()+10, '@E' ), "Não receber após 30 dias da data de vencimento" }
      oBoleto:Demonstrativo := { "Vetor: pode a exemplo ser utilizado para se demonstrar o rateio de despesas para condominios", '', 'Utiliza Fonte com espaçamento de tamanho fixo ( Courier ), o que permite geração de demostrativos financeiros flexiveis.', '', 'O limite é sua criatividade :)', '', "Exiba detalhes importantes para o usuario", '', 'Valores em cobrança', '', 'Contratos', '', 'Informações úteis', '', 'Etc...' }
      oBoleto:Beneficiario_ := { "Beneficiario: CNPJ", "Beneficiario: Nome", "Beneficiario: Endereço ( Opcional )" }
      oBoleto:Pagador______ := { "Pagador: CNPJ", "Pagador: Nome", "Pagador: Endereço Completo" }
      oBoleto:Avalista_____ := { "Avalista: CNPJ", "Avalista: Nome", "Avalista: Endereço ( Opcional )" }

      oBoleto:AddPage()

      // *---------------------------------------------------------------------*
      // BANCO CECREDI
      // *---------------------------------------------------------------------*
      oBoleto:Banco________ := '085'
      oBoleto:Banco_Agencia := '0123'
      oBoleto:Banco_Ag_Dv__ := ''
      oBoleto:Banco_Ag_Un_A := '22'
      oBoleto:Conta________ := '12345'
      oBoleto:Conta_DV_____ := '9'
      oBoleto:Conta_OP_____ := ''
      oBoleto:Carteira_____ := '00'
      oBoleto:Carteira_Tipo := '3'
      oBoleto:NossoNumero__ := '12345'
      oBoleto:Doc_Origem___ := 'NFe'
      oBoleto:Prefixo______ := '123456'
      oBoleto:Prefixo_DV___ := '0'
      oBoleto:Doc_Numero___ := '00001234'
      oBoleto:Doc_Aceite___ := 'N'
      oBoleto:Doc_Especie__ := 'R$'
      oBoleto:Doc_Data_____ := Date()
      oBoleto:Vencimento___ := Date()+30
      oBoleto:Valor________ := ( 13.37 * 3 )
      oBoleto:Protesto_Dias := 0
      oBoleto:Multa_Auto___ := 2
      oBoleto:Juros_Mes____ := 2
      oBoleto:Numero_Vias__ := 3
      oBoleto:Local_Pagamen := { "Pagavel em qualquer banco até o limite da data de vencimento" }
      oBoleto:Instrucoes___ := { "Desconto de 5% se pago até o dia " + Tran( Date()+10, '@E' ), "Não receber após 30 dias da data de vencimento" }
      oBoleto:Demonstrativo := { "Exiba detalhes importantes para o usuario", '', 'Valores em cobrança', '', 'Contratos', '', 'Informações úteis', '', 'Etc...' }
      oBoleto:Beneficiario_ := { "Beneficiario: CNPJ", "Beneficiario: Nome", "Beneficiario: Endereço ( Opcional )" }
      oBoleto:Pagador______ := { "Pagador: CNPJ", "Pagador: Nome", "Pagador: Endereço Completo" }
      oBoleto:Avalista_____ := { "Avalista: CNPJ", "Avalista: Nome", "Avalista: Endereço ( Opcional )" }

      oBoleto:AddPage()

      // *---------------------------------------------------------------------*
      // CAIXA ECONOMICA FEDERAL
      // *---------------------------------------------------------------------*
      oBoleto:Banco________ := '104'
      oBoleto:Banco_Agencia := '0012'
      oBoleto:Banco_Ag_Dv__ := ''
      oBoleto:Banco_Ag_Un_A := ''
      oBoleto:Conta________ := '80614'
      oBoleto:Conta_DV_____ := '5'
      oBoleto:Conta_OP_____ := '003'
      oBoleto:Carteira_____ := 'SR'
      oBoleto:Carteira_Tipo := ''
      oBoleto:NossoNumero__ := '8207406073'
      oBoleto:Doc_Origem___ := 'NFe'
      oBoleto:Prefixo______ := ''
      oBoleto:Prefixo_DV___ := ''
      oBoleto:Doc_Numero___ := '00001234'
      oBoleto:Doc_Aceite___ := 'N'
      oBoleto:Doc_Especie__ := 'R$'
      oBoleto:Doc_Data_____ := Date()
      oBoleto:Vencimento___ := STOD( '20121010' )
      oBoleto:Valor________ := ( 13.37 * 4 )
      oBoleto:Protesto_Dias := 0
      oBoleto:Multa_Auto___ := 2
      oBoleto:Juros_Mes____ := 2
      oBoleto:Numero_Vias__ := 2
      oBoleto:Local_Pagamen := { "Pague preferencialmente nas Agências Lotéricas", "Pagavel em qualquer banco até o limite da data de vencimento" }
      oBoleto:Instrucoes___ := { "Desconto de 5% se pago até o dia " + Tran( Date()+10, '@E' ), "Não receber após 30 dias da data de vencimento" }
      oBoleto:Demonstrativo := { "Exiba detalhes importantes para o usuario", '', 'Valores em cobrança', '', 'Contratos', '', 'Informações úteis', '', 'Etc...' }
      oBoleto:Beneficiario_ := { "Beneficiario: CNPJ", "Beneficiario: Nome", "Beneficiario: Endereço ( Opcional )" }
      oBoleto:Pagador______ := { "Pagador: CNPJ", "Pagador: Nome", "Pagador: Endereço Completo" }
      oBoleto:Avalista_____ := { "Avalista: CNPJ", "Avalista: Nome", "Avalista: Endereço ( Opcional )" }

      oBoleto:AddPage()

      // *---------------------------------------------------------------------*
      // CAIXA ECONOMICA FEDERAL
      // *---------------------------------------------------------------------*
      oBoleto:Banco________ := '104'
      oBoleto:Banco_Agencia := '1816'
      oBoleto:Banco_Ag_Dv__ := ''
      oBoleto:Banco_Ag_Un_A := ''
      oBoleto:Conta________ := '93780'
      oBoleto:Conta_DV_____ := '0'
      oBoleto:Conta_OP_____ := '003'
      oBoleto:Carteira_____ := 'SR'
      oBoleto:Carteira_Tipo := ''
      oBoleto:NossoNumero__ := '2400000000085318'
      oBoleto:Doc_Origem___ := 'NFe'
      oBoleto:Prefixo______ := ''
      oBoleto:Prefixo_DV___ := ''
      oBoleto:Doc_Numero___ := '1161329'
      oBoleto:Doc_Aceite___ := 'N'
      oBoleto:Doc_Especie__ := 'R$'
      oBoleto:Doc_Data_____ := Date()
      oBoleto:Vencimento___ := Date()+30
      oBoleto:Valor________ := ( 13.37 * 5 )
      oBoleto:Protesto_Dias := 0
      oBoleto:Multa_Auto___ := 2
      oBoleto:Juros_Mes____ := 2
      oBoleto:Numero_Vias__ := 3
      oBoleto:Local_Pagamen := { "Pague preferencialmente nas Agências Lotéricas", "Pagavel em qualquer banco até o limite da data de vencimento" }
      oBoleto:Instrucoes___ := { "Desconto de 5% se pago até o dia " + Tran( Date()+15, '@E' ), "Não receber após 30 dias da data de vencimento" }
      oBoleto:Demonstrativo := { "Exiba detalhes importantes para o usuario", '', 'Valores em cobrança', '', 'Contratos', '', 'Informações úteis', '', 'Etc...' }
      oBoleto:Beneficiario_ := { "Beneficiario: CNPJ", "Beneficiario: Nome", "Beneficiario: Endereço ( Opcional )" }
      oBoleto:Pagador______ := { "Pagador: CNPJ", "Pagador: Nome", "Pagador: Endereço Completo" }
      oBoleto:Avalista_____ := { "Avalista: CNPJ", "Avalista: Nome", "Avalista: Endereço ( Opcional )" }

      oBoleto:AddPage()

      // *---------------------------------------------------------------------*
      // BRADESCO
      // *---------------------------------------------------------------------*
      oBoleto:Banco________ := '237'
      oBoleto:Banco_Agencia := '2747'
      oBoleto:Banco_Ag_Dv__ := '2'
      oBoleto:Banco_Ag_Un_A := ''
      oBoleto:Conta________ := '1453'
      oBoleto:Conta_DV_____ := '2'
      oBoleto:Conta_OP_____ := ''
      oBoleto:Carteira_____ := '18'
      oBoleto:Carteira_Tipo := ''
      oBoleto:NossoNumero__ := '12345'
      oBoleto:Doc_Origem___ := 'NFe'
      oBoleto:Prefixo______ := ''
      oBoleto:Prefixo_DV___ := ''
      oBoleto:Doc_Numero___ := '00001234'
      oBoleto:Doc_Aceite___ := 'N'
      oBoleto:Doc_Especie__ := 'R$'
      oBoleto:Doc_Data_____ := Date()
      oBoleto:Vencimento___ := STOD( '20121010' )
      oBoleto:Valor________ := ( 13.37 * 6 )
      oBoleto:Protesto_Dias := 0
      oBoleto:Multa_Auto___ := 2
      oBoleto:Juros_Mes____ := 2
      oBoleto:Numero_Vias__ := 3
      oBoleto:Local_Pagamen := { "Pagavel em qualquer banco até o limite da data de vencimento" }
      oBoleto:Instrucoes___ := { "Desconto de 5% se pago até o dia " + Tran( Date()+10, '@E' ), "Não receber após 30 dias da data de vencimento" }
      oBoleto:Demonstrativo := { "Exiba detalhes importantes para o usuario", '', 'Valores em cobrança', '', 'Contratos', '', 'Informações úteis', '', 'Etc...' }
      oBoleto:Beneficiario_ := { "Beneficiario: CNPJ", "Beneficiario: Nome", "Beneficiario: Endereço ( Opcional )" }
      oBoleto:Pagador______ := { "Pagador: CNPJ", "Pagador: Nome", "Pagador: Endereço Completo" }
      oBoleto:Avalista_____ := { "Avalista: CNPJ", "Avalista: Nome", "Avalista: Endereço ( Opcional )" }

      oBoleto:AddPage()

      // *---------------------------------------------------------------------*
      // BANCO ITAÚ
      // *---------------------------------------------------------------------*
      oBoleto:Banco________ := '341'
      oBoleto:Banco_Agencia := '2525'
      oBoleto:Banco_Ag_Dv__ := ''
      oBoleto:Banco_Ag_Un_A := ''
      oBoleto:Conta________ := '00542'
      oBoleto:Conta_DV_____ := '3'
      oBoleto:Conta_OP_____ := ''
      oBoleto:Carteira_____ := '175'
      oBoleto:Carteira_Tipo := ''
      oBoleto:NossoNumero__ := '15887235'
      oBoleto:Doc_Origem___ := 'NFe'
      oBoleto:Prefixo______ := ''
      oBoleto:Prefixo_DV___ := ''
      oBoleto:Doc_Numero___ := '00001234'
      oBoleto:Doc_Aceite___ := 'N'
      oBoleto:Doc_Especie__ := 'R$'
      oBoleto:Doc_Data_____ := Date()
      oBoleto:Vencimento___ := Date()+30
      oBoleto:Valor________ := ( 13.37 * 7 )
      oBoleto:Protesto_Dias := 0
      oBoleto:Multa_Auto___ := 2
      oBoleto:Juros_Mes____ := 2
      oBoleto:Numero_Vias__ := 2
      oBoleto:Local_Pagamen := { "Pagavel em qualquer banco até o limite da data de vencimento" }
      oBoleto:Instrucoes___ := { "Desconto de 5% se pago até o dia " + Tran( Date()+10, '@E' ), "Não receber após 30 dias da data de vencimento" }
      oBoleto:Demonstrativo := { "Exiba detalhes importantes para o usuario", '', 'Valores em cobrança', '', 'Contratos', '', 'Informações úteis', '', 'Etc...' }
      oBoleto:Beneficiario_ := { "Beneficiario: CNPJ", "Beneficiario: Nome", "Beneficiario: Endereço ( Opcional )" }
      oBoleto:Pagador______ := { "Pagador: CNPJ", "Pagador: Nome", "Pagador: Endereço Completo" }
      oBoleto:Avalista_____ := { "Avalista: CNPJ", "Avalista: Nome", "Avalista: Endereço ( Opcional )" }

      oBoleto:AddPage()

      // *---------------------------------------------------------------------*
      // BANCO HSBC
      // *---------------------------------------------------------------------*
      oBoleto:Banco________ := '399'
      oBoleto:Banco_Agencia := ''
      oBoleto:Banco_Ag_Dv__ := ''
      oBoleto:Banco_Ag_Un_A := ''
      oBoleto:Conta________ := ''
      oBoleto:Conta_DV_____ := ''
      oBoleto:Conta_OP_____ := ''
      oBoleto:Carteira_____ := 'CNR'
      oBoleto:Carteira_Tipo := ''
      oBoleto:NossoNumero__ := '44346353158'
      oBoleto:Doc_Origem___ := 'NFe'
      oBoleto:Prefixo______ := '3448614'
      oBoleto:Prefixo_DV___ := ''
      oBoleto:Doc_Numero___ := '00001234'
      oBoleto:Doc_Aceite___ := 'N'
      oBoleto:Doc_Especie__ := 'R$'
      oBoleto:Doc_Data_____ := Date()
      oBoleto:Vencimento___ := Date()+30
      oBoleto:Valor________ := ( 13.37 * 8 )
      oBoleto:Protesto_Dias := 0
      oBoleto:Multa_Auto___ := 2
      oBoleto:Juros_Mes____ := 2
      oBoleto:Numero_Vias__ := 3
      oBoleto:Local_Pagamen := { "Pagavel em qualquer banco até o limite da data de vencimento" }
      oBoleto:Instrucoes___ := { "Desconto de 5% se pago até o dia " + Tran( Date()+10, '@E' ), "Não receber após 30 dias da data de vencimento" }
      oBoleto:Demonstrativo := { "Exiba detalhes importantes para o usuario", '', 'Valores em cobrança', '', 'Contratos', '', 'Informações úteis', '', 'Etc...' }
      oBoleto:Beneficiario_ := { "Beneficiario: CNPJ", "Beneficiario: Nome", "Beneficiario: Endereço ( Opcional )" }
      oBoleto:Pagador______ := { "Pagador: CNPJ", "Pagador: Nome", "Pagador: Endereço Completo" }
      oBoleto:Avalista_____ := { "Avalista: CNPJ", "Avalista: Nome", "Avalista: Endereço ( Opcional )" }

      oBoleto:AddPage()

      // *---------------------------------------------------------------------*
      // BANCO SAFRA
      // *---------------------------------------------------------------------*
      oBoleto:Banco________ := '422'
      oBoleto:Banco_Agencia := '0123'
      oBoleto:Banco_Ag_Dv__ := ''
      oBoleto:Banco_Ag_Un_A := ''
      oBoleto:Conta________ := '00542'
      oBoleto:Conta_DV_____ := '3'
      oBoleto:Conta_OP_____ := ''
      oBoleto:Carteira_____ := '00'
      oBoleto:Carteira_Tipo := ''
      oBoleto:NossoNumero__ := '15887235'
      oBoleto:Doc_Origem___ := 'NFe'
      oBoleto:Prefixo______ := '123456'
      oBoleto:Prefixo_DV___ := '7'
      oBoleto:Doc_Numero___ := '00001234'
      oBoleto:Doc_Aceite___ := 'N'
      oBoleto:Doc_Especie__ := 'R$'
      oBoleto:Doc_Data_____ := Date()
      oBoleto:Vencimento___ := Date()+30
      oBoleto:Valor________ := ( 13.37 * 9 )
      oBoleto:Protesto_Dias := 0
      oBoleto:Multa_Auto___ := 2
      oBoleto:Juros_Mes____ := 2
      oBoleto:Numero_Vias__ := 2
      oBoleto:Local_Pagamen := { "Pagavel em qualquer banco até o limite da data de vencimento" }
      oBoleto:Instrucoes___ := { "Desconto de 5% se pago até o dia " + Tran( Date()+10, '@E' ), "Não receber após 30 dias da data de vencimento" }
      oBoleto:Demonstrativo := { "Exiba detalhes importantes para o usuario", '', 'Valores em cobrança', '', 'Contratos', '', 'Informações úteis', '', 'Etc...' }
      oBoleto:Beneficiario_ := { "Beneficiario: CNPJ", "Beneficiario: Nome", "Beneficiario: Endereço ( Opcional )" }
      oBoleto:Pagador______ := { "Pagador: CNPJ", "Pagador: Nome", "Pagador: Endereço Completo" }
      oBoleto:Avalista_____ := { "Avalista: CNPJ", "Avalista: Nome", "Avalista: Endereço ( Opcional )" }

      oBoleto:AddPage()

      // *---------------------------------------------------------------------*
      // BANCO SICREDI
      // *---------------------------------------------------------------------*
      oBoleto:Banco________ := '748'
      oBoleto:Banco_Agencia := '0123'
      oBoleto:Banco_Ag_Dv__ := ''
      oBoleto:Banco_Ag_Un_A := '22'
      oBoleto:Conta________ := '12345'
      oBoleto:Conta_DV_____ := '9'
      oBoleto:Conta_OP_____ := ''
      oBoleto:Carteira_____ := '00'
      oBoleto:Carteira_Tipo := '3'
      oBoleto:NossoNumero__ := '12345'
      oBoleto:Doc_Origem___ := 'NFe'
      oBoleto:Prefixo______ := ''
      oBoleto:Prefixo_DV___ := ''
      oBoleto:Doc_Numero___ := '00001234'
      oBoleto:Doc_Aceite___ := 'N'
      oBoleto:Doc_Especie__ := 'R$'
      oBoleto:Doc_Data_____ := Date()
      oBoleto:Vencimento___ := Date()+30
      oBoleto:Valor________ := ( 13.37 * 10 )
      oBoleto:Protesto_Dias := 0
      oBoleto:Multa_Auto___ := 2
      oBoleto:Juros_Mes____ := 2
      oBoleto:Numero_Vias__ := 3
      oBoleto:Local_Pagamen := { "Pagavel em qualquer banco até o limite da data de vencimento" }
      oBoleto:Instrucoes___ := { "Desconto de 5% se pago até o dia " + Tran( Date()+10, '@E' ), "Não receber após 30 dias da data de vencimento" }
      oBoleto:Demonstrativo := { "Exiba detalhes importantes para o usuario", '', 'Valores em cobrança', '', 'Contratos', '', 'Informações úteis', '', 'Etc...' }
      oBoleto:Beneficiario_ := { "Beneficiario: CNPJ", "Beneficiario: Nome", "Beneficiario: Endereço ( Opcional )" }
      oBoleto:Pagador______ := { "Pagador: CNPJ", "Pagador: Nome", "Pagador: Endereço Completo" }
      oBoleto:Avalista_____ := { "Avalista: CNPJ", "Avalista: Nome", "Avalista: Endereço ( Opcional )" }

      oBoleto:AddPage()

      oBoleto:Finish( .T. )

Return

// *---------------------------------------------------------------------*
// F_Set_Desktop()
// *---------------------------------------------------------------------*
PROCEDURE F_Set_Desktop()

   REQUEST HB_LANG_PT
   REQUEST HB_CODEPAGE_PT850

   REQUEST HB_GT_WVG_DEFAULT
   REQUEST HB_GT_WVT
   REQUEST HB_GT_WIN

   *---------------------------------------------------------------------------*
   * ANO COM 04 DIGITOS
   *---------------------------------------------------------------------------*
   SET CENTURY ON

   *---------------------------------------------------------------------------*
   * DATAS: -50 DATA ATUAL + 50
   *---------------------------------------------------------------------------*
   SET EPOCH TO YEAR( DATE() ) - 50

   SETMODE( 33, 112 )

   SetColor( 'N/W' )

   CLS

   // hb_langSelect( hb_UserLang(), "PT850" ) // .OR.
   // HB_LANGSELECT( 'pt-BR', "PT850" )
   hb_cdpSelect( "PT850" )

   Set ( _SET_SCOREBOARD, .F. )
   Set ( _SET_EVENTMASK, INKEY_ALL - INKEY_MOVE + HB_INKEY_GTEVENT )

   *---------------------------------------------------------------------------*
   // CONFIGURAÇÕES REGIONAIS / VIDEO
   *---------------------------------------------------------------------------*
   hb_gtInfo( HB_GTI_CLIPBOARDDATA )
   hb_gtInfo( HB_GTI_SELECTCOPY, .T. )
   hb_gtInfo( HB_GTI_MOUSESTATUS, 1 )
   hb_gtInfo( HB_GTI_MAXIMIZED, .F. )
   hb_gtInfo( HB_GTI_CLOSABLE, .T. )
   hb_gtInfo( HB_GTI_ISGRAPHIC, .T. )
   hb_gtInfo( HB_GTI_STDERRCON, .T. )

RETURN
