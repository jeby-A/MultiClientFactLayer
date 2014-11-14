--select * from fact.Operation_MultiClient_InvDoc_FbGeo

IF OBJECT_ID(N'fact.Operation_MultiClient_InvDoc_FbGeo') IS NOT NULL
    DROP view fact.Operation_MultiClient_InvDoc_FbGeo
GO
CREATE VIEW fact.Operation_MultiClient_InvDoc_FbGeo
AS
SELECT
		FactLayerName = 'Operation - Inv Doc Fb Geo', 
		FactLayerTrust = null,
		FactLayerConfidence = null,
		FactLayerAuthority = null,
		FactLayerDtmUtc = null,
		
		geo.Street1, geo.Street2, geo.City, geo.StateProv, geo.PostalCode, geo.CountryCode, 
		geo.FormattedAddress, geo.FormattedPlace, geo.FormattedPostalCode,	
		geo.AddrLatitude, geo.AddrLongitude, geo.AddrTrust, geo.AddrConfidence, geo.AddrAuthority, geo.AddrValueSource,
		geo.PostalLatitude, geo.PostalLongitude, geo.PostalTrust, geo.PostalConfidence, geo.PostalAuthority, PostalValueSource,
		geo.PlaceLatitude, geo.PlaceLongitude, geo.PlaceTrust, geo.PlaceConfidence, geo.PlaceAuthority, PlaceValueSource,	
		geo.AddrHash, geo.RecordDtmUTC,
		
		--Reference fields
		--Reference fields
		fb.DataSourceName,
		fb.DataSourceTrust,
		fb.DataSourceConfidence,
		fb.DataSourceAuthority,
		fb.DataSourceDtmUtc,
		
		fb.FB_ID, 
		fb.OWNER_KEY,		
		
		fb.VEND_LABL, 
		fb.Inv_Key,
		fb.Fb_Key,	
		
		MappedStreet1 = mappedGeo.Street1, 
		MappedStreet2 = mappedGeo.Street2, 
		MappedPortStation = mappedGeo.PortStation,
		MappedCity = mappedGeo.City, 
		MappedStateProv = mappedGeo.StateProv, 
		MappedPostalCode = mappedGeo.PostalCode, 
		MappedCountryCode = mappedGeo.CountryCode,
		
		MappedFormattedAddress =  mappedGeo.FormattedAddress,		
		MappedFormattedPlacePostalCode = mappedGeo.FormattedPlacePostalCode		
FROM fact.Mapped_MultiClient_InvDocGeo mappedGeo
LEFT JOIN fact.Refined_MultiClient_FrghtBl fb
	on mappedGeo.UntNId = fb.FbNId
LEFT JOIN fact.Refined_MultiClient_InvDocGeo geo 
 on mappedGeo.UntNId = geo.UntNId and 
    mappedGeo.UntTypeId = geo.UntTypeId and
    mappedGeo.AddrTypeId = geo.AddrTypeId and
    mappedGeo.InstNum = geo.InstNum
WHERE mappedGeo.AddrTypeId in (12,13)