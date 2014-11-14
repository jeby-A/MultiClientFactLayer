
IF OBJECT_ID('tempdb..#FactLayerInvoiceHealth') IS NOT NULL DROP TABLE #FactLayerInvoiceHealth
create table #FactLayerInvoiceHealth
(
	[Inv_ID] varchar(23) not null,
	[InvNId] bigint not null,
	[OwnerKey] varchar(8) not null,
	[LSPOrgName] nvarchar(100) null,
	[DataSourceName] nvarchar(200) null,
	[Fact Layer Name] varchar(100) not null,	
	[Data Gap Definition]  varchar(400) not null,
	[Data Gap Level] varchar(20) not null,
	[Resolution Owner] varchar(50) null,
	[Data Gap Result] bit null	
)
GO	

INSERT INTO #FactLayerInvoiceHealth
select  
	Inv_ID,
	InvNId,
	Owner_Key,
	LSPOrgName,
	DataSourceName,
	[Fact Layer Name] = 'Source Fact Layer',	
	[Fact Name] = 'Direct Billing Inqueries To',
	[Data Gap Definition] = 'Source provides the data, check whether we key or mapped.',
	[Data Gap Level] = 'Medium',
	[Resolution Owner] = 'DataEntry',
	[Data Gap Result] = case when [Direct Billing Inqueries To] is null then 1 else 0 end	
	from fact.Source_FedexFreightEast_Paper_Invoice

select 
	LSPOrgName,
	DataSourceName, 
	OwnerKey,
	[Fact Layer Name],
	[Fact Name],
	[Data Gap Definition],
	[Data Gap Level],
	[Resolution Owner],
	[Data Gap Result],
	[Count] = COUNT(*)
from #FactLayerInvoiceHealth
GROUP BY LSPOrgName,
	DataSourceName, 
	OwnerKey,
	[Fact Layer Name],
	[Fact Name],
	[Data Gap Definition],
	[Data Gap Level],
	[Resolution Owner],
	[Data Gap Result]