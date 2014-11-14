--select * from fact.TraxStandard_MultiClient

IF OBJECT_ID(N'fact.TraxStandard_MultiClient') IS NOT NULL
    DROP view fact.TraxStandard_MultiClient
GO
CREATE VIEW fact.TraxStandard_MultiClient
AS

SELECT
	FactLayerName = 'Trax Standard', 
	FactLayerTrust = null,
	FactLayerConfidence = null,
	FactLayerAuthority = null,
	FactLayerDtmUtc = null,
	
	DataSourceName, 	
	BusinessFlow, 	
	ExecPath,	
	TransType,
	
	fb.[AL_ORIG_1],
	fb.[AL_ORIG_2],
	fb.[AL_ORIG_3],
	fb.[AL_ORIG_4],
	fb.[AL_CITY_ORIG],
	fb.[AL_STATE_PROV_ORIG],
	fb.[AL_POST_CODE_ORIG],
	fb.[AL_CNTRY_CODE_ORIG],
	Orig_FormattedAddress,		
	ORIG_AddrLatitude,
	ORIG_AddrLongitude,
	ORIG_AddrTrust,
	ORIG_AddrConfidence,
	ORIG_AddrAuthority,
	ORIG_AddrValueSource,
		
	ORIG_PostalLatitude,
	ORIG_PostalLongitude,
	ORIG_PostalTrust,
	ORIG_PostalConfidence,
	ORIG_PostalAuthority,
	ORIG_PostalValueSource,
		
	ORIG_PlaceLatitude,
	ORIG_PlaceLongitude,
	ORIG_PlaceTrust,
	ORIG_PlaceConfidence,
	ORIG_PlaceAuthority,
	ORIG_PlaceValueSource,
				
	ORIG_AddrHash,
	ORIG_RecordDtmUTC,
	
	--ShipTo Component
	[AL_DEST_1],
	[AL_DEST_2],
	[AL_DEST_3],
	[AL_DEST_4],
	[AL_CITY_DEST],
	[AL_STATE_PROV_DEST],
	[AL_POST_CODE_DEST],
	[AL_CNTRY_CODE_DEST],
	DEST_FormattedAddress,
	DEST_AddrLatitude,
	DEST_AddrLongitude,
	DEST_AddrTrust,
	DEST_AddrConfidence,
	DEST_AddrAuthority,
	DEST_AddrValueSource,
	
	DEST_PostalLatitude,
	DEST_PostalLongitude,
	DEST_PostalTrust,
	DEST_PostalConfidence,
	DEST_PostalAuthority,
	DEST_PostalValueSource,
	
	DEST_PlaceLatitude,
	DEST_PlaceLongitude,
	DEST_PlaceTrust,
	DEST_PlaceConfidence,
	DEST_PlaceAuthority,
	DEST_PlaceValueSource,
	
	DEST_AddrHash,
	DEST_RecordDtmUTC,
		
	--Weight Component
	FB_ACTUAL_WT,
	FbActualWt_Trust = null,
	FbActualWt_Confidence = null,
	FbActualWt_Authority = null,
	FbActualWt_ValueSource = null,
	
	FB_FNCL_WT,
	FbFnclWt_Trust = null,
	FbFnclWt_Confidence = null,
	FbFnclWt_Authority = null,
	FbFnclWt_ValueSource = null,
		
	FB_WT_QUAL,
	FbWtQual_Trust = null,
	FbWtQual_Confidence = null,
	FbWtQual_Authority = null,
	FbWtQual_ValueSource = null,
		
	Mass_Trust = null,
	Mass_Confidence = null,
	Mass_Authority = null,
	Mass_ValueSource = null,
			
	fb.FB_ID, fb.Inv_ID, fb.OWNER_KEY, fb.VEND_LABL, fb.FB_STAT, fb.Inv_Key, fb.FB_KEY
	from fact.FrghtBl_MultiClient_Base fb
	left join factFlow.FbFlowNorm flow with (nolock) 
		on fb.FB_ID = flow.FB_ID 
