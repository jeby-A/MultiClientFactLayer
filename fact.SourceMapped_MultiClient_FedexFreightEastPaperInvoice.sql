
/*
	create schema fact	
	go
	
	select * 
	from fact.SourceMapped_MultiClient_FedexFreightEastPaperInvoice
*/

IF OBJECT_ID(N'fact.SourceMapped_MultiClient_FedexFreightEastPaperInvoice') IS NOT NULL
    DROP view fact.SourceMapped_MultiClient_FedexFreightEastPaperInvoice
GO
create view fact.SourceMapped_MultiClient_FedexFreightEastPaperInvoice
AS
	SELECT
		[Send Payment To] = RemitTo_FormattedAddress,
		[Direct Billing Inqueries To] = null,
		[Direct Billing Inqueries To - Email] = null,
		[Direct Billing Inqueries To - Website] = null,
		[Direct Billing Inqueries To - Phone] = null,
		[Direct Billing Inqueries To - FAX] = null,
		[Direct Billing Inqueries To - Toll-Free] = null,
		
		[BillTo/Payment Due From] = BillTo_FormattedAddress,
		
		[Statement Number] = Inv_Key,
		[Customer Number] = ACCT_NUM_VEND_BLNG,
		[Statement Date] = Inv_Creat_DTM,
		[Total Statement Charges] = Vend_Inv_Amt,
		[Currency] = INV_CURRENCY_QUAL,
		[Invoice Type] = Inv_Type,		
		*
	FROM fact.Mapped_MultiClient_Invoice
	where LSPOrgName = 'Fedex Freight East' and DataSourceName = 'FedEx_Freight_Paper_Invoice'	
	