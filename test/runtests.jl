
using YearMonths
using CVMData
using Test

ym = YearMonths.YearMonth(2021,1)
quotes = CVMData.Funds.get_month_quotes(ym)
@test length(quotes) >= 0

ym = YearMonths.YearMonth(2050,1)
@test_throws BoundsError CVMData.Funds.get_month_quotes(ym)
