--select * from fact.Operation_MultiClient_BillingAccount

IF OBJECT_ID(N'fact.Operation_MultiClient_BillingAccount') IS NOT NULL
    DROP view fact.Operation_MultiClient_BillingAccount
GO
CREATE VIEW fact.Operation_MultiClient_BillingAccount
AS
SELECT
		FactLayerName = 'Operation - Billing Account', 
		FactLayerTrust = null,
		FactLayerConfidence = null,
		FactLayerAuthority = null,
		FactLayerDtmUtc = null,
		
		inv.ACCT_NUM_VEND_BLNG,
		AcctNumVendBlngTrust,
		AcctNumVendBlngConfidence,
		AcctNumVendBlngAuthority,
		AcctNumVendBlngValueSource,
		
		--Reference fields
		DataSourceName, 
		DataSourceTrust, 
		DataSourceConfidence, 
		DataSourceAuthority, 
		DataSourceDtmUtc,
	
		mappedInv.Inv_ID, 
		mappedInv.OWNER_KEY,
		
		--mapped 
		MappedVendLabl = mappedInv.VEND_LABL, 
		MappedInvKey = mappedInv.Inv_Key,
		MappedAccNumVendBlng = mappedInv.ACCT_NUM_VEND_BLNG,
		MappedAccIdVendBlng = mappedInv.ACCT_ID_VEND_BLNG,
		MappedBillToAddress = mappedInv.BillTo_FormattedAddress,
		MappedRemitToAddress = mappedInv.RemitTo_FormattedAddress,		
		MappedTaxRegKeyBlng = mappedInv.Tax_Reg_Key_Blng,
		MappedTaxRegCntryBlng = mappedInv.Tax_Reg_Cntry_Blng,
		MappedTaxRegKeyVend = mappedInv.Tax_Reg_Key_Vend,
		MappedTaxRegCntryVend = mappedInv.Tax_Reg_Cntry_Vend,
		
		--refined
		inv.Vend_Labl,
		inv.Inv_Key,
		inv.Inv_Stat,
		inv.ACCT_ID_VEND_BLNG,
		inv.BLNG_FormattedAddress,
		inv.REMIT_FormattedAddress,		
		inv.Tax_Reg_Key_Blng,
		inv.Tax_Reg_Cntry_Blng,
		inv.Tax_Reg_Key_Vend,
		inv.Tax_Reg_Cntry_Vend,
		inv.Entity_Blng,
		inv.ERP_Vend_Code		
	from fact.Mapped_MultiClient_Invoice mappedInv
	left join fact.Refined_MultiClient_Invoice inv
		on mappedInv.Inv_ID = inv.Inv_ID			