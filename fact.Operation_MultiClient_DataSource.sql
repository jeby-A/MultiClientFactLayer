/*
	select * 
	from fact.Operation_MultiClient_DataSource
	order by Owner_Key, Vend_Labl
*/

IF OBJECT_ID(N'fact.Operation_MultiClient_DataFlow') IS NOT NULL
    DROP view fact.Operation_MultiClient_DataFlow
GO
CREATE VIEW fact.Operation_MultiClient_DataFlow
AS

SELECT
		FactLayerName = 'Operation - Data Flow', 
		FactLayerTrust = null,
		FactLayerConfidence = null,
		FactLayerAuthority = null,
		FactLayerDtmUtc = null,
		
		--TODO: 
		--LSPName, Originator, DocFormat, DocType
		--DataSource
		DataSourceName, 
		DataSourceTrust, 
		DataSourceConfidence, 
		DataSourceAuthority, 
		DataSourceDtmUtc,
		
		--TransType
		
		--RecdType
		
		--Reference fields
		Inv.Inv_ID, 
		Inv.OWNER_KEY, 
		--mapped
		MappedVendLabl = mappedInv.VEND_LABL,		
		MappedInvType = mappedInv.INV_TYPE,
		MappedInvKey = mappedInv.Inv_Key, 
		MappedRemitAddress = mappedInv.RemitTo_FormattedAddress,	
		--refined 
		inv.Vend_Labl,
		Inv.Inv_Key,
		inv.REMIT_FormattedAddress
		
	from fact.Mapped_MultiClient_Invoice mappedInv
	left join fact.Refined_MultiClient_Invoice inv
		on mappedInv.Inv_ID = inv.Inv_ID

