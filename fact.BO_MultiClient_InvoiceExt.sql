/*
select top 10 * from fact.BO_MultiClient_InvoiceExt
*/

IF OBJECT_ID(N'fact.BO_MultiClient_InvoiceExt') IS NOT NULL
    DROP view fact.BO_MultiClient_InvoiceExt
GO
CREATE VIEW fact.BO_MultiClient_InvoiceExt
AS
	SELECT 
		InvNId,INV_ID,NORMALIZED_SCAC,INV_KEY_PFX,
		INV_KEY_BASE,INV_KEY_SFX,INV_DUP_PATTERN,
		INV_DUP_TYPE,INV_DUP_RSLT,INV_DUP_MANUAL_RSLT,
		INV_DUP_CAP_APP_AMT,INV_DUP_ADJM_REASON,INV_DUP_ADJM_DESC,
		ACCT_NUM_BLNG,TAX_REG_KEY_BLNG,TAX_REG_CNTRY_BLNG,
		TAX_REG_KEY_VEND,TAX_REG_CNTRY_VEND,ENTITY_BLNG,ERP_VEND_CODE,
		VEND_INV_DUE_DTM,VEND_NAME,VEND_ID,VEND_BLNG_STATION,
		INV_NON_TAX_AMT,TAX_AMT,TAX_PCNT,SPOT_QUOTE_KEY,SPOT_QUOTE_AMT,
		SPOT_QUOTE_CURRENCY_QUAL,PAYMT_DSCNT_REASON_CODE,PAYMT_DSCNT_REASON_DESC,
		AUTH_KEY,IMG_PAGE_NUM,IMG_PAGE_CNT
	FROM fact.Refined_MultiClient_Invoice