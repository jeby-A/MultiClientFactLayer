
/*
	drop view factlayer.InvoiceBase
	create schema fact
	
	select distinct Owner_Key from fact.InvoiceView_Base

	select top 10 * from fact.InvoiceView_Base
	where BLNG_PlaceTrust = 1
	
	
	select top 10 * from fact.InvoiceView_Base
	where BLNG_PlaceValueSource = 'Normed-Google'
	
*/

IF OBJECT_ID(N'fact.Invoice_Chameleon_Base') IS NOT NULL
    DROP view fact.Invoice_Chameleon_Base
GO
CREATE VIEW fact.Invoice_Chameleon_Base
AS
with AddrNorm_CTE(UntNId, UntTypeId, AddrTypeId, AddrType, InstNum,
	--RawName1, RawName2, RawStreet1, RawStreet2, RawPortStation, 
	--RawCity, RawStateProv, RawPostalCode, RawCountryCode, 
	--NormStreet1, NormStreet2, NormCity, NormStateProv, NormPostalCode, NormCountryCode, 
	--NormRegion, NormTerritory, NormFormattedAddress, NormLocationType, 
	Name1, Name2, 
	Street1, Street2, City, StateProv, PostalCode, CountryCode, 
	FormattedAddress,	
	AddrLatitude, AddrLongitude, AddrTrust, AddrConfidence, AddrAuthority, AddrValueSource,
	PostalLatitude, PostalLongitude, PostalTrust, PostalConfidence, PostalAuthority, PostalValueSource,
	PlaceLatitude, PlaceLongitude, PlaceTrust, PlaceConfidence, PlaceAuthority, PlaceValueSource,	
	AddrHash, RecordDtmUTC)
	AS 	
	(SELECT
		r.LocalUntNId as UntNId,
		r.UntTypeId,
		r.AddrTypeId,
		t.AddrType,
		r.InstNum,
		
		Name1 = r.AddrLine1,
		Name2 = r.AddrLine2, 
		Street1 = case when AddrTrust = 1 then a.NormStreet1 else a.RawStreet1 end,		
		Street2 = case when AddrTrust = 1 then a.NormStreet2 else a.RawStreet2 end,			
		City = case when AddrTrust = 1 Or PlaceTrust = 1 then a.NormCity else a.RawCity end,
		StateProv = case when AddrTrust = 1 Or PlaceTrust = 1 then a.NormStateProv else a.RawStateProv end,
		PostalCode = case when AddrTrust = 1 Or PostalTrust = 1 then a.NormPostalCode else a.RawPostalCode end,
		CountryCode = case when AddrTrust = 1 Or PlaceTrust = 1 Or PostalTrust = 1 then a.NormCountryCode else a.RawCountryCode end,
		
		FormattedAddress = case when AddrTrust = 1 then a.NormFormattedAddress 
							when (PlaceTrust = 1 or PlaceTrust = 0) and PostalTrust = 1 then 
								isnull(a.RawStreet1 + ',', '') +  
								isnull(a.RawStreet2 + ',', '') + 
								isnull(a.NormCity + ',', '') + 
								isnull(a.NormStateProv + ',', '') + 
								isnull(a.NormPostalCode + ',', '') + 
								isnull(a.NormCountryCode, '')
							when PlaceTrust = 1 and PostalTrust = 0 then 
									isnull(a.RawStreet1 + ',', '') +  
								isnull(a.RawStreet2 + ',', '') + 
								isnull(a.NormCity + ',', '') + 
								isnull(a.NormStateProv + ',', '') + 
								isnull(a.RawPostalCode + ',', '') + 
								isnull(a.NormCountryCode, '')
							when PlaceTrust = 0 and PostalTrust = 0 then 
									isnull(a.RawStreet1 + ',', '') +  
								isnull(a.RawStreet2 + ',', '') + 
								isnull(a.RawCity + ',', '') + 
								isnull(a.RawStateProv + ',', '') + 
								isnull(a.RawPostalCode + ',', '') + 
								isnull(a.RawCountryCode, '')
							else 
								isnull(a.RawStreet1 + ',', '') +  
								isnull(a.RawStreet2 + ',', '') + 
								isnull(a.RawCity + ',', '') + 
								isnull(a.RawStateProv + ',', '') + 
								isnull(a.RawPostalCode + ',', '') + 
								isnull(a.RawCountryCode, '')
							end,
		a.AddrLatitude,
		a.AddrLongitude,
		a.AddrTrust,
		a.AddrConfidence,
		a.AddrAuthority,
		AddrValueSource =case when a.AddrTrust = 1 then 'DataComponent'
							else 'Raw' end,
		
		a.PostalLatitude,
		a.PostalLongitude,
		a.PostalTrust,
		a.PostalConfidence,
		a.PostalAuthority,
		PostalCodeValueSource =case when a.AddrTrust = 1 or a.PostalTrust = 1 then 'DataComponent'
							else 'Raw' end,
							
		a.PlaceLatitude,
		a.PlaceLongitude,
		a.PlaceTrust,
		a.PlaceConfidence,
		a.PlaceAuthority,
		PlaceValueSource =case when a.AddrTrust = 1 or a.PostalTrust = 1 or a.PlaceTrust = 1 
							then 'DataComponent'
							else 'Raw' end,
		
		a.AddrHash,
		a.RecordDtmUTC		
	FROM dbo.AddrRaw r with(nolock) 
	left join DNorm.AddrRawToAddrNormAtom j on r.LocalUntNId = j.UntNId and r.UntTypeId = j.UntTypeId and r.AddrTypeId = j.AddrTypeId and r.InstNum = j.InstNum
	left join dbo.AddrType t on r.AddrTypeId = t.AddrTypeId
	left join DNorm.AddrNormAtom a on j.AddrHash = a.AddrHash
	WHERE r.UntTypeId = 2 --inv level addresses
)
--select * from AddrNorm_CTE;

select
		inv.[INV_ID], 
		ext.InvNId,      
		inv.[OWNER_KEY],
		[INV_VOID_FLAG], inv.[BAT_ID], 
		inv.[BAT_KEY], [VEND_BAT_KEY],
		inv.[INV_ORIG_ID],
		
		--LSPName
		LspOrgId, LspOrgName, LspOrgTrust, LspOrgConfidence, LspOrgAuthority, LspOrgDtmUtc,
		--DataSource
		DataSourceId, DataSourceName, DataSourceTrust, DataSourceConfidence, DataSourceAuthority, DataSourceDtmUtc,
		--InvAmtUSD
		InvAmtUSD, InvAmtUSDTrust, InvAmtUSDConfidence, InvAmtUSDAuthority, InvAmtUSDDtmUtc,
		--BillTo Geo Component
		[AL_BLNG_1] = [AL_BLNG_1],
		[AL_BLNG_2] = [AL_BLNG_2],
		[AL_BLNG_3] = case when bt.UntNId is not null then bt.Street1 else [AL_BLNG_3] end,
		[AL_BLNG_4] = case when bt.UntNId is not null then bt.Street2 else [AL_BLNG_4] end,
		[AL_CITY_BLNG] = case when bt.UntNId is not null then bt.City else [AL_CITY_BLNG] end,
		[AL_STATE_PROV_BLNG] = case when bt.UntNId is not null then bt.StateProv else [AL_STATE_PROV_BLNG] end,
		[AL_POST_CODE_BLNG] = case when bt.UntNId is not null then bt.PostalCode else [AL_POST_CODE_BLNG] end,
		[AL_CNTRY_CODE_BLNG] = case when bt.UntNId is not null then bt.CountryCode else [AL_CNTRY_CODE_BLNG] end,
		
		BLNG_FormattedAddress = case when bt.UntNId is not null then bt.FormattedAddress
								 else 
									isnull([AL_BLNG_3] + ',', '') +  
									isnull([AL_BLNG_4] + ',', '') + 
									isnull([AL_CITY_BLNG] + ',', '') + 
									isnull([AL_STATE_PROV_BLNG] + ',', '') + 
									isnull([AL_POST_CODE_BLNG] + ',', '') + 
									isnull([AL_CNTRY_CODE_BLNG], '') 
									end,		
		BLNG_AddrLatitude = bt.AddrLatitude,
		BLNG_AddrLongitude = bt.AddrLongitude,
		BLNG_AddrTrust = bt.AddrTrust,
		BLNG_AddrConfidence = bt.AddrConfidence,
		BLNG_AddrAuthority = bt.AddrAuthority,
		BLNG_AddrValueSource = case when bt.UntNId is not null then bt.AddrValueSource else 'Legacy' end,		
		
		BLNG_PostalLatitude = bt.PostalLatitude,
		BLNG_PostalLongitude = bt.PostalLongitude,
		BLNG_PostalTrust = bt.PostalTrust,
		BLNG_PostalConfidence = bt.PostalConfidence,
		BLNG_PostalAuthority = bt.PostalAuthority,
		BLNG_PostalValueSource = case when bt.UntNId is not null then bt.PostalValueSource else 'Legacy' end,
		
		BLNG_PlaceLatitude = bt.PlaceLatitude,
		BLNG_PlaceLongitude = bt.PlaceLongitude,
		BLNG_PlaceTrust = bt.PlaceTrust,
		BLNG_PlaceConfidence = bt.PlaceConfidence,
		BLNG_PlaceAuthority = bt.PlaceAuthority,
		BLNG_PlaceValueSource = case when bt.UntNId is not null then bt.PlaceValueSource else 'Legacy' end,
					
		BLNG_AddrHash = bt.AddrHash,
		BLNG_RecordDtmUTC = bt.RecordDtmUTC,
		
		--RemitTo Component
		[AL_REMIT_1] = [AL_REMIT_1],
		[AL_REMIT_2] = [AL_REMIT_2], 
		[AL_REMIT_3] = br.Street1, 
		[AL_REMIT_4] = br.Street2,
		[AL_CITY_REMIT] = br.City, 
		[AL_STATE_PROV_REMIT] = br.StateProv, 
		[AL_POST_CODE_REMIT] = br.PostalCode, 
		[AL_CNTRY_CODE_REMIT] = br.CountryCode,
				
		REMIT_FormattedAddress = case when br.UntNId is not null then br.FormattedAddress
								 else 
									isnull([AL_REMIT_3] + ',', '') +  
									isnull([AL_REMIT_4] + ',', '') + 
									isnull([AL_CITY_REMIT] + ',', '') + 
									isnull([AL_STATE_PROV_REMIT] + ',', '') + 
									isnull([AL_POST_CODE_REMIT] + ',', '') + 
									isnull([AL_CNTRY_CODE_REMIT], '') 
									end,			
		REMIT_AddrLatitude = br.AddrLatitude,
		REMIT_AddrLongitude = br.AddrLongitude,
		REMIT_AddrTrust = br.AddrTrust,
		REMIT_AddrConfidence = br.AddrConfidence,
		REMIT_AddrAuthority = br.AddrAuthority,
		REMIT_AddrValueSource = case when br.UntNId is not null then br.AddrValueSource else 'Legacy' end,
		
		REMIT_PostalLatitude = br.PostalLatitude,
		REMIT_PostalLongitude = br.PostalLongitude,
		REMIT_PostalTrust = br.PostalTrust,
		REMIT_PostalConfidence = br.PostalConfidence,
		REMIT_PostalAuthority = br.PostalAuthority,
		REMIT_PostalValueSource = case when br.UntNId is not null then br.PostalValueSource else 'Legacy' end,
		
		REMIT_PlaceLatitude = br.PlaceLatitude,
		REMIT_PlaceLongitude = br.PlaceLongitude,
		REMIT_PlaceTrust = br.PlaceTrust,
		REMIT_PlaceConfidence = br.PlaceConfidence,
		REMIT_PlaceAuthority = br.PlaceAuthority,
		REMIT_PlaceValueSource = case when br.UntNId is not null then br.PlaceValueSource else 'Legacy' end,
		
		REMIT_AddrHash = br.AddrHash,
		REMIT_RecordDtmUTC = br.RecordDtmUTC,
		
		--Legacy Fields
		inv.[VEND_LABL],
		inv.[INV_FB_CNT],  
		inv.[INV_AMT], [VEND_INV_AMT], [INV_CURRENCY_QUAL],		
		inv.[INV_KEY], 
		[INV_STAT], 
		[INV_TYPE], 
		[INV_CREAT_DTM], 
		[INV_DUE_DTM],				
		[INV_APP_AMT], 
		[INV_ADJM_AMT], 
		[INV_PD_AMT], 
		[INV_PD_DTM], 
		[INV_ADJM_CNT],
		[INV_PAYMT_CNT], 
		[INV_CREDIT_AMT], 
		[INV_DISPUTE_AMT], 
		[INV_OPEN_AMT],
		inv.[ACCT_NUM_VEND_BLNG], 
		[ACCT_ID_VEND_BLNG], 
		inv.[LOC_ID_BLNG], inv.[LOC_KEY_BLNG],
		[AL_BLNG_QUAL], 
		[AL_PHONE_NUM_BLNG], [AL_PHONE_EXT_BLNG], [LOC_ID_REMIT], [LOC_KEY_REMIT],
		[AL_REMIT_QUAL], 
		[AL_PHONE_NUM_REMIT], [AL_PHONE_EXT_REMIT], inv.[MSG_GRP_NUM],
		[NORMALIZED_SCAC], [INV_KEY_PFX], [INV_KEY_BASE], [INV_KEY_SFX],
		[INV_DUP_PATTERN], [INV_DUP_TYPE], [INV_DUP_RSLT], [INV_DUP_MANUAL_RSLT],
		[INV_DUP_CAP_APP_AMT], [INV_DUP_ADJM_REASON], [INV_DUP_ADJM_DESC],
		[ACCT_NUM_BLNG], [TAX_REG_KEY_BLNG], [TAX_REG_CNTRY_BLNG], [TAX_REG_KEY_VEND],
		[TAX_REG_CNTRY_VEND], [ENTITY_BLNG], [ERP_VEND_CODE], [VEND_INV_DUE_DTM],
		[VEND_NAME], [VEND_ID], [VEND_BLNG_STATION], [INV_NON_TAX_AMT],
		[TAX_AMT], [TAX_PCNT], [SPOT_QUOTE_KEY], [SPOT_QUOTE_AMT], [SPOT_QUOTE_CURRENCY_QUAL],
		[PAYMT_DSCNT_REASON_CODE], [PAYMT_DSCNT_REASON_DESC], [AUTH_KEY],
		[IMG_PAGE_NUM], [IMG_PAGE_CNT]			
    FROM dbo.Invoice inv with(nolock)     
    LEFT JOIN dbo.Invoice_Ext ext with(nolock) on inv.Inv_ID = ext.Inv_ID
    LEFT JOIN [DNorm].[InvNorm] invNorm with(nolock) on invNorm.invnid = ext.invnid
    LEFT JOIN AddrNorm_CTE bt with(nolock) on ext.InvNId = bt.UntNId and bt.UntTypeId = 2 and bt.AddrTypeId = 1
    LEFT JOIN AddrNorm_CTE br with(nolock) on ext.InvNId = br.UntNId and br.UntTypeId = 2 and br.AddrTypeId = 2
    WHERE inv.INV_ID like 'INVC__0%'
	;
 
