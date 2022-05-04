
using YearMonths
using CVMData
using Test
using Downloads

ym = YearMonths.YearMonth(2022,5)
quotes = CVMData.Funds.get_month_quotes(ym)
@info("got $(length(quotes)) quotes for $ym")
@test length(quotes) > 0
@show quotes[1:10]

ym = YearMonths.YearMonth(2022,4)
quotes = CVMData.Funds.get_month_quotes(ym)
@info("got $(length(quotes)) quotes for $ym")
@test length(quotes) > 0
@show quotes[1:10]

ym = YearMonths.YearMonth(2019,1)
quotes = CVMData.Funds.get_month_quotes(ym)
@info("got $(length(quotes)) quotes for $ym")
@test length(quotes) > 0
@show quotes[1:10]

ym = YearMonths.YearMonth(2020,4)
quotes = CVMData.Funds.get_month_quotes(ym)
@info("got $(length(quotes)) quotes for $ym")
@test length(quotes) > 0
@show quotes[1:10]

ym = YearMonths.YearMonth(2021,1)
quotes = CVMData.Funds.get_month_quotes(ym)
@info("got $(length(quotes)) quotes for $ym")
@test length(quotes) > 0
@show quotes[1:10]

ym = YearMonths.YearMonth(2999,1)
@test_throws Downloads.RequestError CVMData.Funds.get_month_quotes(ym)
