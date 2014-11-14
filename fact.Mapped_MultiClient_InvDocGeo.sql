
/*
	select * from fact.Mapped_InvDocGeo
	order by UNTNID, UNTTYPEID, AddrTypeId
*/

IF OBJECT_ID(N'fact.Mapped_MultiClient_InvDocGeo') IS NOT NULL
    DROP view fact.Mapped_MultiClient_InvDocGeo
GO
CREATE VIEW fact.Mapped_MultiClient_InvDocGeo
AS
with AddrRaw_CTE(UntNId, UntTypeId, AddrTypeId, AddrType, InstNum,
	--RawName1, RawName2, RawStreet1, RawStreet2, RawPortStation, 
	--RawCity, RawStateProv, RawPostalCode, RawCountryCode, 
	--NormStreet1, NormStreet2, NormCity, NormStateProv, NormPostalCode, NormCountryCode, 
	--NormRegion, NormTerritory, NormFormattedAddress, NormLocationType, 
	Street1, Street2, PortStation, City, StateProv, PostalCode, CountryCode, 
	FormattedAddress, FormattedPlacePostalCode)
	AS 	
	(SELECT
		r.LocalUntNId as UntNId,
		r.UntTypeId,
		r.AddrTypeId,
		t.AddrType,
		r.InstNum,
		--Name1 = r.AddrLine1,
		--Name2 = r.AddrLine2, 
		AddrLine3,
		AddrLine4,
		PortStation,
		PlaceName,
		StateProv,
		PostalCode,
		Country,
		
		FormattedAddress = isnull(AddrLine3 + ',', '') +  
								isnull(AddrLine4 + ',', '') + 
								isnull(PlaceName + ',', '') + 
								isnull(StateProv + ',', '') + 
								isnull(PostalCode + ',', '') + 
								isnull(Country, ''),
							
		FormattedPlacePostalCode = isnull(PlaceName + ',', '') + 
								isnull(StateProv + ',', '') + 
								isnull(PostalCode + ',', '') + 
								isnull(Country, '')									
	FROM dbo.AddrRaw r with(nolock)
	left join dbo.AddrType t on r.AddrTypeId = t.AddrTypeId
	WHERE r.AddrTypeId in(1,2,12,13) --FB level addresses	
	/*union 
	 SELECT 
		UntNId = FbNId,
		UntTypeId = 3, --fb level
		AddrTypeId = 12,
		AddrType = 'ShipFrom',
		InstNum = 1,
		
		AddrLine3 = AL_ORIG_3,
		AddrLine4 = AL_ORIG_4,
		PortStation = null,
		PlaceName = AL_CITY_ORIG,
		StateProv = AL_STATE_PROV_ORIG,
		PostalCode = AL_POST_CODE_ORIG,
		Country = AL_CNTRY_CODE_ORIG,
		
		FormattedAddress = isnull(AL_ORIG_3 + ',', '') +  
								isnull(AL_ORIG_4 + ',', '') + 
								isnull(AL_CITY_ORIG + ',', '') + 
								isnull(AL_STATE_PROV_ORIG + ',', '') + 
								isnull(AL_POST_CODE_ORIG + ',', '') + 
								isnull(AL_CNTRY_CODE_ORIG, ''),
							
		FormattedPlacePostalCode = isnull(AL_CITY_ORIG + ',', '') + 
								isnull(AL_STATE_PROV_ORIG + ',', '') + 
								isnull(AL_POST_CODE_ORIG + ',', '') + 
								isnull(AL_CNTRY_CODE_ORIG, '')								
		FROM fact.Mapped_MultiClient_FrghtBl
	UNION
		SELECT 
		UntNId = FbNId,
		UntTypeId = 3, --fb level
		AddrTypeId = 13,
		AddrType = 'ShipTo',
		InstNum = 1,
		
		AddrLine3 = AL_DEST_3,
		AddrLine4 = AL_DEST_4,
		PortStation = null,
		PlaceName = AL_CITY_DEST,
		StateProv = AL_STATE_PROV_DEST,
		PostalCode = AL_POST_CODE_DEST,
		Country = AL_CNTRY_CODE_DEST,
		
		FormattedAddress = isnull(AL_DEST_3 + ',', '') +  
								isnull(AL_DEST_4 + ',', '') + 
								isnull(AL_CITY_DEST + ',', '') + 
								isnull(AL_STATE_PROV_DEST + ',', '') + 
								isnull(AL_POST_CODE_DEST + ',', '') + 
								isnull(AL_CNTRY_CODE_DEST, ''),
							
		FormattedPlacePostalCode = isnull(AL_CITY_DEST + ',', '') + 
								isnull(AL_STATE_PROV_DEST + ',', '') + 
								isnull(AL_POST_CODE_DEST + ',', '') + 
								isnull(AL_CNTRY_CODE_DEST, '')						
		FROM fact.Mapped_MultiClient_FrghtBl
	UNION
		SELECT 
		UntNId = InvNId,
		UntTypeId = 2, --inv level
		AddrTypeId = 1,
		AddrType = 'InvBillTo',
		InstNum = 1,
		
		AddrLine3 = AL_BLNG_3,
		AddrLine4 = AL_BLNG_4,
		PortStation = null,
		PlaceName = AL_CITY_BLNG,
		StateProv = AL_STATE_PROV_BLNG,
		PostalCode = AL_POST_CODE_BLNG,
		Country = AL_CNTRY_CODE_BLNG,
		
		FormattedAddress = isnull(AL_BLNG_3 + ',', '') +  
								isnull(AL_BLNG_4 + ',', '') + 
								isnull(AL_CITY_BLNG + ',', '') + 
								isnull(AL_STATE_PROV_BLNG + ',', '') + 
								isnull(AL_POST_CODE_BLNG + ',', '') + 
								isnull(AL_CNTRY_CODE_BLNG, ''),
							
		FormattedPlacePostalCode = isnull(AL_CITY_BLNG + ',', '') + 
								isnull(AL_STATE_PROV_BLNG + ',', '') + 
								isnull(AL_POST_CODE_BLNG + ',', '') + 
								isnull(AL_CNTRY_CODE_BLNG, '')						
		FROM fact.Mapped_MultiClient_Invoice	
	UNION
		SELECT 
		UntNId = InvNId,
		UntTypeId = 2, --inv level
		AddrTypeId = 2,
		AddrType = 'InvRemitTo',
		InstNum = 1,
		
		AddrLine3 = AL_REMIT_3,
		AddrLine4 = AL_REMIT_4,
		PortStation = null,
		PlaceName = AL_CITY_REMIT,
		StateProv = AL_STATE_PROV_REMIT,
		PostalCode = AL_POST_CODE_REMIT,
		Country = AL_CNTRY_CODE_REMIT,
		
		FormattedAddress = isnull(AL_REMIT_3 + ',', '') +  
								isnull(AL_REMIT_4 + ',', '') + 
								isnull(AL_CITY_REMIT + ',', '') + 
								isnull(AL_STATE_PROV_REMIT + ',', '') + 
								isnull(AL_POST_CODE_REMIT + ',', '') + 
								isnull(AL_CNTRY_CODE_REMIT, ''),
							
		FormattedPlacePostalCode = isnull(AL_CITY_REMIT + ',', '') + 
								isnull(AL_STATE_PROV_REMIT + ',', '') + 
								isnull(AL_POST_CODE_REMIT + ',', '') + 
								isnull(AL_CNTRY_CODE_REMIT, '')				
		FROM fact.Mapped_MultiClient_Invoice	*/
)


	select * 
	from AddrRaw_CTE;
 