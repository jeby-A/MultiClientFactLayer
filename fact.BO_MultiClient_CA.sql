
/*
	select * from fact.CaElemView_Base	
*/

IF OBJECT_ID(N'fact.BO_MultiClient_CA') IS NOT NULL
    DROP view fact.BO_MultiClient_CA
GO
CREATE VIEW fact.BO_MultiClient_CA
AS
	SELECT 
		UNT_ID,
		CA_LINE_NUM,
		CA_PCNT,
		CA_AMT,
		RULE_KEY_CA,
		CA_ELEM_1,
		CA_ELEM_2,
		CA_ELEM_3,
		CA_ELEM_4,
		CA_ELEM_5,
		CA_ELEM_6,
		CA_ELEM_7,
		CA_ELEM_8,
		CA_ELEM_9,
		CA_ELEM_10,
		CA_ELEM_11,
		CA_ELEM_12,
		MSG_GRP_NUM,
		COST_CENTER,
		GL,
		PIN_FB_LN_CHRG_CODE		
	FROM dbo.CA_ELEM ca with(nolock)
	