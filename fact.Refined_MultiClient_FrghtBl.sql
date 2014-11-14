
/*
	drop view fact.FrghtBlBase
	create schema fact

	select top 10 * from fact.Refined_MultiClient_FrghtBl
	where ORIG_AddrValueSource = 'Rules'
	where BAT_ID = 'BACH0000264020629350000'
	
	select * from A_Line
*/

IF OBJECT_ID(N'fact.Refined_MultiClient_FrghtBl') IS NOT NULL
    DROP view fact.Refined_MultiClient_FrghtBl
GO
CREATE VIEW fact.Refined_MultiClient_FrghtBl
AS
with AddrNorm_CTE(UntNId, UntTypeId, AddrTypeId, AddrType, InstNum,
	--RawName1, RawName2, RawStreet1, RawStreet2, RawPortStation, 
	--RawCity, RawStateProv, RawPostalCode, RawCountryCode, 
	--NormStreet1, NormStreet2, NormCity, NormStateProv, NormPostalCode, NormCountryCode, 
	--NormRegion, NormTerritory, NormFormattedAddress, NormLocationType, 
	Name1, Name2, 
	Street1, Street2, City, StateProv, PostalCode, CountryCode, 
	FormattedAddress, FormattedPlace,
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
							when PlaceTrust = 1 and PostalTrust = 1 then 
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
							when PlaceTrust = 0 and PostalTrust = 1 then 
								isnull(a.RawStreet1 + ',', '') +  
								isnull(a.RawStreet2 + ',', '') + 
								isnull(a.NormCity + ',', '') + 
								isnull(a.RawStateProv + ',', '') + 
								isnull(a.NormPostalCode + ',', '') + 
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
							
		FormattedPlace = case when AddrTrust = 1 AND PlaceTrust = 1 then 
								isnull(a.NormCity + ',', '') + 
								isnull(a.NormStateProv + ',', '') + 
								isnull(a.NormCountryCode, '')
						 else 
								isnull(a.RawCity + ',', '') + 
								isnull(a.RawStateProv + ',', '') + 
								isnull(a.RawCountryCode, '')
						END,
							
		
		
		a.AddrLatitude,
		a.AddrLongitude,
		a.AddrTrust,
		a.AddrConfidence,
		a.AddrAuthority,
		AddrValueSource =case when a.AddrTrust = 1 
							then 'Refinery'
							else 'Rules' end,
		
		a.PostalLatitude,
		a.PostalLongitude,
		a.PostalTrust,
		a.PostalConfidence,
		a.PostalAuthority,
		PostalCodeValueSource =case when a.AddrTrust = 1 or a.PostalTrust = 1 
							then 'Refinery'
							else 'Rules' end,
							
		a.PlaceLatitude,
		a.PlaceLongitude,
		a.PlaceTrust,
		a.PlaceConfidence,
		a.PlaceAuthority,
		PlaceValueSource =case when a.AddrTrust = 1 or a.PostalTrust = 1 or a.PlaceTrust = 1 
							then 'Refinery'
							else 'Rules' end,
		
		a.AddrHash,
		a.RecordDtmUTC		
	FROM dbo.AddrRaw r with(nolock) 
	left join DNorm.AddrRawToAddrNormAtom j on r.LocalUntNId = j.UntNId and r.UntTypeId = j.UntTypeId and r.AddrTypeId = j.AddrTypeId and r.InstNum = j.InstNum
	left join dbo.AddrType t on r.AddrTypeId = t.AddrTypeId
	left join DNorm.AddrNormAtom a on j.AddrHash = a.AddrHash
	WHERE r.UntTypeId = 3 --FB level addresses
)

--select * from AddrNorm_CTE;

select
		fb.FB_ID,
		FBNID = ext.fbnid,      
		fb.OWNER_KEY,		
		FB_VOID_FLAG,FB_PARENT_ID,fb.INV_ID,fb.BAT_ID,fb.BAT_KEY,
		
		--LSPName
		LspOrgId, LspOrgName, LspOrgTrust, LspOrgConfidence, LspOrgAuthority, LspOrgDtmUtc,
		--Data oriented flow
		DataSourceName, DataSourceTrust, DataSourceConfidence, DataSourceAuthority, DataSourceDtmUtc,
		TransType,TransTypeTrust,TransTypeConfidence,TransTypeAuthority,TransTypeDtmUtc,
		--Flow components
		BusinessFlow, BusinessFlowTrust, BusinessFlowConfidence, BusinessFlowAuthority, BusinessFlowDtmUtc,
		ExecPath,ExecPathTrust,ExecPathConfidence,ExecPathAuthority,ExecPathDtmUtc,
					
		--ShipFrom Geo Component
		[AL_ORIG_1] = [AL_ORIG_1],
		[AL_ORIG_2] = [AL_ORIG_2],
		[AL_ORIG_3] = case when sf.UntNId is not null then sf.Street1 else [AL_ORIG_3] end,
		[AL_ORIG_4] = case when sf.UntNId is not null then sf.Street2 else [AL_ORIG_4] end,
		[AL_CITY_ORIG] = case when sf.UntNId is not null then sf.City else [AL_CITY_ORIG] end,
		[AL_STATE_PROV_ORIG] = case when sf.UntNId is not null then sf.StateProv else [AL_STATE_PROV_ORIG] end,
		[AL_POST_CODE_ORIG] = case when sf.UntNId is not null then sf.PostalCode else [AL_POST_CODE_ORIG] end,
		[AL_CNTRY_CODE_ORIG] = case when sf.UntNId is not null then sf.CountryCode else [AL_CNTRY_CODE_ORIG] end,
		
		ORIG_FormattedAddress = case when sf.UntNId is not null then sf.FormattedAddress
								else 
								isnull([AL_ORIG_3] + ',', '') +  
								isnull([AL_ORIG_4] + ',', '') + 
								isnull([AL_CITY_ORIG] + ',', '') + 
								isnull([AL_STATE_PROV_ORIG] + ',', '') + 
								isnull([AL_POST_CODE_ORIG] + ',', '') + 
								isnull([AL_CNTRY_CODE_ORIG], '') 
								end,
		ORIG_FormattedPlace = case when sf.UntNId is not null then sf.FormattedPlace
								else 
								isnull([AL_CITY_ORIG] + ',', '') + 
								isnull([AL_STATE_PROV_ORIG] + ',', '') + 
								isnull([AL_CNTRY_CODE_ORIG], '') 
								end,
								
		ORIG_AddrLatitude = sf.AddrLatitude,
		ORIG_AddrLongitude = sf.AddrLongitude,
		ORIG_AddrTrust = sf.AddrTrust,
		ORIG_AddrConfidence = sf.AddrConfidence,
		ORIG_AddrAuthority = sf.AddrAuthority,
		ORIG_AddrValueSource = case when sf.UntNId is not null 
								then sf.AddrValueSource 
							else 'Rules' end,
		
		ORIG_PostalLatitude = sf.PostalLatitude,
		ORIG_PostalLongitude = sf.PostalLongitude,
		ORIG_PostalTrust = sf.PostalTrust,
		ORIG_PostalConfidence = sf.PostalConfidence,
		ORIG_PostalAuthority = sf.PostalAuthority,
		ORIG_PostalValueSource = case when sf.UntNId is not null then sf.PostalValueSource else 'Legacy' end,
		
		ORIG_PlaceLatitude = sf.PlaceLatitude,
		ORIG_PlaceLongitude = sf.PlaceLongitude,
		ORIG_PlaceTrust = sf.PlaceTrust,
		ORIG_PlaceConfidence = sf.PlaceConfidence,
		ORIG_PlaceAuthority = sf.PlaceAuthority,
		ORIG_PlaceValueSource = case when sf.UntNId is not null then sf.PlaceValueSource else 'Legacy' end,
				
		ORIG_AddrHash = sf.AddrHash,
		ORIG_RecordDtmUTC = sf.RecordDtmUTC,
		
		--RemitTo Component
		[AL_DEST_1] = [AL_DEST_1],
		[AL_DEST_2] = [AL_DEST_2], 
		[AL_DEST_3] = case when st.UntNId is not null then st.Street1 else [AL_DEST_3] end,
		[AL_DEST_4] = case when st.UntNId is not null then st.Street2 else [AL_DEST_4] end,
		[AL_CITY_DEST] = case when st.UntNId is not null then st.City else [AL_CITY_DEST] end,
		[AL_STATE_PROV_DEST] = case when st.UntNId is not null then st.StateProv else [AL_STATE_PROV_DEST] end,
		[AL_POST_CODE_DEST] = case when st.UntNId is not null then st.PostalCode else [AL_POST_CODE_DEST] end,
		[AL_CNTRY_CODE_DEST] = case when st.UntNId is not null then st.CountryCode else [AL_CNTRY_CODE_DEST] end,
				
		DEST_FormattedAddress = case when st.UntNId is not null then st.FormattedAddress
								else 
								isnull([AL_DEST_3] + ',', '') +  
								isnull([AL_DEST_4] + ',', '') + 
								isnull([AL_CITY_DEST] + ',', '') + 
								isnull([AL_STATE_PROV_DEST] + ',', '') + 
								isnull([AL_POST_CODE_DEST] + ',', '') + 
								isnull([AL_CNTRY_CODE_DEST], '') 
								end,	
		DEST_FormattedPlace = case when st.UntNId is not null then st.FormattedPlace
								else 
								isnull([AL_CITY_DEST] + ',', '') + 
								isnull([AL_STATE_PROV_DEST] + ',', '') + 								 
								isnull([AL_CNTRY_CODE_DEST], '') 
								end,
		DEST_AddrLatitude = st.AddrLatitude,
		DEST_AddrLongitude = st.AddrLongitude,
		DEST_AddrTrust = st.AddrTrust,
		DEST_AddrConfidence = st.AddrConfidence,
		DEST_AddrAuthority = st.AddrAuthority,
		DEST_AddrValueSource = case when st.UntNId is not null then st.AddrValueSource else 'Legacy' end,
		
		DEST_PostalLatitude = st.PostalLatitude,
		DEST_PostalLongitude = st.PostalLongitude,
		DEST_PostalTrust = st.PostalTrust,
		DEST_PostalConfidence = st.PostalConfidence,
		DEST_PostalAuthority = st.PostalAuthority,
		DEST_PostalValueSource = case when st.UntNId is not null then st.PostalValueSource else 'Legacy' end,
		
		DEST_PlaceLatitude = st.PlaceLatitude,
		DEST_PlaceLongitude = st.PlaceLongitude,
		DEST_PlaceTrust = st.PlaceTrust,
		DEST_PlaceConfidence = st.PlaceConfidence,
		DEST_PlaceAuthority = case when st.UntNId is not null then st.PlaceAuthority else 'Legacy' end,
		DEST_PlaceValueSource = st.PlaceValueSource,
		
		DEST_AddrHash = st.AddrHash,
		DEST_RecordDtmUTC = st.RecordDtmUTC,
		
		--Weight Component
		FB_ACTUAL_WT,
		FbActualWtTrust = null,
		FbActualWtConfidence = null,
		FbActualWtAuthority = null,
		FbActualWtValueSource = null,
		
		FB_FNCL_WT,
		FbFnclWtTrust = null,
		FbFnclWtConfidence = null,
		FbFnclWtAuthority = null,
		FbFnclWtValueSource = null,
		
		FB_WT_QUAL,
		FbWtQualTrust = null,
		FbWtQualConfidence = null,
		FbWtQualAuthority = null,
		FbWtQualValueSource = null,
		
		ActualWeightTrust = null,
		ActualWeightConfidence = null,
		ActualWeightAuthority = null,
		ActualWeightValueSource = null,
		
		FinancialWeightTrust = null,
		FinancialWeightConfidence = null,
		FinancialWeightAuthority = null,
		FinancialWeightValueSource = null,
		
					
		FB_DIM_WT,
		FB_BRK_PT_WT,
		
		--Payment Term Component
		FB_PAYMT_TERMS_CODE,
		PaymentTermCodeTrust = null, 
		PaymentTermCodeConfidence = null,
		PaymentTermCodeAuthority = null,
		PaymentTermCodeDtmUtc = null,
		
		--Legacy Fields
		FB_KEY,VEND_FB_TYPE,FB_TYPE
		INV_KEY,FB_CLASS,
		FB_STAT,FB_LN_CNT,FB_AMT,FB_FRGHT_AMT,FB_DSCNT_AMT,
		FB_ACC_AMT,FB_TAX_AMT,FB_CURRENCY_QUAL,FB_RPT_FACTOR,
		TX_FB_AMT,TX_FB_FRGHT_AMT,TX_FB_DSCNT_AMT,TX_FB_ACC_AMT,
		TX_FB_TAX_AMT,TX_FB_TAX_PCNT,TX_FB_CURRENCY_QUAL,
		TX_FB_RPT_FACTOR,FB_APP_AMT,FB_APP_FRGHT_AMT,FB_APP_DSCNT_AMT,
		FB_APP_ACC_AMT,FB_APP_TAX_AMT,FB_APP_TAX_PCNT,FB_APP_CURRENCY_QUAL,
		FB_APP_RPT_FACTOR,FB_ADJM_AMT,FB_ADJM_REASON,FB_ADJM_DESC,
		FB_PD_AMT,FB_CREDIT_AMT,FB_DISPUTE_AMT,FB_OPEN_AMT,
		FB_TERMS,FB_CREAT_DTM,FB_DUE_DTM,
		FB_ADJM_CNT,FB_PAYMT_CNT,FB_PKG_TYPE,FB_PCS_CNT,
		BUNDLE_NUM,TX_SHPMT_ID,VEND_LABL,SRVC_REQ_CODE,
		VEND_SRVC_NAME,VEND_COMMIT_CODE,VEND_SRVC_GUAR_CODE,
		VEND_TARIFF,VEND_RATE_SCALE,CA_INFO_1_RAW,CA_INFO_2_RAW,
		BOL_1_RAW,BOL_NUM_KEY,ACCT_NUM_VEND_BLNG,ACCT_NUM_VEND_ORIG,
		ACCT_NUM_VEND_DEST,LOC_ID_ORIG,LOC_KEY_ORIG,AL_ORIG_QUAL,
		
		AL_PHONE_NUM_ORIG,AL_PHONE_EXT_ORIG,LOC_ID_DEST,
		LOC_KEY_DEST,AL_DEST_QUAL,
		
		AL_PHONE_NUM_DEST,AL_PHONE_EXT_DEST,
		ENT_TYPE_BLNG,LOC_ID_BLNG,LOC_KEY_BLNG,ENT_TYPE_SHPR,
		LOC_ID_SHPR,LOC_KEY_SHPR,ENT_TYPE_CONS,LOC_ID_CONS,
		LOC_KEY_CONS,
		
		FB_DECL_AMT,TX_FB_DIM_WT,TX_FB_BRK_PT_WT,
		TX_FB_FNCL_WT,TX_FB_WT_QUAL,TX_FB_BASE_RATE,FB_PENDING_REASON,
		FB_PENDING_REASON_DESC,INTERLINE_SCAC,INTERLINE_QUAL,
		INTERLINE_AMT,PRICE_LANE_LABL,LM_LANE_LABL,LM_REQ_KEY,
		LM_DIST,LM_DIST_QUAL,TX_LM_DIST,TX_LM_DIST_QUAL,
		TX_LM_TYPE,TX_LM_DIR,LM_TRANSIT_STAT,LM_RDY_DTM,
		LM_PKUP_BY_DTM,LM_DLVRY_REQ_DTM,LM_PKUP_ACTUAL_DTM,
		LM_PKUP_VARNC_LABL,LM_PKUP_VARNC_REASON,LM_ETA_DTM,
		LM_ATA_DTM,LM_FIRST_DLVRY_DTM,[LM_ATA/ETA_VARNC_LABL],
		[LM_ATA/ETA_VARNC_REASON],POD_SIGN_BY,FB_DU_FLAG,
		FORCE_FA_EX_FLAG,RULE_MP_WINNER,RULE_DU_WINNER,RULE_LM_WINNER,
		RULE_ORIG_WINNER,RULE_DEST_WINNER,RULE_BOL_WINNER,RULE_RT_WINNER,
		RULE_FA_WINNER,RULE_CA_WINNER,RULE_BL_WINNER,
		[%T001],[%T002],[%T003],[%T004],[%T005],[%T006],[%T007],
		[%T008],[%T009],[%T010],[%T011],[%T012],[%T013],[%T014],
		[%T015],[%T016],[%T017],[%T018],[%T019],[%T020],
		MSG_GRP_NUM,
		CURR_ENV,EX_DTL_INFO,FB_RECYCLE_FROM_ID,FB_RECYCLE_REASON_INFO,DENIED_FLAG,DENIAL_ENV,DENIAL_PHASE,FB_KEY_PFX,FB_KEY_BASE,FB_KEY_SFX,FB_DUP_PATTERN,FB_DUP_TYPE,FB_DUP_RSLT,FB_DUP_MANUAL_RSLT,  
		FB_DUP_CAP_APP_AMT,FB_DUP_ADJM_REASON,FB_DUP_ADJM_DESC,TRANS_TYPE,MODE,MODE_TYPE,SRVC_LVL,SRVC_SCOPE,ROLE_ORIG,ROLE_ORIG_RULE,PORT_ORIG,ROUTE_CITY_ORIG,ROUTE_STATE_PROV_ORIG,ROUTE_CNTRY_CODE_ORIG,ROLE_DEST,ROLE_DEST_RULE,  
		PORT_DEST,ROUTE_CITY_DEST,ROUTE_STATE_PROV_DEST,ROUTE_CNTRY_CODE_DEST,BUSINESS_UNIT,BUSINESS_UNIT_RULE,BUSINESS_FLOW,BUSINESS_PROGRAM,DIRECT_INDIRECT_CODE,INTRA_STATE_PROV_FLAG,INTER_STATE_PROV_FLAG,INTERNATIONAL_FLAG,  
		INCO_TERMS,CONTRACT_NUM,TX_PAYMT_TERMS_CODE,SUPPLY_CHAIN_ARC,SHPMT_PURP_TYPE,SHPMT_PURP,CA_MODEL,CA_RULE,GL_MODEL,GL_RULE,ASN_WT,ASN_WT_QUAL,ASN_RATED_AMT,ASN_RATED_CURRENCY_QUAL,PAYMT_RESP_LOC_ID,BLNG_GRP_KEY,BLNG_GRP_FB_ID,BM_ENTITY,  
		BM_SUB_ENTITY,BM_DIV,BM_SUB_DIV,OM_ORG,OM_AREA,OM_GRP,OM_DEPT,OM_TEAM,VEND_SRVC_CODE,VEND_SRVC_SCOPE,VEND_SRVC_TYPE,VEND_SRVC_ZONE,VEND_SRVC_ZONE_ORIG,VEND_SRVC_ZONE_DEST,VEND_SUPPLY_CHAIN_SRVC,CUST_SRVC_CODE,CUST_SRVC_NAME,CUST_MODE,  
		DIM_DATA,DIM_UOM,DIM_FACTOR,VOL,VOL_UOM,LOAD_METER,EXCH_RATE,EXCH_DATE,ext.PAYMT_DSCNT_REASON_CODE,ext.PAYMT_DSCNT_REASON_DESC,ext.SPOT_QUOTE_KEY,ext.SPOT_QUOTE_AMT,ext.SPOT_QUOTE_CURRENCY_QUAL,ext.AUTH_KEY,ext.IMG_PAGE_NUM,ext.IMG_PAGE_CNT
		
		--INV_KEY,
		
		--FB_CLASS, FB_STAT, FB_LN_CNT, FB_AMT, FB_FRGHT_AMT, FB_DSCNT_AMT, FB_ACC_AMT, FB_TAX_AMT,
  --      FB_KEY,VEND_FB_TYPE,FB_TYPE,FB_CURRENCY_QUAL,FB_APP_CURRENCY_QUAL,FB_APP_RPT_FACTOR,FB_ADJM_AMT,FB_ADJM_REASON,FB_ADJM_DESC,FB_TERMS,  
		--FB_PAYMT_TERMS_CODE,FB_CREAT_DTM,FB_DUE_DTM,FB_PAYMT_CNT,FB_PKG_TYPE,FB_PCS_CNT,BUNDLE_NUM,TX_SHPMT_ID,fb.VEND_LABL,SRVC_REQ_CODE,VEND_SRVC_NAME,VEND_COMMIT_CODE,VEND_SRVC_GUAR_CODE,VEND_TARIFF,VEND_RATE_SCALE,  
		--  CA_INFO_1_RAW,CA_INFO_2_RAW,BOL_1_RAW,BOL_NUM_KEY,fb.ACCT_NUM_VEND_BLNG,ACCT_NUM_VEND_ORIG,ACCT_NUM_VEND_DEST,
		--  LOC_ID_ORIG,LOC_KEY_ORIG,AL_ORIG_QUAL,
		--  AL_PHONE_NUM_ORIG,AL_PHONE_EXT_ORIG,
		--  LOC_ID_DEST,LOC_KEY_DEST,AL_DEST_QUAL,        
		--  AL_PHONE_NUM_DEST,AL_PHONE_EXT_DEST,ENT_TYPE_BLNG,fb.LOC_ID_BLNG,fb.LOC_KEY_BLNG,ENT_TYPE_SHPR,LOC_ID_SHPR,LOC_KEY_SHPR,ENT_TYPE_CONS,LOC_ID_CONS,LOC_KEY_CONS,
		--  FB_DECL_AMT,  
		--  INTERLINE_SCAC,INTERLINE_QUAL,INTERLINE_AMT,PRICE_LANE_LABL,LM_LANE_LABL,LM_REQ_KEY,LM_DIST,LM_DIST_QUAL,LM_TRANSIT_STAT,LM_RDY_DTM,LM_PKUP_BY_DTM,LM_DLVRY_REQ_DTM,LM_PKUP_ACTUAL_DTM,LM_PKUP_VARNC_LABL,LM_PKUP_VARNC_REASON,  
		--  LM_ETA_DTM,LM_ATA_DTM,LM_FIRST_DLVRY_DTM,POD_SIGN_BY,[%T001],[%T002],[%T003],[%T004],[%T005],[%T006],[%T007],[%T008],[%T009],[%T010],[%T011],[%T012],[%T013],[%T014],[%T015],[%T016],[%T017],[%T018],[%T019],[%T020],      
	    
		--  CURR_ENV,EX_DTL_INFO,FB_RECYCLE_FROM_ID,FB_RECYCLE_REASON_INFO,DENIED_FLAG,DENIAL_ENV,DENIAL_PHASE,FB_KEY_PFX,FB_KEY_BASE,FB_KEY_SFX,FB_DUP_PATTERN,FB_DUP_TYPE,FB_DUP_RSLT,FB_DUP_MANUAL_RSLT,  
		--  FB_DUP_CAP_APP_AMT,FB_DUP_ADJM_REASON,FB_DUP_ADJM_DESC,TRANS_TYPE,MODE,MODE_TYPE,SRVC_LVL,SRVC_SCOPE,ROLE_ORIG,ROLE_ORIG_RULE,PORT_ORIG,ROUTE_CITY_ORIG,ROUTE_STATE_PROV_ORIG,ROUTE_CNTRY_CODE_ORIG,ROLE_DEST,ROLE_DEST_RULE,  
		--  PORT_DEST,ROUTE_CITY_DEST,ROUTE_STATE_PROV_DEST,ROUTE_CNTRY_CODE_DEST,BUSINESS_UNIT,BUSINESS_UNIT_RULE,BUSINESS_FLOW,BUSINESS_PROGRAM,DIRECT_INDIRECT_CODE,INTRA_STATE_PROV_FLAG,INTER_STATE_PROV_FLAG,INTERNATIONAL_FLAG,  
		--  INCO_TERMS,CONTRACT_NUM,TX_PAYMT_TERMS_CODE,SUPPLY_CHAIN_ARC,SHPMT_PURP_TYPE,SHPMT_PURP,CA_MODEL,CA_RULE,GL_MODEL,GL_RULE,ASN_WT,ASN_WT_QUAL,ASN_RATED_AMT,ASN_RATED_CURRENCY_QUAL,PAYMT_RESP_LOC_ID,BLNG_GRP_KEY,BLNG_GRP_FB_ID,BM_ENTITY,  
		--  BM_SUB_ENTITY,BM_DIV,BM_SUB_DIV,OM_ORG,OM_AREA,OM_GRP,OM_DEPT,OM_TEAM,VEND_SRVC_CODE,VEND_SRVC_SCOPE,VEND_SRVC_TYPE,VEND_SRVC_ZONE,VEND_SRVC_ZONE_ORIG,VEND_SRVC_ZONE_DEST,VEND_SUPPLY_CHAIN_SRVC,CUST_SRVC_CODE,CUST_SRVC_NAME,CUST_MODE,  
		--  DIM_DATA,DIM_UOM,DIM_FACTOR,VOL,VOL_UOM,LOAD_METER,EXCH_RATE,EXCH_DATE,ext.PAYMT_DSCNT_REASON_CODE,ext.PAYMT_DSCNT_REASON_DESC,ext.SPOT_QUOTE_KEY,ext.SPOT_QUOTE_AMT,ext.SPOT_QUOTE_CURRENCY_QUAL,ext.AUTH_KEY,ext.IMG_PAGE_NUM,ext.IMG_PAGE_CNT
      
      --Aline
      --,CNTXT
    FROM dbo.OutFRGHT_BL fb with(nolock) 
    LEFT JOIN dbo.OutFRGHT_BL_EXT ext with(nolock) on fb.FB_ID = ext.FB_ID
    left join factFlow.FbFlowNorm flow with (nolock) 
		on fb.FB_ID = flow.FB_ID 
    --LEFT JOIN dbo.A_LINE aline with(nolock) on aline.UNT_ID = fb.FB_ID
    LEFT JOIN dbo.Invoice_Ext invext with(nolock) on fb.INV_ID = invext.INV_ID
    LEFT JOIN [DNorm].[InvNorm] invNorm with(nolock) on invNorm.invnid = invext.invnid
    LEFT JOIN AddrNorm_CTE sf  with(nolock) on ext.FBNID = sf.UntNId and sf.UntTypeId = 3 and sf.AddrTypeId = 12
    LEFT JOIN AddrNorm_CTE st with(nolock) on ext.FBNID = st.UntNId and st.UntTypeId = 3 and st.AddrTypeId = 13
     --WHERE fb.FB_ID like 'FBLL__0%'
	;