/*

	select top 10 * from fact.InvoiceView_BO
*/

IF OBJECT_ID(N'fact.BO_MultiClient_Invoice') IS NOT NULL
    DROP view fact.BO_MultiClient_Invoice
GO
CREATE VIEW fact.BO_MultiClient_Invoice
AS
	SELECT
		INV_ID,OWNER_KEY,INV_KEY,INV_VOID_FLAG,BAT_ID,BAT_KEY,VEND_BAT_KEY,
		VEND_LABL,INV_STAT,INV_TYPE,INV_ORIG_ID,INV_CREAT_DTM,INV_DUE_DTM,
		INV_FB_CNT,INV_AMT,VEND_INV_AMT,INV_CURRENCY_QUAL,INV_APP_AMT,INV_ADJM_AMT,
		INV_PD_AMT,INV_PD_DTM,INV_ADJM_CNT,INV_PAYMT_CNT,INV_CREDIT_AMT,INV_DISPUTE_AMT,
		INV_OPEN_AMT,ACCT_NUM_VEND_BLNG,ACCT_ID_VEND_BLNG,LOC_ID_BLNG,LOC_KEY_BLNG,AL_BLNG_QUAL,
		AL_BLNG_1,AL_BLNG_2,AL_BLNG_3,AL_BLNG_4,AL_CITY_BLNG,AL_STATE_PROV_BLNG,AL_POST_CODE_BLNG,
		AL_CNTRY_CODE_BLNG,AL_PHONE_NUM_BLNG,AL_PHONE_EXT_BLNG,LOC_ID_REMIT,LOC_KEY_REMIT,
		AL_REMIT_QUAL,AL_REMIT_1,AL_REMIT_2,AL_REMIT_3,AL_REMIT_4,AL_CITY_REMIT,AL_STATE_PROV_REMIT,
		AL_POST_CODE_REMIT,AL_CNTRY_CODE_REMIT,AL_PHONE_NUM_REMIT,AL_PHONE_EXT_REMIT,MSG_GRP_NUM
	FROM fact.InvoiceView_Base
	