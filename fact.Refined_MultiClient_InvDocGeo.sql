
/*
	select * from fact.Refined_InvDocGeo
	where AddrTypeId = 2
*/

IF OBJECT_ID(N'fact.Refined_MultiClient_InvDocGeo') IS NOT NULL
    DROP view fact.Refined_MultiClient_InvDocGeo
GO
CREATE VIEW fact.Refined_MultiClient_InvDocGeo
AS
with AddrNorm_CTE(UntNId, UntTypeId, AddrTypeId, AddrType, InstNum,
	--RawName1, RawName2, RawStreet1, RawStreet2, RawPortStation, 
	--RawCity, RawStateProv, RawPostalCode, RawCountryCode, 
	--NormStreet1, NormStreet2, NormCity, NormStateProv, NormPostalCode, NormCountryCode, 
	--NormRegion, NormTerritory, NormFormattedAddress, NormLocationType, 
	--Name1, Name2, 
	Street1, Street2, City, StateProv, PostalCode, CountryCode, 
	FormattedAddress, FormattedPlace, FormattedPostalCode,	
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
		
		--Name1 = r.AddrLine1,
		--Name2 = r.AddrLine2, 
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
		FormattedPostalCode = case when AddrTrust = 1 AND PostalTrust = 1 then 
								isnull(a.NormCity + ',', '') + 
								isnull(a.NormPostalCode + ',', '') + 
								isnull(a.NormCountryCode, '')
						 else 
								isnull(a.RawCity + ',', '') + 
								isnull(a.RawPostalCode + ',', '') + 
								isnull(a.RawCountryCode, '')
						END,
		a.AddrLatitude,
		a.AddrLongitude,
		a.AddrTrust,
		a.AddrConfidence,
		a.AddrAuthority,
		AddrValueSource =case when a.AddrTrust = 1 then 'Normed-Google'
							else 'Raw' end,
		
		a.PostalLatitude,
		a.PostalLongitude,
		a.PostalTrust,
		a.PostalConfidence,
		a.PostalAuthority,
		PostalCodeValueSource =case when a.AddrTrust = 1 or a.PostalTrust = 1 then 'Normed-Google'
							else 'Raw' end,
							
		a.PlaceLatitude,
		a.PlaceLongitude,
		a.PlaceTrust,
		a.PlaceConfidence,
		a.PlaceAuthority,
		PlaceValueSource =case when a.AddrTrust = 1 or a.PostalTrust = 1 or a.PlaceTrust = 1 
							then 'Normed-Google'
							else 'Raw' end,
		
		a.AddrHash,
		a.RecordDtmUTC		
	FROM dbo.AddrRaw r with(nolock) 
	left join DNorm.AddrRawToAddrNormAtom j on r.LocalUntNId = j.UntNId and r.UntTypeId = j.UntTypeId and r.AddrTypeId = j.AddrTypeId and r.InstNum = j.InstNum
	left join dbo.AddrType t on r.AddrTypeId = t.AddrTypeId
	left join DNorm.AddrNormAtom a on j.AddrHash = a.AddrHash
	WHERE r.AddrTypeId in(1,2,12,13) --FB level addresses
)

	select * 
	from AddrNorm_CTE;
