
/*
	drop view factlayer.InvoiceBase
	create schema fact
	
	select * from fact.Mapped_MultiClient_Invoice
	sp_help invoice
*/

IF OBJECT_ID(N'fact.Mapped_MultiClient_Invoice') IS NOT NULL
    DROP view fact.Mapped_MultiClient_Invoice
GO
CREATE VIEW fact.Mapped_MultiClient_Invoice
AS
	select
		--LSPName
		LspOrgId, LspOrgName, LspOrgTrust, LspOrgConfidence, LspOrgAuthority, LspOrgDtmUtc,
		--DataSource
		--Data oriented flow
		DataSourceName, DataSourceTrust, DataSourceConfidence, DataSourceAuthority, DataSourceDtmUtc,
		
		--dbo.Invoice table
		inv.INV_ID, ext.InvNId, 
		
		OWNER_KEY,INV_KEY,INV_VOID_FLAG,BAT_ID,BAT_KEY,VEND_BAT_KEY,
		VEND_LABL,INV_STAT,INV_TYPE,INV_ORIG_ID,INV_CREAT_DTM,INV_DUE_DTM,
		INV_FB_CNT,INV_AMT,VEND_INV_AMT,INV_CURRENCY_QUAL,INV_APP_AMT,INV_ADJM_AMT,
		INV_PD_AMT,INV_PD_DTM,INV_ADJM_CNT,INV_PAYMT_CNT,INV_CREDIT_AMT,INV_DISPUTE_AMT,
		INV_OPEN_AMT,ACCT_NUM_VEND_BLNG,ACCT_ID_VEND_BLNG,LOC_ID_BLNG,LOC_KEY_BLNG,AL_BLNG_QUAL,
		AL_BLNG_1,AL_BLNG_2,AL_BLNG_3,AL_BLNG_4,AL_CITY_BLNG,AL_STATE_PROV_BLNG,AL_POST_CODE_BLNG,
		AL_CNTRY_CODE_BLNG,
		BillTo_FormattedAddress = isnull(AL_BLNG_3 + ',', '') +  
								isnull(AL_BLNG_4 + ',', '') + 
								isnull(AL_CITY_BLNG + ',', '') + 
								isnull(AL_STATE_PROV_BLNG + ',', '') + 
								isnull(AL_POST_CODE_BLNG + ',', '') + 
								isnull(AL_CNTRY_CODE_BLNG, ''),
		BillTo_FormattedPlace = isnull(AL_CITY_BLNG + ',', '') + 
								isnull(AL_STATE_PROV_BLNG + ',', '') + 
								isnull(AL_CNTRY_CODE_BLNG, ''),
								
		AL_PHONE_NUM_BLNG,AL_PHONE_EXT_BLNG,LOC_ID_REMIT,LOC_KEY_REMIT,
		AL_REMIT_QUAL,AL_REMIT_1,AL_REMIT_2,AL_REMIT_3,AL_REMIT_4,AL_CITY_REMIT,AL_STATE_PROV_REMIT,
		AL_POST_CODE_REMIT,AL_CNTRY_CODE_REMIT,
		RemitTo_FormattedAddress = isnull(AL_REMIT_3 + ',', '') +  
								isnull(AL_REMIT_4 + ',', '') + 
								isnull(AL_CITY_REMIT + ',', '') + 
								isnull(AL_STATE_PROV_REMIT + ',', '') + 
								isnull(AL_CNTRY_CODE_REMIT, ''),
		RemitTo_FormattedPlace = isnull(AL_CITY_REMIT + ',', '') + 
								isnull(AL_STATE_PROV_REMIT + ',', '') + 
								isnull(AL_CNTRY_CODE_REMIT, ''),
		
		AL_PHONE_NUM_REMIT,AL_PHONE_EXT_REMIT,MSG_GRP_NUM,
		
		--Invoice_Ext Table
		NORMALIZED_SCAC,INV_KEY_PFX,
		INV_KEY_BASE,INV_KEY_SFX,INV_DUP_PATTERN,
		INV_DUP_TYPE,INV_DUP_RSLT,INV_DUP_MANUAL_RSLT,
		INV_DUP_CAP_APP_AMT,INV_DUP_ADJM_REASON,INV_DUP_ADJM_DESC,
		ACCT_NUM_BLNG,TAX_REG_KEY_BLNG,TAX_REG_CNTRY_BLNG,
		TAX_REG_KEY_VEND,TAX_REG_CNTRY_VEND,ENTITY_BLNG,ERP_VEND_CODE,
		VEND_INV_DUE_DTM,VEND_NAME,VEND_ID,VEND_BLNG_STATION,
		INV_NON_TAX_AMT,TAX_AMT,TAX_PCNT,SPOT_QUOTE_KEY,SPOT_QUOTE_AMT,
		SPOT_QUOTE_CURRENCY_QUAL,PAYMT_DSCNT_REASON_CODE,PAYMT_DSCNT_REASON_DESC,
		AUTH_KEY,IMG_PAGE_NUM,IMG_PAGE_CNT
	FROM dbo.Invoice inv with(nolock)     
    LEFT JOIN dbo.Invoice_Ext ext with(nolock) on inv.Inv_ID = ext.Inv_ID
    LEFT JOIN [DNorm].[InvNorm] invNorm with(nolock) on invNorm.invnid = ext.invnid
    --WHERE inv.INV_ID like 'INVC__0%'
	;
 
