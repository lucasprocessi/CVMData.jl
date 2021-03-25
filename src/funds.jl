
module Funds

    using Dates
    import ..YearMonths
    import ..HTTP

    struct FundData
        fund_type::Union{String, Nothing}
        cnpj::String
        date::Date
        total_value::Float64
        quota_value::Float64
        net_worth::Float64
        deposits::Float64
        withdraws::Float64
        number_quota_holders::Int64
    end

    function get_month_quotes(ym::YearMonths.YearMonth)::Vector{FundData}
        @assert ym >= YearMonths.YearMonth(2017, 1)

        raw = _get_data(ym)

        out = Vector{FundData}()

        header = split(String(raw[1]), ";")

        for i in 2:length(raw)

            line = raw[i]

            if line == ""
                continue
            end

            s = split(String(line), ";")

            if ym <= YearMonths.YearMonth(2020,3)

                @assert length(s) == 8 "bad CVM data, this line should have 8 fields: $s"
                fund_type = nothing
                cnpj = String(s[1])
                date = Date(String(s[2]))
                total_value = parse(Float64, String(s[3]))
                quota_value = parse(Float64, String(s[4]))
                net_worth = parse(Float64, String(s[5]))
                deposits = parse(Float64, String(s[6]))
                withdraws = parse(Float64, String(s[7]))
                number_quota_holders = parse(Int64, String(s[8]))

            else
                # after 2020-03
                @assert length(s) == 9 "bad CVM data, this line should have 9 fields: $s"
                fund_type = String(s[1])
                cnpj = String(s[2])
                date = Date(String(s[3]))
                total_value = parse(Float64, String(s[4]))
                quota_value = parse(Float64, String(s[5]))
                net_worth = parse(Float64, String(s[6]))
                deposits = parse(Float64, String(s[7]))
                withdraws = parse(Float64, String(s[8]))
                number_quota_holders = parse(Int64, String(s[9]))

            end
            d = FundData(
                fund_type, cnpj, date,
                total_value, quota_value, net_worth,
                deposits, withdraws, number_quota_holders
            )
            push!(out, d)

        end

        return(out)
    end

    function _get_url(ym::YearMonths.YearMonth)::String
        str_year = "$(YearMonths.year(ym))"
        str_month = lpad("$(YearMonths.month(ym))", 2, "0")
        url = "http://dados.cvm.gov.br/dados/FI/DOC/INF_DIARIO/DADOS/inf_diario_fi_$str_year$str_month.csv"
        return url
    end

    function _get_data(ym::YearMonths.YearMonth)
        url = _get_url(ym)
        r = HTTP.get(url, status_exception = false)
        if r.status == 200
            return split(String(r.body), "\r\n")
        elseif r.status == 404
            throw(BoundsError("CVM fund data not found for $ym"))
        else
            error("error retrieving CVM fund data: $r")
        end
    end

end
