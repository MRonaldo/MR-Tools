#include "hbclass.ch"
#include "harupdf.ch"
#include "hbzebra.ch"

#define Pdf_Instrucoes    8
#define Pdf_Demonstr__   20

#define Bol_Start_Date    STOD( "19971007" )

#define Font_Fixa_____    "Courier"
#define Font_Variavel_    "Helvetica"
#define Font_Code_Page    'WinAnsiEncoding'

#define Font_Small____   06
#define Font_Normal___   09
#define Font_Large____   12

#define Page_Left_____    1
#define Page_Line_Size    2
#define Page_Pos_S00__   10
#define Page_Pos_S01__   11
#define Page_Pos_v____   12
#define Page_Pos_z____   13

// *----------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// Classe: MR_Boleto
//
// *----------------------------------------------------------------------------*
Create Class MR_Boleto

   // *-------------------------------------------------------------------------*
   // Objeto: HaruPDF
   // *-------------------------------------------------------------------------*
   DATA o_Pdf

   // *-------------------------------------------------------------------------*
   // Objeto: Pagina PDF
   // *-------------------------------------------------------------------------*
   DATA oPage

   // *-------------------------------------------------------------------------*
   // Arquivo PDF
   // *-------------------------------------------------------------------------*
   DATA oFile

   // *-------------------------------------------------------------------------*
   // Fonte para Impressao
   // *-------------------------------------------------------------------------*
   DATA oFont_f______
   DATA oFont_v______

   // *-------------------------------------------------------------------------*
   // Beneficiario: Banco
   // *-------------------------------------------------------------------------*
   DATA Banco________   INIT '001'
   DATA Banco_Nome___   INIT ''
   DATA Banco_Dv_____   INIT '0'
   DATA Banco_Agencia   INIT ''
   DATA Banco_Ag_Dv__   INIT ''
   DATA Banco_Ag_Un_A   INIT ''

   DATA Ag_Cd_Benefic   INIT ''

   DATA Moeda________   INIT '9'

   // *-------------------------------------------------------------------------*
   // Local de Pagamento
   // *-------------------------------------------------------------------------*
   DATA Local_Pagamen   INIT ''

   // *-------------------------------------------------------------------------*
   // Beneficiario: Conta
   // *-------------------------------------------------------------------------*
   DATA Conta________   INIT ''
   DATA Conta_DV_____   INIT ''
   DATA Conta_OP_____   INIT ''

   // *-------------------------------------------------------------------------*
   // Beneficiario: Prefixo ( Parte Integrante do Nosso Numero )
   // *-------------------------------------------------------------------------*
   DATA Prefixo______   INIT '0'
   DATA Prefixo_DV___   INIT ''

   // *-------------------------------------------------------------------------*
   // Beneficiario: Carteira
   // *-------------------------------------------------------------------------*
   DATA Carteira_____   INIT ''
   DATA Carteira_Tipo   INIT ''
   DATA Cart_Variacao   INIT '019'

   // *-------------------------------------------------------------------------*
   // Beneficiario: Nosso Numero
   // *-------------------------------------------------------------------------*
   DATA NossoNumero__   INIT ''
   DATA NossoNumer_DV   INIT ''
   DATA NossoNumero_z   INIT ''

   // *-------------------------------------------------------------------------*
   // Boleto: Linha Digitavel
   // *-------------------------------------------------------------------------*
   DATA Campo_Livre__   INIT ''
   DATA Ln_Digitavel_   INIT REPL( '0', 44 )

   // *-------------------------------------------------------------------------*
   // Boleto: Representacao Numerica do Codigo de Barras
   // *-------------------------------------------------------------------------*
   DATA Cod_Barras___   INIT ''
   DATA Cod_Barras_DV   INIT ''

   // *-------------------------------------------------------------------------*
   // Boleto: Origem do valor ( NF, NFe, NFSe, Duplicata, Promissoria, etc... )
   // *-------------------------------------------------------------------------*
   DATA Doc_Origem___   INIT ''
   DATA Doc_Numero___   INIT ''
   DATA Doc_Data_____   INIT DATE()
   DATA Doc_Aceite___   INIT ''
   DATA Doc_Especie__   INIT ''

   // *-------------------------------------------------------------------------*
   // Boleto: Dados Base
   // *-------------------------------------------------------------------------*
   DATA Vencimento___   INIT DATE()
   DATA Vencim_Fator_   INIT DATE()
   DATA Valor________   INIT 0
   DATA Multa_Auto___   INIT 0
   DATA Juros_Mes____   INIT 0
   DATA Numero_Vias__   INIT 2
   DATA Protesto_Dias   INIT 0

   // *-------------------------------------------------------------------------*
   // Boleto: Instrucoes: {} ( Exemplo: instrucoes e discriminacao da Cobranca)
   // *-------------------------------------------------------------------------*
   DATA Instrucoes___   INIT AFILL( ARRAY( Pdf_Instrucoes ), '' )
   DATA Demonstrativo   INIT AFILL( ARRAY( Pdf_Demonstr__ ), '' )

   // *-------------------------------------------------------------------------*
   // Boleto: Beneficiario {}
   // *-------------------------------------------------------------------------*
   DATA Beneficiario_   INIT AFILL( ARRAY( 4 ), '' )

   // *-------------------------------------------------------------------------*
   // Boleto: Pagador {}
   // *-------------------------------------------------------------------------*
   DATA Pagador______   INIT AFILL( ARRAY( 7 ), '' )

   // *-------------------------------------------------------------------------*
   // Boleto: avalista {}
   // *-------------------------------------------------------------------------*
   DATA Avalista_____   INIT AFILL( ARRAY( 4 ), '' )

   // *-------------------------------------------------------------------------*
   // Boleto: Arquivos de Remessa e Retorno
   // *-------------------------------------------------------------------------*
   DATA Cnab_Data____   INIT { '', '' }
   DATA Cnab_Lote____   INIT 0
   DATA Cnab_Path____   INIT '\TEMP\'
   DATA Cnab_Remessa_   INIT .F.
   DATA Cnab_Rem_data   INIT DATE()

   // *-------------------------------------------------------------------------*
   // Representacao grafica para o Codigo de Barras
   // *-------------------------------------------------------------------------*
   DATA hZebra_______

   // *-------------------------------------------------------------------------*
   // Dimensoes da Pagina utilizada
   // *-------------------------------------------------------------------------*
   DATA Page_Height__   INIT 0
   DATA Page_Width___   INIT 0

   // *-------------------------------------------------------------------------*
   // Metodos da Classe
   // *-------------------------------------------------------------------------*

   Method AddPage()
   Method Banco_001()
   Method Banco_033()
   Method Banco_085()
   Method Banco_104()
   Method Banco_237()
   Method Banco_341()
   Method Banco_399()
   Method Banco_422()
   Method Banco_748()
   Method DC_Mod10( c_Banco, mNMOG )
   Method DC_Mod11( c_Banco, mBSDG, mFGCB, mNMOG, lMult10 )
   Method DC_ModEsp( c_Banco, mNMOG )
   Method Draw_Image( nLeft, nTop, nWidth, nHeight )
   Method Draw_Line( x, y, w, z, nPenSize )
   Method Draw_Text( nLeft, nTop, cTxt, oFont, nSize )
#ifdef __XHARBOUR__
   Method Draw_Zebra( x, y, w, z )
#else
   Method Draw_Zebra( ... )
#endif
   Method Execute()
   Method Finish( lOpen )
   Method Interleaved_2of5()
   Method New( cFilePdf ) Constructor
   Method Only_Numbers( cStr )
   Method Update()

   // Base code from: Jose Quintas
   METHOD Cnab_Add()
   METHOD DigitoDoc( cDocNumero, cCarteira )
   METHOD Cnab_Save()

   EndClass

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:New( cFilePdf )
//
// *-------------------------------------------------------------------------*
METHOD New( cFilePdf ) Class MR_Boleto

   ::o_Pdf := HPDF_New()
   ::oFile := cFilePdf

   HPDF_SetCompressionMode( ::o_Pdf, HPDF_COMP_ALL )

   // *-------------------------------------------------------------------------*
   // Fonte Tamanho Fixo
   // *-------------------------------------------------------------------------*
   ::oFont_f______ := HPDF_GetFont( ::o_Pdf, Font_Fixa_____, Font_Code_Page )

   // *-------------------------------------------------------------------------*
   // Fonte Espaçamento Variavel
   // *-------------------------------------------------------------------------*
   ::oFont_v______ := HPDF_GetFont( ::o_Pdf, Font_Variavel_, Font_Code_Page )

   Return( Self )

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:AddPage()
//
// *-------------------------------------------------------------------------*
METHOD AddPage() Class MR_Boleto
   LOCAL aPos := Afill( Array( 20 ), 0 )
   LOCAL i
   LOCAL cAux

   ::Update()

   ::Execute()

   ::oPage := HPDF_AddPage( ::o_Pdf )

   HPDF_Page_SetSize( ::oPage, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT )

   ::Page_Height__ := HPDF_Page_GetHeight( ::oPage )
   ::Page_Width___ := HPDF_Page_GetWidth( ::oPage )

   // *-------------------------------------------------------------------------*
   // Dimensoes para objetos
   // *-------------------------------------------------------------------------*
   aPos[ Page_Left_____ ] += ( ::Page_Width___ * 0.033 )
   aPos[ Page_Line_Size ] += ( ::Page_Width___ - aPos[ Page_Left_____ ] )

   // *-------------------------------------------------------------------------*
   // 1a Via - Controle do Beneficiario
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_S01__ ] += ( ::Page_Height__ * 0.026 )
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.044 )

   IF ::Numero_Vias__ > 2

   // *-------------------------------------------------------------------------*
   // Codigo do Banco e Linha Digitavel
   // *-------------------------------------------------------------------------*
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.370 ), aPos[ Page_Pos_v____ ], TRAN( ::Ln_Digitavel_, "@!"), ::oFont_v______, Font_Large____ )
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.265 ), aPos[ Page_Pos_v____ ], TRAN( ::Banco________ + ::Banco_Dv_____ , '@R 999-!' ), ::oFont_v______, Font_Normal___ * 2 )

   // *-------------------------------------------------------------------------*
   // Logo do Banco
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Image( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], 150/2, 40/2 )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Linha Vertical
   // *-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.255 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.255 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.355 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.355 ), aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Save last Vertical Pos TO
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_S00__ ] := aPos[ Page_Pos_v____ ]

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Beneficiario:', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Vencimento', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   cAux := TRAN( ::Beneficiario_[ 2 ], '@A')
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   cAux := TRAN( ::Vencimento___, "@E" )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.750 ), aPos[ Page_Pos_v____ ] , cAux, ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + 0, aPos[ Page_Pos_v____ ], TRAN( 'Agencia/Codigo do Beneficiario', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.200 ), aPos[ Page_Pos_v____ ], TRAN( 'Numero do Documento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.400 ), aPos[ Page_Pos_v____ ], TRAN( 'Nosso Numero', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(=) Valor do Documento', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   cAux := ::Ag_Cd_Benefic
   ::Draw_Text( aPos[ Page_Left_____ ] + 0, aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   cAux := TRAN( ::Doc_Numero___, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.200 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   cAux := TRAN( ::NossoNumero_z, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.400 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   cAux := TRAN( ::Valor________, '@E 999,999,999,999.99' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.800 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Linha Vertical *
   // *-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_S00__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Pagador:', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.002 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( 'CNPJ/CPF: ' + ::Pagador______[ 1 ], '@A' ), ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( ::Pagador______[ 2 ], '@A' ), ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   cAux := ::Pagador______[ 3 ]
   IF !( EMPTY( ::Pagador______[ 4 ] ) )
      cAux += ', ' + ::Pagador______[ 4 ]
   ENDIF
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( cAux, '@A' ), ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   cAux := ::Pagador______[ 5 ]
   IF !( EMPTY( ::Pagador______[ 6 ] ) )
      cAux += ', ' + ::Pagador______[ 6 ]
   ENDIF
   IF !( EMPTY( ::Pagador______[ 7 ] ) )
      cAux += ', CEP.: ' + ::Pagador______[ 7 ]
   ENDIF
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( cAux, '@A' ), ::oFont_v______, Font_Normal___ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'VIA PARA CONTROLE DO BENEFICIARIO', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.026 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ] * 0.440, aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( aPos[ Page_Line_Size ] * 0.560 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( aPos[ Page_Line_Size ] * 0.455 ), aPos[ Page_Pos_v____ ] + ( ::Page_Height__ * 0.002 ), TRAN( 'Recorte Aqui', '@A' ), ::oFont_v______, Font_Small____ )


   // *-------------------------------------------------------------------------*
   // 2a Via - Recibo do Pagador
   // *-------------------------------------------------------------------------*

   // *-------------------------------------------------------------------------*
   // Coordenadas
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_S01__ ] := ( ::Page_Height__ * 0.170 )
   aPos[ Page_Pos_v____ ] := ( ::Page_Height__ * 0.186 )

   ENDIF

   // *-------------------------------------------------------------------------*
   // Codigo do Banco e Linha Digitavel
   // *-------------------------------------------------------------------------*
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.370 ), aPos[ Page_Pos_v____ ], TRAN( ::Ln_Digitavel_, "@!"), ::oFont_v______, Font_Large____ )
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.265 ), aPos[ Page_Pos_v____ ], TRAN( ::Banco________ + ::Banco_Dv_____ , '@R 999-!' ), ::oFont_v______, Font_Normal___ * 2 )

   // *-------------------------------------------------------------------------*
   // Logo do Banco
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Image( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], 150/2, 40/2 )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Linha Vertical
   // *-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.255 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.255 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.355 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.355 ), aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Save last Vertical Pos TO
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_S00__ ] := aPos[ Page_Pos_v____ ]

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Local de Pagamento:', '@A' ), ::oFont_v______, Font_Small____ )
   IF !( EMPTY( ::Local_Pagamen[ 2 ] ) )
      cAux := TRAN( ::Local_Pagamen[ 1 ], '@A')
      ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_v____ ] , cAux, ::oFont_v______, Font_Small____ )
   ENDIF
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Vencimento', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   IF !( EMPTY( ::Local_Pagamen[ 2 ] ) )
      cAux := TRAN( ::Local_Pagamen[ 2 ], '@A')
      ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_v____ ] , cAux, ::oFont_v______, Font_Small____ )
   ELSE
      cAux := TRAN( ::Local_Pagamen[ 1 ], '@A')
      ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] , cAux, ::oFont_v______, Font_Normal___ )
   ENDIF
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.750 ), aPos[ Page_Pos_v____ ] , TRAN( ::Vencimento___, "@E"), ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Beneficiario:', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.060 ), aPos[ Page_Pos_v____ ], TRAN( 'CNPJ/CPF: ' + ::Beneficiario_[ 1 ] + SPACE( 3 ) + ::Beneficiario_[ 3 ], '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Agencia/Codigo do Beneficiario', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   cAux := TRAN( ::Beneficiario_[ 2 ], '@A')
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := ::Ag_Cd_Benefic
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.750 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Save last Vertical Pos
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_S01__ ] := aPos[ Page_Pos_v____ ]

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Data do Documento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.150 ), aPos[ Page_Pos_v____ ], TRAN( 'Numero do Documento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.320 ), aPos[ Page_Pos_v____ ], TRAN( 'Especie Documento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.450 ), aPos[ Page_Pos_v____ ], TRAN( 'Aceite', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.520 ), aPos[ Page_Pos_v____ ], TRAN( 'Data de Processamento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Nosso Numero', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   cAux := TRAN( ::Doc_Data_____, '@E' )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::Doc_Numero___, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.150 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::Doc_Origem___, '@A' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.320 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::Doc_Aceite___, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.450 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( DATE(), '@E' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.520 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::NossoNumero_z, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.750 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Linha Vertical
   // *-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.145 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.145 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.315 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.315 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.445 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.445 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.515 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.515 ), aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Linha Vertical *
   // *-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_S00__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Demonstrativo da Cobranca:', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Demonstrativo das Despesas
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.004 )
   FOR i := 1 TO ( Pdf_Demonstr__ + IIF( ::Numero_Vias__ > 2, 0, 17 ) )
      aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
      ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( ::Demonstrativo[ i ], '@A' ), ::oFont_f______, Font_Small____ )
   NEXT

   // *-------------------------------------------------------------------------*
   // Linha Horizontal
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Save last Vertical Pos
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_S00__ ] := aPos[ Page_Pos_v____ ]

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Instrucoes: ( Todas as informacoes impressas neste documento, sao de exclusiva responsabilidade do Beneficiario )', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(=) Valor do Documento', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   cAux := TRAN( ::Valor________, '@E 999,999,999,999.99' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.800 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(-) Desconto/Abatimento', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto: Instrucoes
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_z____ ] := aPos[ Page_Pos_v____ ]
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_z____ ], 'Multa Automatica - ' + ::Doc_Especie__, ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_z____ ], TRAN( ROUND( ::Valor________ * ( ::Multa_Auto___ / 100 ), 2 ), '@E 999,999,999.99' ) + ' : Acrescer ao valor total para pagamento em atrazo.', ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto: Instrucoes
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_z____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_z____ ], 'Juros de Mora de - ' + ::Doc_Especie__, ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_z____ ], TRAN( ROUND( ::Valor________ * ( ( ( ::Juros_Mes____ * 12 ) / 365 ) / 100 ), 2 ), '@E 999,999,999.99' ) + ' / Dia.', ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Demonstrativo das Despesas
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_z____ ] += ( ::Page_Height__ * 0.010 )
   FOR i := 1 TO Pdf_Instrucoes
      aPos[ Page_Pos_z____ ] += ( ::Page_Height__ * 0.008 )
      ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_z____ ], TRAN( ::Instrucoes___[ i ], '@A' ), ::oFont_v______, Font_Small____ )
   NEXT

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(-) Outras Deducoes', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(+) Mora / Multa', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(+) Outros Acrescimos', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(=) Valor Cobrado', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Linha Vertical
   // *-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_S00__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Pagador:', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.002 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( 'CNPJ/CPF: ' + ::Pagador______[ 1 ], '@A' ), ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( ::Pagador______[ 2 ], '@A' ), ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   cAux := ::Pagador______[ 3 ]
   IF !( EMPTY( ::Pagador______[ 4 ] ) )
      cAux += ', ' + ::Pagador______[ 4 ]
   ENDIF
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( cAux, '@A' ), ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   cAux := ::Pagador______[ 5 ]
   IF !( EMPTY( ::Pagador______[ 6 ] ) )
      cAux += ', ' + ::Pagador______[ 6 ]
   ENDIF
   IF !( EMPTY( ::Pagador______[ 7 ] ) )
      cAux += ', CEP.: ' + ::Pagador______[ 7 ]
   ENDIF

   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( cAux, '@A' ), ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Pagador / Avalista:', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.000 )
   // *-------------------------------------------------------------------------*
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_v____ ], TRAN( ::Avalista_____[ 1 ] + SPACE( 3 ) + ::Avalista_____[ 2 ] +  SPACE( 3 ) + ::Avalista_____[ 3 ], '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'MR Boleto: Titulo processado e impresso pelo Beneficiario', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Autenticacao Mecanica - Recibo do Pagador', '@A' ), ::oFont_v______, Font_Small____ )


   // *-------------------------------------------------------------------------*
   // 3a Via - Ficha de Compensacao
   // *-------------------------------------------------------------------------*

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] := ( ::Page_Height__ * 0.655 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ] * 0.440, aPos[ Page_Pos_v____ ], 0.6 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( aPos[ Page_Line_Size ] * 0.560 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( aPos[ Page_Line_Size ] * 0.455 ), aPos[ Page_Pos_v____ ] + ( ::Page_Height__ * 0.002 ), TRAN( 'Recorte Aqui', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Coordenadas
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_S01__ ] := ( ::Page_Height__ * 0.670 )
   aPos[ Page_Pos_v____ ] := ( ::Page_Height__ * 0.686 )

   // *-------------------------------------------------------------------------*
   // Codigo do Banco e Linha Digitavel
   // *-------------------------------------------------------------------------*
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.370 ), aPos[ Page_Pos_v____ ], TRAN( ::Ln_Digitavel_, "@!"), ::oFont_v______, Font_Large____ )
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.265 ), aPos[ Page_Pos_v____ ], TRAN( ::Banco________ + ::Banco_Dv_____ , '@R 999-!' ), ::oFont_v______, Font_Normal___ * 2 )

   // *-------------------------------------------------------------------------*
   // Logo do Banco
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Image( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], 150/2, 40/2 )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Linha Vertical
   // *-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.255 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.255 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.355 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.355 ), aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Save last Vertical Pos TO
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_S00__ ] := aPos[ Page_Pos_v____ ]

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Local de Pagamento', '@A' ), ::oFont_v______, Font_Small____ )
   IF !( EMPTY( ::Local_Pagamen[ 2 ] ) )
      cAux := TRAN( ::Local_Pagamen[ 1 ], '@A')
      ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_v____ ] , cAux, ::oFont_v______, Font_Small____ )
   ENDIF
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Vencimento', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   IF !( EMPTY( ::Local_Pagamen[ 2 ] ) )
      cAux := TRAN( ::Local_Pagamen[ 2 ], '@A')
      ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_v____ ] , cAux, ::oFont_v______, Font_Small____ )
   ELSE
      cAux := TRAN( ::Local_Pagamen[ 1 ], '@A')
      ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] , cAux, ::oFont_v______, Font_Normal___ )
   ENDIF
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.750 ), aPos[ Page_Pos_v____ ] , TRAN( ::Vencimento___, "@E"), ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Beneficiario:', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.060 ), aPos[ Page_Pos_v____ ], TRAN( 'CNPJ/CPF: ' + ::Beneficiario_[ 1 ] + SPACE( 3 ) + ::Beneficiario_[ 3 ], '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Agencia/Codigo do Beneficiario', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   cAux := TRAN( ::Beneficiario_[ 2 ], '@A')
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := ::Ag_Cd_Benefic
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.750 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Save last Vertical Pos
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_S01__ ] := aPos[ Page_Pos_v____ ]

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Data do Documento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.150 ), aPos[ Page_Pos_v____ ], TRAN( 'Numero do Documento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.320 ), aPos[ Page_Pos_v____ ], TRAN( 'Especie Documento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.450 ), aPos[ Page_Pos_v____ ], TRAN( 'Aceite', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.520 ), aPos[ Page_Pos_v____ ], TRAN( 'Data de Processamento', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Nosso Numero', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   cAux := TRAN( ::Doc_Data_____, '@E' )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::Doc_Numero___, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.150 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::Doc_Origem___, '@A' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.320 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::Doc_Aceite___, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.450 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( DATE(), '@E' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.520 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )
   cAux := TRAN( ::NossoNumero_z, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.750 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Linha Vertical
   // *-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.145 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.145 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.315 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.315 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.445 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.445 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.515 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.515 ), aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Save last Vertical Pos
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_S01__ ] := aPos[ Page_Pos_v____ ]

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Uso do Banco', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.220 ), aPos[ Page_Pos_v____ ], TRAN( 'Carteira', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.320 ), aPos[ Page_Pos_v____ ], TRAN( 'Especie', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.420 ), aPos[ Page_Pos_v____ ], TRAN( 'Quantidade', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.520 ), aPos[ Page_Pos_v____ ], TRAN( 'Valor', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(=) Valor do Documento', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   cAux := TRAN( ::Carteira_____, '@!' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.220 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   cAux := TRAN( ::Doc_Especie__, '@A' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.320 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   cAux := TRAN( ::Valor________, '@E 999,999,999,999.99' )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.800 ), aPos[ Page_Pos_v____ ], cAux, ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Linha Vertical
   // *-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.215 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.215 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.315 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.315 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.415 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.415 ), aPos[ Page_Pos_v____ ], 0.2 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.515 ), aPos[ Page_Pos_S01__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.515 ), aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Instrucoes: ( Todas as informacoes impressas neste documento, sao de exclusiva responsabilidade do Beneficiario )', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(-) Desconto/Abatimento', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto: Instrucoes
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_z____ ] := aPos[ Page_Pos_v____ ]
   aPos[ Page_Pos_z____ ] += ( ::Page_Height__ * 0.004 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_z____ ], 'Multa Automatica - ' + ::Doc_Especie__, ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_z____ ], TRAN( ROUND( ::Valor________ * ( ::Multa_Auto___ / 100 ), 2 ), '@E 999,999,999.99' ) + ' : Acrescer ao valor total para pagamento em atrazo.', ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto: Instrucoes
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_z____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_z____ ], 'Juros de Mora de - ' + ::Doc_Especie__, ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_z____ ], TRAN( ROUND( ::Valor________ * ( ( ( ::Juros_Mes____ * 12 ) / 365 ) / 100 ), 2 ), '@E 999,999,999.99' ) + ' / Dia.', ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Demonstrativo das Despesas
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_z____ ] += ( ::Page_Height__ * 0.004 )
   FOR i := 1 TO Pdf_Instrucoes
      aPos[ Page_Pos_z____ ] += ( ::Page_Height__ * 0.008 )
      ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_z____ ], TRAN( ::Instrucoes___[ i ], '@A' ), ::oFont_v______, Font_Small____ )
   NEXT

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(-) Outras Deducoes', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(+) Mora / Multa', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(+) Outros Acrescimos', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( '(=) Valor Cobrado', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Linha Vertical
   // *-------------------------------------------------------------------------*
   ::Draw_Line( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_S00__ ], aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.665 ), aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Pagador:', '@A' ), ::oFont_v______, Font_Small____ )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Codigo de Baixa:', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.002 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.002 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( 'CNPJ/CPF: ' + ::Pagador______[ 1 ], '@A' ), ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( ::Pagador______[ 2 ], '@A' ), ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   cAux := ::Pagador______[ 3 ]
   IF !( EMPTY( ::Pagador______[ 4 ] ) )
      cAux += ', ' + ::Pagador______[ 4 ]
   ENDIF
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( cAux, '@A' ), ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.010 )
   // *-------------------------------------------------------------------------*
   cAux := ::Pagador______[ 5 ]
   IF !( EMPTY( ::Pagador______[ 6 ] ) )
      cAux += ', ' + ::Pagador______[ 6 ]
   ENDIF
   IF !( EMPTY( ::Pagador______[ 7 ] ) )
      cAux += ', CEP.: ' + ::Pagador______[ 7 ]
   ENDIF

   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.010 )
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.050 ), aPos[ Page_Pos_v____ ], TRAN( cAux, '@A' ), ::oFont_v______, Font_Normal___ )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ], TRAN( 'Pagador / Avalista:', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados do Boleto ( 0.000 )
   // *-------------------------------------------------------------------------*
   ::Draw_Text( aPos[ Page_Left_____ ]+ ( ::Page_Width___ * 0.100 ), aPos[ Page_Pos_v____ ], TRAN( ::Avalista_____[ 1 ] + SPACE( 3 ) + ::Avalista_____[ 2 ] +  SPACE( 3 ) + ::Avalista_____[ 3 ], '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Linha Horizontal ( 0.003 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.003 )
   ::Draw_Line( aPos[ Page_Left_____ ], aPos[ Page_Pos_v____ ] ,  aPos[ Page_Line_Size ], aPos[ Page_Pos_v____ ], 0.2 )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'MR Boleto: Titulo processado e impresso pelo Beneficiario', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // Dados da Grade ( 0.008 )
   // *-------------------------------------------------------------------------*
   aPos[ Page_Pos_v____ ] += ( ::Page_Height__ * 0.008 )
   ::Draw_Text( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.670 ), aPos[ Page_Pos_v____ ], TRAN( 'Autenticacao Mecanica - Ficha de Compensacao', '@A' ), ::oFont_v______, Font_Small____ )

   // *-------------------------------------------------------------------------*
   // IMAGEM DO Codigo DE BARRAS
   // *-------------------------------------------------------------------------*
   ::hZebra_______ := hb_zebra_create_itf( ::Cod_Barras___, HB_ZEBRA_FLAG_WIDE2_5 )
   IF ( ::hZebra_______ != NIL )

      IF hb_zebra_geterror( ::hZebra_______ ) == 0
         ::Draw_Zebra( aPos[ Page_Left_____ ] + ( ::Page_Width___ * 0.010 ), ( ::Page_Height__ * 0.060 ), 0.40, -( ::Page_Height__ * 0.045 ) )
      ELSE
         ? "Error", hb_zebra_geterror( ::hZebra_______ )
      ENDIF

   ENDIF

   // *-------------------------------------------------------------------------*
   // Kill object
   // *-------------------------------------------------------------------------*
   hb_zebra_destroy( ::hZebra_______ )

   Return NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Update()
//
// *-------------------------------------------------------------------------*
METHOD Update() Class MR_Boleto

   if HB_ISSTRING( ::Instrucoes___ )
      ::Instrucoes___ := { ::Instrucoes___ }
   endif

   IF Len( ::Instrucoes___ ) < Pdf_Instrucoes
      WHILE Len( ::Instrucoes___ ) < Pdf_Instrucoes
         AADD( ::Instrucoes___, '' )
      ENDDO
   ENDIF


   if HB_ISSTRING( ::Demonstrativo )
      ::Demonstrativo := { ::Demonstrativo }
   endif

   IF Len( ::Demonstrativo ) < ( Pdf_Demonstr__ + IIF( ::Numero_Vias__ > 2, 0, 17 ) )
      WHILE Len( ::Demonstrativo ) < ( Pdf_Demonstr__ + IIF( ::Numero_Vias__ > 2, 0, 17 ) )
         AADD( ::Demonstrativo, '' )
      ENDDO
   ENDIF


   if HB_ISSTRING( ::Local_Pagamen )
      ::Local_Pagamen := { ::Local_Pagamen }
   endif

   IF Len( ::Local_Pagamen ) < 2
      WHILE Len( ::Local_Pagamen ) < 2
         AADD( ::Local_Pagamen, '' )
      ENDDO
   ENDIF


   if HB_ISSTRING( ::Beneficiario_ )
      ::Beneficiario_ := { ::Beneficiario_ }
   endif

   IF Len( ::Beneficiario_ ) < 4
      WHILE Len( ::Beneficiario_ ) < 4
         AADD( ::Beneficiario_, '' )
      ENDDO
   ENDIF


   if HB_ISSTRING( ::Pagador______ )
      ::Pagador______ := { ::Pagador______ }
   endif

   IF Len( ::Pagador______ ) < 7
      WHILE Len( ::Pagador______ ) < 7
         AADD( ::Pagador______, '' )
      ENDDO
   ENDIF


   if HB_ISSTRING( ::Avalista_____ )
      ::Avalista_____ := { ::Avalista_____ }
   endif

   IF Len( ::Avalista_____ ) < 4
      WHILE Len( ::Avalista_____ ) < 4
         AADD( ::Avalista_____, '' )
      ENDDO
   ENDIF

   Return NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Execute()
//
// *-------------------------------------------------------------------------*
METHOD Execute() Class MR_Boleto
   LOCAL aAux := ARRAY( 5 )

   DO CASE

   CASE ::Banco________ == "001"

        ::Banco_001()

   CASE ::Banco________ == "033"

        ::Banco_033()

   CASE ::Banco________ == "085"

        ::Banco_085()

   CASE ::Banco________ == "104"

        ::Banco_104()

   CASE ::Banco________ == "237"

        ::Banco_237()

   CASE ::Banco________ == "341"

        ::Banco_341()

   CASE ::Banco________ == "399"

        ::Banco_399()

   CASE ::Banco________ == "422"

        ::Banco_422()

   CASE ::Banco________ == "748"

        ::Banco_748()

   OTHERWISE

        ::Banco_Dv_____ := "X"
        ::Banco_Nome___ := "Banco Invalido"

        ::Ag_Cd_Benefic := TRAN( ::Banco_Agencia + '-' + ::Banco_Ag_Dv__ + '/'+ ::Conta________ + '-' + ::Conta_DV_____, "@!")

   ENDCASE

   ::Vencim_Fator_ := STRZERO( ::Vencimento___ - Bol_Start_Date, 4 )

   // *-------------------------------------------------------------------------*
   // Monta Codigo de Barras (p/ Banco)
   // *-------------------------------------------------------------------------*
   ::Cod_Barras_DV := ::DC_Mod11( ::Banco________, 9, .T. , ::Banco________ + ::Moeda________ + ::Vencim_Fator_ + StrZero( ::Valor________ * 100,10 ) + ::Campo_Livre__, .F. )
   ::Cod_Barras___ := ::Banco________ + ::Moeda________ + ::Cod_Barras_DV + ::Vencim_Fator_ + StrZero( ::Valor________ * 100, 10 ) + ::Campo_Livre__

   // *-------------------------------------------------------------------------*
   // REPRESENTACAO NUMERICA DO CODIGO DE BARRAS
   // *-------------------------------------------------------------------------*
   aAux[ 1 ] := ::Banco________ + ::Moeda________ + SubStr( ::Campo_Livre__,  1, 5 )
   aAux[ 1 ] += ::DC_Mod10( ::Banco________, aAux[  1 ] )

   aAux[ 2 ] := SubStr( ::Campo_Livre__,  6, 10 )
   aAux[ 2 ] += ::DC_Mod10( ::Banco________, aAux[  2 ] )

   aAux[ 3 ] := SubStr( ::Campo_Livre__, 16, 10 )
   aAux[ 3 ] += ::DC_Mod10( ::Banco________, aAux[  3 ] )
   aAux[ 4 ] := ::Cod_Barras_DV
   aAux[ 5 ] := ::Vencim_Fator_ + StrZero( ::Valor________ * 100, 10 )
   // *-------------------------------------------------------------------------*
   // LINHA DIGITAVEL - 05 Conjuntos Numericos
   // *-------------------------------------------------------------------------*
   ::Ln_Digitavel_ := LEFT( aAux[ 1 ], 5 ) + '.' + SubStr( aAux[ 1 ], 6 ) + " " + ;
                      Left( aAux[ 2 ], 5 ) + "." + SubStr( aAux[ 2 ], 6 ) + " " + ;
                      Left( aAux[ 3 ], 5 ) + "." + SubStr( aAux[ 3 ], 6 ) + " " + ;
                      aAux[ 4 ] + " " +  ;
                      aAux[ 5 ]

   Return NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Banco_001()
//
// *-------------------------------------------------------------------------*
METHOD Banco_001() Class MR_Boleto

   ::Banco_Dv_____ := "9"
   ::Banco_Nome___ := "Banco do Brasil"

   ::Prefixo______ := PADL( ALLTRIM( Left( ::Prefixo______, 6 ) ), 6, '0' )
   ::Prefixo_DV___ := PADL( ALLTRIM( Left( ::Prefixo_DV___, 1 ) ), 1, '0' )

   IF Left( ::Carteira_____, 2 ) $ "16|18|SR"

      // *-------------------------------------------------------------------------*
      // NN com 18 Posicoes
      // *-------------------------------------------------------------------------*
      ::Carteira_____ := PADL( ALLTRIM( Left( ::Carteira_____, 2 ) ), 2, '0' )

      ::Conta________ := PADL( ALLTRIM( Left( ::Conta________, 8 ) ), 8, '0' )

      ::NossoNumero__ := ::Prefixo______ + ::Prefixo_DV___+ PADL( ALLTRIM( Left( ::NossoNumero__, 10 ) ), 10, '0' )
      ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 9, .F. , ::NossoNumero__, .F. )

      ::NossoNumero_z := ::NossoNumero__ + '-' + ::NossoNumer_DV

      // *-------------------------------------------------------------------------*
      // Indicacao do NN com 17 Posicoes Livres
      // *-------------------------------------------------------------------------*
      ::Campo_Livre__:= REPL( '0', 6 ) + ::NossoNumero__ + ::Carteira_____

   ELSEIF Left( ::Carteira_____, 2 ) $ "17|19"

      // *-------------------------------------------------------------------------*
      // NN com 17 Posicoes
      // *-------------------------------------------------------------------------*
      ::Carteira_____ := PADL( ALLTRIM( Left( ::Carteira_____, 2 ) ), 2, '0' )

      ::Conta________ := PADL( ALLTRIM( Left( ::Conta________, 8 ) ), 8, '0' )

      ::NossoNumero__ := ::Prefixo______ + ::Prefixo_DV___+ PADL( ALLTRIM( Left( ::NossoNumero__, 10 ) ), 10, '0' )
      ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 9, .F. , ::NossoNumero__, .F. )

      ::NossoNumero_z := ::NossoNumero__ + '-' + ::NossoNumer_DV

      // *-------------------------------------------------------------------------*
      // Indicacao do NN com 17 Posicoes Livres
      // *-------------------------------------------------------------------------*
      ::Campo_Livre__:= REPL( '0', 6 ) + ::NossoNumero__ + ::Carteira_____

      // *-------------------------------------------------------------------------*
      // Gera Arquivo Remessa
      // *-------------------------------------------------------------------------*
      ::Cnab_Remessa_ := .T.
      ::Cnab_Add()

   ELSE

      ::Carteira_____ := PADL( ALLTRIM( Left( ::Carteira_____, 2 ) ), 2, '0' )

      ::Conta________ := PADL( ALLTRIM( Left( ::Conta________, 8 ) ), 8, '0' )

      ::NossoNumero__ := ::Prefixo______ + PADL( ALLTRIM( Left( ::NossoNumero__, 5 ) ), 5, '0' )
      ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 9, .F., ::NossoNumero__, .F. )

      ::NossoNumero_z := Tran( ::NossoNumero__, "@R 99.999.999.999" ) + "-" + ::NossoNumer_DV

      ::Campo_Livre__:= ::NossoNumero__ + ::Banco_Agencia + ::Conta________ + ::Carteira_____

   ENDIF

   ::Ag_Cd_Benefic := TRAN( ::Banco_Agencia + '-' + ::Banco_Ag_Dv__ + '/'+ ::Conta________ + '-' + ::Conta_DV_____, "@!")

   Return NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Banco_033()
//
// *-------------------------------------------------------------------------*
METHOD Banco_033() Class MR_Boleto

   ::Banco_Dv_____ := "7"
   ::Banco_Nome___ := "Banco Santander"

   IF EMPTY( ::Prefixo______ )
      ::Prefixo______ := ::Conta________
      ::Conta________ := ''
      ::Prefixo_DV___ := ::Conta_DV_____
      ::Conta_DV_____ := ''
   ENDIF

   ::Prefixo______ := PADL( ALLTRIM( Left( ::Prefixo______,  6 ) ),  6, '0' )
   ::Prefixo_DV___ := PADL( ALLTRIM( Left( ::Prefixo_DV___,  1 ) ),  1, '0' )

   ::NossoNumero__ := PADL( ALLTRIM( Left( ::NossoNumero__, 12 ) ), 12, '0' )
   ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 9, .F., ::NossoNumero__, .F. )

   ::NossoNumero_z := ::NossoNumero__ + " " + ::NossoNumer_DV

   ::Ag_Cd_Benefic := TRAN( ::Banco_Agencia + '/' + ::Prefixo______ + '-' + ::Prefixo_DV___, "@!")

   ::Campo_Livre__ := '9' + ::Prefixo______ + ::Prefixo_DV___ + ::NossoNumero__ +  + ::NossoNumer_DV  + '0'+ ::Carteira_____

   Return NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Banco_085() baseado no 001 brasil
//
// *-------------------------------------------------------------------------*
METHOD Banco_085() Class MR_Boleto

   ::Banco_Dv_____ := "1"
   ::Banco_Nome___ := "CECRED"

   ::Prefixo______ := PADL( ALLTRIM( Left( ::Prefixo______, 6 ) ), 6, '0' )
   ::Prefixo_DV___ := PADL( ALLTRIM( Left( ::Prefixo_DV___, 1 ) ), 1, '0' )

   IF .T. // SEMPRE .T.
      ::Carteira_____ := PADL( ALLTRIM( Left( ::Carteira_____, 2 ) ), 2, '0' )
      ::Conta________ := PADL( ALLTRIM( Left( ::Conta________, 8 ) ), 8, '0' )
      ::NossoNumero__ := ::Prefixo______ + ::Prefixo_DV___+ PADL( ALLTRIM( Left( ::NossoNumero__, 10 ) ), 10, '0' )
      ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 9, .F. , ::NossoNumero__, .F. )
      ::NossoNumero_z := ::NossoNumero__ + '-' + ::NossoNumer_DV
      ::Campo_Livre__:= REPL( '0', 6 ) + ::NossoNumero__ + ::Carteira_____
   ELSE
      ::Carteira_____ := PADL( ALLTRIM( Left( ::Carteira_____, 2 ) ), 2, '0' )
      ::Conta________ := PADL( ALLTRIM( Left( ::Conta________, 8 ) ), 8, '0' )
      ::NossoNumero__ := ::Prefixo______ + PADL( ALLTRIM( Left( ::NossoNumero__, 5 ) ), 5, '0' )
      ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 9, .F., ::NossoNumero__, .F. )
      ::NossoNumero_z := Tran( ::NossoNumero__, "@R 99.999.999.999" ) + "-" + ::NossoNumer_DV
      ::Campo_Livre__:= ::NossoNumero__ + ::Banco_Agencia + ::Conta________ + ::Carteira_____
   ENDIF

   ::Ag_Cd_Benefic := TRAN( ::Banco_Agencia + '-' + ::Banco_Ag_Dv__ + '/'+ ::Conta________ + '-' + ::Conta_DV_____, "@!")

   Return NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Banco_104()
//
// *-------------------------------------------------------------------------*
METHOD Banco_104() Class MR_Boleto

   ::Banco_Dv_____ := "0"
   ::Banco_Nome___ := "Caixa"

   IF EMPTY( ::Prefixo______ )
      ::Prefixo______ := ::Conta________
      ::Conta________ := ''
      ::Prefixo_DV___ := ::Conta_DV_____
      ::Conta_DV_____ := ''
   ENDIF

   IF LEN( ::NossoNumero__ ) < 16

      ::Prefixo______ := PADL( ALLTRIM( Left( ::Prefixo______,  8 ) ), 8, '0' )

      ::NossoNumero__ := PADL( ALLTRIM( Left( ::NossoNumero__, 10 ) ), 10, '0' )

      ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 9, .F., ::NossoNumero__, .F. )

      ::NossoNumero_z := ::NossoNumero__ + "-" + ::NossoNumer_DV

      ::Banco_Agencia := PADL( ALLTRIM( Left( ::Banco_Agencia,  4 ) ),  4, '0' )

      ::Ag_Cd_Benefic := TRAN( ::Banco_Agencia + '.' + ::Conta_OP_____ + '.' + ::Prefixo______ + '.' + ::Prefixo_DV___, "@!")

      ::Campo_Livre__:= ::NossoNumero__ + ::Banco_Agencia + ::Conta_OP_____ + ::Prefixo______
   ELSE

      ::Prefixo______ := PADL( ALLTRIM( Left( ::Prefixo______,  6 ) ), 6, '0' )

      ::NossoNumero__ := PADL( ALLTRIM( Left( ::NossoNumero__, 16 ) ), 16, '0' )

      ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 9, .F., SUBSTR( ::NossoNumero__, 9, 8 ), .F. )

      ::NossoNumero_z := ::NossoNumero__ + "-" + ::NossoNumer_DV

      ::Banco_Agencia := PADL( ALLTRIM( Left( ::Banco_Agencia,  4 ) ),  4, '0' )

      ::Ag_Cd_Benefic := TRAN( ::Banco_Agencia + '.' + ::Conta_OP_____ + '.' + ::Prefixo______ + '.' + ::Prefixo_DV___, "@!")

      ::Campo_Livre__:= ::Prefixo______ + ::NossoNumero__
   ENDIF

   Return NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Banco_237()
//
// *-------------------------------------------------------------------------*
METHOD Banco_237() Class MR_Boleto

   ::Banco_Dv_____ := "2"
   ::Banco_Nome___ := "Bradesco"

   ::Carteira_____ := PADL( ALLTRIM( Left( ::Carteira_____, 3 ) ), 3, '0' )
   ::Conta________ := PADL( ALLTRIM( Left( ::Conta________, 7 ) ), 7, '0' )
   ::Conta_DV_____ := PADL( ALLTRIM( Left( ::Conta_DV_____, 1 ) ), 1, '0' )
   ::Banco_Agencia := PADL( ALLTRIM( Left( ::Banco_Agencia, 4 ) ), 4, '0' )

   ::Ag_Cd_Benefic := TRAN( ::Banco_Agencia + iif( Empty( ::Banco_Ag_Dv__ ), "", "-" + ::Banco_Ag_Dv__ ) + '/' + ::Conta________ + '-' + ::Conta_DV_____, "@!")

   IF Len( ::NossoNumero__ ) < 8
      ::NossoNumero__ := ::Banco_Agencia + PADL( ALLTRIM( Left( ::NossoNumero__, 7 ) ), 7, '0' )
      ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 7, .F. , ::Carteira_____ + ::NossoNumero__, .F. )
      ::NossoNumero_z := ::Carteira_____ + '/' + TRANS( ::NossoNumero__, "@R 99/99999" ) + "-" + ::NossoNumer_DV
   ELSE
      ::NossoNumero__ := PADL( ALLTRIM( Left( ::NossoNumero__, 11 ) ), 11, '0' )
      ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 7, .F. , ::Carteira_____ + ::NossoNumero__, .F. )
      ::NossoNumero_z := ::Carteira_____ + '/' + TRANS( ::NossoNumero__, "@R 9999/99/99999" ) + "-" + ::NossoNumer_DV
   ENDIF

   ::Campo_Livre__ := ::Banco_Agencia + SubStr( ::Carteira_____, 2, 2 ) + PADL( ::NossoNumero__, 11, '0' ) + ::Conta________ + "0"

   Return NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Banco_341()
//
// *-------------------------------------------------------------------------*
METHOD Banco_341() Class MR_Boleto

   ::Banco_Dv_____ := "7"
   ::Banco_Nome___ := "Ita?"

   ::Carteira_____ := PADL( ALLTRIM( Left( ::Carteira_____, 3 ) ), 3, '0' )
   ::Conta________ := PADL( ALLTRIM( Left( ::Conta________, 5 ) ), 5, '0' )
   ::Conta_DV_____ := PADL( ALLTRIM( Left( ::Conta_DV_____, 1 ) ), 1, '0' )
   ::Banco_Agencia := PADL( ALLTRIM( Left( ::Banco_Agencia, 4 ) ),  4, '0' )

   ::NossoNumero__ := PADL( ALLTRIM( Left( ::NossoNumero__, 8 ) ), 8, '0' )
   ::NossoNumer_DV := ::DC_Mod10( ::Banco________, ::Banco_Agencia + ::Conta________ + ::Carteira_____ + ::NossoNumero__ )

   ::NossoNumero_z := ::Carteira_____ + '/' + ::NossoNumero__ + "-" + ::NossoNumer_DV

   ::Ag_Cd_Benefic := TRAN( ::Banco_Agencia + '/' + ::Conta________ + '-' + ::Conta_DV_____, "@!")

   ::Campo_Livre__:= ::Carteira_____ + ::NossoNumero__ + ::NossoNumer_DV  + ::Banco_Agencia + ::Conta________ + ::Conta_DV_____ + "000"

   Return NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Banco_399()
//
// *-------------------------------------------------------------------------*
METHOD Banco_399() Class MR_Boleto
   LOCAL cDataHSBC := StrZero( ::Vencimento___ - SToD( Str( Year( ::Vencimento___  ), 4 ) + "0101" ), 3 ) + Right( Str( Year( ::Vencimento___ ), 4 ), 1 )

   ::Banco_Dv_____ := "9"
   ::Banco_Nome___ := "HSBC"

   ::Carteira_____ := ALLTRIM( ::Carteira_____ )

   IF ::Carteira_____ == "00"

      ::Conta________ := PADL( ALLTRIM( Left( ::Conta________, 5 ) ), 5, '0' )
      ::Conta_DV_____ := PADL( ALLTRIM( Left( ::Conta_DV_____, 1 ) ), 1, '0' )
      ::Banco_Agencia := PADL( ALLTRIM( Left( ::Banco_Agencia, 4 ) ), 4, '0' )

      ::NossoNumero__ := PADL( ALLTRIM( Left( ::NossoNumero__, 10 ) ), 10, '0' )
      ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 7, .T. , ::NossoNumero__, .F. )
      ::NossoNumero_z := ::NossoNumero__ + "-" + ::NossoNumer_DV

      ::Campo_Livre__ := ::NossoNumero__ + ::NossoNumer_DV + ::Banco_Agencia + ::Conta________ + ::Conta_DV_____ + "00" + "1"

      ::Ag_Cd_Benefic := TRAN( ::Banco_Agencia + IF( Empty( ::Banco_Ag_Dv__ ), "", "-" + ::Banco_Ag_Dv__ ) + '/' + ::Conta________ + '-' + ::Conta_DV_____, "@!")

   ELSE       // Sem Registro

      ::Prefixo______ := PADL( ALLTRIM( Left( ::Prefixo______,  7 ) ),  7, '0' )

      ::NossoNumero__ := PADL( ALLTRIM( Left( ::NossoNumero__, 16 ) ), 16, '0' )
      ::NossoNumero_z := PADL( ALLTRIM( RIGHT( ::NossoNumero__, 14 ) ), 14, '0' )

      ::Campo_Livre__ := ::Prefixo______ + ::NossoNumero__ + cDataHSBC + "2"

      ::Ag_Cd_Benefic := PADL( ::Prefixo______, 12, '0' )

   ENDIF

   Return NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Banco_422()
//
// *-------------------------------------------------------------------------*
METHOD Banco_422() Class MR_Boleto

   ::Banco_Dv_____   := "7"
   ::Banco_Nome___   := "Safra"

   ::Banco_Agencia := PADL( ALLTRIM( Left( ::Banco_Agencia,  4 ) ),  4, '0' )
   ::Conta________ := PADL( ALLTRIM( Left( ::Conta________,  8 ) ),  8, '0' )
   ::Conta_DV_____ := PADL( ALLTRIM( Left( ::Conta_DV_____,  1 ) ),  1, '0' )

   ::Carteira_____ := PADL( ALLTRIM( Left( ::Carteira_____,  2 ) ),  2, '0' )
   ::Prefixo______ := PADL( ALLTRIM( Left( ::Prefixo______,  6 ) ),  6, '0' )

   ::Ag_Cd_Benefic := '0' + ::Banco_Agencia + '/' + ::Conta________ + '-' + ::Conta_DV_____

   ::NossoNumero__ := PADL( ALLTRIM( Left( ::NossoNumero__, 11 ) ), 11, '0' )
   ::NossoNumer_DV := ::DC_Mod11( ::Banco________, 7, .T. , ::NossoNumero__, .F. )

   IF ::Carteira_____ == '06'
      ::NossoNumero_z := ::Carteira_____ + '/' + ::NossoNumero__ + "-" + ::NossoNumer_DV
      ::Campo_Livre__:= '7' + ::Prefixo______ + ::NossoNumero__ + '4'
   ELSE
      ::NossoNumero_z := '0' + ::Banco_Agencia + '/' + ::NossoNumero__ + "-" + ::NossoNumer_DV
      ::Campo_Livre__ := '70' + ::Banco_Agencia + ::Conta________ + ::Conta_DV_____  + ::NossoNumero__ + ::NossoNumer_DV + '1'
   ENDIF

   Return NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Banco_748()
//
// *-------------------------------------------------------------------------*
METHOD Banco_748() Class MR_Boleto

   LOCAL cAux
   LOCAL cDig
   LOCAL cAno := RIGHT( hb_NtoS( YEAR(::Doc_Data_____ ) ), 2 )
   LOCAL cNNr := PADL( ALLTRIM( Left( ::NossoNumero__, 5 ) ), 5, '0' )

   ::Banco_Dv_____ := "X"
   ::Banco_Nome___ := "Banco Cooperativo Sicredi"

   ::Carteira_____ := PADL( ALLTRIM( Left( ::Carteira_____, 1 ) ), 1, '0' )
   ::Carteira_Tipo := PADL( ALLTRIM( Left( ::Carteira_Tipo, 1 ) ), 1, '0' )

   ::Banco_Agencia := PADL( ALLTRIM( Left( ::Banco_Agencia, 4 ) ), 4, '0' )
   ::Banco_Ag_Un_A := PADL( ALLTRIM( Left( ::Banco_Ag_Un_A, 2 ) ), 2, '0' )

   ::Conta________ := PADL( ALLTRIM( Left( ::Conta________, 5 ) ), 5, '0' )
   ::Conta_DV_____ := PADL( ALLTRIM( Left( ::Conta_DV_____, 1 ) ), 1, '0' )

   cAux := cAno + ::Carteira_Tipo + cNNr
   cDig := ::DC_Mod11( ::Banco________, 7, .T. , cAux, .F. )
   ::NossoNumero__ := cAux + cDig
   ::NossoNumer_DV := cDig

   ::NossoNumero_z := cAno + '/' + ::Carteira_Tipo + cNNr + '-' + ::NossoNumer_DV

   ::Ag_Cd_Benefic := ::Banco_Agencia + '.' + ::Banco_Ag_Un_A + '.' + ::Conta________

   cAux := ::Carteira_____ + ::Carteira_Tipo + ::NossoNumero__ + ::Banco_Agencia + ::Banco_Ag_Un_A + ::Conta________ + '10'
   ::Campo_Livre__ := cAux + ::DC_Mod11( ::Banco________, 7, .T. , cAux, .F. )

   Return NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Draw_Text( nLeft, nTop, cTxt, nSize )
//
// *-------------------------------------------------------------------------*
METHOD Draw_Text( nLeft, nTop, cTxt, oFont, nSize ) Class MR_Boleto

   HPDF_Page_SetFontAndSize( ::oPage, oFont, nSize )

   /* text output */
   HPDF_Page_BeginText( ::oPage )
   HPDF_Page_TextOut( ::oPage, nLeft, ( ::Page_Height__ - nTop ), cTxt )
   HPDF_Page_EndText( ::oPage )

   Return NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Draw_Line( x, y, w, z, nPenSize )
//
// *-------------------------------------------------------------------------*
METHOD Draw_Line( x, y, w, z, nPenSize ) Class MR_Boleto

   HPDF_Page_SetLineWidth( ::oPage, nPenSize )

   HPDF_Page_MoveTo( ::oPage, x, ( ::Page_Height__ - y ) )

   HPDF_Page_LineTo( ::oPage, w, ( ::Page_Height__ - z ) )

   HPDF_Page_Stroke( ::oPage )

   Return NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Draw_Image( nLeft, nTop, nWidth, nHeight )
//
// *-------------------------------------------------------------------------*
METHOD Draw_Image( nLeft, nTop, nWidth, nHeight ) Class MR_Boleto
   Local cFile := 'Res\Logo_' + ::Banco________ + '.jpg'
   Local oImage

   IF hb_FileExists( cFile )

      oImage := HPDF_LoadJPEGImageFromFile( ::o_Pdf, cFile )
      HPDF_Page_DrawImage( ::oPage, oImage, nLeft, ( ::Page_Height__ - nTop ), nWidth, nHeight )

   ELSE

     ::Draw_Text( nLeft, nTop - ( ::Page_Height__ * 0.005 ), ::Banco_Nome___, ::oFont_v______, Font_Large____ )

   ENDIF

   Return NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Draw_Zebra( ... )
//
// *------------------------------------------------------------------------*
#ifdef __XHARBOUR__
METHOD Draw_Zebra( x, y, w, z ) Class MR_Boleto
#else
METHOD Draw_Zebra( ... ) Class MR_Boleto
#endif

   IF hb_zebra_GetError( ::hZebra_______ ) != 0
      RETURN HB_ZEBRA_ERROR_INVALIDZEBRA
   ENDIF

   hb_zebra_draw( ::hZebra_______, {| x, y, w, z | HPDF_Page_Rectangle( ::oPage, x, y, w, z ) }, ... )

   HPDF_Page_Fill( ::oPage )

   Return NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Finish( lOpen )
//
// *-------------------------------------------------------------------------*
METHOD Finish( lOpen ) Class MR_Boleto

   IF hb_FileExists( ::oFile )
      FERASE( ::oFile )
   ENDIF

   HPDF_SaveToFile( ::o_Pdf, ::oFile)

   IF ::Cnab_Remessa_
      ::Cnab_Save()
   ENDIF

   hPDF_Free( ::o_Pdf )

   IF lOpen
      IF hb_FileExists( ::oFile )

#ifdef __GCC__
         hb_RUN( ::oFile )
#else
         wapi_ShellExecute( 0, 'open', ::oFile, , , 3 ) // SW_SHOWMAXIMIZED  3
#endif

      ENDIF
   ENDIF

   Return NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:DC_Mod10( c_Banco, mNMOG )
//
// *-------------------------------------------------------------------------*
METHOD DC_Mod10( c_Banco, mNMOG ) Class MR_Boleto
   LOCAL mVLDG
   LOCAL mSMMD
   LOCAL mCTDG
   LOCAL mRSDV
   LOCAL mDCMD

   mSMMD := IIF( EMPTY( c_Banco ), 0, 0 )

   FOR mCTDG := 1 TO Len( mNMOG )
      mVLDG := Val( SubStr( mNMOG,Len(mNMOG ) - mCTDG + 1,1 ) ) * IF( Mod( mCTDG,2 ) == 0, 1, 2 )
      mSMMD += mVLDG - IF( mVLDG > 9, 9, 0 )
   NEXT
   mRSDV := Mod( mSMMD, 10 )
   mDCMD := IF( mRSDV == 0, "0", Str( 10 - mRSDV,1 ) )

   RETURN mDCMD

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:DC_Mod11( c_Banco, mBSDG, mFGCB, mNMOG, lMult10 )
//
// bradesco -> DC_Mod11("237", 7, .F., carteira+agencia+nossonumero, .F.)
//
// *-------------------------------------------------------------------------*
METHOD DC_Mod11( c_Banco, mBSDG, mFGCB, mNMOG, lMult10 ) Class MR_Boleto
   LOCAL mSMMD
   LOCAL mCTDG
   LOCAL mSQMP
   LOCAL mRSDV
   LOCAL mDCMD

   // mFGCB := IIF( EMPTY( mFGCB ), .F., mFGCB )
   // mFGCB := IIF( EMPTY( lMult10 ), .F., lMult10 )

   mSMMD := 0
   mSQMP := 2

   FOR mCTDG := 1 TO Len( mNMOG )
      mSMMD += Val( SubStr( mNMOG,Len(mNMOG ) - mCTDG + 1,1 ) ) * ( mSQMP )
      mSQMP := IF( mSQMP == mBSDG, 2, mSQMP + 1 )
   NEXT
   IF lMult10
      mSMMD *= 10
   ENDIF
   //  mRSDV := MOD(mSMMD,11)
   mRSDV := ( mSMMD % 11 )
   IF mFGCB
      mDCMD := IF( mRSDV > 9 .OR. mRSDV < 2, "1", Str( 11 - mRSDV,1 ) )
   ELSE
      IF c_Banco $ "001#085"                 // Brasil / CECREDI
         mDCMD := IF( mRSDV == 0, "0", IF( mRSDV == 1,"X",Str(11 - mRSDV,1 ) ) )
      ELSEIF c_Banco $ "008|033|353"         //Santander Banespa
         mDCMD := IF( mRSDV < 2, "0", IF( mRSDV == 10,"1",Str(11 - mRSDV,1 ) ) )
      // mDCMD := IF(mRSDV == 0, "0", IF(mRSDV == 1, "X", STR(11 - mRSDV, 1) ) )
      ELSEIF c_Banco == "104"                // Caixa
         mRSDV := 11 - mRSDV
         mDCMD := IF( mRSDV > 9, "0", Str( mRSDV,1 ) )
      ELSEIF c_Banco == "237"                // Bradesco
         mDCMD := IF( mRSDV == 0, "0", IF( mRSDV == 1,"P",Str(11 - mRSDV,1 ) ) )
      ELSEIF c_Banco == "341"                // Itau
         mDCMD := IF( mRSDV == 11, "1", Str( 11 - mRSDV,1 ) )
      ELSEIF c_Banco == "409"                // Unibanco
         mDCMD := IF( mRSDV == 0 .OR. mRSDV == 10, "0", Str( mRSDV,1 ) )
      ELSEIF c_Banco == "422"                // Safra
         mDCMD := IF( mRSDV == 0, "1", IF( mRSDV == 1,"0",Str(11 - mRSDV,1 ) ) )
      ENDIF
   ENDIF

   RETURN mDCMD

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:DC_ModEsp( c_Banco, mNMOG )
//
// *-------------------------------------------------------------------------*
METHOD DC_ModEsp( c_Banco, mNMOG ) Class MR_Boleto

   LOCAL mVLDG
   LOCAL mSMMD
   LOCAL mCTDG
   LOCAL mSQMP
   LOCAL mRSDV
   LOCAL mDCMD := 0

   IF c_Banco == "033"                  // Banespa
      mSMMD := 0
      mSQMP := 3
      FOR mCTDG := 1 TO Len( mNMOG )
         mVLDG := Val( SubStr( mNMOG,Len(mNMOG ) - mCTDG + 1,1 ) ) * ( mSQMP )
         mSMMD += mVLDG - ( Int( mVLDG / 10 ) * 10 )
         mSQMP := IF( mSQMP == 3, 7, IF( mSQMP == 7,9,IF(mSQMP == 9,1,3 ) ) )
      NEXT
      mRSDV := mSMMD - ( Int( mSMMD / 10 ) * 10 )
      mDCMD := IF( mRSDV == 0, 0, 10 - mRSDV )
   ENDIF

   RETURN Str( mDCMD, 1 )

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Interleaved_2of5()
//
// *-------------------------------------------------------------------------*
METHOD Interleaved_2of5() Class MR_Boleto
   Local n
   Local m
   Local cIz
   Local cDer
   Local nCheck := 0
   Local cBar   := []
   Local cBarra := []
   Local cCode  := Transform( ::Cod_Barras___, "@9")
   Local aBar   := {[00110], [10001], [01001], [11000], [00101], [10100], [01100], [00011], [10010], [01010]}
   Local lMode  := .F.

   If ( LEN( cCode ) % 2 == 1 .and. !( lMode ) )
      cCode+= [0]
   Endif

   If lMode
      For n:= 1 to len(cCode) step 2
          nCheck+= val(substr(cCode, n, 1)) * 3 + val(substr(cCode, n + 1, 1))
      Next
      cCode+= right(str(nCheck, 10, 0), 1)
   Endif

   cBarra:= [0000]
   For n:= 1 to len(cCode) Step 2
       cIz := aBar[val(substr(cCode, n, 1)) + 1]
       cDer:= aBar[val(substr(cCode, n + 1, 1)) + 1]
       For m:= 1 to 5
           cBarra+= substr(cIz, m, 1) + substr(cDer, m, 1)
       Next
   Next

   cBarra+= [100]
   For n:= 1 To Len(cBarra) Step 2
       If substr(cBarra, n, 1) == [1]
          cBar+= [111]
       Else
          cBar+= [1]
       Endif
       If substr(cBarra, n + 1, 1) == [1]
          cBar+= [000]
       Else
          cBar+= [0]
       Endif
   Next

Return( cBar )

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Only_Numbers( cStr )
//
// *-------------------------------------------------------------------------*
METHOD Only_Numbers( cStr ) Class MR_Boleto

   LOCAL i
   LOCAL iMax
   LOCAL cAux
   LOCAL cRet

   cStr := ALLTRIM( cStr )
   iMax := LEN( cStr )
   cRet := ''

   /* LOOP */
   FOR i := 1 TO iMax

      IF ( cAux := SUBSTR( cStr, i, 1 ) ) $ '0123456789'
         cRet += cAux
      ENDIF

   NEXT

Return( cRet )

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Cnab_Add()
//
// *-------------------------------------------------------------------------*
METHOD Cnab_Add() Class MR_Boleto

   LOCAL cAux
   LOCAL cTxt
   LOCAL hAux
   LOCAL i := 0

   hAux := hb_hash()
   hAux[ 'Banco' ] := PADR( UPPER( ::Banco_Nome___ ), 30 )
   hAux[ 'Inscr' ] := ALLTRIM( LEFT( ::Only_Numbers( ::Pagador______[ 1 ] ), 14 ) )
   hAux[ 'CpfCnpj' ] := IIF( LEN( hAux[ 'Inscr' ] ) > 11, '2', '1' )
   cAux := DTOS( ::Cnab_Rem_data )
   hAux[ 'Data' ] := SUBSTR( cAux, 7, 2 ) + SUBSTR( cAux, 5, 2 ) + SUBSTR( cAux, 1, 4 )
   hAux[ 'Hora' ] := STRTRAN( TIME(), ':', '' )
   cAux := DTOS( ::Vencimento___ )
   hAux[ 'Vencimento' ] := SUBSTR( cAux, 7, 2 ) + SUBSTR( cAux, 5, 2 ) + SUBSTR( cAux, 1, 4 )
   cAux := STRTRAN( hb_NtoS( ROUND( ::Valor________, 2 ) ), '.', '' )
   hAux[ 'Valor' ] := PADL( cAux, 15,  '0' )
   cAux := STRTRAN( hb_NtoS( ROUND( ::Valor________ * ( ( ( ::Juros_Mes____ * 12 ) / 365 ) / 100 ), 2 ) ), '.', '' )
   hAux[ 'JuroDia' ] := PADL( cAux, 15,  '0' )

   IF ::Banco________ == "001"

      /* Registro Detalhe - Segmento P */
      i++
      cTxt := ::Banco________                      // 01.3P  Codigo do Banco na Compensacao        1    3   3  -  Num            G001
      cTxt += '0001'                               // 02.3P  Lote de Servico                       4    7   4  -  Num           *G002
      cTxt += "3"                                  // 03.3P  Tipo de Registro                      8    8   1  -  Num  '3'      *G003
      cTxt += STRZERO( i, 5 )                      // 04.3P  N? Sequencial do Registro no Lote     9   13   5  -  Num           *G038
      cTxt += "P"                                  // 05.3P  C?d. Segmento Registro Detalhe       14   14   1  -  Alfa  'P'     *G039
      cTxt += SPACE( 1 )                           // 06.3P  Uso Exclusivo FEBRABAN/CNAB          15   15   1  -  Alfa  Brancos  G004
      cTxt += '01'                                 // 07.3P  Codigo de Movimento Remessa          16   17   2  -  Num           *C004
      cTxt += PADL( ::Banco_Agencia,  5, '0' )     // 08.3P  Codigo Agencia da Conta              18   22   5  -  Num           *G008
      cTxt += ::Banco_Ag_Dv__                      // 09.3P  D?gito Verificador da Agencia        23   23   1  -  Alfa          *G009
      cTxt += PADL( ::Conta________, 12, '0' )     // 10.3P  Numero  Numero da Conta Corrente     24   35  12  -  Num           *G010
      cTxt += ::Conta_DV_____                      // 11.3P  D?gito Verificador da Conta          36   36   1  -  Alfa          *G011
      cTxt += SPACE( 1 )                           // 12.3P  D?gito Verificador da Ag/Conta       37   37   1  -  Alfa          *G012
      cTxt += PADR( ::NossoNumero__, 20 )          // 13.3P  Nosso Numero                         38   57  20  -  Alfa          *G069
      cTxt += '1'                                  // 14.3P  Codigo da Carteira                   58   58   1  -  Num           *C006
      cTxt += '1'                                  // 15.3P  Forma Cadastr.Titulo no Banco        59   59   1  -  Num           *C007
      cTxt += '1'                                  // 16.3P  Tipo de Documento                    60   60   1  -  Alfa           C008
      cTxt += '1'                                  // 17.3P  Id Emissao do Bloqueto               61   61   1  -  Num           *C009
      cTxt += '1'                                  // 18.3P  Identifica??o da Distribui??o        62   62   1  -  Alfa           C010
      cTxt += PADR( ::Doc_Numero___, 15 )          // 19.3P  Numero do Documento de Cobranca      63   77  15  -  Alfa          *C011
      cTxt += hAux[ 'Vencimento' ]                 // 20.3P  Data de Vencimento do Titulo         78   85   8  -  Num           *C012
      cTxt += hAux[ 'Valor' ]                      // 21.3P  Valor Nominal do Titulo              86  100  13  2  Num           *G070
      cTxt += REPL( '0',  5 )                      // 22.3P  Agencia Encarregada Cobranca        101  105   5  -  Num           *C014
      cTxt += SPACE( 1 )                           // 23.3P  D?gito Verificador da Agencia       106  106   1  -  Alfa          *G009
      cTxt += '23'                                 // 24.3P  Especie do Titulo                   107  108   2  -  Num           *C015
      cTxt += 'N'                                  // 25.3P  Aceite                              109  109   1  -  Alfa           C016
      cTxt += hAux[ 'Data' ]                       // 26.3P  Data da Emissao do Titulo           110  117   8  -  Num            G071
      cTxt += '0'                                  // 27.3P  Codigo do Juros de Mora             118  118   1  -  Num           *C018
      cTxt += PADR( '0',  8 )                      // 28.3P  Data do Juros de Mora               119  126   8  -  Num           *C019
      cTxt += hAux[ 'JuroDia' ]                    // 29.3P  Juros de Mora por Dia/Taxa          127  141  13  2  Num            C020
      cTxt += '0'                                  // 30.3P  Codigo do Desconto 1                142  142   1  -  Num           *C021
      cTxt += REPL( '0',  8 )                      // 31.3P  Data do Desconto 1                  143  150   8  -  Num            C022
      cTxt += REPL( '0', 15 )                      // 32.3P  Valor/Percentual Concedido          151  165  13  2  Num            C023
      cTxt += REPL( '0', 15 )                      // 33.3P  Valor do IOF a ser Recolhido        166  180  13  2  Num            C024
      cTxt += REPL( '0', 15 )                      // 34.3P  Valor do Abatimento                 181  195  13  2  Num            G045
      cTxt += PADR( ::Doc_Numero___, 25 )          // 35.3P  Identifica??o Titulo Empresa        196  220  25  -  Alfa           G072
      cTxt += '0'                                  // 36.3P  Codigo para Protesto                221  221   1  -  Num            C026
      cTxt += STRZERO( ::Protesto_Dias, 2 )        // 37.3P  Numero de Dias para Protesto        222  223   2  -  Num            C027
      cTxt += '2'                                  // 38.3P  Codigo para Baixa/Devolu??o         224  224   1  -  Num            C028
      cTxt += REPL( '0',  3 )                      // 39.3P  Numero Dias Baixa/Devolu??o         225  227   3  -  Alfa           C029
      cTxt += PADL( ::Moeda________ , 2, '0' )     // 40.3P  Codigo da Moeda                     228  229   2  -  Num           *G065
      cTxt += REPL( '0', 10 )                      // 41.3P  N? Contrato Operacao de Cr?d.       230  239  10  -  Num            C030
      cTxt += " "                                  // 42.3P  Uso Exclusivo FEBRABAN/CNAB         240  240   1  -  Alfa  Brancos  G004
      /* Add */
      AAdd( ::Cnab_Data____, cTxt )

      /* Registro Detalhe - Segmento Q */
      i++
      cTxt := ::Banco________                      // 01.3Q  Codigo do Banco                       1    3   3  -  Num            G001
      cTxt += '0001'                               // 02.3Q  Lote                                  4    7   4  -  Num           *G002
      cTxt += "3"                                  // 03.3Q  Tipo de Registro                      8    8   1  -  Num  ?3?      *G003
      cTxt += STRZERO( i, 5 )                      // 04.3Q  N? do Registro                        9   13   5  -  Num           *G038
      cTxt += "Q"                                  // 05.3Q  Segmento                             14   14   1  -  Alfa  ?Q?     *G039
      cTxt += SPACE( 1 )                           // 06.3Q  Uso Exclusivo FEBRABAN/CNAB          15   15   1  -  Alfa  Brancos  G004
      cTxt += '01'                                 // 07.3Q  Codigo de Movimento Remessa          16   17   2  -  Num           *C004
      cTxt += hAux[ 'CpfCnpj' ]                    // 08.3Q  Tipo  Tipo de Inscri??o              18   18   1  -  Num           *G005
      cTxt += PADL( hAux[ 'Inscr' ], 15, '0' )     // 09.3Q  Numero de Inscri??o                  19   33  15  -  Num           *G006
      cTxt += PADR( ::Pagador______[ 2 ], 40 )     // 10.3Q  Nome                                 34   73  40  -  Alfa           G013
      cTxt += PADR( ::Pagador______[ 3 ], 40 )     // 11.3Q  Endere?o                             74  113  40  -  Alfa           G032
      cTxt += PADR( ::Pagador______[ 4 ], 15 )     // 12.3Q  Bairro                              114  128  15  -  Alfa           G032
      cTxt += PADR( ::Pagador______[ 7 ], 8, '0' ) // 13.3Q  CEP                                 129  133   5  -  Num            G034
      cTxt += ''                                   // 14.3Q  Sufixo do CEP                       134  136   3  -  Num            G035
      cTxt += PADR( ::Pagador______[ 5 ], 15 )     // 15.3Q  Cidade                              137  151  15  -  Alfa           G033
      cTxt += PADR( ::Pagador______[ 6 ],  2 )     // 16.3Q  Sacado UF                           152  153   2  -  Alfa           G036
      cTxt += '0'                                  // 17.3Q  Tipo de Inscri??o                   154  154   1  -  Num           *G005
      cTxt += REPL( '0', 15 )                      // 18.3Q  Numero de Inscri??o                 155  169  15  -  Num           *G006
      cTxt += SPACE( 40 )                          // 19.3Q  Sacador/Avalista                    170  209  40  -  Alfa           G013
      cTxt += REPL( '0', 3 )                       // 20.3Q  Banco Correspondente                210  212   3  -  Num           *C031
      cTxt += SPACE( 20 )                          // 21.3Q  Nosso N? no Banco Correspondente    213  232  20  -  Alfa          *C032
      cTxt += SPACE( 8 )                           // 22.3Q  Uso Exclusivo FEBRABAN/CNAB         233  240   8  -  Alfa  Brancos  G004
      /* Add */
      AAdd( ::Cnab_Data____, cTxt )

      /* Registro Detalhe - Segmento R */
      i++
      cTxt := ::Banco________                      // 01.3R  Codigo do Banco                       1    3   3  -  Num            G001
      cTxt += '0001'                               // 02.3R  Lote                                  4    7   4  -  Num           *G002
      cTxt += "3"                                  // 03.3R  Tipo de Registro                      8    8   1  -  Num  ?3?      *G003
      cTxt += STRZERO( i, 5 )                      // 04.3R  N? do Registro                        9   13   5  -  Num           *G038
      cTxt += "R"                                  // 05.3R  Segmento                             14   14   1  -  Alfa ?R?      *G039
      cTxt += SPACE( 1 )                           // 06.3R  Uso Exclusivo FEBRABAN/CNAB          15   15   1  -  Alfa Brancos   G004
      cTxt += '01'                                 // 07.3R  Codigo de Movimento Remessa          16   17   2  -  Num           *C004
      cTxt += REPL( '0', 72 )
      cTxt += SPACE( 90 )
      cTxt += '000000000000000000000000000000000000 000000000000  0000000000'
      /* Add */
      AAdd( ::Cnab_Data____, cTxt )

   ENDIF

   IF ::Banco________ == "237"

      // ----- registro detalhe -----
      /* 001 */ cTxt := "1"                                        // Fixo: 1=Movimentacao
      /* 002 */ cTxt += StrZero( 0, 5 )                            // Opcional: Agencia do Pagador
      /* 007 */ cTxt += "0"                                        // Opcional: Digito da Agencia do Pagador
      /* 008 */ cTxt += StrZero( 0, 5 )                            // Opcional: Razao da Conta do Pagador
      /* 013 */ cTxt += StrZero( 0, 7 )                            // Opcional: Numero da Conta do Pagador
      /* 020 */ cTxt += "0"                                        // Optional: Digito do Numero da Conta do Pagador
      /* 021 */ cTxt += "0" + StrZero( Val( ::Carteira_____ ), 3 ) + StrZero( Val( ::Banco_Agencia ), 5 ) + StrZero( Val( ::Conta________ ), 7 ) + StrZero( Val( ::Conta_DV_____ ), 1 ) // 17 // Zero + Carteira + Agencia sem digito + Conta + Digito Conta do Beneficiario
      /* 038 */ cTxt += Space(25)                                  // Numero de controle do participante - olhar pag. 17
      /* 063 */ cTxt += StrZero(0, 3 )                             // Codigo do banco a ser debitado - olhar pag.17
      /* 066 */ cTxt += "0"                                        // Multa, 2=percentual, 0=sem multa
      /* 067 */ cTxt += StrZero( 0, 4 )                            // Percentual de multa - olhar pag 17
      /* 071 */ cTxt += StrZero( Val( ::Doc_Numero___ ), 11 )  // ID do titulo no banco - olhar pag. 17 - 10 caracteres + digito = 11 caracteres
      /* 082 */ cTxt += ::DigitoDoc( StrZero( Val( ::Doc_Numero___ ), 10 ) ) // Digito de controle da ID do titulo
      /* 083 */ cTxt += StrZero( 0, 10 )                           // Desconto Bonificacao por dia
      /* 093 */ cTxt += "2"                                        // 1=Banco emite, 2=Cliente emite - olhar pag. 19
      /* 094 */ cTxt += "N"                                        // N=Nao registra, outracoisa=banco emite para debito automatico - olhar pag. 19
      /* 095 */ cTxt += Space(10)                                  // Brancos
      /* 105 */ cTxt += Space(1)                                   // Indicacao de Rateio
      /* 106 */ cTxt += Space(1)                                   // Enderecamento para aviso de debito
      /* 107 */ cTxt += Space(2)                                   // Brancos
      /* 109 */ cTxt += "01"                                       // Identificacao da ocorrencia - 01=Remessa
      /* 111 */ cTxt += Space(10)                                  // Numero do documento
      /* 121 */ cTxt += StrZero( Day( ::Vencimento___ ), 2 ) + StrZero( Month( ::Vencimento___ ), 2 ) + Right( StrZero( Year( ::Vencimento___ ), 4 ), 2 ) // Data vencto DDMMAA
      /* 127 */ cTxt += StrZero( ::Valor________ * 100, 13 )       // Valor do titulo
      /* 140 */ cTxt += StrZero( 0, 3 )                            // Zeros - Banco Encarregado da cobranca
      /* 143 */ cTxt += StrZero( 0, 5 )                            // Zeros - Agencia depositaria
      /* 148 */ cTxt += "99"                                       // 01-duplicata, 05-Recibo, 99-Outros
      /* 150 */ cTxt += "N"                                        // Sempre N - identificacao
      /* 151 */ cTxt += StrZero( Day( ::Doc_Data_____ ), 2 ) + StrZero( Month( ::Doc_Data_____ ), 2 ) + Right( StrZero( Year( ::Doc_Data_____ ) , 4 ), 2 ) // Data de emissao do titulo DDMMAA
      /* 157 */ cTxt += "00"                                       // Instrucao - olhar pag. 20 // 00=nada,06=protestar,18=Baixar
      /* 159 */ cTxt += "00"                                       // Instrucao - olhar pag. 20 // complemento do anterior, indicando qtde. dias
      /* 161 */ cTxt += StrZero( ::Juros_Mes____ * ::Valor________ / 30, 13 )  // Multa por dia - olhar pag. 21
      /* 174 */ cTxt += StrZero( 0, 6 )                            // Data limite pra desconto
      /* 180 */ cTxt += StrZero( 0, 13 )                           // Valor do desconto
      /* 193 */ cTxt += StrZero( 0, 13 )                           // Valor IOF
      /* 206 */ cTxt += StrZero( 0, 13 )                           // Valor Abatimento
      /* 219 */ cTxt += iif( Len( ::Pagador______[ 1 ] ) == 14, "02", "01" ) // 01=CPF, 02=CNPJ, 98=Nao tem, 99=Outros
      /* 221 */ cTxt += StrZero( Val( ::Pagador______[ 1 ] ), 14 ) // Numero do CPF ou CNPJ - olhar pag. 21
      /* 235 */ cTxt += Pad( ::Pagador______[ 2 ], 40 )            // Nome do pagador
      /* 275 */ cTxt += Pad( ::Pagador______[ 3 ], 40 )            // Endereco do pagador
      /* 315 */ cTxt += Space(12)                                  // Primeira mensagem
      /* 327 */ cTxt += ::Pagador______[ 4 ]                       // CEP
      /* 335 */ cTxt += Space(60)                                  // Pagador/Avalista ou segunda mensagem
      /* 395 */ cTxt += StrZero( Len( ::Cnab_Data____ ), 6 )       // Numero sequencial de registro
      ::Cnab_Data____[ Len( ::Cnab_Data____ ) ] := cTxt

      AAdd( ::Cnab_Data____, cTxt )

   ENDIF

RETURN NIL

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:DigitoDoc( cDocNumero, cCarteira )
//
// *-------------------------------------------------------------------------*
METHOD DigitoDoc( cDocNumero, cCarteira ) Class MR_Boleto
   LOCAL nCont, nNumero, nResto, cDigito
   LOCAL nSoma := 0

   FOR nCont = 1 TO 11
      nNumero := Val( Substr( Right( cCarteira, 2 ) + cDocNumero, nCont, 1 ) ) // 2 dig.carteira + 10 dig.Numero (11 c/ dig.controle)
      nSoma := nSoma + ( nNumero * { 2, 7, 6, 5, 4, 3, 2, 7, 6, 5, 4, 3, 2 }[ nCont ] )
   NEXT

   nResto := Mod( nSoma, 11 )

   IF nResto == 0
      cDigito := "0"
   ELSEIF nResto == 1
      cDigito := "P"
   ELSE
      cDigito := Str( 11 - nResto, 1 )
   ENDIF

RETURN( cDigito )

// *-------------------------------------------------------------------------*
//
// M., Ronaldo: Boleto Bancario em Harbour
//
// METHOD MR_Boleto:Cnab_Save()
//
// *-------------------------------------------------------------------------*
METHOD Cnab_Save() Class MR_Boleto

   LOCAL cNumero
   LOCAL cAux
   LOCAL cFile
   LOCAL cTxt
   LOCAL i
   LOCAL nAux
   LOCAL hAux

   hAux := hb_hash()
   hAux[ 'Banco' ] := PADR( UPPER( ::Banco_Nome___ ), 30 )
   hAux[ 'Inscr' ] := ALLTRIM( LEFT( ::Only_Numbers( ::Beneficiario_[ 1 ] ), 14 ) )
   hAux[ 'CpfCnpj' ] := IIF( LEN( hAux[ 'Inscr' ] ) > 11, '2', '1' )
   cAux := DTOS( ::Cnab_Rem_data )
   hAux[ 'Data' ] := SUBSTR( cAux, 7, 2 ) + SUBSTR( cAux, 5, 2 ) + SUBSTR( cAux, 1, 4 )
   hAux[ 'Hora' ] := STRTRAN( TIME(), ':', '' )
   cAux := DTOS( ::Vencimento___ )
   hAux[ 'Vencimento' ] := SUBSTR( cAux, 7, 2 ) + SUBSTR( cAux, 5, 2 ) + SUBSTR( cAux, 3, 2 )
   hAux[ 'Valor' ] := PADL( hb_NtoS( ROUND( ::Valor________, 2 ) ), 13,  '0' )
   hAux[ 'JuroDia' ] := PADL( hb_NtoS( ROUND( ::Valor________ * ( ( ( ::Juros_Mes____ * 12 ) / 365 ) / 100 ), 2 ) ), 13,  '0' )
   cAux := hb_NtoS( YEAR( ::Cnab_Rem_data ) ) + '0101'
   hAux[ 'Sequencia' ] := STRZERO( ::Cnab_Rem_data - STOD( cAux ), 6 )
   hAux[ 'Registros' ] := StrZero( Len( ::Cnab_Data____ ) + 1, 6 )
   hAux[ 'Prefixo' ] := PADR( '00'+::Prefixo______ + ::Prefixo_DV___ + '0014' + ::Carteira_____ + ::Cart_Variacao, 20 )

   /* Header de Arquivo */
   cTxt := ::Banco________                   // 01.0  Banco  Codigo do Banco na Compensacao     1    3   3  -  Num            G001
   cTxt += "0000"                            // 02.0  Lote de Servico                           4    7   4  -  Num  '0000'   *G002
   cTxt += "0"                               // 03.0  Tipo de Registro                          8    8   1  -  Num  '0'      *G003
   cTxt += SPACE( 9 )                        // 04.0  Uso Exclusivo FEBRABAN / CNAB             9   17   9  -  Alfa  Brancos  G004
   cTxt += hAux[ 'CpfCnpj' ]                 // 05.0  Tipo de Inscri??o da Empresa             18   18   1  -  Num           *G005
   cTxt += PADL( hAux[ 'Inscr' ], 14, '0' )  // 06.0  CNPJ/CPF Numero Inscri??o Empresa        19   32  14  -  Num           *G006
   cTxt += SPACE( 20 )                       // 07.0  Codigo do Conv?nio no Banco              33   52  20  -  Alfa          *G007 // PADR( '00'+::Prefixo______, 20 )
   cTxt += PADL( ::Banco_Agencia, 5, '0' )   // 08.0  Codigo  Agencia Mantenedora da Conta     53   57   5  -  Num           *G008
   cTxt += ::Banco_Ag_Dv__                   // 09.0  DV da Agencia                            58   58   1  -  Alfa          *G009
   cTxt += PADL( ::Conta________, 12, '0' )  // 10.0  Numero da Conta Corrente                 59   70  12  -  Num           *G010
   cTxt += ::Conta_DV_____                   // 11.0  DV da Conta                              71   71   1  -  Alfa          *G011
   cTxt += SPACE( 1 )                        // 12.0  D?gito Verificador da Ag/Conta           72   72   1  -  Alfa          *G012
   cTxt += PADR( ::Beneficiario_[ 2 ], 30 )  // 13.0  Nome da Empresa                          73  102  30  -  Alfa           G013
   cTxt += hAux[ 'Banco' ]                   // 14.0  Nome do Banco                           103  132  30  -  Alfa           G014
   cTxt += SPACE( 10 )                       // 15.0  Uso Exclusivo FEBRABAN / CNAB           133  142  10  -  Alfa  Brancos  G004
   cTxt += '1'                               // 16.0  Codigo Remessa / Retorno                143  143   1  -  Num            G015
   cTxt += hAux[ 'Data' ]                    // 17.0  Data de Gera??o do Arquivo              144  151   8  -  Num            G016
   cTxt += hAux[ 'Hora' ]                    // 18.0  Hora de Gera??o do Arquivo              152  157   6  -  Num            G017
   cTxt += hAux[ 'Sequencia' ]               // 19.0  Numero Seq?encial do Arquivo            158  163   6  -  Num           *G018
   cTxt += '082'                             // 20.0  Versao do Layout do Arquivo             164  166   3  -  Num  '082'    *G019
   cTxt += REPL( '0', 5 )                    // 21.0  Densidade de Grava??o do Arquivo        167  171   5  -  Num            G020
   cTxt += SPACE( 20 )                       // 22.0  Uso Reservado do Banco                  172  191  20  -  Alfa           G021
   cTxt += SPACE( 20 )                       // 23.0  Uso Reservado da Empresa                192  211  20  -  Alfa           G022
   cTxt += SPACE( 29 )                       // 24.0  Uso Exclusivo FEBRABAN / CNAB           212  240  29  -  Alfa  Brancos  G004
   /* Add */
   ::Cnab_Data____[ 1 ] := cTxt

   /* Header da Empresa */
   cTxt := ::Banco________                   // 01.1  Codigo do Banco na Compensacao      3
   cTxt += "0001"                            // 02.1  Lote de Servico                     4   '0001'
   cTxt += "1"                               // 03.1  Tipo de Registro                    1   '1'
   cTxt += "R"                               // 04.1  Tipo de Operacao                    1   (R)emessa, Re(T)orno
   cTxt += "01"                              // 05.1  Tipo de Servico                     2   '01'
   cTxt += SPACE( 2 )                        // 06.1  Uso Exclusivo FEBRABAN/CNAB         2   Brancos
   cTxt += "041"                             // 07.1  N? da Versao do Layout do Lote      3   '041'
   cTxt += " "                               // 08.1  Uso Exclusivo FEBRABAN/CNAB         1   Brancos
   cTxt += hAux[ 'CpfCnpj' ]                 // 09.1  Tipo de Inscri??o da Empresa        1   0-Isento, 1-Cpf, 2-Cnpj, 3-Pis, 9-Outros
   cTxt += PADL( hAux[ 'Inscr' ], 15, '0' )  // 10.1  N? de Inscri??o da Empresa         15
   cTxt += hAux[ 'Prefixo' ]                 // 11.1  Codigo do Conv?nio no Banco        20
   cTxt += PADL( ::Banco_Agencia,  5, '0' )  // 12.1  Agencia Mantenedora da Conta        5
   cTxt += ::Banco_Ag_Dv__                   // 13.1  D?gito Verificador da Conta         1
   cTxt += PADL( ::Conta________, 12, '0' )  // 14.1  Numero da Conta Corrente           12
   cTxt += ::Conta_DV_____                   // 15.1  D?gito Verificador da Conta         1
   cTxt += SPACE( 1 )                        // 16.1  D?gito Verificador da Ag/Conta      1
   cTxt += PADR( ::Beneficiario_[ 2 ], 30 )  // 17.1  Nome da Empresa                    30
   cTxt += PADR( ::Instrucoes___[ 1 ], 40 )  // 18.1  Mensagem 1                         40
   cTxt += PADR( ::Instrucoes___[ 2 ], 40 )  // 19.1  Mensagem 2                         40
   cTxt += REPL( '0',  8 )                   // 20.1  Numero Remessa/Retorno              8
   cTxt += hAux[ 'Data' ]                    // 21.1  Data de Grava??o Remessa/Retorno    8
   cTxt += REPL( '0',  8 )                   // 22.1  Data do Cr?dito                     8
   cTxt += REPL( ' ', 33 )                   // 23.1  Uso Exclusivo FEBRABAN/CNAB        33   Brancos
   /* Add */
   ::Cnab_Data____[ 2 ] := cTxt

   /* Registro Trailer de Lote */
   hAux[ 'Registros' ] := StrZero( Len( ::Cnab_Data____ ), 6 )
   cTxt := ::Banco________                   // 01.5  Banco                                 1    3   3  -  Num            G001
   cTxt += "0001"                            // 02.5  Lote Servico                          4    7   4  -  Num           *G002
   cTxt += "5"                               // 03.5  Tipo Registro                         8    8   1  -  Num  ?5?      *G003
   cTxt += SPACE( 9 )                        // 04.5  Uso Exclusivo FEBRABAN/CNAB           9   17   9  -  Alfa  Brancos  G004
   cTxt += hAux[ 'Registros' ]               // 05.5  Qtd Registros Lote                   18   23   6  -  Num           *G057
   cTxt += REPL( '0',  6 )                   // 06.5  Qtd Tit.Cobranca Simples             24   29   6  -  Num           *C070
   cTxt += REPL( '0', 17 )                   // 07.5  Vlr Total Tit.Carteiras Simples      30   46  15  2  Num           *C071
   cTxt += REPL( '0',  6 )                   // 08.5  Qtd Tit.Cobranca Vinculada           47   52   6  -  Num           *C070
   cTxt += REPL( '0', 17 )                   // 09.5  Vlr Total Tit.Carteiras Vinculada    53   69  15  2  Num           *C071
   cTxt += REPL( '0',  6 )                   // 10.5  Qtd Tit.Cobranca Caucionada          70   75   6  -  Num           *C070
   cTxt += REPL( '0', 17 )                   // 11.5  Vlr Tit.Carteiras Caucionada         76   92  15  2  Num           *C071
   cTxt += REPL( '0',  6 )                   // 12.5  Qtd Tit.Cobranca Descontada          93   98   6  -  Nim           *C070
   cTxt += REPL( '0', 17 )                   // 13.5  Vlr Total  Tit.Carteiras Descontada  99  115  15  2  Num           *C071
   cTxt += SPACE(   8 )                      // 14.5  Numero do Aviso Lancamento          116  123   8  -  Alfa          *C072
   cTxt += SPACE( 117 )                      // 15.5  Uso Exclusivo FEBRABAN/CNAB         124  240 117  -  Alfa  Brancos  G004
   /* Add */
   AAdd( ::Cnab_Data____, cTxt )

   /* Trailer de Arquivo */
   hAux[ 'Registros' ] := StrZero( Len( ::Cnab_Data____ ) + 1, 6 )
   cTxt := ::Banco________                   // 01.9  Banco  Codigo do Banco na Compensacao     1    3    3  -  Num            G001
   cTxt += "9999"                            // 02.9  Lote de Servico                           4    7    4  -  Num  '9999'   *G002
   cTxt += "9"                               // 03.9  Tipo de Registro                          8    8    1  -  Num  '9'      *G003
   cTxt += SPACE( 9 )                        // 04.9  Uso Exclusivo FEBRABAN/CNAB               9   17    9  -  Alfa  Brancos  G004
   cTxt += "000001"                          // 05.9  Quantidade de Lotes do Arquivo           18   23    6  -  Num            G049
   cTxt += hAux[ 'Registros' ]               // 06.9  Quantidade Registros Arquivo             24   29    6  -  Num   NR LINH  G056
   cTxt += "000000"                          // 07.9  Qtde de Contas p/ Conc. (Lotes)          30   35    6  -  Num           *G037
   cTxt += SPACE( 205 )                      // 08.9  Uso Exclusivo FEBRABAN/CNAB              36  240  205  -  Alfa  Brancos  G004
   /* Add */
   AAdd( ::Cnab_Data____, cTxt )

   nAux := Len( ::Cnab_Data____ )
   cTxt := ''
   FOR i := 1 TO nAux
     cTxt += ::Cnab_Data____[ i ] + IIF( i < nAux, HB_EOL(), '' )
   NEXT

// cNumero := "01"
// cFile := Cnab_Path____ + "CB" + StrZero( Day( Date() ), 2 ) + StrZero( Month( Date() ), 2 )
// WHILE File( cFile + cNumero + ".REM" )
//    cNumero := StrZero( Val( cNumero ) + 1, 2 )
// ENDDO
// cFile := cFile + cNumero + ".REM"

   cAux := DTOS( Date() )
   cNumero := PADL( ALLTRIM( LEFT( ::Only_Numbers( ::Doc_Numero___ ), 6 ) ), 6, '0' )
   cFile := ::Cnab_Path____ + "CB" + Substr( cAux, 7, 2 ) + Substr( cAux, 5, 2 ) + "_" + cNumero + ".REM"
   IF hb_FileExists( cFile )
      FERASE( cFile )
   ENDIF

   hb_MemoWrit( cFile, cTxt )

   ::Cnab_Data____ := { '', '' }
   ::Cnab_Remessa_ := .F.

RETURN( NIL )
