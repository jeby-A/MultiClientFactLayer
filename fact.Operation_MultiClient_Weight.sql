/*
	select * 
	from fact.Operation_MultiClient_Weight
	order by Owner_Key, Vend_Labl
*/

IF OBJECT_ID(N'fact.Operation_MultiClient_Weight') IS NOT NULL
    DROP view fact.Operation_MultiClient_Weight
GO
CREATE VIEW fact.Operation_MultiClient_Weight
AS

SELECT
		FactLayerName = 'Operation - Weight', 
		FactLayerTrust = null,
		FactLayerConfidence = null,
		FactLayerAuthority = null,
		FactLayerDtmUtc = null,
		
		fb.FB_ACTUAL_WT,
		FbActualWtTrust,
		FbActualWtConfidence,
		FbActualWtAuthority,
		FbActualWtValueSource,
		
		fb.FB_FNCL_WT,
		FbFnclWtTrust,
		FbFnclWtConfidence,
		FbFnclWtAuthority,
		FbFnclWtValueSource,
		
		fb.FB_WT_QUAL,
		FbWtQualTrust,
		FbWtQualConfidence,
		FbWtQualAuthority,
		FbWtQualValueSource,
		
		ActualWeightTrust,
		ActualWeightConfidence,
		ActualWeightAuthority,
		ActualWeightValueSource,
		
		FinancialWeightTrust,
		FinancialWeightConfidence,
		FinancialWeightAuthority,
		FinancialWeightValueSource,
		
		--mapped
		MappedFbActualWt = mappedfb.FB_ACTUAL_WT,
		MappedFbFnclWt = mappedfb.FB_FNCL_WT,
		MappedFbWtQual = mappedfb.FB_WT_QUAL,
		MappedFbPkgType = mappedfb.FB_PKG_TYPE,
		
		--Reference fields
		fb.DataSourceName, 
		fb.DataSourceTrust, 
		fb.DataSourceConfidence, 
		fb.DataSourceAuthority, 
		fb.DataSourceDtmUtc,
	
		mappedFb.FB_ID, 
		mappedFb.OWNER_KEY,		
		
		
		MappedVendLabl = mappedfb.VEND_LABL, 
		MappedInvKey = mappedfb.Inv_Key,
		MappedFbKey = mappedfb.Fb_Key,		
		
		MappedShipFromPlace = mappedFb.ORIG_FormattedPlace,
		MappedShipToPlace = mappedFb.Dest_FormattedPlace,
		MappedPriceLaneLabl = mappedfb.PRICE_LANE_LABL,		
		MappedPortOrig = mappedfb.PORT_ORIG,
		MappedPortDest = mappedfb.PORT_Dest,
		MappedCaInfo1Raw = mappedFb.CA_INFO_1_RAW,
		MappedCaInfo2Raw = mappedFb.CA_INFO_2_RAW,
		
		
		--refined
		fb.Vend_Labl,
		fb.Inv_Key,
		fb.Fb_Key,
		fb.fb_Stat,
		fb.FB_PKG_TYPE,
		
		fb.ORIG_FormattedPlace,
		fb.Dest_FormattedPlace,
		fb.PRICE_LANE_LABL,
		fb.PORT_ORIG,
		fb.PORT_DEST		
	from fact.Mapped_MultiClient_FrghtBl mappedfb
	left join fact.Refined_MultiClient_FrghtBL fb
		on mappedfb.FB_ID = fb.FB_ID
