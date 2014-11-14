/*
	select * 
	from fact.Operation_MultiClient_PaymentTerm
	order by Owner_Key, Vend_Labl
*/

IF OBJECT_ID(N'fact.Operation_MultiClient_PaymentTerm') IS NOT NULL
    DROP view fact.Operation_MultiClient_PaymentTerm
GO
CREATE VIEW fact.Operation_MultiClient_PaymentTerm
AS

SELECT
		FactLayerName = 'Operation - Payment Term', 
		FactLayerTrust = null,
		FactLayerConfidence = null,
		FactLayerAuthority = null,
		FactLayerDtmUtc = null,
		
		fb.FB_PAYMT_TERMS_CODE, 
		fb.PaymentTermCodeTrust, 
		fb.PaymentTermCodeConfidence, 
		fb.PaymentTermCodeAuthority, 
		fb.PaymentTermCodeDtmUtc,
		
		--mapped
		MappedPaymentTermCode = mappedfb.FB_PAYMT_TERMS_CODE,
		
		
		--Reference fields
		fb.DataSourceName, 
		fb.DataSourceTrust, 
		fb.DataSourceConfidence, 
		fb.DataSourceAuthority, 
		fb.DataSourceDtmUtc,
	
		invFlow.Inv_ID,
		mappedFb.FB_ID, 
		mappedFb.OWNER_KEY,		
		
		
		MappedVendLabl = mappedfb.VEND_LABL, 
		MappedInvKey = mappedfb.Inv_Key,
		MappedFbKey = mappedfb.Fb_Key,
		MappedBillToAddress = invFlow.MappedBillToAddress,
		MappedAccNumVendBlng = invFlow.ACCT_NUM_VEND_BLNG,
		MappedTaxRegKeyBlng = invFlow.Tax_Reg_Key_Blng,
		MappedTaxRegCntryBlng = invFlow.Tax_Reg_Cntry_Blng,
		MappedTaxRegKeyVend = invFlow.Tax_Reg_Key_Vend,
		MappedTaxRegCntryVend = invFlow.Tax_Reg_Cntry_Vend,
		
		MappedShipFromAddress = mappedFb.ORIG_FormattedAddress,
		MappedShipToAddress = mappedFb.Dest_FormattedAddress,
		
		--refined
		fb.Vend_Labl,
		fb.Inv_Key,
		fb.Fb_Key,
		fb.fb_Stat,
		invFlow.BLNG_FormattedAddress,
		invFlow.ACCT_NUM_VEND_BLNG,
		invFlow.Tax_Reg_Key_Blng,
		invFlow.Tax_Reg_Cntry_Blng,
		invFlow.Tax_Reg_Key_Vend,
		invFlow.Tax_Reg_Cntry_Vend,
		invFlow.Entity_Blng,
		invFlow.ERP_Vend_Code,
		ShipFromAddress = fb.ORIG_FormattedAddress,
		ShipToAddress = fb.Dest_FormattedAddress
		
	from fact.Mapped_MultiClient_FrghtBl mappedfb
	left join fact.Refined_MultiClient_FrghtBL fb
		on mappedfb.FB_ID = fb.FB_ID
	left join fact.Operation_MultiClient_InvoiceFlow invFlow
		on mappedfb.Inv_ID = invFlow.Inv_ID
